// Package instance holds the two settings that let several BitWindow installs
// run on one machine: a home directory and a port offset.
package instance

import (
	"fmt"
	"net"
	"os"
	"path/filepath"
	"strconv"
	"strings"
)

const (
	// HomeEnv names the directory that replaces the user's home for every data path.
	HomeEnv = "BITWINDOW_HOME"
	// PortOffsetEnv names the integer added to every fixed port.
	PortOffsetEnv = "BITWINDOW_PORT_OFFSET"
	// MaxPortOffset keeps the highest generated port, 58004 for a signet
	// sidechain, under 65536.
	MaxPortOffset = 7500
)

// Home returns BITWINDOW_HOME, or "" when it is not set.
func Home() string {
	return os.Getenv(HomeEnv)
}

// UserHome returns BITWINDOW_HOME, or the user's home directory when it is not set.
func UserHome() (string, error) {
	if home := Home(); home != "" {
		return home, nil
	}
	return os.UserHomeDir()
}

// PortOffset returns BITWINDOW_PORT_OFFSET, or 0 when it is not set.
func PortOffset() (int, error) {
	raw := os.Getenv(PortOffsetEnv)
	if raw == "" {
		return 0, nil
	}
	offset, err := strconv.Atoi(raw)
	if err != nil || offset < 0 || offset > MaxPortOffset {
		return 0, fmt.Errorf("%s=%q: give an integer from 0 to %d", PortOffsetEnv, raw, MaxPortOffset)
	}
	return offset, nil
}

// Port returns base plus the port offset. A base of 0 means no port and stays 0.
// It panics on a bad offset, so a process calls [PortOffset] at startup first.
func Port(base int) int {
	offset, err := PortOffset()
	if err != nil {
		panic(err)
	}
	if base == 0 {
		return 0
	}
	return base + offset
}

// Isolated reports whether BITWINDOW_HOME or a port offset sets this install
// apart from the default install.
func Isolated() bool {
	return Home() != "" || Port(1) != 1
}

// Addr returns host:Port(base).
func Addr(host string, base int) string {
	return net.JoinHostPort(host, strconv.Itoa(Port(base)))
}

// Environ returns os.Environ for a child process. A non-empty home replaces
// HOME, APPDATA and BITWINDOW_HOME and drops XDG_DATA_HOME, so a child that
// reads them keeps its data there.
func Environ(home string) []string {
	env := os.Environ()
	if home == "" {
		return env
	}
	out := make([]string, 0, len(env)+2)
	for _, kv := range env {
		name, _, _ := strings.Cut(kv, "=")
		switch strings.ToUpper(name) {
		case "HOME", "APPDATA", "XDG_DATA_HOME", HomeEnv:
			continue
		}
		out = append(out, kv)
	}
	return append(out, "HOME="+home, "APPDATA="+filepath.Join(home, "AppData", "Roaming"), HomeEnv+"="+home)
}
