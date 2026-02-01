package dir

import (
	"fmt"
	"os"
	"path/filepath"
	"runtime"
)

func DefaultDataDir() (string, error) {

	var dir string

	switch runtime.GOOS {
	case "linux":
		const linuxAppName = "bitwindow"

		if xdgDataHome := os.Getenv("XDG_DATA_HOME"); xdgDataHome != "" {
			dir = filepath.Join(xdgDataHome, linuxAppName)
		} else {
			home, err := os.UserHomeDir()
			if err != nil {
				return "", err
			}
			dir = filepath.Join(home, ".local", "share", linuxAppName)
		}
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
