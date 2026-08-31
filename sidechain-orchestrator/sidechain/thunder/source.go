package thunder

import (
	"context"
	"sync"

	"github.com/btcsuite/btcd/chaincfg"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/sidechainesplora"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/thunderwallet"
)

// HistorySource lists the transactions that touched a set of addresses. A
// thunder node keeps no address history, so one implementation reads the
// node's own coins and another reads an Esplora index.
//
// The wallet mode picks the implementation. Everything above this seam runs
// the same code either way.
type HistorySource interface {
	History(ctx context.Context, addresses []string) ([]sidechainesplora.Entry, error)
	// TipHeight is the height the history was read at. A caller counts
	// confirmations from it, so it comes from the same source as the history.
	TipHeight(ctx context.Context) (uint32, error)
}

// AddressSource lists the wallet addresses to read the history of. A node
// answers from its own wallet, and a light wallet derives them from the seed,
// because light mode runs no node to ask.
type AddressSource interface {
	Addresses(ctx context.Context) ([]string, error)
}

// LightKeys is the wallet a light mode owns. It names the addresses to watch,
// and holds the keys that sign what those addresses spend.
type LightKeys interface {
	AddressSource
	Keyring() (*thunderwallet.MemoryKeyring, error)
}

// Mode is how one request reads the chain.
type Mode struct {
	// IndexURL names the Esplora index to read. An empty URL reads the node.
	IndexURL string
	// LocalNode says whether a thunder node runs on this host. Light mode runs
	// none, so the wallet derives its own addresses.
	LocalNode bool
	// Params name the mainchain a withdrawal address belongs to. They travel
	// with the mode, so one read keeps the payout script and the index it goes
	// to on one network.
	Params *chaincfg.Params
}

// NewMode decides how one request reads the chain.
//
// A light install reads a hosted index and runs no node. A network with no
// index cannot serve light mode, so the node answers everything there. A full
// install that names an index keeps its node, and reads only history through
// the index.
func NewMode(light bool, indexURL string, params *chaincfg.Params) Mode {
	return Mode{
		IndexURL:  indexURL,
		LocalNode: !light || indexURL == "",
		Params:    params,
	}
}

// ModeFunc resolves the mode. It runs once per request, because a network swap
// or a wallet mode change moves the answer while the process runs.
type ModeFunc func() Mode

// sources picks the history and the address source one mode names. A request
// resolves the mode one time, so both sources describe one wallet on one
// network.
type sources struct {
	nodeHistory   HistorySource
	nodeAddresses AddressSource
	nodeBackend   WalletBackend
	derived       LightKeys

	mu          sync.Mutex
	cached      string
	index       *sidechainesplora.Wallet
	light       WalletBackend
	lightKeys   *thunderwallet.MemoryKeyring
	lightParams *chaincfg.Params
	discovered  *discoveredAddresses
}

func newSources(
	history HistorySource, addresses AddressSource, backend WalletBackend,
	derived LightKeys,
) *sources {
	return &sources{
		nodeHistory:   history,
		nodeAddresses: addresses,
		nodeBackend:   backend,
		derived:       derived,
	}
}

// History answers from the index the mode names, and from the node otherwise.
func (s *sources) History(mode Mode) HistorySource {
	if index := s.indexFor(mode.IndexURL); index != nil {
		return index
	}
	return s.nodeHistory
}

// Addresses derives the addresses when no node runs, because there is then
// nothing to ask. A node that runs holds the wallet, so it answers.
func (s *sources) Addresses(mode Mode) AddressSource {
	if mode.LocalNode || s.derived == nil || mode.IndexURL == "" {
		return s.nodeAddresses
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	s.indexLocked(mode.IndexURL)
	return s.discovered
}

// Backend runs the wallet in this process when no node runs, and inside the
// node when one does.
func (s *sources) Backend(ctx context.Context, mode Mode) (WalletBackend, error) {
	if mode.LocalNode || s.derived == nil || mode.IndexURL == "" {
		return s.nodeBackend, nil
	}
	keys, err := s.derived.Keyring()
	if err != nil {
		return nil, err
	}

	s.mu.Lock()
	defer s.mu.Unlock()
	s.indexLocked(mode.IndexURL)
	// A wallet restore hands back a new keyring under the same URL. Keying on
	// the URL alone would keep signing with the wallet that came before.
	if s.light == nil || s.lightKeys != keys || s.lightParams != mode.Params {
		s.lightKeys = keys
		s.lightParams = mode.Params
		if s.discovered != nil {
			s.discovered.Forget()
		}
		s.light = newLightBackend(keys, s.discovered, s.index.Client(), mode.Params)
	}
	return s.light, nil
}

// indexFor returns the index client for a URL. An empty URL means the node
// answers instead.
func (s *sources) indexFor(url string) HistorySource {
	if url == "" {
		return nil
	}
	s.mu.Lock()
	defer s.mu.Unlock()
	s.indexLocked(url)
	return s.index
}

// indexLocked builds the index and everything that reads through it, and
// rebuilds them whenever the URL changes. The caller holds the lock.
func (s *sources) indexLocked(url string) {
	if s.index != nil && s.cached == url {
		return
	}
	s.cached = url
	s.index = sidechainesplora.NewWallet(sidechainesplora.New(url))
	s.light = nil
	s.lightKeys = nil
	s.discovered = nil
	if s.derived != nil {
		s.discovered = newDiscoveredAddresses(s.derived, s.index.Client())
	}
}

var _ HistorySource = (*sidechainesplora.Wallet)(nil)
