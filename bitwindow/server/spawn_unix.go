//go:build !windows

package main

import (
	"os/exec"
	"syscall"
)

// configureOrchestratordSpawn puts orchestratord in its own process group so
// SIGHUP / process-group signals to bitwindowd's group don't reach it. See
// startOrchestratord in main.go for the rest of the detach setup.
func configureOrchestratordSpawn(cmd *exec.Cmd) {
	if cmd.SysProcAttr == nil {
		cmd.SysProcAttr = &syscall.SysProcAttr{}
	}
	cmd.SysProcAttr.Setpgid = true
}
