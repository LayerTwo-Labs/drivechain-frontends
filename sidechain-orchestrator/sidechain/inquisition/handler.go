package inquisition

import (
	"context"
	"encoding/json"
	"fmt"
	"math"

	"connectrpc.com/connect"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/inquisition/v1"
	svc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/inquisition/v1/inquisitionv1connect"
)

var _ svc.InquisitionServiceHandler = (*Handler)(nil)

// Handler implements InquisitionServiceHandler over the node's Core JSON-RPC.
type Handler struct {
	client *Client
}

func NewHandler(client *Client) *Handler {
	return &Handler{client: client}
}

func (h *Handler) GetBalance(ctx context.Context, _ *connect.Request[pb.GetBalanceRequest]) (*connect.Response[pb.GetBalanceResponse], error) {
	total, available, err := h.client.GetBalance(ctx)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetBalanceResponse{TotalSats: total, AvailableSats: available}), nil
}

func (h *Handler) GetBlockCount(ctx context.Context, _ *connect.Request[pb.GetBlockCountRequest]) (*connect.Response[pb.GetBlockCountResponse], error) {
	count, err := h.client.GetBlockCount(ctx)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetBlockCountResponse{Count: count}), nil
}

func (h *Handler) GetBlockchainInfo(ctx context.Context, _ *connect.Request[pb.GetBlockchainInfoRequest]) (*connect.Response[pb.GetBlockchainInfoResponse], error) {
	raw, err := h.client.GetBlockchainInfo(ctx)
	if err != nil {
		return nil, err
	}
	var info struct {
		Chain                string   `json:"chain"`
		Blocks               int64    `json:"blocks"`
		Headers              int64    `json:"headers"`
		BestBlockHash        string   `json:"bestblockhash"`
		Difficulty           float64  `json:"difficulty"`
		Time                 int64    `json:"time"`
		MedianTime           int64    `json:"mediantime"`
		VerificationProgress float64  `json:"verificationprogress"`
		InitialBlockDownload bool     `json:"initialblockdownload"`
		ChainWork            string   `json:"chainwork"`
		SizeOnDisk           int64    `json:"size_on_disk"`
		Pruned               bool     `json:"pruned"`
		Warnings             []string `json:"warnings"`
	}
	if err := json.Unmarshal(raw, &info); err != nil {
		return nil, fmt.Errorf("decode getblockchaininfo result: %w", err)
	}
	return connect.NewResponse(&pb.GetBlockchainInfoResponse{
		Chain:                info.Chain,
		Blocks:               info.Blocks,
		Headers:              info.Headers,
		BestBlockHash:        info.BestBlockHash,
		Difficulty:           info.Difficulty,
		Time:                 info.Time,
		MedianTime:           info.MedianTime,
		VerificationProgress: info.VerificationProgress,
		InitialBlockDownload: info.InitialBlockDownload,
		ChainWork:            info.ChainWork,
		SizeOnDisk:           info.SizeOnDisk,
		Pruned:               info.Pruned,
		Warnings:             info.Warnings,
	}), nil
}

func (h *Handler) GetSidechainInfo(ctx context.Context, _ *connect.Request[pb.GetSidechainInfoRequest]) (*connect.Response[pb.GetSidechainInfoResponse], error) {
	info, err := h.client.GetSidechainInfo(ctx)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetSidechainInfoResponse{
		Synced:       info.Synced,
		MainchainTip: info.MainchainTip,
		LastError:    info.LastError,
	}), nil
}

func (h *Handler) GetMainchainTip(ctx context.Context, _ *connect.Request[pb.GetMainchainTipRequest]) (*connect.Response[pb.GetMainchainTipResponse], error) {
	hash, err := h.client.GetMainchainTip(ctx)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetMainchainTipResponse{BlockHash: hash}), nil
}

func (h *Handler) GetBmmCommitment(ctx context.Context, req *connect.Request[pb.GetBmmCommitmentRequest]) (*connect.Response[pb.GetBmmCommitmentResponse], error) {
	commitment, err := h.client.GetBmmCommitment(ctx, req.Msg.MainchainBlockHash)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetBmmCommitmentResponse{Commitment: commitment}), nil
}

func (h *Handler) GetNewAddress(ctx context.Context, _ *connect.Request[pb.GetNewAddressRequest]) (*connect.Response[pb.GetNewAddressResponse], error) {
	address, err := h.client.GetNewAddress(ctx)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetNewAddressResponse{Address: address}), nil
}

func (h *Handler) Send(ctx context.Context, req *connect.Request[pb.SendRequest]) (*connect.Response[pb.SendResponse], error) {
	txid, err := h.client.SendToAddress(ctx, req.Msg.Address, req.Msg.AmountSats, req.Msg.SubtractFeeFromAmount)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.SendResponse{Txid: txid}), nil
}

func (h *Handler) EstimateFee(ctx context.Context, _ *connect.Request[pb.EstimateFeeRequest]) (*connect.Response[pb.EstimateFeeResponse], error) {
	feeRate, err := h.client.EstimateSmartFee(ctx)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.EstimateFeeResponse{SatsPerKvb: int64(math.Round(feeRate * 1e8))}), nil
}

func (h *Handler) ListUtxos(ctx context.Context, _ *connect.Request[pb.ListUtxosRequest]) (*connect.Response[pb.ListUtxosResponse], error) {
	unspent, err := h.client.ListUnspent(ctx)
	if err != nil {
		return nil, err
	}
	utxos := make([]*pb.Utxo, 0, len(unspent))
	for _, u := range unspent {
		utxos = append(utxos, &pb.Utxo{
			Txid:          u.Txid,
			Vout:          u.Vout,
			Address:       u.Address,
			ValueSats:     btcToSats(u.Amount),
			Confirmations: u.Confirmations,
		})
	}
	return connect.NewResponse(&pb.ListUtxosResponse{Utxos: utxos}), nil
}

func (h *Handler) ListTransactions(ctx context.Context, req *connect.Request[pb.ListTransactionsRequest]) (*connect.Response[pb.ListTransactionsResponse], error) {
	count := int(req.Msg.Count)
	if count <= 0 {
		count = 100
	}
	txs, err := h.client.ListTransactions(ctx, count)
	if err != nil {
		return nil, err
	}
	out := make([]*pb.Transaction, 0, len(txs))
	for _, tx := range txs {
		out = append(out, &pb.Transaction{
			Txid:          tx.Txid,
			AmountSats:    btcToSats(tx.Amount),
			Confirmations: tx.Confirmations,
			Time:          tx.Time,
			Address:       tx.Address,
			Category:      tx.Category,
		})
	}
	return connect.NewResponse(&pb.ListTransactionsResponse{Transactions: out}), nil
}

func (h *Handler) Stop(ctx context.Context, _ *connect.Request[pb.StopRequest]) (*connect.Response[pb.StopResponse], error) {
	if err := h.client.Stop(ctx); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.StopResponse{}), nil
}
