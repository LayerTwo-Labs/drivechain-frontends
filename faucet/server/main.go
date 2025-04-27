package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"time"

	"github.com/LayerTwo-Labs/sidesail/faucet/server/api/explorer"
	"github.com/LayerTwo-Labs/sidesail/faucet/server/jsonrpc"
	"github.com/LayerTwo-Labs/sidesail/faucet/server/server"
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

	// Thunder currently does not support auth, so leave empty.
	var thunderUsername, thunderPassword string
	thunderClient := jsonrpc.NewClient(
		conf.ThunderAddress,
		thunderUsername,
		thunderPassword,
	)

	var bitassetsUsername, bitassetsPassword string
	bitassetsClient := jsonrpc.NewClient(
		conf.BitAssetsAddress,
		bitassetsUsername,
		bitassetsPassword,
	)

	var bitnamesUsername, bitnamesPassword string
	bitnamesClient := jsonrpc.NewClient(
		conf.BitNamesAddress,
		bitnamesUsername,
		bitnamesPassword,
	)

	proxy, err := coreproxy.NewBitcoind(
		ctx, conf.BitcoinCoreAddress,
		conf.BitcoinCoreRPCUser, conf.BitcoinCoreRPCPassword,
	)
	if err != nil {
		return fmt.Errorf("start core proxy: %w", err)
	}

	srv := server.New(ctx, proxy, &explorer.RpcClients{
		Thunder:   thunderClient,
		BitAssets: bitassetsClient,
		BitNames:  bitnamesClient,
	})

	zerolog.Ctx(ctx).Info().Msgf("server: listening on %q", conf.Listen)

	errs := make(chan error)
	go func() {
		errs <- srv.Serve(ctx, conf.Listen)
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

type Options struct {
	RPCUser     string `short:"u" long:"user" description:"RPC user" required:"true" env:"RPC_USER" default:"user"`
	RPCPassword string `short:"p" long:"password" description:"RPC passwore" required:"true" env:"RPC_PASSWORD" default:"password"`
	RPCHost     string `short:"h" long:"host" description:"RPC url:port" required:"true" env:"RPC_URL" default:"localhost:8332"`
}
