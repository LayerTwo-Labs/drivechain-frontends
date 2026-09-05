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

// put stores a copy and answers another one.
func (c *blockCache) put(
	key string, block *pb.Block, activity []*pb.Activity, ownHeight bool,
) (*pb.Block, []*pb.Activity) {
	if c == nil {
		return block, activity
	}
	c.mu.Lock()
	defer c.mu.Unlock()
	if _, ok := c.rows[key]; !ok {
		c.order = append(c.order, key)
		for len(c.order) > blockCacheSize {
			delete(c.rows, c.order[0])
			c.order = c.order[1:]
		}
	}
	c.rows[key] = cachedBlock{block: block, activity: activity, ownHeight: ownHeight}
	return copyBlock(c.rows[key])
}

func copyBlock(held cachedBlock) (*pb.Block, []*pb.Activity) {
	rows := make([]*pb.Activity, 0, len(held.activity))
	for _, row := range held.activity {
		rows = append(rows, proto.Clone(row).(*pb.Activity))
	}
	return proto.Clone(held.block).(*pb.Block), rows
}

// mainchainHeader is the height and the time of one mainchain block.
type mainchainHeader struct {
	height uint32
	time   int64
}

// mainchainCache holds those, because a mainchain header never changes and
// only the enforcer answers for it.
type mainchainCache struct {
	mu    sync.Mutex
	rows  map[string]mainchainHeader
	order []string
}

func newMainchainCache() *mainchainCache {
	return &mainchainCache{rows: map[string]mainchainHeader{}}
}

func (c *mainchainCache) get(hash string) (mainchainHeader, bool) {
	if c == nil {
		return mainchainHeader{}, false
	}
	c.mu.Lock()
	defer c.mu.Unlock()
	held, ok := c.rows[hash]
	return held, ok
}

func (c *mainchainCache) put(hash string, held mainchainHeader) {
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

// mainchainHeaderFor names the mainchain block a sidechain header points at. A
// sidechain header carries no clock, so the block time comes from there too.
func (h *ExplorerHandler) mainchainHeaderFor(ctx context.Context, hash string) (mainchainHeader, bool) {
	if hash == "" {
		return mainchainHeader{}, false
	}
	if held, ok := h.mainchain.get(hash); ok {
		return held, true
	}
	validator, err := h.orch.EnforcerValidator()
	if err != nil {
		return mainchainHeader{}, false
	}
	resp, err := validator.GetBlockHeaderInfo(ctx, connect.NewRequest(
		&enforcerpb.GetBlockHeaderInfoRequest{
			BlockHash: &commonv1.ReverseHex{Hex: wrapperspb.String(hash)},
		}))
	if err != nil {
		return mainchainHeader{}, false
	}
	for _, info := range resp.Msg.GetHeaderInfos() {
		held := mainchainHeader{height: info.GetHeight(), time: int64(info.GetTimestamp())}
		h.mainchain.put(hash, held)
		return held, true
	}
	return mainchainHeader{}, false
}

// resolveMainchain fills in the height and the time a block header points at.
func (h *ExplorerHandler) resolveMainchain(ctx context.Context, blocks ...*pb.Block) {
	for _, block := range blocks {
		if block == nil || block.GetMainchainHash() == "" {
			continue
		}
		if block.GetMainchainHeight() != 0 && block.GetBlockTime() != 0 {
			continue
		}
		held, ok := h.mainchainHeaderFor(ctx, block.GetMainchainHash())
		if !ok {
			continue
		}
		block.MainchainHeight = held.height
		block.BlockTime = held.time
	}
}
