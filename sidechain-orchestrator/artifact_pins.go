package orchestrator

import (
	"encoding/hex"
	"fmt"
	"os"
)

// verifyArtifactPin compares a downloaded archive, or the executable inside
// it, with the hash the config pins for this platform.
func verifyArtifactPin(cfg BinaryConfig, path string, archive bool) error {
	if len(cfg.ArtifactPins) == 0 {
		return nil
	}
	pin := cfg.ArtifactPins[currentPlatform()]
	expected := pin.ExecutableSHA256
	if archive {
		expected = pin.ArchiveSHA256
	}
	if !isSHA256(expected) {
		return fmt.Errorf("%s has no artifact pin for %s", cfg.Name, currentPlatform())
	}
	info, err := os.Lstat(path)
	if err != nil {
		return fmt.Errorf("%s artifact: %w", cfg.Name, err)
	}
	if !info.Mode().IsRegular() {
		return fmt.Errorf("%s artifact must be a regular file: %s", cfg.Name, path)
	}
	actual, _, err := hashFile(path)
	if err != nil {
		return err
	}
	if actual != expected {
		return fmt.Errorf("%s artifact checksum mismatch; refusing %s", cfg.Name, path)
	}
	return nil
}

// checkArtifactPins fails when a pinned binary has no release for platform.
func checkArtifactPins(cfg BinaryConfig, platform string) error {
	if len(cfg.ArtifactPins) == 0 {
		return nil
	}
	pin := cfg.ArtifactPins[platform]
	if cfg.Files[platform] == "" || !isSHA256(pin.ArchiveSHA256) || !isSHA256(pin.ExecutableSHA256) {
		return fmt.Errorf("%s has no pinned release for %s", cfg.Name, platform)
	}
	return nil
}

func isSHA256(value string) bool {
	decoded, err := hex.DecodeString(value)
	return err == nil && len(decoded) == 32
}
