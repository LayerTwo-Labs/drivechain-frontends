package main

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"
	"sync"
	"time"

	"github.com/rs/zerolog"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/daemon"
	orchconfig "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	orchdaemon "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/daemon"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/logfile"
)

// startConfig is the JSON that the app gives to BitwindowStart.
type startConfig struct {
	// Args are the bitwindowd command line flags.
	Args []string `json:"args"`
	// Env is set in the process environment before the start.
	Env map[string]string `json:"env"`
}

// status is the JSON that BitwindowStatus returns.
type status struct {
	Running bool   `json:"running"`
	Error   string `json:"error,omitempty"`
}

// backend holds the one bitwindowd that runs in this process.
type backend struct {
	mu      sync.Mutex
	cancel  context.CancelFunc
	done    chan struct{}
	exitErr error
	run     func(ctx context.Context, args []string) error
}

func newBackend() *backend {
	return &backend{run: func(ctx context.Context, args []string) error {
		return daemon.Run(ctx, args, daemon.Options{Orchestrator: runOrchestrator})
	}}
}

func parseStartConfig(raw string) (startConfig, error) {
	var cfg startConfig
	if err := json.Unmarshal([]byte(raw), &cfg); err != nil {
		return startConfig{}, fmt.Errorf("parse start config: %w", err)
	}
	return cfg, nil
}

func (b *backend) start(raw string) error {
	cfg, err := parseStartConfig(raw)
	if err != nil {
		return err
	}

	b.mu.Lock()
	defer b.mu.Unlock()
	if b.done != nil {
		select {
		case <-b.done:
		default:
			return errors.New("bitwindowd already runs in this process")
		}
	}

	for key, value := range cfg.Env {
		if err := os.Setenv(key, value); err != nil {
			return fmt.Errorf("set %s: %w", key, err)
		}
	}

	ctx, cancel := context.WithCancel(context.Background())
	done := make(chan struct{})
	b.cancel, b.done, b.exitErr = cancel, done, nil
	go func() {
		err := b.run(ctx, cfg.Args)
		b.mu.Lock()
		b.exitErr = err
		b.mu.Unlock()
		close(done)
	}()
	return nil
}

// stop asks bitwindowd to stop. status reports when it is gone.
func (b *backend) stop() {
	b.mu.Lock()
	defer b.mu.Unlock()
	if b.cancel != nil {
		b.cancel()
	}
}

func (b *backend) status() status {
	b.mu.Lock()
	defer b.mu.Unlock()
	if b.done == nil {
		return status{}
	}
	select {
	case <-b.done:
	default:
		return status{Running: true}
	}
	if b.exitErr != nil {
		return status{Error: b.exitErr.Error()}
	}
	return status{}
}

// wait blocks until bitwindowd is gone or timeout ends.
func (b *backend) wait(timeout time.Duration) error {
	b.mu.Lock()
	done := b.done
	b.mu.Unlock()
	if done == nil {
		return nil
	}
	select {
	case <-done:
		return nil
	case <-time.After(timeout):
		return fmt.Errorf("bitwindowd did not stop in %s", timeout)
	}
}

// runOrchestrator runs drivechaind with the settings bitwindowd gives a child
// drivechaind on the desktop.
func runOrchestrator(ctx context.Context, p daemon.OrchestratorParams) error {
	f, err := os.OpenFile(p.LogPath, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0o644)
	if err != nil {
		return fmt.Errorf("open drivechaind log %s: %w", p.LogPath, err)
	}
	defer f.Close() //nolint:errcheck

	const timeFormat = "15:04:05.000"
	out := zerolog.MultiLevelWriter(
		zerolog.ConsoleWriter{Out: os.Stderr, TimeFormat: timeFormat},
		zerolog.ConsoleWriter{Out: logfile.Tag(f, "orchestrator"), NoColor: true, TimeFormat: timeFormat},
	)
	return orchdaemon.Run(ctx, orchestratorConfig(p, out, os.Getenv))
}

func orchestratorConfig(p daemon.OrchestratorParams, out io.Writer, getenv func(string) string) orchdaemon.Config {
	return orchdaemon.Config{
		DataDir:      p.BitwindowDir,
		Network:      orchconfig.DefaultNetwork,
		ListenAddr:   p.ListenAddr,
		BitwindowDir: p.BitwindowDir,
		LocalAuth:    localAuth(getenv("ORCHESTRATOR_LOCAL_AUTH")),
		OwnerPID:     p.OwnerPID,
		Log:          zerolog.New(out).Level(zerolog.InfoLevel).With().Timestamp().Logger(),
	}
}

// localAuth reads the ORCHESTRATOR_LOCAL_AUTH kill switch as the app does.
func localAuth(value string) bool {
	return value != "false" && value != "0" && value != "FALSE" && value != "False"
}
