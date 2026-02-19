package config

import (
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"

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

type Config struct {
	Version bool `long:"version" short:"v" description:"Print version information and exit"`

	BitcoinCoreURL         string  `long:"bitcoincore.url" description:"URL for connecting to Bitcoin Core - derived from network if not set"`
	BitcoinCoreCookie      string  `long:"bitcoincore.cookie" description:"Path to Bitcoin Core cookie file"`
	BitcoinCoreRpcUser     string  `long:"bitcoincore.rpcuser" default:"user"`
	BitcoinCoreRpcPassword string  `long:"bitcoincore.rpcpassword" default:"password"`
	BitcoinCoreNetwork     Network `long:"bitcoincore.network" description:"Bitcoin network - derived from URL if not set" choice:"mainnet" choice:"forknet" choice:"regtest" choice:"signet" choice:"testnet"`

	EnforcerHost string `long:"enforcer.host" description:"host:port for connecting to the enforcer server" default:"localhost:50051"`

	APIHost string `long:"api.host" env:"API_HOST" description:"public address for the connect server" default:"localhost:30301"`
	Datadir string `long:"datadir" description:"Path to the data directory"`

	LogPath  string `long:"log.path" description:"Path to write logs to"`
	LogLevel string `long:"log.level" description:"Log level" default:"info" env:"LOG_LEVEL"`

	GuiBootedMainchain bool `long:"gui-booted-mainchain" description:"Set to true if GUI booted this process. Used by this application to shutdown everything correctly."`
	GuiBootedEnforcer  bool `long:"gui-booted-enforcer" description:"Set to true if GUI booted this process. Used by this application to shutdown everything correctly."`

	SyncToHeight uint32 `long:"sync-to-height" description:"Sync to this height and then exit"`
}

func Parse() (Config, error) {
	var conf Config
	parser := flags.NewParser(&conf, flags.AllowBoolValues|flags.Default)

	if _, err := parser.Parse(); err != nil {
		return Config{}, err
	}

	if conf.BitcoinCoreCookie == "" && (conf.BitcoinCoreRpcPassword == "" || conf.BitcoinCoreRpcUser == "") {
		return Config{}, errors.New("no Bitcoin Core auth provided")
	}

	if conf.BitcoinCoreCookie != "" {
		cookie, err := os.ReadFile(conf.BitcoinCoreCookie)
		if err != nil {
			return Config{}, fmt.Errorf("read cookie file %q: %w", conf.BitcoinCoreCookie, err)
		}

		user, password, ok := strings.Cut(string(cookie), ":")
		if !ok || user == "" || password == "" {
			return Config{}, fmt.Errorf("unexpected cookie format: %s", string(cookie))
		}

		conf.BitcoinCoreRpcUser = user
		conf.BitcoinCoreRpcPassword = password
	}

	// Handle network/URL derivation
	switch {
	case conf.BitcoinCoreNetwork != "" && conf.BitcoinCoreURL != "":
		// Both set - use as provided
	case conf.BitcoinCoreNetwork != "" && conf.BitcoinCoreURL == "":
		// Network set, derive URL
		conf.BitcoinCoreURL = deriveURLFromNetwork(conf.BitcoinCoreNetwork)
		if conf.BitcoinCoreURL == "" {
			return Config{}, fmt.Errorf("could not derive URL from network %q", conf.BitcoinCoreNetwork)
		}
	case conf.BitcoinCoreNetwork == "" && conf.BitcoinCoreURL != "":
		// URL set, derive network
		conf.BitcoinCoreNetwork = deriveNetworkFromURL(conf.BitcoinCoreURL)
		if conf.BitcoinCoreNetwork == "" {
			return Config{}, fmt.Errorf("could not derive network from URL %q: please specify --bitcoincore.network flag", conf.BitcoinCoreURL)
		}
	default:
		// Neither set
		return Config{}, errors.New("either --bitcoincore.network or --bitcoincore.url must be specified")
	}

	if conf.Datadir == "" {
		datadir, err := dir.DefaultDataDir()
		if err != nil {
			return Config{}, fmt.Errorf("get data directory: %w", err)
		}
		conf.Datadir = datadir
	}

	// Append network subdirectory
	conf.Datadir = filepath.Join(conf.Datadir, string(conf.BitcoinCoreNetwork))

	if conf.LogPath == "" {
		conf.LogPath = filepath.Join(conf.Datadir, "server.log")
	}

	// Ensure the data directory exists
	err := os.MkdirAll(conf.Datadir, 0755)
	if err != nil && !os.IsExist(err) {
		return Config{}, fmt.Errorf("create data directory: %w", err)
	}

	return conf, nil
}

func deriveURLFromNetwork(network Network) string {
	switch network {
	case NetworkMainnet:
		return "http://localhost:8332"
	case NetworkForknet:
		return "http://localhost:18301"
	case NetworkTestnet:
		return "http://localhost:18332"
	case NetworkSignet:
		return "http://localhost:38332"
	case NetworkRegtest:
		return "http://localhost:18443"
	}
	return ""
}

func deriveNetworkFromURL(url string) Network {
	switch {
	case strings.Contains(url, ":8332"):
		return NetworkMainnet
	case strings.Contains(url, ":18301"):
		return NetworkForknet
	case strings.Contains(url, ":18332"):
		return NetworkTestnet
	case strings.Contains(url, ":38332"):
		return NetworkSignet
	case strings.Contains(url, ":18443"):
		return NetworkRegtest
	}
	return ""
}

// IsDemoMode returns true when running on mainnet, enabling demo mode
// with simulated sidechain data instead of requiring an enforcer connection.
func (c *Config) IsDemoMode() bool {
	return c.BitcoinCoreNetwork == NetworkMainnet
}
