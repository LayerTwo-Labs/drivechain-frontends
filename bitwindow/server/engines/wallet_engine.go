package engines

import (
	"context"
	"encoding/hex"
	"errors"
	"fmt"
	"math"
	"strconv"
	"strings"
	"sync"
	"time"

	"connectrpc.com/connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"golang.org/x/sync/singleflight"
	"google.golang.org/protobuf/types/known/emptypb"

	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	orchrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
)

// WalletType is a wallet's provider backend. Watch-only is an orthogonal
// capability (the watch_only payload), not a provider.
type WalletType string

const (
	WalletTypeBitcoinCore WalletType = "bitcoinCore"
	WalletTypeElectrum    WalletType = "electrum"
)

// WalletInfo is a wallet as the orchestrator lists it.
type WalletInfo struct {
	ID         string
	Name       string
	WalletType WalletType
	WatchOnly  bool
	// AccountIndex shifts the standard BIP84/BIP86 descriptors to this account.
	// 0 = standard. Mutually exclusive with DerivationPath.
	AccountIndex uint32
	// DerivationPath is an explicit account-level path (m/purpose'/coin'/account')
	// overriding purpose/coin/account; empty = standard purposes at AccountIndex.
	DerivationPath string
	// ScriptType is the stored address kind; empty means native segwit.
	ScriptType string
}

// IsWatchOnly reports whether the wallet holds no signing key — it holds an
// xpub/descriptor payload instead of a seed. Orthogonal to the provider type.
func (w *WalletInfo) IsWatchOnly() bool {
	return w.WatchOnly
}

func walletTypeFromProto(t orchpb.WalletType) WalletType {
	switch t {
	case orchpb.WalletType_WALLET_TYPE_BITCOIN_CORE:
		return WalletTypeBitcoinCore
	case orchpb.WalletType_WALLET_TYPE_ELECTRUM:
		return WalletTypeElectrum
	case orchpb.WalletType_WALLET_TYPE_ENFORCER, orchpb.WalletType_WALLET_TYPE_UNSPECIFIED:
	}
	return WalletType(t.String())
}

// WalletEngine handles backend routing and Bitcoin Core sync. The wallets and
// their lock state live in the orchestrator's WalletManagerService.
type WalletEngine struct {
	bitcoindConnector func(context.Context) (corerpc.BitcoinServiceClient, error)
	chainParams       *chaincfg.Params

	orchClient orchrpc.WalletManagerServiceClient

	// The one node-mode source every poller and gated RPC reads.
	nodeMode *NodeMode

	mu sync.RWMutex

	// frozenCoins names the coins the user froze, so no send of ours takes one.
	frozenCoins FrozenCoinsFunc
	// frozenPushMu runs one hand-over at a time, newest set last.
	frozenPushMu sync.Mutex

	// Maps walletID -> Bitcoin Core wallet name (cache)
	coreWallets map[string]string

	// Wallet ids already checked for a pre-rename watch_<prefix> wallet. The
	// answer cannot change while the process runs, and the frontend polls this
	// path, so the check must not repeat a listwallets and loadwallet each time.
	legacyChecked map[string]bool

	// Coalesces concurrent EnsureBitcoinCoreWallet calls for the same
	// walletID into a single in-flight execution. The frontend polls
	// listTransactions every 5s, and each call before the cache populates
	// would otherwise issue its own loadwallet RPC against bitcoind —
	// causing a queue of "wallet already loading" -4s while Core is busy.
	ensureGroup singleflight.Group

	// Sync throttling
	lastSync time.Time
}

func NewWalletEngine(
	bitcoindConnector func(context.Context) (corerpc.BitcoinServiceClient, error),
	orchClient orchrpc.WalletManagerServiceClient,
	chainParams *chaincfg.Params,
	frozenCoins FrozenCoinsFunc,
) *WalletEngine {
	return &WalletEngine{
		bitcoindConnector: bitcoindConnector,
		orchClient:        orchClient,
		chainParams:       chainParams,
		frozenCoins:       frozenCoins,
		coreWallets:       make(map[string]string),
		nodeMode:          NewNodeMode(orchClient),
	}
}

// FrozenCoinsFunc names the coins the user froze, as txid:vout. Every send
// this server makes leaves those coins alone.
type FrozenCoinsFunc func(ctx context.Context) ([]string, error)

// frozenCoinsInterval is how often the set goes over again. A drivechaind
// restart drops the set it holds, and nothing here sees that restart. The
// orchestrator picks coins for its own work too, so the window stays short.
const frozenCoinsInterval = 10 * time.Second

// KeepFrozenCoins hands the orchestrator the frozen set, and hands it over
// again while ctx runs. Coin selection lives in drivechaind, and a restart of
// it leaves the set behind.
func (e *WalletEngine) KeepFrozenCoins(ctx context.Context) {
	ticker := time.NewTicker(frozenCoinsInterval)
	defer ticker.Stop()
	for {
		if err := e.PushFrozenCoins(ctx); err != nil {
			zerolog.Ctx(ctx).Debug().Err(err).Msg("hand over the frozen coins")
		}
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
		}
	}
}

// PushFrozenCoins hands the orchestrator the coins no send may take. It runs
// before every send, so a drivechaind restart cannot leave the set behind.
//
// One push runs at a time. The set is read and sent under the same lock, so a
// slow push cannot land after a newer one and put the older set back.
func (e *WalletEngine) PushFrozenCoins(ctx context.Context) error {
	e.frozenPushMu.Lock()
	defer e.frozenPushMu.Unlock()

	outpoints, err := e.frozenCoins(ctx)
	if err != nil {
		return fmt.Errorf("read the frozen coins: %w", err)
	}

	coins := make([]*orchpb.FrozenOutpoint, 0, len(outpoints))
	for _, outpoint := range outpoints {
		txid, vout, ok := splitOutpoint(outpoint)
		if !ok {
			return fmt.Errorf("frozen coin %q is not a txid:vout", outpoint)
		}
		coins = append(coins, &orchpb.FrozenOutpoint{Txid: txid, Vout: int32(vout)})
	}

	_, err = e.orchClient.SetFrozenCoins(ctx, connect.NewRequest(&orchpb.SetFrozenCoinsRequest{
		Outpoints: coins,
	}))
	if err != nil {
		return fmt.Errorf("set frozen coins: %w", err)
	}
	return nil
}

// splitOutpoint reads a txid:vout pair.
func splitOutpoint(outpoint string) (string, int, bool) {
	txid, voutText, found := strings.Cut(outpoint, ":")
	if !found || txid == "" {
		return "", 0, false
	}
	vout, err := strconv.Atoi(voutText)
	if err != nil || vout < 0 {
		return "", 0, false
	}
	return txid, vout, true
}

// NodeMode hands out the shared node-mode source.
func (e *WalletEngine) NodeMode() *NodeMode {
	return e.nodeMode
}

// ============================================================================
// Unlock/Lock/State Management
// ============================================================================

// Unlock opens the wallet in the orchestrator.
func (e *WalletEngine) Unlock(ctx context.Context, password string) error {
	_, err := e.orchClient.UnlockWallet(ctx, connect.NewRequest(&orchpb.UnlockWalletRequest{Password: password}))
	if err != nil {
		return fmt.Errorf("unlock wallet: %w", err)
	}
	return nil
}

// Lock closes the wallet in the orchestrator.
func (e *WalletEngine) Lock(ctx context.Context) error {
	if _, err := e.orchClient.LockWallet(ctx, connect.NewRequest(&orchpb.LockWalletRequest{})); err != nil {
		return fmt.Errorf("lock wallet: %w", err)
	}
	return nil
}

// IsUnlocked reports whether the orchestrator holds the wallets open.
func (e *WalletEngine) IsUnlocked(ctx context.Context) (bool, error) {
	resp, err := e.orchClient.GetWalletStatus(ctx, connect.NewRequest(&orchpb.GetWalletStatusRequest{}))
	if err != nil {
		return false, fmt.Errorf("get wallet status: %w", err)
	}
	return resp.Msg.State == orchpb.WalletState_WALLET_STATE_UNLOCKED, nil
}

// IsEncrypted reports whether the orchestrator wallet file has a password.
func (e *WalletEngine) IsEncrypted(ctx context.Context) (bool, error) {
	resp, err := e.orchClient.GetWalletStatus(ctx, connect.NewRequest(&orchpb.GetWalletStatusRequest{}))
	if err != nil {
		return false, fmt.Errorf("get wallet status: %w", err)
	}
	return resp.Msg.Encrypted, nil
}

// GetStarterSeed returns the seed hex of the wallet that derives the L1 and
// sidechain starters. BitDrive and ChequeEngine key off it, so it must name the
// same wallet for the life of the install.
func (e *WalletEngine) GetStarterSeed(ctx context.Context) (string, error) {
	// GetWalletSeed names its wallet, so resolve the starter's id before
	// asking for its seed.
	list, err := e.orchClient.ListWallets(ctx, connect.NewRequest(&orchpb.ListWalletsRequest{}))
	if err != nil {
		return "", fmt.Errorf("list wallets: %w", err)
	}
	starter, found := lo.Find(list.Msg.Wallets, func(w *orchpb.WalletMetadata) bool {
		return w.IsStarter
	})
	if !found {
		return "", errors.New("no starter wallet")
	}
	resp, err := e.orchClient.GetWalletSeed(
		ctx,
		connect.NewRequest(&orchpb.GetWalletSeedRequest{WalletId: starter.Id}),
	)
	if err != nil {
		return "", fmt.Errorf("get seed of starter wallet %s: %w", starter.Id, err)
	}
	return resp.Msg.SeedHex, nil
}

func (e *WalletEngine) GetWalletSeed(ctx context.Context, walletID string) (string, error) {
	resp, err := e.orchClient.GetWalletSeed(ctx, connect.NewRequest(&orchpb.GetWalletSeedRequest{
		WalletId: walletID,
	}))
	if err != nil {
		return "", fmt.Errorf("get seed of wallet %s: %w", walletID, err)
	}
	return resp.Msg.SeedHex, nil
}

func (e *WalletEngine) GetActiveWallet(ctx context.Context) (*WalletInfo, error) {
	wallets, activeID, err := e.listWallets(ctx)
	if err != nil {
		return nil, err
	}
	if activeID == "" {
		return nil, errors.New("no active wallet")
	}
	return findWallet(wallets, activeID)
}

// ============================================================================
// Wallet Info & Backend Routing
// ============================================================================

func (e *WalletEngine) GetChainParams() *chaincfg.Params {
	return e.chainParams
}

// GetWalletInfo returns the wallet with walletID.
func (e *WalletEngine) GetWalletInfo(ctx context.Context, walletID string) (*WalletInfo, error) {
	wallets, err := e.GetAllWallets(ctx)
	if err != nil {
		return nil, err
	}
	return findWallet(wallets, walletID)
}

func findWallet(wallets []WalletInfo, walletID string) (*WalletInfo, error) {
	if len(wallets) == 0 {
		return nil, errors.New("no wallet is unlocked")
	}
	walletInfo, ok := lo.Find(wallets, func(w WalletInfo) bool {
		return w.ID == walletID
	})
	if !ok {
		return nil, fmt.Errorf("wallet %s not found", walletID)
	}
	return &walletInfo, nil
}

func (e *WalletEngine) GetWalletBackendType(ctx context.Context, walletID string) (WalletType, error) {
	if walletID == "" {
		return "", errors.New("wallet_id required")
	}
	wallet, err := e.GetWalletInfo(ctx, walletID)
	if err != nil {
		return "", err
	}
	return wallet.WalletType, nil
}

// IsWatchOnly reports whether the wallet has no signing key (watch-only),
// orthogonal to its provider type.
func (e *WalletEngine) IsWatchOnly(ctx context.Context, walletID string) (bool, error) {
	if walletID == "" {
		return false, errors.New("wallet_id required")
	}
	wallet, err := e.GetWalletInfo(ctx, walletID)
	if err != nil {
		return false, err
	}
	return wallet.IsWatchOnly(), nil
}

// ============================================================================
// Bitcoin Core Wallet Management
// ============================================================================

// EnsureBitcoinCoreWallet ensures a Bitcoin Core wallet exists for the given walletID
// Creates it from the seed if it doesn't exist (lazy loading).
//
// Concurrent callers for the same walletID are coalesced via singleflight so
// only one CreateWallet/LoadWallet against bitcoind is in flight at a time.
// Without this, each frontend poll would queue another loadwallet RPC and
// hit "-4: Wallet already loading" while Core was busy.
func (e *WalletEngine) EnsureBitcoinCoreWallet(ctx context.Context, walletID string) (string, error) {
	// Fast path — cache hit, no need to coalesce.
	e.mu.RLock()
	if walletName, exists := e.coreWallets[walletID]; exists {
		e.mu.RUnlock()
		return walletName, nil
	}
	e.mu.RUnlock()

	v, err, _ := e.ensureGroup.Do(walletID, func() (interface{}, error) {
		return e.ensureBitcoinCoreWalletLocked(ctx, walletID)
	})
	if err != nil {
		return "", err
	}
	return v.(string), nil
}

// ensureBitcoinCoreWalletLocked is the singleflight-wrapped body of
// EnsureBitcoinCoreWallet. Don't call directly.
func (e *WalletEngine) ensureBitcoinCoreWalletLocked(ctx context.Context, walletID string) (string, error) {
	resp, err := e.orchClient.CreateBitcoinCoreWallet(ctx, connect.NewRequest(&orchpb.CreateBitcoinCoreWalletRequest{
		WalletId: walletID,
	}))
	if err != nil {
		return "", err
	}
	e.mu.Lock()
	e.coreWallets[walletID] = resp.Msg.CoreWalletName
	e.mu.Unlock()
	return resp.Msg.CoreWalletName, nil
}

// CoreWalletName returns the Bitcoin Core wallet that holds the wallet's coins.
// A watch-only wallet can live in a legacy watch_<prefix> wallet.
func (e *WalletEngine) CoreWalletName(ctx context.Context, walletID string) (string, error) {
	watchOnly, err := e.IsWatchOnly(ctx, walletID)
	if err != nil {
		return "", err
	}
	if watchOnly {
		return e.EnsureWatchOnlyWallet(ctx, walletID)
	}
	return e.EnsureBitcoinCoreWallet(ctx, walletID)
}

// GetNewAddress returns a receive address of the wallet. The orchestrator
// derives it for Core and electrum wallets alike.
func (e *WalletEngine) GetNewAddress(ctx context.Context, walletID string, addressType orchpb.AddressType) (string, error) {
	resp, err := e.orchClient.GetNewAddress(ctx, connect.NewRequest(&orchpb.GetNewAddressRequest{
		WalletId:    walletID,
		AddressType: addressType,
	}))
	if err != nil {
		return "", fmt.Errorf("get new address: %w", err)
	}
	return resp.Msg.Address, nil
}

// DeriveReceiveAddresses returns the first count receive addresses of the
// wallet, as the orchestrator derives them.
func (e *WalletEngine) DeriveReceiveAddresses(ctx context.Context, walletID string, count int) ([]string, error) {
	resp, err := e.orchClient.DeriveAddresses(ctx, connect.NewRequest(&orchpb.DeriveAddressesRequest{
		WalletId: walletID,
		Count:    int32(count),
	}))
	if err != nil {
		return nil, fmt.Errorf("derive addresses: %w", err)
	}
	return resp.Msg.Addresses, nil
}

// GetElectrumBalance returns the confirmed, pending and immature balance (in
// sats) for an electrum wallet from the orchestrator's Esplora-backed provider.
func (e *WalletEngine) GetElectrumBalance(ctx context.Context, walletID string) (confirmed, pending, immature uint64, err error) {
	resp, err := e.orchClient.GetBalance(ctx, connect.NewRequest(&orchpb.GetBalanceRequest{
		WalletId: walletID,
	}))
	if err != nil {
		return 0, 0, 0, fmt.Errorf("electrum: get balance: %w", err)
	}
	return uint64(math.Round(resp.Msg.ConfirmedSats)), uint64(math.Round(resp.Msg.UnconfirmedSats)), uint64(math.Round(resp.Msg.ImmatureSats)), nil
}

// RequireFullNode refuses an operation that needs a local BIP300/301 enforcer.
// Light mode runs no daemon, so the operation cannot work there.
func (e *WalletEngine) RequireFullNode(ctx context.Context, op string) error {
	return e.nodeMode.RequireFullNode(ctx, op)
}

// BroadcastOpReturn publishes raw OP_RETURN data through the active wallet's
// backend and returns the txid. Every wallet broadcasts through the
// orchestrator wallet manager now — the same path the normal "Send" flow uses.
// This is the single broadcast seam every server-side OP_RETURN sender shares.
func (e *WalletEngine) BroadcastOpReturn(ctx context.Context, data []byte, feeSatPerVByte, feeSats uint64) (string, error) {
	activeWallet, err := e.GetActiveWallet(ctx)
	if err != nil {
		return "", fmt.Errorf("get active wallet: %w", err)
	}

	req := &orchpb.SendTransactionRequest{
		WalletId:    activeWallet.ID,
		OpReturnHex: hex.EncodeToString(data),
	}
	switch {
	case feeSatPerVByte > 0:
		req.FeeRateSatPerVbyte = int64(feeSatPerVByte)
	case feeSats > 0:
		req.FixedFeeSats = int64(feeSats)
	}
	return e.SendTransaction(ctx, req)
}

// SendTransaction builds, signs, and broadcasts a transaction through the
// orchestrator wallet manager, which routes to the active wallet's backend
// (electrum or Bitcoin Core). Used by server-side senders like news OP_RETURNs.
func (e *WalletEngine) SendTransaction(ctx context.Context, req *orchpb.SendTransactionRequest) (string, error) {
	if err := e.refuseFrozenInputs(ctx, req.RequiredInputs); err != nil {
		return "", err
	}
	if err := e.PushFrozenCoins(ctx); err != nil {
		return "", err
	}
	resp, err := e.orchClient.SendTransaction(ctx, connect.NewRequest(req))
	if err != nil {
		return "", fmt.Errorf("send transaction: %w", err)
	}
	return resp.Msg.Txid, nil
}

// ErrFrozenInput is the error of a send that names a coin the user froze.
var ErrFrozenInput = errors.New("the output is frozen; unfreeze it to spend it")

// refuseFrozenInputs stops a send that names a frozen coin. The orchestrator
// spends a required input through its freeze.
func (e *WalletEngine) refuseFrozenInputs(ctx context.Context, inputs []*orchpb.UnspentOutput) error {
	if len(inputs) == 0 {
		return nil
	}
	frozen, err := e.frozenCoins(ctx)
	if err != nil {
		return fmt.Errorf("read the frozen coins: %w", err)
	}
	held := make(map[string]bool, len(frozen))
	for _, outpoint := range frozen {
		txid, vout, ok := splitOutpoint(outpoint)
		if !ok {
			return fmt.Errorf("frozen coin %q is not a txid:vout", outpoint)
		}
		held[fmt.Sprintf("%s:%d", strings.ToLower(txid), vout)] = true
	}
	for _, input := range inputs {
		if held[fmt.Sprintf("%s:%d", strings.ToLower(input.Txid), input.Vout)] {
			return fmt.Errorf("%s:%d: %w", input.Txid, input.Vout, ErrFrozenInput)
		}
	}
	return nil
}

// ListWalletIDs names every wallet the orchestrator holds.
func (e *WalletEngine) ListWalletIDs(ctx context.Context) ([]string, error) {
	resp, err := e.orchClient.ListWallets(ctx, connect.NewRequest(&orchpb.ListWalletsRequest{}))
	if err != nil {
		return nil, fmt.Errorf("list wallets: %w", err)
	}
	return lo.Map(resp.Msg.Wallets, func(w *orchpb.WalletMetadata, _ int) string { return w.Id }), nil
}

// BumpFee replaces a transaction with one that pays more. Coin selection runs
// in the orchestrator, which locks the frozen coins for the length of the call.
func (e *WalletEngine) BumpFee(ctx context.Context, req *orchpb.BumpFeeRequest) (*orchpb.BumpFeeResponse, error) {
	if err := e.PushFrozenCoins(ctx); err != nil {
		return nil, err
	}
	resp, err := e.orchClient.BumpFee(ctx, connect.NewRequest(req))
	if err != nil {
		return nil, fmt.Errorf("bump fee: %w", err)
	}
	return resp.Msg, nil
}

// CreateDeposit builds and broadcasts a BIP300 M5 deposit from any wallet.
func (e *WalletEngine) CreateDeposit(ctx context.Context, req *orchpb.CreateDepositRequest) (string, error) {
	if err := e.PushFrozenCoins(ctx); err != nil {
		return "", err
	}
	resp, err := e.orchClient.CreateDeposit(ctx, connect.NewRequest(req))
	if err != nil {
		return "", fmt.Errorf("create deposit: %w", err)
	}
	return resp.Msg.Txid, nil
}

// GetElectrumUnspent returns an electrum wallet's UTXOs from the orchestrator,
// which serves them over Esplora.
func (e *WalletEngine) GetElectrumUnspent(ctx context.Context, walletID string) ([]*orchpb.UnspentOutput, error) {
	resp, err := e.orchClient.ListUnspent(ctx, connect.NewRequest(&orchpb.ListUnspentRequest{
		WalletId: walletID,
	}))
	if err != nil {
		return nil, fmt.Errorf("electrum: list unspent: %w", err)
	}
	return resp.Msg.Utxos, nil
}

// GetElectrumTransactions returns an electrum wallet's transactions from the
// orchestrator, which serves them over Esplora.
func (e *WalletEngine) GetElectrumTransactions(ctx context.Context, walletID string) ([]*orchpb.TransactionEntry, error) {
	resp, err := e.orchClient.ListTransactions(ctx, connect.NewRequest(&orchpb.ListTransactionsRequest{
		WalletId: walletID,
		// The orchestrator has no skip, and a count of 0 means 100 rows.
		Count: math.MaxInt32,
	}))
	if err != nil {
		return nil, fmt.Errorf("electrum: list transactions: %w", err)
	}
	return resp.Msg.Transactions, nil
}

// EnsureWatchOnlyWallet ensures a watch-only wallet exists in Bitcoin Core
func (e *WalletEngine) EnsureWatchOnlyWallet(ctx context.Context, walletID string) (string, error) {
	// This path named the wallet watch_<prefix> before it was aligned with the
	// orchestrator, and that wallet holds the scan state for this wallet's
	// history. Check it before delegation: the orchestrator only ever derives
	// wallet_<prefix>, so it would create an empty wallet beside the populated
	// one and the balance would read as zero until a manual rescan.
	e.mu.RLock()
	cached, ok := e.coreWallets[walletID]
	e.mu.RUnlock()
	if ok {
		return cached, nil
	}

	legacy, err := e.legacyWatchOnlyWallet(ctx, walletID)
	if err != nil {
		return "", err
	}
	if legacy != "" {
		e.mu.Lock()
		e.coreWallets[walletID] = legacy
		e.mu.Unlock()
		return legacy, nil
	}

	return e.EnsureBitcoinCoreWallet(ctx, walletID)
}

// ============================================================================
// Wallet Sync (from WalletSyncer)
// ============================================================================

// SyncWallets syncs Bitcoin Core wallets from wallet.json to Bitcoin Core
// This is called after wallet unlock to ensure all Bitcoin Core wallets exist
func (e *WalletEngine) SyncWallets(ctx context.Context) error {
	log := zerolog.Ctx(ctx)

	// Throttle syncs to once per 5 seconds
	e.mu.Lock()
	if time.Since(e.lastSync) < 5*time.Second {
		e.mu.Unlock()
		log.Debug().Msg("wallet sync: throttled, skipping")
		return nil
	}
	e.lastSync = time.Now()
	e.mu.Unlock()

	log.Info().Msg("wallet sync: starting")

	resp, err := e.orchClient.EnsureCoreWallets(ctx, connect.NewRequest(&orchpb.EnsureCoreWalletsRequest{}))
	if err != nil {
		return fmt.Errorf("wallet sync: %w", err)
	}
	log.Info().Int32("synced", resp.Msg.SyncedCount).Msg("wallet sync: completed via orchestrator")
	return nil
}

func (e *WalletEngine) GetAllWallets(ctx context.Context) ([]WalletInfo, error) {
	wallets, _, err := e.listWallets(ctx)
	return wallets, err
}

// listWallets returns the wallets the orchestrator holds open, and the active
// wallet id. A locked wallet file lists no wallets.
func (e *WalletEngine) listWallets(ctx context.Context) ([]WalletInfo, string, error) {
	resp, err := e.orchClient.ListWallets(ctx, connect.NewRequest(&orchpb.ListWalletsRequest{}))
	if err != nil {
		return nil, "", fmt.Errorf("list wallets: %w", err)
	}
	wallets := lo.Map(resp.Msg.Wallets, func(w *orchpb.WalletMetadata, _ int) WalletInfo {
		return WalletInfo{
			ID:             w.Id,
			Name:           w.Name,
			WalletType:     walletTypeFromProto(w.WalletType),
			WatchOnly:      w.WatchOnly,
			AccountIndex:   w.AccountIndex,
			DerivationPath: w.DerivationPath,
			ScriptType:     w.ScriptType,
		}
	})
	return wallets, resp.Msg.ActiveWalletId, nil
}

// ChequeAddressUnspent reports a cheque address's UTXOs. Always electrum-backed
// on the orchestrator side, whatever wallet the user has active.
func (e *WalletEngine) ChequeAddressUnspent(ctx context.Context, address string) ([]*orchpb.AddressUnspentOutput, int32, error) {
	resp, err := e.orchClient.GetAddressUnspent(ctx, connect.NewRequest(&orchpb.GetAddressUnspentRequest{
		Address: address,
	}))
	if err != nil {
		return nil, 0, fmt.Errorf("electrum: address unspent: %w", err)
	}
	return resp.Msg.Utxos, resp.Msg.TipHeight, nil
}

// BroadcastChequeTx broadcasts a cheque sweep over electrum, whatever wallet
// the user has active.
func (e *WalletEngine) BroadcastChequeTx(ctx context.Context, txHex string) (string, error) {
	resp, err := e.orchClient.BroadcastElectrumTransaction(ctx, connect.NewRequest(&orchpb.BroadcastElectrumTransactionRequest{
		TxHex: txHex,
	}))
	if err != nil {
		return "", fmt.Errorf("electrum: broadcast: %w", err)
	}
	return resp.Msg.Txid, nil
}

// EstimateFeeRate returns the electrum fee estimate in sat/vB for a
// confirmation target, floored at the 1 sat/vB relay minimum.
func (e *WalletEngine) EstimateFeeRate(ctx context.Context, confTarget int32) (float64, error) {
	resp, err := e.orchClient.EstimateFee(ctx, connect.NewRequest(&orchpb.EstimateFeeRequest{
		ConfTarget: confTarget,
	}))
	if err != nil {
		return 0, fmt.Errorf("electrum: estimate fee: %w", err)
	}
	rate := resp.Msg.SatPerVbyte
	if rate < 1 {
		rate = 1
	}
	return rate, nil
}

// legacyWatchOnlyWallet returns the pre-rename watch_<prefix> wallet name when
// Bitcoin Core can serve it, or "" when no such wallet exists. A load failure
// that does not say the wallet is absent returns an error instead: to treat it
// as absent would create a second wallet and hide the first one's scan state.
// The answer is remembered, because the frontend polls this path.
func (e *WalletEngine) legacyWatchOnlyWallet(ctx context.Context, walletID string) (string, error) {
	if e.bitcoindConnector == nil || len(walletID) < 8 {
		return "", nil
	}

	e.mu.RLock()
	checked := e.legacyChecked[walletID]
	e.mu.RUnlock()
	if checked {
		return "", nil
	}

	// Two polls that both find the wallet unloaded would both call loadwallet,
	// and the loser gets an "already loading" error. Coalesce them, as the
	// wallet-ensure path beside this one already does.
	found, err, _ := e.ensureGroup.Do("legacy:"+walletID, func() (interface{}, error) {
		return e.probeLegacyWatchOnlyWallet(ctx, walletID)
	})
	if err != nil {
		return "", err
	}
	return found.(string), nil
}

func (e *WalletEngine) probeLegacyWatchOnlyWallet(ctx context.Context, walletID string) (string, error) {
	name := fmt.Sprintf("watch_%s", walletID[:8])

	// A failure here is not proof that the legacy wallet is absent. To read it
	// that way lets the orchestrator create wallet_<prefix> beside a populated
	// watch_<prefix>, which hides that wallet's balance and scan history. The
	// frontend polls this path, so a propagated error costs one cycle.
	bitcoindClient, err := e.bitcoindConnector(ctx)
	if err != nil {
		return "", fmt.Errorf("check for a legacy watch-only wallet: %w", err)
	}
	listResp, err := bitcoindClient.ListWallets(ctx, connect.NewRequest(&emptypb.Empty{}))
	if err != nil {
		return "", fmt.Errorf("check for a legacy watch-only wallet: %w", err)
	}
	if lo.Contains(listResp.Msg.Wallets, name) {
		return name, nil
	}

	if _, err := bitcoindClient.LoadWallet(ctx, connect.NewRequest(&corepb.LoadWalletRequest{Filename: name})); err != nil {
		if isWalletNotFoundError(err.Error()) {
			e.markLegacyChecked(walletID)
			return "", nil
		}
		return "", fmt.Errorf("load legacy watch-only wallet %s: %w", name, err)
	}
	return name, nil
}

func (e *WalletEngine) markLegacyChecked(walletID string) {
	e.mu.Lock()
	defer e.mu.Unlock()
	if e.legacyChecked == nil {
		e.legacyChecked = make(map[string]bool)
	}
	e.legacyChecked[walletID] = true
}

// isWalletNotFoundError reports whether Core says the wallet does not exist,
// rather than that it could not be loaded right now.
func isWalletNotFoundError(msg string) bool {
	m := strings.ToLower(msg)
	return strings.Contains(m, "not found") ||
		strings.Contains(m, "does not exist") ||
		strings.Contains(m, "no such file")
}

// SidechainDepositTotals sums this install's deposits: all time, and since
// `since`. Both in sats. An empty walletID sums every wallet's.
func (e *WalletEngine) SidechainDepositTotals(ctx context.Context, since time.Time, walletID string) (int64, int64, error) {
	resp, err := e.orchClient.GetSidechainDepositTotals(ctx, connect.NewRequest(&orchpb.GetSidechainDepositTotalsRequest{
		SinceUnix: since.Unix(),
		WalletId:  walletID,
	}))
	if err != nil {
		return 0, 0, fmt.Errorf("get sidechain deposit totals: %w", err)
	}
	return resp.Msg.TotalSats, resp.Msg.RecentSats, nil
}

// ListSidechainDeposits reports the deposits this install made to a slot. The
// orchestrator records each one as it broadcasts it, because an M5 is an
// ordinary transaction on the wire.
func (e *WalletEngine) ListSidechainDeposits(ctx context.Context, slot uint32, walletID string) ([]*orchpb.SidechainDeposit, error) {
	resp, err := e.orchClient.ListSidechainDeposits(ctx, connect.NewRequest(&orchpb.ListSidechainDepositsRequest{
		Slot:     slot,
		WalletId: walletID,
	}))
	if err != nil {
		return nil, fmt.Errorf("list sidechain deposits: %w", err)
	}
	return resp.Msg.Deposits, nil
}
