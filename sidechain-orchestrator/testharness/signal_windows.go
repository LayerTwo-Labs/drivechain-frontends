//go:build windows

package testharness

import "os"

// stopProcess kills the process on Windows (no SIGTERM support).
func stopProcess(p *os.Process) {
	_ = p.Kill()
	_, _ = p.Wait()
}
