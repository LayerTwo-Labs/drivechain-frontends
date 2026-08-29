package wallet

import (
	"encoding/hex"
	"testing"

	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/require"
)

// TestCosignerKeyMustMatchItsOrigin: a key and a path that disagree build a
// correct script with a wrong label, and only the label fails a hardware signer.
func TestCosignerKeyMustMatchItsOrigin(t *testing.T) {
	net := &chaincfg.MainNetParams
	seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, ""))
	account, err := DeriveAccountXpub(seedHex, "m/48'/0'/0'/2'", net)
	require.NoError(t, err)
	seed, err := hex.DecodeString(seedHex)
	require.NoError(t, err)
	root, err := hdkeychain.NewMaster(seed, net)
	require.NoError(t, err)
	rootPub, err := root.Neuter()
	require.NoError(t, err)
	master := rootPub.String()

	require.NoError(t, CheckCosignerKeyMatchesOrigin(account, "48'/0'/0'/2'"))
	require.NoError(t, CheckCosignerKeyMatchesOrigin(account, "m/48'/0'/1'/2'"),
		"the depth cannot tell one account from another")
	require.NoError(t, CheckCosignerKeyMatchesOrigin(master, ""))
	require.NoError(t, CheckCosignerKeyMatchesOrigin("", "48'/0'/0'/2'"))
	// A cosigner pasted as a bare xpub gives an account key and no origin, and
	// the wallet supports it.
	require.NoError(t, CheckCosignerKeyMatchesOrigin(account, ""))
	require.NoError(t, CheckCosignerKeyMatchesOrigin(account, "m/"))

	err = CheckCosignerKeyMatchesOrigin(master, "48'/0'/0'/2'")
	require.ErrorContains(t, err, "sits 0 steps")
	err = CheckCosignerKeyMatchesOrigin(account, "48'/0'")
	require.ErrorContains(t, err, "sits 4 steps")
}
