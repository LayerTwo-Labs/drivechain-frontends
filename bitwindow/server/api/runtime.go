package api

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"sync"
	"sync/atomic"
	"time"

	"connectrpc.com/connect"
	"connectrpc.com/grpcreflect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"google.golang.org/protobuf/types/known/emptypb"

	api_bitdrive "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/bitdrive"
	api_bitwindowd "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/bitwindowd"
	api_drivechain "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/drivechain"
	api_enforcer "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/enforcer"
	api_health "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/health"
	api_m4 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/m4"
	api_misc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/misc"
	api_multisig "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/multisig"
	api_notification "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/notification"
	api_sidechain "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/sidechain"
	api_utils "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/utils"
	api_wallet "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/wallet"
	api_walletpsbt "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/walletpsbt"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	dial "github.com/LayerTwo-Labs/sidesail/bitwindow/server/dial"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitdrive/v1/bitdrivev1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1/bitwindowdv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/drivechain/v1/drivechainv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/health/v1/healthv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/m4/v1/m4v1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/misc/v1/miscv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/multisig/v1/multisigv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/notification/v1/notificationv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/sidechain/v1/sidechainv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/utils/v1/utilsv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1/walletv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/walletpsbt/v1/walletpsbtv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/miningpools"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/utxometadata"
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/enforcerproxy"
	cryptorpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/crypto/v1/cryptov1connect"
	validatorpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
	orchctlpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	orchrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/localauth"
)

// swappableHandler atomically swaps the http.Handler it dispatches to.
//
// Lets the listener stay up across network swaps: each Runtime has its own
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

// Runtime holds all per-network state. Each network swap builds a fresh
// Runtime (new DB, new engines, new mux); the old Runtime is canceled
// + closed after its handlers drain.
type Runtime struct {
	ctx    context.Context
	cancel context.CancelFunc
	wg     sync.WaitGroup

	// inflight counts in-flight request handlers so Close drains them before
	// closing the DB — otherwise a network swap closes db out from under a
	// running handler ("sql: database is closed").
	inflight sync.WaitGroup

	db       *sql.DB
	mux      *http.ServeMux
	services []string // service paths registered on mux, for grpcreflect

	walletEngine       *engines.WalletEngine
	chequeEngine       *engines.ChequeEngine
	chequeChain        engines.ChequeChain
	bitcoinEngine      *engines.Parser
	deniabilityEngine  *engines.DeniabilityEngine
	mempoolWatcher     *engines.MempoolWatcher
	timestampEngine    *engines.TimestampEngine
	notificationEngine *engines.NotificationEngine
	sidechainMonitor   *engines.SidechainMonitorEngine
	depositDropped     *engines.DepositDroppedEngine
	walletSvc          *api_wallet.Server
	m4Engine           *engines.M4Engine
	bitdriveEngine     *engines.BitDriveEngine

	conf        config.Config
	chainParams *chaincfg.Params
	walletDir   string
	coinnewsLog *os.File
}

// coinnewsLogPath returns the coinnews log of the active network.
func coinnewsLogPath(conf config.Config) string {
	return filepath.Join(conf.Datadir, "coinnews-sync.log")
}

// buildRuntime opens the network-scoped DB, instantiates engines, and
// registers all Connect sub-handlers on a fresh mux. Engines are NOT
// started — call rt.Start to kick goroutines off.
func (s *Server) buildRuntime(ctx context.Context, conf config.Config, networkID string) (*Runtime, error) {
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

	orchClient := s.svcs.OrchestratorClient
	if orchClient == nil {
		// Seed-bearing client (GetWalletSeed) — attach the local-auth cookie.
		orchClient = orchrpc.NewWalletManagerServiceClient(
			http.DefaultClient,
			s.svcs.OrchestratorAddr,
			connect.WithInterceptors(localauth.Interceptor(s.svcs.BitwindowDir)),
		)
	}
	rt.walletEngine = engines.NewWalletEngine(
		func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
			return s.Bitcoind.Get(ctx)
		},
		orchClient,
		rt.chainParams,
		// A coin the user froze belongs to no send of ours: not a news
		// broadcast, not a timestamp, not a BitDrive write.
		func(ctx context.Context) ([]string, error) {
			return utxometadata.FrozenOutpoints(ctx, rt.db)
		},
	)

	rt.chequeChain = engines.NewElectrumChequeChain(rt.walletEngine)
	rt.chequeEngine = engines.NewChequeEngine(rt.db, rt.walletEngine, rt.chainParams, rt.chequeChain)
	rt.timestampEngine = engines.NewTimestampEngine(rt.db, rt.walletEngine, s.Bitcoind, rt.walletEngine.NodeMode())
	rt.m4Engine = engines.NewM4Engine(rt.db)
	rt.notificationEngine = engines.NewNotificationEngine(rt.db, s.Bitcoind, rt.walletEngine.NodeMode())
	bitdriveEngine, err := engines.NewBitDriveEngine(rt.db, rt.walletEngine, conf.Datadir, rt.chainParams)
	if err != nil {
		return nil, err
	}
	rt.bitdriveEngine = bitdriveEngine
	rt.sidechainMonitor = engines.NewSidechainMonitorEngine(
		s.Thunder, s.BitNames, s.BitAssets, s.Truthcoin, s.Photon, s.CoinShift,
		rt.notificationEngine,
	)
	// A dropped deposit never reaches the sidechain, and nothing else in the
	// app reports it. The enforcer names the slots worth reading.
	rt.depositDropped = engines.NewDepositDroppedEngine(
		rt.db, rt.walletEngine, rt.notificationEngine,
		func(ctx context.Context) ([]uint32, error) { return activeSidechainSlots(ctx, s.Enforcer) },
	)

	var coinnewsLogger *zerolog.Logger
	coinnewsLogPath := coinnewsLogPath(conf)
	if coinnewsFile, err := os.OpenFile(coinnewsLogPath, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0666); err == nil {
		rt.coinnewsLog = coinnewsFile
		coinnewsWriter := zerolog.NewConsoleWriter(func(w *zerolog.ConsoleWriter) {
			w.Out = coinnewsFile
			w.NoColor = true
			w.TimeFormat = time.DateTime + ".000"
		})
		logger := zerolog.New(coinnewsWriter).With().Timestamp().Logger()
		coinnewsLogger = &logger
		log.Info().Str("path", coinnewsLogPath).Msg("coinnews sync log enabled")
	} else {
		log.Warn().Err(err).Str("path", coinnewsLogPath).Msg("open coinnews-sync.log: skip the dedicated log")
	}
	rt.bitcoinEngine = engines.NewBitcoind(s.Bitcoind, s.Enforcer, rt.db, conf, chainParams, rt.walletEngine.NodeMode(), coinnewsLogger)

	rt.deniabilityEngine = engines.NewDeniability(s.Bitcoind, rt.db, rt.walletEngine)
	rt.mempoolWatcher = engines.NewMempoolWatcher(rt.db, coreRawCall(s), func(ctx context.Context) (<-chan engines.SequenceMsg, func(), error) {
		addr, err := zmqAddress(ctx, conf, "pubsequence")
		if err != nil {
			return nil, nil, err
		}
		return engines.NewZmqEngine(addr).SubscribeSequence(ctx)
	}, rt.walletEngine.NodeMode())

	// Register Connect sub-handlers on rt.mux. All registrations capture
	// rt's db + engines, so when this runtime is replaced, none of these
	// handler bodies are reachable through the new mux.
	register := func(servicePath string, h http.Handler) {
		rt.mux.Handle(servicePath, h)
		rt.services = append(rt.services, servicePath)
	}

	// All bitwindowd endpoints require the local-auth cookie (one interceptor,
	// every handler). Disabled automatically when no cookie exists.
	stdOpts := []connect.HandlerOption{connect.WithInterceptors(logInterceptor(), recoverInterceptor{}, localauth.Interceptor(s.svcs.BitwindowDir))}

	// bitwindowd — UpdateNetwork captured here calls back into Server.Recycle,
	// which builds a fresh Runtime. Method value is bound to s, late-binds
	// to current runtime via s.current at call time.
	{
		pools := miningpools.New(ctx, conf.BitcoinCoreNetwork, networkID, conf.Datadir, s.svcs.MiningPoolFetch)
		bwSvc := api_bitwindowd.New(s.onShutdown, rt.db, s.Bitcoind, rt.walletEngine, rt.mempoolWatcher, pools, conf, s.Recycle)
		path, h := bitwindowdv1connect.NewBitwindowdServiceHandler(bwSvc, stdOpts...)
		register(path, h)
	}
	{
		drivechainSvc := api_drivechain.New(s.Enforcer, s.BlockProducer, rt.walletEngine)
		path, h := drivechainv1connect.NewDrivechainServiceHandler(drivechainSvc, stdOpts...)
		register(path, h)
	}
	{
		orchestrator := dial.Orchestrator(s.svcs.OrchestratorAddr, s.svcs.BitwindowDir)
		restartL1 := func(ctx context.Context) error {
			_, err := orchestrator.RestartL1(ctx, connect.NewRequest(&orchctlpb.RestartL1Request{}))
			return err
		}
		rt.walletSvc = api_wallet.New(rt.db, s.Bitcoind, s.Enforcer, rt.chequeEngine, rt.chequeChain, rt.walletEngine, rt.walletDir, restartL1)
		path, h := walletv1connect.NewWalletServiceHandler(rt.walletSvc, stdOpts...)
		register(path, h)
	}
	{
		miscSvc := api_misc.New(rt.db, rt.timestampEngine, s.Bitcoind, rt.walletEngine,
			engines.NewRemoteCoinNews(string(conf.BitcoinCoreNetwork)))
		path, h := miscv1connect.NewMiscServiceHandler(miscSvc, stdOpts...)
		register(path, h)
	}
	{
		healthSvc := api_health.New(rt.db, s.Bitcoind, s.Enforcer, s.Crypto)
		path, h := healthv1connect.NewHealthServiceHandler(healthSvc, stdOpts...)
		register(path, h)
	}
	{
		m4Svc := api_m4.NewServer(rt.m4Engine, s.BlockProducer)
		path, h := m4v1connect.NewM4ServiceHandler(m4Svc, stdOpts...)
		register(path, h)
	}
	{
		notifSvc := api_notification.New(rt.notificationEngine)
		path, h := notificationv1connect.NewNotificationServiceHandler(notifSvc, stdOpts...)
		register(path, h)
	}
	{
		bitdriveSvc := api_bitdrive.New(rt.db, rt.bitdriveEngine)
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
		walletPsbtSvc := api_walletpsbt.New(rt.db)
		path, h := walletpsbtv1connect.NewWalletPsbtServiceHandler(walletPsbtSvc, stdOpts...)
		register(path, h)
	}
	// Enforcer bridge — single impl serves three separate services
	enforcerSvc := api_enforcer.New(s.Enforcer, s.Crypto, s.BlockProducer, s.Mining, rt.walletEngine)
	{
		path, h := validatorrpc.NewValidatorServiceHandler(enforcerSvc, stdOpts...)
		register(path, h)
	}
	{
		path, h := cryptorpc.NewCryptoServiceHandler(enforcerSvc, stdOpts...)
		register(path, h)
	}
	{
		path, h := validatorrpc.NewBlockProducerServiceHandler(enforcerSvc, stdOpts...)
		register(path, h)
	}
	{
		path, h := validatorrpc.NewMiningServiceHandler(enforcerSvc, stdOpts...)
		register(path, h)
	}
	rt.mux.Handle("/enforcer/jsonrpc", localauth.Middleware(s.svcs.BitwindowDir, enforcerproxy.JSONRPC(s.svcs.EnforcerJSONRPCAddr)))

	// gRPC reflection. Each runtime mux gets its own reflector so listing
	// stays accurate after a recycle (set is identical across runtimes,
	// but rt-local for clarity).
	reflector := grpcreflect.NewStaticReflector(rt.services...)
	rt.mux.Handle(grpcreflect.NewHandlerV1(reflector))
	rt.mux.Handle(grpcreflect.NewHandlerV1Alpha(reflector))

	return rt, nil
}

// Start forks rt's engine context from parent and launches goroutines.
func (rt *Runtime) Start(parent context.Context) {
	rt.ctx, rt.cancel = context.WithCancel(parent)
	log := zerolog.Ctx(parent)

	// ChequeEngine spawns its own goroutines; track them in rt.wg so
	// runtime shutdown blocks until they drain. Otherwise an in-flight
	// bitcoind mock call can race the gomock controller's Finish (called
	// after rt.Close) and panic with "Fail in goroutine after Test
	// completed".
	chequeDone := rt.chequeEngine.Start(rt.ctx)
	rt.wg.Add(1)
	go func() {
		defer rt.wg.Done()
		<-chequeDone
	}()

	// Coin selection runs in drivechaind, and a restart of it drops the frozen
	// set. Hand the set over again while this runtime lives.
	rt.wg.Add(1)
	go func() {
		defer rt.wg.Done()
		rt.walletEngine.KeepFrozenCoins(rt.ctx)
	}()

	rt.runEngine("bitcoin", rt.bitcoinEngine.Run, log)
	rt.runEngine("deniability", rt.deniabilityEngine.Run, log)
	rt.runEngine("mempool-watch", rt.mempoolWatcher.Run, log)
	rt.runEngine("timestamp", rt.timestampEngine.Run, log)
	rt.runEngine("notification", rt.notificationEngine.Run, log)
	rt.runEngine("sidechain-monitor", rt.sidechainMonitor.Run, log)
	rt.runEngine("deposit-dropped", rt.depositDropped.Run, log)
	rt.runEngine("address-sync", rt.walletSvc.Run, log)

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

	const (
		minBackoff = 5 * time.Second
		maxBackoff = time.Minute
	)
	backoff := minBackoff
	for {
		// Light mode runs no local Bitcoin Core, so no ZMQ endpoint exists.
		if !rt.walletEngine.NodeMode().RunsLocalNode(ctx) {
			backoff = minBackoff
		} else {
			zmqEngine, err := dialZmqEngine(ctx, rt.conf)
			switch {
			case err == nil:
				backoff = minBackoff
				err = rt.feedZMQ(ctx, zmqEngine, log)
				if ctx.Err() != nil {
					return
				}
				log.Warn().Err(err).Msg("ZMQ engine stopped, retrying")
			case connect.CodeOf(err) == connect.CodeUnavailable || isBitcoinCoreStartupError(err.Error()):
				log.Debug().Msg("ZMQ engine: waiting for Bitcoin Core connection")
			default:
				log.Error().Err(err).Msg("acquire ZMQ engine")
			}
		}

		select {
		case <-ctx.Done():
			return
		case <-time.After(backoff):
		}
		backoff = min(2*backoff, maxBackoff)
	}
}

// feedZMQ feeds each raw tx into bitcoinEngine until the ZMQ engine stops.
func (rt *Runtime) feedZMQ(ctx context.Context, zmqEngine *engines.ZMQ, log *zerolog.Logger) error {
	txs := zmqEngine.Subscribe()
	rt.wg.Add(1)
	go func() {
		defer rt.wg.Done()
		for tx := range txs {
			if err := rt.bitcoinEngine.HandleNewRawTransaction(ctx, tx); err != nil {
				log.Error().Err(err).Msgf("handle new raw transaction: %s", tx.TxHash())
			}
		}
	}()

	log.Info().Msg("starting ZMQ engine")
	return zmqEngine.Run(ctx)
}

func dialZmqEngine(ctx context.Context, conf config.Config) (*engines.ZMQ, error) {
	addr, err := zmqAddress(ctx, conf, "pubrawtx")
	if err != nil {
		return nil, err
	}
	return engines.NewZMQ(addr)
}

// coreRawCall routes raw bitcoind RPCs through the orchestrator.
func coreRawCall(s *Server) engines.RawCall {
	client := dial.Orchestrator(s.svcs.OrchestratorAddr, s.svcs.BitwindowDir)
	return func(ctx context.Context, method string, params ...any) (json.RawMessage, error) {
		paramsJSON, err := json.Marshal(params)
		if err != nil {
			return nil, err
		}
		resp, err := client.CoreRawCall(ctx, connect.NewRequest(&orchctlpb.CoreRawCallRequest{
			Method:     method,
			ParamsJson: string(paramsJSON),
		}))
		if err != nil {
			return nil, err
		}
		return json.RawMessage(resp.Msg.ResultJson), nil
	}
}

// zmqAddress looks up the endpoint bitcoind publishes notifType on.
func zmqAddress(ctx context.Context, conf config.Config, notifType string) (string, error) {
	btc, err := dial.Bitcoind(ctx, conf.OrchestratorAddr)
	if err != nil {
		return "", fmt.Errorf("dial orchestrator bitcoin service: %w", err)
	}
	notifs, err := btc.GetZmqNotifications(ctx, connect.NewRequest(&emptypb.Empty{}))
	if err != nil {
		return "", fmt.Errorf("get zmq notifications: %w", err)
	}
	notif, found := lo.Find(notifs.Msg.Notifications,
		func(n *corepb.GetZmqNotificationsResponse_Notification) bool {
			return n.Type == notifType
		},
	)
	if !found {
		return "", fmt.Errorf("bitcoind does not publish %s ZMQ notifications", notifType)
	}
	return notif.Address, nil
}

// Handler wraps the runtime mux so in-flight requests are tracked in
// rt.inflight; Close drains them before closing the DB.
func (rt *Runtime) Handler() http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		rt.inflight.Add(1)
		defer rt.inflight.Done()
		rt.mux.ServeHTTP(w, r)
	})
}

// Close cancels engines, waits for goroutines, drains in-flight request
// handlers, then closes the DB. Safe to call once. Subsequent calls are no-ops.
func (rt *Runtime) Close() {
	if rt.cancel != nil {
		rt.cancel()
	}
	rt.wg.Wait()

	// Wait for in-flight handlers so none queries the DB after it closes.
	// Bounded so a hung handler can't block teardown forever.
	drained := make(chan struct{})
	go func() {
		rt.inflight.Wait()
		close(drained)
	}()
	select {
	case <-drained:
	case <-time.After(10 * time.Second):
	}

	log := zerolog.Ctx(rt.ctx)
	if err := rt.db.Close(); err != nil {
		log.Warn().Err(err).Str("datadir", rt.conf.Datadir).Msg("close runtime: close the database")
	}
	if rt.coinnewsLog != nil {
		if err := rt.coinnewsLog.Close(); err != nil {
			log.Warn().Err(err).Str("path", rt.coinnewsLog.Name()).Msg("close runtime: close the coinnews log")
		}
	}
}

func chainParamsFor(network config.Network) *chaincfg.Params {
	switch network {
	case config.NetworkMainnet, config.NetworkECash:
		return &chaincfg.MainNetParams
	case config.NetworkTestnet:
		return &chaincfg.TestNet3Params
	case config.NetworkSignet:
		return &chaincfg.SigNetParams
	case config.NetworkRegtest:
		return &chaincfg.RegressionNetParams
	}
	// These params name the coin every address and key path takes, so a guess
	// here is a wrong address, not a small mistake.
	panic(fmt.Sprintf("unknown network %q", network))
}

// activeSidechainSlots names the slots that hold a sidechain. The deposit
// watch reads deposits per slot, and every slot the enforcer omits holds none.
func activeSidechainSlots(ctx context.Context, enforcer *service.Service[validatorrpc.ValidatorServiceClient]) ([]uint32, error) {
	client, err := enforcer.Get(ctx)
	if err != nil {
		return nil, err
	}
	resp, err := client.GetSidechains(ctx, connect.NewRequest(&validatorpb.GetSidechainsRequest{}))
	if err != nil {
		return nil, fmt.Errorf("get sidechains: %w", err)
	}
	slots := make([]uint32, 0, len(resp.Msg.GetSidechains()))
	for _, sc := range resp.Msg.GetSidechains() {
		slots = append(slots, sc.GetSidechainNumber().GetValue())
	}
	return slots, nil
}
