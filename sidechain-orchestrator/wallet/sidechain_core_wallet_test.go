package wallet

import (
	"testing"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
)

// Standard BIP39 test vectors.
const (
	testMnemonicA = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"
	testMnemonicB = "legal winner thank year wave sausage worth useful legal winner thank yellow"
)

// The seed a pre-descriptor fork adopts must be a deterministic, valid WIF: the same mnemonic always
// yields the same seed (so a restored wallet re-derives the same addresses), a different mnemonic
// yields a different seed, and the fork's sethdseed can decode it. (The end-to-end proof that
// freebankd accepts this exact WIF and reproduces its addresses is the bridge test in the FreeBank
// repo; this guards the Go derivation.)
func TestDeriveLegacySeedWIF(t *testing.T) {
	net := &chaincfg.RegressionNetParams

	wif1, err := deriveLegacySeedWIF(testMnemonicA, net)
	if err != nil {
		t.Fatalf("derive: %v", err)
	}
	wif2, err := deriveLegacySeedWIF(testMnemonicA, net)
	if err != nil {
		t.Fatalf("derive again: %v", err)
	}
	if wif1 != wif2 {
		t.Fatalf("not deterministic: %q vs %q", wif1, wif2)
	}

	decoded, err := btcutil.DecodeWIF(wif1)
	if err != nil {
		t.Fatalf("decode WIF: %v", err)
	}
	if !decoded.IsForNet(net) {
		t.Fatalf("WIF is not for the regtest network")
	}

	other, err := deriveLegacySeedWIF(testMnemonicB, net)
	if err != nil {
		t.Fatalf("derive other: %v", err)
	}
	if other == wif1 {
		t.Fatalf("distinct mnemonics produced the same seed WIF")
	}

	t.Logf("regtest seed WIF for mnemonic A: %s", wif1)
}
