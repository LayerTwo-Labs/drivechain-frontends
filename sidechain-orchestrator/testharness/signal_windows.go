//go:build windows

package testharness

import (
	"os"
	"os/exec"
	"strconv"
)

// stopProcess kills the process and its child tree on Windows; TerminateProcess
// alone leaves grandchildren like the enforcer alive to lock temp-dir files.
func stopProcess(p *os.Process) {
	_ = exec.Command("taskkill", "/F", "/T", "/PID", strconv.Itoa(p.Pid)).Run()
	_ = p.Kill()
	_, _ = p.Wait()
}
