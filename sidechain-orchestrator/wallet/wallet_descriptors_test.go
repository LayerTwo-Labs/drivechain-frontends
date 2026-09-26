package wallet

import (
	"encoding/hex"
	"encoding/json"
	"testing"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestWalletDescriptorsCoverEveryWalletShape(t *testing.T) {
	net := &chaincfg.SigNetParams
	seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, ""))
	otherSeedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, "other"))
	cosigner := func(seed string) MultisigCosigner {
		xpub, err := DeriveAccountXpub(seed, "m/48'/1'/0'/2'", net)
		require.NoError(t, err)
		return MultisigCosigner{Xpub: xpub, OriginPath: "48'/1'/0'/2'"}
	}

	for _, c := range []struct {
		name  string
		w     *WalletData
		kinds []ScriptKind
	}{
		{"hot segwit", &WalletData{Master: MasterWallet{SeedHex: seedHex}}, []ScriptKind{ScriptNativeSegwit, ScriptTaproot}},
		{"hot legacy", &WalletData{Master: MasterWallet{SeedHex: seedHex}, ScriptType: "legacy"}, []ScriptKind{ScriptLegacy}},
		{"watch-only", &WalletData{WatchOnly: json.RawMessage(`{"xpub":"` + accountXpub(t, seedHex, net) + `"}`)}, []ScriptKind{ScriptNativeSegwit}},
		{"multisig", &WalletData{ScriptType: "multisig", Multisig: &MultisigWalletData{
			M: 1, N: 2, Cosigners: []MultisigCosigner{cosigner(seedHex), cosigner(otherSeedHex)},
		}}, []ScriptKind{ScriptMultisig}},
	} {
		t.Run(c.name, func(t *testing.T) {
			descriptors, err := WalletDescriptors(c.w, net)
			require.NoError(t, err)
			kinds := make([]ScriptKind, len(descriptors))
			for i, d := range descriptors {
				kinds[i] = d.Kind
			}
			assert.Equal(t, c.kinds, kinds)
		})
	}
}

func TestWatchOnlyPreviewDerivesItsAddresses(t *testing.T) {
	net := &chaincfg.SigNetParams
	seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, ""))
	w := &WalletData{WatchOnly: json.RawMessage(`{"xpub":"` + accountXpub(t, seedHex, net) + `"}`)}

	got, err := DeriveWalletReceiveAddresses(w, net, 0, 2)
	require.NoError(t, err)
	want, err := DeriveBIP84Addresses(seedHex, net, 0, 2)
	require.NoError(t, err)
	assert.Equal(t, want, got)
}
