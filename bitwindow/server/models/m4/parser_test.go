package m4

import (
	"encoding/binary"
	"testing"

	"github.com/btcsuite/btcd/txscript"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestParseM4Bytes_Version01(t *testing.T) {
	// Create valid M4 v0x01 message
	script := make([]byte, 0)
	script = append(script, txscript.OP_RETURN) // 0x6a

	// Add M4 header (little-endian)
	header := make([]byte, 4)
	binary.LittleEndian.PutUint32(header, M4CommitmentHeader)
	script = append(script, header...)

	// Version 0x01
	script = append(script, 0x01)

	// Upvote vector: SC0=abstain, SC1=alarm, SC2=upvote index 5
	script = append(script, 0xFF, 0xFE, 0x05)

	msg, err := ParseM4Bytes(script)
	require.NoError(t, err)
	require.NotNil(t, msg)

	assert.Equal(t, uint8(0x01), msg.Version)
	assert.Len(t, msg.Votes, 3)

	// Check vote 0 (abstain)
	assert.Equal(t, uint8(0), msg.Votes[0].SidechainSlot)
	assert.Equal(t, VoteTypeAbstain, msg.Votes[0].VoteType)
	assert.Nil(t, msg.Votes[0].BundleIndex)

	// Check vote 1 (alarm)
	assert.Equal(t, uint8(1), msg.Votes[1].SidechainSlot)
	assert.Equal(t, VoteTypeAlarm, msg.Votes[1].VoteType)
	assert.Nil(t, msg.Votes[1].BundleIndex)

	// Check vote 2 (upvote index 5)
	assert.Equal(t, uint8(2), msg.Votes[2].SidechainSlot)
	assert.Equal(t, VoteTypeUpvote, msg.Votes[2].VoteType)
	require.NotNil(t, msg.Votes[2].BundleIndex)
	assert.Equal(t, uint16(5), *msg.Votes[2].BundleIndex)
}

func TestParseM4Bytes_Version02(t *testing.T) {
	// Create valid M4 v0x02 message
	script := make([]byte, 0)
	script = append(script, txscript.OP_RETURN)

	header := make([]byte, 4)
	binary.LittleEndian.PutUint32(header, M4CommitmentHeader)
	script = append(script, header...)

	// Version 0x02
	script = append(script, 0x02)

	// Upvote vector: SC0=abstain (0xFFFF), SC1=upvote index 1000
	vote0 := make([]byte, 2)
	binary.LittleEndian.PutUint16(vote0, VoteAbstain)
	script = append(script, vote0...)

	vote1 := make([]byte, 2)
	binary.LittleEndian.PutUint16(vote1, 1000)
	script = append(script, vote1...)

	msg, err := ParseM4Bytes(script)
	require.NoError(t, err)
	require.NotNil(t, msg)

	assert.Equal(t, uint8(0x02), msg.Version)
	assert.Len(t, msg.Votes, 2)

	// Check vote 0 (abstain)
	assert.Equal(t, uint8(0), msg.Votes[0].SidechainSlot)
	assert.Equal(t, VoteTypeAbstain, msg.Votes[0].VoteType)

	// Check vote 1 (upvote index 1000)
	assert.Equal(t, uint8(1), msg.Votes[1].SidechainSlot)
	assert.Equal(t, VoteTypeUpvote, msg.Votes[1].VoteType)
	require.NotNil(t, msg.Votes[1].BundleIndex)
	assert.Equal(t, uint16(1000), *msg.Votes[1].BundleIndex)
}

func TestParseM4Bytes_InvalidHeader(t *testing.T) {
	script := make([]byte, 0)
	script = append(script, txscript.OP_RETURN)

	// Wrong header
	header := make([]byte, 4)
	binary.LittleEndian.PutUint32(header, 0x12345678)
	script = append(script, header...)

	script = append(script, 0x01)
	script = append(script, 0xFF)

	_, err := ParseM4Bytes(script)
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "invalid header")
}

func TestParseM4Bytes_TooShort(t *testing.T) {
	script := []byte{txscript.OP_RETURN, 0x01, 0x02}

	_, err := ParseM4Bytes(script)
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "script too short")
}

func TestParseM4Bytes_NotOPReturn(t *testing.T) {
	script := make([]byte, 0)
	script = append(script, 0x00) // Not OP_RETURN

	header := make([]byte, 4)
	binary.LittleEndian.PutUint32(header, M4CommitmentHeader)
	script = append(script, header...)

	script = append(script, 0x01)

	_, err := ParseM4Bytes(script)
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "not an OP_RETURN")
}

func TestIsM4Commitment(t *testing.T) {
	// Valid M4
	script := make([]byte, 0)
	script = append(script, txscript.OP_RETURN)

	header := make([]byte, 4)
	binary.LittleEndian.PutUint32(header, M4CommitmentHeader)
	script = append(script, header...)

	script = append(script, 0x01, 0xFF)

	assert.True(t, IsM4Commitment(script))

	// Not M4 (wrong header)
	script2 := make([]byte, 0)
	script2 = append(script2, txscript.OP_RETURN)

	header2 := make([]byte, 4)
	binary.LittleEndian.PutUint32(header2, 0x11111111)
	script2 = append(script2, header2...)

	assert.False(t, IsM4Commitment(script2))

	// Too short
	assert.False(t, IsM4Commitment([]byte{txscript.OP_RETURN}))
}
