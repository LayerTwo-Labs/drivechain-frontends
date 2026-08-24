package logfile

import (
	"bytes"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestPath(t *testing.T) {
	require.Equal(t, filepath.Join("/data/bitwindow", "bitwindow.log"), Path("/data/bitwindow"))
}

// Three processes append to the shared file. One Write per call keeps each
// line whole, and the tag names the process that wrote it.
func TestTagMarksEveryLineInOneWrite(t *testing.T) {
	var sink countingWriter
	w := Tag(&sink, "orchestrator")

	n, err := w.Write([]byte("first\nsecond\n"))
	require.NoError(t, err)
	require.Equal(t, len("first\nsecond\n"), n)

	require.Equal(t, 1, sink.writes)
	require.Equal(t, "[orchestrator]  first\n[orchestrator]  second\n", sink.buf.String())
}

func TestTagPadsShortSourcesToTheSameColumn(t *testing.T) {
	var frontend, bitwindowd countingWriter
	_, err := Tag(&frontend, "frontend").Write([]byte("a\n"))
	require.NoError(t, err)
	_, err = Tag(&bitwindowd, "bitwindowd").Write([]byte("a\n"))
	require.NoError(t, err)

	require.Equal(t,
		len(frontend.buf.String())-len("a\n"),
		len(bitwindowd.buf.String())-len("a\n"),
	)
}

type countingWriter struct {
	buf    bytes.Buffer
	writes int
}

func (c *countingWriter) Write(p []byte) (int, error) {
	c.writes++
	return c.buf.Write(p)
}
