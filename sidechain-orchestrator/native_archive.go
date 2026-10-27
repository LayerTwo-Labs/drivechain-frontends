package orchestrator

import (
	"archive/tar"
	"compress/gzip"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
)

// Native Linux bundles need lib/ and share/ beside bin/. Never flatten them.
func (d *DownloadManager) extractTarPreservingTree(archive, dest, prefix string) (bool, error) {
	f, err := os.Open(archive)
	if err != nil {
		return false, err
	}
	defer f.Close()
	gz, err := gzip.NewReader(f)
	if err != nil {
		return false, err
	}
	defer gz.Close()
	reader := tar.NewReader(gz)
	prefix = strings.TrimSuffix(prefix, "/")
	count := 0
	for {
		h, err := reader.Next()
		if err == io.EOF {
			break
		}
		if err != nil {
			return false, err
		}
		name := h.Name
		if prefix != "" {
			if !strings.HasPrefix(name, prefix+"/") {
				continue
			}
			name = strings.TrimPrefix(name, prefix+"/")
			if name == "" {
				continue
			}
		}
		if !filepath.IsLocal(name) {
			return false, fmt.Errorf("tar entry %q leaves the archive", h.Name)
		}
		if err = rejectSymlinkInPath(dest, name); err != nil {
			return false, err
		}
		path := filepath.Join(dest, name)
		switch h.Typeflag {
		case tar.TypeDir:
			if err = os.MkdirAll(path, 0o755); err != nil {
				return false, err
			}
		case tar.TypeReg, tar.TypeRegA:
			if err = os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
				return false, err
			}
			out, err := os.OpenFile(path, os.O_CREATE|os.O_TRUNC|os.O_WRONLY, os.FileMode(h.Mode)&0o777)
			if err != nil {
				return false, err
			}
			_, copyErr := io.CopyN(out, reader, h.Size)
			closeErr := out.Close()
			if copyErr != nil {
				return false, copyErr
			}
			if closeErr != nil {
				return false, closeErr
			}
			if err = os.Chmod(path, os.FileMode(h.Mode)&0o777); err != nil {
				return false, err
			}
			count++
		case tar.TypeSymlink:
			if filepath.IsAbs(h.Linkname) || !filepath.IsLocal(filepath.Join(filepath.Dir(name), h.Linkname)) {
				return false, fmt.Errorf("tar symlink %q leaves the archive", h.Name)
			}
			if err = os.MkdirAll(filepath.Dir(path), 0o755); err != nil {
				return false, err
			}
			if err = os.Symlink(h.Linkname, path); err != nil {
				return false, err
			}
			count++
		default:
			return false, fmt.Errorf("unsupported native bundle entry %q", h.Name)
		}
	}
	if count == 0 {
		return false, fmt.Errorf("native bundle contains no files")
	}
	return false, nil
}

// Verify all executables in a fresh tree before replacing an installed bundle.
func (d *DownloadManager) extractNativeBundle(archive string, cfg BinaryConfig, target DownloadTarget) (bool, error) {
	dest := filepath.Join(BinDir(d.dataDir), target.BinSubfolder)
	if target.BinSubfolder == "" || !filepath.IsLocal(target.BinSubfolder) {
		return false, fmt.Errorf("native bundle needs a private install directory")
	}
	if err := os.MkdirAll(filepath.Dir(dest), 0o755); err != nil {
		return false, err
	}
	stage, err := os.MkdirTemp(filepath.Dir(dest), ".native-staging-")
	if err != nil {
		return false, err
	}
	defer os.RemoveAll(stage)
	switch {
	case strings.HasSuffix(strings.ToLower(archive), ".zip"):
		_, err = d.extractZipPreservingTree(archive, stage, target.ExtractSubfolder)
	case strings.HasSuffix(strings.ToLower(archive), ".tar.gz"), strings.HasSuffix(strings.ToLower(archive), ".tgz"):
		_, err = d.extractTarPreservingTree(archive, stage, target.ExtractSubfolder)
	default:
		return false, fmt.Errorf("native bundle must be ZIP or tar.gz")
	}
	if err != nil {
		return false, err
	}
	for name, hash := range cfg.BundleChecksums {
		if !filepath.IsLocal(name) {
			return false, fmt.Errorf("invalid bundle checksum path")
		}
		part := BinaryConfig{Name: cfg.Name, ArtifactPins: map[string]ArtifactPin{currentPlatform(): {ExecutableSHA256: hash}}}
		if err = verifyArtifactPin(part, filepath.Join(stage, name), false); err != nil {
			return false, err
		}
	}
	// Verify the primary entry even for a component without extra checksums.
	if err = verifyArtifactPin(cfg, filepath.Join(stage, platformExecutable(cfg.BinaryName)), false); err != nil {
		return false, err
	}
	backup := dest + ".previous"
	if err = os.RemoveAll(backup); err != nil {
		return false, err
	}
	existed := false
	if _, err = os.Lstat(dest); err == nil {
		if err = os.Rename(dest, backup); err != nil {
			return false, err
		}
		existed = true
	} else if !os.IsNotExist(err) {
		return false, err
	}
	if err = os.Rename(stage, dest); err != nil {
		if existed {
			_ = os.Rename(backup, dest)
		}
		return false, err
	}
	_ = os.RemoveAll(backup)
	return false, nil
}
