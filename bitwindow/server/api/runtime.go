package api

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"sync/atomic"
	"time"

	"connectrpc.com/connect"
	"connectrpc.com/grpcreflect"

	api_bitdrive "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/bitdrive"
	api_bitwindowd "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/bitwindowd"
	api_drivechain "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/drivechain"
	api_enforcer "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/enforcer"
	api_fast_withdrawal "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/fast_withdrawal"
	api_health "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/health"
	api_m4 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/m4"
	api_misc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/misc"
	api_multisig "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/multisig"
	api_notification "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/notification"
	api_sidechain "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/sidechain"
	api_utils "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/utils"
	api_wallet "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/wallet"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	dial "github.com/LayerTwo-Labs/sidesail/bitwindow/server/dial"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitdrive/v1/bitdrivev1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1/bitwindowdv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/drivechain/v1/drivechainv1connect"
	fast_withdrawalv1connect "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/fast_withdrawal/v1/fast_withdrawalv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/health/v1/healthv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/m4/v1/m4v1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/misc/v1/miscv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/multisig/v1/multisigv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/notification/v1/notificationv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/sidechain/v1/sidechainv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/utils/v1/utilsv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1/walletv1connect"

	cryptorpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/crypto/v1/cryptov1connect"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
	orchrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"google.golang.org/protobuf/types/known/emptypb"
)

// swappableHandler atomically swaps the http.Handler it dispatches to.
//
// Lets the listener stay up across network swaps: each Runtime owns its own
// mux, and the top-level server points at this swappable. Recycle stores
// the new runtime's mux; in-flight requests on the old mux finish naturally
// against their captured handler refs.
type swappableHandler struct {
	inner atomic.Pointer[http.Handler]
}

func newSwappableHandler() *swappableHandler { return &swappableHandler{} }

func (s *swappableHandler) swap(h http.Handler) { s.inner.Store(&h) }

func (s *swappableHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	cur := s.inner.Load()
	if cur == nil {
		http.Error(w, "bitwindowd not ready", http.StatusServiceUnavailable)
		return
	}
	(*cur).ServeHTTP(w, r)
}

// Runtime owns all per-network state. Each network swap builds a fresh
// Runtime (new DB, new engines, new mux); the old Runtime is canceled
// + closed after its handlers drain.
type Runtime struct {
	ctx    context.Context
	cancel context.CancelFunc
	wg     sync.WaitGroup

	db       *sql.DB
	mux      *http.ServeMux
	services []string // service paths registered on mux, for grpcreflect

	walletEngine       *engines.WalletEngine
	chequeEngine       *engines.ChequeEngine
	bitcoinEngine      *engines.Parser
	deniabilityEngine  *engines.DeniabilityEngine
	timestampEngine    *engines.TimestampEngine
	notificationEngine *engines.NotificationEngine
	sidechainMonitor   *engines.SidechainMonitorEngine
	m4Engine           *engines.M4Engine
	bitdriveEngine     *engines.BitDriveEngine

	conf        config.Config
	chainParams *chaincfg.Params
	walletDir   string
}

// buildRuntime opens the network-scoped DB, instantiates engines, and
// registers all Connect sub-handlers on a fresh mux. Engines are NOT
// started — call rt.Start to kick goroutines off.
func (s *Server) buildRuntime(ctx context.Context, conf config.Config) (*Runtime, error) {
	log := zerolog.Ctx(ctx)

	walletDir := s.svcs.WalletDir
	if walletDir == "" {
		walletDir = filepath.Dir(conf.Datadir)
	}
	chainParams := s.svcs.ChainParams
	if chainParams == nil {
		chainParams = chainParamsFor(conf.BitcoinCoreNetwork)
	}

	rt := &Runtime{
		conf:        conf,
		walletDir:   walletDir,
		chainParams: chainParams,
		mux:         http.NewServeMux(),
	}

	if s.svcs.Database != nil {
		// Test injection — bypass on-disk open
		rt.db = s.svcs.Database
	} else {
		opened, err := database.New(ctx, conf)
		if err != nil {
			return nil, fmt.Errorf("open db at %s: %w", conf.Datadir, err)
		}
		rt.db = opened
	}

	log.Info().
		Str("network", string(conf.BitcoinCoreNetwork)).
		Str("datadir", conf.Datadir).
		Msg("runtime db ready")

	// WalletEngine wraps wallet.json on disk; auto-unlocks unencrypted wallets
	// inside its constructor. Driven by walletDir which is shared across
	// networks (not per-network).
	rt.walletEngine = engines.NewWalletEngine(
		func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
			return s.Bitcoind.Get(ctx)
		},
		func(ctx context.Context) (validatorrpc.WalletServiceClient, error) {
			return s.Wallet.Get(ctx)
		},
		rt.walletDir,
		rt.chainParams,
	)
	if s.svcs.OrchestratorAddr != "" {
		orchClient := orchrpc.NewWalletManagerServiceClient(http.DefaultClient, s.svcs.OrchestratorAddr)
		rt.walletEngine.SetOrchestratorClient(orchClient)
	}

	rt.chequeEngine = engines.NewChequeEngine(rt.walletEngine, rt.chainParams, s.Bitcoind)
	walletAdapter := engines.NewWalletAdapter(s.Wallet)
	timestampLogger := log.With().Str("component", "timestamp").Logger()
	rt.timestampEngine = engines.NewTimestampEngine(rt.db, timestampLogger, walletAdapter, s.Bitcoind)
	rt.m4Engine = engines.NewM4Engine(rt.db)
	rt.notificationEngine = engines.NewNotificationEngine(rt.db, s.Bitcoind)
	rt.bitdriveEngine = engines.NewBitDriveEngine(rt.db, rt.walletEngine, conf.Datadir, rt.chainParams)
	rt.sidechainMonitor = engines.NewSidechainMonitorEngine(
		s.Thunder, s.BitNames, s.BitAssets, s.Truthcoin, s.Photon, s.CoinShift,
		rt.notificationEngine,
	)
	rt.bitcoinEngine = engines.NewBitcoind(s.Bitcoind, rt.db, conf)

	// Coinnews dedicated log lives next to the main server log. Path is
	// derived from conf.LogPath which is also network-scoped (Finalize
	// rewrites it), so each runtime's coinnews log is in its own folder.
	coinnewsLogPath := filepath.Join(filepath.Dir(conf.LogPath), "coinnews-sync.log")
	if coinnewsFile, err := os.OpenFile(coinnewsLogPath, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0666); err == nil {
		coinnewsWriter := zerolog.NewConsoleWriter(func(w *zerolog.ConsoleWriter) {
			w.Out = coinnewsFile
			w.NoColor = true
			w.TimeFormat = time.DateTime + ".000"
		})
		coinnewsLogger := zerolog.New(coinnewsWriter).With().Timestamp().Logger()
		rt.bitcoinEngine.SetCoinnewsLogger(&coinnewsLogger)
		log.Info().Str("path", coinnewsLogPath).Msg("coinnews sync log enabled")
	} else {
		log.Warn().Err(err).Str("path", coinnewsLogPath).Msg("could not open coinnews-sync.log, skipping dedicated log")
	}

	rt.deniabilityEngine = engines.NewDeniability(s.Wallet, s.Bitcoind, rt.db, rt.walletEngine)

	// Register Connect sub-handlers on rt.mux. All registrations capture
	// rt's db + engines, so when this runtime is replaced, none of these
	// handler bodies are reachable through the new mux.
	register := func(servicePath string, h http.Handler) {
		rt.mux.Handle(servicePath, h)
		rt.services = append(rt.services, servicePath)
	}

	stdOpts := []connect.HandlerOption{connect.WithInterceptors(logInterceptor())}

	// bitwindowd — UpdateNetwork captured here calls back into Server.Recycle,
	// which builds a fresh Runtime. Method value is bound to s, late-binds
	// to current runtime via s.current at call time.
	{
		bwSvc := api_bitwindowd.New(s.onShutdown, rt.db, s.Enforcer, s.Wallet, s.Bitcoind, rt.walletEngine, conf, s.Recycle)
		path, h := bitwindowdv1connect.NewBitwindowdServiceHandler(bwSvc, stdOpts...)
		register(path, h)
	}
	{
		drivechainSvc := api_drivechain.New(s.Enforcer, s.Wallet, rt.db, conf)
		path, h := drivechainv1connect.NewDrivechainServiceHandler(drivechainSvc, stdOpts...)
		register(path, h)
	}
	{
		walletSvcImpl := api_wallet.New(ctx, rt.db, s.Bitcoind, s.Wallet, s.Crypto, rt.chequeEngine, rt.walletEngine, rt.walletDir)
		path, h := walletv1connect.NewWalletServiceHandler(walletSvcImpl, stdOpts...)
		register(path, h)
	}
	{
		miscSvc := api_misc.New(rt.db, s.Wallet, rt.timestampEngine, s.Bitcoind)
		path, h := miscv1connect.NewMiscServiceHandler(miscSvc, stdOpts...)
		register(path, h)
	}
	{
		healthSvc := api_health.New(rt.db, s.Bitcoind, s.Enforcer, s.Wallet, s.Crypto)
		path, h := healthv1connect.NewHealthServiceHandler(healthSvc, stdOpts...)
		register(path, h)
	}
	{
		m4Svc := api_m4.NewServer(rt.m4Engine)
		path, h := m4v1connect.NewM4ServiceHandler(m4Svc, stdOpts...)
		register(path, h)
	}
	{
		notifSvc := api_notification.New(rt.notificationEngine)
		path, h := notificationv1connect.NewNotificationServiceHandler(notifSvc, stdOpts...)
		register(path, h)
	}
	{
		bitdriveSvc := api_bitdrive.New(rt.db, s.Wallet, s.Bitcoind, rt.bitdriveEngine)
		path, h := bitdrivev1connect.NewBitDriveServiceHandler(bitdriveSvc, stdOpts...)
		register(path, h)
	}
	{
		utilsSvc := api_utils.New(rt.chainParams)
		path, h := utilsv1connect.NewUtilsServiceHandler(utilsSvc, stdOpts...)
		register(path, h)
	}
	{
		sidechainSvc := api_sidechain.New(rt.sidechainMonitor)
		path, h := sidechainv1connect.NewSidechainServiceHandler(sidechainSvc, stdOpts...)
		register(path, h)
	}
	{
		multisigSvc := api_multisig.New(rt.db)
		path, h := multisigv1connect.NewMultisigServiceHandler(multisigSvc, stdOpts...)
		register(path, h)
	}
	{
		fastSvc := api_fast_withdrawal.New(s.Thunder, s.BitNames, s.BitAssets, s.Truthcoin, s.Photon, s.CoinShift, rt.sidechainMonitor)
		path, h := fast_withdrawalv1connect.NewFastWithdrawalServiceHandler(fastSvc, stdOpts...)
		register(path, h)
	}
	// Enforcer bridge — single impl serves three separate services
	enforcerSvc := api_enforcer.New(s.Enforcer, s.Wallet, s.Crypto)
	{
		path, h := validatorrpc.NewValidatorServiceHandler(enforcerSvc, stdOpts...)
		register(path, h)
	}
	{
		path, h := validatorrpc.NewWalletServiceHandler(enforcerSvc, stdOpts...)
		register(path, h)
	}
	{
		path, h := cryptorpc.NewCryptoServiceHandler(enforcerSvc, stdOpts...)
		register(path, h)
	}

	// gRPC reflection. Each runtime mux gets its own reflector so listing
	// stays accurate after a recycle (set is identical across runtimes,
	// but rt-local for clarity).
	reflector := grpcreflect.NewStaticReflector(rt.services...)
	rt.mux.Handle(grpcreflect.NewHandlerV1(reflector))
	rt.mux.Handle(grpcreflect.NewHandlerV1Alpha(reflector))

	return rt, nil
}

// Start forks rt's engine context from parent and launches goroutines.
// Each engine writes its terminal error to errCh if non-nil; errCh closes
// when all engines have exited.
func (rt *Runtime) Start(parent context.Context) {
	rt.ctx, rt.cancel = context.WithCancel(parent)
	log := zerolog.Ctx(parent)

	// ChequeEngine has Start (it manages its own goroutine internally).
	rt.chequeEngine.Start(rt.ctx)

	// Auto-unlock any unencrypted wallet from disk. Mirrors the previous
	// main.go startup logic; runs once per runtime.
	rt.wg.Add(1)
	go func() {
		defer rt.wg.Done()
		rt.autoUnlockWallet(rt.ctx)
	}()

	rt.runEngine("bitcoin", rt.bitcoinEngine.Run, log)
	rt.runEngine("deniability", rt.deniabilityEngine.Run, log)
	rt.runEngine("timestamp", rt.timestampEngine.Run, log)
	rt.runEngine("notification", rt.notificationEngine.Run, log)
	rt.runEngine("sidechain-monitor", rt.sidechainMonitor.Run, log)

	if rt.conf.IsDemoMode() {
		demoEngine := engines.NewDemoEngine(rt.db)
		rt.runEngine("demo", demoEngine.Run, log)
		log.Info().Msg("demo mode enabled: simulating sidechain activity")
	}

	// ZMQ engine acquires its endpoint from bitcoind dynamically; retry
	// loop tolerates bitcoind startup. Lives on rt.ctx so it stops on
	// recycle.
	rt.wg.Add(1)
	go rt.runZMQ(rt.ctx, log)
}

func (rt *Runtime) runEngine(name string, run func(context.Context) error, log *zerolog.Logger) {
	rt.wg.Add(1)
	go func() {
		defer rt.wg.Done()
		err := run(rt.ctx)
		if err != nil && rt.ctx.Err() == nil {
			log.Error().Err(err).Str("engine", name).Msg("engine exited with error")
		}
	}()
}

func (rt *Runtime) runZMQ(ctx context.Context, log *zerolog.Logger) {
	defer rt.wg.Done()

	const maxAttempts = 20
	var zmqEngine *engines.ZMQ

	for attempt := 0; attempt < maxAttempts; attempt++ {
		eng, err := dialZmqEngine(ctx, rt.conf)
		if err != nil {
			if connect.CodeOf(err) == connect.CodeUnavailable || strings.Contains(err.Error(), "connection refused") {
				log.Debug().Msg("ZMQ engine: waiting for Bitcoin Core connection")
			} else {
				log.Error().Err(err).Msg("unable to acquire ZMQ engine")
			}
			select {
			case <-ctx.Done():
				return
			case <-time.After(5 * time.Second):
			}
			continue
		}

		if attempt != 0 {
			log.Debug().Msgf("ZMQ engine acquired on attempt %d", attempt)
		}
		zmqEngine = eng
		break
	}

	if zmqEngine == nil {
		log.Warn().Msg("no ZMQ engine acquired, skipping")
		return
	}

	// Subscribe goroutine — feeds raw txs into bitcoinEngine.
	go func() {
		for tx := range zmqEngine.Subscribe() {
			if err := rt.bitcoinEngine.HandleNewRawTransaction(ctx, tx); err != nil {
				log.Error().Err(err).Msgf("handle new raw transaction: %s", tx.TxHash())
			}
		}
	}()

	log.Info().Msg("starting ZMQ engine")
	if err := zmqEngine.Run(ctx); err != nil && ctx.Err() == nil {
		log.Error().Err(err).Msg("ZMQ engine exited with error")
	}
}

func dialZmqEngine(ctx context.Context, conf config.Config) (*engines.ZMQ, error) {
	btc, err := dial.Bitcoind(ctx, conf.OrchestratorAddr)
	if err != nil {
		return nil, fmt.Errorf("dial orchestrator bitcoin service: %w", err)
	}
	notifs, err := btc.GetZmqNotifications(ctx, connect.NewRequest(&emptypb.Empty{}))
	if err != nil {
		return nil, fmt.Errorf("get zmq notifications: %w", err)
	}
	pubRawTxAddress, found := lo.Find(notifs.Msg.Notifications,
		func(n *corepb.GetZmqNotificationsResponse_Notification) bool {
			return n.Type == "pubrawtx"
		},
	)
	if !found {
		return nil, errors.New("bitcoind does not publish pubrawtx ZMQ notifications")
	}
	return engines.NewZMQ(pubRawTxAddress.Address)
}

func (rt *Runtime) autoUnlockWallet(ctx context.Context) {
	log := zerolog.Ctx(ctx)
	walletPath := filepath.Join(rt.walletDir, "wallet.json")
	encryptionMetadataPath := filepath.Join(rt.walletDir, "wallet_encryption.json")

	if _, err := os.Stat(walletPath); err != nil {
		return
	}
	if _, err := os.Stat(encryptionMetadataPath); err == nil {
		log.Info().Msg("wallet is encrypted, skipping auto-unlock")
		return
	}

	log.Info().Msg("unencrypted wallet detected, auto-unlocking cheque engine")

	walletData, err := os.ReadFile(walletPath)
	if err != nil {
		log.Error().Err(err).Msg("failed to read wallet for auto-unlock")
		return
	}

	var walletMap map[string]any
	if err := json.Unmarshal(walletData, &walletMap); err != nil {
		log.Error().Err(err).Msg("failed to parse wallet for auto-unlock")
		return
	}

	if err := rt.walletEngine.Unlock(walletMap); err != nil {
		log.Error().Err(err).Msg("failed to auto-unlock wallet engine")
		return
	}
	log.Info().Msg("wallet engine auto-unlocked successfully")
}

// Close cancels engines, waits for goroutines, and closes the DB.
// Safe to call once. Subsequent calls are no-ops.
func (rt *Runtime) Close() {
	if rt.cancel != nil {
		rt.cancel()
	}
	rt.wg.Wait()
	if rt.db != nil {
		_ = rt.db.Close()
	}
}

func chainParamsFor(network config.Network) *chaincfg.Params {
	switch network {
	case config.NetworkMainnet, config.NetworkForknet:
		return &chaincfg.MainNetParams
	case config.NetworkTestnet:
		return &chaincfg.TestNet3Params
	case config.NetworkSignet:
		return &chaincfg.SigNetParams
	case config.NetworkRegtest:
		return &chaincfg.RegressionNetParams
	default:
		return &chaincfg.SigNetParams
	}
}
