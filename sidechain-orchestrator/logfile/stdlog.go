package logfile

import (
	stdlog "log"
	"strings"

	"github.com/rs/zerolog"
)

// TransportNoise names the net/http lines a booting daemon repeats once a
// second: a refused dial through the enforcer proxy, and a client that drops
// an HTTP/2 frame.
func TransportNoise(line string) bool {
	return strings.HasPrefix(line, "http: proxy error:") ||
		strings.HasPrefix(line, "http2: server connection error")
}

// StdLogger adapts a zerolog logger for net/http, which writes through the
// standard logger. quiet picks the lines that drop to debug; every other line,
// a handler panic and its stack included, stays at error.
func StdLogger(log zerolog.Logger, quiet func(string) bool) *stdlog.Logger {
	return stdlog.New(levelWriter{log: log, quiet: quiet}, "", 0)
}

type levelWriter struct {
	log   zerolog.Logger
	quiet func(string) bool
}

func (w levelWriter) Write(p []byte) (int, error) {
	line := strings.TrimRight(string(p), "\n")
	level := zerolog.ErrorLevel
	if w.quiet != nil && w.quiet(line) {
		level = zerolog.DebugLevel
	}
	w.log.WithLevel(level).Msg(line)
	return len(p), nil
}
