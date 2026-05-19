package connectserver

import (
	"context"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"runtime/debug"
	"strings"
	"sync"
	"sync/atomic"
	"time"

	"connectrpc.com/connect"
	"connectrpc.com/grpchealth"
	"connectrpc.com/grpcreflect"
	"github.com/gorilla/mux"
	"github.com/oklog/ulid/v2"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"

	"github.com/barebitcoin/btc-buf/connectserver/logging"
)

func addContextLogger() connect.Interceptor {
	return connect.UnaryInterceptorFunc(func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			// Ensure that all request contexts have a brand-new context logger
			// that it is safe to manipulate.
			ctx = zerolog.Ctx(ctx).With().Logger().WithContext(ctx)
			return next(ctx, req)
		}
	})
}

type requestIdKeyType int

const requestIdKey requestIdKeyType = 1

func RequestID(ctx context.Context) string {
	value, ok := ctx.Value(requestIdKey).(string)
	if !ok {
		return ""
	}

	return value
}

func addRequestID() connect.Interceptor {
	return connect.UnaryInterceptorFunc(func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			const traceHeader = "x-trace-id"
			requestId := "req_" + ulid.Make().String()
			if head := req.Header().Get(traceHeader); head != "" {
				requestId = head
			}
			log := zerolog.Ctx(ctx).With().Str("requestId", requestId).Logger()

			ctx = log.WithContext(ctx)
			ctx = context.WithValue(ctx, requestIdKey, requestId)

			res, err := next(ctx, req)

			// Propagate the request ID back to the caller
			if err == nil {
				res.Header().Set(traceHeader, requestId)
			}

			if err != nil {
				type withMeta interface {
					Meta() http.Header
				}

				if err, ok := err.(withMeta); ok {
					err.Meta().Set(traceHeader, requestId)
				}
			}

			return res, err
		}
	})
}

// New creates a new Server with interceptors applied.
func New(logConf logging.InterceptorConf, interceptors ...connect.Interceptor) *Server {
	// Ordering of interceptors matter! First interceptors in the list get
	// called first.
	allInterceptors := []connect.Interceptor{
		addContextLogger(),
		addRequestID(),
		panicInterceptor(),
		logging.Interceptor(logConf),
	}

	allInterceptors = append(allInterceptors, interceptors...)

	mux := http.NewServeMux()

	return &Server{mux: mux, interceptors: allInterceptors}
}

// Server exposes a set of Connect APIs over both gRPC and HTTP. It supports
// health checks out of the box. Reflection is enabled, but only for whitelisted
// ip addresses.
type Server struct {
	// used for creating health and reflect services
	services []string

	pprof bool

	mux    *http.ServeMux
	server *http.Server
	health *grpchealth.StaticChecker

	interceptors []connect.Interceptor
}

var pprofOnce sync.Once

// Serve pprof data. Since we're not specifying a handler in the server,
// it uses the default serve mux. The wildcard import of pprof above
// registers routes to the default serve mux, which is why this seemingly
// pointless code works.
//
// Blog: https://go.dev/blog/pprof
func (s *Server) WithPprof(ctx context.Context) *Server {
	s.pprof = true

	pprofOnce.Do(func() {
		address := "localhost:6060"
		zerolog.Ctx(ctx).Warn().Msgf("server: enabling pprof: %s", address)
		go func() {
			// pprof is registered at the default serve mux when
			// importing the package
			srv := httpServer(address, http.DefaultServeMux)
			err := srv.ListenAndServe()
			if err != nil {
				zerolog.Ctx(ctx).Err(err).Msg("server: serve pprof")
			}
		}()
	})

	return s
}

func (s *Server) Handler() http.Handler {
	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// If the body is completely empty, replace it with the
		// empty object. This makes it possible to send requests
		// without a body, without getting a cryptic error.
		if r.ContentLength == 0 && r.Header.Get("Content-Type") == "application/json" {
			r.Body = io.NopCloser(strings.NewReader(`{}`))
		}

		s.mux.ServeHTTP(w, r)
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
		log.Debug().Msgf("serve connect: enabling reflection: %s", joinedServices)

		reflector := grpcreflect.NewStaticReflector(s.services...)
		s.mux.Handle(grpcreflect.NewHandlerV1(reflector))
		s.mux.Handle(grpcreflect.NewHandlerV1Alpha(reflector))
	}

	log.Debug().Msgf("serve connect: enabling health check: %s", joinedServices)

	s.health = grpchealth.NewStaticChecker(services...)
	s.mux.Handle(grpchealth.NewHandler(s.health))

	var lc net.ListenConfig
	lis, err := lc.Listen(ctx, "tcp", address)
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
		Handler:           s.Handler(),
		ReadHeaderTimeout: time.Minute,
	}

	if err := s.server.Serve(lis); err != nil && !errors.Is(err, http.ErrServerClosed) {
		return fmt.Errorf("serve: %w", err)
	}

	return nil
}

func (s *Server) SetHealthStatus(service string, status grpchealth.Status) {
	s.health.SetStatus(service, status)
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

// Register a new service with the server. This is not part of the Server API
// because this is generic function.
func Register[T any](
	s *Server,
	handler func(svc T, opts ...connect.HandlerOption) (string, http.Handler),
	svc T,
) {
	service, h := handler(svc,
		connect.WithInterceptors(s.interceptors...),
		connect.WithCodec(protoJsonCodec{}),
	)

	s.services = append(s.services, service)
	s.mux.Handle(service, h)
}

// returns a HTTP server with sensible defaults.
func httpServer(addr string, handler http.Handler) *http.Server {
	/// Enable panic recovery with logging
	if handler, ok := handler.(*mux.Router); ok {
		handler.Use(func(handler http.Handler) http.Handler {
			return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				defer func() {
					defer func() {
						if err := recover(); err != nil {
							stack := string(debug.Stack())
							// Add a regular ol' stack print here, as that's
							// much easier to see in the console
							fmt.Println(stack)

							w.WriteHeader(http.StatusInternalServerError)
							zerolog.Ctx(r.Context()).Error().
								Err(fmt.Errorf("%v", err)).
								Str("stack", stack).
								Msg("recovered from panic while serving HTTP")
						}
					}()
				}()
				handler.ServeHTTP(w, r)
			})
		})
	}

	return &http.Server{
		Addr:    addr,
		Handler: handler,

		// To please the linter: without this we're apparently susceptible
		// to a slow loris attack.
		ReadHeaderTimeout: time.Second * 30,
	}
}

// PanicInterceptor ensures we never crash with a panic when serving
// Cribbed from https://github.com/grpc-ecosystem/go-grpc-middleware
func panicInterceptor() connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (resp connect.AnyResponse, err error) {
			panicked := true

			defer func() {
				if r := recover(); r != nil || panicked {
					err = recoverFrom(ctx, r)
				}
			}()

			resp, err = next(ctx, req)
			panicked = false
			return resp, err
		}
	}
}

func recoverFrom(ctx context.Context, panic any) error {
	err := fmt.Errorf("panic: %v", panic)

	zerolog.Ctx(ctx).Warn().Stack().Err(err).
		Interface("panic", panic).
		Msg("recovered while serving Connect")

	fmt.Println(string(debug.Stack()))

	return err
}
