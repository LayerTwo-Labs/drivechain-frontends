package main

import (
	"context"
	"errors"
	"fmt"
	"sort"
	"sync"
	"time"
)

type status struct {
	Confirmed   bool   `json:"confirmed"`
	BlockHeight int    `json:"block_height,omitempty"`
	BlockHash   string `json:"block_hash,omitempty"`
	BlockTime   int64  `json:"block_time,omitempty"`
}

type vout struct {
	ScriptPubKey        string `json:"scriptpubkey"`
	ScriptPubKeyAsm     string `json:"scriptpubkey_asm"`
	ScriptPubKeyType    string `json:"scriptpubkey_type"`
	ScriptPubKeyAddress string `json:"scriptpubkey_address,omitempty"`
	Value               int64  `json:"value"`
}

type vin struct {
	TxID       string   `json:"txid"`
	Vout       int      `json:"vout"`
	Prevout    *vout    `json:"prevout"`
	ScriptSig  string   `json:"scriptsig"`
	Witness    []string `json:"witness,omitempty"`
	IsCoinbase bool     `json:"is_coinbase"`
	Sequence   int64    `json:"sequence"`
}

type tx struct {
	TxID     string `json:"txid"`
	Version  int32  `json:"version"`
	Locktime int64  `json:"locktime"`
	Vin      []vin  `json:"vin"`
	Vout     []vout `json:"vout"`
	Size     int32  `json:"size"`
	Weight   int32  `json:"weight"`
	Fee      int64  `json:"fee"`
	Status   status `json:"status"`

	hex   string
	order int
}

type block struct {
	ID                string  `json:"id"`
	Height            int     `json:"height"`
	Version           int32   `json:"version"`
	Timestamp         int64   `json:"timestamp"`
	TxCount           int     `json:"tx_count"`
	Size              int     `json:"size"`
	Weight            int     `json:"weight"`
	MerkleRoot        string  `json:"merkle_root"`
	PreviousBlockHash *string `json:"previousblockhash"`
	MedianTime        int64   `json:"mediantime"`
	Nonce             uint32  `json:"nonce"`
	Bits              string  `json:"bits"`
	Difficulty        float64 `json:"difficulty"`

	txids []string
}

type outpoint struct {
	txid string
	vout int
}

type spend struct {
	txid string
	vin  int
}

// chainState is one consistent read of the chain and the mempool.
type chainState struct {
	blocks   []*block
	byHash   map[string]*block
	txs      map[string]*tx
	addrTxs  map[string][]string
	spentBy  map[outpoint]spend
	mempool  []string
	tipHash  string
	nextSeen int
}

// index keeps an address index of a regtest chain in memory. A regtest chain
// is small, so a reorg rebuilds the whole index.
type index struct {
	core *coreRPC

	mu        sync.Mutex
	confirmed *chainState
	state     *chainState
	readAt    time.Time
}

const refreshEvery = 250 * time.Millisecond

func newIndex(core *coreRPC) *index { return &index{core: core} }

// read returns the current chain state, at most refreshEvery old.
func (x *index) read(ctx context.Context) (*chainState, error) {
	x.mu.Lock()
	defer x.mu.Unlock()
	if x.state != nil && time.Since(x.readAt) < refreshEvery {
		return x.state, nil
	}
	if err := x.syncBlocks(ctx); err != nil {
		return nil, err
	}
	state, err := x.withMempool(ctx)
	if err != nil {
		return nil, err
	}
	x.state, x.readAt = state, time.Now()
	return state, nil
}

// invalidate makes the next read go to Core.
func (x *index) invalidate() {
	x.mu.Lock()
	defer x.mu.Unlock()
	x.state = nil
}

func emptyState() *chainState {
	return &chainState{
		byHash:  map[string]*block{},
		txs:     map[string]*tx{},
		addrTxs: map[string][]string{},
		spentBy: map[outpoint]spend{},
	}
}

func (x *index) syncBlocks(ctx context.Context) error {
	var tipHash string
	if err := x.core.call(ctx, "", "getbestblockhash", nil, &tipHash); err != nil {
		return err
	}
	if x.confirmed != nil && x.confirmed.tipHash == tipHash {
		return nil
	}
	var tipHeight int
	if err := x.core.call(ctx, "", "getblockcount", nil, &tipHeight); err != nil {
		return err
	}

	st := x.confirmed
	if st != nil && len(st.blocks) > 0 {
		last := st.blocks[len(st.blocks)-1]
		var hashAtLast string
		if err := x.core.call(ctx, "", "getblockhash", []any{last.Height}, &hashAtLast); err != nil || hashAtLast != last.ID {
			st = nil
		}
	}
	if st == nil {
		st = emptyState()
	}
	for h := len(st.blocks); h <= tipHeight; h++ {
		var hash string
		if err := x.core.call(ctx, "", "getblockhash", []any{h}, &hash); err != nil {
			return err
		}
		var cb coreBlock
		if err := x.core.call(ctx, "", "getblock", []any{hash, 3}, &cb); err != nil {
			return err
		}
		if err := st.addBlock(cb); err != nil {
			return fmt.Errorf("block %d: %w", h, err)
		}
	}
	st.tipHash = tipHash
	x.confirmed = st
	return nil
}

func (st *chainState) addBlock(cb coreBlock) error {
	b := &block{
		ID: cb.Hash, Height: cb.Height, Version: cb.Version, Timestamp: cb.Time, TxCount: len(cb.Tx),
		Size: cb.Size, Weight: cb.Weight, MerkleRoot: cb.MerkleRoot, MedianTime: cb.MedianTime,
		Nonce: cb.Nonce, Bits: cb.Bits, Difficulty: cb.Difficulty,
	}
	if cb.PreviousBlockHash != "" {
		prev := cb.PreviousBlockHash
		b.PreviousBlockHash = &prev
	}
	st.blocks = append(st.blocks, b)
	st.byHash[b.ID] = b
	for _, ct := range cb.Tx {
		t, err := convertTx(ct)
		if err != nil {
			return err
		}
		t.Status = status{Confirmed: true, BlockHeight: cb.Height, BlockHash: cb.Hash, BlockTime: cb.Time}
		st.add(t)
		b.txids = append(b.txids, t.TxID)
	}
	return nil
}

func (st *chainState) add(t *tx) {
	t.order = st.nextSeen
	st.nextSeen++
	st.txs[t.TxID] = t
	seen := map[string]bool{}
	link := func(addr string) {
		if addr == "" || seen[addr] {
			return
		}
		seen[addr] = true
		st.addrTxs[addr] = append(st.addrTxs[addr], t.TxID)
	}
	for i, in := range t.Vin {
		if in.IsCoinbase {
			continue
		}
		st.spentBy[outpoint{in.TxID, in.Vout}] = spend{txid: t.TxID, vin: i}
		if in.Prevout != nil {
			link(in.Prevout.ScriptPubKeyAddress)
		}
	}
	for _, out := range t.Vout {
		link(out.ScriptPubKeyAddress)
	}
}

// withMempool copies the confirmed state and adds the mempool to the copy.
func (x *index) withMempool(ctx context.Context) (*chainState, error) {
	base := x.confirmed
	var txids []string
	if err := x.core.call(ctx, "", "getrawmempool", nil, &txids); err != nil {
		return nil, err
	}
	st := &chainState{
		blocks: base.blocks, byHash: base.byHash, tipHash: base.tipHash, nextSeen: base.nextSeen,
		txs:     make(map[string]*tx, len(base.txs)+len(txids)),
		addrTxs: make(map[string][]string, len(base.addrTxs)),
		spentBy: make(map[outpoint]spend, len(base.spentBy)),
	}
	for k, v := range base.txs {
		st.txs[k] = v
	}
	for k, v := range base.addrTxs {
		st.addrTxs[k] = v
	}
	for k, v := range base.spentBy {
		st.spentBy[k] = v
	}

	pending := make([]*tx, 0, len(txids))
	for _, txid := range txids {
		var ct coreTx
		if err := x.core.call(ctx, "", "getrawtransaction", []any{txid, 2}, &ct); err != nil {
			var rpcErr *rpcError
			if errors.As(err, &rpcErr) && rpcErr.Code == -5 {
				continue
			}
			return nil, err
		}
		t, err := convertTx(ct)
		if err != nil {
			return nil, fmt.Errorf("mempool tx %s: %w", txid, err)
		}
		pending = append(pending, t)
	}
	sort.Slice(pending, func(i, j int) bool { return pending[i].TxID < pending[j].TxID })
	if err := fillPrevouts(st, pending); err != nil {
		return nil, err
	}
	for _, t := range pending {
		st.add(t)
		st.mempool = append(st.mempool, t.TxID)
	}
	return st, nil
}

func convertTx(ct coreTx) (*tx, error) {
	t := &tx{
		TxID: ct.TxID, Version: ct.Version, Locktime: ct.Locktime, Size: ct.Size, Weight: ct.Weight, hex: ct.Hex,
		Vin: make([]vin, 0, len(ct.Vin)), Vout: make([]vout, 0, len(ct.Vout)),
	}
	fee, err := sats(ct.Fee)
	if err != nil {
		return nil, err
	}
	t.Fee = fee
	for _, in := range ct.Vin {
		v := vin{TxID: in.TxID, Vout: in.Vout, ScriptSig: in.ScriptSig.Hex, Witness: in.Witness, Sequence: in.Sequence}
		if in.Coinbase != "" {
			v.IsCoinbase = true
			v.TxID = "0000000000000000000000000000000000000000000000000000000000000000"
			v.Vout = 0xffffffff
			v.ScriptSig = in.Coinbase
		} else if in.Prevout != nil {
			value, err := sats(in.Prevout.Value)
			if err != nil {
				return nil, err
			}
			out := convertScript(in.Prevout.ScriptPubKey, value)
			v.Prevout = &out
		}
		t.Vin = append(t.Vin, v)
	}
	for _, out := range ct.Vout {
		value, err := sats(out.Value)
		if err != nil {
			return nil, err
		}
		t.Vout = append(t.Vout, convertScript(out.ScriptPubKey, value))
	}
	return t, nil
}

func convertScript(s coreScriptPubKey, value int64) vout {
	return vout{
		ScriptPubKey: s.Hex, ScriptPubKeyAsm: s.Asm, ScriptPubKeyType: esploraScriptType(s.Type),
		ScriptPubKeyAddress: s.Address, Value: value,
	}
}

func esploraScriptType(coreType string) string {
	switch coreType {
	case "pubkeyhash":
		return "p2pkh"
	case "scripthash":
		return "p2sh"
	case "witness_v0_keyhash":
		return "v0_p2wpkh"
	case "witness_v0_scripthash":
		return "v0_p2wsh"
	case "witness_v1_taproot":
		return "v1_p2tr"
	case "nulldata":
		return "op_return"
	case "pubkey":
		return "p2pk"
	case "multisig":
		return "multisig"
	default:
		return "unknown"
	}
}

// addressTxs returns the history of an address, the mempool first, then the
// chain newest first.
func (st *chainState) addressTxs(addr string) (mempool, chain []*tx) {
	for _, txid := range st.addrTxs[addr] {
		t := st.txs[txid]
		if t.Status.Confirmed {
			chain = append(chain, t)
		} else {
			mempool = append(mempool, t)
		}
	}
	sort.Slice(chain, func(i, j int) bool { return chain[i].order > chain[j].order })
	sort.Slice(mempool, func(i, j int) bool { return mempool[i].order > mempool[j].order })
	return mempool, chain
}

type txoStats struct {
	FundedTxoCount int   `json:"funded_txo_count"`
	FundedTxoSum   int64 `json:"funded_txo_sum"`
	SpentTxoCount  int   `json:"spent_txo_count"`
	SpentTxoSum    int64 `json:"spent_txo_sum"`
	TxCount        int   `json:"tx_count"`
}

func (st *chainState) addressStats(addr string) (chainStats, mempoolStats txoStats) {
	for _, txid := range st.addrTxs[addr] {
		t := st.txs[txid]
		stats := &chainStats
		if !t.Status.Confirmed {
			stats = &mempoolStats
		}
		stats.TxCount++
		for _, out := range t.Vout {
			if out.ScriptPubKeyAddress == addr {
				stats.FundedTxoCount++
				stats.FundedTxoSum += out.Value
			}
		}
		for _, in := range t.Vin {
			if in.Prevout != nil && in.Prevout.ScriptPubKeyAddress == addr {
				stats.SpentTxoCount++
				stats.SpentTxoSum += in.Prevout.Value
			}
		}
	}
	return chainStats, mempoolStats
}

type utxo struct {
	TxID   string `json:"txid"`
	Vout   int    `json:"vout"`
	Value  int64  `json:"value"`
	Status status `json:"status"`
}

func (st *chainState) addressUTXOs(addr string) []utxo {
	out := []utxo{}
	for _, txid := range st.addrTxs[addr] {
		t := st.txs[txid]
		for n, o := range t.Vout {
			if o.ScriptPubKeyAddress != addr {
				continue
			}
			if _, spent := st.spentBy[outpoint{t.TxID, n}]; spent {
				continue
			}
			out = append(out, utxo{TxID: t.TxID, Vout: n, Value: o.Value, Status: t.Status})
		}
	}
	return out
}

// fillPrevouts sets the prevouts and the fee of mempool transactions. Core
// reads prevouts from undo data, which a mempool transaction has none of.
func fillPrevouts(st *chainState, pending []*tx) error {
	byID := make(map[string]*tx, len(pending))
	for _, t := range pending {
		byID[t.TxID] = t
	}
	for _, t := range pending {
		if t.Fee != 0 && allPrevouts(t) {
			continue
		}
		var in, out int64
		for i := range t.Vin {
			v := &t.Vin[i]
			if v.IsCoinbase {
				continue
			}
			if v.Prevout == nil {
				source, ok := st.txs[v.TxID]
				if !ok {
					source, ok = byID[v.TxID]
				}
				if !ok || v.Vout >= len(source.Vout) {
					return fmt.Errorf("mempool tx %s spends unknown output %s:%d", t.TxID, v.TxID, v.Vout)
				}
				prev := source.Vout[v.Vout]
				v.Prevout = &prev
			}
			in += v.Prevout.Value
		}
		for _, o := range t.Vout {
			out += o.Value
		}
		t.Fee = in - out
	}
	return nil
}

func allPrevouts(t *tx) bool {
	for _, v := range t.Vin {
		if !v.IsCoinbase && v.Prevout == nil {
			return false
		}
	}
	return true
}
