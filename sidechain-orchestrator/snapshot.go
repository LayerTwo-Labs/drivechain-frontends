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
	// are reported as errors; the automatic eCash one stays non-fatal and
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
	if o.BitcoinConf != nil {
		return o.BitcoinConf.DataDir()
	}
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
	ecashID := o.ecashID
	o.mu.RUnlock()
	entry, ok := o.catalogEntryForRunningNetwork(cat, ecashID)
	if !ok {
		return nil
	}
	return entry.AssumeUTXO
}

// catalogEntryForRunningNetwork returns the entry this install runs. The eCash
// rows share one network, so document order names the wrong one whenever the
// user picked a row the catalog does not list first.
func (o *Orchestrator) catalogEntryForRunningNetwork(cat netcatalog.Catalog, ecashID string) (netcatalog.Network, bool) {
	network := config.NetworkFromString(o.Network)
	if network == config.NetworkECash && ecashID != "" {
		return cat.ByID(ecashID)
	}
	return catalogEntryForNetwork(cat, network)
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

// CoreChainStates is what getchainstates reports: the snapshot chainstate Core
// loaded, and the height it verified from genesis behind that snapshot.
type CoreChainStates struct {
	Snapshot ActiveSnapshot
	// VerifiedBlocks is the tip of the background chainstate, the one Core
	// validates from genesis. Zero when Core loaded no snapshot, because a
	// node without one verifies every block it counts in Blocks.
	VerifiedBlocks int64
	// VerifiedGoal is the height the background chainstate must reach: the
	// block the snapshot commits to, not the chain tip. Zero with no snapshot.
	VerifiedGoal int64
}

// SnapshotStatus returns the published and currently-loaded snapshots.
func (o *Orchestrator) SnapshotStatus(ctx context.Context) SnapshotStatus {
	s := SnapshotStatus{}
	if states, err := o.chainStatesFrom(ctx); err == nil {
		s.Active = states.Snapshot
	}
	if a := o.publishedSnapshot(); a != nil {
		s.Available = *a
	}
	return s
}

// chainStatesFrom reads getchainstates from the running Core, then resolves the
// snapshot's base height. Verification finishes at that base, not at the tip, so
// a bar measured against headers never reaches 100%.
func (o *Orchestrator) chainStatesFrom(ctx context.Context) (CoreChainStates, error) {
	client, err := o.CoreStatusClient()
	if err != nil {
		return CoreChainStates{}, err
	}
	raw, err := client.call(ctx, "getchainstates")
	if err != nil {
		return CoreChainStates{}, err
	}
	states, err := parseChainStates(raw)
	if err != nil {
		return CoreChainStates{}, err
	}
	if !states.Snapshot.Present {
		return states, nil
	}

	header, err := client.call(ctx, "getblockheader", states.Snapshot.Blockhash)
	if err != nil {
		return CoreChainStates{}, err
	}
	states.VerifiedGoal, err = parseBlockHeight(header)
	if err != nil {
		return CoreChainStates{}, err
	}
	return completeValidatedSnapshot(states), nil
}

// completeValidatedSnapshot reads a finished verification as finished. Core
// removes the background chainstate once it validates the snapshot, so the
// verified height drops to zero while the goal stays set — which reads as
// "never started" instead of "done".
func completeValidatedSnapshot(states CoreChainStates) CoreChainStates {
	if states.Snapshot.Validated && states.VerifiedBlocks == 0 {
		states.VerifiedBlocks = states.VerifiedGoal
	}
	return states
}

// parseBlockHeight reads the height out of a getblockheader reply.
func parseBlockHeight(raw []byte) (int64, error) {
	var header struct {
		Height int64 `json:"height"`
	}
	if err := json.Unmarshal(raw, &header); err != nil {
		return 0, fmt.Errorf("decode getblockheader: %w", err)
	}
	return header.Height, nil
}

// parseChainStates projects a getchainstates reply. Core reports one
// chainstate normally and two behind an assumeutxo snapshot: the snapshot one
// carries snapshot_blockhash and sits at the tip, and the other holds the
// height Core verified from genesis.
func parseChainStates(raw []byte) (CoreChainStates, error) {
	var reply struct {
		ChainStates []struct {
			Blocks               int64   `json:"blocks"`
			SnapshotBlockhash    string  `json:"snapshot_blockhash"`
			Validated            bool    `json:"validated"`
			VerificationProgress float64 `json:"verificationprogress"`
		} `json:"chainstates"`
	}
	if err := json.Unmarshal(raw, &reply); err != nil {
		return CoreChainStates{}, fmt.Errorf("decode getchainstates: %w", err)
	}

	var out CoreChainStates
	var background int64
	for _, s := range reply.ChainStates {
		if s.SnapshotBlockhash == "" {
			background = max(background, s.Blocks)
			continue
		}
		out.Snapshot = ActiveSnapshot{
			Present:              true,
			Blockhash:            s.SnapshotBlockhash,
			Height:               s.Blocks,
			Validated:            s.Validated,
			VerificationProgress: s.VerificationProgress,
		}
	}
	if out.Snapshot.Present {
		out.VerifiedBlocks = background
	}
	return out, nil
}

func catalogEntryForNetwork(cat netcatalog.Catalog, n config.Network) (netcatalog.Network, bool) {
	return cat.ForNetwork(string(n))
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

	// Progress rides the download map so the existing bars render it and take
	// precedence over block sync, which is stalled behind the snapshot anyway.
	defer o.download.ClearState("bitcoind")

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
		trySend(ch, StartupProgress{Stage: snapshotStage, Message: "preparing " + src.Label + "..."})
		o.download.PublishState("bitcoind", DownloadState{Message: snapshotDownloadMessage})
		if err := ensureSnapshotFile(ctx, src, path, ch, o); err != nil {
			o.log.Error().Err(err).Msg("snapshot download/verify failed, falling back to a full sync")
			ch <- o.snapshotFailure(src, "snapshot unavailable, doing a full sync instead", err)
			return
		}
	} else if src.SHA256 != "" {
		// A digest supplied alongside a local file still has to hold: handing
		// Core a corrupt snapshot is worse than refusing it.
		trySend(ch, StartupProgress{Stage: snapshotStage, Message: "verifying " + src.Label + "..."})
		sum, err := sha256File(path)
		if err != nil {
			o.log.Error().Err(err).Str("path", path).Msg("snapshot: could not read file to verify")
			trySend(ch, StartupProgress{Stage: snapshotStage, Message: "could not read the snapshot file", Error: err})
			return
		}
		if !strings.EqualFold(sum, src.SHA256) {
			err := fmt.Errorf("snapshot hash mismatch: got %s, want %s", sum, src.SHA256)
			o.log.Error().Err(err).Msg("snapshot verification failed")
			trySend(ch, StartupProgress{Stage: snapshotStage, Message: err.Error(), Error: err})
			return
		}
	}

	// Core validates the snapshot here and blocks until the whole thing is
	// loaded, so this is both the acceptance check and the load. Its rejection
	// message is the useful one — relay it rather than paraphrasing.
	trySend(ch, StartupProgress{Stage: snapshotStage, Message: "loading " + src.Label + ", bitcoin core is reading the snapshot..."})
	o.download.PublishState("bitcoind", DownloadState{Message: snapshotApplyMessage})

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
		trySend(ch, StartupProgress{Stage: snapshotStage, Message: "bitcoin core rejected the snapshot: " + err.Error(), Error: err})
		return
	}

	// The snapshot file is left on disk. It is expensive to fetch and stays
	// reusable, so deleting it is the caller's call, not ours.
	trySend(ch, StartupProgress{Stage: snapshotStage, Message: "UTXO snapshot loaded, validating at the tip", Done: true})
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

// trySend drops the update when nobody is draining. Snapshot progress is
// advisory; a full channel must never stall the load itself.
func trySend(ch chan<- StartupProgress, p StartupProgress) {
	select {
	case ch <- p:
	default:
	}
}

// Status text the frontend renders for the two snapshot phases.
const (
	snapshotDownloadMessage = "Downloading UTXO snapshot"
	snapshotApplyMessage    = "Applying UTXO snapshot"
	snapshotVerifyMessage   = "Verifying UTXO snapshot"
)

// ensureSnapshotFile makes sure a verified snapshot exists at path, reusing an
// already-downloaded copy when its digest still matches.
func ensureSnapshotFile(ctx context.Context, src SnapshotSource, path string, ch chan<- StartupProgress, o *Orchestrator) error {
	if src.SHA256 != "" {
		// Hashing 9.5 GB takes minutes; say so rather than sitting on "Downloading".
		o.download.PublishState("bitcoind", DownloadState{Message: snapshotVerifyMessage})
		if sum, err := sha256File(path); err == nil && strings.EqualFold(sum, src.SHA256) {
			o.log.Info().Msg("snapshot already present and verified")
			return nil
		}
	}

	trySend(ch, StartupProgress{Stage: snapshotStage, Message: "downloading " + src.Label + "..."})
	sum, err := downloadAndHash(ctx, src.URL, path, ch, func(s DownloadState) {
		o.download.PublishState("bitcoind", s)
	})
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
func downloadAndHash(ctx context.Context, url, dest string, ch chan<- StartupProgress, publish func(DownloadState)) (string, error) {
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
	pw := &snapshotProgressWriter{total: resp.ContentLength, ch: ch, publish: publish}
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
	publish func(DownloadState)
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
		if w.publish != nil {
			w.publish(DownloadState{
				Message:      snapshotDownloadMessage,
				MBDownloaded: toMB(w.written),
				MBTotal:      toMB(w.total),
			})
		}
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
