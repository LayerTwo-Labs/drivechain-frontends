package wallet

import (
	"bytes"
	"context"
	"encoding/hex"
	"encoding/json"
	"net"
	"net/http"
	"net/http/httptest"
	"strconv"
	"strings"
	"sync"
	"testing"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/wire"
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

// newCoreProviderFixture wires a real Service (enforcer + bitcoinCore
// wallets) to a CoreProvider talking to the fake bitcoind on regtest.
func newCoreProviderFixture(t *testing.T) (*CoreProvider, *fakeBitcoind, string) {
	t.Helper()
	svc := newTestService(t)
	_, err := svc.GenerateWallet("Enforcer", "", "", testSlots)
	require.NoError(t, err)
	core, err := svc.GenerateWallet("Core", "", "", testSlots)
	require.NoError(t, err)
	require.Equal(t, "bitcoinCore", core.WalletType)

	fake := newFakeBitcoind(t)
	log := zerolog.New(zerolog.NewTestWriter(t))
	provider := NewCoreProvider(svc, fake.client(t), &chaincfg.RegressionNetParams, log)
	return provider, fake, core.ID
}

func TestCoreProviderEnsureCreatesDescriptorWallet(t *testing.T) {
	provider, fake, coreID := newCoreProviderFixture(t)
	fake.stubEnsureFlow()

	name, err := provider.Ensure(context.Background(), coreID)
	require.NoError(t, err)
	assert.Equal(t, "wallet_"+coreID[:8], name)

	creates := fake.callsFor("createwallet")
	require.Len(t, creates, 1)
	assert.Equal(t, name, mustString(t, creates[0].Params[0]))

	imports := fake.callsFor("importdescriptors")
	require.Len(t, imports, 2, "BIP84 pair + BIP47 notification descriptor")

	var bip84 []ImportDescriptor
	require.NoError(t, json.Unmarshal(imports[0].Params[0], &bip84))
	require.Len(t, bip84, 2)
	// Regtest coin type is 1; external chain /0/*, change chain /1/*.
	assert.Contains(t, bip84[0].Desc, "wpkh([")
	assert.Contains(t, bip84[0].Desc, "/84'/1'/0']")
	assert.Contains(t, bip84[0].Desc, "/0/*")
	assert.False(t, bip84[0].Internal)
	assert.Equal(t, []int{0, 999}, bip84[0].Range)
	assert.Contains(t, bip84[1].Desc, "/1/*")
	assert.True(t, bip84[1].Internal)

	var notif []ImportDescriptor
	require.NoError(t, json.Unmarshal(imports[1].Params[0], &notif))
	require.Len(t, notif, 1)
	assert.True(t, strings.HasPrefix(notif[0].Desc, "pkh("), "bip47 notification key is P2PKH")
	assert.Contains(t, notif[0].Desc, "#", "descriptor carries a checksum")
	assert.Equal(t, float64(0), asFloat(t, notif[0].Timestamp), "rescan from genesis")

	// Second Ensure hits the cache — no further RPC traffic.
	before := len(fake.callsFor("listwallets"))
	_, err = provider.Ensure(context.Background(), coreID)
	require.NoError(t, err)
	assert.Equal(t, before, len(fake.callsFor("listwallets")))
}

func TestCoreProviderEnsureTransientBackoff(t *testing.T) {
	provider, fake, coreID := newCoreProviderFixture(t)
	fake.handle("listwallets", func(bitcoindCall) (any, string) {
		return nil, "-28: Verifying blocks"
	})
	ctx := context.Background()

	_, err := provider.Ensure(ctx, coreID)
	require.ErrorContains(t, err, "Verifying blocks")
	require.Len(t, fake.callsFor("listwallets"), 1)

	// Within the backoff window the cached error returns without new RPCs.
	_, err = provider.Ensure(ctx, coreID)
	require.ErrorContains(t, err, "Verifying blocks")
	assert.Len(t, fake.callsFor("listwallets"), 1)
}

func TestCoreProviderSendSimple(t *testing.T) {
	provider, fake, coreID := newCoreProviderFixture(t)
	fake.stubEnsureFlow()
	fake.handle("sendtoaddress", func(bitcoindCall) (any, string) { return "txid-single", "" })
	fake.handle("sendmany", func(bitcoindCall) (any, string) { return "txid-many", "" })
	ctx := context.Background()

	txid, err := provider.Send(ctx, coreID, SendRequest{
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

	txid, err = provider.Send(ctx, coreID, SendRequest{
		DestinationsSats: map[string]int64{"bcrt1qa": 1_000, "bcrt1qb": 2_000},
	})
	require.NoError(t, err)
	assert.Equal(t, "txid-many", txid)
	require.Len(t, fake.callsFor("sendmany"), 1)
}

func TestCoreProviderSendFeeRatePath(t *testing.T) {
	provider, fake, coreID := newCoreProviderFixture(t)
	fake.stubEnsureFlow()

	var fundedHex string
	fake.handle("fundrawtransaction", func(c bitcoindCall) (any, string) {
		fundedHex = mustString(t, c.Params[0])
		return map[string]any{"hex": fundedHex, "fee": 0.00001, "changepos": 1}, ""
	})
	fake.handle("signrawtransactionwithwallet", func(c bitcoindCall) (any, string) {
		return map[string]any{"hex": mustString(t, c.Params[0]), "complete": true}, ""
	})
	fake.handle("sendrawtransaction", func(bitcoindCall) (any, string) { return "txid-funded", "" })

	net := &chaincfg.RegressionNetParams
	dest := p2wpkhAddr(t, fixedKey(0x77), net)

	txid, err := provider.Send(context.Background(), coreID, SendRequest{
		DestinationsSats: map[string]int64{dest: 30_000},
		FeeRateSatPerVB:  5,
		OpReturnHex:      "cafe",
	})
	require.NoError(t, err)
	assert.Equal(t, "txid-funded", txid)

	funds := fake.callsFor("fundrawtransaction")
	require.Len(t, funds, 1)
	var opts map[string]any
	require.NoError(t, json.Unmarshal(funds[0].Params[1], &opts))
	assert.Equal(t, true, opts["add_inputs"])
	assert.Equal(t, float64(5), opts["fee_rate"])

	// The hex handed to fundrawtransaction is our locally-built tx:
	// destination + OP_RETURN, no inputs yet.
	tx := decodeTxHex(t, fundedHex)
	assert.Empty(t, tx.TxIn)
	require.Len(t, tx.TxOut, 2)
	assert.Equal(t, int64(30_000), tx.TxOut[0].Value)
	assert.Equal(t, int64(0), tx.TxOut[1].Value)
	assert.Equal(t, byte(0x6a), tx.TxOut[1].PkScript[0], "second output is OP_RETURN")
}

func TestCoreProviderSendFixedFeeSelectsInputsAndChange(t *testing.T) {
	provider, fake, coreID := newCoreProviderFixture(t)
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
	var signedInputHex string
	fake.handle("signrawtransactionwithwallet", func(c bitcoindCall) (any, string) {
		signedInputHex = mustString(t, c.Params[0])
		return map[string]any{"hex": signedInputHex, "complete": true}, ""
	})
	fake.handle("sendrawtransaction", func(bitcoindCall) (any, string) { return "txid-fixed", "" })

	txid, err := provider.Send(context.Background(), coreID, SendRequest{
		DestinationsSats: map[string]int64{dest: 50_000},
		FixedFeeSats:     1_000,
	})
	require.NoError(t, err)
	assert.Equal(t, "txid-fixed", txid)

	// The raw path builds locally: no createrawtransaction, no fundrawtransaction.
	assert.Empty(t, fake.callsFor("createrawtransaction"))
	assert.Empty(t, fake.callsFor("fundrawtransaction"))

	// Largest-first selection skips the unspendable 90k UTXO, picks 40k+20k.
	tx := decodeTxHex(t, signedInputHex)
	require.Len(t, tx.TxIn, 2)
	assert.Equal(t, strings.Repeat("22", 32), tx.TxIn[0].PreviousOutPoint.Hash.String())
	assert.Equal(t, strings.Repeat("11", 32), tx.TxIn[1].PreviousOutPoint.Hash.String())

	// Outputs: destination 50k + change 60k-50k-1k = 9k.
	require.Len(t, tx.TxOut, 2)
	assert.Equal(t, int64(50_000), tx.TxOut[0].Value)
	assert.Equal(t, int64(9_000), tx.TxOut[1].Value)
}

func TestCoreProviderSendReplayProtect(t *testing.T) {
	provider, fake, coreID := newCoreProviderFixture(t)
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
	var signInputHex, broadcastHex string
	fake.handle("signrawtransactionwithwallet", func(c bitcoindCall) (any, string) {
		signInputHex = mustString(t, c.Params[0])
		return map[string]any{"hex": signInputHex, "complete": true}, ""
	})
	fake.handle("sendrawtransaction", func(c bitcoindCall) (any, string) {
		broadcastHex = mustString(t, c.Params[0])
		return "txid-replay", ""
	})

	_, err := provider.Send(context.Background(), coreID, SendRequest{
		DestinationsSats: map[string]int64{dest: 50_000},
		FixedFeeSats:     1_000,
		ReplayProtect:    true,
	})
	require.NoError(t, err)

	// The magic version is set BEFORE signing (the signature commits to it)…
	tx := decodeTxHex(t, signInputHex)
	assert.Equal(t, int32(12566463), tx.Version)
	// …and the replay byte is injected AFTER, making the broadcast hex start
	// with version bfbfbf00 followed by the 0x3f marker.
	assert.True(t, strings.HasPrefix(broadcastHex, "bfbfbf003f"), "broadcast hex %s", broadcastHex[:12])
}

func TestCoreProviderWatchKeys(t *testing.T) {
	provider, fake, coreID := newCoreProviderFixture(t)
	fake.stubEnsureFlow()

	err := provider.WatchKeys(context.Background(), coreID, []WatchKey{
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

func TestCoreProviderNextReceiveAddress(t *testing.T) {
	provider, fake, coreID := newCoreProviderFixture(t)
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
	addr, err := provider.NextReceiveAddress(ctx, coreID)
	require.NoError(t, err)
	assert.Equal(t, "bcrt1qunused", addr)
	assert.Empty(t, fake.callsFor("getnewaddress"))

	// All used → mint.
	fake.handle("listreceivedbyaddress", func(bitcoindCall) (any, string) {
		return []map[string]any{{"address": "bcrt1qused", "amount": 0.5, "txids": []string{"a"}}}, ""
	})
	fake.handle("getnewaddress", func(bitcoindCall) (any, string) { return "bcrt1qminted", "" })
	addr, err = provider.NextReceiveAddress(ctx, coreID)
	require.NoError(t, err)
	assert.Equal(t, "bcrt1qminted", addr)
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

func decodeTxHex(t *testing.T, rawHex string) *wire.MsgTx {
	t.Helper()
	raw, err := hex.DecodeString(rawHex)
	require.NoError(t, err)
	var tx wire.MsgTx
	if tx.Deserialize(bytes.NewReader(raw)) == nil {
		return &tx
	}
	// A zero-input unsigned tx is ambiguous with the segwit marker; retry
	// with the legacy encoding, like Core's decoder does.
	tx = wire.MsgTx{}
	require.NoError(t, tx.DeserializeNoWitness(bytes.NewReader(raw)))
	return &tx
}
