package orchestrator

import (
	"regexp"
	"strings"
)

// Platform/architecture suffixes to strip from extracted filenames.
var platformSuffixes = []string{
	"-x86_64-apple-darwin",
	"-x86_64-unknown-linux-gnu",
	"-x86_64-pc-windows-gnu",
	"-x86_64-w64-msvc",
	"_linux_x86_64",
	"_osx_x86_64",
	"_windows_x86_64",
}

// versionPattern matches version strings like -1.2.3- or -v1.2.3- or _1.9.1
var versionPattern = regexp.MustCompile(`[-_]v?\d+\.\d+\.\d+[-_]?`)

// StripPlatformSuffix removes platform/architecture and version suffixes
// from extracted filenames to produce a clean binary name.
//
// Examples:
//
//	"thunder-orchard-0.1.0-x86_64-apple-darwin" -> "thunder-orchard"
//	"grpcurl_1.9.1_linux_x86_64" -> "grpcurl"
//	"bip300301-enforcer-latest-x86_64-unknown-linux-gnu" -> "bip300301-enforcer-latest"
func StripPlatformSuffix(name string) string {
	result := name

	// Strip file extension first
	for _, ext := range []string{".exe", ".tar.gz", ".zip", ".gz"} {
		result = strings.TrimSuffix(result, ext)
	}

	// Strip platform suffixes
	for _, suffix := range platformSuffixes {
		result = strings.TrimSuffix(result, suffix)
	}

	// Strip version numbers (e.g. -0.1.0- or -v1.2.3)
	result = versionPattern.ReplaceAllString(result, "-")

	// Clean up trailing/leading/double dashes
	result = strings.TrimRight(result, "-_")
	result = strings.TrimLeft(result, "-_")

	return result
}
