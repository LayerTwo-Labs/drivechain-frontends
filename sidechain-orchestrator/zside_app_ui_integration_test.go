//go:build integration

package orchestrator_test

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"
	"testing"
	"time"

	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	wmpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	zpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/zside/v1"
	"github.com/stretchr/testify/require"
)

// TestZSideAppUI runs the zSide app's Flutter integration test against a real
// regtest stack. The app talks to this test's drivechaind, and a goroutine
// adds a zSide block every few seconds while the app runs.
//
// Run: ZSIDE_APP_UI=1 ZSIDE_BIN=... ZSIDE_CLI_BIN=... ZSIDE_MAINCHAIN_BITCOIND=... BIP300301_ENFORCER=... \
//
//	ZSIDE_UI_SHOTS=/path/to/shots go test -tags integration -run TestZSideAppUI -v -timeout 40m .
func TestZSideAppUI(t *testing.T) {
	if os.Getenv("ZSIDE_APP_UI") == "" || os.Getenv("ZSIDE_CLI_BIN") == "" {
		t.Skip("set ZSIDE_APP_UI=1 and ZSIDE_CLI_BIN to run the zSide app on this machine")
	}
	flutter := os.Getenv("FLUTTER")
	if flutter == "" {
		flutter = "flutter"
	}
	flutter, err := exec.LookPath(flutter)
	require.NoError(t, err, "find flutter")
	appDir, err := filepath.Abs(filepath.Join("..", "zside"))
	require.NoError(t, err)
	shots := os.Getenv("ZSIDE_UI_SHOTS")
	if shots == "" {
		shots = t.TempDir()
	}
	require.NoError(t, os.MkdirAll(shots, 0o755))

	// Flutter and Xcode keep their caches under the real home.
	realHome, err := os.UserHomeDir()
	require.NoError(t, err)

	ctx, cancel := context.WithTimeout(context.Background(), 38*time.Minute)
	defer cancel()
	stack := startZSideStack(ctx, t, true)

	const depositSats = 50_000_000
	for range 3 {
		require.NoError(t, stack.blindMergeMine(ctx))
	}
	stack.deposit(t, depositSats)
	require.NoError(t, stack.blindMergeMine(ctx))
	balance, err := stack.zside.GetBalance(ctx, &zpb.GetBalanceRequest{})
	require.NoError(t, err)
	require.EqualValues(t, depositSats, balance.TotalTransparentSats)

	withdrawAddr, err := stack.wallets.GetNewAddress(ctx, &wmpb.GetNewAddressRequest{})
	require.NoError(t, err)

	bmmCtx, stopBMM := context.WithCancel(ctx)
	var bmmErr error
	var wg sync.WaitGroup
	wg.Go(func() {
		bmmErr = blindMergeMineEvery(bmmCtx, stack, 4*time.Second)
	})
	stopMining := func() {
		stopBMM()
		wg.Wait()
		require.NoError(t, bmmErr, "background BMM")
	}

	cmd := exec.CommandContext(ctx, flutter, "test", "integration_test/zside_app_test.dart",
		"-d", "macos",
		fmt.Sprintf("--dart-define=ORCHESTRATOR_PORT=%d", orchestratorPort),
		"--dart-define=ZSIDE_UI_WITHDRAW_ADDRESS="+withdrawAddr.Address,
		"--dart-define=ZSIDE_UI_SHOTS="+shots,
	)
	cmd.Dir = appDir
	cmd.Env = append(withHome(os.Environ(), realHome), "ZSIDE_DATADIR="+filepath.Join(stack.home, "zside"))
	var out bytes.Buffer
	cmd.Stdout = &out
	cmd.Stderr = &out
	runErr := cmd.Run()
	t.Logf("--- flutter test output ---\n%s", out.String())
	if runErr != nil {
		stopMining()
		t.Fatalf("flutter test: %v", runErr)
	}
	t.Logf("screenshots in %s", shots)

	// The node bundles withdrawals only at some heights.
	waitFor(t, 3*time.Minute, "a withdrawal bundle that pays the app's withdrawal", func() bool {
		bundle, err := stack.zside.GetPendingWithdrawalBundle(ctx, &zpb.GetPendingWithdrawalBundleRequest{})
		return err == nil && strings.Contains(bundle.BundleJson, fmt.Sprintf(`"main_address":%q`, withdrawAddr.Address))
	})
	stopMining()
}

func blindMergeMineEvery(ctx context.Context, stack *zsideStack, interval time.Duration) error {
	ticker := time.NewTicker(interval)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return nil
		case <-ticker.C:
		}
		if err := stack.blindMergeMine(ctx); err != nil {
			if errors.Is(ctx.Err(), context.Canceled) {
				return nil
			}
			return err
		}
	}
}

func withHome(env []string, home string) []string {
	out := make([]string, 0, len(env))
	for _, kv := range env {
		if strings.HasPrefix(kv, "HOME=") || strings.HasPrefix(kv, "USERPROFILE=") {
			continue
		}
		out = append(out, kv)
	}
	return append(out, "HOME="+home)
}

// startZSideThroughDrivechaind puts the node binaries where drivechaind keeps
// its downloads, and has drivechaind start the node. The app reads the node
// state from drivechaind, which tracks only a node it started.
func startZSideThroughDrivechaind(ctx context.Context, t *testing.T, stack *zsideStack, zsideBin string) {
	t.Helper()
	orchDir := filepath.Join(stack.home, "orchestrator")
	installBinary(t, zsideBin, orchestrator.BinaryPath(orchDir, "thunder-orchard"))
	installBinary(t, os.Getenv("ZSIDE_CLI_BIN"), orchestrator.BinaryPath(orchDir, "thunder-orchard-cli"))

	orch := orchestratorv1connect.NewOrchestratorServiceClient(connect.NewClient(connecthttp.NewTransport(http.DefaultClient, stack.orchURL)))
	_, err := orch.StartWithL1(ctx, &orchpb.StartWithL1Request{
		Target: "zside", Immediate: true, ForceBackend: true,
	})
	require.NoError(t, err, "start zside")

	var status *orchpb.BinaryStatusMsg
	for deadline := time.Now().Add(90 * time.Second); status == nil || !status.Connected; time.Sleep(time.Second) {
		require.False(t, time.Now().After(deadline), "drivechaind never connected to zside: %v", status)
		resp, err := orch.ListBinaries(ctx, &orchpb.ListBinariesRequest{ForceBackend: true})
		require.NoError(t, err, "list binaries")
		for _, b := range resp.Binaries {
			if b.Name == "zside" {
				status = b
			}
		}
	}
}

func installBinary(t *testing.T, src, dst string) {
	t.Helper()
	raw, err := os.ReadFile(src)
	require.NoError(t, err)
	require.NoError(t, os.MkdirAll(filepath.Dir(dst), 0o755))
	require.NoError(t, os.WriteFile(dst, raw, 0o755))
}
