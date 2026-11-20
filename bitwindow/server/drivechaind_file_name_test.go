package main

import "testing"

func TestDrivechaindFileName(t *testing.T) {
	for goos, want := range map[string]string{
		"darwin":  "drivechaind",
		"linux":   "drivechaind",
		"windows": "drivechaind.exe",
		"android": "libdrivechaind.so",
	} {
		if got := drivechaindFileName(goos); got != want {
			t.Errorf("drivechaindFileName(%q) = %q, want %q", goos, got, want)
		}
	}
}
