package config

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"

	dir "github.com/LayerTwo-Labs/sidesail/bitwindow/server/dir"
	"github.com/jessevdk/go-flags"
)

type Network string

const (
	NetworkMainnet Network = "mainnet"
	NetworkForknet Network = "forknet"
	NetworkRegtest Network = "regtest"
	NetworkSignet  Network = "signet"
	NetworkTestnet Network = "testnet"
)

// Config holds bitwindowd's runtime configuration. Network identity is
// **not** declared here as a CLI flag — bitwindowd sources it from
// orchestratord at startup via [Finalize] so it is always aligned with
// orchestrator's view of the world. bitcoind RPC creds aren't needed
// either: bitwindowd dials orchestratord's hosted BitcoinService for any
// bitcoind call.
type Config struct {
	Version bool `long:"version" short:"v" description:"Print version information and exit"`

	EnforcerHost     string `long:"enforcer.host" description:"host:port for connecting to the enforcer server" default:"localhost:50051"`
	OrchestratorAddr string `long:"orchestrator.addr" description:"URL for connecting to the orchestrator daemon" default:"http://localhost:30400"`

	APIHost string `long:"api.host" env:"API_HOST" description:"public address for the connect server" default:"localhost:30301"`
	Datadir string `long:"datadir" description:"Path to the data directory"`

	LogPath  string `long:"log.path" description:"Path to write logs to"`
	LogLevel string `long:"log.level" description:"Log level" default:"info" env:"LOG_LEVEL"`

	GuiBootedMainchain bool `long:"gui-booted-mainchain" description:"Set to true if GUI booted this process. Used by this application to shutdown everything correctly."`
	GuiBootedEnforcer  bool `long:"gui-booted-enforcer" description:"Set to true if GUI booted this process. Used by this application to shutdown everything correctly."`

	SyncToHeight uint32 `long:"sync-to-height" description:"Sync to this height and then exit"`

	// BitcoinCoreNetwork is set by Finalize from orchestratord — never from
	// CLI flags. Used downstream for Datadir scoping and chain-params lookup.
	BitcoinCoreNetwork Network `no-flag:"true"`

	// baseDatadir / baseLogPath capture the un-finalized values on the
	// first Finalize so subsequent calls (network swap via Recycle) can
	// recompute network-scoped paths from the original base instead of
	// stacking another suffix (".../signet/forknet/forknet/...").
	baseDatadir string `no-flag:"true"`
	baseLogPath string `no-flag:"true"`
}

func Parse() (Config, error) {
	var conf Config
	parser := flags.NewParser(&conf, flags.AllowBoolValues|flags.Default)

	if _, err := parser.Parse(); err != nil {
		return Config{}, err
	}

	if conf.Datadir == "" {
		datadir, err := dir.DefaultDataDir()
		if err != nil {
			return Config{}, fmt.Errorf("get data directory: %w", err)
		}
		conf.Datadir = datadir
	}

	return conf, nil
}

// BitwindowDir returns the parent dir before the per-network suffix is
// appended in Finalize. wallet.json lives here.
func (c *Config) BitwindowDir() string {
	return c.Datadir
}

// Finalize sets the network (sourced from orchestratord by the caller) and
// appends the per-network suffix to Datadir. Idempotent — re-running on
// network swap recomputes paths from the original base, so suffixes don't
// stack across swaps.
func (c *Config) Finalize(network Network) error {
	if network == "" {
		return errors.New("Finalize: empty network — caller must source it from orchestratord")
	}

	// First call snapshots the un-suffixed base for future swaps.
	if c.baseDatadir == "" {
		c.baseDatadir = c.Datadir
		c.baseLogPath = c.LogPath
	}

	c.BitcoinCoreNetwork = network
	c.Datadir = filepath.Join(c.baseDatadir, string(network))

	if c.baseLogPath == "" {
		c.LogPath = filepath.Join(c.Datadir, "server.log")
	} else {
		c.LogPath = c.baseLogPath
	}

	if err := os.MkdirAll(c.Datadir, 0755); err != nil && !os.IsExist(err) {
		return fmt.Errorf("create data directory: %w", err)
	}

	return nil
}

// IsDemoMode returns true when running on mainnet, enabling demo mode
// with simulated sidechain data instead of requiring an enforcer connection.
func (c *Config) IsDemoMode() bool {
	return c.BitcoinCoreNetwork == NetworkMainnet
}

// IsFullChainNetwork reports whether the network has full mainnet-scale
// block volume (mainnet / forknet). Callers gate IBD-only RPC throttling
// on this — signet / testnet / regtest blocks are small or empty so
// running scans through their IBD doesn't move the needle on Core load.
func IsFullChainNetwork(n Network) bool {
	return n == NetworkMainnet || n == NetworkForknet
}
