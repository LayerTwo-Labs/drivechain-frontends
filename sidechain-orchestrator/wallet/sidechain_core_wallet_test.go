package wallet

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// The slot starter is derived from the master seed, so its wallet can hold
// coins older than the import. Both descriptors must rescan from genesis.
func TestEnsureCoreWalletFromMnemonicRescansFromGenesis(t *testing.T) {
	const mnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"

	fake := newFakeBitcoind(t)
	fake.stubEnsureFlow()
	log := zerolog.New(zerolog.NewTestWriter(t))

	err := EnsureCoreWalletFromMnemonic(
		context.Background(), fake.client(t), log,
		"orchestrator", mnemonic, &chaincfg.RegressionNetParams,
	)
	require.NoError(t, err)

	imports := fake.callsFor("importdescriptors")
	require.Len(t, imports, 1)

	var descs []ImportDescriptor
	require.NoError(t, json.Unmarshal(imports[0].Params[0], &descs))
	require.Len(t, descs, 2, "external + change")
	assert.Equal(t, float64(0), asFloat(t, descs[0].Timestamp), "rescan from genesis")
	assert.Equal(t, float64(0), asFloat(t, descs[1].Timestamp), "rescan from genesis")
}
