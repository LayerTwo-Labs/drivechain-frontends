package wallet

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"strings"
	"testing"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// A Core derived sidechain gets its starter as one native segwit pair that
// scans from the tip.
func TestEnsureCoreWalletFromMnemonicImportsOneSegwitPair(t *testing.T) {
	net := &chaincfg.RegressionNetParams
	fake := newFakeBitcoind(t)
	fake.stubEnsureFlow()

	require.NoError(t, EnsureCoreWalletFromMnemonic(context.Background(), fake.client(t), zerolog.Nop(), "starter", testMnemonic, net))

	var imports []ImportDescriptor
	require.NoError(t, json.Unmarshal(fake.callsFor("importdescriptors")[0].Params[0], &imports))
	require.Len(t, imports, 2)
	assert.True(t, strings.HasPrefix(imports[0].Desc, "wpkh([73c5da0a/84'/1'/0']tprv"), imports[0].Desc)
	assert.Equal(t, "now", imports[0].Timestamp)
	assert.True(t, imports[1].Internal)

	receive, err := ParseDescriptor(imports[0].Desc)
	require.NoError(t, err)
	ds, _, err := receive.DeriveScript(false, 0, net)
	require.NoError(t, err)
	want, err := DeriveBIP84Addresses(hex.EncodeToString(MnemonicToSeed(testMnemonic, "")), net, 0, 1)
	require.NoError(t, err)
	assert.Equal(t, want[0], ds.address.EncodeAddress())
}
