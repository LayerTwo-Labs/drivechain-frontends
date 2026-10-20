package server

import (
	"context"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"strings"
	"sync/atomic"
	"time"

	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"connectrpc.com/grpcreflect"
	api_explorer "github.com/LayerTwo-Labs/sidesail/dc-hub/server/api/explorer"
	api_faucet "github.com/LayerTwo-Labs/sidesail/dc-hub/server/api/faucet"
	"github.com/LayerTwo-Labs/sidesail/dc-hub/server/api/faucet/validation"
	api_validator "github.com/LayerTwo-Labs/sidesail/dc-hub/server/api/validator"
	"github.com/LayerTwo-Labs/sidesail/dc-hub/server/connector"
	validatordrpc "github.com/LayerTwo-Labs/sidesail/dc-hub/server/gen/cusf/mainchain/v1/mainchainv1connect"
	explorerrpc "github.com/LayerTwo-Labs/sidesail/dc-hub/server/gen/explorer/v1/explorerv1connect"
	faucetrpc "github.com/LayerTwo-Labs/sidesail/dc-hub/server/gen/hub/v1/hubv1connect"
	"github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/rs/cors"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
)

// New creates a new Server with interceptors applied.
func New(
	ctx context.Context, bitcoind bitcoindv1alphaconnect.BitcoinServiceClient,
	rpcClients *api_explorer.RpcClients,
	enforcerConnector connector.Connector[validatordrpc.ValidatorServiceClient],
) *Server {
	mux := http.NewServeMux()
	srv := &Server{
		mux: mux,
		services: []string{
			faucetrpc.FaucetServiceName,
			explorerrpc.ExplorerServiceName,
			validatordrpc.ValidatorServiceName,
		},
	}

	validatorSvc := connector.New("enforcer", enforcerConnector)
	rpcServer := connect.NewServer(validation.Interceptor())
	faucetrpc.RegisterFaucetServiceHandler(rpcServer, api_faucet.New(bitcoind))
	explorerrpc.RegisterExplorerServiceHandler(rpcServer, api_explorer.New(bitcoind, rpcClients, validatorSvc))
	validatordrpc.RegisterValidatorServiceHandler(rpcServer, api_validator.New(validatorSvc))
	connecthttp.Mount(mux, rpcServer, connecthttp.WithReadMaxBytes(0))
	reflector := grpcreflect.NewStaticReflector(srv.services...)
	mux.Handle(grpcreflect.NewHandlerV1(reflector))
	mux.Handle(grpcreflect.NewHandlerV1Alpha(reflector))

	return srv
}

// Server exposes a set of Connect APIs over both gRPC and HTTP. Reflection is enabled.
type Server struct {
	// used for creating health and reflect services
	services []string

	mux    *http.ServeMux
	server *http.Server
}

func (s *Server) Handler(ctx context.Context) http.Handler {
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
	})

	withCORS := corsHandler.Handler(s.mux)

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

		withCORS.ServeHTTP(w, r)
	})

	return handler
}

func (s *Server) Serve(ctx context.Context, address string) error {
	log := zerolog.Ctx(ctx)

	services := lo.Map(s.services, func(svc string, index int) string {
		// Remove trailing and leading slashes
		return strings.Trim(svc, "/")
	})

	joinedServices := strings.Join(services, ", ")
	log.Debug().
		Msgf("serve connect: enabling reflection: %s", joinedServices)

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

	// cleartext HTTP/2 alongside HTTP/1, which connect-go's gRPC protocol needs
	protocols := new(http.Protocols)
	protocols.SetHTTP1(true)
	protocols.SetUnencryptedHTTP2(true)
	s.server = &http.Server{
		Handler:   s.Handler(ctx),
		Protocols: protocols,
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
