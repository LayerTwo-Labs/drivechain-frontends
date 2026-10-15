package drivechain

import (
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// The index answers the escrow the mainchain holds. A light install reads every
// sidechain from here, so the shapes must match what the service sends.
func TestEscrowIndexReadsTheChain(t *testing.T) {
	var path string
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		path = r.URL.Path
		_, _ = w.Write([]byte(`[
			{"slot":2,"title":"BitNames","description":"names","vote_count":73,
			 "proposal_height":987283,"activation_height":987402,
			 "treasury":{"txid":"aa","vout":1,"value_sats":100007100}},
			{"slot":4,"title":"BitAssets","description":"assets","vote_count":73,
			 "proposal_height":987283,"activation_height":987402,"treasury":null}]`))
	}))
	defer server.Close()

	got, err := newEscrowIndex(server.URL).Sidechains(t.Context())
	require.NoError(t, err)
	assert.Equal(t, "/sidechains", path)
	require.Len(t, got, 2)

	first := got[0]
	assert.EqualValues(t, 2, first.Slot)
	assert.Equal(t, "BitNames", first.Title)
	assert.EqualValues(t, 73, first.VoteCount)
	assert.EqualValues(t, 100007100, first.BalanceSatoshi)
	assert.Equal(t, "aa", first.ChaintipTxid)
	assert.EqualValues(t, 1, first.ChaintipVout)
	// A slot with no treasury reads as zero here, because the wire has no way
	// to say "none". It must not carry another chain's outpoint.
	assert.Zero(t, got[1].BalanceSatoshi)
	assert.Empty(t, got[1].ChaintipTxid)
}

// A down index must report an error, never an empty list that reads as "no
// sidechains exist".
func TestEscrowIndexReportsAFailure(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		http.Error(w, "no enforcer behind me", http.StatusServiceUnavailable)
	}))
	defer server.Close()

	_, err := newEscrowIndex(server.URL).Sidechains(t.Context())
	require.ErrorContains(t, err, "the index answered 503")
}
