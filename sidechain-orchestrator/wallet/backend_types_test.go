package wallet

import (
	"encoding/json"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestWalletTransactionReplaced(t *testing.T) {
	const listed = `[
		{"txid": "old", "category": "send", "confirmations": 0, "mempoolconflicts": ["new"]},
		{"txid": "new", "category": "send", "confirmations": 0, "mempoolconflicts": []},
		{"txid": "gone", "category": "send", "confirmations": -1, "mempoolconflicts": []},
		{"txid": "mined", "category": "send", "confirmations": 2}
	]`
	var txs []WalletTransaction
	require.NoError(t, json.Unmarshal([]byte(listed), &txs))

	replaced := map[string]bool{}
	for _, tx := range txs {
		replaced[tx.TxID] = tx.Replaced()
	}
	assert.Equal(t, map[string]bool{"old": true, "new": false, "gone": false, "mined": false}, replaced)
}
