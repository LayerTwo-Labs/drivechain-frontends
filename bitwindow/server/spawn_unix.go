//go:build !windows

package main

import (
	"os/exec"
	"syscall"
)

// configureDrivechaindSpawn puts drivechaind in its own process group so
// SIGHUP / process-group signals to bitwindowd's group don't reach it. See
// startDrivechaind in main.go for the rest of the detach setup.
func configureDrivechaindSpawn(cmd *exec.Cmd) {
	if cmd.SysProcAttr == nil {
		cmd.SysProcAttr = &syscall.SysProcAttr{}
	}
	cmd.SysProcAttr.Setpgid = true
}
