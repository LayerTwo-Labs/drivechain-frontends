package wallet

import (
	"bufio"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
	"sync"
)

// hwiDaemon is the persistent hardware-wallet process.
type hwiDaemon struct {
	cmd *exec.Cmd
	in  io.WriteCloser
	out *bufio.Reader
}

var (
	daemonMu sync.Mutex
	daemon   *hwiDaemon
)

// hwiCall sends one request to the shared daemon and returns its raw JSON reply.
func hwiCall(ctx context.Context, req map[string]any) (json.RawMessage, error) {
	daemonMu.Lock()
	defer daemonMu.Unlock()

	if daemon == nil {
		d, err := startHWIDaemon()
		if err != nil {
			return nil, err
		}
		daemon = d
	}

	raw, err := daemon.roundtrip(ctx, req)
	if err != nil {
		// Process died or the caller cancelled; drop it so the next call restarts it.
		daemon.close()
		daemon = nil
		return nil, err
	}

	var e struct {
		Error string `json:"error"`
		Code  int    `json:"code"`
	}
	if json.Unmarshal(raw, &e) == nil && e.Error != "" {
		return nil, fmt.Errorf("hwi error %d: %s", e.Code, e.Error)
	}
	return raw, nil
}

func (d *hwiDaemon) roundtrip(ctx context.Context, req map[string]any) (json.RawMessage, error) {
	body, err := json.Marshal(req)
	if err != nil {
		return nil, err
	}
	if _, err := d.in.Write(append(body, '\n')); err != nil {
		return nil, fmt.Errorf("write to hwi daemon: %w", err)
	}
	type reply struct {
		line []byte
		err  error
	}
	ch := make(chan reply, 1)
	go func() {
		line, err := d.out.ReadBytes('\n')
		ch <- reply{line, err}
	}()
	select {
	case <-ctx.Done():
		return nil, ctx.Err()
	case r := <-ch:
		if r.err != nil {
			return nil, fmt.Errorf("read from hwi daemon: %w", r.err)
		}
		return json.RawMessage(r.line), nil
	}
}

func (d *hwiDaemon) close() {
	if d.in != nil {
		_ = d.in.Close()
	}
	if d.cmd != nil && d.cmd.Process != nil {
		_ = d.cmd.Process.Kill()
	}
}

func startHWIDaemon() (*hwiDaemon, error) {
	name, args := hwiDaemonCommand()
	cmd := exec.Command(name, args...)
	cmd.Stderr = os.Stderr
	in, err := cmd.StdinPipe()
	if err != nil {
		return nil, err
	}
	out, err := cmd.StdoutPipe()
	if err != nil {
		return nil, err
	}
	if err := cmd.Start(); err != nil {
		return nil, fmt.Errorf("start hwi daemon (%s): %w", name, err)
	}
	return &hwiDaemon{cmd: cmd, in: in, out: bufio.NewReader(out)}, nil
}

// hwiDaemonCommand resolves the daemon launch command: the
// ORCHESTRATOR_HWI_DAEMON override, else the bundled binary beside the exe.
func hwiDaemonCommand() (string, []string) {
	if p := os.Getenv("ORCHESTRATOR_HWI_DAEMON"); p != "" {
		if strings.HasSuffix(p, ".py") {
			return "python3", []string{p}
		}
		return p, nil
	}
	name := "hwi-daemon"
	if runtime.GOOS == "windows" {
		name = "hwi-daemon.exe"
	}
	if exe, err := os.Executable(); err == nil {
		bundled := filepath.Join(filepath.Dir(exe), name)
		if _, statErr := os.Stat(bundled); statErr == nil {
			return bundled, nil
		}
	}
	return name, nil
}
