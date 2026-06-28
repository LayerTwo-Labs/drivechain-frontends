package orchestrator

import (
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"runtime"
	"sync"
)

// orchestratorSettingsFile is the JSON file persisted in the bitwindow data
// directory. It is intentionally tiny and only stores user-tunable runtime
// preferences that the orchestrator owns (currently: Core variant selection).
const orchestratorSettingsFile = "orchestrator_settings.json"

// OrchestratorSettings is the on-disk shape of orchestrator_settings.json.
type OrchestratorSettings struct {
	CoreVariant       string `json:"core_variant"`
	UseTestSidechains bool   `json:"use_test_sidechains"`
	// ElectrumServerURL overrides the network's default Esplora endpoint for
	// electrum wallets. Empty means "use the network default".
	ElectrumServerURL string `json:"electrum_server_url"`
	// TorEnabled routes the electrum wallet's chain connections through TorProxy
	// when true. Default false means direct connection.
	TorEnabled bool `json:"tor_enabled"`
	// TorProxy is the SOCKS5 proxy address (host:port) used when TorEnabled.
	TorProxy string `json:"tor_proxy"`
}

// DefaultTorProxy is the SOCKS5 address of a standard local Tor daemon. Tor
// Browser exposes the same proxy on 127.0.0.1:9150.
const DefaultTorProxy = "127.0.0.1:9050"

func defaultOrchestratorSettings() OrchestratorSettings {
	return OrchestratorSettings{CoreVariant: DefaultCoreVariantID}
}

// SettingsPath returns the path to orchestrator_settings.json.
func SettingsPath(bitwindowDir string) string {
	return filepath.Join(bitwindowDir, orchestratorSettingsFile)
}

// LoadSettings reads orchestrator_settings.json, returning defaults if absent.
func LoadSettings(bitwindowDir string) (OrchestratorSettings, error) {
	path := SettingsPath(bitwindowDir)
	data, err := os.ReadFile(path)
	if err != nil {
		if errors.Is(err, os.ErrNotExist) {
			return defaultOrchestratorSettings(), nil
		}
		return OrchestratorSettings{}, fmt.Errorf("read orchestrator settings: %w", err)
	}

	s := defaultOrchestratorSettings()
	if err := json.Unmarshal(data, &s); err != nil {
		return OrchestratorSettings{}, fmt.Errorf("parse orchestrator settings: %w", err)
	}
	if s.CoreVariant == "" {
		s.CoreVariant = DefaultCoreVariantID
	}
	return s, nil
}

// SaveSettings writes orchestrator_settings.json atomically. Bytes hit disk
// before the rename and the parent directory is fsync'd on POSIX so a crash
// can't leave the file half-written or replace a valid file with a tmp that
// isn't yet durable.
func SaveSettings(bitwindowDir string, s OrchestratorSettings) error {
	if err := os.MkdirAll(bitwindowDir, 0o755); err != nil {
		return fmt.Errorf("mkdir bitwindow dir: %w", err)
	}
	path := SettingsPath(bitwindowDir)
	data, err := json.MarshalIndent(s, "", "  ")
	if err != nil {
		return fmt.Errorf("marshal orchestrator settings: %w", err)
	}

	tmp := path + ".tmp"
	if err := os.WriteFile(tmp, data, 0o644); err != nil {
		return fmt.Errorf("write orchestrator settings: %w", err)
	}
	cleanup := true
	defer func() {
		if cleanup {
			_ = os.Remove(tmp)
		}
	}()

	// O_RDWR (not O_RDONLY): Windows' FlushFileBuffers requires GENERIC_WRITE
	// on the handle, so a read-only reopen makes f.Sync() fail with EACCES.
	f, err := os.OpenFile(tmp, os.O_RDWR, 0)
	if err != nil {
		return fmt.Errorf("reopen orchestrator settings tmp: %w", err)
	}
	syncErr := f.Sync()
	closeErr := f.Close()
	if syncErr != nil {
		return fmt.Errorf("fsync orchestrator settings tmp: %w", syncErr)
	}
	if closeErr != nil {
		return fmt.Errorf("close orchestrator settings tmp: %w", closeErr)
	}

	if err := os.Rename(tmp, path); err != nil {
		return fmt.Errorf("rename orchestrator settings: %w", err)
	}
	cleanup = false

	if runtime.GOOS != "windows" {
		dir, err := os.Open(bitwindowDir)
		if err != nil {
			return fmt.Errorf("open bitwindow dir for fsync: %w", err)
		}
		syncErr := dir.Sync()
		closeErr := dir.Close()
		if syncErr != nil {
			return fmt.Errorf("fsync bitwindow dir: %w", syncErr)
		}
		if closeErr != nil {
			return fmt.Errorf("close bitwindow dir: %w", closeErr)
		}
	}
	return nil
}

// SettingsStore is a thread-safe in-memory cache around orchestrator_settings.json.
type SettingsStore struct {
	mu           sync.RWMutex
	bitwindowDir string
	current      OrchestratorSettings
}

// NewSettingsStore loads (or initialises) the on-disk settings.
func NewSettingsStore(bitwindowDir string) (*SettingsStore, error) {
	s, err := LoadSettings(bitwindowDir)
	if err != nil {
		return nil, err
	}
	return &SettingsStore{bitwindowDir: bitwindowDir, current: s}, nil
}

func (s *SettingsStore) Get() OrchestratorSettings {
	s.mu.RLock()
	defer s.mu.RUnlock()
	return s.current
}

func (s *SettingsStore) CoreVariant() string {
	return s.Get().CoreVariant
}

// SetCoreVariant persists a new variant ID and returns the previous value.
func (s *SettingsStore) SetCoreVariant(id string) (string, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	prev := s.current.CoreVariant
	if prev == id {
		return prev, nil
	}
	next := s.current
	next.CoreVariant = id
	if err := SaveSettings(s.bitwindowDir, next); err != nil {
		return prev, err
	}
	s.current = next
	return prev, nil
}

// ElectrumServerURL returns the user's Esplora endpoint override, or "" when
// the network default should be used.
func (s *SettingsStore) ElectrumServerURL() string {
	return s.Get().ElectrumServerURL
}

// SetElectrumServerURL persists a new Esplora endpoint override and returns the
// previous value. An empty url clears the override.
func (s *SettingsStore) SetElectrumServerURL(url string) (string, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	prev := s.current.ElectrumServerURL
	if prev == url {
		return prev, nil
	}
	next := s.current
	next.ElectrumServerURL = url
	if err := SaveSettings(s.bitwindowDir, next); err != nil {
		return prev, err
	}
	s.current = next
	return prev, nil
}

// TorConfig returns the persisted Tor routing preference: whether it is enabled
// and the SOCKS5 proxy address to use.
func (s *SettingsStore) TorConfig() (bool, string) {
	g := s.Get()
	return g.TorEnabled, g.TorProxy
}

// SetTorConfig persists the Tor routing preference and returns the previous
// values, so a failed apply can be rolled back.
func (s *SettingsStore) SetTorConfig(enabled bool, proxy string) (bool, string, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	prevEnabled, prevProxy := s.current.TorEnabled, s.current.TorProxy
	if prevEnabled == enabled && prevProxy == proxy {
		return prevEnabled, prevProxy, nil
	}
	next := s.current
	next.TorEnabled = enabled
	next.TorProxy = proxy
	if err := SaveSettings(s.bitwindowDir, next); err != nil {
		return prevEnabled, prevProxy, err
	}
	s.current = next
	return prevEnabled, prevProxy, nil
}

func (s *SettingsStore) UseTestSidechains() bool {
	return s.Get().UseTestSidechains
}

// SetUseTestSidechains persists the new value and returns the previous one.
func (s *SettingsStore) SetUseTestSidechains(v bool) (bool, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	prev := s.current.UseTestSidechains
	if prev == v {
		return prev, nil
	}
	next := s.current
	next.UseTestSidechains = v
	if err := SaveSettings(s.bitwindowDir, next); err != nil {
		return prev, err
	}
	s.current = next
	return prev, nil
}
