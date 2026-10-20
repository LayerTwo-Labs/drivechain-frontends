package api

import (
	"context"
	"errors"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"
	"time"

	connectv1 "connectrpc.com/connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1/bitwindowdv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	cryptorpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/crypto/v1/cryptov1connect"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bitassets"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bitnames"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/coinshift"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/photon"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/thunder"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/truthcoin"
)

// Each network holds its own coinnews log, so a network swap does not mix the
// records of two chains in one file.
func TestCoinnewsLogPathFollowsTheNetworkDatadir(t *testing.T) {
	base := t.TempDir()

	conf := config.Config{Datadir: base}
	require.NoError(t, conf.Finalize(config.NetworkSignet))
	require.Equal(t, filepath.Join(base, "signet", "coinnews-sync.log"), coinnewsLogPath(conf))

	require.NoError(t, conf.Finalize(config.NetworkMainnet))
	require.Equal(t, filepath.Join(base, "mainnet", "coinnews-sync.log"), coinnewsLogPath(conf))
}

func TestRuntimeCloseClosesTheCoinnewsLog(t *testing.T) {
	conf := config.Config{Datadir: t.TempDir(), BitcoinCoreNetwork: config.NetworkRegtest}
	s := &Server{svcs: Services{Database: database.Test(t), WalletDir: t.TempDir()}}

	rt, err := s.buildRuntime(t.Context(), conf, "")
	require.NoError(t, err)
	require.NotNil(t, rt.coinnewsLog)

	rt.ctx = t.Context()
	rt.Close()

	_, err = rt.coinnewsLog.WriteString("x")
	require.ErrorIs(t, err, os.ErrClosed)
}

func TestRuntimeCloseStopsTheAddressSync(t *testing.T) {
	conf := config.Config{Datadir: t.TempDir(), BitcoinCoreNetwork: config.NetworkRegtest}
	s := &Server{svcs: Services{Database: database.Test(t), WalletDir: t.TempDir()}}

	rt, err := s.buildRuntime(t.Context(), conf, "")
	require.NoError(t, err)

	rt.ctx, rt.cancel = context.WithCancel(t.Context())
	rt.runEngine("address-sync", rt.walletSvc.Run, zerolog.Ctx(rt.ctx))

	closed := make(chan struct{})
	go func() {
		rt.Close()
		close(closed)
	}()
	select {
	case <-closed:
	case <-time.After(5 * time.Second):
		t.Fatal("the address sync did not stop")
	}
}

func TestServeReturnsAfterTheRuntimeCloses(t *testing.T) {
	conf := config.Config{Datadir: t.TempDir(), BitcoinCoreNetwork: config.NetworkRegtest}
	s := &Server{svcs: Services{Database: database.Test(t), WalletDir: t.TempDir()}, topSwap: newSwappableHandler()}

	rt, err := s.buildRuntime(t.Context(), conf, "")
	require.NoError(t, err)
	rt.ctx = t.Context()
	s.current.Store(rt)

	ctx, cancel := context.WithCancel(t.Context())
	served := make(chan error, 1)
	go func() { served <- s.Serve(ctx, "127.0.0.1:0") }()
	cancel()

	select {
	case err := <-served:
		require.NoError(t, err)
	case <-time.After(10 * time.Second):
		t.Fatal("Serve did not return")
	}
	require.ErrorContains(t, rt.db.PingContext(t.Context()), "database is closed")
}

func refuse[T any](context.Context) (T, error) {
	var zero T
	return zero, errors.New("not available in tests")
}

// newRecycleServer builds a server on the network with a real database in a
// temporary datadir.
func newRecycleServer(t *testing.T, network config.Network, networkID string) *Server {
	t.Helper()

	conf := config.Config{Datadir: t.TempDir()}
	require.NoError(t, conf.Finalize(network))
	srv, err := New(t.Context(), Services{
		ECashNetworkID:         networkID,
		MiningPoolFetch:        func(context.Context, string) ([]byte, error) { return nil, errors.New("no pool registry in tests") },
		BitcoindConnector:      refuse[corerpc.BitcoinServiceClient],
		EnforcerConnector:      refuse[validatorrpc.ValidatorServiceClient],
		BlockProducerConnector: refuse[validatorrpc.BlockProducerServiceClient],
		MiningConnector:        refuse[validatorrpc.MiningServiceClient],
		CryptoConnector:        refuse[cryptorpc.CryptoServiceClient],
		ThunderConnector:       refuse[*thunder.Client],
		BitNamesConnector:      refuse[*bitnames.Client],
		BitAssetsConnector:     refuse[*bitassets.Client],
		TruthcoinConnector:     refuse[*truthcoin.Client],
		PhotonConnector:        refuse[*photon.Client],
		CoinShiftConnector:     refuse[*coinshift.Client],
		WalletDir:              t.TempDir(),
	}, conf, nil)
	require.NoError(t, err)
	t.Cleanup(func() { srv.Shutdown(context.WithoutCancel(t.Context())) })
	return srv
}

func requireClosed(t *testing.T, rt *Runtime) {
	t.Helper()
	require.Eventually(t, func() bool {
		err := rt.db.PingContext(t.Context())
		return err != nil && err.Error() == "sql: database is closed"
	}, 15*time.Second, 10*time.Millisecond)
}

func TestRecycle(t *testing.T) {
	t.Run("the active network returns at once", func(t *testing.T) {
		srv := newRecycleServer(t, config.NetworkRegtest, "")
		old := srv.current.Load()

		require.NoError(t, srv.Recycle(t.Context(), config.NetworkRegtest, "regtest", 0))

		assert.Same(t, old, srv.current.Load())
		require.NoError(t, old.db.PingContext(t.Context()))
	})

	t.Run("a new network serves the new runtime and closes the old one", func(t *testing.T) {
		srv := newRecycleServer(t, config.NetworkRegtest, "")
		old := srv.current.Load()

		require.NoError(t, srv.Recycle(t.Context(), config.NetworkSignet, "signet", 0))

		rt := srv.current.Load()
		require.NotSame(t, old, rt)
		assert.Equal(t, config.NetworkSignet, rt.conf.BitcoinCoreNetwork)
		assert.Equal(t, filepath.Join(filepath.Dir(old.conf.Datadir), "signet"), rt.conf.Datadir)
		assert.Equal(t, "signet", srv.networkID)
		require.NoError(t, rt.db.PingContext(t.Context()))
		requireClosed(t, old)
	})

	t.Run("an eCash id change resets the chain rows and keeps the user rows", func(t *testing.T) {
		srv := newRecycleServer(t, config.NetworkECash, "alphanet")
		old := srv.current.Load()
		ctx := t.Context()
		for _, insert := range []string{
			`INSERT INTO address_book (label, address, direction) VALUES ('rent', 'bc1qrent', 'send')`,
			`INSERT INTO processed_blocks (height, block_hash, txids, block_time) VALUES (5, 'h5', '[]', CURRENT_TIMESTAMP)`,
			`INSERT INTO processed_blocks (height, block_hash, txids, block_time) VALUES (10, 'h10', '[]', CURRENT_TIMESTAMP)`,
		} {
			_, err := old.db.ExecContext(ctx, insert)
			require.NoError(t, err)
		}

		require.NoError(t, srv.Recycle(ctx, config.NetworkECash, "betanet", 8))

		rt := srv.current.Load()
		require.NotSame(t, old, rt)
		assert.Equal(t, old.conf.Datadir, rt.conf.Datadir)
		assert.Equal(t, "betanet", srv.networkID)
		requireClosed(t, old)

		var heights []int
		rows, err := rt.db.QueryContext(ctx, `SELECT height FROM processed_blocks ORDER BY height`)
		require.NoError(t, err)
		for rows.Next() {
			var h int
			require.NoError(t, rows.Scan(&h))
			heights = append(heights, h)
		}
		require.NoError(t, rows.Err())
		require.NoError(t, rows.Close())
		assert.Equal(t, []int{5}, heights)

		var labels int
		require.NoError(t, rt.db.QueryRowContext(ctx, `SELECT COUNT(*) FROM address_book`).Scan(&labels))
		assert.Equal(t, 1, labels)
	})

	t.Run("an eCash switch from a request of the old runtime does not wait for that request", func(t *testing.T) {
		srv := newRecycleServer(t, config.NetworkECash, "alphanet")
		old := srv.current.Load()
		recycled := make(chan error, 1)
		old.mux = http.NewServeMux()
		old.mux.HandleFunc(bitwindowdv1connect.BitwindowdServiceUpdateNetworkProcedure, func(w http.ResponseWriter, r *http.Request) {
			recycled <- srv.Recycle(r.Context(), config.NetworkECash, "betanet", 0)
		})
		server := httptest.NewServer(srv.Handler())
		t.Cleanup(server.Close)

		start := time.Now()
		resp, err := http.Post(server.URL+bitwindowdv1connect.BitwindowdServiceUpdateNetworkProcedure, "application/json", nil)
		require.NoError(t, err)
		require.NoError(t, resp.Body.Close())

		require.NoError(t, <-recycled)
		assert.Less(t, time.Since(start), 5*time.Second)
		assert.NotSame(t, old, srv.current.Load())
	})

	t.Run("an eCash switch waits for the other requests of the old runtime", func(t *testing.T) {
		srv := newRecycleServer(t, config.NetworkECash, "alphanet")
		old := srv.current.Load()
		slowStarted := make(chan struct{})
		slowErr := make(chan error, 1)
		recycled := make(chan error, 1)
		old.mux = http.NewServeMux()
		old.mux.HandleFunc("/test/slow", func(w http.ResponseWriter, r *http.Request) {
			close(slowStarted)
			time.Sleep(300 * time.Millisecond)
			slowErr <- old.db.PingContext(r.Context())
		})
		old.mux.HandleFunc(bitwindowdv1connect.BitwindowdServiceUpdateNetworkProcedure, func(w http.ResponseWriter, r *http.Request) {
			recycled <- srv.Recycle(r.Context(), config.NetworkECash, "betanet", 0)
		})
		server := httptest.NewServer(srv.Handler())
		t.Cleanup(server.Close)

		go func() {
			resp, err := http.Get(server.URL + "/test/slow")
			if err == nil {
				err = resp.Body.Close()
			}
			if err != nil {
				slowErr <- err
			}
		}()
		<-slowStarted
		resp, err := http.Post(server.URL+bitwindowdv1connect.BitwindowdServiceUpdateNetworkProcedure, "application/json", nil)
		require.NoError(t, err)
		require.NoError(t, resp.Body.Close())

		require.NoError(t, <-recycled)
		require.NoError(t, <-slowErr)
	})
}

func TestZmqAddress(t *testing.T) {
	core := mocks.NewMockBitcoinServiceClient(gomock.NewController(t))
	core.EXPECT().GetZmqNotifications(gomock.Any(), gomock.Any()).
		Return(connectv1.NewResponse(&corepb.GetZmqNotificationsResponse{
			Notifications: []*corepb.GetZmqNotificationsResponse_Notification{
				{Type: "pubrawtx", Address: "tcp://127.0.0.1:29000"},
			},
		}), nil).Times(2)
	bitcoind := service.New("bitcoind", func(context.Context) (corerpc.BitcoinServiceClient, error) { return core, nil })

	t.Run("reads the address from the bitcoind service", func(t *testing.T) {
		addr, err := zmqAddress(t.Context(), bitcoind, "pubrawtx")
		require.NoError(t, err)
		assert.Equal(t, "tcp://127.0.0.1:29000", addr)
	})

	t.Run("refuses a type that bitcoind does not publish", func(t *testing.T) {
		_, err := zmqAddress(t.Context(), bitcoind, "pubsequence")
		require.ErrorContains(t, err, "bitcoind does not publish pubsequence ZMQ notifications")
	})
}
