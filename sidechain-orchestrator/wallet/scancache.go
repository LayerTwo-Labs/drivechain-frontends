package wallet

import (
	"encoding/json"
	"os"
	"path/filepath"
)

// persistedScanVersion guards the on-disk format; a mismatch is treated as no
// cache (the wallet re-scans live).
const persistedScanVersion = 1

// persistedAddr is one scanned chain address and the Esplora data fetched for
// it — the same EsploraAddressStats the live scan stored. Keys and scripts are
// re-derived from the seed on load, so only fetched data is persisted.
type persistedAddr struct {
	Change  bool                `json:"change"`
	Index   uint32              `json:"index"`
	Address string              `json:"address"`
	Stats   EsploraAddressStats `json:"stats"`
}

// persistedScan is a wallet's scan as written to disk, so a cold boot rebuilds
// it without re-querying Esplora.
type persistedScan struct {
	Version  int             `json:"version"`
	WalletID string          `json:"wallet_id"`
	Addrs    []persistedAddr `json:"addrs"`
}

func (s *Service) electrumCacheDir() string {
	return filepath.Join(s.bitwindowDir, "electrum-cache")
}

func (s *Service) electrumScanPath(walletID string) string {
	return filepath.Join(s.electrumCacheDir(), walletID+".json")
}

// loadElectrumScan reads a wallet's persisted scan; ok is false if absent or
// written by a different format version.
func (s *Service) loadElectrumScan(walletID string) (*persistedScan, bool) {
	data, err := os.ReadFile(s.electrumScanPath(walletID))
	if err != nil {
		return nil, false
	}
	var ps persistedScan
	if err := json.Unmarshal(data, &ps); err != nil || ps.Version != persistedScanVersion {
		return nil, false
	}
	return &ps, true
}

// saveElectrumScan writes a wallet's scan atomically (temp file + rename).
func (s *Service) saveElectrumScan(walletID string, data []byte) error {
	if err := os.MkdirAll(s.electrumCacheDir(), 0o700); err != nil {
		return err
	}
	path := s.electrumScanPath(walletID)
	tmp := path + ".tmp"
	if err := os.WriteFile(tmp, data, 0o600); err != nil {
		return err
	}
	return os.Rename(tmp, path)
}

// deleteElectrumScan removes a wallet's persisted scan.
func (s *Service) deleteElectrumScan(walletID string) {
	_ = os.Remove(s.electrumScanPath(walletID))
}
