package api

import (
	"context"
	"net/http/httptest"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

// TestWatchWalletSyncStream drives WatchWalletSync through the real connect
// server: a subscriber receives an initial snapshot, then descriptive scan
// progress (which chain, addresses checked) once a scan runs.
func TestWatchWalletSyncStream(t *testing.T) {
	log := zerolog.New(zerolog.NewTestWriter(t))
	svc := wallet.NewService(t.TempDir(), log)
	require.NoError(t, svc.Init())
	t.Cleanup(func() { svc.Close() })

	w, err := svc.CreateElectrumWallet("E", nil, nil, "", "", "")
	require.NoError(t, err)

	net := &chaincfg.SigNetParams
	addrs, err := wallet.DeriveBIP84Addresses(w.Master.SeedHex, net, 0, 1)
	require.NoError(t, err)

	esplora := &psbtTestEsplora{addr: addrs[0], amount: 100_000, txid: "44"}
	eb := wallet.NewElectrumBackend(svc, esplora, net, log)
	engine := wallet.NewWalletEngine(svc, wallet.NewBackendRouter(svc, nil, nil, eb), net, log)
	h := NewWalletHandler(svc)
	h.SetEngine(engine)

	_, handler := walletmanagerv1connect.NewWalletManagerServiceHandler(h)
	srv := httptest.NewServer(handler)
	defer srv.Close()
	client := walletmanagerv1connect.NewWalletManagerServiceClient(srv.Client(), srv.URL)

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	stream, err := client.WatchWalletSync(ctx, connect.NewRequest(&pb.WatchWalletSyncRequest{WalletId: w.ID}))
	require.NoError(t, err)

	// First frame is the immediate snapshot — receiving it proves the server has
	// subscribed, so the scan we trigger next won't be missed.
	require.True(t, stream.Receive())

	go func() { _, _, _ = eb.Balance(context.Background(), w.ID) }()

	sawScanning := false
	for stream.Receive() {
		msg := stream.Msg()
		if msg.Phase == "scanning" && msg.Chain == "external" {
			require.Contains(t, msg.Message, "Scanning external addresses")
			require.True(t, msg.Scanning)
			sawScanning = true
			break
		}
	}
	require.NoError(t, stream.Err())
	require.True(t, sawScanning, "stream must report descriptive scan progress")
}
