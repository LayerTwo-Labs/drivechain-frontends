//go:build !windows

package testharness

import (
	"os"
	"syscall"
)

// stopProcess sends SIGTERM and waits for the process to exit.
func stopProcess(p *os.Process) {
	_ = p.Signal(syscall.SIGTERM)
	_, _ = p.Wait()
}
