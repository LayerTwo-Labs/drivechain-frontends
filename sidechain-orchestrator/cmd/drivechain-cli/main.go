package main

import (
	"fmt"
	"os"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/commands"
	"github.com/urfave/cli/v2"
)

// version is the release this binary comes from. The release build sets it with
// -ldflags "-X main.version=...".
var version = "dev"

func main() {
	app := &cli.App{
		Name:                   "drivechain-cli",
		Usage:                  "Run and control a Drivechain node and its sidechains",
		Version:                version,
		Flags:                  commands.GlobalFlags,
		Commands:               commands.Commands(),
		UseShortOptionHandling: true,
	}

	if err := app.Run(os.Args); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
}
