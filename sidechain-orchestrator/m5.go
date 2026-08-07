package orchestrator

const (
	opDrivechain = 0xb4 // OP_NOP5
	opPushBytes1 = 0x01
	opTrue       = 0x51
	treasuryLen  = 4
)

// M5TreasuryScript builds the BIP300 sidechain treasury scriptPubKey:
// OP_DRIVECHAIN <slot> OP_TRUE. A deposit pays the new CTIP to this script.
func M5TreasuryScript(slot uint8) []byte {
	return []byte{opDrivechain, opPushBytes1, slot, opTrue}
}

// ParseM5TreasuryScript reads the sidechain slot off a treasury scriptPubKey.
// It returns false for any other script, so it can be run over a whole block.
func ParseM5TreasuryScript(script []byte) (uint8, bool) {
	if len(script) != treasuryLen {
		return 0, false
	}
	if script[0] != opDrivechain || script[1] != opPushBytes1 || script[3] != opTrue {
		return 0, false
	}
	return script[2], true
}
