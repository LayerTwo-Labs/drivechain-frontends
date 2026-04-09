package thunder

import (
	"context"
	"encoding/json"
	"fmt"

	"connectrpc.com/connect"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/thunder/v1"
	svc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/thunder/v1/thunderv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

var _ svc.ThunderServiceHandler = (*Handler)(nil)

// Handler implements ThunderServiceHandler by proxying to the thunder binary's JSON-RPC.
// Common methods delegate to the embedded JSONRPCProxy; Thunder-specific methods are
// implemented directly using the proxy's Client.
type Handler struct {
	proxy *sidechain.JSONRPCProxy
}

func NewHandler(proxy *sidechain.JSONRPCProxy) *Handler {
	return &Handler{proxy: proxy}
}

// --- Common SidechainRPCProxy methods ---

func (h *Handler) GetBalance(ctx context.Context, req *connect.Request[pb.GetBalanceRequest]) (*connect.Response[pb.GetBalanceResponse], error) {
	total, available, err := h.proxy.GetBalance(ctx)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetBalanceResponse{
		TotalSats:     total,
		AvailableSats: available,
	}), nil
}

func (h *Handler) GetBlockCount(ctx context.Context, req *connect.Request[pb.GetBlockCountRequest]) (*connect.Response[pb.GetBlockCountResponse], error) {
	count, err := h.proxy.GetBlockCount(ctx)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetBlockCountResponse{Count: count}), nil
}

func (h *Handler) Stop(ctx context.Context, req *connect.Request[pb.StopRequest]) (*connect.Response[pb.StopResponse], error) {
	if err := h.proxy.Stop(ctx); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.StopResponse{}), nil
}

func (h *Handler) GetNewAddress(ctx context.Context, req *connect.Request[pb.GetNewAddressRequest]) (*connect.Response[pb.GetNewAddressResponse], error) {
	address, err := h.proxy.GetNewAddress(ctx)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetNewAddressResponse{Address: address}), nil
}

func (h *Handler) Withdraw(ctx context.Context, req *connect.Request[pb.WithdrawRequest]) (*connect.Response[pb.WithdrawResponse], error) {
	txid, err := h.proxy.Withdraw(ctx, req.Msg.Address, req.Msg.AmountSats, req.Msg.SideFeeSats, req.Msg.MainFeeSats)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.WithdrawResponse{Txid: txid}), nil
}

func (h *Handler) Transfer(ctx context.Context, req *connect.Request[pb.TransferRequest]) (*connect.Response[pb.TransferResponse], error) {
	txid, err := h.proxy.Transfer(ctx, req.Msg.Address, req.Msg.AmountSats, req.Msg.FeeSats)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.TransferResponse{Txid: txid}), nil
}

func (h *Handler) Mine(ctx context.Context, req *connect.Request[pb.MineRequest]) (*connect.Response[pb.MineResponse], error) {
	raw, err := h.proxy.Mine(ctx, req.Msg.FeeSats)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.MineResponse{BmmResultJson: string(raw)}), nil
}

func (h *Handler) GetPendingWithdrawalBundle(ctx context.Context, req *connect.Request[pb.GetPendingWithdrawalBundleRequest]) (*connect.Response[pb.GetPendingWithdrawalBundleResponse], error) {
	raw, err := h.proxy.GetPendingWithdrawalBundle(ctx)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetPendingWithdrawalBundleResponse{BundleJson: string(raw)}), nil
}

func (h *Handler) GetWalletUtxos(ctx context.Context, req *connect.Request[pb.GetWalletUtxosRequest]) (*connect.Response[pb.GetWalletUtxosResponse], error) {
	raw, err := h.proxy.GetWalletUtxos(ctx)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetWalletUtxosResponse{UtxosJson: string(raw)}), nil
}

func (h *Handler) ListUtxos(ctx context.Context, req *connect.Request[pb.ListUtxosRequest]) (*connect.Response[pb.ListUtxosResponse], error) {
	raw, err := h.proxy.ListUtxos(ctx)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.ListUtxosResponse{UtxosJson: string(raw)}), nil
}

func (h *Handler) GetLatestFailedWithdrawalBundleHeight(ctx context.Context, req *connect.Request[pb.GetLatestFailedWithdrawalBundleHeightRequest]) (*connect.Response[pb.GetLatestFailedWithdrawalBundleHeightResponse], error) {
	height, err := h.proxy.GetLatestFailedWithdrawalBundleHeight(ctx)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetLatestFailedWithdrawalBundleHeightResponse{Height: height}), nil
}

func (h *Handler) CallRaw(ctx context.Context, req *connect.Request[pb.CallRawRequest]) (*connect.Response[pb.CallRawResponse], error) {
	var params any
	if req.Msg.ParamsJson != "" {
		if err := json.Unmarshal([]byte(req.Msg.ParamsJson), &params); err != nil {
			return nil, fmt.Errorf("unmarshal params: %w", err)
		}
	}
	raw, err := h.proxy.CallRaw(ctx, req.Msg.Method, params)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.CallRawResponse{ResultJson: string(raw)}), nil
}

// --- Thunder-specific methods ---

func (h *Handler) GetSidechainWealth(ctx context.Context, req *connect.Request[pb.GetSidechainWealthRequest]) (*connect.Response[pb.GetSidechainWealthResponse], error) {
	var sats int64
	if err := h.proxy.Client.Call(ctx, "sidechain_wealth_sats", nil, &sats); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetSidechainWealthResponse{Sats: sats}), nil
}

func (h *Handler) CreateDeposit(ctx context.Context, req *connect.Request[pb.CreateDepositRequest]) (*connect.Response[pb.CreateDepositResponse], error) {
	var txid string
	params := map[string]any{
		"address":    req.Msg.Address,
		"value_sats": req.Msg.ValueSats,
		"fee_sats":   req.Msg.FeeSats,
	}
	if err := h.proxy.Client.Call(ctx, "create_deposit", params, &txid); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.CreateDepositResponse{Txid: txid}), nil
}

func (h *Handler) ConnectPeer(ctx context.Context, req *connect.Request[pb.ConnectPeerRequest]) (*connect.Response[pb.ConnectPeerResponse], error) {
	if err := h.proxy.Client.Call(ctx, "connect_peer", req.Msg.Address, nil); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.ConnectPeerResponse{}), nil
}

func (h *Handler) ListPeers(ctx context.Context, req *connect.Request[pb.ListPeersRequest]) (*connect.Response[pb.ListPeersResponse], error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "list_peers", nil)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.ListPeersResponse{PeersJson: string(raw)}), nil
}

func (h *Handler) GetBlock(ctx context.Context, req *connect.Request[pb.GetBlockRequest]) (*connect.Response[pb.GetBlockResponse], error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "get_block", req.Msg.Hash)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetBlockResponse{BlockJson: string(raw)}), nil
}

func (h *Handler) GetBestMainchainBlockHash(ctx context.Context, req *connect.Request[pb.GetBestMainchainBlockHashRequest]) (*connect.Response[pb.GetBestMainchainBlockHashResponse], error) {
	var hash string
	if err := h.proxy.Client.Call(ctx, "get_best_mainchain_block_hash", nil, &hash); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetBestMainchainBlockHashResponse{Hash: hash}), nil
}

func (h *Handler) GetBestSidechainBlockHash(ctx context.Context, req *connect.Request[pb.GetBestSidechainBlockHashRequest]) (*connect.Response[pb.GetBestSidechainBlockHashResponse], error) {
	var hash string
	if err := h.proxy.Client.Call(ctx, "get_best_sidechain_block_hash", nil, &hash); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetBestSidechainBlockHashResponse{Hash: hash}), nil
}

func (h *Handler) GetBmmInclusions(ctx context.Context, req *connect.Request[pb.GetBmmInclusionsRequest]) (*connect.Response[pb.GetBmmInclusionsResponse], error) {
	var inclusions string
	if err := h.proxy.Client.Call(ctx, "get_bmm_inclusions", req.Msg.BlockHash, &inclusions); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetBmmInclusionsResponse{Inclusions: inclusions}), nil
}

func (h *Handler) RemoveFromMempool(ctx context.Context, req *connect.Request[pb.RemoveFromMempoolRequest]) (*connect.Response[pb.RemoveFromMempoolResponse], error) {
	if err := h.proxy.Client.Call(ctx, "remove_from_mempool", req.Msg.Txid, nil); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.RemoveFromMempoolResponse{}), nil
}

func (h *Handler) GenerateMnemonic(ctx context.Context, req *connect.Request[pb.GenerateMnemonicRequest]) (*connect.Response[pb.GenerateMnemonicResponse], error) {
	var mnemonic string
	if err := h.proxy.Client.Call(ctx, "generate_mnemonic", nil, &mnemonic); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GenerateMnemonicResponse{Mnemonic: mnemonic}), nil
}

func (h *Handler) SetSeedFromMnemonic(ctx context.Context, req *connect.Request[pb.SetSeedFromMnemonicRequest]) (*connect.Response[pb.SetSeedFromMnemonicResponse], error) {
	if err := h.proxy.Client.Call(ctx, "set_seed_from_mnemonic", req.Msg.Mnemonic, nil); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.SetSeedFromMnemonicResponse{}), nil
}
