package bandwidth

import (
	"bufio"
	"fmt"
	"os"
	"os/exec"
	"runtime"
	"strconv"
	"strings"
	"time"
)

// Stats represents network bandwidth statistics for a process
type Stats struct {
	PID             int
	ProcessName     string
	RxBytesPerSec   float64 // Current receive rate (bytes/sec)
	TxBytesPerSec   float64 // Current transmit rate (bytes/sec)
	TotalRxBytes    uint64  // Total bytes received
	TotalTxBytes    uint64  // Total bytes sent
	ConnectionCount int32   // Number of active network connections
	lastRx          uint64
	lastTx          uint64
	lastSampleTime  time.Time
}

// Tracker maintains bandwidth statistics for multiple processes
type Tracker struct {
	stats map[int]*Stats
}

// NewTracker creates a new bandwidth tracker
func NewTracker() *Tracker {
	return &Tracker{
		stats: make(map[int]*Stats),
	}
}

// GetStats returns bandwidth statistics for a process
func (t *Tracker) GetStats(pid int, processName string) (*Stats, error) {
	if pid <= 0 {
		return nil, fmt.Errorf("invalid PID: %d", pid)
	}

	// Get or create stats entry
	stats, exists := t.stats[pid]
	if !exists {
		stats = &Stats{
			PID:            pid,
			ProcessName:    processName,
			lastSampleTime: time.Now(),
		}
		t.stats[pid] = stats
	}

	// Update statistics based on platform
	if err := t.updateStats(stats); err != nil {
		return nil, fmt.Errorf("update stats: %w", err)
	}

	return stats, nil
}

// updateStats updates the bandwidth statistics for a process
func (t *Tracker) updateStats(stats *Stats) error {
	switch runtime.GOOS {
	case "linux":
		return t.updateStatsLinux(stats)
	case "darwin":
		return t.updateStatsDarwin(stats)
	case "windows":
		return t.updateStatsWindows(stats)
	default:
		return fmt.Errorf("unsupported platform: %s", runtime.GOOS)
	}
}

// updateStatsLinux updates stats on Linux using /proc filesystem
func (t *Tracker) updateStatsLinux(stats *Stats) error {
	// Read /proc/<pid>/net/dev for network stats
	netDevPath := fmt.Sprintf("/proc/%d/net/dev", stats.PID)
	file, err := os.Open(netDevPath)
	if err != nil {
		return fmt.Errorf("open %s: %w", netDevPath, err)
	}
	defer file.Close()

	var totalRx, totalTx uint64
	scanner := bufio.NewScanner(file)

	// Skip first two header lines
	scanner.Scan()
	scanner.Scan()

	for scanner.Scan() {
		line := scanner.Text()
		fields := strings.Fields(line)
		if len(fields) < 10 {
			continue
		}

		// Skip loopback interface
		if strings.HasPrefix(fields[0], "lo:") {
			continue
		}

		// Parse receive bytes (field 1) and transmit bytes (field 9)
		rxBytes, _ := strconv.ParseUint(fields[1], 10, 64)
		txBytes, _ := strconv.ParseUint(fields[9], 10, 64)

		totalRx += rxBytes
		totalTx += txBytes
	}

	// Calculate rates if we have previous sample
	now := time.Now()
	if stats.lastSampleTime.Unix() > 0 {
		elapsed := now.Sub(stats.lastSampleTime).Seconds()
		if elapsed > 0 {
			stats.RxBytesPerSec = float64(totalRx-stats.lastRx) / elapsed
			stats.TxBytesPerSec = float64(totalTx-stats.lastTx) / elapsed
		}
	}

	stats.TotalRxBytes = totalRx
	stats.TotalTxBytes = totalTx
	stats.lastRx = totalRx
	stats.lastTx = totalTx
	stats.lastSampleTime = now

	// Count connections using netstat
	stats.ConnectionCount = t.countConnectionsLinux(stats.PID)

	return scanner.Err()
}

// countConnectionsLinux counts active network connections for a PID on Linux
func (t *Tracker) countConnectionsLinux(pid int) int32 {
	// Use /proc/net/tcp and /proc/net/tcp6
	count := int32(0)

	// Get socket inodes for this process
	fdPath := fmt.Sprintf("/proc/%d/fd", pid)
	entries, err := os.ReadDir(fdPath)
	if err != nil {
		return 0
	}

	socketInodes := make(map[string]bool)
	for _, entry := range entries {
		link, err := os.Readlink(fmt.Sprintf("%s/%s", fdPath, entry.Name()))
		if err != nil {
			continue
		}
		if strings.HasPrefix(link, "socket:[") {
			inode := strings.TrimPrefix(link, "socket:[")
			inode = strings.TrimSuffix(inode, "]")
			socketInodes[inode] = true
		}
	}

	// Count matching sockets in /proc/net/tcp
	for _, netFile := range []string{"/proc/net/tcp", "/proc/net/tcp6"} {
		file, err := os.Open(netFile)
		if err != nil {
			continue
		}
		defer file.Close()

		scanner := bufio.NewScanner(file)
		scanner.Scan() // Skip header

		for scanner.Scan() {
			fields := strings.Fields(scanner.Text())
			if len(fields) > 9 {
				inode := fields[9]
				if socketInodes[inode] {
					count++
				}
			}
		}
	}

	return count
}

// updateStatsDarwin updates stats on macOS using lsof
func (t *Tracker) updateStatsDarwin(stats *Stats) error {
	// Use netstat to get per-process network stats on macOS
	cmd := exec.Command("netstat", "-I", "en0", "-b")
	output, err := cmd.Output()
	if err != nil {
		// Fallback: return zero stats instead of error
		return nil
	}

	// Parse netstat output (simplified - actual implementation needs proper parsing)
	lines := strings.Split(string(output), "\n")
	if len(lines) > 1 {
		// This is a simplified version - real implementation would parse the output properly
		// For now, we'll use lsof to count connections
		stats.ConnectionCount = t.countConnectionsDarwin(stats.PID)
	}

	return nil
}

// countConnectionsDarwin counts active network connections for a PID on macOS
func (t *Tracker) countConnectionsDarwin(pid int) int32 {
	cmd := exec.Command("lsof", "-i", "-n", "-P", "-p", strconv.Itoa(pid))
	output, err := cmd.Output()
	if err != nil {
		return 0
	}

	// Count lines (minus header)
	lines := strings.Split(string(output), "\n")
	count := len(lines) - 1
	if count < 0 {
		count = 0
	}

	return int32(count)
}

// updateStatsWindows updates stats on Windows using netstat
func (t *Tracker) updateStatsWindows(stats *Stats) error {
	// Use netstat -ano to get connections by PID on Windows
	cmd := exec.Command("netstat", "-ano")
	output, err := cmd.Output()
	if err != nil {
		return nil // Return nil instead of error for graceful degradation
	}

	pidStr := strconv.Itoa(stats.PID)
	count := int32(0)

	lines := strings.Split(string(output), "\n")
	for _, line := range lines {
		if strings.Contains(line, pidStr) {
			count++
		}
	}

	stats.ConnectionCount = count
	return nil
}
