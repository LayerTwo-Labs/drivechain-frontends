package wallet

import (
	"bytes"
	"context"
	"encoding/hex"
	"fmt"
	"strings"
	"sync"
	"sync/atomic"
	"testing"

	"connectrpc.com/connect"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const testMnemonic = "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about"

// accountXpub derives the BIP84 account xpub (m/84'/coin'/0') for a seed —
// what a user would paste to import a watch-only electrum wallet.
func accountXpub(t *testing.T, seedHex string, net *chaincfg.Params) string {
	t.Helper()
	seed, err := hex.DecodeString(seedHex)
	require.NoError(t, err)
	master, err := hdkeychain.NewMaster(seed, net)
	require.NoError(t, err)
	const h = hdkeychain.HardenedKeyStart
	purpose, err := master.Derive(h + 84)
	require.NoError(t, err)
	coin, err := purpose.Derive(h + net.HDCoinType)
	require.NoError(t, err)
	acc, err := coin.Derive(h + 0)
	require.NoError(t, err)
	pub, err := acc.Neuter()
	require.NoError(t, err)
	return pub.String()
}

// fakeEsplora is an in-memory implementation of the Esplora interface driven by
// per-address fixtures — the same interface ElectrumBackend uses in production,
// so tests exercise the real backend logic without a REST endpoint.
type fakeEsplora struct {
	mu        sync.Mutex
	stats     map[string]EsploraAddressStats
	utxos     map[string][]EsploraUTXO
	txs       map[string][]EsploraTx
	txByID    map[string]EsploraTx
	hexByID   map[string]string
	tip       int
	feeRate   float64
	broadcast []string
}

var _ ChainDataSource = (*fakeEsplora)(nil)

func newFakeEsplora() *fakeEsplora {
	return &fakeEsplora{
		stats:   map[string]EsploraAddressStats{},
		utxos:   map[string][]EsploraUTXO{},
		txs:     map[string][]EsploraTx{},
		txByID:  map[string]EsploraTx{},
		hexByID: map[string]string{},
		tip:     110,
		feeRate: 1,
	}
}

func (f *fakeEsplora) AddressStats(_ context.Context, address string) (EsploraAddressStats, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if s, ok := f.stats[address]; ok {
		return s, nil
	}
	return EsploraAddressStats{Address: address}, nil
}

func (f *fakeEsplora) AddressUTXOs(_ context.Context, address string) ([]EsploraUTXO, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	return f.utxos[address], nil
}

func (f *fakeEsplora) AddressTxs(_ context.Context, address string) ([]EsploraTx, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	return f.txs[address], nil
}

func (f *fakeEsplora) Tx(_ context.Context, txid string) (EsploraTx, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if tx, ok := f.txByID[txid]; ok {
		return tx, nil
	}
	return EsploraTx{}, fmt.Errorf("tx %s not found", txid)
}

func (f *fakeEsplora) TxHex(_ context.Context, txid string) (string, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if h, ok := f.hexByID[txid]; ok {
		return h, nil
	}
	return "", fmt.Errorf("tx %s not found", txid)
}

func (f *fakeEsplora) Broadcast(_ context.Context, rawHex string) (string, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.broadcast = append(f.broadcast, rawHex)
	return "broadcasttxid", nil
}

func (f *fakeEsplora) TipHeight(_ context.Context) (int, error) {
	f.mu.Lock()
	defer f.mu.Unlock()
	return f.tip, nil
}

func (f *fakeEsplora) FeeRateForTarget(_ context.Context, _ int, fallback float64) float64 {
	f.mu.Lock()
	defer f.mu.Unlock()
	if f.feeRate > 0 {
		return f.feeRate
	}
	return fallback
}

func newElectrumFixture(t *testing.T) (*ElectrumBackend, *fakeEsplora, *WalletData, string) {
	t.Helper()
	svc := newTestService(t)
	w, err := svc.CreateElectrumWallet("Electrum", nil, nil, "", "", "", 0, "")
	require.NoError(t, err)
	require.Equal(t, WalletTypeElectrum, w.WalletType)

	addrs, err := DeriveBIP84Addresses(w.Master.SeedHex, &chaincfg.SigNetParams, 0, 1)
	require.NoError(t, err)
	firstAddr := addrs[0]

	fake := newFakeEsplora()
	p := NewElectrumBackend(svc, fake, &chaincfg.SigNetParams, zerolog.New(zerolog.NewTestWriter(t)))
	return p, fake, w, firstAddr
}

func TestElectrumBalanceAndUnspent(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	ctx := context.Background()

	fake.stats[addr] = EsploraAddressStats{
		Address:    addr,
		ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 100_000, TxCount: 1},
	}
	fake.utxos[addr] = []EsploraUTXO{{
		TxID: "aa", Vout: 0, Value: 100_000,
		Status: EsploraStatus{Confirmed: true, BlockHeight: 100, BlockTime: 1700000000},
	}}

	confirmed, unconfirmed, err := p.Balance(ctx, w.ID)
	require.NoError(t, err)
	assert.InDelta(t, 0.001, confirmed, 1e-9)
	assert.Zero(t, unconfirmed)

	utxos, err := p.ListUnspent(ctx, w.ID)
	require.NoError(t, err)
	require.Len(t, utxos, 1)
	assert.Equal(t, addr, utxos[0].Address)
	assert.Equal(t, 11, utxos[0].Confirmations) // tip 110 - 100 + 1
}

func TestElectrumNextReceiveSkipsUsed(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	fake.stats[addr] = EsploraAddressStats{Address: addr, ChainStats: EsploraTxoStats{TxCount: 1}}

	_, _, err := p.Balance(context.Background(), w.ID) // warm the scan so usage is known
	require.NoError(t, err)

	next, err := p.NextReceiveAddress(context.Background(), w.ID, ScriptUnknown)
	require.NoError(t, err)
	assert.NotEqual(t, addr, next, "used address must not be offered for receive")

	path, err := p.AddressHDPath(context.Background(), w.ID, next)
	require.NoError(t, err)
	assert.Contains(t, path, "/0/") // external chain
}

func TestElectrumSendBuildsSignsBroadcasts(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	ctx := context.Background()

	fake.stats[addr] = EsploraAddressStats{
		Address:    addr,
		ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 200_000, TxCount: 1},
	}
	fake.utxos[addr] = []EsploraUTXO{{
		TxID: "1111111111111111111111111111111111111111111111111111111111111111",
		Vout: 0, Value: 200_000,
		Status: EsploraStatus{Confirmed: true, BlockHeight: 100},
	}}

	dest := "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx"
	txid, err := p.Send(ctx, w.ID, SendRequest{
		DestinationsSats: map[string]int64{dest: 50_000},
		FeeRateSatPerVB:  2,
	})
	require.NoError(t, err)
	assert.Equal(t, "broadcasttxid", txid)
	require.Len(t, fake.broadcast, 1)

	raw, err := hex.DecodeString(fake.broadcast[0])
	require.NoError(t, err)
	var tx wire.MsgTx
	require.NoError(t, tx.Deserialize(bytes.NewReader(raw)))

	require.Len(t, tx.TxIn, 1)
	require.NotEmpty(t, tx.TxIn[0].Witness, "input must be signed (P2WPKH witness present)")
	// One destination output + a change output back to the wallet.
	require.Len(t, tx.TxOut, 2)
	assert.Equal(t, int64(50_000), tx.TxOut[0].Value)
}

// TestElectrumSendSidechainDeposit drives the full BIP300 M5 deposit through the
// real Send path across a range of slots and the first-deposit (no CTIP) case,
// and validates EVERY input through txscript.Engine — proving the constructed
// transaction is consensus-spendable: the CTIP is an anyone-can-spend
// OP_DRIVECHAIN output spent with an empty scriptSig, and the wallet input
// carries a valid signature. Outputs are asserted byte-for-byte and in order.
func TestElectrumSendSidechainDeposit(t *testing.T) {
	net := &chaincfg.SigNetParams
	const (
		walletAmount  = int64(2_000_000)
		depositAmount = int64(400_000)
		fee           = int64(1_000)
	)

	cases := []struct {
		name        string
		slot        byte
		withCtip    bool
		oldCtip     int64
		depositAddr string
	}{
		{"slot_0_with_ctip", 0, true, 250_000, "s0_examplesidechainaddress"},
		{"slot_1_with_ctip", 1, true, 500_000, "s1_anotheraddress"},
		// Slots 1-16 must NOT collapse to OP_1..OP_16 (minimal push) — the script
		// is emitted as raw bytes, so OP_PUSHBYTES_1 (0x01) stays put.
		{"slot_16_with_ctip", 16, true, 1, "s16_x"},
		{"slot_255_with_ctip", 255, true, 999_999, "s255_maxslot"},
		{"slot_7_first_deposit", 7, false, 0, "s7_firstdeposit"},
	}

	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			p, fake, w, addr := newElectrumFixture(t)
			ctx := context.Background()

			fake.stats[addr] = EsploraAddressStats{
				Address:    addr,
				ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: walletAmount, TxCount: 1},
			}
			fake.utxos[addr] = []EsploraUTXO{{
				TxID: "3333333333333333333333333333333333333333333333333333333333333333",
				Vout: 0, Value: walletAmount,
				Status: EsploraStatus{Confirmed: true, BlockHeight: 100},
			}}

			drivechainScript := []byte{txscript.OP_NOP5, txscript.OP_DATA_1, tc.slot, txscript.OP_TRUE}

			var externalInputs []ExternalInput
			var ctipTxid string
			if tc.withCtip {
				treasuryPrev := wire.NewMsgTx(2)
				treasuryPrev.AddTxIn(wire.NewTxIn(&wire.OutPoint{Index: 0xffffffff}, []byte{0x00}, nil))
				treasuryPrev.AddTxOut(wire.NewTxOut(tc.oldCtip, drivechainScript))
				var buf bytes.Buffer
				require.NoError(t, treasuryPrev.Serialize(&buf))
				ctipTxid = treasuryPrev.TxHash().String()
				fake.hexByID[ctipTxid] = hex.EncodeToString(buf.Bytes())
				externalInputs = []ExternalInput{{TxID: ctipTxid, Vout: 0, AmountSats: tc.oldCtip}}
			}

			treasuryValue := tc.oldCtip + depositAmount
			txid, err := p.Send(ctx, w.ID, SendRequest{
				FixedFeeSats: fee,
				RawOutputs: []TxOutSpec{
					{RawScriptHex: hex.EncodeToString(drivechainScript), AmountSats: treasuryValue},
				},
				OpReturnHex:    hex.EncodeToString([]byte(tc.depositAddr)),
				ExternalInputs: externalInputs,
			})
			require.NoError(t, err)
			require.Equal(t, "broadcasttxid", txid)
			require.Len(t, fake.broadcast, 1)

			var tx wire.MsgTx
			raw, err := hex.DecodeString(fake.broadcast[0])
			require.NoError(t, err)
			require.NoError(t, tx.Deserialize(bytes.NewReader(raw)))

			// Outputs: treasury, OP_RETURN address, change — exact bytes and order.
			require.Len(t, tx.TxOut, 3)
			assert.Equal(t, []byte{0xB4, 0x01, tc.slot, 0x51}, tx.TxOut[0].PkScript,
				"out[0] treasury = OP_DRIVECHAIN OP_PUSHBYTES_1 <slot> OP_TRUE, raw (no minimal-push)")
			assert.Equal(t, treasuryValue, tx.TxOut[0].Value, "treasury value = old CTIP + deposit")

			require.Equal(t, byte(txscript.OP_RETURN), tx.TxOut[1].PkScript[0], "out[1] must be OP_RETURN")
			pushed, err := txscript.PushedData(tx.TxOut[1].PkScript)
			require.NoError(t, err)
			require.Len(t, pushed, 1)
			assert.Equal(t, []byte(tc.depositAddr), pushed[0], "OP_RETURN carries the address bytes verbatim")
			assert.Zero(t, tx.TxOut[1].Value)
			assert.Equal(t, walletAmount-depositAmount-fee, tx.TxOut[2].Value, "change = wallet - deposit - fee")

			// Map every input to its prevout and locate the CTIP vs wallet inputs.
			walletAddr, err := btcutil.DecodeAddress(addr, net)
			require.NoError(t, err)
			walletScript, err := txscript.PayToAddrScript(walletAddr)
			require.NoError(t, err)

			prevByOutpoint := map[wire.OutPoint]*wire.TxOut{}
			ctipIdx, walletIdx := -1, -1
			for i := range tx.TxIn {
				op := tx.TxIn[i].PreviousOutPoint
				if tc.withCtip && op.Hash.String() == ctipTxid {
					prevByOutpoint[op] = wire.NewTxOut(tc.oldCtip, drivechainScript)
					ctipIdx = i
				} else {
					prevByOutpoint[op] = wire.NewTxOut(walletAmount, walletScript)
					walletIdx = i
				}
			}
			require.NotEqual(t, -1, walletIdx, "wallet input present")

			prevOuts := txscript.NewMultiPrevOutFetcher(prevByOutpoint)
			sigHashes := txscript.NewTxSigHashes(&tx, prevOuts)

			if tc.withCtip {
				require.Len(t, tx.TxIn, 2)
				require.NotEqual(t, -1, ctipIdx, "CTIP input present")
				assert.Empty(t, tx.TxIn[ctipIdx].SignatureScript, "CTIP spent with empty scriptSig")
				assert.Empty(t, tx.TxIn[ctipIdx].Witness, "CTIP input is not signed")
				// OP_DRIVECHAIN is a NOP under base rules → anyone-can-spend; verify
				// without upgradable-NOP/cleanstack policy (BIP300 is enforced separately).
				vm, err := txscript.NewEngine(drivechainScript, &tx, ctipIdx, txscript.ScriptBip16, nil, sigHashes, tc.oldCtip, prevOuts)
				require.NoError(t, err)
				require.NoError(t, vm.Execute(), "CTIP anyone-can-spend input must validate with empty scriptSig")
			} else {
				require.Len(t, tx.TxIn, 1, "first deposit has only the wallet input")
			}

			require.NotEmpty(t, tx.TxIn[walletIdx].Witness, "wallet input must be signed")
			vmWallet, err := txscript.NewEngine(walletScript, &tx, walletIdx,
				txscript.StandardVerifyFlags|txscript.ScriptVerifyTaproot, nil, sigHashes, walletAmount, prevOuts)
			require.NoError(t, err)
			require.NoError(t, vmWallet.Execute(), "wallet input signature must validate")
		})
	}
}

// TestElectrumSendOpReturnOnly proves an OP_RETURN-only broadcast (e.g. coinnews)
// works with no destinations: the backend still selects a wallet input to cover
// the fee, signs it, emits the OP_RETURN output and returns change.
func TestElectrumSendOpReturnOnly(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	ctx := context.Background()

	const walletAmount = int64(200_000)
	fake.stats[addr] = EsploraAddressStats{
		Address:    addr,
		ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: walletAmount, TxCount: 1},
	}
	fake.utxos[addr] = []EsploraUTXO{{
		TxID: "5555555555555555555555555555555555555555555555555555555555555555",
		Vout: 0, Value: walletAmount,
		Status: EsploraStatus{Confirmed: true, BlockHeight: 100},
	}}

	payload := []byte("coinnews: hello world")
	txid, err := p.Send(ctx, w.ID, SendRequest{
		FixedFeeSats: 1_000,
		OpReturnHex:  hex.EncodeToString(payload),
	})
	require.NoError(t, err)
	require.Equal(t, "broadcasttxid", txid)
	require.Len(t, fake.broadcast, 1)

	var tx wire.MsgTx
	raw, err := hex.DecodeString(fake.broadcast[0])
	require.NoError(t, err)
	require.NoError(t, tx.Deserialize(bytes.NewReader(raw)))

	require.Len(t, tx.TxIn, 1, "a fee-paying input must be selected")
	assert.NotEmpty(t, tx.TxIn[0].Witness, "the input must be signed")

	require.Len(t, tx.TxOut, 2, "OP_RETURN output + change")
	require.Equal(t, byte(txscript.OP_RETURN), tx.TxOut[0].PkScript[0])
	pushed, err := txscript.PushedData(tx.TxOut[0].PkScript)
	require.NoError(t, err)
	require.Len(t, pushed, 1)
	assert.Equal(t, payload, pushed[0])
	assert.Zero(t, tx.TxOut[0].Value)
	assert.Equal(t, walletAmount-1_000, tx.TxOut[1].Value, "change = funds - fee")
}

// TestElectrumSendSidechainDepositInsufficientFunds proves the deposit fails
// cleanly when the wallet can't cover the deposit amount plus fee (the CTIP value
// funds only the treasury output, not the user's contribution).
func TestElectrumSendSidechainDepositInsufficientFunds(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	ctx := context.Background()

	const (
		walletAmount  = int64(100_000)
		oldCtip       = int64(500_000)
		depositAmount = int64(400_000) // exceeds wallet funds
		fee           = int64(1_000)
		slot          = byte(1)
	)

	fake.stats[addr] = EsploraAddressStats{
		Address:    addr,
		ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: walletAmount, TxCount: 1},
	}
	fake.utxos[addr] = []EsploraUTXO{{
		TxID: "4444444444444444444444444444444444444444444444444444444444444444",
		Vout: 0, Value: walletAmount,
		Status: EsploraStatus{Confirmed: true, BlockHeight: 100},
	}}

	drivechainScript := []byte{txscript.OP_NOP5, txscript.OP_DATA_1, slot, txscript.OP_TRUE}
	treasuryPrev := wire.NewMsgTx(2)
	treasuryPrev.AddTxIn(wire.NewTxIn(&wire.OutPoint{Index: 0xffffffff}, []byte{0x00}, nil))
	treasuryPrev.AddTxOut(wire.NewTxOut(oldCtip, drivechainScript))
	var buf bytes.Buffer
	require.NoError(t, treasuryPrev.Serialize(&buf))
	ctipTxid := treasuryPrev.TxHash().String()
	fake.hexByID[ctipTxid] = hex.EncodeToString(buf.Bytes())

	_, err := p.Send(ctx, w.ID, SendRequest{
		FixedFeeSats: fee,
		RawOutputs: []TxOutSpec{
			{RawScriptHex: hex.EncodeToString(drivechainScript), AmountSats: oldCtip + depositAmount},
		},
		OpReturnHex:    hex.EncodeToString([]byte("s1_addr")),
		ExternalInputs: []ExternalInput{{TxID: ctipTxid, Vout: 0, AmountSats: oldCtip}},
	})
	require.Error(t, err)
	assert.Contains(t, err.Error(), "insufficient funds")
	assert.Empty(t, fake.broadcast, "nothing is broadcast when funding fails")
}

// TestElectrumSendUpdatesCacheInstantly proves a send reflects in balance, UTXOs
// and history immediately with no re-scan: the fake Esplora still reports the
// pre-send state, so anything showing the spend came from the local applySpend.
func TestElectrumSendUpdatesCacheInstantly(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	ctx := context.Background()

	fake.stats[addr] = EsploraAddressStats{
		Address:    addr,
		ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 200_000, TxCount: 1},
	}
	fake.utxos[addr] = []EsploraUTXO{{
		TxID: "1111111111111111111111111111111111111111111111111111111111111111",
		Vout: 0, Value: 200_000,
		Status: EsploraStatus{Confirmed: true, BlockHeight: 100},
	}}

	// Warm the cache: confirmed reflects the single 200k UTXO, nothing pending.
	confirmed, pending, err := p.Balance(ctx, w.ID)
	require.NoError(t, err)
	require.InDelta(t, 0.002, confirmed, 1e-9)
	require.Zero(t, pending)

	dest := "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx"
	txid, err := p.Send(ctx, w.ID, SendRequest{
		DestinationsSats: map[string]int64{dest: 50_000},
		FeeRateSatPerVB:  2,
	})
	require.NoError(t, err)

	confirmed, pending, err = p.Balance(ctx, w.ID)
	require.NoError(t, err)
	assert.Zero(t, confirmed, "spent input no longer counts as confirmed")
	assert.Greater(t, pending, 0.0, "change returns as pending")
	assert.InDelta(t, 0.0015, confirmed+pending, 5e-5, "total = 200k - 50k - fee")

	utxos, err := p.ListUnspent(ctx, w.ID)
	require.NoError(t, err)
	require.Len(t, utxos, 1, "old UTXO spent, change UTXO added")
	assert.Equal(t, txid, utxos[0].TxID, "remaining UTXO is the change output")

	txs, err := p.ListTransactions(ctx, w.ID, 0)
	require.NoError(t, err)
	found := false
	for _, tx := range txs {
		if tx.TxID == txid {
			found = true
		}
	}
	assert.True(t, found, "sent tx appears in history immediately")
}

func TestElectrumSendMaxSubtractsFee(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	ctx := context.Background()

	fake.stats[addr] = EsploraAddressStats{
		Address:    addr,
		ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 100_000, TxCount: 1},
	}
	fake.utxos[addr] = []EsploraUTXO{{
		TxID: "3333333333333333333333333333333333333333333333333333333333333333",
		Vout: 0, Value: 100_000, Status: EsploraStatus{Confirmed: true, BlockHeight: 100},
	}}

	dest := "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx"
	_, err := p.Send(ctx, w.ID, SendRequest{
		DestinationsSats:      map[string]int64{dest: 100_000},
		FeeRateSatPerVB:       2,
		SubtractFeeFromAmount: true,
	})
	require.NoError(t, err)
	require.Len(t, fake.broadcast, 1)

	raw, err := hex.DecodeString(fake.broadcast[0])
	require.NoError(t, err)
	var tx wire.MsgTx
	require.NoError(t, tx.Deserialize(bytes.NewReader(raw)))

	require.Len(t, tx.TxOut, 1, "send-max produces no change output")
	// 1-in 1-out: 11 + 68 + 31 = 110 vB at 2 sat/vB = 220 fee.
	assert.Equal(t, int64(100_000-220), tx.TxOut[0].Value)
}

// TestElectrumSubtractFeeReturnsChange: a partial subtract-fee send reduces only
// the recipient by the fee and returns the remainder as change — it must not
// sweep the whole UTXO to the recipient.
func TestElectrumSubtractFeeReturnsChange(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	ctx := context.Background()

	fake.stats[addr] = EsploraAddressStats{
		Address:    addr,
		ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 1_000_000, TxCount: 1},
	}
	fake.utxos[addr] = []EsploraUTXO{{
		TxID: "4444444444444444444444444444444444444444444444444444444444444444",
		Vout: 0, Value: 1_000_000, Status: EsploraStatus{Confirmed: true, BlockHeight: 100},
	}}

	dest := "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx"
	_, err := p.Send(ctx, w.ID, SendRequest{
		DestinationsSats:      map[string]int64{dest: 50_000},
		FeeRateSatPerVB:       2,
		SubtractFeeFromAmount: true,
	})
	require.NoError(t, err)
	require.Len(t, fake.broadcast, 1)

	raw, err := hex.DecodeString(fake.broadcast[0])
	require.NoError(t, err)
	var tx wire.MsgTx
	require.NoError(t, tx.Deserialize(bytes.NewReader(raw)))

	require.Len(t, tx.TxOut, 2, "partial subtract-fee keeps a change output")
	// 1-in 2-out native segwit = 141 vB at 2 sat/vB = 282 fee, taken from the
	// recipient; the rest of the UTXO returns as change.
	assert.Equal(t, int64(50_000-282), tx.TxOut[0].Value, "recipient reduced by fee only")
	assert.Equal(t, int64(950_000), tx.TxOut[1].Value, "remainder returned as change")
}

func TestElectrumSendInsufficientFunds(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	fake.stats[addr] = EsploraAddressStats{
		Address:    addr,
		ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 1_000, TxCount: 1},
	}
	fake.utxos[addr] = []EsploraUTXO{{
		TxID: "2222222222222222222222222222222222222222222222222222222222222222",
		Vout: 0, Value: 1_000, Status: EsploraStatus{Confirmed: true, BlockHeight: 100},
	}}

	_, err := p.Send(context.Background(), w.ID, SendRequest{
		DestinationsSats: map[string]int64{"tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx": 50_000},
		FeeRateSatPerVB:  2,
	})
	require.ErrorContains(t, err, "insufficient funds")
}

func TestElectrumImportSeedIsDeterministic(t *testing.T) {
	svc := newTestService(t)
	w, err := svc.CreateElectrumWallet("Imported", nil, nil, testMnemonic, "", "", 0, "")
	require.NoError(t, err)
	require.Equal(t, WalletTypeElectrum, w.WalletType)

	expected := hex.EncodeToString(MnemonicToSeed(testMnemonic, ""))
	assert.Equal(t, expected, w.Master.SeedHex, "imported mnemonic must produce its own seed")
	assert.Equal(t, testMnemonic, w.Master.Mnemonic)
}

// TestElectrumCustomAccountReceiveAndSpend proves a non-zero account index is
// honored end-to-end: addresses derive under m/84'/1'/1' (signet coin type),
// and a self-send is built, signed to completion, and broadcast. It mirrors
// TestElectrumSendBuildsSignsBroadcasts but on a custom account.
func TestElectrumCustomAccountReceiveAndSpend(t *testing.T) {
	svc := newTestService(t)
	ctx := context.Background()
	net := &chaincfg.SigNetParams

	w, err := svc.CreateElectrumWallet("Acct1", nil, nil, testMnemonic, "", "", 1, "")
	require.NoError(t, err)
	require.Equal(t, uint32(1), w.AccountIndex)

	fake := newFakeEsplora()
	p := NewElectrumBackend(svc, fake, net, zerolog.New(zerolog.NewTestWriter(t)))

	// Receive address must derive under the account-1 external chain.
	d, err := p.walletDescriptor(w)
	require.NoError(t, err)
	recv, err := p.deriveAddr(d, false, 0)
	require.NoError(t, err)
	assert.Equal(t, "m/84'/1'/1'/0/0", recv.hdPath, "receive address must sit under m/84'/1'/1'/0/*")

	// Change address must derive under the account-1 internal chain.
	chgAddr, err := p.NextChangeAddress(ctx, w.ID)
	require.NoError(t, err)
	chgPath, err := p.AddressHDPath(ctx, w.ID, chgAddr)
	require.NoError(t, err)
	assert.Contains(t, chgPath, "m/84'/1'/1'/1/", "change address must sit under m/84'/1'/1'/1/*")

	// Fund the account-1 receive address and spend from it.
	fake.stats[recv.address] = EsploraAddressStats{
		Address:    recv.address,
		ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 200_000, TxCount: 1},
	}
	fake.utxos[recv.address] = []EsploraUTXO{{
		TxID: "2222222222222222222222222222222222222222222222222222222222222222",
		Vout: 0, Value: 200_000,
		Status: EsploraStatus{Confirmed: true, BlockHeight: 100},
	}}

	dest := "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx"
	txid, err := p.Send(ctx, w.ID, SendRequest{
		DestinationsSats: map[string]int64{dest: 50_000},
		FeeRateSatPerVB:  2,
	})
	require.NoError(t, err)
	assert.Equal(t, "broadcasttxid", txid)
	require.Len(t, fake.broadcast, 1)

	raw, err := hex.DecodeString(fake.broadcast[0])
	require.NoError(t, err)
	var tx wire.MsgTx
	require.NoError(t, tx.Deserialize(bytes.NewReader(raw)))

	// Every wallet input must be signed to completion (signedCount == walletInputs):
	// the single input carries a P2WPKH witness, and a change output returns funds.
	require.Len(t, tx.TxIn, 1)
	require.NotEmpty(t, tx.TxIn[0].Witness, "account-1 input must be signed (P2WPKH witness present)")
	require.Len(t, tx.TxOut, 2)
	assert.Equal(t, int64(50_000), tx.TxOut[0].Value)
}

func TestElectrumWatchOnlyDerivesSameAddressesAndCannotSend(t *testing.T) {
	svc := newTestService(t)
	ctx := context.Background()

	seedWallet, err := svc.CreateElectrumWallet("Seed", nil, nil, testMnemonic, "", "", 0, "")
	require.NoError(t, err)
	xpub := accountXpub(t, seedWallet.Master.SeedHex, &chaincfg.SigNetParams)

	woWallet, err := svc.CreateElectrumWallet("Watch", nil, nil, "", xpub, "", 0, "")
	require.NoError(t, err)
	require.Equal(t, WalletTypeElectrum, woWallet.WalletType)
	require.Empty(t, woWallet.Master.SeedHex, "watch-only wallet stores no seed")

	// The address the watch-only xpub derives must equal the seed wallet's.
	seedAddrs, err := DeriveBIP84Addresses(seedWallet.Master.SeedHex, &chaincfg.SigNetParams, 0, 1)
	require.NoError(t, err)
	addr := seedAddrs[0]

	fake := newFakeEsplora()
	p := NewElectrumBackend(svc, fake, &chaincfg.SigNetParams, zerolog.New(zerolog.NewTestWriter(t)))
	fake.stats[addr] = EsploraAddressStats{
		Address:    addr,
		ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 70_000, TxCount: 1},
	}

	confirmed, _, err := p.Balance(ctx, woWallet.ID)
	require.NoError(t, err)
	assert.InDelta(t, 0.0007, confirmed, 1e-9, "watch-only must derive the same address as the seed")

	_, err = p.Send(ctx, woWallet.ID, SendRequest{
		DestinationsSats: map[string]int64{"tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx": 10_000},
	})
	require.ErrorContains(t, err, "watch-only")
}

// TestElectrumBalanceMempoolSpendStaysNonNegative covers an unconfirmed spend
// of confirmed coins: the net mempool delta is negative, which previously made
// Balance return a negative value that wrapped to a huge uint64 downstream.
func TestElectrumBalanceMempoolSpendStaysNonNegative(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	fake.stats[addr] = EsploraAddressStats{
		Address:      addr,
		ChainStats:   EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 100_000, TxCount: 1},
		MempoolStats: EsploraTxoStats{FundedTxoSum: 30_000, SpentTxoSum: 100_000, TxCount: 1},
	}

	confirmed, pending, err := p.Balance(context.Background(), w.ID)
	require.NoError(t, err)
	assert.GreaterOrEqual(t, confirmed, 0.0, "confirmed must never be negative")
	assert.GreaterOrEqual(t, pending, 0.0, "pending must never be negative")
	assert.InDelta(t, 0.0, confirmed, 1e-9)  // 100k confirmed, all being spent in mempool
	assert.InDelta(t, 0.0003, pending, 1e-9) // 30k of mempool inflow (change)
}

// TestElectrumBalanceSpendingUnconfirmedReceive covers spending an unconfirmed
// receive: mempoolSpent exceeds the confirmed balance, so pending must be the
// net wallet total (the change), not the gross mempool inflow.
func TestElectrumBalanceSpendingUnconfirmedReceive(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	// No confirmed coins. In the mempool: received 1 BTC, then spent it leaving
	// 0.5 BTC change — funded 1.5, spent 1.0. The real wallet total is 0.5.
	fake.stats[addr] = EsploraAddressStats{
		Address:      addr,
		MempoolStats: EsploraTxoStats{FundedTxoSum: 150_000_000, SpentTxoSum: 100_000_000, TxCount: 2},
	}

	confirmed, pending, err := p.Balance(context.Background(), w.ID)
	require.NoError(t, err)
	assert.InDelta(t, 0.0, confirmed, 1e-9)
	assert.InDelta(t, 0.5, pending, 1e-9, "pending must be the net 0.5 BTC, not gross 1.5 BTC")
}

// TestElectrumWatchOnlyNextReceiveAdvances guards address reuse: a watch-only
// wallet has no private keys, but its derived chain addresses must still
// advance past used ones instead of always handing out index 0.
func TestElectrumWatchOnlyNextReceiveAdvances(t *testing.T) {
	svc := newTestService(t)
	ctx := context.Background()

	seedWallet, err := svc.CreateElectrumWallet("Seed", nil, nil, testMnemonic, "", "", 0, "")
	require.NoError(t, err)
	xpub := accountXpub(t, seedWallet.Master.SeedHex, &chaincfg.SigNetParams)
	wo, err := svc.CreateElectrumWallet("Watch", nil, nil, "", xpub, "", 0, "")
	require.NoError(t, err)

	addrs, err := DeriveBIP84Addresses(seedWallet.Master.SeedHex, &chaincfg.SigNetParams, 0, 2)
	require.NoError(t, err)
	used, next := addrs[0], addrs[1]

	fake := newFakeEsplora()
	p := NewElectrumBackend(svc, fake, &chaincfg.SigNetParams, zerolog.New(zerolog.NewTestWriter(t)))
	fake.stats[used] = EsploraAddressStats{Address: used, ChainStats: EsploraTxoStats{TxCount: 1}}

	_, _, err = p.Balance(ctx, wo.ID) // warm the scan so usage is known
	require.NoError(t, err)

	got, err := p.NextReceiveAddress(ctx, wo.ID, ScriptUnknown)
	require.NoError(t, err)
	assert.NotEqual(t, used, got, "watch-only must not reuse a used address")
	assert.Equal(t, next, got)
}

// TestElectrumListTransactionsSelfSend covers a consolidation where every input
// and output belongs to the wallet: there's no external payment row, but the
// transaction (and its fee) must still appear in history.
func TestElectrumListTransactionsSelfSend(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	fake.stats[addr] = EsploraAddressStats{
		Address:    addr,
		ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 100_000, TxCount: 1},
	}
	fake.txs[addr] = []EsploraTx{{
		TxID:   "cc",
		Fee:    1_000,
		Vin:    []EsploraVin{{Prevout: &EsploraVout{ScriptPubKeyAddress: addr, Value: 100_000}}},
		Vout:   []EsploraVout{{ScriptPubKeyAddress: addr, Value: 99_000}},
		Status: EsploraStatus{Confirmed: true, BlockHeight: 100, BlockTime: 1700000000},
	}}

	rows, err := p.ListTransactions(context.Background(), w.ID, 0)
	require.NoError(t, err)
	require.Len(t, rows, 1, "self-send must still appear in history")
	assert.Equal(t, "cc", rows[0].TxID)
	assert.Equal(t, "send", rows[0].Category)
	assert.InDelta(t, -0.00001, rows[0].Fee, 1e-9) // -1000 sats
}

// TestElectrumWatchOnlyDescriptorWatchesCorrectAddress imports a real wpkh
// descriptor (origin prefix + /0/* branch) and proves the wallet scans exactly
// the address that descriptor derives — i.e. the balance lands on the same
// address the originating seed produces, and the receive address it hands out
// is one the descriptor genuinely owns.
func TestElectrumWatchOnlyDescriptorWatchesCorrectAddress(t *testing.T) {
	svc := newTestService(t)
	ctx := context.Background()

	seedWallet, err := svc.CreateElectrumWallet("Seed", nil, nil, testMnemonic, "", "", 0, "")
	require.NoError(t, err)
	xpub := accountXpub(t, seedWallet.Master.SeedHex, &chaincfg.SigNetParams)

	descriptor := "wpkh([abcd1234/84h/0h/0h]" + xpub + "/0/*)"
	wo, err := svc.CreateElectrumWallet("WatchDesc", nil, nil, "", descriptor, "", 0, "")
	require.NoError(t, err)
	require.Equal(t, WalletTypeElectrum, wo.WalletType)

	addrs, err := DeriveBIP84Addresses(seedWallet.Master.SeedHex, &chaincfg.SigNetParams, 0, 5)
	require.NoError(t, err)

	fake := newFakeEsplora()
	p := NewElectrumBackend(svc, fake, &chaincfg.SigNetParams, zerolog.New(zerolog.NewTestWriter(t)))
	fake.stats[addrs[0]] = EsploraAddressStats{
		Address:    addrs[0],
		ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 55_000, TxCount: 1},
	}

	confirmed, _, err := p.Balance(ctx, wo.ID)
	require.NoError(t, err)
	assert.InDelta(t, 0.00055, confirmed, 1e-9, "descriptor must watch the address it derives")

	next, err := p.NextReceiveAddress(ctx, wo.ID, ScriptUnknown)
	require.NoError(t, err)
	assert.Contains(t, addrs, next, "receive address must be one the descriptor owns")
	assert.NotEqual(t, addrs[0], next, "must skip the used address")
}

// TestElectrumNextReceiveTaproot proves a taproot-configured hot electrum wallet
// hands out a bech32m (bc1p / tb1p) receive address by default, and that it can
// also serve a segwit (bech32) address from the same seed (dual-kind).
func TestElectrumNextReceiveTaproot(t *testing.T) {
	net := &chaincfg.SigNetParams
	ctx := context.Background()
	svc := newTestService(t)

	w, err := svc.CreateElectrumWallet("Taproot", nil, nil, testMnemonic, "", "taproot", 0, "")
	require.NoError(t, err)
	require.Equal(t, "taproot", w.ScriptType)

	fake := newFakeEsplora()
	p := NewElectrumBackend(svc, fake, net, zerolog.New(zerolog.NewTestWriter(t)))

	addr, err := p.NextReceiveAddress(ctx, w.ID, ScriptTaproot)
	require.NoError(t, err)
	assert.True(t, strings.HasPrefix(addr, net.Bech32HRPSegwit+"1p"), "taproot address must be bech32m: got %s", addr)

	// UNSPECIFIED resolves to the wallet's own kind, so it must also be taproot.
	addrDefault, err := p.NextReceiveAddress(ctx, w.ID, ScriptUnknown)
	require.NoError(t, err)
	assert.True(t, strings.HasPrefix(addrDefault, net.Bech32HRPSegwit+"1p"), "default address must be bech32m: got %s", addrDefault)

	// A hot wallet derives both BIP84 and BIP86 from its seed, so a segwit
	// request is served a bech32 address rather than rejected.
	segwit, err := p.NextReceiveAddress(ctx, w.ID, ScriptNativeSegwit)
	require.NoError(t, err)
	assert.True(t, strings.HasPrefix(segwit, net.Bech32HRPSegwit+"1q"), "segwit address must be bech32: got %s", segwit)
}

// TestElectrumWatchOnlyAllScriptTypesScanCorrectly imports a watch-only
// descriptor of each address type and proves the descriptor-driven backend
// scans the exact address that type derives.
func TestElectrumWatchOnlyAllScriptTypesScanCorrectly(t *testing.T) {
	seedHex := hex.EncodeToString(MnemonicToSeed(testMnemonic, ""))
	net := &chaincfg.SigNetParams
	ctx := context.Background()

	for _, kind := range []ScriptKind{ScriptLegacy, ScriptNestedSegwit, ScriptNativeSegwit, ScriptTaproot} {
		t.Run(kind.String(), func(t *testing.T) {
			acct, err := accountKeyFromSeed(seedHex, kind, net)
			require.NoError(t, err)
			d := &Descriptor{Kind: kind, Threshold: 1, Keys: []DescriptorKey{{Account: acct}}}
			descStr, err := d.String()
			require.NoError(t, err)

			svc := newTestService(t)
			wo, err := svc.CreateElectrumWallet("WO-"+kind.String(), nil, nil, "", descStr, "", 0, "")
			require.NoError(t, err)
			require.Equal(t, kind.String(), wo.ScriptType)

			ds, _, err := d.DeriveScript(false, 0, net)
			require.NoError(t, err)
			addr := ds.address.EncodeAddress()

			fake := newFakeEsplora()
			p := NewElectrumBackend(svc, fake, net, zerolog.New(zerolog.NewTestWriter(t)))
			fake.stats[addr] = EsploraAddressStats{
				Address:    addr,
				ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 42_000, TxCount: 1},
			}

			confirmed, _, err := p.Balance(ctx, wo.ID)
			require.NoError(t, err)
			assert.InDelta(t, 0.00042, confirmed, 1e-9, "%s descriptor must scan its derived address", kind)
		})
	}
}

func TestCreateElectrumWatchOnlyRejectsBadDescriptor(t *testing.T) {
	svc := newTestService(t)
	_, err := svc.CreateElectrumWallet("WO", nil, nil, "", "combo(xpubA)", "", 0, "")
	require.ErrorContains(t, err, "invalid watch-only descriptor")
}

func TestEstimateFeeSats(t *testing.T) {
	// 1 native-segwit input (68 vB) + 62 vB of outputs: 11+68+62 = 141 vB at 2 sat/vB.
	assert.Equal(t, int64(282), estimateFeeSats(1, inputVsize(ScriptNativeSegwit), 62, 2))
}

func TestConfsFor(t *testing.T) {
	assert.Equal(t, 0, confsFor(EsploraStatus{Confirmed: false}, 110))
	assert.Equal(t, 11, confsFor(EsploraStatus{Confirmed: true, BlockHeight: 100}, 110))
	assert.Equal(t, 1, confsFor(EsploraStatus{Confirmed: true, BlockHeight: 110}, 110))
}

// TestElectrumPSBTRoundTrip exercises the exposed PSBT surface end to end:
// create an unsigned PSBT, sign it with the wallet, finalize to a raw tx.
func TestElectrumPSBTRoundTrip(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	ctx := context.Background()

	fake.stats[addr] = EsploraAddressStats{
		Address:    addr,
		ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 200_000, TxCount: 1},
	}
	fake.utxos[addr] = []EsploraUTXO{{
		TxID: "4444444444444444444444444444444444444444444444444444444444444444",
		Vout: 0, Value: 200_000,
		Status: EsploraStatus{Confirmed: true, BlockHeight: 100},
	}}

	req := SendRequest{
		DestinationsSats: map[string]int64{"tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx": 50_000},
		FeeRateSatPerVB:  2,
	}

	unsigned, err := p.CreatePSBT(ctx, w.ID, req)
	require.NoError(t, err)
	require.NotEmpty(t, unsigned)

	signed, err := p.SignPSBT(ctx, w.ID, unsigned)
	require.NoError(t, err)

	rawHex, err := p.FinalizePSBT(signed)
	require.NoError(t, err)

	var tx wire.MsgTx
	raw, err := hex.DecodeString(rawHex)
	require.NoError(t, err)
	require.NoError(t, tx.Deserialize(bytes.NewReader(raw)))
	require.Len(t, tx.TxIn, 1)
	require.NotEmpty(t, tx.TxIn[0].Witness, "finalized input must carry a witness")
	require.Len(t, tx.TxOut, 2) // recipient + change
}

// TestCreateElectrumHotWalletScriptTypes creates a hot wallet of each address
// type and proves it derives the right address AND can build→sign→finalize a
// spend that passes txscript.Engine — i.e. hot wallets of every type can sign.
func TestCreateElectrumHotWalletScriptTypes(t *testing.T) {
	net := &chaincfg.SigNetParams
	ctx := context.Background()
	const amount = int64(200_000)
	const dest = "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx"

	for _, st := range []string{"legacy", "nested-segwit", "taproot"} {
		t.Run(st, func(t *testing.T) {
			svc := newTestService(t)
			w, err := svc.CreateElectrumWallet("Hot-"+st, nil, nil, testMnemonic, "", st, 0, "")
			require.NoError(t, err)
			require.Equal(t, st, w.ScriptType)

			acct, err := accountKeyFromSeed(w.Master.SeedHex, w.scriptKind(), net)
			require.NoError(t, err)
			d := &Descriptor{Kind: w.scriptKind(), Threshold: 1, Keys: []DescriptorKey{{Account: acct}}}
			ds, _, err := d.DeriveScript(false, 0, net)
			require.NoError(t, err)
			addr := ds.address.EncodeAddress()

			// Funding prev tx (also serves the legacy non-witness UTXO).
			prevTx := wire.NewMsgTx(2)
			prevTx.AddTxIn(wire.NewTxIn(&wire.OutPoint{Index: 0xffffffff}, []byte{0x00}, nil))
			prevTx.AddTxOut(wire.NewTxOut(amount, ds.scriptPubKey))
			var buf bytes.Buffer
			require.NoError(t, prevTx.Serialize(&buf))
			prevHash := prevTx.TxHash().String()

			fake := newFakeEsplora()
			fake.stats[addr] = EsploraAddressStats{Address: addr, ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: amount, TxCount: 1}}
			fake.utxos[addr] = []EsploraUTXO{{TxID: prevHash, Vout: 0, Value: amount, Status: EsploraStatus{Confirmed: true, BlockHeight: 100}}}
			fake.hexByID[prevHash] = hex.EncodeToString(buf.Bytes())

			p := NewElectrumBackend(svc, fake, net, zerolog.New(zerolog.NewTestWriter(t)))
			req := SendRequest{DestinationsSats: map[string]int64{dest: 50_000}, FeeRateSatPerVB: 2}

			unsigned, err := p.CreatePSBT(ctx, w.ID, req)
			require.NoError(t, err)
			signed, err := p.SignPSBT(ctx, w.ID, unsigned)
			require.NoError(t, err)
			rawHex, err := p.FinalizePSBT(signed)
			require.NoError(t, err)

			var final wire.MsgTx
			raw, err := hex.DecodeString(rawHex)
			require.NoError(t, err)
			require.NoError(t, final.Deserialize(bytes.NewReader(raw)))
			fetcher := txscript.NewCannedPrevOutputFetcher(ds.scriptPubKey, amount)
			sh := txscript.NewTxSigHashes(&final, fetcher)
			vm, err := txscript.NewEngine(ds.scriptPubKey, &final, 0, txscript.StandardVerifyFlags|txscript.ScriptVerifyTaproot, nil, sh, amount, fetcher)
			require.NoError(t, err)
			require.NoError(t, vm.Execute(), "%s hot wallet spend must verify", st)
		})
	}
}

// TestElectrumGetWalletTransactionSentAmountExcludesFee: a send's Amount is the
// payment only (fee reported separately), not payment+fee.
func TestElectrumGetWalletTransactionSentAmountExcludesFee(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	fake.stats[addr] = EsploraAddressStats{Address: addr, ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 100_000, TxCount: 1}}
	// Spend 100k from addr → 50k to external + 40k change back, 10k fee.
	tx := EsploraTx{
		TxID:   "dd",
		Fee:    10_000,
		Vin:    []EsploraVin{{Prevout: &EsploraVout{ScriptPubKeyAddress: addr, Value: 100_000}}},
		Vout:   []EsploraVout{{ScriptPubKeyAddress: "external", Value: 50_000}, {ScriptPubKeyAddress: addr, Value: 40_000}},
		Status: EsploraStatus{Confirmed: true, BlockHeight: 100},
	}
	fake.txByID["dd"] = tx
	fake.hexByID["dd"] = "00"

	wt, err := p.GetWalletTransaction(context.Background(), w.ID, "dd")
	require.NoError(t, err)
	assert.InDelta(t, -0.0005, wt.Amount, 1e-9, "Amount is the 50k payment, excluding the 10k fee")
	assert.InDelta(t, -0.0001, wt.Fee, 1e-9)
}

// TestElectrumListReceivedExcludesChange: the receive-address list must not
// expose internal change addresses.
// TestElectrumListReceivedIncludesFundedChange proves a change address holding a
// balance is listed and flagged Change, while an unused change address is not —
// so the table accounts for change UTXOs without dumping the change lookahead.
func TestElectrumListReceivedIncludesFundedChange(t *testing.T) {
	net := &chaincfg.SigNetParams
	p, fake, w, addr := newElectrumFixture(t)

	acct, err := accountKeyFromSeed(w.Master.SeedHex, ScriptNativeSegwit, net)
	require.NoError(t, err)
	d := &Descriptor{Kind: ScriptNativeSegwit, Threshold: 1, Keys: []DescriptorKey{{Account: acct}}}
	fundedChg, _, err := d.DeriveScript(true, 0, net)
	require.NoError(t, err)
	fundedChgAddr := fundedChg.address.EncodeAddress()
	unusedChg, _, err := d.DeriveScript(true, 1, net)
	require.NoError(t, err)
	unusedChgAddr := unusedChg.address.EncodeAddress()

	fake.stats[addr] = EsploraAddressStats{Address: addr, ChainStats: EsploraTxoStats{TxCount: 1}}
	fake.stats[fundedChgAddr] = EsploraAddressStats{Address: fundedChgAddr, ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 2857, TxCount: 1}}

	recv, err := p.ListReceivedByAddress(context.Background(), w.ID)
	require.NoError(t, err)
	byAddr := map[string]ReceivedByAddress{}
	for _, r := range recv {
		byAddr[r.Address] = r
	}
	require.Contains(t, byAddr, addr, "external receive address must be listed")
	assert.False(t, byAddr[addr].Change)

	require.Contains(t, byAddr, fundedChgAddr, "funded change address must be listed")
	assert.True(t, byAddr[fundedChgAddr].Change, "change address must be flagged as change")
	assert.InDelta(t, 2857.0/1e8, byAddr[fundedChgAddr].Amount, 1e-9)

	assert.NotContains(t, byAddr, unusedChgAddr, "unused change address must not appear (no change lookahead)")
}

// TestElectrumDualKindServesAndSpendsTaproot proves a standard hot segwit wallet
// also derives, tracks, and spends taproot (BIP86) from the same seed.
func TestElectrumDualKindServesAndSpendsTaproot(t *testing.T) {
	net := &chaincfg.SigNetParams
	ctx := context.Background()
	p, fake, w, _ := newElectrumFixture(t) // native-segwit hot wallet

	tapAddr, err := p.NextReceiveAddress(ctx, w.ID, ScriptTaproot)
	require.NoError(t, err)
	require.True(t, strings.HasPrefix(tapAddr, net.Bech32HRPSegwit+"1p"), "want bech32m, got %s", tapAddr)

	// Fund the taproot address only, then spend it — proves the dual-kind scan
	// tracks and signs taproot UTXOs, not just the wallet's primary segwit kind.
	fake.stats[tapAddr] = EsploraAddressStats{
		Address:    tapAddr,
		ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 200_000, TxCount: 1},
	}
	fake.utxos[tapAddr] = []EsploraUTXO{{
		TxID: "2222222222222222222222222222222222222222222222222222222222222222",
		Vout: 0, Value: 200_000,
		Status: EsploraStatus{Confirmed: true, BlockHeight: 100},
	}}

	confirmed, _, err := p.Balance(ctx, w.ID)
	require.NoError(t, err)
	assert.InDelta(t, 0.002, confirmed, 1e-9, "taproot funds must count toward the segwit wallet's balance")

	txid, err := p.Send(ctx, w.ID, SendRequest{
		DestinationsSats: map[string]int64{"tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx": 50_000},
		FeeRateSatPerVB:  2,
	})
	require.NoError(t, err)
	assert.Equal(t, "broadcasttxid", txid)
	require.Len(t, fake.broadcast, 1)
}

// TestElectrumListReceivedCapsAtHighestUsed proves the receive list stops at the
// highest external index that has received funds, plus one — not the full
// gap-limit lookahead the scan walks.
func TestElectrumListReceivedCapsAtHighestUsed(t *testing.T) {
	net := &chaincfg.SigNetParams
	ctx := context.Background()
	svc := newTestService(t)
	seedWallet, err := svc.CreateElectrumWallet("Seed", nil, nil, testMnemonic, "", "", 0, "")
	require.NoError(t, err)
	xpub := accountXpub(t, seedWallet.Master.SeedHex, net)
	wo, err := svc.CreateElectrumWallet("Watch", nil, nil, "", xpub, "", 0, "") // single-kind segwit
	require.NoError(t, err)

	addrs, err := DeriveBIP84Addresses(seedWallet.Master.SeedHex, net, 0, 6)
	require.NoError(t, err)

	fake := newFakeEsplora()
	p := NewElectrumBackend(svc, fake, net, zerolog.New(zerolog.NewTestWriter(t)))
	// Index 2 received funds; everything else is unused.
	fake.stats[addrs[2]] = EsploraAddressStats{Address: addrs[2], ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 70_000, TxCount: 1}}

	recv, err := p.ListReceivedByAddress(ctx, wo.ID)
	require.NoError(t, err)
	assert.Len(t, recv, 4, "list must stop at highest-received + 1, not dump the gap-limit lookahead")
	listed := map[string]bool{}
	for _, r := range recv {
		listed[r.Address] = true
	}
	for i := 0; i <= 3; i++ {
		assert.True(t, listed[addrs[i]], "index %d (within highest-received + 1) must be listed", i)
	}
	assert.False(t, listed[addrs[4]], "index 4 (beyond highest-received + 1) must not be listed")
}

// TestElectrumListReceivedReportsCurrentBalance proves the receive list reports
// each address's current balance (funded minus spent), not gross received.
func TestElectrumListReceivedReportsCurrentBalance(t *testing.T) {
	net := &chaincfg.SigNetParams
	ctx := context.Background()
	svc := newTestService(t)
	seedWallet, err := svc.CreateElectrumWallet("Seed", nil, nil, testMnemonic, "", "", 0, "")
	require.NoError(t, err)
	xpub := accountXpub(t, seedWallet.Master.SeedHex, net)
	wo, err := svc.CreateElectrumWallet("Watch", nil, nil, "", xpub, "", 0, "")
	require.NoError(t, err)

	addrs, err := DeriveBIP84Addresses(seedWallet.Master.SeedHex, net, 0, 2)
	require.NoError(t, err)

	fake := newFakeEsplora()
	p := NewElectrumBackend(svc, fake, net, zerolog.New(zerolog.NewTestWriter(t)))
	// Index 0: received 100k then spent all of it → current balance 0.
	fake.stats[addrs[0]] = EsploraAddressStats{Address: addrs[0], ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 100_000, SpentTxoCount: 1, SpentTxoSum: 100_000, TxCount: 2}}
	// Index 1: received 50k, unspent → current balance 0.0005.
	fake.stats[addrs[1]] = EsploraAddressStats{Address: addrs[1], ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 50_000, TxCount: 1}}

	recv, err := p.ListReceivedByAddress(ctx, wo.ID)
	require.NoError(t, err)
	byAddr := map[string]float64{}
	for _, r := range recv {
		byAddr[r.Address] = r.Amount
	}
	assert.InDelta(t, 0.0, byAddr[addrs[0]], 1e-9, "fully spent address must report zero balance, not gross received")
	assert.InDelta(t, 0.0005, byAddr[addrs[1]], 1e-9)
}

// TestElectrumWatchOnlyUTXOsNotSpendable: a watch-only wallet's coins are
// solvable (we know the script) but not spendable (no keys).
func TestElectrumWatchOnlyUTXOsNotSpendable(t *testing.T) {
	net := &chaincfg.SigNetParams
	svc := newTestService(t)
	seedWallet, err := svc.CreateElectrumWallet("Seed", nil, nil, testMnemonic, "", "", 0, "")
	require.NoError(t, err)
	xpub := accountXpub(t, seedWallet.Master.SeedHex, net)
	wo, err := svc.CreateElectrumWallet("Watch", nil, nil, "", xpub, "", 0, "")
	require.NoError(t, err)
	addrs, err := DeriveBIP84Addresses(seedWallet.Master.SeedHex, net, 0, 1)
	require.NoError(t, err)
	addr := addrs[0]

	fake := newFakeEsplora()
	p := NewElectrumBackend(svc, fake, net, zerolog.New(zerolog.NewTestWriter(t)))
	fake.stats[addr] = EsploraAddressStats{Address: addr, ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 100_000, TxCount: 1}}
	fake.utxos[addr] = []EsploraUTXO{{TxID: "aa", Vout: 0, Value: 100_000, Status: EsploraStatus{Confirmed: true, BlockHeight: 100}}}

	utxos, err := p.ListUnspent(context.Background(), wo.ID)
	require.NoError(t, err)
	require.Len(t, utxos, 1)
	assert.False(t, utxos[0].Spendable, "watch-only UTXO must not be spendable")
	assert.True(t, utxos[0].Solvable)
}

// TestElectrumSendRejectsMultiOutputSubtractFee: subtract-fee with more than one
// recipient is rejected (the fee-absorbing output would be nondeterministic).
func TestElectrumSendRejectsMultiOutputSubtractFee(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	fake.stats[addr] = EsploraAddressStats{Address: addr, ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 200_000, TxCount: 1}}
	fake.utxos[addr] = []EsploraUTXO{{TxID: "55", Vout: 0, Value: 200_000, Status: EsploraStatus{Confirmed: true, BlockHeight: 100}}}

	_, err := p.Send(context.Background(), w.ID, SendRequest{
		DestinationsSats: map[string]int64{
			"tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx":                     50_000,
			"tb1qrp33g0q5c5txsp9arysrx4k6zdkfs4nce4xj0gdcccefvpysxf3qccfmv3": 50_000,
		},
		FeeRateSatPerVB:       2,
		SubtractFeeFromAmount: true,
	})
	require.ErrorContains(t, err, "single destination")
}

// TestEstimateFeeSatsByScriptKind: input vsize (and thus fee) scales with the
// wallet's address type — a legacy input is far larger than native segwit.
func TestEstimateFeeSatsByScriptKind(t *testing.T) {
	// 1 input + 2 outputs (62 vB total) at 2 sat/vB.
	nativeIn, legacyIn, taprootIn := inputVsize(ScriptNativeSegwit), inputVsize(ScriptLegacy), inputVsize(ScriptTaproot)
	assert.Equal(t, int64(2*(11+68+62)), estimateFeeSats(1, nativeIn, 62, 2))
	assert.Equal(t, int64(2*(11+148+62)), estimateFeeSats(1, legacyIn, 62, 2))
	assert.Greater(t, estimateFeeSats(1, legacyIn, 62, 2), estimateFeeSats(1, taprootIn, 62, 2))
}

// TestDustThresholdByType: dust scales with the output's script type — the
// classic 546 only applies to legacy P2PKH; segwit outputs are lower.
func TestDustThresholdByType(t *testing.T) {
	assert.Equal(t, int64(546), dustThreshold(ScriptLegacy))       // 3*(34+148)
	assert.Equal(t, int64(297), dustThreshold(ScriptNativeSegwit)) // 3*(31+68)
	assert.Equal(t, int64(333), dustThreshold(ScriptTaproot))      // 3*(43+68)
	assert.Equal(t, int64(540), dustThreshold(ScriptNestedSegwit)) // 3*(32+148)
	assert.Less(t, dustThreshold(ScriptNativeSegwit), dustThreshold(ScriptLegacy))
}

// countingEsplora wraps an Esplora and counts AddressStats calls, to prove a
// cold-boot scan is served from the persisted cache with no network.
type countingEsplora struct {
	ChainDataSource
	statsCalls int32
}

func (c *countingEsplora) AddressStats(ctx context.Context, address string) (EsploraAddressStats, error) {
	atomic.AddInt32(&c.statsCalls, 1)
	return c.ChainDataSource.AddressStats(ctx, address)
}

// TestElectrumScanPersistsAcrossRestart: a live scan persists to disk, and a
// fresh backend on the same datadir (a simulated restart) rebuilds the balance
// from the cache without querying Esplora.
func TestElectrumScanPersistsAcrossRestart(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	ctx := context.Background()

	fake.stats[addr] = EsploraAddressStats{
		Address:    addr,
		ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 250_000, TxCount: 1},
	}

	confirmed, _, err := p.Balance(ctx, w.ID) // live scan → persists to disk
	require.NoError(t, err)
	require.InDelta(t, 0.0025, confirmed, 1e-9)

	// Simulated restart: a new backend on the same Service, backed by an Esplora
	// with no data that counts every AddressStats call.
	counting := &countingEsplora{ChainDataSource: newFakeEsplora()}
	p2 := NewElectrumBackend(p.svc, counting, &chaincfg.SigNetParams, zerolog.New(zerolog.NewTestWriter(t)))

	confirmed2, _, err := p2.Balance(ctx, w.ID)
	require.NoError(t, err)
	assert.InDelta(t, 0.0025, confirmed2, 1e-9, "cold boot returns the cached balance")
	assert.Zero(t, atomic.LoadInt32(&counting.statsCalls), "cold boot must not query Esplora")

	// The next call this session is served from the in-memory cache: no new
	// block has arrived, so it does not re-query Esplora and returns the same
	// balance (Sparrow-style scan-once-refresh-on-block).
	confirmed3, _, err := p2.Balance(ctx, w.ID)
	require.NoError(t, err)
	assert.InDelta(t, 0.0025, confirmed3, 1e-9, "served from warm cache while tip unchanged")
	assert.Zero(t, atomic.LoadInt32(&counting.statsCalls), "no re-query without a new block")
}

// TestElectrumScanPersistsUTXOsAndTxs proves a wallet's UTXOs and transactions
// survive a restart by reconstructing from electrum.db, not by re-querying
// Esplora: a cold-boot backend returns the same utxos/history with zero network
// calls.
func TestElectrumScanPersistsUTXOsAndTxs(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	ctx := context.Background()

	fake.stats[addr] = EsploraAddressStats{
		Address:    addr,
		ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 250_000, TxCount: 1},
	}
	fake.utxos[addr] = []EsploraUTXO{{
		TxID:   "aa",
		Vout:   0,
		Value:  250_000,
		Status: EsploraStatus{Confirmed: true, BlockHeight: 100, BlockHash: "hash", BlockTime: 1_700_000_000},
	}}
	fake.txs[addr] = []EsploraTx{{
		TxID:   "aa",
		Vout:   []EsploraVout{{ScriptPubKeyAddress: addr, Value: 250_000}},
		Status: EsploraStatus{Confirmed: true, BlockHeight: 100, BlockTime: 1_700_000_000},
	}}

	utxos, err := p.ListUnspent(ctx, w.ID) // live scan → persists to electrum.db
	require.NoError(t, err)
	require.Len(t, utxos, 1)

	// Cold boot: a fresh backend whose Esplora holds no data and counts stats
	// calls. UTXOs and history must come entirely from the database.
	counting := &countingEsplora{ChainDataSource: newFakeEsplora()}
	p2 := NewElectrumBackend(p.svc, counting, &chaincfg.SigNetParams, zerolog.New(zerolog.NewTestWriter(t)))

	utxos2, err := p2.ListUnspent(ctx, w.ID)
	require.NoError(t, err)
	require.Len(t, utxos2, 1, "utxos reconstructed from electrum.db")
	assert.Equal(t, "aa", utxos2[0].TxID)
	assert.InDelta(t, 0.0025, utxos2[0].Amount, 1e-9)

	txs2, err := p2.ListTransactions(ctx, w.ID, 0)
	require.NoError(t, err)
	require.Len(t, txs2, 1, "transactions reconstructed from electrum.db")
	assert.Equal(t, "aa", txs2[0].TxID)

	assert.Zero(t, atomic.LoadInt32(&counting.statsCalls), "cold boot must not query Esplora")
}

// recordingEsplora captures the wallet's sync snapshot at each AddressStats
// call, so a test can prove the polled status reflects scan progress.
type recordingEsplora struct {
	ChainDataSource
	svc   *Service
	snaps []SyncProgress
}

func (r *recordingEsplora) AddressStats(ctx context.Context, address string) (EsploraAddressStats, error) {
	r.snaps = append(r.snaps, r.svc.ActiveSyncStatus())
	return r.ChainDataSource.AddressStats(ctx, address)
}

// TestElectrumScanReportsProgress: the snapshot a GetSyncStatus poll would read
// reflects descriptive progress mid-scan (which chain, addresses checked), and
// settles to idle afterward.
func TestElectrumScanReportsProgress(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	ctx := context.Background()
	fake.stats[addr] = EsploraAddressStats{
		Address:    addr,
		ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 100_000, TxCount: 1},
	}

	rec := &recordingEsplora{ChainDataSource: fake, svc: p.svc}
	p2 := NewElectrumBackend(p.svc, rec, &chaincfg.SigNetParams, zerolog.New(zerolog.NewTestWriter(t)))

	_, _, err := p2.Balance(ctx, w.ID) // live scan
	require.NoError(t, err)

	var sawExternal, sawChange bool
	for _, s := range rec.snaps {
		if s.Phase == SyncScanning && s.Chain == "external" {
			sawExternal = true
			assert.Contains(t, s.Message, "Scanning external addresses")
		}
		if s.Phase == SyncScanning && s.Chain == "change" {
			sawChange = true
		}
	}
	assert.True(t, sawExternal, "snapshot reflects scanning the external chain")
	assert.True(t, sawChange, "snapshot reflects scanning the change chain")
	assert.Equal(t, SyncIdle, p.svc.SyncSnapshot(w.ID).Phase, "settles to idle")
}

func TestElectrumCreateCpfpPackageRate(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	ctx := context.Background()

	const (
		parentTxid  = "2222222222222222222222222222222222222222222222222222222222222222"
		parentValue = int64(200_000)
		parentVsize = int64(150)
		parentFee   = int64(150) // 1 sat/vB parent, deliberately too low
		targetRate  = int64(20)
	)

	fake.stats[addr] = EsploraAddressStats{
		Address:      addr,
		MempoolStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: parentValue, TxCount: 1},
	}
	fake.utxos[addr] = []EsploraUTXO{{
		TxID: parentTxid, Vout: 0, Value: parentValue,
		Status: EsploraStatus{Confirmed: false},
	}}
	fake.txByID[parentTxid] = EsploraTx{
		TxID:   parentTxid,
		Weight: int32(parentVsize * 4),
		Fee:    parentFee,
		Status: EsploraStatus{Confirmed: false},
	}

	childTxid, err := p.CreateCpfp(ctx, w.ID, CpfpRequest{
		ParentTxID: parentTxid,
		ParentVout: 0,
		TargetRate: targetRate,
	})
	require.NoError(t, err)
	assert.Equal(t, "broadcasttxid", childTxid)
	require.Len(t, fake.broadcast, 1)

	raw, err := hex.DecodeString(fake.broadcast[0])
	require.NoError(t, err)
	var tx wire.MsgTx
	require.NoError(t, tx.Deserialize(bytes.NewReader(raw)))

	require.Len(t, tx.TxIn, 1, "child must spend exactly the parent outpoint")
	assert.Equal(t, parentTxid, tx.TxIn[0].PreviousOutPoint.Hash.String())
	assert.Equal(t, uint32(0), tx.TxIn[0].PreviousOutPoint.Index)
	require.NotEmpty(t, tx.TxIn[0].Witness, "child input must be signed")

	require.Len(t, tx.TxOut, 1, "self-send: single output, fee taken from it")
	childFee := parentValue - tx.TxOut[0].Value
	require.Positive(t, childFee)

	childVsize := computeVsize(&tx)
	packageRate := float64(parentFee+childFee) / float64(parentVsize+childVsize)
	assert.GreaterOrEqual(t, packageRate, float64(targetRate),
		"package fee rate (%.2f) must reach target (%d)", packageRate, targetRate)
}

func TestElectrumCreateCpfpRejectsConfirmedParent(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	ctx := context.Background()

	const parentTxid = "4444444444444444444444444444444444444444444444444444444444444444"
	fake.stats[addr] = EsploraAddressStats{
		Address:    addr,
		ChainStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 100_000, TxCount: 1},
	}
	fake.utxos[addr] = []EsploraUTXO{{
		TxID: parentTxid, Vout: 0, Value: 100_000,
		Status: EsploraStatus{Confirmed: true, BlockHeight: 100},
	}}

	_, err := p.CreateCpfp(ctx, w.ID, CpfpRequest{ParentTxID: parentTxid, ParentVout: 0, TargetRate: 10})
	require.Error(t, err)
	assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
}

func TestElectrumCreateCpfpRejectsLowTarget(t *testing.T) {
	p, fake, w, addr := newElectrumFixture(t)
	ctx := context.Background()

	const parentTxid = "5555555555555555555555555555555555555555555555555555555555555555"
	fake.stats[addr] = EsploraAddressStats{
		Address:      addr,
		MempoolStats: EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: 100_000, TxCount: 1},
	}
	fake.utxos[addr] = []EsploraUTXO{{
		TxID: parentTxid, Vout: 0, Value: 100_000,
		Status: EsploraStatus{Confirmed: false},
	}}
	fake.txByID[parentTxid] = EsploraTx{TxID: parentTxid, Weight: 600, Fee: 1500} // 10 sat/vB

	_, err := p.CreateCpfp(ctx, w.ID, CpfpRequest{ParentTxID: parentTxid, ParentVout: 0, TargetRate: 10})
	require.Error(t, err)
	assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
}

// computeVsize returns the BIP141 virtual size of a fully-signed transaction.
func computeVsize(tx *wire.MsgTx) int64 {
	var stripped bytes.Buffer
	_ = tx.SerializeNoWitness(&stripped)
	var full bytes.Buffer
	_ = tx.Serialize(&full)
	baseSize := int64(stripped.Len())
	totalSize := int64(full.Len())
	weight := baseSize*3 + totalSize
	return (weight + 3) / 4
}
