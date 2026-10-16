package api

import (
	"context"
	"os"
	"path/filepath"
	"testing"
	"time"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
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
