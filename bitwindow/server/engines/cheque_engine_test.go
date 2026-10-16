package engines

import (
	"bytes"
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"os"
	"path/filepath"
	"strings"
	"testing"
	"time"

	"connectrpc.com/connect"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/cheques"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	orchrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
)

const (
	chequeWalletID = "80CEBA2163224572BDEADD2D2181C51B"
	chequeSeedHex  = "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f"
)

func testChequeEngine(t *testing.T, chain ChequeChain) *ChequeEngine {
	t.Helper()

	orch := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	orch.EXPECT().
		GetWalletSeed(gomock.Any(), gomock.Any()).
		Return(connect.NewResponse(&orchpb.GetWalletSeedResponse{SeedHex: chequeSeedHex}), nil).
		AnyTimes()
	return testChequeEngineWith(t, chain, orch)
}

func testChequeEngineWith(t *testing.T, chain ChequeChain, orch orchrpc.WalletManagerServiceClient) *ChequeEngine {
	t.Helper()

	dir := t.TempDir()
	walletData, err := json.Marshal(map[string]any{
		"version":        1,
		"activeWalletId": chequeWalletID,
		"wallets": []map[string]any{{
			"version":     1,
			"master":      map[string]any{"seed_hex": chequeSeedHex},
			"id":          chequeWalletID,
			"name":        "test",
			"wallet_type": "bitcoinCore",
		}},
	})
	require.NoError(t, err)
	require.NoError(t, os.WriteFile(filepath.Join(dir, "wallet.json"), walletData, 0o600))

	walletEngine := NewWalletEngine(
		t.Context(),
		func(ctx context.Context) (corerpc.BitcoinServiceClient, error) { return nil, nil },
		orch,
		dir,
		&chaincfg.SigNetParams,
		nil,
	)
	return NewChequeEngine(database.Test(t), walletEngine, &chaincfg.SigNetParams, chain)
}

func TestScanForFundsReportsFundedIndex(t *testing.T) {
	chain := &fakeChain{funded: map[string][]ChequeUTXO{}}
	engine := testChequeEngine(t, chain)

	address, err := engine.DeriveChequeAddress(t.Context(), chequeWalletID, 3)
	require.NoError(t, err)
	chain.funded[address] = testUTXOs()

	recoveries, err := engine.ScanForFunds(t.Context(), chequeWalletID, 20)
	require.NoError(t, err)
	require.Len(t, recoveries, 1)
	require.Equal(t, uint32(3), recoveries[0].Index)
	require.Equal(t, address, recoveries[0].Address)
	require.Equal(t, uint64(100_000), recoveries[0].Amount)
	require.Equal(t, []cheques.FundingOutput{{Txid: testUTXOs()[0].TxID}}, recoveries[0].Outputs)
	require.Len(t, chain.queried, 20, "the scan reads every index up to the count")
}

func TestRecoverChequesOnUnlockPersistsFundedCheques(t *testing.T) {
	chain := &fakeChain{funded: map[string][]ChequeUTXO{}}
	engine := testChequeEngine(t, chain)
	ctx := t.Context()

	address, err := engine.DeriveChequeAddress(t.Context(), chequeWalletID, 0)
	require.NoError(t, err)
	chain.funded[address] = testUTXOs()

	require.True(t, engine.walletEngine.IsUnlocked())

	engine.recoverChequesOnUnlock(ctx)
	engine.recoverChequesOnUnlock(ctx)

	list, err := cheques.List(ctx, engine.db, chequeWalletID)
	require.NoError(t, err)
	require.Len(t, list, 1)
	require.Equal(t, uint32(0), list[0].DerivationIndex)
	require.Equal(t, address, list[0].Address)
	require.Equal(t, []string{testUTXOs()[0].TxID}, list[0].FundedTxids)
	require.True(t, list[0].IsFunded())

	next, err := cheques.GetNextIndex(ctx, engine.db, chequeWalletID)
	require.NoError(t, err)
	require.Equal(t, uint32(1), next)
}

// A recovered output keeps the block that confirmed it, so a reorg below that
// block can drop it.
func TestRecoverChequesOnUnlockKeepsTheBlockHeight(t *testing.T) {
	chain := &fakeChain{funded: map[string][]ChequeUTXO{}}
	engine := testChequeEngine(t, chain)
	ctx := t.Context()

	address, err := engine.DeriveChequeAddress(t.Context(), chequeWalletID, 0)
	require.NoError(t, err)
	utxos := testUTXOs()
	utxos[0].Height = 123
	chain.funded[address] = utxos

	engine.recoverChequesOnUnlock(ctx)

	var height sql.NullInt64
	require.NoError(t, engine.db.QueryRowContext(ctx, `SELECT block_height FROM cheque_funding_outputs`).Scan(&height))
	require.Equal(t, sql.NullInt64{Int64: 123, Valid: true}, height)
}

func TestRecoverChequesOnUnlockWaitsForTheChain(t *testing.T) {
	chain := &fakeChain{funded: map[string][]ChequeUTXO{}, failures: 3}
	engine := testChequeEngine(t, chain)
	engine.scanRetry = time.Millisecond
	ctx := t.Context()

	address, err := engine.DeriveChequeAddress(t.Context(), chequeWalletID, 0)
	require.NoError(t, err)
	chain.funded[address] = testUTXOs()

	engine.recoverChequesOnUnlock(ctx)

	list, err := cheques.List(ctx, engine.db, chequeWalletID)
	require.NoError(t, err)
	require.Len(t, list, 1)
	require.Equal(t, address, list[0].Address)
}

// A chain source that never comes up gets one warning, not one per retry.
func TestRecoverChequesOnUnlockWarnsOneTime(t *testing.T) {
	chain := &fakeChain{err: errors.New("electrum backend not configured")}
	engine := testChequeEngine(t, chain)
	engine.scanRetry = time.Millisecond

	var logs bytes.Buffer
	ctx, cancel := context.WithCancel(zerolog.New(&logs).WithContext(t.Context()))
	done := make(chan struct{})
	go func() {
		engine.recoverChequesOnUnlock(ctx)
		close(done)
	}()
	time.Sleep(100 * time.Millisecond)
	cancel()
	<-done

	require.Equal(t, 1, strings.Count(logs.String(), `"level":"warn"`), logs.String())
}

// A wallet with no seed holds no cheques, so the scan skips it and never retries.
func TestRecoverChequesOnUnlockSkipsASeedlessWallet(t *testing.T) {
	chain := &fakeChain{funded: map[string][]ChequeUTXO{}}
	orch := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	orch.EXPECT().
		GetWalletSeed(gomock.Any(), gomock.Any()).
		Return(nil, connect.NewError(connect.CodeFailedPrecondition, errors.New("wallet holds no master seed"))).
		AnyTimes()
	engine := testChequeEngineWith(t, chain, orch)
	engine.scanRetry = time.Millisecond

	var logs bytes.Buffer
	ctx, cancel := context.WithTimeout(zerolog.New(&logs).WithContext(t.Context()), 5*time.Second)
	defer cancel()
	engine.recoverChequesOnUnlock(ctx)

	require.NoError(t, ctx.Err())
	require.NotContains(t, logs.String(), `"level":"warn"`)
	require.Empty(t, chain.queried)
}

// A chain read that fails means the electrum backend is down, so the scan must
// not report an empty wallet.
func TestScanForFundsReturnsChainError(t *testing.T) {
	chain := &fakeChain{err: errors.New("electrum backend not configured")}
	engine := testChequeEngine(t, chain)

	_, err := engine.ScanForFunds(t.Context(), chequeWalletID, 20)
	require.ErrorContains(t, err, "electrum backend not configured")
}

func TestChequeEngineCheckFunding(t *testing.T) {
	t.Parallel()

	newCheque := func(t *testing.T, engine *ChequeEngine, expected uint64) *cheques.Cheque {
		t.Helper()
		address, err := engine.DeriveChequeAddress(t.Context(), chequeWalletID, 0)
		require.NoError(t, err)
		id, err := cheques.Create(t.Context(), engine.db, chequeWalletID, 0, expected, address)
		require.NoError(t, err)
		cheque, err := cheques.Get(t.Context(), engine.db, chequeWalletID, id)
		require.NoError(t, err)
		return cheque
	}

	t.Run("a funded address stores the funding", func(t *testing.T) {
		t.Parallel()

		chain := &fakeChain{funded: map[string][]ChequeUTXO{}}
		engine := testChequeEngine(t, chain)
		cheque := newCheque(t, engine, 100_000)
		utxos := testUTXOs()
		utxos[0].Confirmations = 2
		chain.funded[cheque.Address] = utxos

		funding, err := engine.CheckFunding(t.Context(), cheque)
		require.NoError(t, err)
		assert.True(t, funding.Funded)
		assert.Equal(t, uint64(100_000), funding.AmountSats)
		assert.Equal(t, []string{utxos[0].TxID}, funding.Txids)
		assert.Equal(t, uint32(2), funding.MinConfirmations)
		assert.NotNil(t, funding.FundedAt)

		stored, err := cheques.Get(t.Context(), engine.db, chequeWalletID, cheque.ID)
		require.NoError(t, err)
		assert.Equal(t, []string{utxos[0].TxID}, stored.FundedTxids)
	})

	for _, tt := range []struct {
		name     string
		expected uint64
	}{
		{name: "an empty address of a funded cheque marks it swept", expected: 100_000},
		{name: "an empty address of a partly funded cheque marks it swept", expected: 200_000},
	} {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()

			chain := &fakeChain{funded: map[string][]ChequeUTXO{}}
			engine := testChequeEngine(t, chain)
			cheque := newCheque(t, engine, tt.expected)
			chain.funded[cheque.Address] = testUTXOs()
			_, err := engine.CheckFunding(t.Context(), cheque)
			require.NoError(t, err)
			cheque, err = cheques.Get(t.Context(), engine.db, chequeWalletID, cheque.ID)
			require.NoError(t, err)
			delete(chain.funded, cheque.Address)

			funding, err := engine.CheckFunding(t.Context(), cheque)
			require.NoError(t, err)
			assert.False(t, funding.Funded)

			stored, err := cheques.Get(t.Context(), engine.db, chequeWalletID, cheque.ID)
			require.NoError(t, err)
			require.NotNil(t, stored.SweptTxid)
			assert.Equal(t, "swept_externally", *stored.SweptTxid)
		})
	}

	t.Run("an empty address of an unfunded cheque stays open", func(t *testing.T) {
		t.Parallel()

		engine := testChequeEngine(t, &fakeChain{funded: map[string][]ChequeUTXO{}})
		cheque := newCheque(t, engine, 100_000)

		_, err := engine.CheckFunding(t.Context(), cheque)
		require.NoError(t, err)

		stored, err := cheques.Get(t.Context(), engine.db, chequeWalletID, cheque.ID)
		require.NoError(t, err)
		assert.Nil(t, stored.SweptTxid)
	})

	t.Run("a failed chain read is unavailable", func(t *testing.T) {
		t.Parallel()

		engine := testChequeEngine(t, &fakeChain{err: errors.New("esplora down")})
		cheque := newCheque(t, engine, 100_000)

		_, err := engine.CheckFunding(t.Context(), cheque)
		require.ErrorContains(t, err, "esplora down")
		assert.Equal(t, connect.CodeUnavailable, connect.CodeOf(err))
	})
}

func TestChequeEngineSweep(t *testing.T) {
	t.Parallel()

	destination := func(t *testing.T) string {
		t.Helper()
		candidates, err := SweepCandidates(newWIF(t, true), &chaincfg.SigNetParams)
		require.NoError(t, err)
		return candidates[0].Address
	}

	t.Run("a cheque key sweeps and marks the cheque", func(t *testing.T) {
		t.Parallel()

		chain := &fakeChain{funded: map[string][]ChequeUTXO{}}
		engine := testChequeEngine(t, chain)
		address, err := engine.DeriveChequeAddress(t.Context(), chequeWalletID, 0)
		require.NoError(t, err)
		id, err := cheques.Create(t.Context(), engine.db, chequeWalletID, 0, 100_000, address)
		require.NoError(t, err)
		chain.funded[address] = testUTXOs()
		wifStr, err := engine.DeriveChequePrivateKey(t.Context(), chequeWalletID, 0)
		require.NoError(t, err)
		wif, err := btcutil.DecodeWIF(wifStr)
		require.NoError(t, err)

		sweep, err := engine.Sweep(t.Context(), chequeWalletID, wif, destination(t), 0)
		require.NoError(t, err)
		assert.Equal(t, "txid", sweep.Txid)
		assert.Equal(t, uint64(100_000), sweep.AmountSats)
		assert.Equal(t, uint64(1), sweep.FeeSatPerVbyte)

		stored, err := cheques.Get(t.Context(), engine.db, chequeWalletID, id)
		require.NoError(t, err)
		require.NotNil(t, stored.SweptTxid)
		assert.Equal(t, "txid", *stored.SweptTxid)
	})

	for _, tt := range []struct {
		name        string
		destination string
		feeRate     uint64
		utxos       int
		valueSats   int64
		wantErr     string
	}{
		{name: "a bad destination", destination: "not-an-address", feeRate: 1, utxos: 1, valueSats: 100_000_000, wantErr: "decode destination address"},
		{name: "a destination on another network", destination: "bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq", feeRate: 1, utxos: 1, valueSats: 100_000_000, wantErr: "destination address is for another network"},
		{name: "a fee rate above the cap", feeRate: 10_001, utxos: 1, valueSats: 100_000_000, wantErr: "fee rate 10001 sat/vB is above the cap"},
		{name: "a fee above the cap", feeRate: 5_000, utxos: 30, valueSats: 100_000_000, wantErr: "is above the cap of 10000000 sats"},
		{name: "funds below the fee", feeRate: 10_000, utxos: 1, valueSats: 1_000, wantErr: "insufficient funds"},
	} {
		t.Run(tt.name+" is an invalid argument", func(t *testing.T) {
			t.Parallel()

			wif := newWIF(t, true)
			candidates, err := SweepCandidates(wif, &chaincfg.SigNetParams)
			require.NoError(t, err)
			utxos := make([]ChequeUTXO, tt.utxos)
			for i := range utxos {
				utxos[i] = ChequeUTXO{TxID: testUTXOs()[0].TxID, Vout: int32(i), ValueSats: tt.valueSats}
			}
			chain := &fakeChain{funded: map[string][]ChequeUTXO{candidates[0].Address: utxos}}
			engine := testChequeEngine(t, chain)
			dest := tt.destination
			if dest == "" {
				dest = destination(t)
			}

			_, err = engine.Sweep(t.Context(), chequeWalletID, wif, dest, tt.feeRate)
			require.ErrorIs(t, err, ErrInvalidSweep)
			require.ErrorContains(t, err, tt.wantErr)
			assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
		})
	}

	t.Run("a key with no funds is not found", func(t *testing.T) {
		t.Parallel()

		engine := testChequeEngine(t, &fakeChain{funded: map[string][]ChequeUTXO{}})

		_, err := engine.Sweep(t.Context(), chequeWalletID, newWIF(t, true), destination(t), 0)
		require.ErrorContains(t, err, "no funds found")
		assert.Equal(t, connect.CodeNotFound, connect.CodeOf(err))
	})
}
