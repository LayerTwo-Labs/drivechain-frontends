package wallet

import (
	"bytes"
	"context"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"math"
	"sort"
	"sync"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/wire"
	"github.com/rs/zerolog"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/replay"
)

const (
	// electrumGapLimit is the BIP44 gap limit: scanning a chain stops after
	// this many consecutive unused addresses.
	electrumGapLimit = 20
	// electrumMaxScan caps per-chain derivation so a misbehaving backend
	// can't drive an unbounded scan.
	electrumMaxScan = 1000
	// dustSats is the minimum a change output must hold to be worth creating.
	dustSats = 546
)

// ElectrumBackend serves a wallet with no local Core or enforcer: it derives
// BIP84 keys from the wallet seed, reads chain state from an Esplora REST
// backend, and builds/signs/broadcasts transactions in-process.
type ElectrumBackend struct {
	svc     *Service
	client  Esplora
	network *chaincfg.Params
	log     zerolog.Logger

	mu        sync.Mutex
	watchKeys map[string][]WatchKey // walletID -> extra keys to track
}

var _ Backend = (*ElectrumBackend)(nil)

// NewElectrumBackend creates an Esplora-backed wallet backend.
func NewElectrumBackend(svc *Service, client Esplora, network *chaincfg.Params, log zerolog.Logger) *ElectrumBackend {
	return &ElectrumBackend{
		svc:       svc,
		client:    client,
		network:   network,
		log:       log.With().Str("component", "electrum-backend").Logger(),
		watchKeys: make(map[string][]WatchKey),
	}
}

// scannedAddr is one derived (or watched) address with its key and current
// funding stats.
type scannedAddr struct {
	address       string
	priv          *btcec.PrivateKey
	pub           *btcec.PublicKey
	scriptPubKey  []byte
	redeem        []byte              // P2SH-P2WPKH redeem (nested segwit)
	witnessScript []byte              // P2WSH multisig script
	multisigPrivs []*btcec.PrivateKey // multisig: the keys this wallet holds
	tapInternal   *btcec.PublicKey    // taproot internal key
	kind          ScriptKind
	change        bool
	index         uint32
	hdPath        string
	stats         EsploraAddressStats
}

type electrumScan struct {
	addrs     []scannedAddr
	byAddr    map[string]scannedAddr
	keys      mapKeySource
	watchOnly bool // no seed: addresses derive from an xpub, cannot sign
}

func (s *electrumScan) owns(address string) bool {
	_, ok := s.byAddr[address]
	return ok
}

// mapKeySource resolves addresses to private keys for SignTransactionLocal.
type mapKeySource map[string]*btcec.PrivateKey

func (m mapKeySource) PrivKeyForAddress(address string) (*btcec.PrivateKey, bool) {
	k, ok := m[address]
	return k, ok
}

func (p *ElectrumBackend) Ensure(ctx context.Context, walletID string) (string, error) {
	if p.svc.GetWalletByID(walletID) == nil {
		return "", fmt.Errorf("wallet %s not found", walletID)
	}
	return walletID, nil
}

func (p *ElectrumBackend) EnsureAll(ctx context.Context) (int, error) {
	n := 0
	for _, w := range p.svc.GetAllWallets() {
		if w.WalletType == "electrum" {
			n++
		}
	}
	return n, nil
}

func (p *ElectrumBackend) Balance(ctx context.Context, walletID string) (float64, float64, error) {
	scan, err := p.scanWallet(ctx, walletID)
	if err != nil {
		return 0, 0, err
	}
	// Split the mempool delta into gross incoming (funded) and gross spent so
	// both returned values stay non-negative: spending confirmed coins makes the
	// net mempool delta negative, which would wrap when cast to uint64 downstream.
	// confirmed = confirmed coins not yet being spent; pending = all mempool
	// inflow (incl. our own change). confirmed+pending preserves the true total.
	var confirmedNet, mempoolFunded, mempoolSpent int64
	for _, a := range scan.addrs {
		confirmedNet += a.stats.ChainStats.FundedTxoSum - a.stats.ChainStats.SpentTxoSum
		mempoolFunded += a.stats.MempoolStats.FundedTxoSum
		mempoolSpent += a.stats.MempoolStats.SpentTxoSum
	}
	confirmed := max(confirmedNet-mempoolSpent, 0)
	return float64(confirmed) / 1e8, float64(mempoolFunded) / 1e8, nil
}

func (p *ElectrumBackend) ListUnspent(ctx context.Context, walletID string) ([]UTXO, error) {
	scan, err := p.scanWallet(ctx, walletID)
	if err != nil {
		return nil, err
	}
	tip, err := p.client.TipHeight(ctx)
	if err != nil {
		return nil, err
	}
	var out []UTXO
	for _, a := range scan.addrs {
		if !a.stats.Used() {
			continue
		}
		utxos, err := p.client.AddressUTXOs(ctx, a.address)
		if err != nil {
			return nil, err
		}
		for _, u := range utxos {
			out = append(out, UTXO{
				TxID:          u.TxID,
				Vout:          u.Vout,
				Address:       a.address,
				Amount:        float64(u.Value) / 1e8,
				Confirmations: confsFor(u.Status, tip),
				Spendable:     true,
				Solvable:      true,
				ReceivedAt:    u.Status.BlockTime,
			})
		}
	}
	return out, nil
}

func (p *ElectrumBackend) ListTransactions(ctx context.Context, walletID string, count int) ([]WalletTransaction, error) {
	return p.ListTransactionsRange(ctx, walletID, count, 0)
}

func (p *ElectrumBackend) ListTransactionsRange(ctx context.Context, walletID string, count, skip int) ([]WalletTransaction, error) {
	scan, err := p.scanWallet(ctx, walletID)
	if err != nil {
		return nil, err
	}
	tip, err := p.client.TipHeight(ctx)
	if err != nil {
		return nil, err
	}

	txByID := map[string]EsploraTx{}
	for _, a := range scan.addrs {
		if !a.stats.Used() {
			continue
		}
		txs, err := p.client.AddressTxs(ctx, a.address)
		if err != nil {
			return nil, err
		}
		for _, tx := range txs {
			txByID[tx.TxID] = tx
		}
	}

	var rows []WalletTransaction
	for _, tx := range txByID {
		rows = append(rows, walletRowsForTx(tx, scan, tip)...)
	}

	// Newest first, matching Core's listtransactions default ordering after
	// the frontend reverses it; sort by time descending here.
	sort.SliceStable(rows, func(i, j int) bool {
		return rows[i].Time > rows[j].Time
	})

	if skip >= len(rows) {
		return nil, nil
	}
	rows = rows[skip:]
	if count > 0 && count < len(rows) {
		rows = rows[:count]
	}
	return rows, nil
}

func (p *ElectrumBackend) ListReceivedByAddress(ctx context.Context, walletID string) ([]ReceivedByAddress, error) {
	scan, err := p.scanWallet(ctx, walletID)
	if err != nil {
		return nil, err
	}
	tip, err := p.client.TipHeight(ctx)
	if err != nil {
		return nil, err
	}

	out := make([]ReceivedByAddress, 0, len(scan.addrs))
	for _, a := range scan.addrs {
		entry := ReceivedByAddress{Address: a.address}
		if a.stats.Used() {
			txs, err := p.client.AddressTxs(ctx, a.address)
			if err != nil {
				return nil, err
			}
			var receivedSats int64
			maxConfs := 0
			for _, tx := range txs {
				var paid int64
				for _, vout := range tx.Vout {
					if vout.ScriptPubKeyAddress == a.address {
						paid += vout.Value
					}
				}
				if paid == 0 {
					continue
				}
				receivedSats += paid
				entry.TxIDs = append(entry.TxIDs, tx.TxID)
				if c := confsFor(tx.Status, tip); c > maxConfs {
					maxConfs = c
				}
			}
			entry.Amount = float64(receivedSats) / 1e8
			entry.Confirmations = maxConfs
		}
		out = append(out, entry)
	}
	return out, nil
}

func (p *ElectrumBackend) GetWalletTransaction(ctx context.Context, walletID, txid string) (*WalletTx, error) {
	scan, err := p.scanWallet(ctx, walletID)
	if err != nil {
		return nil, err
	}
	tx, err := p.client.Tx(ctx, txid)
	if err != nil {
		return nil, err
	}
	rawHex, err := p.client.TxHex(ctx, txid)
	if err != nil {
		return nil, err
	}
	tip, err := p.client.TipHeight(ctx)
	if err != nil {
		return nil, err
	}

	ownIn, ownOut := walletFlow(tx, scan)
	fee := 0.0
	if ownIn > 0 {
		fee = -float64(tx.Fee) / 1e8
	}
	return &WalletTx{
		TxID:          tx.TxID,
		Amount:        float64(ownOut-ownIn) / 1e8,
		Fee:           fee,
		Confirmations: int32(confsFor(tx.Status, tip)),
		BlockTime:     tx.Status.BlockTime,
		Time:          tx.Status.BlockTime,
		Hex:           rawHex,
	}, nil
}

func (p *ElectrumBackend) AddressHDPath(ctx context.Context, walletID, address string) (string, error) {
	scan, err := p.scanWallet(ctx, walletID)
	if err != nil {
		return "", err
	}
	a, ok := scan.byAddr[address]
	if !ok {
		return "", fmt.Errorf("address %s not found in wallet", address)
	}
	return a.hdPath, nil
}

func (p *ElectrumBackend) NextReceiveAddress(ctx context.Context, walletID string) (string, error) {
	return p.nextUnused(ctx, walletID, false)
}

func (p *ElectrumBackend) NextChangeAddress(ctx context.Context, walletID string) (string, error) {
	return p.nextUnused(ctx, walletID, true)
}

func (p *ElectrumBackend) nextUnused(ctx context.Context, walletID string, change bool) (string, error) {
	scan, err := p.scanWallet(ctx, walletID)
	if err != nil {
		return "", err
	}
	return p.nextUnusedFromScan(walletID, scan, change)
}

// nextUnusedFromScan picks the next unused address on a chain from an existing
// scan, avoiding a second full wallet scan on the send path.
func (p *ElectrumBackend) nextUnusedFromScan(walletID string, scan *electrumScan, change bool) (string, error) {
	highest := -1
	for _, a := range scan.addrs {
		// Skip BIP47 watch keys (empty hdPath); they aren't part of the
		// derivation chain. Watch-only chain addresses have no priv key but
		// still advance the chain, so the chain marker is hdPath, not priv.
		if a.hdPath == "" || a.change != change {
			continue
		}
		if int(a.index) > highest {
			highest = int(a.index)
		}
		if !a.stats.Used() {
			return a.address, nil
		}
	}
	// Every scanned address is used — derive the next index past the scan.
	w := p.svc.GetWalletByID(walletID)
	if w == nil {
		return "", fmt.Errorf("wallet %s not found", walletID)
	}
	derivers, _, err := p.chainDerivers(w)
	if err != nil {
		return "", err
	}
	chainIdx := 0
	if change {
		chainIdx = 1
	}
	a, err := derivers[chainIdx](uint32(highest + 1))
	if err != nil {
		return "", err
	}
	return a.address, nil
}

// WatchKeys records extra keys (BIP47 per-sender payment windows) so their
// P2PKH addresses are scanned and spendable.
func (p *ElectrumBackend) WatchKeys(ctx context.Context, walletID string, keys []WatchKey) error {
	if len(keys) == 0 {
		return nil
	}
	p.mu.Lock()
	defer p.mu.Unlock()
	existing := p.watchKeys[walletID]
	seen := make(map[string]bool, len(existing))
	for _, k := range existing {
		seen[k.WIF] = true
	}
	for _, k := range keys {
		if !seen[k.WIF] {
			existing = append(existing, k)
			seen[k.WIF] = true
		}
	}
	p.watchKeys[walletID] = existing
	return nil
}

func (p *ElectrumBackend) Send(ctx context.Context, walletID string, req SendRequest) (string, error) {
	if req.FeeRateSatPerVB > 0 && req.FixedFeeSats > 0 {
		return "", errors.New("fee rate and fixed fee are mutually exclusive")
	}
	scan, err := p.scanWallet(ctx, walletID)
	if err != nil {
		return "", err
	}
	if scan.watchOnly {
		return "", errors.New("watch-only electrum wallet cannot sign or send")
	}

	outputs, totalOutSats := buildSendOutputs(req)

	pool, err := p.spendableUTXOs(ctx, scan)
	if err != nil {
		return "", err
	}

	// Pin required inputs, then fill from the remaining pool largest-first.
	required := make(map[string]bool)
	var selected []electrumUTXO
	var selectedSats int64
	for _, ri := range req.RequiredInputs {
		key := fmt.Sprintf("%s:%d", ri.TxID, ri.Vout)
		required[key] = true
		u, ok := findUTXO(pool, ri.TxID, ri.Vout)
		if !ok {
			return "", fmt.Errorf("required input %s not found among wallet UTXOs", key)
		}
		selected = append(selected, u)
		selectedSats += u.amountSats
	}
	remaining := make([]electrumUTXO, 0, len(pool))
	for _, u := range pool {
		if !required[fmt.Sprintf("%s:%d", u.txid, u.vout)] {
			remaining = append(remaining, u)
		}
	}
	sort.Slice(remaining, func(i, j int) bool { return remaining[i].amountSats > remaining[j].amountSats })

	feeRate := float64(req.FeeRateSatPerVB)
	if feeRate <= 0 {
		feeRate = p.client.FeeRateForTarget(ctx, 6, 1.0)
		if feeRate < 1 {
			feeRate = 1
		}
	}

	// Send-max has no change output; a normal send assumes one.
	nOut := len(outputs) + 1
	if req.SubtractFeeFromAmount {
		nOut = len(outputs)
	}
	feeSats := func(nIn int) int64 {
		if req.FixedFeeSats > 0 {
			return req.FixedFeeSats
		}
		return estimateFeeSats(nIn, nOut, feeRate)
	}

	// For subtract-fee sends, the first output absorbs the fee; precompute the
	// other outputs' total so the selection loop can guarantee the absorbing
	// output stays above dust.
	var sffaOtherOut int64
	if req.SubtractFeeFromAmount && len(outputs) > 0 {
		sffaOtherOut = totalOutSats - int64(math.Round(outputs[0].AmountBTC*1e8))
	}

	i := 0
	for {
		fee := feeSats(len(selected))
		target := totalOutSats + fee
		if req.SubtractFeeFromAmount {
			// Need enough to cover the requested outputs and leave the
			// absorbing output >= dust after the fee; otherwise a valid send
			// would fail while spendable UTXOs remain.
			target = max(totalOutSats, sffaOtherOut+fee+dustSats)
		}
		if len(selected) > 0 && selectedSats >= target {
			break
		}
		if i >= len(remaining) {
			return "", fmt.Errorf("insufficient funds: need %d sats, have %d sats", target, selectedSats)
		}
		selected = append(selected, remaining[i])
		selectedSats += remaining[i].amountSats
		i++
	}

	fee := feeSats(len(selected))
	var changeSats int64
	if req.SubtractFeeFromAmount {
		if len(outputs) == 0 || outputs[0].OpReturnHex != "" {
			return "", errors.New("subtractFeeFromAmount requires a payable first output")
		}
		// Spend everything selected: outputs[0] absorbs all leftover value
		// minus the fee, so there is no change output.
		reduced := selectedSats - sffaOtherOut - fee
		if reduced < dustSats {
			return "", fmt.Errorf("fee %d sats exceeds first output", fee)
		}
		outputs[0].AmountBTC = float64(reduced) / 1e8
	} else {
		changeSats = selectedSats - totalOutSats - fee
	}
	if changeSats < 0 {
		return "", fmt.Errorf("insufficient funds: short %d sats", -changeSats)
	}
	if changeSats >= dustSats {
		changeAddr, err := p.nextUnusedFromScan(walletID, scan, true)
		if err != nil {
			return "", fmt.Errorf("derive change address: %w", err)
		}
		outputs = append(outputs, TxOutSpec{Address: changeAddr, AmountBTC: float64(changeSats) / 1e8})
	}

	psbtInputs := make([]psbtInput, len(selected))
	for idx, u := range selected {
		sa, ok := scan.byAddr[u.address]
		if !ok {
			return "", fmt.Errorf("no derivation info for input address %s", u.address)
		}
		h, err := chainhash.NewHashFromStr(u.txid)
		if err != nil {
			return "", fmt.Errorf("parse input txid %q: %w", u.txid, err)
		}
		psbtInputs[idx] = psbtInput{
			outpoint: wire.OutPoint{Hash: *h, Index: uint32(u.vout)},
			amount:   u.amountSats,
			addr:     sa,
		}
	}

	packet, err := buildPSBT(psbtInputs, outputs, p.network, p.prevTxFetcher(ctx))
	if err != nil {
		return "", fmt.Errorf("build psbt: %w", err)
	}
	// Replay protection sets the magic tx version before signing (the signature
	// commits to it) and appends the replay byte after extraction.
	if req.ReplayProtect {
		packet.UnsignedTx.Version = replay.TxReplayVersion
	}

	signedCount, err := signPSBT(packet, psbtInputs, p.network)
	if err != nil {
		return "", fmt.Errorf("sign psbt: %w", err)
	}
	if signedCount < len(psbtInputs) {
		return "", errors.New("transaction signing incomplete")
	}

	hexToSend, err := finalizeAndExtract(packet)
	if err != nil {
		return "", err
	}
	if req.ReplayProtect {
		hexToSend, err = replay.InjectReplayByte(hexToSend)
		if err != nil {
			return "", fmt.Errorf("inject replay byte: %w", err)
		}
	}
	return p.client.Broadcast(ctx, hexToSend)
}

// prevTxFetcher returns a function that fetches and decodes a previous
// transaction by txid, for populating the non-witness UTXO of legacy inputs.
func (p *ElectrumBackend) prevTxFetcher(ctx context.Context) prevTxFunc {
	return func(txid string) (*wire.MsgTx, error) {
		rawHex, err := p.client.TxHex(ctx, txid)
		if err != nil {
			return nil, err
		}
		b, err := hex.DecodeString(rawHex)
		if err != nil {
			return nil, fmt.Errorf("decode prev tx hex: %w", err)
		}
		var tx wire.MsgTx
		if err := tx.Deserialize(bytes.NewReader(b)); err != nil {
			return nil, fmt.Errorf("deserialize prev tx: %w", err)
		}
		return &tx, nil
	}
}

func (p *ElectrumBackend) SignTransaction(ctx context.Context, walletID, rawHex string) (*SignRawTransactionResult, error) {
	scan, err := p.scanWallet(ctx, walletID)
	if err != nil {
		return nil, err
	}
	raw, err := hex.DecodeString(rawHex)
	if err != nil {
		return nil, fmt.Errorf("decode tx hex: %w", err)
	}
	var tx wire.MsgTx
	if err := tx.Deserialize(bytes.NewReader(raw)); err != nil {
		return nil, fmt.Errorf("deserialize tx: %w", err)
	}
	prevOuts := make(map[wire.OutPoint]PrevOut, len(tx.TxIn))
	for _, in := range tx.TxIn {
		prevTxID := in.PreviousOutPoint.Hash.String()
		prevTx, err := p.client.Tx(ctx, prevTxID)
		if err != nil {
			return nil, fmt.Errorf("fetch prevout %s: %w", prevTxID, err)
		}
		idx := int(in.PreviousOutPoint.Index)
		if idx >= len(prevTx.Vout) {
			return nil, fmt.Errorf("prevout %s:%d out of range", prevTxID, idx)
		}
		vout := prevTx.Vout[idx]
		prevOuts[in.PreviousOutPoint] = PrevOut{Address: vout.ScriptPubKeyAddress, AmountSats: vout.Value}
	}
	return SignTransactionLocal(rawHex, prevOuts, scan.keys, p.network)
}

func (p *ElectrumBackend) BumpFee(ctx context.Context, walletID, txid string, newFeeRate int64) (string, error) {
	return "", errors.New("fee bumping is not supported for electrum wallets")
}

func (p *ElectrumBackend) Chain() ChainSource {
	return esploraChain{client: p.client}
}

// esploraChain adapts an Esplora backend to the wallet-agnostic ChainSource.
type esploraChain struct {
	client Esplora
}

func (c esploraChain) GetRawTransaction(ctx context.Context, txid string) (*RawTransaction, error) {
	tx, err := c.client.Tx(ctx, txid)
	if err != nil {
		return nil, err
	}
	rawHex, err := c.client.TxHex(ctx, txid)
	if err != nil {
		return nil, err
	}
	tip, err := c.client.TipHeight(ctx)
	if err != nil {
		return nil, err
	}
	return esploraTxToRaw(tx, rawHex, tip), nil
}

func (c esploraChain) Broadcast(ctx context.Context, rawHex string) (string, error) {
	return c.client.Broadcast(ctx, rawHex)
}

// ============================================================================
// Derivation + scanning
// ============================================================================

// walletDescriptor builds the parsed output descriptor for a wallet: from its
// seed + script kind when hot (the account key is private, so its addresses can
// be signed), or from its stored watch-only descriptor otherwise.
func (p *ElectrumBackend) walletDescriptor(w *WalletData) (*Descriptor, error) {
	if p.network == nil {
		return nil, errors.New("no chain params for this network; cannot derive electrum wallet")
	}
	if w.Master.SeedHex != "" {
		acct, err := accountKeyFromSeed(w.Master.SeedHex, w.scriptKind(), p.network)
		if err != nil {
			return nil, err
		}
		return &Descriptor{Kind: w.scriptKind(), Threshold: 1, Keys: []DescriptorKey{{Account: acct}}}, nil
	}
	desc, err := watchOnlyDescriptorString(w)
	if err != nil {
		return nil, err
	}
	return ParseDescriptor(desc)
}

// deriveAddr resolves one address of a descriptor, enriching it with the signing
// metadata: the private key (hot wallets), scriptPubKey, and redeem/tap material.
func (p *ElectrumBackend) deriveAddr(d *Descriptor, change bool, index uint32) (scannedAddr, error) {
	ds, pub, err := d.DeriveScript(change, index, p.network)
	if err != nil {
		return scannedAddr{}, err
	}
	a := scannedAddr{
		address:      ds.address.EncodeAddress(),
		pub:          pub,
		scriptPubKey: ds.scriptPubKey,
		redeem:       ds.redeemScript,
		tapInternal:  ds.tapInternal,
		kind:         d.Kind,
		change:       change,
		index:        index,
		hdPath:       descriptorHDPath(d.Kind, p.network, change, index),
	}
	if d.Kind == ScriptMultisig {
		a.witnessScript = ds.witnessScript
		for _, k := range d.Keys {
			priv, ok, err := deriveChildPrivIfPossible(k.Account, chainIndex(change), index)
			if err != nil {
				return scannedAddr{}, err
			}
			if ok {
				a.multisigPrivs = append(a.multisigPrivs, priv)
			}
		}
	} else {
		priv, ok, err := deriveChildPrivIfPossible(d.Keys[0].Account, chainIndex(change), index)
		if err != nil {
			return scannedAddr{}, err
		}
		if ok {
			a.priv = priv
		}
	}
	return a, nil
}

// descriptorHDPath formats the BIP derivation path for display.
func descriptorHDPath(kind ScriptKind, net *chaincfg.Params, change bool, index uint32) string {
	purpose, ok := kind.Purpose()
	if !ok {
		return fmt.Sprintf("m/%d/%d", chainIndex(change), index)
	}
	return fmt.Sprintf("m/%d'/%d'/0'/%d/%d", purpose, net.HDCoinType, chainIndex(change), index)
}

func chainIndex(change bool) uint32 {
	if change {
		return 1
	}
	return 0
}

func (p *ElectrumBackend) scanWallet(ctx context.Context, walletID string) (*electrumScan, error) {
	w := p.svc.GetWalletByID(walletID)
	if w == nil {
		return nil, fmt.Errorf("wallet %s not found", walletID)
	}

	scan := &electrumScan{
		byAddr: make(map[string]scannedAddr),
		keys:   make(mapKeySource),
	}

	derivers, watchOnly, err := p.chainDerivers(w)
	if err != nil {
		return nil, err
	}
	scan.watchOnly = watchOnly
	for _, d := range derivers {
		addrs, err := p.scanChain(ctx, d)
		if err != nil {
			return nil, err
		}
		scan.addrs = append(scan.addrs, addrs...)
	}

	p.mu.Lock()
	watch := append([]WatchKey(nil), p.watchKeys[walletID]...)
	p.mu.Unlock()
	for _, k := range watch {
		a, err := p.watchKeyAddr(ctx, k)
		if err != nil {
			p.log.Warn().Err(err).Msg("electrum watch key derivation failed")
			continue
		}
		scan.addrs = append(scan.addrs, a)
	}

	for _, a := range scan.addrs {
		scan.byAddr[a.address] = a
		if a.priv != nil {
			scan.keys[a.address] = a.priv
		}
	}
	return scan, nil
}

// chainDeriver derives the address+key at an index of one derivation chain.
type chainDeriver func(index uint32) (scannedAddr, error)

// chainDerivers returns the external+change derivers for a wallet from its
// output descriptor. The second return is true for watch-only (no priv keys).
func (p *ElectrumBackend) chainDerivers(w *WalletData) ([]chainDeriver, bool, error) {
	d, err := p.walletDescriptor(w)
	if err != nil {
		return nil, false, err
	}
	var out []chainDeriver
	for _, change := range []bool{false, true} {
		change := change
		out = append(out, func(i uint32) (scannedAddr, error) {
			return p.deriveAddr(d, change, i)
		})
	}
	return out, w.IsWatchOnly(), nil
}

func (p *ElectrumBackend) scanChain(ctx context.Context, derive chainDeriver) ([]scannedAddr, error) {
	var out []scannedAddr
	consecutiveUnused := 0
	for i := uint32(0); consecutiveUnused < electrumGapLimit && i < electrumMaxScan; i++ {
		a, err := derive(i)
		if err != nil {
			return nil, err
		}
		stats, err := p.client.AddressStats(ctx, a.address)
		if err != nil {
			return nil, fmt.Errorf("address stats %s: %w", a.address, err)
		}
		a.stats = stats
		out = append(out, a)
		if stats.Used() {
			consecutiveUnused = 0
		} else {
			consecutiveUnused++
		}
	}
	return out, nil
}

// watchOnlyDescriptorString returns the descriptor (or bare xpub) stored in a
// watch-only wallet's payload, for ParseDescriptor.
func watchOnlyDescriptorString(w *WalletData) (string, error) {
	var stored struct {
		Xpub       string `json:"xpub"`
		Descriptor string `json:"descriptor"`
	}
	if len(w.WatchOnly) > 0 {
		if err := json.Unmarshal(w.WatchOnly, &stored); err != nil {
			return "", fmt.Errorf("parse watch-only data: %w", err)
		}
	}
	if stored.Descriptor != "" {
		return stored.Descriptor, nil
	}
	if stored.Xpub != "" {
		return stored.Xpub, nil
	}
	return "", errors.New("watch-only electrum wallet has no descriptor or xpub")
}

func (p *ElectrumBackend) watchKeyAddr(ctx context.Context, k WatchKey) (scannedAddr, error) {
	wif, err := btcutil.DecodeWIF(k.WIF)
	if err != nil {
		return scannedAddr{}, fmt.Errorf("decode watch WIF: %w", err)
	}
	pubHash := btcutil.Hash160(wif.PrivKey.PubKey().SerializeCompressed())
	addr, err := btcutil.NewAddressPubKeyHash(pubHash, p.network)
	if err != nil {
		return scannedAddr{}, fmt.Errorf("watch key address: %w", err)
	}
	encoded := addr.EncodeAddress()
	stats, err := p.client.AddressStats(ctx, encoded)
	if err != nil {
		return scannedAddr{}, fmt.Errorf("watch key stats: %w", err)
	}
	return scannedAddr{address: encoded, priv: wif.PrivKey, stats: stats}, nil
}

// ============================================================================
// Mapping helpers
// ============================================================================

type electrumUTXO struct {
	txid       string
	vout       int
	address    string
	amountSats int64
	confirmed  bool
}

func (p *ElectrumBackend) spendableUTXOs(ctx context.Context, scan *electrumScan) ([]electrumUTXO, error) {
	var out []electrumUTXO
	for _, a := range scan.addrs {
		if !a.stats.Used() {
			continue
		}
		utxos, err := p.client.AddressUTXOs(ctx, a.address)
		if err != nil {
			return nil, err
		}
		for _, u := range utxos {
			out = append(out, electrumUTXO{
				txid:       u.TxID,
				vout:       u.Vout,
				address:    a.address,
				amountSats: u.Value,
				confirmed:  u.Status.Confirmed,
			})
		}
	}
	return out, nil
}

func findUTXO(pool []electrumUTXO, txid string, vout int) (electrumUTXO, bool) {
	for _, u := range pool {
		if u.txid == txid && u.vout == vout {
			return u, true
		}
	}
	return electrumUTXO{}, false
}

// walletFlow returns the sats flowing out of and into the wallet for a tx:
// ownIn = value of prevouts the wallet controls, ownOut = value of outputs
// paying the wallet.
func walletFlow(tx EsploraTx, scan *electrumScan) (ownIn, ownOut int64) {
	for _, vin := range tx.Vin {
		if vin.Prevout != nil && scan.owns(vin.Prevout.ScriptPubKeyAddress) {
			ownIn += vin.Prevout.Value
		}
	}
	for _, vout := range tx.Vout {
		if scan.owns(vout.ScriptPubKeyAddress) {
			ownOut += vout.Value
		}
	}
	return ownIn, ownOut
}

// walletRowsForTx maps one Esplora tx to listtransactions-style rows: a send
// row per external destination when the wallet funded any input, otherwise a
// receive row per output paying the wallet.
func walletRowsForTx(tx EsploraTx, scan *electrumScan, tip int) []WalletTransaction {
	ownIn, _ := walletFlow(tx, scan)
	confs := confsFor(tx.Status, tip)
	var rows []WalletTransaction

	if ownIn > 0 {
		feeApplied := false
		for _, vout := range tx.Vout {
			if scan.owns(vout.ScriptPubKeyAddress) {
				continue // change back to us is not a payment row
			}
			row := WalletTransaction{
				Address:       vout.ScriptPubKeyAddress,
				Category:      "send",
				Amount:        -float64(vout.Value) / 1e8,
				Confirmations: confs,
				BlockTime:     tx.Status.BlockTime,
				Time:          tx.Status.BlockTime,
				TxID:          tx.TxID,
			}
			if !feeApplied {
				row.Fee = -float64(tx.Fee) / 1e8
				feeApplied = true
			}
			rows = append(rows, row)
		}
		if len(rows) == 0 {
			// Self-send / consolidation: every output returns to the wallet, so
			// there's no external payment row. Emit one so the tx and its fee
			// still appear in history.
			var addr string
			if len(tx.Vout) > 0 {
				addr = tx.Vout[0].ScriptPubKeyAddress
			}
			rows = append(rows, WalletTransaction{
				Address:       addr,
				Category:      "send",
				Amount:        0,
				Fee:           -float64(tx.Fee) / 1e8,
				Confirmations: confs,
				BlockTime:     tx.Status.BlockTime,
				Time:          tx.Status.BlockTime,
				TxID:          tx.TxID,
			})
		}
		return rows
	}

	for n, vout := range tx.Vout {
		if !scan.owns(vout.ScriptPubKeyAddress) {
			continue
		}
		rows = append(rows, WalletTransaction{
			Address:       vout.ScriptPubKeyAddress,
			Category:      "receive",
			Amount:        float64(vout.Value) / 1e8,
			Vout:          n,
			Confirmations: confs,
			BlockTime:     tx.Status.BlockTime,
			Time:          tx.Status.BlockTime,
			TxID:          tx.TxID,
		})
	}
	return rows
}

func esploraTxToRaw(tx EsploraTx, rawHex string, tip int) *RawTransaction {
	raw := &RawTransaction{
		TxID:          tx.TxID,
		Hash:          tx.TxID,
		Hex:           rawHex,
		Size:          tx.Size,
		Vsize:         int32(math.Ceil(float64(tx.Weight) / 4)),
		Weight:        tx.Weight,
		Version:       tx.Version,
		Locktime:      tx.Locktime,
		Blockhash:     tx.Status.BlockHash,
		Confirmations: int32(confsFor(tx.Status, tip)),
		BlockTime:     tx.Status.BlockTime,
		Time:          tx.Status.BlockTime,
	}
	for _, vin := range tx.Vin {
		in := RawTxIn{Vout: vin.Vout, Sequence: vin.Sequence, Witness: vin.Witness}
		if vin.IsCoinbase {
			in.Coinbase = vin.ScriptSig
		} else {
			in.TxID = vin.TxID
		}
		raw.Vin = append(raw.Vin, in)
	}
	for n, vout := range tx.Vout {
		raw.Vout = append(raw.Vout, RawTxOut{
			Value: float64(vout.Value) / 1e8,
			N:     n,
			ScriptPubKey: ScriptPubKey{
				Asm:     vout.ScriptPubKeyAsm,
				Hex:     vout.ScriptPubKey,
				Type:    vout.ScriptPubKeyType,
				Address: vout.ScriptPubKeyAddress,
			},
		})
	}
	return raw
}

func confsFor(status EsploraStatus, tip int) int {
	if !status.Confirmed || status.BlockHeight == 0 {
		return 0
	}
	if c := tip - status.BlockHeight + 1; c > 0 {
		return c
	}
	return 0
}

// estimateFeeSats approximates the fee for a P2WPKH tx with nIn inputs and
// nOut outputs at feeRate sat/vB (~68 vB/input, ~31 vB/output, 11 vB base).
func estimateFeeSats(nIn, nOut int, feeRate float64) int64 {
	vsize := 11 + nIn*68 + nOut*31
	return int64(math.Ceil(float64(vsize) * feeRate))
}
