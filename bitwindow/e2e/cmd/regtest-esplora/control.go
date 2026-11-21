package main

import (
	"encoding/json"
	"fmt"
	"net/http"
)

// registerControl adds the test routes. They mine blocks and pay from the Core
// wallet, so they serve a test stack only.
func registerControl(mux *http.ServeMux, core *coreRPC, x *index, wallet string) {
	mux.HandleFunc("POST /regtest/mine", func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Blocks  int    `json:"blocks"`
			Address string `json:"address"`
		}
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, fmt.Sprintf("decode: %v", err), http.StatusBadRequest)
			return
		}
		if req.Blocks < 1 || req.Blocks > 1000 {
			http.Error(w, "blocks must be 1 to 1000", http.StatusBadRequest)
			return
		}
		if req.Address == "" {
			if err := core.call(r.Context(), wallet, "getnewaddress", nil, &req.Address); err != nil {
				http.Error(w, err.Error(), http.StatusBadGateway)
				return
			}
		}
		var hashes []string
		if err := core.call(r.Context(), "", "generatetoaddress", []any{req.Blocks, req.Address}, &hashes); err != nil {
			http.Error(w, err.Error(), http.StatusBadGateway)
			return
		}
		x.invalidate()
		writeJSON(w, map[string]any{"hashes": hashes})
	})

	mux.HandleFunc("POST /regtest/send", func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Address string      `json:"address"`
			Amount  json.Number `json:"amount_btc"`
		}
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, fmt.Sprintf("decode: %v", err), http.StatusBadRequest)
			return
		}
		if req.Address == "" || req.Amount == "" {
			http.Error(w, "give an address and amount_btc", http.StatusBadRequest)
			return
		}
		var txid string
		if err := core.call(r.Context(), wallet, "sendtoaddress", []any{req.Address, req.Amount}, &txid); err != nil {
			http.Error(w, err.Error(), http.StatusBadGateway)
			return
		}
		x.invalidate()
		writeJSON(w, map[string]any{"txid": txid})
	})

	mux.HandleFunc("GET /regtest/newaddress", func(w http.ResponseWriter, r *http.Request) {
		var addr string
		if err := core.call(r.Context(), wallet, "getnewaddress", nil, &addr); err != nil {
			http.Error(w, err.Error(), http.StatusBadGateway)
			return
		}
		writeJSON(w, map[string]any{"address": addr})
	})

	mux.HandleFunc("GET /regtest/tx/{txid}", func(w http.ResponseWriter, r *http.Request) {
		var out map[string]any
		if err := core.call(r.Context(), "", "getrawtransaction", []any{r.PathValue("txid"), 1}, &out); err != nil {
			http.Error(w, err.Error(), http.StatusNotFound)
			return
		}
		writeJSON(w, out)
	})
}
