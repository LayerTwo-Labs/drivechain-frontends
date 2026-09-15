package wallet

import (
	"context"
	"encoding/json"
	"fmt"
	"testing"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/replay"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const corePSBT = "cHNidP8BAAoCAAAAAAAAAAAAAAA="

type fundedPSBTCall struct {
	wallet    string
	rawInputs string
	outputs   []map[string]any
	locktime  uint32
	options   map[string]any
}

func stubFundedPSBT(t *testing.T, fake *fakeBitcoind, before func()) *[]fundedPSBTCall {
	t.Helper()
	calls := &[]fundedPSBTCall{}
	fake.handle("walletcreatefundedpsbt", func(c bitcoindCall) (any, string) {
		require.Len(t, c.Params, 4)
		call := fundedPSBTCall{wallet: c.Wallet, rawInputs: string(c.Params[0])}
		require.NoError(t, json.Unmarshal(c.Params[1], &call.outputs))
		require.NoError(t, json.Unmarshal(c.Params[2], &call.locktime))
		require.NoError(t, json.Unmarshal(c.Params[3], &call.options))
		*calls = append(*calls, call)
		if before != nil {
			before()
		}
		return map[string]any{"psbt": corePSBT, "fee": 0.00000452, "changepos": 2}, ""
	})
	return calls
}

func TestCoreBackendCreatePSBTFundsTheOutputs(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()
	calls := stubFundedPSBT(t, fake, nil)
	dest := p2wpkhAddr(t, fixedKey(0xAA), &chaincfg.RegressionNetParams)

	packet, err := backend.CreatePSBT(context.Background(), coreID, SendRequest{
		DestinationsSats: map[string]int64{dest: 125_000},
		OpReturnHex:      "6263727431",
		FeeRateSatPerVB:  3,
	})
	require.NoError(t, err)
	assert.Equal(t, corePSBT, packet)

	name, err := backend.walletName(context.Background(), coreID)
	require.NoError(t, err)
	require.Len(t, *calls, 1)
	call := (*calls)[0]
	assert.Equal(t, name, call.wallet)
	assert.Equal(t, "[]", call.rawInputs, "Core selects every input")
	assert.Equal(t, []map[string]any{{dest: 0.00125}, {"data": "6263727431"}}, call.outputs)
	assert.Zero(t, call.locktime)
	assert.Equal(t, map[string]any{"fee_rate": float64(3)}, call.options)
}

func TestCoreBackendCreatePSBTReplayProtection(t *testing.T) {
	cases := map[string]struct {
		network     string
		allowReplay bool
		protected   bool
	}{
		"ecash":                 {network: "ecash", protected: true},
		"ecash allows replay":   {network: "ecash", allowReplay: true},
		"regtest":               {network: "regtest"},
		"regtest allows replay": {network: "regtest", allowReplay: true},
	}
	for name, tc := range cases {
		t.Run(name, func(t *testing.T) {
			backend, fake, coreID := newCoreBackendFixture(t)
			backend.svc.SetNetwork(tc.network)
			fake.stubEnsureFlow()
			calls := stubFundedPSBT(t, fake, nil)

			_, err := backend.CreatePSBT(context.Background(), coreID, SendRequest{
				DestinationsSats: map[string]int64{p2wpkhAddr(t, fixedKey(0xAA), &chaincfg.RegressionNetParams): 50_000},
				AllowReplay:      tc.allowReplay,
			})
			require.NoError(t, err)

			require.Len(t, *calls, 1)
			call := (*calls)[0]
			if tc.protected {
				assert.Equal(t, replay.ReplayLockTime, call.locktime)
				assert.Equal(t, true, call.options["replaceable"])
				return
			}
			assert.Zero(t, call.locktime)
			assert.NotContains(t, call.options, "replaceable")
		})
	}
}

func TestCoreBackendCreatePSBTSubtractsTheFeeFromTheDestinations(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()
	calls := stubFundedPSBT(t, fake, nil)
	net := &chaincfg.RegressionNetParams

	_, err := backend.CreatePSBT(context.Background(), coreID, SendRequest{
		DestinationsSats: map[string]int64{
			p2wpkhAddr(t, fixedKey(0xAA), net): 50_000,
			p2wpkhAddr(t, fixedKey(0xBB), net): 60_000,
		},
		OpReturnHex:           "beef",
		SubtractFeeFromAmount: true,
		Replaceable:           true,
	})
	require.NoError(t, err)

	require.Len(t, *calls, 1)
	call := (*calls)[0]
	require.Len(t, call.outputs, 3)
	assert.Equal(t, map[string]any{"data": "beef"}, call.outputs[2], "the fee never comes from the data output")
	assert.Equal(t, []any{float64(0), float64(1)}, call.options["subtractFeeFromOutputs"])
	assert.Equal(t, true, call.options["replaceable"])
}

func TestCoreBackendCreatePSBTRefusesWhatCoreDoesNotFund(t *testing.T) {
	dest := p2wpkhAddr(t, fixedKey(0xAA), &chaincfg.RegressionNetParams)
	cases := map[string]SendRequest{
		"pinned input":   {RequiredInputs: []RequiredInput{{TxID: freeCoinTxid, Vout: 0, AmountSats: 10_000}}},
		"external input": {ExternalInputs: []ExternalInput{{TxID: freeCoinTxid, Vout: 0, AmountSats: 10_000}}},
		"raw output":     {RawOutputs: []TxOutSpec{{OpReturnHex: "beef"}}},
		"fixed fee":      {FixedFeeSats: 1_000},
	}
	for name, req := range cases {
		t.Run(name, func(t *testing.T) {
			backend, fake, coreID := newCoreBackendFixture(t)
			fake.stubEnsureFlow()
			calls := stubFundedPSBT(t, fake, nil)

			req.DestinationsSats = map[string]int64{dest: 50_000}
			_, err := backend.CreatePSBT(context.Background(), coreID, req)
			require.Error(t, err)
			assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
			assert.Empty(t, *calls)
		})
	}
}

func TestCoreBackendCreatePSBTHoldsFrozenCoinsWhileCoreFunds(t *testing.T) {
	for _, fundErr := range []string{"", "Insufficient funds"} {
		t.Run(fmt.Sprintf("funding error %q", fundErr), func(t *testing.T) {
			backend, fake, coreID := newCoreBackendFixture(t)
			fake.stubEnsureFlow()
			frozenKey := frozenCoinTxid + ":1"

			locked := map[string]bool{}
			fake.handle("listunspent", func(bitcoindCall) (any, string) {
				return []map[string]any{
					{"txid": frozenCoinTxid, "vout": 1, "amount": 0.04, "spendable": true, "confirmations": 3},
					{"txid": freeCoinTxid, "vout": 0, "amount": 0.01, "spendable": true, "confirmations": 3},
				}, ""
			})
			fake.handle("lockunspent", func(c bitcoindCall) (any, string) {
				var unlock bool
				require.NoError(t, json.Unmarshal(c.Params[0], &unlock))
				var outputs []RawInput
				require.NoError(t, json.Unmarshal(c.Params[1], &outputs))
				for _, o := range outputs {
					locked[fmt.Sprintf("%s:%d", o.TxID, o.Vout)] = !unlock
				}
				return true, ""
			})
			backend.svc.SetFrozenCoins(func(_ context.Context, _ string, candidates []Outpoint) (map[string]bool, error) {
				frozen := map[string]bool{}
				for _, c := range candidates {
					if c.TxID == frozenCoinTxid {
						frozen[c.Key()] = true
					}
				}
				return frozen, nil
			})

			lockedWhileFunding := false
			fake.handle("walletcreatefundedpsbt", func(bitcoindCall) (any, string) {
				lockedWhileFunding = locked[frozenKey]
				if fundErr != "" {
					return nil, fundErr
				}
				return map[string]any{"psbt": corePSBT, "fee": 0.00000452, "changepos": 1}, ""
			})

			_, err := backend.CreatePSBT(context.Background(), coreID, SendRequest{
				DestinationsSats: map[string]int64{p2wpkhAddr(t, fixedKey(0xAA), &chaincfg.RegressionNetParams): 50_000},
			})
			if fundErr == "" {
				require.NoError(t, err)
			} else {
				require.ErrorContains(t, err, fundErr)
			}
			assert.True(t, lockedWhileFunding, "Core must not select the frozen coin")
			assert.False(t, locked[frozenKey], "the call releases the coin when it ends")
			assert.False(t, locked[freeCoinTxid+":0"])
		})
	}
}

func TestCoreBackendSignPSBTSignsWithoutFinalizing(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()
	fake.handle("walletprocesspsbt", func(bitcoindCall) (any, string) {
		return map[string]any{"psbt": "signed-psbt", "complete": false}, ""
	})

	signed, err := backend.SignPSBT(context.Background(), coreID, corePSBT)
	require.NoError(t, err)
	assert.Equal(t, "signed-psbt", signed)

	name, err := backend.walletName(context.Background(), coreID)
	require.NoError(t, err)
	calls := fake.callsFor("walletprocesspsbt")
	require.Len(t, calls, 1)
	assert.Equal(t, name, calls[0].Wallet)
	params := make([]string, len(calls[0].Params))
	for i, p := range calls[0].Params {
		params[i] = string(p)
	}
	assert.Equal(t, []string{`"` + corePSBT + `"`, "true", `"DEFAULT"`, "true", "false"}, params)
}

func TestCoreBackendSignPSBTReturnsTheCoreError(t *testing.T) {
	backend, fake, coreID := newCoreBackendFixture(t)
	fake.stubEnsureFlow()
	fake.handle("walletprocesspsbt", func(bitcoindCall) (any, string) { return nil, "TX decode failed" })

	_, err := backend.SignPSBT(context.Background(), coreID, "not-a-psbt")
	require.ErrorContains(t, err, "TX decode failed")
}

type psbtFakeBackend struct {
	fakeBackend
}

func (f *psbtFakeBackend) CreatePSBT(_ context.Context, walletID string, _ SendRequest) (string, error) {
	f.calls = append(f.calls, "CreatePSBT:"+walletID)
	return "psbt-" + f.name, nil
}

func (f *psbtFakeBackend) SignPSBT(_ context.Context, walletID, _ string) (string, error) {
	f.calls = append(f.calls, "SignPSBT:"+walletID)
	return "signed-" + f.name, nil
}

func TestWalletEngineRoutesPSBTsByWalletType(t *testing.T) {
	svc := newTestService(t)
	core, err := svc.GenerateWallet("Core", "", "", testSlots)
	require.NoError(t, err)
	require.Equal(t, WalletTypeBitcoinCore, core.WalletType)
	elec, err := svc.CreateElectrumWallet("Electrum", nil, nil, "", "", "", "", 0, "")
	require.NoError(t, err)
	require.Equal(t, WalletTypeElectrum, elec.WalletType)

	chain := &psbtFakeBackend{fakeBackend{name: "chain"}}
	electrum := &psbtFakeBackend{fakeBackend{name: "electrum"}}
	engine := NewWalletEngine(svc, NewBackendRouter(svc, chain, electrum), StaticParams(&chaincfg.RegressionNetParams), zerolog.Nop())
	ctx := context.Background()

	for id, backend := range map[string]string{core.ID: "chain", elec.ID: "electrum"} {
		packet, err := engine.CreatePSBT(ctx, id, SendRequest{})
		require.NoError(t, err)
		assert.Equal(t, "psbt-"+backend, packet)
		signed, err := engine.SignPSBT(ctx, id, packet)
		require.NoError(t, err)
		assert.Equal(t, "signed-"+backend, signed)
	}
	assert.Equal(t, []string{"CreatePSBT:" + core.ID, "SignPSBT:" + core.ID}, chain.calls)
	assert.Equal(t, []string{"CreatePSBT:" + elec.ID, "SignPSBT:" + elec.ID}, electrum.calls)
}

func TestWalletEngineRefusesAPSBTFromABackendWithoutOne(t *testing.T) {
	router, _, chainFake, firstID, _ := newRouterFixture(t)
	engine := NewWalletEngine(router.svc, router, StaticParams(&chaincfg.RegressionNetParams), zerolog.Nop())
	ctx := context.Background()

	_, err := engine.CreatePSBT(ctx, firstID, SendRequest{})
	require.ErrorContains(t, err, "cannot build a PSBT")
	_, err = engine.SignPSBT(ctx, firstID, corePSBT)
	require.ErrorContains(t, err, "cannot build a PSBT")
	assert.Empty(t, chainFake.calls)
}

func TestWalletEngineRefusesAPSBTForAnUnknownWallet(t *testing.T) {
	router, _, _, _, _ := newRouterFixture(t)
	engine := NewWalletEngine(router.svc, router, StaticParams(&chaincfg.RegressionNetParams), zerolog.Nop())

	_, err := engine.CreatePSBT(context.Background(), "absent", SendRequest{})
	require.ErrorContains(t, err, "not found")
}
