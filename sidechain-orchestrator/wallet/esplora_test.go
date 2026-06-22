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
