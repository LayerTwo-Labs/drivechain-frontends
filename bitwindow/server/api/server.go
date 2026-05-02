package api

import (
	"context"
	"errors"
	"fmt"
	"net"
	"net/http"
	"strings"
	"sync"
	"sync/atomic"
	"time"

	"connectrpc.com/connect"

	"database/sql"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bitassets"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bitnames"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/coinshift"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/photon"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/thunder"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/truthcoin"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"

	cryptorpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/crypto/v1/cryptov1connect"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
)

type Services struct {
	BitcoindConnector service.Connector[corerpc.BitcoinServiceClient]
	WalletConnector   service.Connector[validatorrpc.WalletServiceClient]
	EnforcerConnector service.Connector[validatorrpc.ValidatorServiceClient]
	CryptoConnector   service.Connector[cryptorpc.CryptoServiceClient]

	// Sidechain connectors
	ThunderConnector   service.Connector[*thunder.Client]
	BitNamesConnector  service.Connector[*bitnames.Client]
	BitAssetsConnector service.Connector[*bitassets.Client]
	TruthcoinConnector service.Connector[*truthcoin.Client]
	PhotonConnector    service.Connector[*photon.Client]
	CoinShiftConnector service.Connector[*coinshift.Client]

	OrchestratorAddr string // e.g. "http://localhost:30400"

	// Test overrides: when set, buildRuntime uses these instead of opening
	// fresh from disk. Production callers leave these zero.
	Database    *sql.DB
	ChainParams *chaincfg.Params
	WalletDir   string
	DataDir     string
}

// Server hosts bitwindowd's HTTP/Connect surface. Long-lived service
// connectors and the listener live here; per-network state (db, engines,
// sub-handlers) lives in Runtime, which is recycled in-process on
// network swap via Recycle.
type Server struct {
	// long-lived (stable across network swaps)
	server  *http.Server
	topSwap *swappableHandler

	Enforcer *service.Service[validatorrpc.ValidatorServiceClient]
	Bitcoind *service.Service[corerpc.BitcoinServiceClient]
	Wallet   *service.Service[validatorrpc.WalletServiceClient]
	Crypto   *service.Service[cryptorpc.CryptoServiceClient]

	Thunder   *service.Service[*thunder.Client]
	BitNames  *service.Service[*bitnames.Client]
	BitAssets *service.Service[*bitassets.Client]
	Truthcoin *service.Service[*truthcoin.Client]
	Photon    *service.Service[*photon.Client]
	CoinShift *service.Service[*coinshift.Client]

	svcs       Services
	onShutdown func(ctx context.Context)

	// Per-network runtime — atomically swapped on Recycle.
	current atomic.Pointer[Runtime]

	// Recycle is single-flight and serializes mutations of conf.
	recycleMu sync.Mutex
	conf      config.Config

	// Root context (server lifetime). Forks runtime engine ctxs.
	rootCtx context.Context
}

// New creates a Server with long-lived connectors started, builds the
// initial Runtime for the configured network, and starts that runtime's
// engines. The HTTP listener is not opened until Serve.
func New(
	ctx context.Context,
	svcs Services,
	conf config.Config,
	onShutdown func(ctx context.Context),
) (*Server, error) {
	bitcoindSvc := service.New("bitcoind", svcs.BitcoindConnector)
	validatorSvc := service.New("enforcer", svcs.EnforcerConnector)
	walletSvc := service.New("wallet", svcs.WalletConnector)
	cryptoSvc := service.New("crypto", svcs.CryptoConnector)

	thunderSvc := service.New("thunder", svcs.ThunderConnector)
	bitnamesSvc := service.New("bitnames", svcs.BitNamesConnector)
	bitassetsSvc := service.New("bitassets", svcs.BitAssetsConnector)
	truthcoinSvc := service.New("truthcoin", svcs.TruthcoinConnector)
	photonSvc := service.New("photon", svcs.PhotonConnector)
	coinshiftSvc := service.New("coinshift", svcs.CoinShiftConnector)

	// Eagerly seed the bitcoind connection so callers (health checks, the
	// wallet bootstrap goroutine waiting on ConnectedChan, the cheque
	// recovery loop) don't have to wait a full reconnect-ticker period.
	// dial.Bitcoind is stateless and always returns success once the
	// orchestrator addr is set, so this is cheap. Remote-handshake
	// connectors (enforcer wallet/validator/crypto) stay lazy because they
	// do real I/O; eager-connecting them would change downstream test
	// semantics that depend on those staying disconnected at boot.
	_, _ = bitcoindSvc.Connect(ctx)

	// Reconnect loops are inherent service behavior — keep them on the
	// root ctx so they survive runtime recycles.
	bitcoindSvc.StartReconnectLoop(ctx)
	validatorSvc.StartReconnectLoop(ctx)
	walletSvc.StartReconnectLoop(ctx)
	cryptoSvc.StartReconnectLoop(ctx)
	thunderSvc.StartReconnectLoop(ctx)
	bitnamesSvc.StartReconnectLoop(ctx)
	bitassetsSvc.StartReconnectLoop(ctx)
	truthcoinSvc.StartReconnectLoop(ctx)
	photonSvc.StartReconnectLoop(ctx)
	coinshiftSvc.StartReconnectLoop(ctx)

	srv := &Server{
		topSwap:    newSwappableHandler(),
		Enforcer:   validatorSvc,
		Bitcoind:   bitcoindSvc,
		Wallet:     walletSvc,
		Crypto:     cryptoSvc,
		Thunder:    thunderSvc,
		BitNames:   bitnamesSvc,
		BitAssets:  bitassetsSvc,
		Truthcoin:  truthcoinSvc,
		Photon:     photonSvc,
		CoinShift:  coinshiftSvc,
		svcs:       svcs,
		onShutdown: onShutdown,
		conf:       conf,
		rootCtx:    ctx,
	}

	rt, err := srv.buildRuntime(ctx, conf)
	if err != nil {
		return nil, fmt.Errorf("build initial runtime: %w", err)
	}
	srv.topSwap.swap(rt.mux)
	srv.current.Store(rt)
	rt.Start(ctx)

	return srv, nil
}

// Recycle swaps to a fresh Runtime for the given network: opens a new
// network-scoped DB, builds new engines, registers new sub-handlers on a
// new mux, atomically points the listener at the new mux, and tears down
// the old runtime asynchronously. The HTTP server keeps running across
// the swap on the same port; the bitwindowd process never exits.
func (s *Server) Recycle(ctx context.Context, network config.Network) error {
	s.recycleMu.Lock()
	defer s.recycleMu.Unlock()

	log := zerolog.Ctx(ctx)
	log.Info().Str("network", string(network)).Msg("recycling runtime for new network")

	old := s.current.Load()
	if old != nil && old.conf.BitcoinCoreNetwork == network {
		log.Info().Msg("network already active, skipping recycle")
		return nil
	}

	// Fresh conf snapshot for the new network. Finalize re-derives Datadir
	// and LogPath (network-scoped folder) from the parent conf shape.
	newConf := s.conf
	if err := newConf.Finalize(network); err != nil {
		return fmt.Errorf("finalize conf for %s: %w", network, err)
	}

	rt, err := s.buildRuntime(ctx, newConf)
	if err != nil {
		return fmt.Errorf("build runtime for %s: %w", network, err)
	}

	s.conf = newConf
	s.topSwap.swap(rt.mux)
	s.current.Store(rt)
	rt.Start(s.rootCtx)

	// Tear down old runtime asynchronously — engines cancel, in-flight
	// streams unwind, db closes. Doesn't block the UpdateNetwork response.
	if old != nil {
		go func() {
			old.Close()
			log.Info().Msg("old runtime torn down")
		}()
	}

	log.Info().Str("network", string(network)).Msg("runtime recycle complete")
	return nil
}

func (s *Server) Handler() http.Handler {
	// Use h2c, so we can serve HTTP/2 without TLS.
	return h2c.NewHandler(s.topSwap, &http2.Server{})
}

func (s *Server) Serve(ctx context.Context, address string) error {
	log := zerolog.Ctx(ctx)
	log.Info().Str("address", address).Msg("serve connect: enabling reflection on per-runtime mux")

	lis, err := net.Listen("tcp", address)
	if err != nil {
		return fmt.Errorf("listen on %q: %w", address, err)
	}
	defer func() {
		err := lis.Close()
		if err == nil {
			return
		}
		switch {
		case errors.Is(err, net.ErrClosed),
			errors.Is(err, http.ErrServerClosed):
			return
		}
		log.Error().Err(err).Msg("could not close listener")
	}()

	s.server = &http.Server{Handler: s.Handler()}
	return s.server.Serve(lis)
}

// Shutdown tries to gracefully stop the server, forcing a shutdown after
// a timeout if needed, then closes the current runtime.
func (s *Server) Shutdown(ctx context.Context) {
	if s == nil {
		return
	}

	log := zerolog.Ctx(ctx)

	if s.server != nil {
		const timeout = time.Second * 3
		var stopped, forced int64
		time.AfterFunc(timeout, func() {
			if atomic.LoadInt64(&stopped) != 0 {
				return
			}
			log.Printf("server: forcing stop after %s", timeout)
			atomic.AddInt64(&forced, 1)
			if err := s.server.Close(); err != nil {
				log.Err(err).Msg("server: could not force stop HTTP server")
				return
			}
		})

		log.Print("server: trying graceful stop")
		if err := s.server.Shutdown(context.Background()); err != nil {
			log.Err(err).Msg("server: could not gracefully stop HTTP server")
		} else if atomic.LoadInt64(&forced) == 0 {
			log.Info().Msg("server: successful graceful stop")
		}
		atomic.AddInt64(&stopped, 1)
	}

	if rt := s.current.Load(); rt != nil {
		rt.Close()
	}
}

func logInterceptor() connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			start := time.Now()

			var code connect.Code
			log := zerolog.Ctx(ctx)

			resp, handlerErr := next(ctx, req)

			if handlerErr != nil {
				if cCode, ok := getCode(handlerErr); ok {
					code = cCode
				} else if errors.Is(handlerErr, context.Canceled) { //nolint:gocritic
					code = connect.CodeCanceled
				} else if errors.Is(handlerErr, context.DeadlineExceeded) {
					code = connect.CodeDeadlineExceeded
				} else {
					code = connect.CodeInternal
				}
			}

			procedure := req.Spec().Procedure
			level := getLogLevel(procedure, code, handlerErr)
			if level == zerolog.Disabled {
				return resp, handlerErr
			}

			message := fmt.Sprintf("%s: %s", procedure, describeCode(code))
			log.WithLevel(level).
				Dur("duration", time.Since(start)).
				Str("status", describeCode(code)).
				Err(handlerErr).
				Msg(message)

			return resp, handlerErr
		}
	}
}

func getLogLevel(procedure string, code connect.Code, err error) zerolog.Level {
	if strings.Contains(procedure, "HealthService") {
		return zerolog.Disabled
	}
	if strings.Contains(procedure, "GetSyncInfo") {
		return zerolog.Disabled
	}

	if code == connect.CodeInternal || code == connect.CodeUnknown {
		if err != nil && isBitcoinCoreStartupError(err.Error()) {
			if strings.Contains(procedure, "BitwindowdService") ||
				strings.Contains(procedure, "BitcoinService") ||
				strings.Contains(procedure, "WalletService") {
				return zerolog.Disabled
			}
		}
		return zerolog.ErrorLevel
	}

	if strings.Contains(procedure, "BitcoinService") {
		if code == connect.CodeUnavailable {
			return zerolog.Disabled
		}
		return zerolog.DebugLevel
	}

	if strings.Contains(procedure, "WalletService") && code == connect.CodeUnavailable {
		return zerolog.Disabled
	}
	if strings.Contains(procedure, "ValidatorService") && code == connect.CodeUnavailable {
		return zerolog.Disabled
	}

	return zerolog.DebugLevel
}

func isBitcoinCoreStartupError(errMsg string) bool {
	if engines.IsBitcoinCoreStartupError(errMsg) {
		return true
	}
	for _, p := range []string{
		"unable to connect to Bitcoin Core",
		"does not accept connections",
		"connection refused",
	} {
		if strings.Contains(errMsg, p) {
			return true
		}
	}
	return false
}

func describeCode(code connect.Code) string {
	if code == 0 {
		return "ok"
	}
	return code.String()
}

func getCode(err error) (connect.Code, bool) {
	for err != nil {
		if hasCode, ok := err.(interface{ Code() connect.Code }); ok {
			return hasCode.Code(), true
		}
		if joinErr, ok := err.(interface{ Unwrap() []error }); ok {
			for _, err := range joinErr.Unwrap() {
				code, ok := getCode(err)
				if ok {
					return code, true
				}
			}
		}
		err = errors.Unwrap(err)
	}
	return connect.CodeUnknown, false
}
