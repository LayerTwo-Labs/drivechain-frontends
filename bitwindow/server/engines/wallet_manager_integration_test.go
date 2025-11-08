package engines

import (
	"context"
	"encoding/hex"
	"fmt"
	"os"
	"testing"

	"connectrpc.com/connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	coreproxy "github.com/barebitcoin/btc-buf/server"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
)

// Test seed for reproducible testing (DO NOT USE IN PRODUCTION)
const testSeedHex = "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f"

// TestDescriptorImportIntegration tests descriptor import against a real Bitcoin Core instance
// This test requires:
// - Bitcoin Core running on localhost:38332 (signet by default)
// - RPC credentials: user=user, pass=password
// - Or set BITCOIND_URL environment variable
//
// Run with: go test -v -run TestDescriptorImportIntegration
func TestDescriptorImportIntegration(t *testing.T) {
	// Skip if not explicitly enabled
	if os.Getenv("INTEGRATION_TEST") == "" {
		t.Skip("Skipping integration test. Set INTEGRATION_TEST=1 to run")
	}

	// Setup logger
	logger := zerolog.New(os.Stdout).With().Timestamp().Logger()
	ctx := logger.WithContext(context.Background())

	// Get Bitcoin Core connection params from env or use defaults
	host := os.Getenv("BITCOIND_HOST")
	if host == "" {
		host = "localhost:38332"
	}
	rpcUser := os.Getenv("BITCOIND_USER")
	if rpcUser == "" {
		rpcUser = "user"
	}
	rpcPass := os.Getenv("BITCOIND_PASSWORD")
	if rpcPass == "" {
		rpcPass = "password"
	}

	t.Logf("Connecting to Bitcoin Core at %s", host)

	// Create Bitcoin Core client using coreproxy
	bitcoindClient, err := coreproxy.NewBitcoind(
		ctx,
		host,
		rpcUser,
		rpcPass,
	)
	if err != nil {
		t.Fatalf("create bitcoind client: %v", err)
	}

	// Test chain params (signet)
	chainParams := &chaincfg.SigNetParams

	// Decode test seed
	seed, err := hex.DecodeString(testSeedHex)
	if err != nil {
		t.Fatalf("decode seed: %v", err)
	}

	// Derive master key
	masterKey, err := hdkeychain.NewMaster(seed, chainParams)
	if err != nil {
		t.Fatalf("derive master key: %v", err)
	}

	// Derive to BIP84 account level: m/84'/1'/0' (1' for testnet/signet)
	purpose, err := masterKey.Derive(hdkeychain.HardenedKeyStart + 84)
	if err != nil {
		t.Fatalf("derive purpose: %v", err)
	}

	coin, err := purpose.Derive(hdkeychain.HardenedKeyStart + 1) // 1' for testnet/signet
	if err != nil {
		t.Fatalf("derive coin type: %v", err)
	}

	account, err := coin.Derive(hdkeychain.HardenedKeyStart + 0)
	if err != nil {
		t.Fatalf("derive account: %v", err)
	}

	accountXprv := account.String()
	t.Logf("Account xprv: %s", accountXprv)

	// Create a unique test wallet name
	testWalletName := fmt.Sprintf("test_wallet_%d", os.Getpid())
	t.Logf("Creating test wallet: %s", testWalletName)

	// Clean up any existing test wallet
	defer func() {
		t.Logf("Cleaning up test wallet: %s", testWalletName)
		_, err := bitcoindClient.UnloadWallet(ctx, connect.NewRequest(&corepb.UnloadWalletRequest{
			WalletName: testWalletName,
		}))
		if err != nil {
			t.Logf("Warning: failed to unload wallet: %v", err)
		}
	}()

	// Create blank descriptor wallet
	t.Log("Creating blank descriptor wallet in Bitcoin Core...")
	_, err = bitcoindClient.CreateWallet(ctx, connect.NewRequest(&corepb.CreateWalletRequest{
		Name:               testWalletName,
		DisablePrivateKeys: false,
		Blank:              true,
		Passphrase:         "",
		AvoidReuse:         false,
	}))
	if err != nil {
		t.Fatalf("create wallet: %v", err)
	}

	// Prepare descriptors
	descriptors := []struct {
		desc     string
		internal bool
		label    string
	}{
		{fmt.Sprintf("wpkh(%s/0/*)", accountXprv), false, "Receiving"},
		{fmt.Sprintf("wpkh(%s/1/*)", accountXprv), true, "Change"},
	}

	// Test the fixed descriptor import logic
	var requests []*corepb.ImportDescriptorsRequest_Request

	for _, d := range descriptors {
		t.Logf("\n=== Processing %s descriptor ===", d.label)
		t.Logf("Descriptor (without checksum): %s", d.desc)

		// Don't use GetDescriptorInfo - it strips private keys!
		// Compute checksum ourselves to keep private keys intact
		descriptorWithChecksum, err := AddDescriptorChecksum(d.desc)
		if err != nil {
			t.Fatalf("compute checksum: %v", err)
		}
		t.Logf("Descriptor (with checksum): %s", descriptorWithChecksum)

		// Use timestamp=nil for "now" to skip rescan (faster for empty wallet)
		requests = append(requests, &corepb.ImportDescriptorsRequest_Request{
			Descriptor_: descriptorWithChecksum,
			Active:      true,
			Timestamp:   nil, // nil = "now", skips rescan
			Internal:    d.internal,
			RangeStart:  1,    // Start from 1 (0 gets omitted by protobuf)
			RangeEnd:    1000, // Generate 1000 keys
		})
	}

	// Step 3: Import descriptors
	t.Log("\n=== Importing descriptors ===")
	resp, err := bitcoindClient.ImportDescriptors(ctx, connect.NewRequest(&corepb.ImportDescriptorsRequest{
		Wallet:   testWalletName,
		Requests: requests,
	}))
	if err != nil {
		t.Fatalf("import descriptors: %v", err)
	}

	// Check results
	for i, result := range resp.Msg.Responses {
		label := "Receiving"
		if i == 1 {
			label = "Change"
		}

		if !result.Success {
			errMsg := "unknown error"
			if result.Error != nil {
				errMsg = result.Error.Message
			}
			t.Fatalf("%s descriptor import failed: %s", label, errMsg)
		}

		if len(result.Warnings) > 0 {
			t.Logf("%s descriptor warnings: %v", label, result.Warnings)
		}

		t.Logf("%s descriptor imported successfully!", label)
	}

	// Step 4: Fill the keypool (required after importing private key descriptors)
	t.Log("\n=== Filling keypool ===")
	_, err = bitcoindClient.KeyPoolRefill(ctx, connect.NewRequest(&corepb.KeyPoolRefillRequest{
		Wallet:  testWalletName,
		NewSize: 1000,
	}))
	if err != nil {
		t.Logf("Warning: keypool refill failed: %v", err)
	}

	// Step 5: Verify we can generate addresses
	t.Log("\n=== Verifying address generation ===")
	addrResp, err := bitcoindClient.GetNewAddress(ctx, connect.NewRequest(&corepb.GetNewAddressRequest{
		Wallet: testWalletName,
		Label:  "", // Empty label for ranged descriptors
	}))
	if err != nil {
		t.Fatalf("generate address: %v", err)
	}

	t.Logf("Generated address: %s", addrResp.Msg.Address)

	// Get wallet info to verify descriptors are active
	t.Log("\n=== Getting wallet info ===")
	infoResp, err := bitcoindClient.GetWalletInfo(ctx, connect.NewRequest(&corepb.GetWalletInfoRequest{
		Wallet: testWalletName,
	}))
	if err != nil {
		t.Fatalf("get wallet info: %v", err)
	}

	t.Logf("Wallet info:")
	t.Logf("  Name: %s", infoResp.Msg.WalletName)
	t.Logf("  Tx count: %d", infoResp.Msg.TxCount)

	t.Log("\n=== Test passed! ===")
}
