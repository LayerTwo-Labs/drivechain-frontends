package commands

import (
	"testing"

	"github.com/stretchr/testify/require"
	"github.com/urfave/cli/v2"
)

func TestRejectFlagAfterArgument(t *testing.T) {
	err := rejectFlagAfterArgument(startContext(t, "bitassets", "--daemon"))
	require.ErrorContains(t, err, `unknown argument "--daemon"`)

	require.NoError(t, rejectFlagAfterArgument(startContext(t, "--daemon", "bitassets")))
}

func TestStartCommandRejectsAFlagAfterTheArgument(t *testing.T) {
	app := &cli.App{
		Name:                   "drivechain-cli",
		Flags:                  GlobalFlags,
		Commands:               []*cli.Command{startCommand, stopCommand},
		UseShortOptionHandling: true,
	}

	require.ErrorContains(t, app.Run([]string{"drivechain-cli", "start", "bitassets", "--daemon"}),
		`unknown argument "--daemon"`)
	require.ErrorContains(t, app.Run([]string{"drivechain-cli", "stop", "bitassets", "--force"}),
		`unknown argument "--force"`)
}
