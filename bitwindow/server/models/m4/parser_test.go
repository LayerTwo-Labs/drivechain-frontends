package m4

import (
	"encoding/binary"
	"encoding/hex"
	"testing"

	"github.com/btcsuite/btcd/txscript"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// opReturn builds the on-chain form of a commitment: OP_RETURN + a data push.
func opReturn(t *testing.T, payload []byte) []byte {
	t.Helper()

	script, err := txscript.NewScriptBuilder().AddOp(txscript.OP_RETURN).AddData(payload).Script()
	require.NoError(t, err)
	return script
}

func headerBytes(header uint32) []byte {
	b := make([]byte, 4)
	binary.BigEndian.PutUint32(b, header)
	return b
}

func TestParseM4Bytes_Version01(t *testing.T) {
	// Create valid M4 v0x01 message
	payload := headerBytes(M4CommitmentHeader)

	// Version 0x01
	payload = append(payload, 0x01)

	// Upvote vector: SC0=abstain, SC1=alarm, SC2=upvote index 5
	payload = append(payload, 0xFF, 0xFE, 0x05)

	msg, err := ParseM4Bytes(opReturn(t, payload))
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
	payload := headerBytes(M4CommitmentHeader)

	// Version 0x02
	payload = append(payload, 0x02)

	// Upvote vector: SC0=abstain (0xFFFF), SC1=upvote index 1000
	vote0 := make([]byte, 2)
	binary.LittleEndian.PutUint16(vote0, VoteAbstain)
	payload = append(payload, vote0...)

	vote1 := make([]byte, 2)
	binary.LittleEndian.PutUint16(vote1, 1000)
	payload = append(payload, vote1...)

	msg, err := ParseM4Bytes(opReturn(t, payload))
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

// A vote vector for more than 75 sidechains is pushed with OP_PUSHDATA1, so the
// payload does not start at a fixed offset.
func TestParseM4Bytes_PushData1(t *testing.T) {
	payload := headerBytes(M4CommitmentHeader)
	payload = append(payload, 0x01)
	for i := 0; i < 100; i++ {
		payload = append(payload, 0xFF)
	}

	script := opReturn(t, payload)
	require.Equal(t, byte(txscript.OP_PUSHDATA1), script[1])
	assert.True(t, IsM4Commitment(script))

	msg, err := ParseM4Bytes(script)
	require.NoError(t, err)
	assert.Len(t, msg.Votes, 100)
}

// The on-chain tag byte order, per the "d77d177601" prefix the engines package
// matches against real coinbase payloads.
func TestParseM4Bytes_OnChainHeader(t *testing.T) {
	payload, err := hex.DecodeString("d77d177601ffff")
	require.NoError(t, err)

	script := opReturn(t, payload)
	require.True(t, IsM4Commitment(script))

	msg, err := ParseM4Bytes(script)
	require.NoError(t, err)
	assert.Equal(t, uint8(0x01), msg.Version)
	assert.Len(t, msg.Votes, 2)
}

func TestParseM4Bytes_InvalidHeader(t *testing.T) {
	// Wrong header
	payload := headerBytes(0x12345678)
	payload = append(payload, 0x01, 0xFF)

	_, err := ParseM4Bytes(opReturn(t, payload))
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "invalid header")
}

func TestParseM4Bytes_TooShort(t *testing.T) {
	_, err := ParseM4Bytes(opReturn(t, []byte{0x01, 0x02}))
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "script too short")
}

func TestParseM4Bytes_NotOPReturn(t *testing.T) {
	payload := headerBytes(M4CommitmentHeader)
	payload = append(payload, 0x01)

	script := opReturn(t, payload)
	script[0] = txscript.OP_DUP // Not OP_RETURN

	_, err := ParseM4Bytes(script)
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "not an OP_RETURN")
}

func TestIsM4Commitment(t *testing.T) {
	// Valid M4
	payload := headerBytes(M4CommitmentHeader)
	payload = append(payload, 0x01, 0xFF)
	assert.True(t, IsM4Commitment(opReturn(t, payload)))

	// Not M4 (wrong header)
	payload2 := headerBytes(0x11111111)
	payload2 = append(payload2, 0x01, 0xFF)
	assert.False(t, IsM4Commitment(opReturn(t, payload2)))

	// Too short
	assert.False(t, IsM4Commitment([]byte{txscript.OP_RETURN}))
	assert.False(t, IsM4Commitment(opReturn(t, headerBytes(M4CommitmentHeader))))
}

// m3Payload is the enforcer serialization: header | slot | bundle txid.
func m3Payload(slot byte, txid []byte) []byte {
	payload := headerBytes(M3CommitmentHeader)
	payload = append(payload, slot)
	return append(payload, txid...)
}

func TestParseM3Bytes(t *testing.T) {
	txid := make([]byte, 32)
	for i := range txid {
		txid[i] = byte(i + 1)
	}

	script := opReturn(t, m3Payload(7, txid))
	require.True(t, IsM3Commitment(script))

	msg, err := ParseM3Bytes(script)
	require.NoError(t, err)
	assert.Equal(t, uint8(7), msg.SidechainSlot)

	// Hashes are displayed in reverse byte order
	reversed := make([]byte, 32)
	for i, b := range txid {
		reversed[31-i] = b
	}
	assert.Equal(t, hex.EncodeToString(reversed), msg.BundleHash)
}

// A commitment seen on chain, recorded verbatim in the engines package's
// shouldSkip: tag | slot 9 (thunder) | bundle txid, pushed with OP_DATA_37.
func TestParseM3Bytes_OnChain(t *testing.T) {
	payload, err := hex.DecodeString("d45aa943091303c6de5739c2fb3a021a8bd2b8c9fa8bcd8f8c18954bec00aa8f9b2cf13602")
	require.NoError(t, err)

	script := opReturn(t, payload)
	require.Equal(t, byte(txscript.OP_DATA_37), script[1])
	require.True(t, IsM3Commitment(script))

	msg, err := ParseM3Bytes(script)
	require.NoError(t, err)
	assert.Equal(t, uint8(9), msg.SidechainSlot)
	assert.Equal(t, "0236f12c9b8faa00ec4b95188c8fcd8bfac9b8d28b1a023afbc23957dec60313", msg.BundleHash)
}

func TestParseM3Bytes_InvalidHeader(t *testing.T) {
	payload := headerBytes(0x12345678)
	payload = append(payload, 7)
	payload = append(payload, make([]byte, 32)...)

	_, err := ParseM3Bytes(opReturn(t, payload))
	assert.Error(t, err)
	assert.Contains(t, err.Error(), "invalid header")
}

func TestIsM3Commitment(t *testing.T) {
	txid := make([]byte, 32)

	assert.True(t, IsM3Commitment(opReturn(t, m3Payload(0, txid))))

	// Wrong header
	wrong := headerBytes(0x11111111)
	wrong = append(wrong, 0)
	wrong = append(wrong, txid...)
	assert.False(t, IsM3Commitment(opReturn(t, wrong)))

	// Wrong payload length
	assert.False(t, IsM3Commitment(opReturn(t, m3Payload(0, txid[:31]))))

	// Not a single data push
	assert.False(t, IsM3Commitment([]byte{txscript.OP_RETURN}))
}
