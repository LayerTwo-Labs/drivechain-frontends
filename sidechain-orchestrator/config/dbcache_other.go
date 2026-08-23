//go:build !darwin && !linux && !windows

package config

func totalMemoryBytes() uint64 {
	return 0
}
