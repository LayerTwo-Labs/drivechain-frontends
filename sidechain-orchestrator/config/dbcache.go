package config

import "strconv"

const (
	minDBCacheMiB = 450
	maxDBCacheMiB = 16384
)

// DefaultDBCacheMiB is the -dbcache value for bitcoin.conf: a quarter of host
// memory, clamped to [450, 16384].
func DefaultDBCacheMiB() int {
	total := totalMemoryBytes()
	if total == 0 {
		return minDBCacheMiB
	}
	cache := int(total / 4 / (1024 * 1024))
	if cache < minDBCacheMiB {
		return minDBCacheMiB
	}
	if cache > maxDBCacheMiB {
		return maxDBCacheMiB
	}
	return cache
}

func defaultDBCacheSetting() string {
	return strconv.Itoa(DefaultDBCacheMiB())
}
