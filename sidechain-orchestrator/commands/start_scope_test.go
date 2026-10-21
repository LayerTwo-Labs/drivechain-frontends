package commands

import (
	"context"
	"flag"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"sort"
	"sync"
	"testing"
	"time"

	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
	"github.com/urfave/cli/v2"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/api"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

// binaryLayers holds the chain layer of every binary the fake reports.
var binaryLayers = map[string]int32{
	"bitcoind":    1,
	"enforcer":    1,
	"drivechaind": 1,
	"bitassets":   2,
	"bitnames":    2,
	"coinshift":   2,
	"photon":      2,
	"thunder":     2,
}

// fakeOrchestrator answers the RPCs that `start` calls. It keeps a set of
// running binaries, and it records every stop.
type fakeOrchestrator struct {
	rpc.UnimplementedOrchestratorServiceHandler

	mu sync.Mutex
	// running holds the binaries that run right now.
	running map[string]bool
	// portInUse holds binaries that answer on their port under another owner.
	portInUse map[string]bool
	// windowOpen holds the chains that run as an app window, with no daemon.
	windowOpen map[string]bool
	// opensWindow names the chain that a boot opens as a window, with no
	// daemon slot behind it.
	opensWindow string
	// stopFailures name the binaries whose stop returns an error.
	stopFailures map[string]bool
	// crashesDuringStream stop while the log stream is open, as a crash does.
	crashesDuringStream []string
	// startsDuringStream run while the log stream is open. A second client
	// starts them, so `start` must not stop them.
	startsDuringStream []string
	// streamErr is the error the log stream ends with.
	streamErr error

	startTarget string
	startReady  <-chan struct{}
	startRead   chan struct{}
	startErr    error

	stopped      []string
	shutdownAlls int
}

func (f *fakeOrchestrator) isRunning(name string) bool {
	f.mu.Lock()
	defer f.mu.Unlock()
	return f.running[name]
}

func (f *fakeOrchestrator) runningNames() []string {
	f.mu.Lock()
	defer f.mu.Unlock()
	names := make([]string, 0, len(f.running))
	for name := range f.running {
		names = append(names, name)
	}
	sort.Strings(names)
	return names
}

func (f *fakeOrchestrator) ListBinaries(_ context.Context, _ *pb.ListBinariesRequest) (*pb.ListBinariesResponse, error) {
	f.mu.Lock()
	defer f.mu.Unlock()

	resp := &pb.ListBinariesResponse{}
	for name, layer := range binaryLayers {
		resp.Binaries = append(resp.Binaries, &pb.BinaryStatusMsg{
			Name:       name,
			ChainLayer: layer,
			Running:    f.running[name],
			WindowOpen: f.windowOpen[name],
			PortInUse:  !f.running[name] && f.portInUse[name],
		})
	}
	return resp, nil
}

func (f *fakeOrchestrator) GetBinaryStatus(_ context.Context, req *pb.GetBinaryStatusRequest) (*pb.GetBinaryStatusResponse, error) {
	return &pb.GetBinaryStatusResponse{
		Status: &pb.BinaryStatusMsg{Name: req.Name, Downloaded: true, Downloadable: true},
	}, nil
}

func (f *fakeOrchestrator) StartWithL1(ctx context.Context, req *pb.StartWithL1Request) (*pb.StartWithL1Response, error) {
	f.mu.Lock()
	f.running["bitcoind"] = true
	f.running["enforcer"] = true
	if f.startReady != nil {
		f.startTarget = req.Target
		f.mu.Unlock()
		if !req.Wait {
			return &pb.StartWithL1Response{}, nil
		}
		close(f.startRead)
		select {
		case <-f.startReady:
		case <-ctx.Done():
			return nil, ctx.Err()
		}
		f.mu.Lock()
	}
	defer f.mu.Unlock()
	if f.startErr != nil && req.Wait {
		return nil, f.startErr
	}
	if f.opensWindow == req.Target {
		f.windowOpen[req.Target] = true
	} else {
		f.running[req.Target] = true
	}
	return &pb.StartWithL1Response{}, nil
}

func (f *fakeOrchestrator) StartBinary(ctx context.Context, req *pb.StartBinaryRequest) (*pb.StartBinaryResponse, error) {
	f.mu.Lock()
	f.running[req.Name] = true
	f.mu.Unlock()
	if f.startReady != nil {
		close(f.startRead)
		select {
		case <-f.startReady:
		case <-ctx.Done():
			return nil, ctx.Err()
		}
	}
	return &pb.StartBinaryResponse{Pid: 1234}, nil
}

// StreamLogs ends at once, which is the ctrl+c path the user hits.
func (f *fakeOrchestrator) StreamLogs(_ context.Context, req *pb.StreamLogsRequest, _ rpc.OrchestratorServiceStreamLogsServerStream) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	if f.startTarget == req.Name && !f.running[req.Name] {
		return connect.NewError(connect.CodeUnknown, req.Name+" is not running")
	}
	for _, name := range f.startsDuringStream {
		f.running[name] = true
	}
	for _, name := range f.crashesDuringStream {
		delete(f.running, name)
	}
	return f.streamErr
}

func (f *fakeOrchestrator) StopBinary(_ context.Context, req *pb.StopBinaryRequest) (*pb.StopBinaryResponse, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.stopped = append(f.stopped, req.Name)
	if f.stopFailures[req.Name] {
		return nil, connect.NewError(connect.CodeInternal, "stop timed out")
	}
	delete(f.running, req.Name)
	delete(f.windowOpen, req.Name)
	return &pb.StopBinaryResponse{}, nil
}

func (f *fakeOrchestrator) ShutdownAll(_ context.Context, _ *pb.ShutdownAllRequest, stream rpc.OrchestratorServiceShutdownAllServerStream) error {
	f.mu.Lock()
	f.shutdownAlls++
	f.mu.Unlock()
	return stream.Send(&pb.ShutdownAllResponse{Done: true})
}

func newFakeOrchestrator(t *testing.T, alreadyRunning ...string) (*fakeOrchestrator, rpc.OrchestratorServiceClient) {
	t.Helper()

	fake := &fakeOrchestrator{
		running:      map[string]bool{},
		portInUse:    map[string]bool{},
		windowOpen:   map[string]bool{},
		stopFailures: map[string]bool{},
	}
	for _, name := range alreadyRunning {
		fake.running[name] = true
	}

	rpcServer := connect.NewServer()

	rpc.RegisterOrchestratorServiceHandler(rpcServer, fake)

	handler := http.NewServeMux()

	connecthttp.Mount(handler, rpcServer, connecthttp.WithReadMaxBytes(0))
	server := httptest.NewServer(handler)
	t.Cleanup(server.Close)

	return fake, rpc.NewOrchestratorServiceClient(connect.NewClient(connecthttp.NewTransport(server.Client(), server.URL, connecthttp.WithReadMaxBytes(0))))
}

func startContext(t *testing.T, argv ...string) *cli.Context {
	t.Helper()

	fs := flag.NewFlagSet("start", flag.ContinueOnError)
	for _, f := range startCommand.Flags {
		require.NoError(t, f.Apply(fs))
	}
	require.NoError(t, fs.Parse(argv))

	cctx := cli.NewContext(cli.NewApp(), fs, nil)
	cctx.Context = context.Background()
	return cctx
}

func TestStartKeepsAChainItDidNotStart(t *testing.T) {
	fake, client := newFakeOrchestrator(t, "bitcoind", "enforcer", "thunder")

	require.NoError(t, runStart(startContext(t, "photon"), client))

	require.Equal(t, []string{"photon"}, fake.stopped)
	require.Zero(t, fake.shutdownAlls)
	require.Equal(t, []string{"bitcoind", "enforcer", "thunder"}, fake.runningNames())
}

func TestStartStopsTheDependenciesItStarted(t *testing.T) {
	fake, client := newFakeOrchestrator(t)

	require.NoError(t, runStart(startContext(t, "photon"), client))

	require.Equal(t, []string{"photon", "enforcer", "bitcoind"}, fake.stopped)
	require.Zero(t, fake.shutdownAlls)
	require.Empty(t, fake.runningNames())
}

func TestStartKeepsL1ForAChainThatArrivedLater(t *testing.T) {
	fake, client := newFakeOrchestrator(t)
	fake.startsDuringStream = []string{"thunder"}

	require.NoError(t, runStart(startContext(t, "photon"), client))

	require.Equal(t, []string{"photon"}, fake.stopped)
	require.Equal(t, []string{"bitcoind", "enforcer", "thunder"}, fake.runningNames())
}

func TestStartKeepsAnAdoptedDependency(t *testing.T) {
	fake, client := newFakeOrchestrator(t)
	fake.portInUse["bitcoind"] = true

	require.NoError(t, runStart(startContext(t, "photon"), client))

	require.Equal(t, []string{"photon", "enforcer"}, fake.stopped)
	require.True(t, fake.isRunning("bitcoind"))
}

func TestStartStopsL1WhileTheDaemonPortAnswers(t *testing.T) {
	fake, client := newFakeOrchestrator(t)
	fake.portInUse["drivechaind"] = true

	require.NoError(t, runStart(startContext(t, "photon"), client))

	require.Equal(t, []string{"photon", "enforcer", "bitcoind"}, fake.stopped)
}

func TestStartStopsAChainItOpenedAsAWindow(t *testing.T) {
	fake, client := newFakeOrchestrator(t)
	fake.opensWindow = "photon"

	require.NoError(t, runStart(startContext(t, "photon"), client))

	require.Equal(t, []string{"photon", "enforcer", "bitcoind"}, fake.stopped)
}

func TestStartKeepsL1ForAWindowItDidNotOpen(t *testing.T) {
	fake, client := newFakeOrchestrator(t)
	fake.windowOpen["thunder"] = true

	require.NoError(t, runStart(startContext(t, "photon"), client))

	require.Equal(t, []string{"photon"}, fake.stopped)
	require.True(t, fake.isRunning("bitcoind"))
	require.True(t, fake.isRunning("enforcer"))
}

func TestStartLeavesAnOutsideBackendAlone(t *testing.T) {
	fake, client := newFakeOrchestrator(t)
	fake.portInUse["photon"] = true
	fake.opensWindow = "photon"

	require.NoError(t, runStart(startContext(t, "photon"), client))

	require.Empty(t, fake.stopped)
}

func TestStartStopsATargetThatCrashed(t *testing.T) {
	fake, client := newFakeOrchestrator(t)
	fake.crashesDuringStream = []string{"photon"}

	require.NoError(t, runStart(startContext(t, "photon"), client))

	require.Equal(t, []string{"photon", "enforcer", "bitcoind"}, fake.stopped)
}

func TestStartStopsTheRestAfterAFailedStop(t *testing.T) {
	fake, client := newFakeOrchestrator(t)
	fake.stopFailures["enforcer"] = true

	err := runStart(startContext(t, "photon"), client)

	require.ErrorContains(t, err, "stop enforcer")
	require.Equal(t, []string{"photon", "enforcer", "bitcoind"}, fake.stopped)
	require.False(t, fake.isRunning("bitcoind"))
}

func TestStartDaemonStopsNothing(t *testing.T) {
	fake, client := newFakeOrchestrator(t, "thunder")

	require.NoError(t, runStart(startContext(t, "--daemon", "photon"), client))

	require.Empty(t, fake.stopped)
	require.Zero(t, fake.shutdownAlls)
	require.Equal(t, []string{"bitcoind", "enforcer", "photon", "thunder"}, fake.runningNames())
}

func TestStartWithoutDepsStopsOnlyTheTarget(t *testing.T) {
	fake, client := newFakeOrchestrator(t, "bitcoind", "enforcer")

	require.NoError(t, runStart(startContext(t, "--without-deps", "photon"), client))

	require.Equal(t, []string{"photon"}, fake.stopped)
	require.True(t, fake.isRunning("bitcoind"))
	require.True(t, fake.isRunning("enforcer"))
}

func snapshotOf(daemons ...string) binarySnapshot {
	snapshot := binarySnapshot{
		daemons:    map[string]bool{},
		busy:       map[string]bool{},
		sidechains: map[string]bool{},
	}
	for _, name := range daemons {
		snapshot.daemons[name] = true
		snapshot.busy[name] = true
		if binaryLayers[name] == 2 {
			snapshot.sidechains[name] = true
		}
	}
	return snapshot
}

func TestBinariesToStopOrdersL1Last(t *testing.T) {
	tests := []struct {
		name     string
		target   string
		withDeps bool
		before   binarySnapshot
		now      binarySnapshot
		want     []string
	}{
		{
			name:     "target and both dependencies",
			target:   "photon",
			withDeps: true,
			before:   snapshotOf(),
			now:      snapshotOf("bitcoind", "enforcer", "photon"),
			want:     []string{"photon", "enforcer", "bitcoind"},
		},
		{
			name:     "enforcer as target keeps the shutdown order",
			target:   "enforcer",
			withDeps: true,
			before:   snapshotOf(),
			now:      snapshotOf("bitcoind", "enforcer"),
			want:     []string{"enforcer", "bitcoind"},
		},
		{
			name:     "bitcoind as target appears one time",
			target:   "bitcoind",
			withDeps: true,
			before:   snapshotOf(),
			now:      snapshotOf("bitcoind"),
			want:     []string{"bitcoind"},
		},
		{
			name:     "a target that exited still gets a stop",
			target:   "photon",
			withDeps: false,
			before:   snapshotOf(),
			now:      snapshotOf(),
			want:     []string{"photon"},
		},
		{
			name:     "a target that ran before this start stops nothing",
			target:   "photon",
			withDeps: false,
			before:   snapshotOf("photon"),
			now:      snapshotOf("photon"),
			want:     []string{},
		},
		{
			name:     "a dependency that ran before this start stays up",
			target:   "photon",
			withDeps: true,
			before:   snapshotOf("bitcoind"),
			now:      snapshotOf("bitcoind", "enforcer", "photon"),
			want:     []string{"photon", "enforcer"},
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			require.Equal(t, tt.want, binariesToStop(tt.target, tt.withDeps, tt.before, tt.now))
		})
	}
}

func wipeContext(t *testing.T, argv ...string) *cli.Context {
	t.Helper()

	fs := flag.NewFlagSet("wipe", flag.ContinueOnError)
	for _, f := range wipeCommand.Flags {
		require.NoError(t, f.Apply(fs))
	}
	require.NoError(t, fs.Parse(argv))

	cctx := cli.NewContext(cli.NewApp(), fs, nil)
	cctx.Context = t.Context()
	return cctx
}

func TestWipe(t *testing.T) {
	t.Run("moves wallets to wallet_backups and deletes chain data", func(t *testing.T) {
		config.SetHomeDir(t.TempDir())
		t.Cleanup(func() { config.SetHomeDir("") })

		dir := t.TempDir()
		orch := orchestrator.New(dir, "signet", dir, orchestrator.AllDefaults(), zerolog.Nop())
		t.Cleanup(orch.StopAllMonitors)
		orch.WalletSvc = wallet.NewService(dir, zerolog.Nop())

		networkDir := config.ThunderDirs.DatadirNetwork(config.NetworkSignet, "")
		walletPath := filepath.Join(networkDir, "wallet.mdb")
		dataPath := filepath.Join(networkDir, "data.mdb")
		require.NoError(t, os.MkdirAll(networkDir, 0o755))
		require.NoError(t, os.WriteFile(walletPath, []byte("keys"), 0o600))
		require.NoError(t, os.WriteFile(dataPath, []byte("chain"), 0o600))

		rpcServer := connect.NewServer()

		rpc.RegisterOrchestratorServiceHandler(rpcServer, api.NewHandler(orch))

		handler := http.NewServeMux()

		connecthttp.Mount(handler, rpcServer, connecthttp.WithReadMaxBytes(0))
		server := httptest.NewServer(handler)
		t.Cleanup(server.Close)
		client := rpc.NewOrchestratorServiceClient(connect.NewClient(connecthttp.NewTransport(server.Client(), server.URL, connecthttp.WithReadMaxBytes(0))))

		require.NoError(t, runWipe(wipeContext(t, "--include-wallets", "thunder"), client))

		require.NoFileExists(t, dataPath)
		require.NoFileExists(t, walletPath)
		backups, err := filepath.Glob(filepath.Join(networkDir, "wallet_backups", "*", "wallet.mdb"))
		require.NoError(t, err)
		require.Len(t, backups, 1)
		keys, err := os.ReadFile(backups[0])
		require.NoError(t, err)
		require.Equal(t, "keys", string(keys))
	})

	t.Run("a stop failure aborts before anything is deleted", func(t *testing.T) {
		fake, client := newFakeOrchestrator(t, "thunder")
		fake.stopFailures["thunder"] = true

		err := runWipe(wipeContext(t, "--include-wallets", "thunder"), client)

		require.ErrorContains(t, err, "stop timed out")
		require.Equal(t, []string{"thunder"}, fake.stopped)
	})
}

func TestStartReportsALogStreamFailure(t *testing.T) {
	fake, client := newFakeOrchestrator(t)
	fake.streamErr = connect.NewError(connect.CodeNotFound, "no log for photon")

	require.ErrorContains(t, runStart(startContext(t, "photon"), client), "no log for photon")

	require.Equal(t, []string{"photon", "enforcer", "bitcoind"}, fake.stopped, "a failed stream still stops what start started")
}

func TestStartWaitsForTheTarget(t *testing.T) {
	fake, client := newFakeOrchestrator(t)
	ready := make(chan struct{})
	startRead := make(chan struct{})
	fake.startReady = ready
	fake.startRead = startRead
	release := sync.OnceFunc(func() { close(ready) })
	defer release()

	ctx, cancel := context.WithTimeout(t.Context(), 5*time.Second)
	defer cancel()
	cctx := startContext(t, "photon")
	cctx.Context = ctx
	result := make(chan error, 1)
	go func() { result <- runStart(cctx, client) }()

	select {
	case <-startRead:
	case err := <-result:
		t.Fatalf("start returned before the target became ready: %v", err)
	case <-ctx.Done():
		t.Fatal(ctx.Err())
	}
	require.True(t, fake.isRunning("bitcoind"))
	require.False(t, fake.isRunning("photon"))
	release()
	require.NoError(t, <-result)
	require.Equal(t, []string{"photon", "enforcer", "bitcoind"}, fake.stopped)
}

func TestStartStopsDependenciesAfterStartupFailure(t *testing.T) {
	fake, client := newFakeOrchestrator(t)
	fake.startErr = connect.NewError(connect.CodeInternal, "the target failed to start")

	err := runStart(startContext(t, "photon"), client)

	require.ErrorContains(t, err, "the target failed to start")
	require.Equal(t, []string{"photon", "enforcer", "bitcoind"}, fake.stopped)
}

func TestStartStopsAfterStartupCancel(t *testing.T) {
	for _, tc := range []struct {
		name string
		args []string
		want []string
	}{
		{name: "with dependencies", args: []string{"photon"}, want: []string{"photon", "enforcer", "bitcoind"}},
		{name: "without dependencies", args: []string{"--without-deps", "photon"}, want: []string{"photon"}},
	} {
		t.Run(tc.name, func(t *testing.T) {
			fake, client := newFakeOrchestrator(t)
			startRead := make(chan struct{})
			fake.startReady = make(chan struct{})
			fake.startRead = startRead

			ctx, cancel := context.WithTimeout(t.Context(), 5*time.Second)
			defer cancel()
			cctx := startContext(t, tc.args...)
			cctx.Context = ctx
			result := make(chan error, 1)
			go func() { result <- runStart(cctx, client) }()

			select {
			case <-startRead:
			case err := <-result:
				t.Fatalf("start returned before cancellation: %v", err)
			case <-ctx.Done():
				t.Fatal(ctx.Err())
			}
			cancel()
			require.NoError(t, <-result)
			require.Equal(t, tc.want, fake.stopped)
		})
	}
}
