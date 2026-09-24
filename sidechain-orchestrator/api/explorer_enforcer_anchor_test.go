package api

import (
	"context"
	"fmt"
	"io"
	"net/http"
	"testing"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/wrapperspb"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	commonpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/common/v1"
	enforcerpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	enforcerrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/explorer/v1"
)

// headerChain answers for mainchain blocks 100 to tip. Block n has hash
// "h<n>" and time n*600. It sends at most pageSize headers per call.
type headerChain struct {
	enforcerrpc.UnimplementedValidatorServiceHandler
	tip      uint32
	pageSize uint32
	calls    int
	largest  uint32
}

func headerHash(height uint32) string { return fmt.Sprintf("h%d", height) }

func (c *headerChain) header(height uint32) *enforcerpb.BlockHeaderInfo {
	return &enforcerpb.BlockHeaderInfo{
		BlockHash:     &commonpb.ReverseHex{Hex: wrapperspb.String(headerHash(height))},
		PrevBlockHash: &commonpb.ReverseHex{Hex: wrapperspb.String(headerHash(height - 1))},
		Height:        height,
		Timestamp:     uint64(height) * 600,
	}
}

func (c *headerChain) GetChainTip(
	context.Context, *connect.Request[enforcerpb.GetChainTipRequest],
) (*connect.Response[enforcerpb.GetChainTipResponse], error) {
	return connect.NewResponse(&enforcerpb.GetChainTipResponse{BlockHeaderInfo: c.header(c.tip)}), nil
}

func (c *headerChain) GetBlockHeaderInfo(
	_ context.Context, req *connect.Request[enforcerpb.GetBlockHeaderInfoRequest],
) (*connect.Response[enforcerpb.GetBlockHeaderInfoResponse], error) {
	c.calls++
	var start uint32
	if _, err := fmt.Sscanf(req.Msg.GetBlockHash().GetHex().GetValue(), "h%d", &start); err != nil || start > c.tip {
		return nil, connect.NewError(connect.CodeNotFound, fmt.Errorf("no block %s", req.Msg.GetBlockHash()))
	}
	count := min(req.Msg.GetMaxAncestors()+1, c.pageSize)
	c.largest = max(c.largest, count)
	var out []*enforcerpb.BlockHeaderInfo
	for height := start; height >= 100 && uint32(len(out)) < count; height-- {
		out = append(out, c.header(height))
	}
	return connect.NewResponse(&enforcerpb.GetBlockHeaderInfoResponse{HeaderInfos: out}), nil
}

func lightExplorer(t *testing.T, chain *headerChain) *ExplorerHandler {
	t.Helper()
	mux := http.NewServeMux()
	path, handler := enforcerrpc.NewValidatorServiceHandler(chain)
	mux.Handle(path, handler)
	server := h2cServer(mux)
	t.Cleanup(server.Close)
	host, port := hostPort(t, server)

	orch := orchestrator.New(t.TempDir(), string(config.NetworkECash), t.TempDir(),
		[]orchestrator.BinaryConfig{{Name: "enforcer", Host: host, Port: port}}, zerolog.New(io.Discard))
	t.Cleanup(orch.StopAllMonitors)
	entry := config.ECashEndpoints()
	t.Cleanup(func() { config.SetECashEndpoints(entry) })
	remote := entry
	remote.Services.Enforcer.URL = server.URL
	config.SetECashEndpoints(remote)
	require.NoError(t, orchestrator.WriteNodeMode(orch.BitwindowDir, orchestrator.NodeModeLight))
	t.Cleanup(func() { require.NoError(t, orch.SetNodeMode(context.Background(), orchestrator.NodeModeFull)) })
	return NewExplorerHandler(orch)
}

// A light node reads the time of the block after the parent, as a full node
// does, so both show one age for one block.
func TestResolveMainchainReadsTheCarrierTimeFromTheEnforcer(t *testing.T) {
	chain := &headerChain{tip: 120, pageSize: 4}
	handler := lightExplorer(t, chain)

	block := &pb.Block{Hash: "side-385", MainchainHash: headerHash(105)}
	handler.resolveMainchain(context.Background(), block)

	assert.EqualValues(t, 105, block.GetMainchainHeight())
	assert.EqualValues(t, 106*600, block.GetBlockTime(), "the age reads the carrier, not the parent")

	chain.calls = 0
	younger := &pb.Block{Hash: "side-386", MainchainHash: headerHash(110)}
	handler.resolveMainchain(context.Background(), younger)
	assert.EqualValues(t, 111*600, younger.GetBlockTime())
	assert.Zero(t, chain.calls, "the walk to the older block holds the younger one")
}

// A parent at the tip carries no M8 yet, so the page reads it again later.
func TestResolveMainchainFromTheEnforcerWaitsForACarrier(t *testing.T) {
	chain := &headerChain{tip: 120, pageSize: 50}
	handler := lightExplorer(t, chain)

	block := &pb.Block{Hash: "side-385", MainchainHash: headerHash(120)}
	handler.resolveMainchain(context.Background(), block)

	assert.EqualValues(t, 120, block.GetMainchainHeight())
	assert.Zero(t, block.GetBlockTime())
	_, held := handler.mainchain.get(headerHash(120))
	assert.False(t, held)
}

func TestCarrierAnchorsNameTheParentOfEachHeader(t *testing.T) {
	chain := &headerChain{}
	got := carrierAnchors([]*enforcerpb.BlockHeaderInfo{chain.header(201), chain.header(200)})
	assert.Equal(t, map[string]mainchainAnchor{
		"h200": {parentHeight: 200, minedAt: 201 * 600},
		"h199": {parentHeight: 199, minedAt: 200 * 600},
	}, got)
}

// A page arrives newest first. One walk from the tip holds the whole page.
func TestResolveMainchainWalksOnceForAPage(t *testing.T) {
	chain := &headerChain{tip: 120, pageSize: 50}
	handler := lightExplorer(t, chain)

	page := []*pb.Block{
		{Hash: "side-3", Height: 3, MainchainHash: headerHash(112)},
		{Hash: "side-2", Height: 2, MainchainHash: headerHash(108)},
		{Hash: "side-1", Height: 1, MainchainHash: headerHash(104)},
	}
	handler.resolveMainchain(context.Background(), page...)

	for _, block := range page {
		assert.NotZero(t, block.GetBlockTime(), block.GetHash())
	}
	assert.Equal(t, 1+1, chain.calls, "one parent read and one walk")
}

// A walk longer than the cache still answers the block it walked to.
func TestResolveMainchainAnswersAWalkLongerThanTheCache(t *testing.T) {
	chain := &headerChain{tip: 100 + blockCacheSize + 50, pageSize: blockCacheSize + 100}
	handler := lightExplorer(t, chain)

	block := &pb.Block{Hash: "side-1", MainchainHash: headerHash(101)}
	handler.resolveMainchain(context.Background(), block)

	assert.EqualValues(t, 102*600, block.GetBlockTime())
	assert.LessOrEqual(t, chain.largest, uint32(enforcerHeaderPage+1))
}
