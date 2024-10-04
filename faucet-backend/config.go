package main

import (
	"errors"
	"fmt"
	"os"
	"strings"

	"github.com/jessevdk/go-flags"
)

type Config struct {
	BitcoinCoreHost        string `long:"bitcoincore.host" description:"host:port for connecting to Bitcoin Core" default:"localhost:38332"`
	BitcoinCoreCookie      string `long:"bitcoincore.cookie" description:"Path to Bitcoin Core cookie file"`
	BitcoinCoreRPCUser     string `long:"bitcoincore.rpcuser" description:"Username for Bitcoin Core RPC" default:"user"`
	BitcoinCoreRPCPassword string `long:"bitcoincore.rpcpassword" description:"Password for Bitcoin Core RPC" default:"password"`

	EnforcerHost string `long:"enforcer.host" description:"host:port for connecting to the enforcer server" default:"localhost:50051"`

	APIHost string `long:"api.host" env:"API_HOST" description:"public address for the connect server" default:"localhost:8082"`
}

func readConfig() (Config, error) {
	var conf Config
	parser := flags.NewParser(&conf, flags.AllowBoolValues|flags.Default)

	if _, err := parser.Parse(); err != nil {
		return Config{}, err
	}

	if conf.BitcoinCoreCookie == "" && (conf.BitcoinCoreRPCPassword == "" || conf.BitcoinCoreRPCUser == "") {
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

		conf.BitcoinCoreRPCUser = user
		conf.BitcoinCoreRPCPassword = password

	}

	return conf, nil
}
