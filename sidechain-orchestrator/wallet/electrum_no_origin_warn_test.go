package wallet

import (
	"bytes"
	"strings"
	"testing"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

// Every balance read rebuilds the descriptor. The missing origin belongs to
// the wallet, not to the read, so the console gets it one time.
func TestNoOriginWarnsOncePerWallet(t *testing.T) {
	var sink bytes.Buffer
	p := &ElectrumBackend{
		log:       zerolog.New(&sink),
		netParams: StaticParams(&chaincfg.RegressionNetParams),
	}
	w := &WalletData{
		ID: "WALLET-A",
		Multisig: &MultisigWalletData{
			M: 1, N: 2,
			Cosigners: []MultisigCosigner{
				{Xpub: "xpub-one"},
				{Xpub: "xpub-two"},
			},
		},
	}

	for range 3 {
		_, _ = p.multisigSigningDescriptorFor(w, "")
	}

	require.Equal(t, 1, strings.Count(sink.String(), "cosigner has no key origin"))
}

func TestNoOriginWarnsForEachWallet(t *testing.T) {
	var sink bytes.Buffer
	p := &ElectrumBackend{
		log:       zerolog.New(&sink),
		netParams: StaticParams(&chaincfg.RegressionNetParams),
	}
	ms := &MultisigWalletData{M: 1, N: 1, Cosigners: []MultisigCosigner{{Xpub: "xpub-one"}}}

	_, _ = p.multisigSigningDescriptorFor(&WalletData{ID: "WALLET-A", Multisig: ms}, "")
	_, _ = p.multisigSigningDescriptorFor(&WalletData{ID: "WALLET-B", Multisig: ms}, "")

	require.Equal(t, 2, strings.Count(sink.String(), "cosigner has no key origin"))
}
