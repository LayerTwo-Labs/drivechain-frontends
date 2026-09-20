package api

import (
	"bytes"
	"context"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"net"
	"net/http"
	"net/http/httptest"
	"path/filepath"
	"sync/atomic"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
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
	err     error
}

func (s *fakeStratumSettings) StratumSettings() orchestrator.StratumSettings { return s.current }

func (s *fakeStratumSettings) SetStratumSettings(next orchestrator.StratumSettings) error {
	if s.err != nil {
		return s.err
	}
	s.current = next
	s.saves++
	return nil
}

// servedNode gives one template, so a start reaches the serve loop.
type servedNode struct{}

func (servedNode) GetBlockTemplate(context.Context) (stratum.Template, error) {
	coinbase := wire.NewMsgTx(2)
	script, err := txscript.NewScriptBuilder().AddInt64(500).Script()
	if err != nil {
		return stratum.Template{}, err
	}
	coinbase.AddTxIn(&wire.TxIn{
		PreviousOutPoint: wire.OutPoint{Index: wire.MaxPrevOutIndex},
		SignatureScript:  script,
		Sequence:         wire.MaxTxInSequenceNum,
	})
	coinbase.AddTxOut(wire.NewTxOut(5_000_000_000, make([]byte, 22)))
	var buf bytes.Buffer
	if err := coinbase.Serialize(&buf); err != nil {
		return stratum.Template{}, err
	}
	return stratum.Template{
		Version:           0x20000000,
		PreviousBlockHash: "00000000407919cf7c93944ad2a1f52f0b1d1924124905b51a2f9ae43335d200",
		CoinbaseTxn:       &stratum.TemplateTransaction{Data: hex.EncodeToString(buf.Bytes())},
		Bits:              "1d00ffff",
		Height:            500,
		CurTime:           uint32(time.Now().Add(-time.Minute).Unix()),
	}, nil
}

func (servedNode) SubmitBlock(context.Context, []byte, string) error { return nil }

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

func newTestStratumHandler(t *testing.T, network fakeStratumNetwork, settings *fakeStratumSettings) (*StratumHandler, *int) {
	t.Helper()
	addresses := 0
	h := NewStratumHandler(context.Background(), StratumDeps{
		Network:  network,
		Settings: settings,
		PayoutAddress: func(context.Context) (string, error) {
			addresses++
			return "bc1qpayout", nil
		},
		Core: func(context.Context, string, string, string) (json.RawMessage, error) {
			return json.RawMessage(`{"confirmations": 3}`), nil
		},
		HistoryPath: filepath.Join(t.TempDir(), "hashrate_history.json"),
		Log:         zerolog.Nop(),
	})
	h.newNode = func() (stratum.Node, error) { return unservedNode{}, nil }
	h.listen = func(uint32) (net.Listener, error) { return net.Listen("tcp", "127.0.0.1:0") }
	return h, &addresses
}

func TestStratumHandlerStart(t *testing.T) {
	t.Run("only on eCash", func(t *testing.T) {
		h, _ := newTestStratumHandler(t, fakeStratumNetwork{network: "signet"}, &fakeStratumSettings{})
		_, err := h.StartStratum(context.Background(), connect.NewRequest(&pb.StartStratumRequest{}))
		assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	})

	t.Run("a node with no template fails the start", func(t *testing.T) {
		h, _ := newTestStratumHandler(t, fakeStratumNetwork{network: "ecash"}, &fakeStratumSettings{})
		_, err := h.StartStratum(context.Background(), connect.NewRequest(&pb.StartStratumRequest{}))
		assert.Equal(t, connect.CodeUnavailable, connect.CodeOf(err))
		assert.ErrorContains(t, err, "the enforcer is not running")

		status, err := h.GetStratumStatus(context.Background(), connect.NewRequest(&pb.GetStratumStatusRequest{}))
		require.NoError(t, err)
		assert.False(t, status.Msg.Running)
	})

	t.Run("a port out of range", func(t *testing.T) {
		h, _ := newTestStratumHandler(t, fakeStratumNetwork{network: "ecash"}, &fakeStratumSettings{})
		_, err := h.StartStratum(context.Background(), connect.NewRequest(&pb.StartStratumRequest{Port: 70000}))
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	})

	t.Run("a request with no port takes the saved one", func(t *testing.T) {
		settings := &fakeStratumSettings{current: orchestrator.StratumSettings{Port: 3401}}
		h, _ := newTestStratumHandler(t, fakeStratumNetwork{network: "ecash"}, settings)
		h.newNode = func() (stratum.Node, error) { return servedNode{}, nil }
		t.Cleanup(h.Stop)

		var ports []uint32
		h.listen = func(port uint32) (net.Listener, error) {
			ports = append(ports, port)
			return net.Listen("tcp", "127.0.0.1:0")
		}

		_, err := h.StartStratum(context.Background(), connect.NewRequest(&pb.StartStratumRequest{}))
		require.NoError(t, err)
		assert.Equal(t, []uint32{3401}, ports)
	})
}

func TestStratumHandlerTargets(t *testing.T) {
	network := fakeStratumNetwork{network: "ecash", entry: betanetEntry()}

	t.Run("the catalog pool of the running network", func(t *testing.T) {
		h, _ := newTestStratumHandler(t, network, &fakeStratumSettings{})
		resp, err := h.ListTargets(context.Background(), connect.NewRequest(&pb.ListTargetsRequest{}))
		require.NoError(t, err)
		require.Len(t, resp.Msg.Pools, 1)
		assert.Equal(t, "bip300", resp.Msg.Pools[0].Id)
		assert.Equal(t, "bip300 pool", resp.Msg.Pools[0].Name)
		assert.Equal(t, "stratum+tcp://pool.beta.bip300.xyz:3334", resp.Msg.Pools[0].Url)
	})

	t.Run("a catalog pool pays the wallet of this install", func(t *testing.T) {
		settings := &fakeStratumSettings{}
		h, _ := newTestStratumHandler(t, network, settings)
		pool := &pb.Target{Kind: pb.TargetKind_TARGET_KIND_POOL, PoolId: "bip300"}
		_, err := h.SetTarget(context.Background(), connect.NewRequest(&pb.SetTargetRequest{Target: pool}))
		require.NoError(t, err)
		_, err = h.SetTarget(context.Background(), connect.NewRequest(&pb.SetTargetRequest{
			Target: &pb.Target{Kind: pb.TargetKind_TARGET_KIND_SOLO},
		}))
		require.NoError(t, err)
		_, err = h.SetTarget(context.Background(), connect.NewRequest(&pb.SetTargetRequest{Target: pool}))
		require.NoError(t, err)

		assert.Equal(t, orchestrator.StratumSettings{Target: "pool", PoolID: "bip300"}, settings.current)

		status, err := h.GetStratumStatus(context.Background(), connect.NewRequest(&pb.GetStratumStatusRequest{}))
		require.NoError(t, err)
		assert.Equal(t, pb.TargetKind_TARGET_KIND_POOL, status.Msg.Target.Kind)
		assert.Equal(t, "bc1qpayout", status.Msg.PayoutAddress)
	})

	t.Run("the same target again changes nothing", func(t *testing.T) {
		settings := &fakeStratumSettings{}
		h, _ := newTestStratumHandler(t, network, settings)
		pool := &pb.Target{Kind: pb.TargetKind_TARGET_KIND_POOL, PoolId: "bip300"}
		for range 2 {
			_, err := h.SetTarget(context.Background(), connect.NewRequest(&pb.SetTargetRequest{Target: pool}))
			require.NoError(t, err)
		}
		assert.Equal(t, 1, settings.saves)
	})

	t.Run("an unknown pool", func(t *testing.T) {
		h, _ := newTestStratumHandler(t, network, &fakeStratumSettings{})
		_, err := h.SetTarget(context.Background(), connect.NewRequest(&pb.SetTargetRequest{
			Target: &pb.Target{Kind: pb.TargetKind_TARGET_KIND_POOL, PoolId: "nopool"},
		}))
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	})

	t.Run("a custom pool", func(t *testing.T) {
		settings := &fakeStratumSettings{}
		h, _ := newTestStratumHandler(t, network, settings)
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
	h, _ := newTestStratumHandler(t, fakeStratumNetwork{network: "ecash", entry: entry}, &fakeStratumSettings{})

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
		h, _ := newTestStratumHandler(t, fakeStratumNetwork{network: "ecash", entry: entry}, &fakeStratumSettings{})
		resp, err := h.ListTargets(context.Background(), connect.NewRequest(&pb.ListTargetsRequest{}))
		require.NoError(t, err)
		assert.Nil(t, resp.Msg.Pools[0].Hashrate)
	})

	t.Run("a pool with no stats URL has no hashrate", func(t *testing.T) {
		h, _ := newTestStratumHandler(t, fakeStratumNetwork{network: "ecash", entry: betanetEntry()}, &fakeStratumSettings{})
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
	h, _ := newTestStratumHandler(t, fakeStratumNetwork{network: "ecash"}, &fakeStratumSettings{})
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
		h, _ := newTestStratumHandler(t, fakeStratumNetwork{network: "ecash"}, &fakeStratumSettings{})
		h.blocks = []stratum.Block{block}
		status, err := h.GetStratumStatus(context.Background(), connect.NewRequest(&pb.GetStratumStatusRequest{}))
		require.NoError(t, err)
		require.Len(t, status.Msg.BlocksFound, 1)
		assert.Equal(t, int32(3), status.Msg.BlocksFound[0].GetConfirmations())
	})

	t.Run("a node that does not answer leaves them unset", func(t *testing.T) {
		h, _ := newTestStratumHandler(t, fakeStratumNetwork{network: "ecash"}, &fakeStratumSettings{})
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
		h, _ := newTestStratumHandler(t, fakeStratumNetwork{network: "ecash"}, &fakeStratumSettings{})
		h.blocks, h.lastErr = []stratum.Block{block}, "no block template"
		h.Reset(t.TempDir())
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
	h, _ := newTestStratumHandler(t, fakeStratumNetwork{network: "ecash"}, &fakeStratumSettings{})
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

// The daemon pays a mined block to a bitwindow wallet address. The page shows
// that same address.
func TestStratumHandlerPayout(t *testing.T) {
	network := fakeStratumNetwork{network: "ecash"}

	t.Run("the status reads the address the daemon pays", func(t *testing.T) {
		h, _ := newTestStratumHandler(t, network, &fakeStratumSettings{})

		status, err := h.GetStratumStatus(context.Background(), connect.NewRequest(&pb.GetStratumStatusRequest{}))
		require.NoError(t, err)
		assert.Equal(t, "bc1qpayout", status.Msg.PayoutAddress)
	})

	t.Run("a wallet that derives none leaves the address empty", func(t *testing.T) {
		h, _ := newTestStratumHandler(t, network, &fakeStratumSettings{})
		h.payout = func(context.Context) (string, error) { return "", errors.New("no wallet") }

		status, err := h.GetStratumStatus(context.Background(), connect.NewRequest(&pb.GetStratumStatusRequest{}))
		require.NoError(t, err)
		assert.Empty(t, status.Msg.PayoutAddress)
	})
}

func TestStratumHandlerMiningSettings(t *testing.T) {
	network := fakeStratumNetwork{network: "ecash"}

	t.Run("the switch on starts the server that the hasher needs", func(t *testing.T) {
		settings := &fakeStratumSettings{}
		h, _ := newTestStratumHandler(t, network, settings)
		h.newNode = func() (stratum.Node, error) { return servedNode{}, nil }
		t.Cleanup(h.Stop)

		on := true
		_, err := h.SetMiningSettings(context.Background(), connect.NewRequest(&pb.SetMiningSettingsRequest{
			CpuMining: &on,
		}))
		require.NoError(t, err)

		status, err := h.GetStratumStatus(context.Background(), connect.NewRequest(&pb.GetStratumStatusRequest{}))
		require.NoError(t, err)
		assert.True(t, status.Msg.Running)
		assert.True(t, status.Msg.Settings.CpuMining)
		assert.Equal(t, uint32(3333), status.Msg.Settings.Port)

		t.Run("and the row leaves when the switch goes off", func(t *testing.T) {
			require.Eventually(t, func() bool {
				status, err := h.GetStratumStatus(context.Background(), connect.NewRequest(&pb.GetStratumStatusRequest{}))
				return err == nil && len(status.Msg.Miners) == 1 &&
					status.Msg.Miners[0].Worker == stratum.CPUWorker &&
					status.Msg.Miners[0].Address == stratum.CPUAddress
			}, 30*time.Second, 50*time.Millisecond)

			off := false
			_, err := h.SetMiningSettings(context.Background(), connect.NewRequest(&pb.SetMiningSettingsRequest{
				CpuMining: &off,
			}))
			require.NoError(t, err)

			require.Eventually(t, func() bool {
				status, err := h.GetStratumStatus(context.Background(), connect.NewRequest(&pb.GetStratumStatusRequest{}))
				return err == nil && len(status.Msg.Miners) == 0 && !status.Msg.Settings.CpuMining
			}, 10*time.Second, 50*time.Millisecond)
		})
	})

	t.Run("the settings persist with no server", func(t *testing.T) {
		settings := &fakeStratumSettings{}
		h, _ := newTestStratumHandler(t, network, settings)

		port, threads, keep := uint32(3401), uint32(2), true
		_, err := h.SetMiningSettings(context.Background(), connect.NewRequest(&pb.SetMiningSettingsRequest{
			Port:              &port,
			CpuThreads:        &threads,
			KeepMiningOnClose: &keep,
		}))
		require.NoError(t, err)

		assert.Equal(t, uint32(3401), settings.current.Port)
		assert.Equal(t, uint32(2), settings.current.CPUThreads)
		assert.True(t, settings.current.KeepMiningOnClose)

		status, err := h.GetStratumStatus(context.Background(), connect.NewRequest(&pb.GetStratumStatusRequest{}))
		require.NoError(t, err)
		assert.False(t, status.Msg.Running)
		assert.True(t, status.Msg.Settings.KeepMiningOnClose)
	})

	t.Run("a port out of range", func(t *testing.T) {
		h, _ := newTestStratumHandler(t, network, &fakeStratumSettings{})
		port := uint32(70000)
		_, err := h.SetMiningSettings(context.Background(), connect.NewRequest(&pb.SetMiningSettingsRequest{Port: &port}))
		assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
	})
}

func TestCoinbasePayout(t *testing.T) {
	block := json.RawMessage(`{
		"confirmations": 12,
		"tx": [
			{"vout": [
				{"value": 3.125, "scriptPubKey": {"address": "bc1qpayout"}},
				{"value": 0.0001, "scriptPubKey": {"address": "bc1qpayout"}},
				{"value": 1.5, "scriptPubKey": {"address": "bc1qsomeoneelse"}},
				{"value": 0, "scriptPubKey": {}}
			]},
			{"vout": [{"value": 9, "scriptPubKey": {"address": "bc1qpayout"}}]}
		]
	}`)

	sats, confirmations, err := coinbasePayout(block, "bc1qpayout")
	require.NoError(t, err)
	assert.Equal(t, int64(312510000), sats)
	assert.Equal(t, int32(12), confirmations)

	t.Run("a block that pays us nothing", func(t *testing.T) {
		sats, _, err := coinbasePayout(block, "bc1qnobody")
		require.NoError(t, err)
		assert.Zero(t, sats)
	})

	t.Run("a reply that is no block", func(t *testing.T) {
		_, _, err := coinbasePayout(json.RawMessage(`"no block"`), "bc1qpayout")
		require.ErrorContains(t, err, "decode the block")
	})
}

func TestStratumHandlerPoolBlocks(t *testing.T) {
	network := fakeStratumNetwork{network: "ecash", entry: betanetEntry()}

	t.Run("a solo target lists none", func(t *testing.T) {
		h, _ := newTestStratumHandler(t, network, &fakeStratumSettings{})
		resp, err := h.ListPoolBlocks(context.Background(), connect.NewRequest(&pb.ListPoolBlocksRequest{}))
		require.NoError(t, err)
		assert.Empty(t, resp.Msg.Blocks)
		assert.Contains(t, resp.Msg.Unavailable, "a pool from the catalog only")
	})

	t.Run("a pool with no stats URL", func(t *testing.T) {
		settings := &fakeStratumSettings{current: orchestrator.StratumSettings{Target: "pool", PoolID: "bip300"}}
		h, _ := newTestStratumHandler(t, network, settings)
		resp, err := h.ListPoolBlocks(context.Background(), connect.NewRequest(&pb.ListPoolBlocksRequest{}))
		require.NoError(t, err)
		assert.Contains(t, resp.Msg.Unavailable, "publishes no block list")
	})
}

func TestStratumHandlerHashrateHistory(t *testing.T) {
	h, _ := newTestStratumHandler(t, fakeStratumNetwork{network: "ecash"}, &fakeStratumSettings{})
	h.history.Record(4.2e6, time.Now())

	resp, err := h.GetHashrateHistory(context.Background(), connect.NewRequest(&pb.GetHashrateHistoryRequest{
		Range: pb.HashrateRange_HASHRATE_RANGE_HOUR,
	}))
	require.NoError(t, err)
	assert.Len(t, resp.Msg.Points, 60)
	assert.Equal(t, 4.2e6, resp.Msg.Peak)
	assert.Zero(t, resp.Msg.Current)
}

// A pool credits a block to the one worker name this installation uses
// upstream, not to a miner name on the local network.
func TestFinderIsOurs(t *testing.T) {
	assert.True(t, finderIsOurs("bc1qpayout", "bc1qpayout"))
	assert.True(t, finderIsOurs("bc1qpayout.rig1", "bc1qpayout"))
	assert.False(t, finderIsOurs("bc1qsomeoneelse.rig1", "bc1qpayout"))
	assert.False(t, finderIsOurs("bc1qpayoutplus", "bc1qpayout"))
	assert.False(t, finderIsOurs("bc1qpayout", ""))
	assert.False(t, finderIsOurs("", "bc1qpayout"))
}

// The miners keep going after the app window closes, so the daemon lease must
// not drain the stack under them.
func TestStratumHandlerHoldsTheDaemon(t *testing.T) {
	settings := &fakeStratumSettings{}
	h, _ := newTestStratumHandler(t, fakeStratumNetwork{network: "ecash"}, settings)
	h.newNode = func() (stratum.Node, error) { return servedNode{}, nil }
	t.Cleanup(func() { h.Stop() })

	// The serve goroutine also takes and gives back the hold.
	var holds atomic.Int64
	h.holdDaemon = func() func() {
		holds.Add(1)
		return func() { holds.Add(-1) }
	}

	_, err := h.StartStratum(context.Background(), connect.NewRequest(&pb.StartStratumRequest{}))
	require.NoError(t, err)
	assert.Zero(t, holds.Load(), "a server alone holds nothing")

	keep := true
	_, err = h.SetMiningSettings(context.Background(), connect.NewRequest(&pb.SetMiningSettingsRequest{
		KeepMiningOnClose: &keep,
	}))
	require.NoError(t, err)
	assert.Equal(t, int64(1), holds.Load())

	t.Run("the setting off gives the daemon back", func(t *testing.T) {
		keep := false
		_, err := h.SetMiningSettings(context.Background(), connect.NewRequest(&pb.SetMiningSettingsRequest{
			KeepMiningOnClose: &keep,
		}))
		require.NoError(t, err)
		assert.Zero(t, holds.Load())
	})

	t.Run("a stop gives the daemon back", func(t *testing.T) {
		keep := true
		_, err := h.SetMiningSettings(context.Background(), connect.NewRequest(&pb.SetMiningSettingsRequest{
			KeepMiningOnClose: &keep,
		}))
		require.NoError(t, err)
		require.Equal(t, int64(1), holds.Load())

		h.Stop()
		assert.Zero(t, holds.Load())
	})
}

// A start that fails must leave the switch off, so the user can try again.
func TestStratumHandlerKeepsTheSwitchOffOnAFailedStart(t *testing.T) {
	settings := &fakeStratumSettings{}
	h, _ := newTestStratumHandler(t, fakeStratumNetwork{network: "ecash"}, settings)

	on := true
	_, err := h.SetMiningSettings(context.Background(), connect.NewRequest(&pb.SetMiningSettingsRequest{
		CpuMining: &on,
	}))
	require.Error(t, err)
	assert.False(t, settings.current.CPUMining)

	status, err := h.GetStratumStatus(context.Background(), connect.NewRequest(&pb.GetStratumStatusRequest{}))
	require.NoError(t, err)
	assert.False(t, status.Msg.Settings.CpuMining)

	t.Run("and a second try still reaches the start", func(t *testing.T) {
		h.newNode = func() (stratum.Node, error) { return servedNode{}, nil }
		t.Cleanup(func() { h.Stop() })

		on := true
		_, err := h.SetMiningSettings(context.Background(), connect.NewRequest(&pb.SetMiningSettingsRequest{
			CpuMining: &on,
		}))
		require.NoError(t, err)
		assert.True(t, settings.current.CPUMining)
	})
}

// A running server listens on the port it started on, so a new port must
// reach a new listener.
func TestStratumHandlerPortChangeRebinds(t *testing.T) {
	h, _ := newTestStratumHandler(t, fakeStratumNetwork{network: "ecash"}, &fakeStratumSettings{})
	h.newNode = func() (stratum.Node, error) { return servedNode{}, nil }
	t.Cleanup(h.Stop)

	var ports []uint32
	h.listen = func(port uint32) (net.Listener, error) {
		ports = append(ports, port)
		return net.Listen("tcp", "127.0.0.1:0")
	}

	_, err := h.StartStratum(context.Background(), connect.NewRequest(&pb.StartStratumRequest{Port: 3333}))
	require.NoError(t, err)

	port := uint32(3401)
	_, err = h.SetMiningSettings(context.Background(), connect.NewRequest(&pb.SetMiningSettingsRequest{
		Port: &port,
	}))
	require.NoError(t, err)

	assert.Equal(t, []uint32{3333, 3401}, ports)
	status, err := h.GetStratumStatus(context.Background(), connect.NewRequest(&pb.GetStratumStatusRequest{}))
	require.NoError(t, err)
	assert.True(t, status.Msg.Running)
	assert.Equal(t, uint32(3401), status.Msg.Port)

	t.Run("a setting that is no port leaves the listener alone", func(t *testing.T) {
		threads := uint32(3)
		_, err := h.SetMiningSettings(context.Background(), connect.NewRequest(&pb.SetMiningSettingsRequest{
			CpuThreads: &threads,
		}))
		require.NoError(t, err)
		assert.Equal(t, []uint32{3333, 3401}, ports)
	})

	t.Run("the port the server already listens on leaves it alone", func(t *testing.T) {
		same := uint32(3401)
		keep := true
		_, err := h.SetMiningSettings(context.Background(), connect.NewRequest(&pb.SetMiningSettingsRequest{
			Port:              &same,
			KeepMiningOnClose: &keep,
		}))
		require.NoError(t, err)
		assert.Equal(t, []uint32{3333, 3401}, ports)
	})
}

// A port that does not bind must leave every miner on the old one.
func TestStratumHandlerKeepsTheListenerOnAFailedRebind(t *testing.T) {
	h, _ := newTestStratumHandler(t, fakeStratumNetwork{network: "ecash"}, &fakeStratumSettings{})
	h.newNode = func() (stratum.Node, error) { return servedNode{}, nil }
	t.Cleanup(h.Stop)

	_, err := h.StartStratum(context.Background(), connect.NewRequest(&pb.StartStratumRequest{Port: 3333}))
	require.NoError(t, err)
	h.listen = func(uint32) (net.Listener, error) { return nil, errors.New("address already in use") }

	port := uint32(3401)
	_, err = h.SetMiningSettings(context.Background(), connect.NewRequest(&pb.SetMiningSettingsRequest{
		Port: &port,
	}))
	require.Error(t, err)

	status, err := h.GetStratumStatus(context.Background(), connect.NewRequest(&pb.GetStratumStatusRequest{}))
	require.NoError(t, err)
	assert.True(t, status.Msg.Running)
	assert.Equal(t, uint32(3333), status.Msg.Port)
	assert.Equal(t, uint32(3333), status.Msg.Settings.Port)
}

// A save that fails after a start must leave no hasher behind.
func TestStratumHandlerStopsTheHasherWhenTheSaveFails(t *testing.T) {
	settings := &fakeStratumSettings{err: errors.New("the disk is full")}
	h, _ := newTestStratumHandler(t, fakeStratumNetwork{network: "ecash"}, settings)
	h.newNode = func() (stratum.Node, error) { return servedNode{}, nil }
	t.Cleanup(h.Stop)

	on := true
	_, err := h.SetMiningSettings(context.Background(), connect.NewRequest(&pb.SetMiningSettingsRequest{
		CpuMining: &on,
	}))
	require.ErrorContains(t, err, "the disk is full")

	status, err := h.GetStratumStatus(context.Background(), connect.NewRequest(&pb.GetStratumStatusRequest{}))
	require.NoError(t, err)
	assert.False(t, status.Msg.Running)
	assert.False(t, status.Msg.Settings.CpuMining)
}

// Every row of the pool block list costs a block read from the node, and the
// page polls every two seconds.
func TestStratumHandlerCachesThePoolBlocks(t *testing.T) {
	var reads int
	pool := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		reads++
		_, _ = w.Write([]byte(`{"rows":[]}`))
	}))
	defer pool.Close()

	entry := betanetEntry()
	entry.Services.MiningPool.StatsURL = pool.URL + "/api/overview"
	network := fakeStratumNetwork{network: "ecash", entry: entry}
	settings := &fakeStratumSettings{current: orchestrator.StratumSettings{Target: "pool", PoolID: "bip300"}}
	h, _ := newTestStratumHandler(t, network, settings)

	for range 5 {
		_, err := h.ListPoolBlocks(context.Background(), connect.NewRequest(&pb.ListPoolBlocksRequest{}))
		require.NoError(t, err)
	}
	assert.Equal(t, 1, reads)

	t.Run("a target change asks the pool again", func(t *testing.T) {
		h.forgetPoolBlocks()
		_, err := h.ListPoolBlocks(context.Background(), connect.NewRequest(&pb.ListPoolBlocksRequest{}))
		require.NoError(t, err)
		assert.Equal(t, 2, reads)
	})

	t.Run("a node that gives no block leaves the payout unset", func(t *testing.T) {
		h.forgetPoolBlocks()
		h.core = func(context.Context, string, string, string) (json.RawMessage, error) {
			return nil, errors.New("block not found")
		}
		reads := 0
		pool := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			reads++
			_, _ = w.Write([]byte(`{"rows":[{"height":968556,"hash":"aa","finder":"someone.else"}]}`))
		}))
		defer pool.Close()
		entry := betanetEntry()
		entry.Services.MiningPool.StatsURL = pool.URL + "/api/overview"
		h.network = fakeStratumNetwork{network: "ecash", entry: entry}

		resp, err := h.ListPoolBlocks(context.Background(), connect.NewRequest(&pb.ListPoolBlocksRequest{}))
		require.NoError(t, err)
		require.Len(t, resp.Msg.Blocks, 1)
		assert.Nil(t, resp.Msg.Blocks[0].MyPayoutSats)
		assert.Nil(t, resp.Msg.Blocks[0].Confirmations)
	})

}

// A fresh install saves no port, and the dialog sends the default back. That
// is the port the server already listens on, so nothing rebinds.
func TestStratumHandlerDefaultPortNeedsNoRebind(t *testing.T) {
	settings := &fakeStratumSettings{}
	h, _ := newTestStratumHandler(t, fakeStratumNetwork{network: "ecash"}, settings)
	h.newNode = func() (stratum.Node, error) { return servedNode{}, nil }
	t.Cleanup(h.Stop)

	var ports []uint32
	h.listen = func(port uint32) (net.Listener, error) {
		ports = append(ports, port)
		return net.Listen("tcp", "127.0.0.1:0")
	}

	_, err := h.StartStratum(context.Background(), connect.NewRequest(&pb.StartStratumRequest{}))
	require.NoError(t, err)
	require.Zero(t, settings.current.Port)

	port, threads := uint32(defaultStratumPort), uint32(2)
	_, err = h.SetMiningSettings(context.Background(), connect.NewRequest(&pb.SetMiningSettingsRequest{
		Port:       &port,
		CpuThreads: &threads,
	}))
	require.NoError(t, err)

	assert.Equal(t, []uint32{defaultStratumPort}, ports)
	assert.Equal(t, uint32(2), settings.current.CPUThreads)
}

// The network hashrate belongs to the chain that ran before, so a switch must
// ask the node of the chain that runs now.
func TestStratumHandlerResetForgetsTheNetworkHashrate(t *testing.T) {
	var rates []string
	h, _ := newTestStratumHandler(t, fakeStratumNetwork{network: "ecash"}, &fakeStratumSettings{})
	h.core = func(_ context.Context, method, _, _ string) (json.RawMessage, error) {
		if method == "getnetworkhashps" {
			rates = append(rates, method)
			return json.RawMessage(fmt.Sprint(len(rates), "e15")), nil
		}
		return json.RawMessage(`{"confirmations": 3}`), nil
	}

	assert.Equal(t, 1e15, h.networkHashrate(context.Background()))
	assert.Equal(t, 1e15, h.networkHashrate(context.Background()), "a second read comes from the cache")

	h.Reset(t.TempDir())

	assert.Equal(t, 2e15, h.networkHashrate(context.Background()))
}
