package lightwallet

import (
	"fmt"
	"sync"

	"connectrpc.com/connect"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/sidechainesplora"
)

// AddressWindow is how many addresses a light wallet can derive. Gap discovery
// decides how many of them it reads, so this is only the ceiling: a wallet that
// ran a node first may sit well past the first few keys.
const AddressWindow = 500

// Mode is how one request reads the chain.
type Mode struct {
	// IndexURL names the Esplora index to read. An empty URL reads the node.
	IndexURL string
	// LocalNode says whether a sidechain node runs on this host. Light mode
	// runs none, so the wallet derives its own addresses.
	LocalNode bool
}

// NewMode decides how one request reads the chain.
//
// A light install reads a hosted index and runs no node. A network with no
// index cannot serve light mode, so the node answers everything there.
func NewMode(light bool, indexURL string) Mode {
	return Mode{IndexURL: indexURL, LocalNode: !light || indexURL == ""}
}

// ModeFunc resolves the mode. It runs once per request, because a network swap
// or a wallet mode change moves the answer while the process runs.
type ModeFunc func() Mode

// Chain names everything one sidechain needs to read its wallet from an index.
type Chain struct {
	// Seed answers with the BIP39 seed the wallet derives its keys from.
	Seed Seed
	// Derive answers the address one seed holds at one index.
	Derive Deriver
	// Output is how this chain writes a wallet output.
	Output OutputShape
}

// Wallet is the light half of a sidechain handler. It hands out the backend
// the current mode names, and it rebuilds that backend when the index moves,
// because another index names another chain.
type Wallet struct {
	mode  ModeFunc
	chain Chain

	mu      sync.Mutex
	url     string
	backend *Backend
}

// NewWallet reads one chain through whatever index the mode names.
func NewWallet(mode ModeFunc, chain Chain) *Wallet {
	return &Wallet{mode: mode, chain: chain}
}

// ReadsIndex reports whether this chain reads a remote index right now. A
// light install starts no daemon for a chain that answers false.
func (w *Wallet) ReadsIndex() bool {
	return w != nil && w.Backend() != nil
}

// CanSpend reports whether the wallet can sign a spend right now. A local node
// signs, and this package reads an index and holds no spend path.
func (w *Wallet) CanSpend() bool {
	return w == nil || w.Backend() == nil
}

// SpendUnsupported is the refusal a chain gives for a spend it cannot sign.
// The code names a capability the backend lacks, so a caller never reads it as
// a dead node.
func SpendUnsupported(chain, action string) error {
	return connect.NewError(connect.CodeUnimplemented, fmt.Errorf(
		"%s reads a remote index in light mode, so it cannot %s yet", chain, action))
}

// Backend answers the light wallet, or nil when a local node answers instead.
func (w *Wallet) Backend() *Backend {
	if w == nil || w.chain.Seed == nil {
		return nil
	}
	mode := w.mode()
	if mode.LocalNode || mode.IndexURL == "" {
		// A local node issues and funds addresses while it runs. The wallet
		// that comes back to the index must walk its whole window again, or it
		// reads none of what the node did.
		w.drop()
		return nil
	}

	w.mu.Lock()
	defer w.mu.Unlock()
	if w.backend == nil || w.url != mode.IndexURL {
		w.url = mode.IndexURL
		w.backend = NewBackend(
			sidechainesplora.New(mode.IndexURL),
			NewWindow(w.chain.Seed, w.chain.Derive, AddressWindow),
			w.chain.Output,
		)
	}
	return w.backend
}

// drop forgets the backend, so the next light request builds a new one.
func (w *Wallet) drop() {
	w.mu.Lock()
	defer w.mu.Unlock()
	w.backend = nil
	w.url = ""
}
