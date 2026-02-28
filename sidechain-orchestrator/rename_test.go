package orchestrator

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestStripPlatformSuffix(t *testing.T) {
	tests := []struct {
		input, want string
	}{
		// GitHub-style: version + platform
		{"thunder-orchard-0.1.0-x86_64-apple-darwin", "thunder-orchard"},
		{"thunder-orchard-0.1.0-x86_64-unknown-linux-gnu", "thunder-orchard"},

		// Underscore-separated (grpcurl)
		{"grpcurl_1.9.1_linux_x86_64", "grpcurl"},
		{"grpcurl_1.9.1_osx_x86_64", "grpcurl"},
		{"grpcurl_1.9.1_windows_x86_64", "grpcurl"},

		// Direct releases (no version, just platform)
		{"bip300301-enforcer-latest-x86_64-unknown-linux-gnu", "bip300301-enforcer-latest"},
		{"L1-bitcoin-patched-latest-x86_64-apple-darwin", "L1-bitcoin-patched-latest"},

		// Already clean
		{"bitcoind", "bitcoind"},
		{"thunder", "thunder"},

		// Extensions stripped
		{"grpcurl_1.9.1_linux_x86_64.tar.gz", "grpcurl"},
		{"thunder.exe", "thunder"},

		// Empty
		{"", ""},
	}
	for _, tt := range tests {
		t.Run(tt.input, func(t *testing.T) {
			assert.Equal(t, tt.want, StripPlatformSuffix(tt.input))
		})
	}
}
