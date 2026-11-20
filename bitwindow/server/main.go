package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/jessevdk/go-flags"
	"github.com/rs/zerolog"
	"github.com/samber/lo"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/daemon"
)

func main() {
	start := time.Now()

	// SIGTERM too, so `systemctl stop` / `docker stop` drain the server and
	// relay Shutdown to drivechaind instead of orphaning it.
	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)

	if err := daemon.Run(ctx, os.Args[1:], daemon.Options{}); err != nil {

		// Error has been printed to the console!
		if _, ok := lo.ErrorsAs[*flags.Error](err); ok {
			cancel()
			os.Exit(1)
		}

		zerolog.Ctx(ctx).Error().Err(err).
			Msgf("main: finished with error after %s", time.Since(start))

		fmt.Fprintf(os.Stderr, "main: finished with error after %s: %s (%T)\n", time.Since(start), err, err)
		cancel()
		os.Exit(1)
	}
}
