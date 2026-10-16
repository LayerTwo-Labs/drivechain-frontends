package engines_test

import (
	"bytes"
	"encoding/binary"
	"testing"
	"time"

	"github.com/btcsuite/btcd/wire"
	zmq "github.com/go-zeromq/zmq4"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
)

func TestZMQRun(t *testing.T) {
	t.Parallel()

	t.Run("closes subscribers when the dial fails", func(t *testing.T) {
		t.Parallel()

		zmqEngine, err := engines.NewZMQ("tcp://127.0.0.1:1")
		require.NoError(t, err)
		txs := zmqEngine.Subscribe()

		require.ErrorContains(t, zmqEngine.Run(t.Context()), "dial")

		select {
		case _, open := <-txs:
			assert.False(t, open)
		case <-time.After(time.Second):
			t.Fatal("the subscriber channel stays open after a failed dial")
		}
	})

	t.Run("stops and closes subscribers when the publisher exits", func(t *testing.T) {
		t.Parallel()

		pub := zmq.NewPub(t.Context())
		require.NoError(t, pub.Listen("tcp://127.0.0.1:0"))

		zmqEngine, err := engines.NewZMQ("tcp://" + pub.Addr().String())
		require.NoError(t, err)
		txs := zmqEngine.Subscribe()

		runErr := make(chan error, 1)
		go func() { runErr <- zmqEngine.Run(t.Context()) }()

		tx := wire.NewMsgTx(wire.TxVersion)
		tx.AddTxIn(wire.NewTxIn(&wire.OutPoint{Index: 0}, nil, nil))
		tx.AddTxOut(wire.NewTxOut(1000, []byte{0x51}))
		var raw bytes.Buffer
		require.NoError(t, tx.Serialize(&raw))
		seq := make([]byte, 4)
		binary.LittleEndian.PutUint32(seq, 1)
		msg := zmq.NewMsgFrom([]byte("rawtx"), raw.Bytes(), seq)

		// The subscription reaches the publisher some time after the dial.
		var got *wire.MsgTx
		require.Eventually(t, func() bool {
			require.NoError(t, pub.Send(msg))
			select {
			case got = <-txs:
				require.NotNil(t, got)
				return true
			case <-time.After(50 * time.Millisecond):
				return false
			}
		}, 5*time.Second, 10*time.Millisecond)
		assert.Equal(t, tx.TxHash(), got.TxHash())

		require.NoError(t, pub.Close())

		select {
		case err := <-runErr:
			require.ErrorContains(t, err, "rawtx subscription closed")
		case <-time.After(5 * time.Second):
			t.Fatal("Run did not return after the publisher closed")
		}

		require.Eventually(t, func() bool {
			select {
			case _, ok := <-txs:
				return !ok
			default:
				return false
			}
		}, 5*time.Second, 10*time.Millisecond)
	})
}
