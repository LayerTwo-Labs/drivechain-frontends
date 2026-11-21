package chaindata

import (
	"context"
	"encoding/binary"
	"encoding/json"
	"net"
	"testing"
	"time"

	zmq "github.com/go-zeromq/zmq4"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

func freeAddr(t *testing.T) string {
	t.Helper()
	l, err := net.Listen("tcp", "127.0.0.1:0")
	require.NoError(t, err)
	addr := l.Addr().String()
	require.NoError(t, l.Close())
	return "tcp://" + addr
}

func TestZMQFeedKeepsTheMempoolTracker(t *testing.T) {
	tip := newFakeCore()
	mp := newFakeMempoolCore()
	call := func(ctx context.Context, method string, params ...any) (json.RawMessage, error) {
		switch method {
		case "getblockchaininfo", "waitforblockheight", "syncwithvalidationinterfacequeue":
			return tip.call(ctx, method, params...)
		}
		return mp.call(ctx, method, params...)
	}
	addr := freeAddr(t)
	pub := zmq.NewPub(t.Context())
	defer pub.Close() //nolint:errcheck // test cleanup
	require.NoError(t, pub.Listen(addr))

	e := New(Config{
		Call:    call,
		Batch:   mp.batch,
		ZMQAddr: func() string { return addr },
		Log:     zerolog.Nop(),
	})
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	go e.Run(ctx)
	require.Eventually(t, e.mempool.Ready, 5*time.Second, 5*time.Millisecond)

	var zseq uint32
	send := func(ev seqEvent) {
		body := append(append([]byte{}, ev.hash[:]...), ev.label)
		if ev.label == 'A' || ev.label == 'R' {
			body = binary.LittleEndian.AppendUint64(body, ev.seq)
		}
		require.NoError(t, pub.Send(zmq.NewMsgFrom([]byte("sequence"), body, binary.LittleEndian.AppendUint32(nil, zseq))))
		zseq++
	}
	send(mp.add(1, mpEntry(100, 100, 1)))
	require.Eventually(t, func() bool {
		_, total, err := e.mempool.Newest(t.Context(), 0)
		return err == nil && total == 1
	}, 2*time.Second, 5*time.Millisecond)
	reads := mp.count("getrawmempool")

	zseq += 3
	send(mp.add(2, mpEntry(100, 100, 1)))
	require.Eventually(t, func() bool { return mp.count("getrawmempool") > reads }, 2*time.Second, 5*time.Millisecond, "a lost message reads the mempool again")
	require.Eventually(t, func() bool {
		_, total, err := e.mempool.Newest(t.Context(), 0)
		return err == nil && total == 2 && e.mempool.Ready()
	}, 2*time.Second, 5*time.Millisecond)
}
