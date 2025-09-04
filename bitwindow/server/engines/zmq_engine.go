package engines

import (
	"bytes"
	"context"
	"encoding/binary"
	"errors"
	"fmt"
	"sync"

	"github.com/btcsuite/btcd/wire"
	zmq "github.com/go-zeromq/zmq4"
	"github.com/rs/zerolog"
)

// ZMQEngine receives raw, unconfirmed transactions from bitcoind via ZMQ.
// Processes them and broadcasts them to the rest of the system.
type ZMQ struct {
	txChan chan *wire.MsgTx

	inner *zmqEngine

	mu          sync.RWMutex
	subscribers []chan *wire.MsgTx
}

// NewZMQ creates a new ZMQ engine for receiving Bitcoin Core raw transaction notifications
func NewZMQ(endpoint string) (*ZMQ, error) {
	if endpoint == "" {
		return nil, errors.New("engines/zmq: endpoint is empty")
	}

	inner := NewZmqEngine(endpoint)

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

	subCh, cancel, err := e.inner.SubscribeRawTx(ctx)
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
type zmqEngine struct {
	endpoint string
}

func NewZmqEngine(endpoint string) *zmqEngine {
	bc := &zmqEngine{
		endpoint: endpoint,
	}

	return bc
}

const channelSize = 100

// SubscribeRawTx subscribes to the ZMQ "rawtx" messages as RawMsg items pushed onto the channel.
//
// Call cancel to cancel the subscription and let the client release the resources. The channel is closed
// when the subscription is canceled or when the client is closed.
func (bc *zmqEngine) SubscribeRawTx(ctx context.Context) (chan RawMsg, func(), error) {
	sub := zmq.NewSub(ctx)
	if err := sub.Dial(bc.endpoint); err != nil {
		return nil, nil, fmt.Errorf("dial %q: %w", bc.endpoint, err)
	}

	if err := sub.SetOption(zmq.OptionSubscribe, "rawtx"); err != nil {
		return nil, nil, fmt.Errorf("subscribe to rawtx: %w", err)
	}

	subCh := make(chan RawMsg, channelSize)
	go func() {
		for {
			msg, err := sub.Recv()
			if err != nil {
				break
			}

			if len(msg.Frames) != 3 {
				zerolog.Ctx(ctx).Err(err).Msgf("engines/zmq: expected 2 frames, got %d", len(msg.Frames))
				continue
			}

			if topic := string(msg.Frames[0]); topic != "rawtx" {
				zerolog.Ctx(ctx).Err(err).Msgf("engines/zmq: expected rawtx topic, got %s", topic)
				continue
			}

			parsedRawMsg := RawMsg{
				Serialized: msg.Frames[1],
				Seq:        binary.LittleEndian.Uint32(msg.Frames[2]),
			}

			select {
			case <-ctx.Done():
				zerolog.Ctx(ctx).Info().Err(ctx.Err()).
					Msg("engines/zmq: rawtx subscription cancelled")
				return

			case subCh <- parsedRawMsg:
				zerolog.Ctx(ctx).Trace().
					Msgf("engines/zmq: received rawtx message")
			}
		}
	}()

	cancel := func() {
		if err := sub.Close(); err != nil {
			zerolog.Ctx(ctx).Err(err).Msg("engines/zmq: unable to close rawtx subscription")
		}
	}
	return subCh, cancel, nil
}
