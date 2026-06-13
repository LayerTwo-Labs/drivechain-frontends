package wallet

import (
	"bytes"
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
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

// fakeEsplora is an in-memory Esplora REST backend driven by per-address
// fixtures, enough to exercise scan/balance/send end to end.
type fakeEsplora struct {
	mu        sync.Mutex
	stats     map[string]EsploraAddressStats
	utxos     map[string][]EsploraUTXO
	txs       map[string][]EsploraTx
	tip       int
	broadcast []string
}

func newFakeEsplora() *fakeEsplora {
	return &fakeEsplora{
		stats: map[string]EsploraAddressStats{},
		utxos: map[string][]EsploraUTXO{},
		txs:   map[string][]EsploraTx{},
		tip:   110,
	}
}

func (f *fakeEsplora) server(t *testing.T) *EsploraClient {
	t.Helper()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		f.mu.Lock()
		defer f.mu.Unlock()
		path := r.URL.Path
		switch {
		case r.Method == http.MethodPost && path == "/api/tx":
			body, _ := io.ReadAll(r.Body)
			f.broadcast = append(f.broadcast, string(body))
			_, _ = io.WriteString(w, "broadcasttxid")
		case path == "/api/blocks/tip/height":
			fmt.Fprintf(w, "%d", f.tip)
		case path == "/api/fee-estimates":
			_ = json.NewEncoder(w).Encode(map[string]float64{"6": 1.0, "1": 2.0})
		case strings.HasSuffix(path, "/utxo"):
			addr := strings.TrimSuffix(strings.TrimPrefix(path, "/api/address/"), "/utxo")
			_ = json.NewEncoder(w).Encode(f.utxos[addr])
		case strings.Contains(path, "/txs"):
			addr := strings.TrimPrefix(path, "/api/address/")
			addr = strings.SplitN(addr, "/txs", 2)[0]
			_ = json.NewEncoder(w).Encode(f.txs[addr])
		case strings.HasPrefix(path, "/api/address/"):
			addr := strings.TrimPrefix(path, "/api/address/")
			s, ok := f.stats[addr]
			if !ok {
				s = EsploraAddressStats{Address: addr}
			}
			_ = json.NewEncoder(w).Encode(s)
		default:
			http.Error(w, "not found: "+path, http.StatusNotFound)
		}
	}))
	t.Cleanup(srv.Close)
	return NewEsploraClient(srv.URL + "/api")
}

func newElectrumFixture(t *testing.T) (*ElectrumProvider, *fakeEsplora, *WalletData, string) {
	t.Helper()
	svc := newTestService(t)
	w, err := svc.CreateElectrumWallet("Electrum", nil, nil, "", "")
	require.NoError(t, err)
	require.Equal(t, "electrum", w.WalletType)

	addrs, err := DeriveBIP84Addresses(w.Master.SeedHex, &chaincfg.SigNetParams, 0, 1)
	require.NoError(t, err)
	firstAddr := addrs[0]

	fake := newFakeEsplora()
	client := fake.server(t)
	p := NewElectrumProvider(svc, client, &chaincfg.SigNetParams, zerolog.New(zerolog.NewTestWriter(t)))
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
	p := NewElectrumProvider(svc, fake.server(t), &chaincfg.SigNetParams, zerolog.New(zerolog.NewTestWriter(t)))
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

func TestExtractXpubToken(t *testing.T) {
	desc := "wpkh([abcd1234/84'/1'/0']tpubDEADBEEF/0/*)#checksum"
	assert.Equal(t, "tpubDEADBEEF", extractXpubToken(desc))
	assert.Equal(t, "", extractXpubToken("addr(tb1qxyz)"))
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
