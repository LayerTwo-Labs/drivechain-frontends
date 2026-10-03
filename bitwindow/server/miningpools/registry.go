package miningpools

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/rs/zerolog"
)

const (
	ttl          = time.Hour
	fetchTimeout = 5 * time.Second
	maxBodyBytes = 1 << 20

	drivechainRegistry = "https://pool.drivechain.info/networks/%s/pools.json"
	mempoolRegistry    = "https://raw.githubusercontent.com/mempool/mining-pools/master/pools-v2.json"

	// SourceBuiltIn names the seed compiled into the binary, served until
	// the first fetch succeeds.
	SourceBuiltIn = "built-in"
)

// betanetSeed is https://pool.drivechain.info/networks/betanet/pools.json
// as of 2026-09-20, so eCash attributes blocks before the first fetch.
const betanetSeed = `{
  "network": "betanet",
  "updated": "2026-09-20",
  "schema_version": 1,
  "pools": [
    {
      "name": "bip300.xyz",
      "operator": "bip300.xyz",
      "chain": "betanet",
      "mode": "pplns",
      "fee_bps": 100,
      "coinbase_tag": "/bip300xyz/",
      "stratum_url": "stratum+tcp://stratum.beta.bip300.xyz:3334",
      "dashboard_url": "https://pool.beta.bip300.xyz",
      "status_url": "https://pool.beta.bip300.xyz/api/status",
      "operator_address": "bc1qljvzxk0tp6qtrunt590z5rtdhs8jhkkn4ny4rm",
      "pool_btc_address": null,
      "payout": "The stratum username is your BTC address; the coinbase pays every miner in the PPLNS window directly, so the pool never holds funds.",
      "software": "simplepool",
      "logo": "mining-pool-logos/bip300xyz.svg",
      "contact": null
    },
    {
      "name": "eCPool.tech",
      "operator": "Wired4ncer",
      "chain": "betanet",
      "mode": "proportional",
      "fee_bps": 50,
      "coinbase_tag": "/ecpool.tech/",
      "stratum_url": "stratum+tcp://mining.ecpool.tech:3334",
      "dashboard_url": "https://ecpool.tech",
      "status_url": "https://ecpool.tech/api/pool/health",
      "operator_address": "bc1p8f2nswh6pa6aedye80wkak74z0g40gkfdds8wcsaznm550altd4qptz0dk",
      "pool_btc_address": null,
      "payout": "The stratum username is your address (bc1q or bc1p); the coinbase pays every miner in the PPLNS window directly, so the pool never holds funds. Port 3336 is solo mode, 3335 is for rented hashrate.",
      "software": "simplepool",
      "logo": "mining-pool-logos/ecpool.png",
      "contact": "https://t.me/+5ajPd2Q70Is0YzM0"
    },
    {
      "name": "ePool",
      "operator": "bitlewis",
      "chain": "betanet",
      "mode": "vibes",
      "fee_bps": 60,
      "coinbase_tag": "ePool",
      "stratum_url": "stratum+tcp://mine.ecash.epool.cash:3334",
      "dashboard_url": "https://ecash.epool.cash",
      "status_url": "https://ecash.epool.cash/api/pool",
      "operator_address": "bc1qr7x0rlf56rphwrzcqgl37rmh2zed6xxrmnpwuq",
      "pool_btc_address": "bc1qr7x0rlf56rphwrzcqgl37rmh2zed6xxrmnpwuq",
      "payout": "The stratum username is your BTC address; rewards are split proportionally across the VIBES window and paid directly in the block coinbase.",
      "software": "DATUM / Blocktfabric",
      "logo": "mining-pool-logos/ePool.png",
      "contact": "https://t.me/+don8J6skqi02OTZh"
    },
    {
      "name": "Pow.re",
      "operator": "Pow.re",
      "chain": "betanet",
      "mode": "solo",
      "fee_bps": 0,
      "coinbase_tag": "/powre/",
      "stratum_url": null,
      "dashboard_url": null,
      "status_url": null,
      "operator_address": "3HxectQ44ECnadiofJjPGRMukEEAkjWjFk",
      "pool_btc_address": null,
      "coinbase_addresses": [
        "3HxectQ44ECnadiofJjPGRMukEEAkjWjFk"
      ],
      "payout": "Pow.re's own fleet only, no outside hashrate. Solo mode: each block's coinbase pays Pow.re's address directly.",
      "software": "simplepool",
      "contact": "gabriel.hardy@pow.re"
    },
    {
      "name": "avonpool",
      "operator": "avonpool.xyz",
      "chain": "betanet",
      "mode": "solo",
      "fee_bps": 100,
      "coinbase_tag": "/avonpool/",
      "stratum_url": "stratum+tcp://pool.beta.avonpool.xyz:3334",
      "dashboard_url": "https://pool.beta.avonpool.xyz",
      "status_url": "https://pool.beta.avonpool.xyz/api/status",
      "operator_address": "bc1qljvzxk0tp6qtrunt590z5rtdhs8jhkkn4ny4rm",
      "pool_btc_address": null,
      "payout": "The stratum username is your own BTC address (bc1q, 1 or 3 — not taproot); solo mode pays the finder's address directly in that block's coinbase, minus the 1% operator fee.",
      "software": "simplepool",
      "logo": "mining-pool-logos/avonpool.svg",
      "contact": null
    }
  ]
}`

// seedFor is the list a network starts from, nil when it starts empty.
func seedFor(network config.Network, ecashID string) []Pool {
	if network != config.NetworkECash || ecashID != "betanet" {
		return nil
	}
	pools, err := ParseRegistry([]byte(betanetSeed))
	if err != nil {
		panic(fmt.Sprintf("miningpools: betanet seed is invalid: %v", err))
	}
	return pools
}

// Fetch downloads a registry document.
type Fetch func(ctx context.Context, url string) ([]byte, error)

// DefaultFetch is a plain HTTP GET with a short timeout and a size cap. A
// file:// URL is read from disk.
func DefaultFetch(ctx context.Context, url string) ([]byte, error) {
	if path, ok := strings.CutPrefix(url, "file://"); ok {
		return os.ReadFile(path)
	}
	ctx, cancel := context.WithTimeout(ctx, fetchTimeout)
	defer cancel()

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return nil, fmt.Errorf("build registry request: %w", err)
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("fetch registry: %w", err)
	}
	defer resp.Body.Close() //nolint:errcheck // read-only body

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("fetch registry: unexpected status %s", resp.Status)
	}
	body, err := io.ReadAll(io.LimitReader(resp.Body, maxBodyBytes))
	if err != nil {
		return nil, fmt.Errorf("read registry body: %w", err)
	}
	return body, nil
}

// RegtestFile is the registry a regtest datadir may carry, for a local stack
// that plays several pools.
const RegtestFile = "mining-pools.json"

// source is where a network's registry lives and how to read it.
func source(network config.Network, ecashID, datadir string) (string, Parse) {
	switch network {
	case config.NetworkECash:
		if ecashID == "" {
			return "", nil
		}
		return fmt.Sprintf(drivechainRegistry, ecashID), ParseRegistry
	case config.NetworkMainnet:
		return mempoolRegistry, ParseMempool
	case config.NetworkRegtest:
		path := filepath.Join(datadir, RegtestFile)
		if datadir == "" {
			return "", nil
		}
		if _, err := os.Stat(path); err != nil {
			return "", nil
		}
		return "file://" + path, ParseRegistry
	case config.NetworkSignet, config.NetworkTestnet:
		return "", nil
	}
	return "", nil
}

// Registry serves a network's pool list. It starts from the built-in
// seed, if any, and refreshes from the network in the background on a TTL, so no
// caller ever waits on a fetch; a failed refresh keeps the last good list.
type Registry struct {
	url   string
	parse Parse
	fetch Fetch
	log   zerolog.Logger

	mu         sync.Mutex
	pools      []Pool
	source     string
	expires    time.Time
	refreshing bool
}

// Resolved is a pool list with where it came from.
type Resolved struct {
	Pools     []Pool
	Source    string
	Available bool
}

// New serves the registry of a network. A nil fetch uses DefaultFetch.
func New(ctx context.Context, network config.Network, ecashID, datadir string, fetch Fetch) *Registry {
	if fetch == nil {
		fetch = DefaultFetch
	}
	url, parse := source(network, ecashID, datadir)
	r := &Registry{
		url:   url,
		parse: parse,
		fetch: fetch,
		log:   zerolog.Ctx(ctx).With().Str("registry", url).Logger(),
		pools: seedFor(network, ecashID),
	}
	if len(r.pools) > 0 {
		r.source = SourceBuiltIn
	}
	if r.url != "" {
		r.startRefresh()
	}
	return r
}

// Available reports whether the network has a registry at all.
func (r *Registry) Available() bool {
	return r != nil && r.url != ""
}

// Pools returns the current list at once and, past the TTL, refreshes it in
// the background for later calls.
func (r *Registry) Pools() Resolved {
	if !r.Available() {
		return Resolved{}
	}
	r.mu.Lock()
	defer r.mu.Unlock()

	if !r.refreshing && !time.Now().Before(r.expires) {
		r.startRefresh()
	}
	return Resolved{Pools: r.pools, Source: r.source, Available: true}
}

// startRefresh needs the lock held, or a Registry no one else sees yet.
func (r *Registry) startRefresh() {
	r.refreshing = true
	r.expires = time.Now().Add(ttl)
	go r.refresh()
}

func (r *Registry) refresh() {
	pools, err := r.read()
	r.mu.Lock()
	defer r.mu.Unlock()
	r.refreshing = false
	if err != nil {
		r.log.Warn().Err(err).Str("source", r.source).Msg("refresh mining pool registry: keep the last list")
		return
	}
	r.pools, r.source = pools, r.url
}

func (r *Registry) read() ([]Pool, error) {
	body, err := r.fetch(context.Background(), r.url)
	if err != nil {
		return nil, err
	}
	return r.parse(body)
}
