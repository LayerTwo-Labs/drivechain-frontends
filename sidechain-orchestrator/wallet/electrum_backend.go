package wallet

import (
	"bytes"
	"context"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"math"
	"net"
	neturl "net/url"
	"sort"
	"strconv"
	"strings"
	"sync"
	"time"

	"connectrpc.com/connect"
	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/btcutil/psbt"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/rs/zerolog"
	"github.com/samber/lo"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/replay"
)

const (
	// electrumGapLimit is the BIP44 gap limit: scanning a chain stops after
	// this many consecutive unused addresses.
	electrumGapLimit = 20
	// electrumMaxScan caps per-chain derivation so a misbehaving backend
	// can't drive an unbounded scan.
	electrumMaxScan = 1000
	// electrumScanTTL re-walks the cache this often even without a new block,
	// so mempool funds surface within seconds instead of at the next block.
	electrumScanTTL = 15 * time.Second
)

// ElectrumBackend serves a wallet with no local Core or enforcer: it derives
// BIP84 keys from the wallet seed, reads chain state from an Esplora REST
// backend, and builds/signs/broadcasts transactions in-process.
// SwappableChainSource is a ChainDataSource whose endpoint can be changed at
// runtime. *EsploraClient implements it; in-memory test backends need not.
type SwappableChainSource interface {
	ChainDataSource
	BaseURLs() []string
	SetBaseURLs([]string)
	ProxyConfig() (bool, string)
	SetProxy(enabled bool, proxyAddr string) error
}

type ElectrumBackend struct {
	svc     *Service
	client  ChainDataSource
	network *chaincfg.Params
	log     zerolog.Logger

	mu        sync.Mutex
	watchKeys map[string][]WatchKey    // walletID -> extra keys to track
	warm      map[string]bool          // walletID -> a live scan has run this process
	warmScan  map[string]*electrumScan // walletID -> cached scan, served between blocks
	tipAt     map[string]int           // walletID -> chain tip the cached scan reflects
	scanAt    map[string]time.Time     // walletID -> when the cached scan was taken
	lastScan  map[string][]byte        // walletID -> last persisted scan bytes (skip rewrites)

	// scanLocks serialises live scans per wallet so concurrent readers
	// (balance, txs, utxos, stats all poll at once) collapse into a single
	// gap-walk instead of each firing its own burst of Esplora requests.
	scanMu    sync.Mutex
	scanLocks map[string]*sync.Mutex

	// Push subscriptions: scripthash -> last status and -> walletID, so a server
	// push refreshes exactly the affected wallet instead of polling.
	subMu        sync.Mutex
	subStatus    map[string]string
	shWallet     map[string]string
	consumerOnce sync.Once
}

var (
	_ Backend      = (*ElectrumBackend)(nil)
	_ Bip47Backend = (*ElectrumBackend)(nil)
)

// NewElectrumBackend creates an Esplora-backed wallet backend.
func NewElectrumBackend(svc *Service, client ChainDataSource, network *chaincfg.Params, log zerolog.Logger) *ElectrumBackend {
	return &ElectrumBackend{
		svc:       svc,
		client:    client,
		network:   network,
		log:       log.With().Str("component", "electrum-backend").Logger(),
		watchKeys: make(map[string][]WatchKey),
		warm:      make(map[string]bool),
		warmScan:  make(map[string]*electrumScan),
		tipAt:     make(map[string]int),
		scanAt:    make(map[string]time.Time),
		lastScan:  make(map[string][]byte),
		scanLocks: make(map[string]*sync.Mutex),
		subStatus: make(map[string]string),
		shWallet:  make(map[string]string),
	}
}

// FeeRateForTarget returns the esplora sat/vB fee estimate for a confirmation target.
func (p *ElectrumBackend) FeeRateForTarget(ctx context.Context, target int) float64 {
	return p.client.FeeRateForTarget(ctx, target, 1.0)
}

// scannedAddr is one derived (or watched) address with its key and current
// funding stats.
type scannedAddr struct {
	address         string
	priv            *btcec.PrivateKey
	pub             *btcec.PublicKey
	scriptPubKey    []byte
	redeem          []byte              // P2SH-P2WPKH redeem (nested segwit)
	witnessScript   []byte              // P2WSH multisig script
	multisigPrivs   []*btcec.PrivateKey // multisig: the keys this wallet holds
	tapInternal     *btcec.PublicKey    // taproot internal key
	tapLeafScript   []byte              // tr sortedmulti_a: the tapleaf multi_a script
	tapControlBlock []byte              // tr sortedmulti_a: the leaf's control block
	kind            ScriptKind
	change          bool
	index           uint32
	hdPath          string
	derivations     []keyDerivation // PSBT key-derivation records (signer key matching)
	stats           EsploraAddressStats
	// utxos and txs are the address's chain data, fetched alongside stats and
	// cached on the scan so balance/utxo/history reads never re-hit Esplora.
	// Both are empty for an unused address.
	utxos []EsploraUTXO
	txs   []EsploraTx
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
	return lo.CountBy(p.svc.GetAllWallets(), func(w WalletData) bool {
		return w.WalletType == WalletTypeElectrum
	}), nil
}

func (p *ElectrumBackend) Balance(ctx context.Context, walletID string) (float64, float64, error) {
	scan, err := p.scanWallet(ctx, walletID)
	if err != nil {
		return 0, 0, err
	}
	// confirmed = confirmed coins not being spent in the mempool; pending = the
	// rest, derived from the true total so spending unconfirmed coins nets out.
	var confirmedNet, mempoolFunded, mempoolSpent int64
	for _, a := range scan.addrs {
		confirmedNet += a.stats.ChainStats.FundedTxoSum - a.stats.ChainStats.SpentTxoSum
		mempoolFunded += a.stats.MempoolStats.FundedTxoSum
		mempoolSpent += a.stats.MempoolStats.SpentTxoSum
	}
	total := confirmedNet + mempoolFunded - mempoolSpent
	confirmed := max(confirmedNet-mempoolSpent, 0)
	pending := total - confirmed
	return float64(confirmed) / 1e8, float64(pending) / 1e8, nil
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
	out := lo.FlatMap(scan.addrs, func(a scannedAddr, _ int) []UTXO {
		return lo.Map(a.utxos, func(u EsploraUTXO, _ int) UTXO {
			return UTXO{
				TxID:          u.TxID,
				Vout:          u.Vout,
				Address:       a.address,
				Amount:        float64(u.Value) / 1e8,
				Confirmations: confsFor(u.Status, tip),
				// Watch-only wallets hold no keys, so their coins are solvable
				// (we know the script) but not spendable.
				Spendable:  !scan.watchOnly,
				Solvable:   true,
				ReceivedAt: u.Status.BlockTime,
			}
		})
	})
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

	allTxs := lo.FlatMap(scan.addrs, func(a scannedAddr, _ int) []EsploraTx { return a.txs })
	txByID := lo.KeyBy(allTxs, func(tx EsploraTx) string { return tx.TxID })

	rows := lo.FlatMap(lo.Values(txByID), func(tx EsploraTx, _ int) []WalletTransaction {
		return walletRowsForTx(tx, scan, tip)
	})

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
	// Shares the tip-gated scan the rest of the wallet reads use, so the receive
	// list reflects the same chain state as the balance instead of a stale cache.
	scan, err := p.scanWallet(ctx, walletID)
	if err != nil {
		return nil, err
	}
	tip, _ := p.client.TipHeight(ctx)

	// The scan walks the full gap-limit lookahead, but the list should stop at
	// the highest index that has received funds, tracked per derivation chain
	// (script kind × external/change), since each is independent. External chains
	// also show the next unused address (the one the receive screen hands out);
	// change chains do not — an unused change address is never offered manually.
	type chainKey struct {
		kind   ScriptKind
		change bool
	}
	highestReceived := make(map[chainKey]int)
	for _, a := range scan.addrs {
		if a.hdPath == "" {
			continue
		}
		key := chainKey{a.kind, a.change}
		if _, ok := highestReceived[key]; !ok {
			highestReceived[key] = -1
		}
		received := a.stats.ChainStats.FundedTxoCount > 0 || a.stats.MempoolStats.FundedTxoCount > 0
		if received && int(a.index) > highestReceived[key] {
			highestReceived[key] = int(a.index)
		}
	}

	out := make([]ReceivedByAddress, 0, len(scan.addrs))
	for _, a := range scan.addrs {
		if a.hdPath == "" {
			continue
		}
		limit := highestReceived[chainKey{a.kind, a.change}]
		if !a.change {
			limit++ // external: also show the next unused receive address
		}
		if int(a.index) > limit {
			continue
		}
		// Current balance for the address: funded minus spent, on-chain and in
		// the mempool. The column shows the live balance, not gross received.
		balance := (a.stats.ChainStats.FundedTxoSum - a.stats.ChainStats.SpentTxoSum) +
			(a.stats.MempoolStats.FundedTxoSum - a.stats.MempoolStats.SpentTxoSum)
		entry := ReceivedByAddress{Address: a.address, Amount: float64(balance) / 1e8, Change: a.change}
		for _, tx := range a.txs {
			entry.TxIDs = append(entry.TxIDs, tx.TxID)
			if c := confsFor(tx.Status, tip); c > entry.Confirmations {
				entry.Confirmations = c
			}
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
	amountSats := ownOut - ownIn
	if ownIn > 0 {
		// We funded the tx, so the fee left our wallet inside ownIn; add it back
		// so Amount is the payment only (the fee is reported separately), matching
		// Core's listtransactions semantics.
		fee = -float64(tx.Fee) / 1e8
		amountSats += tx.Fee
	}
	return &WalletTx{
		TxID:          tx.TxID,
		Amount:        float64(amountSats) / 1e8,
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

func (p *ElectrumBackend) NextReceiveAddress(ctx context.Context, walletID string, kind ScriptKind) (string, error) {
	w := p.svc.GetWalletByID(walletID)
	if w == nil {
		return "", fmt.Errorf("wallet %s not found", walletID)
	}
	// ScriptUnknown is the default sentinel ("the wallet's natural kind").
	target := kind
	if target == ScriptUnknown {
		target = w.scriptKind()
	}
	// A multisig wallet has exactly one address kind — the one its descriptor
	// defines. A single-sig address type (native-segwit/taproot/…) doesn't apply,
	// so always serve the wallet's own kind instead of rejecting the request.
	if w.Multisig != nil {
		target = w.scriptKind()
	}
	// Serving a kind the wallet doesn't derive would yield an address it can
	// neither track nor spend, so reject it rather than silently downgrade.
	if !lo.Contains(p.receiveKinds(w), target) {
		return "", connect.NewError(
			connect.CodeUnimplemented,
			fmt.Errorf("electrum wallet does not derive %s addresses", target),
		)
	}
	return p.nextUnused(walletID, target, false)
}

func (p *ElectrumBackend) NextChangeAddress(ctx context.Context, walletID string) (string, error) {
	w := p.svc.GetWalletByID(walletID)
	if w == nil {
		return "", fmt.Errorf("wallet %s not found", walletID)
	}
	return p.nextUnused(walletID, w.scriptKind(), true)
}

// nextUnused picks the next unused address of a kind with no network call: a
// plain SELECT for the lowest-index address on the chain with no history, and
// when none is on record (fresh wallet, or every stored address is used) it
// derives the next index locally. Either way it is instant — address allocation
// never blocks on a scan. The background scan keeps electrum_addresses current.
func (p *ElectrumBackend) nextUnused(walletID string, kind ScriptKind, change bool) (string, error) {
	if addr, ok := p.svc.firstUnusedAddress(walletID, kind, change); ok {
		return addr, nil
	}
	w := p.svc.GetWalletByID(walletID)
	if w == nil {
		return "", fmt.Errorf("wallet %s not found", walletID)
	}
	derivers, err := p.kindDerivers(w, kind)
	if err != nil {
		return "", err
	}
	a, err := derivers[chainIndex(change)](uint32(p.svc.maxAddressIndex(walletID, kind, change) + 1))
	if err != nil {
		return "", err
	}
	return a.address, nil
}

// nextUnusedAddrFromScan returns the next unused address on a chain from an
// existing scan (with derivation records), for the send path that builds a
// change output without a second wallet scan.
func (p *ElectrumBackend) nextUnusedAddrFromScan(walletID string, scan *electrumScan, kind ScriptKind, change bool) (scannedAddr, error) {
	highest := -1
	for _, a := range scan.addrs {
		// Skip BIP47 watch keys (empty hdPath); they aren't part of the
		// derivation chain. Watch-only chain addresses have no priv key but
		// still advance the chain, so the chain marker is hdPath, not priv.
		if a.hdPath == "" || a.change != change || a.kind != kind {
			continue
		}
		if int(a.index) > highest {
			highest = int(a.index)
		}
		if !a.stats.Used() {
			return a, nil
		}
	}
	// Every scanned address is used — derive the next index past the scan.
	w := p.svc.GetWalletByID(walletID)
	if w == nil {
		return scannedAddr{}, fmt.Errorf("wallet %s not found", walletID)
	}
	derivers, err := p.kindDerivers(w, kind)
	if err != nil {
		return scannedAddr{}, err
	}
	a, err := derivers[chainIndex(change)](uint32(highest + 1))
	if err != nil {
		return scannedAddr{}, err
	}
	return a, nil
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
	added := false
	for _, k := range keys {
		if !seen[k.WIF] {
			existing = append(existing, k)
			seen[k.WIF] = true
			added = true
		}
	}
	p.watchKeys[walletID] = existing
	if added {
		// The cache is keyed on a fixed address set + chain tip. BIP47 grows the
		// address set mid-session without a new block, so tip-gating alone would
		// keep serving the stale scan and never see payments to the new
		// addresses. Drop the cache to force a re-walk on the next read.
		delete(p.warmScan, walletID)
		delete(p.scanAt, walletID)
	}
	return nil
}

// EnsureNotificationWatched registers the wallet's own BIP47 notification key so
// the scan tracks its notification address and inbound notification txs surface
// in ListTransactionsRange.
func (p *ElectrumBackend) EnsureNotificationWatched(ctx context.Context, walletID string, notifKey WatchKey) error {
	return p.WatchKeys(ctx, walletID, []WatchKey{notifKey})
}

func (p *ElectrumBackend) Send(ctx context.Context, walletID string, req SendRequest) (string, error) {
	scan, err := p.scanForSend(ctx, walletID, req)
	if err != nil {
		return "", err
	}
	if scan.watchOnly {
		return "", errors.New("watch-only electrum wallet cannot sign or send")
	}
	packet, psbtInputs, effect, err := p.buildSendPSBT(ctx, walletID, scan, req)
	if err != nil {
		return "", err
	}
	return p.signAndBroadcast(ctx, walletID, packet, psbtInputs, effect, req.ReplayProtect)
}

// signAndBroadcast signs the wallet's inputs in packet, finalizes, broadcasts,
// and folds the spend into the cached scan. replayProtect stamps the magic
// nLockTime and non-final sequences before signing.
func (p *ElectrumBackend) signAndBroadcast(ctx context.Context, walletID string, packet *psbt.Packet, psbtInputs []psbtInput, effect *spendEffect, replayProtect bool) (string, error) {
	if replayProtect {
		replay.ApplyLockTime(packet.UnsignedTx)
	}
	signedCount, err := signPSBT(packet, psbtInputs, p.network)
	if err != nil {
		return "", fmt.Errorf("sign psbt: %w", err)
	}
	// External inputs (e.g. a CTIP) are pre-finalized and need no signature; only
	// the wallet's own inputs must be signed.
	walletInputs := 0
	for i := range psbtInputs {
		if !psbtInputs[i].external {
			walletInputs++
		}
	}
	if signedCount < walletInputs {
		return "", errors.New("transaction signing incomplete")
	}
	hexToSend, err := finalizeAndExtract(packet)
	if err != nil {
		return "", err
	}
	txid, err := p.client.Broadcast(ctx, hexToSend)
	if err != nil {
		return "", err
	}
	// We already know exactly what the spend changed — the inputs it consumed and
	// the change it created — so apply that to the cached scan directly instead of
	// re-walking the whole wallet over Esplora. Balance/utxo reads reflect the
	// send immediately; the next block's scan reconciles against the chain.
	p.applySpend(walletID, txid, effect, packet)
	return txid, nil
}

// spendEffect captures what a send consumed and produced so the cached scan can
// be updated in place after broadcast instead of re-walking the wallet: the
// inputs it spent and the change it created (change is nil when none).
type spendEffect struct {
	spent      []electrumUTXO
	change     *scannedAddr
	changeSats int64
}

// applySpend folds a just-broadcast send into the cached scan with no network
// call: it drops the spent UTXOs (marking their addresses mempool-spent) and
// adds the change UTXO (marking the change address mempool-funded), so balance
// and UTXO reads reflect the send at once. The next block's scan reconciles this
// optimistic view against the chain.
func (p *ElectrumBackend) applySpend(walletID, txid string, effect *spendEffect, packet *psbt.Packet) {
	if effect == nil {
		return
	}
	p.mu.Lock()
	cached := p.warmScan[walletID]
	p.mu.Unlock()
	if cached == nil {
		return // nothing cached; the next read scans fresh anyway
	}
	scan := copyScan(cached)

	// The synthesized mempool tx, stamped now so it sorts to the top of history
	// as the newest entry. The next block's scan replaces it with the confirmed
	// version from Esplora.
	sentTx := buildSentTx(txid, effect, packet, p.network, time.Now().Unix())

	spentOutpoints := make(map[string]bool, len(effect.spent))
	spentByAddr := make(map[string]int64)
	for _, u := range effect.spent {
		spentOutpoints[fmt.Sprintf("%s:%d", u.txid, u.vout)] = true
		spentByAddr[u.address] += u.amountSats
	}
	for i := range scan.addrs {
		a := &scan.addrs[i]
		sats, ok := spentByAddr[a.address]
		if !ok {
			continue
		}
		a.utxos = lo.Filter(a.utxos, func(u EsploraUTXO, _ int) bool {
			return !spentOutpoints[fmt.Sprintf("%s:%d", u.TxID, u.Vout)]
		})
		a.stats.MempoolStats.SpentTxoSum += sats
		a.stats.MempoolStats.SpentTxoCount++
		a.stats.MempoolStats.TxCount++
		a.txs = append(append([]EsploraTx(nil), a.txs...), sentTx)
	}

	if effect.change != nil {
		vout := -1
		for i, out := range packet.UnsignedTx.TxOut {
			if bytes.Equal(out.PkScript, effect.change.scriptPubKey) {
				vout = i
				break
			}
		}
		if vout >= 0 {
			utxo := EsploraUTXO{TxID: txid, Vout: vout, Value: effect.changeSats}
			if i := indexOfAddr(scan.addrs, effect.change.address); i >= 0 {
				a := &scan.addrs[i]
				a.utxos = append(append([]EsploraUTXO(nil), a.utxos...), utxo)
				a.stats.MempoolStats.FundedTxoSum += effect.changeSats
				a.stats.MempoolStats.FundedTxoCount++
				a.stats.MempoolStats.TxCount++
				a.txs = append(append([]EsploraTx(nil), a.txs...), sentTx)
			} else {
				ca := *effect.change
				ca.utxos = []EsploraUTXO{utxo}
				ca.txs = []EsploraTx{sentTx}
				ca.stats.Address = ca.address
				ca.stats.MempoolStats.FundedTxoSum += effect.changeSats
				ca.stats.MempoolStats.FundedTxoCount++
				ca.stats.MempoolStats.TxCount++
				scan.addrs = append(scan.addrs, ca)
			}
		}
	}

	finalizeScan(scan)
	p.mu.Lock()
	p.warmScan[walletID] = scan
	p.mu.Unlock()
	p.persistScan(walletID, scan)
}

// buildSentTx reconstructs the Esplora view of a just-broadcast send from the
// data we already hold: the prevouts it spent (address + value) and the outputs
// it created (decoded from the packet). Marked unconfirmed and stamped at now so
// history and walletRowsForTx render it exactly like the real tx will.
func buildSentTx(txid string, effect *spendEffect, packet *psbt.Packet, net *chaincfg.Params, now int64) EsploraTx {
	var inSum int64
	vin := lo.Map(effect.spent, func(u electrumUTXO, _ int) EsploraVin {
		inSum += u.amountSats
		return EsploraVin{
			TxID:    u.txid,
			Vout:    u.vout,
			Prevout: &EsploraVout{ScriptPubKeyAddress: u.address, Value: u.amountSats},
		}
	})
	var outSum int64
	vout := lo.Map(packet.UnsignedTx.TxOut, func(out *wire.TxOut, _ int) EsploraVout {
		outSum += out.Value
		addr := ""
		if _, addrs, _, err := txscript.ExtractPkScriptAddrs(out.PkScript, net); err == nil && len(addrs) > 0 {
			addr = addrs[0].EncodeAddress()
		}
		return EsploraVout{ScriptPubKeyAddress: addr, Value: out.Value}
	})
	return EsploraTx{
		TxID:   txid,
		Vin:    vin,
		Vout:   vout,
		Fee:    inSum - outSum,
		Status: EsploraStatus{Confirmed: false, BlockTime: now},
	}
}

// copyScan returns a copy of a scan with fresh addrs/byAddr/keys containers, so
// applySpend can mutate it without racing readers of the original.
func copyScan(s *electrumScan) *electrumScan {
	return &electrumScan{
		addrs:     append([]scannedAddr(nil), s.addrs...),
		byAddr:    make(map[string]scannedAddr, len(s.byAddr)),
		keys:      make(mapKeySource, len(s.keys)),
		watchOnly: s.watchOnly,
	}
}

func indexOfAddr(addrs []scannedAddr, address string) int {
	for i := range addrs {
		if addrs[i].address == address {
			return i
		}
	}
	return -1
}

// buildSendPSBT performs coin selection and builds an unsigned PSBT for a send.
// It does not require signing keys, so it serves both Send and CreatePSBT
// (including watch-only wallets, which produce a PSBT for an external signer).
func (p *ElectrumBackend) buildSendPSBT(ctx context.Context, walletID string, scan *electrumScan, req SendRequest) (*psbt.Packet, []psbtInput, *spendEffect, error) {
	if req.FeeRateSatPerVB > 0 && req.FixedFeeSats > 0 {
		return nil, nil, nil, errors.New("fee rate and fixed fee are mutually exclusive")
	}
	// Destinations come from a map, so the first output is not stable; only a
	// single-recipient subtract-fee send has a well-defined output to reduce.
	if req.SubtractFeeFromAmount && len(req.DestinationsSats) > 1 {
		return nil, nil, nil, errors.New("subtractFeeFromAmount requires a single destination")
	}
	outputs, totalOutSats := buildSendOutputs(req)

	pool := p.spendableUTXOs(scan)

	// External (non-wallet) inputs — e.g. an anyone-can-spend sidechain CTIP —
	// contribute their value toward the outputs but are not signed by us. Their
	// vsize is not added to fee estimation, so callers that supply them use a
	// fixed fee (FixedFeeSats).
	externalSats := int64(0)
	for _, ei := range req.ExternalInputs {
		externalSats += ei.AmountSats
	}

	// Pin required inputs, then fill from the remaining pool largest-first.
	required := make(map[string]bool)
	var selected []electrumUTXO
	selectedSats := externalSats
	for _, ri := range req.RequiredInputs {
		key := fmt.Sprintf("%s:%d", ri.TxID, ri.Vout)
		required[key] = true
		u, ok := findUTXO(pool, ri.TxID, ri.Vout)
		if !ok {
			return nil, nil, nil, fmt.Errorf("required input %s not found among wallet UTXOs", key)
		}
		selected = append(selected, u)
		selectedSats += u.amountSats
	}
	remaining := lo.Filter(pool, func(u electrumUTXO, _ int) bool {
		return !required[fmt.Sprintf("%s:%d", u.txid, u.vout)]
	})
	sort.Slice(remaining, func(i, j int) bool { return remaining[i].amountSats > remaining[j].amountSats })

	feeRate := float64(req.FeeRateSatPerVB)
	if feeRate <= 0 {
		feeRate = p.client.FeeRateForTarget(ctx, 6, 1.0)
		if feeRate < 1 {
			feeRate = 1
		}
	}

	// Per-type sizing: input vsize from the wallet descriptor (accurate for
	// m-of-n multisig), output vsize per recipient script type, plus the change
	// output (the wallet's own type) unless a send leaves none.
	w := p.svc.GetWalletByID(walletID)
	if w == nil {
		return nil, nil, nil, fmt.Errorf("wallet %s not found", walletID)
	}
	d, err := p.walletDescriptor(w)
	if err != nil {
		return nil, nil, nil, err
	}
	inVsize := walletInputVsize(d)
	changeDust := dustThreshold(d.Kind)
	withChange := true
	feeSats := func(nIn int) int64 {
		if req.FixedFeeSats > 0 {
			return req.FixedFeeSats
		}
		outVsize := 0
		for _, o := range outputs {
			outVsize += outputVsize(o, p.network)
		}
		if withChange {
			outVsize += outputVsizeForKind(d.Kind)
		}
		return estimateFeeSats(nIn, inVsize, outVsize, feeRate)
	}

	i := 0
	for {
		fee := feeSats(len(selected))
		// Subtract-fee sends take the fee out of the first output, so they only
		// need to cover the output total; change (if any) returns as normal.
		target := totalOutSats + fee
		if req.SubtractFeeFromAmount {
			target = totalOutSats
		}
		if len(selected) > 0 && selectedSats >= target {
			break
		}
		if i >= len(remaining) {
			return nil, nil, nil, fmt.Errorf("insufficient funds: need %d sats, have %d sats", target, selectedSats)
		}
		selected = append(selected, remaining[i])
		selectedSats += remaining[i].amountSats
		i++
	}

	// Subtract-fee change is known before the fee (its selection target ignores
	// fee), so drop the assumed change output when none will clear dust.
	if req.SubtractFeeFromAmount && selectedSats-totalOutSats < changeDust {
		withChange = false
	}
	fee := feeSats(len(selected))
	var changeSats int64
	if req.SubtractFeeFromAmount {
		if len(outputs) == 0 || outputs[0].OpReturnHex != "" {
			return nil, nil, nil, errors.New("subtractFeeFromAmount requires a payable first output")
		}
		// Take the fee out of the first output; the rest of the selected value
		// returns as change, matching Bitcoin Core's subtract-fee semantics.
		reduced := int64(math.Round(outputs[0].AmountBTC*1e8)) - fee
		if reduced < dustForOutput(outputs[0], p.network) {
			return nil, nil, nil, fmt.Errorf("fee %d sats exceeds first output", fee)
		}
		outputs[0].AmountBTC = float64(reduced) / 1e8
		changeSats = selectedSats - totalOutSats
	} else {
		changeSats = selectedSats - totalOutSats - fee
	}
	if changeSats < 0 {
		return nil, nil, nil, fmt.Errorf("insufficient funds: short %d sats", -changeSats)
	}
	effect := &spendEffect{spent: selected}
	if changeSats >= changeDust {
		changeAddr, err := p.nextUnusedAddrFromScan(walletID, scan, w.scriptKind(), true)
		if err != nil {
			return nil, nil, nil, fmt.Errorf("derive change address: %w", err)
		}
		effect.change = &changeAddr
		effect.changeSats = changeSats
		outputs = append(outputs, TxOutSpec{
			Address:     changeAddr.address,
			AmountBTC:   float64(changeSats) / 1e8,
			Kind:        changeAddr.kind,
			Derivations: changeAddr.derivations,
		})
	}

	// External inputs come first (e.g. the CTIP at input 0), then wallet inputs.
	psbtInputs := make([]psbtInput, 0, len(req.ExternalInputs)+len(selected))
	for _, ei := range req.ExternalInputs {
		h, err := chainhash.NewHashFromStr(ei.TxID)
		if err != nil {
			return nil, nil, nil, fmt.Errorf("parse external input txid %q: %w", ei.TxID, err)
		}
		psbtInputs = append(psbtInputs, psbtInput{
			outpoint: wire.OutPoint{Hash: *h, Index: uint32(ei.Vout)},
			amount:   ei.AmountSats,
			external: true,
		})
	}
	for _, u := range selected {
		sa, ok := scan.byAddr[u.address]
		if !ok {
			return nil, nil, nil, fmt.Errorf("no derivation info for input address %s", u.address)
		}
		h, err := chainhash.NewHashFromStr(u.txid)
		if err != nil {
			return nil, nil, nil, fmt.Errorf("parse input txid %q: %w", u.txid, err)
		}
		psbtInputs = append(psbtInputs, psbtInput{
			outpoint: wire.OutPoint{Hash: *h, Index: uint32(u.vout)},
			amount:   u.amountSats,
			addr:     sa,
		})
	}

	packet, err := buildPSBT(psbtInputs, outputs, p.network, p.prevTxFetcher(ctx))
	if err != nil {
		return nil, nil, nil, fmt.Errorf("build psbt: %w", err)
	}
	// Multisig hardware signers need the cosigner xpubs to register the policy.
	packet.XPubs = multisigGlobalXpubs(d)
	return packet, psbtInputs, effect, nil
}

func (p *ElectrumBackend) requireElectrum(walletID string) error {
	w := p.svc.GetWalletByID(walletID)
	if w == nil {
		return fmt.Errorf("wallet %s not found", walletID)
	}
	if w.WalletType != WalletTypeElectrum {
		return fmt.Errorf("wallet %s is not an electrum wallet", walletID)
	}
	return nil
}

// CreatePSBT builds an unsigned PSBT for a send and returns it base64-encoded.
func (p *ElectrumBackend) CreatePSBT(ctx context.Context, walletID string, req SendRequest) (string, error) {
	if err := p.requireElectrum(walletID); err != nil {
		return "", err
	}
	scan, err := p.scanForSend(ctx, walletID, req)
	if err != nil {
		return "", err
	}
	packet, _, _, err := p.buildSendPSBT(ctx, walletID, scan, req)
	if err != nil {
		return "", err
	}
	return packet.B64Encode()
}

// SignPSBT adds this wallet's signatures to a base64 PSBT and returns the
// updated PSBT. Inputs whose keys it doesn't hold are left for other signers.
func (p *ElectrumBackend) SignPSBT(ctx context.Context, walletID, psbtBase64 string) (string, error) {
	if err := p.requireElectrum(walletID); err != nil {
		return "", err
	}
	packet, err := decodePSBTBase64(psbtBase64)
	if err != nil {
		return "", err
	}
	scan, err := p.scanWallet(ctx, walletID)
	if err != nil {
		return "", err
	}
	inputs, err := p.psbtInputsFromPacket(packet, scan)
	if err != nil {
		return "", err
	}
	if _, err := signPSBT(packet, inputs, p.network); err != nil {
		return "", err
	}
	return packet.B64Encode()
}

// SignPSBTWithCosigner signs a multisig PSBT with a single held cosigner's key
// (identified by xpub), leaving the other legs for their own signers. It derives
// each input's signing key at the exact path the PSBT records, so no chain scan
// is needed — the per-keystore "Sign" action.
func (p *ElectrumBackend) SignPSBTWithCosigner(ctx context.Context, walletID, psbtBase64, cosignerXpub string) (string, error) {
	if err := p.requireElectrum(walletID); err != nil {
		return "", err
	}
	w := p.svc.GetWalletByID(walletID)
	if w == nil || w.Multisig == nil {
		return "", errors.New("wallet is not a multisig wallet")
	}
	packet, err := decodePSBTBase64(psbtBase64)
	if err != nil {
		return "", err
	}
	desc, err := p.multisigSigningDescriptorFor(w, cosignerXpub)
	if err != nil {
		return "", err
	}
	inputs := make([]psbtInput, len(packet.Inputs))
	for i := range packet.Inputs {
		change, index, ok := chainIndexFromInput(packet.Inputs[i])
		if !ok {
			return "", fmt.Errorf("psbt input %d has no derivation path to sign from", i)
		}
		sa, err := p.deriveAddr(desc, change, index)
		if err != nil {
			return "", err
		}
		out := prevOutForInput(packet, i)
		if out == nil {
			return "", fmt.Errorf("psbt input %d missing prevout", i)
		}
		inputs[i] = psbtInput{
			outpoint: packet.UnsignedTx.TxIn[i].PreviousOutPoint,
			amount:   out.Value,
			addr:     sa,
		}
	}
	if _, err := signPSBT(packet, inputs, p.network); err != nil {
		return "", err
	}
	return packet.B64Encode()
}

// chainIndexFromInput reads (change, index) from a PSBT input's BIP32 derivation
// path — its last two elements are the chain (0/1) and address index. Handles
// both the ECDSA (Bip32Derivation) and taproot (TaprootBip32Derivation) forms.
func chainIndexFromInput(in psbt.PInput) (change bool, index uint32, ok bool) {
	for _, d := range in.Bip32Derivation {
		if len(d.Bip32Path) >= 2 {
			return d.Bip32Path[len(d.Bip32Path)-2] == 1, d.Bip32Path[len(d.Bip32Path)-1], true
		}
	}
	for _, d := range in.TaprootBip32Derivation {
		if len(d.Bip32Path) >= 2 {
			return d.Bip32Path[len(d.Bip32Path)-2] == 1, d.Bip32Path[len(d.Bip32Path)-1], true
		}
	}
	return false, 0, false
}

// CombinePSBT merges signatures from several base64 PSBTs of the same tx.
func (p *ElectrumBackend) CombinePSBT(psbtsBase64 []string) (string, error) {
	if len(psbtsBase64) == 0 {
		return "", errors.New("no psbts to combine")
	}
	base, err := decodePSBTBase64(psbtsBase64[0])
	if err != nil {
		return "", err
	}
	others := make([]*psbt.Packet, 0, len(psbtsBase64)-1)
	for _, b := range psbtsBase64[1:] {
		o, err := decodePSBTBase64(b)
		if err != nil {
			return "", err
		}
		others = append(others, o)
	}
	if err := combinePSBT(base, others...); err != nil {
		return "", err
	}
	return base.B64Encode()
}

// FinalizePSBT finalizes a fully-signed base64 PSBT and returns the raw tx hex.
func (p *ElectrumBackend) FinalizePSBT(psbtBase64 string) (string, error) {
	packet, err := decodePSBTBase64(psbtBase64)
	if err != nil {
		return "", err
	}
	return finalizeAndExtract(packet)
}

// psbtInputsFromPacket reconstructs the per-input signing metadata for a PSBT by
// scanning the wallet and matching each input's prevout to a derived address.
func (p *ElectrumBackend) psbtInputsFromPacket(packet *psbt.Packet, scan *electrumScan) ([]psbtInput, error) {
	inputs := make([]psbtInput, len(packet.Inputs))
	for i := range packet.Inputs {
		out := prevOutForInput(packet, i)
		if out == nil {
			return nil, fmt.Errorf("psbt input %d missing prevout", i)
		}
		_, addrs, _, err := txscript.ExtractPkScriptAddrs(out.PkScript, p.network)
		if err != nil || len(addrs) == 0 {
			return nil, fmt.Errorf("psbt input %d: cannot resolve address", i)
		}
		sa, ok := scan.byAddr[addrs[0].EncodeAddress()]
		if !ok {
			return nil, fmt.Errorf("psbt input %d address %s is not in this wallet", i, addrs[0].EncodeAddress())
		}
		inputs[i] = psbtInput{
			outpoint: packet.UnsignedTx.TxIn[i].PreviousOutPoint,
			amount:   out.Value,
			addr:     sa,
		}
	}
	return inputs, nil
}

func decodePSBTBase64(b64 string) (*psbt.Packet, error) {
	packet, err := psbt.NewFromRawBytes(strings.NewReader(b64), true)
	if err != nil {
		return nil, fmt.Errorf("decode psbt: %w", err)
	}
	return packet, nil
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

// CreateCpfp builds a child transaction that spends an unconfirmed wallet UTXO
// back to a fresh wallet address, with a fee chosen so the parent+child package
// reaches req.TargetRate. Validation rejects a confirmed, unowned, or
// already-fast-enough parent.
func (p *ElectrumBackend) CreateCpfp(ctx context.Context, walletID string, req CpfpRequest) (string, error) {
	if err := p.requireElectrum(walletID); err != nil {
		return "", err
	}
	if req.TargetRate <= 0 {
		return "", connect.NewError(connect.CodeInvalidArgument, errors.New("target fee rate must be positive"))
	}

	scan, err := p.scanWallet(ctx, walletID)
	if err != nil {
		return "", err
	}
	if scan.watchOnly {
		return "", errors.New("watch-only electrum wallet cannot sign or send")
	}

	parentUTXO, ok := findUTXO(p.spendableUTXOs(scan), req.ParentTxID, req.ParentVout)
	if !ok {
		return "", connect.NewError(connect.CodeInvalidArgument,
			fmt.Errorf("outpoint %s:%d is not a spendable wallet UTXO", req.ParentTxID, req.ParentVout))
	}
	if parentUTXO.confirmed {
		return "", connect.NewError(connect.CodeInvalidArgument,
			fmt.Errorf("outpoint %s:%d is already confirmed; CPFP only applies to unconfirmed parents", req.ParentTxID, req.ParentVout))
	}

	parentTx, err := p.client.Tx(ctx, req.ParentTxID)
	if err != nil {
		return "", fmt.Errorf("fetch parent tx: %w", err)
	}
	parentVsize := int64(math.Ceil(float64(parentTx.Weight) / 4))
	parentFee := parentTx.Fee
	if parentVsize > 0 && req.TargetRate <= parentFee/parentVsize {
		return "", connect.NewError(connect.CodeInvalidArgument,
			fmt.Errorf("target rate %d sat/vB does not exceed parent rate %d sat/vB", req.TargetRate, parentFee/parentVsize))
	}

	w := p.svc.GetWalletByID(walletID)
	if w == nil {
		return "", fmt.Errorf("wallet %s not found", walletID)
	}
	d, err := p.walletDescriptor(w)
	if err != nil {
		return "", err
	}
	childVsize := int64(11 + walletInputVsize(d) + outputVsizeForKind(d.Kind))
	childFee := packageChildFee(req.TargetRate, parentVsize, parentFee, childVsize, 1)
	if childFee >= parentUTXO.amountSats {
		return "", connect.NewError(connect.CodeInvalidArgument,
			fmt.Errorf("child fee %d sats exceeds parent output value %d sats", childFee, parentUTXO.amountSats))
	}

	childAddr, err := p.nextUnusedAddrFromScan(walletID, scan, w.scriptKind(), false)
	if err != nil {
		return "", fmt.Errorf("derive child address: %w", err)
	}

	req2 := SendRequest{
		DestinationsSats:      map[string]int64{childAddr.address: parentUTXO.amountSats},
		FixedFeeSats:          childFee,
		SubtractFeeFromAmount: true,
		RequiredInputs:        []RequiredInput{{TxID: parentUTXO.txid, Vout: parentUTXO.vout, AmountSats: parentUTXO.amountSats}},
	}
	packet, psbtInputs, effect, err := p.buildSendPSBT(ctx, walletID, scan, req2)
	if err != nil {
		return "", err
	}
	return p.signAndBroadcast(ctx, walletID, packet, psbtInputs, effect, false)
}

func (p *ElectrumBackend) Chain() ChainSource {
	return esploraChain{client: p.client}
}

// ServerURL returns the wallet's current primary Esplora endpoint, or "" when
// the backend's client does not expose one.
func (p *ElectrumBackend) ServerURL() string {
	sw, ok := p.client.(SwappableChainSource)
	if !ok {
		return ""
	}
	roots := sw.BaseURLs()
	if len(roots) == 0 {
		return ""
	}
	return roots[0]
}

// SetServerURL points the wallet at a different Esplora endpoint at runtime. The
// switch is validated before it commits: the new endpoint must be a well-formed
// http/https URL and must answer a tip-height probe. On any failure the previous
// endpoint is restored and an error is returned, so the wallet is never left
// disconnected. On success the new tip height is returned and the choice is
// persisted. Swapping only the client's URL list is safe with in-flight reads:
// requests that already captured the old list finish against it, new ones use
// the new endpoint.
func (p *ElectrumBackend) SetServerURL(ctx context.Context, url string) (int, error) {
	sw, ok := p.client.(SwappableChainSource)
	if !ok {
		return 0, connect.NewError(connect.CodeUnimplemented, errors.New("this wallet's backend does not support switching servers"))
	}
	normalized, err := normalizeEsploraURL(url)
	if err != nil {
		return 0, connect.NewError(connect.CodeInvalidArgument, err)
	}

	prev := sw.BaseURLs()
	sw.SetBaseURLs([]string{normalized})

	tip, err := sw.TipHeight(ctx)
	if err != nil {
		sw.SetBaseURLs(prev)
		return 0, connect.NewError(connect.CodeUnavailable, fmt.Errorf("server %s unreachable, kept previous server: %w", normalized, err))
	}

	// The new endpoint serves a different chain view, so every cached scan is
	// stale. Drop them so reads re-walk against the new server.
	p.mu.Lock()
	p.warmScan = make(map[string]*electrumScan)
	p.tipAt = make(map[string]int)
	p.scanAt = make(map[string]time.Time)
	p.warm = make(map[string]bool)
	p.mu.Unlock()

	return tip, nil
}

// TorConfig reports whether the wallet routes chain connections through a SOCKS5
// proxy and the proxy address, or (false, "") when the backend can't proxy.
func (p *ElectrumBackend) TorConfig() (bool, string) {
	sw, ok := p.client.(SwappableChainSource)
	if !ok {
		return false, ""
	}
	return sw.ProxyConfig()
}

// SetTorConfig routes (or stops routing) the wallet's chain connections through a
// SOCKS5 proxy. When enabling, proxyAddr must be a valid host:port and is probed
// with a tip-height request before committing; on any failure the previous proxy
// config is restored and an error returned, so the wallet is never left
// disconnected. On success the new tip height is returned and cached scans are
// dropped (the new route may reach a different server view).
func (p *ElectrumBackend) SetTorConfig(ctx context.Context, enabled bool, proxyAddr string) (int, error) {
	sw, ok := p.client.(SwappableChainSource)
	if !ok {
		return 0, connect.NewError(connect.CodeUnimplemented, errors.New("this wallet's backend does not support tor routing"))
	}
	if enabled {
		normalized, err := normalizeProxyAddr(proxyAddr)
		if err != nil {
			return 0, connect.NewError(connect.CodeInvalidArgument, err)
		}
		proxyAddr = normalized
	}

	prevEnabled, prevProxy := sw.ProxyConfig()
	if err := sw.SetProxy(enabled, proxyAddr); err != nil {
		return 0, connect.NewError(connect.CodeInvalidArgument, err)
	}

	tip, err := sw.TipHeight(ctx)
	if err != nil {
		_ = sw.SetProxy(prevEnabled, prevProxy)
		return 0, connect.NewError(connect.CodeUnavailable, fmt.Errorf("proxy %s unreachable, kept previous tor config: %w", proxyAddr, err))
	}

	p.mu.Lock()
	p.warmScan = make(map[string]*electrumScan)
	p.tipAt = make(map[string]int)
	p.scanAt = make(map[string]time.Time)
	p.warm = make(map[string]bool)
	p.mu.Unlock()

	return tip, nil
}

// normalizeProxyAddr validates a SOCKS5 proxy address of the form host:port.
func normalizeProxyAddr(raw string) (string, error) {
	trimmed := strings.TrimSpace(raw)
	if trimmed == "" {
		return "", errors.New("proxy address is required when tor is enabled")
	}
	host, port, err := net.SplitHostPort(trimmed)
	if err != nil {
		return "", fmt.Errorf("proxy address must be host:port: %w", err)
	}
	if host == "" {
		return "", errors.New("proxy address must include a host")
	}
	if n, err := strconv.Atoi(port); err != nil || n < 1 || n > 65535 {
		return "", fmt.Errorf("proxy port must be 1-65535, got %q", port)
	}
	return trimmed, nil
}

// normalizeEsploraURL validates a user-supplied Esplora endpoint and returns it
// trimmed of a trailing slash. It must be an absolute http/https URL with a host.
func normalizeEsploraURL(raw string) (string, error) {
	trimmed := strings.TrimSpace(raw)
	if trimmed == "" {
		return "", errors.New("server URL is required")
	}
	u, err := neturl.Parse(trimmed)
	if err != nil {
		return "", fmt.Errorf("invalid server URL: %w", err)
	}
	if u.Scheme != "http" && u.Scheme != "https" {
		return "", fmt.Errorf("server URL must be http or https, got %q", u.Scheme)
	}
	if u.Host == "" {
		return "", errors.New("server URL must include a host")
	}
	return strings.TrimRight(trimmed, "/"), nil
}

// esploraChain adapts a ChainDataSource to the wallet-agnostic ChainSource.
type esploraChain struct {
	client ChainDataSource
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

// walletDescriptor builds the parsed output descriptor for a wallet's primary
// script kind — the kind used for change and fee sizing.
func (p *ElectrumBackend) walletDescriptor(w *WalletData) (*Descriptor, error) {
	return p.walletDescriptorFor(w, w.scriptKind())
}

// walletDescriptorFor builds the parsed output descriptor for one of a wallet's
// script kinds: from its seed + the kind when hot (the account key is private,
// so its addresses can be signed), or from its single stored watch-only
// descriptor otherwise (watch-only wallets are single-kind, so kind is ignored).
func (p *ElectrumBackend) walletDescriptorFor(w *WalletData, kind ScriptKind) (*Descriptor, error) {
	if p.network == nil {
		return nil, errors.New("no chain params for this network; cannot derive electrum wallet")
	}
	if w.Multisig != nil {
		return p.multisigSigningDescriptor(w)
	}
	if w.Master.SeedHex != "" {
		ap, err := accountPathFor(w, kind, p.network)
		if err != nil {
			return nil, err
		}
		acct, origin, err := accountKeyAndOrigin(w.Master.SeedHex, ap, p.network)
		if err != nil {
			return nil, err
		}
		return &Descriptor{Kind: kind, Threshold: 1, Keys: []DescriptorKey{{Origin: origin, Account: acct}}}, nil
	}
	desc, err := watchOnlyDescriptorString(w)
	if err != nil {
		return nil, err
	}
	return ParseDescriptor(desc)
}

// multisigSigningDescriptor builds the wallet's multisig descriptor, substituting
// each held cosigner's account xprv for its xpub (so deriveAddr yields signing
// keys) while external legs stay xpubs. The resulting descriptor derives the same
// addresses as the watch-only one and is signed through the same PSBT path as any
// other input — held keys are just signers that happen to live on disk.
func (p *ElectrumBackend) multisigSigningDescriptor(w *WalletData) (*Descriptor, error) {
	return p.multisigSigningDescriptorFor(w, "")
}

// multisigSigningDescriptorFor builds the multisig descriptor with held cosigners
// substituted as their xprv. When onlyXpub is non-empty, only that cosigner's
// xprv is substituted (the rest stay xpubs), so signing adds a single cosigner's
// signature — the per-keystore signing path.
func (p *ElectrumBackend) multisigSigningDescriptorFor(w *WalletData, onlyXpub string) (*Descriptor, error) {
	ms := w.Multisig
	if ms == nil {
		return nil, errors.New("wallet has no multisig config")
	}
	group := MultisigLoungeGroup{M: ms.M, N: ms.N}
	signWithXprv := map[string]string{}
	for _, c := range ms.Cosigners {
		group.Keys = append(group.Keys, MultisigLoungeKey{
			Xpub:        c.Xpub,
			Fingerprint: c.Fingerprint,
			OriginPath:  c.OriginPath,
			// Emit a [fingerprint/origin] prefix whenever we have the origin, so
			// every cosigner's key-origin lands in the PSBT (needed to attribute
			// signatures and for external-wallet interop) — not just held keys.
			IsWallet: c.Fingerprint != "" && c.OriginPath != "",
		})
		if !c.Held() {
			continue
		}
		if onlyXpub != "" && c.Xpub != onlyXpub {
			continue
		}
		xprv := c.Xprv
		if xprv == "" {
			seedHex := hex.EncodeToString(MnemonicToSeed(c.Mnemonic, c.Passphrase))
			x, _, err := DeriveAccountXprv(seedHex, "m/"+c.OriginPath, p.network)
			if err != nil {
				return nil, fmt.Errorf("derive cosigner xprv: %w", err)
			}
			xprv = x
		}
		signWithXprv[c.Xpub] = xprv
	}

	scriptType := multisigTypeString(w.scriptKind())
	var receive string
	var err error
	if len(signWithXprv) > 0 {
		receive, _, err = BuildMultisigSigningDescriptorsTyped(group, signWithXprv, scriptType)
	} else {
		receive, _, err = BuildMultisigLoungeDescriptorsTyped(group, scriptType)
	}
	if err != nil {
		return nil, err
	}
	return ParseDescriptor(receive)
}

// deriveAddr resolves one address of a descriptor, enriching it with the signing
// metadata: the private key (hot wallets), scriptPubKey, and redeem/tap material.
func (p *ElectrumBackend) deriveAddr(d *Descriptor, change bool, index uint32) (scannedAddr, error) {
	ds, pub, err := d.DeriveScript(change, index, p.network)
	if err != nil {
		return scannedAddr{}, err
	}
	derivations, err := d.derivations(change, index)
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
		hdPath:       descriptorHDPath(d, p.network, change, index),
		derivations:  derivations,
	}
	if d.Kind.isMultisig() {
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
	} else if d.Kind.isTaprootMultisig() {
		a.tapInternal = ds.tapInternal
		a.tapLeafScript = ds.tapLeafScript
		a.tapControlBlock = ds.tapControlBlock
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

// descriptorHDPath formats the full BIP derivation path for display, using the
// descriptor's resolved account origin so a custom account/path is reflected.
func descriptorHDPath(d *Descriptor, net *chaincfg.Params, change bool, index uint32) string {
	if len(d.Keys) == 1 {
		if _, path, ok := parseOrigin(d.Keys[0].Origin); ok && len(path) == 3 {
			const h = hdkeychain.HardenedKeyStart
			return fmt.Sprintf("m/%d'/%d'/%d'/%d/%d", path[0]-h, path[1]-h, path[2]-h, chainIndex(change), index)
		}
	}
	if purpose, ok := d.Kind.Purpose(); ok && net != nil {
		return fmt.Sprintf("m/%d'/%d'/0'/%d/%d", purpose, net.HDCoinType, chainIndex(change), index)
	}
	return fmt.Sprintf("m/%d/%d", chainIndex(change), index)
}

func chainIndex(change bool) uint32 {
	if change {
		return 1
	}
	return 0
}

// scanWallet returns a wallet scan, served from the persisted cache on the
// first call after boot. Use it for passive reads (balance, history).
func (p *ElectrumBackend) scanWallet(ctx context.Context, walletID string) (*electrumScan, error) {
	return p.scan(ctx, walletID, true)
}

// scanForSend builds a send from the cached scan. Scripthash push subscriptions
// keep the cache current, so a send no longer needs a full live re-walk.
func (p *ElectrumBackend) scanForSend(ctx context.Context, walletID string, _ SendRequest) (*electrumScan, error) {
	return p.scanWallet(ctx, walletID)
}

func (p *ElectrumBackend) scan(ctx context.Context, walletID string, allowCache bool) (*electrumScan, error) {
	w := p.svc.GetWalletByID(walletID)
	if w == nil {
		return nil, fmt.Errorf("wallet %s not found", walletID)
	}

	if allowCache {
		// Sparrow-style: scan a wallet once, then serve from an in-memory cache
		// between blocks. A wallet's balance/history can't change without a new
		// block, so reads do a single cheap tip check instead of re-deriving the
		// whole chain over Esplora on every poll.
		if scan := p.cachedScan(ctx, walletID); scan != nil {
			return scan, nil
		}
	}

	// Serialise scans per wallet: when several readers miss the cache at once
	// (cold boot, or just after a new block), only one walks the chain; the
	// rest wait and then get the cache it just populated.
	unlock := p.lockScan(walletID)
	defer unlock()

	if allowCache {
		if scan := p.cachedScan(ctx, walletID); scan != nil {
			return scan, nil
		}
		// Cold-boot fast path: rebuild the previous scan from disk with no network.
		if scan, ok := p.loadColdScan(walletID, w); ok {
			p.cacheScan(ctx, walletID, scan)
			return scan, nil
		}
	}

	scan := &electrumScan{
		byAddr: make(map[string]scannedAddr),
		keys:   make(mapKeySource),
	}

	scan.watchOnly = w.IsWatchOnly()
	chainNames := []string{"external", "change"}
	// Only stream per-address progress on a wallet's first scan this process
	// (the initial sync). Warm wallets re-scan on routine balance polls, and
	// streaming those would spin the bottom-nav "Scanning…" status forever.
	p.mu.Lock()
	initial := !p.warm[walletID]
	prior := p.warmScan[walletID]
	p.mu.Unlock()
	// prior holds the wallet's last known chain data (warm cache, else the
	// on-disk scan). Addresses whose stats are unchanged copy their UTXOs and
	// transactions from it instead of re-fetching, so only what moved hits
	// the network.
	if prior == nil {
		if cold, _, ok := p.rebuildScanFromDisk(walletID, w); ok {
			prior = cold
		}
	}
	defer p.svc.syncReporter.publish(walletID, SyncProgress{Phase: SyncIdle, Message: "Idle"})
	for _, kind := range p.receiveKinds(w) {
		derivers, err := p.kindDerivers(w, kind)
		if err != nil {
			return nil, err
		}
		for i, d := range derivers {
			chain := "external"
			if i < len(chainNames) {
				chain = chainNames[i]
			}
			addrs, err := p.scanChain(ctx, walletID, chain, d, prior, initial)
			if err != nil {
				return nil, err
			}
			scan.addrs = append(scan.addrs, addrs...)
		}
	}
	p.svc.syncReporter.publish(walletID, SyncProgress{Phase: SyncDone, Message: "Up to date"})

	p.mu.Lock()
	watch := append([]WatchKey(nil), p.watchKeys[walletID]...)
	p.mu.Unlock()
	for _, k := range watch {
		a, err := p.watchKeyAddr(ctx, k, prior)
		if err != nil {
			p.log.Warn().Err(err).Msg("electrum watch key derivation failed")
			continue
		}
		scan.addrs = append(scan.addrs, a)
	}

	finalizeScan(scan)
	p.persistScan(walletID, scan)
	p.mu.Lock()
	p.warm[walletID] = true
	p.mu.Unlock()
	p.cacheScan(ctx, walletID, scan)
	go p.subscribeScan(walletID, scan)
	return scan, nil
}

// subscribeScan registers every scanned address's scripthash for server pushes
// and records its status, so a change refreshes only this wallet. Electrum only.
func (p *ElectrumBackend) subscribeScan(walletID string, scan *electrumScan) {
	ec, ok := p.client.(*ElectrumClient)
	if !ok {
		return
	}
	p.consumerOnce.Do(func() { go p.consumeNotifications(ec) })
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	_, _ = ec.SubscribeHeaders(ctx)
	for _, a := range scan.addrs {
		sh, err := ec.ScriptHash(a.address)
		if err != nil {
			continue
		}
		status, err := ec.Subscribe(ctx, sh)
		if err != nil {
			continue
		}
		p.subMu.Lock()
		p.shWallet[sh] = walletID
		p.subStatus[sh] = status
		p.subMu.Unlock()
	}
}

// consumeNotifications turns server pushes into cache invalidation + a change
// fan-out, so incoming funds surface within ~1s instead of on a poll timer.
func (p *ElectrumBackend) consumeNotifications(ec *ElectrumClient) {
	for n := range ec.Notifications() {
		switch n.Kind {
		case "scripthash":
			p.subMu.Lock()
			walletID, known := p.shWallet[n.ScriptHash]
			changed := known && p.subStatus[n.ScriptHash] != n.Status
			if changed {
				p.subStatus[n.ScriptHash] = n.Status
			}
			p.subMu.Unlock()
			if changed {
				p.invalidate(walletID)
				p.svc.notifyChanged()
			}
		case "headers":
			p.svc.notifyChanged()
		case "reconnect":
			p.onElectrumReconnect()
		}
	}
}

func (p *ElectrumBackend) invalidate(walletID string) {
	p.mu.Lock()
	delete(p.warmScan, walletID)
	delete(p.tipAt, walletID)
	delete(p.scanAt, walletID)
	p.mu.Unlock()
}

// onElectrumReconnect drops all subscription state and warm caches; the next
// read re-scans and re-subscribes on the fresh socket.
func (p *ElectrumBackend) onElectrumReconnect() {
	p.subMu.Lock()
	p.subStatus = make(map[string]string)
	p.shWallet = make(map[string]string)
	p.subMu.Unlock()
	p.mu.Lock()
	p.warmScan = make(map[string]*electrumScan)
	p.tipAt = make(map[string]int)
	p.scanAt = make(map[string]time.Time)
	p.mu.Unlock()
	p.svc.notifyChanged()
}

// lockScan returns the per-wallet scan mutex (creating it on first use), locked.
// Call the returned func to unlock.
func (p *ElectrumBackend) lockScan(walletID string) func() {
	p.scanMu.Lock()
	m := p.scanLocks[walletID]
	if m == nil {
		m = &sync.Mutex{}
		p.scanLocks[walletID] = m
	}
	p.scanMu.Unlock()
	m.Lock()
	return m.Unlock
}

// cachedScan returns the in-memory scan when it still reflects the current chain
// tip. Between blocks a wallet's funds can't change, so a read is served from
// cache after one cheap TipHeight call instead of a full re-walk. Returns nil
// when there is no cache or a new block has arrived (the caller re-walks once
// and refreshes the cache).
func (p *ElectrumBackend) cachedScan(ctx context.Context, walletID string) *electrumScan {
	p.mu.Lock()
	scan := p.warmScan[walletID]
	at, hasTip := p.tipAt[walletID]
	fresh := time.Since(p.scanAt[walletID]) < electrumScanTTL
	p.mu.Unlock()
	if scan == nil {
		return nil
	}
	tip, err := p.client.TipHeight(ctx)
	if err != nil {
		return scan // network blip: serve cache rather than re-walk or fail the read
	}
	if hasTip && tip == at && fresh {
		return scan // no new block and cache still fresh → nothing changed
	}
	return nil // new block, or cache aged out: re-walk once to catch mempool activity
}

// cacheScan stores a completed scan as the in-memory cache, tagged with the
// chain tip it reflects so cachedScan can detect staleness on the next block.
func (p *ElectrumBackend) cacheScan(ctx context.Context, walletID string, scan *electrumScan) {
	tip, err := p.client.TipHeight(ctx)
	p.mu.Lock()
	p.warmScan[walletID] = scan
	p.scanAt[walletID] = time.Now()
	if err == nil {
		p.tipAt[walletID] = tip
	} else {
		delete(p.tipAt, walletID) // unknown tip → force a refresh on the next read
	}
	p.mu.Unlock()
}

// loadColdScan rebuilds a wallet's scan from its persisted cache without any
// network calls, used once per process before the first live scan. ok is false
// when warm, when no cache exists, or on any derive error. On success it marks
// the wallet warm so the next read serves the cache instead of re-walking.
func (p *ElectrumBackend) loadColdScan(walletID string, w *WalletData) (*electrumScan, bool) {
	p.mu.Lock()
	warm := p.warm[walletID]
	p.mu.Unlock()
	if warm {
		return nil, false
	}
	scan, ps, ok := p.rebuildScanFromDisk(walletID, w)
	if !ok {
		return nil, false
	}
	p.mu.Lock()
	p.warm[walletID] = true
	p.lastScan[walletID], _ = json.Marshal(ps)
	p.mu.Unlock()
	p.log.Debug().Str("wallet", walletID).Int("addrs", len(scan.addrs)).Msg("electrum scan loaded from cache")
	return scan, true
}

// rebuildScanFromDisk reconstructs a wallet's scan purely from its persisted
// cache: keys and scripts are re-derived from the descriptor, stats come from
// disk, and no network call is made. It mutates no backend state, so reads that
// only need the known chain (e.g. address allocation) can use it freely. ok is
// false when no cache exists or the persisted addresses drift from derivation.
func (p *ElectrumBackend) rebuildScanFromDisk(walletID string, w *WalletData) (*electrumScan, *persistedScan, bool) {
	ps, ok := p.svc.loadElectrumScan(walletID)
	if !ok {
		return nil, nil, false
	}
	scan := &electrumScan{
		byAddr:    make(map[string]scannedAddr),
		keys:      make(mapKeySource),
		watchOnly: w.IsWatchOnly(),
	}
	descByKind := make(map[ScriptKind]*Descriptor)
	for _, pa := range ps.Addrs {
		d, ok := descByKind[pa.Kind]
		if !ok {
			var err error
			d, err = p.walletDescriptorFor(w, pa.Kind)
			if err != nil {
				return nil, nil, false
			}
			descByKind[pa.Kind] = d
		}
		a, err := p.deriveAddr(d, pa.Change, pa.Index)
		if err != nil || a.address != pa.Address {
			return nil, nil, false // cache drift — fall back to a live scan
		}
		a.stats = pa.Stats
		a.utxos = pa.UTXOs
		a.txs = pa.Txs
		scan.addrs = append(scan.addrs, a)
	}
	finalizeScan(scan)
	return scan, ps, true
}

// finalizeScan builds the by-address and key lookups from a scan's addresses.
func finalizeScan(scan *electrumScan) {
	for _, a := range scan.addrs {
		scan.byAddr[a.address] = a
		if a.priv != nil {
			scan.keys[a.address] = a.priv
		}
	}
}

// persistScan writes the wallet's chain scan to disk, skipping the write when
// nothing changed since the last persist. BIP47 watch keys (no hdPath) are not
// part of the derivation chain and are excluded.
func (p *ElectrumBackend) persistScan(walletID string, scan *electrumScan) {
	ps := persistedScan{WalletID: walletID}
	ps.Addrs = lo.FilterMap(scan.addrs, func(a scannedAddr, _ int) (persistedAddr, bool) {
		if a.hdPath == "" {
			return persistedAddr{}, false
		}
		return persistedAddr{
			Kind: a.kind, Change: a.change, Index: a.index, Address: a.address,
			Stats: a.stats, UTXOs: a.utxos, Txs: a.txs,
		}, true
	})
	data, err := json.Marshal(ps)
	if err != nil {
		return
	}
	p.mu.Lock()
	unchanged := bytes.Equal(p.lastScan[walletID], data)
	p.mu.Unlock()
	if unchanged {
		return
	}
	if err := p.svc.saveElectrumScan(walletID, &ps); err != nil {
		p.log.Warn().Err(err).Str("wallet", walletID).Msg("persist electrum scan failed")
		return // don't record the write as done — retry on the next scan
	}
	p.mu.Lock()
	p.lastScan[walletID] = data
	p.mu.Unlock()
}

// chainDeriver derives the address+key at an index of one derivation chain.
type chainDeriver func(index uint32) (scannedAddr, error)

// receiveKinds lists the script kinds an electrum wallet derives receive
// addresses for. A standard hot single-sig segwit or taproot wallet derives
// both (BIP84 + BIP86) from its one seed, so the receive screen can switch
// between them; its own kind is listed first as the primary used for change and
// fee sizing. Every other wallet — watch-only, explicit-path, legacy, nested,
// or multisig — is single-kind.
func (p *ElectrumBackend) receiveKinds(w *WalletData) []ScriptKind {
	primary := w.scriptKind()
	if w.IsWatchOnly() || w.usesExplicitPath() {
		return []ScriptKind{primary}
	}
	switch primary {
	case ScriptNativeSegwit:
		return []ScriptKind{ScriptNativeSegwit, ScriptTaproot}
	case ScriptTaproot:
		return []ScriptKind{ScriptTaproot, ScriptNativeSegwit}
	default:
		return []ScriptKind{primary}
	}
}

// kindDerivers returns the external (index 0) and change (index 1) address
// derivers for one script kind of a wallet, built from that kind's descriptor.
func (p *ElectrumBackend) kindDerivers(w *WalletData, kind ScriptKind) ([]chainDeriver, error) {
	d, err := p.walletDescriptorFor(w, kind)
	if err != nil {
		return nil, err
	}
	out := make([]chainDeriver, 2)
	for ci, change := range []bool{false, true} {
		out[ci] = func(i uint32) (scannedAddr, error) {
			return p.deriveAddr(d, change, i)
		}
	}
	return out, nil
}

func (p *ElectrumBackend) scanChain(ctx context.Context, walletID, chain string, derive chainDeriver, prior *electrumScan, initial bool) ([]scannedAddr, error) {
	var out []scannedAddr
	consecutiveUnused := 0
	found := 0
	for i := uint32(0); consecutiveUnused < electrumGapLimit && i < electrumMaxScan; i++ {
		if initial {
			p.svc.syncReporter.publish(walletID, scanProgress(chain, len(out), found))
		}
		a, err := derive(i)
		if err != nil {
			return nil, err
		}
		if err := p.hydrate(ctx, &a, prior); err != nil {
			return nil, err
		}
		out = append(out, a)
		if a.stats.Used() {
			consecutiveUnused = 0
			found++
		} else {
			consecutiveUnused++
		}
	}
	return out, nil
}

// hydrate fills an address's stats and, when it has history, its UTXOs and
// transactions. When prior holds the same address with identical stats the
// chain data is unchanged since the last scan, so it is copied instead of
// re-fetched — Esplora is only queried for what actually moved.
func (p *ElectrumBackend) hydrate(ctx context.Context, a *scannedAddr, prior *electrumScan) error {
	stats, err := p.client.AddressStats(ctx, a.address)
	if err != nil {
		return fmt.Errorf("address stats %s: %w", a.address, err)
	}
	a.stats = stats
	if !stats.Used() {
		return nil
	}
	if prior != nil {
		if prev, ok := prior.byAddr[a.address]; ok && prev.stats == stats {
			a.utxos = prev.utxos
			a.txs = prev.txs
			return nil
		}
	}
	utxos, err := p.client.AddressUTXOs(ctx, a.address)
	if err != nil {
		return fmt.Errorf("address utxos %s: %w", a.address, err)
	}
	txs, err := p.client.AddressTxs(ctx, a.address)
	if err != nil {
		return fmt.Errorf("address txs %s: %w", a.address, err)
	}
	a.utxos = utxos
	a.txs = txs
	return nil
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

func (p *ElectrumBackend) watchKeyAddr(ctx context.Context, k WatchKey, prior *electrumScan) (scannedAddr, error) {
	wif, err := btcutil.DecodeWIF(k.WIF)
	if err != nil {
		return scannedAddr{}, fmt.Errorf("decode watch WIF: %w", err)
	}
	pubHash := btcutil.Hash160(wif.PrivKey.PubKey().SerializeCompressed())
	addr, err := btcutil.NewAddressPubKeyHash(pubHash, p.network)
	if err != nil {
		return scannedAddr{}, fmt.Errorf("watch key address: %w", err)
	}
	a := scannedAddr{address: addr.EncodeAddress(), priv: wif.PrivKey}
	if err := p.hydrate(ctx, &a, prior); err != nil {
		return scannedAddr{}, err
	}
	return a, nil
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

func (p *ElectrumBackend) spendableUTXOs(scan *electrumScan) []electrumUTXO {
	return lo.FlatMap(scan.addrs, func(a scannedAddr, _ int) []electrumUTXO {
		return lo.Map(a.utxos, func(u EsploraUTXO, _ int) electrumUTXO {
			return electrumUTXO{
				txid:       u.TxID,
				vout:       u.Vout,
				address:    a.address,
				amountSats: u.Value,
				confirmed:  u.Status.Confirmed,
			}
		})
	})
}

func findUTXO(pool []electrumUTXO, txid string, vout int) (electrumUTXO, bool) {
	return lo.Find(pool, func(u electrumUTXO) bool {
		return u.txid == txid && u.vout == vout
	})
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
