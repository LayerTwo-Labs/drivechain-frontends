package orchestrator

// Core wallet management — ported from bitwindow/server/engines/wallet_engine.go.
// Creates Bitcoin Core wallets via JSON-RPC with proper BIP84 descriptor import.

import (
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"strings"

	"github.com/tyler-smith/go-bip32"
	"golang.org/x/crypto/ripemd160" //nolint:staticcheck // needed for Hash160
)

// CreateWallet creates a new wallet in Bitcoin Core.
func (c *CoreStatusClient) CreateWallet(ctx context.Context, walletName string, disablePrivateKeys, blank, descriptors bool) error {
	_, err := c.call(ctx, "createwallet",
		walletName,
		disablePrivateKeys,
		blank,
		"",    // passphrase
		false, // avoid_reuse
		descriptors,
		false, // load_on_startup
	)
	return err
}

// LoadWallet loads an existing wallet in Bitcoin Core.
func (c *CoreStatusClient) LoadWallet(ctx context.Context, walletName string) error {
	_, err := c.call(ctx, "loadwallet", walletName)
	return err
}

// UnloadWallet unloads a wallet from Bitcoin Core.
func (c *CoreStatusClient) UnloadWallet(ctx context.Context, walletName string) error {
	_, err := c.call(ctx, "unloadwallet", walletName)
	return err
}

// ListWallets returns the list of currently loaded wallets.
func (c *CoreStatusClient) ListWallets(ctx context.Context) ([]string, error) {
	result, err := c.call(ctx, "listwallets")
	if err != nil {
		return nil, err
	}
	var wallets []string
	if err := json.Unmarshal(result, &wallets); err != nil {
		return nil, fmt.Errorf("decode listwallets: %w", err)
	}
	return wallets, nil
}

// ImportDescriptorsRPC imports descriptors into a specific wallet using the /wallet/<name> endpoint.
func (c *CoreStatusClient) ImportDescriptorsRPC(ctx context.Context, walletName string, descriptors []map[string]interface{}) (json.RawMessage, error) {
	origURL := c.url
	c.url = fmt.Sprintf("%s/wallet/%s", origURL, walletName)
	defer func() { c.url = origURL }()

	return c.call(ctx, "importdescriptors", descriptors)
}

// hash160 computes RIPEMD160(SHA256(data)) — standard Bitcoin Hash160.
func hash160(data []byte) []byte {
	sha := sha256.Sum256(data)
	ripe := ripemd160.New()
	ripe.Write(sha[:])
	return ripe.Sum(nil)
}

// CreateBitcoinCoreWalletFromSeed creates a Bitcoin Core descriptor wallet and imports
// BIP84 (wpkh) descriptors derived from the seed.
// Ported from bitwindow/server/engines/wallet_engine.go CreateBitcoinCoreWalletFromSeed.
func (c *CoreStatusClient) CreateBitcoinCoreWalletFromSeed(ctx context.Context, walletName, seedHex, network string) error {
	seed, err := hex.DecodeString(seedHex)
	if err != nil {
		return fmt.Errorf("decode seed hex: %w", err)
	}

	// Derive master key
	masterKey, err := bip32.NewMasterKey(seed)
	if err != nil {
		return fmt.Errorf("derive master key: %w", err)
	}

	// Compute master fingerprint: Hash160(compressed pubkey)[:4]
	fingerprint := hex.EncodeToString(hash160(masterKey.PublicKey().Key)[:4])

	// Coin type: 0' for mainnet, 1' for testnet/signet/regtest
	coinType := uint32(1)
	if network == "mainnet" {
		coinType = 0
	}

	// Derive BIP84 account key: m/84'/<coin>'/0'
	purpose, err := masterKey.NewChildKey(bip32.FirstHardenedChild + 84)
	if err != nil {
		return fmt.Errorf("derive purpose: %w", err)
	}
	coin, err := purpose.NewChildKey(bip32.FirstHardenedChild + coinType)
	if err != nil {
		return fmt.Errorf("derive coin: %w", err)
	}
	account, err := coin.NewChildKey(bip32.FirstHardenedChild + 0)
	if err != nil {
		return fmt.Errorf("derive account: %w", err)
	}

	// Serialize xprv with correct network version bytes.
	// go-bip32 always uses mainnet (xprv/xpub 0488ade4/0488b21e).
	// For testnet/signet/regtest, Core expects tprv/tpub (04358394/043587cf).
	accountXprv := account.String()
	if network != "mainnet" {
		// Override version bytes for testnet/signet/regtest
		account.Version = []byte{0x04, 0x35, 0x83, 0x94} // tprv
		accountXprv = account.String()
	}

	// Create blank descriptor wallet in Bitcoin Core
	err = c.CreateWallet(ctx, walletName, false, true, true)
	if err != nil {
		// If wallet already exists, try to load it
		if strings.Contains(err.Error(), "Database already exists") || strings.Contains(err.Error(), "already exists") {
			if loadErr := c.LoadWallet(ctx, walletName); loadErr != nil {
				return fmt.Errorf("load existing wallet %s: %w", walletName, loadErr)
			}
		} else {
			return fmt.Errorf("create wallet %s: %w", walletName, err)
		}
	}

	// Build descriptors with key origin info: wpkh([fingerprint/84'/coin'/0']xprv/0/*)
	type descriptorDef struct {
		desc     string
		internal bool
	}

	descs := []descriptorDef{
		{fmt.Sprintf("wpkh([%s/84'/%d'/0']%s/0/*)", fingerprint, coinType, accountXprv), false}, // receiving
		{fmt.Sprintf("wpkh([%s/84'/%d'/0']%s/1/*)", fingerprint, coinType, accountXprv), true},  // change
	}

	var importRequests []map[string]interface{}
	for _, d := range descs {
		descWithChecksum, err := AddDescriptorChecksum(d.desc)
		if err != nil {
			return fmt.Errorf("compute descriptor checksum: %w", err)
		}

		importRequests = append(importRequests, map[string]interface{}{
			"desc":      descWithChecksum,
			"active":    true,
			"internal":  d.internal,
			"timestamp": "now",
			"range":     []int{0, 999},
		})
	}

	// Import descriptors
	result, err := c.ImportDescriptorsRPC(ctx, walletName, importRequests)
	if err != nil {
		return fmt.Errorf("importdescriptors: %w", err)
	}

	// Verify results
	var results []struct {
		Success bool `json:"success"`
		Error   *struct {
			Code    int    `json:"code"`
			Message string `json:"message"`
		} `json:"error"`
	}
	if err := json.Unmarshal(result, &results); err != nil {
		return fmt.Errorf("decode importdescriptors response: %w", err)
	}

	for i, r := range results {
		if !r.Success {
			errMsg := "unknown error"
			if r.Error != nil {
				errMsg = r.Error.Message
			}
			return fmt.Errorf("descriptor %d import failed: %s", i, errMsg)
		}
	}

	return nil
}

// CreateWatchOnlyWalletInCore creates a watch-only wallet in Bitcoin Core from a descriptor or xpub.
func (c *CoreStatusClient) CreateWatchOnlyWalletInCore(ctx context.Context, walletName, descriptorOrXpub string) error {
	// Create watch-only descriptor wallet (private keys disabled)
	err := c.CreateWallet(ctx, walletName, true, true, true)
	if err != nil {
		if strings.Contains(err.Error(), "Database already exists") || strings.Contains(err.Error(), "already exists") {
			if loadErr := c.LoadWallet(ctx, walletName); loadErr != nil {
				return fmt.Errorf("load existing wallet %s: %w", walletName, loadErr)
			}
		} else {
			return fmt.Errorf("create wallet %s: %w", walletName, err)
		}
	}

	isDescriptor := strings.Contains(descriptorOrXpub, "(") && strings.Contains(descriptorOrXpub, ")")

	var importRequests []map[string]interface{}

	if isDescriptor {
		// Raw descriptor — import as-is
		desc := descriptorOrXpub
		if !strings.Contains(desc, "#") {
			desc, _ = AddDescriptorChecksum(desc)
		}
		importRequests = append(importRequests, map[string]interface{}{
			"desc":      desc,
			"active":    true,
			"internal":  false,
			"timestamp": "now",
			"range":     []int{0, 999},
		})
	} else {
		// xpub — create wpkh descriptors for receiving and change
		receiveDesc := fmt.Sprintf("wpkh(%s/0/*)", descriptorOrXpub)
		changeDesc := fmt.Sprintf("wpkh(%s/1/*)", descriptorOrXpub)

		receiveWithChecksum, _ := AddDescriptorChecksum(receiveDesc)
		changeWithChecksum, _ := AddDescriptorChecksum(changeDesc)

		importRequests = append(importRequests,
			map[string]interface{}{
				"desc":      receiveWithChecksum,
				"active":    true,
				"internal":  false,
				"timestamp": "now",
				"range":     []int{0, 999},
			},
			map[string]interface{}{
				"desc":      changeWithChecksum,
				"active":    true,
				"internal":  true,
				"timestamp": "now",
				"range":     []int{0, 999},
			},
		)
	}

	result, err := c.ImportDescriptorsRPC(ctx, walletName, importRequests)
	if err != nil {
		return fmt.Errorf("importdescriptors: %w", err)
	}

	var results []struct {
		Success bool `json:"success"`
		Error   *struct {
			Code    int    `json:"code"`
			Message string `json:"message"`
		} `json:"error"`
	}
	if err := json.Unmarshal(result, &results); err != nil {
		return fmt.Errorf("decode importdescriptors response: %w", err)
	}

	for i, r := range results {
		if !r.Success {
			errMsg := "unknown error"
			if r.Error != nil {
				errMsg = r.Error.Message
			}
			return fmt.Errorf("descriptor %d import failed: %s", i, errMsg)
		}
	}

	return nil
}
