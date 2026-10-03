package orchestrator

import (
	"context"
	"strconv"
	"strings"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/logfile"
	"github.com/rs/zerolog"
	"os"
	"path/filepath"
	"sync"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func collectLines(t *testing.T, path string, offset int64, stop <-chan struct{}) (*[]string, <-chan struct{}) {
	t.Helper()
	var mu sync.Mutex
	lines := make([]string, 0, 8)
	done := make(chan struct{})
	go func() {
		defer close(done)
		followLogFile(path, offset, stop, func(line string, _ int64) {
			mu.Lock()
			lines = append(lines, line)
			mu.Unlock()
		})
	}()
	return &lines, done
}

func TestFollowLogFileReadsLinesTheChildAppends(t *testing.T) {
	path := filepath.Join(t.TempDir(), "child.log")
	require.NoError(t, os.WriteFile(path, []byte("first\n"), 0o644))

	stop := make(chan struct{})
	lines, done := collectLines(t, path, 0, stop)

	f, err := os.OpenFile(path, os.O_WRONLY|os.O_APPEND, 0o644)
	require.NoError(t, err)
	time.Sleep(2 * logTailPoll)
	_, err = f.WriteString("second\nthird\n")
	require.NoError(t, err)
	require.NoError(t, f.Close())
	time.Sleep(3 * logTailPoll)

	close(stop)
	<-done
	assert.Equal(t, []string{"first", "second", "third"}, *lines)
}

// A line with no newline yet still reaches the reader once the child dies.
func TestFollowLogFileFlushesTheLastPartialLine(t *testing.T) {
	path := filepath.Join(t.TempDir(), "child.log")
	require.NoError(t, os.WriteFile(path, []byte("done\nhalf"), 0o644))

	stop := make(chan struct{})
	lines, done := collectLines(t, path, 0, stop)
	time.Sleep(2 * logTailPoll)
	close(stop)
	<-done

	assert.Equal(t, []string{"done", "half"}, *lines)
}

// A truncation resets the read, so the lines after it are not lost.
func TestFollowLogFileStartsOverAfterATruncation(t *testing.T) {
	path := filepath.Join(t.TempDir(), "child.log")
	require.NoError(t, os.WriteFile(path, []byte("old line\n"), 0o644))

	stop := make(chan struct{})
	lines, done := collectLines(t, path, 0, stop)
	time.Sleep(2 * logTailPoll)

	require.NoError(t, os.Truncate(path, 0))
	time.Sleep(2 * logTailPoll)
	require.NoError(t, os.WriteFile(path, []byte("new line\n"), 0o644))
	time.Sleep(3 * logTailPoll)

	close(stop)
	<-done
	assert.Equal(t, []string{"old line", "new line"}, *lines)
}

func TestFollowLogFileReturnsOnAMissingFile(t *testing.T) {
	stop := make(chan struct{})
	close(stop)
	_, done := collectLines(t, filepath.Join(t.TempDir(), "gone.log"), 0, stop)

	select {
	case <-done:
	case <-time.After(5 * time.Second):
		t.Fatal("the tail never returned")
	}
}

// A tail resumes where the last one stopped, so the shared log holds each
// line one time across a daemon handover.
func TestReadLogOffsetResumesAtTheRecord(t *testing.T) {
	dir := t.TempDir()
	require.NoError(t, os.MkdirAll(filepath.Dir(binaryLogPath(dir, "ticker", "stdout")), 0o755))
	require.NoError(t, os.WriteFile(binaryLogPath(dir, "ticker", "stdout"), []byte("0123456789"), 0o644))

	require.NoError(t, writeLogOffset(dir, "ticker", "stdout", 4))
	assert.Equal(t, int64(4), readLogOffset(dir, "ticker", "stdout"))
}

// Without a record the tail starts at the end. The lines before it already
// reached the shared log, and a replay would double them.
func TestReadLogOffsetStartsAtTheEndWithNoRecord(t *testing.T) {
	dir := t.TempDir()
	require.NoError(t, os.MkdirAll(filepath.Dir(binaryLogPath(dir, "ticker", "stdout")), 0o755))
	require.NoError(t, os.WriteFile(binaryLogPath(dir, "ticker", "stdout"), []byte("0123456789"), 0o644))

	assert.Equal(t, int64(10), readLogOffset(dir, "ticker", "stdout"))
	assert.Equal(t, int64(0), readLogOffset(dir, "gone", "stdout"))
}

// A spawn starts a fresh session, so the record of the last one goes too.
func TestOpenBinaryLogDropsTheOffsetRecord(t *testing.T) {
	dir := t.TempDir()
	require.NoError(t, os.MkdirAll(filepath.Dir(binaryLogPath(dir, "ticker", "stdout")), 0o755))
	require.NoError(t, writeLogOffset(dir, "ticker", "stdout", 4242))

	f, err := openBinaryLog(dir, "ticker", "stdout")
	require.NoError(t, err)
	require.NoError(t, f.Close())

	assert.Equal(t, int64(0), readLogOffset(dir, "ticker", "stdout"))
}

// A spawn starts a fresh session, so the file holds no line of the last one.
func TestOpenBinaryLogStartsEmpty(t *testing.T) {
	dir := t.TempDir()
	path := binaryLogPath(dir, "sleep-test", "stdout")
	require.NoError(t, os.MkdirAll(filepath.Dir(path), 0o755))
	require.NoError(t, os.WriteFile(path, []byte("a line of the last session\n"), 0o644))

	f, err := openBinaryLog(dir, "sleep-test", "stdout")
	require.NoError(t, err)
	require.NoError(t, f.Close())

	body, err := os.ReadFile(path)
	require.NoError(t, err)
	assert.Empty(t, body)
}

// logLines returns every line the ring holds for a managed process.
func logLines(pm *ProcessManager, name string) []string {
	pm.mu.Lock()
	proc := pm.processes[name]
	pm.mu.Unlock()
	if proc == nil {
		return nil
	}
	entries := proc.RecentLogs(256)
	lines := make([]string, 0, len(entries))
	for _, e := range entries {
		lines = append(lines, e.Line)
	}
	return lines
}

func waitForLogLine(t *testing.T, pm *ProcessManager, name, want string) {
	t.Helper()
	deadline := time.Now().Add(15 * time.Second)
	for time.Now().Before(deadline) {
		for _, line := range logLines(pm, name) {
			if strings.Contains(line, want) {
				return
			}
		}
		time.Sleep(100 * time.Millisecond)
	}
	t.Fatalf("no log line held %q for %s: %v", want, name, logLines(pm, name))
}

// The whole point of the file sink: a second orchestrator adopts the child of
// the first one and still reads its output. A pipe dies with its owner.
func TestAdoptedChildKeepsItsLogs(t *testing.T) {
	o := newTestOrchestrator(t)
	symlinkSystemBinary(t, o.DataDir, "sh")
	cfg := BinaryConfig{Name: "ticker", BinaryName: "sh", ChainLayer: 1}

	pid, err := o.process.Start(context.Background(), cfg, []string{"-c", "i=0; while [ $i -lt 200 ]; do echo tick-$i; i=$((i+1)); sleep 0.2; done"}, nil)
	require.NoError(t, err)
	t.Cleanup(func() {
		if proc, err := os.FindProcess(pid); err == nil {
			_ = proc.Kill()
		}
	})
	waitForLogLine(t, o.process, "ticker", "tick-0")

	// A fresh orchestrator over the same data dir, as a retire leaves behind.
	next := NewProcessManager(o.DataDir, o.process.pidManager, zerolog.Nop())
	next.SharedLogPath = o.process.SharedLogPath
	next.AdoptProcess(cfg, pid)

	// A line the child writes after the handover, not a replay of an older one.
	waitForLogLine(t, next, "ticker", "tick-"+strconv.Itoa(highestTick(t, next)+3))
}

// highestTick reads the tick the ring holds last, so the wait that follows
// asks for output the child writes later.
func highestTick(t *testing.T, pm *ProcessManager) int {
	t.Helper()
	highest := -1
	for _, line := range logLines(pm, "ticker") {
		_, digits, found := strings.Cut(line, "tick-")
		if !found {
			continue
		}
		n, err := strconv.Atoi(digits)
		require.NoError(t, err)
		if n > highest {
			highest = n
		}
	}
	return highest
}

// Every managed binary lands in the one file a user sends, under its own tag.
// A second tail resumes at the record, so no line lands there twice.
func TestSharedLogTakesEachLineOnce(t *testing.T) {
	dir := t.TempDir()
	shared := filepath.Join(t.TempDir(), logfile.Name)
	pm := NewProcessManager(dir, nil, zerolog.Nop())
	pm.SharedLogPath = shared
	proc := &ManagedProcess{logs: make([]LogEntry, 0, 8), exitCh: make(chan struct{})}

	spool, err := openBinaryLog(dir, "ticker", "stdout")
	require.NoError(t, err)
	_, err = spool.WriteString("one\ntwo\n")
	require.NoError(t, err)

	stop := make(chan struct{})
	close(stop)
	<-pm.tailBinaryLog(proc, "ticker", "stdout", 0, stop, nil, nil)

	_, err = spool.WriteString("three\n")
	require.NoError(t, err)
	require.NoError(t, spool.Close())

	resume := make(chan struct{})
	close(resume)
	<-pm.tailBinaryLog(proc, "ticker", "stdout", readLogOffset(dir, "ticker", "stdout"), resume, nil, nil)

	body, err := os.ReadFile(shared)
	require.NoError(t, err)
	lines := strings.Split(strings.TrimRight(string(body), "\n"), "\n")
	require.Len(t, lines, 3)
	for i, want := range []string{"one", "two", "three"} {
		assert.Contains(t, lines[i], "[ticker]", "the reader must see which process wrote the line")
		assert.True(t, strings.HasSuffix(lines[i], want), "line %d held %q", i, lines[i])
	}
}
