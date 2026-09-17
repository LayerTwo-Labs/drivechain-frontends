package api

import (
	"errors"
	"testing"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
)

// Every daemon answers the same way while it boots, and the console holds
// nothing the reader can act on until one of them is up.
func TestGetLogLevelDuringBoot(t *testing.T) {
	tests := []struct {
		name      string
		procedure string
		code      connect.Code
		err       error
		want      zerolog.Level
	}{
		{
			name:      "the enforcer is not up yet",
			procedure: "/drivechain.v1.DrivechainService/ListSidechains",
			code:      connect.CodeInternal,
			err:       errors.New("internal: enforcer: unavailable: enforcer does not accept connections"),
			want:      zerolog.Disabled,
		},
		{
			name:      "Core still loads its block index",
			procedure: "/bitwindowd.v1.BitwindowdService/ListBlocks",
			code:      connect.CodeUnknown,
			err:       errors.New("-28: Loading block index…"),
			want:      zerolog.Disabled,
		},
		{
			name:      "a real fault still prints",
			procedure: "/drivechain.v1.DrivechainService/ListSidechains",
			code:      connect.CodeInternal,
			err:       errors.New("no such column: slot"),
			want:      zerolog.ErrorLevel,
		},
		{
			name:      "Core stays quiet while it is busy",
			procedure: "/bitwindowd.v1.BitwindowdService/ListBlocks",
			code:      connect.CodeUnknown,
			err:       errors.New("-28: Verifying blocks…"),
			want:      zerolog.Disabled,
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			assert.Equal(t, tc.want, getLogLevel(tc.procedure, tc.code, tc.err))
		})
	}
}
