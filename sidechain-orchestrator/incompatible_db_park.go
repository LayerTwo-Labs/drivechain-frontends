package orchestrator

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"sync"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
)

// incompatibleDBRefusal is the startup error truthcoin-dc gives for a
// database that an older release wrote. It names the version and the path.
var incompatibleDBRefusal = regexp.MustCompile("Incompatible DB version \\(([^)]+)\\)\\. Please clear the DB \\(`([^`]+)`\\) and re-sync")

// parksIncompatibleDB names the daemons whose refused database the orchestrator parks.
var parksIncompatibleDB = map[string]bool{"truthcoin": true}

// parkIncompatibleDB moves aside the database that a refusal in exitErr names,
// so the next start builds a new one. It reports false when exitErr holds no
// refusal, or names a path outside datadir, or a path in parked.
func parkIncompatibleDB(datadir string, exitErr error, parked map[string]bool) (string, bool, error) {
	match := incompatibleDBRefusal.FindStringSubmatch(exitErr.Error())
	if match == nil {
		return "", false, nil
	}
	version, dbPath := match[1], filepath.Clean(match[2])
	if parked[dbPath] || !sameDir(filepath.Dir(dbPath), filepath.Clean(datadir)) {
		return "", false, nil
	}
	switch name := filepath.Base(dbPath); name {
	case "data.mdb", sidechainWalletFile:
	default:
		return "", false, nil
	}
	if _, err := os.Stat(dbPath); err != nil {
		if errors.Is(err, os.ErrNotExist) {
			return "", false, nil
		}
		return "", false, fmt.Errorf("read %s before parking it: %w", dbPath, err)
	}
	target, err := freeParkedPath(dbPath, "version-"+version)
	if err != nil {
		return "", false, err
	}
	if err := os.Rename(dbPath, target); err != nil {
		return "", false, fmt.Errorf("park %s: %w", dbPath, err)
	}
	parked[dbPath] = true
	return target, true, nil
}

// maxRefusedDBRestarts caps the starts after a park: one per database.
const maxRefusedDBRestarts = 4

// refusesOldDB reports whether exitErr is a refusal the orchestrator parks for cfg.
func refusesOldDB(cfg BinaryConfig, exitErr error) bool {
	return parksIncompatibleDB[cfg.Name] && incompatibleDBRefusal.MatchString(exitErr.Error())
}

// refusedDBMu serializes the parks, because each start that waits on one
// refused process sees the same exit error.
var refusedDBMu sync.Mutex

// handledRefusals holds the exited processes whose refused database is parked.
var handledRefusals = map[*ManagedProcess]bool{}

// parkRefusedDB parks the database that cfg refused at start, and logs the
// move. It reports true when the caller must start cfg again: after its own
// park, or when another start already parked for this exit.
func (o *Orchestrator) parkRefusedDB(cfg BinaryConfig, exitErr error, parked map[string]bool) (bool, error) {
	if !refusesOldDB(cfg, exitErr) {
		return false, nil
	}
	dc, ok := config.DirConfigByName(cfg.Name)
	if !ok {
		return false, nil
	}

	refusedDBMu.Lock()
	defer refusedDBMu.Unlock()
	run := o.process.LatestRun(cfg.Name)
	if run != nil && (handledRefusals[run] || !run.Exited()) {
		return true, nil
	}
	datadir := dc.DatadirNetwork(config.Network(o.CurrentNetwork()), "")
	target, ok, err := parkIncompatibleDB(datadir, exitErr, parked)
	if err != nil || !ok {
		return false, err
	}
	if run != nil {
		handledRefusals[run] = true
	}
	o.log.Info().Str("binary", cfg.Name).Str("parked", target).Msg("parked a database an older release wrote, starting again")
	return true, nil
}

// Exited reports whether the process is gone.
func (p *ManagedProcess) Exited() bool {
	select {
	case <-p.exitCh:
		return true
	default:
		return false
	}
}
