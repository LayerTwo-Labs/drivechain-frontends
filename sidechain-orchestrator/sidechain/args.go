package sidechain

import "context"

// Host is what a sidechain reads from the orchestrator before its node starts.
// Args takes one, so a chain states its own command line and the orchestrator
// holds no rule about any single chain.
type Host interface {
	// BackendOnly reports whether the orchestrator starts the bare node. When
	// it is false the orchestrator starts the chain's frontend build, which
	// draws a window of its own.
	BackendOnly() bool

	// MainchainREST is the host:port the mainchain serves REST on, empty when
	// the mainchain config failed to load.
	MainchainREST() string

	// ForkHeight is the height the network's fork activates at, 0 when the
	// network publishes none.
	ForkHeight() int

	// MainchainBlockHash returns the hash of the mainchain block at a height.
	MainchainBlockHash(ctx context.Context, height int) (string, error)

	// ToolPath is where the orchestrator downloaded a helper binary, empty
	// when it holds none.
	ToolPath(name string) string
}
