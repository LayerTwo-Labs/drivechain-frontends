package daemon

import "testing"

func TestDrivechaindFileName(t *testing.T) {
	for goos, want := range map[string]string{
		"darwin":  "drivechaind",
		"linux":   "drivechaind",
		"windows": "drivechaind.exe",
	} {
		if got := drivechaindFileName(goos); got != want {
			t.Errorf("drivechaindFileName(%q) = %q, want %q", goos, got, want)
		}
	}
}
