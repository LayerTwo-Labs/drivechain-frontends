//go:build windows

package main

import (
	"os/exec"
	"syscall"
)

// configureDrivechaindSpawn detaches drivechaind from bitwindowd's
// process group so console signals don't propagate. See startDrivechaind
// in main.go for the rest of the detach setup.
func configureDrivechaindSpawn(cmd *exec.Cmd) {
	if cmd.SysProcAttr == nil {
		cmd.SysProcAttr = &syscall.SysProcAttr{}
	}
	cmd.SysProcAttr.CreationFlags |= syscall.CREATE_NEW_PROCESS_GROUP
}
