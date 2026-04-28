package api

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"net"
	"net/http"
	"slices"
	"strings"
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
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	cryptorpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/crypto/v1/cryptov1connect"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
	orchrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bitassets"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bitnames"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/coinshift"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/photon"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/thunder"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/truthcoin"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"
	"google.golang.org/protobuf/reflect/protoreflect"
	"google.golang.org/protobuf/types/dynamicpb"
)

type Services struct {
	Database          *sql.DB
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

	ChainParams      *chaincfg.Params
	WalletDir        string
	DataDir          string
	OrchestratorAddr string // e.g. "http://localhost:30400"
}

// New creates a new Server with interceptors applied.
func New(
	ctx context.Context,
	svcs Services,
	conf config.Config,
	coreProxyListener net.Listener,
	onShutdown func(ctx context.Context),
) (*Server, error) {
	mux := http.NewServeMux()

	bitcoindSvc := service.New("bitcoind", svcs.BitcoindConnector)
	validatorSvc := service.New("enforcer", svcs.EnforcerConnector)
	walletSvc := service.New("wallet", svcs.WalletConnector)
	cryptoSvc := service.New("crypto", svcs.CryptoConnector)

	// Start reconnection loops
	bitcoindSvc.StartReconnectLoop(ctx)
	validatorSvc.StartReconnectLoop(ctx)
	walletSvc.StartReconnectLoop(ctx)
	cryptoSvc.StartReconnectLoop(ctx)

	// Create sidechain services
	thunderSvc := service.New("thunder", svcs.ThunderConnector)
	bitnamesSvc := service.New("bitnames", svcs.BitNamesConnector)
	bitassetsSvc := service.New("bitassets", svcs.BitAssetsConnector)
	truthcoinSvc := service.New("truthcoin", svcs.TruthcoinConnector)
	photonSvc := service.New("photon", svcs.PhotonConnector)
	coinshiftSvc := service.New("coinshift", svcs.CoinShiftConnector)

	// Start sidechain reconnection loops
	thunderSvc.StartReconnectLoop(ctx)
	bitnamesSvc.StartReconnectLoop(ctx)
	bitassetsSvc.StartReconnectLoop(ctx)
	truthcoinSvc.StartReconnectLoop(ctx)
	photonSvc.StartReconnectLoop(ctx)
	coinshiftSvc.StartReconnectLoop(ctx)

	// Create wallet engine for unlock/lock, routing, and sync
	walletEngine := engines.NewWalletEngine(
		func(ctx context.Context) (corerpc.BitcoinServiceClient, error) {
			return bitcoindSvc.Get(ctx)
		},
		func(ctx context.Context) (validatorrpc.WalletServiceClient, error) {
			return walletSvc.Get(ctx)
		},
		svcs.WalletDir,
		svcs.ChainParams,
	)

	// Connect wallet engine to orchestrator if address is configured
	if svcs.OrchestratorAddr != "" {
		orchClient := orchrpc.NewWalletManagerServiceClient(
			http.DefaultClient,
			svcs.OrchestratorAddr,
		)
		walletEngine.SetOrchestratorClient(orchClient)
		zerolog.Ctx(ctx).Info().Str("addr", svcs.OrchestratorAddr).Msg("wallet engine connected to orchestrator")
	}

	// Create cheque engine for address derivation
	chequeEngine := engines.NewChequeEngine(walletEngine, svcs.ChainParams, bitcoindSvc)

	// Create timestamp engine for file timestamping
	walletAdapter := engines.NewWalletAdapter(walletSvc)
	timestampEngine := engines.NewTimestampEngine(svcs.Database, zerolog.Ctx(ctx).With().Str("component", "timestamp").Logger(), walletAdapter, bitcoindSvc)

	// Create M4 engine for M4 Explorer
	m4Engine := engines.NewM4Engine(svcs.Database)

	// Create notification engine for streaming notifications
	notificationEngine := engines.NewNotificationEngine(svcs.Database, bitcoindSvc)

	// Create BitDrive engine for file storage
	bitdriveEngine := engines.NewBitDriveEngine(svcs.Database, walletEngine, svcs.DataDir, svcs.ChainParams)

	// Create sidechain monitor engine for fast withdrawal detection
	sidechainMonitorEngine := engines.NewSidechainMonitorEngine(
		thunderSvc,
		bitnamesSvc,
		bitassetsSvc,
		truthcoinSvc,
		photonSvc,
		coinshiftSvc,
		notificationEngine,
	)

	srv := &Server{
		mux:                    mux,
		Bitcoind:               bitcoindSvc,
		Enforcer:               validatorSvc,
		Wallet:                 walletSvc,
		Crypto:                 cryptoSvc,
		WalletEngine:           walletEngine,
		ChequeEngine:           chequeEngine,
		TimestampEngine:        timestampEngine,
		M4Engine:               m4Engine,
		NotificationEngine:     notificationEngine,
		SidechainMonitorEngine: sidechainMonitorEngine,

		// Sidechain services
		Thunder:   thunderSvc,
		BitNames:  bitnamesSvc,
		BitAssets: bitassetsSvc,
		Truthcoin: truthcoinSvc,
		Photon:    photonSvc,
		CoinShift: coinshiftSvc,
	}

	Register(srv, bitwindowdv1connect.NewBitwindowdServiceHandler, bitwindowdv1connect.BitwindowdServiceHandler(api_bitwindowd.New(
		onShutdown, svcs.Database, validatorSvc, walletSvc, bitcoindSvc, walletEngine, conf,
	)))

	// Dynamically forward all Bitcoin Core RPCs to the Bitcoin Core proxy.
	const bitcoinService = "/bitcoin.bitcoind.v1alpha.BitcoinService/"
	srv.services = append(srv.services, bitcoinService)
	srv.mux.Handle(bitcoinService, http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		_, method, ok := strings.Cut(r.URL.Path, bitcoinService)
		if !ok {
			http.NotFound(w, r)
			return
		}

		schema := corepb.File_bitcoin_bitcoind_v1alpha_bitcoin_proto.Services().
			ByName("BitcoinService").
			Methods().
			ByName(protoreflect.Name(method))

		if schema == nil {
			zerolog.Ctx(ctx).Error().Msgf("unknown method %s", method)
			http.Error(w, fmt.Sprintf("unknown method: %s", method), http.StatusNotFound)
			return
		}

		initializer := func(spec connect.Spec, msg any) error {
			dynamic, ok := msg.(*dynamicpb.Message)
			if !ok {
				return nil
			}
			desc, ok := spec.Schema.(protoreflect.MethodDescriptor)
			if !ok {
				return fmt.Errorf("invalid schema type %T for %T message", spec.Schema, dynamic)
			}
			if spec.IsClient {
				*dynamic = *dynamicpb.NewMessage(desc.Output())
			} else {
				*dynamic = *dynamicpb.NewMessage(desc.Input())
			}
			return nil
		}

		handler := connect.NewUnaryHandler(
			r.URL.Path, func(ctx context.Context, cRequest *connect.Request[dynamicpb.Message]) (*connect.Response[dynamicpb.Message], error) {
				var httpClient http.Client
				fullURL := "http://" + coreProxyListener.Addr().String() + r.URL.Path

				client := connect.NewClient[dynamicpb.Message, dynamicpb.Message](
					&httpClient, fullURL,
					connect.WithSchema(schema),
					connect.WithResponseInitializer(initializer),
				)
				res, err := client.CallUnary(ctx, cRequest)
				return res, err
			},
			connect.WithSchema(schema),
			connect.WithRequestInitializer(initializer),
		)

		handler.ServeHTTP(w, r)
	}))

	drivechainClient := drivechainv1connect.DrivechainServiceHandler(api_drivechain.New(
		validatorSvc,
		walletSvc,
		svcs.Database,
		conf,
	))
	Register(srv, drivechainv1connect.NewDrivechainServiceHandler, drivechainClient)

	Register(srv, walletv1connect.NewWalletServiceHandler, walletv1connect.WalletServiceHandler(api_wallet.New(
		ctx, svcs.Database, bitcoindSvc, walletSvc, cryptoSvc, chequeEngine, walletEngine, svcs.WalletDir,
	)))
	Register(srv, miscv1connect.NewMiscServiceHandler, miscv1connect.MiscServiceHandler(api_misc.New(
		svcs.Database, walletSvc, timestampEngine, bitcoindSvc,
	)))
	Register(srv, healthv1connect.NewHealthServiceHandler, healthv1connect.HealthServiceHandler(api_health.New(
		svcs.Database, bitcoindSvc, validatorSvc, walletSvc, cryptoSvc,
	)))
	Register(srv, m4v1connect.NewM4ServiceHandler, m4v1connect.M4ServiceHandler(api_m4.NewServer(
		m4Engine,
	)))
	Register(srv, notificationv1connect.NewNotificationServiceHandler, notificationv1connect.NotificationServiceHandler(api_notification.New(
		notificationEngine,
	)))
	Register(srv, bitdrivev1connect.NewBitDriveServiceHandler, bitdrivev1connect.BitDriveServiceHandler(api_bitdrive.New(
		svcs.Database, walletSvc, bitcoindSvc, bitdriveEngine,
	)))
	Register(srv, utilsv1connect.NewUtilsServiceHandler, utilsv1connect.UtilsServiceHandler(api_utils.New(
		svcs.ChainParams,
	)))
	Register(srv, sidechainv1connect.NewSidechainServiceHandler, sidechainv1connect.SidechainServiceHandler(api_sidechain.New(
		sidechainMonitorEngine,
	)))
	multisigServer := api_multisig.New(svcs.Database)
	Register(srv, multisigv1connect.NewMultisigServiceHandler, multisigv1connect.MultisigServiceHandler(multisigServer))

	Register(srv, fast_withdrawalv1connect.NewFastWithdrawalServiceHandler, fast_withdrawalv1connect.FastWithdrawalServiceHandler(api_fast_withdrawal.New(
		thunderSvc,
		bitnamesSvc,
		bitassetsSvc,
		truthcoinSvc,
		photonSvc,
		coinshiftSvc,
		sidechainMonitorEngine,
	)))

	// Register all enforcer services, only to be used as a bridge
	enforcer := api_enforcer.New(validatorSvc, walletSvc, cryptoSvc)
	Register(srv, validatorrpc.NewValidatorServiceHandler, validatorrpc.ValidatorServiceHandler(enforcer))
	Register(srv, validatorrpc.NewWalletServiceHandler, validatorrpc.WalletServiceHandler(enforcer))
	Register(srv, cryptorpc.NewCryptoServiceHandler, cryptorpc.CryptoServiceHandler(enforcer))

	return srv, nil
}

// Server exposes a set of Connect APIs over both gRPC and HTTP. Reflection is enabled.
type Server struct {
	// used for creating health and reflect services
	services []string

	mux    *http.ServeMux
	server *http.Server

	Enforcer               *service.Service[validatorrpc.ValidatorServiceClient]
	Bitcoind               *service.Service[corerpc.BitcoinServiceClient]
	Wallet                 *service.Service[validatorrpc.WalletServiceClient]
	Crypto                 *service.Service[cryptorpc.CryptoServiceClient]
	WalletEngine           *engines.WalletEngine
	ChequeEngine           *engines.ChequeEngine
	TimestampEngine        *engines.TimestampEngine
	M4Engine               *engines.M4Engine
	NotificationEngine     *engines.NotificationEngine
	SidechainMonitorEngine *engines.SidechainMonitorEngine

	// Sidechain services
	Thunder   *service.Service[*thunder.Client]
	BitNames  *service.Service[*bitnames.Client]
	BitAssets *service.Service[*bitassets.Client]
	Truthcoin *service.Service[*truthcoin.Client]
	Photon    *service.Service[*photon.Client]
	CoinShift *service.Service[*coinshift.Client]
}

func (s *Server) Handler() http.Handler {
	// Use h2c, so we can serve HTTP/2 without TLS.
	return h2c.NewHandler(s.mux, &http2.Server{})
}

func (s *Server) Serve(ctx context.Context, address string) error {
	log := zerolog.Ctx(ctx)

	services := lo.Map(s.services, func(svc string, index int) string {
		// Remove trailing and leading slashes
		return strings.Trim(svc, "/")
	})

	joinedServices := strings.Join(services, ", ")
	{
		log.Debug().
			Msgf("serve connect: enabling reflection: %s", joinedServices)

		reflector := grpcreflect.NewStaticReflector(s.services...)

		s.mux.Handle(grpcreflect.NewHandlerV1(reflector))
		s.mux.Handle(grpcreflect.NewHandlerV1Alpha(reflector))
	}

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

		log.Error().Err(err).
			Msg("could not close listener")
	}()

	s.server = &http.Server{
		Handler: s.Handler(),
	}
	return s.server.Serve(lis)
}

// Shutdown tries to gracefully stop the server, forcing a shutdown
// after a timeout if this isn't possible. It is safe to call on a
// nil server.
func (s *Server) Shutdown(ctx context.Context) {
	if s == nil || s.server == nil {
		return
	}

	log := zerolog.Ctx(ctx)

	const timeout = time.Second * 3

	// If we have requests that don't complete, or streams that never close, we
	// risk hanging forever. Therefore, force stop after a timeout. Use int64
	// instead of bools, so we can load/add with the atomic package.
	var (
		stopped, forced int64
	)
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
		return
	}

	if atomic.LoadInt64(&forced) == 0 {
		log.Info().Msg("server: successful graceful stop")
		log.Print("server: successful graceful stop")
	}

	log.Info().Msg("server: failed graceful stop")

	atomic.AddInt64(&stopped, 1)
}

// Register can be user to register a new sub-service to the server.
// This is _NOT_ a part of the Server API, because it is generic.
func Register[T any](
	s *Server,
	handler func(svc T, opts ...connect.HandlerOption) (string, http.Handler),
	svc T, opts ...connect.HandlerOption,
) {
	standardOpts := []connect.HandlerOption{
		connect.WithInterceptors(
			logInterceptor(),
		),
	}
	service, h := handler(svc,
		slices.Concat(
			opts,
			standardOpts,
		)...,
	)

	s.services = append(s.services, service)
	s.mux.Handle(service, h)
}

func logInterceptor() connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			start := time.Now()

			var code connect.Code

			log := zerolog.Ctx(ctx)

			// Forward the request to the actual request handler. Prior to this
			// line we haven't executed any handler code, after this line we're
			// done.
			resp, handlerErr := next(ctx, req)

			// Important: We don't mutate err, only create a textual representation
			// of it. What's sent back to the user is the responsibility of other
			// interceptors/handlers.
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

			// Skip logging entirely for disabled procedures
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

// getLogLevel determines the appropriate log level for a procedure.
// This filters out noisy endpoints during normal operation.
func getLogLevel(procedure string, code connect.Code, err error) zerolog.Level {
	// Health checks are very noisy - disable logging entirely
	if strings.Contains(procedure, "HealthService") {
		return zerolog.Disabled
	}

	// GetSyncInfo is called very frequently during startup/IBD
	if strings.Contains(procedure, "GetSyncInfo") {
		return zerolog.Disabled
	}

	// Internal and unknown errors are bad! In theory, these are bugs. We
	// should always make sure to return something meaningful.
	// Exception: Bitcoin Core startup errors on expected endpoints are filtered.
	if code == connect.CodeInternal || code == connect.CodeUnknown {
		// Filter startup errors only on endpoints that interact with Bitcoin Core
		if err != nil && isBitcoinCoreStartupError(err.Error()) {
			if strings.Contains(procedure, "BitwindowdService") ||
				strings.Contains(procedure, "BitcoinService") ||
				strings.Contains(procedure, "WalletService") {
				return zerolog.Disabled
			}
		}
		return zerolog.ErrorLevel
	}

	// Bitcoin Core startup messages through proxy - these happen during IBD
	// and are very noisy (loading block index, verifying blocks, etc.)
	if strings.Contains(procedure, "BitcoinService") {
		// During unavailable state (startup), don't log at all
		if code == connect.CodeUnavailable {
			return zerolog.Disabled
		}
		return zerolog.DebugLevel
	}

	// Wallet sync calls during startup
	if strings.Contains(procedure, "WalletService") && code == connect.CodeUnavailable {
		return zerolog.Disabled
	}

	// ValidatorService (enforcer) during startup
	if strings.Contains(procedure, "ValidatorService") && code == connect.CodeUnavailable {
		return zerolog.Disabled
	}

	// Default to debug level for successful operations
	return zerolog.DebugLevel
}

// isBitcoinCoreStartupError returns true for Bitcoin Core RPC errors
// that indicate the node is still starting up or not yet connected.
// Wraps engines.IsBitcoinCoreStartupError plus connection-level failures
// that the engine helper doesn't cover (we want to suppress noisy logs
// for those too, but they aren't real "startup" states elsewhere).
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

		// Joined errors cannot be unwrapped in the same way as other
		// errors...
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
