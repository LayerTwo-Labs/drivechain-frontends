// fulcrum-proxy serves an eCash node's JSON-RPC to Fulcrum. Fulcrum reads a
// node as Bitcoin Core only when its user agent starts with "/Satoshi:", and
// indexes any other node as a coin without SegWit.
package main

import (
	"flag"
	"log"
	"net/http"
	"net/url"
	"time"
)

func main() {
	listen := flag.String("listen", "127.0.0.1:18312", "address to serve on")
	upstream := flag.String("upstream", "http://127.0.0.1:18302", "JSON-RPC URL of the eCash node")
	flag.Parse()

	target, err := url.Parse(*upstream)
	if err != nil {
		log.Fatalf("parse upstream: %v", err)
	}

	server := &http.Server{
		Addr:              *listen,
		Handler:           newProxy(target),
		ReadHeaderTimeout: 10 * time.Second,
	}
	log.Printf("serving %s for %s", *listen, target)
	log.Fatal(server.ListenAndServe())
}
