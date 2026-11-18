package orchestrator

import "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"

const (
	opNop5       = 0xb4
	opNop8       = 0xb7
	opPushBytes1 = 0x01
	opTrue       = 0x51
	treasuryLen  = 4
)

// OpDrivechain is the opcode the enforcer reads as OP_DRIVECHAIN on network:
// OP_NOP8 on the eCash fork, OP_NOP5 on the Bitcoin fork.
func OpDrivechain(network config.Network) byte {
	if network == config.NetworkECash {
		return opNop8
	}
	return opNop5
}

// M8TreasuryScript builds the BIP300 sidechain treasury scriptPubKey:
// OP_DRIVECHAIN <slot> OP_TRUE. A deposit pays the new CTIP to this script.
func M8TreasuryScript(opDrivechain byte, slot uint8) []byte {
	return []byte{opDrivechain, opPushBytes1, slot, opTrue}
}

// ParseM8TreasuryScript reads the sidechain slot off a treasury scriptPubKey.
// It returns false for any other script, so it can be run over a whole block.
func ParseM8TreasuryScript(opDrivechain byte, script []byte) (uint8, bool) {
	if len(script) != treasuryLen {
		return 0, false
	}
	if script[0] != opDrivechain || script[1] != opPushBytes1 || script[3] != opTrue {
		return 0, false
	}
	return script[2], true
}
