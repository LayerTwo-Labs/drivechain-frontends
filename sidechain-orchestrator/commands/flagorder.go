package commands

import (
	"fmt"
	"strings"

	"github.com/urfave/cli/v2"
)

// rejectFlagAfterArgument fails a command that got a flag after its argument.
// The parser stops at the first argument, so that flag does nothing.
func rejectFlagAfterArgument(cctx *cli.Context) error {
	for _, arg := range cctx.Args().Slice() {
		if len(arg) > 1 && strings.HasPrefix(arg, "-") {
			return fmt.Errorf("unknown argument %q: write a flag before the binary name", arg)
		}
	}
	return nil
}
