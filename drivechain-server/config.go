package main

import (
	"errors"
	"fmt"
	"os"
	"strings"

	"github.com/jessevdk/go-flags"
)

type Config struct {
	BitcoinCoreHost string `long:"bitcoincore.host" description:"host:port for connecting to Bitcoin Core" default:"localhost:18332"`

	BitcoinCoreCookie string `long:"bitcoincore.cookie" description:"Path to Bitcoin Core cookie file" `

	BitcoinCoreRpcUser     string `long:"bitcoincore.rpcuser"`
	BitcoinCoreRpcPassword string `long:"bitcoincore.rpcpassword"`

	ElectrumHost  string `long:"electrum.host" description:"host:port for connecting to Electrum server" default:"electrum.blockstream.info:60002"`
	ElectrumNoSSL bool   `long:"electrum.no-ssl" description:"Avoid using SSL for connecting to Electrum"`
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
