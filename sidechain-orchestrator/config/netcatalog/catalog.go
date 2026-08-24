// Package netcatalog resolves the network catalog published at
// https://drivechain.dev/config: the per-network service endpoints, explorer
// URL templates and — for the eCash family — the live network id ("alphanet",
// "drynet4", ...). Standing up a new eCash network is therefore a release
// artifact plus an entry in that document, with no code change here.
package netcatalog

import (
	"bytes"
	"context"
	_ "embed"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"sort"
	"time"
)

// DefaultURL is the published catalog document.
const DefaultURL = "https://drivechain.dev/config"

// FamilyECash is the family key for the eCash series. Lookups use the family
// rather than the id, because the id is free-form and changes with every new
// eCash network.
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

	// ForkHeight is the height the eCash fork activates at. Published so a new
	// eCash network, and the real fork, roll over without a code change.
	ForkHeight int `json:"fork_height"`

	// P2P is the seed node bitcoind connects through. Every eCash network
	// publishes its own address and port.
	P2P struct {
		Address string `json:"address"`
	} `json:"p2p"`

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

	// AssumeUTXO is the published UTXO snapshot for this network, or nil when it
	// has none. URL points straight at the .dat file.
	AssumeUTXO *AssumeUTXO `json:"assumeutxo"`
}

// AssumeUTXO describes a network's published UTXO snapshot.
type AssumeUTXO struct {
	URL       string `json:"url"`
	Height    int64  `json:"height"`
	SHA256    string `json:"sha256"`
	SizeBytes int64  `json:"size_bytes"`
}

// Backend kinds a network can publish. Fulcrum and electrum both speak the
// Electrum wire protocol; esplora is the REST API.
const (
	KindFulcrum  = "fulcrum"
	KindElectrum = "electrum"
	KindEsplora  = "esplora"
)

// kindRank orders the backend kinds the wallet reads from, best first. Fulcrum
// indexes the whole chain and pushes updates, so it beats a partial Electrum
// server, which in turn beats polling an Esplora REST API. An unpublished kind
// ranks last.
var kindRank = map[string]int{
	KindFulcrum:  0,
	KindElectrum: 1,
	KindEsplora:  2,
}

func rankOf(kind string) int {
	if r, ok := kindRank[kind]; ok {
		return r
	}
	return len(kindRank)
}

// Backend is one endpoint a network can be read from. Kind is "fulcrum",
// "electrum" or "esplora"; lower Priority wins.
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

// ByID returns the network with the given id, and whether one was found.
func (c Catalog) ByID(id string) (Network, bool) {
	for _, n := range c.Networks {
		if n.ID == id {
			return n, true
		}
	}
	return Network{}, false
}

// ForNetwork returns the catalog entry for a running network name. eCash
// resolves by family because its id is free-form.
func (c Catalog) ForNetwork(network string) (Network, bool) {
	switch network {
	case "ecash":
		return c.CurrentECash()
	case "mainnet":
		return c.ByID("bitcoin")
	case "signet", "forknet":
		return c.ByID(network)
	default:
		return Network{}, false
	}
}

// CurrentECash returns the live eCash network. The document lists it first and
// any retired ones after it, so document order — not the id — decides.
func (c Catalog) CurrentECash() (Network, bool) {
	return c.ByFamily(FamilyECash)
}

// SameAs reports whether two catalogs carry the same document. The picker and
// the endpoints read every entry, so an id-only compare would drop a refresh
// that adds a network or moves a host.
func (c Catalog) SameAs(other Catalog) bool {
	if c.SchemaVersion != other.SchemaVersion || len(c.Networks) != len(other.Networks) {
		return false
	}
	mine, err := json.Marshal(c)
	if err != nil {
		return false
	}
	theirs, err := json.Marshal(other)
	if err != nil {
		return false
	}
	return bytes.Equal(mine, theirs)
}

// NewIDs returns the ids this catalog lists that prev does not, in document
// order. A refresh uses it to tell the user which networks appeared.
func (c Catalog) NewIDs(prev Catalog) []string {
	known := make(map[string]bool, len(prev.Networks))
	for _, n := range prev.Networks {
		known[n.ID] = true
	}
	var fresh []string
	for _, n := range c.Networks {
		if !known[n.ID] {
			fresh = append(fresh, n.ID)
		}
	}
	return fresh
}

// ECashID returns the live eCash network id (e.g. "alphanet"), or "" when the
// catalog carries no eCash entry.
func (c Catalog) ECashID() string {
	n, ok := c.CurrentECash()
	if !ok {
		return ""
	}
	return n.ID
}

// ExplorerHost returns the host of the explorer this network publishes, or ""
// when it publishes none.
func (n Network) ExplorerHost() string {
	u, err := url.Parse(n.ExplorerTxTemplate)
	if err != nil {
		return ""
	}
	return u.Host
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

// ElectrumURL returns the highest-priority Electrum-protocol URL, fulcrum
// first, or "" when the network publishes neither.
func (n Network) ElectrumURL() string {
	if url := n.BackendURL(KindFulcrum); url != "" {
		return url
	}
	return n.BackendURL(KindElectrum)
}

// ChainSourceURLs returns every backend URL the wallet can read, best first:
// by kind rank, then by published priority, then in document order. The wallet
// reads the first that answers and drops to the next on a failure.
func (n Network) ChainSourceURLs() []string {
	ordered := make([]Backend, 0, len(n.Backends))
	for _, b := range n.Backends {
		if b.URL == "" || rankOf(b.Kind) == len(kindRank) {
			continue
		}
		ordered = append(ordered, b)
	}
	sort.SliceStable(ordered, func(i, j int) bool {
		if ri, rj := rankOf(ordered[i].Kind), rankOf(ordered[j].Kind); ri != rj {
			return ri < rj
		}
		return ordered[i].Priority < ordered[j].Priority
	})
	urls := make([]string, 0, len(ordered))
	for _, b := range ordered {
		urls = append(urls, b.URL)
	}
	return urls
}

// Embedded is the catalog compiled into the binary. It is what every reader
// falls back to when the published document cannot be fetched.
func Embedded() Catalog {
	// The embedded copy is compiled in and always parses; a failure here is a
	// build problem, not a runtime one.
	parsed, err := parse(embedded)
	if err != nil {
		panic(fmt.Sprintf("netcatalog: embedded networks.json is invalid: %v", err))
	}
	return parsed
}

// Resolve returns the published document, or the embedded copy when the fetch
// fails. The catalog is a document rather than state, so no process keeps a
// copy of it on disk.
func Resolve(ctx context.Context) Catalog {
	c, err := Fetch(ctx, DefaultURL)
	if err != nil {
		return Embedded()
	}
	return c
}

// RemoveLegacyFiles deletes the catalog copies an older build kept in the data
// directory. That build served a cached document, and held a refresh back in a
// second file until a start applied it.
func RemoveLegacyFiles(bitwindowDir string) {
	for _, name := range []string{cacheFilename, pendingFilename} {
		_ = os.Remove(filepath.Join(bitwindowDir, name))
	}
}

// EmbeddedECashID is the eCash network id compiled into the binary. It is the
// fallback for code that needs an id before the catalog has been resolved from
// disk or the network — notably the first-boot bitcoin.conf.
func EmbeddedECashID() string {
	return EmbeddedECash().ID
}

// EmbeddedECash is the eCash entry compiled into the binary, zero when it
// carries none. Endpoint helpers fall back to it before the catalog resolves.
func EmbeddedECash() Network {
	n, _ := Embedded().CurrentECash()
	return n
}

// EmbeddedPeer is the seed address the compiled-in catalog publishes for a
// network id, empty when it lists none.
func EmbeddedPeer(id string) string {
	n, ok := Embedded().ByID(id)
	if !ok {
		return ""
	}
	return n.P2P.Address
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
