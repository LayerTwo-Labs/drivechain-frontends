package commands

import (
	"fmt"
	"net/http"

	"connectrpc.com/connect"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	"github.com/urfave/cli/v2"
)

var GlobalFlags = []cli.Flag{
	&cli.StringFlag{
		Name:    "rpcserver",
		Usage:   "orchestratord RPC address",
		Value:   "localhost:30400",
		EnvVars: []string{"ORCHESTRATOR_RPCSERVER"},
	},
	&cli.StringFlag{
		Name:    "datadir",
		Usage:   "data directory",
		EnvVars: []string{"ORCHESTRATOR_DATADIR"},
	},
	&cli.StringFlag{
		Name:    "network",
		Usage:   "bitcoin network",
		Value:   "signet",
		EnvVars: []string{"ORCHESTRATOR_NETWORK"},
	},
}

// Commands returns all available CLI subcommands.
func Commands() []*cli.Command {
	return []*cli.Command{
		downloadCommand,
		startCommand,
		stopCommand,
		statusCommand,
		logsCommand,
		shutdownCommand,
	}
}

func newClient(cctx *cli.Context) rpc.OrchestratorServiceClient {
	addr := cctx.String("rpcserver")
	url := fmt.Sprintf("http://%s", addr)
	return rpc.NewOrchestratorServiceClient(
		http.DefaultClient,
		url,
		connect.WithGRPC(),
	)
}
