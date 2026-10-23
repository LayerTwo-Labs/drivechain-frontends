package api

import (
	"context"
	"errors"
	"net/http"
	"os"
	"path/filepath"
	"runtime"
	"sync"
	"testing"
	"time"

	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
)

type pausedLogStream struct {
	connect.ServerStream
	beforeSend func() error
}

func (s *pausedLogStream) Send(msg any) error {
	if err := s.beforeSend(); err != nil {
		return err
	}
	return s.ServerStream.Send(msg)
}

func TestStreamLogsReportsOverflowAndResumes(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("the test executable uses a shell")
	}
	home := config.HomeDir()
	config.SetHomeDir(t.TempDir())
	t.Cleanup(func() { config.SetHomeDir(home) })
	orch := newTestOrchHandlerWithBinary(t, orchestrator.BinaryConfig{Name: "logtest", BinaryName: "logtest"})
	t.Cleanup(func() { require.NoError(t, orch.Stop(context.Background(), "logtest", false)) })
	require.NoError(t, os.MkdirAll(orchestrator.BinDir(orch.DataDir), 0o700))
	require.NoError(t, os.WriteFile(orchestrator.BinaryPath(orch.DataDir, "logtest"), []byte(`#!/bin/sh
i=1
while [ "$i" -le 5000 ]; do printf 'saved %s\n' "$i"; i=$((i + 1)); done
while [ ! -f "$LOG_RELEASE" ]; do sleep 0.01; done
i=1
while [ "$i" -le 150 ]; do printf 'live %s\n' "$i"; i=$((i + 1)); done
exec sleep 30
`), 0o700))
	gate := filepath.Join(t.TempDir(), "release")
	_, err := orch.Start(t.Context(), "logtest", nil, map[string]string{"LOG_RELEASE": gate})
	require.NoError(t, err)
	waitForLine := func(line string) {
		require.EventuallyWithT(t, func(c *assert.CollectT) {
			entries, err := orch.RecentLogs("logtest", 1)
			require.NoError(c, err)
			require.Len(c, entries, 1)
			require.Equal(c, line, entries[0].Line)
		}, 5*time.Second, 10*time.Millisecond)
	}
	waitForLine("saved 5000")
	latest, err := orch.RecentLogs("logtest", 1)
	require.NoError(t, err)
	runID := latest[0].RunID

	ready := make(chan struct{})
	resume := make(chan struct{})
	signal := sync.OnceFunc(func() { close(ready) })
	release := sync.OnceFunc(func() { close(resume) })
	server := connect.NewServer(func(next connect.ServerFunc) connect.ServerFunc {
		return func(ctx context.Context, spec connect.Spec, stream connect.ServerStream) error {
			return next(ctx, spec, &pausedLogStream{ServerStream: stream, beforeSend: func() error {
				signal()
				select {
				case <-resume:
					return nil
				case <-ctx.Done():
					return ctx.Err()
				}
			}})
		}
	})
	mux := http.NewServeMux()
	rpc.RegisterOrchestratorServiceHandler(server, NewHandler(orch))
	connecthttp.Mount(mux, server, connecthttp.WithReadMaxBytes(0))
	srv := h2cServer(mux)
	defer srv.Close()
	defer release()
	client := rpc.NewOrchestratorServiceClient(connect.NewClient(connecthttp.NewTransport(h2cClient(), srv.URL, connecthttp.WithGRPC())))
	ctx, cancel := context.WithTimeout(t.Context(), 10*time.Second)
	defer cancel()
	type result struct {
		entries []*pb.StreamLogsResponse
		err     error
	}
	done := make(chan result, 1)
	go func() {
		stream, err := client.StreamLogs(ctx, &pb.StreamLogsRequest{Name: "logtest", Tail: 100, RunId: runID, AfterSequence: 1})
		if err != nil {
			done <- result{err: err}
			return
		}
		var received result
		for {
			entry, err := stream.Receive()
			if err != nil {
				received.err = errors.Join(err, stream.Close())
				done <- received
				return
			}
			received.entries = append(received.entries, entry)
		}
	}()
	select {
	case <-ready:
	case <-ctx.Done():
		t.Fatal("the API did not send the saved output")
	}
	require.NoError(t, os.WriteFile(gate, nil, 0o600))
	waitForLine("live 150")
	release()
	var received result
	select {
	case received = <-done:
	case <-ctx.Done():
		t.Fatal("the API did not stop after the buffer filled")
	}
	var streamErr *connect.Error
	require.ErrorAs(t, received.err, &streamErr)
	require.Equal(t, connect.CodeResourceExhausted, streamErr.Code())
	require.Len(t, received.entries, 5100)
	for i, entry := range received.entries {
		require.Equal(t, uint64(i+2), entry.Sequence)
	}
	require.True(t, orch.Status("logtest").Running)
	stream, err := client.StreamLogs(ctx, &pb.StreamLogsRequest{Name: "logtest", Tail: 100, RunId: runID, AfterSequence: 5101})
	require.NoError(t, err)
	defer func() { require.NoError(t, stream.Close()) }()
	for i := range 50 {
		entry, err := stream.Receive()
		require.NoError(t, err)
		require.Equal(t, uint64(5102+i), entry.Sequence)
	}
}
