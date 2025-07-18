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
	api_bitcoind "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/bitcoind"
	api_bitwindowd "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/bitwindowd"
	api_drivechain "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/drivechain"
	api_enforcer "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/enforcer"
	api_health "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/health"
	api_misc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/misc"
	api_wallet "github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/wallet"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitcoind/v1/bitcoindv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1/bitwindowdv1connect"
	cryptorpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/crypto/v1/cryptov1connect"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1/mainchainv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/drivechain/v1/drivechainv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/health/v1/healthv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/misc/v1/miscv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/wallet/v1/walletv1connect"
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"
)

type Services struct {
	Database          *sql.DB
	BitcoindConnector service.Connector[bitcoindv1alphaconnect.BitcoinServiceClient]
	WalletConnector   service.Connector[validatorrpc.WalletServiceClient]
	EnforcerConnector service.Connector[validatorrpc.ValidatorServiceClient]
	CryptoConnector   service.Connector[cryptorpc.CryptoServiceClient]
}

type Config struct {
	GUIBootedMainchain bool
	GUIBootedEnforcer  bool
	OnShutdown         func()
}

// New creates a new Server with interceptors applied.
func New(
	ctx context.Context,
	s Services,
	c Config,
) (*Server, error) {
	mux := http.NewServeMux()

	bitcoindSvc := service.New("bitcoind", s.BitcoindConnector)
	validatorSvc := service.New("enforcer", s.EnforcerConnector)
	walletSvc := service.New("wallet", s.WalletConnector)
	cryptoSvc := service.New("crypto", s.CryptoConnector)

	// Start reconnection loops
	bitcoindSvc.StartReconnectLoop(ctx)
	validatorSvc.StartReconnectLoop(ctx)
	walletSvc.StartReconnectLoop(ctx)
	cryptoSvc.StartReconnectLoop(ctx)

	srv := &Server{
		mux:      mux,
		Bitcoind: bitcoindSvc,
		Enforcer: validatorSvc,
		Wallet:   walletSvc,
		Crypto:   cryptoSvc,
	}

	Register(srv, bitwindowdv1connect.NewBitwindowdServiceHandler, bitwindowdv1connect.BitwindowdServiceHandler(api_bitwindowd.New(
		c.OnShutdown, s.Database, validatorSvc, walletSvc, bitcoindSvc, c.GUIBootedMainchain, c.GUIBootedEnforcer,
	)))
	Register(srv, bitcoindv1connect.NewBitcoindServiceHandler, bitcoindv1connect.BitcoindServiceHandler(api_bitcoind.New(
		bitcoindSvc,
	)))

	drivechainClient := drivechainv1connect.DrivechainServiceHandler(api_drivechain.New(
		validatorSvc,
	))
	Register(srv, drivechainv1connect.NewDrivechainServiceHandler, drivechainClient)

	Register(srv, walletv1connect.NewWalletServiceHandler, walletv1connect.WalletServiceHandler(api_wallet.New(
		ctx, s.Database, bitcoindSvc, walletSvc, cryptoSvc,
	)))
	Register(srv, miscv1connect.NewMiscServiceHandler, miscv1connect.MiscServiceHandler(api_misc.New(
		s.Database, walletSvc,
	)))
	Register(srv, healthv1connect.NewHealthServiceHandler, healthv1connect.HealthServiceHandler(api_health.New(
		s.Database, bitcoindSvc, validatorSvc, walletSvc, cryptoSvc,
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

	Enforcer *service.Service[validatorrpc.ValidatorServiceClient]
	Bitcoind *service.Service[bitcoindv1alphaconnect.BitcoinServiceClient]
	Wallet   *service.Service[validatorrpc.WalletServiceClient]
	Crypto   *service.Service[cryptorpc.CryptoServiceClient]
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
		return fmt.Errorf("could not listen: %w", err)
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
	service, h := handler(svc,
		slices.Concat(
			opts,
		)...,
	)

	s.services = append(s.services, service)
	s.mux.Handle(service, h)
}
