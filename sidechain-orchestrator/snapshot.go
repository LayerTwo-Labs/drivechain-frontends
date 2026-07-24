package orchestrator

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
)

// SnapshotSource describes where a UTXO snapshot comes from. Exactly one of
// URL or Path is set: URL is downloaded, Path is an existing file on disk.
type SnapshotSource struct {
	URL  string
	Path string
	// SHA256 is the expected digest. Empty skips verification, which is the
	// normal case for a file the user supplied themselves.
	SHA256 string
	// Height is the block the snapshot commits to. Zero when unknown, which
	// disables the already-synced check.
	Height int64
	// Label names the source in logs and progress messages.
	Label string
	// Requested marks a snapshot the user explicitly asked for. Those failures
	// are reported as errors; the automatic drynet one stays non-fatal and
	// falls back to a normal sync.
	Requested bool
}

// SetPendingSnapshot records a snapshot to apply the next time bitcoind comes
// up. Applying is deferred rather than done inline because loadtxoutset needs a
// chainstate that has not passed the snapshot height: the caller wipes the
// existing chain and restarts bitcoind, and the snapshot is applied against the
// fresh node on the way back up.
func (o *Orchestrator) SetPendingSnapshot(src *SnapshotSource) {
	o.mu.Lock()
	defer o.mu.Unlock()
	o.pendingSnapshot = src
}

// takePendingSnapshot removes and returns the pending snapshot, if any.
func (o *Orchestrator) takePendingSnapshot() *SnapshotSource {
	o.mu.Lock()
	defer o.mu.Unlock()
	src := o.pendingSnapshot
	o.pendingSnapshot = nil
	return src
}

// ApplyUserSnapshot loads a snapshot the user supplied and streams progress.
// loadtxoutset is an online RPC, so this applies against the running node and
// does not stop, restart or wipe anything.
//
// Core refuses a snapshot whose base block the active chain has already passed,
// and refuses a second snapshot in the same datadir. Both come back as errors
// from loadtxoutset and are relayed verbatim rather than pre-empted here.
func (o *Orchestrator) ApplyUserSnapshot(ctx context.Context, src SnapshotSource) (<-chan StartupProgress, error) {
	if src.URL == "" && src.Path == "" {
		return nil, fmt.Errorf("snapshot source needs a URL or a file path")
	}
	if src.Path != "" {
		if _, err := os.Stat(src.Path); err != nil {
			return nil, fmt.Errorf("snapshot file: %w", err)
		}
	}
	if src.Label == "" {
		src.Label = "UTXO snapshot"
	}
	if src.URL != "" && o.bitcoindDatadir() == "" {
		return nil, fmt.Errorf("no datadir resolved for %s to download the snapshot into", o.Network)
	}
	// A Core the user launched themselves is not in the process manager, but
	// loadtxoutset only needs it to be answering RPC. Same reachability check
	// the generation rollover uses.
	if !o.process.IsRunning("bitcoind") && !o.coreRPCReachable() {
		return nil, fmt.Errorf("bitcoin core is not running")
	}

	ch := make(chan StartupProgress, 64)
	go func() {
		defer close(ch)
		o.applySnapshot(ctx, src, ch)
	}()
	return ch, nil
}

// bitcoindDatadir returns the datadir bitcoind writes to on the active network.
func (o *Orchestrator) bitcoindDatadir() string {
	if o.BitcoinConf != nil && o.BitcoinConf.DetectedDataDir != "" {
		return o.BitcoinConf.DetectedDataDir
	}
	// DetectedDataDir is empty whenever the user has set no explicit datadir=,
	// which is the normal case on signet, testnet and regtest — Core is simply
	// running in its platform default. Resolve that rather than refusing.
	return config.BitcoinCoreDirs.DatadirNetwork(config.NetworkFromString(o.Network), "")
}

// maybeApplySnapshot runs once bitcoind is up and reachable. It applies an
// explicitly requested snapshot when one is pending, otherwise falls back to
// the published snapshot for the active network. Every failure is non-fatal —
// the node just falls back to a normal sync.
func (o *Orchestrator) maybeApplySnapshot(ctx context.Context, ch chan<- StartupProgress) {
	src := o.takePendingSnapshot()
	if src == nil {
		auto, err := o.autoSnapshotSource(ctx)
		if err != nil || auto == nil {
			if err != nil {
				o.log.Warn().Err(err).Msg("snapshot: no published snapshot for this network")
			}
			return
		}
		src = auto
	}
	o.applySnapshot(ctx, *src, ch)
}

// autoSnapshotSource returns the UTXO snapshot the network catalog publishes
// for the active network, or nil when it publishes none.
func (o *Orchestrator) autoSnapshotSource(_ context.Context) (*SnapshotSource, error) {
	a := o.publishedSnapshot()
	if a == nil {
		return nil, nil
	}
	return &SnapshotSource{
		URL:    a.URL,
		SHA256: a.SHA256,
		Height: a.Height,
		Label:  "UTXO snapshot",
	}, nil
}

// publishedSnapshot returns the active network's catalog assumeutxo entry, or
// nil when none is published. o.Catalog is read under the lock.
func (o *Orchestrator) publishedSnapshot() *netcatalog.AssumeUTXO {
	o.mu.RLock()
	cat := o.Catalog
	o.mu.RUnlock()
	entry, ok := catalogEntryForNetwork(cat, config.NetworkFromString(o.Network))
	if !ok {
		return nil
	}
	return entry.AssumeUTXO
}

// SnapshotStatus reports the snapshot published for the active network and the
// one currently loaded in Bitcoin Core. Zero-valued fields mean none.
type SnapshotStatus struct {
	Available netcatalog.AssumeUTXO
	Active    ActiveSnapshot
}

// ActiveSnapshot is the assumeutxo chainstate Bitcoin Core has loaded. Present
// is false when Core is unreachable, too old, or has no snapshot loaded.
type ActiveSnapshot struct {
	Present              bool
	Blockhash            string
	Height               int64
	Validated            bool
	VerificationProgress float64
}

// SnapshotStatus returns the published and currently-loaded snapshots.
func (o *Orchestrator) SnapshotStatus(ctx context.Context) SnapshotStatus {
	s := SnapshotStatus{Active: o.activeSnapshot(ctx)}
	if a := o.publishedSnapshot(); a != nil {
		s.Available = *a
	}
	return s
}

// activeSnapshot returns the assumeutxo chainstate loaded in Core.
func (o *Orchestrator) activeSnapshot(ctx context.Context) ActiveSnapshot {
	client, err := o.CoreStatusClient()
	if err != nil {
		return ActiveSnapshot{}
	}
	raw, err := client.call(ctx, "getchainstates")
	if err != nil {
		return ActiveSnapshot{}
	}
	var states struct {
		ChainStates []struct {
			Blocks               int64   `json:"blocks"`
			SnapshotBlockhash    string  `json:"snapshot_blockhash"`
			Validated            bool    `json:"validated"`
			VerificationProgress float64 `json:"verificationprogress"`
		} `json:"chainstates"`
	}
	if err := json.Unmarshal(raw, &states); err != nil {
		return ActiveSnapshot{}
	}
	for _, s := range states.ChainStates {
		if s.SnapshotBlockhash != "" {
			return ActiveSnapshot{
				Present:              true,
				Blockhash:            s.SnapshotBlockhash,
				Height:               s.Blocks,
				Validated:            s.Validated,
				VerificationProgress: s.VerificationProgress,
			}
		}
	}
	return ActiveSnapshot{}
}

// catalogEntryForNetwork maps an active network to its catalog entry. Drynet is
// keyed by family since its id carries the generation; the rest by id.
func catalogEntryForNetwork(cat netcatalog.Catalog, n config.Network) (netcatalog.Network, bool) {
	switch n {
	case config.NetworkDrynet:
		return cat.CurrentECash()
	case config.NetworkMainnet:
		return cat.ByID("bitcoin")
	case config.NetworkSignet:
		return cat.ByID("signet")
	case config.NetworkForknet:
		return cat.ByID("forknet")
	default:
		return netcatalog.Network{}, false
	}
}

// applySnapshot downloads (when needed), verifies and loads a snapshot against
// the running bitcoind.
func (o *Orchestrator) applySnapshot(ctx context.Context, src SnapshotSource, ch chan<- StartupProgress) {
	client, err := o.CoreStatusClient()
	if err != nil {
		o.log.Warn().Err(err).Msg("snapshot: no core client, skipping")
		return
	}

	// Skip once the node already reaches the snapshot height: the snapshot is
	// loaded (or the chain is fully synced) and loadtxoutset would only error.
	if src.Height > 0 {
		if count, err := client.GetBlockCount(ctx); err == nil && count >= src.Height {
			return
		}
	}

	path := src.Path
	if path == "" {
		// Only a download needs somewhere to land; a file the user pointed us
		// at is loaded from wherever it already is.
		datadir := o.bitcoindDatadir()
		if datadir == "" {
			o.log.Warn().Msg("snapshot: no datadir resolved, skipping")
			return
		}
		path = filepath.Join(datadir, snapshotFileName(src.URL))
		ch <- StartupProgress{Stage: snapshotStage, Message: "preparing " + src.Label + "..."}
		if err := ensureSnapshotFile(ctx, src, path, ch, o); err != nil {
			o.log.Error().Err(err).Msg("snapshot download/verify failed, falling back to a full sync")
			ch <- o.snapshotFailure(src, "snapshot unavailable, doing a full sync instead", err)
			return
		}
	} else if src.SHA256 != "" {
		// A digest supplied alongside a local file still has to hold: handing
		// Core a corrupt snapshot is worse than refusing it.
		ch <- StartupProgress{Stage: snapshotStage, Message: "verifying " + src.Label + "..."}
		sum, err := sha256File(path)
		if err != nil {
			o.log.Error().Err(err).Str("path", path).Msg("snapshot: could not read file to verify")
			ch <- StartupProgress{Stage: snapshotStage, Message: "could not read the snapshot file", Error: err}
			return
		}
		if !strings.EqualFold(sum, src.SHA256) {
			err := fmt.Errorf("snapshot hash mismatch: got %s, want %s", sum, src.SHA256)
			o.log.Error().Err(err).Msg("snapshot verification failed")
			ch <- StartupProgress{Stage: snapshotStage, Message: err.Error(), Error: err}
			return
		}
	}

	// Core validates the snapshot here and blocks until the whole thing is
	// loaded, so this is both the acceptance check and the load. Its rejection
	// message is the useful one — relay it rather than paraphrasing.
	ch <- StartupProgress{Stage: snapshotStage, Message: "loading " + src.Label + ", bitcoin core is reading the snapshot..."}

	loadErr := make(chan error, 1)
	go func() {
		_, err := client.call(ctx, "loadtxoutset", path)
		loadErr <- err
	}()

	// loadtxoutset exposes no completion fraction, so the only progress to be
	// had is what Core writes to its log while the call blocks.
	stopTailing := make(chan struct{})
	tailerDone := make(chan struct{})
	go func() {
		defer close(tailerDone)
		o.tailCoreLogs(ch, stopTailing)
	}()
	err = <-loadErr
	// Wait for the tailer to actually exit, not just signal it: the caller
	// closes ch as soon as this returns, and a tailer mid-tick would then send
	// on a closed channel and take the orchestrator down.
	close(stopTailing)
	<-tailerDone

	if err != nil {
		o.log.Error().Err(err).Msg("snapshot loadtxoutset failed, falling back to a full sync")
		ch <- StartupProgress{Stage: snapshotStage, Message: "bitcoin core rejected the snapshot: " + err.Error(), Error: err}
		return
	}

	// The snapshot file is left on disk. It is expensive to fetch and stays
	// reusable, so deleting it is the caller's call, not ours.
	ch <- StartupProgress{Stage: snapshotStage, Message: "UTXO snapshot loaded, validating at the tip", Done: true}
	o.log.Info().Str("source", src.Label).Msg("UTXO snapshot loaded via loadtxoutset")
}

// tailCoreLogs forwards new bitcoind startup log lines onto ch until stop is
// closed. The process manager already captures these from Core's stdout; this
// just republishes them so a caller streaming the snapshot apply sees Core's
// own account of a load that reports no percentage.
func (o *Orchestrator) tailCoreLogs(ch chan<- StartupProgress, stop <-chan struct{}) {
	o.monitorsMu.Lock()
	mon := o.monitors["bitcoind"]
	o.monitorsMu.Unlock()
	if mon == nil {
		return
	}
	seen := len(mon.StartupLogs())
	ticker := time.NewTicker(time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-stop:
			return
		case <-ticker.C:
			lines := mon.StartupLogs()
			// The buffer keeps only the last 20 lines, so a burst can drop the
			// index below what we've seen; restart from the front when it does.
			if len(lines) < seen {
				seen = 0
			}
			for _, l := range lines[seen:] {
				select {
				case ch <- StartupProgress{Stage: snapshotStage, Message: l.Message}:
				default:
				}
			}
			seen = len(lines)
		}
	}
}

// snapshotFailure reports a failed step. A snapshot the user asked for carries
// the error so the RPC fails and the UI says so; the automatic one reports the
// same message without an error, because falling back to a normal sync is a
// perfectly good outcome nobody needs to be told about as a failure.
func (o *Orchestrator) snapshotFailure(src SnapshotSource, msg string, err error) StartupProgress {
	p := StartupProgress{Stage: snapshotStage, Message: msg}
	if src.Requested {
		p.Error = err
	}
	return p
}

// snapshotFileName picks the on-disk name for a downloaded snapshot, falling
// back to a fixed name when the URL has no usable last segment. It takes the
// base of the path only, so a query string on a presigned or cache-busted URL
// never leaks into the filename (which would be invalid on Windows).
func snapshotFileName(rawURL string) string {
	name := ""
	if u, err := url.Parse(rawURL); err == nil {
		name = filepath.Base(u.Path)
	} else {
		name = filepath.Base(rawURL)
	}
	if name == "" || name == "." || name == "/" {
		return "utxo-snapshot.dat"
	}
	return name
}

const snapshotStage = "utxo-snapshot"

// ensureSnapshotFile makes sure a verified snapshot exists at path, reusing an
// already-downloaded copy when its digest still matches.
func ensureSnapshotFile(ctx context.Context, src SnapshotSource, path string, ch chan<- StartupProgress, o *Orchestrator) error {
	if src.SHA256 != "" {
		if sum, err := sha256File(path); err == nil && strings.EqualFold(sum, src.SHA256) {
			o.log.Info().Msg("snapshot already present and verified")
			return nil
		}
	}

	ch <- StartupProgress{Stage: snapshotStage, Message: "downloading " + src.Label + "..."}
	sum, err := downloadAndHash(ctx, src.URL, path, ch)
	if err != nil {
		return fmt.Errorf("download snapshot: %w", err)
	}
	if src.SHA256 == "" {
		o.log.Warn().Str("url", src.URL).Msg("snapshot has no published digest, loading unverified")
		return nil
	}
	if !strings.EqualFold(sum, src.SHA256) {
		_ = os.Remove(path)
		return fmt.Errorf("snapshot hash mismatch: got %s, want %s", sum, src.SHA256)
	}
	return nil
}

// downloadAndHash streams url to dest (via a .part file) while computing its
// sha256, so the ~9 GB file is read from the network exactly once. It emits
// coarse progress on ch and returns the lowercase hex digest.
func downloadAndHash(ctx context.Context, url, dest string, ch chan<- StartupProgress) (string, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return "", err
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close() //nolint:errcheck // cleanup
	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("HTTP %d", resp.StatusCode)
	}

	tmp := dest + ".part"
	f, err := os.Create(tmp)
	if err != nil {
		return "", err
	}

	hasher := sha256.New()
	pw := &snapshotProgressWriter{total: resp.ContentLength, ch: ch}
	if _, err := io.Copy(io.MultiWriter(f, hasher, pw), resp.Body); err != nil {
		_ = f.Close()
		_ = os.Remove(tmp)
		return "", err
	}
	if err := f.Close(); err != nil {
		_ = os.Remove(tmp)
		return "", err
	}
	// Windows refuses to rename onto an existing file, so a stale or corrupt
	// cached snapshot would otherwise be undeletable: the retry downloads the
	// whole thing again and only then fails at the rename.
	if err := os.Remove(dest); err != nil && !os.IsNotExist(err) {
		_ = os.Remove(tmp)
		return "", fmt.Errorf("replace existing snapshot: %w", err)
	}
	if err := os.Rename(tmp, dest); err != nil {
		return "", err
	}
	return hex.EncodeToString(hasher.Sum(nil)), nil
}

// sha256File returns the lowercase hex sha256 of a file, or an error if it
// can't be read.
func sha256File(path string) (string, error) {
	f, err := os.Open(path)
	if err != nil {
		return "", err
	}
	defer f.Close() //nolint:errcheck // cleanup
	hasher := sha256.New()
	if _, err := io.Copy(hasher, f); err != nil {
		return "", err
	}
	return hex.EncodeToString(hasher.Sum(nil)), nil
}

// snapshotProgressWriter emits a StartupProgress update each time another whole
// percent of the download lands, so the boot UI shows movement without flooding
// the channel.
type snapshotProgressWriter struct {
	total   int64
	written int64
	lastPct int
	ch      chan<- StartupProgress
}

func (w *snapshotProgressWriter) Write(p []byte) (int, error) {
	n := len(p)
	w.written += int64(n)
	if w.total <= 0 {
		return n, nil
	}
	pct := int(w.written * 100 / w.total)
	if pct > w.lastPct {
		w.lastPct = pct
		select {
		case w.ch <- StartupProgress{
			Stage:        snapshotStage,
			Message:      fmt.Sprintf("downloading UTXO snapshot... %d%%", pct),
			MBDownloaded: toMB(w.written),
			MBTotal:      toMB(w.total),
		}:
		default:
		}
	}
	return n, nil
}
