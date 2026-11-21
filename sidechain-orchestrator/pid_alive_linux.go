package orchestrator

import (
	"bytes"
	"os"
	"strconv"
)

// isPidAlive reports whether a process with the given PID runs. A zombie does
// not run.
func isPidAlive(pid int) bool {
	stat, err := os.ReadFile("/proc/" + strconv.Itoa(pid) + "/stat")
	if err != nil {
		return false
	}
	// The state follows the command name, which can hold spaces and parens.
	end := bytes.LastIndexByte(stat, ')')
	if end < 0 || end+2 >= len(stat) {
		return false
	}
	state := stat[end+2]
	return state != 'Z' && state != 'X'
}
