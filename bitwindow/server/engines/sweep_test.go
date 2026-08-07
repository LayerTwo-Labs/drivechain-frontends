package engines

import (
	"context"
	"errors"
	"testing"
	"time"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
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
	if err != nil {
		t.Fatalf("generate private key: %v", err)
	}
	wif, err := btcutil.NewWIF(privKey, &chaincfg.SigNetParams, compressed)
	if err != nil {
		t.Fatalf("create WIF: %v", err)
	}
	return wif
}

// fakeChain answers AddressUnspent from a fixed address→UTXO map.
type fakeChain struct {
	funded  map[string][]ChequeUTXO
	queried []string
	err     error
}

func (f *fakeChain) Name() string                   { return "fake" }
func (f *fakeChain) Available(context.Context) bool { return true }
func (f *fakeChain) AddressUnspent(_ context.Context, address string, _ time.Time) ([]ChequeUTXO, error) {
	if f.err != nil {
		return nil, f.err
	}
	f.queried = append(f.queried, address)
	return f.funded[address], nil
}
func (f *fakeChain) FeeRateSatPerVByte(context.Context, int32) (float64, error) { return 1, nil }
func (f *fakeChain) Broadcast(context.Context, string) (string, error)          { return "txid", nil }

func TestSweepCandidatesCompressedKeyHasBothKinds(t *testing.T) {
	wif := newWIF(t, true)

	candidates, err := SweepCandidates(wif, &chaincfg.SigNetParams)
	if err != nil {
		t.Fatalf("derive candidates: %v", err)
	}
	if len(candidates) != 2 {
		t.Fatalf("expected 2 candidates, got %d", len(candidates))
	}
	if candidates[0].Kind != SweepAddressP2WPKH {
		t.Errorf("expected p2wpkh first, got %s", candidates[0].Kind)
	}
	if candidates[1].Kind != SweepAddressP2PKH {
		t.Errorf("expected p2pkh second, got %s", candidates[1].Kind)
	}
}

func TestSweepCandidatesUncompressedKeyIsLegacyOnly(t *testing.T) {
	wif := newWIF(t, false)

	candidates, err := SweepCandidates(wif, &chaincfg.SigNetParams)
	if err != nil {
		t.Fatalf("derive candidates: %v", err)
	}
	if len(candidates) != 1 {
		t.Fatalf("expected 1 candidate, got %d", len(candidates))
	}
	if candidates[0].Kind != SweepAddressP2PKH {
		t.Errorf("expected p2pkh, got %s", candidates[0].Kind)
	}
}

func TestResolveSweepSourceFindsLegacyFunds(t *testing.T) {
	wif := newWIF(t, true)
	candidates, err := SweepCandidates(wif, &chaincfg.SigNetParams)
	if err != nil {
		t.Fatalf("derive candidates: %v", err)
	}
	legacy := candidates[1]

	chain := &fakeChain{funded: map[string][]ChequeUTXO{legacy.Address: testUTXOs()}}

	source, err := ResolveSweepSource(context.Background(), chain, wif, &chaincfg.SigNetParams)
	if err != nil {
		t.Fatalf("resolve source: %v", err)
	}
	if source.Kind != SweepAddressP2PKH {
		t.Errorf("expected p2pkh source, got %s", source.Kind)
	}
	if source.Address != legacy.Address {
		t.Errorf("expected address %s, got %s", legacy.Address, source.Address)
	}
	if source.TotalSats() != 100_000 {
		t.Errorf("expected 100000 sats, got %d", source.TotalSats())
	}
	if len(chain.queried) != 2 {
		t.Errorf("expected both kinds queried, got %v", chain.queried)
	}
}

func TestResolveSweepSourcePrefersWitnessWhenBothFunded(t *testing.T) {
	wif := newWIF(t, true)
	candidates, _ := SweepCandidates(wif, &chaincfg.SigNetParams)

	chain := &fakeChain{funded: map[string][]ChequeUTXO{
		candidates[0].Address: testUTXOs(),
		candidates[1].Address: testUTXOs(),
	}}

	source, err := ResolveSweepSource(context.Background(), chain, wif, &chaincfg.SigNetParams)
	if err != nil {
		t.Fatalf("resolve source: %v", err)
	}
	if source.Kind != SweepAddressP2WPKH {
		t.Errorf("expected p2wpkh source, got %s", source.Kind)
	}
}

func TestResolveSweepSourceEmptyKeyReportsFirstCandidate(t *testing.T) {
	wif := newWIF(t, true)
	candidates, _ := SweepCandidates(wif, &chaincfg.SigNetParams)

	chain := &fakeChain{funded: map[string][]ChequeUTXO{}}

	source, err := ResolveSweepSource(context.Background(), chain, wif, &chaincfg.SigNetParams)
	if err != nil {
		t.Fatalf("resolve source: %v", err)
	}
	if len(source.UTXOs) != 0 {
		t.Errorf("expected no utxos, got %d", len(source.UTXOs))
	}
	if source.Address != candidates[0].Address {
		t.Errorf("expected the p2wpkh address reported, got %s", source.Address)
	}
}

func TestResolveSweepSourceReturnsChainError(t *testing.T) {
	wif := newWIF(t, true)
	chain := &fakeChain{err: errors.New("electrum down")}

	if _, err := ResolveSweepSource(context.Background(), chain, wif, &chaincfg.SigNetParams); err == nil {
		t.Fatal("expected an error when the chain fails")
	}
}

func TestSweepVbytesChargesMoreForLegacyInputs(t *testing.T) {
	witness := SweepVbytes(SweepAddressP2WPKH, 1)
	legacy := SweepVbytes(SweepAddressP2PKH, 1)

	if witness != 110 {
		t.Errorf("expected 110 vbytes for one witness input, got %d", witness)
	}
	if legacy != 190 {
		t.Errorf("expected 190 vbytes for one legacy input, got %d", legacy)
	}
}

func TestBuildAndSignWitnessSweep(t *testing.T) {
	wif := newWIF(t, true)
	candidates, _ := SweepCandidates(wif, &chaincfg.SigNetParams)
	source := SweepSource{Address: candidates[0].Address, Kind: SweepAddressP2WPKH, UTXOs: testUTXOs()}

	tx, err := BuildSweepTx(source, destAddress, 10, &chaincfg.SigNetParams)
	if err != nil {
		t.Fatalf("build: %v", err)
	}

	// 100000 - (110 vbytes * 10 sat/vbyte)
	if tx.TxOut[0].Value != 98_900 {
		t.Errorf("expected 98900 sats out, got %d", tx.TxOut[0].Value)
	}

	signed, err := SignSweepTx(tx, source, wif, &chaincfg.SigNetParams)
	if err != nil {
		t.Fatalf("sign: %v", err)
	}
	if len(signed.TxIn[0].Witness) == 0 {
		t.Error("expected a witness on the signed input")
	}
	if len(signed.TxIn[0].SignatureScript) != 0 {
		t.Error("expected no signature script on a witness input")
	}
	assertInputVerifies(t, signed, source, 100_000)
}

func TestBuildAndSignLegacySweep(t *testing.T) {
	wif := newWIF(t, false)
	candidates, _ := SweepCandidates(wif, &chaincfg.SigNetParams)
	source := SweepSource{Address: candidates[0].Address, Kind: SweepAddressP2PKH, UTXOs: testUTXOs()}

	tx, err := BuildSweepTx(source, destAddress, 10, &chaincfg.SigNetParams)
	if err != nil {
		t.Fatalf("build: %v", err)
	}

	// 100000 - (190 vbytes * 10 sat/vbyte)
	if tx.TxOut[0].Value != 98_100 {
		t.Errorf("expected 98100 sats out, got %d", tx.TxOut[0].Value)
	}

	signed, err := SignSweepTx(tx, source, wif, &chaincfg.SigNetParams)
	if err != nil {
		t.Fatalf("sign: %v", err)
	}
	if len(signed.TxIn[0].SignatureScript) == 0 {
		t.Error("expected a signature script on the signed input")
	}
	if len(signed.TxIn[0].Witness) != 0 {
		t.Error("expected no witness on a legacy input")
	}
	assertInputVerifies(t, signed, source, 100_000)
}

func TestBuildSweepTxRejectsFeeAboveBalance(t *testing.T) {
	wif := newWIF(t, true)
	candidates, _ := SweepCandidates(wif, &chaincfg.SigNetParams)
	source := SweepSource{Address: candidates[0].Address, Kind: SweepAddressP2WPKH, UTXOs: testUTXOs()}

	if _, err := BuildSweepTx(source, destAddress, 10_000, &chaincfg.SigNetParams); err == nil {
		t.Fatal("expected an error when the fee exceeds the balance")
	}
}

func TestBuildSweepTxRejectsForeignNetworkAddress(t *testing.T) {
	wif := newWIF(t, true)
	candidates, _ := SweepCandidates(wif, &chaincfg.SigNetParams)
	source := SweepSource{Address: candidates[0].Address, Kind: SweepAddressP2WPKH, UTXOs: testUTXOs()}

	mainnet := "bc1qar0srrr7xfkvy5l643lydnw9re59gtzzwf5mdq"
	if _, err := BuildSweepTx(source, mainnet, 10, &chaincfg.SigNetParams); err == nil {
		t.Fatal("expected an error for a mainnet destination on signet")
	}
}

// assertInputVerifies runs the script engine over input 0, which is the real
// proof that the signature and its script kind match the source address.
func assertInputVerifies(t *testing.T, tx *wire.MsgTx, source SweepSource, valueSats int64) {
	t.Helper()

	sourceAddr, err := btcutil.DecodeAddress(source.Address, &chaincfg.SigNetParams)
	if err != nil {
		t.Fatalf("decode source: %v", err)
	}
	pkScript, err := txscript.PayToAddrScript(sourceAddr)
	if err != nil {
		t.Fatalf("source script: %v", err)
	}

	vm, err := txscript.NewEngine(
		pkScript, tx, 0,
		txscript.StandardVerifyFlags,
		nil, nil, valueSats,
		txscript.NewCannedPrevOutputFetcher(pkScript, valueSats),
	)
	if err != nil {
		t.Fatalf("new engine: %v", err)
	}
	if err := vm.Execute(); err != nil {
		t.Fatalf("script did not verify: %v", err)
	}
}
