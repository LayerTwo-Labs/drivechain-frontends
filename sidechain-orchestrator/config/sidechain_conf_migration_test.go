package config

import (
	"strconv"
	"strings"
	"testing"
)

// A node made before the live chain took the base port holds the +20000 value
// the old scheme wrote. The migration drops it, and the sync writes the port
// the node's peers look for.
func TestMigrationDropsTheRetiredPortScheme(t *testing.T) {
	SetHomeDir(t.TempDir())
	t.Cleanup(func() { SetHomeDir("") })

	m := sidechainConfFor(t, "thunder", NetworkECash, map[string]string{
		"net-addr":           "0.0.0.0:24009",
		"rpc-addr":           "127.0.0.1:26009",
		"mainchain-grpc-url": "http://localhost:50051",
	})

	if err := m.SyncNetworkFromBitcoinConf(); err != nil {
		t.Fatalf("sync: %v", err)
	}

	for key, want := range map[string]string{
		"net-addr":       "0.0.0.0:4009",
		"rpc-addr":       "127.0.0.1:6009",
		"config-version": strconv.Itoa(SidechainConfMigrationsVersion),
	} {
		if got := m.Config.GetSetting(key); got != want {
			t.Errorf("%s = %q, want %q", key, got, want)
		}
	}
}

// The migration records itself. A user who later types a retired port owns
// that value, and no later sync takes it away.
func TestMigrationRunsOneTime(t *testing.T) {
	SetHomeDir(t.TempDir())
	t.Cleanup(func() { SetHomeDir("") })

	m := sidechainConfFor(t, "thunder", NetworkECash, map[string]string{
		"net-addr":       "0.0.0.0:24009",
		"rpc-addr":       "127.0.0.1:6009",
		"config-version": strconv.Itoa(SidechainConfMigrationsVersion),
	})

	if err := m.SyncNetworkFromBitcoinConf(); err != nil {
		t.Fatalf("sync: %v", err)
	}

	if got := m.Config.GetSetting("net-addr"); got != "0.0.0.0:24009" {
		t.Errorf("net-addr = %q, the migration took a value the user typed", got)
	}
}

// A zmq chain carries its own keys. The migration reads the same offsets, so
// it moves that chain too.
func TestMigrationDropsTheRetiredPortOnAZmqChain(t *testing.T) {
	SetHomeDir(t.TempDir())
	t.Cleanup(func() { SetHomeDir("") })

	m := sidechainConfFor(t, "bitnames", NetworkECash, map[string]string{
		"rpc-port": "26002",
		"net-addr": "0.0.0.0:24002",
		"zmq-addr": "127.0.0.1:48002",
	})

	if err := m.SyncNetworkFromBitcoinConf(); err != nil {
		t.Fatalf("sync: %v", err)
	}

	for key, want := range map[string]string{
		"rpc-port": "6002",
		"net-addr": "0.0.0.0:4002",
		"zmq-addr": "127.0.0.1:28002",
	} {
		if got := m.Config.GetSetting(key); got != want {
			t.Errorf("%s = %q, want %q", key, got, want)
		}
	}
}

// A new file starts at the current version, so no migration reads it.
func TestDefaultConfigCarriesTheCurrentVersion(t *testing.T) {
	want := "config-version=" + strconv.Itoa(SidechainConfMigrationsVersion)
	for name := range KnownSidechainSpecs {
		m := sidechainConfFor(t, name, NetworkECash, map[string]string{})
		if !strings.Contains(m.GetDefaultConfig(), want) {
			t.Errorf("%s default config carries no %q", name, want)
		}
	}
}

// SidechainConfMigrationsVersion counts the migrations, so the versions must
// run 1, 2, 3 with no gap.
func TestMigrationVersionsAreConsecutive(t *testing.T) {
	for i, migration := range sidechainConfMigrations {
		if migration.Version != i+1 {
			t.Errorf("migration %d carries version %d, want %d", i, migration.Version, i+1)
		}
	}
	if SidechainConfMigrationsVersion != len(sidechainConfMigrations) {
		t.Errorf("SidechainConfMigrationsVersion = %d, want %d", SidechainConfMigrationsVersion, len(sidechainConfMigrations))
	}
}
