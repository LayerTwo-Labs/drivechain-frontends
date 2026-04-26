package dir

import (
	"os"
	"path/filepath"
	"testing"
)

func TestLinuxDataDirMigration(t *testing.T) {
	cases := []struct {
		name             string
		setup            func(t *testing.T, base string)
		wantSymlink      bool
		wantLegacyExists bool
		wantNewIsDir     bool
		wantPreserveFile string
	}{
		{
			name:             "neither dir exists",
			setup:            func(t *testing.T, base string) {},
			wantSymlink:      false,
			wantLegacyExists: false,
			wantNewIsDir:     false,
		},
		{
			name: "only new dir exists",
			setup: func(t *testing.T, base string) {
				if err := os.MkdirAll(filepath.Join(base, linuxAppName), 0o755); err != nil {
					t.Fatal(err)
				}
			},
			wantNewIsDir: true,
		},
		{
			name: "only legacy dir exists migrates with symlink",
			setup: func(t *testing.T, base string) {
				legacy := filepath.Join(base, linuxAppNameLegacy)
				if err := os.MkdirAll(legacy, 0o755); err != nil {
					t.Fatal(err)
				}
				if err := os.WriteFile(filepath.Join(legacy, "wallet.json"), []byte("legacy"), 0o644); err != nil {
					t.Fatal(err)
				}
			},
			wantSymlink:      true,
			wantLegacyExists: true,
			wantNewIsDir:     true,
			wantPreserveFile: "wallet.json",
		},
		{
			name: "both dirs exist leaves legacy untouched",
			setup: func(t *testing.T, base string) {
				if err := os.MkdirAll(filepath.Join(base, linuxAppName), 0o755); err != nil {
					t.Fatal(err)
				}
				legacy := filepath.Join(base, linuxAppNameLegacy)
				if err := os.MkdirAll(legacy, 0o755); err != nil {
					t.Fatal(err)
				}
				if err := os.WriteFile(filepath.Join(legacy, "marker"), []byte("legacy"), 0o644); err != nil {
					t.Fatal(err)
				}
			},
			wantLegacyExists: true,
			wantNewIsDir:     true,
		},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			base := t.TempDir()
			t.Setenv("XDG_DATA_HOME", base)

			tc.setup(t, base)

			got, err := linuxDataDir()
			if err != nil {
				t.Fatalf("linuxDataDir: %v", err)
			}

			want := filepath.Join(base, linuxAppName)
			if got != want {
				t.Fatalf("dir = %q, want %q", got, want)
			}

			legacy := filepath.Join(base, linuxAppNameLegacy)
			info, lerr := os.Lstat(legacy)
			switch {
			case tc.wantSymlink:
				if lerr != nil {
					t.Fatalf("legacy symlink missing: %v", lerr)
				}
				if info.Mode()&os.ModeSymlink == 0 {
					t.Fatalf("legacy path is not a symlink: mode=%v", info.Mode())
				}
				target, err := os.Readlink(legacy)
				if err != nil {
					t.Fatalf("readlink: %v", err)
				}
				if target != want {
					t.Errorf("symlink target = %q, want %q", target, want)
				}
			case tc.wantLegacyExists:
				if lerr != nil {
					t.Fatalf("expected legacy to remain, got %v", lerr)
				}
				if info.Mode()&os.ModeSymlink != 0 {
					t.Errorf("legacy unexpectedly became a symlink: mode=%v", info.Mode())
				}
			default:
				if lerr == nil {
					t.Errorf("legacy should not exist, but does (mode=%v)", info.Mode())
				} else if !os.IsNotExist(lerr) {
					t.Errorf("unexpected legacy stat error: %v", lerr)
				}
			}

			newInfo, nerr := os.Stat(want)
			if tc.wantNewIsDir {
				if nerr != nil {
					t.Fatalf("new dir stat: %v", nerr)
				}
				if !newInfo.IsDir() {
					t.Errorf("new path is not a dir: mode=%v", newInfo.Mode())
				}
			} else if nerr == nil {
				t.Errorf("new dir should not exist yet, but does")
			}

			if tc.wantPreserveFile != "" {
				if _, err := os.Stat(filepath.Join(want, tc.wantPreserveFile)); err != nil {
					t.Errorf("preserved file missing after migration: %v", err)
				}
			}
		})
	}
}
