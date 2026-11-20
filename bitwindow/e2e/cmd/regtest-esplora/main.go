// Command regtest-esplora serves the Esplora REST API of a regtest Bitcoin
// Core node, so a light-mode BitWindow can read a local regtest chain. With
// --control it also serves the test routes that mine blocks and pay addresses.
package main

import (
	"context"
	"errors"
	"flag"
	"fmt"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"
)

func main() {
	listen := flag.String("listen", "127.0.0.1:19460", "host:port to serve on")
	rpcURL := flag.String("rpc-url", "http://127.0.0.1:19443", "Bitcoin Core RPC URL")
	rpcUser := flag.String("rpc-user", "user", "Bitcoin Core RPC user")
	rpcPass := flag.String("rpc-pass", "password", "Bitcoin Core RPC password")
	wallet := flag.String("wallet", "qa", "Core wallet that funds /regtest/send and takes the mined coins")
	control := flag.Bool("control", false, "serve the /regtest test routes")
	flag.Parse()

	if err := run(*listen, *rpcURL, *rpcUser, *rpcPass, *wallet, *control); err != nil {
		fmt.Fprintf(os.Stderr, "regtest-esplora: %v\n", err)
		os.Exit(1)
	}
}

func run(listen, rpcURL, rpcUser, rpcPass, wallet string, control bool) error {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()

	core := &coreRPC{url: rpcURL, user: rpcUser, pass: rpcPass, client: &http.Client{Timeout: 30 * time.Second}}
	idx := newIndex(core)
	mux := http.NewServeMux()
	registerEsplora(mux, idx)
	if control {
		registerControl(mux, core, idx, wallet)
	}

	server := &http.Server{Addr: listen, Handler: logRequests(mux), ReadHeaderTimeout: 10 * time.Second}
	errs := make(chan error, 1)
	go func() { errs <- server.ListenAndServe() }()
	log.Printf("serve the regtest Esplora API on %s (control routes: %t)", listen, control)

	select {
	case err := <-errs:
		return err
	case <-ctx.Done():
	}
	shutdown, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	if err := server.Shutdown(shutdown); err != nil && !errors.Is(err, http.ErrServerClosed) {
		return err
	}
	return nil
}

type statusRecorder struct {
	http.ResponseWriter
	status int
}

func (r *statusRecorder) WriteHeader(status int) {
	r.status = status
	r.ResponseWriter.WriteHeader(status)
}

func logRequests(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		rec := &statusRecorder{ResponseWriter: w, status: http.StatusOK}
		next.ServeHTTP(rec, r)
		if rec.status >= 400 || os.Getenv("REGTEST_ESPLORA_LOG_ALL") != "" {
			log.Printf("%s %s -> %d", r.Method, r.URL.Path, rec.status)
		}
	})
}
