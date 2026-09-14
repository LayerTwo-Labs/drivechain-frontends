package api

import (
	"io"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"

	"connectrpc.com/connect"
	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

func TestPlanECashSwitchHandlerReportsChainData(t *testing.T) {
	for _, test := range []struct {
		name         string
		hasChainData bool
		badBlocksDir bool
		chainID      string
		errorText    string
	}{
		{name: "empty directory"},
		{name: "chain files", hasChainData: true, chainID: "alphanet"},
		{name: "invalid blocks directory", badBlocksDir: true, errorText: "read ECX chain files"},
		{name: "unknown chain identity", hasChainData: true, errorText: "read ECX chain identity"},
	} {
		t.Run(test.name, func(t *testing.T) {
			o := orchestrator.New(t.TempDir(), "signet", t.TempDir(), nil, zerolog.New(io.Discard))
			o.Catalog = netcatalog.Catalog{Networks: []netcatalog.Network{
				{ID: "alphanet", Family: netcatalog.FamilyECash, ForkHeight: 900000},
				{ID: "betanet", Family: netcatalog.FamilyECash, ForkHeight: 910000},
			}}
			root := t.TempDir()
			o.BitcoinConf.Config.SetGroupDatadir(config.DatadirGroupECash, root)
			require.NoError(t, o.Settings.SetECashChainID(test.chainID))
			o.BitcoinConf.Config.SetSetting("uacomment", "", "main")
			if test.hasChainData {
				require.NoError(t, os.Mkdir(filepath.Join(root, "blocks"), 0o700))
				require.NoError(t, os.WriteFile(filepath.Join(root, "blocks", "blk00000.dat"), []byte("chain data"), 0o600))
			}
			if test.badBlocksDir {
				o.BitcoinConf.Config.SetSetting("blocksdir", "[", "main")
			}
			_, handler := rpc.NewBitcoinConfServiceHandler(NewBitcoinConfHandler(o))
			server := httptest.NewServer(handler)
			t.Cleanup(server.Close)
			client := rpc.NewBitcoinConfServiceClient(server.Client(), server.URL)

			response, err := client.PlanECashSwitch(t.Context(), connect.NewRequest(&pb.PlanECashSwitchRequest{
				NetworkId: " betanet ",
			}))

			if test.errorText != "" {
				require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
				require.ErrorContains(t, err, test.errorText)
				require.Nil(t, response)
				return
			}
			require.NoError(t, err)
			require.Equal(t, "betanet", response.Msg.ToId)
			require.Equal(t, test.hasChainData, response.Msg.HasChainData)
			require.Equal(t, test.chainID, response.Msg.ChainId)
		})
	}
}
