package api

import (
	"context"
	"sync"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/wrapperspb"

	commonv1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/common/v1"
	enforcerpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/explorer/v1"
)

// blockCacheSize bounds both caches. A block body never changes, so the walk
// for the newest rows reads each block one time.
const blockCacheSize = 8192

// blockCache holds what one sidechain block carried.
type blockCache struct {
	mu    sync.Mutex
	rows  map[string]cachedBlock
	order []string
}

type cachedBlock struct {
	block    *pb.Block
	activity []*pb.Activity
	// ownHeight is true when the node named the height itself. A node that
	// names none takes the walk's height, and that one is not cacheable.
	ownHeight bool
}

func newBlockCache() *blockCache {
	return &blockCache{rows: map[string]cachedBlock{}}
}

// get answers a copy, so a caller can stamp a row without touching the cache.
// It answers false for ownHeight when the caller must stamp the height too.
func (c *blockCache) get(key string) (*pb.Block, []*pb.Activity, bool, bool) {
	if c == nil {
		return nil, nil, false, false
	}
	c.mu.Lock()
	defer c.mu.Unlock()
	held, ok := c.rows[key]
	if !ok {
		return nil, nil, false, false
	}
	block, rows := copyBlock(held)
	return block, rows, held.ownHeight, true
}

// put stores a copy and answers another one. A caller keeps writing to the
// block it gave, so the cache never holds that one.
func (c *blockCache) put(
	key string, block *pb.Block, activity []*pb.Activity, ownHeight bool,
) (*pb.Block, []*pb.Activity) {
	if c == nil {
		return block, activity
	}
	held, rows := copyBlock(cachedBlock{block: block, activity: activity})
	c.mu.Lock()
	defer c.mu.Unlock()
	if _, ok := c.rows[key]; !ok {
		c.order = append(c.order, key)
		for len(c.order) > blockCacheSize {
			delete(c.rows, c.order[0])
			c.order = c.order[1:]
		}
	}
	c.rows[key] = cachedBlock{block: held, activity: rows, ownHeight: ownHeight}
	return copyBlock(c.rows[key])
}

func copyBlock(held cachedBlock) (*pb.Block, []*pb.Activity) {
	rows := make([]*pb.Activity, 0, len(held.activity))
	for _, row := range held.activity {
		rows = append(rows, proto.Clone(row).(*pb.Activity))
	}
	return proto.Clone(held.block).(*pb.Block), rows
}

// mainchainAnchor is what the mainchain says about one sidechain header.
type mainchainAnchor struct {
	// parentHeight is the block the header names, which a bid was built on.
	parentHeight uint32
	// minedAt is the time of the block after that one. A miner takes the M8
	// there, so that is when the sidechain block connected.
	minedAt int64
}

// mainchainCache holds those, because a mainchain header never changes.
type mainchainCache struct {
	mu    sync.Mutex
	rows  map[string]mainchainAnchor
	order []string
}

func newMainchainCache() *mainchainCache {
	return &mainchainCache{rows: map[string]mainchainAnchor{}}
}

func (c *mainchainCache) get(hash string) (mainchainAnchor, bool) {
	if c == nil {
		return mainchainAnchor{}, false
	}
	c.mu.Lock()
	defer c.mu.Unlock()
	held, ok := c.rows[hash]
	return held, ok
}

func (c *mainchainCache) put(hash string, held mainchainAnchor) {
	if c == nil {
		return
	}
	c.mu.Lock()
	defer c.mu.Unlock()
	if _, ok := c.rows[hash]; !ok {
		c.order = append(c.order, hash)
		for len(c.order) > blockCacheSize {
			delete(c.rows, c.order[0])
			c.order = c.order[1:]
		}
	}
	c.rows[hash] = held
}

// anchorFor names the mainchain block a sidechain header points at, and the
// time the block after it connected the sidechain block. A sidechain header
// carries no clock of its own.
func (h *ExplorerHandler) anchorFor(ctx context.Context, hash string) (mainchainAnchor, bool) {
	if hash == "" {
		return mainchainAnchor{}, false
	}
	if held, ok := h.mainchain.get(hash); ok {
		return held, true
	}
	held, ok := h.anchorFromCore(ctx, hash)
	if !ok {
		held, ok = h.anchorFromEnforcer(ctx, hash)
	}
	if !ok {
		return mainchainAnchor{}, false
	}
	// A parent with no block after it carries no M8 yet, so read it again.
	if held.minedAt != 0 {
		h.mainchain.put(hash, held)
	}
	return held, true
}

// anchorFromCore reads the parent and the block that followed it.
func (h *ExplorerHandler) anchorFromCore(ctx context.Context, hash string) (mainchainAnchor, bool) {
	parent, err := h.mainchainHeader(ctx, hash)
	if err != nil {
		return mainchainAnchor{}, false
	}
	out := mainchainAnchor{parentHeight: parent.Height}
	if parent.NextBlockHash == "" {
		return out, true
	}
	carrier, err := h.mainchainHeader(ctx, parent.NextBlockHash)
	if err != nil {
		return out, true
	}
	out.minedAt = carrier.Time
	return out, true
}

// anchorFromEnforcer answers for an install that runs no bitcoind. It names
// the parent's own time, which is the earliest the block can have connected.
func (h *ExplorerHandler) anchorFromEnforcer(ctx context.Context, hash string) (mainchainAnchor, bool) {
	validator, err := h.orch.EnforcerValidator()
	if err != nil {
		return mainchainAnchor{}, false
	}
	resp, err := validator.GetBlockHeaderInfo(ctx, connect.NewRequest(
		&enforcerpb.GetBlockHeaderInfoRequest{
			BlockHash: &commonv1.ReverseHex{Hex: wrapperspb.String(hash)},
		}))
	if err != nil {
		return mainchainAnchor{}, false
	}
	for _, info := range resp.Msg.GetHeaderInfos() {
		return mainchainAnchor{parentHeight: info.GetHeight(), minedAt: int64(info.GetTimestamp())}, true
	}
	return mainchainAnchor{}, false
}

// resolveMainchain fills in the block a header names, and when it connected.
func (h *ExplorerHandler) resolveMainchain(ctx context.Context, blocks ...*pb.Block) {
	for _, block := range blocks {
		if block == nil || block.GetMainchainHash() == "" {
			continue
		}
		if block.GetMainchainHeight() != 0 && block.GetBlockTime() != 0 {
			continue
		}
		held, ok := h.anchorFor(ctx, block.GetMainchainHash())
		if !ok {
			continue
		}
		block.MainchainHeight = held.parentHeight
		block.BlockTime = held.minedAt
	}
}
