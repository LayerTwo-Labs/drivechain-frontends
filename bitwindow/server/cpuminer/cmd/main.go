/*
 * Copyright 2010 Jeff Garzik
 * Copyright 2012-2017 pooler
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2 of the License, or (at your option)
 * any later version.  See COPYING for more details.
 */

package main

import (
	"context"
	"errors"
	"flag"
	"fmt"
	"os"
	"os/signal"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/cpuminer"
	"github.com/rs/zerolog"
)

var (
	scanTime     = flag.Duration("scantime", time.Minute, "upper bound on time spent scanning current work (seconds)")
	routines     = flag.Int("routines", 1, "number of miner goroutines to run")
	rpcURL       = flag.String("url", "", "URL of mining server")
	rpcUser      = flag.String("user", "", "username for mining server")
	rpcPass      = flag.String("pass", "", "password for mining server")
	coinbaseSig  = flag.String("coinbase-sig", "", "data to insert in the coinbase when possible")
	coinbaseAddr = flag.String("coinbase-addr", "", "payout address")
)

func main() {
	flag.Parse()

	zerolog.TimeFieldFormat = time.RFC3339Nano
	log := zerolog.
		New(zerolog.NewConsoleWriter(func(w *zerolog.ConsoleWriter) {
			w.TimeFormat = time.DateTime + ".000"
		})).
		With().Caller().Timestamp().Logger()

	zerolog.DefaultContextLogger = &log

	if err := realMain(); err != nil {
		log.Fatal().Err(err).Msg("failed to run miner")
		os.Exit(1)
	}
}

func realMain() error {
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	if *rpcURL == "" {
		return errors.New("no URL supplied")
	}

	errs := make(chan error)

	signals := make(chan os.Signal, 1)
	signal.Notify(signals, os.Interrupt)

	go func() {
		sig := <-signals
		errs <- fmt.Errorf("received signal: %s", sig)
	}()

	miner, err := cpuminer.New(cpuminer.Config{
		Routines:          *routines,
		ScanTime:          *scanTime,
		RpcURL:            *rpcURL,
		RpcUser:           *rpcUser,
		RpcPass:           *rpcPass,
		CoinbaseAddress:   *coinbaseAddr,
		CoinbaseSignature: *coinbaseSig,
	})
	if err != nil {
		return fmt.Errorf("create miner: %w", err)
	}

	go func() {
		errs <- miner.Start(ctx)
	}()

	start := time.Now()
	statsTimer := time.NewTicker(time.Second * 3)

	log := zerolog.Ctx(ctx)

	defer statsTimer.Stop()
	go func() {
		for range statsTimer.C {
			totalHashes := miner.GetHashes()
			log.Info().
				Msgf("total hashes: %d, %s",
					totalHashes, formatHashrate(totalHashes, time.Since(start)),
				)
		}
	}()

	log.Info().Msgf("started %d miner routines", *routines)

	if err := <-errs; err != nil {
		return err
	}

	log.Info().Msg("miner stopped")
	return nil
}

func formatHashrate(hashesDone uint64, elapsed time.Duration) string {
	hashrate := float64(hashesDone) / elapsed.Seconds()

	if hashrate >= 1e6 {
		return fmt.Sprintf("%.0f MH/s", hashrate/1e6)
	}
	return fmt.Sprintf("%.2f kH/s", hashrate/1e3)
}
