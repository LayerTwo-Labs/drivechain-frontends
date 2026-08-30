package main

import (
	"context"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"os"
	"os/signal"
	"path/filepath"
	"sync"
	"sync/atomic"
	"syscall"
	"time"

	"connectrpc.com/connect"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/urfave/cli/v2"

	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	coreproxy "github.com/barebitcoin/btc-buf/server"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/api"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/enforcerproxy"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/engines"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/engines/bmmstate"
	bbcrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bbc/v1/bbcv1connect"
	bitassetsrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bitassets/v1/bitassetsv1connect"
	bitnamesrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bitnames/v1/bitnamesv1connect"
	bmmrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bmm/v1/bmmv1connect"
	coinshiftrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/coinshift/v1/coinshiftv1connect"
	cryptorpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/crypto/v1/cryptov1connect"
	enforcerrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
	multisigloungerpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/multisiglounge/v1/multisigloungev1connect"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	photonrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/photon/v1/photonv1connect"
	thunderrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/thunder/v1/thunderv1connect"
	truthcoinrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/truthcoin/v1/truthcoinv1connect"
	walletrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	zsiderpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/zside/v1/zsidev1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/lease"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/localauth"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/logfile"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/rpcmeter"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	bbcsvc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bbc"
	bitassetssvc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bitassets"
	bitnamessvc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bitnames"
	coinshiftsvc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/coinshift"
	photonsvc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/photon"
	thundersvc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/thunder"
	truthcoinsvc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/truthcoin"
	zsidesvc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/zside"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet/bip47state"
)

// version is the release this binary comes from. The release build sets it with
// -ldflags "-X main.version=...".
var version = "dev"

func main() {
	app := &cli.App{
		Name:    "drivechaind",
		Usage:   "Sidechain orchestrator daemon",
		Version: version,
		Flags: []cli.Flag{
			&cli.StringFlag{
				Name:    "datadir",
				Usage:   "data directory",
				Value:   orchestrator.DefaultDataDir(),
				EnvVars: []string{"ORCHESTRATOR_DATADIR"},
			},
			&cli.StringFlag{
				Name:    "network",
				Usage:   "bitcoin network (mainnet, testnet, signet, regtest, forknet, ecash)",
				Value:   config.DefaultNetwork,
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
			&cli.StringFlag{
				Name:    "app-home",
				Usage:   "home directory every binary's data directory resolves against (default: the user's home)",
				EnvVars: []string{"ORCHESTRATOR_APP_HOME"},
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
				Usage:   "launch the prod download for the --binary auto-boots instead of the frontend build",
				EnvVars: []string{"ORCHESTRATOR_FORCE_BACKEND"},
			},
			&cli.StringFlag{
				Name:    "logfile",
				Usage:   "append logs to this file instead of stdout (used when bitwindowd spawns us detached and our stdout has no reader)",
				EnvVars: []string{"ORCHESTRATOR_LOGFILE"},
			},
			&cli.IntFlag{
				Name:    "owner-pid",
				Usage:   "shut down once this process exits (the frontend that owns us)",
				EnvVars: []string{"ORCHESTRATOR_OWNER_PID"},
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
	// Millisecond timestamps: startup is a sequence of sub-second steps, and
	// the default minute granularity makes it impossible to see which one is slow.
	var logOut io.Writer = zerolog.ConsoleWriter{Out: os.Stdout, TimeFormat: "15:04:05.000"}
	if logPath := cctx.String("logfile"); logPath != "" {
		// O_APPEND so multiple processes (e.g. an old instance still draining
		// and a new instance probing the port) don't truncate each other.
		f, err := os.OpenFile(logPath, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0o644)
		if err != nil {
			fmt.Fprintf(os.Stderr, "open --logfile %q: %v\n", logPath, err)
			os.Exit(1)
		}
		defer f.Close() //nolint:errcheck
		logOut = zerolog.ConsoleWriter{Out: logfile.Tag(f, "orchestrator"), NoColor: true, TimeFormat: "15:04:05.000"}
	}
	log := zerolog.New(logOut).
		Level(level).
		With().
		Timestamp().
		Logger()

	// Absolute up front: we launch children with cmd.Dir set elsewhere, so a
	// relative path here would re-resolve against the wrong directory.
	dataDir, err := filepath.Abs(cctx.String("datadir"))
	if err != nil {
		return fmt.Errorf("resolve --datadir: %w", err)
	}
	network := cctx.String("network")
	listenAddr := cctx.String("rpclisten")
	bitwindowDir, err := filepath.Abs(cctx.String("bitwindow-dir"))
	if err != nil {
		return fmt.Errorf("resolve --bitwindow-dir: %w", err)
	}
	localAuth := cctx.Bool("local-auth")

	if appHome := cctx.String("app-home"); appHome != "" {
		config.SetHomeDir(appHome)
		log.Info().Str("app_home", appHome).Msg("binary paths resolve against app-home")
	}

	log.Info().
		Str("datadir", dataDir).
		Str("network", network).
		Str("rpclisten", listenAddr).
		Msg("starting drivechaind")

	if err := wallet.SanityCheck(); err != nil {
		return fmt.Errorf("random source sanity check failed, refusing to start: %w", err)
	}

	// Single-instance check. With local auth enabled, adopting an existing
	// listener would require sending it the bearer cookie; a port-squatter could
	// harvest that token. Fail closed instead.
	if conn, dialErr := net.DialTimeout("tcp", listenAddr, 200*time.Millisecond); dialErr == nil {
		_ = conn.Close()
		if localAuth {
			return fmt.Errorf("RPC address %s is already in use; refusing to adopt an existing listener while local auth is enabled", listenAddr)
		}
		log.Info().Str("addr", listenAddr).Msg("drivechaind already running on this port; exiting (will be adopted by caller)")
		return nil
	}

	// Load binary configs from JSON (in bitwindow dir), falling back to hardcoded defaults
	configPath := orchestrator.ConfigFilePath(bitwindowDir)
	configs := orchestrator.LoadConfigFile(configPath, log)
	orch := orchestrator.New(dataDir, network, bitwindowDir, configs, log)

	// Whoever holds this owns the binaries in dataDir. The kernel frees it when
	// the holder dies, so a leftover from a crashed run is ours to stop.
	orch.ClaimOwnerLock(ctx, dataDir)

	orch.StartReleaseChecks(ctx)

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
	walletSvc.SetNetwork(orch.CurrentNetwork())
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

	// Strictly after AdoptOrphans: a eCash network rollover wipes chain
	// data, and it decides whether that is safe by asking whether bitcoind is
	// running. Before adoption the process manager is empty, so a Core still
	// alive from the previous session would look stopped and have its blocks
	// renamed out from under it. Still before the listener binds, so the
	// generation is settled before anything can be served.
	orch.ResolveNetworkCatalog(ctx)

	// A swap that died between the park and the conf write left this network's
	// state parked. Bring it back before anything opens the datadir.
	//
	// Fatal: the listener and the --binary auto-boot both start daemons, and a
	// daemon over an absent path builds fresh state that hides the real one.
	if err := orch.RestoreParkedSwapState(); err != nil {
		return fmt.Errorf("restore parked network-swap state: %w", err)
	}

	if err := orch.ApplyPendingEnforcerWipe(); err != nil {
		return fmt.Errorf("apply the enforcer cleanup a switch left behind: %w", err)
	}

	// Set up gRPC/ConnectRPC server
	handler := api.NewHandler(orch)
	mux := http.NewServeMux()
	if localAuth {
		// Allows a relaunched bitwindowd to verify that an occupied RPC port is
		// the previous drivechaind without sending the bearer cookie to an
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
	bip47SendStore := bip47state.NewStore(walletSvc.NetworkDir())
	walletHandler.SetBip47StateStore(bip47SendStore)

	multisigLoungeHandler := api.NewMultisigLoungeHandler()
	multisigLoungeHandler.SetService(walletSvc)
	multisigLoungeHandler.SetCoreCaller(handler.RawCoreCall)

	// bitwindow-bitcoin.conf wins over the --network flag, which drivechaind
	// is usually launched without.
	currentNetwork := func() string {
		if n := orch.CurrentNetwork(); n != "" {
			return n
		}
		return network
	}
	// Every key path, address and hardware request takes its coin from these
	// params. A guess reaches a device as the wrong coin, so an unknown network
	// stops the daemon here rather than deeper, one wrong answer at a time.
	if _, known := config.LookupNetwork(currentNetwork()); !known {
		return fmt.Errorf("unknown network %q", currentNetwork())
	}
	netParams := wallet.ParamsFunc(func() *chaincfg.Params {
		n, known := config.LookupNetwork(currentNetwork())
		if !known {
			panic(fmt.Sprintf("network %q became unknown after startup", currentNetwork()))
		}
		return config.ChainParamsFor(n)
	})
	orch.NetParams = netParams

	// Chain wallet provider — CoreBackend today; electrum/btcd providers
	// slot in behind the same wallet.Backend interface.
	var chainBackend wallet.Backend
	if orch.BitcoinConf != nil {
		// Port and credentials both move with the network.
		coreEndpoint := func() wallet.CoreEndpoint {
			endpoint := wallet.CoreEndpoint{
				Host: orch.BitcoinConf.GetRPCHost(),
				Port: orch.BitcoinConf.GetRPCPort(),
			}
			user, password, err := orch.BitcoinConf.GetRPCCredentials()
			if err != nil {
				log.Warn().Err(err).Msg("core wallet rpc has no credentials")
				return endpoint
			}
			endpoint.User, endpoint.Password = user, password
			return endpoint
		}
		coreRPC := wallet.NewCoreRPCClient(coreEndpoint)
		chainBackend = wallet.NewCoreBackend(walletSvc, coreRPC, netParams, log)
		log.Info().Int("rpc_port", coreEndpoint().Port).Msg("core wallet provider initialized")
	}

	if enforcerCfg, ok := orch.Configs()["enforcer"]; ok {
		// Enforcer passthrough: sidechain apps funnel all enforcer traffic
		// through drivechaind instead of dialing the enforcer directly.
		enforcerBridge, err := enforcerproxy.Connect(enforcerCfg.RPCURL())
		if err != nil {
			return fmt.Errorf("enforcer bridge: %w", err)
		}
		for _, svc := range []string{
			enforcerrpc.ValidatorServiceName,
			cryptorpc.CryptoServiceName,
			// The proposal and ACK RPCs the enforcer moved off its wallet.
			enforcerrpc.BlockProducerServiceName,
			// Mining, so a regtest operator can produce the mainchain block
			// that takes a BMM bid without reaching past the orchestrator.
			enforcerrpc.MiningServiceName,
		} {
			mux.Handle("/"+svc+"/", localauth.Middleware(authDir, enforcerBridge))
		}
		mux.Handle("/enforcer/jsonrpc", localauth.Middleware(authDir, enforcerproxy.JSONRPC(enforcerproxy.DefaultJSONRPCAddr)))
	}

	// Electrum wallet provider — derives BIP84 keys locally and reads/broadcasts
	// chain state over the Esplora REST API. The wallet backend speaks Esplora,
	// so it needs an Esplora endpoint; bitwindow's higher-level reads route
	// through the hosted orchestrator separately (see Server.buildDataSource).
	// Endpoint and params are looked up per call from the orchestrator's current
	// network, so a network swap applies without restarting the process.
	resolveChainTarget := func() wallet.ChainTarget {
		current := currentNetwork()
		net := config.NetworkFromString(current)
		urls := config.WalletChainSourceURLsForNetwork(net)
		// A persisted runtime override replaces the network default endpoint.
		if override := orch.ElectrumServerOverride(); override != "" {
			urls = []string{override}
		}
		return wallet.ChainTarget{Network: current, URLs: urls, Params: netParams()}
	}

	chainSource := wallet.NewNetworkChainSource(resolveChainTarget, log)
	if torEnabled, torProxy := orch.TorConfigOverride(); torEnabled && torProxy != "" {
		if err := chainSource.SetProxy(true, torProxy); err != nil {
			return fmt.Errorf("apply persisted tor proxy %q: %w", torProxy, err)
		}
		log.Info().Str("tor_proxy", torProxy).Msg("electrum wallet routing through tor proxy")
	}
	orch.SetChainTipSource(chainSource)
	electrumBackend := wallet.NewElectrumBackend(walletSvc, chainSource, netParams, log)
	log.Info().Strs("chain_source_urls", resolveChainTarget().URLs).Msg("electrum wallet provider initialized")

	router := wallet.NewBackendRouter(walletSvc, chainBackend, electrumBackend)
	walletEngine := wallet.NewWalletEngine(walletSvc, router, netParams, log)
	walletEngine.OnNetworkReset(func(dir string) { bip47SendStore.Rebind(dir) })
	orch.SetWalletEngine(walletEngine)
	walletHandler.SetEngine(walletEngine)
	multisigLoungeHandler.SetEngine(walletEngine)

	if chainBackend != nil {
		// Fork engine: single source of truth for eCash fork state, needs
		// Core-backed wallet access for its claimable scan.
		orch.InitForkEngine(walletEngine)

		// Split engine: one BTC-mainnet lookup per claimable outpoint, so the
		// claim UI can mark which coins are splittable.
		splitClient := wallet.NewEsploraClient(config.SplitCheckEsploraURLs(), log)
		splitClient.SetMinInterval(500 * time.Millisecond)
		// The split client obeys the same Tor routing as the wallet chain
		// source — persisted config at boot, runtime changes via the backend.
		if torEnabled, torProxy := orch.TorConfigOverride(); torEnabled && torProxy != "" {
			if err := splitClient.SetProxy(true, torProxy); err != nil {
				return fmt.Errorf("apply persisted tor proxy %q to split client: %w", torProxy, err)
			}
		}
		if electrumBackend != nil {
			electrumBackend.OnProxyChange(splitClient.SetProxy)
		}
		splitEngine := engines.NewSplitEngine(log, orch, orch, splitClient, walletSvc, currentNetwork)
		walletEngine.OnNetworkReset(splitEngine.ResetForNetwork)
		go func() {
			if err := splitEngine.Run(ctx); err != nil && !errors.Is(err, context.Canceled) {
				log.Error().Err(err).Msg("split engine exited")
			}
		}()
	}

	// BIP47 receive engine: watches each BIP47-capable wallet's (Core + electrum)
	// notification address for incoming notification txs, decodes their OP_RETURN
	// payload to recover the sender's payment code, and imports per-payment
	// receive keys so subsequent payments are spendable. Starts whenever any
	// BIP47-capable backend is configured — an electrum-only wallet needs it too.
	if chainBackend != nil || electrumBackend != nil {
		bip47InboundStore := bip47state.NewInboundStore(walletSvc.NetworkDir())
		bip47Engine := engines.NewBIP47Engine(log, walletSvc, walletEngine, bip47InboundStore)
		walletEngine.OnNetworkReset(bip47Engine.ResetForNetwork)
		go func() {
			if err := bip47Engine.Run(ctx); err != nil && !errors.Is(err, context.Canceled) {
				log.Error().Err(err).Msg("bip47 engine exited")
			}
		}()
	}

	// Wallet sync engine: keeps every electrum wallet on the current network
	// warm, so switching wallets serves stored history with no scan wait.
	if electrumBackend != nil {
		walletSyncEngine := engines.NewWalletSyncEngine(log, walletSvc, walletEngine)
		walletEngine.OnNetworkReset(walletSyncEngine.ResetForNetwork)
		go func() {
			if err := walletSyncEngine.Run(ctx); err != nil && !errors.Is(err, context.Canceled) {
				log.Error().Err(err).Msg("wallet sync engine exited")
			}
		}()
	}

	// BMM engine: bids for sidechain blocks on every new mainchain tip and
	// connects the blocks miners take, with no frontend attached.
	bmmHandler := api.NewBMMHandler(orch, walletHandler)
	bmmStore := bmmstate.NewStore(walletSvc.NetworkDir(), 0)
	bmmEngine := engines.NewBmmEngine(log, bmmHandler, orch, bmmStore)
	bmmHandler.SetEngine(bmmEngine)
	walletEngine.OnNetworkReset(func(dir string) { bmmStore.Rebind(dir) })
	go func() {
		if err := bmmEngine.Run(ctx); err != nil && !errors.Is(err, context.Canceled) {
			log.Error().Err(err).Msg("bmm engine exited")
		}
	}()

	bmmPath, bmmH := bmmrpc.NewBMMServiceHandler(bmmHandler, connect.WithInterceptors(authIC))
	mux.Handle(bmmPath, bmmH)

	walletPath, walletH := walletrpc.NewWalletManagerServiceHandler(walletHandler, connect.WithInterceptors(authIC))
	mux.Handle(walletPath, walletH)

	multisigLoungePath, multisigLoungeH := multisigloungerpc.NewMultisigLoungeServiceHandler(multisigLoungeHandler, connect.WithInterceptors(authIC))
	mux.Handle(multisigLoungePath, multisigLoungeH)

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
		// The proxy authenticates via the cookie file and re-reads it on Core
		// restarts, so it only needs rebuilding on a network swap.
		var coreProxyMu sync.Mutex
		rebuildCoreProxy := func(reason string) {
			coreProxyMu.Lock()
			defer coreProxyMu.Unlock()

			proxy, err := startCoreProxy(ctx, orch, log)
			if err != nil {
				log.Warn().Err(err).Str("reason", reason).Msg("failed to start bitcoin core proxy")
				return
			}
			_, h := corerpc.NewBitcoinServiceHandler(proxy, connect.WithInterceptors(authIC, meterIC))
			swappable.swap(h)
			log.Info().Str("reason", reason).Msg("bitcoin core proxy ready")
		}
		rebuildCoreProxy("startup")
		// The path is constant; register once.
		corePath, _ := corerpc.NewBitcoinServiceHandler(noopBitcoinService{}, connect.WithInterceptors(authIC, meterIC))
		mux.Handle(corePath, swappable)
		log.Info().Str("service", "bitcoin.bitcoind.v1alpha.BitcoinService").Msg("registered bitcoin core proxy")

		orch.BitcoinConf.OnNetworkChanged = func() {
			rebuildCoreProxy("network swap")
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
		case "bbc":
			// Core derived: its own client, authenticated by the node's cookie.
			dirs, ok := config.DirConfigByName(name)
			if !ok {
				log.Warn().Str("sidechain", name).Msg("no directory config; skipping RPC service")
				continue
			}
			cookie := filepath.Join(dirs.DatadirNetwork(config.Network(orch.Network), ""), ".cookie")
			h := bbcsvc.NewHandler(bbcsvc.NewClient(cfg.RPCHost(), cfg.Port, cookie))
			path, handler := bbcrpc.NewBbcServiceHandler(h, connect.WithInterceptors(authIC))
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
	clients := lease.New(cctx.Int("owner-pid"), lease.DefaultGrace, func() {
		log.Info().Msg("no clients left and the owner is gone, shutting down")
		orch.BeginShutdown()
	})
	orch.SetLease(clients)

	srv := &http.Server{
		ConnState: clients.ConnState,
		Handler:   mux,
		Protocols: protocols,
		HTTP2:     &http.HTTP2Config{SendPingTimeout: 30 * time.Second},
		// A socket that never sends a request would hold the lease forever.
		ReadHeaderTimeout: 10 * time.Second,
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

	go clients.Run(ctx)

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

	log.Info().Msg("drivechaind shutdown complete")
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
	host := fmt.Sprintf("%s:%d", orch.BitcoinConf.GetRPCHost(), port)

	// Explicit creds win; otherwise pass the cookie path so the proxy re-reads
	// it on Core restarts instead of pinning a rotated-out cookie. Empty creds
	// fall through to cookie auth, so the proxy can start before Core writes it.
	explicitUser, explicitPass := orch.BitcoinConf.GetExplicitRPCCredentials()
	log.Info().Str("host", host).Str("user", explicitUser).Msg("starting Bitcoin Core proxy")

	// Quiet the proxy's connection logs — its rpcclient retries on a tight
	// loop while bitcoind is starting and floods stdout otherwise.
	proxyLog := log.Level(zerolog.WarnLevel)
	initCtx := proxyLog.WithContext(ctx)

	return coreproxy.NewBitcoind(
		initCtx, host, explicitUser, explicitPass,
		coreproxy.WithCookiePath(orch.BitcoinConf.GetRPCCookiePath()),
		coreproxy.WithLogging(func(_ context.Context) *zerolog.Logger { return &proxyLog }),
		coreproxy.WithoutInitialConnectionCheck(),
	)
}
