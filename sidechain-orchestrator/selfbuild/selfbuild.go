// Package selfbuild tells whether this process runs a given executable file.
package selfbuild

import (
	"context"
	"errors"
	"fmt"
	"io"
	"io/fs"
	"net/http"
	"net/url"
	"os"
	"strings"
)

// RunsPath is the HTTP path of [Handler].
const RunsPath = "/build/runs"

var (
	startPath string
	startInfo os.FileInfo
	startErr  error
)

// The file can change after the start, so the stat runs before any other code.
func init() {
	startPath, startErr = os.Executable()
	if startErr == nil {
		startInfo, startErr = os.Stat(startPath)
	}
}

// Path is the executable this process started from.
func Path() (string, error) {
	return startPath, startErr
}

// Runs reports whether this process runs the file at path, unchanged since the process started.
func Runs(path string) (bool, error) {
	if startErr != nil {
		return false, startErr
	}
	info, err := os.Stat(path)
	if errors.Is(err, fs.ErrNotExist) {
		return false, nil
	}
	if err != nil {
		return false, err
	}
	return os.SameFile(startInfo, info) && info.Size() == startInfo.Size() && info.ModTime().Equal(startInfo.ModTime()), nil
}

// Handler answers GET ?path=<file> with "yes" when [Runs] is true, else "no".
func Handler() http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
			return
		}
		path := r.URL.Query().Get("path")
		if path == "" {
			http.Error(w, "path missing", http.StatusBadRequest)
			return
		}
		runs, err := Runs(path)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		if runs {
			_, _ = w.Write([]byte("yes"))
			return
		}
		_, _ = w.Write([]byte("no"))
	})
}

// Ask reports whether the daemon at baseURL runs the file at path. A daemon
// with no [Handler] is an older build, so it does not run the file.
func Ask(ctx context.Context, baseURL, path string) (bool, error) {
	u, err := url.Parse(strings.TrimSuffix(baseURL, "/") + RunsPath)
	if err != nil {
		return false, fmt.Errorf("parse %q: %w", baseURL, err)
	}
	u.RawQuery = url.Values{"path": {path}}.Encode()
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, u.String(), nil)
	if err != nil {
		return false, err
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return false, fmt.Errorf("ask %s: %w", u.Host, err)
	}
	defer func() { _ = resp.Body.Close() }()
	body, err := io.ReadAll(io.LimitReader(resp.Body, 256))
	if err != nil {
		return false, fmt.Errorf("read the answer of %s: %w", u.Host, err)
	}
	switch {
	case resp.StatusCode == http.StatusNotFound:
		return false, nil
	case resp.StatusCode != http.StatusOK:
		return false, fmt.Errorf("%s answered %s: %s", u.Host, resp.Status, strings.TrimSpace(string(body)))
	}
	return string(body) == "yes", nil
}
