//go:build integration

package orchestrator_test

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	bmmpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bmm/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bmm/v1/bmmv1connect"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	wmpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	"github.com/stretchr/testify/require"
)

// Fixed because drivechaind resolves both from chains_config.json rather than
// from anything the test can pass in, so no stack may already be running.
const (
	enforcerPort = 50051
	bbcPort      = 18743

	mainchainRPCPort = 19443
	mainchainZMQPort = 29332
	orchestratorPort = 30411

	bbcSlot = 1
)

// TestBbcBMM blind merge mines the Bbc sidechain through
// drivechaind, which is the path the frontends drive: CreateBid asks the
// sidechain node for a block template and pays for its commitment on the
// mainchain, then ConnectBid submits the block once a miner takes the bid.
//
// Needs two binaries, supplied via env; drivechaind is built from source:
//
//	BBC_BITCOIND - bitcoind from the covenant-sidechain fork
//	BIP300301_ENFORCER   - bip300301_enforcer
//
// Run: BBC_BITCOIND=... BIP300301_ENFORCER=... \
//
//	go test -tags integration -run TestBbcBMM ./...
func TestBbcBMM(t *testing.T) {
	bitcoind := os.Getenv("BBC_BITCOIND")
	enforcerBin := os.Getenv("BIP300301_ENFORCER")
	if bitcoind == "" || enforcerBin == "" {
		t.Skip("set BBC_BITCOIND and BIP300301_ENFORCER to run")
	}

	// drivechaind exits 0 when its port is already bound, and the enforcer's
	// readiness probe cannot tell a daemon it started from one it did not. Left
	// unchecked the test would silently drive the developer's live stack.
	requirePortsFree(t, mainchainRPCPort, mainchainZMQPort, enforcerPort, bbcPort, orchestratorPort)

	// Built before HOME moves, so the Go build cache stays where it is.
	orchBin := buildDrivechaind(t)

	// drivechaind and the sidechain node both resolve their datadirs from the
	// home directory, and the test then reads the same cookie they write.
	home := t.TempDir()
	t.Setenv("HOME", home)
	t.Setenv("USERPROFILE", home)

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Minute)
	defer cancel()

	mainDir := filepath.Join(home, "mainchain")
	require.NoError(t, os.MkdirAll(mainDir, 0o700))

	// Consensus Cleanup is renounced because the enforcer's block producer
	// builds a plain coinbase, which BIP54's nLockTime rule rejects; a real
	// deployment runs stock Core as the mainchain.
	startProcess(t, "mainchain", bitcoind,
		"-regtest", "-datadir="+mainDir, "-server", "-rest", "-txindex",
		fmt.Sprintf("-rpcport=%d", mainchainRPCPort), "-port=19444",
		"-fallbackfee=0.0001", "-renounce=consensuscleanup",
		fmt.Sprintf("-zmqpubsequence=tcp://127.0.0.1:%d", mainchainZMQPort),
	)
	cookiePath := filepath.Join(mainDir, "regtest", ".cookie")
	waitFor(t, 60*time.Second, "mainchain cookie", func() bool {
		_, err := os.Stat(cookiePath)
		return err == nil
	})
	cookie, err := os.ReadFile(cookiePath)
	require.NoError(t, err)
	user, password, ok := bytes.Cut(cookie, []byte(":"))
	require.True(t, ok, "malformed cookie %q", cookie)

	enforcerDir := filepath.Join(home, "enforcer")
	require.NoError(t, os.MkdirAll(enforcerDir, 0o700))
	startProcess(t, "enforcer", enforcerBin,
		"--data-dir="+enforcerDir,
		fmt.Sprintf("--node-rpc-addr=127.0.0.1:%d", mainchainRPCPort),
		"--node-rpc-user="+string(user), "--node-rpc-pass="+string(password),
		fmt.Sprintf("--node-zmq-addr-sequence=tcp://127.0.0.1:%d", mainchainZMQPort),
		fmt.Sprintf("--serve-grpc-addr=127.0.0.1:%d", enforcerPort),
		"--enable-block-template-server",
		// BDK syncs from an Esplora server we do not run; on regtest the ZMQ
		// block stream is enough.
		"--wallet-sync-source=disabled", "--wallet-auto-create",
	)
	enforcer := &jsonClient{base: fmt.Sprintf("http://127.0.0.1:%d/cusf.mainchain.v1.", enforcerPort)}
	waitFor(t, 90*time.Second, "enforcer", func() bool {
		return enforcer.call(ctx, "ValidatorService/GetChainTip", map[string]any{}, nil) == nil
	})

	activateSlot(ctx, t, enforcer)

	inqDir := config.BbcDirs.RootDir()
	require.NoError(t, os.MkdirAll(inqDir, 0o700))
	startProcess(t, "bbc", bitcoind,
		"-regtest", "-datadir="+inqDir, "-listen=0",
		fmt.Sprintf("-rpcport=%d", bbcPort),
		fmt.Sprintf("-sidechainslot=%d", bbcSlot),
		fmt.Sprintf("-enforcerport=%d", enforcerPort),
		"-fallbackfee=0.0001",
	)
	sidechain := newCoreRPC(t, config.BbcDirs.DatadirNetwork(config.NetworkRegtest, ""), bbcPort)
	waitFor(t, 90*time.Second, "sidechain peg sync", func() bool {
		var info struct {
			Synced bool `json:"synced"`
		}
		return sidechain.call(ctx, "getsidechaininfo", nil, &info) == nil && info.Synced
	})

	startOrchestrator(t, orchBin, home, mainDir)
	httpClient := &http.Client{Timeout: 60 * time.Second}
	orchURL := fmt.Sprintf("http://127.0.0.1:%d", orchestratorPort)
	wallets := walletmanagerv1connect.NewWalletManagerServiceClient(httpClient, orchURL)
	bmm := bmmv1connect.NewBMMServiceClient(httpClient, orchURL)
	waitFor(t, 60*time.Second, "drivechaind", func() bool {
		_, err := wallets.GetWalletStatus(ctx, connect.NewRequest(&wmpb.GetWalletStatusRequest{}))
		return err == nil
	})

	// The first wallet is the enforcer's; only a Bitcoin Core wallet can build
	// the bare scriptPubKey an M8 request needs, so bidding runs on a second.
	generateWallet(ctx, t, wallets, "enforcer")
	coreWallet := generateWallet(ctx, t, wallets, "core")
	_, err = wallets.SwitchWallet(ctx, connect.NewRequest(&wmpb.SwitchWalletRequest{WalletId: coreWallet}))
	require.NoError(t, err)

	addr, err := wallets.GetNewAddress(ctx, connect.NewRequest(&wmpb.GetNewAddressRequest{}))
	require.NoError(t, err)
	mineMainchain(ctx, t, enforcer, 150, addr.Msg.Address)
	waitFor(t, 60*time.Second, "bidding funds", func() bool {
		bal, err := wallets.GetBalance(ctx, connect.NewRequest(&wmpb.GetBalanceRequest{}))
		return err == nil && bal.Msg.ConfirmedSats > 0
	})

	var height int64
	require.NoError(t, sidechain.call(ctx, "getblockcount", nil, &height))
	require.Zero(t, height, "sidechain should start empty")

	blindMergeMine := func(cycle int64) {
		bid, err := bmm.CreateBid(ctx, connect.NewRequest(&bmmpb.CreateBidRequest{
			Sidechain: orchpb.BinaryType_BINARY_TYPE_BBC,
			BidSats:   1000,
		}))
		require.NoError(t, err, "cycle %d: create bid", cycle)
		require.NotEmpty(t, bid.Msg.BmmTxid, "bid must be broadcast on the mainchain")
		require.NotEmpty(t, bid.Msg.PrevMainHash)

		mineMainchain(ctx, t, enforcer, 1, addr.Msg.Address)

		// The sidechain node has to see the commitment in the new mainchain
		// block before it will accept the block, and it learns that by polling.
		var connected *bmmpb.ConnectBidResponse
		waitFor(t, 60*time.Second, "bid inclusion", func() bool {
			resp, err := bmm.ConnectBid(ctx, connect.NewRequest(&bmmpb.ConnectBidRequest{
				Sidechain:    orchpb.BinaryType_BINARY_TYPE_BBC,
				CriticalHash: bid.Msg.CriticalHash,
				BlockJson:    bid.Msg.BlockJson,
			}))
			if err != nil || !resp.Msg.Connected {
				return false
			}
			connected = resp.Msg
			return true
		})
		require.NotEmpty(t, connected.MainBlockHash)

		require.NoError(t, sidechain.call(ctx, "getblockcount", nil, &height))
		require.Equal(t, cycle, height, "cycle %d should have extended the sidechain", cycle)
	}

	for i := int64(1); i <= 3; i++ {
		blindMergeMine(i)
	}

	// A deposit through the same RPC BitWindow calls. The M5 pays an
	// OP_DRIVECHAIN treasury output, which relays only because this build
	// treats it as standard -- the mainchain node runs no -acceptnonstdtxn.
	const depositSats = 50_000_000
	require.NoError(t, sidechain.call(ctx, "createwallet", []any{"deposit"}, nil))
	var sideAddress string
	require.NoError(t, sidechain.call(ctx, "getnewaddress", nil, &sideAddress))

	deposit, err := wallets.CreateDeposit(ctx, connect.NewRequest(&wmpb.CreateDepositRequest{
		Slot:        bbcSlot,
		Destination: sideAddress,
		AmountSats:  depositSats,
		FeeSats:     10_000,
	}))
	require.NoError(t, err, "create deposit")
	require.NotEmpty(t, deposit.Msg.Txid)
	require.EqualValues(t, depositSats, deposit.Msg.TreasurySats, "first deposit starts the treasury")

	// The deposit must confirm at or below the mainchain tip the next template
	// builds on, or it falls outside the range that coinbase covers.
	mineMainchain(ctx, t, enforcer, 1, addr.Msg.Address)
	blindMergeMine(4)

	var addressInfo struct {
		ScriptPubKey string `json:"scriptPubKey"`
	}
	require.NoError(t, sidechain.call(ctx, "getaddressinfo", []any{sideAddress}, &addressInfo))

	var credited string
	require.NoError(t, sidechain.call(ctx, "getblockhash", []any{4}, &credited))
	var deposited struct {
		Tx []struct {
			Vout []struct {
				Value        float64 `json:"value"`
				ScriptPubKey struct {
					Hex string `json:"hex"`
				} `json:"scriptPubKey"`
			} `json:"vout"`
		} `json:"tx"`
	}
	require.NoError(t, sidechain.call(ctx, "getblock", []any{credited, 2}, &deposited))
	var paid float64
	for _, out := range deposited.Tx[0].Vout {
		if out.ScriptPubKey.Hex == addressInfo.ScriptPubKey {
			paid += out.Value
		}
	}
	require.InDelta(t, float64(depositSats)/1e8, paid, 1e-9, "deposit must credit the destination")

	// Every satoshi on this chain arrives through the peg, so with no deposits
	// and no fees the coinbase of a blind merge mined block pays nothing.
	var hash string
	require.NoError(t, sidechain.call(ctx, "getblockhash", []any{3}, &hash))
	var block struct {
		Tx []struct {
			Vout []struct {
				Value float64 `json:"value"`
			} `json:"vout"`
		} `json:"tx"`
	}
	require.NoError(t, sidechain.call(ctx, "getblock", []any{hash, 2}, &block))
	// The miner's fee output, the BMM commitment, and the witness commitment
	// Core appends. Deposits, of which this test makes none, would add more.
	require.Len(t, block.Tx[0].Vout, 3)
	var total float64
	for _, out := range block.Tx[0].Vout {
		total += out.Value
	}
	require.Zero(t, total, "sidechain coinbase must not mint")
}

func activateSlot(ctx context.Context, t *testing.T, enforcer *jsonClient) {
	t.Helper()

	address := struct {
		Address string `json:"address"`
	}{}
	require.NoError(t, enforcer.call(ctx, "WalletService/CreateNewAddress", map[string]any{}, &address))
	mineMainchain(ctx, t, enforcer, 101, address.Address)

	require.NoError(t, enforcer.call(ctx, "BlockProducerService/SubmitSidechainProposal", map[string]any{
		"sidechainId": bbcSlot,
		"declaration": map[string]any{
			"v0": map[string]any{
				"title":       "Big Block Covenant",
				"description": "Covenant sidechain",
				"hashId1":     map[string]any{"hex": repeatHex("11", 32)},
				"hashId2":     map[string]any{"hex": repeatHex("22", 20)},
			},
		},
	}, nil))
	// The field is ack_all; a wrong key here is silently ignored and the
	// proposal expires without ever gaining a vote.
	require.NoError(t, enforcer.call(ctx, "BlockProducerService/SetAckAllProposals",
		map[string]any{"ackAll": true}, nil))

	for i := 0; i < 12; i++ {
		mineMainchain(ctx, t, enforcer, 1, address.Address)
		var active struct {
			Sidechains []struct {
				SidechainNumber int `json:"sidechainNumber"`
			} `json:"sidechains"`
		}
		require.NoError(t, enforcer.call(ctx, "ValidatorService/GetSidechains", map[string]any{}, &active))
		for _, s := range active.Sidechains {
			if s.SidechainNumber == bbcSlot {
				return
			}
		}
	}
	t.Fatalf("slot %d never activated", bbcSlot)
}

// mineMainchain mines through the enforcer so coinbases carry its M1/M2 messages.
func mineMainchain(ctx context.Context, t *testing.T, enforcer *jsonClient, blocks int, address string) {
	t.Helper()
	require.NoError(t, enforcer.call(ctx, "MiningService/GenerateToAddress", map[string]any{
		"blocks": blocks, "address": address,
	}, nil))
}

func generateWallet(
	ctx context.Context, t *testing.T,
	wallets walletmanagerv1connect.WalletManagerServiceClient, name string,
) string {
	t.Helper()
	resp, err := wallets.GenerateWallet(ctx, connect.NewRequest(&wmpb.GenerateWalletRequest{Name: name}))
	require.NoError(t, err)
	return resp.Msg.WalletId
}

func buildDrivechaind(t *testing.T) string {
	t.Helper()
	bin := filepath.Join(t.TempDir(), "drivechaind")
	out, err := exec.Command("go", "build", "-o", bin, "./cmd/drivechaind").CombinedOutput()
	require.NoError(t, err, "build drivechaind: %s", out)
	return bin
}

func startOrchestrator(t *testing.T, bin, home, mainchainDir string) {
	t.Helper()

	// Points the Core wallet backend at the mainchain this test started rather
	// than at the platform default datadir.
	bitwindowDir := filepath.Join(home, "bitwindow")
	require.NoError(t, os.MkdirAll(bitwindowDir, 0o700))
	conf := fmt.Sprintf("chain=regtest\n[regtest]\ndatadir=%s\nrpcport=%d\n", mainchainDir, mainchainRPCPort)
	require.NoError(t, os.WriteFile(filepath.Join(bitwindowDir, "bitwindow-bitcoin.conf"), []byte(conf), 0o600))

	startProcess(t, "drivechaind", bin,
		"--network", "regtest",
		"--bitwindow-dir", bitwindowDir,
		"--datadir", filepath.Join(home, "orchestrator"),
		"--local-auth=false",
		"--rpclisten", fmt.Sprintf("localhost:%d", orchestratorPort),
	)
}

func startProcess(t *testing.T, name, bin string, args ...string) {
	t.Helper()

	logFile, err := os.Create(filepath.Join(t.TempDir(), name+".log"))
	require.NoError(t, err)

	cmd := exec.Command(bin, args...)
	cmd.Env = os.Environ()
	cmd.Stdout = logFile
	cmd.Stderr = logFile
	require.NoError(t, cmd.Start(), "start %s", name)

	t.Cleanup(func() {
		_ = cmd.Process.Kill()
		_, _ = cmd.Process.Wait()
		logFile.Close()
		if t.Failed() {
			if contents, err := os.ReadFile(logFile.Name()); err == nil {
				t.Logf("--- %s log ---\n%s", name, contents)
			}
		}
	})
}

func requirePortsFree(t *testing.T, ports ...int) {
	t.Helper()
	for _, port := range ports {
		listener, err := net.Listen("tcp", fmt.Sprintf("127.0.0.1:%d", port))
		require.NoError(t, err, "port %d is in use; stop the running stack first", port)
		require.NoError(t, listener.Close())
	}
}

func waitFor(t *testing.T, timeout time.Duration, what string, ready func() bool) {
	t.Helper()
	deadline := time.Now().Add(timeout)
	for time.Now().Before(deadline) {
		if ready() {
			return
		}
		time.Sleep(500 * time.Millisecond)
	}
	t.Fatalf("timed out after %s waiting for %s", timeout, what)
}

func repeatHex(pair string, count int) string {
	out := make([]byte, 0, len(pair)*count)
	for i := 0; i < count; i++ {
		out = append(out, pair...)
	}
	return string(out)
}

// jsonClient speaks Connect's JSON protocol, which is a plain HTTP POST. The
// enforcer services this test drives have no generated client in this repo.
type jsonClient struct {
	base string // URL prefix through the proto package, e.g. ".../cusf.mainchain.v1."
}

func (c *jsonClient) call(ctx context.Context, method string, body, out any) error {
	payload, err := json.Marshal(body)
	if err != nil {
		return fmt.Errorf("marshal %s: %w", method, err)
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, c.base+method, bytes.NewReader(payload))
	if err != nil {
		return fmt.Errorf("build %s: %w", method, err)
	}
	req.Header.Set("Content-Type", "application/json")

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return fmt.Errorf("%s: %w", method, err)
	}
	defer resp.Body.Close()

	raw, err := io.ReadAll(resp.Body)
	if err != nil {
		return fmt.Errorf("read %s: %w", method, err)
	}
	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("%s: %s: %s", method, resp.Status, raw)
	}
	if out == nil {
		return nil
	}
	if err := json.Unmarshal(raw, out); err != nil {
		return fmt.Errorf("decode %s: %w", method, err)
	}
	return nil
}

// coreRPC calls a Bitcoin Core node with the cookie it wrote at startup.
type coreRPC struct {
	url     string
	datadir string
}

func newCoreRPC(t *testing.T, datadir string, port int) *coreRPC {
	t.Helper()
	return &coreRPC{url: fmt.Sprintf("http://127.0.0.1:%d", port), datadir: datadir}
}

func (c *coreRPC) call(ctx context.Context, method string, params []any, out any) error {
	if params == nil {
		params = []any{}
	}
	payload, err := json.Marshal(map[string]any{
		"jsonrpc": "1.0", "id": "test", "method": method, "params": params,
	})
	if err != nil {
		return fmt.Errorf("marshal %s: %w", method, err)
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, c.url, bytes.NewReader(payload))
	if err != nil {
		return fmt.Errorf("build %s: %w", method, err)
	}
	req.Header.Set("Content-Type", "application/json")

	cookie, err := os.ReadFile(filepath.Join(c.datadir, ".cookie"))
	if err != nil {
		return fmt.Errorf("read cookie: %w", err)
	}
	user, password, _ := bytes.Cut(cookie, []byte(":"))
	req.SetBasicAuth(string(user), string(password))

	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return fmt.Errorf("%s: %w", method, err)
	}
	defer resp.Body.Close()

	var envelope struct {
		Result json.RawMessage `json:"result"`
		Error  json.RawMessage `json:"error"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&envelope); err != nil {
		return fmt.Errorf("decode %s: %w", method, err)
	}
	if len(envelope.Error) > 0 && string(envelope.Error) != "null" {
		return fmt.Errorf("%s: %s", method, envelope.Error)
	}
	if out == nil {
		return nil
	}
	if err := json.Unmarshal(envelope.Result, out); err != nil {
		return fmt.Errorf("unmarshal %s: %w", method, err)
	}
	return nil
}
