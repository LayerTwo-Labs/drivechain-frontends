package coinshift

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"

	"connectrpc.com/connect/v2"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/coinshift/v1"
	svc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/coinshift/v1/coinshiftv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

var _ svc.CoinShiftServiceHandler = (*Handler)(nil)

// Handler implements CoinShiftServiceHandler by proxying to the coinshift binary's JSON-RPC.
// Common methods delegate to the proxy field; CoinShift-specific methods are
// implemented directly using the proxy's Client.
type Handler struct {
	proxy *sidechain.JSONRPCProxy
}

func NewHandler(proxy *sidechain.JSONRPCProxy) *Handler {
	return &Handler{proxy: proxy}
}

// WalletBalance reads the wallet balance in sats. Another service answers the
// same number from here.
func (h *Handler) WalletBalance(ctx context.Context) (total, available int64, err error) {
	return h.proxy.GetBalance(ctx)
}

// --- Common Node methods ---

func (h *Handler) GetBalance(ctx context.Context, req *pb.GetBalanceRequest) (*pb.GetBalanceResponse, error) {
	total, available, err := h.WalletBalance(ctx)
	if err != nil {
		return nil, err
	}
	return &pb.GetBalanceResponse{
		TotalSats:     total,
		AvailableSats: available,
	}, nil
}

func (h *Handler) GetBlockCount(ctx context.Context, req *pb.GetBlockCountRequest) (*pb.GetBlockCountResponse, error) {
	count, err := h.proxy.GetBlockCount(ctx)
	if err != nil {
		return nil, err
	}
	return &pb.GetBlockCountResponse{Count: count}, nil
}

func (h *Handler) Stop(ctx context.Context, req *pb.StopRequest) (*pb.StopResponse, error) {
	if err := h.proxy.Stop(ctx); err != nil {
		return nil, err
	}
	return &pb.StopResponse{}, nil
}

func (h *Handler) GetNewAddress(ctx context.Context, req *pb.GetNewAddressRequest) (*pb.GetNewAddressResponse, error) {
	address, err := h.proxy.GetNewAddress(ctx)
	if err != nil {
		return nil, err
	}
	return &pb.GetNewAddressResponse{Address: address}, nil
}

func (h *Handler) Withdraw(ctx context.Context, req *pb.WithdrawRequest) (*pb.WithdrawResponse, error) {
	txid, err := h.proxy.Withdraw(ctx, req.Address, req.AmountSats, req.SideFeeSats, req.MainFeeSats)
	if err != nil {
		return nil, err
	}
	return &pb.WithdrawResponse{Txid: txid}, nil
}

func (h *Handler) Transfer(ctx context.Context, req *pb.TransferRequest) (*pb.TransferResponse, error) {
	txid, err := h.proxy.Transfer(ctx, req.Address, req.AmountSats, req.FeeSats)
	if err != nil {
		return nil, err
	}
	return &pb.TransferResponse{Txid: txid}, nil
}

func (h *Handler) Mine(ctx context.Context, req *pb.MineRequest) (*pb.MineResponse, error) {
	raw, err := h.proxy.Mine(ctx, req.FeeSats)
	if err != nil {
		return nil, err
	}
	return &pb.MineResponse{BmmResultJson: string(raw)}, nil
}

func (h *Handler) GetPendingWithdrawalBundle(ctx context.Context, req *pb.GetPendingWithdrawalBundleRequest) (*pb.GetPendingWithdrawalBundleResponse, error) {
	raw, err := h.proxy.GetPendingWithdrawalBundle(ctx)
	if err != nil {
		return nil, err
	}
	return &pb.GetPendingWithdrawalBundleResponse{BundleJson: string(raw)}, nil
}

func (h *Handler) GetWalletUtxos(ctx context.Context, req *pb.GetWalletUtxosRequest) (*pb.GetWalletUtxosResponse, error) {
	raw, err := h.proxy.GetWalletUtxos(ctx)
	if err != nil {
		return nil, err
	}
	return &pb.GetWalletUtxosResponse{UtxosJson: string(raw)}, nil
}

func (h *Handler) ListUtxos(ctx context.Context, req *pb.ListUtxosRequest) (*pb.ListUtxosResponse, error) {
	raw, err := h.proxy.ListUtxos(ctx)
	if err != nil {
		return nil, err
	}
	return &pb.ListUtxosResponse{UtxosJson: string(raw)}, nil
}

func (h *Handler) RemoveFromMempool(ctx context.Context, req *pb.RemoveFromMempoolRequest) (*pb.RemoveFromMempoolResponse, error) {
	if err := h.proxy.Client.Call(ctx, "remove_from_mempool", []any{req.Txid}, nil); err != nil {
		return nil, err
	}
	return &pb.RemoveFromMempoolResponse{}, nil
}

func (h *Handler) GetLatestFailedWithdrawalBundleHeight(ctx context.Context, req *pb.GetLatestFailedWithdrawalBundleHeightRequest) (*pb.GetLatestFailedWithdrawalBundleHeightResponse, error) {
	height, err := h.proxy.GetLatestFailedWithdrawalBundleHeight(ctx)
	if err != nil {
		return nil, err
	}
	return &pb.GetLatestFailedWithdrawalBundleHeightResponse{Height: height}, nil
}

func (h *Handler) GenerateMnemonic(ctx context.Context, req *pb.GenerateMnemonicRequest) (*pb.GenerateMnemonicResponse, error) {
	var mnemonic string
	if err := h.proxy.Client.Call(ctx, "generate_mnemonic", nil, &mnemonic); err != nil {
		return nil, err
	}
	return &pb.GenerateMnemonicResponse{Mnemonic: mnemonic}, nil
}

func (h *Handler) SetSeedFromMnemonic(ctx context.Context, req *pb.SetSeedFromMnemonicRequest) (*pb.SetSeedFromMnemonicResponse, error) {
	if err := h.proxy.Client.Call(ctx, "set_seed_from_mnemonic", []any{req.Mnemonic}, nil); err != nil {
		return nil, err
	}
	return &pb.SetSeedFromMnemonicResponse{}, nil
}

func (h *Handler) CallRaw(ctx context.Context, req *pb.CallRawRequest) (*pb.CallRawResponse, error) {
	var params any
	if req.ParamsJson != "" {
		if err := json.Unmarshal([]byte(req.ParamsJson), &params); err != nil {
			return nil, fmt.Errorf("unmarshal params: %w", err)
		}
	}
	raw, err := h.proxy.CallRaw(ctx, req.Method, params)
	if err != nil {
		return nil, err
	}
	return &pb.CallRawResponse{ResultJson: string(raw)}, nil
}

// --- CoinShift-specific methods ---

func (h *Handler) GetSidechainWealth(ctx context.Context, req *pb.GetSidechainWealthRequest) (*pb.GetSidechainWealthResponse, error) {
	var sats int64
	if err := h.proxy.Client.Call(ctx, "sidechain_wealth", nil, &sats); err != nil {
		return nil, err
	}
	return &pb.GetSidechainWealthResponse{Sats: sats}, nil
}

func (h *Handler) CreateDeposit(ctx context.Context, req *pb.CreateDepositRequest) (*pb.CreateDepositResponse, error) {
	var txid string
	params := []any{req.Address, req.ValueSats, req.FeeSats}
	if err := h.proxy.Client.Call(ctx, "create_deposit", params, &txid); err != nil {
		return nil, err
	}
	return &pb.CreateDepositResponse{Txid: txid}, nil
}

func (h *Handler) ConnectPeer(ctx context.Context, req *pb.ConnectPeerRequest) (*pb.ConnectPeerResponse, error) {
	if err := h.proxy.Client.Call(ctx, "connect_peer", []any{req.Address}, nil); err != nil {
		return nil, err
	}
	return &pb.ConnectPeerResponse{}, nil
}

func (h *Handler) ForgetPeer(ctx context.Context, req *pb.ForgetPeerRequest) (*pb.ForgetPeerResponse, error) {
	if err := h.proxy.Client.Call(ctx, "forget_peer", []any{req.Address}, nil); err != nil {
		return nil, err
	}
	return &pb.ForgetPeerResponse{}, nil
}

func (h *Handler) ListPeers(ctx context.Context, req *pb.ListPeersRequest) (*pb.ListPeersResponse, error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "list_peers", nil)
	if err != nil {
		return nil, err
	}
	return &pb.ListPeersResponse{PeersJson: string(raw)}, nil
}

func (h *Handler) GetBlock(ctx context.Context, req *pb.GetBlockRequest) (*pb.GetBlockResponse, error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "get_block", []any{req.Hash})
	if err != nil {
		return nil, err
	}
	return &pb.GetBlockResponse{BlockJson: string(raw)}, nil
}

func (h *Handler) GetBestMainchainBlockHash(ctx context.Context, req *pb.GetBestMainchainBlockHashRequest) (*pb.GetBestMainchainBlockHashResponse, error) {
	var hash string
	if err := h.proxy.Client.Call(ctx, "get_best_mainchain_block_hash", nil, &hash); err != nil {
		return nil, err
	}
	return &pb.GetBestMainchainBlockHashResponse{Hash: hash}, nil
}

func (h *Handler) GetBestSidechainBlockHash(ctx context.Context, req *pb.GetBestSidechainBlockHashRequest) (*pb.GetBestSidechainBlockHashResponse, error) {
	var hash string
	if err := h.proxy.Client.Call(ctx, "get_best_sidechain_block_hash", nil, &hash); err != nil {
		return nil, err
	}
	return &pb.GetBestSidechainBlockHashResponse{Hash: hash}, nil
}

func (h *Handler) GetBmmInclusions(ctx context.Context, req *pb.GetBmmInclusionsRequest) (*pb.GetBmmInclusionsResponse, error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "get_bmm_inclusions", []any{req.BlockHash})
	if err != nil {
		return nil, err
	}
	return &pb.GetBmmInclusionsResponse{Inclusions: string(raw)}, nil
}

func (h *Handler) GetWalletAddresses(ctx context.Context, req *pb.GetWalletAddressesRequest) (*pb.GetWalletAddressesResponse, error) {
	var addresses []string
	if err := h.proxy.Client.Call(ctx, "get_wallet_addresses", nil, &addresses); err != nil {
		return nil, err
	}
	return &pb.GetWalletAddressesResponse{Addresses: addresses}, nil
}

func (h *Handler) OpenapiSchema(ctx context.Context, req *pb.OpenapiSchemaRequest) (*pb.OpenapiSchemaResponse, error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "openapi_schema", nil)
	if err != nil {
		return nil, err
	}
	return &pb.OpenapiSchemaResponse{SchemaJson: string(raw)}, nil
}

// --- Swap methods ---

func swapIDParam(hexID string) ([32]byte, error) {
	var id [32]byte
	b, err := hex.DecodeString(hexID)
	if err != nil || len(b) != len(id) {
		return id, connect.Errorf(connect.CodeInvalidArgument,
			"swap_id must be 32 bytes hex, got %q", hexID)
	}
	copy(id[:], b)
	return id, nil
}

func (h *Handler) CreateSwap(ctx context.Context, req *pb.CreateSwapRequest) (*pb.CreateSwapResponse, error) {
	params := []any{
		req.ParentChain,
		req.L1RecipientAddress,
		req.L1AmountSats,
		req.L2Recipient,
		req.L2AmountSats,
		req.RequiredConfirmations,
		req.FeeSats,
	}
	var tuple [2]json.RawMessage
	if err := h.proxy.Client.Call(ctx, "create_swap", params, &tuple); err != nil {
		return nil, err
	}
	var swapID [32]byte
	if err := json.Unmarshal(tuple[0], &swapID); err != nil {
		return nil, fmt.Errorf("unmarshal swap id: %w", err)
	}
	var txid string
	if err := json.Unmarshal(tuple[1], &txid); err != nil {
		return nil, fmt.Errorf("unmarshal txid: %w", err)
	}
	return &pb.CreateSwapResponse{
		SwapId: hex.EncodeToString(swapID[:]),
		Txid:   txid,
	}, nil
}

func (h *Handler) ClaimSwap(ctx context.Context, req *pb.ClaimSwapRequest) (*pb.ClaimSwapResponse, error) {
	swapID, err := swapIDParam(req.SwapId)
	if err != nil {
		return nil, err
	}
	var txid string
	params := []any{swapID, req.L2ClaimerAddress}
	if err := h.proxy.Client.Call(ctx, "claim_swap", params, &txid); err != nil {
		return nil, err
	}
	return &pb.ClaimSwapResponse{Txid: txid}, nil
}

func (h *Handler) GetSwapStatus(ctx context.Context, req *pb.GetSwapStatusRequest) (*pb.GetSwapStatusResponse, error) {
	swapID, err := swapIDParam(req.SwapId)
	if err != nil {
		return nil, err
	}
	raw, err := h.proxy.Client.CallRaw(ctx, "get_swap_status", []any{swapID})
	if err != nil {
		return nil, err
	}
	return &pb.GetSwapStatusResponse{SwapJson: string(raw)}, nil
}

func (h *Handler) ListSwaps(ctx context.Context, req *pb.ListSwapsRequest) (*pb.ListSwapsResponse, error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "list_swaps", nil)
	if err != nil {
		return nil, err
	}
	return &pb.ListSwapsResponse{SwapsJson: string(raw)}, nil
}

func (h *Handler) ListSwapsByRecipient(ctx context.Context, req *pb.ListSwapsByRecipientRequest) (*pb.ListSwapsByRecipientResponse, error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "list_swaps_by_recipient", []any{req.Recipient})
	if err != nil {
		return nil, err
	}
	return &pb.ListSwapsByRecipientResponse{SwapsJson: string(raw)}, nil
}

func (h *Handler) UpdateSwapL1Txid(ctx context.Context, req *pb.UpdateSwapL1TxidRequest) (*pb.UpdateSwapL1TxidResponse, error) {
	swapID, err := swapIDParam(req.SwapId)
	if err != nil {
		return nil, err
	}
	params := []any{swapID, req.L1TxidHex, req.Confirmations}
	if err := h.proxy.Client.Call(ctx, "update_swap_l1_txid", params, nil); err != nil {
		return nil, err
	}
	return &pb.UpdateSwapL1TxidResponse{}, nil
}

func (h *Handler) ReconstructSwaps(ctx context.Context, req *pb.ReconstructSwapsRequest) (*pb.ReconstructSwapsResponse, error) {
	var count int64
	if err := h.proxy.Client.Call(ctx, "reconstruct_swaps", nil, &count); err != nil {
		return nil, err
	}
	return &pb.ReconstructSwapsResponse{Count: count}, nil
}
