// Package netcatalog resolves the network catalog published at
// https://drivechain.dev/config: the per-network service endpoints, explorer
// URL templates and — for the eCash family — the live drynet generation id
// ("drynet2", "drynet3", ...). Standing up a new drynet is therefore a release
// artifact plus an entry in that document, with no code change here.
package netcatalog

import (
	"context"
	_ "embed"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"time"
)

// DefaultURL is the published catalog document.
const DefaultURL = "https://drivechain.dev/config"

// FamilyECash is the family key for the drynet series. Lookups use the family
// rather than the id, because the id carries the generation number and so
// changes with every new drynet.
const FamilyECash = "ecash"

const (
	cacheFilename   = "networks_cache.json"
	pendingFilename = "networks_pending.json"
	fetchTimeout    = 5 * time.Second
	maxBodyBytes    = 1 << 20
)

//go:embed networks.json
var embedded []byte

// Catalog is the parsed catalog document.
type Catalog struct {
	SchemaVersion int       `json:"schema_version"`
	Networks      []Network `json:"networks"`
}

// Network is one entry of the catalog.
type Network struct {
	ID          string `json:"id"`
	Family      string `json:"family"`
	DisplayName string `json:"display_name"`
	Description string `json:"description"`
	Chain       string `json:"chain"`

	Currency struct {
		Name   string `json:"name"`
		Ticker string `json:"ticker"`
	} `json:"currency"`

	Backends []Backend `json:"backends"`

	ExplorerTxTemplate      string `json:"explorer_tx_template"`
	ExplorerAddressTemplate string `json:"explorer_address_template"`
	ExplorerBlockTemplate   string `json:"explorer_block_template"`

	Services struct {
		Faucet struct {
			URL             *string `json:"url"`
			Amount          *int    `json:"amount"`
			CooldownSeconds *int    `json:"cooldown_seconds"`
		} `json:"faucet"`
		CoinNews struct {
			URL string `json:"url"`
		} `json:"coinnews"`
	} `json:"services"`
}

// Backend is one endpoint a network can be read from. Kind is "esplora" or
// "electrum"; lower Priority wins.
type Backend struct {
	Kind     string `json:"kind"`
	URL      string `json:"url"`
	Priority int    `json:"priority"`
	TLS      bool   `json:"tls"`
	Label    string `json:"label"`
}

// ByFamily returns the network for a family, and whether one was found.
func (c Catalog) ByFamily(family string) (Network, bool) {
	for _, n := range c.Networks {
		if n.Family == family {
			return n, true
		}
	}
	return Network{}, false
}

// DrynetID returns the live drynet generation id (e.g. "drynet2"), or "" when
// the catalog carries no eCash entry.
func (c Catalog) DrynetID() string {
	n, ok := c.ByFamily(FamilyECash)
	if !ok {
		return ""
	}
	return n.ID
}

// BackendURL returns the highest-priority URL of the given kind, or "".
func (n Network) BackendURL(kind string) string {
	best := Backend{Priority: int(^uint(0) >> 1)}
	found := false
	for _, b := range n.Backends {
		if b.Kind == kind && b.Priority < best.Priority {
			best, found = b, true
		}
	}
	if !found {
		return ""
	}
	return best.URL
}

// CachePath is where the last known good catalog is persisted.
func CachePath(bitwindowDir string) string {
	return filepath.Join(bitwindowDir, cacheFilename)
}

// Load returns the catalog persisted by a previous run. fromDisk is false when
// no usable cache exists, in which case the embedded copy is returned — that
// distinction matters to callers comparing generations, since only a cache
// written by a previous run describes the state actually on disk.
func Load(bitwindowDir string) (c Catalog, fromDisk bool) {
	if raw, err := os.ReadFile(CachePath(bitwindowDir)); err == nil {
		if parsed, err := parse(raw); err == nil {
			return parsed, true
		}
	}
	// The embedded copy is compiled in and always parses; a failure here is a
	// build problem, not a runtime one.
	parsed, err := parse(embedded)
	if err != nil {
		panic(fmt.Sprintf("netcatalog: embedded networks.json is invalid: %v", err))
	}
	return parsed, false
}

// EmbeddedDrynetID is the drynet generation compiled into the binary. It is
// the fallback for code that needs a generation before the catalog has been
// resolved from disk or the network — notably the first-boot bitcoin.conf.
func EmbeddedDrynetID() string {
	c, err := parse(embedded)
	if err != nil {
		return ""
	}
	return c.DrynetID()
}

// Fetch downloads and parses the live catalog.
func Fetch(ctx context.Context, url string) (Catalog, error) {
	ctx, cancel := context.WithTimeout(ctx, fetchTimeout)
	defer cancel()

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return Catalog{}, fmt.Errorf("build catalog request: %w", err)
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return Catalog{}, fmt.Errorf("fetch catalog: %w", err)
	}
	defer resp.Body.Close() //nolint:errcheck // read-only body

	if resp.StatusCode != http.StatusOK {
		return Catalog{}, fmt.Errorf("fetch catalog: unexpected status %s", resp.Status)
	}
	body, err := io.ReadAll(io.LimitReader(resp.Body, maxBodyBytes))
	if err != nil {
		return Catalog{}, fmt.Errorf("read catalog body: %w", err)
	}
	return parse(body)
}

// Save persists a catalog as the baseline for the next run. The write is
// tmp-then-rename but deliberately skips fsync: this is a cache, and a torn
// write simply fails to parse on the next boot and falls back to the embedded
// copy.
func Save(bitwindowDir string, c Catalog) error {
	return writeCatalog(CachePath(bitwindowDir), bitwindowDir, c)
}

func writeCatalog(path, bitwindowDir string, c Catalog) error {
	if err := os.MkdirAll(bitwindowDir, 0o755); err != nil {
		return fmt.Errorf("mkdir bitwindow dir: %w", err)
	}
	data, err := json.MarshalIndent(c, "", "  ")
	if err != nil {
		return fmt.Errorf("marshal catalog: %w", err)
	}
	tmp := path + ".tmp"
	if err := os.WriteFile(tmp, data, 0o644); err != nil {
		return fmt.Errorf("write catalog cache: %w", err)
	}
	if err := os.Rename(tmp, path); err != nil {
		_ = os.Remove(tmp)
		return fmt.Errorf("rename catalog cache: %w", err)
	}
	return nil
}

// PendingPath is where a refreshed catalog waits to be applied.
func PendingPath(bitwindowDir string) string {
	return filepath.Join(bitwindowDir, pendingFilename)
}

// SavePending records a freshly fetched catalog for the next start to apply.
// The running process keeps serving whatever it loaded, so the cache — which
// must always describe the data on disk — is left alone until startup promotes
// this.
func SavePending(bitwindowDir string, c Catalog) error {
	return writeCatalog(PendingPath(bitwindowDir), bitwindowDir, c)
}

// LoadPending returns a catalog left by a previous run's refresh, if any.
func LoadPending(bitwindowDir string) (Catalog, bool) {
	raw, err := os.ReadFile(PendingPath(bitwindowDir))
	if err != nil {
		return Catalog{}, false
	}
	parsed, err := parse(raw)
	if err != nil {
		return Catalog{}, false
	}
	return parsed, true
}

// ClearPending removes a promoted or unusable pending catalog.
func ClearPending(bitwindowDir string) {
	_ = os.Remove(PendingPath(bitwindowDir))
}

// parse decodes a catalog document and rejects one that carries no networks or
// an unreadable schema, so a garbage response never displaces a good cache.
func parse(raw []byte) (Catalog, error) {
	var c Catalog
	if err := json.Unmarshal(raw, &c); err != nil {
		return Catalog{}, fmt.Errorf("parse catalog: %w", err)
	}
	if c.SchemaVersion == 0 {
		return Catalog{}, fmt.Errorf("parse catalog: missing schema_version")
	}
	if len(c.Networks) == 0 {
		return Catalog{}, fmt.Errorf("parse catalog: no networks")
	}
	for _, n := range c.Networks {
		if n.ID == "" || n.Family == "" {
			return Catalog{}, fmt.Errorf("parse catalog: network missing id or family")
		}
	}
	return c, nil
}
