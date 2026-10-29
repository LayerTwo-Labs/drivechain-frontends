package wallet

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const (
	betanetLock = 499999999
	mainnetLock = 499999998
)

func TestStrandedTxIDsSelectsOnlyStrandedTxs(t *testing.T) {
	txs := []WalletTransaction{
		{TxID: "confirmed", Category: "send", Confirmations: 3},
		{TxID: "conflicted", Category: "send", Confirmations: -2},
		{TxID: "mempool", Category: "send", Confirmations: 0},
		{TxID: "abandoned", Category: "send", Confirmations: 0, Abandoned: true},
		{TxID: "abandoned", Category: "receive", Confirmations: 0},
		{TxID: "evicted", Category: "send", Confirmations: 0},
		{TxID: "lowfee", Category: "send", Confirmations: 0},
		{TxID: "childofevicted", Category: "send", Confirmations: 0},
		{TxID: "replaylocked", Category: "send", Confirmations: 0},
		{TxID: "replaylocked", Category: "receive", Confirmations: 0},
		{TxID: "spendsretired", Category: "send", Confirmations: 0},
		{TxID: "grandchild", Category: "send", Confirmations: 0},
		{TxID: "childofretired", Category: "send", Confirmations: 0},
		{TxID: "mixedinputs", Category: "send", Confirmations: 0},
		{TxID: "chainandevicted", Category: "send", Confirmations: 0},
	}
	checks := map[string]TxCheck{
		"mempool":         {InMempool: true},
		"abandoned":       {RetiredLock: true},
		"evicted":         {Accepted: true},
		"lowfee":          {},
		"childofevicted":  {MissingInputs: true, Inputs: []TxInput{{Parent: "evicted"}}},
		"replaylocked":    {RetiredLock: true},
		"spendsretired":   {MissingInputs: true, Inputs: []TxInput{{Parent: "external"}}},
		"grandchild":      {MissingInputs: true, Inputs: []TxInput{{Parent: "childofretired"}}},
		"childofretired":  {MissingInputs: true, Inputs: []TxInput{{Parent: "replaylocked"}}},
		"mixedinputs":     {MissingInputs: true, Inputs: []TxInput{{Parent: "evicted"}, {Parent: "external"}}},
		"chainandevicted": {MissingInputs: true, Inputs: []TxInput{{Parent: "onchain", Unspent: true}, {Parent: "evicted"}}},
	}

	assert.Equal(t,
		[]string{"replaylocked", "spendsretired", "grandchild", "childofretired", "mixedinputs"},
		StrandedTxIDs(txs, checks))
}

func stubStrandedChain(fake *fakeBitcoind, walletName string) {
	fake.stubEnsureFlow()
	fake.handle("getblockchaininfo", func(bitcoindCall) (any, string) {
		return map[string]any{"blocks": 980000, "headers": 980000, "initialblockdownload": false}, ""
	})
	fake.handle("listsinceblock", func(c bitcoindCall) (any, string) {
		if c.Wallet != walletName {
			return map[string]any{"transactions": []map[string]any{}}, ""
		}
		return map[string]any{"transactions": []map[string]any{
			{"txid": "confirmed", "category": "receive", "confirmations": 12},
			{"txid": "conflicted", "category": "send", "confirmations": -1},
			{"txid": "mempool", "category": "send", "confirmations": 0, "abandoned": false},
			{"txid": "abandoned", "category": "send", "confirmations": 0, "abandoned": true},
			{"txid": "evicted", "category": "send", "confirmations": 0, "abandoned": false},
			{"txid": "replaylocked", "category": "send", "confirmations": 0, "abandoned": false},
			{"txid": "finalsequence", "category": "send", "confirmations": 0, "abandoned": false},
			{"txid": "spendsretired", "category": "send", "confirmations": 0, "abandoned": false},
		}}, ""
	})
}

func TestCoreBackendReleaseStrandedAbandonsOnlyStrandedTxs(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	name := "wallet_" + coreID[:8]
	stubStrandedChain(fake, name)
	fake.handle("getmempoolentry", func(c bitcoindCall) (any, string) {
		if mustString(t, c.Params[0]) == "mempool" {
			return map[string]any{"vsize": 141}, ""
		}
		return nil, "Transaction not in mempool"
	})
	fake.handle("gettransaction", func(c bitcoindCall) (any, string) {
		txid := mustString(t, c.Params[0])
		lock := 979000
		if txid == "replaylocked" || txid == "finalsequence" {
			lock = betanetLock
		}
		return map[string]any{
			"hex":     "hex-" + txid,
			"decoded": map[string]any{"locktime": lock, "vin": []map[string]any{{"txid": "parent-" + txid}}},
		}, ""
	})
	fake.handle("testmempoolaccept", func(c bitcoindCall) (any, string) {
		var raw []string
		require.NoError(t, json.Unmarshal(c.Params[0], &raw))
		switch raw[0] {
		case "hex-evicted", "hex-finalsequence":
			return []map[string]any{{"allowed": true}}, ""
		case "hex-replaylocked":
			return []map[string]any{{"allowed": false, "reject-reason": "non-final"}}, ""
		}
		return []map[string]any{{"allowed": false, "reject-reason": "missing-inputs"}}, ""
	})
	fake.handle("abandontransaction", func(bitcoindCall) (any, string) { return nil, "" })

	done, err := backend.ReleaseStranded(context.Background(), []uint32{betanetLock})
	require.NoError(t, err)
	assert.True(t, done)
	assert.Len(t, fake.callsFor("listsinceblock"), 2)

	var tested []string
	for _, c := range fake.callsFor("testmempoolaccept") {
		var raw []string
		require.NoError(t, json.Unmarshal(c.Params[0], &raw))
		tested = append(tested, raw...)
	}
	assert.ElementsMatch(t, []string{"hex-evicted", "hex-replaylocked", "hex-finalsequence", "hex-spendsretired"}, tested)

	outs := fake.callsFor("gettxout")
	require.Len(t, outs, 1)
	assert.Equal(t, "parent-spendsretired", mustString(t, outs[0].Params[0]))
	assert.JSONEq(t, "true", string(outs[0].Params[2]))

	var abandoned []string
	for _, c := range fake.callsFor("abandontransaction") {
		assert.Equal(t, name, c.Wallet)
		abandoned = append(abandoned, mustString(t, c.Params[0]))
	}
	assert.Equal(t, []string{"replaylocked", "spendsretired"}, abandoned)
}

func TestCoreBackendReleaseStrandedKeepsTheCurrentReplayLock(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	stubStrandedChain(fake, "wallet_"+coreID[:8])
	fake.handle("getmempoolentry", func(bitcoindCall) (any, string) { return nil, "Transaction not in mempool" })
	fake.handle("gettransaction", func(c bitcoindCall) (any, string) {
		return map[string]any{"hex": "hex", "decoded": map[string]any{"locktime": mainnetLock, "vin": []map[string]any{}}}, ""
	})
	fake.handle("testmempoolaccept", func(bitcoindCall) (any, string) {
		return []map[string]any{{"allowed": false, "reject-reason": "mempool min fee not met"}}, ""
	})

	done, err := backend.ReleaseStranded(context.Background(), []uint32{betanetLock})
	require.NoError(t, err)
	assert.True(t, done)
	assert.Empty(t, fake.callsFor("abandontransaction"))
}

func TestCoreBackendReleaseStrandedWaitsForSync(t *testing.T) {
	for name, info := range map[string]map[string]any{
		"headers ahead":     {"blocks": 973000, "headers": 980000, "initialblockdownload": false},
		"in block download": {"blocks": 973000, "headers": 973000, "initialblockdownload": true},
	} {
		t.Run(name, func(t *testing.T) {
			backend, fake, _ := newCoreBackendFixture(t)
			fake.handle("getblockchaininfo", func(bitcoindCall) (any, string) { return info, "" })

			done, err := backend.ReleaseStranded(context.Background(), []uint32{betanetLock})
			require.NoError(t, err)
			assert.False(t, done)
			assert.Empty(t, fake.callsFor("listsinceblock"))
		})
	}
}

func TestCoreBackendReleaseStrandedReturnsAMempoolError(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	stubStrandedChain(fake, "wallet_"+coreID[:8])
	fake.handle("getmempoolentry", func(bitcoindCall) (any, string) { return nil, "Loading block index" })

	done, err := backend.ReleaseStranded(context.Background(), []uint32{betanetLock})
	require.ErrorContains(t, err, "Loading block index")
	assert.False(t, done)
	assert.Empty(t, fake.callsFor("abandontransaction"))
}
