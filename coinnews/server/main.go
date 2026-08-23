// coinnews-server is a standalone read-only indexer for the CoinNews
// OP_RETURN protocol (see ../codec). It connects to a Bitcoin Core
// node, persists decoded messages into SQLite, and exposes them via
// ConnectRPC for the Next.js frontend in ../app.
package main

import (
	"context"
	"flag"
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"strconv"
	"syscall"
	"time"

	"connectrpc.com/grpcreflect"
	"github.com/rs/zerolog"

	"github.com/LayerTwo-Labs/sidesail/coinnews/server/api"
	connectrpc "github.com/LayerTwo-Labs/sidesail/coinnews/server/gen/coinnews/v1/coinnewsv1connect"
	"github.com/LayerTwo-Labs/sidesail/coinnews/server/scanner"
	"github.com/LayerTwo-Labs/sidesail/coinnews/server/store"
)

// h2cProtocols serves cleartext HTTP/2 alongside HTTP/1, which connect-go's
// gRPC protocol needs.
func h2cProtocols() *http.Protocols {
	protocols := new(http.Protocols)
	protocols.SetHTTP1(true)
	protocols.SetUnencryptedHTTP2(true)
	return protocols
}

func main() {
	scanFromEnv, scanFromErr := envUint("COINNEWS_SCAN_FROM_HEIGHT", 0)

	var (
		listen         = flag.String("listen", envOr("COINNEWS_LISTEN", "0.0.0.0:8080"), "HTTP listen address")
		dbPath         = flag.String("db", envOr("COINNEWS_DB", "./coinnews.db"), "SQLite path")
		bitcoindURL    = flag.String("bitcoind-url", envOr("COINNEWS_BITCOIND_URL", "http://127.0.0.1:38332"), "Bitcoin Core RPC URL")
		bitcoindUser   = flag.String("bitcoind-user", envOr("COINNEWS_BITCOIND_USER", "user"), "Bitcoin Core RPC user")
		bitcoindPass   = flag.String("bitcoind-pass", envOr("COINNEWS_BITCOIND_PASS", "password"), "Bitcoin Core RPC password")
		bitcoindCookie = flag.String("bitcoind-cookie", envOr("COINNEWS_BITCOIND_COOKIE", ""), "Path to a Bitcoin Core .cookie file (contents: user:password); overrides -bitcoind-user/-bitcoind-pass when set")
		network        = flag.String("network", envOr("COINNEWS_NETWORK", "signet"), "Network label (mainnet/signet/testnet/regtest) — informational")
		scan           = flag.Bool("scan", envBool("COINNEWS_SCAN", true), "Run the block scanner; set false for read-only API mode")
		scanFrom       = flag.Uint("scan-from-height", uint(scanFromEnv), "First block to index; moves a lagging cursor forward, never rewinds. Use a chain's fork height to skip blocks that carry no CoinNews")
	)
	flag.Parse()

	log := zerolog.New(zerolog.ConsoleWriter{Out: os.Stderr, TimeFormat: time.RFC3339}).
		With().Timestamp().Str("network", *network).Logger()

	if scanFromErr != nil {
		log.Fatal().Err(scanFromErr).Msg("COINNEWS_SCAN_FROM_HEIGHT")
	}

	// A cookie file lets us share Bitcoin Core's auto-generated
	// `__cookie__:<pass>` credentials (e.g. a mounted Docker secret)
	// instead of hardcoding a static rpcauth user/pass. Read it here only to
	// fail fast on a bad path; the client re-reads it per call.
	if *bitcoindCookie != "" {
		if _, _, err := scanner.ReadCookie(*bitcoindCookie); err != nil {
			log.Fatal().Err(err).Str("file", *bitcoindCookie).Msg("read bitcoind cookie file")
		}
	}

	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer cancel()

	db, err := store.Open(ctx, *dbPath)
	if err != nil {
		log.Fatal().Err(err).Str("db", *dbPath).Msg("open store")
	}
	defer db.Close() //nolint:errcheck

	if *scan {
		go func() {
			s := &scanner.Scanner{
				Client: &scanner.Client{
					URL:        *bitcoindURL,
					User:       *bitcoindUser,
					Pass:       *bitcoindPass,
					CookiePath: *bitcoindCookie,
					HTTP:       &http.Client{Timeout: 30 * time.Second},
				},
				DB:           db,
				Log:          log.With().Str("component", "scanner").Logger(),
				PollInterval: 5 * time.Second,
				FromHeight:   uint32(*scanFrom),
			}
			if err := s.Run(ctx); err != nil {
				log.Error().Err(err).Msg("scanner exited")
			}
		}()
	}

	mux := http.NewServeMux()
	path, handler := connectrpc.NewCoinNewsServiceHandler(&api.Handler{DB: db})
	mux.Handle(path, handler)

	// Server reflection lets grpcurl/buf curl and other generic
	// clients discover the service without a local copy of the proto.
	reflector := grpcreflect.NewStaticReflector(connectrpc.CoinNewsServiceName)
	mux.Handle(grpcreflect.NewHandlerV1(reflector))
	mux.Handle(grpcreflect.NewHandlerV1Alpha(reflector))
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("ok\n"))
	})

	log.Info().Str("listen", *listen).Str("rpc_path", path).Msg("coinnews-server: starting")
	srv := &http.Server{
		Addr:              *listen,
		Handler:           corsMiddleware(mux),
		Protocols:         h2cProtocols(),
		ReadHeaderTimeout: 10 * time.Second,
	}

	go func() {
		<-ctx.Done()
		shutdownCtx, sCancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer sCancel()
		_ = srv.Shutdown(shutdownCtx)
	}()

	if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
		log.Fatal().Err(err).Msg("server")
	}
	log.Info().Msg("coinnews-server: shutdown clean")
}

// corsMiddleware allows the Next.js frontend (different host in
// production) to call the RPC server in the browser. Permissive on
// purpose — this server is read-only public data.
func corsMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
		w.Header().Set("Access-Control-Allow-Headers", "*")
		w.Header().Set("Access-Control-Expose-Headers", "Connect-Protocol-Version, Connect-Timeout-Ms, Grpc-Timeout, Grpc-Status, Grpc-Message")
		if r.Method == http.MethodOptions {
			w.WriteHeader(http.StatusNoContent)
			return
		}
		next.ServeHTTP(w, r)
	})
}

func envOr(key, fallback string) string {
	if v, ok := os.LookupEnv(key); ok {
		return v
	}
	return fallback
}

// envUint reads a uint32-ranged value. A set-but-unparsable value is an
// error, never the fallback: a silent 0 here sends the scanner back to
// genesis, which is the cost the setting exists to avoid.
func envUint(key string, fallback uint64) (uint64, error) {
	v, ok := os.LookupEnv(key)
	if !ok {
		return fallback, nil
	}
	n, err := strconv.ParseUint(v, 10, 32)
	if err != nil {
		return 0, fmt.Errorf("%s=%q: want a whole number that fits in 32 bits", key, v)
	}
	return n, nil
}

func envBool(key string, fallback bool) bool {
	v, ok := os.LookupEnv(key)
	if !ok {
		return fallback
	}
	switch v {
	case "1", "true", "TRUE", "True":
		return true
	default:
		return false
	}
}

// silence unused-import linter when the scanner is disabled at compile
// (not currently — left as documentation that fmt is intentional).
var _ = fmt.Sprintf
