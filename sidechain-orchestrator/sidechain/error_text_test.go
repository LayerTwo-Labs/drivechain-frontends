package sidechain

import (
	"context"
	"errors"
	"fmt"
	"net"
	"os"
	"testing"

	"connectrpc.com/connect/v2"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func refusedDialError(t *testing.T) error {
	t.Helper()
	listener, err := net.Listen("tcp", "127.0.0.1:0")
	require.NoError(t, err)
	addr := listener.Addr().String()
	require.NoError(t, listener.Close())
	conn, err := net.Dial("tcp", addr)
	if conn != nil {
		require.NoError(t, conn.Close())
	}
	require.Error(t, err)
	return err
}

func TestWithErrorTextKeepsTheText(t *testing.T) {
	boom := errors.New("boom")
	tests := []struct {
		name     string
		err      error
		wantCode connect.Code
		wantText string
	}{
		{name: "plain error", err: boom, wantCode: connect.CodeUnknown, wantText: "boom"},
		{name: "wrapped plain error", err: fmt.Errorf("transfer: %w", boom), wantCode: connect.CodeUnknown, wantText: "transfer: boom"},
		{name: "canceled", err: fmt.Errorf("http post: %w", context.Canceled), wantCode: connect.CodeCanceled, wantText: "http post: context canceled"},
		{name: "deadline", err: fmt.Errorf("http post: %w", context.DeadlineExceeded), wantCode: connect.CodeDeadlineExceeded, wantText: "http post: context deadline exceeded"},
		{name: "os deadline", err: fmt.Errorf("read: %w", os.ErrDeadlineExceeded), wantCode: connect.CodeDeadlineExceeded, wantText: "read: i/o timeout"},
		{name: "remote connect error", err: fmt.Errorf("enforcer: %w", connect.NewError(connect.CodeUnavailable, "down").WithRemote()), wantCode: connect.CodeInternal, wantText: "enforcer: unavailable: down"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got := withErrorText(tt.err)
			cerr, ok := errors.AsType[*connect.Error](got)
			require.True(t, ok)
			assert.False(t, cerr.IsRemote())
			assert.Equal(t, tt.wantCode, cerr.Code())
			assert.Equal(t, tt.wantText, cerr.Message())
			assert.ErrorIs(t, got, tt.err)
		})
	}
}

func TestWithErrorTextMarksARefusedConnectionUnavailable(t *testing.T) {
	dialErr := refusedDialError(t)
	err := fmt.Errorf("http post: %w", dialErr)

	cerr, ok := errors.AsType[*connect.Error](withErrorText(err))

	require.True(t, ok)
	assert.Equal(t, connect.CodeUnavailable, cerr.Code())
	assert.Contains(t, cerr.Message(), "http post: ")
	assert.Contains(t, cerr.Message(), "connection refused")
	assert.ErrorIs(t, cerr, dialErr)
}

func TestWithErrorTextKeepsALocalConnectError(t *testing.T) {
	local := connect.NewError(connect.CodeInvalidArgument, "bad address")
	wrapped := fmt.Errorf("transfer: %w", local)

	assert.Same(t, local, withErrorText(local))
	assert.Equal(t, wrapped, withErrorText(wrapped))
}

func TestWithErrorTextKeepsNil(t *testing.T) {
	assert.NoError(t, withErrorText(nil))
}
