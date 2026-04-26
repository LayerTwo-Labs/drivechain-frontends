package dir

import (
	"fmt"
	"os"
	"path/filepath"
	"runtime"
)

// Flutter's path_provider on Linux uses the GApplication id when libgio is
// loadable and falls back to the executable name otherwise. libgio is
// unreliable across distros, so the canonical subdir is "bitwindow" (matching
// the executable name in CMakeLists.txt). Older installs landed under
// "com.layertwolabs.bitwindow"; on first boot we rename the legacy dir into
// place and leave a symlink so libgio-good Flutter still resolves to the
// same data.
const (
	linuxAppName       = "bitwindow"
	linuxAppNameLegacy = "com.layertwolabs.bitwindow"
)

func linuxDataDir() (string, error) {
	var base string
	if xdgDataHome := os.Getenv("XDG_DATA_HOME"); xdgDataHome != "" {
		base = xdgDataHome
	} else {
		home, err := os.UserHomeDir()
		if err != nil {
			return "", err
		}
		base = filepath.Join(home, ".local", "share")
	}

	newPath := filepath.Join(base, linuxAppName)
	legacy := filepath.Join(base, linuxAppNameLegacy)

	_, newErr := os.Stat(newPath)
	_, legacyErr := os.Stat(legacy)
	if os.IsNotExist(newErr) && legacyErr == nil {
		if err := os.Rename(legacy, newPath); err == nil {
			_ = os.Symlink(newPath, legacy)
		}
	}
	return newPath, nil
}

func DefaultDataDir() (string, error) {

	var dir string

	switch runtime.GOOS {
	case "linux":
		linuxDir, err := linuxDataDir()
		if err != nil {
			return "", err
		}
		dir = linuxDir
	case "darwin":
		const macosAppName = "bitwindow"

		home, err := os.UserHomeDir()
		if err != nil {
			return "", err
		}
		dir = filepath.Join(home, "Library", "Application Support", macosAppName)
	case "windows":
		const windowsAppName = "BitWindow"

		appData, ok := os.LookupEnv("APPDATA")
		if !ok {
			return "", fmt.Errorf("APPDATA environment variable not set")
		}
		// Match Flutter's path_provider which uses CompanyName\ProductName from Runner.rc
		dir = filepath.Join(appData, "10520LayertwoLabs", windowsAppName)
	default:
		return "", fmt.Errorf("unsupported OS: %s", runtime.GOOS)
	}

	return dir, nil
}
