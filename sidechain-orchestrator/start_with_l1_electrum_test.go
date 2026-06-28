package orchestrator

import (
	"context"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/stretchr/testify/require"
)

func newTestWalletService(t *testing.T) *wallet.Service {
	t.Helper()
	return wallet.NewService(t.TempDir(), testLogger(t))
}

// An electrum wallet serves chain data remotely, so StartWithL1 must boot
// neither Bitcoin Core nor the enforcer — it short-circuits to a skipped-l1
// completion and starts no processes.
func TestStartWithL1SkipsBackendsForElectrum(t *testing.T) {
	o := newTestOrchestrator(t)
	svc := newTestWalletService(t)
	_, err := svc.CreateElectrumWallet("Electrum", nil, nil, "", "", "", 0, "")
	require.NoError(t, err)
	require.False(t, svc.ActiveWalletNeedsBitcoinBackends())
	o.WalletSvc = svc

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	ch, err := o.StartWithL1(ctx, "bitcoind", StartOpts{})
	require.NoError(t, err)

	var stages []string
	for p := range ch {
		require.NoError(t, p.Error)
		stages = append(stages, p.Stage)
	}

	require.Equal(t, []string{"skipped-l1"}, stages)
	require.False(t, o.process.IsRunning("bitcoind"))
	require.False(t, o.process.IsRunning("enforcer"))
}

// A non-electrum wallet needs the local stack, so the gate must not skip it.
func TestStartWithL1NeedsBackendsForCoreWallet(t *testing.T) {
	svc := newTestWalletService(t)
	_, err := svc.GenerateWallet("Core", "", "", nil)
	require.NoError(t, err)
	require.True(t, svc.ActiveWalletNeedsBitcoinBackends())
}

// In electrum mode a grpc-style sidechain has no local enforcer, so it must be
// rewired to the hosted orchestrator's mainchain rather than dial localhost.
func TestPointSidechainAtRemoteMainchainInjectsURL(t *testing.T) {
	o := newTestOrchestrator(t) // signet
	o.SidechainConfs = map[string]*config.SidechainConfManager{
		"thunder": {Spec: config.SidechainConfSpec{PortStyle: "grpc"}},
	}
	cfg := BinaryConfig{Name: "thunder", DisplayName: "Thunder", ChainLayer: 2}

	opts := StartOpts{}
	ch := make(chan StartupProgress, 4)
	require.True(t, o.pointSidechainAtRemoteMainchain(cfg, &opts, ch))
	require.Contains(t, opts.TargetArgs, "--mainchain-grpc-url=https://orchestrator.signet.drivechain.info")
}

// A network with no hosted orchestrator can't back an electrum sidechain, so
// the boot must fail cleanly instead of launching a doomed daemon.
func TestPointSidechainAtRemoteMainchainFailsWithoutRemote(t *testing.T) {
	o := newTestOrchestrator(t)
	o.Network = string(config.NetworkRegtest)
	o.SidechainConfs = map[string]*config.SidechainConfManager{
		"thunder": {Spec: config.SidechainConfSpec{PortStyle: "grpc"}},
	}
	cfg := BinaryConfig{Name: "thunder", DisplayName: "Thunder", ChainLayer: 2}

	opts := StartOpts{}
	ch := make(chan StartupProgress, 4)
	require.False(t, o.pointSidechainAtRemoteMainchain(cfg, &opts, ch))
	require.Empty(t, opts.TargetArgs)
	require.Error(t, (<-ch).Error)
}

// zmq-style sidechains carry no mainchain-grpc-url and can't reach a remote
// enforcer, so electrum mode must reject them rather than start them to fail.
func TestPointSidechainAtRemoteMainchainRejectsZMQ(t *testing.T) {
	o := newTestOrchestrator(t)
	o.SidechainConfs = map[string]*config.SidechainConfManager{
		"bitnames": {Spec: config.SidechainConfSpec{PortStyle: "zmq"}},
	}
	cfg := BinaryConfig{Name: "bitnames", DisplayName: "BitNames", ChainLayer: 2}

	opts := StartOpts{}
	ch := make(chan StartupProgress, 4)
	require.False(t, o.pointSidechainAtRemoteMainchain(cfg, &opts, ch))
	require.Empty(t, opts.TargetArgs)
	require.Error(t, (<-ch).Error)
}
