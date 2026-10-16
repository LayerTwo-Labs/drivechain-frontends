package engines

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestOpReturnOutputVbytesUsesTheRightPushOpcode(t *testing.T) {
	// a single-byte push covers payloads up to 75 bytes
	assert.EqualValues(t, 8+1+1+1+75, OpReturnOutputVbytes(75))
	// past that the payload needs OP_PUSHDATA1 plus a length byte
	assert.EqualValues(t, 8+1+1+2+76, OpReturnOutputVbytes(76))
	// a 249-byte payload makes a 252-byte script, the last one-byte script length
	assert.EqualValues(t, 8+1+1+2+249, OpReturnOutputVbytes(249))
	// a 250-byte payload makes a 253-byte script, which needs a 3-byte length
	assert.EqualValues(t, 8+3+1+2+250, OpReturnOutputVbytes(250))
	// past 255 bytes the payload needs OP_PUSHDATA2 plus a 2-byte length
	assert.EqualValues(t, 8+3+1+3+256, OpReturnOutputVbytes(256))
	// past 65535 bytes it needs OP_PUSHDATA4, and the script length needs 5 bytes
	assert.EqualValues(t, 8+5+1+5+65536, OpReturnOutputVbytes(65536))
}

func TestOpReturnTxVbytesCountsInputChangeAndPayload(t *testing.T) {
	// one segwit input (68) + change (31) + overhead (11) + the payload output
	want := uint64(68+31+11) + OpReturnOutputVbytes(40)
	assert.Equal(t, want, OpReturnTxVbytes(40))
}

func TestOpReturnTxVbytesGrowsWithThePayload(t *testing.T) {
	small := OpReturnTxVbytes(40)
	large := OpReturnTxVbytes(140)
	require.Greater(t, large, small)
	// 100 more payload bytes, plus the wider push opcode
	assert.Equal(t, uint64(101), large-small)
}
