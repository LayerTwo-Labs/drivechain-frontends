package orchestrator

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"sync"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
)

// ecashStampFile names the eCash network a sidechain datadir holds state for.
const ecashStampFile = ".ecash-network"

// ecashUnstampedKey parks state from before the stamp existed, whose eCash
// network nothing records.
const ecashUnstampedKey = "ecash-unstamped"

// ecashAlignMu serializes the moves, because two starts of one stopped sidechain
// both run before either registers a process.
var ecashAlignMu sync.Mutex

// ecashSidechainStateNames are the entries one eCash network owns in a
// sidechain datadir. The wallet goes too: its coins belong to that chain, and
// the starter mnemonic rebuilds its keys on any network.
var ecashSidechainStateNames = append(append([]string{}, config.SidechainChainDataNames...), "wallet.mdb")

// alignECashSidechainState gives a sidechain the state of the eCash network it
// starts on. Every eCash network shares one flat datadir, so after a switch the
// daemon would open the previous network's database. State of another network
// is parked under that network, never deleted, and comes back on a switch back.
func (o *Orchestrator) alignECashSidechainState(cfg BinaryConfig) error {
	if cfg.ChainLayer != 2 || config.Network(o.CurrentNetwork()) != config.NetworkECash {
		return nil
	}
	// A running daemon holds its database open.
	if o.process != nil && o.process.IsRunning(cfg.Name) {
		return nil
	}
	o.mu.RLock()
	id := o.ecashID
	o.mu.RUnlock()
	if id == "" {
		return nil
	}
	dc, ok := config.DirConfigByName(cfg.Name)
	if !ok {
		return nil
	}
	bitcoinOverride := ""
	if o.BitcoinConf != nil {
		bitcoinOverride = o.BitcoinConf.DetectedDataDir
	}
	ecashAlignMu.Lock()
	defer ecashAlignMu.Unlock()
	return alignECashState(dc.DatadirNetwork(config.NetworkECash, bitcoinOverride), id)
}

// alignECashState parks the state dir holds for another eCash network, stamps
// dir with id, and brings back what id parked. The stamp goes before the
// restore, so a start after a restore that stopped halfway finishes it instead
// of parking the part it already restored under the wrong network.
func alignECashState(dir, id string) error {
	stampPath := filepath.Join(dir, ecashStampFile)
	raw, err := os.ReadFile(stampPath)
	if err != nil && !errors.Is(err, os.ErrNotExist) {
		return fmt.Errorf("read %s: %w", stampPath, err)
	}
	if stamped := strings.TrimSpace(string(raw)); stamped != id {
		outgoingKey := ecashUnstampedKey
		if stamped != "" {
			outgoingKey = "ecash-" + stamped
		}
		for _, name := range ecashSidechainStateNames {
			path := filepath.Join(dir, name)
			switch _, err := os.Stat(path); {
			case errors.Is(err, os.ErrNotExist):
				continue
			case err != nil:
				return fmt.Errorf("read %s before parking it: %w", path, err)
			}
			parked, err := freeParkedPath(path, outgoingKey)
			if err != nil {
				return err
			}
			if err := os.Rename(path, parked); err != nil {
				return fmt.Errorf("park %s under %s: %w", path, outgoingKey, err)
			}
		}
		if err := os.MkdirAll(dir, 0o755); err != nil {
			return fmt.Errorf("create %s: %w", dir, err)
		}
		if err := os.WriteFile(stampPath, []byte(id+"\n"), 0o644); err != nil {
			return fmt.Errorf("stamp %s with %s: %w", dir, id, err)
		}
	}

	// A live path is the newer state, so a parked copy under it stays parked.
	for _, name := range ecashSidechainStateNames {
		path := filepath.Join(dir, name)
		switch _, err := os.Stat(path); {
		case err == nil:
			continue
		case !errors.Is(err, os.ErrNotExist):
			return fmt.Errorf("read %s before restoring it: %w", path, err)
		}
		incoming, ok := latestParkedPath(path, "ecash-"+id)
		if !ok {
			continue
		}
		if err := os.Rename(incoming, path); err != nil {
			return fmt.Errorf("restore %s from %s: %w", path, incoming, err)
		}
	}
	return nil
}
