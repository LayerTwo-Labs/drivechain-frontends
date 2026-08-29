package wallet

import (
	"testing"

	"github.com/btcsuite/btcd/btcutil/psbt"
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
