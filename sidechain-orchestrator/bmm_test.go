package orchestrator

import (
	"encoding/hex"
	"strings"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const (
	testCriticalHash = "9f2c1d4a7b3e5f6c0b9a8d7e6f5c4b3a2918273645d0e1f2a3b4c5d6e7f80910"
	testPrevMainHash = "00000000000a3f81b2c4d5e6f7a8b9c0d1e2f3a4b5c6d7e8f9a0b1c2d3e4f5a6"
)

func TestM8BmmRequestScript(t *testing.T) {
	script, err := M8BmmRequestScript(9, testCriticalHash, testPrevMainHash)
	require.NoError(t, err)

	// OP_RETURN, push length, tag, slot, both hashes.
	require.Len(t, script, 2+3+1+32+32)
	assert.Equal(t, byte(0x6a), script[0])
	assert.Equal(t, byte(68), script[1], "68 byte direct push")
	assert.Equal(t, []byte{0x00, 0xBF, 0x00}, script[2:5])
	assert.Equal(t, byte(9), script[5], "sidechain slot")

	critical, err := hex.DecodeString(testCriticalHash)
	require.NoError(t, err)
	assert.Equal(t, critical, script[6:38],
		"sidechain block hash goes on the wire as printed")

	prevMain, err := hex.DecodeString(testPrevMainHash)
	require.NoError(t, err)
	reverseBytes(prevMain)
	assert.Equal(t, prevMain, script[38:70],
		"bitcoind prints mainchain block hashes reversed, so the wire bytes are too")
}

// The value on an M8's OP_RETURN is ignored by BIP301, so the only place a bid
// can reach a miner is the fee. Guard the script against carrying one.
func TestM8BmmRequestScriptCarriesNoValue(t *testing.T) {
	script, err := M8BmmRequestScript(0, testCriticalHash, testPrevMainHash)
	require.NoError(t, err)
	assert.Equal(t, byte(0x6a), script[0], "unspendable, so a value would be burnt")
}

func TestM8BmmRequestScriptRejectsBadHashes(t *testing.T) {
	tests := []struct {
		name     string
		critical string
		prevMain string
		wantErr  string
	}{
		{"short critical", "abcd", testPrevMainHash, "sidechain block hash"},
		{"short prev main", testCriticalHash, "abcd", "mainchain block hash"},
		{"critical not hex", strings.Repeat("z", 64), testPrevMainHash, "sidechain block hash"},
		{"prev main not hex", testCriticalHash, strings.Repeat("z", 64), "mainchain block hash"},
		{"empty", "", "", "sidechain block hash"},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := M8BmmRequestScript(0, tt.critical, tt.prevMain)
			require.Error(t, err)
			assert.Contains(t, err.Error(), tt.wantErr)
		})
	}
}

func TestM8BmmRequestScriptSlotIsCarried(t *testing.T) {
	for _, slot := range []uint8{0, 1, 9, 255} {
		script, err := M8BmmRequestScript(slot, testCriticalHash, testPrevMainHash)
		require.NoError(t, err)
		assert.Equal(t, slot, script[5])
	}
}

func TestParseM8BmmRequestScriptRoundTrip(t *testing.T) {
	script, err := M8BmmRequestScript(9, testCriticalHash, testPrevMainHash)
	require.NoError(t, err)

	parsed := ParseM8BmmRequestScript(script)
	require.NotNil(t, parsed)
	assert.Equal(t, uint8(9), parsed.Slot)
	assert.Equal(t, testCriticalHash, parsed.CriticalHash)
	assert.Equal(t, testPrevMainHash, parsed.PrevMainHash,
		"a mainchain hash must come back the way bitcoind prints it")
}

// Run over every output of every mempool transaction, so anything that is not
// an M8 has to be ignored rather than misread.
func TestParseM8BmmRequestScriptIgnoresOtherScripts(t *testing.T) {
	valid, err := M8BmmRequestScript(0, testCriticalHash, testPrevMainHash)
	require.NoError(t, err)

	tests := []struct {
		name   string
		script []byte
	}{
		{"empty", nil},
		{"p2wpkh", append([]byte{0x00, 0x14}, make([]byte, 20)...)},
		{"op_return without the tag", append([]byte{0x6a, 68}, make([]byte, 68)...)},
		{"wrong tag", func() []byte {
			s := append([]byte(nil), valid...)
			s[2] = 0x01
			return s
		}()},
		{"truncated", valid[:len(valid)-1]},
		{"trailing byte", append(append([]byte(nil), valid...), 0x00)},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			assert.Nil(t, ParseM8BmmRequestScript(tt.script))
		})
	}
}
