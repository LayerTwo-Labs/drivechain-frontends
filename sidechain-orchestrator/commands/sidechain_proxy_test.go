package commands

import (
	"testing"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
)

func TestCreateSidechainCommands(t *testing.T) {
	commands := createSidechainCommands()

	expectedSidechains := []string{
		"bitassets", "bitnames", "coinshift",
		"photon", "thunder", "truthcoin", "zside",
	}

	if len(commands) != len(expectedSidechains) {
		t.Errorf("Expected %d sidechain commands, got %d", len(expectedSidechains), len(commands))
	}

	// Check that all expected sidechains are present
	found := make(map[string]bool)
	for _, cmd := range commands {
		found[cmd.Name] = true
	}

	for _, expected := range expectedSidechains {
		if !found[expected] {
			t.Errorf("Missing sidechain command: %s", expected)
		}
	}
}

func TestSidechainPorts(t *testing.T) {
	tests := []struct {
		sidechain string
		port      int
	}{
		{"bitnames", 38332},
		{"thunder", 48332},
		{"bitassets", 28332},
		{"coinshift", 58332},
		{"photon", 18332},
		{"truthcoin", 68332},
		{"zside", 78332},
	}

	for _, tt := range tests {
		t.Run(tt.sidechain, func(t *testing.T) {
			port, err := getSidechainPort(tt.sidechain)
			if err != nil {
				t.Errorf("Failed to get port for %s: %v", tt.sidechain, err)
			}
			if port != tt.port {
				t.Errorf("Expected port %d for %s, got %d", tt.port, tt.sidechain, port)
			}
		})
	}
}

func TestSidechainBinaryType(t *testing.T) {
	tests := []struct {
		sidechain string
		want      pb.BinaryType
	}{
		{"bitnames", pb.BinaryType_BINARY_TYPE_BITNAMES},
		{"thunder", pb.BinaryType_BINARY_TYPE_THUNDER},
		{"bitassets", pb.BinaryType_BINARY_TYPE_BITASSETS},
		{"coinshift", pb.BinaryType_BINARY_TYPE_COINSHIFT},
		{"photon", pb.BinaryType_BINARY_TYPE_PHOTON},
		{"truthcoin", pb.BinaryType_BINARY_TYPE_TRUTHCOIN},
		{"zside", pb.BinaryType_BINARY_TYPE_ZSIDE},
	}

	for _, tt := range tests {
		t.Run(tt.sidechain, func(t *testing.T) {
			got, err := sidechainBinaryType(tt.sidechain)
			if err != nil {
				t.Fatalf("sidechainBinaryType(%q): %v", tt.sidechain, err)
			}
			if got != tt.want {
				t.Fatalf("sidechainBinaryType(%q) = %s, want %s", tt.sidechain, got, tt.want)
			}
		})
	}
}

func TestSidechainPortUnknown(t *testing.T) {
	_, err := getSidechainPort("unknown")
	if err == nil {
		t.Error("Expected error for unknown sidechain")
	}
}

func TestTitleCase(t *testing.T) {
	tests := []struct {
		input    string
		expected string
	}{
		{"bitnames", "Bitnames"},
		{"thunder", "Thunder"},
		{"", ""},
		{"a", "A"},
	}

	for _, tt := range tests {
		t.Run(tt.input, func(t *testing.T) {
			result := titleCase(tt.input)
			if result != tt.expected {
				t.Errorf("titleCase(%q) = %q, want %q", tt.input, result, tt.expected)
			}
		})
	}
}

func TestWalletRestoreCommandNames(t *testing.T) {
	want := map[string]bool{
		"list-restorable-wallets": false,
		"restore-wallet":          false,
	}

	for _, cmd := range walletCommand.Subcommands {
		if _, ok := want[cmd.Name]; ok {
			want[cmd.Name] = true
		}
	}

	for name, found := range want {
		if !found {
			t.Fatalf("missing wallet subcommand %q", name)
		}
	}
}
