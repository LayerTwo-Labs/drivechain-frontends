package api

import (
	"context"
	"encoding/json"
	"fmt"

	"connectrpc.com/connect"

	pb "github.com/LayerTwo-Labs/sidesail/thunder/server/gen/thunder/v1"
	svc "github.com/LayerTwo-Labs/sidesail/thunder/server/gen/thunder/v1/thunderv1connect"
	"github.com/LayerTwo-Labs/sidesail/thunder/server/rpc"
)

var _ svc.ThunderServiceHandler = new(ThunderHandler)

// ThunderHandler proxies ConnectRPC calls to the thunder binary via JSON-RPC.
type ThunderHandler struct {
	rpc *rpc.Client
}

func NewThunderHandler(rpc *rpc.Client) *ThunderHandler {
	return &ThunderHandler{rpc: rpc}
}

func (h *ThunderHandler) GetBalance(ctx context.Context, req *connect.Request[pb.GetBalanceRequest]) (*connect.Response[pb.GetBalanceResponse], error) {
	var result struct {
		TotalSats     int64 `json:"total_sats"`
		AvailableSats int64 `json:"available_sats"`
	}
	if err := h.rpc.Call(ctx, "balance", nil, &result); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetBalanceResponse{
		TotalSats:     result.TotalSats,
		AvailableSats: result.AvailableSats,
	}), nil
}

func (h *ThunderHandler) GetBlockCount(ctx context.Context, req *connect.Request[pb.GetBlockCountRequest]) (*connect.Response[pb.GetBlockCountResponse], error) {
	var count int64
	if err := h.rpc.Call(ctx, "getblockcount", nil, &count); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetBlockCountResponse{
		Count: count,
	}), nil
}

func (h *ThunderHandler) Stop(ctx context.Context, req *connect.Request[pb.StopRequest]) (*connect.Response[pb.StopResponse], error) {
	if err := h.rpc.Call(ctx, "stop", nil, nil); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.StopResponse{}), nil
}

func (h *ThunderHandler) GetNewAddress(ctx context.Context, req *connect.Request[pb.GetNewAddressRequest]) (*connect.Response[pb.GetNewAddressResponse], error) {
	var address string
	if err := h.rpc.Call(ctx, "get_new_address", nil, &address); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetNewAddressResponse{
		Address: address,
	}), nil
}

func (h *ThunderHandler) Withdraw(ctx context.Context, req *connect.Request[pb.WithdrawRequest]) (*connect.Response[pb.WithdrawResponse], error) {
	var txid string
	params := []any{req.Msg.Address, req.Msg.AmountSats, req.Msg.SideFeeSats, req.Msg.MainFeeSats}
	if err := h.rpc.Call(ctx, "withdraw", params, &txid); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.WithdrawResponse{
		Txid: txid,
	}), nil
}

func (h *ThunderHandler) Transfer(ctx context.Context, req *connect.Request[pb.TransferRequest]) (*connect.Response[pb.TransferResponse], error) {
	var txid string
	params := []any{req.Msg.Address, req.Msg.AmountSats, req.Msg.FeeSats}
	if err := h.rpc.Call(ctx, "transfer", params, &txid); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.TransferResponse{
		Txid: txid,
	}), nil
}

func (h *ThunderHandler) GetSidechainWealth(ctx context.Context, req *connect.Request[pb.GetSidechainWealthRequest]) (*connect.Response[pb.GetSidechainWealthResponse], error) {
	var sats int64
	if err := h.rpc.Call(ctx, "sidechain_wealth_sats", nil, &sats); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetSidechainWealthResponse{
		Sats: sats,
	}), nil
}

func (h *ThunderHandler) CreateDeposit(ctx context.Context, req *connect.Request[pb.CreateDepositRequest]) (*connect.Response[pb.CreateDepositResponse], error) {
	var txid string
	params := map[string]any{
		"address":    req.Msg.Address,
		"value_sats": req.Msg.ValueSats,
		"fee_sats":   req.Msg.FeeSats,
	}
	if err := h.rpc.Call(ctx, "create_deposit", params, &txid); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.CreateDepositResponse{
		Txid: txid,
	}), nil
}

func (h *ThunderHandler) GetPendingWithdrawalBundle(ctx context.Context, req *connect.Request[pb.GetPendingWithdrawalBundleRequest]) (*connect.Response[pb.GetPendingWithdrawalBundleResponse], error) {
	raw, err := h.rpc.CallRaw(ctx, "pending_withdrawal_bundle", nil)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetPendingWithdrawalBundleResponse{
		BundleJson: string(raw),
	}), nil
}

func (h *ThunderHandler) ConnectPeer(ctx context.Context, req *connect.Request[pb.ConnectPeerRequest]) (*connect.Response[pb.ConnectPeerResponse], error) {
	if err := h.rpc.Call(ctx, "connect_peer", req.Msg.Address, nil); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.ConnectPeerResponse{}), nil
}

func (h *ThunderHandler) ListPeers(ctx context.Context, req *connect.Request[pb.ListPeersRequest]) (*connect.Response[pb.ListPeersResponse], error) {
	raw, err := h.rpc.CallRaw(ctx, "list_peers", nil)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.ListPeersResponse{
		PeersJson: string(raw),
	}), nil
}

func (h *ThunderHandler) Mine(ctx context.Context, req *connect.Request[pb.MineRequest]) (*connect.Response[pb.MineResponse], error) {
	raw, err := h.rpc.CallRaw(ctx, "mine", []any{req.Msg.FeeSats})
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.MineResponse{
		BmmResultJson: string(raw),
	}), nil
}

func (h *ThunderHandler) GetBlock(ctx context.Context, req *connect.Request[pb.GetBlockRequest]) (*connect.Response[pb.GetBlockResponse], error) {
	raw, err := h.rpc.CallRaw(ctx, "get_block", req.Msg.Hash)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetBlockResponse{
		BlockJson: string(raw),
	}), nil
}

func (h *ThunderHandler) GetBestMainchainBlockHash(ctx context.Context, req *connect.Request[pb.GetBestMainchainBlockHashRequest]) (*connect.Response[pb.GetBestMainchainBlockHashResponse], error) {
	var hash string
	if err := h.rpc.Call(ctx, "get_best_mainchain_block_hash", nil, &hash); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetBestMainchainBlockHashResponse{
		Hash: hash,
	}), nil
}

func (h *ThunderHandler) GetBestSidechainBlockHash(ctx context.Context, req *connect.Request[pb.GetBestSidechainBlockHashRequest]) (*connect.Response[pb.GetBestSidechainBlockHashResponse], error) {
	var hash string
	if err := h.rpc.Call(ctx, "get_best_sidechain_block_hash", nil, &hash); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetBestSidechainBlockHashResponse{
		Hash: hash,
	}), nil
}

func (h *ThunderHandler) GetBmmInclusions(ctx context.Context, req *connect.Request[pb.GetBmmInclusionsRequest]) (*connect.Response[pb.GetBmmInclusionsResponse], error) {
	var inclusions string
	if err := h.rpc.Call(ctx, "get_bmm_inclusions", req.Msg.BlockHash, &inclusions); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetBmmInclusionsResponse{
		Inclusions: inclusions,
	}), nil
}

func (h *ThunderHandler) GetWalletUtxos(ctx context.Context, req *connect.Request[pb.GetWalletUtxosRequest]) (*connect.Response[pb.GetWalletUtxosResponse], error) {
	raw, err := h.rpc.CallRaw(ctx, "get_wallet_utxos", nil)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetWalletUtxosResponse{
		UtxosJson: string(raw),
	}), nil
}

func (h *ThunderHandler) ListUtxos(ctx context.Context, req *connect.Request[pb.ListUtxosRequest]) (*connect.Response[pb.ListUtxosResponse], error) {
	raw, err := h.rpc.CallRaw(ctx, "list_utxos", nil)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.ListUtxosResponse{
		UtxosJson: string(raw),
	}), nil
}

func (h *ThunderHandler) RemoveFromMempool(ctx context.Context, req *connect.Request[pb.RemoveFromMempoolRequest]) (*connect.Response[pb.RemoveFromMempoolResponse], error) {
	if err := h.rpc.Call(ctx, "remove_from_mempool", req.Msg.Txid, nil); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.RemoveFromMempoolResponse{}), nil
}

func (h *ThunderHandler) GetLatestFailedWithdrawalBundleHeight(ctx context.Context, req *connect.Request[pb.GetLatestFailedWithdrawalBundleHeightRequest]) (*connect.Response[pb.GetLatestFailedWithdrawalBundleHeightResponse], error) {
	raw, err := h.rpc.CallRaw(ctx, "latest_failed_withdrawal_bundle_height", nil)
	if err != nil {
		return nil, err
	}

	// Result can be null or an integer
	var height int64
	if raw != nil && string(raw) != "null" {
		if err := json.Unmarshal(raw, &height); err != nil {
			return nil, fmt.Errorf("unmarshal height: %w", err)
		}
	}

	return connect.NewResponse(&pb.GetLatestFailedWithdrawalBundleHeightResponse{
		Height: height,
	}), nil
}

func (h *ThunderHandler) GenerateMnemonic(ctx context.Context, req *connect.Request[pb.GenerateMnemonicRequest]) (*connect.Response[pb.GenerateMnemonicResponse], error) {
	var mnemonic string
	if err := h.rpc.Call(ctx, "generate_mnemonic", nil, &mnemonic); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GenerateMnemonicResponse{
		Mnemonic: mnemonic,
	}), nil
}

func (h *ThunderHandler) SetSeedFromMnemonic(ctx context.Context, req *connect.Request[pb.SetSeedFromMnemonicRequest]) (*connect.Response[pb.SetSeedFromMnemonicResponse], error) {
	if err := h.rpc.Call(ctx, "set_seed_from_mnemonic", req.Msg.Mnemonic, nil); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.SetSeedFromMnemonicResponse{}), nil
}

func (h *ThunderHandler) CallRaw(ctx context.Context, req *connect.Request[pb.CallRawRequest]) (*connect.Response[pb.CallRawResponse], error) {
	var params any
	if req.Msg.ParamsJson != "" {
		if err := json.Unmarshal([]byte(req.Msg.ParamsJson), &params); err != nil {
			return nil, fmt.Errorf("unmarshal params: %w", err)
		}
	}

	raw, err := h.rpc.CallRaw(ctx, req.Msg.Method, params)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.CallRawResponse{
		ResultJson: string(raw),
	}), nil
}
