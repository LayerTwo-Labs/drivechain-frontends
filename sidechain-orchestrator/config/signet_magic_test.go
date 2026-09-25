package config

import (
	"crypto/sha256"
	"encoding/hex"
	"strings"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	"github.com/stretchr/testify/require"
)

// Core makes the signet network magic out of the challenge: the first four
// bytes of the double SHA256 of the serialized script. The catalog row and the
// conf must name one chain, or a signet datadir reads as another network.
func TestSignetCatalogMagicMatchesTheChallenge(t *testing.T) {
	conf := (&BitcoinConfManager{Network: NetworkSignet}).GetDefaultConfig()
	const setting = "signetchallenge="
	start := strings.Index(conf, setting)
	require.GreaterOrEqual(t, start, 0, "the default conf pins a signet challenge")
	line := conf[start+len(setting):]
	challenge := strings.TrimSpace(line[:strings.Index(line, "\n")])

	raw, err := hex.DecodeString(challenge)
	require.NoError(t, err)
	require.Less(t, len(raw), 253, "a longer script takes a wider compact size prefix")

	first := sha256.Sum256(append([]byte{byte(len(raw))}, raw...))
	second := sha256.Sum256(first[:])

	row, ok := netcatalog.Embedded().ByID("signet")
	require.True(t, ok)
	require.Equal(t, hex.EncodeToString(second[:4]), row.NetworkMagic)
}
