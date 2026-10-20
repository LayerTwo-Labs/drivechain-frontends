// Command ecash-broadcaster is a connect server with one endpoint,
// BroadcastECashTx, that broadcasts a signed eCash transaction to the node.
package main

import (
	"context"
	"flag"
	"log"
	"net/http"
	"os/signal"
	"syscall"
	"time"

	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/LayerTwo-Labs/sidesail/ecash-broadcaster/gen/ecash/v1/ecashv1connect"
)

func main() {
	listen := flag.String("listen", ":8090", "address to listen on")
	host := flag.String("bitcoind-host", "localhost", "eCash node RPC host")
	port := flag.Int("bitcoind-port", 38332, "eCash node RPC port")
	user := flag.String("bitcoind-rpcuser", "", "eCash node RPC user")
	pass := flag.String("bitcoind-rpcpassword", "", "eCash node RPC password")
	flag.Parse()

	h := &handler{bitcoind: newBitcoindClient(*host, *port, *user, *pass)}

	protocols := new(http.Protocols)
	protocols.SetHTTP1(true)
	protocols.SetUnencryptedHTTP2(true)
	srv := &http.Server{
		Addr:      *listen,
		Handler:   newMux(h),
		Protocols: protocols,
	}

	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	go func() {
		log.Printf("ecash-broadcaster listening on %s, relaying to %s:%d", *listen, *host, *port)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			log.Fatalf("serve: %v", err)
		}
	}()

	<-ctx.Done()
	log.Println("shutting down")
	shutdownCtx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	if err := srv.Shutdown(shutdownCtx); err != nil {
		log.Printf("shutdown: %v", err)
	}
}

func newMux(handler *handler) *http.ServeMux {
	mux := http.NewServeMux()
	server := connect.NewServer()
	ecashv1connect.RegisterECashBroadcastServiceHandler(server, handler)
	connecthttp.Mount(mux, server, connecthttp.WithReadMaxBytes(0))
	return mux
}
