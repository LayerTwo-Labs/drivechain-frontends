package engines

import (
	"context"
	"fmt"
	"sync"
	"time"

	"connectrpc.com/connect"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	orchrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
)

// nodeModeTTL keeps a per-tick gate off the orchestrator. Engines tick each
// second; the mode changes when the user picks a new one.
const nodeModeTTL = 5 * time.Second

// NodeMode answers one question for the whole server: does this install run a
// local Bitcoin node? Every backend-dependent engine and RPC reads it here.
type NodeMode struct {
	client orchrpc.WalletManagerServiceClient

	mu     sync.Mutex
	cached orchpb.NodeMode
	readAt time.Time
}

func NewNodeMode() *NodeMode {
	return &NodeMode{}
}

func (n *NodeMode) SetClient(client orchrpc.WalletManagerServiceClient) {
	n.mu.Lock()
	defer n.mu.Unlock()
	n.client = client
	n.cached = orchpb.NodeMode_NODE_MODE_UNSPECIFIED
	n.readAt = time.Time{}
}

// Mode reads the mode the user picked. Repeat calls inside the TTL get the
// cached answer.
func (n *NodeMode) Mode(ctx context.Context) (orchpb.NodeMode, error) {
	n.mu.Lock()
	client := n.client
	cached, readAt := n.cached, n.readAt
	n.mu.Unlock()

	if client == nil {
		return orchpb.NodeMode_NODE_MODE_UNSPECIFIED, fmt.Errorf("orchestrator wallet client not connected")
	}
	if !readAt.IsZero() && time.Since(readAt) < nodeModeTTL {
		return cached, nil
	}

	resp, err := client.GetNodeMode(ctx, connect.NewRequest(&orchpb.GetNodeModeRequest{}))
	if err != nil {
		return orchpb.NodeMode_NODE_MODE_UNSPECIFIED, err
	}

	n.mu.Lock()
	n.cached, n.readAt = resp.Msg.Mode, time.Now()
	n.mu.Unlock()
	return resp.Msg.Mode, nil
}

// hasClient reports whether this source can reach the orchestrator at all.
func (n *NodeMode) hasClient() bool {
	n.mu.Lock()
	defer n.mu.Unlock()
	return n.client != nil
}

// lastKnown gives the mode of the last successful read.
func (n *NodeMode) lastKnown() orchpb.NodeMode {
	n.mu.Lock()
	defer n.mu.Unlock()
	return n.cached
}

// RunsLocalNode reports whether a poller may talk to Bitcoin Core. Full mode
// is the only mode that runs one: light mode starts no daemon, and an unpicked
// mode starts nothing either while the welcome prompt waits for the user. An
// unreadable mode keeps the last known answer, and an engine with no source
// has no mode to obey.
func (n *NodeMode) RunsLocalNode(ctx context.Context) bool {
	if n == nil || !n.hasClient() {
		return true
	}
	mode, err := n.Mode(ctx)
	if err != nil {
		mode = n.lastKnown()
	}
	return mode == orchpb.NodeMode_NODE_MODE_FULL
}

// expire drops the cached mode, so the next read reaches the orchestrator.
func (n *NodeMode) expire() {
	n.mu.Lock()
	defer n.mu.Unlock()
	n.readAt = time.Time{}
}

// RequireFullNode refuses an operation that needs a local Bitcoin node or the
// BIP300/301 enforcer. Strict where RunsLocalNode is lenient: a caller that
// cannot read the mode gets an error, not a guess. It also reads fresh — a
// user who just picked full mode must not meet a cached refusal.
func (n *NodeMode) RequireFullNode(ctx context.Context, op string) error {
	n.expire()
	mode, err := n.Mode(ctx)
	if err != nil {
		return connect.NewError(connect.CodeUnavailable,
			fmt.Errorf("%s: could not read the node mode: %w", op, err))
	}
	if mode == orchpb.NodeMode_NODE_MODE_LIGHT {
		return connect.NewError(connect.CodeFailedPrecondition,
			fmt.Errorf("%s needs full mode, which runs a local Bitcoin node and the enforcer", op))
	}
	return nil
}
