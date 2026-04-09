package coinshift

import (
	"context"
	"encoding/json"
	"fmt"

	"connectrpc.com/connect"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/coinshift/v1"
	svc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/coinshift/v1/coinshiftv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

var _ svc.CoinShiftServiceHandler = (*Handler)(nil)

// Handler implements CoinShiftServiceHandler by proxying to the coinshift binary's JSON-RPC.
// Common methods delegate to the embedded JSONRPCProxy; CoinShift-specific methods are
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

func (h *Handler) RemoveFromMempool(ctx context.Context, req *connect.Request[pb.RemoveFromMempoolRequest]) (*connect.Response[pb.RemoveFromMempoolResponse], error) {
	if err := h.proxy.Client.Call(ctx, "remove_from_mempool", req.Msg.Txid, nil); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.RemoveFromMempoolResponse{}), nil
}

func (h *Handler) GetLatestFailedWithdrawalBundleHeight(ctx context.Context, req *connect.Request[pb.GetLatestFailedWithdrawalBundleHeightRequest]) (*connect.Response[pb.GetLatestFailedWithdrawalBundleHeightResponse], error) {
	height, err := h.proxy.GetLatestFailedWithdrawalBundleHeight(ctx)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetLatestFailedWithdrawalBundleHeightResponse{Height: height}), nil
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

// --- CoinShift-specific methods ---

func (h *Handler) GetSidechainWealth(ctx context.Context, req *connect.Request[pb.GetSidechainWealthRequest]) (*connect.Response[pb.GetSidechainWealthResponse], error) {
	var sats int64
	if err := h.proxy.Client.Call(ctx, "sidechain_wealth_sats", nil, &sats); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetSidechainWealthResponse{Sats: sats}), nil
}

func (h *Handler) CreateDeposit(ctx context.Context, req *connect.Request[pb.CreateDepositRequest]) (*connect.Response[pb.CreateDepositResponse], error) {
	var txid string
	params := []any{req.Msg.Address, req.Msg.ValueSats, req.Msg.FeeSats}
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

func (h *Handler) ForgetPeer(ctx context.Context, req *connect.Request[pb.ForgetPeerRequest]) (*connect.Response[pb.ForgetPeerResponse], error) {
	if err := h.proxy.Client.Call(ctx, "forget_peer", req.Msg.Address, nil); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.ForgetPeerResponse{}), nil
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

func (h *Handler) GetWalletAddresses(ctx context.Context, req *connect.Request[pb.GetWalletAddressesRequest]) (*connect.Response[pb.GetWalletAddressesResponse], error) {
	var addresses []string
	if err := h.proxy.Client.Call(ctx, "get_wallet_addresses", nil, &addresses); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetWalletAddressesResponse{Addresses: addresses}), nil
}

func (h *Handler) OpenapiSchema(ctx context.Context, req *connect.Request[pb.OpenapiSchemaRequest]) (*connect.Response[pb.OpenapiSchemaResponse], error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "openapi_schema", nil)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.OpenapiSchemaResponse{SchemaJson: string(raw)}), nil
}

// --- Swap methods ---

func (h *Handler) CreateSwap(ctx context.Context, req *connect.Request[pb.CreateSwapRequest]) (*connect.Response[pb.CreateSwapResponse], error) {
	var result struct {
		SwapID string `json:"swap_id"`
		Txid   string `json:"txid"`
	}
	params := []any{
		req.Msg.L2AmountSats,
		req.Msg.L1AmountSats,
		req.Msg.L1RecipientAddress,
		req.Msg.ParentChain,
		req.Msg.L2Recipient,
		req.Msg.RequiredConfirmations,
		req.Msg.FeeSats,
	}
	if err := h.proxy.Client.Call(ctx, "create_swap", params, &result); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.CreateSwapResponse{
		SwapId: result.SwapID,
		Txid:   result.Txid,
	}), nil
}

func (h *Handler) ClaimSwap(ctx context.Context, req *connect.Request[pb.ClaimSwapRequest]) (*connect.Response[pb.ClaimSwapResponse], error) {
	var txid string
	params := []any{req.Msg.SwapId, req.Msg.L2ClaimerAddress}
	if err := h.proxy.Client.Call(ctx, "claim_swap", params, &txid); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.ClaimSwapResponse{Txid: txid}), nil
}

func (h *Handler) GetSwapStatus(ctx context.Context, req *connect.Request[pb.GetSwapStatusRequest]) (*connect.Response[pb.GetSwapStatusResponse], error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "get_swap_status", []any{req.Msg.SwapId})
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetSwapStatusResponse{SwapJson: string(raw)}), nil
}

func (h *Handler) ListSwaps(ctx context.Context, req *connect.Request[pb.ListSwapsRequest]) (*connect.Response[pb.ListSwapsResponse], error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "list_swaps", nil)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.ListSwapsResponse{SwapsJson: string(raw)}), nil
}

func (h *Handler) ListSwapsByRecipient(ctx context.Context, req *connect.Request[pb.ListSwapsByRecipientRequest]) (*connect.Response[pb.ListSwapsByRecipientResponse], error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "list_swaps_by_recipient", req.Msg.Recipient)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.ListSwapsByRecipientResponse{SwapsJson: string(raw)}), nil
}

func (h *Handler) UpdateSwapL1Txid(ctx context.Context, req *connect.Request[pb.UpdateSwapL1TxidRequest]) (*connect.Response[pb.UpdateSwapL1TxidResponse], error) {
	params := []any{req.Msg.SwapId, req.Msg.L1TxidHex, req.Msg.Confirmations}
	if err := h.proxy.Client.Call(ctx, "update_swap_l1_txid", params, nil); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.UpdateSwapL1TxidResponse{}), nil
}

func (h *Handler) ReconstructSwaps(ctx context.Context, req *connect.Request[pb.ReconstructSwapsRequest]) (*connect.Response[pb.ReconstructSwapsResponse], error) {
	var count int64
	if err := h.proxy.Client.Call(ctx, "reconstruct_swaps", nil, &count); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.ReconstructSwapsResponse{Count: count}), nil
}
