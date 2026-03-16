package orchestrator

import (
	"archive/tar"
	"archive/zip"
	"compress/gzip"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"strings"
	"sync"

	"github.com/rs/zerolog"
)

type DownloadProgress struct {
	BytesDownloaded int64
	TotalBytes      int64 // -1 if unknown
	Message         string
	Done            bool
	Error           error
}

type DownloadManager struct {
	dataDir    string
	httpClient *http.Client
	log        zerolog.Logger
	inFlight   sync.Map
}

func NewDownloadManager(dataDir string, log zerolog.Logger) *DownloadManager {
	_ = os.MkdirAll(BinDir(dataDir), 0o755)
	return &DownloadManager{
		dataDir:    dataDir,
		httpClient: &http.Client{},
		log:        log.With().Str("component", "download").Logger(),
	}
}

// Download downloads a binary to the bin directory with progress reporting.
// It determines the download strategy based on config (GitHub vs direct).
func (d *DownloadManager) Download(ctx context.Context, config BinaryConfig, force bool) (<-chan DownloadProgress, error) {
	binPath := BinaryPath(d.dataDir, config.BinaryName)

	if !force {
		if _, err := os.Stat(binPath); err == nil {
			ch := make(chan DownloadProgress, 1)
			ch <- DownloadProgress{Message: "already downloaded", Done: true}
			close(ch)
			return ch, nil
		}
	}

	fileName, err := config.FileForOS()
	if err != nil {
		return nil, err
	}

	if fileName == "" || config.DownloadURL == "" {
		return nil, fmt.Errorf("no download available for %s on %s", config.Name, currentOS())
	}

	if _, loaded := d.inFlight.LoadOrStore(config.Name, true); loaded {
		return nil, fmt.Errorf("%s is already being downloaded", config.Name)
	}

	ch := make(chan DownloadProgress, 100)

	go func() {
		defer d.inFlight.Delete(config.Name)
		defer close(ch)

		var downloadURL string
		switch config.DownloadSource {
		case DownloadSourceGitHub:
			url, err := d.resolveGitHubURL(ctx, config.DownloadURL, fileName)
			if err != nil {
				ch <- DownloadProgress{Error: fmt.Errorf("resolve GitHub URL: %w", err)}
				return
			}
			downloadURL = url
		case DownloadSourceDirect:
			downloadURL = config.DownloadURL + fileName
		}

		d.log.Info().Str("url", downloadURL).Str("binary", config.Name).Msg("downloading")

		tmpDir, err := os.MkdirTemp("", "orchestrator-download-*")
		if err != nil {
			ch <- DownloadProgress{Error: fmt.Errorf("create temp dir: %w", err)}
			return
		}
		defer os.RemoveAll(tmpDir)

		savePath := filepath.Join(tmpDir, filepath.Base(downloadURL))

		if err := d.downloadFile(ctx, downloadURL, savePath, ch); err != nil {
			ch <- DownloadProgress{Error: err}
			return
		}

		ch <- DownloadProgress{Message: "extracting..."}

		if err := d.extractBinary(savePath, config, d.dataDir); err != nil {
			ch <- DownloadProgress{Error: fmt.Errorf("extract: %w", err)}
			return
		}

		ch <- DownloadProgress{Message: "done", Done: true}
	}()

	return ch, nil
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
	defer resp.Body.Close()

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

// downloadFile downloads a URL to a local path with progress reporting.
func (d *DownloadManager) downloadFile(ctx context.Context, url, savePath string, progress chan<- DownloadProgress) error {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return fmt.Errorf("create request: %w", err)
	}

	resp, err := d.httpClient.Do(req)
	if err != nil {
		return fmt.Errorf("download: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("download returned HTTP %d", resp.StatusCode)
	}

	f, err := os.Create(savePath)
	if err != nil {
		return fmt.Errorf("create file: %w", err)
	}
	defer f.Close()

	total := resp.ContentLength
	var downloaded int64
	var lastPermille int64 = -1 // tracks 0.1% increments (0-1000)
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
			var msg string
			if total > 0 {
				permille := downloaded * 1000 / total
				if permille != lastPermille {
					lastPermille = permille
					shouldSend = true
					msg = fmt.Sprintf("Downloaded %.2f MB / %.2f MB (%.1f%%)",
						float64(downloaded)/1e6, float64(total)/1e6, float64(permille)/10.0)
				}
			} else {
				if downloaded-lastUnknownReport >= unknownChunkSize {
					lastUnknownReport = downloaded
					shouldSend = true
					msg = fmt.Sprintf("Downloaded %.2f MB", float64(downloaded)/1e6)
				}
			}

			if shouldSend {
				progress <- DownloadProgress{
					BytesDownloaded: downloaded,
					TotalBytes:      total,
					Message:         msg,
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
func (d *DownloadManager) extractBinary(archivePath string, config BinaryConfig, dataDir string) error {
	binDir := BinDir(dataDir)
	_ = os.MkdirAll(binDir, 0o755)

	lower := strings.ToLower(archivePath)
	switch {
	case strings.HasSuffix(lower, ".zip"):
		return d.extractZip(archivePath, binDir, config.BinaryName)
	case strings.HasSuffix(lower, ".tar.gz") || strings.HasSuffix(lower, ".tgz"):
		return d.extractTarGz(archivePath, binDir, config.BinaryName)
	default:
		return d.processRawBinary(archivePath, binDir, config.BinaryName)
	}
}

// extractZip extracts a zip archive, flattening single-directory archives.
func (d *DownloadManager) extractZip(archivePath, destDir, binaryName string) error {
	r, err := zip.OpenReader(archivePath)
	if err != nil {
		return fmt.Errorf("open zip: %w", err)
	}
	defer r.Close()

	tmpDir, err := os.MkdirTemp("", "orchestrator-extract-*")
	if err != nil {
		return fmt.Errorf("create temp dir: %w", err)
	}
	defer os.RemoveAll(tmpDir)

	for _, f := range r.File {
		if f.FileInfo().IsDir() {
			continue
		}

		destPath := filepath.Join(tmpDir, f.Name)
		if err := os.MkdirAll(filepath.Dir(destPath), 0o755); err != nil {
			return fmt.Errorf("create dir: %w", err)
		}

		if err := extractZipFile(f, destPath); err != nil {
			return err
		}
	}

	return d.moveExtractedBinaries(tmpDir, destDir, binaryName)
}

func extractZipFile(f *zip.File, dest string) error {
	rc, err := f.Open()
	if err != nil {
		return fmt.Errorf("open zip entry %s: %w", f.Name, err)
	}
	defer rc.Close()

	outFile, err := os.Create(dest)
	if err != nil {
		return fmt.Errorf("create %s: %w", dest, err)
	}
	defer outFile.Close()

	if _, err := io.Copy(outFile, rc); err != nil {
		return fmt.Errorf("extract %s: %w", f.Name, err)
	}

	return nil
}

// extractTarGz extracts a tar.gz archive.
func (d *DownloadManager) extractTarGz(archivePath, destDir, binaryName string) error {
	f, err := os.Open(archivePath)
	if err != nil {
		return fmt.Errorf("open archive: %w", err)
	}
	defer f.Close()

	gz, err := gzip.NewReader(f)
	if err != nil {
		return fmt.Errorf("gzip reader: %w", err)
	}
	defer gz.Close()

	tmpDir, err := os.MkdirTemp("", "orchestrator-extract-*")
	if err != nil {
		return fmt.Errorf("create temp dir: %w", err)
	}
	defer os.RemoveAll(tmpDir)

	tr := tar.NewReader(gz)
	for {
		header, err := tr.Next()
		if err == io.EOF {
			break
		}
		if err != nil {
			return fmt.Errorf("read tar: %w", err)
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
			return fmt.Errorf("create %s: %w", destPath, err)
		}

		if _, err := io.Copy(outFile, tr); err != nil {
			outFile.Close()
			return fmt.Errorf("extract %s: %w", header.Name, err)
		}
		outFile.Close()
	}

	return d.moveExtractedBinaries(tmpDir, destDir, binaryName)
}

// processRawBinary copies a raw binary to the destination directory.
func (d *DownloadManager) processRawBinary(srcPath, destDir, binaryName string) error {
	destPath := filepath.Join(destDir, binaryName)

	src, err := os.Open(srcPath)
	if err != nil {
		return fmt.Errorf("open source: %w", err)
	}
	defer src.Close()

	dst, err := os.Create(destPath)
	if err != nil {
		return fmt.Errorf("create dest: %w", err)
	}
	defer dst.Close()

	if _, err := io.Copy(dst, src); err != nil {
		return fmt.Errorf("copy: %w", err)
	}

	return chmod(destPath)
}

// moveExtractedBinaries moves files from a temp extraction dir to the bin dir,
// applying rename logic and chmod.
func (d *DownloadManager) moveExtractedBinaries(tmpDir, destDir, binaryName string) error {
	entries, err := os.ReadDir(tmpDir)
	if err != nil {
		return fmt.Errorf("read extracted dir: %w", err)
	}

	// If extraction produced a single directory, look inside it
	if len(entries) == 1 && entries[0].IsDir() {
		tmpDir = filepath.Join(tmpDir, entries[0].Name())
		entries, err = os.ReadDir(tmpDir)
		if err != nil {
			return fmt.Errorf("read nested dir: %w", err)
		}
	}

	moved := 0
	for _, entry := range entries {
		if entry.IsDir() {
			continue
		}

		srcPath := filepath.Join(tmpDir, entry.Name())
		cleanName := StripPlatformSuffix(entry.Name())
		destPath := filepath.Join(destDir, cleanName)

		if err := moveFile(srcPath, destPath); err != nil {
			d.log.Warn().Err(err).Str("file", entry.Name()).Msg("move extracted file")
			continue
		}

		if err := chmod(destPath); err != nil {
			d.log.Warn().Err(err).Str("file", destPath).Msg("chmod")
		}

		moved++
		d.log.Debug().Str("file", cleanName).Msg("extracted")
	}

	if moved == 0 {
		return fmt.Errorf("no files extracted for %s", binaryName)
	}

	return nil
}

// moveFile moves a file from src to dest, handling cross-device moves.
func moveFile(src, dest string) error {
	if err := os.Rename(src, dest); err == nil {
		return nil
	}

	// Cross-device fallback: copy then remove
	srcFile, err := os.Open(src)
	if err != nil {
		return err
	}
	defer srcFile.Close()

	destFile, err := os.Create(dest)
	if err != nil {
		return err
	}
	defer destFile.Close()

	if _, err := io.Copy(destFile, srcFile); err != nil {
		return err
	}

	srcFile.Close()
	return os.Remove(src)
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

	return result
}
