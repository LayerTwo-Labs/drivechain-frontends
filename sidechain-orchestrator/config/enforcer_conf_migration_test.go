package config

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// An existing conf keeps enable-wallet forever without a migration, so the
// enforcer would seed a wallet that never starts and serve no block templates.
func TestMigrationDropsTheWalletFlag(t *testing.T) {
	c := &EnforcerConfig{ConfigVersion: 2, Settings: map[string]string{}}
	c.SetSetting("enable-wallet", "true")
	c.SetSetting("enable-mempool", "true")

	require.True(t, RunEnforcerConfMigrations(c))

	assert.Empty(t, c.GetSetting("enable-wallet"))
	assert.Equal(t, "true", c.GetSetting("enable-block-template-server"))
	assert.Equal(t, enforcerConfMigrationsVersion, c.ConfigVersion)
}

// Running it twice must not undo a value the user set by hand.
func TestMigrationRunsTwiceAndKeepsAHandSetValue(t *testing.T) {
	c := &EnforcerConfig{ConfigVersion: 2, Settings: map[string]string{}}
	c.SetSetting("enable-wallet", "true")
	c.SetSetting("enable-mempool", "false")

	require.True(t, RunEnforcerConfMigrations(c))
	assert.False(t, RunEnforcerConfMigrations(c), "a migrated conf is left alone")
	assert.Equal(t, "true", c.GetSetting("enable-mempool"),
		"the template server needs the mempool, so clap would reject the argv without it")
}

// The enforcer dropped these flags and exits on an unknown option, so an
// existing conf that still lists one must self-heal on load.
func TestMigrationDropsFlagsTheEnforcerRemoved(t *testing.T) {
	c := &EnforcerConfig{ConfigVersion: 3, Settings: map[string]string{}}
	c.SetSetting("serve-json-rpc-addr", "127.0.0.1:8123")
	c.SetSetting("wallet-full-scan", "true")
	c.SetSetting("signet-miner-coinbase-recipient", "tb1qexample")
	c.SetSetting("serve-rpc-addr", "127.0.0.1:8122")

	require.True(t, RunEnforcerConfMigrations(c))

	assert.Empty(t, c.GetSetting("serve-json-rpc-addr"))
	assert.Empty(t, c.GetSetting("wallet-full-scan"))
	assert.Empty(t, c.GetSetting("signet-miner-coinbase-recipient"))
	assert.Equal(t, "127.0.0.1:8122", c.GetSetting("serve-rpc-addr"), "a flag it still accepts stays")
	assert.Equal(t, 4, c.ConfigVersion)
}
