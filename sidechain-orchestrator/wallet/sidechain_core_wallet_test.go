package wallet

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// A Core derived sidechain gets its starter as one native segwit pair that
// rescans from genesis.
func TestEnsureCoreWalletFromMnemonicImportsOneSegwitPair(t *testing.T) {
	net := &chaincfg.RegressionNetParams
	fake := newFakeBitcoind(t)
	fake.stubEnsureFlow()
	stubStarterDescriptors(fake, 0)

	require.NoError(t, EnsureCoreWalletFromMnemonic(context.Background(), fake.client(t), zerolog.Nop(), "starter", testMnemonic, net))

	require.Len(t, fake.callsFor("importdescriptors"), 1)
	var imports []ImportDescriptor
	require.NoError(t, json.Unmarshal(fake.callsFor("importdescriptors")[0].Params[0], &imports))
	require.Len(t, imports, 2)
	assert.True(t, strings.HasPrefix(imports[0].Desc, "wpkh([73c5da0a/84'/1'/0']tprv"), imports[0].Desc)
	assert.Equal(t, float64(0), asFloat(t, imports[0].Timestamp))
	assert.Equal(t, float64(0), asFloat(t, imports[1].Timestamp))
	assert.True(t, imports[1].Internal)

	receive, err := ParseDescriptor(imports[0].Desc)
	require.NoError(t, err)
	ds, _, err := receive.DeriveScript(false, 0, net)
	require.NoError(t, err)
	want, err := DeriveBIP84Addresses(hex.EncodeToString(MnemonicToSeed(testMnemonic, "")), net, 0, 1)
	require.NoError(t, err)
	assert.Equal(t, want[0], ds.address.EncodeAddress())
}

// Core answers importdescriptors only when the genesis rescan ends, so the
// starter import must outlast the normal client timeout.
func TestEnsureCoreWalletFromMnemonicWaitsForTheRescan(t *testing.T) {
	fake := newFakeBitcoind(t)
	fake.stubEnsureFlow()
	stubStarterDescriptors(fake, 0)
	imported := fake.handlerFor("importdescriptors")
	fake.handle("importdescriptors", func(c bitcoindCall) (any, string) {
		time.Sleep(300 * time.Millisecond)
		return imported(c)
	})
	rpc := fake.client(t)
	rpc.client.Timeout = 100 * time.Millisecond

	require.NoError(t, EnsureCoreWalletFromMnemonic(context.Background(), rpc, zerolog.Nop(), "starter", testMnemonic, &chaincfg.RegressionNetParams))
}

// stubStarterDescriptors answers listdescriptors with the two active starter
// descriptors at birthday ts, until an import moves the birthday to its own.
// Core stores a birthday below 1 as 1.
func stubStarterDescriptors(fake *fakeBitcoind, ts int64) {
	var mu sync.Mutex
	birthday := ts
	imported := fake.handlerFor("importdescriptors")
	fake.handle("importdescriptors", func(c bitcoindCall) (any, string) {
		var descs []ImportDescriptor
		_ = json.Unmarshal(c.Params[0], &descs)
		mu.Lock()
		birthday = time.Now().Unix()
		if f, ok := descs[0].Timestamp.(float64); ok {
			birthday = max(int64(f), 1)
		}
		mu.Unlock()
		return imported(c)
	})
	fake.handle("listdescriptors", func(bitcoindCall) (any, string) {
		mu.Lock()
		defer mu.Unlock()
		d := map[string]any{"desc": "wpkh(x)", "active": true, "timestamp": birthday}
		return map[string]any{"descriptors": []any{d, d}}, ""
	})
}

// A starter a previous version imported at "now" rescans from genesis one
// time, so the coins sent to it before show up.
func TestEnsureCoreWalletFromMnemonicRescansAnOldStarter(t *testing.T) {
	fake := newFakeBitcoind(t)
	fake.stubEnsureFlow()
	fake.handle("listwallets", func(bitcoindCall) (any, string) { return []string{"starter"}, "" })
	stubStarterDescriptors(fake, 1_700_000_000)
	rpc := fake.client(t)

	for range 2 {
		require.NoError(t, EnsureCoreWalletFromMnemonic(context.Background(), rpc, zerolog.Nop(), "starter", testMnemonic, &chaincfg.RegressionNetParams))
	}

	calls := fake.callsFor("importdescriptors")
	require.Len(t, calls, 1)
	var imports []ImportDescriptor
	require.NoError(t, json.Unmarshal(calls[0].Params[0], &imports))
	for _, imp := range imports {
		assert.Equal(t, float64(0), asFloat(t, imp.Timestamp))
	}
}
