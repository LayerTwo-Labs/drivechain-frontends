package orchestrator

import "golang.org/x/sys/unix"

// isPidAlive reports whether a process with the given PID runs. A zombie does
// not run.
func isPidAlive(pid int) bool {
	kp, err := unix.SysctlKinfoProc("kern.proc.pid", pid)
	if err != nil {
		return false
	}
	return int(kp.Proc.P_pid) == pid && kp.Proc.P_stat != szomb
}

// szomb is the zombie state of sys/proc.h.
const szomb = 5
