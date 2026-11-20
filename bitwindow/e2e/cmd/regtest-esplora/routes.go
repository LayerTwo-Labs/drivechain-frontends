package main

import (
	"encoding/json"
	"errors"
	"io"
	"net/http"
	"strconv"
	"strings"
)

const (
	chainPage   = 25
	mempoolPage = 50
	blocksPage  = 10
)

func writeJSON(w http.ResponseWriter, v any) {
	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(v); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

func writeText(w http.ResponseWriter, s string) {
	w.Header().Set("Content-Type", "text/plain")
	if _, err := io.WriteString(w, s); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
}

// handler serves one route from a chain state.
type handler func(w http.ResponseWriter, r *http.Request, st *chainState)

func (x *index) serve(h handler) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		st, err := x.read(r.Context())
		if err != nil {
			http.Error(w, err.Error(), http.StatusBadGateway)
			return
		}
		h(w, r, st)
	}
}

func registerEsplora(mux *http.ServeMux, x *index) {
	mux.HandleFunc("GET /blocks/tip/height", x.serve(func(w http.ResponseWriter, _ *http.Request, st *chainState) {
		writeText(w, strconv.Itoa(len(st.blocks)-1))
	}))
	mux.HandleFunc("GET /blocks/tip/hash", x.serve(func(w http.ResponseWriter, _ *http.Request, st *chainState) {
		writeText(w, st.tipHash)
	}))
	mux.HandleFunc("GET /blocks", x.serve(func(w http.ResponseWriter, _ *http.Request, st *chainState) {
		writeJSON(w, blocksFrom(st, len(st.blocks)-1))
	}))
	mux.HandleFunc("GET /blocks/{start}", x.serve(func(w http.ResponseWriter, r *http.Request, st *chainState) {
		start, err := strconv.Atoi(r.PathValue("start"))
		if err != nil {
			http.Error(w, "bad height", http.StatusBadRequest)
			return
		}
		writeJSON(w, blocksFrom(st, start))
	}))
	mux.HandleFunc("GET /block-height/{height}", x.serve(func(w http.ResponseWriter, r *http.Request, st *chainState) {
		h, err := strconv.Atoi(r.PathValue("height"))
		if err != nil || h < 0 || h >= len(st.blocks) {
			http.Error(w, "Block not found", http.StatusNotFound)
			return
		}
		writeText(w, st.blocks[h].ID)
	}))
	mux.HandleFunc("GET /block/{hash}", x.serve(withBlock(func(w http.ResponseWriter, _ *http.Request, _ *chainState, b *block) {
		writeJSON(w, b)
	})))
	mux.HandleFunc("GET /block/{hash}/status", x.serve(withBlock(func(w http.ResponseWriter, _ *http.Request, st *chainState, b *block) {
		next := ""
		if b.Height+1 < len(st.blocks) {
			next = st.blocks[b.Height+1].ID
		}
		writeJSON(w, map[string]any{"in_best_chain": true, "height": b.Height, "next_best": next})
	})))
	mux.HandleFunc("GET /block/{hash}/txids", x.serve(withBlock(func(w http.ResponseWriter, _ *http.Request, _ *chainState, b *block) {
		writeJSON(w, b.txids)
	})))
	blockTxs := withBlock(func(w http.ResponseWriter, r *http.Request, st *chainState, b *block) {
		start := 0
		if raw := r.PathValue("start"); raw != "" {
			var err error
			if start, err = strconv.Atoi(raw); err != nil || start < 0 {
				http.Error(w, "bad start index", http.StatusBadRequest)
				return
			}
		}
		out := []*tx{}
		for i := start; i < len(b.txids) && len(out) < chainPage; i++ {
			out = append(out, st.txs[b.txids[i]])
		}
		writeJSON(w, out)
	})
	mux.HandleFunc("GET /block/{hash}/txs", x.serve(blockTxs))
	mux.HandleFunc("GET /block/{hash}/txs/{start}", x.serve(blockTxs))

	mux.HandleFunc("GET /tx/{txid}", x.serve(withTx(func(w http.ResponseWriter, _ *http.Request, _ *chainState, t *tx) {
		writeJSON(w, t)
	})))
	mux.HandleFunc("GET /tx/{txid}/hex", x.serve(withTx(func(w http.ResponseWriter, _ *http.Request, _ *chainState, t *tx) {
		writeText(w, t.hex)
	})))
	mux.HandleFunc("GET /tx/{txid}/status", x.serve(withTx(func(w http.ResponseWriter, _ *http.Request, _ *chainState, t *tx) {
		writeJSON(w, t.Status)
	})))
	mux.HandleFunc("GET /tx/{txid}/outspend/{vout}", x.serve(withTx(func(w http.ResponseWriter, r *http.Request, st *chainState, t *tx) {
		n, err := strconv.Atoi(r.PathValue("vout"))
		if err != nil || n < 0 || n >= len(t.Vout) {
			http.Error(w, "bad output index", http.StatusBadRequest)
			return
		}
		writeJSON(w, outspend(st, t, n))
	})))
	mux.HandleFunc("GET /tx/{txid}/outspends", x.serve(withTx(func(w http.ResponseWriter, _ *http.Request, st *chainState, t *tx) {
		out := make([]map[string]any, len(t.Vout))
		for n := range t.Vout {
			out[n] = outspend(st, t, n)
		}
		writeJSON(w, out)
	})))
	mux.HandleFunc("POST /tx", func(w http.ResponseWriter, r *http.Request) {
		raw, err := io.ReadAll(io.LimitReader(r.Body, 4<<20))
		if err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		var txid string
		if err := x.core.call(r.Context(), "", "sendrawtransaction", []any{strings.TrimSpace(string(raw))}, &txid); err != nil {
			status := http.StatusBadGateway
			var rpcErr *rpcError
			if errors.As(err, &rpcErr) {
				status = http.StatusBadRequest
			}
			http.Error(w, err.Error(), status)
			return
		}
		x.invalidate()
		writeText(w, txid)
	})

	mux.HandleFunc("GET /address/{addr}", x.serve(func(w http.ResponseWriter, r *http.Request, st *chainState) {
		addr := r.PathValue("addr")
		chainStats, mempoolStats := st.addressStats(addr)
		writeJSON(w, map[string]any{"address": addr, "chain_stats": chainStats, "mempool_stats": mempoolStats})
	}))
	mux.HandleFunc("GET /address/{addr}/utxo", x.serve(func(w http.ResponseWriter, r *http.Request, st *chainState) {
		writeJSON(w, st.addressUTXOs(r.PathValue("addr")))
	}))
	mux.HandleFunc("GET /address/{addr}/txs", x.serve(func(w http.ResponseWriter, r *http.Request, st *chainState) {
		mempool, chain := st.addressTxs(r.PathValue("addr"))
		writeJSON(w, append(limit(mempool, mempoolPage), limit(chain, chainPage)...))
	}))
	mux.HandleFunc("GET /address/{addr}/txs/mempool", x.serve(func(w http.ResponseWriter, r *http.Request, st *chainState) {
		mempool, _ := st.addressTxs(r.PathValue("addr"))
		writeJSON(w, limit(mempool, mempoolPage))
	}))
	chainTxs := func(w http.ResponseWriter, r *http.Request, st *chainState) {
		_, chain := st.addressTxs(r.PathValue("addr"))
		if last := r.PathValue("last"); last != "" {
			at := -1
			for i, t := range chain {
				if t.TxID == last {
					at = i
				}
			}
			if at < 0 {
				http.Error(w, "unknown last seen txid", http.StatusBadRequest)
				return
			}
			chain = chain[at+1:]
		}
		writeJSON(w, limit(chain, chainPage))
	}
	mux.HandleFunc("GET /address/{addr}/txs/chain", x.serve(chainTxs))
	mux.HandleFunc("GET /address/{addr}/txs/chain/{last}", x.serve(chainTxs))

	mux.HandleFunc("GET /mempool", x.serve(func(w http.ResponseWriter, _ *http.Request, st *chainState) {
		var vsize, fees int64
		for _, txid := range st.mempool {
			t := st.txs[txid]
			vsize += int64((t.Weight + 3) / 4)
			fees += t.Fee
		}
		writeJSON(w, map[string]any{"count": len(st.mempool), "vsize": vsize, "total_fee": fees, "fee_histogram": [][]float64{}})
	}))
	mux.HandleFunc("GET /mempool/txids", x.serve(func(w http.ResponseWriter, _ *http.Request, st *chainState) {
		writeJSON(w, append([]string{}, st.mempool...))
	}))
	mux.HandleFunc("GET /fee-estimates", func(w http.ResponseWriter, _ *http.Request) {
		writeJSON(w, regtestFeeEstimates)
	})
}

// regtestFeeEstimates is the fee table of this server. A regtest node has no
// fee market, so Core's estimator answers nothing.
var regtestFeeEstimates = map[string]float64{
	"1": 5, "2": 4, "3": 3, "6": 2, "12": 1.5, "25": 1.2, "144": 1, "504": 1, "1008": 1,
}

func limit(txs []*tx, n int) []*tx {
	if len(txs) > n {
		return txs[:n]
	}
	if txs == nil {
		return []*tx{}
	}
	return txs
}

func blocksFrom(st *chainState, start int) []*block {
	out := []*block{}
	if start >= len(st.blocks) {
		start = len(st.blocks) - 1
	}
	for h := start; h >= 0 && len(out) < blocksPage; h-- {
		out = append(out, st.blocks[h])
	}
	return out
}

func outspend(st *chainState, t *tx, n int) map[string]any {
	s, ok := st.spentBy[outpoint{t.TxID, n}]
	if !ok {
		return map[string]any{"spent": false}
	}
	return map[string]any{"spent": true, "txid": s.txid, "vin": s.vin, "status": st.txs[s.txid].Status}
}

func withBlock(h func(http.ResponseWriter, *http.Request, *chainState, *block)) handler {
	return func(w http.ResponseWriter, r *http.Request, st *chainState) {
		b, ok := st.byHash[r.PathValue("hash")]
		if !ok {
			http.Error(w, "Block not found", http.StatusNotFound)
			return
		}
		h(w, r, st, b)
	}
}

func withTx(h func(http.ResponseWriter, *http.Request, *chainState, *tx)) handler {
	return func(w http.ResponseWriter, r *http.Request, st *chainState) {
		t, ok := st.txs[r.PathValue("txid")]
		if !ok {
			http.Error(w, "Transaction not found", http.StatusNotFound)
			return
		}
		h(w, r, st, t)
	}
}
