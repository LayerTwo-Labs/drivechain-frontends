package wallet

import (
	"context"
	"encoding/json"
	"net"
	"net/http"
	"net/http/httptest"
	"strconv"
	"strings"
	"sync"
	"testing"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// fakeBitcoind is an httptest JSON-RPC server standing in for bitcoind. It
// records every call (method, wallet path, raw params) and answers from
// per-method handlers, exercising the real CoreRPCClient wire path.
type fakeBitcoind struct {
	srv *httptest.Server

	mu       sync.Mutex
	calls    []bitcoindCall
	handlers map[string]func(c bitcoindCall) (any, string)
}

type bitcoindCall struct {
	Wallet string
	Method string
	Params []json.RawMessage
}

func newFakeBitcoind(t *testing.T) *fakeBitcoind {
	t.Helper()
	f := &fakeBitcoind{handlers: map[string]func(bitcoindCall) (any, string){}}
	f.srv = httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Method string            `json:"method"`
			Params []json.RawMessage `json:"params"`
		}
		if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		call := bitcoindCall{
			Wallet: strings.TrimPrefix(r.URL.Path, "/wallet/"),
			Method: req.Method,
			Params: req.Params,
		}
		if call.Wallet == "/" || r.URL.Path == "/" {
			call.Wallet = ""
		}

		f.mu.Lock()
		f.calls = append(f.calls, call)
		handler := f.handlers[req.Method]
		f.mu.Unlock()

		if handler == nil {
			t.Errorf("fake bitcoind: unhandled method %q", req.Method)
			_ = json.NewEncoder(w).Encode(map[string]any{"error": map[string]any{"code": -32601, "message": "unhandled"}})
			return
		}
		result, rpcErrMsg := handler(call)
		if rpcErrMsg != "" {
			_ = json.NewEncoder(w).Encode(map[string]any{"error": map[string]any{"code": -1, "message": rpcErrMsg}})
			return
		}
		_ = json.NewEncoder(w).Encode(map[string]any{"result": result})
	}))
	t.Cleanup(f.srv.Close)
	return f
}

func (f *fakeBitcoind) handle(method string, fn func(bitcoindCall) (any, string)) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.handlers[method] = fn
}

func (f *fakeBitcoind) callsFor(method string) []bitcoindCall {
	f.mu.Lock()
	defer f.mu.Unlock()
	var out []bitcoindCall
	for _, c := range f.calls {
		if c.Method == method {
			out = append(out, c)
		}
	}
	return out
}

func (f *fakeBitcoind) client(t *testing.T) *CoreRPCClient {
	t.Helper()
	host, portStr, err := net.SplitHostPort(strings.TrimPrefix(f.srv.URL, "http://"))
	require.NoError(t, err)
	port, err := strconv.Atoi(portStr)
	require.NoError(t, err)
	return NewCoreRPCClient(host, port, "user", "pass")
}

// stubEnsureFlow installs the happy-path handlers for lazy wallet creation.
func (f *fakeBitcoind) stubEnsureFlow() {
	f.handle("listwallets", func(bitcoindCall) (any, string) { return []string{}, "" })
	f.handle("createwallet", func(bitcoindCall) (any, string) { return map[string]any{}, "" })
	f.handle("importdescriptors", func(c bitcoindCall) (any, string) {
		var descs []ImportDescriptor
		_ = json.Unmarshal(c.Params[0], &descs)
		results := make([]map[string]any, len(descs))
		for i := range results {
			results[i] = map[string]any{"success": true}
		}
		return results, ""
	})
}

// newCoreBackendFixture wires a real Service (enforcer + bitcoinCore
// wallets) to a CoreBackend talking to the fake bitcoind on regtest.
func newCoreBackendFixture(t *testing.T) (*CoreBackend, *fakeBitcoind, string) {
	t.Helper()
	svc := newTestService(t)
	_, err := svc.GenerateWallet("Enforcer", "", "", testSlots)
	require.NoError(t, err)
	core, err := svc.GenerateWallet("Core", "", "", testSlots)
	require.NoError(t, err)
	require.Equal(t, WalletTypeBitcoinCore, core.WalletType)

	fake := newFakeBitcoind(t)
	log := zerolog.New(zerolog.NewTestWriter(t))
	backend := NewCoreBackend(svc, fake.client(t), &chaincfg.RegressionNetParams, log)
	return backend, fake, core.ID
}

func TestCoreBackendEnsureCreatesDescriptorWallet(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()

	name, err := backend.Ensure(context.Background(), coreID)
	require.NoError(t, err)
	assert.Equal(t, "wallet_"+coreID[:8], name)

	creates := fake.callsFor("createwallet")
	require.Len(t, creates, 1)
	assert.Equal(t, name, mustString(t, creates[0].Params[0]))

	imports := fake.callsFor("importdescriptors")
	require.Len(t, imports, 2, "BIP84 pair + BIP47 notification descriptor")

	var singleSig []ImportDescriptor
	require.NoError(t, json.Unmarshal(imports[0].Params[0], &singleSig))
	require.Len(t, singleSig, 4, "BIP84 (segwit) pair + BIP86 (taproot) pair")
	// Regtest coin type is 1; external chain /0/*, change chain /1/*.
	assert.Contains(t, singleSig[0].Desc, "wpkh([")
	assert.Contains(t, singleSig[0].Desc, "/84'/1'/0']")
	assert.Contains(t, singleSig[0].Desc, "/0/*")
	assert.False(t, singleSig[0].Internal)
	assert.Equal(t, []int{0, 999}, singleSig[0].Range)
	assert.Contains(t, singleSig[1].Desc, "/1/*")
	assert.True(t, singleSig[1].Internal)
	// BIP86 taproot pair, external + change.
	assert.Contains(t, singleSig[2].Desc, "tr([")
	assert.Contains(t, singleSig[2].Desc, "/86'/1'/0']")
	assert.Contains(t, singleSig[2].Desc, "/0/*")
	assert.False(t, singleSig[2].Internal)
	assert.Equal(t, []int{0, 999}, singleSig[2].Range)
	assert.Contains(t, singleSig[3].Desc, "tr([")
	assert.Contains(t, singleSig[3].Desc, "/1/*")
	assert.True(t, singleSig[3].Internal)

	var notif []ImportDescriptor
	require.NoError(t, json.Unmarshal(imports[1].Params[0], &notif))
	require.Len(t, notif, 1)
	assert.True(t, strings.HasPrefix(notif[0].Desc, "pkh("), "bip47 notification key is P2PKH")
	assert.Contains(t, notif[0].Desc, "#", "descriptor carries a checksum")
	assert.Equal(t, float64(0), asFloat(t, notif[0].Timestamp), "rescan from genesis")

	// Second Ensure hits the cache — no further RPC traffic.
	before := len(fake.callsFor("listwallets"))
	_, err = backend.Ensure(context.Background(), coreID)
	require.NoError(t, err)
	assert.Equal(t, before, len(fake.callsFor("listwallets")))
}

// A backend constructed without chain params (unrecognized network) must
// fail wallet creation with an error, not panic on the nil deref.
func TestCoreBackendEnsureNilNetworkFailsClosed(t *testing.T) {
	svc := newTestService(t)
	_, err := svc.GenerateWallet("Enforcer", "", "", testSlots)
	require.NoError(t, err)
	core, err := svc.GenerateWallet("Core", "", "", testSlots)
	require.NoError(t, err)

	fake := newFakeBitcoind(t)
	fake.stubEnsureFlow()
	log := zerolog.New(zerolog.NewTestWriter(t))
	backend := NewCoreBackend(svc, fake.client(t), nil, log)

	_, err = backend.Ensure(context.Background(), core.ID)
	require.ErrorContains(t, err, "no chain params")
}

func TestCoreBackendEnsureTransientBackoff(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.handle("listwallets", func(bitcoindCall) (any, string) {
		return nil, "-28: Verifying blocks"
	})
	ctx := context.Background()

	_, err := backend.Ensure(ctx, coreID)
	require.ErrorContains(t, err, "Verifying blocks")
	require.Len(t, fake.callsFor("listwallets"), 1)

	// Within the backoff window the cached error returns without new RPCs.
	_, err = backend.Ensure(ctx, coreID)
	require.ErrorContains(t, err, "Verifying blocks")
	assert.Len(t, fake.callsFor("listwallets"), 1)
}

func TestCoreBackendSendSimple(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()
	fake.handle("sendtoaddress", func(bitcoindCall) (any, string) { return "txid-single", "" })
	fake.handle("sendmany", func(bitcoindCall) (any, string) { return "txid-many", "" })
	ctx := context.Background()

	txid, err := backend.Send(ctx, coreID, SendRequest{
		DestinationsSats:      map[string]int64{"bcrt1qdest": 25_000},
		SubtractFeeFromAmount: true,
	})
	require.NoError(t, err)
	assert.Equal(t, "txid-single", txid)

	sends := fake.callsFor("sendtoaddress")
	require.Len(t, sends, 1)
	assert.Equal(t, "bcrt1qdest", mustString(t, sends[0].Params[0]))
	var amount float64
	require.NoError(t, json.Unmarshal(sends[0].Params[1], &amount))
	assert.Equal(t, 0.00025, amount)
	var subtract bool
	require.NoError(t, json.Unmarshal(sends[0].Params[4], &subtract))
	assert.True(t, subtract)

	txid, err = backend.Send(ctx, coreID, SendRequest{
		DestinationsSats: map[string]int64{"bcrt1qa": 1_000, "bcrt1qb": 2_000},
	})
	require.NoError(t, err)
	assert.Equal(t, "txid-many", txid)
	require.Len(t, fake.callsFor("sendmany"), 1)
}

func TestCoreBackendSendFeeRatePath(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()

	const builtHex = "deadbeef00112233"
	fake.handle("createrawtransaction", func(bitcoindCall) (any, string) { return builtHex, "" })
	fake.handle("fundrawtransaction", func(c bitcoindCall) (any, string) {
		return map[string]any{"hex": mustString(t, c.Params[0]) + "ff", "fee": 0.00001, "changepos": 1}, ""
	})
	fake.handle("signrawtransactionwithwallet", func(c bitcoindCall) (any, string) {
		return map[string]any{"hex": mustString(t, c.Params[0]), "complete": true}, ""
	})
	fake.handle("sendrawtransaction", func(bitcoindCall) (any, string) { return "txid-funded", "" })

	net := &chaincfg.RegressionNetParams
	dest := p2wpkhAddr(t, fixedKey(0x77), net)

	txid, err := backend.Send(context.Background(), coreID, SendRequest{
		DestinationsSats: map[string]int64{dest: 30_000},
		FeeRateSatPerVB:  5,
		OpReturnHex:      "cafe",
	})
	require.NoError(t, err)
	assert.Equal(t, "txid-funded", txid)

	// Core builds the unsigned tx: destination + OP_RETURN, no inputs.
	creates := fake.callsFor("createrawtransaction")
	require.Len(t, creates, 1)
	var inputs []RawInput
	require.NoError(t, json.Unmarshal(creates[0].Params[0], &inputs))
	assert.Empty(t, inputs)
	var outputs []map[string]any
	require.NoError(t, json.Unmarshal(creates[0].Params[1], &outputs))
	require.Len(t, outputs, 2)
	assert.Equal(t, 0.0003, outputs[0][dest])
	assert.Equal(t, "cafe", outputs[1]["data"])

	// The built hex flows through fund → sign → broadcast.
	funds := fake.callsFor("fundrawtransaction")
	require.Len(t, funds, 1)
	assert.Equal(t, builtHex, mustString(t, funds[0].Params[0]))
	var opts map[string]any
	require.NoError(t, json.Unmarshal(funds[0].Params[1], &opts))
	assert.NotContains(t, opts, "add_inputs", "absent when Core selects inputs, like master")
	assert.Equal(t, float64(5), opts["fee_rate"])

	signs := fake.callsFor("signrawtransactionwithwallet")
	require.Len(t, signs, 1)
	assert.Equal(t, builtHex+"ff", mustString(t, signs[0].Params[0]))
}

func TestCoreBackendSendFixedFeeSelectsInputsAndChange(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()

	net := &chaincfg.RegressionNetParams
	dest := p2wpkhAddr(t, fixedKey(0x88), net)
	change := p2wpkhAddr(t, fixedKey(0x99), net)

	fake.handle("listunspent", func(bitcoindCall) (any, string) {
		return []map[string]any{
			{"txid": strings.Repeat("11", 32), "vout": 0, "amount": 0.0002, "spendable": true},
			{"txid": strings.Repeat("22", 32), "vout": 1, "amount": 0.0004, "spendable": true},
			{"txid": strings.Repeat("33", 32), "vout": 0, "amount": 0.0009, "spendable": false},
		}, ""
	})
	fake.handle("getrawchangeaddress", func(bitcoindCall) (any, string) { return change, "" })
	const builtHex = "deadbeef00112233"
	fake.handle("createrawtransaction", func(bitcoindCall) (any, string) { return builtHex, "" })
	fake.handle("signrawtransactionwithwallet", func(c bitcoindCall) (any, string) {
		return map[string]any{"hex": mustString(t, c.Params[0]), "complete": true}, ""
	})
	fake.handle("sendrawtransaction", func(bitcoindCall) (any, string) { return "txid-fixed", "" })

	txid, err := backend.Send(context.Background(), coreID, SendRequest{
		DestinationsSats: map[string]int64{dest: 50_000},
		FixedFeeSats:     1_000,
	})
	require.NoError(t, err)
	assert.Equal(t, "txid-fixed", txid)

	// Fixed-fee path selects inputs itself and skips fundrawtransaction.
	assert.Empty(t, fake.callsFor("fundrawtransaction"))

	creates := fake.callsFor("createrawtransaction")
	require.Len(t, creates, 1)

	// Largest-first selection skips the unspendable 90k UTXO, picks 40k+20k.
	var inputs []RawInput
	require.NoError(t, json.Unmarshal(creates[0].Params[0], &inputs))
	require.Len(t, inputs, 2)
	assert.Equal(t, strings.Repeat("22", 32), inputs[0].TxID)
	assert.Equal(t, 1, inputs[0].Vout)
	assert.Equal(t, strings.Repeat("11", 32), inputs[1].TxID)

	// Outputs: destination 50k + change 60k-50k-1k = 9k.
	var outputs []map[string]any
	require.NoError(t, json.Unmarshal(creates[0].Params[1], &outputs))
	require.Len(t, outputs, 2)
	assert.Equal(t, 0.0005, outputs[0][dest])
	assert.Equal(t, 0.00009, outputs[1][change])

	signs := fake.callsFor("signrawtransactionwithwallet")
	require.Len(t, signs, 1)
	assert.Equal(t, builtHex, mustString(t, signs[0].Params[0]))
}

func TestCoreBackendSendReplayProtect(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()

	net := &chaincfg.RegressionNetParams
	dest := p2wpkhAddr(t, fixedKey(0xAA), net)

	fake.handle("listunspent", func(bitcoindCall) (any, string) {
		return []map[string]any{
			{"txid": strings.Repeat("44", 32), "vout": 0, "amount": 0.001, "spendable": true},
		}, ""
	})
	fake.handle("getrawchangeaddress", func(bitcoindCall) (any, string) {
		return p2wpkhAddr(t, fixedKey(0xBB), net), ""
	})
	fake.handle("createrawtransaction", func(bitcoindCall) (any, string) { return "01000000aabbccdd", "" })
	var signInputHex, broadcastHex string
	fake.handle("signrawtransactionwithwallet", func(c bitcoindCall) (any, string) {
		signInputHex = mustString(t, c.Params[0])
		return map[string]any{"hex": signInputHex, "complete": true}, ""
	})
	fake.handle("sendrawtransaction", func(c bitcoindCall) (any, string) {
		broadcastHex = mustString(t, c.Params[0])
		return "txid-replay", ""
	})

	_, err := backend.Send(context.Background(), coreID, SendRequest{
		DestinationsSats: map[string]int64{dest: 50_000},
		FixedFeeSats:     1_000,
		ReplayProtect:    true,
	})
	require.NoError(t, err)

	// The magic version replaces the original BEFORE signing (the signature
	// commits to it)…
	assert.Equal(t, "bfbfbf00aabbccdd", signInputHex)
	// …and the replay byte is injected AFTER, making the broadcast hex start
	// with version bfbfbf00 followed by the 0x3f marker.
	assert.Equal(t, "bfbfbf003faabbccdd", broadcastHex)
}

func TestCoreBackendCreateCpfp(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()

	const (
		parentTxid  = "66666666666666666666666666666666666666666666666666666666666666aa"
		parentValue = int64(200_000)
		parentVsize = int64(150)
		parentFee   = int64(150) // 1 sat/vB parent, too low
		targetRate  = int64(20)
	)
	childAddr := p2wpkhAddr(t, fixedKey(0x77), &chaincfg.RegressionNetParams)

	fake.handle("listunspent", func(bitcoindCall) (any, string) {
		return []map[string]any{
			{"txid": parentTxid, "vout": 0, "amount": 0.002, "spendable": true, "confirmations": 0},
		}, ""
	})
	fake.handle("getmempoolentry", func(bitcoindCall) (any, string) {
		return map[string]any{"vsize": parentVsize, "fees": map[string]any{"base": float64(parentFee) / 1e8}}, ""
	})
	fake.handle("listreceivedbyaddress", func(bitcoindCall) (any, string) {
		return []map[string]any{{"address": childAddr, "amount": 0.0, "txids": []string{}}}, ""
	})
	var builtOutputs []map[string]any
	fake.handle("createrawtransaction", func(c bitcoindCall) (any, string) {
		require.NoError(t, json.Unmarshal(c.Params[1], &builtOutputs))
		return "deadbeefcpfp", ""
	})
	fake.handle("signrawtransactionwithwallet", func(c bitcoindCall) (any, string) {
		return map[string]any{"hex": mustString(t, c.Params[0]), "complete": true}, ""
	})
	fake.handle("sendrawtransaction", func(bitcoindCall) (any, string) { return "child-txid", "" })

	childTxid, err := backend.CreateCpfp(context.Background(), coreID, CpfpRequest{
		ParentTxID: parentTxid,
		ParentVout: 0,
		TargetRate: targetRate,
	})
	require.NoError(t, err)
	assert.Equal(t, "child-txid", childTxid)

	// The parent is unconfirmed: listunspent MUST be called with minconf 0, or
	// the default (1) hides it.
	unspents := fake.callsFor("listunspent")
	require.NotEmpty(t, unspents)
	require.NotEmpty(t, unspents[0].Params, "listunspent must pass minconf")
	var minConf int
	require.NoError(t, json.Unmarshal(unspents[0].Params[0], &minConf))
	assert.Equal(t, 0, minConf, "listunspent minconf must be 0")

	// The child output equals parentValue - childFee, and the package clears the
	// target rate.
	childVsize := int64(11 + inputVsize(ScriptNativeSegwit) + outputVsizeForKind(ScriptNativeSegwit))
	childFee, outputSats, err := cpfpChildPlan(targetRate, parentVsize, parentFee, childVsize, parentValue)
	require.NoError(t, err)
	require.Len(t, builtOutputs, 1, "self-send: single output")
	assert.InDelta(t, btcutil.Amount(outputSats).ToBTC(), builtOutputs[0][childAddr], 1e-12)

	packageRate := float64(parentFee+childFee) / float64(parentVsize+childVsize)
	assert.GreaterOrEqual(t, packageRate, float64(targetRate))
	assert.Positive(t, outputSats)
}

func TestCpfpChildPlanMeetsTargetRate(t *testing.T) {
	cases := []struct {
		name                                                        string
		targetRate, parentVsize, parentFee, childVsize, parentValue int64
	}{
		{"parent_underpaid", 20, 150, 150, 110, 200_000},
		{"parent_zero_fee", 10, 200, 0, 110, 500_000},
		{"high_target", 100, 250, 500, 110, 1_000_000},
		{"parent_already_ok_child_min_relay", 5, 150, 750, 110, 100_000},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			childFee, outputSats, err := cpfpChildPlan(tc.targetRate, tc.parentVsize, tc.parentFee, tc.childVsize, tc.parentValue)
			require.NoError(t, err)
			assert.Equal(t, tc.parentValue-childFee, outputSats)
			assert.Positive(t, outputSats)
			packageRate := float64(tc.parentFee+childFee) / float64(tc.parentVsize+tc.childVsize)
			assert.GreaterOrEqual(t, packageRate, float64(tc.targetRate),
				"package rate %.2f must reach target %d", packageRate, tc.targetRate)
			assert.GreaterOrEqual(t, childFee, tc.childVsize, "child fee must clear 1 sat/vB min relay")
		})
	}
}

func TestCpfpChildPlanRejectsFeeExceedingParent(t *testing.T) {
	_, _, err := cpfpChildPlan(1000, 150, 0, 110, 1_000)
	require.Error(t, err)
}

func TestCoreBackendWatchKeys(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()

	err := backend.WatchKeys(context.Background(), coreID, []WatchKey{
		{WIF: "cMahea7zqjxrtgAbB7LSGbcQUr1uX1ojuat9jZodMN8rFTv2sfUK", RescanFrom: 1_700_000_000},
	})
	require.NoError(t, err)

	imports := fake.callsFor("importdescriptors")
	require.Len(t, imports, 3, "BIP84 pair + notification + watch keys")
	var descs []ImportDescriptor
	require.NoError(t, json.Unmarshal(imports[2].Params[0], &descs))
	require.Len(t, descs, 1)
	assert.True(t, strings.HasPrefix(descs[0].Desc, "pkh(cMahea7"))
	assert.Contains(t, descs[0].Desc, "#")
	assert.Equal(t, float64(1_700_000_000), asFloat(t, descs[0].Timestamp))
}

func TestCoreBackendNextReceiveAddress(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()
	ctx := context.Background()

	// An unused bech32 address is reused instead of minting a new one;
	// used and non-bech32 (BIP47 P2PKH) entries are skipped.
	fake.handle("listreceivedbyaddress", func(bitcoindCall) (any, string) {
		return []map[string]any{
			{"address": "bcrt1qused", "amount": 0.5, "txids": []string{"a"}},
			{"address": "mkP2pkhBip47", "amount": 0.0, "txids": []string{}},
			{"address": "bcrt1qunused", "amount": 0.0, "txids": []string{}},
		}, ""
	})
	addr, err := backend.NextReceiveAddress(ctx, coreID, ScriptNativeSegwit)
	require.NoError(t, err)
	assert.Equal(t, "bcrt1qunused", addr)
	assert.Empty(t, fake.callsFor("getnewaddress"))

	// All used → mint.
	fake.handle("listreceivedbyaddress", func(bitcoindCall) (any, string) {
		return []map[string]any{{"address": "bcrt1qused", "amount": 0.5, "txids": []string{"a"}}}, ""
	})
	fake.handle("getnewaddress", func(bitcoindCall) (any, string) { return "bcrt1qminted", "" })
	addr, err = backend.NextReceiveAddress(ctx, coreID, ScriptNativeSegwit)
	require.NoError(t, err)
	assert.Equal(t, "bcrt1qminted", addr)
}

func TestCoreBackendNextReceiveAddressTaproot(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()
	ctx := context.Background()

	// A taproot request skips segwit (bc1q/bcrt1q) candidates and reuses the
	// unused bech32m (bcrt1p) one.
	fake.handle("listreceivedbyaddress", func(bitcoindCall) (any, string) {
		return []map[string]any{
			{"address": "bcrt1qsegwitunused", "amount": 0.0, "txids": []string{}},
			{"address": "bcrt1ptaprootunused", "amount": 0.0, "txids": []string{}},
		}, ""
	})
	addr, err := backend.NextReceiveAddress(ctx, coreID, ScriptTaproot)
	require.NoError(t, err)
	assert.Equal(t, "bcrt1ptaprootunused", addr)
	assert.Empty(t, fake.callsFor("getnewaddress"))

	// No unused taproot candidate → mint with address_type=bech32m.
	fake.handle("listreceivedbyaddress", func(bitcoindCall) (any, string) {
		return []map[string]any{{"address": "bcrt1qsegwitunused", "amount": 0.0, "txids": []string{}}}, ""
	})
	var mintedType string
	fake.handle("getnewaddress", func(c bitcoindCall) (any, string) {
		if len(c.Params) > 1 {
			mintedType = mustString(t, c.Params[1])
		}
		return "bcrt1pminted", ""
	})
	addr, err = backend.NextReceiveAddress(ctx, coreID, ScriptTaproot)
	require.NoError(t, err)
	assert.Equal(t, "bcrt1pminted", addr)
	assert.Equal(t, "bech32m", mintedType)
}

func mustString(t *testing.T, raw json.RawMessage) string {
	t.Helper()
	var s string
	require.NoError(t, json.Unmarshal(raw, &s))
	return s
}

func asFloat(t *testing.T, v any) float64 {
	t.Helper()
	f, ok := v.(float64)
	require.True(t, ok, "expected numeric value, got %T", v)
	return f
}
