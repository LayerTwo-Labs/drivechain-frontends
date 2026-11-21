package api

import (
	"context"
	"io"
	"net"
	"sync/atomic"
	"testing"
	"time"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
)

func TestBinariesFeedReadsOneTimeForAllSubscribers(t *testing.T) {
	var reads, value atomic.Int32
	changed := make(chan struct{}, 1)
	feed := &binariesFeed{
		read: func(context.Context) ([]*pb.BinaryStatusMsg, error) {
			reads.Add(1)
			return []*pb.BinaryStatusMsg{{Name: "bitcoind", Pid: value.Load()}}, nil
		},
		same:    sameBinaries,
		changed: func(context.Context) <-chan struct{} { return changed },
		recheck: time.Hour,
	}

	ctx, cancel := context.WithCancel(t.Context())
	a := feed.subscribe(ctx)
	b := feed.subscribe(ctx)
	got, err := feed.latest()
	require.NoError(t, err)
	require.EqualValues(t, 0, got[0].Pid)
	require.EqualValues(t, 1, reads.Load())

	value.Store(1)
	changed <- struct{}{}
	for _, ch := range []<-chan struct{}{a, b} {
		select {
		case <-ch:
		case <-time.After(time.Second):
			t.Fatal("no wake after a change")
		}
	}
	require.EqualValues(t, 2, reads.Load())
	got, err = feed.latest()
	require.NoError(t, err)
	require.EqualValues(t, 1, got[0].Pid)

	changed <- struct{}{}
	require.Eventually(t, func() bool { return reads.Load() == 3 }, time.Second, time.Millisecond)
	select {
	case <-a:
		t.Fatal("wake with no change")
	case <-time.After(50 * time.Millisecond):
	}

	cancel()
	require.Eventually(t, func() bool {
		feed.mu.Lock()
		defer feed.mu.Unlock()
		return len(feed.subs) == 0
	}, time.Second, time.Millisecond)
	changed <- struct{}{}
	time.Sleep(50 * time.Millisecond)
	require.EqualValues(t, 3, reads.Load())
}

func TestBinariesStateDialsNoPort(t *testing.T) {
	ln, err := net.Listen("tcp", "127.0.0.1:0")
	require.NoError(t, err)
	defer ln.Close() //nolint:errcheck
	var accepts atomic.Int32
	go func() {
		for {
			conn, err := ln.Accept()
			if err != nil {
				return
			}
			accepts.Add(1)
			_ = conn.Close()
		}
	}()
	port := ln.Addr().(*net.TCPAddr).Port

	orch := orchestrator.New(t.TempDir(), "regtest", t.TempDir(),
		[]orchestrator.BinaryConfig{{Name: "porttest", BinaryName: "porttest", Port: port}}, zerolog.New(io.Discard))

	state := orch.ListAllState(orchestrator.DownloadOptions{})
	require.Len(t, state, 1)
	require.False(t, state[0].PortInUse)
	time.Sleep(50 * time.Millisecond)
	require.EqualValues(t, 0, accepts.Load())

	require.True(t, orch.ListAll()[0].PortInUse)
}
