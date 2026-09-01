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
	CoreVariant string `json:"core_variant"`
	// ECashNetworkID pins the eCash network the user picked from the catalog
	// ("alphanet"). Empty means "whichever one the catalog lists first", which
	// is what a fresh install and every non-eCash network use.
	ECashNetworkID string `json:"ecash_network_id"`
	// ECashChainID is the eCash network whose blocks this install holds. The
	// pick above is the user's choice; this is the record of what runs, and it
	// outlives the conf sentinel, which a swap to another network strips.
	ECashChainID string `json:"ecash_chain_id,omitempty"`
	// SeenNetworkIDs are the catalog ids this install already told the user
	// about. TakeNewNetworks reports the rest once, then adds them here.
	SeenNetworkIDs []string `json:"seen_network_ids"`
	// RewoundBlockHash is the block an eCash switch dropped. Core bars that
	// branch for good, so a move back to the network it dropped must clear the
	// mark first.
	RewoundBlockHash string `json:"rewound_block_hash"`
	// PendingEnforcerWipe is the eCash network whose enforcer validator chain a
	// switch left behind. The enforcer keeps one chain per network, not per
	// fork, so it has to go before the enforcer runs on the new one.
	PendingEnforcerWipe string `json:"pending_enforcer_wipe,omitempty"`
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

// ECashNetworkID returns the eCash network the user picked, empty when they
// picked none.
func (s *SettingsStore) ECashNetworkID() string {
	return s.Get().ECashNetworkID
}

// SetECashNetworkID persists the picked eCash network and returns the previous
// value.
func (s *SettingsStore) SetECashNetworkID(id string) (string, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	prev := s.current.ECashNetworkID
	if prev == id {
		return prev, nil
	}
	next := s.current
	next.ECashNetworkID = id
	if err := SaveSettings(s.bitwindowDir, next); err != nil {
		return prev, err
	}
	s.current = next
	return prev, nil
}

// ECashChainID returns the eCash network whose blocks this install holds,
// empty when it holds none.
func (s *SettingsStore) ECashChainID() string {
	return s.Get().ECashChainID
}

// SetECashChainID persists the eCash network this install runs.
func (s *SettingsStore) SetECashChainID(id string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.current.ECashChainID == id {
		return nil
	}
	next := s.current
	next.ECashChainID = id
	if err := SaveSettings(s.bitwindowDir, next); err != nil {
		return err
	}
	s.current = next
	return nil
}

// SeenNetworkIDs returns the catalog ids this install already told the user
// about, nil when it told them none yet.
func (s *SettingsStore) SeenNetworkIDs() []string {
	return s.Get().SeenNetworkIDs
}

// SetSeenNetworkIDs persists the catalog ids this install told the user about.
func (s *SettingsStore) SetSeenNetworkIDs(ids []string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	next := s.current
	next.SeenNetworkIDs = ids
	if err := SaveSettings(s.bitwindowDir, next); err != nil {
		return err
	}
	s.current = next
	return nil
}

// PendingEnforcerWipe returns the network whose enforcer chain still has to go,
// empty when none does.
func (s *SettingsStore) PendingEnforcerWipe() string {
	return s.Get().PendingEnforcerWipe
}

// SetPendingEnforcerWipe persists enforcer cleanup a switch could not finish.
// An empty id clears it.
func (s *SettingsStore) SetPendingEnforcerWipe(id string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if s.current.PendingEnforcerWipe == id {
		return nil
	}
	next := s.current
	next.PendingEnforcerWipe = id
	if err := SaveSettings(s.bitwindowDir, next); err != nil {
		return err
	}
	s.current = next
	return nil
}

// RewoundBlockHash returns the block an eCash switch dropped, empty when none.
func (s *SettingsStore) RewoundBlockHash() string {
	return s.Get().RewoundBlockHash
}

// SetRewoundBlockHash persists the block an eCash switch dropped. A rollback
// uses it to put the previous mark back, so it leaves any drop still waiting
// alone — that work outlives the switch that failed.
func (s *SettingsStore) SetRewoundBlockHash(hash string) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	next := s.current
	next.RewoundBlockHash = hash
	if err := SaveSettings(s.bitwindowDir, next); err != nil {
		return err
	}
	s.current = next
	return nil
}

// CommitRewind records the block a drop is about to bar, so a later switch can
// lift it. It runs before the bar: a bar no record names can never be lifted.
func (s *SettingsStore) CommitRewind(hash string) error {
	return s.SetRewoundBlockHash(hash)
}
