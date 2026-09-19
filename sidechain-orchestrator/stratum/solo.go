package stratum

import (
	"bytes"
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"net"
	"strconv"
	"time"

	"github.com/btcsuite/btcd/blockchain"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/rs/zerolog"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/rpc"
)

const (
	soloExtranonceSize = 12
	maxScriptSigSize   = 100
	templatePoll       = 5 * time.Second
	templateRefresh    = 30 * time.Second
	// templateOutage is how long template reads may fail before the source
	// stops. Miners keep the last work until then.
	templateOutage = 2 * time.Minute
)

// Template is the part of a getblocktemplate reply the server reads.
type Template struct {
	Version           int32                 `json:"version"`
	PreviousBlockHash string                `json:"previousblockhash"`
	Transactions      []TemplateTransaction `json:"transactions"`
	CoinbaseTxn       *TemplateTransaction  `json:"coinbasetxn"`
	Bits              string                `json:"bits"`
	Height            uint32                `json:"height"`
	CurTime           uint32                `json:"curtime"`
	WorkID            string                `json:"workid"`
}

type TemplateTransaction struct {
	Data string `json:"data"`
	Txid string `json:"txid"`
}

// Node builds block templates and takes solved blocks.
type Node interface {
	GetBlockTemplate(ctx context.Context) (Template, error)
	SubmitBlock(ctx context.Context, block []byte, workID string) error
}

// EnforcerNode reads templates from the enforcer's JSON-RPC server, which
// builds the coinbase and pays it to the enforcer wallet.
type EnforcerNode struct {
	client *rpc.Client
}

func NewEnforcerNode(addr string) (*EnforcerNode, error) {
	host, portText, err := net.SplitHostPort(addr)
	if err != nil {
		return nil, fmt.Errorf("enforcer address %q: %w", addr, err)
	}
	port, err := strconv.Atoi(portText)
	if err != nil {
		return nil, fmt.Errorf("enforcer port %q: %w", portText, err)
	}
	return &EnforcerNode{client: rpc.New(host, port)}, nil
}

func (n *EnforcerNode) GetBlockTemplate(ctx context.Context) (Template, error) {
	var t Template
	params := []any{map[string]any{
		"capabilities": []string{"coinbasetxn", "workid"},
		"rules":        []string{"segwit"},
	}}
	if err := n.client.Call(ctx, "getblocktemplate", params, &t); err != nil {
		return Template{}, fmt.Errorf("getblocktemplate: %w", err)
	}
	return t, nil
}

func (n *EnforcerNode) SubmitBlock(ctx context.Context, block []byte, workID string) error {
	params := []any{hex.EncodeToString(block)}
	if workID != "" {
		params = append(params, map[string]string{"workid": workID})
	}
	raw, err := n.client.CallRaw(ctx, "submitblock", params)
	if err != nil {
		return fmt.Errorf("submitblock: %w", err)
	}
	if len(raw) == 0 || string(raw) == "null" {
		return nil
	}
	var reason string
	if err := json.Unmarshal(raw, &reason); err != nil {
		return fmt.Errorf("decode submitblock reply %s: %w", raw, err)
	}
	return fmt.Errorf("node rejected the block: %s", reason)
}

// NewSoloWork turns a block template into work. It adds a 12-byte
// extranonce push to the end of the coinbase scriptSig and keeps every
// output, the witness commitment too.
func NewSoloWork(t Template) (*Work, error) {
	if t.CoinbaseTxn == nil || t.CoinbaseTxn.Data == "" {
		return nil, fmt.Errorf("the template has no coinbasetxn")
	}
	raw, err := hex.DecodeString(t.CoinbaseTxn.Data)
	if err != nil {
		return nil, fmt.Errorf("decode coinbasetxn: %w", err)
	}
	var coinbase wire.MsgTx
	if err := coinbase.Deserialize(bytes.NewReader(raw)); err != nil {
		return nil, fmt.Errorf("parse coinbasetxn: %w", err)
	}
	if len(coinbase.TxIn) != 1 {
		return nil, fmt.Errorf("the coinbase has %d inputs, want 1", len(coinbase.TxIn))
	}

	script, err := txscript.NewScriptBuilder().
		AddOps(coinbase.TxIn[0].SignatureScript).
		AddData(make([]byte, soloExtranonceSize)).
		Script()
	if err != nil {
		return nil, fmt.Errorf("build coinbase scriptSig: %w", err)
	}
	if len(script) > maxScriptSigSize {
		return nil, fmt.Errorf("the coinbase scriptSig needs %d bytes, the limit is %d", len(script), maxScriptSigSize)
	}
	coinbase.TxIn[0].SignatureScript = script
	coinbase.TxIn[0].Witness = nil

	var buf bytes.Buffer
	if err := coinbase.SerializeNoWitness(&buf); err != nil {
		return nil, fmt.Errorf("serialize coinbase: %w", err)
	}
	serialized := buf.Bytes()
	end := 4 + wire.VarIntSerializeSize(1) + 36 + wire.VarIntSerializeSize(uint64(len(script))) + len(script)

	txids := make([]chainhash.Hash, 0, len(t.Transactions))
	txs := make([][]byte, 0, len(t.Transactions))
	for i, tx := range t.Transactions {
		txid, err := chainhash.NewHashFromStr(tx.Txid)
		if err != nil {
			return nil, fmt.Errorf("transaction %d txid: %w", i, err)
		}
		data, err := hex.DecodeString(tx.Data)
		if err != nil {
			return nil, fmt.Errorf("transaction %d data: %w", i, err)
		}
		txids = append(txids, *txid)
		txs = append(txs, data)
	}

	prev, err := chainhash.NewHashFromStr(t.PreviousBlockHash)
	if err != nil {
		return nil, fmt.Errorf("previousblockhash: %w", err)
	}
	bits, err := strconv.ParseUint(t.Bits, 16, 32)
	if err != nil {
		return nil, fmt.Errorf("bits %q: %w", t.Bits, err)
	}

	var reward int64
	for _, out := range coinbase.TxOut {
		reward += out.Value
	}

	return &Work{
		PrevHash:       *prev,
		Coinb1:         bytes.Clone(serialized[:end-soloExtranonceSize]),
		Coinb2:         bytes.Clone(serialized[end:]),
		ExtranonceSize: soloExtranonceSize,
		Branch:         merkleBranch(txids),
		Version:        t.Version,
		Bits:           uint32(bits),
		Time:           t.CurTime,
		VersionMask:    VersionMask,
		Target:         blockchain.CompactToBig(uint32(bits)),
		Height:         t.Height,
		RewardSats:     reward,
		txs:            txs,
		witness:        hasWitnessCommitment(coinbase.TxOut),
		workID:         t.WorkID,
	}, nil
}

var witnessCommitmentPrefix = []byte{txscript.OP_RETURN, 0x24, 0xaa, 0x21, 0xa9, 0xed}

func hasWitnessCommitment(outs []*wire.TxOut) bool {
	for _, out := range outs {
		if len(out.PkScript) >= 38 && bytes.HasPrefix(out.PkScript, witnessCommitmentPrefix) {
			return true
		}
	}
	return false
}

// assembleBlock serializes the block a share completes. A coinbase under a
// witness commitment gets the 32-byte zero reserved value as its witness.
func assembleBlock(w *Work, s Share) ([]byte, error) {
	var coinbase wire.MsgTx
	if err := coinbase.DeserializeNoWitness(bytes.NewReader(s.Coinbase)); err != nil {
		return nil, fmt.Errorf("parse share coinbase: %w", err)
	}
	if w.witness {
		coinbase.TxIn[0].Witness = wire.TxWitness{make([]byte, 32)}
	}

	var buf bytes.Buffer
	if err := s.Header.Serialize(&buf); err != nil {
		return nil, fmt.Errorf("serialize header: %w", err)
	}
	if err := wire.WriteVarInt(&buf, 0, uint64(len(w.txs)+1)); err != nil {
		return nil, fmt.Errorf("write transaction count: %w", err)
	}
	if err := coinbase.Serialize(&buf); err != nil {
		return nil, fmt.Errorf("serialize coinbase: %w", err)
	}
	for _, tx := range w.txs {
		buf.Write(tx)
	}
	return buf.Bytes(), nil
}

// nextSoloWork decides whether a fresh template goes out to the miners, and
// whether they must drop what they hold.
func nextSoloWork(prev *Work, sincePublish time.Duration, next *Work) (publish, clean bool) {
	if prev == nil || prev.PrevHash != next.PrevHash {
		return true, true
	}
	return sincePublish >= templateRefresh, false
}

// SoloSource gives miners work on this node's block templates.
type SoloSource struct {
	node  Node
	log   zerolog.Logger
	first *Work
	wake  chan struct{}
}

// NewSoloSource reads the first template, so a node that cannot serve one
// fails here and not after the server starts.
func NewSoloSource(ctx context.Context, node Node, log zerolog.Logger) (*SoloSource, error) {
	t, err := node.GetBlockTemplate(ctx)
	if err != nil {
		return nil, err
	}
	first, err := NewSoloWork(t)
	if err != nil {
		return nil, err
	}
	return &SoloSource{node: node, log: log, first: first, wake: make(chan struct{}, 1)}, nil
}

func (s *SoloSource) Run(ctx context.Context, publish func(*Work)) error {
	current := s.first
	current.Clean = true
	published := time.Now()
	publish(current)

	ticker := time.NewTicker(templatePoll)
	defer ticker.Stop()
	var failingSince time.Time
	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-ticker.C:
		case <-s.wake:
		}
		next, err := s.nextWork(ctx)
		if err != nil {
			if failingSince.IsZero() {
				failingSince = time.Now()
			}
			if outageOver(failingSince, time.Now()) {
				return fmt.Errorf("no block template for %s: %w", templateOutage, err)
			}
			s.log.Warn().Err(err).Msg("stratum: read a block template, the next poll tries again")
			continue
		}
		failingSince = time.Time{}
		send, clean := nextSoloWork(current, time.Since(published), next)
		if !send {
			continue
		}
		next.Clean = clean
		current, published = next, time.Now()
		publish(current)
	}
}

func (s *SoloSource) nextWork(ctx context.Context) (*Work, error) {
	t, err := s.node.GetBlockTemplate(ctx)
	if err != nil {
		return nil, err
	}
	return NewSoloWork(t)
}

// outageOver reports whether template reads that fail since failingSince
// must stop the source.
func outageOver(failingSince, now time.Time) bool {
	return !failingSince.IsZero() && now.Sub(failingSince) >= templateOutage
}

func (s *SoloSource) Submit(ctx context.Context, w *Work, share Share) (*Block, error) {
	block, err := assembleBlock(w, share)
	if err != nil {
		return nil, err
	}
	if err := s.node.SubmitBlock(ctx, block, w.workID); err != nil {
		return nil, err
	}
	select {
	case s.wake <- struct{}{}:
	default:
	}
	return &Block{
		Height:     w.Height,
		Hash:       share.Header.BlockHash(),
		RewardSats: w.RewardSats,
		Worker:     share.Worker,
	}, nil
}
