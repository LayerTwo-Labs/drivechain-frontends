package orchestrator

import (
	"context"
	"io"
	"testing"
	"time"

	"github.com/rs/zerolog"
)

func TestMonitorChangeWakesBinariesSubscriber(t *testing.T) {
	o := New(t.TempDir(), "regtest", t.TempDir(), nil, zerolog.New(io.Discard))
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	changed := o.SubscribeBinaries(ctx)
	o.getOrCreateMonitor("bitcoind", nil, nil).SetStopping(true)

	select {
	case <-changed:
	case <-time.After(time.Second):
		t.Fatal("monitor change did not wake the subscriber")
	}
}

func TestDownloadStateWakesSubscriber(t *testing.T) {
	o := New(t.TempDir(), "regtest", t.TempDir(), nil, zerolog.New(io.Discard))
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	changed := o.SubscribeDownloads(ctx)
	o.download.PublishState("bitcoind", DownloadState{MBDownloaded: 1, MBTotal: 2})

	select {
	case <-changed:
	case <-time.After(time.Second):
		t.Fatal("a download state write did not wake the subscriber")
	}
}

func TestMigrationChangeWakesSubscriber(t *testing.T) {
	o := New(t.TempDir(), "regtest", t.TempDir(), nil, zerolog.New(io.Discard))
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()

	changed := o.SubscribeECashMigration(ctx)
	if err := o.endFailedStart(ECashMigrationStatus{Phase: "prepare", Error: "download failed"}); err != nil {
		t.Fatal(err)
	}

	select {
	case <-changed:
	case <-time.After(time.Second):
		t.Fatal("a migration change did not wake the subscriber")
	}
	status, err := o.ECashMigrationStatus()
	if err != nil {
		t.Fatal(err)
	}
	if status.Error != "download failed" {
		t.Fatalf("status error = %q", status.Error)
	}
}

type staticCheck struct{ err error }

func (c staticCheck) Check(context.Context) error { return c.err }

func TestConnectionsFollowTheMonitor(t *testing.T) {
	o := New(t.TempDir(), "regtest", t.TempDir(), nil, zerolog.New(io.Discard))
	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	changed := o.SubscribeBinaries(ctx)
	wait := func(want bool) {
		t.Helper()
		select {
		case <-changed:
		case <-time.After(time.Second):
			t.Fatal("a connection change did not wake the subscriber")
		}
		got := o.Connections()
		if len(got) != 1 || got[0] != (BinaryConnection{Name: "thunder", Connected: want}) {
			t.Fatalf("connections = %+v, want thunder connected=%t", got, want)
		}
	}

	mon := o.getOrCreateMonitor("thunder", staticCheck{}, nil)
	mon.testConnection(ctx)
	wait(true)

	mon.MarkDisconnected()
	wait(false)
}
