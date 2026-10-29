// difficulty serves a live page of eCash difficulty retargets, read from a
// local node.
package main

import (
	"context"
	_ "embed"
	"encoding/json"
	"flag"
	"log"
	"net/http"
	"sync"
	"time"
)

//go:embed index.html
var indexHTML []byte

type server struct {
	mu    sync.RWMutex
	state State
}

func (s *server) refresh(ctx context.Context, b *Builder) {
	ctx, cancel := context.WithTimeout(ctx, 20*time.Second)
	defer cancel()
	st, err := b.Build(ctx, time.Now().Unix())
	s.mu.Lock()
	defer s.mu.Unlock()
	if err != nil {
		log.Printf("refresh: %v", err)
		s.state.Error = err.Error()
		return
	}
	s.state = st
}

func (s *server) handleState(w http.ResponseWriter, _ *http.Request) {
	s.mu.RLock()
	body, err := json.Marshal(s.state)
	s.mu.RUnlock()
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Cache-Control", "no-store")
	if _, err := w.Write(body); err != nil {
		log.Printf("write state: %v", err)
	}
}

func handleIndex(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	if _, err := w.Write(indexHTML); err != nil {
		log.Printf("write page: %v", err)
	}
}

func main() {
	listen := flag.String("listen", "127.0.0.1:8133", "address to serve on")
	rpcURL := flag.String("rpc-url", "http://127.0.0.1:18302", "JSON-RPC URL of the eCash node")
	cookie := flag.String("rpc-cookie", "", "path to the node's .cookie file")
	fork := flag.Int64("fork-height", 973728, "height of the eCash fork block")
	every := flag.Duration("refresh", time.Second, "time between chain reads")
	flag.Parse()
	if *cookie == "" {
		log.Fatal("set --rpc-cookie")
	}

	core := &Core{url: *rpcURL, cookiePath: *cookie, http: &http.Client{Timeout: 15 * time.Second}}
	builder := NewBuilder(core, *fork)
	srv := &server{}
	ctx := context.Background()
	srv.refresh(ctx, builder)
	go func() {
		for range time.Tick(*every) {
			srv.refresh(ctx, builder)
		}
	}()

	mux := http.NewServeMux()
	mux.HandleFunc("GET /api/state", srv.handleState)
	mux.HandleFunc("GET /", handleIndex)
	httpServer := &http.Server{
		Addr:              *listen,
		Handler:           mux,
		ReadHeaderTimeout: 10 * time.Second,
	}
	log.Printf("serving %s from %s", *listen, *rpcURL)
	log.Fatal(httpServer.ListenAndServe())
}
