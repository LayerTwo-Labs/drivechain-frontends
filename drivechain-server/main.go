package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"path/filepath"
	"runtime"
	"time"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/drivechain-server/bdk"
	"github.com/LayerTwo-Labs/sidesail/drivechain-server/dial"
	"github.com/LayerTwo-Labs/sidesail/drivechain-server/server"
	pb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	coreproxy "github.com/barebitcoin/btc-buf/server"
	"github.com/jessevdk/go-flags"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
)

func main() {
	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt)
	defer cancel()

	logger := zerolog.
		New(zerolog.NewConsoleWriter()).
		Level(zerolog.TraceLevel)

	zerolog.DefaultContextLogger = &logger

	if err := realMain(ctx); err != nil {
		cancel()

		// Error has been printed to the console!
		if _, ok := lo.ErrorsAs[*flags.Error](err); ok {
			os.Exit(1)
		}

		zerolog.Ctx(ctx).
			Fatal().
			Err(err).
			Msgf("main: got error: %T", err)
	}
}

func realMain(ctx context.Context) error {
	conf, err := readConfig()
	if err != nil {
		return err
	}

	proxy, err := startCoreProxy(ctx, conf)
	if err != nil {
		return err
	}

	info, err := proxy.GetBlockchainInfo(ctx, connect.NewRequest(&pb.GetBlockchainInfoRequest{}))
	if err != nil {
		return err
	}

	enforcer, err := dial.BIPEnforcer(ctx, conf.EnforcerHost)
	if err != nil {
		return fmt.Errorf("connect to enforcer: %w", err)
	}

	zerolog.Ctx(ctx).Info().Msgf("blockchain info: %s", info.Msg.String())

	electrumProtocol := "ssl"
	if conf.ElectrumNoSSL {
		electrumProtocol = "tcp"
	}

	datadir, err := getDataDir()
	if err != nil {
		return err
	}

	// This is all wonky stuff. We're on some kind of botched regtest...
	// However, the address format is mainnet - and that's the only thing
	// that matters.
	const network = "bitcoin" // means mainnet!
	wallet, err := bdk.NewWallet(
		ctx, datadir, network,
		fmt.Sprintf("%s://%s", electrumProtocol, conf.ElectrumHost),
		conf.Passphrase, conf.XPrivOverride,
	)
	if err != nil {
		return err
	}

	// Verify the wallet is wired together correctly
	if err := wallet.Sync(ctx); err != nil {
		return fmt.Errorf("initial wallet sync: %w", err)
	}

	zerolog.Ctx(ctx).Debug().
		Msgf("initiating electrum connection at %s", wallet.Electrum)

	srv, err := server.New(ctx, proxy, wallet, enforcer)
	if err != nil {
		return err
	}
	const address = "localhost:8080"

	zerolog.Ctx(ctx).Info().Msgf("server: listening on %s", address)

	errs := make(chan error)
	go func() {
		errs <- srv.Serve(ctx, address)
	}()
	go func() {
		<-ctx.Done()

		ctx, cancel := context.WithTimeout(context.WithoutCancel(ctx), time.Second*1)
		defer cancel()

		srv.Shutdown(ctx)

		errs <- nil
	}()

	return <-errs
}

func startCoreProxy(ctx context.Context, conf Config) (*coreproxy.Bitcoind, error) {
	core, err := coreproxy.NewBitcoind(
		ctx, conf.BitcoinCoreHost,
		conf.BitcoinCoreRpcUser, conf.BitcoinCoreRpcPassword,
	)
	if err != nil {
		return nil, err
	}

	return core, nil
}

func getDataDir() (string, error) {
	const appName = "bdk-cli"
	var dir string

	switch runtime.GOOS {
	case "linux":
	case "darwin":
		if xdgDataHome := os.Getenv("XDG_DATA_HOME"); xdgDataHome != "" {
			dir = filepath.Join(xdgDataHome, appName)
		} else {
			home, err := os.UserHomeDir()
			if err != nil {
				return "", err
			}
			if runtime.GOOS == "darwin" {
				dir = filepath.Join(home, "Library", "Application Support", appName)
			} else {
				dir = filepath.Join(home, ".local", "share", appName)
			}
		}
	case "windows":
		appData, ok := os.LookupEnv("APPDATA")
		if !ok {
			return "", fmt.Errorf("APPDATA environment variable not set")
		}
		dir = filepath.Join(appData, appName)
	default:
		return "", fmt.Errorf("unsupported OS: %s", runtime.GOOS)
	}

	// Ensure the directory exists
	err := os.MkdirAll(dir, 0755)
	if err != nil && !os.IsExist(err) {
		return "", err
	}

	return dir, nil
}
