package wallet

import (
	"context"
	"net/http"
	"net/http/httptest"
	"sync/atomic"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

// countingServer answers every request with status and body, and counts them.
func countingServer(t *testing.T, status int, body string, hits *int32) *httptest.Server {
	t.Helper()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		atomic.AddInt32(hits, 1)
		w.WriteHeader(status)
		_, _ = w.Write([]byte(body))
	}))
	t.Cleanup(srv.Close)
	return srv
}

func twoRootClient(a, b string) *EsploraClient {
	c := NewEsploraClient([]string{a, b}, zerolog.Nop())
	c.minInterval = 0
	return c
}

// Each server keeps its own mempool. A broadcast that reached the second host
// only is absent from the first, and a 404 from the first must not read as
// proof: firstTreasuryOf would skip a live deposit and build a rival treasury.
func TestEsploraAsksTheNextRootOnA404(t *testing.T) {
	var absentHits, holderHits int32
	absent := countingServer(t, http.StatusNotFound, "Transaction not found", &absentHits)
	holder := countingServer(t, http.StatusOK, `{"txid":"aa","status":{"confirmed":false}}`, &holderHits)

	tx, err := twoRootClient(absent.URL, holder.URL).Tx(context.Background(), "aa")

	require.NoError(t, err)
	require.Equal(t, "aa", tx.TxID)
	require.Equal(t, int32(1), atomic.LoadInt32(&absentHits))
	require.Equal(t, int32(1), atomic.LoadInt32(&holderHits))
}

// Every root agrees, so the 404 is proof and the caller reads ErrTxNotFound.
func TestEsploraReportsA404EveryRootAgreesOn(t *testing.T) {
	var firstHits, secondHits int32
	first := countingServer(t, http.StatusNotFound, "Transaction not found", &firstHits)
	second := countingServer(t, http.StatusNotFound, "Transaction not found", &secondHits)

	_, err := twoRootClient(first.URL, second.URL).Tx(context.Background(), "aa")

	require.Error(t, err)
	require.True(t, isNotFound(err))
	require.Equal(t, int32(1), atomic.LoadInt32(&firstHits))
	require.Equal(t, int32(1), atomic.LoadInt32(&secondHits))
}

// The rotation comes back to a root that already answered 404. Counting answers
// instead of roots reads 404, 500, 404 as agreement, and the second root never
// said the transaction is gone.
func TestEsploraKeepsA404UnprovedWhenARootOnlyFails(t *testing.T) {
	var absentHits, brokenHits int32
	absent := countingServer(t, http.StatusNotFound, "Transaction not found", &absentHits)
	broken := countingServer(t, http.StatusInternalServerError, "boom", &brokenHits)

	_, err := twoRootClient(absent.URL, broken.URL).Tx(context.Background(), "aa")

	require.Error(t, err)
	require.False(t, isNotFound(err), "one root alone cannot prove absence")
}

// One root is the whole list, so its 404 ends the read at once. Outspend counts
// on that: it asks each root itself.
func TestEsploraStopsOnA404FromTheOnlyRoot(t *testing.T) {
	var hits int32
	only := countingServer(t, http.StatusNotFound, "Transaction not found", &hits)
	c := NewEsploraClient([]string{only.URL}, zerolog.Nop())
	c.minInterval = 0

	_, err := c.Tx(context.Background(), "aa")

	require.True(t, isNotFound(err))
	require.Equal(t, int32(1), atomic.LoadInt32(&hits))
}
