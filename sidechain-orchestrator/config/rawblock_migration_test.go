package config

import (
	"strings"
	"testing"
)

func TestDefaultConfigHasNoRawBlockPublisher(t *testing.T) {
	for _, network := range []Network{NetworkECash, NetworkSignet, NetworkRegtest} {
		m := &BitcoinConfManager{Network: network}
		if strings.Contains(m.GetDefaultConfig(), "zmqpubrawblock") {
			t.Errorf("%s default config publishes raw blocks", network)
		}
	}
}

func TestMigrationDropsTheGeneratedRawBlockPublisher(t *testing.T) {
	config := ParseBitcoinConfig("# bitwindow-bitcoin-conf-version=12\n" +
		"zmqpubsequence=tcp://127.0.0.1:29000\n" +
		"zmqpubrawblock=tcp://127.0.0.1:29003\n" +
		"[main]\nzmqpubrawblock=tcp://127.0.0.1:29003\n")

	if migrated, _ := RunBitcoinConfMigrations(config); !migrated {
		t.Fatal("migration did not run")
	}

	for _, section := range []string{"", "main"} {
		if config.HasSetting("zmqpubrawblock", section) {
			t.Errorf("zmqpubrawblock stays in section %q", section)
		}
	}
	if got := config.GetSetting("zmqpubsequence"); got != "tcp://127.0.0.1:29000" {
		t.Errorf("zmqpubsequence = %q", got)
	}
}

func TestMigrationKeepsAUserRawBlockPublisher(t *testing.T) {
	config := ParseBitcoinConfig("# bitwindow-bitcoin-conf-version=12\nzmqpubrawblock=tcp://127.0.0.1:28332\n")

	RunBitcoinConfMigrations(config)

	if got := config.GetSetting("zmqpubrawblock"); got != "tcp://127.0.0.1:28332" {
		t.Errorf("zmqpubrawblock = %q, want the user value", got)
	}
}

func TestMigrationKeepsAUserRawBlockPublisherFromBeforeV8(t *testing.T) {
	config := ParseBitcoinConfig("# bitwindow-bitcoin-conf-version=7\nzmqpubrawblock=tcp://127.0.0.1:28332\n")

	RunBitcoinConfMigrations(config)

	if got := config.GetSetting("zmqpubrawblock"); got != "tcp://127.0.0.1:28332" {
		t.Errorf("zmqpubrawblock = %q, want the user value", got)
	}
}
