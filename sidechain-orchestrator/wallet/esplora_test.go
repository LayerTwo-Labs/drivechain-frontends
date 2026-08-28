package wallet

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

// TestEsploraAddressTxsPaginationUsesConfirmedCursor verifies AddressTxs
// paginates by the oldest confirmed tx in a page, not the last element. Esplora
// returns confirmed history newest-first and the chain endpoint only accepts a
// confirmed txid, so a page whose final element is a mempool tx must not be used
// as the cursor.
func TestEsploraAddressTxsPaginationUsesConfirmedCursor(t *testing.T) {
	page1 := make([]EsploraTx, 0, 26)
	for i := 0; i < 25; i++ {
		page1 = append(page1, EsploraTx{
			TxID:   fmt.Sprintf("c%d", i),
			Status: EsploraStatus{Confirmed: true, BlockHeight: 100 - i},
		})
	}
	// A mempool tx as the final element — the naive "last element is the cursor"
	// approach would query /txs/chain/m0 and fail.
	page1 = append(page1, EsploraTx{TxID: "m0", Status: EsploraStatus{Confirmed: false}})
	page2 := []EsploraTx{{TxID: "c25", Status: EsploraStatus{Confirmed: true, BlockHeight: 75}}}

	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case "/api/address/A/txs":
			_ = json.NewEncoder(w).Encode(page1)
		case "/api/address/A/txs/chain/c24": // oldest confirmed in page1
			_ = json.NewEncoder(w).Encode(page2)
		default:
			http.Error(w, "unexpected cursor: "+r.URL.Path, http.StatusNotFound)
		}
	}))
	defer srv.Close()

	client := NewEsploraClient([]string{srv.URL + "/api"}, zerolog.Nop())
	txs, err := client.AddressTxs(context.Background(), "A")
	require.NoError(t, err)
	require.Len(t, txs, 27, "all pages must be fetched via the confirmed cursor")
}

// outspendStub answers the status and outspend paths for one transaction.
func outspendStub(t *testing.T, txid string, knowsTx bool, spent string, hits *int) string {
	t.Helper()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		*hits++
		switch r.URL.Path {
		case "/api/tx/" + txid + "/status":
			if !knowsTx {
				http.Error(w, "not found", http.StatusNotFound)
				return
			}
			_, _ = w.Write([]byte(`{"confirmed":true}`))
		case "/api/tx/" + txid + "/outspend/0":
			_, _ = w.Write([]byte(spent))
		default:
			http.Error(w, "unexpected path: "+r.URL.Path, http.StatusNotFound)
		}
	}))
	t.Cleanup(srv.Close)
	return srv.URL + "/api"
}

// TestEsploraOutspendKeepsOneProvider: a server answers "not spent" for a
// transaction it never saw. Taking that answer from one server and the
// transaction from another reports a spent coin as unspent.
func TestEsploraOutspendKeepsOneProvider(t *testing.T) {
	const txid = "aa"
	var blindHits, knowingHits int
	blind := outspendStub(t, txid, false, `{"spent":false}`, &blindHits)
	knowing := outspendStub(t, txid, true, `{"spent":true,"status":{"confirmed":true}}`, &knowingHits)

	client := NewEsploraClient([]string{blind, knowing}, zerolog.Nop())
	out, found, err := client.Outspend(context.Background(), txid, 0)
	require.NoError(t, err)
	require.True(t, found)
	require.True(t, out.Spent, "the answer must come from the server that holds the transaction")
	// The spend answer comes first, then the transaction check exposes the
	// server that does not hold it.
	require.Equal(t, 2, blindHits)
}

// TestEsploraOutspendUnknownEverywhere: no server holds the transaction, so the
// coin is not one Bitcoin knows.
func TestEsploraOutspendUnknownEverywhere(t *testing.T) {
	const txid = "aa"
	var a, b int
	client := NewEsploraClient([]string{
		outspendStub(t, txid, false, `{"spent":false}`, &a),
		outspendStub(t, txid, false, `{"spent":false}`, &b),
	}, zerolog.Nop())

	_, found, err := client.Outspend(context.Background(), txid, 0)
	require.NoError(t, err)
	require.False(t, found)
	require.Equal(t, 2, a)
	require.Equal(t, 2, b)
}

// TestEsploraOutspendEvictedTransaction: a transaction can drop out of the
// mempool between the two reads. The coin must read as absent, because the
// engine caches an "unspent" answer forever.
func TestEsploraOutspendEvictedTransaction(t *testing.T) {
	const txid = "aa"
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/api/tx/"+txid+"/status" {
			http.Error(w, "not found", http.StatusNotFound)
			return
		}
		_, _ = w.Write([]byte(`{"spent":false}`))
	}))
	defer srv.Close()

	client := NewEsploraClient([]string{srv.URL + "/api"}, zerolog.Nop())
	_, found, err := client.Outspend(context.Background(), txid, 0)
	require.NoError(t, err)
	require.False(t, found)
}
