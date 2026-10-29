package wallet

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// fakeCore answers scantxoutset, getblockhash and getrawtransaction from fixed data.
type fakeCore struct {
	subversion string
	unspents   []map[string]any
	txs        map[string][]map[string]any
	calls      []string
}

func (f *fakeCore) call(_ context.Context, method string, params ...any) (json.RawMessage, error) {
	f.calls = append(f.calls, method)
	switch method {
	case "getnetworkinfo":
		subversion := f.subversion
		if subversion == "" {
			subversion = "/eCash Satoshi:31.1.0(ecash-alphanet; BitWindow-0.2)/"
		}
		return json.Marshal(map[string]any{"subversion": subversion})
	case "scantxoutset":
		return json.Marshal(map[string]any{"success": true, "unspents": f.unspents})
	case "getblockhash":
		return json.Marshal(fmt.Sprintf("hash-%d", params[0]))
	case "getrawtransaction":
		vout, ok := f.txs[params[0].(string)]
		if !ok {
			return nil, errors.New("no such transaction")
		}
		return json.Marshal(map[string]any{"vout": vout})
	default:
		return nil, fmt.Errorf("unexpected method %s", method)
	}
}

func coreVout(coins float64, hexScript, kind string) map[string]any {
	return map[string]any{"value": coins, "scriptPubKey": map[string]any{"hex": hexScript, "type": kind}}
}

func TestCoreECXBurnsReadsBurnsFromTheForkOn(t *testing.T) {
	payout := payoutOut(t, "bc1qgkavkjygu5d952s7kspkyp3q2vrgg99rsuz2z5")
	core := &fakeCore{
		unspents: []map[string]any{
			{"txid": "before-fork", "height": 963_000},
			{"txid": "big", "height": 963_700},
			{"txid": "big", "height": 963_700},
			{"txid": "early", "height": 963_650},
			{"txid": "small", "height": 963_800},
		},
		txs: map[string][]map[string]any{
			"big": {
				coreVout(4000, ECXBurnScriptHex, "pubkeyhash"),
				coreVout(1000, ECXBurnScriptHex, "pubkeyhash"),
				coreVout(0, payout.ScriptPubKey, "nulldata"),
			},
			"early": {coreVout(1000, ECXBurnScriptHex, "pubkeyhash"), coreVout(0, payout.ScriptPubKey, "nulldata")},
			"small": {coreVout(999.99999999, ECXBurnScriptHex, "pubkeyhash")},
		},
	}

	burns, err := CoreECXBurns(context.Background(), core.call, ECXBurnNetworkByID("alphanet"), 963_648)
	require.NoError(t, err)

	assert.Equal(t, []ECXBurn{
		{TxID: "big", Height: 963_700, BurnSats: 500_000_000_000, PayoutAddress: "bc1qgkavkjygu5d952s7kspkyp3q2vrgg99rsuz2z5", PayoutSats: 5_000_000_000},
		{TxID: "early", Height: 963_650, BurnSats: 100_000_000_000, PayoutAddress: "bc1qgkavkjygu5d952s7kspkyp3q2vrgg99rsuz2z5", PayoutSats: 1_000_000_000},
	}, burns, "newest first, as the table says")
	assert.NotContains(t, core.calls[2:], "scantxoutset", "the scan runs once")
}

func TestCoreECXBurnsReturnsALookupError(t *testing.T) {
	core := &fakeCore{unspents: []map[string]any{{"txid": "gone", "height": 963_700}}}
	_, err := CoreECXBurns(context.Background(), core.call, ECXBurnNetworkByID("alphanet"), 963_648)
	require.ErrorContains(t, err, "read burn gone")
}

func TestCoreECXBurnsRefusesAnUnfinishedScan(t *testing.T) {
	call := func(_ context.Context, method string, _ ...any) (json.RawMessage, error) {
		if method == "getnetworkinfo" {
			return json.RawMessage(`{"subversion":"/eCash Satoshi:31.1.0(ecash-alphanet)/"}`), nil
		}
		return json.RawMessage(`{"success":false}`), nil
	}
	_, err := CoreECXBurns(context.Background(), call, ECXBurnNetworkByID("alphanet"), 963_648)
	require.ErrorContains(t, err, "did not finish")
}

func TestReadCoreCookie(t *testing.T) {
	path := filepath.Join(t.TempDir(), ".cookie")
	require.NoError(t, os.WriteFile(path, []byte("__cookie__:secret\n"), 0o600))
	user, password, err := ReadCoreCookie(path)
	require.NoError(t, err)
	assert.Equal(t, []string{"__cookie__", "secret"}, []string{user, password})

	require.NoError(t, os.WriteFile(path, []byte("nocolon"), 0o600))
	_, _, err = ReadCoreCookie(path)
	require.Error(t, err)
}

func TestCoreECXBurnsRefusesANodeOfAnotherNetwork(t *testing.T) {
	for name, subversion := range map[string]string{
		"betanet node":  "/eCash Satoshi:31.1.0(ecash-betanet; BitWindow-0.2)/",
		"mainnet node":  "/eCash Satoshi:31.1.0(ecash-ecash; BitWindow-0.2)/",
		"no eCash mark": "/Satoshi:29.0.0/",
	} {
		t.Run(name, func(t *testing.T) {
			core := &fakeCore{subversion: subversion}
			_, err := CoreECXBurns(context.Background(), core.call, ECXBurnNetworkByID("alphanet"), 963_648)
			require.ErrorContains(t, err, "not alphanet")
			assert.Equal(t, []string{"getnetworkinfo"}, core.calls, "a wrong node gets no scan")
		})
	}
}

func TestCoreECashID(t *testing.T) {
	assert.Equal(t, "alphanet", coreECashID("/eCash Satoshi:31.1.0(ecash-alphanet; BitWindow-0.2)/"))
	assert.Equal(t, "betanet", coreECashID("/eCash Satoshi:31.1.0(BitWindow-0.2; ecash-betanet)/"))
	assert.Equal(t, "", coreECashID("/Satoshi:29.0.0/"))
	assert.Equal(t, "", coreECashID("/Satoshi:29.0.0(BitWindow-0.2)/"))
}
