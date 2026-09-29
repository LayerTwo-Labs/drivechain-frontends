package config

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/rs/zerolog"
)

// The truthcoin root moved from `truthcoin` to `truthcoin_dc`. The launch path
// builds the daemon flags out of the conf, so a dropped conf restarts the
// daemon on other ports than the user chose.
func TestLegacyConfSurvivesTheRootChange(t *testing.T) {
	home := t.TempDir()
	SetHomeDir(home)
	t.Cleanup(func() { SetHomeDir("") })

	spec := KnownSidechainSpecs["truthcoin"]
	if spec.LegacyRootDirName == "" {
		t.Fatal("truthcoin names no old folder, so no conf can move")
	}

	appDir := MustDirConfig(spec.DirKey).AppDir()
	legacyDir := filepath.Join(appDir, spec.LegacyRootDirName)
	if err := os.MkdirAll(legacyDir, 0755); err != nil {
		t.Fatal(err)
	}
	const handEdited = "net-addr=0.0.0.0:41234\nzmq-addr=127.0.0.1:41235\n"
	legacyPath := filepath.Join(legacyDir, spec.ConfigFilename)
	if err := os.WriteFile(legacyPath, []byte(handEdited), 0644); err != nil {
		t.Fatal(err)
	}

	m, err := NewSidechainConfManager(spec, nil, zerolog.Nop())
	if err != nil {
		t.Fatal(err)
	}

	if got := m.Config.GetSetting("net-addr"); got != "0.0.0.0:41234" {
		t.Errorf("net-addr = %q, want the value the user set", got)
	}
	if got := m.Config.GetSetting("zmq-addr"); got != "127.0.0.1:41235" {
		t.Errorf("zmq-addr = %q, want the value the user set", got)
	}
	if !strings.HasSuffix(filepath.Dir(m.ConfigPath), "truthcoin_dc") {
		t.Errorf("conf path = %q, want it under truthcoin_dc", m.ConfigPath)
	}
	if _, err := os.Stat(legacyPath); err != nil {
		t.Errorf("the old conf must stay until the new one reads back: %v", err)
	}
}

// A user who never ran the old release keeps the default conf.
func TestNoLegacyConfKeepsTheDefault(t *testing.T) {
	home := t.TempDir()
	SetHomeDir(home)
	t.Cleanup(func() { SetHomeDir("") })

	spec := KnownSidechainSpecs["truthcoin"]
	m, err := NewSidechainConfManager(spec, nil, zerolog.Nop())
	if err != nil {
		t.Fatal(err)
	}
	if got := m.Config.GetSetting("net-addr"); got == "" {
		t.Error("a fresh install must still get a net-addr")
	}
}

// A conf already under the new root wins: a second run must not undo an edit
// the user made there.
func TestTheNewConfWinsOverTheOldOne(t *testing.T) {
	home := t.TempDir()
	SetHomeDir(home)
	t.Cleanup(func() { SetHomeDir("") })

	spec := KnownSidechainSpecs["truthcoin"]
	appDir := MustDirConfig(spec.DirKey).AppDir()

	legacyDir := filepath.Join(appDir, spec.LegacyRootDirName)
	if err := os.MkdirAll(legacyDir, 0755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(filepath.Join(legacyDir, spec.ConfigFilename), []byte("net-addr=0.0.0.0:1111\n"), 0644); err != nil {
		t.Fatal(err)
	}

	newRoot := MustDirConfig(spec.DirKey).RootDir()
	if err := os.MkdirAll(newRoot, 0755); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(filepath.Join(newRoot, spec.ConfigFilename), []byte("net-addr=0.0.0.0:2222\n"), 0644); err != nil {
		t.Fatal(err)
	}

	m, err := NewSidechainConfManager(spec, nil, zerolog.Nop())
	if err != nil {
		t.Fatal(err)
	}
	if got := m.Config.GetSetting("net-addr"); got != "0.0.0.0:2222" {
		t.Errorf("net-addr = %q, want the value under the new root", got)
	}
}
