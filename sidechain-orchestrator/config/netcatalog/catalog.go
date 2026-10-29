// Package netcatalog resolves the network catalog published at
// https://drivechain.dev/config: the per-network service endpoints, explorer
// URL templates and — for the eCash family — the live network id ("betanet",
// "ecash", ...). Standing up a new eCash network is therefore a release
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
	"regexp"
	"sort"
	"strings"
	"time"
)

// DefaultURL is the published catalog document.
const DefaultURL = "https://drivechain.dev/config"

// FamilyECash is the family key for the eCash series. Lookups use the family
// rather than the id, because the id is free-form and changes with every new
// eCash network.
const FamilyECash = "ecash"

// DefaultReplayLockTime is LOCKTIME_THRESHOLD - 1, the replay locktime of
// every eCash network that publishes no replay_lock_time.
const DefaultReplayLockTime uint32 = 499999999

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
	ID             string `json:"id"`
	Family         string `json:"family"`
	DisplayName    string `json:"display_name"`
	Description    string `json:"description"`
	Chain          string `json:"chain"`
	NetworkMagic   string `json:"network_magic,omitempty"`
	ForkParentHash string `json:"fork_parent_hash,omitempty"`

	Currency struct {
		Name   string `json:"name"`
		Ticker string `json:"ticker"`
	} `json:"currency"`

	// ForkHeight is the height the eCash fork activates at. Published so a new
	// eCash network, and the real fork, roll over without a code change.
	ForkHeight int `json:"fork_height"`

	// ReplayLockTime is the nLockTime this eCash network's node treats as
	// final. Zero means the field is absent; see ReplayLockTimeOrDefault.
	ReplayLockTime uint32 `json:"replay_lock_time,omitempty"`

	// ReleaseChannel is the path segment of the L1 release this eCash network
	// downloads. Only the compiled-in catalog sets it; see ReleaseChannelOrID.
	ReleaseChannel string `json:"release_channel,omitempty"`

	// MigrationOnly marks a network the app does not run. An install on it can
	// only migrate its chain to a newer eCash network.
	MigrationOnly bool `json:"migration_only,omitempty"`

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
		Enforcer Endpoints `json:"enforcer"`
		Faucet   struct {
			URL             *string `json:"url"`
			Amount          *int    `json:"amount"`
			CooldownSeconds *int    `json:"cooldown_seconds"`
		} `json:"faucet"`
		CoinNews struct {
			URL string `json:"url"`
		} `json:"coinnews"`
		MiningPool MiningPool `json:"mining_pool"`
	} `json:"services"`

	// AssumeUTXO is the published UTXO snapshot for this network, or nil when it
	// has none. URL points straight at the .dat file.
	AssumeUTXO *AssumeUTXO `json:"assumeutxo"`
}

// Endpoint is one published address of a service.
type Endpoint struct {
	URL string `json:"url"`
}

// Endpoints lists the published addresses of a service, preferred first.
type Endpoints []Endpoint

// URL returns the first address that is set, or an empty string.
func (e Endpoints) URL() string {
	for _, endpoint := range e {
		if endpoint.URL != "" {
			return endpoint.URL
		}
	}
	return ""
}

// UnmarshalJSON reads a list, or the single object that documents before
// 2026-10-29 carry.
func (e *Endpoints) UnmarshalJSON(raw []byte) error {
	if trimmed := bytes.TrimSpace(raw); len(trimmed) > 0 && trimmed[0] == '{' {
		var one struct {
			URL *string `json:"url"`
		}
		if err := json.Unmarshal(trimmed, &one); err != nil {
			return err
		}
		*e = nil
		if one.URL != nil {
			*e = Endpoints{{URL: *one.URL}}
		}
		return nil
	}
	var list []Endpoint
	if err := json.Unmarshal(raw, &list); err != nil {
		return err
	}
	*e = nil
	if len(list) > 0 {
		*e = list
	}
	return nil
}

// MiningPool is the Stratum pool a network publishes. Name, Fee and
// StatsURL are optional.
type MiningPool struct {
	URL     *string `json:"url"`
	Stratum *string `json:"stratum"`
	Name    string  `json:"name,omitempty"`
	Fee     string  `json:"fee,omitempty"`
	// StatsURL serves the pool overview JSON, with the pool hashrate.
	StatsURL string `json:"stats_url,omitempty"`
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
	case "signet":
		return c.ByID(network)
	default:
		return Network{}, false
	}
}

// CurrentECash returns the live eCash network. The document lists the eCash
// networks from oldest to newest, so the last one is live. Document order — not
// the id — decides.
func (c Catalog) CurrentECash() (Network, bool) {
	var live Network
	found := false
	for _, n := range c.Networks {
		if n.Family == FamilyECash {
			live, found = n, true
		}
	}
	return live, found
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

// ECashID returns the live eCash network id (e.g. "betanet"), or "" when the
// catalog carries no eCash entry.
func (c Catalog) ECashID() string {
	n, ok := c.CurrentECash()
	if !ok {
		return ""
	}
	return n.ID
}

// ReplayLockTimeOrDefault returns the network's replay locktime, or
// DefaultReplayLockTime when the entry carries none.
func (n Network) ReplayLockTimeOrDefault() uint32 {
	if n.ReplayLockTime == 0 {
		return DefaultReplayLockTime
	}
	return n.ReplayLockTime
}

// ReleaseChannelOrID returns the network's release channel, or its id when
// the entry carries none.
func (n Network) ReleaseChannelOrID() string {
	if n.ReleaseChannel == "" {
		return n.ID
	}
	return n.ReleaseChannel
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
	c, err := parse(body)
	if err != nil {
		return Catalog{}, err
	}
	return fillFromEmbedded(c, Embedded()), nil
}

// fillFromEmbedded gives an entry the fork parent hash and replay locktime that
// the compiled-in entry of the same id carries, where the document leaves them
// blank, and marks it migration-only when the app no longer runs it.
func fillFromEmbedded(c, from Catalog) Catalog {
	filled := make([]Network, len(c.Networks))
	copy(filled, c.Networks)
	for i, n := range filled {
		known, ok := from.ByID(n.ID)
		if !ok {
			continue
		}
		if n.ForkParentHash == "" {
			filled[i].ForkParentHash = known.ForkParentHash
		}
		if n.ReplayLockTime == 0 {
			filled[i].ReplayLockTime = known.ReplayLockTime
		}
		if known.MigrationOnly {
			filled[i].MigrationOnly = true
		}
	}
	c.Networks = filled
	return c
}

// The id becomes a directory name and a conf value, and the address a conf value.
var validNetworkID = regexp.MustCompile(`^[a-z0-9][a-z0-9-]{0,31}$`)

func unsafeConfRune(r rune) bool {
	return r <= 0x20 || r == 0x7f || r == '#' || r == ';' || r == '='
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
		if !validNetworkID.MatchString(n.ID) {
			return Catalog{}, fmt.Errorf("parse catalog: network id %q is not valid", n.ID)
		}
		if strings.ContainsFunc(n.P2P.Address, unsafeConfRune) {
			return Catalog{}, fmt.Errorf("parse catalog: network %q p2p address %q is not valid", n.ID, n.P2P.Address)
		}
	}
	return c, nil
}

// ByMagic returns the network whose blocks carry this magic, and whether one
// does. The blocks name the chain on disk, so a datadir tells the app which
// network it holds.
func (c Catalog) ByMagic(magic string) (Network, bool) {
	if magic == "" {
		return Network{}, false
	}
	for _, n := range c.Networks {
		if n.NetworkMagic != "" && strings.EqualFold(n.NetworkMagic, magic) {
			return n, true
		}
	}
	return Network{}, false
}
