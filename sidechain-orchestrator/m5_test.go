package orchestrator

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// The slot is a bare pushed byte, so slots 1-16 must not collapse to OP_1..OP_16.
// A minimal-push encoding there makes the treasury unreadable as a CTIP.
func TestM5TreasuryScriptAllSlots(t *testing.T) {
	for slot := 0; slot <= 255; slot++ {
		script := M5TreasuryScript(uint8(slot))
		require.Equalf(t, []byte{0xb4, 0x01, byte(slot), 0x51}, script, "slot %d", slot)

		parsed, ok := ParseM5TreasuryScript(script)
		require.Truef(t, ok, "slot %d", slot)
		assert.Equalf(t, uint8(slot), parsed, "slot %d", slot)
	}
}

// Run over every output of every transaction, so anything that is not a
// treasury has to be ignored rather than misread.
func TestParseM5TreasuryScriptIgnoresOtherScripts(t *testing.T) {
	tests := []struct {
		name   string
		script []byte
	}{
		{"empty", nil},
		{"p2wpkh", append([]byte{0x00, 0x14}, make([]byte, 20)...)},
		{"op_return", []byte{0x6a, 0x01, 0x00}},
		{"minimal push slot", []byte{0xb4, 0x51, 0x51}},
		{"missing op_true", []byte{0xb4, 0x01, 0x01, 0x00}},
		{"wrong opcode", []byte{0xb3, 0x01, 0x01, 0x51}},
		{"trailing byte", []byte{0xb4, 0x01, 0x01, 0x51, 0x00}},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, ok := ParseM5TreasuryScript(tt.script)
			assert.False(t, ok)
		})
	}
}
