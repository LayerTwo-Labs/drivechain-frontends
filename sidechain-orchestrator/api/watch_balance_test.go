package api

import (
	"context"
	"net/http"
	"net/http/httptest"
	"sync"
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

type balanceBackend struct {
	wallet.Backend
	mu  sync.Mutex
	btc map[string]float64
}

func (b *balanceBackend) Balance(ctx context.Context, walletID string) (float64, float64, float64, error) {
	b.mu.Lock()
	defer b.mu.Unlock()
	return b.btc[walletID], 0, 0, nil
}

func (b *balanceBackend) set(walletID string, btc float64) {
	b.mu.Lock()
	defer b.mu.Unlock()
	b.btc[walletID] = btc
}

// watchBalance serves h and opens a WatchBalance stream. Its next func gives
// the next balance frame. The recheck tick is an hour, so only an event can
// send a frame after the first.
func watchBalance(t *testing.T, h *WalletHandler) func() *pb.WatchBalanceResponse {
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

	return func() *pb.WatchBalanceResponse {
		t.Helper()
		frames := make(chan *pb.WatchBalanceResponse, 1)
		errs := make(chan error, 1)
		go func() {
			for {
				msg, err := stream.Receive()
				if err != nil {
					errs <- err
					return
				}
				if !msg.Heartbeat {
					frames <- msg
					return
				}
			}
		}()
		select {
		case msg := <-frames:
			return msg
		case err := <-errs:
			t.Fatalf("stream ended: %v", err)
		case <-time.After(5 * time.Second):
			t.Fatal("no frame after the change")
		}
		return nil
	}
}

func newBalanceHandler(t *testing.T, backend *balanceBackend) (*WalletHandler, *wallet.Service, *chaindata.Engine) {
	t.Helper()
	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	require.NoError(t, svc.Init())
	t.Cleanup(svc.Close)
	engine := chaindata.New(chaindata.Config{Log: zerolog.Nop()})
	h := NewWalletHandler(svc)
	h.SetEngine(wallet.NewWalletEngine(svc, wallet.NewBackendRouter(svc, backend, nil), nil, zerolog.Nop()))
	h.chainData = engine
	return h, svc, engine
}

func TestWatchBalanceSendsOnEachChange(t *testing.T) {
	backend := &balanceBackend{btc: map[string]float64{}}
	h, svc, engine := newBalanceHandler(t, backend)
	first, err := svc.GenerateWallet("First", "", "", nil)
	require.NoError(t, err)
	second, err := svc.GenerateWallet("Second", "", "", nil)
	require.NoError(t, err)
	require.NoError(t, svc.SwitchWallet(first.ID))
	backend.set(first.ID, 1)
	backend.set(second.ID, 2)
	next := watchBalance(t, h)

	msg := next()
	require.Equal(t, first.ID, msg.WalletId)
	require.Equal(t, 1e8, msg.Balance.ConfirmedSats)

	backend.set(first.ID, 1.5)
	engine.Fire(chaindata.EventSettle)
	msg = next()
	require.Equal(t, first.ID, msg.WalletId)
	require.Equal(t, 1.5e8, msg.Balance.ConfirmedSats)

	require.NoError(t, svc.SwitchWallet(second.ID))
	msg = next()
	require.Equal(t, second.ID, msg.WalletId)
	require.Equal(t, 2e8, msg.Balance.ConfirmedSats)
}

func TestWatchBalanceWaitsForAWallet(t *testing.T) {
	backend := &balanceBackend{btc: map[string]float64{}}
	h, svc, _ := newBalanceHandler(t, backend)
	next := watchBalance(t, h)

	msg := next()
	require.Empty(t, msg.WalletId)
	require.Nil(t, msg.Balance)

	w, err := svc.GenerateWallet("First", "", "", nil)
	require.NoError(t, err)
	msg = next()
	require.Equal(t, w.ID, msg.WalletId)
}
