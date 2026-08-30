package orchestrator

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// A fresh install has no file, so the app must ask before it boots anything.
func TestNodeModeStartsUnset(t *testing.T) {
	assert.Equal(t, NodeModeUnset, ReadNodeMode(t.TempDir()))
}

func TestNodeModeRoundTrips(t *testing.T) {
	dir := t.TempDir()
	require.NoError(t, WriteNodeMode(dir, NodeModeLight))
	assert.Equal(t, NodeModeLight, ReadNodeMode(dir))

	require.NoError(t, WriteNodeMode(dir, NodeModeFull))
	assert.Equal(t, NodeModeFull, ReadNodeMode(dir))
}

func TestWriteNodeModeRejectsUnset(t *testing.T) {
	require.Error(t, WriteNodeMode(t.TempDir(), NodeModeUnset))
	require.Error(t, WriteNodeMode(t.TempDir(), NodeMode("half")))
}

// A damaged file must make the app ask again, not boot the wrong stack.
func TestDamagedNodeModeReadsAsUnset(t *testing.T) {
	dir := t.TempDir()
	require.NoError(t, os.WriteFile(filepath.Join(dir, nodeModeFileName), []byte("garbage"), 0o644))
	assert.Equal(t, NodeModeUnset, ReadNodeMode(dir))
}

// Regtest serves no Esplora, so the stored mode never applies there. An unset
// mode must read as full too, or the app asks a question regtest cannot answer.
func TestNodeModeForNetworkForcesFullWhereNoEsplora(t *testing.T) {
	assert.Equal(t, NodeModeFull, NodeModeForNetwork(NodeModeLight, config.NetworkRegtest))
	assert.Equal(t, NodeModeFull, NodeModeForNetwork(NodeModeLight, config.NetworkTestnet))
	assert.Equal(t, NodeModeFull, NodeModeForNetwork(NodeModeUnset, config.NetworkRegtest))
	assert.Equal(t, NodeModeFull, NodeModeForNetwork(NodeModeUnset, config.NetworkTestnet))
	assert.Equal(t, NodeModeLight, NodeModeForNetwork(NodeModeLight, config.NetworkMainnet))
	assert.Equal(t, NodeModeUnset, NodeModeForNetwork(NodeModeUnset, config.NetworkMainnet))
}
