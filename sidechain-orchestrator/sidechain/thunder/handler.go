package thunder

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"

	"connectrpc.com/connect/v2"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/thunder/v1"
	svc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/thunder/v1/thunderv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/sidechainesplora"
)

var _ svc.ThunderServiceHandler = (*Handler)(nil)

// Handler serves Thunder RPCs through the local node.
type Handler struct {
	proxy     *sidechain.JSONRPCProxy
	backend   *nodeBackend
	history   HistorySource
	addresses AddressSource
}

func NewHandler(proxy *sidechain.JSONRPCProxy) *Handler {
	return NewHandlerWithIndex(proxy, "")
}

// NewHandlerWithIndex uses an optional Esplora URL for history and the local node for wallet RPCs.
func NewHandlerWithIndex(proxy *sidechain.JSONRPCProxy, indexURL string) *Handler {
	var history HistorySource = newNodeHistory(proxy)
	if indexURL != "" {
		history = sidechainesplora.NewWallet(sidechainesplora.New(indexURL))
	}
	return &Handler{
		proxy:     proxy,
		backend:   newNodeBackend(proxy),
		history:   history,
		addresses: newNodeAddresses(proxy),
	}
}

// WalletBalance returns the local wallet balance.
func (h *Handler) WalletBalance(ctx context.Context) (int64, int64, error) {
	return h.backend.Balance(ctx)
}

// --- Common Node methods ---

func (h *Handler) GetBalance(ctx context.Context, req *pb.GetBalanceRequest) (*pb.GetBalanceResponse, error) {
	total, available, err := h.backend.Balance(ctx)
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
	address, err := h.backend.NewAddress(ctx)
	if err != nil {
		return nil, err
	}
	return &pb.GetNewAddressResponse{Address: address}, nil
}

func (h *Handler) Withdraw(ctx context.Context, req *pb.WithdrawRequest) (*pb.WithdrawResponse, error) {
	txid, err := h.backend.Withdraw(ctx, req.Address,
		req.AmountSats, req.SideFeeSats, req.MainFeeSats)
	if err != nil {
		return nil, err
	}
	return &pb.WithdrawResponse{Txid: txid}, nil
}

func (h *Handler) Transfer(ctx context.Context, req *pb.TransferRequest) (*pb.TransferResponse, error) {
	txid, err := h.backend.Transfer(ctx, req.Address, req.AmountSats, req.FeeSats)
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
	raw, err := h.backend.UTXOs(ctx)
	if err != nil {
		return nil, err
	}
	raw, err = sidechain.WithMempoolUTXOs(ctx, h.proxy, raw)
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

func (h *Handler) GetLatestFailedWithdrawalBundleHeight(ctx context.Context, req *pb.GetLatestFailedWithdrawalBundleHeightRequest) (*pb.GetLatestFailedWithdrawalBundleHeightResponse, error) {
	height, err := h.proxy.GetLatestFailedWithdrawalBundleHeight(ctx)
	if err != nil {
		return nil, err
	}
	return &pb.GetLatestFailedWithdrawalBundleHeightResponse{Height: height}, nil
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

// --- Thunder-specific methods ---

func (h *Handler) GetSidechainWealth(ctx context.Context, req *pb.GetSidechainWealthRequest) (*pb.GetSidechainWealthResponse, error) {
	var sats int64
	if err := h.proxy.Client.Call(ctx, "sidechain_wealth", nil, &sats); err != nil {
		return nil, err
	}
	return &pb.GetSidechainWealthResponse{Sats: sats}, nil
}

func (h *Handler) CreateDeposit(ctx context.Context, req *pb.CreateDepositRequest) (*pb.CreateDepositResponse, error) {
	var txid string
	params := map[string]any{
		"address":    req.Address,
		"value_sats": req.ValueSats,
		"fee_sats":   req.FeeSats,
	}
	if err := h.proxy.Client.Call(ctx, "create_deposit", params, &txid); err != nil {
		return nil, err
	}
	return &pb.CreateDepositResponse{Txid: txid}, nil
}

func (h *Handler) ConnectPeer(ctx context.Context, req *pb.ConnectPeerRequest) (*pb.ConnectPeerResponse, error) {
	// The node takes positional params. A bare string reads as neither, and it
	// answers "Invalid params".
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

func (h *Handler) RemoveFromMempool(ctx context.Context, req *pb.RemoveFromMempoolRequest) (*pb.RemoveFromMempoolResponse, error) {
	if err := h.proxy.Client.Call(ctx, "remove_from_mempool", []any{req.Txid}, nil); err != nil {
		return nil, err
	}
	return &pb.RemoveFromMempoolResponse{}, nil
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

// ListWalletTransactions returns history from the node or the explicit index URL.
func (h *Handler) ListWalletTransactions(
	ctx context.Context, req *pb.ListWalletTransactionsRequest,
) (*pb.ListWalletTransactionsResponse, error) {
	addresses, err := h.addresses.Addresses(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable,
			fmt.Errorf("read wallet addresses: %w", err).Error())
	}
	if len(addresses) == 0 {
		return &pb.ListWalletTransactionsResponse{}, nil
	}

	entries, err := h.history.History(ctx, addresses)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable,
			fmt.Errorf("read wallet history: %w", err).Error())
	}

	// An index with no blocks yet has no tip, and a wallet on a new chain
	// still reads its own history. Every entry then counts zero confirmations.
	tip, err := h.history.TipHeight(ctx)
	if err != nil && !errors.Is(err, sidechainesplora.ErrEmptyIndex) {
		return nil, connect.NewError(connect.CodeUnavailable,
			fmt.Errorf("read the chain tip: %w", err).Error())
	}

	out := make([]*pb.SidechainWalletTransaction, 0, len(entries))
	for _, entry := range entries {
		out = append(out, &pb.SidechainWalletTransaction{
			Txid:        entry.Txid,
			ValueSats:   entry.ValueSats,
			FeeSats:     entry.FeeSats,
			BlockHeight: entry.BlockHeight,
			BlockTime:   entry.BlockTime,
			Confirmed:   entry.Confirmed,
			Vout:        entry.Vout,
		})
	}
	return &pb.ListWalletTransactionsResponse{
		Transactions: out,
		TipHeight:    tip,
	}, nil
}
