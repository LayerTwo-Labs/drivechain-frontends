package commands

import (
	"flag"
	"testing"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/urfave/cli/v2"
)

func TestCookieDirUsesBitwindowDir(t *testing.T) {
	fs := flag.NewFlagSet("test", flag.ContinueOnError)
	fs.String("datadir", "/tmp/orchestrator-data", "")
	fs.String("bitwindow-dir", "/tmp/bitwindow-data", "")
	cctx := cli.NewContext(cli.NewApp(), fs, nil)

	if got, want := cookieDir(cctx), "/tmp/bitwindow-data"; got != want {
		t.Fatalf("cookieDir() = %q, want %q", got, want)
	}
}

func TestCookieDirDefaultIgnoresDatadir(t *testing.T) {
	fs := flag.NewFlagSet("test", flag.ContinueOnError)
	fs.String("datadir", "/tmp/orchestrator-data", "")
	fs.String("bitwindow-dir", "", "")
	cctx := cli.NewContext(cli.NewApp(), fs, nil)

	if got, want := cookieDir(cctx), orchestrator.DefaultBitwindowDir(); got != want {
		t.Fatalf("cookieDir() = %q, want %q", got, want)
	}
}
