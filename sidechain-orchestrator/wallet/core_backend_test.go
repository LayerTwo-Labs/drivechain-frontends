package wallet

import (
	"bytes"
	"context"
	"encoding/hex"
	"encoding/json"
	"net"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/replay"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
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
	return NewCoreRPCClient(StaticCoreEndpoint(host, port, "user", "pass"))
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
	// Serving one receive address costs one getaddressinfo, for its path.
	f.handle("getaddressinfo", func(c bitcoindCall) (any, string) {
		var address string
		_ = json.Unmarshal(c.Params[0], &address)
		return map[string]any{"address": address, "hdkeypath": "m/84'/1'/0'/0/0", "ismine": true}, ""
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
	backend := NewCoreBackend(svc, fake.client(t), StaticParams(&chaincfg.RegressionNetParams), log)
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

// A deleted wallet's Core wallet must not stay loaded: it keeps serving keys
// the user deleted, and a same-prefix successor would reuse its descriptors.
func TestCoreBackendForgetUnloadsWallet(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()
	fake.handle("unloadwallet", func(bitcoindCall) (any, string) { return map[string]any{}, "" })
	ctx := context.Background()

	name, err := backend.Ensure(ctx, coreID)
	require.NoError(t, err)

	require.NoError(t, backend.Forget(ctx, coreID))
	unloads := fake.callsFor("unloadwallet")
	require.Len(t, unloads, 1)
	assert.Equal(t, name, mustString(t, unloads[0].Params[0]))

	// The cached name is gone with it, so the next Ensure provisions from
	// scratch instead of handing back a wallet Core no longer has.
	creates := len(fake.callsFor("createwallet"))
	_, err = backend.Ensure(ctx, coreID)
	require.NoError(t, err)
	assert.Len(t, fake.callsFor("createwallet"), creates+1)
}

// Unloading alone isn't enough: the wallet's directory has to move aside too.
// Core refuses to create a wallet over an existing directory, and
// createAndImport's fallback would load the deleted wallet and import a
// same-named successor's descriptors into it.
func TestCoreBackendForgetBacksUpWalletDir(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	coreDir := t.TempDir()
	backend.svc.CoreDataDir = coreDir
	walletsDir := filepath.Join(coreDir, "regtest", "wallets")

	fake.stubEnsureFlow()
	// bitcoind creates the wallet's directory, and refuses a name whose
	// directory is already there.
	fake.handle("createwallet", func(c bitcoindCall) (any, string) {
		var name string
		if err := json.Unmarshal(c.Params[0], &name); err != nil {
			return nil, err.Error()
		}
		dir := filepath.Join(walletsDir, name)
		if _, err := os.Stat(dir); err == nil {
			return nil, "Failed to create database path '" + dir + "'. Database already exists."
		}
		if err := os.MkdirAll(dir, 0o700); err != nil {
			return nil, err.Error()
		}
		if err := os.WriteFile(filepath.Join(dir, "wallet.dat"), []byte(name), 0o600); err != nil {
			return nil, err.Error()
		}
		return map[string]any{}, ""
	})
	fake.handle("loadwallet", func(bitcoindCall) (any, string) { return map[string]any{}, "" })
	fake.handle("unloadwallet", func(bitcoindCall) (any, string) { return map[string]any{}, "" })
	ctx := context.Background()

	name, err := backend.Ensure(ctx, coreID)
	require.NoError(t, err)
	require.DirExists(t, filepath.Join(walletsDir, name))

	require.NoError(t, backend.Forget(ctx, coreID))
	assert.NoDirExists(t, filepath.Join(walletsDir, name))
	backup := findBackup(t, filepath.Join(coreDir, "wallet_backups"), name)
	require.NotEmpty(t, backup, "wallet dir moved to backup, never removed")
	assert.FileExists(t, filepath.Join(backup, "wallet.dat"))

	// A same-named successor now gets a Core wallet of its own: createwallet
	// succeeds and imports into it, and Core is never asked to load the
	// deleted wallet's file.
	imports := len(fake.callsFor("importdescriptors"))
	_, err = backend.Ensure(ctx, coreID)
	require.NoError(t, err)
	assert.Len(t, fake.callsFor("createwallet"), 2)
	assert.Empty(t, fake.callsFor("loadwallet"))
	assert.Greater(t, len(fake.callsFor("importdescriptors")), imports)
}

// Core rejects unloadwallet for a wallet it never loaded — one left behind by
// an earlier run. That's not a failure for the delete path, and the wallet's
// directory still has to move aside.
func TestCoreBackendForgetIgnoresUnloadedWallet(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	coreDir := t.TempDir()
	backend.svc.CoreDataDir = coreDir
	name := "wallet_" + coreID[:8]
	dir := filepath.Join(coreDir, "regtest", "wallets", name)
	require.NoError(t, os.MkdirAll(dir, 0o700))
	fake.handle("unloadwallet", func(bitcoindCall) (any, string) {
		return nil, "Requested wallet does not exist or is not loaded"
	})

	require.NoError(t, backend.Forget(context.Background(), coreID))
	require.Len(t, fake.callsFor("unloadwallet"), 1)
	assert.NoDirExists(t, dir)
	assert.NotEmpty(t, findBackup(t, filepath.Join(coreDir, "wallet_backups"), name))
}

// The delete path reaches Core through the engine, which can no longer resolve
// the wallet's type — the wallet is already out of wallet.json.
func TestWalletEngineForgetWalletAfterDelete(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()
	fake.handle("unloadwallet", func(bitcoindCall) (any, string) { return map[string]any{}, "" })
	ctx := context.Background()

	svc := backend.svc
	log := zerolog.New(zerolog.NewTestWriter(t))
	router := NewBackendRouter(svc, backend, nil)
	engine := NewWalletEngine(svc, router, StaticParams(&chaincfg.RegressionNetParams), log)

	name, err := engine.Backend().Ensure(ctx, coreID)
	require.NoError(t, err)
	require.NoError(t, svc.DeleteWallet(coreID))

	require.NoError(t, engine.ForgetWallet(ctx, coreID))
	unloads := fake.callsFor("unloadwallet")
	require.Len(t, unloads, 1)
	assert.Equal(t, name, mustString(t, unloads[0].Params[0]))
}

// A failed BIP47 notification import doesn't break wallet loading, but the
// wallet must not be cached as fully provisioned: later calls retry it.
func TestCoreBackendRetriesFailedBip47NotificationImport(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()

	var mu sync.Mutex
	failNotif := true
	fake.handle("importdescriptors", func(c bitcoindCall) (any, string) {
		var descs []ImportDescriptor
		_ = json.Unmarshal(c.Params[0], &descs)
		mu.Lock()
		fail := failNotif && len(descs) == 1 && strings.HasPrefix(descs[0].Desc, "pkh(")
		mu.Unlock()
		results := make([]map[string]any, len(descs))
		for i := range results {
			results[i] = map[string]any{"success": !fail}
			if fail {
				results[i]["error"] = map[string]any{"code": -1, "message": "rescan timed out"}
			}
		}
		return results, ""
	})
	ctx := context.Background()

	_, err := backend.Ensure(ctx, coreID)
	require.NoError(t, err)
	require.Len(t, fake.callsFor("importdescriptors"), 2)

	// Within the backoff window the failed import isn't hammered.
	_, err = backend.Ensure(ctx, coreID)
	require.NoError(t, err)
	assert.Len(t, fake.callsFor("importdescriptors"), 2)

	mu.Lock()
	failNotif = false
	mu.Unlock()
	backend.mu.Lock()
	backend.bip47NotifRetry[coreID] = time.Time{} // backoff elapsed
	backend.mu.Unlock()

	// Once the backoff elapses the notification descriptor is imported again.
	_, err = backend.walletName(ctx, coreID)
	require.NoError(t, err)
	imports := fake.callsFor("importdescriptors")
	require.Len(t, imports, 3)
	var notif []ImportDescriptor
	require.NoError(t, json.Unmarshal(imports[2].Params[0], &notif))
	require.Len(t, notif, 1)
	assert.True(t, strings.HasPrefix(notif[0].Desc, "pkh("))

	// Now that it succeeded, no further imports.
	_, err = backend.Ensure(ctx, coreID)
	require.NoError(t, err)
	assert.Len(t, fake.callsFor("importdescriptors"), 3)
	assert.Empty(t, backend.bip47NotifRetry)
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

func TestCoreBackendSendFixedFeeResolvesRequiredInputValue(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()

	net := &chaincfg.RegressionNetParams
	dest := p2wpkhAddr(t, fixedKey(0xCC), net)
	change := p2wpkhAddr(t, fixedKey(0xDD), net)
	pinned := strings.Repeat("55", 32)

	fake.handle("listunspent", func(c bitcoindCall) (any, string) {
		// minconf 0 so a pinned unconfirmed output still resolves.
		var minConf int
		require.NoError(t, json.Unmarshal(c.Params[0], &minConf))
		assert.Equal(t, 0, minConf)
		return []map[string]any{
			{"txid": pinned, "vout": 2, "amount": 0.001, "spendable": true},
		}, ""
	})
	fake.handle("getrawchangeaddress", func(bitcoindCall) (any, string) { return change, "" })
	fake.handle("createrawtransaction", func(bitcoindCall) (any, string) { return "deadbeef", "" })
	fake.handle("signrawtransactionwithwallet", func(c bitcoindCall) (any, string) {
		return map[string]any{"hex": mustString(t, c.Params[0]), "complete": true}, ""
	})
	fake.handle("sendrawtransaction", func(bitcoindCall) (any, string) { return "txid-pinned", "" })

	// AmountSats left at zero, as callers that only know the outpoint send it.
	txid, err := backend.Send(context.Background(), coreID, SendRequest{
		DestinationsSats: map[string]int64{dest: 50_000},
		FixedFeeSats:     1_000,
		RequiredInputs:   []RequiredInput{{TxID: pinned, Vout: 2}},
	})
	require.NoError(t, err)
	assert.Equal(t, "txid-pinned", txid)

	creates := fake.callsFor("createrawtransaction")
	require.Len(t, creates, 1)
	var inputs []RawInput
	require.NoError(t, json.Unmarshal(creates[0].Params[0], &inputs))
	require.Len(t, inputs, 1)
	assert.Equal(t, pinned, inputs[0].TxID)
	assert.Equal(t, 2, inputs[0].Vout)

	// Change is 100k on-chain - 50k dest - 1k fee, not burned by the zero amount.
	var outputs []map[string]any
	require.NoError(t, json.Unmarshal(creates[0].Params[1], &outputs))
	require.Len(t, outputs, 2)
	assert.Equal(t, 0.0005, outputs[0][dest])
	assert.Equal(t, 0.00049, outputs[1][change])
}

func TestCoreBackendSendFixedFeeRejectsForeignRequiredInput(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()

	net := &chaincfg.RegressionNetParams
	dest := p2wpkhAddr(t, fixedKey(0xCC), net)
	foreign := strings.Repeat("66", 32)

	fake.handle("listunspent", func(bitcoindCall) (any, string) { return []map[string]any{}, "" })
	// Core's reply for an outpoint it does not know.
	fake.handle("getrawtransaction", func(bitcoindCall) (any, string) {
		return nil, "No such mempool or blockchain transaction"
	})

	_, err := backend.Send(context.Background(), coreID, SendRequest{
		DestinationsSats: map[string]int64{dest: 50_000},
		FixedFeeSats:     1_000,
		RequiredInputs:   []RequiredInput{{TxID: foreign, Vout: 0, AmountSats: 1_000_000}},
	})
	require.ErrorContains(t, err, "is not a wallet UTXO")
	assert.Empty(t, fake.callsFor("createrawtransaction"))
}

// A replacement pins the inputs of the transaction it replaces. That
// unconfirmed transaction already spends them, so listunspent does not carry
// them and the value has to come from the previous output.
func TestCoreBackendSendFixedFeeResolvesSpentRequiredInput(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()

	net := &chaincfg.RegressionNetParams
	dest := p2wpkhAddr(t, fixedKey(0xCC), net)
	prev := strings.Repeat("77", 32)

	fake.handle("listunspent", func(bitcoindCall) (any, string) { return []map[string]any{}, "" })
	fake.handle("getrawtransaction", func(bitcoindCall) (any, string) {
		return map[string]any{
			"txid": prev,
			"vout": []map[string]any{
				{"value": 0.001, "n": 0},
				{"value": 0.01, "n": 1},
			},
		}, ""
	})

	fake.handle("getrawchangeaddress", func(bitcoindCall) (any, string) {
		return p2wpkhAddr(t, fixedKey(0xDD), net), ""
	})
	fake.handle("createrawtransaction", func(bitcoindCall) (any, string) { return "deadbeef", "" })
	fake.handle("signrawtransactionwithwallet", func(c bitcoindCall) (any, string) {
		return map[string]any{"hex": mustString(t, c.Params[0]), "complete": true}, ""
	})
	fake.handle("sendrawtransaction", func(bitcoindCall) (any, string) { return "txid-replacement", "" })

	// No AmountSats: the caller does not know it, so Core must supply it.
	_, err := backend.Send(context.Background(), coreID, SendRequest{
		DestinationsSats: map[string]int64{dest: 50_000},
		FixedFeeSats:     1_000,
		RequiredInputs:   []RequiredInput{{TxID: prev, Vout: 1}},
	})
	require.NoError(t, err)

	created := fake.callsFor("createrawtransaction")
	require.Len(t, created, 1)
	// 1_000_000 in, 50_000 out, 1_000 fee -> 949_000 change.
	require.Contains(t, string(created[0].Params[1]), "0.00949")
}

func TestCoreBackendSendReplayProtect(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	backend.svc.SetNetwork("ecash")
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
	})
	require.NoError(t, err)

	// Replay protection is applied by passing the magic locktime as
	// createrawtransaction's 3rd argument; Core lowers the input sequences.
	creates := fake.callsFor("createrawtransaction")
	require.Len(t, creates, 1)
	var locktime uint32
	require.NoError(t, json.Unmarshal(creates[0].Params[2], &locktime))
	assert.Equal(t, replay.ReplayLockTime, locktime)

	// No hex surgery — the built tx is signed and broadcast unchanged.
	assert.Equal(t, "01000000aabbccdd", signInputHex)
	assert.Equal(t, "01000000aabbccdd", broadcastHex)
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

// TestCoreBackendCreateCpfpTaproot proves CPFP works for a taproot-only (BIP86)
// Core wallet: the child must be sized as P2TR and a bech32m address requested,
// not the hardcoded native-segwit child that would break a tr()-only wallet.
func TestCoreBackendCreateCpfpTaproot(t *testing.T) {
	svc := newTestService(t)
	_, err := svc.GenerateWallet("Enforcer", "", "", testSlots)
	require.NoError(t, err)
	// Explicit BIP86 path => taproot-only Core wallet (imports only tr()).
	core, err := svc.GenerateWalletWithPath("CoreTaproot", "", "", 0, "m/86'/1'/0'", "", testSlots)
	require.NoError(t, err)
	require.Equal(t, WalletTypeBitcoinCore, core.WalletType)

	fake := newFakeBitcoind(t)
	log := zerolog.New(zerolog.NewTestWriter(t))
	backend := NewCoreBackend(svc, fake.client(t), StaticParams(&chaincfg.RegressionNetParams), log)
	coreID := core.ID

	// The wallet resolves to taproot.
	require.Equal(t, ScriptTaproot, backend.walletScriptKind(coreID))

	fake.stubEnsureFlow()

	const (
		parentTxid  = "66666666666666666666666666666666666666666666666666666666666666bb"
		parentValue = int64(200_000)
		parentVsize = int64(150)
		parentFee   = int64(150)
		targetRate  = int64(20)
	)
	// A P2TR (bech32m) child address — regtest HRP "bcrt" + "1p".
	taprootAddr := p2trAddr(t, fixedKey(0x88), &chaincfg.RegressionNetParams)
	require.True(t, strings.HasPrefix(taprootAddr, "bcrt1p"), "child address must be bech32m taproot")

	fake.handle("listunspent", func(bitcoindCall) (any, string) {
		return []map[string]any{
			{"txid": parentTxid, "vout": 0, "amount": 0.002, "spendable": true, "confirmations": 0},
		}, ""
	})
	fake.handle("getmempoolentry", func(bitcoindCall) (any, string) {
		return map[string]any{"vsize": parentVsize, "fees": map[string]any{"base": float64(parentFee) / 1e8}}, ""
	})
	var requestedAddressType string
	fake.handle("listreceivedbyaddress", func(bitcoindCall) (any, string) {
		// No reusable unused address => forces a getnewaddress with the kind.
		return []map[string]any{}, ""
	})
	fake.handle("getnewaddress", func(c bitcoindCall) (any, string) {
		if len(c.Params) >= 2 {
			requestedAddressType = mustString(t, c.Params[1])
		}
		return taprootAddr, ""
	})
	var builtOutputs []map[string]any
	fake.handle("createrawtransaction", func(c bitcoindCall) (any, string) {
		require.NoError(t, json.Unmarshal(c.Params[1], &builtOutputs))
		return "deadbeefcpfptr", ""
	})
	fake.handle("signrawtransactionwithwallet", func(c bitcoindCall) (any, string) {
		return map[string]any{"hex": mustString(t, c.Params[0]), "complete": true}, ""
	})
	fake.handle("sendrawtransaction", func(bitcoindCall) (any, string) { return "child-txid-tr", "" })

	childTxid, err := backend.CreateCpfp(context.Background(), coreID, CpfpRequest{
		ParentTxID: parentTxid,
		ParentVout: 0,
		TargetRate: targetRate,
	})
	require.NoError(t, err)
	assert.Equal(t, "child-txid-tr", childTxid)
	assert.Equal(t, "bech32m", requestedAddressType, "taproot wallet must request a bech32m child address")

	// The child output is sized with TAPROOT vsize, not native segwit.
	childVsize := int64(11 + inputVsize(ScriptTaproot) + outputVsizeForKind(ScriptTaproot))
	_, outputSats, err := cpfpChildPlan(targetRate, parentVsize, parentFee, childVsize, parentValue)
	require.NoError(t, err)
	require.Len(t, builtOutputs, 1)
	assert.InDelta(t, btcutil.Amount(outputSats).ToBTC(), builtOutputs[0][taprootAddr], 1e-12)

	// Taproot sizing differs from native segwit — the fix actually changes the plan.
	nsVsize := int64(11 + inputVsize(ScriptNativeSegwit) + outputVsizeForKind(ScriptNativeSegwit))
	assert.NotEqual(t, nsVsize, childVsize, "taproot child vsize must differ from native segwit")
}

// TestCoreBackendCpfpBase58Kinds proves the Core backend fully supports the
// base58 script kinds that custom derivation (purpose 44'/49') makes reachable:
// a legacy and a nested-segwit Core wallet each generate a kind-correct receive
// address (right addressType, candidate filter matches base58) and complete a
// CPFP sized for that kind.
func TestCoreBackendCpfpBase58Kinds(t *testing.T) {
	net := &chaincfg.RegressionNetParams
	cases := []struct {
		name        string
		path        string
		kind        ScriptKind
		addressType string
		childAddr   func(*testing.T) string
	}{
		{"legacy", "m/44'/1'/0'", ScriptLegacy, "legacy",
			func(t *testing.T) string { return p2pkhAddr(t, fixedKey(0x44), net) }},
		{"nested-segwit", "m/49'/1'/0'", ScriptNestedSegwit, "p2sh-segwit",
			func(t *testing.T) string { return p2shSegwitAddr(t, fixedKey(0x49), net) }},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			svc := newTestService(t)
			_, err := svc.GenerateWallet("Enforcer", "", "", testSlots)
			require.NoError(t, err)
			core, err := svc.GenerateWalletWithPath("Core-"+tc.name, "", "", 0, tc.path, "", testSlots)
			require.NoError(t, err)

			fake := newFakeBitcoind(t)
			backend := NewCoreBackend(svc, fake.client(t), StaticParams(net), zerolog.New(zerolog.NewTestWriter(t)))
			coreID := core.ID
			require.Equal(t, tc.kind, backend.walletScriptKind(coreID))

			fake.stubEnsureFlow()
			childAddr := tc.childAddr(t)

			const (
				parentTxid  = "66666666666666666666666666666666666666666666666666666666666666cc"
				parentValue = int64(200_000)
				parentVsize = int64(150)
				parentFee   = int64(150)
				targetRate  = int64(20)
			)
			fake.handle("listunspent", func(bitcoindCall) (any, string) {
				return []map[string]any{{"txid": parentTxid, "vout": 0, "amount": 0.002, "spendable": true, "confirmations": 0}}, ""
			})
			fake.handle("getmempoolentry", func(bitcoindCall) (any, string) {
				return map[string]any{"vsize": parentVsize, "fees": map[string]any{"base": float64(parentFee) / 1e8}}, ""
			})
			// An unused base58 address of the wallet's kind: the candidate filter
			// must match it (the old witness-prefix filter never would).
			fake.handle("listreceivedbyaddress", func(bitcoindCall) (any, string) {
				return []map[string]any{{"address": childAddr, "amount": 0.0, "txids": []string{}}}, ""
			})
			var calledGetNewAddress bool
			fake.handle("getnewaddress", func(bitcoindCall) (any, string) {
				calledGetNewAddress = true
				return childAddr, ""
			})
			var builtOutputs []map[string]any
			fake.handle("createrawtransaction", func(c bitcoindCall) (any, string) {
				require.NoError(t, json.Unmarshal(c.Params[1], &builtOutputs))
				return "deadbeefcpfp58", ""
			})
			fake.handle("signrawtransactionwithwallet", func(c bitcoindCall) (any, string) {
				return map[string]any{"hex": mustString(t, c.Params[0]), "complete": true}, ""
			})
			fake.handle("sendrawtransaction", func(bitcoindCall) (any, string) { return "child-58", "" })

			// The reused unused address path must be hit (filter matches base58).
			addr, err := nextAddr(backend, context.Background(), coreID, tc.kind)
			require.NoError(t, err)
			assert.Equal(t, childAddr, addr, "must reuse the matching base58 address")
			assert.False(t, calledGetNewAddress, "an unused kind-matching address should be reused, not minted")

			// addressType mapping is correct for getnewaddress when no reuse exists.
			at, ok := coreAddressType(tc.kind)
			require.True(t, ok)
			assert.Equal(t, tc.addressType, at)

			// CPFP completes and sizes the child for this kind.
			childTxid, err := backend.CreateCpfp(context.Background(), coreID, CpfpRequest{
				ParentTxID: parentTxid, ParentVout: 0, TargetRate: targetRate,
			})
			require.NoError(t, err)
			assert.Equal(t, "child-58", childTxid)

			childVsize := int64(11 + inputVsize(tc.kind) + outputVsizeForKind(tc.kind))
			_, outputSats, err := cpfpChildPlan(targetRate, parentVsize, parentFee, childVsize, parentValue)
			require.NoError(t, err)
			require.Len(t, builtOutputs, 1)
			assert.InDelta(t, btcutil.Amount(outputSats).ToBTC(), builtOutputs[0][childAddr], 1e-12)
		})
	}
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

	net := &chaincfg.RegressionNetParams
	usedSegwit := p2wpkhAddr(t, fixedKey(0x01), net)
	unusedSegwit := p2wpkhAddr(t, fixedKey(0x02), net)
	unusedLegacy := p2pkhAddr(t, fixedKey(0x03), net)

	// An unused bech32 address is reused instead of minting a new one;
	// used and wrong-kind (P2PKH) entries are skipped.
	fake.handle("listreceivedbyaddress", func(bitcoindCall) (any, string) {
		return []map[string]any{
			{"address": usedSegwit, "amount": 0.5, "txids": []string{"a"}},
			{"address": unusedLegacy, "amount": 0.0, "txids": []string{}},
			{"address": unusedSegwit, "amount": 0.0, "txids": []string{}},
		}, ""
	})
	addr, err := nextAddr(backend, ctx, coreID, ScriptNativeSegwit)
	require.NoError(t, err)
	assert.Equal(t, unusedSegwit, addr)
	assert.Empty(t, fake.callsFor("getnewaddress"))

	// All used → mint with address_type=bech32.
	fake.handle("listreceivedbyaddress", func(bitcoindCall) (any, string) {
		return []map[string]any{{"address": usedSegwit, "amount": 0.5, "txids": []string{"a"}}}, ""
	})
	var mintedType string
	fake.handle("getnewaddress", func(c bitcoindCall) (any, string) {
		if len(c.Params) > 1 {
			mintedType = mustString(t, c.Params[1])
		}
		return unusedSegwit, ""
	})
	addr, err = nextAddr(backend, ctx, coreID, ScriptNativeSegwit)
	require.NoError(t, err)
	assert.Equal(t, unusedSegwit, addr)
	assert.Equal(t, "bech32", mintedType)
}

// TestCoreBackendNextReceiveAddressUnknownSentinel pins the default-sentinel
// behavior: NextReceiveAddress(..., ScriptUnknown) means "the wallet's natural
// kind", which for a default Core wallet is native segwit (bech32). A regression
// here broke the integration test's getnewaddress path.
func TestCoreBackendNextReceiveAddressUnknownSentinel(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()
	ctx := context.Background()

	net := &chaincfg.RegressionNetParams
	minted := p2wpkhAddr(t, fixedKey(0x21), net)

	// No reusable unused address → mint, and the requested type must be bech32.
	fake.handle("listreceivedbyaddress", func(bitcoindCall) (any, string) { return []map[string]any{}, "" })
	var mintedType string
	fake.handle("getnewaddress", func(c bitcoindCall) (any, string) {
		if len(c.Params) > 1 {
			mintedType = mustString(t, c.Params[1])
		}
		return minted, ""
	})

	addr, err := nextAddr(backend, ctx, coreID, ScriptUnknown)
	require.NoError(t, err)
	assert.Equal(t, minted, addr)
	assert.Equal(t, "bech32", mintedType, "ScriptUnknown must resolve to native segwit for a default wallet")
}

func TestCoreBackendNextReceiveAddressTaproot(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()
	ctx := context.Background()

	net := &chaincfg.RegressionNetParams
	unusedSegwit := p2wpkhAddr(t, fixedKey(0x11), net)
	unusedTaproot := p2trAddr(t, fixedKey(0x12), net)
	mintedTaproot := p2trAddr(t, fixedKey(0x13), net)

	// A taproot request skips segwit candidates and reuses the unused P2TR one.
	fake.handle("listreceivedbyaddress", func(bitcoindCall) (any, string) {
		return []map[string]any{
			{"address": unusedSegwit, "amount": 0.0, "txids": []string{}},
			{"address": unusedTaproot, "amount": 0.0, "txids": []string{}},
		}, ""
	})
	addr, err := nextAddr(backend, ctx, coreID, ScriptTaproot)
	require.NoError(t, err)
	assert.Equal(t, unusedTaproot, addr)
	assert.Empty(t, fake.callsFor("getnewaddress"))

	// No unused taproot candidate → mint with address_type=bech32m.
	fake.handle("listreceivedbyaddress", func(bitcoindCall) (any, string) {
		return []map[string]any{{"address": unusedSegwit, "amount": 0.0, "txids": []string{}}}, ""
	})
	var mintedType string
	fake.handle("getnewaddress", func(c bitcoindCall) (any, string) {
		if len(c.Params) > 1 {
			mintedType = mustString(t, c.Params[1])
		}
		return mintedTaproot, ""
	})
	addr, err = nextAddr(backend, ctx, coreID, ScriptTaproot)
	require.NoError(t, err)
	assert.Equal(t, mintedTaproot, addr)
	assert.Equal(t, "bech32m", mintedType)
}

// TestCoreBackendNextChangeAddressKind pins change addresses to the wallet's own
// script kind: a tr()-only wallet has no bech32 ScriptPubKeyMan to serve.
func TestCoreBackendNextChangeAddressKind(t *testing.T) {
	net := &chaincfg.RegressionNetParams
	ctx := context.Background()

	t.Run("default wallet stays bech32", func(t *testing.T) {
		backend, fake, coreID := newCoreBackendFixture(t)
		fake.stubEnsureFlow()

		change := p2wpkhAddr(t, fixedKey(0x31), net)
		var requestedType string
		fake.handle("getrawchangeaddress", func(c bitcoindCall) (any, string) {
			if len(c.Params) > 0 {
				requestedType = mustString(t, c.Params[0])
			}
			return change, ""
		})

		addr, err := backend.NextChangeAddress(ctx, coreID)
		require.NoError(t, err)
		assert.Equal(t, change, addr)
		assert.Equal(t, "bech32", requestedType)
	})

	t.Run("taproot wallet requests bech32m", func(t *testing.T) {
		svc := newTestService(t)
		_, err := svc.GenerateWallet("Enforcer", "", "", testSlots)
		require.NoError(t, err)
		core, err := svc.GenerateWalletWithPath("CoreTaproot", "", "", 0, "m/86'/1'/0'", "", testSlots)
		require.NoError(t, err)

		fake := newFakeBitcoind(t)
		backend := NewCoreBackend(svc, fake.client(t), func() *chaincfg.Params { return net }, zerolog.New(zerolog.NewTestWriter(t)))
		coreID := core.ID
		require.Equal(t, ScriptTaproot, backend.walletScriptKind(coreID))

		fake.stubEnsureFlow()

		change := p2trAddr(t, fixedKey(0x32), net)
		var requestedType string
		fake.handle("getrawchangeaddress", func(c bitcoindCall) (any, string) {
			if len(c.Params) > 0 {
				requestedType = mustString(t, c.Params[0])
			}
			return change, ""
		})

		addr, err := backend.NextChangeAddress(ctx, coreID)
		require.NoError(t, err)
		assert.Equal(t, change, addr)
		assert.Equal(t, "bech32m", requestedType)
	})
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

// A BIP300 M5 deposit needs both halves that only Core lacked: a bare
// OP_DRIVECHAIN scriptPubKey, and the CTIP spent as an unsigned external input.
func TestCoreBackendSendM5Deposit(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()

	const (
		ctipTxid      = "77777777777777777777777777777777777777777777777777777777777777aa"
		walletTxid    = "1111111111111111111111111111111111111111111111111111111111111111"
		oldTreasury   = int64(500_000)
		depositSats   = int64(120_000)
		feeSats       = int64(2_000)
		walletFunds   = int64(300_000)
		sidechainSlot = 1
	)
	treasury := []byte{0xb4, 0x01, sidechainSlot, 0x51}
	net := &chaincfg.RegressionNetParams

	fake.handle("listunspent", func(bitcoindCall) (any, string) {
		return []map[string]any{
			{"txid": walletTxid, "vout": 0, "amount": float64(walletFunds) / 1e8, "spendable": true},
		}, ""
	})
	fake.handle("getrawchangeaddress", func(bitcoindCall) (any, string) {
		return p2wpkhAddr(t, fixedKey(0xBB), net), ""
	})
	var signedHex string
	// Core can never sign the anyone-can-spend CTIP, so it reports incomplete.
	fake.handle("signrawtransactionwithwallet", func(c bitcoindCall) (any, string) {
		signedHex = mustString(t, c.Params[0])
		return map[string]any{"hex": signedHex, "complete": false}, ""
	})
	fake.handle("sendrawtransaction", func(bitcoindCall) (any, string) { return "m5-txid", "" })

	txid, err := backend.Send(context.Background(), coreID, SendRequest{
		RawOutputs: []TxOutSpec{
			{RawScriptHex: hex.EncodeToString(treasury), AmountSats: oldTreasury + depositSats},
		},
		OpReturnHex:  hex.EncodeToString([]byte("s1_depositaddress")),
		FixedFeeSats: feeSats,
		ExternalInputs: []ExternalInput{{
			TxID: ctipTxid, Vout: 0, AmountSats: oldTreasury,
			ScriptPubKeyHex: hex.EncodeToString(treasury),
		}},
	})
	require.NoError(t, err, "an unsigned external input must not fail the send")
	assert.Equal(t, "m5-txid", txid)
	assert.Empty(t, fake.callsFor("createrawtransaction"),
		"createrawtransaction cannot express a bare scriptPubKey")

	raw, err := hex.DecodeString(signedHex)
	require.NoError(t, err)
	var tx wire.MsgTx
	require.NoError(t, tx.Deserialize(bytes.NewReader(raw)))

	require.Len(t, tx.TxIn, 2)
	assert.Equal(t, ctipTxid, tx.TxIn[0].PreviousOutPoint.Hash.String(), "CTIP holds input 0")
	assert.Empty(t, tx.TxIn[0].SignatureScript, "the CTIP is spent with an empty scriptSig")
	assert.Equal(t, walletTxid, tx.TxIn[1].PreviousOutPoint.Hash.String())

	require.Len(t, tx.TxOut, 3)
	assert.Equal(t, treasury, tx.TxOut[0].PkScript, "treasury script is emitted verbatim")
	assert.Equal(t, oldTreasury+depositSats, tx.TxOut[0].Value, "treasury grows by the deposit")
	assert.Equal(t, byte(txscript.OP_RETURN), tx.TxOut[1].PkScript[0])
	assert.Equal(t, walletFunds-depositSats-feeSats, tx.TxOut[2].Value,
		"only the deposit and fee leave the wallet; the CTIP passes through")
}

// A wallet restored from someone's existing seed has history older than the
// import, so Core has to rescan from genesis to find its coins.
func TestImportTimestampRescansRestoredSeeds(t *testing.T) {
	if got := importTimestamp(&WalletData{Imported: true}); got != int64(0) {
		t.Errorf("importTimestamp(imported) = %v, want int64(0) — a rescan from genesis", got)
	}
	if got := importTimestamp(&WalletData{}); got != "now" {
		t.Errorf("importTimestamp(generated) = %v, want \"now\"", got)
	}
}

// The flag is what tells the two apart, and it is set at generation time.
func TestGenerateFullWalletMarksImportedSeeds(t *testing.T) {
	const mnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"

	restored, err := GenerateFullWallet("restored", mnemonic, "", nil, WalletTypeBitcoinCore)
	if err != nil {
		t.Fatalf("GenerateFullWallet(custom): %v", err)
	}
	if !restored.Imported {
		t.Error("a wallet built from a supplied mnemonic must be marked imported")
	}

	fresh, err := GenerateFullWallet("fresh", "", "", nil, WalletTypeBitcoinCore)
	if err != nil {
		t.Fatalf("GenerateFullWallet(generated): %v", err)
	}
	if fresh.Imported {
		t.Error("a generated wallet has no history and must not be marked imported")
	}
}

// createwallet succeeding before a failing descriptor import leaves the wallet
// listed but empty. The retry must re-import it, not treat listwallets
// membership as proof the descriptors landed.
func TestCoreBackendRetryReimportsDescriptorsAfterPartialCreate(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()

	var mu sync.Mutex
	created := false
	failSingleSig := true
	fake.handle("listwallets", func(bitcoindCall) (any, string) {
		mu.Lock()
		defer mu.Unlock()
		if created {
			return []string{"wallet_" + coreID[:8]}, ""
		}
		return []string{}, ""
	})
	fake.handle("createwallet", func(bitcoindCall) (any, string) {
		mu.Lock()
		created = true
		mu.Unlock()
		return map[string]any{}, ""
	})
	// The first import failed, so the wallet holds no active descriptor. That
	// is exactly what must not be read as "already imported".
	fake.handle("listdescriptors", func(bitcoindCall) (any, string) {
		return map[string]any{"descriptors": []map[string]any{}}, ""
	})
	fake.handle("importdescriptors", func(c bitcoindCall) (any, string) {
		var descs []ImportDescriptor
		_ = json.Unmarshal(c.Params[0], &descs)
		mu.Lock()
		fail := failSingleSig && len(descs) == 4
		mu.Unlock()
		results := make([]map[string]any, len(descs))
		for i := range results {
			results[i] = map[string]any{"success": !fail}
			if fail {
				results[i]["error"] = map[string]any{"code": -5, "message": "Missing checksum"}
			}
		}
		return results, ""
	})
	ctx := context.Background()

	_, err := backend.Ensure(ctx, coreID)
	require.ErrorContains(t, err, "descriptor 0 import failed")
	require.Len(t, fake.callsFor("createwallet"), 1)

	mu.Lock()
	failSingleSig = false
	mu.Unlock()

	// The wallet is now in listwallets, so createwallet is skipped — but the
	// descriptors still have to be imported.
	name, err := backend.Ensure(ctx, coreID)
	require.NoError(t, err)
	assert.Equal(t, "wallet_"+coreID[:8], name)
	assert.Len(t, fake.callsFor("createwallet"), 1)

	imports := fake.callsFor("importdescriptors")
	require.GreaterOrEqual(t, len(imports), 2, "failed single-sig import, then its retry")
	var singleSig []ImportDescriptor
	require.NoError(t, json.Unmarshal(imports[1].Params[0], &singleSig))
	require.Len(t, singleSig, 4)
	assert.Contains(t, singleSig[0].Desc, "/84'/1'/0']")
}

// Core hands out no address it holds no descriptor for, so it imports exactly
// the kinds the wallet advertises. A legacy wallet advertises legacy alone.
func TestCoreBackendImportsTheWalletScriptTypeWithoutAPath(t *testing.T) {
	svc := newTestService(t)
	_, err := svc.GenerateWallet("Enforcer", "", "", testSlots)
	require.NoError(t, err)
	core, err := svc.GenerateWalletWithPath("CoreLegacy", "", "", 0, "", "legacy", testSlots)
	require.NoError(t, err)
	require.Empty(t, core.DerivationPath, "no path may travel with the wallet")
	require.Equal(t, "legacy", core.ScriptType)

	fake := newFakeBitcoind(t)
	backend := NewCoreBackend(svc, fake.client(t), StaticParams(&chaincfg.RegressionNetParams), zerolog.New(zerolog.NewTestWriter(t)))
	fake.stubEnsureFlow()

	_, err = backend.Ensure(context.Background(), core.ID)
	require.NoError(t, err)

	imports := fake.callsFor("importdescriptors")
	require.NotEmpty(t, imports)
	var singleSig []ImportDescriptor
	require.NoError(t, json.Unmarshal(imports[0].Params[0], &singleSig))
	require.Len(t, singleSig, 2, "the legacy pair alone, external + change")
	assert.Contains(t, singleSig[0].Desc, "pkh([")
	assert.Contains(t, singleSig[0].Desc, "/44'/1'/0']")

	// Address requests, change and CPFP sizing all read this. A different kind
	// here asks Core for a family it holds no descriptor for.
	assert.Equal(t, ScriptLegacy, backend.walletScriptKind(core.ID))
	assert.Equal(t, []ScriptKind{ScriptLegacy}, ReceiveKinds(core))
}

// A taproot wallet advertises taproot and native segwit, so Core imports both
// pairs. Importing the taproot pair alone would break the segwit Receive tab.
func TestCoreBackendImportsEveryKindTheWalletAdvertises(t *testing.T) {
	svc := newTestService(t)
	_, err := svc.GenerateWallet("Enforcer", "", "", testSlots)
	require.NoError(t, err)
	core, err := svc.GenerateWalletWithPath("CoreTaproot", "", "", 0, "", "taproot", testSlots)
	require.NoError(t, err)
	require.Equal(t, []ScriptKind{ScriptTaproot, ScriptNativeSegwit}, ReceiveKinds(core))

	fake := newFakeBitcoind(t)
	backend := NewCoreBackend(svc, fake.client(t), StaticParams(&chaincfg.RegressionNetParams), zerolog.New(zerolog.NewTestWriter(t)))
	fake.stubEnsureFlow()

	_, err = backend.Ensure(context.Background(), core.ID)
	require.NoError(t, err)

	var singleSig []ImportDescriptor
	require.NoError(t, json.Unmarshal(fake.callsFor("importdescriptors")[0].Params[0], &singleSig))
	require.Len(t, singleSig, 4, "the taproot pair and the segwit pair")
	assert.Contains(t, singleSig[0].Desc, "tr([")
	assert.Contains(t, singleSig[2].Desc, "wpkh([")
}

// coreBumpFeeFixture stubs an unconfirmed wallet transaction that pays a
// stranger and returns change, so a fee bump has both kinds of output.
func coreBumpFeeFixture(t *testing.T) (*CoreBackend, *fakeBitcoind, string, string, string) {
	t.Helper()
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()

	paymentAddr := p2wpkhAddr(t, fixedKey(0x88), &chaincfg.RegressionNetParams)
	changeAddr := p2wpkhAddr(t, fixedKey(0x99), &chaincfg.RegressionNetParams)

	fake.handle("getmempoolentry", func(c bitcoindCall) (any, string) {
		var txid string
		_ = json.Unmarshal(c.Params[0], &txid)
		if txid != coreBumpTxid {
			// Core picks its own size and fee for the replacement, and they
			// differ from what the plan predicted.
			return map[string]any{"vsize": 162, "fees": map[string]any{"base": float64(1620) / 1e8}, "descendantcount": 1}, ""
		}
		return map[string]any{"vsize": 150, "fees": map[string]any{"base": float64(150) / 1e8}, "descendantcount": 1}, ""
	})
	fake.handle("estimatesmartfee", func(bitcoindCall) (any, string) {
		return map[string]any{"feerate": 0.00002, "blocks": 3}, ""
	})
	fake.handle("gettransaction", func(bitcoindCall) (any, string) {
		return map[string]any{"txid": coreBumpTxid, "fee": -0.00000150}, ""
	})
	// Core carries no prevout for a transaction that waits in the mempool, so
	// the funding transaction answers who owns each input.
	fake.handle("getrawtransaction", func(c bitcoindCall) (any, string) {
		if mustString(t, c.Params[0]) == coreBumpFundingTxid {
			return map[string]any{
				"txid": coreBumpFundingTxid,
				"vout": []map[string]any{
					{"value": 0.002, "n": 0, "scriptPubKey": map[string]any{"address": changeAddr, "type": "witness_v0_keyhash"}},
				},
			}, ""
		}
		return map[string]any{
			"txid":     coreBumpTxid,
			"vsize":    150,
			"locktime": 0,
			"vin":      []map[string]any{{"txid": coreBumpFundingTxid, "vout": 0, "sequence": 4294967293}},
			"vout": []map[string]any{
				{"value": 0.001, "n": 0, "scriptPubKey": map[string]any{"address": paymentAddr, "type": "witness_v0_keyhash"}},
				{"value": 0.0009985, "n": 1, "scriptPubKey": map[string]any{"address": changeAddr, "type": "witness_v0_keyhash"}},
			},
		}, ""
	})
	fake.handle("getaddressinfo", func(c bitcoindCall) (any, string) {
		var address string
		_ = json.Unmarshal(c.Params[0], &address)
		return map[string]any{
			"address":   address,
			"hdkeypath": "m/84'/1'/0'/1/0",
			"ismine":    address == changeAddr,
			"ischange":  address == changeAddr,
		}, ""
	})
	return backend, fake, coreID, paymentAddr, changeAddr
}

// serveReplacement teaches the fake to answer getrawtransaction for the
// transaction a bump broadcasts, the way Core answers for its own replacement.
func (f *fakeBitcoind) serveReplacement(t *testing.T, txid, paymentAddr string, paymentBTC float64, changeAddr string, changeBTC float64) {
	t.Helper()
	previous := f.handlers["getrawtransaction"]
	f.handle("getrawtransaction", func(c bitcoindCall) (any, string) {
		if mustString(t, c.Params[0]) == txid {
			return map[string]any{
				"txid": txid,
				"vout": []map[string]any{
					{"value": paymentBTC, "n": 0, "scriptPubKey": map[string]any{"address": paymentAddr}},
					{"value": changeBTC, "n": 1, "scriptPubKey": map[string]any{"address": changeAddr}},
				},
			}, ""
		}
		return previous(c)
	})
}

const (
	coreBumpTxid        = "77777777777777777777777777777777777777777777777777777777777777aa"
	coreBumpFundingTxid = "88888888888888888888888888888888888888888888888888888888888888bb"
)

func TestCoreBackendBumpFeeTakesItFromChange(t *testing.T) {
	backend, fake, coreID, paymentAddr, changeAddr := coreBumpFeeFixture(t)
	fake.handle("bumpfee", func(bitcoindCall) (any, string) {
		return map[string]any{"txid": "replacement-txid"}, ""
	})
	fake.serveReplacement(t, "replacement-txid", paymentAddr, 0.001, changeAddr, 0.0009838)

	result, err := backend.BumpFee(context.Background(), coreID, BumpFeeRequest{TxID: coreBumpTxid, NewFeeRate: 10})
	require.NoError(t, err)
	assert.Equal(t, "replacement-txid", result.NewTxID)
	assert.False(t, result.Plan.ReducesPayment)
	assert.Equal(t, 1, result.Plan.FeeFromVout, "the change output pays")
	assert.Equal(t, int64(1620), result.Plan.NewFeeSats, "the plan reports what the replacement really pays, not what it planned")
	assert.Equal(t, int64(1470), result.Plan.ExtraFeeSats)
	assert.InDelta(t, 10.0, result.Plan.NewFeeRate, 0.001, "the rate follows the size Core chose")
	assert.Equal(t, int64(98_380), result.Plan.AmountAfter, "the plan reports what the change output really holds")

	calls := fake.callsFor("bumpfee")
	require.Len(t, calls, 1)
	require.Len(t, calls[0].Params, 2, "bumpfee must carry the fee rate")
	var options map[string]any
	require.NoError(t, json.Unmarshal(calls[0].Params[1], &options))
	assert.Equal(t, float64(10), options["fee_rate"])
	assert.Empty(t, fake.callsFor("sendrawtransaction"), "Core builds the replacement itself")
}

func TestCoreBackendBumpFeeTakesItFromAPayment(t *testing.T) {
	backend, fake, coreID, paymentAddr, changeAddr := coreBumpFeeFixture(t)
	fake.serveReplacement(t, "rebuilt-txid", paymentAddr, 0.0009865, changeAddr, 0.0009985)
	var signedHex string
	fake.handle("signrawtransactionwithwallet", func(c bitcoindCall) (any, string) {
		signedHex = mustString(t, c.Params[0])
		return map[string]any{"hex": signedHex, "complete": true}, ""
	})
	fake.handle("sendrawtransaction", func(bitcoindCall) (any, string) { return "rebuilt-txid", "" })

	vout := 0
	result, err := backend.BumpFee(context.Background(), coreID, BumpFeeRequest{
		TxID: coreBumpTxid, NewFeeRate: 10, FeeFromVout: &vout,
	})
	require.NoError(t, err)
	assert.Equal(t, "rebuilt-txid", result.NewTxID)
	assert.True(t, result.Plan.ReducesPayment)
	assert.Equal(t, int64(98_650), result.Plan.AmountAfter)
	assert.Empty(t, fake.callsFor("bumpfee"), "Core's bumpfee refuses to touch a payment")

	raw, err := hex.DecodeString(signedHex)
	require.NoError(t, err)
	var tx wire.MsgTx
	require.NoError(t, tx.Deserialize(bytes.NewReader(raw)))
	require.Len(t, tx.TxIn, 1, "the replacement spends the same input")
	assert.Equal(t, coreBumpFundingTxid, tx.TxIn[0].PreviousOutPoint.Hash.String())
	assert.Equal(t, bip125Sequence, tx.TxIn[0].Sequence, "the replacement stays replaceable")
	require.Len(t, tx.TxOut, 2)
	assert.Equal(t, int64(98_650), tx.TxOut[0].Value, "the recipient pays the higher fee")
	assert.Equal(t, int64(99_850), tx.TxOut[1].Value, "the change keeps its amount")
}

func TestCoreBackendPreviewBumpFeeReportsTheOutputs(t *testing.T) {
	backend, _, coreID, paymentAddr, changeAddr := coreBumpFeeFixture(t)

	preview, err := backend.PreviewBumpFee(context.Background(), coreID, BumpFeeRequest{TxID: coreBumpTxid, NewFeeRate: 10})
	require.NoError(t, err)
	assert.Equal(t, int64(150), preview.OldFeeSats)
	assert.Equal(t, int64(150), preview.VsizeVBytes)
	assert.Equal(t, 1, preview.InputCount)
	require.Len(t, preview.Outputs, 2)
	assert.Equal(t, paymentAddr, preview.Outputs[0].Address)
	assert.False(t, preview.Outputs[0].IsChange)
	assert.Equal(t, changeAddr, preview.Outputs[1].Address)
	assert.True(t, preview.Outputs[1].IsChange)
	require.NotNil(t, preview.Plan)
	assert.Equal(t, int64(1350), preview.Plan.ExtraFeeSats)
}

// A transaction this wallet does not fund has no replacement to build: Core
// reports no fee for it, and the rebuild could never sign its inputs.
func TestCoreBackendPreviewBumpFeeRefusesForeignInputs(t *testing.T) {
	backend, fake, coreID, _, _ := coreBumpFeeFixture(t)
	fake.handle("gettransaction", func(bitcoindCall) (any, string) {
		return map[string]any{"txid": coreBumpTxid}, ""
	})

	preview, err := backend.PreviewBumpFee(context.Background(), coreID, BumpFeeRequest{TxID: coreBumpTxid, NewFeeRate: 10})
	require.NoError(t, err)
	assert.Nil(t, preview.Plan)
	assert.Contains(t, preview.Reason, "signs none of the inputs")

	vout := 0
	_, err = backend.BumpFee(context.Background(), coreID, BumpFeeRequest{TxID: coreBumpTxid, NewFeeRate: 10, FeeFromVout: &vout})
	require.Error(t, err, "a replacement it cannot sign must not reach the node")
	assert.Empty(t, fake.callsFor("sendrawtransaction"))
}

// A rebuild signs every input again. A transaction with an input this wallet
// cannot sign — a sidechain CTIP, or a collaborative send — has no rebuild.
func TestCoreBackendPreviewBumpFeeRefusesAPartlyOwnedTransaction(t *testing.T) {
	backend, fake, coreID, _, _ := coreBumpFeeFixture(t)
	// Core counts only the wallet's own debit, so its fee falls short of the
	// fee the mempool reports when a foreign input helps fund the transaction.
	fake.handle("gettransaction", func(bitcoindCall) (any, string) {
		return map[string]any{"txid": coreBumpTxid, "fee": -0.00000100}, ""
	})

	for _, req := range []BumpFeeRequest{
		{TxID: coreBumpTxid, NewFeeRate: 10},
		{TxID: coreBumpTxid, NewFeeRate: 10, FeeFromVout: intPtr(0)},
	} {
		preview, err := backend.PreviewBumpFee(context.Background(), coreID, req)
		require.NoError(t, err)
		assert.Nil(t, preview.Plan)
		assert.False(t, preview.CanReplace, "neither Core's bumpfee nor a rebuild can sign it")
		assert.Contains(t, preview.Reason, "only part of the inputs")
	}
}

// A transaction that already carries a child has no replacement: it must outpay
// the child too, and Core's own bumpfee refuses such a parent.
func TestCoreBackendPreviewBumpFeeRefusesAParentWithAChild(t *testing.T) {
	backend, fake, coreID, _, _ := coreBumpFeeFixture(t)
	fake.handle("getmempoolentry", func(bitcoindCall) (any, string) {
		return map[string]any{"vsize": 150, "fees": map[string]any{"base": float64(150) / 1e8}, "descendantcount": 2}, ""
	})

	preview, err := backend.PreviewBumpFee(context.Background(), coreID, BumpFeeRequest{TxID: coreBumpTxid, NewFeeRate: 10})
	require.NoError(t, err)
	assert.Nil(t, preview.Plan)
	assert.False(t, preview.CanReplace)
	assert.True(t, preview.HasChild, "a child transaction cannot speed this one up either")
	assert.Contains(t, preview.Reason, "already spends this one")
}

func intPtr(v int) *int { return &v }

// A send that asks to stay replaceable must carry BIP125 sequences, so a fee
// bump can follow it. createrawtransaction cannot set them.
func TestCoreBackendReplaceableSendSignalsBip125(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()
	dest := p2wpkhAddr(t, fixedKey(0x21), &chaincfg.RegressionNetParams)

	fake.handle("listunspent", func(bitcoindCall) (any, string) {
		return []map[string]any{
			{"txid": coreBumpFundingTxid, "vout": 0, "amount": 0.01, "spendable": true, "confirmations": 3},
		}, ""
	})
	fake.handle("getrawchangeaddress", func(bitcoindCall) (any, string) {
		return p2wpkhAddr(t, fixedKey(0x22), &chaincfg.RegressionNetParams), ""
	})
	var signedHex string
	fake.handle("signrawtransactionwithwallet", func(c bitcoindCall) (any, string) {
		signedHex = mustString(t, c.Params[0])
		return map[string]any{"hex": signedHex, "complete": true}, ""
	})
	fake.handle("sendrawtransaction", func(bitcoindCall) (any, string) { return "sent-txid", "" })

	_, err := backend.Send(context.Background(), coreID, SendRequest{
		DestinationsSats: map[string]int64{dest: 500_000},
		FixedFeeSats:     1_000,
		Replaceable:      true,
	})
	require.NoError(t, err)

	assert.Empty(t, fake.callsFor("createrawtransaction"),
		"createrawtransaction cannot signal BIP125, so the send builds the transaction itself")
	raw, err := hex.DecodeString(signedHex)
	require.NoError(t, err)
	var tx wire.MsgTx
	require.NoError(t, tx.Deserialize(bytes.NewReader(raw)))
	require.NotEmpty(t, tx.TxIn)
	for i, in := range tx.TxIn {
		assert.Equal(t, bip125Sequence, in.Sequence, "input %d does not signal BIP125", i)
	}
}

// Core refuses to bump a transaction that does not signal replacement, so the
// preview says so before the dialog offers one.
func TestCoreBackendPreviewBumpFeeRefusesAFinalTransaction(t *testing.T) {
	backend, fake, coreID, paymentAddr, changeAddr := coreBumpFeeFixture(t)
	fake.handle("getrawtransaction", func(c bitcoindCall) (any, string) {
		if mustString(t, c.Params[0]) == coreBumpFundingTxid {
			return map[string]any{
				"txid": coreBumpFundingTxid,
				"vout": []map[string]any{{"value": 0.002, "n": 0, "scriptPubKey": map[string]any{"address": changeAddr}}},
			}, ""
		}
		return map[string]any{
			"txid":     coreBumpTxid,
			"vsize":    150,
			"locktime": 0,
			"vin":      []map[string]any{{"txid": coreBumpFundingTxid, "vout": 0, "sequence": 4294967295}},
			"vout": []map[string]any{
				{"value": 0.001, "n": 0, "scriptPubKey": map[string]any{"address": paymentAddr}},
				{"value": 0.0009985, "n": 1, "scriptPubKey": map[string]any{"address": changeAddr}},
			},
		}, ""
	})

	preview, err := backend.PreviewBumpFee(context.Background(), coreID, BumpFeeRequest{TxID: coreBumpTxid, NewFeeRate: 10})
	require.NoError(t, err)
	assert.Nil(t, preview.Plan)
	assert.False(t, preview.CanReplace)
	assert.Contains(t, preview.Reason, "does not signal replacement")
}

// Core adds a coin when the change cannot pay the higher fee, so the change
// path holds even when the planner finds no room in that output.
func TestCoreBackendPreviewBumpFeeAddsInputsForTheChangePath(t *testing.T) {
	backend, _, coreID, _, _ := coreBumpFeeFixture(t)

	preview, err := backend.PreviewBumpFee(context.Background(), coreID, BumpFeeRequest{TxID: coreBumpTxid, NewFeeRate: 10})
	require.NoError(t, err)
	assert.True(t, preview.AddsInputs, "Core funds the change path itself")

	// A rebuild spends exactly what it replaces, so it cannot add a coin.
	vout := 0
	preview, err = backend.PreviewBumpFee(context.Background(), coreID, BumpFeeRequest{
		TxID: coreBumpTxid, NewFeeRate: 10, FeeFromVout: &vout,
	})
	require.NoError(t, err)
	assert.False(t, preview.AddsInputs)
}
