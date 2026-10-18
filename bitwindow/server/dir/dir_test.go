package dir

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
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
				require.NoError(t, os.MkdirAll(filepath.Join(base, linuxAppName), 0o755))
			},
			wantNewIsDir: true,
		},
		{
			name: "only legacy dir exists migrates with symlink",
			setup: func(t *testing.T, base string) {
				legacy := filepath.Join(base, linuxAppNameLegacy)
				require.NoError(t, os.MkdirAll(legacy, 0o755))
				require.NoError(t, os.WriteFile(filepath.Join(legacy, "wallet.json"), []byte("legacy"), 0o644))
			},
			wantSymlink:      true,
			wantLegacyExists: true,
			wantNewIsDir:     true,
			wantPreserveFile: "wallet.json",
		},
		{
			name: "both dirs exist leaves legacy untouched",
			setup: func(t *testing.T, base string) {
				require.NoError(t, os.MkdirAll(filepath.Join(base, linuxAppName), 0o755))
				legacy := filepath.Join(base, linuxAppNameLegacy)
				require.NoError(t, os.MkdirAll(legacy, 0o755))
				require.NoError(t, os.WriteFile(filepath.Join(legacy, "marker"), []byte("legacy"), 0o644))
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
			require.NoError(t, err)

			want := filepath.Join(base, linuxAppName)
			require.Equal(t, want, got)

			legacy := filepath.Join(base, linuxAppNameLegacy)
			info, lerr := os.Lstat(legacy)
			switch {
			case tc.wantSymlink:
				require.NoError(t, lerr)
				require.NotZero(t, info.Mode()&os.ModeSymlink)
				target, err := os.Readlink(legacy)
				require.NoError(t, err)
				assert.Equal(t, want, target)
			case tc.wantLegacyExists:
				require.NoError(t, lerr)
				assert.Zero(t, info.Mode()&os.ModeSymlink)
			default:
				assert.ErrorIs(t, lerr, os.ErrNotExist)
			}

			newInfo, nerr := os.Stat(want)
			if tc.wantNewIsDir {
				require.NoError(t, nerr)
				assert.True(t, newInfo.IsDir())
			} else {
				assert.ErrorIs(t, nerr, os.ErrNotExist)
			}

			if tc.wantPreserveFile != "" {
				_, err := os.Stat(filepath.Join(want, tc.wantPreserveFile))
				assert.NoError(t, err)
			}
		})
	}
}

func TestLinuxDataDirMigration_RenameFails(t *testing.T) {
	base := t.TempDir()
	t.Setenv("XDG_DATA_HOME", base)

	legacy := filepath.Join(base, linuxAppNameLegacy)
	require.NoError(t, os.MkdirAll(legacy, 0o755))
	require.NoError(t, os.Symlink(filepath.Join(base, "missing"), filepath.Join(base, linuxAppName)))

	_, err := linuxDataDir()
	require.ErrorContains(t, err, "move legacy data dir")

	info, err := os.Stat(legacy)
	require.NoError(t, err)
	assert.True(t, info.IsDir())
}
