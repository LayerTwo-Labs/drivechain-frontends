package api

import (
	"context"
	"encoding/json"
	"errors"
	"net"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/stratum/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/stratum"
)

type fakeStratumNetwork struct {
	network string
	entry   netcatalog.Network
}

func (n fakeStratumNetwork) CurrentNetwork() string { return n.network }

func (n fakeStratumNetwork) RunningCatalogEntry() (netcatalog.Network, bool) {
	return n.entry, n.entry.ID != ""
}

type fakeStratumSettings struct {
	current orchestrator.StratumSettings
	saves   int
}

func (s *fakeStratumSettings) StratumSettings() orchestrator.StratumSettings { return s.current }

func (s *fakeStratumSettings) SetStratumSettings(next orchestrator.StratumSettings) error {
	s.current = next
	s.saves++
	return nil
}

type unservedNode struct{}

func (unservedNode) GetBlockTemplate(context.Context) (stratum.Template, error) {
	return stratum.Template{}, errors.New("the enforcer is not running")
}

func (unservedNode) SubmitBlock(context.Context, []byte, string) error { return nil }

func betanetEntry() netcatalog.Network {
	entry := netcatalog.Network{ID: "betanet"}
	stratumURL := "stratum+tcp://pool.beta.bip300.xyz:3334"
	entry.Services.MiningPool.Stratum = &stratumURL
	return entry
}

func newTestStratumHandler(network fakeStratumNetwork, settings *fakeStratumSettings) (*StratumHandler, *int) {
	addresses := 0
	h := NewStratumHandler(context.Background(), network, settings,
		func(context.Context) (string, error) {
			addresses++
			return "bc1qpayout", nil
		},
		func(context.Context, string, string, string) (json.RawMessage, error) {
			return json.RawMessage(`{"confirmations": 3}`), nil
		},
		zerolog.Nop(),
	)
	h.newNode = func() (stratum.Node, error) { return unservedNode{}, nil }
	h.listen = func(uint32) (net.Listener, error) { return net.Listen("tcp", "127.0.0.1:0") }
	return h, &addresses
}

func TestStratumHandlerStart(t *testing.T) {
	t.Run("only on eCash", func(t *testing.T) {
		h, _ := newTestStratumHandler(fakeStratumNetwork{network: "signet"}, &fakeStratumSettings{})
		_, err := h.StartStratum(context.Background(), connect.NewRequest(&pb.StartStratumRequest{}))
		assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	})

	t.Run("a node with no template fails the start", func(t *testing.T) {
		h, _ := newTestStratumHandler(fakeStratumNetwork{network: "ecash"}, &fakeStratumSettings{})
		_, err := h.StartStratum(context.Background(), connect.NewRequest(&pb.StartStratumRequest{}))
		assert.Equal(t, connect.CodeUnavailable, connect.CodeOf(err))
		assert.ErrorContains(t, err, "the enforcer is not running")

		status, err := h.GetStratumStatus(context.Background(), connect.NewRequest(&pb.GetStratumStatusRequest{}))
		require.NoError(t, err)
		assert.False(t, status.Msg.Running)
	})

	t.Run("a port out of range", func(t *testing.T) {
		h, _ := newTestStratumHandler(fakeStratumNetwork{network: "ecash"}, &fakeStratumSettings{})
		_, err := h.StartStratum(context.Background(), connect.NewRequest(&pb.StartStratumRequest{Port: 70000}))
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	})
}

func TestStratumHandlerTargets(t *testing.T) {
	network := fakeStratumNetwork{network: "ecash", entry: betanetEntry()}

	t.Run("the catalog pool of the running network", func(t *testing.T) {
		h, _ := newTestStratumHandler(network, &fakeStratumSettings{})
		resp, err := h.ListTargets(context.Background(), connect.NewRequest(&pb.ListTargetsRequest{}))
		require.NoError(t, err)
		require.Len(t, resp.Msg.Pools, 1)
		assert.Equal(t, "bip300", resp.Msg.Pools[0].Id)
		assert.Equal(t, "bip300 pool", resp.Msg.Pools[0].Name)
		assert.Equal(t, "stratum+tcp://pool.beta.bip300.xyz:3334", resp.Msg.Pools[0].Url)
	})

	t.Run("a catalog pool gets one payout address", func(t *testing.T) {
		settings := &fakeStratumSettings{}
		h, addresses := newTestStratumHandler(network, settings)
		pool := &pb.Target{Kind: pb.TargetKind_TARGET_KIND_POOL, PoolId: "bip300"}
		_, err := h.SetTarget(context.Background(), connect.NewRequest(&pb.SetTargetRequest{Target: pool}))
		require.NoError(t, err)
		_, err = h.SetTarget(context.Background(), connect.NewRequest(&pb.SetTargetRequest{
			Target: &pb.Target{Kind: pb.TargetKind_TARGET_KIND_SOLO},
		}))
		require.NoError(t, err)
		_, err = h.SetTarget(context.Background(), connect.NewRequest(&pb.SetTargetRequest{Target: pool}))
		require.NoError(t, err)

		assert.Equal(t, 1, *addresses)
		assert.Equal(t, orchestrator.StratumSettings{Target: "pool", PoolID: "bip300", PayoutAddress: "bc1qpayout"}, settings.current)

		status, err := h.GetStratumStatus(context.Background(), connect.NewRequest(&pb.GetStratumStatusRequest{}))
		require.NoError(t, err)
		assert.Equal(t, pb.TargetKind_TARGET_KIND_POOL, status.Msg.Target.Kind)
		assert.Equal(t, "bc1qpayout", status.Msg.PayoutAddress)
	})

	t.Run("an unknown pool", func(t *testing.T) {
		h, _ := newTestStratumHandler(network, &fakeStratumSettings{})
		_, err := h.SetTarget(context.Background(), connect.NewRequest(&pb.SetTargetRequest{
			Target: &pb.Target{Kind: pb.TargetKind_TARGET_KIND_POOL, PoolId: "nopool"},
		}))
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	})

	t.Run("a custom pool", func(t *testing.T) {
		settings := &fakeStratumSettings{}
		h, _ := newTestStratumHandler(network, settings)
		custom := &pb.Target{Kind: pb.TargetKind_TARGET_KIND_CUSTOM, Url: "stratum+tcp://pool.example.com:3333", Worker: "bc1qme.rig", Password: "x"}
		_, err := h.SetTarget(context.Background(), connect.NewRequest(&pb.SetTargetRequest{Target: custom}))
		require.NoError(t, err)
		assert.Equal(t, "custom", settings.current.Target)
		assert.Equal(t, "bc1qme.rig", settings.current.Worker)

		for _, bad := range []*pb.Target{
			{Kind: pb.TargetKind_TARGET_KIND_CUSTOM, Url: "http://pool.example.com:3333", Worker: "w"},
			{Kind: pb.TargetKind_TARGET_KIND_CUSTOM, Url: "stratum+tcp://pool.example.com", Worker: "w"},
			{Kind: pb.TargetKind_TARGET_KIND_CUSTOM, Url: "stratum+tcp://pool.example.com:3333"},
		} {
			_, err := h.SetTarget(context.Background(), connect.NewRequest(&pb.SetTargetRequest{Target: bad}))
			assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
		}
		assert.Equal(t, 1, settings.saves)
	})
}

// The overview the bip300 betanet pool served on 2026-09-19.
const betanetPoolOverview = `{"accepted":685985,"rejected":144,"blocks":112,"blocks_pending":0,"blocks_orphaned":1,"blocks_rejected":5,"workers_active":22,"hashrate":6100355035537160,"hashrate_1h":15857720329737.973,"hashrate_5m":16531755363981.977,"best_share_24h":226771532.3177558,"best_share_lifetime":226771532.3177558,"reject_rate_pct":0.020987307051589424,"shares_lifetime":730719,"rejects_lifetime":235,"blocks_lifetime":112,"oldest_share_ts":1789634904,"last_share_ts":1789823392,"window_sec":86400,"window_effective_sec":86400,"db_ready":true}`

func TestParsePoolOverview(t *testing.T) {
	hashrate, ok := parsePoolOverview([]byte(betanetPoolOverview))
	require.True(t, ok)
	assert.InDelta(t, 16531755363981.977, hashrate, 1e-3)

	for _, unknown := range []string{``, `[]`, `{"hashrate": 5}`, `{"hashrate_5m": "fast"}`, `{"hashrate_5m": -1}`, `<html>`} {
		t.Run(unknown, func(t *testing.T) {
			_, ok := parsePoolOverview([]byte(unknown))
			assert.False(t, ok)
		})
	}
}

func TestListTargetsPoolHashrate(t *testing.T) {
	requests := 0
	stats := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		requests++
		_, _ = w.Write([]byte(betanetPoolOverview))
	}))
	t.Cleanup(stats.Close)

	entry := betanetEntry()
	entry.Services.MiningPool.StatsURL = stats.URL
	h, _ := newTestStratumHandler(fakeStratumNetwork{network: "ecash", entry: entry}, &fakeStratumSettings{})

	for range 2 {
		resp, err := h.ListTargets(context.Background(), connect.NewRequest(&pb.ListTargetsRequest{}))
		require.NoError(t, err)
		require.NotNil(t, resp.Msg.Pools[0].Hashrate)
		assert.InDelta(t, 16531755363981.977, *resp.Msg.Pools[0].Hashrate, 1e-3)
	}
	assert.Equal(t, 1, requests)

	t.Run("a pool that does not answer has no hashrate", func(t *testing.T) {
		down := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
			w.WriteHeader(http.StatusBadGateway)
		}))
		t.Cleanup(down.Close)
		entry.Services.MiningPool.StatsURL = down.URL
		h, _ := newTestStratumHandler(fakeStratumNetwork{network: "ecash", entry: entry}, &fakeStratumSettings{})
		resp, err := h.ListTargets(context.Background(), connect.NewRequest(&pb.ListTargetsRequest{}))
		require.NoError(t, err)
		assert.Nil(t, resp.Msg.Pools[0].Hashrate)
	})

	t.Run("a pool with no stats URL has no hashrate", func(t *testing.T) {
		h, _ := newTestStratumHandler(fakeStratumNetwork{network: "ecash", entry: betanetEntry()}, &fakeStratumSettings{})
		resp, err := h.ListTargets(context.Background(), connect.NewRequest(&pb.ListTargetsRequest{}))
		require.NoError(t, err)
		assert.Nil(t, resp.Msg.Pools[0].Hashrate)
	})
}

func TestCatalogPoolIdentity(t *testing.T) {
	tests := []struct {
		url, id, name string
	}{
		{url: "stratum+tcp://pool.beta.bip300.xyz:3334", id: "bip300", name: "bip300 pool"},
		{url: "stratum+tcp://pool.alpha.avonpool.xyz:3334", id: "avonpool", name: "avonpool pool"},
		{url: "stratum+tcp://192.168.1.5:3333", id: "192.168.1.5", name: "192.168.1.5"},
	}
	for _, tt := range tests {
		t.Run(tt.url, func(t *testing.T) {
			id, name, err := catalogPoolIdentity(tt.url)
			require.NoError(t, err)
			assert.Equal(t, tt.id, id)
			assert.Equal(t, tt.name, name)
		})
	}
}

func TestStratumHandlerSetWorkMode(t *testing.T) {
	h, _ := newTestStratumHandler(fakeStratumNetwork{network: "ecash"}, &fakeStratumSettings{})
	_, err := h.SetWorkMode(context.Background(), connect.NewRequest(&pb.SetWorkModeRequest{
		Address: "192.168.1.9", Mode: pb.WorkMode_WORK_MODE_LOW,
	}))
	assert.Equal(t, connect.CodeNotFound, connect.CodeOf(err))

	_, err = h.SetWorkMode(context.Background(), connect.NewRequest(&pb.SetWorkModeRequest{Address: "192.168.1.9"}))
	assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
}

func TestStratumHandlerFoundBlocks(t *testing.T) {
	block := stratum.Block{Height: 500, Worker: "avalon.1", RewardSats: 5_000_000_000, FoundAt: time.Now()}

	t.Run("confirmations from the node", func(t *testing.T) {
		h, _ := newTestStratumHandler(fakeStratumNetwork{network: "ecash"}, &fakeStratumSettings{})
		h.blocks = []stratum.Block{block}
		status, err := h.GetStratumStatus(context.Background(), connect.NewRequest(&pb.GetStratumStatusRequest{}))
		require.NoError(t, err)
		require.Len(t, status.Msg.BlocksFound, 1)
		assert.Equal(t, int32(3), status.Msg.BlocksFound[0].GetConfirmations())
	})

	t.Run("a node that does not answer leaves them unset", func(t *testing.T) {
		h, _ := newTestStratumHandler(fakeStratumNetwork{network: "ecash"}, &fakeStratumSettings{})
		h.core = func(context.Context, string, string, string) (json.RawMessage, error) {
			return nil, errors.New("rpc error -5: Block not found")
		}
		h.blocks = []stratum.Block{block}
		status, err := h.GetStratumStatus(context.Background(), connect.NewRequest(&pb.GetStratumStatusRequest{}))
		require.NoError(t, err)
		require.Len(t, status.Msg.BlocksFound, 1)
		assert.Nil(t, status.Msg.BlocksFound[0].Confirmations)
	})

	t.Run("a network reset forgets them", func(t *testing.T) {
		h, _ := newTestStratumHandler(fakeStratumNetwork{network: "ecash"}, &fakeStratumSettings{})
		h.blocks, h.lastErr = []stratum.Block{block}, "no block template"
		h.Reset()
		status, err := h.GetStratumStatus(context.Background(), connect.NewRequest(&pb.GetStratumStatusRequest{}))
		require.NoError(t, err)
		assert.Empty(t, status.Msg.BlocksFound)
		assert.Empty(t, status.Msg.Error)
	})
}

type templateNode struct{ unservedNode }

func (templateNode) GetBlockTemplate(context.Context) (stratum.Template, error) {
	return stratum.Template{
		Version:           0x20000000,
		PreviousBlockHash: "00000000407919cf7c93944ad2a1f52f0b1d1924124905b51a2f9ae43335d200",
		CoinbaseTxn: &stratum.TemplateTransaction{
			Data: "01000000010000000000000000000000000000000000000000000000000000000000000000ffffffff020101ffffffff0100f2052a01000000015100000000",
		},
		Bits:    "207fffff",
		Height:  1,
		CurTime: 1784800000,
	}, nil
}

func TestStratumHandlerRun(t *testing.T) {
	h, _ := newTestStratumHandler(fakeStratumNetwork{network: "ecash"}, &fakeStratumSettings{})
	h.newNode = func() (stratum.Node, error) { return templateNode{}, nil }

	_, err := h.StartStratum(context.Background(), connect.NewRequest(&pb.StartStratumRequest{Port: 3333}))
	require.NoError(t, err)

	t.Run("a second start on the same port changes nothing", func(t *testing.T) {
		_, err := h.StartStratum(context.Background(), connect.NewRequest(&pb.StartStratumRequest{Port: 3333}))
		require.NoError(t, err)
	})

	t.Run("a start on another port", func(t *testing.T) {
		_, err := h.StartStratum(context.Background(), connect.NewRequest(&pb.StartStratumRequest{Port: 4444}))
		assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	})

	var status *connect.Response[pb.GetStratumStatusResponse]
	require.Eventually(t, func() bool {
		status, err = h.GetStratumStatus(context.Background(), connect.NewRequest(&pb.GetStratumStatusRequest{}))
		return err == nil && status.Msg.NetworkDifficulty > 0
	}, 5*time.Second, 10*time.Millisecond)
	assert.True(t, status.Msg.Running)
	assert.Equal(t, uint32(3333), status.Msg.Port)
	assert.Equal(t, pb.TargetKind_TARGET_KIND_SOLO, status.Msg.Target.Kind)

	_, err = h.StopStratum(context.Background(), connect.NewRequest(&pb.StopStratumRequest{}))
	require.NoError(t, err)
	status, err = h.GetStratumStatus(context.Background(), connect.NewRequest(&pb.GetStratumStatusRequest{}))
	require.NoError(t, err)
	assert.False(t, status.Msg.Running)
	assert.Empty(t, status.Msg.Error)
}
