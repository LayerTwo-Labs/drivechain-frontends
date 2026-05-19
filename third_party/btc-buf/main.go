package main

import (
	"bufio"
	"context"
	"fmt"
	"net"
	"os"
	"os/exec"
	"os/signal"
	"runtime/debug"
	"time"

	"github.com/rs/zerolog"

	"github.com/barebitcoin/btc-buf/server"
)

func realMain(cfg *config) error {
	ctx, cancel := context.WithCancelCause(context.Background())
	defer cancel(context.Canceled)

	sig := make(chan os.Signal, 1)
	signal.Notify(sig, os.Interrupt)

	go func() {
		signal := <-sig
		zerolog.Ctx(ctx).Info().
			Stringer("signal", signal).
			Msg("received signal, canceling context")
		cancel(fmt.Errorf("received %s signal", signal))
	}()

	errs := make(chan error)
	if cfg.SSH.Host != "" {
		zerolog.Ctx(ctx).Info().
			Msgf("setting up SSH tunnel: %d:localhost:%d -> %s",
				cfg.SSH.LocalPort, cfg.SSH.RemotePort, cfg.SSH.Host,
			)
		if err := setupSSHTunnel(ctx, cfg.SSH, errs); err != nil {
			return fmt.Errorf("setup SSH tunnel: %w", err)
		}
	}

	clientCtx, clientCancel := context.WithTimeout(ctx, time.Second*10)
	defer clientCancel()

	bitcoind, err := server.NewBitcoind(
		clientCtx, cfg.Bitcoind.Host, cfg.Bitcoind.User, cfg.Bitcoind.Pass,
	)
	if err != nil {
		return fmt.Errorf("new server: %w", err)
	}

	go func() {
		if err := bitcoind.Listen(ctx, cfg.Listen); err != nil {
			errs <- err
		}
	}()
	go func() {
		<-ctx.Done()
		bitcoind.Shutdown(ctx)

		errs <- context.Cause(ctx)
	}()

	return <-errs
}

func main() {
	ctx := context.Background()

	cfg, err := readConfig(ctx)
	if err != nil {
		fmt.Fprintln(os.Stderr, "unable to read config:", err)
		os.Exit(1)
	}

	// important: this is only usable AFTER readConfig has been called
	log := zerolog.Ctx(ctx)

	if info, ok := debug.ReadBuildInfo(); ok {
		log.Info().
			Str("go", info.GoVersion).
			Str("vcs.sha", findSetting("vcs.revision", info.Settings)).
			Str("vcs.modified", findSetting("vcs.modified", info.Settings)).
			Msgf("starting %s", os.Args[0])
	}

	if err := realMain(cfg); err != nil {
		log.Fatal().Err(err).Msg("main: received error")
	}
	log.Info().Msgf("main: exiting with 0 code")
}

func findSetting(key string, settings []debug.BuildSetting) string {
	for _, setting := range settings {
		if setting.Key == key {
			return setting.Value
		}
	}

	return "unknown"
}

// setupSSHTunnel creates an SSH tunnel by running the ssh command
func setupSSHTunnel(ctx context.Context, conf sshConfig, out chan error) error {
	if conf.KeyFile == "" {
		return fmt.Errorf("ssh: key file is required")
	}

	args := []string{
		"-v", "-N",
		"-F", "none", // don't read the default config file
		"-o", "PasswordAuthentication=no", // disable password authentication
		"-o", "PreferredAuthentications=publickey", // only use public key authentication
		"-o", "IdentitiesOnly=yes", // only use explicitly provided keys
		"-o", "ServerAliveInterval=60", // send keep-alive every 60 seconds
		"-o", "ServerAliveCountMax=3", // allow 3 missed keep-alive responses before disconnecting
		"-o", "TCPKeepAlive=yes", // enable TCP keep-alive
		"-i", conf.KeyFile, // specify the key file to use
		"-L", fmt.Sprintf("%d:localhost:%d", conf.LocalPort, conf.RemotePort),
		conf.Host,
	}
	if conf.KnownHosts != nil {
		tempFile, err := os.CreateTemp("", "")
		if err != nil {
			return fmt.Errorf("create temp file: %w", err)
		}

		for _, host := range conf.KnownHosts {
			_, err := fmt.Fprintln(tempFile, host)
			if err != nil {
				return fmt.Errorf("write temp file: %w", err)
			}
		}
		if err := tempFile.Close(); err != nil {
			return fmt.Errorf("close temp file: %w", err)
		}

		args = append(args, "-o", "UserKnownHostsFile="+tempFile.Name())
	}
	// Build SSH command with port forwarding
	// -N: Don't execute remote command (forward only)
	// -L: Local port forwarding
	cmd := exec.CommandContext(ctx, "ssh", args...)

	// Capture stdout and stderr
	stdout, err := cmd.StdoutPipe()
	if err != nil {
		return fmt.Errorf("create stdout pipe: %w", err)
	}

	stderr, err := cmd.StderrPipe()
	if err != nil {
		return fmt.Errorf("create stderr pipe: %w", err)
	}

	// Start the SSH tunnel
	if err := cmd.Start(); err != nil {
		return fmt.Errorf("starting SSH tunnel: %w", err)
	}

	// Monitor the tunnel process in background
	go func() {
		if err := cmd.Wait(); err != nil {
			zerolog.Ctx(ctx).Error().
				Err(err).
				Msg("SSH tunnel exited unexpectedly")
			out <- fmt.Errorf("SSH tunnel exited unexpectedly: %w", err)
		}
	}()

	// Log stdout in background
	go func() {
		scanner := bufio.NewScanner(stdout)
		for scanner.Scan() {
			zerolog.Ctx(ctx).Debug().
				Msgf("SSH tunnel stdout: %s", scanner.Text())
		}
	}()

	// Log stderr in background
	go func() {
		scanner := bufio.NewScanner(stderr)
		for scanner.Scan() {
			zerolog.Ctx(ctx).Debug().
				Msgf("SSH tunnel stderr: %s", scanner.Text())
		}
	}()

	// Wait for the tunnel to be established
	for i := 0; i < 10; i++ {
		if conn, err := net.Dial("tcp", fmt.Sprintf("localhost:%d", conf.LocalPort)); err == nil {
			if err := conn.Close(); err != nil {
				return fmt.Errorf("close connection: %w", err)
			}
			return nil
		}
		select {
		case <-ctx.Done():
			return fmt.Errorf("wait for SSH tunnel: %w", ctx.Err())
		case err := <-out:
			return fmt.Errorf("setup SSH tunnel: %w", err)

		case <-time.After(time.Second):
		}
	}

	return fmt.Errorf("timeout waiting for SSH tunnel")
}
