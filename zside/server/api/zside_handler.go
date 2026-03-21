package api

import (
	"context"
	"encoding/json"
	"fmt"

	"connectrpc.com/connect"

	pb "github.com/LayerTwo-Labs/sidesail/zside/server/gen/zside/v1"
	svc "github.com/LayerTwo-Labs/sidesail/zside/server/gen/zside/v1/zsidev1connect"
	"github.com/LayerTwo-Labs/sidesail/zside/server/rpc"
)

var _ svc.ZSideServiceHandler = new(ZSideHandler)

// ZSideHandler proxies ConnectRPC calls to the zside binary via JSON-RPC.
type ZSideHandler struct {
	rpc *rpc.Client
}

func NewZSideHandler(rpc *rpc.Client) *ZSideHandler {
	return &ZSideHandler{rpc: rpc}
}

func (h *ZSideHandler) GetBalance(ctx context.Context, req *connect.Request[pb.GetBalanceRequest]) (*connect.Response[pb.GetBalanceResponse], error) {
	var result struct {
		TotalShieldedSats        int64 `json:"total_shielded_sats"`
		TotalTransparentSats     int64 `json:"total_transparent_sats"`
		AvailableShieldedSats    int64 `json:"available_shielded_sats"`
		AvailableTransparentSats int64 `json:"available_transparent_sats"`
	}
	if err := h.rpc.Call(ctx, "balance", nil, &result); err != nil {
		return nil, err
	}
	totalSats := result.TotalShieldedSats + result.TotalTransparentSats
	availableSats := result.AvailableShieldedSats + result.AvailableTransparentSats
	return connect.NewResponse(&pb.GetBalanceResponse{
		TotalSats:     totalSats,
		AvailableSats: availableSats,
	}), nil
}

func (h *ZSideHandler) GetBalanceBreakdown(ctx context.Context, req *connect.Request[pb.GetBalanceBreakdownRequest]) (*connect.Response[pb.GetBalanceBreakdownResponse], error) {
	var result struct {
		TotalShieldedSats        int64 `json:"total_shielded_sats"`
		TotalTransparentSats     int64 `json:"total_transparent_sats"`
		AvailableShieldedSats    int64 `json:"available_shielded_sats"`
		AvailableTransparentSats int64 `json:"available_transparent_sats"`
	}
	if err := h.rpc.Call(ctx, "balance", nil, &result); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetBalanceBreakdownResponse{
		AvailableShieldedSats:    result.AvailableShieldedSats,
		AvailableTransparentSats: result.AvailableTransparentSats,
		TotalShieldedSats:        result.TotalShieldedSats,
		TotalTransparentSats:     result.TotalTransparentSats,
	}), nil
}

func (h *ZSideHandler) GetBlockCount(ctx context.Context, req *connect.Request[pb.GetBlockCountRequest]) (*connect.Response[pb.GetBlockCountResponse], error) {
	var count int64
	if err := h.rpc.Call(ctx, "getblockcount", nil, &count); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetBlockCountResponse{
		Count: count,
	}), nil
}

func (h *ZSideHandler) Stop(ctx context.Context, req *connect.Request[pb.StopRequest]) (*connect.Response[pb.StopResponse], error) {
	if err := h.rpc.Call(ctx, "stop", nil, nil); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.StopResponse{}), nil
}

func (h *ZSideHandler) GetNewTransparentAddress(ctx context.Context, req *connect.Request[pb.GetNewTransparentAddressRequest]) (*connect.Response[pb.GetNewTransparentAddressResponse], error) {
	var address string
	if err := h.rpc.Call(ctx, "get_new_transparent_address", nil, &address); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetNewTransparentAddressResponse{
		Address: address,
	}), nil
}

func (h *ZSideHandler) GetNewShieldedAddress(ctx context.Context, req *connect.Request[pb.GetNewShieldedAddressRequest]) (*connect.Response[pb.GetNewShieldedAddressResponse], error) {
	var address string
	if err := h.rpc.Call(ctx, "get_new_shielded_address", nil, &address); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetNewShieldedAddressResponse{
		Address: address,
	}), nil
}

func (h *ZSideHandler) GetShieldedWalletAddresses(ctx context.Context, req *connect.Request[pb.GetShieldedWalletAddressesRequest]) (*connect.Response[pb.GetShieldedWalletAddressesResponse], error) {
	var addresses []string
	if err := h.rpc.Call(ctx, "get_shielded_wallet_addresses", nil, &addresses); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetShieldedWalletAddressesResponse{
		Addresses: addresses,
	}), nil
}

func (h *ZSideHandler) GetTransparentWalletAddresses(ctx context.Context, req *connect.Request[pb.GetTransparentWalletAddressesRequest]) (*connect.Response[pb.GetTransparentWalletAddressesResponse], error) {
	var addresses []string
	if err := h.rpc.Call(ctx, "get_transparent_wallet_addresses", nil, &addresses); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetTransparentWalletAddressesResponse{
		Addresses: addresses,
	}), nil
}

func (h *ZSideHandler) Withdraw(ctx context.Context, req *connect.Request[pb.WithdrawRequest]) (*connect.Response[pb.WithdrawResponse], error) {
	var txid string
	params := []any{req.Msg.Address, req.Msg.AmountSats, req.Msg.SideFeeSats, req.Msg.MainFeeSats}
	if err := h.rpc.Call(ctx, "withdraw", params, &txid); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.WithdrawResponse{
		Txid: txid,
	}), nil
}

func (h *ZSideHandler) TransparentTransfer(ctx context.Context, req *connect.Request[pb.TransparentTransferRequest]) (*connect.Response[pb.TransparentTransferResponse], error) {
	var txid string
	params := []any{req.Msg.Address, req.Msg.AmountSats, req.Msg.FeeSats}
	if err := h.rpc.Call(ctx, "transparent_transfer", params, &txid); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.TransparentTransferResponse{
		Txid: txid,
	}), nil
}

func (h *ZSideHandler) ShieldedTransfer(ctx context.Context, req *connect.Request[pb.ShieldedTransferRequest]) (*connect.Response[pb.ShieldedTransferResponse], error) {
	var txid string
	params := []any{req.Msg.Address, req.Msg.AmountSats, req.Msg.FeeSats}
	if err := h.rpc.Call(ctx, "shielded_transfer", params, &txid); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.ShieldedTransferResponse{
		Txid: txid,
	}), nil
}

func (h *ZSideHandler) Shield(ctx context.Context, req *connect.Request[pb.ShieldRequest]) (*connect.Response[pb.ShieldResponse], error) {
	var txid string
	params := []any{req.Msg.AmountSats, req.Msg.FeeSats}
	if err := h.rpc.Call(ctx, "shield", params, &txid); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.ShieldResponse{
		Txid: txid,
	}), nil
}

func (h *ZSideHandler) Unshield(ctx context.Context, req *connect.Request[pb.UnshieldRequest]) (*connect.Response[pb.UnshieldResponse], error) {
	var txid string
	params := []any{req.Msg.AmountSats, req.Msg.FeeSats}
	if err := h.rpc.Call(ctx, "unshield", params, &txid); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.UnshieldResponse{
		Txid: txid,
	}), nil
}

func (h *ZSideHandler) GetSidechainWealth(ctx context.Context, req *connect.Request[pb.GetSidechainWealthRequest]) (*connect.Response[pb.GetSidechainWealthResponse], error) {
	var sats int64
	if err := h.rpc.Call(ctx, "sidechain_wealth_sats", nil, &sats); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetSidechainWealthResponse{
		Sats: sats,
	}), nil
}

func (h *ZSideHandler) CreateDeposit(ctx context.Context, req *connect.Request[pb.CreateDepositRequest]) (*connect.Response[pb.CreateDepositResponse], error) {
	var txid string
	params := []any{req.Msg.Address, req.Msg.ValueSats, req.Msg.FeeSats}
	if err := h.rpc.Call(ctx, "create_deposit", params, &txid); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.CreateDepositResponse{
		Txid: txid,
	}), nil
}

func (h *ZSideHandler) GetPendingWithdrawalBundle(ctx context.Context, req *connect.Request[pb.GetPendingWithdrawalBundleRequest]) (*connect.Response[pb.GetPendingWithdrawalBundleResponse], error) {
	raw, err := h.rpc.CallRaw(ctx, "pending_withdrawal_bundle", nil)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetPendingWithdrawalBundleResponse{
		BundleJson: string(raw),
	}), nil
}

func (h *ZSideHandler) ConnectPeer(ctx context.Context, req *connect.Request[pb.ConnectPeerRequest]) (*connect.Response[pb.ConnectPeerResponse], error) {
	if err := h.rpc.Call(ctx, "connect_peer", req.Msg.Address, nil); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.ConnectPeerResponse{}), nil
}

func (h *ZSideHandler) ListPeers(ctx context.Context, req *connect.Request[pb.ListPeersRequest]) (*connect.Response[pb.ListPeersResponse], error) {
	raw, err := h.rpc.CallRaw(ctx, "list_peers", nil)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.ListPeersResponse{
		PeersJson: string(raw),
	}), nil
}

func (h *ZSideHandler) Mine(ctx context.Context, req *connect.Request[pb.MineRequest]) (*connect.Response[pb.MineResponse], error) {
	raw, err := h.rpc.CallRaw(ctx, "mine", []any{req.Msg.FeeSats})
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.MineResponse{
		BmmResultJson: string(raw),
	}), nil
}

func (h *ZSideHandler) GetBlock(ctx context.Context, req *connect.Request[pb.GetBlockRequest]) (*connect.Response[pb.GetBlockResponse], error) {
	raw, err := h.rpc.CallRaw(ctx, "get_block", req.Msg.Hash)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetBlockResponse{
		BlockJson: string(raw),
	}), nil
}

func (h *ZSideHandler) GetBestMainchainBlockHash(ctx context.Context, req *connect.Request[pb.GetBestMainchainBlockHashRequest]) (*connect.Response[pb.GetBestMainchainBlockHashResponse], error) {
	var hash string
	if err := h.rpc.Call(ctx, "get_best_mainchain_block_hash", nil, &hash); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetBestMainchainBlockHashResponse{
		Hash: hash,
	}), nil
}

func (h *ZSideHandler) GetBestSidechainBlockHash(ctx context.Context, req *connect.Request[pb.GetBestSidechainBlockHashRequest]) (*connect.Response[pb.GetBestSidechainBlockHashResponse], error) {
	var hash string
	if err := h.rpc.Call(ctx, "get_best_sidechain_block_hash", nil, &hash); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetBestSidechainBlockHashResponse{
		Hash: hash,
	}), nil
}

func (h *ZSideHandler) GetBmmInclusions(ctx context.Context, req *connect.Request[pb.GetBmmInclusionsRequest]) (*connect.Response[pb.GetBmmInclusionsResponse], error) {
	var inclusions string
	if err := h.rpc.Call(ctx, "get_bmm_inclusions", req.Msg.BlockHash, &inclusions); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetBmmInclusionsResponse{
		Inclusions: inclusions,
	}), nil
}

func (h *ZSideHandler) GetWalletUtxos(ctx context.Context, req *connect.Request[pb.GetWalletUtxosRequest]) (*connect.Response[pb.GetWalletUtxosResponse], error) {
	raw, err := h.rpc.CallRaw(ctx, "get_wallet_utxos", nil)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetWalletUtxosResponse{
		UtxosJson: string(raw),
	}), nil
}

func (h *ZSideHandler) ListUtxos(ctx context.Context, req *connect.Request[pb.ListUtxosRequest]) (*connect.Response[pb.ListUtxosResponse], error) {
	raw, err := h.rpc.CallRaw(ctx, "list_utxos", nil)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.ListUtxosResponse{
		UtxosJson: string(raw),
	}), nil
}

func (h *ZSideHandler) RemoveFromMempool(ctx context.Context, req *connect.Request[pb.RemoveFromMempoolRequest]) (*connect.Response[pb.RemoveFromMempoolResponse], error) {
	if err := h.rpc.Call(ctx, "remove_from_mempool", req.Msg.Txid, nil); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.RemoveFromMempoolResponse{}), nil
}

func (h *ZSideHandler) GetLatestFailedWithdrawalBundleHeight(ctx context.Context, req *connect.Request[pb.GetLatestFailedWithdrawalBundleHeightRequest]) (*connect.Response[pb.GetLatestFailedWithdrawalBundleHeightResponse], error) {
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

func (h *ZSideHandler) GenerateMnemonic(ctx context.Context, req *connect.Request[pb.GenerateMnemonicRequest]) (*connect.Response[pb.GenerateMnemonicResponse], error) {
	var mnemonic string
	if err := h.rpc.Call(ctx, "generate_mnemonic", nil, &mnemonic); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GenerateMnemonicResponse{
		Mnemonic: mnemonic,
	}), nil
}

func (h *ZSideHandler) SetSeedFromMnemonic(ctx context.Context, req *connect.Request[pb.SetSeedFromMnemonicRequest]) (*connect.Response[pb.SetSeedFromMnemonicResponse], error) {
	if err := h.rpc.Call(ctx, "set_seed_from_mnemonic", req.Msg.Mnemonic, nil); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.SetSeedFromMnemonicResponse{}), nil
}

func (h *ZSideHandler) CallRaw(ctx context.Context, req *connect.Request[pb.CallRawRequest]) (*connect.Response[pb.CallRawResponse], error) {
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
