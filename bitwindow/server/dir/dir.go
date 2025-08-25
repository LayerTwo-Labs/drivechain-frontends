package dir

import (
	"fmt"
	"os"
	"path/filepath"
	"runtime"
)

func DefaultDataDir() (string, error) {

	var dir string
	const appName = "bitwindow"

	switch runtime.GOOS {
	case "linux":
		if xdgDataHome := os.Getenv("XDG_DATA_HOME"); xdgDataHome != "" {
			dir = filepath.Join(xdgDataHome, appName)
		} else {
			home, err := os.UserHomeDir()
			if err != nil {
				return "", err
			}
			dir = filepath.Join(home, ".local", "share", appName)
		}
	case "darwin":
		home, err := os.UserHomeDir()
		if err != nil {
			return "", err
		}
		dir = filepath.Join(home, "Library", "Application Support", appName)
	case "windows":
		appData, ok := os.LookupEnv("APPDATA")
		if !ok {
			return "", fmt.Errorf("APPDATA environment variable not set")
		}
		dir = filepath.Join(appData, appName)
	default:
		return "", fmt.Errorf("unsupported OS: %s", runtime.GOOS)
	}

	return dir, nil
}
