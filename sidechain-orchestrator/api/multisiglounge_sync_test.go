package api

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"net"
	"os/exec"
	"sort"
	"strings"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/multisiglounge/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

const syncTestMnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"

// loungeRegtest is a throwaway regtest bitcoind for handler e2e tests. It bridges
// the handler's CoreRawCaller to a real node via bitcoin-cli.
type loungeRegtest struct {
	t       *testing.T
	cli     string
	dataDir string
	port    int
}

func newLoungeRegtest(t *testing.T) *loungeRegtest {
	t.Helper()
	cli, err := exec.LookPath("bitcoin-cli")
	if err != nil {
		t.Skip("bitcoin-cli not on PATH; skipping multisig sync e2e")
	}
	daemon, err := exec.LookPath("bitcoind")
	if err != nil {
		t.Skip("bitcoind not on PATH; skipping multisig sync e2e")
	}
	dir := t.TempDir()
	rpcPort := freePort(t)
	p2pPort := freePort(t)
	// -txindex mirrors the bitwindow node: RestoreHistory fetches arbitrary
	// historical txs by id via getrawtransaction, which needs the tx index.
	// Per-node RPC and P2P ports keep concurrent regtest nodes (e.g. the wallet
	// package's e2e running in parallel) from colliding on the defaults.
	require.NoError(t, exec.Command(daemon, "-regtest", "-datadir="+dir, "-daemon", "-server=1",
		"-rpcuser=u", "-rpcpassword=p", "-fallbackfee=0.0001", "-txindex=1",
		fmt.Sprintf("-rpcport=%d", rpcPort), fmt.Sprintf("-port=%d", p2pPort),
		fmt.Sprintf("-bind=127.0.0.1:%d", p2pPort), "-listen=1").Run())
	rt := &loungeRegtest{t: t, cli: cli, dataDir: dir, port: rpcPort}
	// -daemon detaches, so the node outlives the test binary unless we stop it.
	// Registered before the readiness wait: its t.Fatal path returns no handle.
	t.Cleanup(rt.stop)

	deadline := time.Now().Add(20 * time.Second)
	for time.Now().Before(deadline) {
		if _, err := rt.cliCall("", "getblockchaininfo", ""); err == nil {
			return rt
		}
		time.Sleep(300 * time.Millisecond)
	}
	t.Fatal("bitcoind regtest RPC did not come up")
	return nil
}

func (rt *loungeRegtest) stop() {
	_, _ = rt.cliCall("", "stop", "")
	time.Sleep(time.Second)
}

// freePort returns an OS-assigned free TCP port for the node's RPC.
func freePort(t *testing.T) int {
	t.Helper()
	l, err := net.Listen("tcp", "127.0.0.1:0")
	require.NoError(t, err)
	defer l.Close() //nolint:errcheck
	return l.Addr().(*net.TCPAddr).Port
}

// cliCall invokes bitcoin-cli with positional params (JSON array string). Objects
// and arrays are passed as their compact JSON; scalars as their literal text.
func (rt *loungeRegtest) cliCall(wallet, method, paramsJSON string) ([]byte, error) {
	args := []string{"-regtest", "-datadir=" + rt.dataDir, "-rpcuser=u", "-rpcpassword=p",
		fmt.Sprintf("-rpcport=%d", rt.port)}
	if wallet != "" {
		args = append(args, "-rpcwallet="+wallet)
	}
	args = append(args, method)
	if paramsJSON != "" {
		var params []interface{}
		if err := json.Unmarshal([]byte(paramsJSON), &params); err != nil {
			return nil, err
		}
		for _, p := range params {
			args = append(args, cliArg(p))
		}
	}
	return exec.Command(rt.cli, args...).Output()
}

func cliArg(p interface{}) string {
	switch v := p.(type) {
	case string:
		return v
	case bool:
		if v {
			return "true"
		}
		return "false"
	case float64:
		// Integers come through as float64; render without a trailing ".0".
		if v == float64(int64(v)) {
			return fmt.Sprintf("%d", int64(v))
		}
		return fmt.Sprintf("%v", v)
	default:
		b, _ := json.Marshal(v)
		return string(b)
	}
}

// coreCaller adapts the regtest node to the handler's CoreRawCaller signature.
func (rt *loungeRegtest) coreCaller() CoreRawCaller {
	return func(_ context.Context, method, paramsJSON, wallet string) (json.RawMessage, error) {
		out, err := rt.cliCall(wallet, method, paramsJSON)
		if err != nil {
			return nil, fmt.Errorf("%s: %w", method, err)
		}
		trimmed := strings.TrimSpace(string(out))
		if trimmed == "" {
			return json.RawMessage("null"), nil
		}
		// bitcoin-cli prints bare strings/numbers; wrap a non-JSON scalar so the
		// handler's json.Unmarshal into a string target succeeds.
		if !json.Valid([]byte(trimmed)) {
			b, _ := json.Marshal(trimmed)
			return b, nil
		}
		return json.RawMessage(trimmed), nil
	}
}

func (rt *loungeRegtest) rpcInto(t *testing.T, wallet, method, paramsJSON string, out interface{}) {
	t.Helper()
	res, err := rt.cliCall(wallet, method, paramsJSON)
	require.NoError(t, err, "%s", method)
	if out == nil {
		return
	}
	if sp, ok := out.(*string); ok {
		*sp = strings.TrimSpace(string(res))
		return
	}
	require.NoError(t, json.Unmarshal(res, out), "decode %s: %s", method, res)
}

// loungeSyncTestGroup builds the standard abandon-seed 2-of-3 group used by the
// sync/restore e2e tests, with all three keys owned by the wallet.
func loungeSyncTestGroup(t *testing.T) *pb.GroupData {
	t.Helper()
	net := &chaincfg.SigNetParams
	const h = hdkeychain.HardenedKeyStart
	master, err := hdkeychain.NewMaster(wallet.MnemonicToSeed(syncTestMnemonic, ""), net)
	require.NoError(t, err)
	mpub, err := master.ECPubKey()
	require.NoError(t, err)
	fp := hex.EncodeToString(btcutil.Hash160(mpub.SerializeCompressed())[:4])

	keys := make([]*pb.GroupKey, 0, 3)
	for acct := uint32(2); acct <= 4; acct++ {
		k := master
		for _, p := range []uint32{h + 48, h + 1, h + 0, h + acct} {
			k, err = k.Derive(p)
			require.NoError(t, err)
		}
		pub, nerr := k.Neuter()
		require.NoError(t, nerr)
		keys = append(keys, &pb.GroupKey{
			Owner:          fmt.Sprintf("owner%d", acct),
			Xpub:           pub.String(),
			DerivationPath: fmt.Sprintf("m/48'/1'/0'/%d'", acct),
			Fingerprint:    fp,
			OriginPath:     fmt.Sprintf("48'/1'/0'/%d'", acct),
			IsWallet:       true,
		})
	}
	return &pb.GroupData{Id: "synctest", Name: "Sync Test", N: 3, M: 2, Keys: keys, WatchWalletName: "ms_sync"}
}

func newSyncHandler(rt *loungeRegtest) *MultisigLoungeHandler {
	h := NewMultisigLoungeHandler()
	h.SetCoreCaller(rt.coreCaller())
	return h
}

func TestSyncGroupBalanceE2E(t *testing.T) {
	rt := newLoungeRegtest(t)
	h := newSyncHandler(rt)
	group := loungeSyncTestGroup(t)

	// First SyncGroup creates the watch-only wallet from the Phase-1 descriptors.
	resp, err := h.SyncGroup(context.Background(), connect.NewRequest(&pb.SyncGroupRequest{Group: group}))
	require.NoError(t, err)
	require.Equal(t, int64(0), resp.Msg.ConfirmedSats)
	require.Equal(t, uint32(0), resp.Msg.UtxoCount)

	// Fund the multisig wallet.
	rt.rpcInto(t, "", "createwallet", `["fund"]`, nil)
	var fundAddr string
	rt.rpcInto(t, "fund", "getnewaddress", "", &fundAddr)
	rt.rpcInto(t, "", "generatetoaddress", fmt.Sprintf(`[101,%q]`, fundAddr), nil)

	var msAddr string
	rt.rpcInto(t, "ms_sync", "getnewaddress", "", &msAddr)
	rt.rpcInto(t, "fund", "sendtoaddress", fmt.Sprintf(`[%q,"1.0"]`, msAddr), nil)
	rt.rpcInto(t, "", "generatetoaddress", fmt.Sprintf(`[1,%q]`, fundAddr), nil)

	resp, err = h.SyncGroup(context.Background(), connect.NewRequest(&pb.SyncGroupRequest{Group: group}))
	require.NoError(t, err)
	require.Equal(t, int64(100_000_000), resp.Msg.ConfirmedSats, "1 BTC confirmed")
	require.Equal(t, uint32(1), resp.Msg.UtxoCount)
	require.Len(t, resp.Msg.Utxos, 1)
	require.Equal(t, int64(100_000_000), resp.Msg.Utxos[0].AmountSats)
	require.Equal(t, msAddr, resp.Msg.Utxos[0].Address)
}

// TestSyncGroupPolicyChangeReimports proves a same-id policy edit (2-of-3 to
// 3-of-3) re-imports the watch wallet's descriptors instead of silently serving
// the retired policy: a deposit made to the new policy before the re-import —
// so only a rescan can find it — must show up in SyncGroup.
func TestSyncGroupPolicyChangeReimports(t *testing.T) {
	rt := newLoungeRegtest(t)
	h := newSyncHandler(rt)
	group := loungeSyncTestGroup(t)
	ctx := context.Background()

	// First sync imports the 2-of-3 descriptors with a range that stays ample.
	_, err := h.SyncGroup(ctx, connect.NewRequest(&pb.SyncGroupRequest{Group: group}))
	require.NoError(t, err)

	rt.rpcInto(t, "", "createwallet", `["fund"]`, nil)
	var fundAddr string
	rt.rpcInto(t, "fund", "getnewaddress", "", &fundAddr)
	rt.rpcInto(t, "", "generatetoaddress", fmt.Sprintf(`[101,%q]`, fundAddr), nil)

	// Same id, same keys, new threshold: what editing a group produces.
	group.M = 3
	receive, _, err := wallet.BuildMultisigLoungeDescriptors(groupDataToLoungeGroup(group))
	require.NoError(t, err)
	var addrs []string
	rt.rpcInto(t, "", "deriveaddresses", fmt.Sprintf(`[%q,[0,0]]`, receive), &addrs)
	require.Len(t, addrs, 1)

	rt.rpcInto(t, "fund", "sendtoaddress", fmt.Sprintf(`[%q,"1.0"]`, addrs[0]), nil)
	rt.rpcInto(t, "", "generatetoaddress", fmt.Sprintf(`[1,%q]`, fundAddr), nil)

	resp, err := h.SyncGroup(ctx, connect.NewRequest(&pb.SyncGroupRequest{Group: group}))
	require.NoError(t, err)
	require.Equal(t, int64(100_000_000), resp.Msg.ConfirmedSats, "the 3-of-3 deposit must be visible")
	require.Len(t, resp.Msg.Utxos, 1)
	require.Equal(t, addrs[0], resp.Msg.Utxos[0].Address)

	// The wallet now tracks the new policy, and reports it in the spelling the
	// next sync compares against — so it does not re-import (and rescan) again.
	state, err := h.watchDescriptorRange(ctx, watchWalletName(group))
	require.NoError(t, err)
	require.Equal(t, normalizeDescriptor(receive), state.receive)
}

func TestRestoreHistoryE2E(t *testing.T) {
	rt := newLoungeRegtest(t)
	h := newSyncHandler(rt)
	group := loungeSyncTestGroup(t)
	ctx := context.Background()

	// Create + fund the watch-only wallet.
	_, err := h.SyncGroup(ctx, connect.NewRequest(&pb.SyncGroupRequest{Group: group}))
	require.NoError(t, err)

	rt.rpcInto(t, "", "createwallet", `["fund"]`, nil)
	var fundAddr string
	rt.rpcInto(t, "fund", "getnewaddress", "", &fundAddr)
	rt.rpcInto(t, "", "generatetoaddress", fmt.Sprintf(`[101,%q]`, fundAddr), nil)
	var msAddr string
	rt.rpcInto(t, "ms_sync", "getnewaddress", "", &msAddr)
	rt.rpcInto(t, "fund", "sendtoaddress", fmt.Sprintf(`[%q,"1.0"]`, msAddr), nil)
	rt.rpcInto(t, "", "generatetoaddress", fmt.Sprintf(`[1,%q]`, fundAddr), nil)

	// Build a 2-of-3 spend PSBT and sign with two keys via the Phase-3 path.
	var dest string
	rt.rpcInto(t, "fund", "getnewaddress", "", &dest)
	outs, _ := json.Marshal([]map[string]float64{{dest: 0.5}})
	opts, _ := json.Marshal(map[string]interface{}{"includeWatching": true, "changeAddress": msAddr})
	var funded struct {
		PSBT string `json:"psbt"`
	}
	rt.rpcInto(t, "ms_sync", "walletcreatefundedpsbt", fmt.Sprintf(`["[]",%s,0,%s]`, string(outs), string(opts)), &funded)

	loungeGroup := groupDataToLoungeGroup(group)
	seedHex := hex.EncodeToString(wallet.MnemonicToSeed(syncTestMnemonic, ""))
	net := &chaincfg.SigNetParams
	signOnce := func(acct uint32, base string) string {
		xprv, xpub, derr := wallet.DeriveAccountXprv(seedHex, fmt.Sprintf("m/48'/1'/0'/%d'", acct), net)
		require.NoError(t, derr)
		recv, chg, berr := wallet.BuildMultisigSigningDescriptors(loungeGroup, map[string]string{xpub: xprv})
		require.NoError(t, berr)
		descs, _ := json.Marshal([]string{recv, chg})
		var res struct {
			PSBT string `json:"psbt"`
		}
		rt.rpcInto(t, "", "descriptorprocesspsbt", fmt.Sprintf(`[%q,%s,"ALL",true,false]`, base, string(descs)), &res)
		return res.PSBT
	}
	signedA := signOnce(2, funded.PSBT)
	signedB := signOnce(3, funded.PSBT)

	// Combine + broadcast via the handler.
	cab, err := h.CombineAndBroadcast(ctx, connect.NewRequest(&pb.CombineAndBroadcastRequest{
		Psbts: []string{signedA, signedB},
		Group: group,
	}))
	require.NoError(t, err)
	spendTxid := cab.Msg.Txid
	require.Len(t, spendTxid, 64)

	// Confirm to 6 blocks so the spend reconstructs as "confirmed".
	rt.rpcInto(t, "", "generatetoaddress", fmt.Sprintf(`[6,%q]`, fundAddr), nil)

	resp, err := h.RestoreHistory(ctx, connect.NewRequest(&pb.RestoreHistoryRequest{Group: group}))
	require.NoError(t, err)

	var spend *pb.MultisigHistoryTx
	for _, tx := range resp.Msg.Transactions {
		if tx.Txid == spendTxid {
			spend = tx
		}
	}
	require.NotNil(t, spend, "the broadcast spend must appear in restored history")
	// Change lands on the group's own receive address, so Core emits a receive row
	// for this txid too. The restored row must still read as an outgoing 0.5 BTC
	// payment to dest, not as an inbound deposit of the change.
	require.False(t, spend.IsDeposit, "an outgoing spend must not restore as a deposit")
	require.Equal(t, int64(50_000_000), spend.AmountSats, "net amount sent, not the change output")
	require.Equal(t, dest, spend.Destination, "the payee, not the group's own change address")
	require.Equal(t, "confirmed", spend.Status)
	require.GreaterOrEqual(t, spend.Confirmations, uint32(6))
	require.NotEmpty(t, spend.FinalHex, "reconstructed tx must carry the raw hex")
	require.NotEmpty(t, spend.Inputs, "reconstructed tx must carry its inputs")
	// 2-of-3 P2WSH spend: the witness carries two ~72-byte signatures. This is the
	// load-bearing parity check on CountMultisigSignatures.
	require.Equal(t, uint32(2), spend.SignatureCount, "two signatures counted from the witness")
}

// TestRestoreHistoryNetsRowsPerTxid pins the row aggregation without a node:
// listtransactions returns one row per wallet-relevant output, receive rows
// first, so direction, amount and payee must come from all rows of a txid.
func TestRestoreHistoryNetsRowsPerTxid(t *testing.T) {
	// 1 BTC in, 0.5 to an external payee, change back to a group address (which
	// Core reports as a send row plus a receive row, not as change).
	const spendRows = `[
		{"txid":"aa","address":"grp","category":"receive","amount":0.4999,"confirmations":7,"time":100},
		{"txid":"aa","address":"grp","category":"send","amount":-0.4999,"confirmations":7,"time":100},
		{"txid":"aa","address":"payee","category":"send","amount":-0.5,"confirmations":7,"time":100}
	]`
	const depositRows = `[{"txid":"aa","address":"grp","category":"receive","amount":1.0,"confirmations":7,"time":100}]`
	// The group's own address is vout[0], as when Core randomises change first.
	const raw = `{"txid":"aa","hex":"0100","vin":[{"txid":"bb","vout":0}],
		"vout":[{"scriptPubKey":{"address":"grp"}},{"scriptPubKey":{"address":"payee"}}]}`

	tests := []struct {
		name        string
		rows        string
		isDeposit   bool
		amountSats  int64
		destination string
	}{
		{"spend with change to a group address", spendRows, false, 50_000_000, "payee"},
		{"deposit", depositRows, true, 100_000_000, "grp"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			h := NewMultisigLoungeHandler()
			h.SetCoreCaller(func(_ context.Context, method, _, _ string) (json.RawMessage, error) {
				switch method {
				case "listwallets":
					return json.RawMessage(`["ms_test"]`), nil
				case "listtransactions":
					return json.RawMessage(tt.rows), nil
				case "gettransaction":
					// The complete detail set, which a listtransactions page
					// may split across its count boundary.
					return json.RawMessage(`{"details":` + tt.rows + `}`), nil
				case "getrawtransaction":
					return json.RawMessage(raw), nil
				case "listdescriptors":
					// The watch wallet already covers the indices it hands out.
					return json.RawMessage(`{"descriptors":[
						{"desc":"wsh(x)","active":true,"internal":false,"range":[0,999],"next":0},
						{"desc":"wsh(y)","active":true,"internal":true,"range":[0,999],"next":0}
					]}`), nil
				}
				return nil, fmt.Errorf("unexpected method %s", method)
			})

			resp, err := h.RestoreHistory(context.Background(), connect.NewRequest(&pb.RestoreHistoryRequest{
				Group: &pb.GroupData{Id: "restore", WatchWalletName: "ms_test"},
			}))
			require.NoError(t, err)
			require.Len(t, resp.Msg.Transactions, 1)
			tx := resp.Msg.Transactions[0]
			require.Equal(t, tt.isDeposit, tx.IsDeposit)
			require.Equal(t, tt.amountSats, tx.AmountSats)
			require.Equal(t, tt.destination, tx.Destination)
		})
	}
}

// oldBuggyFundGroupDescriptor reproduces the pre-Phase-6 fund_group_modal inline
// descriptor: BIP67-sorted keys joined, with the range suffix appended ONCE to
// the whole join (so only the last key ranges). This is the consensus bug; the
// fix routes fund_group through BuildDescriptors instead.
func oldBuggyFundGroupDescriptor(g *pb.GroupData, change bool) string {
	keys := append([]*pb.GroupKey(nil), g.GetKeys()...)
	sort.SliceStable(keys, func(i, j int) bool { return keys[i].GetXpub() < keys[j].GetXpub() })
	parts := make([]string, len(keys))
	for i, k := range keys {
		if k.GetIsWallet() && k.GetFingerprint() != "" && k.GetOriginPath() != "" {
			parts[i] = fmt.Sprintf("[%s/%s]%s", k.GetFingerprint(), k.GetOriginPath(), k.GetXpub())
		} else {
			parts[i] = k.GetXpub()
		}
	}
	branch := "0"
	if change {
		branch = "1"
	}
	return fmt.Sprintf("wsh(sortedmulti(%d,%s/%s/*))", g.GetM(), strings.Join(parts, ","), branch)
}

// TestFundGroupDescriptorFix proves the fund_group fix: the descriptor it now
// uses (BuildDescriptors) is the standard per-key-ranged form and derives a
// DIFFERENT address set than the old inline single-key-ranged descriptor — i.e.
// the consensus bug is gone, and fund_group now agrees with everything else.
func TestFundGroupDescriptorFix(t *testing.T) {
	rt := newLoungeRegtest(t)
	group := loungeSyncTestGroup(t)

	correctReceive, _, err := wallet.BuildMultisigLoungeDescriptors(groupDataToLoungeGroup(group))
	require.NoError(t, err)
	buggyReceive := oldBuggyFundGroupDescriptor(group, false)

	checksum := func(desc string) string {
		var info struct {
			Descriptor string `json:"descriptor"`
		}
		rt.rpcInto(t, "", "getdescriptorinfo", fmt.Sprintf(`[%q]`, desc), &info)
		return info.Descriptor
	}
	deriveFirst := func(descWithChecksum string) []string {
		var addrs []string
		rt.rpcInto(t, "", "deriveaddresses", fmt.Sprintf(`[%q,[0,3]]`, descWithChecksum), &addrs)
		return addrs
	}

	correctAddrs := deriveFirst(correctReceive) // already carries a checksum
	buggyAddrs := deriveFirst(checksum(buggyReceive))

	require.NotEqual(t, buggyAddrs, correctAddrs,
		"the corrected fund_group descriptor must derive a different address set than the old buggy one")
	// Every cosigner ranges in the corrected form, so addresses differ per index.
	require.NotEqual(t, correctAddrs[0], correctAddrs[1], "corrected descriptor ranges all keys")
}

// TestCreateSpendPsbtE2E proves the CreateSpendPsbt RPC builds a valid fundable
// unsigned PSBT, then chains it through the Go sign→combine→broadcast path to
// confirm the whole flow spends real multisig coins.
func TestCreateSpendPsbtE2E(t *testing.T) {
	rt := newLoungeRegtest(t)
	h := newSyncHandler(rt)
	group := loungeSyncTestGroup(t)
	ctx := context.Background()

	_, err := h.SyncGroup(ctx, connect.NewRequest(&pb.SyncGroupRequest{Group: group}))
	require.NoError(t, err)

	rt.rpcInto(t, "", "createwallet", `["fund"]`, nil)
	var fundAddr string
	rt.rpcInto(t, "fund", "getnewaddress", "", &fundAddr)
	rt.rpcInto(t, "", "generatetoaddress", fmt.Sprintf(`[101,%q]`, fundAddr), nil)
	var msAddr string
	rt.rpcInto(t, "ms_sync", "getnewaddress", "", &msAddr)
	rt.rpcInto(t, "fund", "sendtoaddress", fmt.Sprintf(`[%q,"1.0"]`, msAddr), nil)
	rt.rpcInto(t, "", "generatetoaddress", fmt.Sprintf(`[1,%q]`, fundAddr), nil)

	var dest string
	rt.rpcInto(t, "fund", "getnewaddress", "", &dest)

	resp, err := h.CreateSpendPsbt(ctx, connect.NewRequest(&pb.CreateSpendPsbtRequest{
		Group:        group,
		Destinations: []*pb.SpendDestination{{Address: dest, Sats: 50_000_000}},
	}))
	require.NoError(t, err)
	require.NotEmpty(t, resp.Msg.PsbtBase64)
	require.Positive(t, resp.Msg.FeeSats)

	// The returned PSBT decodes, draws inputs from the watch wallet, and pays the
	// destination.
	var decoded struct {
		Tx struct {
			Vin  []struct{ Txid string } `json:"vin"`
			Vout []struct {
				Value        float64 `json:"value"`
				ScriptPubKey struct {
					Address string `json:"address"`
				} `json:"scriptPubKey"`
			} `json:"vout"`
		} `json:"tx"`
	}
	rt.rpcInto(t, "", "decodepsbt", fmt.Sprintf(`[%q]`, resp.Msg.PsbtBase64), &decoded)
	require.NotEmpty(t, decoded.Tx.Vin, "PSBT must spend wallet inputs")
	var paysDest bool
	for _, o := range decoded.Tx.Vout {
		if o.ScriptPubKey.Address == dest {
			paysDest = true
			require.InDelta(t, 0.5, o.Value, 1e-8)
		}
	}
	require.True(t, paysDest, "PSBT must pay the requested destination")

	// Chain it through the full Go path: sign with two keys, combine, broadcast.
	loungeGroup := groupDataToLoungeGroup(group)
	seedHex := hex.EncodeToString(wallet.MnemonicToSeed(syncTestMnemonic, ""))
	net := &chaincfg.SigNetParams
	signOnce := func(acct uint32, base string) string {
		xprv, xpub, derr := wallet.DeriveAccountXprv(seedHex, fmt.Sprintf("m/48'/1'/0'/%d'", acct), net)
		require.NoError(t, derr)
		recv, chg, berr := wallet.BuildMultisigSigningDescriptors(loungeGroup, map[string]string{xpub: xprv})
		require.NoError(t, berr)
		descs, _ := json.Marshal([]string{recv, chg})
		var r struct {
			PSBT string `json:"psbt"`
		}
		rt.rpcInto(t, "", "descriptorprocesspsbt", fmt.Sprintf(`[%q,%s,"ALL",true,false]`, base, string(descs)), &r)
		return r.PSBT
	}
	cab, err := h.CombineAndBroadcast(ctx, connect.NewRequest(&pb.CombineAndBroadcastRequest{
		Psbts: []string{signOnce(2, resp.Msg.PsbtBase64), signOnce(3, resp.Msg.PsbtBase64)},
		Group: group,
	}))
	require.NoError(t, err)
	require.Len(t, cab.Msg.Txid, 64, "the CreateSpendPsbt output must sign+combine+broadcast end to end")
}
