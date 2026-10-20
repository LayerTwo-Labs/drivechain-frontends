package zside

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/zside/v1"
	svc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/zside/v1/zsidev1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

var _ svc.ZSideServiceHandler = (*Handler)(nil)

// Handler implements ZSideServiceHandler by proxying to the zside binary's JSON-RPC.
// Common methods delegate to the proxy field; ZSide-specific methods are
// implemented directly using the proxy's Client.
type Handler struct {
	proxy *sidechain.JSONRPCProxy
}

func NewHandler(proxy *sidechain.JSONRPCProxy) *Handler {
	return &Handler{proxy: proxy}
}

// --- Common Node methods ---

func (h *Handler) GetBalance(ctx context.Context, req *pb.GetBalanceRequest) (*pb.GetBalanceResponse, error) {
	// ZSide has a custom balance response with shielded and transparent pools
	var result struct {
		TotalShieldedSats        int64 `json:"total_shielded_sats"`
		TotalTransparentSats     int64 `json:"total_transparent_sats"`
		AvailableShieldedSats    int64 `json:"available_shielded_sats"`
		AvailableTransparentSats int64 `json:"available_transparent_sats"`
	}
	if err := h.proxy.Client.Call(ctx, "balance", nil, &result); err != nil {
		return nil, err
	}
	return &pb.GetBalanceResponse{
		TotalShieldedSats:        result.TotalShieldedSats,
		TotalTransparentSats:     result.TotalTransparentSats,
		AvailableShieldedSats:    result.AvailableShieldedSats,
		AvailableTransparentSats: result.AvailableTransparentSats,
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

func (h *Handler) Withdraw(ctx context.Context, req *pb.WithdrawRequest) (*pb.WithdrawResponse, error) {
	var txid string
	params := []any{req.Address, req.AmountSats, req.SideFeeSats, req.MainFeeSats}
	if err := h.proxy.Client.Call(ctx, "create_withdrawal", params, &txid); err != nil {
		return nil, err
	}
	return &pb.WithdrawResponse{Txid: txid}, nil
}

// Transfer sends transparent coins, the only kind a plain address holds.
func (h *Handler) Transfer(ctx context.Context, req *pb.TransferRequest) (*pb.TransferResponse, error) {
	var txid string
	params := []any{req.Address, req.AmountSats, req.FeeSats}
	if err := h.proxy.Client.Call(ctx, "create_transparent_transfer", params, &txid); err != nil {
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

// GetWalletUtxos lists the wallet coins as the mempool leaves them: a coin an
// unconfirmed transaction spends drops out, and an unconfirmed coin is marked
// "confirmed": false.
func (h *Handler) GetWalletUtxos(ctx context.Context, req *pb.GetWalletUtxosRequest) (*pb.GetWalletUtxosResponse, error) {
	var confirmed, unconfirmed []map[string]json.RawMessage
	if err := h.proxy.Client.Call(ctx, "get_wallet_utxos", nil, &confirmed); err != nil {
		return nil, err
	}
	if err := h.proxy.Client.Call(ctx, "get_wallet_utxos_unconfirmed", nil, &unconfirmed); err != nil {
		return nil, err
	}
	var spent []struct {
		Output struct {
			Outpoint json.RawMessage `json:"outpoint"`
		} `json:"output"`
	}
	if err := h.proxy.Client.Call(ctx, "get_wallet_stxos_unconfirmed", nil, &spent); err != nil {
		return nil, err
	}
	spentKeys := make(map[string]bool, len(spent))
	for _, stxo := range spent {
		key, err := outpointKey(stxo.Output.Outpoint)
		if err != nil {
			return nil, err
		}
		spentKeys[key] = true
	}

	rows := make([]map[string]json.RawMessage, 0, len(confirmed)+len(unconfirmed))
	for _, group := range []struct {
		utxos     []map[string]json.RawMessage
		confirmed bool
	}{{confirmed, true}, {unconfirmed, false}} {
		for _, utxo := range group.utxos {
			key, err := outpointKey(utxo["outpoint"])
			if err != nil {
				return nil, err
			}
			if spentKeys[key] {
				continue
			}
			if !group.confirmed {
				utxo["confirmed"] = json.RawMessage("false")
			}
			rows = append(rows, utxo)
		}
	}
	raw, err := json.Marshal(rows)
	if err != nil {
		return nil, fmt.Errorf("encode the zSide wallet coins: %w", err)
	}
	return &pb.GetWalletUtxosResponse{UtxosJson: string(raw)}, nil
}

// outpointKey is the compact JSON of an outpoint, the same for each listing of
// one coin.
func outpointKey(outpoint json.RawMessage) (string, error) {
	var compact bytes.Buffer
	if err := json.Compact(&compact, outpoint); err != nil {
		return "", fmt.Errorf("read the outpoint of a zSide coin: %w", err)
	}
	return compact.String(), nil
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

// --- ZSide-specific methods ---

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

func (h *Handler) GetNewShieldedAddress(ctx context.Context, req *pb.GetNewShieldedAddressRequest) (*pb.GetNewShieldedAddressResponse, error) {
	var address string
	if err := h.proxy.Client.Call(ctx, "get_new_shielded_address", nil, &address); err != nil {
		return nil, err
	}
	return &pb.GetNewShieldedAddressResponse{Address: address}, nil
}

func (h *Handler) GetNewTransparentAddress(ctx context.Context, req *pb.GetNewTransparentAddressRequest) (*pb.GetNewTransparentAddressResponse, error) {
	var address string
	if err := h.proxy.Client.Call(ctx, "get_new_transparent_address", nil, &address); err != nil {
		return nil, err
	}
	return &pb.GetNewTransparentAddressResponse{Address: address}, nil
}

func (h *Handler) GetShieldedWalletAddresses(ctx context.Context, req *pb.GetShieldedWalletAddressesRequest) (*pb.GetShieldedWalletAddressesResponse, error) {
	var addresses []string
	if err := h.proxy.Client.Call(ctx, "get_shielded_wallet_addresses", nil, &addresses); err != nil {
		return nil, err
	}
	return &pb.GetShieldedWalletAddressesResponse{Addresses: addresses}, nil
}

func (h *Handler) GetTransparentWalletAddresses(ctx context.Context, req *pb.GetTransparentWalletAddressesRequest) (*pb.GetTransparentWalletAddressesResponse, error) {
	var addresses []string
	if err := h.proxy.Client.Call(ctx, "get_transparent_wallet_addresses", nil, &addresses); err != nil {
		return nil, err
	}
	return &pb.GetTransparentWalletAddressesResponse{Addresses: addresses}, nil
}

func (h *Handler) Shield(ctx context.Context, req *pb.ShieldRequest) (*pb.ShieldResponse, error) {
	var txid string
	params := []any{req.AmountSats, req.FeeSats}
	if err := h.proxy.Client.Call(ctx, "create_shield", params, &txid); err != nil {
		return nil, err
	}
	return &pb.ShieldResponse{Txid: txid}, nil
}

func (h *Handler) Unshield(ctx context.Context, req *pb.UnshieldRequest) (*pb.UnshieldResponse, error) {
	var txid string
	params := []any{req.AmountSats, req.FeeSats}
	if err := h.proxy.Client.Call(ctx, "create_unshield", params, &txid); err != nil {
		return nil, err
	}
	return &pb.UnshieldResponse{Txid: txid}, nil
}

func (h *Handler) ShieldedTransfer(ctx context.Context, req *pb.ShieldedTransferRequest) (*pb.ShieldedTransferResponse, error) {
	var txid string
	params := []any{req.Address, req.AmountSats, req.FeeSats}
	if err := h.proxy.Client.Call(ctx, "create_shielded_transfer", params, &txid); err != nil {
		return nil, err
	}
	return &pb.ShieldedTransferResponse{Txid: txid}, nil
}

func (h *Handler) TransparentTransfer(ctx context.Context, req *pb.TransparentTransferRequest) (*pb.TransparentTransferResponse, error) {
	var txid string
	params := []any{req.Address, req.AmountSats, req.FeeSats}
	if err := h.proxy.Client.Call(ctx, "create_transparent_transfer", params, &txid); err != nil {
		return nil, err
	}
	return &pb.TransparentTransferResponse{Txid: txid}, nil
}
