package main

import (
	"context"
	"crypto/tls"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"os"
	"os/signal"
	"sync/atomic"
	"syscall"
	"time"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"
	"github.com/urfave/cli/v2"
	"golang.org/x/net/http2"

	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	coreproxy "github.com/barebitcoin/btc-buf/server"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/api"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/enforcerproxy"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/engines"
	bitassetsrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bitassets/v1/bitassetsv1connect"
	bitnamesrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bitnames/v1/bitnamesv1connect"
	coinshiftrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/coinshift/v1/coinshiftv1connect"
	cryptorpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/crypto/v1/cryptov1connect"
	enforcerrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	photonrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/photon/v1/photonv1connect"
	thunderrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/thunder/v1/thunderv1connect"
	truthcoinrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/truthcoin/v1/truthcoinv1connect"
	walletrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	zsiderpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/zside/v1/zsidev1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/localauth"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/rpcmeter"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	bitassetssvc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bitassets"
	bitnamessvc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bitnames"
	coinshiftsvc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/coinshift"
	photonsvc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/photon"
	thundersvc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/thunder"
	truthcoinsvc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/truthcoin"
	zsidesvc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/zside"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet/bip47send"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet/bip47state"
)

func main() {
	app := &cli.App{
		Name:  "orchestratord",
		Usage: "Sidechain orchestrator daemon",
		Flags: []cli.Flag{
			&cli.StringFlag{
				Name:    "datadir",
				Usage:   "data directory",
				Value:   orchestrator.DefaultDataDir(),
				EnvVars: []string{"ORCHESTRATOR_DATADIR"},
			},
			&cli.StringFlag{
				Name:    "network",
				Usage:   "bitcoin network (mainnet, testnet, signet, regtest)",
				Value:   "signet",
				EnvVars: []string{"ORCHESTRATOR_NETWORK"},
			},
			&cli.StringFlag{
				Name:    "rpclisten",
				Usage:   "gRPC listen address",
				Value:   "localhost:30400",
				EnvVars: []string{"ORCHESTRATOR_RPCLISTEN"},
			},
			&cli.StringFlag{
				Name:    "loglevel",
				Usage:   "log level (debug, info, warn, error)",
				Value:   "info",
				EnvVars: []string{"ORCHESTRATOR_LOGLEVEL"},
			},
			&cli.StringFlag{
				Name:    "bitwindow-dir",
				Usage:   "path to bitwindow data directory",
				Value:   orchestrator.DefaultBitwindowDir(),
				EnvVars: []string{"ORCHESTRATOR_BITWINDOW_DIR"},
			},
			&cli.BoolFlag{
				Name:    "local-auth",
				Usage:   "write a per-session cookie token to <bitwindow-dir>/.auth.cookie and require it on every RPC (bitcoind-style local auth)",
				Value:   true,
				EnvVars: []string{"ORCHESTRATOR_LOCAL_AUTH"},
			},
			&cli.StringSliceFlag{
				Name:    "binary",
				Usage:   "sidechain binary to start with deps on boot (can be repeated, e.g. --binary=thunder --binary=bitnames)",
				EnvVars: []string{"ORCHESTRATOR_BINARY"},
			},
			&cli.BoolFlag{
				Name:    "force-backend",
				Usage:   "bypass UseTestSidechains for the --binary auto-boots; always launch the prod download",
				EnvVars: []string{"ORCHESTRATOR_FORCE_BACKEND"},
			},
			&cli.StringFlag{
				Name:    "logfile",
				Usage:   "append logs to this file instead of stdout (used when bitwindowd spawns us detached and our stdout has no reader)",
				EnvVars: []string{"ORCHESTRATOR_LOGFILE"},
			},
		},
		Action: run,
	}

	if err := app.Run(os.Args); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
}

func run(cctx *cli.Context) error {
	ctx, cancel := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer cancel()

	// Set up logging
	level, err := zerolog.ParseLevel(cctx.String("loglevel"))
	if err != nil {
		level = zerolog.InfoLevel
	}
	var logOut io.Writer = zerolog.ConsoleWriter{Out: os.Stdout}
	if logPath := cctx.String("logfile"); logPath != "" {
		// O_APPEND so multiple processes (e.g. an old instance still draining
		// and a new instance probing the port) don't truncate each other.
		f, err := os.OpenFile(logPath, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0o644)
		if err != nil {
			fmt.Fprintf(os.Stderr, "open --logfile %q: %v\n", logPath, err)
			os.Exit(1)
		}
		defer f.Close() //nolint:errcheck
		logOut = zerolog.ConsoleWriter{Out: f, NoColor: true}
	}
	log := zerolog.New(logOut).
		Level(level).
		With().
		Timestamp().
		Logger()

	dataDir := cctx.String("datadir")
	network := cctx.String("network")
	listenAddr := cctx.String("rpclisten")
	bitwindowDir := cctx.String("bitwindow-dir")
	localAuth := cctx.Bool("local-auth")

	log.Info().
		Str("datadir", dataDir).
		Str("network", network).
		Str("rpclisten", listenAddr).
		Msg("starting orchestratord")

	// Single-instance check. With local auth enabled, adopting an existing
	// listener would require sending it the bearer cookie; a port-squatter could
	// harvest that token. Fail closed instead.
	if conn, dialErr := net.DialTimeout("tcp", listenAddr, 200*time.Millisecond); dialErr == nil {
		_ = conn.Close()
		if localAuth {
			return fmt.Errorf("RPC address %s is already in use; refusing to adopt an existing listener while local auth is enabled", listenAddr)
		}
		log.Info().Str("addr", listenAddr).Msg("orchestratord already running on this port; exiting (will be adopted by caller)")
		return nil
	}

	// Load binary configs from JSON (in bitwindow dir), falling back to hardcoded defaults
	configPath := orchestrator.ConfigFilePath(bitwindowDir)
	configs := orchestrator.LoadConfigFile(configPath, log)
	orch := orchestrator.New(dataDir, network, bitwindowDir, configs, log)

	// Local RPC auth (bitcoind-style cookie). When enabled, a fresh token is
	// written once this process owns the listener (see WriteCookie below) — it
	// overwrites any stale one, so we never delete the cookie out from under a
	// client. When disabled, drop any leftover cookie so nothing presents it.
	// authIC is added to every handler below, so all endpoints are authed
	// uniformly.
	authIC := localauth.Interceptor("")
	authDir := ""
	if localAuth {
		authIC = localauth.Interceptor(bitwindowDir)
		authDir = bitwindowDir
	} else if err := localauth.RemoveCookie(bitwindowDir); err != nil {
		log.Warn().Err(err).Msg("could not clear stale local auth cookie")
	}

	// Watch config file for changes
	stopWatch, err := orchestrator.WatchConfigFile(configPath, func(newConfigs []orchestrator.BinaryConfig) {
		orch.UpdateConfigs(newConfigs)
	}, log)
	if err != nil {
		log.Warn().Err(err).Msg("failed to watch config file")
	} else {
		defer stopWatch()
	}

	// Initialize wallet service
	walletSvc := wallet.NewService(bitwindowDir, log)
	walletSvc.OnStopAllBinaries = func() error {
		shutdownCtx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
		defer cancel()

		ch, err := orch.ShutdownAll(shutdownCtx, false)
		if err != nil {
			return err
		}

		for progress := range ch {
			if progress.Error != nil {
				return progress.Error
			}
		}

		return nil
	}
	walletSvc.GetBinaryWalletPaths = orch.BinaryWalletPaths
	if orch.BitcoinConf != nil {
		walletSvc.CoreDataDir = config.BitcoinCoreDirs.RootDirNetwork(orch.BitcoinConf.Network)
	}
	if err := walletSvc.Init(); err != nil {
		log.Warn().Err(err).Msg("wallet service init")
	}
	defer walletSvc.Close()
	orch.WalletSvc = walletSvc

	// Adopt orphaned processes from previous session
	if err := orch.AdoptOrphans(ctx); err != nil {
		log.Warn().Err(err).Msg("adopt orphans")
	}

	// Set up gRPC/ConnectRPC server
	handler := api.NewHandler(orch)
	mux := http.NewServeMux()
	if localAuth {
		// Allows a relaunched bitwindowd to verify that an occupied RPC port is
		// the previous orchestratord without sending the bearer cookie to an
		// arbitrary listener.
		mux.HandleFunc("/local-auth/challenge", func(w http.ResponseWriter, r *http.Request) {
			if r.Method != http.MethodGet {
				http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
				return
			}
			nonce := r.URL.Query().Get("nonce")
			if nonce == "" || len(nonce) > 256 {
				http.Error(w, "invalid nonce", http.StatusBadRequest)
				return
			}
			token, err := localauth.ReadCookie(bitwindowDir)
			if err != nil {
				http.Error(w, "read auth cookie", http.StatusInternalServerError)
				return
			}
			if token == "" {
				http.Error(w, "auth cookie missing", http.StatusServiceUnavailable)
				return
			}
			_, _ = io.WriteString(w, localauth.ChallengeResponse(token, nonce))
		})
	}

	path, h := rpc.NewOrchestratorServiceHandler(handler, connect.WithInterceptors(authIC))
	mux.Handle(path, h)

	// Wallet manager service
	walletHandler := api.NewWalletHandler(walletSvc)
	walletHandler.SetOrchestrator(orch)
	walletHandler.SetBip47StateStore(bip47state.NewStore(bitwindowDir))

	netParams, perr := bip47send.NetworkParams(network)
	if perr != nil {
		log.Warn().Err(perr).Str("network", network).Msg("unrecognised network; BIP47 features will be disabled")
	}

	// Chain wallet provider — CoreProvider today; electrum/btcd providers
	// slot in behind the same wallet.Provider interface.
	var chainProvider wallet.Provider
	if orch.BitcoinConf != nil {
		port := orch.BitcoinConf.GetRPCPort()
		var user, password string
		if orch.BitcoinConf.Config != nil {
			section := orch.BitcoinConf.Network.CoreSection()
			user = orch.BitcoinConf.Config.GetEffectiveSetting("rpcuser", section)
			password = orch.BitcoinConf.Config.GetEffectiveSetting("rpcpassword", section)
		}
		coreRPC := wallet.NewCoreRPCClient(orch.BitcoinConf.GetRPCHost(), port, user, password)
		chainProvider = wallet.NewCoreProvider(walletSvc, coreRPC, netParams, log)
		log.Info().Int("rpc_port", port).Msg("core wallet provider initialized")
	}

	// Enforcer wallet provider — relays the enforcer-type wallet to the
	// enforcer daemon's wallet service.
	var enforcerProvider wallet.Provider
	if enforcerCfg, ok := orch.Configs()["enforcer"]; ok {
		httpClient := &http.Client{
			Transport: &http2.Transport{
				AllowHTTP: true,
				DialTLSContext: func(ctx context.Context, network, addr string, _ *tls.Config) (net.Conn, error) {
					var d net.Dialer
					return d.DialContext(ctx, network, addr)
				},
			},
		}
		enforcerClient := enforcerrpc.NewWalletServiceClient(httpClient, enforcerCfg.RPCURL(), connect.WithGRPC())
		enforcerProvider = wallet.NewEnforcerProvider(enforcerClient)
		orch.SetForkEnforcerWallet(enforcerClient)
		log.Info().Int("enforcer_port", enforcerCfg.Port).Msg("enforcer wallet provider registered")

		// Enforcer passthrough: sidechain apps funnel all enforcer traffic
		// through orchestratord instead of dialing the enforcer directly.
		enforcerBridge, err := enforcerproxy.Connect(enforcerCfg.RPCURL())
		if err != nil {
			return fmt.Errorf("enforcer bridge: %w", err)
		}
		for _, svc := range []string{
			enforcerrpc.ValidatorServiceName,
			enforcerrpc.WalletServiceName,
			cryptorpc.CryptoServiceName,
		} {
			mux.Handle("/"+svc+"/", localauth.Middleware(authDir, enforcerBridge))
		}
		mux.Handle("/enforcer/jsonrpc", localauth.Middleware(authDir, enforcerproxy.JSONRPC(enforcerproxy.DefaultJSONRPCAddr)))
	}

	// Electrum wallet provider — derives BIP84 keys locally and reads/broadcasts
	// chain state over the Esplora REST API. No local Core/enforcer needed.
	var electrumProvider wallet.Provider
	if esploraURL := config.EsploraURLForNetwork(config.NetworkFromString(network)); esploraURL != "" && netParams != nil {
		electrumProvider = wallet.NewElectrumProvider(walletSvc, wallet.NewEsploraClient(esploraURL), netParams, log)
		log.Info().Str("esplora_url", esploraURL).Msg("electrum wallet provider initialized")
	}

	router := wallet.NewRoutingProvider(walletSvc, enforcerProvider, chainProvider, electrumProvider)
	walletEngine := wallet.NewWalletEngine(walletSvc, router, netParams, log)
	walletHandler.SetEngine(walletEngine)

	if chainProvider != nil {
		// Fork engine: single source of truth for eCash fork state, needs
		// Core-backed wallet access for its claimable scan.
		orch.InitForkEngine(walletEngine)

		// BIP47 receive engine: watches each Core wallet's notification address
		// for incoming notification txs, decodes their OP_RETURN payload to
		// recover the sender's payment code, and imports per-payment receive
		// descriptors so subsequent payments are spendable.
		bip47InboundStore := bip47state.NewInboundStore(bitwindowDir)
		bip47Engine := engines.NewBIP47Engine(log, walletSvc, walletEngine, bip47InboundStore)
		go func() {
			if err := bip47Engine.Run(ctx); err != nil && !errors.Is(err, context.Canceled) {
				log.Error().Err(err).Msg("bip47 engine exited")
			}
		}()
	}

	walletPath, walletH := walletrpc.NewWalletManagerServiceHandler(walletHandler, connect.WithInterceptors(authIC))
	mux.Handle(walletPath, walletH)

	// Bitcoin config service
	if orch.BitcoinConf != nil {
		confHandler := api.NewBitcoinConfHandler(orch)
		confPath, confH := rpc.NewBitcoinConfServiceHandler(confHandler, connect.WithInterceptors(authIC))
		mux.Handle(confPath, confH)
	}

	// Bitcoin Core proxy (btc-buf BitcoinService) — single canonical route
	// to bitcoind. Behind a swappable shim so a network swap can rebuild
	// the underlying proxy with fresh creds without re-registering the mux
	// path or restarting the orchestrator. OnNetworkChanged fires after
	// SwapNetwork persists the new config.
	if orch.BitcoinConf != nil {
		// Meter every call through the proxy so we can see which bitcoind RPCs
		// the frontend actually issues and how slow each is. authIC stays
		// outermost (auth before metering); meterIC times only the post-auth
		// handler. Logs a per-method summary every coreMeterInterval.
		const coreMeterInterval = 30 * time.Second
		meterIC := rpcmeter.New(ctx, log, coreMeterInterval).Interceptor()

		swappable := newSwappableHandler()
		if proxy, err := startCoreProxy(ctx, orch, log); err != nil {
			log.Warn().Err(err).Msg("failed to start bitcoin core proxy")
		} else {
			_, coreH := corerpc.NewBitcoinServiceHandler(proxy, connect.WithInterceptors(authIC, meterIC))
			swappable.swap(coreH)
		}
		// The path is constant; register once.
		corePath, _ := corerpc.NewBitcoinServiceHandler(noopBitcoinService{}, connect.WithInterceptors(authIC, meterIC))
		mux.Handle(corePath, swappable)
		log.Info().Str("service", "bitcoin.bitcoind.v1alpha.BitcoinService").Msg("registered bitcoin core proxy")

		orch.BitcoinConf.OnNetworkChanged = func() {
			rebuilt, err := startCoreProxy(ctx, orch, log)
			if err != nil {
				log.Error().Err(err).Msg("rebuild bitcoin core proxy after network swap")
				return
			}
			_, h := corerpc.NewBitcoinServiceHandler(rebuilt, connect.WithInterceptors(authIC, meterIC))
			swappable.swap(h)
			log.Info().Str("network", string(orch.BitcoinConf.Network)).Msg("rebuilt bitcoin core proxy for new network")
		}
	}

	// Enforcer config service
	if orch.EnforcerConf != nil {
		enforcerHandler := api.NewEnforcerConfHandler(orch.EnforcerConf)
		enforcerPath, enforcerH := rpc.NewEnforcerConfServiceHandler(enforcerHandler, connect.WithInterceptors(authIC))
		mux.Handle(enforcerPath, enforcerH)
	}

	// Generic sidechain config service (all sidechains)
	sidechainConfHandler := api.NewSidechainConfHandler(orch.SidechainConfs)
	scConfPath, scConfH := rpc.NewSidechainConfServiceHandler(sidechainConfHandler, connect.WithInterceptors(authIC))
	mux.Handle(scConfPath, scConfH)

	// Per-sidechain typed RPC services (proxy to sidechain binary JSON-RPC)
	for name, cfg := range orch.Configs() {
		proxy := sidechain.NewJSONRPCProxy(cfg.RPCHost(), cfg.Port)
		switch name {
		case "thunder":
			h := thundersvc.NewHandler(proxy)
			path, handler := thunderrpc.NewThunderServiceHandler(h, connect.WithInterceptors(authIC))
			mux.Handle(path, handler)
			log.Info().Str("sidechain", name).Int("port", cfg.Port).Msg("registered sidechain RPC service")
		case "bitnames":
			h := bitnamessvc.NewHandler(proxy)
			path, handler := bitnamesrpc.NewBitnamesServiceHandler(h, connect.WithInterceptors(authIC))
			mux.Handle(path, handler)
			log.Info().Str("sidechain", name).Int("port", cfg.Port).Msg("registered sidechain RPC service")
		case "bitassets":
			h := bitassetssvc.NewHandler(proxy)
			path, handler := bitassetsrpc.NewBitAssetsServiceHandler(h, connect.WithInterceptors(authIC))
			mux.Handle(path, handler)
			log.Info().Str("sidechain", name).Int("port", cfg.Port).Msg("registered sidechain RPC service")
		case "photon":
			h := photonsvc.NewHandler(proxy)
			path, handler := photonrpc.NewPhotonServiceHandler(h, connect.WithInterceptors(authIC))
			mux.Handle(path, handler)
			log.Info().Str("sidechain", name).Int("port", cfg.Port).Msg("registered sidechain RPC service")
		case "truthcoin":
			h := truthcoinsvc.NewHandler(proxy)
			path, handler := truthcoinrpc.NewTruthcoinServiceHandler(h, connect.WithInterceptors(authIC))
			mux.Handle(path, handler)
			log.Info().Str("sidechain", name).Int("port", cfg.Port).Msg("registered sidechain RPC service")
		case "coinshift":
			h := coinshiftsvc.NewHandler(proxy)
			path, handler := coinshiftrpc.NewCoinShiftServiceHandler(h, connect.WithInterceptors(authIC))
			mux.Handle(path, handler)
			log.Info().Str("sidechain", name).Int("port", cfg.Port).Msg("registered sidechain RPC service")
		case "zside":
			h := zsidesvc.NewHandler(proxy)
			path, handler := zsiderpc.NewZSideServiceHandler(h, connect.WithInterceptors(authIC))
			mux.Handle(path, handler)
			log.Info().Str("sidechain", name).Int("port", cfg.Port).Msg("registered sidechain RPC service")
		}
	}

	// h2c (HTTP/2 cleartext) via http.Server.Protocols — the ConnectRPC-blessed
	// replacement for h2c.NewHandler. Carries Connect, gRPC and gRPC-Web on one
	// listener. SendPingTimeout preserves the old http2.Server.ReadIdleTimeout
	// behavior: ping every 30s of idle to evict dead connections.
	protocols := new(http.Protocols)
	protocols.SetHTTP1(true)
	protocols.SetUnencryptedHTTP2(true)
	srv := &http.Server{
		Handler:   mux,
		Protocols: protocols,
		HTTP2:     &http.HTTP2Config{SendPingTimeout: 30 * time.Second},
	}

	// Bind listener first so we know the port is ours before logging.
	lis, err := net.Listen("tcp", listenAddr)
	if err != nil {
		return fmt.Errorf("listen %s: %w", listenAddr, err)
	}
	if localAuth {
		if _, err := localauth.WriteCookie(bitwindowDir); err != nil {
			_ = lis.Close()
			return fmt.Errorf("write local auth cookie: %w", err)
		}
		log.Info().Str("cookie", localauth.CookiePath(bitwindowDir)).Msg("local RPC auth enabled")
	}
	log.Info().Str("addr", lis.Addr().String()).Msg("serving gRPC")

	errs := make(chan error, 1)
	go func() {
		if err := srv.Serve(lis); err != nil && err != http.ErrServerClosed {
			errs <- fmt.Errorf("serve: %w", err)
		}
	}()

	// Auto-boot sidechains specified via --binary flags
	binariesToBoot := cctx.StringSlice("binary")
	forceBackend := cctx.Bool("force-backend")
	for _, name := range binariesToBoot {
		go func(target string) {
			log.Info().Str("binary", target).Bool("force_backend", forceBackend).Msg("auto-booting sidechain with deps")
			ch, err := orch.StartWithL1(ctx, target, orchestrator.StartOpts{
				TargetArgs:   []string{"--headless"},
				ForceBackend: forceBackend,
			})
			if err != nil {
				log.Error().Err(err).Str("binary", target).Msg("failed to start sidechain")
				return
			}
			for p := range ch {
				if p.Done {
					log.Info().Str("binary", target).Msg("sidechain startup complete")
					break
				}
				if p.Error != nil {
					log.Error().Err(p.Error).Str("binary", target).Msg("sidechain startup error")
					break
				}
			}
		}(name)
	}

	// Wait for shutdown signal or error
	select {
	case <-ctx.Done():
		log.Info().Msg("received shutdown signal")
	case err := <-errs:
		log.Error().Err(err).Msg("server error")
		cancel()
	}

	// Route signal-driven shutdown through the same state machine the
	// Shutdown RPC uses. BeginShutdown spawns a goroutine that drains
	// children and then os.Exit(0)s — AwaitShutdownIdle blocks until the
	// drain finishes; os.Exit usually fires before this returns. The final
	// os.Exit is belt-and-suspenders for the "somehow we became KEEP" case.
	log.Info().Msg("shutting down managed binaries...")
	orch.BeginShutdown()
	_ = orch.AwaitShutdownIdle(context.Background())
	os.Exit(0)

	log.Info().Msg("orchestratord shutdown complete")
	return nil
}

// swappableHandler holds an http.Handler atomically so the registered
// /bitcoin.bitcoind.v1alpha.BitcoinService/ path can swap its dispatch
// target on network change without re-registering the mux.
type swappableHandler struct {
	inner atomic.Pointer[http.Handler]
}

func newSwappableHandler() *swappableHandler {
	return &swappableHandler{}
}

func (s *swappableHandler) swap(h http.Handler) {
	s.inner.Store(&h)
}

func (s *swappableHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	cur := s.inner.Load()
	if cur == nil {
		http.Error(w, "bitcoin service not ready", http.StatusServiceUnavailable)
		return
	}
	(*cur).ServeHTTP(w, r)
}

// noopBitcoinService satisfies the BitcoinServiceHandler interface for the
// sole purpose of asking corerpc.NewBitcoinServiceHandler what mux path to
// register under. The returned handler is discarded — only the path is used.
type noopBitcoinService struct {
	corerpc.UnimplementedBitcoinServiceHandler
}

// startCoreProxy initializes the btc-buf BitcoinService proxy against the
// bitcoind managed by this orchestrator. The proxy survives a not-yet-running
// bitcoind via WithoutInitialConnectionCheck — btc-buf's rpcclient reconnects
// once Core comes up.
func startCoreProxy(ctx context.Context, orch *orchestrator.Orchestrator, log zerolog.Logger) (*coreproxy.Bitcoind, error) {
	port := orch.BitcoinConf.GetRPCPort()
	var user, password string
	if orch.BitcoinConf.Config != nil {
		section := orch.BitcoinConf.Network.CoreSection()
		user = orch.BitcoinConf.Config.GetEffectiveSetting("rpcuser", section)
		password = orch.BitcoinConf.Config.GetEffectiveSetting("rpcpassword", section)
	}

	host := fmt.Sprintf("%s:%d", orch.BitcoinConf.GetRPCHost(), port)
	log.Info().Str("host", host).Str("user", user).Msg("starting Bitcoin Core proxy")

	// Quiet the proxy's connection logs — its rpcclient retries on a tight
	// loop while bitcoind is starting and floods stdout otherwise.
	proxyLog := log.Level(zerolog.WarnLevel)
	initCtx := proxyLog.WithContext(ctx)

	return coreproxy.NewBitcoind(
		initCtx, host, user, password,
		coreproxy.WithLogging(func(_ context.Context) *zerolog.Logger { return &proxyLog }),
		coreproxy.WithoutInitialConnectionCheck(),
	)
}
