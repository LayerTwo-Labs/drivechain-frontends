package engines

import (
	"encoding/binary"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestParseSequenceMsg(t *testing.T) {
	hash := make([]byte, 32)
	hash[0] = 0xab

	body := append(append([]byte{}, hash...), 'A')
	body = binary.LittleEndian.AppendUint64(body, 42)
	msg, err := parseSequenceMsg([][]byte{[]byte("sequence"), body, {0, 0, 0, 0}})
	require.NoError(t, err)
	require.Equal(t, TransactionAdded, msg.Event)
	require.EqualValues(t, 42, msg.MempoolSeq)
	require.EqualValues(t, 0xab, msg.Hash[0])

	msg, err = parseSequenceMsg([][]byte{[]byte("sequence"), append(append([]byte{}, hash...), 'C'), {0, 0, 0, 0}})
	require.NoError(t, err)
	require.Equal(t, BlockConnected, msg.Event)

	_, err = parseSequenceMsg([][]byte{[]byte("sequence"), append(append([]byte{}, hash...), 'A'), {0, 0, 0, 0}})
	require.Error(t, err)

	_, err = parseSequenceMsg([][]byte{[]byte("rawtx"), body, {0, 0, 0, 0}})
	require.Error(t, err)
}
