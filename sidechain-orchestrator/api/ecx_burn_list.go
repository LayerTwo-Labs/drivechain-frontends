package api

import (
	"context"
	"fmt"

	"connectrpc.com/connect/v2"
	"github.com/rs/zerolog"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

func (h *WalletHandler) ListEcxBurns(ctx context.Context, req *pb.ListEcxBurnsRequest) (*pb.ListEcxBurnsResponse, error) {
	if h.orch == nil {
		return nil, connect.NewError(connect.CodeUnavailable, "the orchestrator is not ready")
	}
	entry, ok := h.orch.RunningCatalogEntry()
	network := wallet.ECXBurnNetworkByID(entry.ID)
	if !ok || network.Name == "" {
		return nil, connect.NewError(connect.CodeFailedPrecondition, "the burn list is available only on Betanet")
	}
	url := entry.BackendURL(netcatalog.KindEsplora)
	if url == "" {
		return nil, connect.NewError(connect.CodeFailedPrecondition, network.Name+" publishes no esplora server")
	}
	client := wallet.NewEsploraClient([]string{url}, *zerolog.Ctx(ctx))
	if enabled, proxy := h.orch.TorConfigOverride(); enabled && proxy != "" {
		if err := client.SetProxy(true, proxy); err != nil {
			return nil, fmt.Errorf("route the burn list through tor: %w", err)
		}
	}
	return listECXBurns(ctx, client, network, entry.ForkHeight)
}

func listECXBurns(ctx context.Context, client *wallet.EsploraClient, network wallet.ECXBurnNetwork, forkHeight int) (*pb.ListEcxBurnsResponse, error) {
	txs, err := client.AddressTxsFrom(ctx, wallet.ECXBurnAddress, forkHeight)
	if err != nil {
		err = fmt.Errorf("read the burn address history: %w", err)
		return nil, connect.NewError(connect.CodeUnavailable, err.Error()).WithCause(err)
	}
	resp := &pb.ListEcxBurnsResponse{}
	var burns []wallet.ECXBurn
	payouts := map[string]bool{}
	for _, tx := range txs {
		burn, ok := network.Burn(tx)
		if !ok {
			continue
		}
		burns = append(burns, burn)
		payouts[burn.PayoutAddress] = true
		resp.TotalBurnSats += burn.BurnSats
		resp.TotalPayoutSats += burn.PayoutSats
		resp.Burns = append(resp.Burns, &pb.EcxBurn{
			Txid:          burn.TxID,
			Height:        int64(burn.Height),
			BurnSats:      burn.BurnSats,
			PayoutAddress: burn.PayoutAddress,
			PayoutSats:    burn.PayoutSats,
		})
	}
	resp.PayoutAddressCount = int64(len(payouts))
	resp.Csv, err = wallet.ECXBurnCSV(burns)
	if err != nil {
		return nil, fmt.Errorf("write the burn csv: %w", err)
	}
	return resp, nil
}
