package bandwidth

import (
	"bufio"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strconv"
	"strings"

	"github.com/samber/lo"
)

// Stats describes the network use of one process. No platform gives the
// bytes of one process, so the byte fields stay zero.
type Stats struct {
	PID             int
	ProcessName     string
	RxBytesPerSec   float64 // Current receive rate (bytes/sec)
	TxBytesPerSec   float64 // Current transmit rate (bytes/sec)
	TotalRxBytes    uint64  // Total bytes received
	TotalTxBytes    uint64  // Total bytes sent
	ConnectionCount int32   // Number of open internet sockets
}

// Tracker reads the network use of a process.
type Tracker struct{}

func NewTracker() *Tracker {
	return &Tracker{}
}

func (t *Tracker) GetStats(pid int, processName string) (*Stats, error) {
	if pid <= 0 {
		return nil, fmt.Errorf("invalid PID: %d", pid)
	}

	var (
		count int32
		err   error
	)
	switch runtime.GOOS {
	case "linux":
		count, err = countConnectionsLinux(pid)
	case "darwin":
		count, err = countConnectionsDarwin(pid)
	default:
		return nil, fmt.Errorf("unsupported platform: %s", runtime.GOOS)
	}
	if err != nil {
		return nil, fmt.Errorf("count connections: %w", err)
	}

	return &Stats{PID: pid, ProcessName: processName, ConnectionCount: count}, nil
}

// countConnectionsLinux counts the TCP sockets of a PID on Linux.
func countConnectionsLinux(pid int) (int32, error) {
	fdPath := fmt.Sprintf("/proc/%d/fd", pid)
	entries, err := os.ReadDir(fdPath)
	if err != nil {
		return 0, err
	}

	socketInodes := make(map[string]bool)
	for _, entry := range entries {
		link, err := os.Readlink(filepath.Join(fdPath, entry.Name()))
		if errors.Is(err, os.ErrNotExist) {
			// The process closed the fd after ReadDir.
			continue
		}
		if err != nil {
			return 0, err
		}
		if inode, ok := strings.CutPrefix(link, "socket:["); ok {
			socketInodes[strings.TrimSuffix(inode, "]")] = true
		}
	}

	var count int32
	for _, netFile := range []string{"/proc/net/tcp", "/proc/net/tcp6"} {
		n, err := countSocketsIn(netFile, socketInodes)
		if err != nil {
			return 0, err
		}
		count += n
	}
	return count, nil
}

func countSocketsIn(netFile string, socketInodes map[string]bool) (int32, error) {
	file, err := os.Open(netFile)
	if errors.Is(err, os.ErrNotExist) {
		// A kernel with no IPv6 has no tcp6 file.
		return 0, nil
	}
	if err != nil {
		return 0, err
	}
	defer file.Close()

	var count int32
	scanner := bufio.NewScanner(file)
	scanner.Scan() // Skip header

	for scanner.Scan() {
		fields := strings.Fields(scanner.Text())
		if len(fields) > 9 && socketInodes[fields[9]] {
			count++
		}
	}
	return count, scanner.Err()
}

// countConnectionsDarwin counts the internet sockets of a PID on macOS.
func countConnectionsDarwin(pid int) (int32, error) {
	output, err := exec.Command("/usr/sbin/lsof", "-a", "-i", "-n", "-P", "-p", strconv.Itoa(pid)).Output()
	var exitErr *exec.ExitError
	// lsof exits 1 when the process has no internet socket.
	if errors.As(err, &exitErr) && exitErr.ExitCode() == 1 && len(output) == 0 {
		return 0, nil
	}
	if err != nil {
		return 0, fmt.Errorf("lsof: %w", err)
	}
	return countLsofRows(string(output)), nil
}

// countLsofRows counts the rows of lsof output below the header.
func countLsofRows(output string) int32 {
	rows := lo.Filter(strings.Split(output, "\n"), func(line string, _ int) bool { return line != "" })
	return int32(max(len(rows)-1, 0))
}
