package commands

import (
	"context"
	"errors"
	"flag"
	"net/http/httptest"
	"sort"
	"sync"
	"testing"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	"github.com/stretchr/testify/require"
	"github.com/urfave/cli/v2"
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

func (f *fakeOrchestrator) ListBinaries(_ context.Context, _ *connect.Request[pb.ListBinariesRequest]) (*connect.Response[pb.ListBinariesResponse], error) {
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
	return connect.NewResponse(resp), nil
}

func (f *fakeOrchestrator) GetBinaryStatus(_ context.Context, req *connect.Request[pb.GetBinaryStatusRequest]) (*connect.Response[pb.GetBinaryStatusResponse], error) {
	return connect.NewResponse(&pb.GetBinaryStatusResponse{
		Status: &pb.BinaryStatusMsg{Name: req.Msg.Name, Downloaded: true, Downloadable: true},
	}), nil
}

func (f *fakeOrchestrator) StartWithL1(_ context.Context, req *connect.Request[pb.StartWithL1Request]) (*connect.Response[pb.StartWithL1Response], error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.running["bitcoind"] = true
	f.running["enforcer"] = true
	if f.opensWindow == req.Msg.Target {
		f.windowOpen[req.Msg.Target] = true
	} else {
		f.running[req.Msg.Target] = true
	}
	return connect.NewResponse(&pb.StartWithL1Response{}), nil
}

func (f *fakeOrchestrator) StartBinary(_ context.Context, req *connect.Request[pb.StartBinaryRequest]) (*connect.Response[pb.StartBinaryResponse], error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.running[req.Msg.Name] = true
	return connect.NewResponse(&pb.StartBinaryResponse{Pid: 1234}), nil
}

// StreamLogs ends at once, which is the ctrl+c path the user hits.
func (f *fakeOrchestrator) StreamLogs(_ context.Context, _ *connect.Request[pb.StreamLogsRequest], _ *connect.ServerStream[pb.StreamLogsResponse]) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	for _, name := range f.startsDuringStream {
		f.running[name] = true
	}
	for _, name := range f.crashesDuringStream {
		delete(f.running, name)
	}
	return nil
}

func (f *fakeOrchestrator) StopBinary(_ context.Context, req *connect.Request[pb.StopBinaryRequest]) (*connect.Response[pb.StopBinaryResponse], error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.stopped = append(f.stopped, req.Msg.Name)
	if f.stopFailures[req.Msg.Name] {
		return nil, connect.NewError(connect.CodeInternal, errors.New("stop timed out"))
	}
	delete(f.running, req.Msg.Name)
	delete(f.windowOpen, req.Msg.Name)
	return connect.NewResponse(&pb.StopBinaryResponse{}), nil
}

func (f *fakeOrchestrator) ShutdownAll(_ context.Context, _ *connect.Request[pb.ShutdownAllRequest], stream *connect.ServerStream[pb.ShutdownAllResponse]) error {
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

	_, handler := rpc.NewOrchestratorServiceHandler(fake)
	server := httptest.NewServer(handler)
	t.Cleanup(server.Close)

	return fake, rpc.NewOrchestratorServiceClient(server.Client(), server.URL)
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
