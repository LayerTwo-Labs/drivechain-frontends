package orchestrator

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strings"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
)

// drynet2 forks Bitcoin mainnet at this height and ships an assumeutxo
// commitment for it, so a fresh node can load a UTXO snapshot and validate at
// the tip within minutes instead of downloading all of mainnet history.
const (
	drynet2ForkHeight   = 957600
	drynet2SnapshotFile = "utxo-957600.dat"
	drynet2SnapshotURL  = "https://data.drivechain.dev/drynet2/" + drynet2SnapshotFile
	drynet2SnapshotSums = "https://data.drivechain.dev/drynet2/SHA256SUMS"
)

// maybeLoadDrynet2Snapshot fast-bootstraps a fresh drynet2 node from the
// published assumeutxo snapshot: it downloads utxo-957600.dat, verifies it
// against SHA256SUMS, and calls loadtxoutset so the node validates at the tip
// within minutes. It is a no-op on other networks and once the node already
// reaches the fork block. Every failure is non-fatal — the node just falls
// back to a normal full sync.
func (o *Orchestrator) maybeLoadDrynet2Snapshot(ctx context.Context, ch chan<- StartupProgress) {
	if config.NetworkFromString(o.Network) != config.NetworkDrynet2 {
		return
	}

	client, err := o.CoreStatusClient()
	if err != nil {
		o.log.Warn().Err(err).Msg("drynet2 snapshot: no core client, skipping")
		return
	}

	// Skip once the node already reaches the fork height: the snapshot is
	// loaded (or the chain is fully synced) and loadtxoutset would only error.
	if count, err := client.GetBlockCount(ctx); err == nil && count >= drynet2ForkHeight {
		return
	}

	datadir := ""
	if o.BitcoinConf != nil {
		datadir = o.BitcoinConf.DetectedDataDir
	}
	if datadir == "" {
		o.log.Warn().Msg("drynet2 snapshot: no datadir configured, skipping")
		return
	}
	snapshotPath := filepath.Join(datadir, drynet2SnapshotFile)

	ch <- StartupProgress{Stage: "drynet2-snapshot", Message: "preparing drynet2 UTXO snapshot..."}
	if err := ensureDrynet2Snapshot(ctx, snapshotPath, ch, o); err != nil {
		o.log.Error().Err(err).Msg("drynet2 snapshot download/verify failed; falling back to full sync")
		ch <- StartupProgress{Stage: "drynet2-snapshot", Message: "snapshot unavailable, doing a full sync instead"}
		return
	}

	ch <- StartupProgress{Stage: "drynet2-snapshot", Message: "loading UTXO snapshot (this can take a few minutes)..."}
	if _, err := client.call(ctx, "loadtxoutset", snapshotPath); err != nil {
		o.log.Error().Err(err).Msg("drynet2 snapshot loadtxoutset failed; falling back to full sync")
		ch <- StartupProgress{Stage: "drynet2-snapshot", Message: "snapshot load failed, doing a full sync instead"}
		return
	}

	// Core has copied what it needs into the chainstate, so reclaim the ~9 GB.
	if err := os.Remove(snapshotPath); err != nil && !os.IsNotExist(err) {
		o.log.Warn().Err(err).Str("path", snapshotPath).Msg("drynet2 snapshot: could not remove snapshot file")
	}
	ch <- StartupProgress{Stage: "drynet2-snapshot", Message: "UTXO snapshot loaded; validating at the tip"}
	o.log.Info().Msg("drynet2 snapshot loaded via loadtxoutset")
}

// ensureDrynet2Snapshot makes sure a verified snapshot file exists at
// snapshotPath, reusing an already-downloaded copy when its hash still matches.
func ensureDrynet2Snapshot(ctx context.Context, snapshotPath string, ch chan<- StartupProgress, o *Orchestrator) error {
	expected, err := fetchDrynet2SnapshotHash(ctx)
	if err != nil {
		return fmt.Errorf("fetch SHA256SUMS: %w", err)
	}

	if sum, err := sha256File(snapshotPath); err == nil && strings.EqualFold(sum, expected) {
		o.log.Info().Msg("drynet2 snapshot already present and verified")
		return nil
	}

	ch <- StartupProgress{Stage: "drynet2-snapshot", Message: "downloading drynet2 UTXO snapshot (~9 GB)..."}
	sum, err := downloadAndHash(ctx, drynet2SnapshotURL, snapshotPath, ch)
	if err != nil {
		return fmt.Errorf("download snapshot: %w", err)
	}
	if !strings.EqualFold(sum, expected) {
		_ = os.Remove(snapshotPath)
		return fmt.Errorf("snapshot hash mismatch: got %s, want %s", sum, expected)
	}
	return nil
}

// fetchDrynet2SnapshotHash downloads SHA256SUMS and returns the hash recorded
// for the snapshot file.
func fetchDrynet2SnapshotHash(ctx context.Context) (string, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, drynet2SnapshotSums, nil)
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
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}
	for _, line := range strings.Split(string(body), "\n") {
		fields := strings.Fields(line)
		if len(fields) >= 2 && strings.HasSuffix(fields[len(fields)-1], drynet2SnapshotFile) {
			return fields[0], nil
		}
	}
	return "", fmt.Errorf("no entry for %s in SHA256SUMS", drynet2SnapshotFile)
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
		case w.ch <- StartupProgress{Stage: "drynet2-snapshot", Message: fmt.Sprintf("downloading drynet2 UTXO snapshot... %d%%", pct)}:
		default:
		}
	}
	return n, nil
}
