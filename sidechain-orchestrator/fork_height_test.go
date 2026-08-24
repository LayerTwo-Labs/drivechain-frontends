package orchestrator

import (
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

func TestUtxoHeightPrefersTheBackendHeight(t *testing.T) {
	// An electrum backend counts confirmations against the chain tip, so the
	// local node's tip must not decide the height.
	u := wallet.UTXO{BlockHeight: 963_000, Confirmations: 28_000}
	require.Equal(t, 963_000, utxoHeight(u, 864_766))
}

func TestUtxoHeightFallsBackToConfirmations(t *testing.T) {
	u := wallet.UTXO{Confirmations: 10}
	require.Equal(t, 991, utxoHeight(u, 1000))
}

func TestUtxoHeightIsZeroForAnUnconfirmedCoin(t *testing.T) {
	require.Equal(t, 0, utxoHeight(wallet.UTXO{}, 1000))
}
