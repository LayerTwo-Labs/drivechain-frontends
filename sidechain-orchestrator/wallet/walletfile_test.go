package wallet

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/walletfile"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// walletFileWith builds a plaintext wallet file holding the given wallet ids.
func walletFileWith(ids ...string) []byte {
	body := `{"version":1,"activeWalletId":"` + ids[0] + `","wallets":[`
	for i, id := range ids {
		if i > 0 {
			body += ","
		}
		body += `{"version":1,"master":{},"l1":{},"sidechains":[],"id":"` + id + `","name":"` + id + `","gradient":null,"wallet_type":"electrum"}`
	}
	return []byte(body + `]}`)
}

func TestLoadWalletFileKeepsTheDigestWhenTheFileDoesNotParse(t *testing.T) {
	t.Parallel()

	dir := t.TempDir()
	service := NewService(dir, zerolog.Nop())
	path := filepath.Join(dir, "wallet.json")
	good := walletFileWith("A")
	require.NoError(t, os.WriteFile(path, good, 0600))
	require.NoError(t, service.loadWalletFile())
	require.Equal(t, walletfile.DigestOf(good), service.lastWalletDigest)

	// A file this process cannot read must not stand as the state it holds.
	require.NoError(t, os.WriteFile(path, []byte("data"), 0600))
	require.Error(t, service.loadWalletFile())

	assert.Equal(t, walletfile.DigestOf(good), service.lastWalletDigest)
}
