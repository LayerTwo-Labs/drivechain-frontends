package api

import (
	"context"
	"encoding/json"
	"fmt"

	"connectrpc.com/connect/v2"
	"github.com/rs/zerolog"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

func (h *WalletHandler) ListEcxBurns(ctx context.Context, req *pb.ListEcxBurnsRequest) (*pb.ListEcxBurnsResponse, error) {
	if req.CoreUrl != "" {
		return coreECXBurns(ctx, req)
	}
	if h.orch == nil {
		return nil, connect.NewError(connect.CodeUnavailable, "the orchestrator is not ready")
	}
	entry, ok := h.orch.RunningCatalogEntry()
	network := wallet.ECXBurnNetworkByID(entry.ID)
	if req.NetworkId != "" && req.NetworkId != entry.ID {
		return nil, connect.NewError(connect.CodeInvalidArgument, "set core_url to list the burns of a network that is not running")
	}
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

// coreECXBurns reads the burns from the node at req.CoreUrl.
func coreECXBurns(ctx context.Context, req *pb.ListEcxBurnsRequest) (*pb.ListEcxBurnsResponse, error) {
	network := wallet.ECXBurnNetworkByID(req.NetworkId)
	if network.Name == "" {
		return nil, connect.Errorf(connect.CodeInvalidArgument, "%q is no burn network; use alphanet or betanet", req.NetworkId)
	}
	entry, ok := netcatalog.Embedded().ByID(req.NetworkId)
	if !ok || entry.ForkHeight <= 0 {
		return nil, connect.Errorf(connect.CodeFailedPrecondition, "the catalog has no fork height for %s", req.NetworkId)
	}
	var user, password string
	if req.CoreCookiePath != "" {
		var err error
		if user, password, err = wallet.ReadCoreCookie(req.CoreCookiePath); err != nil {
			return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
		}
	}
	call := func(ctx context.Context, method string, params ...any) (json.RawMessage, error) {
		return orchestrator.CallBitcoindRPC(ctx, req.CoreUrl, user, password, method, params)
	}
	burns, err := wallet.CoreECXBurns(ctx, call, network, entry.ForkHeight)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, err.Error()).WithCause(err)
	}
	return ecxBurnsResponse(burns)
}

func listECXBurns(ctx context.Context, client *wallet.EsploraClient, network wallet.ECXBurnNetwork, forkHeight int) (*pb.ListEcxBurnsResponse, error) {
	txs, err := client.AddressTxsFrom(ctx, wallet.ECXBurnAddress, forkHeight)
	if err != nil {
		err = fmt.Errorf("read the burn address history: %w", err)
		return nil, connect.NewError(connect.CodeUnavailable, err.Error()).WithCause(err)
	}
	var burns []wallet.ECXBurn
	for _, tx := range txs {
		if burn, ok := network.Burn(tx); ok {
			burns = append(burns, burn)
		}
	}
	return ecxBurnsResponse(burns)
}

func ecxBurnsResponse(burns []wallet.ECXBurn) (*pb.ListEcxBurnsResponse, error) {
	resp := &pb.ListEcxBurnsResponse{}
	payouts := map[string]bool{}
	for _, burn := range burns {
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
	var err error
	resp.Csv, err = wallet.ECXBurnCSV(burns)
	if err != nil {
		return nil, fmt.Errorf("write the burn csv: %w", err)
	}
	return resp, nil
}
