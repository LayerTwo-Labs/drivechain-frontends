package main

import (
	"context"
	"errors"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/jessevdk/go-flags"
	"github.com/rs/zerolog"
)

type config struct {
	Listen string `long:"listen" description:"interface:port for server" default:"localhost:5080"`

	JsonLog  bool           `long:"logging.json" description:"log to JSON format (default human readable)"`
	LogLevel string         `long:"logging.level" description:"log level" default:"debug"`
	Bitcoind bitcoindConfig `group:"bitcoind" namespace:"bitcoind"`
	SSH      sshConfig      `group:"ssh" namespace:"ssh"`
}

type sshConfig struct {
	Host       string   `long:"host" description:"host to connect to"`
	LocalPort  int      `long:"local-port" description:"local port to connect to"`
	RemotePort int      `long:"remote-port" description:"remote port to connect to"`
	KnownHosts []string `long:"known-hosts"`
	KeyFile    string   `long:"key-file" description:"path to SSH private key file"`
}

type bitcoindConfig struct {
	User     string `long:"user"`
	Pass     string `long:"pass"`
	PassFile string `long:"passfile" description:"if set, reads password from this file"`
	Host     string `long:"host" description:"host:port to connect to Bitcoin Core on. Inferred from network if not set."`
	Cookie   bool   `long:"cookie" description:"Read cookie data from the data directory. Not compatible with user and pass options. "`
	Network  string `long:"network" default:"regtest" description:"Network Bitcoin Core is running on. Only used to infer other parameters if not set."`
	Wallet   string `long:"wallet" description:"equivalent to -rpcwallet in bitcoin-cli"`
}

func readConfig(ctx context.Context) (*config, error) {
	var cfg config
	if _, err := flags.Parse(&cfg); err != nil {
		// help was requested, avoid print and non-zero exit code
		if flagErr := new(flags.Error); errors.As(
			err, &flagErr,
		) && flagErr.Type == flags.ErrHelp {
			os.Exit(0)
		}

		return nil, err
	}

	if err := configureLogging(&cfg); err != nil {
		return nil, err
	}

	if cfg.Bitcoind.Pass != "" && cfg.Bitcoind.PassFile != "" {
		return nil, errors.New("cannot set both pass and passfile")
	}

	if cfg.Bitcoind.PassFile != "" {
		pass, err := os.ReadFile(cfg.Bitcoind.PassFile)
		if err != nil {
			return nil, fmt.Errorf("read passfile: %w", err)
		}
		cfg.Bitcoind.Pass = strings.TrimSpace(string(pass))
	}

	log := zerolog.Ctx(ctx)
	if cfg.Bitcoind.Pass == "" && cfg.Bitcoind.User == "" {
		log.Debug().
			Msg("config: empty bitcoind.pass and bitcoind.user, defaulting to cookie")

		cfg.Bitcoind.Cookie = true
	}

	net, ok := nets[cfg.Bitcoind.Network]
	if !ok {
		return nil, fmt.Errorf("unknown bitcoin network: %q", cfg.Bitcoind.Network)
	}

	if cfg.Bitcoind.Cookie {
		log.Debug().
			Str("network", cfg.Bitcoind.Network).
			Msg("config: reading bitcoind cookie data")

		if cfg.Bitcoind.Pass != "" ||
			cfg.Bitcoind.User != "" {
			return nil, fmt.Errorf("cannot set username or password when specifying bitcoind.cookie")
		}

		path, err := cookiePath(net)
		if err != nil {
			return nil, fmt.Errorf("find cookie path: %w", err)
		}

		log.Debug().Str("path", path).
			Msg("config: found cookie path")

		cookie, err := os.ReadFile(path)
		if err != nil {
			return nil, fmt.Errorf("read cookie: %w", err)
		}

		user, pass, found := strings.Cut(string(cookie), ":")
		if !found {
			return nil, fmt.Errorf("parse cookie: %s", string(cookie))
		}

		cfg.Bitcoind.User = user
		cfg.Bitcoind.Pass = pass
	}

	if cfg.Bitcoind.Host == "" {
		log.Debug().Str("network", cfg.Bitcoind.Network).
			Msg("config: empty bitcoind.host, inferring from network")

		cfg.Bitcoind.Host = net.defaultRpcHost
	}

	if cfg.Bitcoind.Wallet != "" {
		cfg.Bitcoind.Host = fmt.Sprintf(
			"%s/wallet/%s",
			cfg.Bitcoind.Host, cfg.Bitcoind.Wallet,
		)
	}

	return &cfg, nil
}

func cookiePath(network bitcoinNet) (string, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return "", err
	}

	return filepath.Join(home, ".bitcoin", network.path, ".cookie"), nil
}

type bitcoinNet struct {
	path           string
	defaultRpcHost string
}

var (
	mainnet = bitcoinNet{
		path:           "",
		defaultRpcHost: "localhost:8332",
	}
	testnet = bitcoinNet{
		path:           "testnet3",
		defaultRpcHost: "localhost:18332",
	}
	regtest = bitcoinNet{
		path:           "regtest",
		defaultRpcHost: "localhost:18443",
	}
	signet = bitcoinNet{
		path:           "signet",
		defaultRpcHost: "localhost:38332",
	}
)

var nets = map[string]bitcoinNet{
	"mainnet":  mainnet,
	"testnet":  testnet,
	"testnet3": testnet,
	"regtest":  regtest,
	"signet":   signet,
}
