package orchestrator

import (
	"archive/tar"
	"archive/zip"
	"compress/gzip"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"runtime"
	"strings"
	"sync"

	"github.com/rs/zerolog"
)

type DownloadProgress struct {
	// Progress in megabytes — bytes are converted at the source (downloadFile)
	// so every consumer (UI, logs, tests) sees the same units.
	MBDownloaded int64
	MBTotal      int64 // -1 if unknown
	Message      string
	Done         bool
	Error        error
}

// DownloadState is the in-memory snapshot of the latest progress event for a
// binary. The orchestrator's GetSyncStatus reads from here so the polled API
// can carry download progress without a separate stream — frontends never
// need to subscribe to DownloadBinary / StartWithL1 just to draw a progress
// bar.
type DownloadState struct {
	MBDownloaded int64
	MBTotal      int64
	Message      string
	Running      bool
}

const bytesPerMB int64 = 1024 * 1024

// toMB rounds bytes down to whole megabytes. -1 (unknown total) passes through.
func toMB(bytes int64) int64 {
	if bytes < 0 {
		return -1
	}
	return bytes / bytesPerMB
}

type DownloadManager struct {
	dataDir        string
	configFilePath string // path to chains_config.json for hash write-back
	httpClient     *http.Client
	log            zerolog.Logger
	inFlight       sync.Map
	// state holds the latest DownloadState for each in-flight binary, keyed
	// by the binary's logical name (e.g. "bitcoind", "thunder"). Updated on
	// every progress event from downloadFile, deleted on Done/Error so a
	// later GetSyncStatus tick reports nothing rather than stale bytes.
	state sync.Map

	// CoreVariant returns the active Bitcoin Core variant spec to use for
	// download/extract. It is consulted only when config.IsBitcoinCore. May
	// be left nil — in that case the download falls back to the legacy
	// per-network file selection (default vs. forknet).
	CoreVariant func() (CoreVariantSpec, bool)

	// SidechainVariant resolves the test/alternative download spec for a
	// layer-2 binary. ok=false means use the production fields. The "test"
	// suffix is also used to namespace the in-flight key and the on-disk
	// extract dir so prod and test builds can coexist without clobbering.
	SidechainVariant func(BinaryConfig) (sidechainVariantSpec, bool)
}

// sidechainVariantSpec is the minimal projection of BinaryConfig fields the
// download/process managers need to resolve an alternative build.
type sidechainVariantSpec struct {
	BinaryName       string
	BaseURL          string
	FileName         string
	ExtractSubfolder string
}

func NewDownloadManager(dataDir, configFilePath string, log zerolog.Logger) *DownloadManager {
	_ = os.MkdirAll(BinDir(dataDir), 0o755)
	return &DownloadManager{
		dataDir:        dataDir,
		configFilePath: configFilePath,
		httpClient:     &http.Client{},
		log:            log.With().Str("component", "download").Logger(),
	}
}

// Download downloads a binary to the bin directory with progress reporting.
// It determines the download strategy based on config (GitHub vs direct).
func (d *DownloadManager) Download(ctx context.Context, config BinaryConfig, network string, force bool) (<-chan DownloadProgress, error) {
	// Resolve variants once: callers don't have to know about them, but every
	// path below (target binary path, download URL, extract dir) must agree
	// on the choice. Core variants and sidechain test-builds are mutually
	// exclusive — Core is always layer-1, test sidechains are layer-2.
	variant, hasVariant := d.activeVariant(config)
	scVariant, hasSCVariant := d.activeSidechainVariant(config)

	binaryName := config.BinaryName
	if hasSCVariant {
		binaryName = scVariant.BinaryName
	}

	binPath := BinaryPath(d.dataDir, binaryName)
	if hasVariant {
		binPath = CoreBinaryPath(d.dataDir, variant, config.BinaryName)
	} else if hasSCVariant {
		binPath = TestSidechainBinaryPath(d.dataDir, binaryName)
	}

	if !force {
		if _, err := os.Stat(binPath); err == nil {
			ch := make(chan DownloadProgress, 1)
			ch <- DownloadProgress{Message: binPath, Done: true}
			close(ch)
			return ch, nil
		}
	}

	var fileName string
	var baseURL string
	switch {
	case hasVariant:
		f, err := variant.FileForOS()
		if err != nil {
			return nil, err
		}
		fileName = f
		baseURL = variant.BaseURL
	case hasSCVariant:
		fileName = scVariant.FileName
		baseURL = scVariant.BaseURL
	default:
		f, err := config.FileForOS()
		if err != nil {
			return nil, err
		}
		fileName = f
		baseURL = config.BaseURL(network)
	}

	if fileName == "" || baseURL == "" {
		return nil, fmt.Errorf("no download available for %s on %s", config.Name, currentOS())
	}

	inFlightKey := config.Name
	switch {
	case hasVariant:
		inFlightKey = config.Name + ":" + variant.ID
	case hasSCVariant:
		inFlightKey = config.Name + ":test"
	}
	if _, loaded := d.inFlight.LoadOrStore(inFlightKey, true); loaded {
		return nil, fmt.Errorf("%s is already being downloaded", config.Name)
	}

	ch := make(chan DownloadProgress, 100)

	// stateKey is the binary's logical name — what GetSyncStatus looks up
	// when populating ChainSync. It deliberately ignores the variant suffix
	// in inFlightKey: a download for "bitcoind:knots" and "bitcoind:patched"
	// can't run concurrently anyway (gated by inFlight), and the UI shows
	// progress for "bitcoind".
	stateKey := config.Name
	d.state.Store(stateKey, DownloadState{Running: true})

	go func() {
		defer d.inFlight.Delete(inFlightKey)
		defer d.state.Delete(stateKey)
		defer close(ch)

		// send aborts the goroutine when ctx fires *or* when the consumer
		// disappears and the buffered channel fills. Without this, an
		// unprotected `ch <- ...` could block forever (channel full, no
		// reader), the deferred `inFlight.Delete` would never run, and
		// every subsequent Download call for the same binary would error
		// out with "X is already being downloaded" — which is exactly how
		// the canceled-then-restart path was wedging the orchestrator.
		send := func(p DownloadProgress) bool {
			// Mirror every progress event into the state map. The polled
			// GetSyncStatus reads from here so the frontend gets download
			// bytes without subscribing to this channel.
			if p.Error == nil && !p.Done {
				d.state.Store(stateKey, DownloadState{
					MBDownloaded: p.MBDownloaded,
					MBTotal:      p.MBTotal,
					Message:      p.Message,
					Running:      true,
				})
			}
			select {
			case ch <- p:
				return true
			case <-ctx.Done():
				return false
			}
		}

		// Test sidechain alt URLs are always served directly from
		// releases.drivechain.info; the prod-side DownloadSourceGitHub flag
		// (used by zside/thunder-orchard for the production builds) doesn't
		// apply to them. Falling through to resolveGitHubURL would try to
		// JSON-parse an HTML 404 and abort the download with a confusing
		// "decode response: invalid character '<'" error.
		var downloadURL string
		source := config.DownloadSource
		if hasSCVariant {
			source = DownloadSourceDirect
		}
		switch source {
		case DownloadSourceGitHub:
			url, err := d.resolveGitHubURL(ctx, baseURL, fileName)
			if err != nil {
				send(DownloadProgress{Error: fmt.Errorf("resolve GitHub URL: %w", err)})
				return
			}
			downloadURL = url
		case DownloadSourceDirect:
			downloadURL = baseURL + fileName
		}

		d.log.Info().Str("url", downloadURL).Str("binary", config.Name).Msg("downloading")

		tmpDir, err := os.MkdirTemp("", "orchestrator-download-*")
		if err != nil {
			send(DownloadProgress{Error: fmt.Errorf("create temp dir: %w", err)})
			return
		}
		defer os.RemoveAll(tmpDir) //nolint:errcheck // cleanup

		savePath := filepath.Join(tmpDir, filepath.Base(downloadURL))

		if err := d.downloadFile(ctx, downloadURL, savePath, ch); err != nil {
			send(DownloadProgress{Error: err})
			return
		}

		// Compute SHA256 hash and write back to config
		if !send(DownloadProgress{Message: "verifying hash..."}) {
			return
		}
		archiveHash, archiveSize, err := hashFile(savePath)
		if err != nil {
			d.log.Warn().Err(err).Msg("failed to hash archive")
		} else {
			d.log.Info().Str("hash", archiveHash).Int64("size", archiveSize).Str("binary", config.Name).Msg("archive hash")
			if d.configFilePath != "" {
				if err := writeHashToConfig(d.configFilePath, config.Name, currentOS(), archiveHash, archiveSize); err != nil {
					d.log.Warn().Err(err).Msg("failed to write hash to config")
				}
			}
		}

		if !send(DownloadProgress{Message: "extracting..."}) {
			return
		}

		extractName := config.BinaryName
		stripPrefix := ""
		if hasSCVariant {
			extractName = scVariant.BinaryName
			stripPrefix = scVariant.ExtractSubfolder
		}
		hasCLI, err := d.extractBinary(savePath, config, extractName, stripPrefix, d.dataDir, network, variant, hasVariant, hasSCVariant)
		if err != nil {
			send(DownloadProgress{Error: fmt.Errorf("extract: %w", err)})
			return
		}
		d.log.Info().Bool("has_cli", hasCLI).Str("binary", extractName).Msg("extraction complete")

		finalPath := BinaryPath(d.dataDir, extractName)
		switch {
		case hasVariant:
			finalPath = CoreBinaryPath(d.dataDir, variant, config.BinaryName)
		case hasSCVariant:
			finalPath = TestSidechainBinaryPath(d.dataDir, extractName)
		}
		send(DownloadProgress{Message: finalPath, Done: true})
	}()

	return ch, nil
}

// activeVariant resolves the Core variant for the given config, if applicable.
func (d *DownloadManager) activeVariant(config BinaryConfig) (CoreVariantSpec, bool) {
	if !config.IsBitcoinCore || d.CoreVariant == nil {
		return CoreVariantSpec{}, false
	}
	return d.CoreVariant()
}

// activeSidechainVariant resolves the test-build spec for a layer-2 binary.
// Returns ok=false when the toggle is off or the config has no alt fields.
func (d *DownloadManager) activeSidechainVariant(config BinaryConfig) (sidechainVariantSpec, bool) {
	if config.IsBitcoinCore || d.SidechainVariant == nil {
		return sidechainVariantSpec{}, false
	}
	return d.SidechainVariant(config)
}

// State returns the latest download progress snapshot for a binary, keyed by
// its logical name (e.g. "bitcoind", "thunder"). ok=false means no download
// is in flight for that name. Read by Orchestrator.GetSyncStatus so the
// polled API can report download progress without callers needing to
// subscribe to the DownloadBinary / StartWithL1 streams.
func (d *DownloadManager) State(binaryName string) (DownloadState, bool) {
	v, ok := d.state.Load(binaryName)
	if !ok {
		return DownloadState{}, false
	}
	state, ok := v.(DownloadState)
	if !ok {
		return DownloadState{}, false
	}
	return state, true
}

// States returns a snapshot of every download currently in flight, keyed by
// the binary's logical name. Entries are inserted when a download starts
// and deleted when its goroutine returns (Done or Error), so the snapshot
// is naturally restricted to live downloads — no need for a Running check.
func (d *DownloadManager) States() map[string]DownloadState {
	out := make(map[string]DownloadState)
	d.state.Range(func(key, value any) bool {
		name, ok := key.(string)
		if !ok {
			return true
		}
		state, ok := value.(DownloadState)
		if !ok {
			return true
		}
		out[name] = state
		return true
	})
	return out
}

// resolveGitHubURL queries the GitHub releases API and finds the asset
// matching the regex pattern.
func (d *DownloadManager) resolveGitHubURL(ctx context.Context, apiURL, pattern string) (string, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, apiURL, nil)
	if err != nil {
		return "", fmt.Errorf("create request: %w", err)
	}
	req.Header.Set("User-Agent", "Drivechain-Frontends")
	req.Header.Set("Accept", "application/vnd.github.v3+json")

	resp, err := d.httpClient.Do(req)
	if err != nil {
		return "", fmt.Errorf("fetch releases: %w", err)
	}
	defer resp.Body.Close() //nolint:errcheck // cleanup

	if resp.StatusCode == http.StatusForbidden {
		return "", fmt.Errorf("GitHub API rate limited")
	}
	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("GitHub API returned %d", resp.StatusCode)
	}

	var release struct {
		Assets []struct {
			Name               string `json:"name"`
			BrowserDownloadURL string `json:"browser_download_url"`
		} `json:"assets"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&release); err != nil {
		return "", fmt.Errorf("decode response: %w", err)
	}

	re, err := regexp.Compile(pattern)
	if err != nil {
		return "", fmt.Errorf("compile pattern %q: %w", pattern, err)
	}

	for _, asset := range release.Assets {
		if re.MatchString(asset.Name) {
			return asset.BrowserDownloadURL, nil
		}
	}

	return "", fmt.Errorf("no asset matching %q in release", pattern)
}

// probeContentLength asks the server for the size up front via HEAD. Returns
// -1 when the server doesn't answer with a usable Content-Length so the
// caller can fall back to whatever the GET response carries (or unknown).
//
// We probe explicitly because some download paths (S3-backed redirects via
// the GitHub API, the bitcoincore.org tarball) return a final response with
// no Content-Length, and the UI then can't show a total. A HEAD round-trip
// is cheap and reliably gives us the number on releases.drivechain.info.
func (d *DownloadManager) probeContentLength(ctx context.Context, url string) int64 {
	req, err := http.NewRequestWithContext(ctx, http.MethodHead, url, nil)
	if err != nil {
		return -1
	}
	resp, err := d.httpClient.Do(req)
	if err != nil {
		return -1
	}
	defer resp.Body.Close() //nolint:errcheck // cleanup
	if resp.StatusCode != http.StatusOK {
		return -1
	}
	if resp.ContentLength > 0 {
		return resp.ContentLength
	}
	return -1
}

// downloadFile downloads a URL to a local path with progress reporting in MB.
func (d *DownloadManager) downloadFile(ctx context.Context, url, savePath string, progress chan<- DownloadProgress) error {
	// Probe the size first — final GET responses sometimes lack Content-Length
	// (S3 redirects, transfer-encoded responses), and the UI's progress bar
	// goes blank when total is unknown.
	probedTotal := d.probeContentLength(ctx, url)

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return fmt.Errorf("create request: %w", err)
	}

	resp, err := d.httpClient.Do(req)
	if err != nil {
		return fmt.Errorf("download: %w", err)
	}
	defer resp.Body.Close() //nolint:errcheck // cleanup

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("download returned HTTP %d", resp.StatusCode)
	}

	f, err := os.Create(savePath)
	if err != nil {
		return fmt.Errorf("create file: %w", err)
	}
	defer f.Close() //nolint:errcheck // cleanup

	total := resp.ContentLength
	if total <= 0 {
		total = probedTotal
	}
	var downloaded int64
	var lastPct int64 = -1
	const unknownChunkSize int64 = 1024 * 1024 // report every ~1MB when total unknown
	var lastUnknownReport int64

	buf := make([]byte, 32*1024)
	for {
		n, readErr := resp.Body.Read(buf)
		if n > 0 {
			if _, err := f.Write(buf[:n]); err != nil {
				return fmt.Errorf("write: %w", err)
			}
			downloaded += int64(n)

			shouldSend := false
			if total > 0 {
				pct := downloaded * 100 / total
				if pct != lastPct {
					lastPct = pct
					shouldSend = true
				}
			} else {
				if downloaded-lastUnknownReport >= unknownChunkSize {
					lastUnknownReport = downloaded
					shouldSend = true
				}
			}

			if shouldSend {
				// Honor ctx so a canceled download doesn't deadlock here
				// when the consumer's already gone — same wedge pattern
				// as the outer goroutine's `ch <-` sends.
				select {
				case progress <- DownloadProgress{
					MBDownloaded: toMB(downloaded),
					MBTotal:      toMB(total),
				}:
				case <-ctx.Done():
					return ctx.Err()
				}
			}
		}
		if readErr != nil {
			if readErr == io.EOF {
				break
			}
			return fmt.Errorf("read: %w", readErr)
		}
	}

	return nil
}

// extractBinary extracts a downloaded archive to the bin directory.
// Returns hasCLI=true iff a companion CLI binary (name contains "-cli") was
// extracted alongside the main binary. Raw binaries never have a CLI.
func (d *DownloadManager) extractBinary(archivePath string, config BinaryConfig, extractName, stripPrefix, dataDir, network string, variant CoreVariantSpec, hasVariant, hasSCVariant bool) (bool, error) {
	destDir := BinDir(dataDir)

	switch {
	case hasSCVariant:
		// Test sidechain builds need a private dir so per-binary lib/data
		// trees don't collide.
		destDir = filepath.Join(destDir, testSidechainSubfolder, extractName)
	case !config.IsBitcoinCore:
		// Forknet zips ship a top-level directory we have to peel off.
		if subfolder, ok := config.ExtractSubfolder[currentOS()]; ok && subfolder != "" {
			if network == "forknet" && len(config.ForknetFiles) > 0 {
				destDir = filepath.Join(destDir, subfolder)
			}
		}
	}

	_ = os.MkdirAll(destDir, 0o755)

	lower := strings.ToLower(archivePath)
	switch {
	case strings.HasSuffix(lower, ".zip"):
		// Test sidechain archives ship as Flutter app bundles — flatten-by-
		// basename would destroy the bundle, so preserve the tree.
		if hasSCVariant {
			return d.extractZipPreservingTree(archivePath, destDir, stripPrefix)
		}
		return d.extractZip(archivePath, destDir, extractName)
	case strings.HasSuffix(lower, ".tar.gz") || strings.HasSuffix(lower, ".tgz"):
		return d.extractTarGz(archivePath, destDir, extractName)
	default:
		// Raw test-sidechain payload on Windows lands at <name>.exe.
		name := extractName
		if hasSCVariant && runtime.GOOS == "windows" {
			name += ".exe"
		}
		return d.processRawBinary(archivePath, destDir, name)
	}
}

// extractZipPreservingTree extracts a zip preserving its directory layout.
// Used for test sidechain Flutter app bundles, where the `Foo.app/` (macOS)
// or `foo/lib/...` (Linux) tree must remain intact for the runtime to
// find frameworks, plugins, and assets at the expected relative paths. If
// stripPrefix is non-empty, that path prefix is removed from each archive
// entry so the archive's top-level namespace doesn't double up against
// destDir's per-binary subfolder (e.g. without stripping "thunder/", the
// Linux extract would land at `bin/test/thunder/thunder/thunder`).
func (d *DownloadManager) extractZipPreservingTree(archivePath, destDir, stripPrefix string) (bool, error) {
	r, err := zip.OpenReader(archivePath)
	if err != nil {
		return false, fmt.Errorf("open zip: %w", err)
	}
	defer r.Close() //nolint:errcheck // cleanup

	if stripPrefix != "" && !strings.HasSuffix(stripPrefix, "/") {
		stripPrefix += "/"
	}

	moved := 0
	hasCLI := false
	for _, f := range r.File {
		name := f.Name
		if stripPrefix != "" {
			if !strings.HasPrefix(name, stripPrefix) {
				// Anything outside the expected top-level dir is metadata
				// we don't want polluting the bin tree (LICENSE, README,
				// stray sibling files). Skip silently.
				continue
			}
			name = strings.TrimPrefix(name, stripPrefix)
			if name == "" {
				continue
			}
		}

		destPath := filepath.Join(destDir, name)

		if f.FileInfo().IsDir() {
			if err := os.MkdirAll(destPath, 0o755); err != nil {
				return false, fmt.Errorf("create dir: %w", err)
			}
			continue
		}

		if err := os.MkdirAll(filepath.Dir(destPath), 0o755); err != nil {
			return false, fmt.Errorf("create dir: %w", err)
		}

		// Symlinks (`Versions/Current` -> `A`, `framework_name` ->
		// `Versions/A/framework_name`) are essential to macOS framework
		// resolution; the framework's main binary is reached through them
		// and code-signing fails to verify if they're rewritten as files.
		if f.Mode()&os.ModeSymlink != 0 {
			rc, err := f.Open()
			if err != nil {
				return false, fmt.Errorf("open symlink %s: %w", f.Name, err)
			}
			target, err := io.ReadAll(rc)
			_ = rc.Close()
			if err != nil {
				return false, fmt.Errorf("read symlink %s: %w", f.Name, err)
			}
			_ = os.Remove(destPath)
			if err := os.Symlink(string(target), destPath); err != nil {
				return false, fmt.Errorf("create symlink %s -> %s: %w", destPath, string(target), err)
			}
			moved++
			continue
		}

		if err := extractZipFile(f, destPath); err != nil {
			return false, err
		}
		if err := chmod(destPath); err != nil {
			d.log.Warn().Err(err).Str("file", destPath).Msg("chmod")
		}
		if strings.Contains(strings.ToLower(strings.TrimSuffix(filepath.Base(destPath), ".exe")), "-cli") {
			hasCLI = true
		}
		moved++
	}

	if moved == 0 {
		return false, fmt.Errorf("no files extracted from %s (stripPrefix=%q)", archivePath, stripPrefix)
	}

	return hasCLI, nil
}

// extractZip extracts a zip archive, flattening single-directory archives.
func (d *DownloadManager) extractZip(archivePath, destDir, binaryName string) (bool, error) {
	r, err := zip.OpenReader(archivePath)
	if err != nil {
		return false, fmt.Errorf("open zip: %w", err)
	}
	defer r.Close() //nolint:errcheck // cleanup

	tmpDir, err := os.MkdirTemp("", "orchestrator-extract-*")
	if err != nil {
		return false, fmt.Errorf("create temp dir: %w", err)
	}
	defer os.RemoveAll(tmpDir) //nolint:errcheck // cleanup

	for _, f := range r.File {
		if f.FileInfo().IsDir() {
			continue
		}

		destPath := filepath.Join(tmpDir, f.Name)
		if err := os.MkdirAll(filepath.Dir(destPath), 0o755); err != nil {
			return false, fmt.Errorf("create dir: %w", err)
		}

		if err := extractZipFile(f, destPath); err != nil {
			return false, err
		}
	}

	return d.moveExtractedBinaries(tmpDir, destDir, binaryName)
}

func extractZipFile(f *zip.File, dest string) error {
	rc, err := f.Open()
	if err != nil {
		return fmt.Errorf("open zip entry %s: %w", f.Name, err)
	}
	defer rc.Close() //nolint:errcheck // cleanup

	outFile, err := os.Create(dest)
	if err != nil {
		return fmt.Errorf("create %s: %w", dest, err)
	}
	defer outFile.Close() //nolint:errcheck // cleanup

	if _, err := io.Copy(outFile, rc); err != nil {
		return fmt.Errorf("extract %s: %w", f.Name, err)
	}

	return nil
}

// extractTarGz extracts a tar.gz archive.
func (d *DownloadManager) extractTarGz(archivePath, destDir, binaryName string) (bool, error) {
	f, err := os.Open(archivePath)
	if err != nil {
		return false, fmt.Errorf("open archive: %w", err)
	}
	defer f.Close() //nolint:errcheck // cleanup

	gz, err := gzip.NewReader(f)
	if err != nil {
		return false, fmt.Errorf("gzip reader: %w", err)
	}
	defer gz.Close() //nolint:errcheck // cleanup

	tmpDir, err := os.MkdirTemp("", "orchestrator-extract-*")
	if err != nil {
		return false, fmt.Errorf("create temp dir: %w", err)
	}
	defer os.RemoveAll(tmpDir) //nolint:errcheck // cleanup

	tr := tar.NewReader(gz)
	for {
		header, err := tr.Next()
		if err == io.EOF {
			break
		}
		if err != nil {
			return false, fmt.Errorf("read tar: %w", err)
		}

		if header.Typeflag != tar.TypeReg {
			continue
		}

		// Skip non-binary files (LICENSE, README, etc.)
		base := filepath.Base(header.Name)
		if strings.EqualFold(base, "LICENSE") || strings.HasPrefix(strings.ToUpper(base), "README") {
			continue
		}

		destPath := filepath.Join(tmpDir, base)
		outFile, err := os.Create(destPath)
		if err != nil {
			return false, fmt.Errorf("create %s: %w", destPath, err)
		}

		if _, err := io.Copy(outFile, tr); err != nil {
			_ = outFile.Close()
			return false, fmt.Errorf("extract %s: %w", header.Name, err)
		}
		_ = outFile.Close()
	}

	return d.moveExtractedBinaries(tmpDir, destDir, binaryName)
}

// processRawBinary copies a raw binary to the destination directory.
// A raw binary never carries a CLI companion, so hasCLI is always false.
func (d *DownloadManager) processRawBinary(srcPath, destDir, binaryName string) (bool, error) {
	destPath := filepath.Join(destDir, binaryName)

	src, err := os.Open(srcPath)
	if err != nil {
		return false, fmt.Errorf("open source: %w", err)
	}
	defer src.Close() //nolint:errcheck // cleanup

	dst, err := os.Create(destPath)
	if err != nil {
		return false, fmt.Errorf("create dest: %w", err)
	}
	defer dst.Close() //nolint:errcheck // cleanup

	if _, err := io.Copy(dst, src); err != nil {
		return false, fmt.Errorf("copy: %w", err)
	}

	return false, chmod(destPath)
}

// moveExtractedBinaries moves files from a temp extraction dir to the bin dir,
// applying rename logic and chmod. Returns hasCLI=true iff any extracted file's
// post-strip name contains "-cli", which is how we distinguish archives that
// ship a CLI companion (thunder, bitnames, bitassets, etc.) from single-binary
// payloads (like truthcoin on some platforms).
func (d *DownloadManager) moveExtractedBinaries(tmpDir, destDir, binaryName string) (bool, error) {
	moved := 0
	hasCLI := false

	// Walk recursively to find all files, flatten them into destDir
	err := filepath.WalkDir(tmpDir, func(path string, entry os.DirEntry, err error) error {
		if err != nil || entry.IsDir() {
			return err
		}

		// Skip non-binary files
		name := entry.Name()
		lower := strings.ToLower(name)
		if lower == "license" || strings.HasPrefix(lower, "readme") {
			return nil
		}

		cleanName := StripPlatformSuffix(name)
		destName := cleanName
		if normalizeBinaryName(cleanName) == normalizeBinaryName(binaryName) {
			destName = binaryName
		}
		destPath := filepath.Join(destDir, destName)

		if strings.Contains(strings.ToLower(strings.TrimSuffix(destName, ".exe")), "-cli") {
			hasCLI = true
		}

		if err := moveFile(path, destPath); err != nil {
			d.log.Warn().Err(err).Str("file", name).Msg("move extracted file")
			return nil
		}

		if err := chmod(destPath); err != nil {
			d.log.Warn().Err(err).Str("file", destPath).Msg("chmod")
		}

		moved++
		d.log.Debug().Str("file", destName).Msg("extracted")
		return nil
	})
	if err != nil {
		return false, fmt.Errorf("walk extracted dir: %w", err)
	}

	if moved == 0 {
		return false, fmt.Errorf("no files extracted for %s", binaryName)
	}

	return hasCLI, nil
}

// moveFile moves a file from src to dest, handling cross-device moves.
func normalizeBinaryName(name string) string {
	name = strings.ToLower(name)
	name = strings.ReplaceAll(name, "-", "")
	name = strings.ReplaceAll(name, "_", "")
	return name
}

func moveFile(src, dest string) error {
	if err := os.Rename(src, dest); err == nil {
		return nil
	}

	// Cross-device fallback: copy then remove
	srcFile, err := os.Open(src)
	if err != nil {
		return err
	}
	defer srcFile.Close() //nolint:errcheck // cleanup

	destFile, err := os.Create(dest)
	if err != nil {
		return err
	}
	defer destFile.Close() //nolint:errcheck // cleanup

	if _, err := io.Copy(destFile, srcFile); err != nil {
		return err
	}

	_ = srcFile.Close()
	return os.Remove(src)
}

// hashFile computes the SHA256 hash and size of a file.
func hashFile(path string) (string, int64, error) {
	f, err := os.Open(path)
	if err != nil {
		return "", 0, err
	}
	defer f.Close() //nolint:errcheck // cleanup

	h := sha256.New()
	size, err := io.Copy(h, f)
	if err != nil {
		return "", 0, err
	}

	return hex.EncodeToString(h.Sum(nil)), size, nil
}

// writeHashToConfig reads chains_config.json, updates the hash for a binary,
// and writes it back. The file watcher will pick up the change.
func writeHashToConfig(configPath, binaryName, osName, hash string, size int64) error {
	// Map internal binary names to JSON keys
	jsonKey := ""
	for k, v := range jsonKeyToName {
		if v == binaryName {
			jsonKey = k
			break
		}
	}
	if jsonKey == "" {
		jsonKey = binaryName
	}

	data, err := os.ReadFile(configPath)
	if err != nil {
		return fmt.Errorf("read config: %w", err)
	}

	var raw map[string]any
	if err := json.Unmarshal(data, &raw); err != nil {
		return fmt.Errorf("unmarshal config: %w", err)
	}

	binaries, ok := raw["binaries"].(map[string]any)
	if !ok {
		return fmt.Errorf("binaries not found in config")
	}

	binaryConf, ok := binaries[jsonKey].(map[string]any)
	if !ok {
		return fmt.Errorf("binary %s not found in config", jsonKey)
	}

	hashes, ok := binaryConf["hashes"].(map[string]any)
	if !ok {
		hashes = make(map[string]any)
	}
	hashes[osName] = map[string]any{"sha256": hash, "size": size}
	binaryConf["hashes"] = hashes

	out, err := json.MarshalIndent(raw, "", "  ")
	if err != nil {
		return fmt.Errorf("marshal config: %w", err)
	}

	return os.WriteFile(configPath, out, 0o644)
}

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

	// Track whether the file had .exe (needed on Windows).
	hadExe := strings.HasSuffix(result, ".exe")

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

	// Strip "-latest" placeholder version tag
	result = strings.TrimSuffix(result, "-latest")

	// Clean up trailing/leading/double dashes
	result = strings.TrimRight(result, "-_")
	result = strings.TrimLeft(result, "-_")

	// Restore .exe on Windows — it's a meaningful extension, not a platform suffix.
	if hadExe && runtime.GOOS == "windows" {
		result += ".exe"
	}

	return result
}
