package api_wallet

import (
	"encoding/hex"
	"fmt"
	"testing"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
)

// TestManualAddressDerivation shows the actual addresses that would be derived
// Run with: go test -v -run TestManualAddressDerivation
func TestManualAddressDerivation(t *testing.T) {
	seedHex := "0329e77e27d1e24336be53d25a897e92e67b5ec7e88eca7529b14e3ffd9168a247b6906469fb8a79ecb25ec077e033f6b567d5d9b0ae334f1e33457ae6bb1364"

	seed, err := hex.DecodeString(seedHex)
	if err != nil {
		t.Fatalf("decode seed: %v", err)
	}

	chainParams := &chaincfg.SigNetParams

	// Derive master key
	masterKey, err := hdkeychain.NewMaster(seed, chainParams)
	if err != nil {
		t.Fatalf("derive master: %v", err)
	}

	// BIP84 path: m/84'/1'/0'/0/{index}
	// coinType = 1 for signet/testnet
	purpose, err := masterKey.Derive(hdkeychain.HardenedKeyStart + 84)
	if err != nil {
		t.Fatalf("derive purpose: %v", err)
	}

	coin, err := purpose.Derive(hdkeychain.HardenedKeyStart + 1) // 1 for signet
	if err != nil {
		t.Fatalf("derive coin: %v", err)
	}

	account, err := coin.Derive(hdkeychain.HardenedKeyStart + 0)
	if err != nil {
		t.Fatalf("derive account: %v", err)
	}

	// External chain (receiving addresses)
	external, err := account.Derive(0)
	if err != nil {
		t.Fatalf("derive external: %v", err)
	}

	fmt.Println("\n=== First 10 Receiving Addresses (BIP84) ===")
	fmt.Println("Wallet: asd (80CEBA2163224572BDEADD2D2181C51B)")
	fmt.Println("Network: signet")
	fmt.Println("Path: m/84'/1'/0'/0/{index}")
	fmt.Println()

	for i := uint32(0); i < 10; i++ {
		addrKey, err := external.Derive(i)
		if err != nil {
			t.Fatalf("derive address %d: %v", i, err)
		}

		pubKey, err := addrKey.ECPubKey()
		if err != nil {
			t.Fatalf("get pubkey %d: %v", i, err)
		}

		pubKeyHash := btcutil.Hash160(pubKey.SerializeCompressed())
		witnessAddr, err := btcutil.NewAddressWitnessPubKeyHash(pubKeyHash, chainParams)
		if err != nil {
			t.Fatalf("create address %d: %v", i, err)
		}

		fmt.Printf("Index %2d: %s\n", i, witnessAddr.EncodeAddress())
	}

	fmt.Println("\n=== How to Test ===")
	fmt.Println("1. Send some bitcoin to address index 0")
	fmt.Println("2. Send some bitcoin to address index 2")
	fmt.Println("3. Call GetNewAddress - it should return index 1 (first unused)")
	fmt.Println("4. After using index 1, next call should return index 3")
	fmt.Println("\nThe function checks ListTransactions to see which addresses")
	fmt.Println("have been used, and returns the first one with no transactions.")
}

// TestDeriveMultipleWallets shows addresses for all your Bitcoin Core wallets
func TestDeriveMultipleWallets(t *testing.T) {
	wallets := []struct {
		name string
		id   string
		seed string
	}{
		{
			name: "Core Wallet",
			id:   "334FB42644954658AA47F7F4E5BF0AF1",
			seed: "b2f58eba88b61da68994fc4a965302cfd273a37d2b81fafcd598155819fc8ceeccd942c8a67e7812114fd5fef97edc349fc564890ba80a1d6d7121347e5f3e73",
		},
		{
			name: "asd",
			id:   "80CEBA2163224572BDEADD2D2181C51B",
			seed: "0329e77e27d1e24336be53d25a897e92e67b5ec7e88eca7529b14e3ffd9168a247b6906469fb8a79ecb25ec077e033f6b567d5d9b0ae334f1e33457ae6bb1364",
		},
	}

	chainParams := &chaincfg.SigNetParams

	for _, wallet := range wallets {
		fmt.Printf("\n=== Wallet: %s (%s) ===\n", wallet.name, wallet.id)

		seed, err := hex.DecodeString(wallet.seed)
		if err != nil {
			t.Errorf("decode seed for %s: %v", wallet.name, err)
			continue
		}

		masterKey, err := hdkeychain.NewMaster(seed, chainParams)
		if err != nil {
			t.Errorf("derive master for %s: %v", wallet.name, err)
			continue
		}

		purpose, _ := masterKey.Derive(hdkeychain.HardenedKeyStart + 84)
		coin, _ := purpose.Derive(hdkeychain.HardenedKeyStart + 1)
		account, _ := coin.Derive(hdkeychain.HardenedKeyStart + 0)
		external, _ := account.Derive(0)

		fmt.Println("First 5 addresses:")
		for i := uint32(0); i < 5; i++ {
			addrKey, _ := external.Derive(i)
			pubKey, _ := addrKey.ECPubKey()
			pubKeyHash := btcutil.Hash160(pubKey.SerializeCompressed())
			witnessAddr, _ := btcutil.NewAddressWitnessPubKeyHash(pubKeyHash, chainParams)
			fmt.Printf("  [%d] %s\n", i, witnessAddr.EncodeAddress())
		}
	}
}
