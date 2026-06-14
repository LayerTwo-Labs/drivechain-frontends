package wallet

import (
	"bytes"
	"context"
	"encoding/hex"
	"fmt"
	"sync"
	"testing"

	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
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

var _ Esplora = (*fakeEsplora)(nil)

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
	w, err := svc.CreateElectrumWallet("Electrum", nil, nil, "", "")
	require.NoError(t, err)
	require.Equal(t, "electrum", w.WalletType)

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

	next, err := p.NextReceiveAddress(context.Background(), w.ID)
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
	w, err := svc.CreateElectrumWallet("Imported", nil, nil, testMnemonic, "")
	require.NoError(t, err)
	require.Equal(t, "electrum", w.WalletType)

	expected := hex.EncodeToString(MnemonicToSeed(testMnemonic, ""))
	assert.Equal(t, expected, w.Master.SeedHex, "imported mnemonic must produce its own seed")
	assert.Equal(t, testMnemonic, w.Master.Mnemonic)
}

func TestElectrumWatchOnlyDerivesSameAddressesAndCannotSend(t *testing.T) {
	svc := newTestService(t)
	ctx := context.Background()

	seedWallet, err := svc.CreateElectrumWallet("Seed", nil, nil, testMnemonic, "")
	require.NoError(t, err)
	xpub := accountXpub(t, seedWallet.Master.SeedHex, &chaincfg.SigNetParams)

	woWallet, err := svc.CreateElectrumWallet("Watch", nil, nil, "", xpub)
	require.NoError(t, err)
	require.Equal(t, "electrum", woWallet.WalletType)
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

// TestElectrumWatchOnlyNextReceiveAdvances guards address reuse: a watch-only
// wallet has no private keys, but its derived chain addresses must still
// advance past used ones instead of always handing out index 0.
func TestElectrumWatchOnlyNextReceiveAdvances(t *testing.T) {
	svc := newTestService(t)
	ctx := context.Background()

	seedWallet, err := svc.CreateElectrumWallet("Seed", nil, nil, testMnemonic, "")
	require.NoError(t, err)
	xpub := accountXpub(t, seedWallet.Master.SeedHex, &chaincfg.SigNetParams)
	wo, err := svc.CreateElectrumWallet("Watch", nil, nil, "", xpub)
	require.NoError(t, err)

	addrs, err := DeriveBIP84Addresses(seedWallet.Master.SeedHex, &chaincfg.SigNetParams, 0, 2)
	require.NoError(t, err)
	used, next := addrs[0], addrs[1]

	fake := newFakeEsplora()
	p := NewElectrumBackend(svc, fake, &chaincfg.SigNetParams, zerolog.New(zerolog.NewTestWriter(t)))
	fake.stats[used] = EsploraAddressStats{Address: used, ChainStats: EsploraTxoStats{TxCount: 1}}

	got, err := p.NextReceiveAddress(ctx, wo.ID)
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

	seedWallet, err := svc.CreateElectrumWallet("Seed", nil, nil, testMnemonic, "")
	require.NoError(t, err)
	xpub := accountXpub(t, seedWallet.Master.SeedHex, &chaincfg.SigNetParams)

	descriptor := "wpkh([abcd1234/84h/0h/0h]" + xpub + "/0/*)"
	wo, err := svc.CreateElectrumWallet("WatchDesc", nil, nil, "", descriptor)
	require.NoError(t, err)
	require.Equal(t, "electrum", wo.WalletType)

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

	next, err := p.NextReceiveAddress(ctx, wo.ID)
	require.NoError(t, err)
	assert.Contains(t, addrs, next, "receive address must be one the descriptor owns")
	assert.NotEqual(t, addrs[0], next, "must skip the used address")
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
			wo, err := svc.CreateElectrumWallet("WO-"+kind.String(), nil, nil, "", descStr)
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
	_, err := svc.CreateElectrumWallet("WO", nil, nil, "", "combo(xpubA)")
	require.ErrorContains(t, err, "invalid watch-only descriptor")
}

func TestEstimateFeeSats(t *testing.T) {
	// 1 input, 2 outputs: 11 + 68 + 62 = 141 vB at 2 sat/vB = 282.
	assert.Equal(t, int64(282), estimateFeeSats(1, 2, 2))
}

func TestConfsFor(t *testing.T) {
	assert.Equal(t, 0, confsFor(EsploraStatus{Confirmed: false}, 110))
	assert.Equal(t, 11, confsFor(EsploraStatus{Confirmed: true, BlockHeight: 100}, 110))
	assert.Equal(t, 1, confsFor(EsploraStatus{Confirmed: true, BlockHeight: 110}, 110))
}
