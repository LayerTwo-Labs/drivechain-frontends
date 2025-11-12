package m4

import (
	"encoding/binary"
	"fmt"

	"github.com/btcsuite/btcd/txscript"
)

// ParseM4Bytes parses raw M4 bytes from a coinbase OP_RETURN
// Format: OP_RETURN | 0xD77D1776 (4 bytes) | Version (1 byte) | Upvote Vector (n bytes)
func ParseM4Bytes(opReturnScript []byte) (*M4Message, error) {
	// Must have at least: OP_RETURN(1) + Header(4) + Version(1)
	if len(opReturnScript) < 6 {
		return nil, fmt.Errorf("M4: script too short: %d bytes", len(opReturnScript))
	}

	// Check OP_RETURN
	if opReturnScript[0] != txscript.OP_RETURN {
		return nil, fmt.Errorf("M4: not an OP_RETURN: %x", opReturnScript[0])
	}

	// Check M4 commitment header (0xD77D1776) - little endian
	header := binary.LittleEndian.Uint32(opReturnScript[1:5])
	if header != M4CommitmentHeader {
		return nil, fmt.Errorf("M4: invalid header: %x (expected %x)", header, M4CommitmentHeader)
	}

	version := opReturnScript[5]
	upvoteVector := opReturnScript[6:]

	msg := &M4Message{
		Version:  version,
		RawBytes: opReturnScript[5:], // Version + upvote vector
	}

	// Parse votes based on version
	switch version {
	case 0x00:
		// Version 0x00: Repeat previous block's M4
		// No votes to parse
		return msg, nil

	case 0x01:
		// Version 0x01: 1 byte per sidechain (most common)
		msg.Votes = parseVersion01(upvoteVector)

	case 0x02:
		// Version 0x02: 2 bytes per sidechain (handles all cases)
		votes, err := parseVersion02(upvoteVector)
		if err != nil {
			return nil, fmt.Errorf("M4: parse v0x02: %w", err)
		}
		msg.Votes = votes

	case 0x03:
		// Version 0x03: Upvote only leading bundles (special algorithm)
		// This requires SCDB state to determine which bundles are leading
		// For now, we'll just mark it as abstain for all sidechains
		// TODO: Implement version 0x03 logic when we have SCDB state
		return msg, nil

	default:
		return nil, fmt.Errorf("M4: unsupported version: 0x%02x", version)
	}

	return msg, nil
}

func parseVersion01(vector []byte) []M4Vote {
	// Each byte is a sidechain vote
	// 0xFF = abstain, 0xFE = alarm, 0x00-0xFD = upvote index
	var votes []M4Vote
	for slot, b := range vector {
		vote := M4Vote{
			SidechainSlot: uint8(slot),
		}

		switch b {
		case 0xFF:
			vote.VoteType = VoteTypeAbstain
		case 0xFE:
			vote.VoteType = VoteTypeAlarm
		default:
			vote.VoteType = VoteTypeUpvote
			idx := uint16(b)
			vote.BundleIndex = &idx
		}

		votes = append(votes, vote)
	}
	return votes
}

func parseVersion02(vector []byte) ([]M4Vote, error) {
	// Each 2 bytes is a sidechain vote (little-endian)
	// 0xFFFF = abstain, 0xFFFE = alarm, 0x0000-0xFFFD = upvote index
	if len(vector)%2 != 0 {
		return nil, fmt.Errorf("invalid vector length: %d (must be even)", len(vector))
	}

	var votes []M4Vote
	for i := 0; i < len(vector); i += 2 {
		slot := uint8(i / 2)
		value := binary.LittleEndian.Uint16(vector[i : i+2])

		vote := M4Vote{
			SidechainSlot: slot,
		}

		switch value {
		case VoteAbstain:
			vote.VoteType = VoteTypeAbstain
		case VoteAlarm:
			vote.VoteType = VoteTypeAlarm
		default:
			vote.VoteType = VoteTypeUpvote
			vote.BundleIndex = &value
		}

		votes = append(votes, vote)
	}
	return votes, nil
}

// EncodeVotePreferences creates M4 bytes from user's vote preferences
func EncodeVotePreferences(prefs []VotePreference) []byte {
	// Use version 0x01 for simplicity (1 byte per sidechain)
	// TODO: Switch to version 0x02 if >253 sidechains

	version := byte(0x01)
	vector := make([]byte, len(prefs))

	for i, pref := range prefs {
		switch pref.VoteType {
		case VoteTypeAbstain:
			vector[i] = 0xFF
		case VoteTypeAlarm:
			vector[i] = 0xFE
		case VoteTypeUpvote:
			// For now, just mark as abstain
			// TODO: Lookup bundle index from hash when we have SCDB state
			vector[i] = 0xFF
		}
	}

	result := make([]byte, 1+len(vector))
	result[0] = version
	copy(result[1:], vector)
	return result
}

// IsM4Commitment checks if the script is an M4 commitment
func IsM4Commitment(script []byte) bool {
	if len(script) < 6 {
		return false
	}
	if script[0] != txscript.OP_RETURN {
		return false
	}
	header := binary.LittleEndian.Uint32(script[1:5])
	return header == M4CommitmentHeader
}

// ParseM3Bytes parses raw M3 bytes from a coinbase OP_RETURN
// Format: OP_RETURN | 0xD45AA943 (4 bytes) | Bundle Hash (32 bytes) | Sidechain Slot (1 byte)
// Total: 38 bytes
func ParseM3Bytes(opReturnScript []byte) (*M3Message, error) {
	// Must have exactly: OP_RETURN(1) + Header(4) + Hash(32) + Slot(1) = 38 bytes
	if len(opReturnScript) != 38 {
		return nil, fmt.Errorf("M3: invalid length: %d bytes (expected 38)", len(opReturnScript))
	}

	// Check OP_RETURN
	if opReturnScript[0] != txscript.OP_RETURN {
		return nil, fmt.Errorf("M3: not an OP_RETURN: %x", opReturnScript[0])
	}

	// Check M3 commitment header (0xD45AA943) - little endian
	header := binary.LittleEndian.Uint32(opReturnScript[1:5])
	if header != M3CommitmentHeader {
		return nil, fmt.Errorf("M3: invalid header: %x (expected %x)", header, M3CommitmentHeader)
	}

	// Extract bundle hash (32 bytes, reversed for display)
	bundleHashBytes := make([]byte, 32)
	copy(bundleHashBytes, opReturnScript[5:37])

	// Reverse for hex display (Bitcoin uses reverse byte order for hashes)
	for i := 0; i < 16; i++ {
		bundleHashBytes[i], bundleHashBytes[31-i] = bundleHashBytes[31-i], bundleHashBytes[i]
	}
	bundleHash := fmt.Sprintf("%x", bundleHashBytes)

	// Extract sidechain slot (1 byte)
	sidechainSlot := opReturnScript[37]

	msg := &M3Message{
		SidechainSlot: sidechainSlot,
		BundleHash:    bundleHash,
	}

	return msg, nil
}

// IsM3Commitment checks if the script is an M3 commitment
func IsM3Commitment(script []byte) bool {
	if len(script) != 38 {
		return false
	}
	if script[0] != txscript.OP_RETURN {
		return false
	}
	header := binary.LittleEndian.Uint32(script[1:5])
	return header == M3CommitmentHeader
}
