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
	BitcoinCoreCookie      string `long:"bitcoincore.cookie" description:"Path to Bitcoin Core cookie file" `
	BitcoinCoreRpcUser     string `long:"bitcoincore.rpcuser" default:"user"`
	BitcoinCoreRpcPassword string `long:"bitcoincore.rpcpassword" default:"password"`

	EnforcerHost string `long:"enforcer.host" description:"host:port for connecting to the enforcer server" default:"localhost:50051"`

	APIHost string `long:"api.host" env:"API_HOST" description:"public address for the connect server" default:"localhost:8080"`

	LogPath string `long:"log.path" description:"Path to write logs to"`

	GuiBootedMainchain bool `long:"gui-booted-mainchain" description:"Set to true if GUI booted this process. Used by this application to shutdown everything correctly."`
	GuiBootedEnforcer  bool `long:"gui-booted-enforcer" description:"Set to true if GUI booted this process. Used by this application to shutdown everything correctly."`
}

func readConfig() (Config, error) {
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

	return conf, nil
}
