package engines

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"math"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"sync"
	"time"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/wallet"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	orchrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"golang.org/x/sync/singleflight"
	"google.golang.org/protobuf/types/known/emptypb"
)

// WalletType is a wallet's provider backend. Watch-only is an orthogonal
// capability (the watch_only payload), not a provider.
type WalletType string

const (
	WalletTypeBitcoinCore WalletType = "bitcoinCore"
	WalletTypeElectrum    WalletType = "electrum"
)

// WalletInfo contains information about a wallet from wallet.json
type WalletInfo struct {
	ID         string     `json:"id"`
	Name       string     `json:"name"`
	WalletType WalletType `json:"wallet_type"`
	Master     struct {
		SeedHex string `json:"seed_hex"`
	} `json:"master"`
	L1 struct {
		Mnemonic string `json:"mnemonic"`
	} `json:"l1"`
	WatchOnly *struct {
		Descriptor string `json:"descriptor"`
		Xpub       string `json:"xpub"`
	} `json:"watch_only,omitempty"`
	// AccountIndex shifts the standard BIP84/BIP86 descriptors to this account.
	// 0 = standard. Mutually exclusive with DerivationPath.
	AccountIndex uint32 `json:"account_index,omitempty"`
	// DerivationPath is an explicit account-level path (m/purpose'/coin'/account')
	// overriding purpose/coin/account; empty = standard purposes at AccountIndex.
	DerivationPath string `json:"derivation_path,omitempty"`
	// ScriptType is the stored address kind; empty means native segwit.
	ScriptType string `json:"script_type,omitempty"`
}

// IsWatchOnly reports whether the wallet holds no signing key — it carries an
// xpub/descriptor payload instead of a seed. Orthogonal to the provider type.
func (w *WalletInfo) IsWatchOnly() bool {
	return w.WatchOnly != nil
}

// WalletEngine handles wallet unlock/lock, backend routing, and Bitcoin Core sync.
// When an orchestrator client is set, core wallet operations are delegated to
// the orchestrator's WalletManagerService.
type WalletEngine struct {
	bitcoindConnector func(context.Context) (corerpc.BitcoinServiceClient, error)
	walletDir         string
	chainParams       *chaincfg.Params

	// Orchestrator client — when set, core wallet operations delegate here
	orchClient orchrpc.WalletManagerServiceClient

	// The one node-mode source every poller and gated RPC reads.
	nodeMode *NodeMode

	// Unlocked wallet state (in memory)
	mu             sync.RWMutex
	seedHex        string
	activeWalletId string
	isUnlocked     bool
	unlockCond     *sync.Cond

	// frozenCoins names the coins the user froze, so no send of ours takes one.
	frozenCoins FrozenCoinsFunc
	// frozenPushMu runs one hand-over at a time, newest set last.
	frozenPushMu sync.Mutex

	// Maps walletId -> Bitcoin Core wallet name (cache)
	coreWallets map[string]string

	// Wallet ids already checked for a pre-rename watch_<prefix> wallet. The
	// answer cannot change while the process runs, and the frontend polls this
	// path, so the check must not repeat a listwallets and loadwallet each time.
	legacyChecked map[string]bool

	// Coalesces concurrent EnsureBitcoinCoreWallet calls for the same
	// walletId into a single in-flight execution. The frontend polls
	// listTransactions every 5s, and each call before the cache populates
	// would otherwise issue its own loadwallet RPC against bitcoind —
	// causing a queue of "wallet already loading" -4s while Core is busy.
	ensureGroup singleflight.Group

	// Cached wallet metadata (populated during unlock for encrypted wallets)
	walletCache map[string]*WalletInfo

	// Sync throttling
	lastSync time.Time
}

// NewWalletEngine creates a new unified wallet engine
func NewWalletEngine(
	bitcoindConnector func(context.Context) (corerpc.BitcoinServiceClient, error),
	walletDir string,
	chainParams *chaincfg.Params,
) *WalletEngine {
	e := &WalletEngine{
		bitcoindConnector: bitcoindConnector,
		walletDir:         walletDir,
		chainParams:       chainParams,
		isUnlocked:        false,
		coreWallets:       make(map[string]string),
		walletCache:       make(map[string]*WalletInfo),
		nodeMode:          NewNodeMode(),
	}
	e.unlockCond = sync.NewCond(&e.mu)

	// The orchestrator client is set via SetOrchestratorClient after construction.

	// Auto-unlock unencrypted wallets at startup
	if !wallet.IsWalletEncrypted(walletDir) {
		walletData, err := wallet.LoadUnencryptedWallet(walletDir)
		if err == nil {
			if unlockErr := e.Unlock(walletData); unlockErr != nil {
				zerolog.Ctx(context.Background()).Warn().Err(unlockErr).Msg("failed to unlock wallet engine")
			}
		}
	}

	return e
}

// FrozenCoinsFunc names the coins the user froze, as txid:vout.
type FrozenCoinsFunc func(ctx context.Context) ([]string, error)

// SetFrozenCoins wires the source that names the coins the user froze. Every
// send this server makes leaves those coins alone.
func (e *WalletEngine) SetFrozenCoins(fn FrozenCoinsFunc) {
	e.mu.Lock()
	defer e.mu.Unlock()
	e.frozenCoins = fn
}

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
			zerolog.Ctx(ctx).Debug().Err(err).Msg("could not hand over the frozen coins")
		}
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
		}
	}
}

// PushFrozenCoins hands over the whole frozen set of this install.
func (e *WalletEngine) PushFrozenCoins(ctx context.Context) error {
	return e.pushFrozenCoins(ctx)
}

// pushFrozenCoins hands the orchestrator the coins no send may take. It runs
// before every send, so a drivechaind restart cannot leave the set behind.
//
// One push runs at a time. The set is read and sent under the same lock, so a
// slow push cannot land after a newer one and put the older set back.
func (e *WalletEngine) pushFrozenCoins(ctx context.Context) error {
	e.mu.RLock()
	fn := e.frozenCoins
	e.mu.RUnlock()
	if fn == nil || e.orchClient == nil {
		return nil
	}

	e.frozenPushMu.Lock()
	defer e.frozenPushMu.Unlock()

	outpoints, err := fn(ctx)
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

// SetOrchestratorClient sets the orchestrator WalletManagerService client.
// When set, core wallet operations delegate to the orchestrator.
func (e *WalletEngine) SetOrchestratorClient(client orchrpc.WalletManagerServiceClient) {
	e.orchClient = client
	e.nodeMode.SetClient(client)
}

// NodeMode hands out the shared node-mode source.
func (e *WalletEngine) NodeMode() *NodeMode {
	return e.nodeMode
}

// ============================================================================
// Unlock/Lock/State Management
// ============================================================================

// Unlock loads the seed into memory from decrypted wallet data
func (e *WalletEngine) Unlock(walletData map[string]any) error {
	e.mu.Lock()
	defer e.mu.Unlock()

	// Handle multi-wallet structure: { version, activeWalletId, wallets: [...] }
	wallets, ok := walletData["wallets"].([]any)
	if !ok {
		return errors.New("invalid wallet structure: missing wallets array")
	}

	if len(wallets) == 0 {
		return errors.New("no wallets found in wallet.json")
	}

	// Get activeWalletId if present
	activeWalletId, _ := walletData["activeWalletId"].(string)

	// Find active wallet
	var activeWallet map[string]any
	var firstWallet map[string]any
	var firstWalletId string
	for _, w := range wallets {
		wallet, ok := w.(map[string]any)
		if !ok {
			continue
		}

		walletId, _ := wallet["id"].(string)

		// Track first wallet as fallback
		if firstWallet == nil {
			firstWallet = wallet
			firstWalletId = walletId
		}

		// If activeWalletId is set, use that specific wallet
		if activeWalletId != "" && walletId == activeWalletId {
			activeWallet = wallet
			break
		}
	}

	// The explicitly set activeWalletId wins; otherwise take the first wallet.
	switch {
	case activeWallet != nil:
		// Already found by activeWalletId

	case firstWallet != nil:
		activeWallet = firstWallet
		activeWalletId = firstWalletId

	}

	if activeWallet == nil {
		return errors.New("no wallets found in wallets array")
	}

	// Extract master seed from active wallet
	master, ok := activeWallet["master"].(map[string]any)
	if !ok {
		return errors.New("invalid wallet structure: missing master key")
	}

	seedHex, ok := master["seed_hex"].(string)
	if !ok || seedHex == "" {
		// Multisig and watch-only wallets have no master seed, so the cheque
		// engine has nothing to unlock. Skip rather than fail.
		zerolog.Ctx(context.Background()).Info().Msg("active wallet has no master seed (multisig/watch-only), skipping cheque engine unlock")
		return nil
	}

	// Validate seed hex
	if _, err := hex.DecodeString(seedHex); err != nil {
		return fmt.Errorf("invalid seed hex: %w", err)
	}

	// Cache all wallet metadata for encrypted wallets
	e.walletCache = make(map[string]*WalletInfo)
	for _, w := range wallets {
		walletMap, ok := w.(map[string]any)
		if !ok {
			continue
		}

		// Parse wallet info
		walletBytes, err := json.Marshal(walletMap)
		if err != nil {
			continue
		}

		var walletInfo WalletInfo
		if err := json.Unmarshal(walletBytes, &walletInfo); err != nil {
			continue
		}

		e.walletCache[walletInfo.ID] = &walletInfo
	}

	e.seedHex = seedHex
	e.activeWalletId = activeWalletId
	e.isUnlocked = true
	e.unlockCond.Broadcast()
	return nil
}

// Lock drops the in-memory seed and wallet cache. The seed string itself can't
// be zeroed in place (Go strings are immutable) — it lingers until GC.
func (e *WalletEngine) Lock() {
	e.mu.Lock()
	defer e.mu.Unlock()

	e.seedHex = ""
	e.activeWalletId = ""
	e.isUnlocked = false
	e.walletCache = make(map[string]*WalletInfo)
}

// IsUnlocked returns whether the engine is unlocked
func (e *WalletEngine) IsUnlocked() bool {
	e.mu.RLock()
	defer e.mu.RUnlock()
	return e.isUnlocked
}

// GetStarterSeed returns the seed hex of the wallet that derives the L1 and
// sidechain starters. BitDrive and ChequeEngine key off it, so it must name the
// same wallet for the life of the install.
func (e *WalletEngine) GetStarterSeed() (string, error) {
	// Try orchestrator first. GetWalletSeed names its wallet, so resolve the
	// starter's id before asking for its seed.
	if e.orchClient != nil {
		ctx := context.Background()
		list, err := e.orchClient.ListWallets(ctx, connect.NewRequest(&orchpb.ListWalletsRequest{}))
		if err == nil {
			starter, found := lo.Find(list.Msg.Wallets, func(w *orchpb.WalletMetadata) bool {
				return w.IsStarter
			})
			if found {
				resp, err := e.orchClient.GetWalletSeed(
					ctx,
					connect.NewRequest(&orchpb.GetWalletSeedRequest{WalletId: starter.Id}),
				)
				if err == nil {
					return resp.Msg.SeedHex, nil
				}
			}
		}
		// Fall through to local on error
	}

	wallets, err := e.loadAllWallets()
	if err != nil {
		return "", fmt.Errorf("load wallets: %w", err)
	}

	seeded := lo.Filter(wallets, func(w WalletInfo, _ int) bool {
		return w.Master.SeedHex != ""
	})
	if len(seeded) == 0 {
		return "", errors.New("no wallet holds a seed")
	}
	return seeded[0].Master.SeedHex, nil
}

// GetWalletSeed returns the seed hex for a specific wallet by ID
// Used by ChequeEngine for per-wallet cheque address derivation
func (e *WalletEngine) GetWalletSeed(walletId string) (string, error) {
	// Try orchestrator first
	if e.orchClient != nil {
		resp, err := e.orchClient.GetWalletSeed(context.Background(), connect.NewRequest(&orchpb.GetWalletSeedRequest{
			WalletId: walletId,
		}))
		if err == nil {
			return resp.Msg.SeedHex, nil
		}
		// Fall through to local on error
	}

	wallets, err := e.loadAllWallets()
	if err != nil {
		return "", fmt.Errorf("load wallets: %w", err)
	}

	// Find wallet by ID
	var targetWallet *WalletInfo
	for _, w := range wallets {
		if w.ID == walletId {
			targetWallet = &w
			break
		}
	}

	if targetWallet == nil {
		return "", fmt.Errorf("wallet not found: %s", walletId)
	}

	if targetWallet.Master.SeedHex == "" {
		return "", fmt.Errorf("wallet %s has no seed", walletId)
	}

	return targetWallet.Master.SeedHex, nil
}

// GetActiveWallet returns the active wallet
// If the wallet is encrypted, it uses the unlocked data from memory
// If the wallet is unencrypted, it reads directly from wallet.json
func (e *WalletEngine) GetActiveWallet(ctx context.Context) (*WalletInfo, error) {
	var activeWalletId string

	// Check if wallet is encrypted
	if wallet.IsWalletEncrypted(e.walletDir) {
		// For encrypted wallets, use the active wallet ID stored in memory
		e.mu.RLock()
		if !e.isUnlocked {
			e.mu.RUnlock()
			return nil, errors.New("wallet is encrypted and locked")
		}
		activeWalletId = e.activeWalletId
		e.mu.RUnlock()
	} else {
		// For unencrypted wallets, read directly from wallet.json
		walletData, err := wallet.LoadUnencryptedWallet(e.walletDir)
		if err != nil {
			return nil, fmt.Errorf("load wallet.json: %w", err)
		}

		id, ok := walletData["activeWalletId"].(string)
		if !ok || id == "" {
			return nil, fmt.Errorf("no active wallet ID found in wallet.json")
		}
		activeWalletId = id
	}

	return e.GetWalletInfo(ctx, activeWalletId)
}

// ============================================================================
// Wallet Info & Backend Routing
// ============================================================================

// GetChainParams returns the chain parameters for this wallet engine
func (e *WalletEngine) GetChainParams() *chaincfg.Params {
	return e.chainParams
}

// GetWalletInfo reads wallet.json and returns info for the specified walletId
func (e *WalletEngine) GetWalletInfo(ctx context.Context, walletId string) (*WalletInfo, error) {
	// Check if wallet is encrypted
	if wallet.IsWalletEncrypted(e.walletDir) {
		// For encrypted wallets, use the cache populated during unlock
		e.mu.RLock()
		defer e.mu.RUnlock()

		if !e.isUnlocked {
			return nil, errors.New("wallet is encrypted and locked")
		}

		walletInfo, exists := e.walletCache[walletId]
		if !exists {
			return nil, fmt.Errorf("wallet %s not found in cache", walletId)
		}

		return walletInfo, nil
	}

	// For unencrypted wallets, read from file
	walletFile := filepath.Join(e.walletDir, "wallet.json")

	data, err := os.ReadFile(walletFile)
	if err != nil {
		return nil, fmt.Errorf("read wallet.json: %w", err)
	}

	var walletData struct {
		Version        int          `json:"version"`
		ActiveWalletId string       `json:"activeWalletId"`
		Wallets        []WalletInfo `json:"wallets"`
	}

	if err := json.Unmarshal(data, &walletData); err != nil {
		return nil, fmt.Errorf("parse wallet.json: %w", err)
	}

	walletInfo := lo.Filter(walletData.Wallets, func(w WalletInfo, _ int) bool {
		return w.ID == walletId
	})

	if len(walletInfo) == 0 {
		return nil, fmt.Errorf("wallet %s not found", walletId)
	}

	return &walletInfo[0], nil
}

// GetActiveWalletInfo returns the WalletInfo for the currently active wallet
// This is an alias for GetActiveWallet for backwards compatibility
func (e *WalletEngine) GetActiveWalletInfo(ctx context.Context) (*WalletInfo, error) {
	return e.GetActiveWallet(ctx)
}

// GetWalletBackendType returns the backend type for a wallet
func (e *WalletEngine) GetWalletBackendType(ctx context.Context, walletId string) (WalletType, error) {
	if walletId == "" {
		return "", fmt.Errorf("wallet_id required")
	}
	wallet, err := e.GetWalletInfo(ctx, walletId)
	if err != nil {
		return "", err
	}
	return wallet.WalletType, nil
}

// IsWatchOnly reports whether the wallet has no signing key (watch-only),
// orthogonal to its provider type.
func (e *WalletEngine) IsWatchOnly(ctx context.Context, walletId string) (bool, error) {
	if walletId == "" {
		return false, fmt.Errorf("wallet_id required")
	}
	wallet, err := e.GetWalletInfo(ctx, walletId)
	if err != nil {
		return false, err
	}
	return wallet.IsWatchOnly(), nil
}

// ============================================================================
// Bitcoin Core Wallet Management
// ============================================================================

// EnsureBitcoinCoreWallet ensures a Bitcoin Core wallet exists for the given walletId
// Creates it from the seed if it doesn't exist (lazy loading).
//
// Concurrent callers for the same walletId are coalesced via singleflight so
// only one CreateWallet/LoadWallet against bitcoind is in flight at a time.
// Without this, each frontend poll would queue another loadwallet RPC and
// hit "-4: Wallet already loading" while Core was busy.
func (e *WalletEngine) EnsureBitcoinCoreWallet(ctx context.Context, walletId string) (string, error) {
	// Fast path — cache hit, no need to coalesce.
	e.mu.RLock()
	if walletName, exists := e.coreWallets[walletId]; exists {
		e.mu.RUnlock()
		return walletName, nil
	}
	e.mu.RUnlock()

	v, err, _ := e.ensureGroup.Do(walletId, func() (interface{}, error) {
		return e.ensureBitcoinCoreWalletLocked(ctx, walletId)
	})
	if err != nil {
		return "", err
	}
	return v.(string), nil
}

// ensureBitcoinCoreWalletLocked is the singleflight-wrapped body of
// EnsureBitcoinCoreWallet. Don't call directly.
func (e *WalletEngine) ensureBitcoinCoreWalletLocked(ctx context.Context, walletId string) (string, error) {
	if e.orchClient == nil {
		return "", fmt.Errorf("orchestrator wallet client not connected")
	}
	resp, err := e.orchClient.CreateBitcoinCoreWallet(ctx, connect.NewRequest(&orchpb.CreateBitcoinCoreWalletRequest{
		WalletId: walletId,
	}))
	if err != nil {
		return "", err
	}
	e.mu.Lock()
	e.coreWallets[walletId] = resp.Msg.CoreWalletName
	e.mu.Unlock()
	return resp.Msg.CoreWalletName, nil
}

// GetBitcoinCoreWalletName returns the Bitcoin Core wallet name for a walletId
func (e *WalletEngine) GetBitcoinCoreWalletName(ctx context.Context, walletId string) (string, error) {
	return e.EnsureBitcoinCoreWallet(ctx, walletId)
}

// GetNewAddress returns a receive address of the wallet. The orchestrator
// derives it for Core and electrum wallets alike.
func (e *WalletEngine) GetNewAddress(ctx context.Context, walletId string, addressType orchpb.AddressType) (string, error) {
	if e.orchClient == nil {
		return "", fmt.Errorf("orchestrator wallet client not connected")
	}
	resp, err := e.orchClient.GetNewAddress(ctx, connect.NewRequest(&orchpb.GetNewAddressRequest{
		WalletId:    walletId,
		AddressType: addressType,
	}))
	if err != nil {
		return "", fmt.Errorf("get new address: %w", err)
	}
	return resp.Msg.Address, nil
}

// DeriveReceiveAddresses returns the first count receive addresses of the
// wallet, as the orchestrator derives them.
func (e *WalletEngine) DeriveReceiveAddresses(ctx context.Context, walletId string, count int) ([]string, error) {
	if e.orchClient == nil {
		return nil, fmt.Errorf("orchestrator wallet client not connected")
	}
	resp, err := e.orchClient.DeriveAddresses(ctx, connect.NewRequest(&orchpb.DeriveAddressesRequest{
		WalletId: walletId,
		Count:    int32(count),
	}))
	if err != nil {
		return nil, fmt.Errorf("derive addresses: %w", err)
	}
	return resp.Msg.Addresses, nil
}

// GetElectrumBalance returns the confirmed and pending balance (in sats) for
// an electrum wallet from the orchestrator's Esplora-backed provider.
func (e *WalletEngine) GetElectrumBalance(ctx context.Context, walletId string) (confirmed, pending uint64, err error) {
	if e.orchClient == nil {
		return 0, 0, fmt.Errorf("orchestrator wallet client not connected")
	}
	resp, err := e.orchClient.GetBalance(ctx, connect.NewRequest(&orchpb.GetBalanceRequest{
		WalletId: walletId,
	}))
	if err != nil {
		return 0, 0, fmt.Errorf("electrum: get balance: %w", err)
	}
	return uint64(math.Round(resp.Msg.ConfirmedSats)), uint64(math.Round(resp.Msg.UnconfirmedSats)), nil
}

// CreatePsbt builds an unsigned PSBT for an electrum-wallet send via the
// orchestrator and returns it base64-encoded.
func (e *WalletEngine) CreatePsbt(ctx context.Context, req *orchpb.CreatePsbtRequest) (string, error) {
	if e.orchClient == nil {
		return "", fmt.Errorf("orchestrator wallet client not connected")
	}
	resp, err := e.orchClient.CreatePsbt(ctx, connect.NewRequest(req))
	if err != nil {
		return "", fmt.Errorf("electrum: create psbt: %w", err)
	}
	return resp.Msg.PsbtBase64, nil
}

// SignPsbt adds an electrum wallet's signatures to a base64 PSBT.
func (e *WalletEngine) SignPsbt(ctx context.Context, walletId, psbtBase64 string) (string, error) {
	if e.orchClient == nil {
		return "", fmt.Errorf("orchestrator wallet client not connected")
	}
	resp, err := e.orchClient.SignPsbt(ctx, connect.NewRequest(&orchpb.SignPsbtRequest{
		WalletId: walletId, PsbtBase64: psbtBase64,
	}))
	if err != nil {
		return "", fmt.Errorf("electrum: sign psbt: %w", err)
	}
	return resp.Msg.PsbtBase64, nil
}

// CombinePsbt merges cosigner PSBTs of the same transaction.
func (e *WalletEngine) CombinePsbt(ctx context.Context, psbtsBase64 []string) (string, error) {
	if e.orchClient == nil {
		return "", fmt.Errorf("orchestrator wallet client not connected")
	}
	resp, err := e.orchClient.CombinePsbt(ctx, connect.NewRequest(&orchpb.CombinePsbtRequest{
		PsbtBase64: psbtsBase64,
	}))
	if err != nil {
		return "", fmt.Errorf("electrum: combine psbt: %w", err)
	}
	return resp.Msg.PsbtBase64, nil
}

// FinalizePsbt extracts the raw transaction from a fully-signed PSBT.
func (e *WalletEngine) FinalizePsbt(ctx context.Context, psbtBase64 string) (string, error) {
	if e.orchClient == nil {
		return "", fmt.Errorf("orchestrator wallet client not connected")
	}
	resp, err := e.orchClient.FinalizePsbt(ctx, connect.NewRequest(&orchpb.FinalizePsbtRequest{
		PsbtBase64: psbtBase64,
	}))
	if err != nil {
		return "", fmt.Errorf("electrum: finalize psbt: %w", err)
	}
	return resp.Msg.RawTxHex, nil
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
	if e.orchClient == nil {
		return "", fmt.Errorf("orchestrator wallet client not connected")
	}
	if err := e.pushFrozenCoins(ctx); err != nil {
		return "", err
	}
	resp, err := e.orchClient.SendTransaction(ctx, connect.NewRequest(req))
	if err != nil {
		return "", fmt.Errorf("send transaction: %w", err)
	}
	return resp.Msg.Txid, nil
}

// ListWalletIDs names every wallet the orchestrator holds.
func (e *WalletEngine) ListWalletIDs(ctx context.Context) ([]string, error) {
	if e.orchClient == nil {
		return nil, fmt.Errorf("orchestrator wallet client not connected")
	}
	resp, err := e.orchClient.ListWallets(ctx, connect.NewRequest(&orchpb.ListWalletsRequest{}))
	if err != nil {
		return nil, fmt.Errorf("list wallets: %w", err)
	}
	return lo.Map(resp.Msg.Wallets, func(w *orchpb.WalletMetadata, _ int) string { return w.Id }), nil
}

// BumpFee replaces a transaction with one that pays more. Coin selection runs
// in the orchestrator, which locks the frozen coins for the length of the call.
func (e *WalletEngine) BumpFee(ctx context.Context, req *orchpb.BumpFeeRequest) (*orchpb.BumpFeeResponse, error) {
	if e.orchClient == nil {
		return nil, fmt.Errorf("orchestrator wallet client not connected")
	}
	if err := e.pushFrozenCoins(ctx); err != nil {
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
	if e.orchClient == nil {
		return "", fmt.Errorf("orchestrator wallet client not connected")
	}
	if err := e.pushFrozenCoins(ctx); err != nil {
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
func (e *WalletEngine) GetElectrumUnspent(ctx context.Context, walletId string) ([]*orchpb.UnspentOutput, error) {
	if e.orchClient == nil {
		return nil, fmt.Errorf("orchestrator wallet client not connected")
	}
	resp, err := e.orchClient.ListUnspent(ctx, connect.NewRequest(&orchpb.ListUnspentRequest{
		WalletId: walletId,
	}))
	if err != nil {
		return nil, fmt.Errorf("electrum: list unspent: %w", err)
	}
	return resp.Msg.Utxos, nil
}

// GetElectrumTransactions returns an electrum wallet's transactions from the
// orchestrator, which serves them over Esplora.
func (e *WalletEngine) GetElectrumTransactions(ctx context.Context, walletId string) ([]*orchpb.TransactionEntry, error) {
	if e.orchClient == nil {
		return nil, fmt.Errorf("orchestrator wallet client not connected")
	}
	resp, err := e.orchClient.ListTransactions(ctx, connect.NewRequest(&orchpb.ListTransactionsRequest{
		WalletId: walletId,
	}))
	if err != nil {
		return nil, fmt.Errorf("electrum: list transactions: %w", err)
	}
	return resp.Msg.Transactions, nil
}

// EnsureWatchOnlyWallet ensures a watch-only wallet exists in Bitcoin Core
func (e *WalletEngine) EnsureWatchOnlyWallet(ctx context.Context, walletId string) (string, error) {
	// This path named the wallet watch_<prefix> before it was aligned with the
	// orchestrator, and that wallet holds the scan state for this wallet's
	// history. Check it before delegation: the orchestrator only ever derives
	// wallet_<prefix>, so it would create an empty wallet beside the populated
	// one and the balance would read as zero until a manual rescan.
	e.mu.RLock()
	cached, ok := e.coreWallets[walletId]
	e.mu.RUnlock()
	if ok {
		return cached, nil
	}

	legacy, err := e.legacyWatchOnlyWallet(ctx, walletId)
	if err != nil {
		return "", err
	}
	if legacy != "" {
		e.mu.Lock()
		e.coreWallets[walletId] = legacy
		e.mu.Unlock()
		return legacy, nil
	}

	return e.EnsureBitcoinCoreWallet(ctx, walletId)
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

	if e.orchClient == nil {
		return fmt.Errorf("orchestrator wallet client not connected")
	}
	resp, err := e.orchClient.EnsureCoreWallets(ctx, connect.NewRequest(&orchpb.EnsureCoreWalletsRequest{}))
	if err != nil {
		return fmt.Errorf("wallet sync: %w", err)
	}
	log.Info().Int32("synced", resp.Msg.SyncedCount).Msg("wallet sync: completed via orchestrator")
	return nil
}

func (e *WalletEngine) loadAllWallets() ([]WalletInfo, error) {
	// Check if wallet is encrypted
	if wallet.IsWalletEncrypted(e.walletDir) {
		// For encrypted wallets, use the cache populated during unlock
		e.mu.RLock()
		defer e.mu.RUnlock()

		if !e.isUnlocked {
			return nil, errors.New("wallet is encrypted and locked")
		}

		// Extract wallets from cache
		wallets := make([]WalletInfo, 0, len(e.walletCache))
		for _, w := range e.walletCache {
			wallets = append(wallets, *w)
		}

		return wallets, nil
	}

	// For unencrypted wallets, read from file
	walletFile := filepath.Join(e.walletDir, "wallet.json")

	data, err := os.ReadFile(walletFile)
	if err != nil {
		return nil, fmt.Errorf("read wallet.json: %w", err)
	}

	var walletData struct {
		Version        int          `json:"version"`
		ActiveWalletId string       `json:"activeWalletId"`
		Wallets        []WalletInfo `json:"wallets"`
	}

	if err := json.Unmarshal(data, &walletData); err != nil {
		return nil, fmt.Errorf("parse wallet.json: %w", err)
	}

	return walletData.Wallets, nil
}

func (e *WalletEngine) GetAllWallets(ctx context.Context) ([]WalletInfo, error) {
	return e.loadAllWallets()
}

// HasOrchestratorClient reports whether the orchestrator's electrum surface is
// reachable at all — false in dev setups that never dialled it.
func (e *WalletEngine) HasOrchestratorClient() bool {
	return e.orchClient != nil
}

// ChequeAddressUnspent reports a cheque address's UTXOs. Always electrum-backed
// on the orchestrator side, whatever wallet the user has active.
func (e *WalletEngine) ChequeAddressUnspent(ctx context.Context, address string) ([]*orchpb.AddressUnspentOutput, int32, error) {
	if e.orchClient == nil {
		return nil, 0, fmt.Errorf("orchestrator wallet client not connected")
	}
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
	if e.orchClient == nil {
		return "", fmt.Errorf("orchestrator wallet client not connected")
	}
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
	if e.orchClient == nil {
		return 0, fmt.Errorf("orchestrator wallet client not connected")
	}
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
func (e *WalletEngine) legacyWatchOnlyWallet(ctx context.Context, walletId string) (string, error) {
	if e.bitcoindConnector == nil || len(walletId) < 8 {
		return "", nil
	}

	e.mu.RLock()
	checked := e.legacyChecked[walletId]
	e.mu.RUnlock()
	if checked {
		return "", nil
	}

	// Two polls that both find the wallet unloaded would both call loadwallet,
	// and the loser gets an "already loading" error. Coalesce them, as the
	// wallet-ensure path beside this one already does.
	found, err, _ := e.ensureGroup.Do("legacy:"+walletId, func() (interface{}, error) {
		return e.probeLegacyWatchOnlyWallet(ctx, walletId)
	})
	if err != nil {
		return "", err
	}
	return found.(string), nil
}

func (e *WalletEngine) probeLegacyWatchOnlyWallet(ctx context.Context, walletId string) (string, error) {
	name := fmt.Sprintf("watch_%s", walletId[:8])

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
			e.markLegacyChecked(walletId)
			return "", nil
		}
		return "", fmt.Errorf("load legacy watch-only wallet %s: %w", name, err)
	}
	return name, nil
}

func (e *WalletEngine) markLegacyChecked(walletId string) {
	e.mu.Lock()
	defer e.mu.Unlock()
	if e.legacyChecked == nil {
		e.legacyChecked = make(map[string]bool)
	}
	e.legacyChecked[walletId] = true
}

// isWalletNotFoundError reports whether Core says the wallet does not exist,
// rather than that it could not be loaded right now.
func isWalletNotFoundError(msg string) bool {
	m := strings.ToLower(msg)
	return strings.Contains(m, "not found") ||
		strings.Contains(m, "does not exist") ||
		strings.Contains(m, "no such file")
}

// ListSidechainDeposits reports the deposits this install made to a slot. The
// orchestrator records each one as it broadcasts it, because an M5 is an
// ordinary transaction on the wire.
// SidechainDepositTotals sums this install's deposits: all time, and since
// `since`. Both in sats. An empty walletID sums every wallet's.
func (e *WalletEngine) SidechainDepositTotals(ctx context.Context, since time.Time, walletID string) (int64, int64, error) {
	if e.orchClient == nil {
		return 0, 0, errors.New("orchestrator wallet client not connected")
	}
	resp, err := e.orchClient.GetSidechainDepositTotals(ctx, connect.NewRequest(&orchpb.GetSidechainDepositTotalsRequest{
		SinceUnix: since.Unix(),
		WalletId:  walletID,
	}))
	if err != nil {
		return 0, 0, fmt.Errorf("get sidechain deposit totals: %w", err)
	}
	return resp.Msg.TotalSats, resp.Msg.RecentSats, nil
}

func (e *WalletEngine) ListSidechainDeposits(ctx context.Context, slot uint32, walletID string) ([]*orchpb.SidechainDeposit, error) {
	if e.orchClient == nil {
		return nil, errors.New("orchestrator wallet client not connected")
	}
	resp, err := e.orchClient.ListSidechainDeposits(ctx, connect.NewRequest(&orchpb.ListSidechainDepositsRequest{
		Slot:     slot,
		WalletId: walletID,
	}))
	if err != nil {
		return nil, fmt.Errorf("list sidechain deposits: %w", err)
	}
	return resp.Msg.Deposits, nil
}
