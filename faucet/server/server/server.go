package server

import (
	"context"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"slices"
	"strings"
	"sync/atomic"
	"time"

	"connectrpc.com/connect"
	"connectrpc.com/grpcreflect"
	api_explorer "github.com/LayerTwo-Labs/sidesail/faucet/server/api/explorer"
	api_faucet "github.com/LayerTwo-Labs/sidesail/faucet/server/api/faucet"
	"github.com/LayerTwo-Labs/sidesail/faucet/server/api/faucet/validation"
	api_validator "github.com/LayerTwo-Labs/sidesail/faucet/server/api/validator"
	"github.com/LayerTwo-Labs/sidesail/faucet/server/connector"
	validatordrpc "github.com/LayerTwo-Labs/sidesail/faucet/server/gen/cusf/mainchain/v1/mainchainv1connect"
	explorerrpc "github.com/LayerTwo-Labs/sidesail/faucet/server/gen/explorer/v1/explorerv1connect"
	faucetrpc "github.com/LayerTwo-Labs/sidesail/faucet/server/gen/faucet/v1/faucetv1connect"
	faucet_ip "github.com/LayerTwo-Labs/sidesail/faucet/server/ip"
	"github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/rs/cors"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"
)

// New creates a new Server with interceptors applied.
func New(
	ctx context.Context, bitcoind bitcoindv1alphaconnect.BitcoinServiceClient,
	rpcClients *api_explorer.RpcClients,
	enforcerConnector connector.Connector[validatordrpc.ValidatorServiceClient],
) *Server {
	interceptors := []connect.Interceptor{
		faucet_ip.Interceptor(),
		validation.Interceptor(),
	}

	mux := http.NewServeMux()
	srv := &Server{mux: mux, interceptors: interceptors}

	validatorSvc := connector.New("enforcer", enforcerConnector)

	Register(
		srv, faucetrpc.NewFaucetServiceHandler,
		faucetrpc.FaucetServiceHandler(api_faucet.New(bitcoind)),
	)
	Register(
		srv, explorerrpc.NewExplorerServiceHandler,
		explorerrpc.ExplorerServiceHandler(api_explorer.New(bitcoind, rpcClients)),
	)
	Register(
		srv, validatordrpc.NewValidatorServiceHandler,
		validatordrpc.ValidatorServiceHandler(api_validator.New(validatorSvc)),
	)

	return srv
}

// Server exposes a set of Connect APIs over both gRPC and HTTP. Reflection is enabled.
type Server struct {
	// used for creating health and reflect services
	services []string

	mux    *http.ServeMux
	server *http.Server

	interceptors []connect.Interceptor
}

func (s *Server) Handler(ctx context.Context) http.Handler {
	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Add CSP header
		w.Header().Set("Content-Security-Policy",
			"default-src 'self'; "+
				"connect-src 'self' ws: wss: http: https:; "+
				"script-src 'self' 'wasm-unsafe-eval' 'unsafe-eval'; "+ // Allow eval for gRPC-web
				"style-src 'self' 'unsafe-inline'")

		// If the body is completely empty, replace it with the
		// empty object. This makes it possible to send requests
		// without a body, without getting a cryptic error.
		if r.ContentLength == 0 && r.Header.Get("Content-Type") == "application/json" {
			r.Body = io.NopCloser(strings.NewReader(`{}`))
		}

		corsHandler := cors.New(cors.Options{
			AllowedOrigins: []string{
				"*",
				"https://drivechain.live",
				"https://api.drivechain.live",
				"http://localhost:3000", // For local development
			},
			AllowedMethods: []string{"GET", "POST", "DELETE", "OPTIONS", "PATCH"},
			AllowedHeaders: []string{
				"Connect-Protocol-Version", "Content-Type", "Connect-Protocol-Version",
				"Content-Type", "Accept", "Connect-Accept-Encoding",
				"Connect-Content-Encoding", "Grpc-Timeout", "X-Grpc-Web",
				"X-User-Agent", "Access-Control-Allow-Origin",
				"Access-Control-Request-Headers",
				"Origin",          // Important for CORS preflight
				"Accept-Encoding", // Allow compression negotiation
			},
			ExposedHeaders: []string{
				"Content-Encoding", "Connect-Content-Encoding",
				"Grpc-Status", "Grpc-Message",
				"Access-Control-Allow-Origin",
				"Access-Control-Request-Headers",
			},
			AllowCredentials: true, // Allow credentials
		})

		withCORS := corsHandler.Handler(s.mux)
		withCORS.ServeHTTP(w, r)
	})

	// Use h2c, so we can serve HTTP/2 without TLS.
	return h2c.NewHandler(handler, &http2.Server{})
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
		Handler: s.Handler(ctx),
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
		log.Print("server: successful graceful stop")
	}

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
			[]connect.HandlerOption{connect.WithInterceptors(s.interceptors...)},
			opts,
		)...,
	)

	s.services = append(s.services, service)
	s.mux.Handle(service, h)
}
