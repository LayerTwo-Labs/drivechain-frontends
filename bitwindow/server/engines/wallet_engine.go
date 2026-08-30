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
	"strings"
	"sync"
	"time"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/wallet"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	orchrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	orchwallet "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
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

// coreWalletName derives the bitcoind wallet name for a wallet id. An id
// shorter than the 8-character prefix is rejected instead of sliced.
func coreWalletName(prefix, walletId string) (string, error) {
	if len(walletId) < 8 {
		return "", fmt.Errorf("wallet id %q is too short to name a Bitcoin Core wallet", walletId)
	}
	return fmt.Sprintf("%s_%s", prefix, walletId[:8]), nil
}

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
	// Try orchestrator first
	if e.orchClient != nil {
		resp, err := e.orchClient.CreateBitcoinCoreWallet(ctx, connect.NewRequest(&orchpb.CreateBitcoinCoreWalletRequest{
			WalletId: walletId,
		}))
		if err == nil {
			e.mu.Lock()
			e.coreWallets[walletId] = resp.Msg.CoreWalletName
			e.mu.Unlock()
			return resp.Msg.CoreWalletName, nil
		}
		// If the orchestrator says "still warming up" (Unavailable), don't
		// fall through to the local path — it would re-issue the same RPCs
		// against bitcoind and fail the same way, defeating the orchestrator's
		// 5s backoff and storming bitcoind during IBD/rescan.
		if connect.CodeOf(err) == connect.CodeUnavailable || IsBitcoinCoreStartupError(err.Error()) {
			return "", err
		}
		// Otherwise fall through to local fallback.
	}

	e.mu.Lock()
	defer e.mu.Unlock()

	// Check cache
	if walletName, exists := e.coreWallets[walletId]; exists {
		return walletName, nil
	}

	// Get wallet info
	wallet, err := e.GetWalletInfo(ctx, walletId)
	if err != nil {
		return "", err
	}

	if wallet.WalletType != WalletTypeBitcoinCore {
		return "", fmt.Errorf("wallet %s is not a Bitcoin Core wallet", walletId)
	}

	// Generate wallet name from wallet ID
	walletName, err := coreWalletName("wallet", walletId)
	if err != nil {
		return "", err
	}

	// Get bitcoind client
	bitcoindClient, err := e.bitcoindConnector(ctx)
	if err != nil {
		return "", fmt.Errorf("get bitcoind client: %w", err)
	}

	// Check if wallet already exists in Bitcoin Core
	listResp, err := bitcoindClient.ListWallets(ctx, connect.NewRequest(&emptypb.Empty{}))
	if err != nil {
		return "", fmt.Errorf("list Bitcoin Core wallets: %w", err)
	}

	walletExists := lo.Contains(listResp.Msg.Wallets, walletName)
	if !walletExists {
		// Create wallet from seed
		if err := e.CreateBitcoinCoreWalletFromSeed(ctx, walletName, wallet.Master.SeedHex, wallet.AccountIndex, wallet.DerivationPath); err != nil {
			return "", fmt.Errorf("create Bitcoin Core wallet: %w", err)
		}
		zerolog.Ctx(ctx).Info().
			Str("wallet_id", walletId).
			Str("wallet_name", walletName).
			Msg("created Bitcoin Core wallet from seed")
	}

	// Cache the mapping
	e.coreWallets[walletId] = walletName
	return walletName, nil
}

// CreateBitcoinCoreWalletFromSeed creates a Bitcoin Core wallet and imports the
// seed. accountIndex/derivationPath are the optional account-level derivation
// override (0/"" = standard BIP84+BIP86 at account 0).
func (e *WalletEngine) CreateBitcoinCoreWalletFromSeed(
	ctx context.Context,
	walletName string,
	seedHex string,
	accountIndex uint32,
	derivationPath string,
) error {
	// Decode seed
	seed, err := hex.DecodeString(seedHex)
	if err != nil {
		return fmt.Errorf("decode seed hex: %w", err)
	}

	// Derive master key
	masterKey, err := hdkeychain.NewMaster(seed, e.chainParams)
	if err != nil {
		return fmt.Errorf("derive master key: %w", err)
	}

	descriptors, err := e.coreDescriptors(masterKey, accountIndex, derivationPath, true)
	if err != nil {
		return err
	}

	// Get bitcoind client
	bitcoindClient, err := e.bitcoindConnector(ctx)
	if err != nil {
		return fmt.Errorf("get bitcoind client: %w", err)
	}

	// Create descriptor wallet in Bitcoin Core
	_, err = bitcoindClient.CreateWallet(ctx, connect.NewRequest(&corepb.CreateWalletRequest{
		Name:               walletName,
		DisablePrivateKeys: false,
		Blank:              true,
		Passphrase:         "",
		AvoidReuse:         false,
	}))
	if err != nil {
		// If wallet already exists on disk, load it instead
		if strings.Contains(err.Error(), "Database already exists") {
			zerolog.Ctx(ctx).Info().
				Str("wallet_name", walletName).
				Msg("Bitcoin Core wallet already exists on disk, loading it")

			_, err = bitcoindClient.LoadWallet(ctx, connect.NewRequest(&corepb.LoadWalletRequest{
				Filename:      walletName,
				LoadOnStartup: true,
			}))
			if err != nil {
				return fmt.Errorf("load Bitcoin Core wallet: %w", err)
			}
		} else {
			return fmt.Errorf("create Bitcoin Core wallet: %w", err)
		}
	}

	var requests []*corepb.ImportDescriptorsRequest_Request
	for _, d := range descriptors {
		descriptorWithChecksum, err := AddDescriptorChecksum(d.desc)
		if err != nil {
			return fmt.Errorf("compute descriptor checksum: %w", err)
		}

		requests = append(requests, &corepb.ImportDescriptorsRequest_Request{
			Descriptor_: descriptorWithChecksum,
			Active:      true,
			Timestamp:   nil,
			Internal:    d.internal,
			RangeEnd:    999,
		})
	}

	resp, err := bitcoindClient.ImportDescriptors(ctx, connect.NewRequest(&corepb.ImportDescriptorsRequest{
		Wallet:   walletName,
		Requests: requests,
	}))
	if err != nil {
		return fmt.Errorf("import descriptors: %w", err)
	}

	// Check results
	for i, result := range resp.Msg.Responses {
		if !result.Success {
			errMsg := "unknown error"
			if result.Error != nil {
				errMsg = result.Error.Message
			}
			return fmt.Errorf("descriptor %d import failed: %s", i, errMsg)
		}
	}

	return nil
}

// coreDescriptor is one descriptor string and whether it's the internal (change) chain.
type coreDescriptor struct {
	desc     string
	internal bool
}

// coreDescriptors builds the receive+change descriptors for a Core wallet from
// the master key and the optional account-level derivation override. With no
// override it returns BIP84 + BIP86 at account 0; an account index shifts both;
// an explicit path returns the single descriptor for that path's purpose. This
// mirrors the orchestrator CoreBackend so the local fallback derives identically.
func (e *WalletEngine) coreDescriptors(masterKey *hdkeychain.ExtendedKey, accountIndex uint32, derivationPath string, withOrigin bool) ([]coreDescriptor, error) {
	pubKey, err := masterKey.ECPubKey()
	if err != nil {
		return nil, fmt.Errorf("get master public key: %w", err)
	}
	fingerprint := hex.EncodeToString(btcutil.Hash160(pubKey.SerializeCompressed())[:4])

	var kinds []orchwallet.ScriptKind
	if strings.TrimSpace(derivationPath) != "" {
		ap, err := orchwallet.ParseAccountPath(derivationPath)
		if err != nil {
			return nil, fmt.Errorf("invalid derivation path: %w", err)
		}
		kind, ok := orchwallet.PurposeToCoreKind(ap.Purpose)
		if !ok {
			return nil, fmt.Errorf("unsupported core descriptor purpose %d'", ap.Purpose)
		}
		kinds = []orchwallet.ScriptKind{kind}
	} else {
		kinds = []orchwallet.ScriptKind{orchwallet.ScriptNativeSegwit, orchwallet.ScriptTaproot}
	}

	var out []coreDescriptor
	for _, kind := range kinds {
		ap, err := orchwallet.ResolveAccountPath(accountIndex, derivationPath, kind, e.chainParams)
		if err != nil {
			return nil, err
		}
		acct, err := DeriveHardenedPath(masterKey, ap)
		if err != nil {
			return nil, err
		}
		acctXprv := acct.String()
		open, close, ok := orchwallet.CoreDescriptorWrapper(kind)
		if !ok {
			return nil, fmt.Errorf("unsupported core descriptor kind %s", kind)
		}
		origin := ""
		if withOrigin {
			origin = fmt.Sprintf("[%s/%s]", fingerprint, ap.Origin("'"))
		}
		out = append(out,
			coreDescriptor{desc: fmt.Sprintf("%s%s%s/0/*%s", open, origin, acctXprv, close), internal: false},
			coreDescriptor{desc: fmt.Sprintf("%s%s%s/1/*%s", open, origin, acctXprv, close), internal: true},
		)
	}
	return out, nil
}

// DeriveHardenedPath derives the hardened account-level key for an AccountPath.
func DeriveHardenedPath(masterKey *hdkeychain.ExtendedKey, ap orchwallet.AccountPath) (*hdkeychain.ExtendedKey, error) {
	const h = hdkeychain.HardenedKeyStart
	cur := masterKey
	for _, idx := range []uint32{ap.Purpose, ap.Coin, ap.Account} {
		next, err := cur.Derive(h + idx)
		if err != nil {
			return nil, fmt.Errorf("derive %d': %w", idx, err)
		}
		cur = next
	}
	return cur, nil
}

// GetBitcoinCoreWalletName returns the Bitcoin Core wallet name for a walletId
func (e *WalletEngine) GetBitcoinCoreWalletName(ctx context.Context, walletId string) (string, error) {
	return e.EnsureBitcoinCoreWallet(ctx, walletId)
}

// GetElectrumReceiveAddress returns a fresh receive address for an electrum
// wallet from the orchestrator, which derives it locally and serves chain
// data over Esplora (no Bitcoin Core).
func (e *WalletEngine) GetElectrumReceiveAddress(ctx context.Context, walletId string) (string, error) {
	if e.orchClient == nil {
		return "", fmt.Errorf("orchestrator wallet client not connected")
	}
	resp, err := e.orchClient.GetNewAddress(ctx, connect.NewRequest(&orchpb.GetNewAddressRequest{
		WalletId: walletId,
	}))
	if err != nil {
		return "", fmt.Errorf("electrum: get new address: %w", err)
	}
	return resp.Msg.Address, nil
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
	resp, err := e.orchClient.SendTransaction(ctx, connect.NewRequest(req))
	if err != nil {
		return "", fmt.Errorf("send transaction: %w", err)
	}
	return resp.Msg.Txid, nil
}

// CreateDeposit builds and broadcasts a BIP300 M5 deposit from any wallet.
func (e *WalletEngine) CreateDeposit(ctx context.Context, req *orchpb.CreateDepositRequest) (string, error) {
	if e.orchClient == nil {
		return "", fmt.Errorf("orchestrator wallet client not connected")
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

	// Try orchestrator first (it handles full and watch-only Core wallets)
	if e.orchClient != nil {
		resp, err := e.orchClient.CreateBitcoinCoreWallet(ctx, connect.NewRequest(&orchpb.CreateBitcoinCoreWalletRequest{
			WalletId: walletId,
		}))
		if err == nil {
			e.mu.Lock()
			e.coreWallets[walletId] = resp.Msg.CoreWalletName
			e.mu.Unlock()
			return resp.Msg.CoreWalletName, nil
		}
		// A starting bitcoind fails the local path the same way, so propagate
		// instead of storming it. A transport failure means the orchestrator is
		// down, and the local path is exactly the fallback for that.
		if IsBitcoinCoreStartupError(err.Error()) {
			return "", err
		}
		// Otherwise fall through to local on error
	}

	e.mu.Lock()
	defer e.mu.Unlock()

	// Check cache
	if walletName, exists := e.coreWallets[walletId]; exists {
		return walletName, nil
	}

	// Get wallet info
	wallet, err := e.GetWalletInfo(ctx, walletId)
	if err != nil {
		return "", err
	}

	if !wallet.IsWatchOnly() {
		return "", fmt.Errorf("wallet %s is not a watch-only wallet", walletId)
	}

	// Generate wallet name from wallet ID
	walletName, err := coreWalletName("wallet", walletId)
	if err != nil {
		return "", err
	}

	// Get bitcoind client
	bitcoindClient, err := e.bitcoindConnector(ctx)
	if err != nil {
		return "", fmt.Errorf("get bitcoind client: %w", err)
	}

	// Check if wallet already exists in Bitcoin Core
	listResp, err := bitcoindClient.ListWallets(ctx, connect.NewRequest(&emptypb.Empty{}))
	if err != nil {
		return "", fmt.Errorf("list Bitcoin Core wallets: %w", err)
	}

	walletExists := lo.Contains(listResp.Msg.Wallets, walletName)
	if !walletExists {
		// Create watch-only wallet
		if err := e.createWatchOnlyWallet(ctx, walletName, wallet); err != nil {
			return "", fmt.Errorf("create watch-only wallet: %w", err)
		}
		zerolog.Ctx(ctx).Info().
			Str("wallet_id", walletId).
			Str("wallet_name", walletName).
			Msg("created watch-only Bitcoin Core wallet")
	}

	// Cache the mapping
	e.coreWallets[walletId] = walletName
	return walletName, nil
}

// createWatchOnlyWallet creates a watch-only Bitcoin Core wallet
func (e *WalletEngine) createWatchOnlyWallet(
	ctx context.Context,
	walletName string,
	wallet *WalletInfo,
) error {
	// Get bitcoind client
	bitcoindClient, err := e.bitcoindConnector(ctx)
	if err != nil {
		return fmt.Errorf("get bitcoind client: %w", err)
	}

	// Create descriptor wallet in Bitcoin Core (watch-only)
	_, err = bitcoindClient.CreateWallet(ctx, connect.NewRequest(&corepb.CreateWalletRequest{
		Name:               walletName,
		DisablePrivateKeys: true,
		Blank:              true,
		Passphrase:         "",
		AvoidReuse:         false,
	}))
	if err != nil {
		// If wallet already exists on disk, load it instead
		if strings.Contains(err.Error(), "Database already exists") {
			zerolog.Ctx(ctx).Info().
				Str("wallet_name", walletName).
				Msg("Bitcoin Core watch-only wallet already exists on disk, loading it")

			_, err = bitcoindClient.LoadWallet(ctx, connect.NewRequest(&corepb.LoadWalletRequest{
				Filename:      walletName,
				LoadOnStartup: false,
			}))
			if err != nil {
				return fmt.Errorf("load Bitcoin Core wallet: %w", err)
			}
		} else {
			return fmt.Errorf("create Bitcoin Core wallet: %w", err)
		}
	}

	// Import the descriptor or xpub
	var descriptorToImport string
	var isXpub bool

	switch {
	case wallet.WatchOnly.Descriptor != "":
		descriptorToImport = wallet.WatchOnly.Descriptor
		isXpub = false

	case wallet.WatchOnly.Xpub != "":
		xpub := wallet.WatchOnly.Xpub
		descriptorToImport = fmt.Sprintf("wpkh(%s/0/*)#checksum", xpub)
		isXpub = true

	default:
		return fmt.Errorf("watch-only wallet requires either descriptor or xpub")
	}

	if err := e.importDescriptorToWallet(ctx, bitcoindClient, walletName, descriptorToImport, isXpub); err != nil {
		return fmt.Errorf("import descriptor: %w", err)
	}

	return nil
}

// importDescriptorToWallet imports a descriptor into a Bitcoin Core wallet
func (e *WalletEngine) importDescriptorToWallet(
	ctx context.Context,
	bitcoindClient corerpc.BitcoinServiceClient,
	walletName string,
	descriptor string,
	isXpub bool,
) error {
	descriptorsToImport := []string{descriptor}

	if isXpub {
		// Add change descriptor for xpub-based wallets
		xpubStart := strings.Index(descriptor, "wpkh(") + 5
		xpubEnd := strings.Index(descriptor, "/0/*)")
		if xpubStart > 5 && xpubEnd > xpubStart {
			xpub := descriptor[xpubStart:xpubEnd]
			changeDescriptor := fmt.Sprintf("wpkh(%s/1/*)#checksum", xpub)
			descriptorsToImport = append(descriptorsToImport, changeDescriptor)
		}
	}

	var requests []*corepb.ImportDescriptorsRequest_Request
	for i, desc := range descriptorsToImport {
		// Strip any existing (possibly placeholder) checksum and compute a real
		// one — Bitcoin Core rejects descriptors imported without a valid checksum.
		descWithChecksum, err := AddDescriptorChecksum(strings.Split(desc, "#")[0])
		if err != nil {
			return fmt.Errorf("compute descriptor checksum: %w", err)
		}
		isInternal := i == 1

		requests = append(requests, &corepb.ImportDescriptorsRequest_Request{
			Descriptor_: descWithChecksum,
			Active:      true,
			Timestamp:   nil,
			Internal:    isInternal,
			Label:       "",
			RangeStart:  0,
			RangeEnd:    1000,
		})
	}

	resp, err := bitcoindClient.ImportDescriptors(ctx, connect.NewRequest(&corepb.ImportDescriptorsRequest{
		Wallet:   walletName,
		Requests: requests,
	}))
	if err != nil {
		return fmt.Errorf("bitcoin core importdescriptors: %w", err)
	}

	// Check results
	for i, result := range resp.Msg.Responses {
		if !result.Success {
			errMsg := "unknown error"
			if result.Error != nil {
				errMsg = result.Error.Message
			}
			return fmt.Errorf("descriptor %d import failed: %s", i, errMsg)
		}
	}

	return nil
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

	// Try orchestrator first
	if e.orchClient != nil {
		resp, err := e.orchClient.EnsureCoreWallets(ctx, connect.NewRequest(&orchpb.EnsureCoreWalletsRequest{}))
		if err == nil {
			log.Info().Int32("synced", resp.Msg.SyncedCount).Msg("wallet sync: completed via orchestrator")
			return nil
		}
		log.Warn().Err(err).Msg("wallet sync: orchestrator failed, falling back to local")
	}

	wallets, err := e.loadAllWallets()
	if err != nil {
		return fmt.Errorf("load wallets: %w", err)
	}

	if len(wallets) == 0 {
		log.Info().Msg("wallet sync: no wallets to sync")
		return nil
	}

	// Ensure Bitcoin Core wallets exist
	if err := e.ensureBitcoinCoreWallets(ctx, wallets); err != nil {
		log.Error().Err(err).Msg("wallet sync: failed")
	}

	log.Info().Msg("wallet sync: completed")
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

func (e *WalletEngine) ensureBitcoinCoreWallets(ctx context.Context, wallets []WalletInfo) error {
	log := zerolog.Ctx(ctx)

	// Find all Bitcoin Core wallets
	coreWallets := lo.Filter(wallets, func(w WalletInfo, _ int) bool {
		return w.WalletType == WalletTypeBitcoinCore
	})

	if len(coreWallets) == 0 {
		return nil
	}

	// Get bitcoind client
	bitcoindClient, err := e.bitcoindConnector(ctx)
	if err != nil {
		return fmt.Errorf("bitcoind not available: %w", err)
	}

	// List existing wallets in Bitcoin Core
	listResp, err := bitcoindClient.ListWallets(ctx, connect.NewRequest(&emptypb.Empty{}))
	if err != nil {
		return fmt.Errorf("list Bitcoin Core wallets: %w", err)
	}

	// Check each wallet
	for _, wallet := range coreWallets {
		// One unnameable wallet must not stop the others from syncing.
		walletName, err := coreWalletName("wallet", wallet.ID)
		if err != nil {
			log.Error().
				Err(err).
				Str("wallet_id", wallet.ID).
				Msg("wallet sync: skipping wallet")
			continue
		}
		walletExists := lo.Contains(listResp.Msg.Wallets, walletName)

		if !walletExists {
			log.Info().
				Str("wallet_id", wallet.ID).
				Str("wallet_name", walletName).
				Msg("wallet sync: creating missing Bitcoin Core wallet")

			if err := e.createBitcoinCoreWalletForSync(ctx, bitcoindClient, walletName, &wallet); err != nil {
				log.Error().
					Err(err).
					Str("wallet_id", wallet.ID).
					Msg("wallet sync: failed to create Bitcoin Core wallet")
				continue
			}

			log.Info().
				Str("wallet_id", wallet.ID).
				Str("wallet_name", walletName).
				Msg("wallet sync: created Bitcoin Core wallet")
		}
	}

	return nil
}

func (e *WalletEngine) createBitcoinCoreWalletForSync(
	ctx context.Context,
	bitcoindClient corerpc.BitcoinServiceClient,
	walletName string,
	wallet *WalletInfo,
) error {
	// Decode seed
	seed, err := hex.DecodeString(wallet.Master.SeedHex)
	if err != nil {
		return fmt.Errorf("decode seed hex: %w", err)
	}

	// Derive master key
	masterKey, err := hdkeychain.NewMaster(seed, e.chainParams)
	if err != nil {
		return fmt.Errorf("derive master key: %w", err)
	}

	descriptors, err := e.coreDescriptors(masterKey, wallet.AccountIndex, wallet.DerivationPath, false)
	if err != nil {
		return err
	}

	// Create wallet
	_, err = bitcoindClient.CreateWallet(ctx, connect.NewRequest(&corepb.CreateWalletRequest{
		Name:               walletName,
		DisablePrivateKeys: false,
		Blank:              true,
		Passphrase:         "",
		AvoidReuse:         false,
	}))
	if err != nil {
		// If wallet already exists on disk, load it instead
		if strings.Contains(err.Error(), "Database already exists") {
			zerolog.Ctx(ctx).Info().
				Str("wallet_name", walletName).
				Msg("Bitcoin Core wallet already exists on disk, loading it")

			_, err = bitcoindClient.LoadWallet(ctx, connect.NewRequest(&corepb.LoadWalletRequest{
				Filename:      walletName,
				LoadOnStartup: false,
			}))
			if err != nil {
				return fmt.Errorf("load Bitcoin Core wallet: %w", err)
			}
		} else {
			return fmt.Errorf("create Bitcoin Core wallet: %w", err)
		}
	}

	var requests []*corepb.ImportDescriptorsRequest_Request
	for _, d := range descriptors {
		descriptorWithChecksum, err := AddDescriptorChecksum(d.desc)
		if err != nil {
			return fmt.Errorf("compute descriptor checksum: %w", err)
		}

		requests = append(requests, &corepb.ImportDescriptorsRequest_Request{
			Descriptor_: descriptorWithChecksum,
			Active:      true,
			Timestamp:   nil,
			Internal:    d.internal,
			RangeStart:  0,
			RangeEnd:    1000,
		})
	}

	resp, err := bitcoindClient.ImportDescriptors(ctx, connect.NewRequest(&corepb.ImportDescriptorsRequest{
		Wallet:   walletName,
		Requests: requests,
	}))
	if err != nil {
		return fmt.Errorf("import descriptors: %w", err)
	}

	// Check results
	for i, result := range resp.Msg.Responses {
		if !result.Success {
			errMsg := "unknown error"
			if result.Error != nil {
				errMsg = result.Error.Message
			}
			return fmt.Errorf("descriptor %d import failed: %s", i, errMsg)
		}
	}

	return nil
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
	name, err := coreWalletName("watch", walletId)
	if err != nil {
		return "", err
	}

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
