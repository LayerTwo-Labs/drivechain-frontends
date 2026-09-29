package orchestrator

import (
	"bufio"
	"bytes"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/logfile"
)

const (
	logTailPoll  = 200 * time.Millisecond
	logTailChunk = 64 * 1024
	// How often the tail records how far it read. A crash replays at most
	// this much into the shared log.
	logOffsetSave = 2 * time.Second
)

// binaryLogPath names the file a child appends one stream to. A child owns its
// own descriptor on this file, so the lines outlive the orchestrator that
// spawned it and the next orchestrator reads them again. A user never sends
// this file: the tail copies every line into the one shared log.
func binaryLogPath(dataDir, processName, stream string) string {
	return filepath.Join(dataDir, "logs", processName+"."+stream+".log")
}

// binaryLogOffsetPath names the file that records how far the tail read.
func binaryLogOffsetPath(dataDir, processName, stream string) string {
	return binaryLogPath(dataDir, processName, stream) + ".offset"
}

// openBinaryLog opens the sink of a spawned child. A spawn starts a fresh
// session, so the file starts empty and the tail starts at the top.
func openBinaryLog(dataDir, processName, stream string) (*os.File, error) {
	path := binaryLogPath(dataDir, processName, stream)
	if err := os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
		return nil, err
	}
	if err := os.Remove(binaryLogOffsetPath(dataDir, processName, stream)); err != nil && !os.IsNotExist(err) {
		return nil, err
	}
	return os.OpenFile(path, os.O_CREATE|os.O_WRONLY|os.O_APPEND|os.O_TRUNC, 0o644)
}

// readLogOffset returns the offset a tail resumes at. Without a record the
// tail starts at the end: the lines before it already reached the shared log
// under an orchestrator that kept no count, and a replay would double them.
func readLogOffset(dataDir, processName, stream string) int64 {
	body, err := os.ReadFile(binaryLogOffsetPath(dataDir, processName, stream))
	if err == nil {
		offset, convErr := strconv.ParseInt(strings.TrimSpace(string(body)), 10, 64)
		if convErr == nil && offset >= 0 {
			return offset
		}
	}
	info, err := os.Stat(binaryLogPath(dataDir, processName, stream))
	if err != nil {
		return 0
	}
	return info.Size()
}

// writeLogOffset records how far the tail read.
func writeLogOffset(dataDir, processName, stream string, offset int64) error {
	return os.WriteFile(binaryLogOffsetPath(dataDir, processName, stream), []byte(strconv.FormatInt(offset, 10)), 0o644)
}

// followLogFile hands every line of path to emit, with the offset that follows
// the line. It returns once stop closes and the file holds nothing more. A
// file that shrinks means a truncation, so the read starts again at the top.
func followLogFile(path string, offset int64, stop <-chan struct{}, emit func(line string, next int64)) {
	f, err := os.Open(path)
	if err != nil {
		return
	}
	defer f.Close() //nolint:errcheck // read only
	if _, err := f.Seek(offset, io.SeekStart); err != nil {
		return
	}

	reader := bufio.NewReaderSize(f, logTailChunk)
	pos := offset
	var partial []byte
	stopped := false
	for {
		for {
			chunk, readErr := reader.ReadBytes('\n')
			partial = append(partial, chunk...)
			pos += int64(len(chunk))
			if len(partial) > 0 && partial[len(partial)-1] == '\n' {
				emit(string(bytes.TrimRight(partial, "\r\n")), pos)
				partial = partial[:0]
			}
			if readErr != nil {
				break
			}
		}

		if shrank(f) {
			if _, err := f.Seek(0, io.SeekStart); err != nil {
				return
			}
			reader.Reset(f)
			pos = 0
			partial = partial[:0]
			continue
		}

		if stopped {
			if len(partial) > 0 {
				emit(string(bytes.TrimRight(partial, "\r\n")), pos)
			}
			return
		}

		select {
		case <-stop:
			stopped = true
		case <-time.After(logTailPoll):
		}
	}
}

// shrank reports whether the file now holds less than the reader took from it.
func shrank(f *os.File) bool {
	info, err := f.Stat()
	if err != nil {
		return false
	}
	pos, err := f.Seek(0, io.SeekCurrent)
	if err != nil {
		return false
	}
	return info.Size() < pos
}

// sharedLogWriter appends the lines of one binary to the single log file a
// user sends, under the source tag that names the process that wrote them.
func (pm *ProcessManager) sharedLogWriter(processName string) (io.Writer, func()) {
	if pm.SharedLogPath == "" {
		return nil, func() {}
	}
	f, err := os.OpenFile(pm.SharedLogPath, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0o644)
	if err != nil {
		pm.log.Warn().Err(err).Str("binary", processName).Msg("open the shared log")
		return nil, func() {}
	}
	return logfile.Tag(f, processName), func() { _ = f.Close() }
}

// tailBinaryLog follows one stream of a managed binary. Every line it keeps
// goes to the log ring of the process and to the one shared log file. The
// channel it returns closes once the tail reads the last line. also takes each
// kept line after the ring does, for a caller that buffers stderr.
func (pm *ProcessManager) tailBinaryLog(
	proc *ManagedProcess,
	processName, stream string,
	offset int64,
	stop <-chan struct{},
	captureStartupLog func(string),
	also func(string),
) <-chan struct{} {
	done := make(chan struct{})
	path := binaryLogPath(pm.dataDir, processName, stream)
	shared, closeShared := pm.sharedLogWriter(processName)

	go func() {
		defer close(done)
		defer closeShared()

		read := offset
		lastSave := time.Now()
		save := func() {
			if err := writeLogOffset(pm.dataDir, processName, stream, read); err != nil {
				pm.log.Warn().Err(err).Str("binary", processName).Msg("record the log offset")
			}
			lastSave = time.Now()
		}
		defer save()

		followLogFile(path, offset, stop, func(raw string, next int64) {
			read = next
			line := stripANSI(raw)
			if isSpam(line) {
				return
			}
			proc.addLog(LogEntry{Timestamp: time.Now(), Stream: stream, Line: line})
			if shared != nil {
				if _, err := fmt.Fprintln(shared, line); err != nil {
					pm.log.Warn().Err(err).Str("binary", processName).Msg("append to the shared log")
				}
			}
			if captureStartupLog != nil {
				captureStartupLog(line)
			}
			if also != nil {
				also(line)
			}
			if time.Since(lastSave) >= logOffsetSave {
				save()
			}
		})
	}()
	return done
}
