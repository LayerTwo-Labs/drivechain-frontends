package logfile

import (
	"bytes"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

// net/http repeats a refused dial once per retry. The bridge holds those lines
// at debug, so an info console stays clean.
func TestStdLoggerHoldsTransportNoiseAtDebug(t *testing.T) {
	var sink bytes.Buffer
	log := zerolog.New(&sink).Level(zerolog.InfoLevel)

	StdLogger(log, TransportNoise).Printf("http: proxy error: dial tcp 127.0.0.1:50051: connect: connection refused")
	StdLogger(log, TransportNoise).Printf("http2: server connection error from 127.0.0.1:1: connection error: PROTOCOL_ERROR")

	require.Empty(t, sink.String())
}

// Server.ErrorLog also carries a handler panic and its stack. Losing that hides
// a real failure, so every line the filter does not name stays at error.
func TestStdLoggerKeepsEveryOtherLineAtError(t *testing.T) {
	var sink bytes.Buffer
	log := zerolog.New(&sink).Level(zerolog.InfoLevel)

	StdLogger(log, TransportNoise).Printf("http: panic serving 127.0.0.1:1: runtime error: index out of range")

	require.Contains(t, sink.String(), `"level":"error"`)
	require.Contains(t, sink.String(), "panic serving")
}

func TestStdLoggerWritesOneLineWithoutTheTrailingNewline(t *testing.T) {
	var sink bytes.Buffer
	log := zerolog.New(&sink).Level(zerolog.DebugLevel)

	StdLogger(log, TransportNoise).Printf("http2: server connection error")

	require.Equal(t, `{"level":"debug","message":"http2: server connection error"}`+"\n", sink.String())
}

// A nil filter must not silence anything.
func TestStdLoggerWithoutAFilterKeepsEveryLineAtError(t *testing.T) {
	var sink bytes.Buffer
	log := zerolog.New(&sink).Level(zerolog.InfoLevel)

	StdLogger(log, nil).Printf("http: proxy error: connection refused")

	require.Contains(t, sink.String(), `"level":"error"`)
}

func TestTransportNoiseNamesOnlyTheTwoRepeatedLines(t *testing.T) {
	require.True(t, TransportNoise("http: proxy error: dial tcp: connection refused"))
	require.True(t, TransportNoise("http2: server connection error from 1.2.3.4:5"))
	require.False(t, TransportNoise("http: panic serving 127.0.0.1:1"))
	require.False(t, TransportNoise("http: TLS handshake error"))
	require.False(t, TransportNoise(""))
}
