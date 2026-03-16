package wallet

import (
	"encoding/json"
	"time"
)

// WalletFile is the top-level structure stored in wallet.json.
type WalletFile struct {
	Version        int          `json:"version"`
	ActiveWalletID string       `json:"activeWalletId"`
	Wallets        []WalletData `json:"wallets"`
}

// WalletData contains all information for a single wallet.
type WalletData struct {
	Version    int               `json:"version"`
	Master     MasterWallet      `json:"master"`
	L1         L1Wallet          `json:"l1"`
	Sidechains []SidechainWallet `json:"sidechains"`
	ID         string            `json:"id"`
	Name       string            `json:"name"`
	Gradient   json.RawMessage   `json:"gradient"`
	CreatedAt  time.Time         `json:"-"`
	WalletType string            `json:"wallet_type"`
	WatchOnly  json.RawMessage   `json:"watch_only,omitempty"`
}

// Custom JSON marshal/unmarshal for WalletData to handle time format
func (w WalletData) MarshalJSON() ([]byte, error) {
	type Alias WalletData
	return json.Marshal(&struct {
		Alias
		CreatedAt string `json:"created_at"`
	}{
		Alias:     Alias(w),
		CreatedAt: w.CreatedAt.Format(time.RFC3339Nano),
	})
}

func (w *WalletData) UnmarshalJSON(data []byte) error {
	type Alias WalletData
	aux := &struct {
		*Alias
		CreatedAt string `json:"created_at"`
	}{
		Alias: (*Alias)(w),
	}
	if err := json.Unmarshal(data, aux); err != nil {
		return err
	}
	// Dart's DateTime.now().toIso8601String() produces formats like:
	// "2026-03-12T07:53:06.465089" (6 fractional digits, no timezone)
	// "2026-03-12T07:53:06.465" (3 fractional digits)
	// Try multiple formats to handle all cases
	var t time.Time
	var err error
	for _, layout := range []string{
		time.RFC3339Nano,
		"2006-01-02T15:04:05.000000", // Dart microseconds (6 digits)
		"2006-01-02T15:04:05.000",    // milliseconds (3 digits)
		"2006-01-02T15:04:05",        // no fractional
	} {
		t, err = time.Parse(layout, aux.CreatedAt)
		if err == nil {
			break
		}
	}
	w.CreatedAt = t
	return nil
}

// MasterWallet contains the root seed and derived keys.
type MasterWallet struct {
	Mnemonic         string `json:"mnemonic"`
	SeedHex          string `json:"seed_hex"`
	MasterKey        string `json:"master_key"`
	ChainCode        string `json:"chain_code"`
	BIP39Binary      string `json:"bip39_binary,omitempty"`
	BIP39Checksum    string `json:"bip39_checksum,omitempty"`
	BIP39ChecksumHex string `json:"bip39_checksum_hex,omitempty"`
	Name             string `json:"name"`
}

// L1Wallet is the Layer 1 (Bitcoin Core) wallet.
type L1Wallet struct {
	Mnemonic string `json:"mnemonic"`
	Name     string `json:"name"`
}

// SidechainWallet is a sidechain-specific wallet.
type SidechainWallet struct {
	Slot     int    `json:"slot"`
	Name     string `json:"name"`
	Mnemonic string `json:"mnemonic"`
}

// SidechainSlot describes a sidechain for wallet generation.
type SidechainSlot struct {
	Slot int
	Name string
}

// WalletMetadata is a lightweight view of a wallet for listing.
type WalletMetadata struct {
	ID         string
	Name       string
	WalletType string
	Gradient   json.RawMessage
	CreatedAt  time.Time
}
