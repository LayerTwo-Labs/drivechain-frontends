package wallet

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"math"
	"sort"
	"strings"
	"sync"
	"time"

	"connectrpc.com/connect"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"github.com/tyler-smith/go-bip32"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/replay"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet/bip47"
)

// walletLoadingBackoff is how long Ensure short-circuits subsequent calls
// after a transient bitcoind error (e.g. -4 Wallet already loading or -28
// Verifying blocks). Frontends poll this path aggressively while the user
// stares at the wallet view; without a gate every poll triggers a fresh
// CreateWallet/LoadWallet RPC and we drown bitcoind in retries that all fail
// the same way until Core is past startup.
const walletLoadingBackoff = 5 * time.Second

// CoreBackend serves wallets from Bitcoin Core descriptor wallets: it
// derives BIP84 descriptors from wallet.json seeds, lazily creates the Core
// wallets, and proxies all wallet operations to Core RPC.
type CoreBackend struct {
	svc     *Service
	rpc     *CoreRPCClient
	log     zerolog.Logger
	network *chaincfg.Params

	mu          sync.Mutex
	coreWallets map[string]string // walletID -> Core wallet name

	// Transient backoff: when bitcoind responds with a "still booting" error
	// (-4 Wallet already loading, -28 Verifying blocks, …), Ensure returns
	// the cached error for `walletLoadingBackoff` so the next ~5s of
	// frontend polls don't translate into RPC storms against bitcoind.
	loadingUntil time.Time
	loadingErr   error
}

var (
	_ Backend      = (*CoreBackend)(nil)
	_ Bip47Backend = (*CoreBackend)(nil)
)

// NewCoreBackend creates the Bitcoin Core wallet backend.
func NewCoreBackend(svc *Service, rpc *CoreRPCClient, network *chaincfg.Params, log zerolog.Logger) *CoreBackend {
	return &CoreBackend{
		svc:         svc,
		rpc:         rpc,
		log:         log.With().Str("component", "core-backend").Logger(),
		network:     network,
		coreWallets: make(map[string]string),
	}
}

// Ensure ensures a Bitcoin Core wallet exists for a wallet.json wallet.
// Returns the Core wallet name.
func (p *CoreBackend) Ensure(ctx context.Context, walletID string) (string, error) {
	p.mu.Lock()
	defer p.mu.Unlock()

	// Check cache
	if name, ok := p.coreWallets[walletID]; ok {
		return name, nil
	}

	// Short-circuit while a recent attempt is still in the bitcoind-warming-up
	// window — return the same error without re-hitting RPC.
	if p.loadingErr != nil && time.Now().Before(p.loadingUntil) {
		return "", p.loadingErr
	}

	// Find wallet data
	all := p.svc.GetAllWallets()
	var targetWallet *WalletData
	for i := range all {
		if all[i].ID == walletID {
			targetWallet = &all[i]
			break
		}
	}
	if targetWallet == nil {
		return "", fmt.Errorf("wallet %s not found", walletID)
	}

	walletName := fmt.Sprintf("wallet_%s", walletID[:8])

	var err error
	switch targetWallet.WalletType {
	case WalletTypeBitcoinCore:
		// Watch-only Core wallets import a descriptor; full wallets create from
		// the seed. Both run on the same Core backend.
		if targetWallet.IsWatchOnly() {
			err = p.createWatchOnlyWallet(ctx, walletName, targetWallet)
		} else {
			err = p.createBitcoinCoreWallet(ctx, walletName, targetWallet)
		}
	default:
		return "", fmt.Errorf("wallet type %s does not use Bitcoin Core", targetWallet.WalletType)
	}

	if err != nil {
		if isTransientWalletErr(err) {
			p.loadingUntil = time.Now().Add(walletLoadingBackoff)
			p.loadingErr = err
		}
		return "", err
	}

	// Ensure the wallet's BIP47 notification descriptor is imported. Runs
	// both for newly-created wallets and existing ones so the descriptor
	// lands on first boot post-engine-deploy. Idempotent in Core, and a
	// failure here shouldn't break wallet loading — the backend will retry
	// next time Ensure runs.
	if targetWallet.WalletType == WalletTypeBitcoinCore && !targetWallet.IsWatchOnly() {
		if perr := p.ensureBip47NotificationDescriptor(ctx, walletName, targetWallet.Master.SeedHex); perr != nil {
			p.log.Warn().Err(perr).Str("wallet", walletName).Msg("could not ensure bip47 notification descriptor")
		}
	}

	// Success — clear any previous transient gate and cache the wallet name.
	p.loadingUntil = time.Time{}
	p.loadingErr = nil
	p.coreWallets[walletID] = walletName
	return walletName, nil
}

// EnsureAll syncs all bitcoinCore wallets (full and watch-only) to Bitcoin Core.
func (p *CoreBackend) EnsureAll(ctx context.Context) (int, error) {
	wallets := p.svc.GetAllWallets()
	synced := 0

	for _, w := range wallets {
		if w.WalletType != WalletTypeBitcoinCore {
			continue
		}
		if _, err := p.Ensure(ctx, w.ID); err != nil {
			p.log.Warn().Err(err).Str("wallet_id", w.ID).Msg("failed to ensure core wallet")
			continue
		}
		synced++
	}

	return synced, nil
}

// walletName returns the Core wallet name for a wallet ID, ensuring it exists.
func (p *CoreBackend) walletName(ctx context.Context, walletID string) (string, error) {
	p.mu.Lock()
	if name, ok := p.coreWallets[walletID]; ok {
		p.mu.Unlock()
		return name, nil
	}
	p.mu.Unlock()

	return p.Ensure(ctx, walletID)
}

func (p *CoreBackend) Balance(ctx context.Context, walletID string) (float64, float64, error) {
	name, err := p.walletName(ctx, walletID)
	if err != nil {
		return 0, 0, err
	}
	confirmed, err := p.rpc.GetBalance(ctx, name)
	if err != nil {
		return 0, 0, err
	}
	unconfirmed, err := p.rpc.GetUnconfirmedBalance(ctx, name)
	if err != nil {
		return 0, 0, err
	}
	return confirmed, unconfirmed, nil
}

func (p *CoreBackend) ListUnspent(ctx context.Context, walletID string) ([]UTXO, error) {
	name, err := p.walletName(ctx, walletID)
	if err != nil {
		return nil, err
	}
	return p.rpc.ListUnspent(ctx, name)
}

func (p *CoreBackend) ListTransactions(ctx context.Context, walletID string, count int) ([]WalletTransaction, error) {
	name, err := p.walletName(ctx, walletID)
	if err != nil {
		return nil, err
	}
	return p.rpc.ListTransactions(ctx, name, count)
}

func (p *CoreBackend) ListTransactionsRange(ctx context.Context, walletID string, count, skip int) ([]WalletTransaction, error) {
	name, err := p.walletName(ctx, walletID)
	if err != nil {
		return nil, err
	}
	return p.rpc.ListTransactionsRange(ctx, name, count, skip)
}

func (p *CoreBackend) ListReceivedByAddress(ctx context.Context, walletID string) ([]ReceivedByAddress, error) {
	name, err := p.walletName(ctx, walletID)
	if err != nil {
		return nil, err
	}
	return p.rpc.ListReceivedByAddress(ctx, name)
}

func (p *CoreBackend) GetWalletTransaction(ctx context.Context, walletID, txid string) (*WalletTx, error) {
	name, err := p.walletName(ctx, walletID)
	if err != nil {
		return nil, err
	}
	raw, err := p.rpc.GetTransaction(ctx, name, txid)
	if err != nil {
		return nil, err
	}
	var tx WalletTx
	if err := json.Unmarshal(raw, &tx); err != nil {
		return nil, fmt.Errorf("decode gettransaction: %w", err)
	}
	return &tx, nil
}

func (p *CoreBackend) AddressHDPath(ctx context.Context, walletID, address string) (string, error) {
	name, err := p.walletName(ctx, walletID)
	if err != nil {
		return "", err
	}
	info, err := p.rpc.GetAddressInfo(ctx, name, address)
	if err != nil {
		return "", err
	}
	return info.HDKeyPath, nil
}

// NextReceiveAddress returns an existing unused address from the wallet, or
// mints a new one if every address has received funds. "Unused" = present in
// listreceivedbyaddress with zero amount and no txids (minconf=0 also catches
// mempool receives). Lets the receive page poll without burning the keypool,
// while staying entirely stateless across orchestrator restarts.
//
// Candidates are filtered to the chain's bech32 prefix because the Core wallet
// also imports P2PKH addresses for BIP47 (the notification address + per-sender
// derived payment addresses) — those must never leak into the regular receive
// flow.
func (p *CoreBackend) NextReceiveAddress(ctx context.Context, walletID string, kind ScriptKind) (string, error) {
	name, err := p.walletName(ctx, walletID)
	if err != nil {
		return "", err
	}
	// ScriptUnknown is the default sentinel ("the wallet's natural kind"); resolve
	// it to the wallet's script kind, which defaults to native segwit.
	if kind == ScriptUnknown {
		kind = p.walletScriptKind(walletID)
	}
	addressType, ok := coreAddressType(kind)
	if !ok {
		return "", fmt.Errorf("unsupported address kind %s for the Bitcoin Core backend", kind)
	}
	addrs, err := p.rpc.ListReceivedByAddress(ctx, name)
	if err != nil {
		return "", err
	}
	// Reuse an unused address only if it matches the requested kind, so a wallet
	// holding several script kinds doesn't hand back a foreign-kind address.
	for _, a := range addrs {
		if a.Amount != 0 || len(a.TxIDs) != 0 {
			continue
		}
		if !p.addressMatchesKind(a.Address, kind) {
			continue
		}
		return a.Address, nil
	}
	return p.rpc.GetNewAddress(ctx, name, "", addressType)
}

// coreAddressType maps a script kind to Bitcoin Core's getnewaddress
// address_type argument.
func coreAddressType(kind ScriptKind) (string, bool) {
	switch kind {
	case ScriptLegacy:
		return "legacy", true
	case ScriptNestedSegwit:
		return "p2sh-segwit", true
	case ScriptNativeSegwit:
		return "bech32", true
	case ScriptTaproot:
		return "bech32m", true
	default:
		return "", false
	}
}

// addressMatchesKind reports whether a decoded address is the concrete type the
// given script kind produces, so candidate filtering works for base58 (P2PKH,
// P2SH-P2WPKH) as well as bech32/bech32m kinds.
func (p *CoreBackend) addressMatchesKind(address string, kind ScriptKind) bool {
	if p.network == nil {
		return false
	}
	addr, err := btcutil.DecodeAddress(address, p.network)
	if err != nil {
		return false
	}
	switch kind {
	case ScriptLegacy:
		_, ok := addr.(*btcutil.AddressPubKeyHash)
		return ok
	case ScriptNestedSegwit:
		_, ok := addr.(*btcutil.AddressScriptHash)
		return ok
	case ScriptNativeSegwit:
		_, ok := addr.(*btcutil.AddressWitnessPubKeyHash)
		return ok
	case ScriptTaproot:
		_, ok := addr.(*btcutil.AddressTaproot)
		return ok
	default:
		return false
	}
}

func (p *CoreBackend) NextChangeAddress(ctx context.Context, walletID string) (string, error) {
	name, err := p.walletName(ctx, walletID)
	if err != nil {
		return "", err
	}
	return p.rpc.GetRawChangeAddress(ctx, name)
}

// WatchKeys imports each key as a pkh() descriptor. Per-key import failures
// are logged, not fatal — matching how Core treats already-known descriptors.
func (p *CoreBackend) WatchKeys(ctx context.Context, walletID string, keys []WatchKey) error {
	name, err := p.walletName(ctx, walletID)
	if err != nil {
		return err
	}
	descriptors := lo.Map(keys, func(k WatchKey, _ int) ImportDescriptor {
		return ImportDescriptor{
			Desc:      mustAddChecksum(fmt.Sprintf("pkh(%s)", k.WIF)),
			Active:    false,
			Timestamp: k.RescanFrom,
		}
	})
	results, err := p.rpc.ImportDescriptors(ctx, name, descriptors)
	if err != nil {
		return err
	}
	for i, r := range results {
		if r.Success {
			continue
		}
		msg := "unknown"
		if r.Error != nil {
			msg = r.Error.Message
		}
		p.log.Warn().Int("descriptor_index", i).Str("error", msg).Msg("watch key import failed")
	}
	return nil
}

// EnsureNotificationWatched imports the wallet's own BIP47 notification key as a
// pkh() descriptor so Core's listtransactions surfaces inbound notification
// txs. Idempotent — Core ignores already-known descriptors.
func (p *CoreBackend) EnsureNotificationWatched(ctx context.Context, walletID string, notifKey WatchKey) error {
	return p.WatchKeys(ctx, walletID, []WatchKey{notifKey})
}

// Send routes simple sends through Core's own coin selection
// (sendtoaddress/sendmany) and everything else — fee control, OP_RETURN,
// pinned inputs, replay protection — through the raw-tx path: build, fund,
// sign, broadcast.
func (p *CoreBackend) Send(ctx context.Context, walletID string, req SendRequest) (string, error) {
	name, err := p.walletName(ctx, walletID)
	if err != nil {
		return "", err
	}

	needsRawPath := req.OpReturnHex != "" ||
		req.FeeRateSatPerVB > 0 ||
		req.FixedFeeSats > 0 ||
		len(req.RequiredInputs) > 0 ||
		req.ReplayProtect // custom serialization needs the raw-tx path

	if !needsRawPath {
		destinations := lo.MapValues(req.DestinationsSats, func(sats int64, _ string) float64 {
			return float64(sats) / 1e8
		})
		if len(destinations) == 1 {
			for addr, amount := range destinations {
				return p.rpc.SendToAddress(ctx, name, addr, amount, req.SubtractFeeFromAmount)
			}
		}
		return p.rpc.SendMany(ctx, name, destinations)
	}

	// Replay protection stamps a magic locktime; Core lowers the inputs it is
	// given below SEQUENCE_FINAL so the locktime takes effect.
	locktime := uint32(0)
	if req.ReplayProtect {
		locktime = replay.ReplayLockTime
	}

	outputs, totalDestinationSats := buildSendOutputs(req)
	inputs := make([]RawInput, 0, len(req.RequiredInputs))
	selectedInputAmountSats := int64(0)
	for _, in := range req.RequiredInputs {
		inputs = append(inputs, RawInput{TxID: in.TxID, Vout: in.Vout})
		selectedInputAmountSats += in.AmountSats
	}

	if req.FixedFeeSats > 0 {
		if len(inputs) == 0 {
			inputs, selectedInputAmountSats, err = p.selectInputsForFixedFee(
				ctx, walletID, totalDestinationSats+req.FixedFeeSats,
			)
			if err != nil {
				return "", err
			}
		}

		changeSats := selectedInputAmountSats - totalDestinationSats - req.FixedFeeSats
		if changeSats < 0 {
			return "", fmt.Errorf(
				"insufficient selected inputs: need %d sats, have %d sats",
				totalDestinationSats+req.FixedFeeSats,
				selectedInputAmountSats,
			)
		}

		if changeSats >= 546 {
			changeAddress, err := p.NextChangeAddress(ctx, walletID)
			if err != nil {
				return "", fmt.Errorf("get raw change address: %w", err)
			}
			outputs = append(outputs, TxOutSpec{Address: changeAddress, AmountBTC: float64(changeSats) / 1e8})
		}

		rawHex, err := p.rpc.CreateRawTransaction(ctx, inputs, rpcOutputs(outputs), locktime)
		if err != nil {
			return "", fmt.Errorf("create raw transaction: %w", err)
		}
		return p.signAndBroadcast(ctx, name, rawHex)
	}

	rawHex, err := p.rpc.CreateRawTransaction(ctx, inputs, rpcOutputs(outputs), locktime)
	if err != nil {
		return "", fmt.Errorf("create raw transaction: %w", err)
	}

	options := map[string]interface{}{}
	if len(inputs) > 0 {
		options["add_inputs"] = false
	}
	if req.FeeRateSatPerVB > 0 {
		options["fee_rate"] = req.FeeRateSatPerVB
	}
	if req.SubtractFeeFromAmount && len(req.DestinationsSats) > 0 {
		options["subtractFeeFromOutputs"] = lo.Range(len(req.DestinationsSats))
	}
	if req.ReplayProtect {
		// Inputs Core selects during funding must also be non-final, else the
		// locktime is ignored and there is no replay protection.
		options["replaceable"] = true
	}

	funded, err := p.rpc.FundRawTransaction(ctx, name, rawHex, options)
	if err != nil {
		return "", fmt.Errorf("fund raw transaction: %w", err)
	}
	return p.signAndBroadcast(ctx, name, funded.Hex)
}

// rpcOutputs maps outputs onto createrawtransaction's wire shape.
func rpcOutputs(outputs []TxOutSpec) []map[string]interface{} {
	return lo.Map(outputs, func(o TxOutSpec, _ int) map[string]interface{} {
		if o.OpReturnHex != "" {
			return map[string]interface{}{"data": o.OpReturnHex}
		}
		return map[string]interface{}{o.Address: o.AmountBTC}
	})
}

// buildSendOutputs maps the request's destinations (plus optional OP_RETURN)
// to ordered outputs and returns the destination total in sats.
func buildSendOutputs(req SendRequest) ([]TxOutSpec, int64) {
	outputs := make([]TxOutSpec, 0, len(req.RawOutputs)+len(req.DestinationsSats)+1)
	totalDestinationSats := int64(0)
	// Raw outputs come first so consensus-ordered scripts (e.g. an OP_DRIVECHAIN
	// treasury immediately before its OP_RETURN address) keep their positions.
	for _, raw := range req.RawOutputs {
		outputs = append(outputs, raw)
		totalDestinationSats += raw.AmountSats
	}
	for address, sats := range req.DestinationsSats {
		outputs = append(outputs, TxOutSpec{Address: address, AmountBTC: float64(sats) / 1e8})
		totalDestinationSats += sats
	}
	if req.OpReturnHex != "" {
		outputs = append(outputs, TxOutSpec{OpReturnHex: req.OpReturnHex})
	}
	return outputs, totalDestinationSats
}

// selectInputsForFixedFee picks spendable UTXOs largest-first until they
// cover requiredSats.
func (p *CoreBackend) selectInputsForFixedFee(ctx context.Context, walletID string, requiredSats int64) ([]RawInput, int64, error) {
	utxos, err := p.ListUnspent(ctx, walletID)
	if err != nil {
		return nil, 0, fmt.Errorf("list unspent: %w", err)
	}

	sort.Slice(utxos, func(i, j int) bool {
		return utxos[i].Amount > utxos[j].Amount
	})

	selected := make([]RawInput, 0)
	totalSats := int64(0)
	for _, utxo := range utxos {
		if !utxo.Spendable {
			continue
		}
		selected = append(selected, RawInput{TxID: utxo.TxID, Vout: utxo.Vout})
		totalSats += int64(math.Round(utxo.Amount * 1e8))
		if totalSats >= requiredSats {
			break
		}
	}

	if totalSats < requiredSats {
		return nil, 0, fmt.Errorf("insufficient funds: need %d sats, have %d sats", requiredSats, totalSats)
	}
	return selected, totalSats, nil
}

// signAndBroadcast signs via Core and broadcasts. Any replay locktime is
// already baked into rawHex, so the signature commits to it here.
func (p *CoreBackend) signAndBroadcast(ctx context.Context, name, rawHex string) (string, error) {
	signed, err := p.rpc.SignRawTransactionWithWallet(ctx, name, rawHex)
	if err != nil {
		return "", fmt.Errorf("sign raw transaction: %w", err)
	}
	if !signed.Complete {
		return "", errors.New("transaction signing incomplete")
	}

	return p.rpc.SendRawTransaction(ctx, signed.Hex)
}

func (p *CoreBackend) SignTransaction(ctx context.Context, walletID, rawHex string) (*SignRawTransactionResult, error) {
	name, err := p.walletName(ctx, walletID)
	if err != nil {
		return nil, err
	}
	return p.rpc.SignRawTransactionWithWallet(ctx, name, rawHex)
}

func (p *CoreBackend) BumpFee(ctx context.Context, walletID, txid string, newFeeRate int64) (string, error) {
	name, err := p.walletName(ctx, walletID)
	if err != nil {
		return "", err
	}
	return p.rpc.BumpFee(ctx, name, txid, newFeeRate)
}

func (p *CoreBackend) CreateCpfp(ctx context.Context, walletID string, req CpfpRequest) (string, error) {
	name, err := p.walletName(ctx, walletID)
	if err != nil {
		return "", err
	}
	if req.TargetRate <= 0 {
		return "", connect.NewError(connect.CodeInvalidArgument, errors.New("target fee rate must be positive"))
	}

	// minconf 0: the parent we must spend is unconfirmed, so the default
	// (minconf 1) would hide it. The parent value feeding the output math is read
	// from this same lookup.
	utxos, err := p.rpc.ListUnspentMinConf(ctx, name, 0)
	if err != nil {
		return "", err
	}
	parent, ok := lo.Find(utxos, func(u UTXO) bool {
		return u.TxID == req.ParentTxID && u.Vout == req.ParentVout && u.Spendable
	})
	if !ok {
		return "", connect.NewError(connect.CodeInvalidArgument,
			fmt.Errorf("outpoint %s:%d is not a spendable wallet UTXO", req.ParentTxID, req.ParentVout))
	}
	if parent.Confirmations > 0 {
		return "", connect.NewError(connect.CodeInvalidArgument,
			fmt.Errorf("outpoint %s:%d is already confirmed; CPFP only applies to unconfirmed parents", req.ParentTxID, req.ParentVout))
	}

	entry, err := p.rpc.GetMempoolEntry(ctx, req.ParentTxID)
	if err != nil {
		return "", fmt.Errorf("get parent mempool entry: %w", err)
	}
	parentVsize := entry.Vsize
	parentFee := int64(math.Round(entry.Fees.Base * 1e8))
	if parentVsize > 0 && req.TargetRate <= parentFee/parentVsize {
		return "", connect.NewError(connect.CodeInvalidArgument,
			fmt.Errorf("target rate %d sat/vB does not exceed parent rate %d sat/vB", req.TargetRate, parentFee/parentVsize))
	}

	// Size the child for the wallet's own script kind: a taproot (BIP86) wallet
	// imports only tr() descriptors, so its child is P2TR — using native-segwit
	// sizing mis-estimates the fee. Default wallets resolve to native segwit.
	childKind := p.walletScriptKind(walletID)

	parentValueSats := int64(math.Round(parent.Amount * 1e8))
	childVsize := int64(11 + inputVsize(childKind) + outputVsizeForKind(childKind))
	_, outputSats, err := cpfpChildPlan(req.TargetRate, parentVsize, parentFee, childVsize, parentValueSats)
	if err != nil {
		return "", connect.NewError(connect.CodeInvalidArgument, err)
	}

	childAddr, err := p.NextReceiveAddress(ctx, walletID, childKind)
	if err != nil {
		return "", err
	}

	inputs := []RawInput{{TxID: req.ParentTxID, Vout: req.ParentVout}}
	outputs := []map[string]interface{}{{childAddr: btcutil.Amount(outputSats).ToBTC()}}
	rawHex, err := p.rpc.CreateRawTransaction(ctx, inputs, outputs, 0)
	if err != nil {
		return "", fmt.Errorf("create child tx: %w", err)
	}
	signed, err := p.rpc.SignRawTransactionWithWallet(ctx, name, rawHex)
	if err != nil {
		return "", fmt.Errorf("sign child tx: %w", err)
	}
	if !signed.Complete {
		return "", errors.New("child transaction signing incomplete")
	}
	return p.rpc.SendRawTransaction(ctx, signed.Hex)
}

// Chain returns the Core-backed chain source.
func (p *CoreBackend) Chain() ChainSource {
	return coreChain{rpc: p.rpc}
}

// coreChain adapts CoreRPCClient to ChainSource.
type coreChain struct {
	rpc *CoreRPCClient
}

func (c coreChain) GetRawTransaction(ctx context.Context, txid string) (*RawTransaction, error) {
	return c.rpc.GetRawTransaction(ctx, txid)
}

func (c coreChain) Broadcast(ctx context.Context, rawHex string) (string, error) {
	return c.rpc.SendRawTransaction(ctx, rawHex)
}

// ============================================================================
// Core wallet creation (descriptor derivation + import)
// ============================================================================

// ensureBip47NotificationDescriptor imports the wallet's BIP47 notification
// P2PKH key (m/47'/0'/0'/0) into Core if not already present. Uses
// timestamp=0 so the first import rescans the chain from genesis and picks
// up historic notification txs; subsequent imports are no-ops because Core
// recognizes the descriptor as already known.
func (p *CoreBackend) ensureBip47NotificationDescriptor(ctx context.Context, walletName, seedHex string) error {
	if p.network == nil {
		return nil
	}
	notifPriv, _, err := bip47.DeriveOwnNotificationKey(seedHex, p.network)
	if err != nil {
		return fmt.Errorf("derive notification key: %w", err)
	}
	wif, err := btcutil.NewWIF(notifPriv, p.network, true)
	if err != nil {
		return fmt.Errorf("encode notification wif: %w", err)
	}
	desc := mustAddChecksum(fmt.Sprintf("pkh(%s)", wif.String()))
	results, err := p.rpc.ImportDescriptors(ctx, walletName, []ImportDescriptor{{
		Desc:      desc,
		Active:    false,
		Timestamp: int64(0),
	}})
	if err != nil {
		return fmt.Errorf("import bip47 notification descriptor: %w", err)
	}
	for i, r := range results {
		if r.Success {
			continue
		}
		msg := "unknown"
		if r.Error != nil {
			msg = r.Error.Message
		}
		return fmt.Errorf("bip47 descriptor %d import failed: %s", i, msg)
	}
	return nil
}

// createBitcoinCoreWallet creates a Bitcoin Core descriptor wallet from a seed.
// With no derivation override it imports the standard BIP84 + BIP86 descriptors
// at account 0; an AccountIndex shifts both to that account; an explicit
// DerivationPath imports the single descriptor for that path's purpose.
func (p *CoreBackend) createBitcoinCoreWallet(ctx context.Context, walletName string, w *WalletData) error {
	if p.network == nil {
		return fmt.Errorf("no chain params for this network; cannot derive wallet descriptors")
	}
	seed, err := hex.DecodeString(w.Master.SeedHex)
	if err != nil {
		return fmt.Errorf("decode seed hex: %w", err)
	}

	masterKey, err := bip32.NewMasterKey(seed)
	if err != nil {
		return fmt.Errorf("create master key: %w", err)
	}
	fingerprint := masterFingerprint(masterKey)

	var purposes []ScriptKind
	if w.usesExplicitPath() {
		ap, err := ParseAccountPath(w.DerivationPath)
		if err != nil {
			return fmt.Errorf("invalid derivation path: %w", err)
		}
		kind, ok := purposeToCoreKind(ap.Purpose)
		if !ok {
			return fmt.Errorf("unsupported core descriptor purpose %d'", ap.Purpose)
		}
		purposes = []ScriptKind{kind}
	} else {
		purposes = []ScriptKind{ScriptNativeSegwit, ScriptTaproot}
	}

	var descriptors []ImportDescriptor
	for _, kind := range purposes {
		ap, err := accountPathFor(w, kind, p.network)
		if err != nil {
			return err
		}
		acct, err := deriveAccountKey(masterKey, ap)
		if err != nil {
			return err
		}
		acctXprv := serializeKeyForNetwork(acct, p.network)
		open, close, ok := coreDescriptorWrapper(kind)
		if !ok {
			return fmt.Errorf("unsupported core descriptor kind %s", kind)
		}
		origin := ap.Origin("'")
		descriptors = append(descriptors,
			ImportDescriptor{
				Desc:      mustAddChecksum(fmt.Sprintf("%s[%s/%s]%s/0/*%s", open, fingerprint, origin, acctXprv, close)),
				Active:    true,
				Timestamp: "now",
				Internal:  false,
				Range:     []int{0, 999},
			},
			ImportDescriptor{
				Desc:      mustAddChecksum(fmt.Sprintf("%s[%s/%s]%s/1/*%s", open, fingerprint, origin, acctXprv, close)),
				Active:    true,
				Timestamp: "now",
				Internal:  true,
				Range:     []int{0, 999},
			},
		)
	}

	return p.createAndImport(ctx, walletName, false, descriptors)
}

// deriveAccountKey derives the hardened account-level key for an AccountPath.
func deriveAccountKey(masterKey *bip32.Key, ap AccountPath) (*bip32.Key, error) {
	purpose, err := masterKey.NewChildKey(bip32.FirstHardenedChild + ap.Purpose)
	if err != nil {
		return nil, fmt.Errorf("derive purpose %d': %w", ap.Purpose, err)
	}
	coin, err := purpose.NewChildKey(bip32.FirstHardenedChild + ap.Coin)
	if err != nil {
		return nil, fmt.Errorf("derive coin %d': %w", ap.Coin, err)
	}
	account, err := coin.NewChildKey(bip32.FirstHardenedChild + ap.Account)
	if err != nil {
		return nil, fmt.Errorf("derive account %d': %w", ap.Account, err)
	}
	return account, nil
}

// coreDescriptorWrapper returns the open/close fragments wrapping the key
// expression for a single-sig kind's Core descriptor.
func coreDescriptorWrapper(kind ScriptKind) (open, close string, ok bool) {
	switch kind {
	case ScriptLegacy:
		return "pkh(", ")", true
	case ScriptNestedSegwit:
		return "sh(wpkh(", "))", true
	case ScriptNativeSegwit:
		return "wpkh(", ")", true
	case ScriptTaproot:
		return "tr(", ")", true
	default:
		return "", "", false
	}
}

// purposeToCoreKind maps a BIP purpose to the single-sig kind Core imports for it.
func purposeToCoreKind(purpose uint32) (ScriptKind, bool) {
	switch purpose {
	case 44:
		return ScriptLegacy, true
	case 49:
		return ScriptNestedSegwit, true
	case 84:
		return ScriptNativeSegwit, true
	case 86:
		return ScriptTaproot, true
	default:
		return ScriptUnknown, false
	}
}

// createWatchOnlyWallet creates a watch-only Bitcoin Core wallet.
func (p *CoreBackend) createWatchOnlyWallet(ctx context.Context, walletName string, w *WalletData) error {
	if w.WatchOnly == nil {
		return fmt.Errorf("watch-only wallet missing watch_only data")
	}

	var watchOnly struct {
		Descriptor string `json:"descriptor"`
		Xpub       string `json:"xpub"`
	}
	if err := json.Unmarshal(w.WatchOnly, &watchOnly); err != nil {
		return fmt.Errorf("parse watch_only: %w", err)
	}

	var descriptors []ImportDescriptor
	if watchOnly.Descriptor != "" {
		desc := watchOnly.Descriptor
		if !strings.Contains(desc, "#") {
			var err error
			desc, err = AddDescriptorChecksum(desc)
			if err != nil {
				return fmt.Errorf("add checksum: %w", err)
			}
		}
		descriptors = append(descriptors, ImportDescriptor{
			Desc:      desc,
			Active:    true,
			Timestamp: "now",
			Range:     []int{0, 1000},
		})
	} else if watchOnly.Xpub != "" {
		descriptors = append(descriptors,
			ImportDescriptor{
				Desc:      mustAddChecksum(fmt.Sprintf("wpkh(%s/0/*)", watchOnly.Xpub)),
				Active:    true,
				Timestamp: "now",
				Range:     []int{0, 1000},
			},
			ImportDescriptor{
				Desc:      mustAddChecksum(fmt.Sprintf("wpkh(%s/1/*)", watchOnly.Xpub)),
				Active:    true,
				Timestamp: "now",
				Internal:  true,
				Range:     []int{0, 1000},
			},
		)
	} else {
		return fmt.Errorf("watch-only wallet requires descriptor or xpub")
	}

	return p.createAndImport(ctx, walletName, true, descriptors)
}

// createAndImport creates a Core wallet and imports descriptors.
func (p *CoreBackend) createAndImport(ctx context.Context, walletName string, disablePrivateKeys bool, descriptors []ImportDescriptor) error {
	existing, err := p.rpc.ListWallets(ctx)
	if err != nil {
		return fmt.Errorf("list wallets: %w", err)
	}

	if !lo.Contains(existing, walletName) {
		if err := p.rpc.CreateWallet(ctx, walletName, disablePrivateKeys, true); err != nil {
			if strings.Contains(err.Error(), "already exists") {
				if loadErr := p.rpc.LoadWallet(ctx, walletName); loadErr != nil {
					return fmt.Errorf("load existing wallet: %w", loadErr)
				}
			} else {
				return fmt.Errorf("create wallet: %w", err)
			}
		}

		results, err := p.rpc.ImportDescriptors(ctx, walletName, descriptors)
		if err != nil {
			return fmt.Errorf("import descriptors: %w", err)
		}

		for i, r := range results {
			if !r.Success {
				errMsg := "unknown"
				if r.Error != nil {
					errMsg = r.Error.Message
				}
				return fmt.Errorf("descriptor %d import failed: %s", i, errMsg)
			}
		}

		p.log.Info().Str("wallet", walletName).Msg("created Bitcoin Core wallet")
	}

	return nil
}

// walletScriptKind resolves the script kind a Core wallet receives to. A wallet
// with an explicit derivation path imports only that purpose's descriptor, so
// the kind follows the path; otherwise the default wallet (wpkh + tr both
// imported) gives bech32 from getnewaddress, i.e. native segwit.
func (p *CoreBackend) walletScriptKind(walletID string) ScriptKind {
	w := p.svc.GetWalletByID(walletID)
	if w == nil || !w.usesExplicitPath() {
		return ScriptNativeSegwit
	}
	ap, err := ParseAccountPath(w.DerivationPath)
	if err != nil {
		return ScriptNativeSegwit
	}
	if kind, ok := purposeToCoreKind(ap.Purpose); ok {
		return kind
	}
	return ScriptNativeSegwit
}
