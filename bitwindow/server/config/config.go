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
	NetworkMainnet Network = "main"
	NetworkRegtest Network = "regtest"
	NetworkSignet  Network = "signet"
	NetworkTestnet Network = "test"
)

type Config struct {
	BitcoinCoreHost        string  `long:"bitcoincore.host" description:"host:port for connecting to Bitcoin Core" default:"localhost:38332"`
	BitcoinCoreCookie      string  `long:"bitcoincore.cookie" description:"Path to Bitcoin Core cookie file" `
	BitcoinCoreRpcUser     string  `long:"bitcoincore.rpcuser" default:"user"`
	BitcoinCoreRpcPassword string  `long:"bitcoincore.rpcpassword" default:"password"`
	BitcoinCoreNetwork     Network `long:"bitcoincore.network" description:"Bitcoin network" choice:"main" choice:"regtest" choice:"signet" choice:"testnet"`

	EnforcerHost string `long:"enforcer.host" description:"host:port for connecting to the enforcer server" default:"localhost:50051"`

	APIHost string `long:"api.host" env:"API_HOST" description:"public address for the connect server" default:"localhost:2122"`
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

	// If network is not explicitly set, try to derive it from the bitcoincore.host port
	if conf.BitcoinCoreNetwork == "" {
		derivedNetwork, err := deriveNetworkFromHost(conf.BitcoinCoreHost)
		if err != nil {
			// network was not set, nor could we derive it, tell the user
			// to add a valid configuration!
			return Config{}, err
		}
		conf.BitcoinCoreNetwork = derivedNetwork
	}

	if conf.Datadir == "" {
		datadir, err := dir.DefaultDataDir()
		if err != nil {
			return Config{}, fmt.Errorf("get data directory: %w", err)
		}
		conf.Datadir = datadir
	}

	// Append network subdirectory for non-mainnet networks
	if conf.BitcoinCoreNetwork != NetworkMainnet {
		conf.Datadir = filepath.Join(conf.Datadir, string(conf.BitcoinCoreNetwork))
	}

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

// deriveNetworkFromHost attempts to derive the network from the Bitcoin Core host's port
func deriveNetworkFromHost(host string) (Network, error) {
	// Extract port from host:port string
	parts := strings.Split(host, ":")
	if len(parts) != 2 {
		return "", fmt.Errorf("could not derive network from bitcoincore.host %q: please specify --network flag", host)
	}

	port := parts[1]
	switch port {
	case "8332":
		return NetworkMainnet, nil
	case "18332":
		return NetworkTestnet, nil
	case "38332":
		return NetworkSignet, nil
	case "18443":
		return NetworkRegtest, nil
	default:
		return "", fmt.Errorf("could not derive network from bitcoincore.host port %q: please specify --network flag", port)
	}
}
