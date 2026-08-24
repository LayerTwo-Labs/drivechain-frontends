package wallet

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func TestHeightForReadsAConfirmedStatus(t *testing.T) {
	require.Equal(t, 963_000, heightFor(EsploraStatus{Confirmed: true, BlockHeight: 963_000}))
}

func TestHeightForIgnoresAnUnconfirmedStatus(t *testing.T) {
	require.Equal(t, 0, heightFor(EsploraStatus{BlockHeight: 963_000}))
}
