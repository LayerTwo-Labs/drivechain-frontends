package main

import (
	"fmt"
	"os"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/commands"
	"github.com/urfave/cli/v2"
)

func main() {
	app := &cli.App{
		Name:     "orchestratorctl",
		Usage:    "Control the sidechain orchestrator daemon",
		Flags:    commands.GlobalFlags,
		Commands: commands.Commands(),
	}

	if err := app.Run(os.Args); err != nil {
		fmt.Fprintf(os.Stderr, "error: %v\n", err)
		os.Exit(1)
	}
}
