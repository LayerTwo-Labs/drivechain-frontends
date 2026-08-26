// Package logfile holds the one log file that the bitwindow frontend,
// bitwindowd, and drivechaind all append to.
package logfile

import (
	"bytes"
	"fmt"
	"io"
	"path/filepath"
)

// Name of the shared log file. It sits in the bitwindow root dir, beside
// wallet.json.
const Name = "bitwindow.log"

// Path returns the shared log file in the given bitwindow dir.
func Path(bitwindowDir string) string {
	return filepath.Join(bitwindowDir, Name)
}

// Width of the source tag, so the merged log file lines up in a column.
const tagWidth = 15

// Tag returns a writer that marks each line with the source name. The reader
// of the merged file sees which process wrote which line.
func Tag(out io.Writer, source string) io.Writer {
	return &tagWriter{out: out, prefix: []byte(fmt.Sprintf("%-*s ", tagWidth, "["+source+"]"))}
}

type tagWriter struct {
	out    io.Writer
	prefix []byte
}

// Write sends one buffer to the file per call. Three processes append to the
// same file, and a single write keeps each line whole.
func (t *tagWriter) Write(p []byte) (int, error) {
	var buf bytes.Buffer
	buf.Grow(len(p) + len(t.prefix))
	for _, line := range bytes.SplitAfter(p, []byte("\n")) {
		if len(line) == 0 {
			continue
		}
		buf.Write(t.prefix)
		buf.Write(line)
	}

	if _, err := t.out.Write(buf.Bytes()); err != nil {
		return 0, err
	}
	return len(p), nil
}
