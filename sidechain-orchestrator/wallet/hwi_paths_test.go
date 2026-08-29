package wallet

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"testing"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/base58"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/btcutil/psbt"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/stretchr/testify/require"
)

// TestDeviceRefusesNonStandardMultisigPath: a hardware signer accepts a multisig
// input only at a BIP48 or a BIP45 path. The check must name the key, the path,
// and the input, because the device names none of them.
func TestDeviceRefusesNonStandardMultisigPath(t *testing.T) {
	h := func(n uint32) uint32 { return n | hardenedKey }
	packetWithPath := func(path []uint32) *psbt.Packet {
		tx := wire.NewMsgTx(2)
		tx.AddTxIn(wire.NewTxIn(&wire.OutPoint{}, nil, nil))
		tx.AddTxOut(wire.NewTxOut(1000, make([]byte, 22)))
		packet, err := psbt.NewFromUnsignedTx(tx)
		require.NoError(t, err)
		packet.Inputs[0].WitnessScript = []byte{0x52, 0x53, 0xae}
		packet.Inputs[0].Bip32Derivation = []*psbt.Bip32Derivation{{
			PubKey:               make([]byte, 33),
			MasterKeyFingerprint: 0x26f9d3d8, // d8d3f926 little-endian
			Bip32Path:            path,
		}}
		return packet
	}

	good := []uint32{h(48), h(0), h(0), h(2), 0, 0}
	require.NoError(t, checkDeviceCanSignPaths(packetWithPath(good), "d8d3f926"))
	require.NoError(t, checkDeviceCanSignPaths(packetWithPath([]uint32{h(45), 0, 0, 0}), "d8d3f926"))

	err := checkDeviceCanSignPaths(packetWithPath([]uint32{0, 0}), "d8d3f926")
	require.ErrorContains(t, err, "m/0/0")
	require.ErrorContains(t, err, "psbt input 0")

	// A BIP84 single-key account is not a multisig path.
	err = checkDeviceCanSignPaths(packetWithPath([]uint32{h(84), h(0), h(0), 0, 0}), "d8d3f926")
	require.ErrorContains(t, err, "m/84'/0'/0'/0/0")

	// Another device's key is not this device's problem.
	require.NoError(t, checkDeviceCanSignPaths(packetWithPath([]uint32{0, 0}), "aabbccdd"))
}

// TestDeviceKeyMustMatchTheWallet: a signer files its signature under the key
// the packet names for its fingerprint. A device with another seed gives a
// valid signature for a key this wallet does not hold, so the keys must match
// before the device signs.
func TestDeviceKeyMustMatchTheWallet(t *testing.T) {
	net := &chaincfg.MainNetParams
	xpubAt := func(pass string) (*hdkeychain.ExtendedKey, string) {
		seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, pass))
		acct, err := accountKeyFromSeed(seedHex, ScriptNativeSegwit, net)
		require.NoError(t, err)
		pub, err := acct.Neuter()
		require.NoError(t, err)
		return pub, pub.String()
	}
	walletKey, walletXpub := xpubAt("wallet")
	_, otherXpub := xpubAt("another device")

	packetFor := func(key *hdkeychain.ExtendedKey) *psbt.Packet {
		tx := wire.NewMsgTx(2)
		tx.AddTxIn(wire.NewTxIn(&wire.OutPoint{}, nil, nil))
		tx.AddTxOut(wire.NewTxOut(1000, make([]byte, 22)))
		packet, err := psbt.NewFromUnsignedTx(tx)
		require.NoError(t, err)
		raw := base58.Decode(key.String())
		packet.XPubs = []psbt.XPub{{
			ExtendedKey:          raw[:78],
			MasterKeyFingerprint: 0x26f9d3d8,
			Bip32Path:            []uint32{48 | hardenedKey, hardenedKey, 1 | hardenedKey, 2 | hardenedKey},
		}}
		return packet
	}

	runner := func(xpub string, seen *string) *HWIRunner {
		return &HWIRunner{chain: "main", call: func(_ context.Context, req map[string]any) (json.RawMessage, error) {
			if seen != nil {
				*seen, _ = req["derivation_path"].(string)
			}
			return json.RawMessage(`{"xpub":"` + xpub + `"}`), nil
		}}
	}
	sel := HardwareSelector{Type: "trezor", Fingerprint: "d8d3f926"}

	var asked string
	require.NoError(t, runner(walletXpub, &asked).
		checkDeviceHoldsWalletKeys(context.Background(), sel, packetFor(walletKey)))
	require.Equal(t, "m/48'/0'/1'/2'", asked)

	err := runner(otherXpub, nil).
		checkDeviceHoldsWalletKeys(context.Background(), sel, packetFor(walletKey))
	require.ErrorContains(t, err, "seed or passphrase does not match the key this wallet stored")
	require.ErrorContains(t, err, "m/48'/0'/1'/2'")
}

// TestDeviceKeyFoundAtAnotherPath: a wallet that imports a cosigner at one path
// and records another leaves the script correct and the path wrong. The report
// must name the real path, because that alone repairs the wallet.
func TestDeviceKeyFoundAtAnotherPath(t *testing.T) {
	net := &chaincfg.MainNetParams
	seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, "device"))

	at := func(path string) *hdkeychain.ExtendedKey {
		xpub, err := DeriveAccountXpub(seedHex, path, net)
		require.NoError(t, err)
		key, err := hdkeychain.NewKeyFromString(xpub)
		require.NoError(t, err)
		return key
	}
	// The wallet stored the account 0 key but recorded the account 1 path.
	stored := at("m/48'/0'/0'/2'")

	tx := wire.NewMsgTx(2)
	tx.AddTxIn(wire.NewTxIn(&wire.OutPoint{}, nil, nil))
	tx.AddTxOut(wire.NewTxOut(1000, make([]byte, 22)))
	packet, err := psbt.NewFromUnsignedTx(tx)
	require.NoError(t, err)
	packet.XPubs = []psbt.XPub{{
		ExtendedKey:          base58.Decode(stored.String())[:78],
		MasterKeyFingerprint: 0x26f9d3d8,
		Bip32Path:            []uint32{48 | hardenedKey, hardenedKey, 1 | hardenedKey, 2 | hardenedKey},
	}}

	r := &HWIRunner{chain: "main", call: func(_ context.Context, req map[string]any) (json.RawMessage, error) {
		path, _ := req["derivation_path"].(string)
		xpub, err := DeriveAccountXpub(seedHex, path, net)
		if err != nil {
			return nil, err
		}
		return json.RawMessage(`{"xpub":"` + xpub + `"}`), nil
	}}

	err = r.checkDeviceHoldsWalletKeys(context.Background(),
		HardwareSelector{Type: "trezor", Fingerprint: "d8d3f926"}, packet)
	require.ErrorContains(t, err, "records cosigner d8d3f926 at m/48'/0'/1'/2'")
	require.ErrorContains(t, err, "device holds that key at m/48'/0'/0'/2'")
}

// TestDeviceSignatureCheckedAtTheDevice: a device that signs another
// transaction must fail at the device call. The broadcast is otherwise the
// first step that reads the signature, and it names no device.
func TestDeviceSignatureCheckedAtTheDevice(t *testing.T) {
	net := &chaincfg.MainNetParams
	seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, ""))
	acct, err := accountKeyFromSeed(seedHex, ScriptNativeSegwit, net)
	require.NoError(t, err)
	priv, ok, err := deriveChildPrivIfPossible(acct, 0, 0)
	require.NoError(t, err)
	require.True(t, ok)

	pkh := btcutil.Hash160(priv.PubKey().SerializeCompressed())
	spk, err := txscript.NewScriptBuilder().AddOp(txscript.OP_0).AddData(pkh).Script()
	require.NoError(t, err)

	tx := wire.NewMsgTx(2)
	tx.AddTxIn(wire.NewTxIn(&wire.OutPoint{Index: 0}, nil, nil))
	tx.AddTxOut(wire.NewTxOut(900, spk))
	packet, err := psbt.NewFromUnsignedTx(tx)
	require.NoError(t, err)
	packet.Inputs[0].WitnessUtxo = wire.NewTxOut(1000, spk)

	// A signature over another transaction: the same input, another amount.
	other := wire.NewMsgTx(2)
	other.AddTxIn(wire.NewTxIn(&wire.OutPoint{Index: 0}, nil, nil))
	other.AddTxOut(wire.NewTxOut(500, spk))
	f := txscript.NewCannedPrevOutputFetcher(spk, 1000)
	wrong, err := txscript.RawTxInWitnessSignature(
		other, txscript.NewTxSigHashes(other, f), 0, 1000, spk, txscript.SigHashAll, priv)
	require.NoError(t, err)
	packet.Inputs[0].PartialSigs = []*psbt.PartialSig{
		{PubKey: priv.PubKey().SerializeCompressed(), Signature: wrong},
	}
	b64, err := packet.B64Encode()
	require.NoError(t, err)

	err = checkDeviceSignatures(b64)
	require.ErrorContains(t, err, "the device signed a different transaction")

	// A taproot key-path spend carries its signature in one field of its own,
	// and it reaches the same check.
	taproot, err := psbt.NewFromUnsignedTx(tx.Copy())
	require.NoError(t, err)
	taproot.Inputs[0].WitnessUtxo = wire.NewTxOut(1000, spk)
	taproot.Inputs[0].TaprootKeySpendSig = wrong
	b64, err = taproot.B64Encode()
	require.NoError(t, err)
	require.Error(t, checkDeviceSignatures(b64))
}
