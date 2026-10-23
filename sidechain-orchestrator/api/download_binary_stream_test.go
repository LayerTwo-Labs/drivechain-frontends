package api

import (
	"archive/zip"
	"bytes"
	"context"
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"runtime"
	"strings"
	"sync"
	"testing"
	"time"

	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
)

// h2cServer serves cleartext HTTP/2, which connect-go's gRPC protocol needs.
// Uses net/http's native support in place of the deprecated x/net/http2/h2c.
func h2cServer(h http.Handler) *httptest.Server {
	srv := httptest.NewUnstartedServer(h)
	srv.Config.Protocols = new(http.Protocols)
	srv.Config.Protocols.SetHTTP1(true)
	srv.Config.Protocols.SetUnencryptedHTTP2(true)
	srv.Start()
	return srv
}

// h2cClient dials cleartext HTTP/2 by prior knowledge.
func h2cClient() *http.Client {
	tr := &http.Transport{Protocols: new(http.Protocols)}
	tr.Protocols.SetUnencryptedHTTP2(true)
	return &http.Client{Transport: tr}
}

// TestDownloadBinary_DispatchesAndCompletes is the regression guard for the
// unary DownloadBinary contract: the RPC returns immediately, the goroutine
// runs in the background, and the binary lands on disk eventually. Progress
// is no longer streamed back to the client — that's polled out of
// GetSyncStatus / DownloadManager.State, which is exercised elsewhere.
func TestDownloadBinary_DispatchesAndCompletes(t *testing.T) {
	bigBinary := bytes.Repeat([]byte("x"), 5*1024*1024)
	payload := makeZipBytes(t, map[string][]byte{"streamtest": bigBinary})
	binarySrv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Length", fmt.Sprintf("%d", len(payload)))
		if r.Method == http.MethodHead {
			w.WriteHeader(http.StatusOK)
			return
		}
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write(payload)
	}))
	defer binarySrv.Close()

	orch := newTestOrchHandlerWithBinary(t, orchestrator.BinaryConfig{
		Name:           "streamtest",
		BinaryName:     "streamtest",
		DownloadSource: orchestrator.DownloadSourceDirect,
		DownloadURLs:   map[string]string{"default": binarySrv.URL + "/"},
		Files:          map[string]string{currentPlatform(): "streamtest.zip"},
	})

	mux := http.NewServeMux()
	rpcServer := connect.NewServer()
	rpc.RegisterOrchestratorServiceHandler(rpcServer, NewHandler(orch))
	connecthttp.Mount(mux, rpcServer, connecthttp.WithReadMaxBytes(0))
	connectSrv := h2cServer(mux)
	defer connectSrv.Close()

	client := rpc.NewOrchestratorServiceClient(connect.NewClient(connecthttp.NewTransport(h2cClient(), connectSrv.URL, connecthttp.WithReadMaxBytes(0), connecthttp.WithGRPC())))

	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()

	// Unary call returns immediately — boot goroutine runs server-side.
	resp, err := client.DownloadBinary(ctx, &pb.DownloadBinaryRequest{
		Name:  "streamtest",
		Force: true,
	})
	require.NoError(t, err)
	require.NotNil(t, resp)

	// The download is now off-thread; spin until it lands or we hit timeout.
	deadline := time.Now().Add(20 * time.Second)
	for {
		if time.Now().After(deadline) {
			t.Fatalf("timed out waiting for download to complete")
		}
		// State stays populated while running and is deleted on completion.
		_, running := orch.DownloadStateForTest("streamtest")
		if !running {
			break
		}
		time.Sleep(50 * time.Millisecond)
	}
}

// TestDownloadBinary_RejectsUnknownBinary confirms the handler returns an
// error directly — the goroutine never gets dispatched.
func TestDownloadBinary_RejectsUnknownBinary(t *testing.T) {
	orch := newTestOrchHandlerWithBinary(t, orchestrator.BinaryConfig{
		Name:           "streamtest",
		BinaryName:     "streamtest",
		DownloadSource: orchestrator.DownloadSourceDirect,
		DownloadURLs:   map[string]string{"default": "http://example.invalid/"},
		Files:          map[string]string{currentPlatform(): "streamtest.zip"},
	})
	mux := http.NewServeMux()
	rpcServer := connect.NewServer()
	rpc.RegisterOrchestratorServiceHandler(rpcServer, NewHandler(orch))
	connecthttp.Mount(mux, rpcServer, connecthttp.WithReadMaxBytes(0))
	srv := h2cServer(mux)
	defer srv.Close()

	client := rpc.NewOrchestratorServiceClient(connect.NewClient(connecthttp.NewTransport(h2cClient(), srv.URL, connecthttp.WithReadMaxBytes(0), connecthttp.WithGRPC())))
	_, err := client.DownloadBinary(context.Background(), &pb.DownloadBinaryRequest{
		Name: "no-such-binary",
	})
	require.Error(t, err, "unknown binary must surface as an RPC error")
}

func TestStartWithL1WaitsForResult(t *testing.T) {
	home := config.HomeDir()
	config.SetHomeDir(t.TempDir())
	t.Cleanup(func() { config.SetHomeDir(home) })

	for _, tc := range []struct {
		name  string
		layer int
		err   string
	}{
		{name: "bitcoind", layer: 1},
		{name: "bbc", layer: 2, err: "does not support a remote enforcer"},
	} {
		t.Run(tc.name, func(t *testing.T) {
			orch := newTestOrchHandlerWithBinary(t, orchestrator.BinaryConfig{
				Name: tc.name, BinaryName: tc.name, ChainLayer: tc.layer, IsBitcoinCore: true,
			})
			require.NoError(t, orchestrator.WriteNodeMode(orch.BitwindowDir, orchestrator.NodeModeLight))
			client, stop := startTestOrchService(t, orch)
			defer stop()

			response, err := client.StartWithL1(t.Context(), &pb.StartWithL1Request{Target: tc.name, Wait: true})

			if tc.err != "" {
				require.ErrorContains(t, err, tc.err)
				require.Nil(t, response)
				return
			}
			require.NoError(t, err)
			require.NotNil(t, response)
		})
	}
}

func TestStartWithL1KeepsRequestContext(t *testing.T) {
	home := config.HomeDir()
	config.SetHomeDir(t.TempDir())
	t.Cleanup(func() { config.SetHomeDir(home) })

	for _, wait := range []bool{false, true} {
		t.Run(fmt.Sprintf("wait=%t", wait), func(t *testing.T) {
			started := make(chan struct{})
			stopped := make(chan error, 1)
			release := make(chan struct{})
			var releaseOnce sync.Once
			binaryServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				if r.Method == http.MethodHead {
					w.WriteHeader(http.StatusOK)
					return
				}
				close(started)
				select {
				case <-release:
					stopped <- r.Context().Err()
					http.Error(w, "download refused", http.StatusServiceUnavailable)
				case <-r.Context().Done():
					stopped <- r.Context().Err()
				}
			}))
			defer binaryServer.Close()
			defer releaseOnce.Do(func() { close(release) })

			orch := newTestOrchHandlerWithBinary(t, orchestrator.BinaryConfig{
				Name:           "boottest",
				BinaryName:     "boottest",
				DownloadSource: orchestrator.DownloadSourceDirect,
				DownloadURLs:   map[string]string{"default": binaryServer.URL + "/"},
				Files:          map[string]string{currentPlatform(): "boottest.zip"},
			})
			require.NoError(t, orchestrator.WriteNodeMode(orch.BitwindowDir, orchestrator.NodeModeFull))
			t.Cleanup(func() {
				waitForDownloadEnd(t, orch, "boottest")
				orch.StopAllMonitors()
			})
			client, stop := startTestOrchService(t, orch)
			defer stop()
			ctx, cancel := context.WithTimeout(t.Context(), eventuallyTimeout)
			defer cancel()
			done := make(chan error, 1)
			go func() {
				_, err := client.StartWithL1(ctx, &pb.StartWithL1Request{Target: "boottest", Immediate: true, Wait: wait})
				done <- err
			}()

			select {
			case <-started:
			case <-ctx.Done():
				t.Fatal("the download did not start")
			}
			if wait {
				select {
				case err := <-done:
					t.Fatalf("startup returned before the download: %v", err)
				default:
				}
				cancel()
				require.Equal(t, connect.CodeCanceled, connect.CodeOf(<-done))
				select {
				case err := <-stopped:
					require.ErrorIs(t, err, context.Canceled)
				case <-time.After(eventuallyTimeout):
					t.Fatal("the request did not cancel the download")
				}
				return
			}
			require.NoError(t, <-done)
			cancel()
			releaseOnce.Do(func() { close(release) })
			require.NoError(t, <-stopped)
		})
	}
}

func TestStartWithL1KeepsMonitorAfterSuccess(t *testing.T) {
	home := config.HomeDir()
	config.SetHomeDir(t.TempDir())
	t.Cleanup(func() { config.SetHomeDir(home) })

	responseDone := make(chan struct{})
	checked := make(chan struct{})
	var checkOnce sync.Once
	healthServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		select {
		case <-responseDone:
			checkOnce.Do(func() { close(checked) })
		default:
		}
		if _, err := io.WriteString(w, `{"result":1,"error":null}`); err != nil {
			t.Error(err)
		}
	}))
	defer healthServer.Close()
	host, port := hostPort(t, healthServer)
	orch := newTestOrchHandlerWithBinary(t, orchestrator.BinaryConfig{
		Name: "boottest", BinaryName: "boottest", Host: host, Port: port,
		HealthCheckType: orchestrator.HealthCheckJSONRPC,
	})
	defer orch.StopAllMonitors()
	require.NoError(t, orchestrator.WriteNodeMode(orch.BitwindowDir, orchestrator.NodeModeFull))
	client, stop := startTestOrchService(t, orch)
	defer stop()
	ctx, cancel := context.WithCancel(t.Context())
	defer cancel()

	response, err := client.StartWithL1(ctx, &pb.StartWithL1Request{Target: "boottest", Immediate: true, Wait: true})

	require.NoError(t, err)
	require.NotNil(t, response)
	cancel()
	close(responseDone)
	select {
	case <-checked:
	case <-time.After(eventuallyTimeout):
		t.Fatal("the monitor stopped after the startup response")
	}
}

func TestStartWithL1KeepsCoreMonitorAfterFailure(t *testing.T) {
	home := config.HomeDir()
	config.SetHomeDir(t.TempDir())
	t.Cleanup(func() { config.SetHomeDir(home) })

	responseDone := make(chan struct{})
	checked := make(chan struct{})
	var checkOnce sync.Once
	healthServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		select {
		case <-responseDone:
			checkOnce.Do(func() { close(checked) })
		default:
		}
		if _, err := io.WriteString(w, `{"result":1,"error":null}`); err != nil {
			t.Error(err)
		}
	}))
	defer healthServer.Close()
	host, port := hostPort(t, healthServer)
	coreConfig := orchestrator.BinaryConfig{
		Name: "bitcoind", BinaryName: "boottest-core", ChainLayer: 1, Host: host, Port: port,
		HealthCheckType: orchestrator.HealthCheckJSONRPC,
	}
	orch := newTestOrchHandlerWithBinary(t, coreConfig)
	orch.BitcoinConf.Config.SetSetting("rpcuser", "test")
	orch.BitcoinConf.Config.SetSetting("rpcpassword", "test")
	orch.UpdateConfigs([]orchestrator.BinaryConfig{
		coreConfig,
		{Name: "boottest", BinaryName: "boottest", ChainLayer: 2},
	})
	defer orch.StopAllMonitors()
	require.NoError(t, orchestrator.WriteNodeMode(orch.BitwindowDir, orchestrator.NodeModeFull))
	client, stop := startTestOrchService(t, orch)
	defer stop()
	_, err := client.StartWithL1(t.Context(), &pb.StartWithL1Request{Target: "bitcoind", Immediate: true, Wait: true})
	require.NoError(t, err)

	_, err = client.StartWithL1(t.Context(), &pb.StartWithL1Request{Target: "boottest", Wait: true})

	require.ErrorContains(t, err, "no download available for boottest")
	close(responseDone)
	select {
	case <-checked:
	case <-time.After(eventuallyTimeout):
		t.Fatal("the Core monitor stopped after the target failed")
	}
}

func TestStreamLogsAfterExit(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("the test executable uses a shell")
	}
	home := config.HomeDir()
	config.SetHomeDir(t.TempDir())
	t.Cleanup(func() { config.SetHomeDir(home) })

	orch := newTestOrchHandlerWithBinary(t, orchestrator.BinaryConfig{
		Name: "logtest", BinaryName: "logtest",
	})
	require.NoError(t, os.MkdirAll(orchestrator.BinDir(orch.DataDir), 0o700))
	require.NoError(t, os.WriteFile(orchestrator.BinaryPath(orch.DataDir, "logtest"),
		[]byte("#!/bin/sh\nprintf 'Error: wallet error\\nCaused by: test database error\\n' >&2\nexit 1\n"), 0o700))
	_, err := orch.Start(t.Context(), "logtest", nil, nil)
	if err != nil {
		require.ErrorContains(t, err, "exited immediately (code 1)")
	}
	require.Eventually(t, func() bool {
		return !orch.Status("logtest").Running
	}, 5*time.Second, 10*time.Millisecond)

	client, stop := startTestOrchService(t, orch)
	defer stop()
	ctx, cancel := context.WithTimeout(t.Context(), 5*time.Second)
	defer cancel()
	stream, err := client.StreamLogs(ctx, &pb.StreamLogsRequest{Name: "logtest", Tail: 100})
	require.NoError(t, err)
	defer func() { require.NoError(t, stream.Close()) }()

	var stderr []string
	for {
		entry, err := stream.Receive()
		if err != nil {
			var streamErr *connect.Error
			require.ErrorAs(t, err, &streamErr)
			require.Equal(t, connect.CodeUnknown, streamErr.Code())
			break
		}
		if entry.Stream == "stderr" {
			stderr = append(stderr, entry.Line)
		}
	}
	require.Equal(t, []string{"Error: wallet error", "Caused by: test database error"}, stderr)
}

func TestStartWithL1DoesNotStartAfterCancellation(t *testing.T) {
	if runtime.GOOS == "windows" {
		t.Skip("the test executable uses a shell")
	}
	home := config.HomeDir()
	config.SetHomeDir(t.TempDir())
	t.Cleanup(func() { config.SetHomeDir(home) })

	started := make(chan struct{})
	release := make(chan struct{})
	var firstCheck, releaseOnce sync.Once
	healthServer := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		firstCheck.Do(func() {
			close(started)
			<-release
		})
		http.Error(w, "not ready", http.StatusServiceUnavailable)
	}))
	defer healthServer.Close()
	defer releaseOnce.Do(func() { close(release) })
	host, port := hostPort(t, healthServer)
	orch := newTestOrchHandlerWithBinary(t, orchestrator.BinaryConfig{
		Name: "boottest", BinaryName: "boottest", Host: host, Port: port,
		HealthCheckType: orchestrator.HealthCheckJSONRPC,
	})
	t.Cleanup(func() {
		orch.StopAllMonitors()
		require.NoError(t, orch.Stop(context.Background(), "boottest", false))
	})
	require.NoError(t, orchestrator.WriteNodeMode(orch.BitwindowDir, orchestrator.NodeModeFull))
	marker := filepath.Join(t.TempDir(), "started")
	require.NoError(t, os.MkdirAll(orchestrator.BinDir(orch.DataDir), 0o700))
	require.NoError(t, os.WriteFile(orchestrator.BinaryPath(orch.DataDir, "boottest"), []byte("#!/bin/sh\n: > \"$BOOT_MARKER\"\nexec sleep 30\n"), 0o700))
	client, stop := startTestOrchService(t, orch)
	defer stop()
	ctx, cancel := context.WithTimeout(t.Context(), eventuallyTimeout)
	defer cancel()
	done := make(chan error, 1)
	go func() {
		_, err := client.StartWithL1(ctx, &pb.StartWithL1Request{
			Target: "boottest", Immediate: true, Wait: true, TargetEnv: map[string]string{"BOOT_MARKER": marker},
		})
		done <- err
	}()

	select {
	case <-started:
	case err := <-done:
		t.Fatalf("startup returned before the health check: %v", err)
	case <-ctx.Done():
		t.Fatal("the health check did not start")
	}
	cancel()
	require.Equal(t, connect.CodeCanceled, connect.CodeOf(<-done))
	_, err := client.StopBinary(t.Context(), &pb.StopBinaryRequest{Name: "boottest"})
	require.NoError(t, err)
	releaseOnce.Do(func() { close(release) })

	require.Eventually(t, func() bool {
		return strings.Contains(orch.Status("boottest").ConnectionError, context.Canceled.Error())
	}, eventuallyTimeout, eventuallyPoll)
	require.False(t, orch.Status("boottest").Running)
	require.NoFileExists(t, marker)
}

// newTestOrchHandlerWithBinary builds a minimal Orchestrator wired with a
// single binary config — enough for DownloadBinary to walk through the
// download path without touching the rest of the configs.
func newTestOrchHandlerWithBinary(t *testing.T, cfg orchestrator.BinaryConfig) *orchestrator.Orchestrator {
	t.Helper()
	log := zerolog.New(io.Discard)
	o := orchestrator.New(t.TempDir(), "signet", t.TempDir(), []orchestrator.BinaryConfig{cfg}, log)
	return o
}

// currentPlatform mirrors orchestrator.currentPlatform — duplicated because
// the helper is unexported in the orchestrator package and we need the same
// os-arch key shape in BinaryConfig.Files for the orch's download lookup to match.
func currentPlatform() string {
	var os string
	switch runtime.GOOS {
	case "darwin":
		os = "macos"
	case "windows":
		os = "windows"
	default:
		os = "linux"
	}
	arch := "x86_64"
	if runtime.GOARCH == "arm64" {
		arch = "arm64"
	}
	return os + "-" + arch
}

// makeZipBytes builds an in-memory zip archive — duplicated from the
// orchestrator package's test helpers since those aren't exported.
func makeZipBytes(t *testing.T, files map[string][]byte) []byte {
	t.Helper()
	var buf bytes.Buffer
	w := zip.NewWriter(&buf)
	for name, content := range files {
		f, err := w.Create(name)
		require.NoError(t, err)
		_, err = f.Write(content)
		require.NoError(t, err)
	}
	require.NoError(t, w.Close())
	return buf.Bytes()
}
