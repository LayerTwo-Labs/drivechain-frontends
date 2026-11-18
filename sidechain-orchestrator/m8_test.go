package orchestrator

import (
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// The enforcer reads OP_NOP8 as OP_DRIVECHAIN only on the eCash fork.
func TestOpDrivechainFollowsTheFork(t *testing.T) {
	tests := []struct {
		network config.Network
		want    byte
	}{
		{config.NetworkECash, 0xb7},
		{config.NetworkSignet, 0xb4},
		{config.NetworkRegtest, 0xb4},
		{config.NetworkTestnet, 0xb4},
		{config.NetworkMainnet, 0xb4},
	}

	for _, tt := range tests {
		t.Run(string(tt.network), func(t *testing.T) {
			assert.Equal(t, tt.want, OpDrivechain(tt.network))
		})
	}
}

// The slot is a bare pushed byte, so slots 1-16 must not collapse to OP_1..OP_16.
// A minimal-push encoding there makes the treasury unreadable as a CTIP.
func TestM8TreasuryScriptAllSlots(t *testing.T) {
	for _, op := range []byte{0xb4, 0xb7} {
		for slot := 0; slot <= 255; slot++ {
			script := M8TreasuryScript(op, uint8(slot))
			require.Equalf(t, []byte{op, 0x01, byte(slot), 0x51}, script, "op %x slot %d", op, slot)

			parsed, ok := ParseM8TreasuryScript(op, script)
			require.Truef(t, ok, "op %x slot %d", op, slot)
			assert.Equalf(t, uint8(slot), parsed, "op %x slot %d", op, slot)
		}
	}
}

// Run over every output of every transaction, so anything that is not a
// treasury has to be ignored rather than misread.
func TestParseM8TreasuryScriptIgnoresOtherScripts(t *testing.T) {
	tests := []struct {
		name   string
		script []byte
	}{
		{"empty", nil},
		{"p2wpkh", append([]byte{0x00, 0x14}, make([]byte, 20)...)},
		{"op_return", []byte{0x6a, 0x01, 0x00}},
		{"minimal push slot", []byte{0xb7, 0x51, 0x51}},
		{"missing op_true", []byte{0xb7, 0x01, 0x01, 0x00}},
		{"other fork opcode", []byte{0xb4, 0x01, 0x01, 0x51}},
		{"trailing byte", []byte{0xb7, 0x01, 0x01, 0x51, 0x00}},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, ok := ParseM8TreasuryScript(0xb7, tt.script)
			assert.False(t, ok)
		})
	}
}
