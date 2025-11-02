package api_wallet

import (
	"encoding/hex"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
)

func TestBuildAndSignChequeSweepTx(t *testing.T) {
	// Generate a test private key and WIF
	privKey, err := btcec.NewPrivateKey()
	if err != nil {
		t.Fatalf("Failed to generate private key: %v", err)
	}

	wif, err := btcutil.NewWIF(privKey, &chaincfg.SigNetParams, true)
	if err != nil {
		t.Fatalf("Failed to create WIF: %v", err)
	}

	testWIF := wif.String()
	t.Logf("Test WIF: %s", testWIF)

	// Get the corresponding address
	pubKeyHash := btcutil.Hash160(privKey.PubKey().SerializeCompressed())
	sourceAddress, err := btcutil.NewAddressWitnessPubKeyHash(pubKeyHash, &chaincfg.SigNetParams)
	if err != nil {
		t.Fatalf("Failed to create source address: %v", err)
	}
	t.Logf("Source address: %s", sourceAddress.EncodeAddress())

	// Sample destination address (signet)
	destAddress := "tb1q6rz28mcfaxtmd6v789l9rrlrusdprr9pqcpvkl"

	// Sample UTXO
	testUTXOs := []*corepb.UnspentOutput{
		{
			Txid:   "4a5e1e4baab89f3a32518a88c31bc87f618f76673e2cc77ab2127b7afdeda33b",
			Vout:   0,
			Amount: 0.001, // 100,000 sats
		},
	}

	// Create a mock server with minimal dependencies for testing transaction building
	chequeEngine := engines.NewChequeEngine(&chaincfg.SigNetParams, nil)
	server := &Server{
		chequeEngine: chequeEngine,
	}

	// Build, sign, and serialize transaction
	feeSatPerVbyte := uint64(10)

	unsignedTx, err := server.buildSweepTx(destAddress, testUTXOs, feeSatPerVbyte)
	if err != nil {
		t.Fatalf("build transaction: %v", err)
	}

	signedTx, err := server.signSweepTx(unsignedTx, testWIF, sourceAddress.EncodeAddress(), testUTXOs)
	if err != nil {
		t.Fatalf("sign transaction: %v", err)
	}

	txHex, err := server.serializeTx(signedTx)
	if err != nil {
		t.Fatalf("serialize transaction: %v", err)
	}

	// Verify it's valid hex
	txBytes, err := hex.DecodeString(txHex)
	if err != nil {
		t.Fatalf("Invalid transaction hex: %v", err)
	}

	t.Logf("Successfully built transaction hex (%d bytes): %s", len(txBytes), txHex)

	// Calculate txid
	txid := signedTx.TxHash().String()
	t.Logf("Transaction ID: %s", txid)

	// Verify the transaction structure
	if len(signedTx.TxIn) != 1 {
		t.Errorf("Expected 1 input, got %d", len(signedTx.TxIn))
	}
	if len(signedTx.TxOut) != 1 {
		t.Errorf("Expected 1 output, got %d", len(signedTx.TxOut))
	}

	// Calculate expected amount (100000 - (110 vbytes * 10 sat/vbyte) = 98900 sats)
	expectedSats := int64(98900)
	if signedTx.TxOut[0].Value != expectedSats {
		t.Errorf("Expected output value %d, got %d", expectedSats, signedTx.TxOut[0].Value)
	}
}
