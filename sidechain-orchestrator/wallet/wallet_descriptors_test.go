package wallet

import (
	"encoding/hex"
	"encoding/json"
	"testing"

	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
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

// A cosigner signs only with the key its stored xpub names.
func TestCosignerSignsWithTheKeyItsXpubNames(t *testing.T) {
	net := &chaincfg.SigNetParams
	const passphrase = "bl\u00e5b\u00e6r"
	const path = "48'/1'/0'/2'"
	xpubOf := func(seed []byte) string {
		xpub, err := DeriveAccountXpub(hex.EncodeToString(seed), "m/"+path, net)
		require.NoError(t, err)
		return xpub
	}

	own := xpubOf(MnemonicToSeed(testMnemonic, passphrase))
	xprv, err := cosignerXprv(MultisigCosigner{Xpub: own, OriginPath: path, Mnemonic: testMnemonic, Passphrase: passphrase}, net)
	require.NoError(t, err)
	key, err := hdkeychain.NewKeyFromString(xprv)
	require.NoError(t, err)
	pub, err := key.Neuter()
	require.NoError(t, err)
	assert.Equal(t, own, pub.String())

	foreign := MultisigCosigner{Xpub: xpubOf(MnemonicToSeed(testMnemonic, "other")), OriginPath: path, Mnemonic: testMnemonic, Passphrase: passphrase}
	_, err = cosignerXprv(foreign, net)
	require.ErrorContains(t, err, "does not derive its stored key")
}

func TestSigningKeyFindsTheKeyBehindAReceiveAddress(t *testing.T) {
	net := &chaincfg.SigNetParams
	seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, ""))
	w := &WalletData{Master: MasterWallet{SeedHex: seedHex}}
	descriptors, err := WalletDescriptors(w, net)
	require.NoError(t, err)

	for _, d := range descriptors {
		ds, pub, err := d.DeriveScript(false, 3, net)
		require.NoError(t, err)
		key, err := SigningKey(w, net, ds.address.EncodeAddress(), 10)
		require.NoError(t, err)
		want := pub.SerializeCompressed()
		if d.Kind == ScriptTaproot {
			// A taproot address commits to the tweaked key.
			want = txscript.ComputeTaprootKeyNoScript(pub).SerializeCompressed()
		}
		assert.Equal(t, want, key.PubKey().SerializeCompressed(), d.Kind.String())
	}

	beyond, _, err := descriptors[0].DeriveScript(false, 10, net)
	require.NoError(t, err)
	_, err = SigningKey(w, net, beyond.address.EncodeAddress(), 10)
	require.ErrorContains(t, err, "not one of the wallet")

	first, _, err := descriptors[0].DeriveScript(false, 0, net)
	require.NoError(t, err)
	watch := &WalletData{WatchOnly: json.RawMessage(`{"xpub":"` + accountXpub(t, seedHex, net) + `"}`)}
	_, err = SigningKey(watch, net, first.address.EncodeAddress(), 10)
	require.ErrorContains(t, err, "no private key")
}
