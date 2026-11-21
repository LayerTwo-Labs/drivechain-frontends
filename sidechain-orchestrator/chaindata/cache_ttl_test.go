package chaindata

import (
	"testing"

	"github.com/stretchr/testify/require"
)

// The status bar shows the peer count from getnetworkinfo in place of the
// peer list from getpeerinfo.
func TestPeerCountGoesStaleWithThePeerList(t *testing.T) {
	require.Equal(t, policies["getpeerinfo"].ttl, policies["getnetworkinfo"].ttl)
}
