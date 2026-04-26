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
}

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

	f, err := os.Open(tmp)
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
