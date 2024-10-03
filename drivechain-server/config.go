package main

import (
	"errors"
	"fmt"
	"os"
	"strings"

	"github.com/jessevdk/go-flags"
)

type Config struct {
	BitcoinCoreHost string `long:"bitcoincore.host" description:"host:port for connecting to Bitcoin Core" default:"localhost:38332"`

	BitcoinCoreCookie string `long:"bitcoincore.cookie" description:"Path to Bitcoin Core cookie file" `

	BitcoinCoreRpcUser     string `long:"bitcoincore.rpcuser"`
	BitcoinCoreRpcPassword string `long:"bitcoincore.rpcpassword"`

	ElectrumHost  string `long:"electrum.host" description:"host:port for connecting to Electrum server" default:"drivechain.live:50001"`
	ElectrumNoSSL bool   `long:"electrum.no-ssl" description:"Avoid using SSL for connecting to Electrum"`

	EnforcerHost string `long:"enforcer.host" description:"host:port for connecting to the enforcer server" default:"localhost:50051"`

	Passphrase      string `long:"passphrase" description:"Passphrase for encrypting/decrypting the wallet key"`
	XPrivOverride   string `long:"xpriv" description:"Override the wallet stored to disk with a custom xpriv'"`
	DescriptorPrint bool   `long:"descriptor.print" description:"Print the descriptor that bdk-cli creates. Useful for testing'"`
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
