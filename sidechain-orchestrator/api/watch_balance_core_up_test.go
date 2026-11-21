package api

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"runtime"
	"sync/atomic"
	"testing"
	"time"

	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/chaindata"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

type downBackend struct {
	*balanceBackend
	down *atomic.Bool
}

func (b downBackend) Balance(ctx context.Context, walletID string) (float64, float64, float64, error) {
	if b.down.Load() {
		return 0, 0, 0, errors.New("connection refused")
	}
	return b.balanceBackend.Balance(ctx, walletID)
}

func TestWatchBalanceWaitsForCore(t *testing.T) {
	var down atomic.Bool
	down.Store(true)
	backend := downBackend{balanceBackend: &balanceBackend{btc: map[string]float64{}}, down: &down}
	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	require.NoError(t, svc.Init())
	t.Cleanup(svc.Close)
	engine := chaindata.New(chaindata.Config{Log: zerolog.Nop(), Call: func(ctx context.Context, method string, _ ...any) (json.RawMessage, error) {
		if down.Load() {
			return nil, errors.New("connection refused")
		}
		if method == "getblockchaininfo" {
			return json.RawMessage(`{"chain":"regtest","blocks":1,"headers":1,"bestblockhash":"a"}`), nil
		}
		<-ctx.Done()
		return nil, ctx.Err()
	}})
	engine.Start(t.Context())
	h := NewWalletHandler(svc)
	h.SetEngine(wallet.NewWalletEngine(svc, wallet.NewBackendRouter(svc, backend, nil), nil, zerolog.Nop()))
	h.chainData = engine

	w, err := svc.GenerateWallet("First", "", "", nil)
	require.NoError(t, err)
	backend.set(w.ID, 1)
	require.Eventually(t, func() bool {
		err := engine.Health()
		return err != nil && !errors.Is(err, chaindata.ErrNoProbe)
	}, 5*time.Second, time.Millisecond)

	next := watchBalance(t, h)
	go func() {
		time.Sleep(50 * time.Millisecond)
		down.Store(false)
		_ = engine.Probe(context.Background())
	}()

	msg := next()
	require.Equal(t, w.ID, msg.WalletId)
	require.Equal(t, 1e8, msg.Balance.ConfirmedSats)
}

// openBalanceStream serves h and opens a WatchBalance stream with an hour recheck.
func openBalanceStream(t *testing.T, h *WalletHandler) rpc.WalletManagerServiceWatchBalanceClientStream {
	t.Helper()
	recheck := balanceRecheckInterval
	balanceRecheckInterval = time.Hour
	t.Cleanup(func() { balanceRecheckInterval = recheck })
	mux := http.NewServeMux()
	srv := connect.NewServer()
	rpc.RegisterWalletManagerServiceHandler(srv, h)
	connecthttp.Mount(mux, srv, connecthttp.WithReadMaxBytes(0))
	server := httptest.NewServer(mux)
	t.Cleanup(server.Close)
	client := rpc.NewWalletManagerServiceClient(connect.NewClient(connecthttp.NewTransport(server.Client(), server.URL, connecthttp.WithReadMaxBytes(0))))
	ctx, cancel := context.WithTimeout(t.Context(), 10*time.Second)
	t.Cleanup(cancel)
	stream, err := client.WatchBalance(ctx, &pb.WatchBalanceRequest{})
	require.NoError(t, err)
	t.Cleanup(func() { _ = stream.Close() })
	return stream
}

// requireStreamEnds fails unless the stream ends with an error within 2 s.
func requireStreamEnds(t *testing.T, stream rpc.WalletManagerServiceWatchBalanceClientStream) {
	t.Helper()
	done := make(chan error, 1)
	go func() {
		for {
			msg, err := stream.Receive()
			if err != nil {
				done <- err
				return
			}
			if !msg.Heartbeat && msg.Balance != nil {
				done <- nil
				return
			}
		}
	}()
	select {
	case err := <-done:
		require.Error(t, err)
	case <-time.After(2 * time.Second):
		t.Fatal("the stream still waits for Core")
	}
}

func downCore(t *testing.T) *chaindata.Engine {
	t.Helper()
	engine := chaindata.New(chaindata.Config{Log: zerolog.Nop(), Call: func(context.Context, string, ...any) (json.RawMessage, error) {
		return nil, errors.New("connection refused")
	}})
	engine.Start(t.Context())
	require.Error(t, engine.Probe(t.Context()))
	return engine
}

func TestWatchBalanceKeepsNoHealthSubscription(t *testing.T) {
	backend := &balanceBackend{btc: map[string]float64{}}
	h, svc, engine := newBalanceHandler(t, backend)
	w, err := svc.GenerateWallet("First", "", "", nil)
	require.NoError(t, err)
	backend.set(w.ID, 0)
	next := watchBalance(t, h)
	next()

	before := runtime.NumGoroutine()
	for i := range 100 {
		backend.set(w.ID, float64(i+1))
		engine.Fire(chaindata.EventSettle)
		next()
	}
	require.Less(t, runtime.NumGoroutine()-before, 20)
}

func TestWatchBalanceOfAnElectrumWalletWaitsForNoCore(t *testing.T) {
	backend := &balanceBackend{btc: map[string]float64{}}
	h, svc, _ := newBalanceHandler(t, backend)
	h.chainData = downCore(t)
	_, err := svc.CreateElectrumWallet("Light", nil, nil, "", "", "", "native-segwit", 0, "")
	require.NoError(t, err)

	requireStreamEnds(t, openBalanceStream(t, h))
}

func TestWatchBalanceStopsTheCoreWaitAtAWalletSwitch(t *testing.T) {
	var down atomic.Bool
	down.Store(true)
	backend := downBackend{balanceBackend: &balanceBackend{btc: map[string]float64{}}, down: &down}
	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	require.NoError(t, svc.Init())
	t.Cleanup(svc.Close)
	h := NewWalletHandler(svc)
	h.SetEngine(wallet.NewWalletEngine(svc, wallet.NewBackendRouter(svc, backend, nil), nil, zerolog.Nop()))
	h.chainData = downCore(t)
	_, err := svc.GenerateWallet("Core", "", "", nil)
	require.NoError(t, err)

	stream := openBalanceStream(t, h)
	time.Sleep(100 * time.Millisecond)
	light, err := svc.CreateElectrumWallet("Light", nil, nil, "", "", "", "native-segwit", 0, "")
	require.NoError(t, err)
	require.NoError(t, svc.SwitchWallet(light.ID))

	requireStreamEnds(t, stream)
}
