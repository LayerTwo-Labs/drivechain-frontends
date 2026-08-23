package config

import (
	"strconv"
	"strings"
	"testing"
)

func TestDefaultDBCacheMiBStaysInRange(t *testing.T) {
	got := DefaultDBCacheMiB()
	if got < minDBCacheMiB || got > maxDBCacheMiB {
		t.Fatalf("dbcache %d outside [%d, %d]", got, minDBCacheMiB, maxDBCacheMiB)
	}
}

func TestDefaultConfigCarriesDBCache(t *testing.T) {
	m := &BitcoinConfManager{Network: NetworkECash}
	want := "dbcache=" + strconv.Itoa(DefaultDBCacheMiB())
	if !strings.Contains(m.GetDefaultConfig(), want) {
		t.Fatalf("default config misses %q", want)
	}
}

func TestMigrationBackfillsDBCache(t *testing.T) {
	config := ParseBitcoinConfig("# bitwindow-bitcoin-conf-version=10\nserver=1\n")
	migrated, _ := RunBitcoinConfMigrations(config)
	if !migrated {
		t.Fatal("no migration ran")
	}
	if got := config.GetSetting("dbcache"); got != defaultDBCacheSetting() {
		t.Fatalf("dbcache = %q, want %q", got, defaultDBCacheSetting())
	}
	if config.ConfigVersion != BitcoinConfMigrationsVersion {
		t.Fatalf("version = %d, want %d", config.ConfigVersion, BitcoinConfMigrationsVersion)
	}
}

func TestMigrationKeepsUserDBCache(t *testing.T) {
	config := ParseBitcoinConfig("# bitwindow-bitcoin-conf-version=10\ndbcache=100\n")
	if _, _ = RunBitcoinConfMigrations(config); config.GetSetting("dbcache") != "100" {
		t.Fatalf("dbcache = %q, want 100", config.GetSetting("dbcache"))
	}
}
