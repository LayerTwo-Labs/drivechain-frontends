package version

import "fmt"

// These variables are set at build time via ldflags
var (
	// Version is the semantic version
	Version = "dev"
	// Commit is the git commit hash
	Commit = "unknown"
	// BuildDate is when the binary was built
	BuildDate = "unknown"
)

// String returns a formatted version string
func String() string {
	return fmt.Sprintf("bitwindowd %s\n commit: %s\n built: %s", Version, Commit, BuildDate)
}
