package engines

import (
	"bytes"
	"context"
	"encoding/binary"
	"errors"
	"fmt"
	"sync"
	"time"

	"github.com/btcsuite/btcd/wire"
	zmq "github.com/pebbe/zmq4"
	"github.com/rs/zerolog"
)

// ZMQEngine receives raw, unconfirmed transactions from bitcoind via ZMQ.
// Processes them and broadcasts them to the rest of the system.
type ZMQ struct {
	txChan chan *wire.MsgTx

	inner *cribbedZmqEngine

	mu          sync.RWMutex
	subscribers []chan *wire.MsgTx
}

// NewZMQ creates a new ZMQ engine for receiving Bitcoin Core raw transaction notifications
func NewZMQ(endpoint string) (*ZMQ, error) {
	if endpoint == "" {
		return nil, errors.New("engines/zmq: endpoint is empty")
	}

	inner, err := NewZmqEngine(endpoint)
	if err != nil {
		return nil, err
	}

	return &ZMQ{
		inner:       inner,
		txChan:      make(chan *wire.MsgTx, 1000), // Buffer for high transaction volumes
		subscribers: make([]chan *wire.MsgTx, 0),
	}, nil
}

// Subscribe returns a channel that will receive new transactions
func (e *ZMQ) Subscribe() <-chan *wire.MsgTx {
	e.mu.Lock()
	defer e.mu.Unlock()

	subscriber := make(chan *wire.MsgTx, 100)
	e.subscribers = append(e.subscribers, subscriber)
	return subscriber
}

// Run starts the ZMQ engine and begins listening for raw transaction notifications
func (e *ZMQ) Run(ctx context.Context) error {
	logger := zerolog.Ctx(ctx)
	logger.Info().Msg("starting ZMQ engine for raw transactions")

	subCh, cancel, err := e.inner.SubscribeRawTx()
	if err != nil {
		return err
	}
	defer cancel()

	errChan := make(chan error, 1)

	go func() {
		for tx := range subCh {
			tx, err := decodeTransaction(tx.Serialized)
			if err != nil {
				errChan <- fmt.Errorf("error decoding raw transaction: %w", err)
				return
			}

			zerolog.Ctx(ctx).Trace().
				Msgf("received raw transaction: %s", tx.TxHash())
			e.txChan <- tx
		}
	}()

	// Start broadcaster for transaction subscribers
	go e.broadcastTransactions(ctx)

	// Wait for context cancellation or error
	select {
	case <-ctx.Done():
		logger.Info().Msg("ZMQ engine shutting down")
		return nil
	case err := <-errChan:

		if err != nil {
			return fmt.Errorf("ZMQ engine error: %w", err)
		}

		return nil
	}
}

// broadcastTransactions sends transactions to all subscribers
func (e *ZMQ) broadcastTransactions(ctx context.Context) {
	log := zerolog.Ctx(ctx).With().Str("component", "tx-broadcaster").Logger()
	log.Info().Msg("engines/zmq: starting transaction broadcaster")

	for {
		select {
		case <-ctx.Done():
			log.Info().Err(ctx.Err()).
				Msg("engines/zmq: stopping transaction broadcaster")

			// Close all subscriber channels
			e.mu.RLock()
			for _, subscriber := range e.subscribers {
				close(subscriber)
			}
			e.mu.RUnlock()
			return

		case tx := <-e.txChan:
			e.mu.RLock()
			for _, subscriber := range e.subscribers {
				select {
				case subscriber <- tx:
				default:
					log.Trace().
						Msgf("engines/zmq: subscriber channel full, dropping transaction for subscriber: %s",
							tx.TxHash())
				}
			}
			e.mu.RUnlock()
		}
	}
}

// decodeTransaction decodes a raw transaction from bytes
func decodeTransaction(rawTx []byte) (*wire.MsgTx, error) {
	var tx wire.MsgTx
	if err := tx.Deserialize(bytes.NewReader(rawTx)); err != nil {
		return nil, fmt.Errorf("deserialize transaction: %w", err)
	}
	return &tx, nil
}

type subscriptions struct {
	sync.RWMutex

	exited      chan struct{}
	zfront      *zmq.Socket
	latestEvent time.Time

	hashTx    [](chan HashMsg)
	hashBlock [](chan HashMsg)
	rawTx     [](chan RawMsg)
	rawBlock  [](chan RawMsg)
	sequence  [](chan SequenceMsg)
}

// HashMsg is a subscription event coming from a "hash"-type ZMQ message.
type HashMsg struct {
	Hash [32]byte // use encoding/hex.EncodeToString() to get it into the RPC method string format.
	Seq  uint32
}

// RawMsg is a subscription event coming from a "raw"-type ZMQ message.
type RawMsg struct {
	Serialized []byte // use encoding/hex.EncodeToString() to get it into the RPC method string format.
	Seq        uint32
}

// SequenceMsg is a subscription event coming from a "sequence" ZMQ message.
type SequenceMsg struct {
	Hash       [32]byte // use encoding/hex.EncodeToString() to get it into the RPC method string format.
	Event      SequenceEvent
	MempoolSeq uint64
}

// SequenceEvent is an enum describing what event triggered the sequence message.
type SequenceEvent int

const (
	Invalid            SequenceEvent = iota
	BlockConnected                   // Blockhash connected
	BlockDisconnected                // Blockhash disconnected
	TransactionRemoved               // Transactionhash removed from mempool for non-block inclusion reason
	TransactionAdded                 // Transactionhash added mempool
)

// This is cribbed from https://pkg.go.dev/github.com/satshub/go-bitcoind/zmq
type cribbedZmqEngine struct {
	endpoint string
	wg       sync.WaitGroup
	quit     chan struct{}

	// ZMQ subscription related things.
	zctx *zmq.Context
	zsub *zmq.Socket
	subs subscriptions
	// subs.zfront --> zback is used like a channel to send messages to the zmqHandler goroutine.
	// Have to use zmq sockets in place of native channels for communication from
	// other functions to the goroutine, since it is constantly waiting on the zsub socket,
	// it can't select on a channel at the same time but can poll on multiple sockets.
	zback *zmq.Socket
}

func NewZmqEngine(endpoint string) (*cribbedZmqEngine, error) {
	bc := &cribbedZmqEngine{
		endpoint: endpoint,
		quit:     make(chan struct{}),
	}

	// ZMQ Subscribe.

	zctx, err := zmq.NewContext()
	if err != nil {
		return nil, err
	}
	zsub, err := zctx.NewSocket(zmq.SUB)
	if err != nil {
		return nil, err
	}
	if err := zsub.Connect(endpoint); err != nil {
		return nil, err
	}
	zback, err := zctx.NewSocket(zmq.PAIR)
	if err != nil {
		return nil, err
	}
	if err := zback.Bind("inproc://channel"); err != nil {
		return nil, err
	}
	zfront, err := zctx.NewSocket(zmq.PAIR)
	if err != nil {
		return nil, err
	}
	if err := zfront.Connect("inproc://channel"); err != nil {
		return nil, err
	}

	bc.zctx = zctx
	bc.zsub = zsub
	bc.subs.exited = make(chan struct{})
	bc.subs.zfront = zfront
	bc.zback = zback

	bc.wg.Add(1)
	go bc.zmqHandler()

	return bc, nil
}

const channelSize = 100

func (bc *cribbedZmqEngine) zmqHandler() {
	defer bc.wg.Done()
	defer bc.zsub.Close()
	defer bc.zback.Close()

	poller := zmq.NewPoller()
	poller.Add(bc.zsub, zmq.POLLIN)
	poller.Add(bc.zback, zmq.POLLIN)
OUTER:
	for {
		// Wait forever until a message can be received or the context was cancelled.
		polled, err := poller.Poll(-1)
		if err != nil {
			break OUTER
		}

		for _, p := range polled {
			switch p.Socket {
			case bc.zsub:
				msg, err := bc.zsub.RecvMessage(0)
				if err != nil {
					break OUTER
				}
				bc.subs.latestEvent = time.Now()
				switch msg[0] {
				case "hashtx":
					var hashMsg HashMsg
					copy(hashMsg.Hash[:], msg[1])
					hashMsg.Seq = binary.LittleEndian.Uint32([]byte(msg[2]))
					bc.subs.RLock()
					for _, ch := range bc.subs.hashTx {
						select {
						case ch <- hashMsg:
						default:
							select {
							// Pop the oldest item and push the newest item (the user will miss a message).
							case <-ch:
								ch <- hashMsg
							case ch <- hashMsg:
							default:
							}
						}
					}
					bc.subs.RUnlock()
				case "hashblock":
					var hashMsg HashMsg
					copy(hashMsg.Hash[:], msg[1])
					hashMsg.Seq = binary.LittleEndian.Uint32([]byte(msg[2]))
					bc.subs.RLock()
					for _, ch := range bc.subs.hashBlock {
						select {
						case ch <- hashMsg:
						default:
							select {
							// Pop the oldest item and push the newest item (the user will miss a message).
							case <-ch:
								ch <- hashMsg
							case ch <- hashMsg:
							default:
							}
						}
					}
					bc.subs.RUnlock()
				case "rawtx":
					var rawMsg RawMsg
					rawMsg.Serialized = []byte(msg[1])
					rawMsg.Seq = binary.LittleEndian.Uint32([]byte(msg[2]))
					bc.subs.RLock()
					for _, ch := range bc.subs.rawTx {
						select {
						case ch <- rawMsg:
						default:
							select {
							// Pop the oldest item and push the newest item (the user will miss a message).
							case <-ch:
								ch <- rawMsg
							case ch <- rawMsg:
							default:
							}
						}
					}
					bc.subs.RUnlock()
				case "rawblock":
					var rawMsg RawMsg
					rawMsg.Serialized = []byte(msg[1])
					rawMsg.Seq = binary.LittleEndian.Uint32([]byte(msg[2]))
					bc.subs.RLock()
					for _, ch := range bc.subs.rawBlock {
						select {
						case ch <- rawMsg:
						default:
							select {
							// Pop the oldest item and push the newest item (the user will miss a message).
							case <-ch:
								ch <- rawMsg
							case ch <- rawMsg:
							default:
							}
						}
					}
					bc.subs.RUnlock()
				case "sequence":
					var sequenceMsg SequenceMsg
					copy(sequenceMsg.Hash[:], msg[1])
					switch msg[1][32] {
					case 'C':
						sequenceMsg.Event = BlockConnected
					case 'D':
						sequenceMsg.Event = BlockDisconnected
					case 'R':
						sequenceMsg.Event = TransactionRemoved
						sequenceMsg.MempoolSeq = binary.LittleEndian.Uint64([]byte(msg[1][33:]))
					case 'A':
						sequenceMsg.Event = TransactionAdded
						sequenceMsg.MempoolSeq = binary.LittleEndian.Uint64([]byte(msg[1][33:]))
					default:
						// This is a fault. Drop the message.
						continue
					}
					bc.subs.RLock()
					for _, ch := range bc.subs.sequence {
						select {
						case ch <- sequenceMsg:
						default:
							select {
							// Pop the oldest item and push the newest item (the user will miss a message).
							case <-ch:
								ch <- sequenceMsg
							case ch <- sequenceMsg:
							default:
							}
						}
					}
					bc.subs.RUnlock()
				}

			case bc.zback:
				msg, err := bc.zback.RecvMessage(0)
				if err != nil {
					break OUTER
				}
				switch msg[0] {
				case "subscribe":
					if err := bc.zsub.SetSubscribe(msg[1]); err != nil {
						break OUTER
					}
				case "unsubscribe":
					if err := bc.zsub.SetUnsubscribe(msg[1]); err != nil {
						break OUTER
					}
				case "term":
					break OUTER
				}
			}
		}
	}

	bc.subs.Lock()
	close(bc.subs.exited)
	bc.subs.zfront.Close()
	// Close all subscriber channels, that will make them notice that we failed.
	if len(bc.subs.hashTx) > 0 {
		_ = bc.zsub.SetUnsubscribe("hashtx")
	}
	for _, ch := range bc.subs.hashTx {
		close(ch)
	}
	if len(bc.subs.hashBlock) > 0 {
		_ = bc.zsub.SetUnsubscribe("hashblock")
	}
	for _, ch := range bc.subs.hashBlock {
		close(ch)
	}
	if len(bc.subs.rawTx) > 0 {
		_ = bc.zsub.SetUnsubscribe("rawtx")
	}
	for _, ch := range bc.subs.rawTx {
		close(ch)
	}
	if len(bc.subs.rawBlock) > 0 {
		_ = bc.zsub.SetUnsubscribe("rawblock")
	}
	for _, ch := range bc.subs.rawBlock {
		close(ch)
	}
	if len(bc.subs.sequence) > 0 {
		_ = bc.zsub.SetUnsubscribe("sequence")
	}
	for _, ch := range bc.subs.sequence {
		close(ch)
	}
	bc.subs.Unlock()
}

var (
	errSubscribeDisabled = errors.New("subscribe disabled (ZmqPubAddress was not set)")
	errSubscribeExited   = errors.New("subscription backend has exited")
)

// SubscribeRawTx subscribes to the ZMQ "rawtx" messages as RawMsg items pushed onto the channel.
//
// Call cancel to cancel the subscription and let the client release the resources. The channel is closed
// when the subscription is canceled or when the client is closed.
func (bc *cribbedZmqEngine) SubscribeRawTx() (subCh chan RawMsg, cancel func(), err error) {
	if bc.zsub == nil {
		err = errSubscribeDisabled
		return
	}
	bc.subs.Lock()
	select {
	case <-bc.subs.exited:
		err = errSubscribeExited
		bc.subs.Unlock()
		return
	default:
	}
	if len(bc.subs.rawTx) == 0 {
		_, err = bc.subs.zfront.SendMessage("subscribe", "rawtx")
		if err != nil {
			bc.subs.Unlock()
			return
		}
	}
	subCh = make(chan RawMsg, channelSize)
	bc.subs.rawTx = append(bc.subs.rawTx, subCh)
	bc.subs.Unlock()
	cancel = func() { _ = bc.unsubscribeRawTx(subCh) }
	return
}

func (bc *cribbedZmqEngine) unsubscribeRawTx(subCh chan RawMsg) (err error) {
	bc.subs.Lock()
	select {
	case <-bc.subs.exited:
		err = errSubscribeExited
		bc.subs.Unlock()
		return
	default:
	}
	for i, ch := range bc.subs.rawTx {
		if ch == subCh {
			bc.subs.rawTx = append(bc.subs.rawTx[:i], bc.subs.rawTx[i+1:]...)
			if len(bc.subs.rawTx) == 0 {
				_, err = bc.subs.zfront.SendMessage("unsubscribe", "rawtx")
			}
			break
		}
	}
	bc.subs.Unlock()
	close(subCh)
	return
}
