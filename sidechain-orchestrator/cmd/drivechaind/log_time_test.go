package main

import (
	"bytes"
	"testing"
	"time"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

func TestLogTimestampsKeepMilliseconds(t *testing.T) {
	prev := zerolog.TimestampFunc
	t.Cleanup(func() { zerolog.TimestampFunc = prev })
	zerolog.TimestampFunc = func() time.Time { return time.Date(2026, 1, 2, 3, 4, 5, 678_000_000, time.Local) }

	var buf bytes.Buffer
	log := zerolog.New(zerolog.ConsoleWriter{Out: &buf, NoColor: true, TimeFormat: "15:04:05.000"}).With().Timestamp().Logger()
	log.Info().Msg("boot step")

	require.Contains(t, buf.String(), "03:04:05.678")
}
