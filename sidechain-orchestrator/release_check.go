package orchestrator

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"sync"
	"time"

	"github.com/rs/zerolog"
	"github.com/samber/lo"
)

// ReleaseCheckInterval is how often the checker re-reads Last-Modified.
const ReleaseCheckInterval = 10 * time.Minute

const releaseCheckTimeout = 5 * time.Second

// ReleaseCheck is what the checker knows about one binary.
type ReleaseCheck struct {
	// Remote is the Last-Modified time of the download, zero when unknown.
	Remote time.Time
	// Local is the mtime of the binary on disk, zero when not downloaded.
	Local time.Time
	// Source names the download the probe read. Every Core variant writes to
	// the same binary path, so the download key is what separates them.
	Source string
}

// UpdateAvailable reports whether the published download is newer than the
// binary on disk. It is false whenever either side is unknown, so a failed
// probe never shows a false update.
func (c ReleaseCheck) UpdateAvailable() bool {
	return !c.Remote.IsZero() && !c.Local.IsZero() && c.Remote.After(c.Local)
}

// ReleaseChecker tracks whether a newer build of each binary is published.
//
// The published archives keep a fixed "latest" name, so only the server's
// Last-Modified separates one release from the next. Probes run on a timer and
// land in a cache, because status is read far more often than releases ship.
type ReleaseChecker struct {
	client    *http.Client
	log       zerolog.Logger
	downloads *DownloadManager

	mu     sync.RWMutex
	checks map[string]ReleaseCheck
}

// NewReleaseChecker reads every download through the manager, so a Core
// variant, a test sidechain build and a GitHub asset all resolve the same way
// they do for a real download.
func NewReleaseChecker(downloads *DownloadManager, log zerolog.Logger) *ReleaseChecker {
	return &ReleaseChecker{
		client:    &http.Client{Timeout: releaseCheckTimeout},
		log:       log,
		downloads: downloads,
		checks:    make(map[string]ReleaseCheck),
	}
}

// StartReleaseChecks polls every configured binary for a newer published build
// until ctx ends. BinaryStatus reads the cached result, so status never blocks
// on the network.
func (o *Orchestrator) StartReleaseChecks(ctx context.Context) {
	// Every config, not only the Downloadable() ones: Bitcoin Core defines its
	// downloads through variants, so its own Files are empty and that filter
	// would drop it. ResolveTarget decides what a probe can reach.
	//
	// Accessors, not values: a network swap or a config reload has to reach the
	// next tick, and a snapshot taken at startup never would.
	go o.releases.Run(ctx, func() []BinaryConfig { return lo.Values(o.Configs()) }, o.CurrentNetwork)
}

// Check returns the cached result for a binary. ok is false until a probe runs,
// and false when the cached probe describes a different file: a Core variant or
// test sidechain change resolves another path, and the previous target's
// timestamps say nothing about the new one.
func (r *ReleaseChecker) Check(config BinaryConfig, network string) (ReleaseCheck, bool) {
	target := r.downloads.ResolveTarget(config, network, DownloadOptions{})

	r.mu.RLock()
	defer r.mu.RUnlock()
	check, ok := r.checks[config.Name]
	if !ok || check.Source != target.InFlightKey {
		return ReleaseCheck{}, false
	}
	return check, true
}

// Run probes every binary at once, then again on each tick, until ctx ends.
// It reads configs and network on every tick, so a swap takes effect at once.
func (r *ReleaseChecker) Run(ctx context.Context, configs func() []BinaryConfig, network func() string) {
	ticker := time.NewTicker(ReleaseCheckInterval)
	defer ticker.Stop()

	// One slow host must not hold up the rest, so the probes run together.
	refreshAll := func() {
		var wg sync.WaitGroup
		current := network()
		for _, config := range configs() {
			wg.Add(1)
			go func(config BinaryConfig) {
				defer wg.Done()
				r.Refresh(ctx, config, current)
			}(config)
		}
		wg.Wait()
	}

	refreshAll()
	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
			refreshAll()
		}
	}
}

// Refresh probes one binary and stores the result. Call it after a download so
// the update button clears at once instead of at the next tick.
func (r *ReleaseChecker) Refresh(ctx context.Context, config BinaryConfig, network string) {
	target := r.downloads.ResolveTarget(config, network, DownloadOptions{})

	var check ReleaseCheck
	remote, err := r.remoteTime(ctx, target)
	if err != nil {
		// A probe that fails leaves the binary with no remote time, which reads
		// as "no update". Keep the local time so the reason stays visible.
		r.log.Debug().Err(err).Str("binary", config.Name).Msg("release check failed")
	} else {
		check.Remote = remote
	}

	// Read the mtime after the probe. A download that lands during the probe
	// would otherwise let this write restore the pre-download time, and the
	// update button would come back until the next tick.
	check.Local = localModTime(target.BinPath)
	check.Source = target.InFlightKey

	r.mu.Lock()
	r.checks[config.Name] = check
	r.mu.Unlock()
}

// localModTime is the mtime of the binary on disk, zero when it is not there.
func localModTime(path string) time.Time {
	info, err := os.Stat(path)
	if err != nil {
		return time.Time{}
	}
	return info.ModTime()
}

// remoteTime reads Last-Modified from the published archive with a HEAD request.
func (r *ReleaseChecker) remoteTime(ctx context.Context, target DownloadTarget) (time.Time, error) {
	url, err := r.downloads.ResolveArchiveURL(ctx, target)
	if err != nil {
		return time.Time{}, err
	}

	req, err := http.NewRequestWithContext(ctx, http.MethodHead, url, nil)
	if err != nil {
		return time.Time{}, err
	}

	resp, err := r.client.Do(req)
	if err != nil {
		return time.Time{}, err
	}
	defer resp.Body.Close() //nolint:errcheck // a HEAD response carries no body

	if resp.StatusCode != http.StatusOK {
		return time.Time{}, fmt.Errorf("release check: HTTP %d for %s", resp.StatusCode, url)
	}

	lastModified := resp.Header.Get("Last-Modified")
	if lastModified == "" {
		return time.Time{}, fmt.Errorf("release check: no Last-Modified header for %s", url)
	}
	return http.ParseTime(lastModified)
}
