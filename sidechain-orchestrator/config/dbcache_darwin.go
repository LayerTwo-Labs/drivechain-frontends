package config

import "golang.org/x/sys/unix"

func totalMemoryBytes() uint64 {
	total, err := unix.SysctlUint64("hw.memsize")
	if err != nil {
		return 0
	}
	return total
}
