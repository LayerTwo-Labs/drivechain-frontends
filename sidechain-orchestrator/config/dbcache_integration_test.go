package config

import (
	"os"
	"strconv"
	"strings"
	"testing"
)

// An old conf on disk gets dbcache written into the file itself.
func TestLoadOrCreate_BackfillsDBCacheOnDisk(t *testing.T) {
	m := newTestConfManager(t)
	confPath := m.getBitWindowConfigPath()

	old := "# bitwindow-bitcoin-conf-version=10\n\nserver=1\ndatadir=/Volumes/LaCie/Bitcoin\nchain=main\n"
	if err := os.WriteFile(confPath, []byte(old), 0644); err != nil {
		t.Fatal(err)
	}

	if _, err := m.loadOrCreateConfigContent(); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	onDisk, err := os.ReadFile(confPath)
	if err != nil {
		t.Fatal(err)
	}
	written := ParseBitcoinConfig(string(onDisk))
	if got := written.GetSetting("dbcache"); got != defaultDBCacheSetting() {
		t.Errorf("dbcache = %q, want %q:\n%s", got, defaultDBCacheSetting(), onDisk)
	}
	if written.ConfigVersion != BitcoinConfMigrationsVersion {
		t.Errorf("version = %d, want %d", written.ConfigVersion, BitcoinConfMigrationsVersion)
	}
	if got := written.GetSetting("datadir"); got != "/Volumes/LaCie/Bitcoin" {
		t.Errorf("datadir = %q, want /Volumes/LaCie/Bitcoin", got)
	}
}

// A hand-set dbcache survives the migration on disk.
func TestLoadOrCreate_KeepsUserDBCacheOnDisk(t *testing.T) {
	m := newTestConfManager(t)
	confPath := m.getBitWindowConfigPath()

	old := "# bitwindow-bitcoin-conf-version=10\n\ndbcache=100\nchain=main\n"
	if err := os.WriteFile(confPath, []byte(old), 0644); err != nil {
		t.Fatal(err)
	}

	if _, err := m.loadOrCreateConfigContent(); err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	onDisk, err := os.ReadFile(confPath)
	if err != nil {
		t.Fatal(err)
	}
	if got := ParseBitcoinConfig(string(onDisk)).GetSetting("dbcache"); got != "100" {
		t.Errorf("dbcache = %q, want 100:\n%s", got, onDisk)
	}
}

// A first run writes dbcache, and a second load leaves it alone.
func TestLoadOrCreate_DBCacheIsIdempotent(t *testing.T) {
	m := newTestConfManager(t)
	confPath := m.getBitWindowConfigPath()

	if _, err := m.loadOrCreateConfigContent(); err != nil {
		t.Fatalf("first load: %v", err)
	}
	first, err := os.ReadFile(confPath)
	if err != nil {
		t.Fatal(err)
	}
	want := "dbcache=" + strconv.Itoa(DefaultDBCacheMiB())
	if !strings.Contains(string(first), want) {
		t.Fatalf("first run misses %q:\n%s", want, first)
	}

	if _, err := m.loadOrCreateConfigContent(); err != nil {
		t.Fatalf("second load: %v", err)
	}
	second, err := os.ReadFile(confPath)
	if err != nil {
		t.Fatal(err)
	}
	if string(second) != string(first) {
		t.Errorf("second load changed the file:\n%s\n---\n%s", first, second)
	}
	if n := strings.Count(string(second), "dbcache="); n != 1 {
		t.Errorf("dbcache lines = %d, want 1:\n%s", n, second)
	}
}
