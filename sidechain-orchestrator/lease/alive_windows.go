//go:build windows

package lease

import "syscall"

const (
	processQueryLimitedInformation = 0x1000
	stillActive                    = 259
)

func alive(pid int) bool {
	handle, err := syscall.OpenProcess(processQueryLimitedInformation, false, uint32(pid))
	if err != nil {
		return false
	}
	defer syscall.CloseHandle(handle) //nolint:errcheck

	var code uint32
	if err := syscall.GetExitCodeProcess(handle, &code); err != nil {
		return false
	}
	return code == stillActive
}
