package engines

import (
	"context"
	"encoding/json"
	"fmt"
	"net"
	"slices"
	"time"

	"github.com/rs/zerolog"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/rpc"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

// seedPeerTickInterval is how often the engine checks that each seeded chain
// still holds its seed peer.
const seedPeerTickInterval = 30 * time.Second

// SeededNode is a running sidechain node and the host:port of its seed peer.
type SeededNode struct {
	Name string
	Seed string
	Node sidechain.Node
}

// SeededNodes lists the running sidechain nodes that have a seed peer.
type SeededNodes interface {
	SeededNodes() ([]SeededNode, error)
}

// SeedPeerEngine dials the seed peer of each running sidechain that lost it.
// A node drops a peer it meets before its own mainchain sync ends, and
// --add-peer dials only once, at start.
type SeedPeerEngine struct {
	log     zerolog.Logger
	nodes   SeededNodes
	resolve func(ctx context.Context, host string) ([]string, error)
}

func NewSeedPeerEngine(log zerolog.Logger, nodes SeededNodes) *SeedPeerEngine {
	return &SeedPeerEngine{
		log:     log.With().Str("component", "seed-peer").Logger(),
		nodes:   nodes,
		resolve: net.DefaultResolver.LookupHost,
	}
}

func (e *SeedPeerEngine) Run(ctx context.Context) error {
	ticker := time.NewTicker(seedPeerTickInterval)
	defer ticker.Stop()

	e.log.Info().Dur("interval", seedPeerTickInterval).Msg("seed peer engine started")

	for {
		e.tick(ctx)
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-ticker.C:
		}
	}
}

func (e *SeedPeerEngine) tick(ctx context.Context) {
	seeded, err := e.nodes.SeededNodes()
	if err != nil {
		e.log.Warn().Err(err).Msg("could not list the seeded sidechains")
		return
	}
	for _, n := range seeded {
		dialed, err := e.keepSeed(ctx, n)
		if err != nil {
			e.log.Warn().Err(err).Str("sidechain", n.Name).Str("seed", n.Seed).Msg("could not keep the seed peer")
			continue
		}
		if dialed != "" {
			e.log.Info().Str("sidechain", n.Name).Str("peer", dialed).Msg("dialed the seed peer")
		}
	}
}

type sidechainPeer struct {
	Address string `json:"address"`
	Status  string `json:"status"`
}

// keepSeed returns the address it dialed, or an empty string when the node
// holds the seed or still syncs the mainchain.
func (e *SeedPeerEngine) keepSeed(ctx context.Context, n SeededNode) (string, error) {
	synced, err := mainchainSynced(ctx, n.Node)
	if err != nil {
		return "", err
	}
	if !synced {
		return "", nil
	}

	host, port, err := net.SplitHostPort(n.Seed)
	if err != nil {
		return "", fmt.Errorf("parse the seed %q: %w", n.Seed, err)
	}
	ips, err := e.resolve(ctx, host)
	if err != nil {
		return "", fmt.Errorf("resolve the seed: %w", err)
	}
	if len(ips) == 0 {
		return "", fmt.Errorf("the seed %s resolves to no address", host)
	}
	seedAddrs := make([]string, 0, len(ips))
	for _, ip := range ips {
		seedAddrs = append(seedAddrs, net.JoinHostPort(ip, port))
	}

	raw, err := n.Node.CallRaw(ctx, "list_peers", nil)
	if err != nil {
		return "", fmt.Errorf("list the peers: %w", err)
	}
	var peers []sidechainPeer
	if err := json.Unmarshal(raw, &peers); err != nil {
		return "", fmt.Errorf("decode the peers: %w", err)
	}
	for _, p := range peers {
		if slices.Contains(seedAddrs, p.Address) {
			return "", nil
		}
	}

	if _, err := n.Node.CallRaw(ctx, "connect_peer", []any{seedAddrs[0]}); err != nil {
		return "", fmt.Errorf("connect to %s: %w", seedAddrs[0], err)
	}
	return seedAddrs[0], nil
}

// mainchainSynced reports whether the node ended its mainchain sync. A node
// without mainchain_sync_progress reports no phase, so it counts as synced.
func mainchainSynced(ctx context.Context, node sidechain.Node) (bool, error) {
	raw, err := node.CallRaw(ctx, "mainchain_sync_progress", nil)
	if rpc.LacksMethod(err) {
		return true, nil
	}
	if err != nil {
		return false, fmt.Errorf("read the mainchain sync: %w", err)
	}
	var progress sidechain.MainchainSyncProgress
	if err := json.Unmarshal(raw, &progress); err != nil {
		return false, fmt.Errorf("decode the mainchain sync: %w", err)
	}
	return progress.Phase == sidechain.MainchainSyncIdle, nil
}
