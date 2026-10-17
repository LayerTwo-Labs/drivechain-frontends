package engines

import (
	"context"
	"errors"
	"testing"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcec/v2/schnorr"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/samber/lo"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const destAddress = "tb1q6rz28mcfaxtmd6v789l9rrlrusdprr9pqcpvkl"

func testUTXOs() []ChequeUTXO {
	return []ChequeUTXO{{
		TxID:      "4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b",
		Vout:      0,
		ValueSats: 100_000,
	}}
}

func newWIF(t *testing.T, compressed bool) *btcutil.WIF {
	t.Helper()
	privKey, err := btcec.NewPrivateKey()
	require.NoError(t, err)
	wif, err := btcutil.NewWIF(privKey, &chaincfg.SigNetParams, compressed)
	require.NoError(t, err)
	return wif
}

// fakeChain answers AddressUnspent from a fixed address→UTXO map.
type fakeChain struct {
	funded  map[string][]ChequeUTXO
	queried []string
	err     error
	// failures makes the next reads fail, as a chain source that still boots does.
	failures int
}

func (f *fakeChain) AddressUnspent(_ context.Context, address string) ([]ChequeUTXO, error) {
	if f.err != nil {
		return nil, f.err
	}
	if f.failures > 0 {
		f.failures--
		return nil, errors.New("connection refused")
	}
	f.queried = append(f.queried, address)
	return f.funded[address], nil
}
func (f *fakeChain) FeeRateSatPerVByte(context.Context, int32) (float64, error) { return 1, nil }
func (f *fakeChain) Broadcast(context.Context, string) (string, error)          { return "txid", nil }

func TestSweepCandidatesCompressedKeyHasBothKinds(t *testing.T) {
	t.Parallel()
	wif := newWIF(t, true)

	candidates, err := SweepCandidates(wif, &chaincfg.SigNetParams)
	require.NoError(t, err)
	require.Len(t, candidates, 2)
	assert.Equal(t, SweepAddressP2WPKH, candidates[0].Kind)
	assert.Equal(t, SweepAddressP2PKH, candidates[1].Kind)
}

func TestSweepCandidatesUncompressedKeyIsLegacyOnly(t *testing.T) {
	t.Parallel()
	wif := newWIF(t, false)

	candidates, err := SweepCandidates(wif, &chaincfg.SigNetParams)
	require.NoError(t, err)
	require.Len(t, candidates, 1)
	assert.Equal(t, SweepAddressP2PKH, candidates[0].Kind)
}

func TestResolveSweepSourceFindsLegacyFunds(t *testing.T) {
	t.Parallel()
	wif := newWIF(t, true)
	candidates, err := SweepCandidates(wif, &chaincfg.SigNetParams)
	require.NoError(t, err)
	legacy := candidates[1]

	chain := &fakeChain{funded: map[string][]ChequeUTXO{legacy.Address: testUTXOs()}}

	source, err := ResolveSweepSource(t.Context(), chain, wif, &chaincfg.SigNetParams)
	require.NoError(t, err)
	assert.Equal(t, SweepAddressP2PKH, source.Kind)
	assert.Equal(t, legacy.Address, source.Address)
	assert.Equal(t, uint64(100_000), source.TotalSats())
	assert.Len(t, chain.queried, 2)
}

func TestResolveSweepSourcePrefersWitnessWhenBothFunded(t *testing.T) {
	t.Parallel()
	wif := newWIF(t, true)
	candidates, _ := SweepCandidates(wif, &chaincfg.SigNetParams)

	chain := &fakeChain{funded: map[string][]ChequeUTXO{
		candidates[0].Address: testUTXOs(),
		candidates[1].Address: testUTXOs(),
	}}

	source, err := ResolveSweepSource(t.Context(), chain, wif, &chaincfg.SigNetParams)
	require.NoError(t, err)
	assert.Equal(t, SweepAddressP2WPKH, source.Kind)
}

func TestResolveSweepSourceEmptyKeyReportsFirstCandidate(t *testing.T) {
	t.Parallel()
	wif := newWIF(t, true)
	candidates, _ := SweepCandidates(wif, &chaincfg.SigNetParams)

	chain := &fakeChain{funded: map[string][]ChequeUTXO{}}

	source, err := ResolveSweepSource(t.Context(), chain, wif, &chaincfg.SigNetParams)
	require.NoError(t, err)
	assert.Empty(t, source.UTXOs)
	assert.Equal(t, candidates[0].Address, source.Address)
}

func TestResolveSweepSourceReturnsChainError(t *testing.T) {
	t.Parallel()
	wif := newWIF(t, true)
	chain := &fakeChain{err: errors.New("electrum down")}

	_, err := ResolveSweepSource(t.Context(), chain, wif, &chaincfg.SigNetParams)
	require.ErrorContains(t, err, "electrum down")
}

func TestSweepVbytesChargesMoreForLegacyInputs(t *testing.T) {
	t.Parallel()
	tests := []struct {
		name       string
		kind       SweepAddressKind
		compressed bool
		want       uint64
	}{
		{name: "p2wpkh", kind: SweepAddressP2WPKH, compressed: true, want: 110},
		{name: "compressed p2pkh", kind: SweepAddressP2PKH, compressed: true, want: 190},
		{name: "uncompressed p2pkh", kind: SweepAddressP2PKH, compressed: false, want: 222},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()
			source := SweepSource{Kind: tt.kind, Compressed: tt.compressed, UTXOs: testUTXOs()}
			assert.Equal(t, tt.want, SweepVbytes(source, OutputVbytes))
		})
	}
}

func TestBuildAndSignSweep(t *testing.T) {
	t.Parallel()
	const feeRate = 10
	tests := []struct {
		name       string
		compressed bool
		kind       SweepAddressKind
		wantValue  int64
	}{
		{name: "p2wpkh", compressed: true, kind: SweepAddressP2WPKH, wantValue: 100_000 - 110*feeRate},
		{name: "compressed p2pkh", compressed: true, kind: SweepAddressP2PKH, wantValue: 100_000 - 190*feeRate},
		{name: "uncompressed p2pkh", compressed: false, kind: SweepAddressP2PKH, wantValue: 100_000 - 222*feeRate},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()
			wif := newWIF(t, tt.compressed)
			candidates, err := SweepCandidates(wif, &chaincfg.SigNetParams)
			require.NoError(t, err)
			candidate, found := lo.Find(candidates, func(c SweepCandidate) bool { return c.Kind == tt.kind })
			require.True(t, found)
			chain := &fakeChain{funded: map[string][]ChequeUTXO{candidate.Address: testUTXOs()}}
			source, err := ResolveSweepSource(t.Context(), chain, wif, &chaincfg.SigNetParams)
			require.NoError(t, err)
			require.Equal(t, tt.kind, source.Kind)

			tx, err := BuildSweepTx(source, destAddress, feeRate, &chaincfg.SigNetParams)
			require.NoError(t, err)
			assert.Equal(t, tt.wantValue, tx.TxOut[0].Value)

			signed, err := SignSweepTx(tx, source, wif, &chaincfg.SigNetParams)
			require.NoError(t, err)
			assertInputVerifies(t, signed, source, 100_000)

			weight := signed.SerializeSizeStripped()*3 + signed.SerializeSize()
			vsize := int64((weight + 3) / 4)
			feeSats := 100_000 - signed.TxOut[0].Value
			assert.GreaterOrEqual(t, feeSats, vsize*feeRate)
		})
	}
}

func TestBuildSweepTxRejectsFeeAboveBalance(t *testing.T) {
	t.Parallel()
	wif := newWIF(t, true)
	candidates, _ := SweepCandidates(wif, &chaincfg.SigNetParams)
	source := SweepSource{Address: candidates[0].Address, Kind: SweepAddressP2WPKH, UTXOs: testUTXOs()}

	_, err := BuildSweepTx(source, destAddress, 10_000, &chaincfg.SigNetParams)
	require.ErrorContains(t, err, "insufficient funds")
}

func TestBuildSweepTxRejectsADustOutput(t *testing.T) {
	t.Parallel()
	wif := newWIF(t, true)
	candidates, err := SweepCandidates(wif, &chaincfg.SigNetParams)
	require.NoError(t, err)
	legacyDest := candidates[1].Address

	tests := []struct {
		name      string
		dest      string
		outVbytes int64
		overFee   int64
		wantErr   string
	}{
		{name: "one sat below the P2WPKH dust limit is refused", dest: destAddress, outVbytes: 31, overFee: 293, wantErr: "below the dust limit of 294 sats"},
		{name: "the P2WPKH dust limit builds", dest: destAddress, outVbytes: 31, overFee: 294},
		{name: "one sat below the P2PKH dust limit is refused", dest: legacyDest, outVbytes: 34, overFee: 545, wantErr: "below the dust limit of 546 sats"},
		{name: "the P2PKH dust limit builds", dest: legacyDest, outVbytes: 34, overFee: 546},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()
			feeSats := InputVbytes + OverheadVbytes + tt.outVbytes
			source := SweepSource{Address: candidates[0].Address, Kind: SweepAddressP2WPKH, UTXOs: []ChequeUTXO{{
				TxID:      "4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b",
				ValueSats: feeSats + tt.overFee,
			}}}

			tx, err := BuildSweepTx(source, tt.dest, 1, &chaincfg.SigNetParams)
			if tt.wantErr != "" {
				require.ErrorIs(t, err, ErrInvalidSweep)
				require.ErrorContains(t, err, tt.wantErr)
				return
			}
			require.NoError(t, err)
			require.Equal(t, tt.overFee, tx.TxOut[0].Value)
		})
	}
}

func TestBuildSweepTxCapsTheFee(t *testing.T) {
	t.Parallel()
	wif := newWIF(t, true)
	candidates, err := SweepCandidates(wif, &chaincfg.SigNetParams)
	require.NoError(t, err)

	oneBitcoin := func(inputs int) []ChequeUTXO {
		utxos := make([]ChequeUTXO, inputs)
		for i := range utxos {
			utxos[i] = ChequeUTXO{
				TxID:      "4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b",
				Vout:      int32(i),
				ValueSats: 100_000_000,
			}
		}
		return utxos
	}

	tests := []struct {
		name           string
		inputs         int
		feeSatPerVbyte uint64
		wantErr        string
	}{
		{name: "rate at the cap builds", inputs: 1, feeSatPerVbyte: 10_000},
		{name: "rate above the cap is refused", inputs: 1, feeSatPerVbyte: 10_001, wantErr: "fee rate 10001 sat/vB is above the cap"},
		{name: "fee above the cap is refused", inputs: 30, feeSatPerVbyte: 5_000, wantErr: "is above the cap of 10000000 sats"},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()
			source := SweepSource{Address: candidates[0].Address, Kind: SweepAddressP2WPKH, UTXOs: oneBitcoin(tt.inputs)}

			tx, err := BuildSweepTx(source, destAddress, tt.feeSatPerVbyte, &chaincfg.SigNetParams)
			if tt.wantErr != "" {
				require.ErrorContains(t, err, tt.wantErr)
				return
			}
			require.NoError(t, err)
			require.Len(t, tx.TxOut, 1)
		})
	}
}

func TestBuildSweepTxRejectsForeignNetworkAddress(t *testing.T) {
	t.Parallel()
	wif := newWIF(t, true)
	candidates, _ := SweepCandidates(wif, &chaincfg.SigNetParams)
	source := SweepSource{Address: candidates[0].Address, Kind: SweepAddressP2WPKH, UTXOs: testUTXOs()}

	mainnet := "bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq"
	_, err := BuildSweepTx(source, mainnet, 10, &chaincfg.SigNetParams)
	require.ErrorContains(t, err, "destination address is for another network")
}

// assertInputVerifies runs the script engine over input 0, which is the real
// proof that the signature and its script kind match the source address.
func assertInputVerifies(t *testing.T, tx *wire.MsgTx, source SweepSource, valueSats int64) {
	t.Helper()

	sourceAddr, err := btcutil.DecodeAddress(source.Address, &chaincfg.SigNetParams)
	require.NoError(t, err)
	pkScript, err := txscript.PayToAddrScript(sourceAddr)
	require.NoError(t, err)

	vm, err := txscript.NewEngine(
		pkScript, tx, 0,
		txscript.StandardVerifyFlags,
		nil, nil, valueSats,
		txscript.NewCannedPrevOutputFetcher(pkScript, valueSats),
	)
	require.NoError(t, err)
	require.NoError(t, vm.Execute())
}

func TestSweepPaysForTheDestinationItActuallyUses(t *testing.T) {
	t.Parallel()
	wif := newWIF(t, true)
	candidates, _ := SweepCandidates(wif, &chaincfg.SigNetParams)
	source := SweepSource{Address: candidates[0].Address, Kind: SweepAddressP2WPKH, UTXOs: testUTXOs()}

	// a taproot output is 43 vbytes, twelve wider than segwit's 31
	taprootAddr, err := btcutil.NewAddressTaproot(
		schnorr.SerializePubKey(wif.PrivKey.PubKey()), &chaincfg.SigNetParams,
	)
	require.NoError(t, err)
	tx, err := BuildSweepTx(source, taprootAddr.EncodeAddress(), 10, &chaincfg.SigNetParams)
	require.NoError(t, err)

	// 100000 - ((68 + 11 + 43) * 10)
	assert.Equal(t, int64(98_780), tx.TxOut[0].Value)

	segwit, err := BuildSweepTx(source, destAddress, 10, &chaincfg.SigNetParams)
	require.NoError(t, err)
	assert.Greater(t, segwit.TxOut[0].Value, tx.TxOut[0].Value)
}
