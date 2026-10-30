package orchestrator

import (
	"regexp"
	"strings"
	"testing"

	"github.com/stretchr/testify/require"
)

var githubReleasesAPI = regexp.MustCompile(`^https://api\.github\.com/repos/([^/]+/[^/]+)/releases`)

func TestEachRepoURLNamesTheReleaseRepo(t *testing.T) {
	o := newTestOrchestrator(t)

	for name, c := range o.configs {
		for _, urls := range []map[string]string{c.DownloadURLs, c.AltDownloadURLs} {
			for _, base := range urls {
				m := githubReleasesAPI.FindStringSubmatch(base)
				if m == nil {
					continue
				}
				require.Equal(t, strings.ToLower("https://github.com/"+m[1]), strings.ToLower(c.RepoURL), name)
			}
		}
	}
}

func TestTheEnforcerRepoURLUsesAnUnderscore(t *testing.T) {
	o := newTestOrchestrator(t)

	require.Equal(t, "https://github.com/LayerTwo-Labs/bip300301_enforcer", o.configs["enforcer"].RepoURL)
}
