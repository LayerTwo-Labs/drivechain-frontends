package truthcoin

import (
	"context"
	"encoding/json"
	"fmt"

	"connectrpc.com/connect"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/truthcoin/v1"
	svc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/truthcoin/v1/truthcoinv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

var _ svc.TruthcoinServiceHandler = (*Handler)(nil)

// Handler implements TruthcoinServiceHandler by proxying to the truthcoin binary's JSON-RPC.
// Common methods delegate to the embedded JSONRPCProxy; Truthcoin-specific methods are
// implemented directly using the proxy's Client.
type Handler struct {
	proxy *sidechain.JSONRPCProxy
}

func NewHandler(proxy *sidechain.JSONRPCProxy) *Handler {
	return &Handler{proxy: proxy}
}

// --- Common SidechainRPCProxy methods ---

func (h *Handler) GetBalance(ctx context.Context, req *connect.Request[pb.GetBalanceRequest]) (*connect.Response[pb.GetBalanceResponse], error) {
	// Truthcoin uses "bitcoin_balance" instead of "balance"
	var result struct {
		TotalSats     int64 `json:"total_sats"`
		AvailableSats int64 `json:"available_sats"`
	}
	if err := h.proxy.Client.Call(ctx, "bitcoin_balance", nil, &result); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetBalanceResponse{
		TotalSats:     result.TotalSats,
		AvailableSats: result.AvailableSats,
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

// --- Truthcoin-specific methods ---

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

func (h *Handler) RefreshWallet(ctx context.Context, req *connect.Request[pb.RefreshWalletRequest]) (*connect.Response[pb.RefreshWalletResponse], error) {
	if err := h.proxy.Client.Call(ctx, "refresh_wallet", nil, nil); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.RefreshWalletResponse{}), nil
}

func (h *Handler) GetTransaction(ctx context.Context, req *connect.Request[pb.GetTransactionRequest]) (*connect.Response[pb.GetTransactionResponse], error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "get_transaction", req.Msg.Txid)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetTransactionResponse{TransactionJson: string(raw)}), nil
}

func (h *Handler) GetTransactionInfo(ctx context.Context, req *connect.Request[pb.GetTransactionInfoRequest]) (*connect.Response[pb.GetTransactionInfoResponse], error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "get_transaction_info", req.Msg.Txid)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetTransactionInfoResponse{TransactionInfoJson: string(raw)}), nil
}

func (h *Handler) GetWalletAddresses(ctx context.Context, req *connect.Request[pb.GetWalletAddressesRequest]) (*connect.Response[pb.GetWalletAddressesResponse], error) {
	var addresses []string
	if err := h.proxy.Client.Call(ctx, "get_wallet_addresses", nil, &addresses); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetWalletAddressesResponse{Addresses: addresses}), nil
}

func (h *Handler) MyUtxos(ctx context.Context, req *connect.Request[pb.MyUtxosRequest]) (*connect.Response[pb.MyUtxosResponse], error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "my_utxos", nil)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.MyUtxosResponse{UtxosJson: string(raw)}), nil
}

func (h *Handler) MyUnconfirmedUtxos(ctx context.Context, req *connect.Request[pb.MyUnconfirmedUtxosRequest]) (*connect.Response[pb.MyUnconfirmedUtxosResponse], error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "my_unconfirmed_utxos", nil)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.MyUnconfirmedUtxosResponse{UtxosJson: string(raw)}), nil
}

// --- Prediction Markets ---

func (h *Handler) CalculateInitialLiquidity(ctx context.Context, req *connect.Request[pb.CalculateInitialLiquidityRequest]) (*connect.Response[pb.CalculateInitialLiquidityResponse], error) {
	params := []any{req.Msg.Beta, req.Msg.NumOutcomes, req.Msg.Dimensions}
	raw, err := h.proxy.Client.CallRaw(ctx, "calculate_initial_liquidity", params)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.CalculateInitialLiquidityResponse{ResultJson: string(raw)}), nil
}

func (h *Handler) MarketCreate(ctx context.Context, req *connect.Request[pb.MarketCreateRequest]) (*connect.Response[pb.MarketCreateResponse], error) {
	var txid string
	params := []any{
		req.Msg.Title,
		req.Msg.Description,
		req.Msg.Dimensions,
		req.Msg.FeeSats,
		req.Msg.Beta,
		req.Msg.InitialLiquidity,
		req.Msg.TradingFee,
		req.Msg.Tags,
		req.Msg.CategoryTxids,
		req.Msg.ResidualNames,
	}
	if err := h.proxy.Client.Call(ctx, "market_create", params, &txid); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.MarketCreateResponse{Txid: txid}), nil
}

func (h *Handler) MarketList(ctx context.Context, req *connect.Request[pb.MarketListRequest]) (*connect.Response[pb.MarketListResponse], error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "market_list", nil)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.MarketListResponse{MarketsJson: string(raw)}), nil
}

func (h *Handler) MarketGet(ctx context.Context, req *connect.Request[pb.MarketGetRequest]) (*connect.Response[pb.MarketGetResponse], error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "market_get", req.Msg.MarketId)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.MarketGetResponse{MarketJson: string(raw)}), nil
}

func (h *Handler) MarketBuy(ctx context.Context, req *connect.Request[pb.MarketBuyRequest]) (*connect.Response[pb.MarketBuyResponse], error) {
	params := []any{
		req.Msg.MarketId,
		req.Msg.OutcomeIndex,
		req.Msg.SharesAmount,
		req.Msg.DryRun,
		req.Msg.FeeSats,
		req.Msg.MaxCost,
	}
	raw, err := h.proxy.Client.CallRaw(ctx, "market_buy", params)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.MarketBuyResponse{ResultJson: string(raw)}), nil
}

func (h *Handler) MarketSell(ctx context.Context, req *connect.Request[pb.MarketSellRequest]) (*connect.Response[pb.MarketSellResponse], error) {
	params := []any{
		req.Msg.MarketId,
		req.Msg.OutcomeIndex,
		req.Msg.SharesAmount,
		req.Msg.SellerAddress,
		req.Msg.DryRun,
		req.Msg.FeeSats,
		req.Msg.MinProceeds,
	}
	raw, err := h.proxy.Client.CallRaw(ctx, "market_sell", params)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.MarketSellResponse{ResultJson: string(raw)}), nil
}

func (h *Handler) MarketPositions(ctx context.Context, req *connect.Request[pb.MarketPositionsRequest]) (*connect.Response[pb.MarketPositionsResponse], error) {
	params := []any{req.Msg.Address, req.Msg.MarketId}
	raw, err := h.proxy.Client.CallRaw(ctx, "market_positions", params)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.MarketPositionsResponse{PositionsJson: string(raw)}), nil
}

// --- Slots ---

func (h *Handler) SlotStatus(ctx context.Context, req *connect.Request[pb.SlotStatusRequest]) (*connect.Response[pb.SlotStatusResponse], error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "slot_status", nil)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.SlotStatusResponse{StatusJson: string(raw)}), nil
}

func (h *Handler) SlotList(ctx context.Context, req *connect.Request[pb.SlotListRequest]) (*connect.Response[pb.SlotListResponse], error) {
	params := []any{req.Msg.Period, req.Msg.Status}
	raw, err := h.proxy.Client.CallRaw(ctx, "slot_list", params)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.SlotListResponse{SlotsJson: string(raw)}), nil
}

func (h *Handler) SlotGet(ctx context.Context, req *connect.Request[pb.SlotGetRequest]) (*connect.Response[pb.SlotGetResponse], error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "slot_get", req.Msg.SlotId)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.SlotGetResponse{SlotJson: string(raw)}), nil
}

func (h *Handler) SlotClaim(ctx context.Context, req *connect.Request[pb.SlotClaimRequest]) (*connect.Response[pb.SlotClaimResponse], error) {
	var txid string
	params := []any{
		req.Msg.FeeSats,
		req.Msg.PeriodIndex,
		req.Msg.SlotIndex,
		req.Msg.Question,
		req.Msg.IsStandard,
		req.Msg.IsScaled,
		req.Msg.Min,
		req.Msg.Max,
	}
	if err := h.proxy.Client.Call(ctx, "slot_claim", params, &txid); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.SlotClaimResponse{Txid: txid}), nil
}

func (h *Handler) SlotClaimCategory(ctx context.Context, req *connect.Request[pb.SlotClaimCategoryRequest]) (*connect.Response[pb.SlotClaimCategoryResponse], error) {
	var slots any
	if req.Msg.SlotsJson != "" {
		if err := json.Unmarshal([]byte(req.Msg.SlotsJson), &slots); err != nil {
			return nil, fmt.Errorf("unmarshal slots: %w", err)
		}
	}
	var txid string
	params := []any{slots, req.Msg.IsStandard, req.Msg.FeeSats}
	if err := h.proxy.Client.Call(ctx, "slot_claim_category", params, &txid); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.SlotClaimCategoryResponse{Txid: txid}), nil
}

// --- Voting ---

func (h *Handler) VoteRegister(ctx context.Context, req *connect.Request[pb.VoteRegisterRequest]) (*connect.Response[pb.VoteRegisterResponse], error) {
	var txid string
	params := []any{req.Msg.FeeSats, req.Msg.ReputationBondSats}
	if err := h.proxy.Client.Call(ctx, "vote_register", params, &txid); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.VoteRegisterResponse{Txid: txid}), nil
}

func (h *Handler) VoteVoter(ctx context.Context, req *connect.Request[pb.VoteVoterRequest]) (*connect.Response[pb.VoteVoterResponse], error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "vote_voter", req.Msg.Address)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.VoteVoterResponse{VoterJson: string(raw)}), nil
}

func (h *Handler) VoteVoters(ctx context.Context, req *connect.Request[pb.VoteVotersRequest]) (*connect.Response[pb.VoteVotersResponse], error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "vote_voters", nil)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.VoteVotersResponse{VotersJson: string(raw)}), nil
}

func (h *Handler) VoteSubmit(ctx context.Context, req *connect.Request[pb.VoteSubmitRequest]) (*connect.Response[pb.VoteSubmitResponse], error) {
	var votes any
	if req.Msg.VotesJson != "" {
		if err := json.Unmarshal([]byte(req.Msg.VotesJson), &votes); err != nil {
			return nil, fmt.Errorf("unmarshal votes: %w", err)
		}
	}
	var txid string
	params := []any{votes, req.Msg.FeeSats}
	if err := h.proxy.Client.Call(ctx, "vote_submit", params, &txid); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.VoteSubmitResponse{Txid: txid}), nil
}

func (h *Handler) VoteList(ctx context.Context, req *connect.Request[pb.VoteListRequest]) (*connect.Response[pb.VoteListResponse], error) {
	params := []any{req.Msg.Voter, req.Msg.DecisionId, req.Msg.PeriodId}
	raw, err := h.proxy.Client.CallRaw(ctx, "vote_list", params)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.VoteListResponse{VotesJson: string(raw)}), nil
}

func (h *Handler) VotePeriod(ctx context.Context, req *connect.Request[pb.VotePeriodRequest]) (*connect.Response[pb.VotePeriodResponse], error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "vote_period", req.Msg.PeriodId)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.VotePeriodResponse{PeriodJson: string(raw)}), nil
}

// --- Votecoin ---

func (h *Handler) VotecoinTransfer(ctx context.Context, req *connect.Request[pb.VotecoinTransferRequest]) (*connect.Response[pb.VotecoinTransferResponse], error) {
	var txid string
	params := []any{req.Msg.Dest, req.Msg.Amount, req.Msg.FeeSats, req.Msg.Memo}
	if err := h.proxy.Client.Call(ctx, "votecoin_transfer", params, &txid); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.VotecoinTransferResponse{Txid: txid}), nil
}

func (h *Handler) VotecoinBalance(ctx context.Context, req *connect.Request[pb.VotecoinBalanceRequest]) (*connect.Response[pb.VotecoinBalanceResponse], error) {
	var balance int64
	if err := h.proxy.Client.Call(ctx, "votecoin_balance", req.Msg.Address, &balance); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.VotecoinBalanceResponse{Balance: balance}), nil
}

func (h *Handler) TransferVotecoin(ctx context.Context, req *connect.Request[pb.TransferVotecoinRequest]) (*connect.Response[pb.TransferVotecoinResponse], error) {
	var txid string
	params := []any{req.Msg.Dest, req.Msg.Amount, req.Msg.FeeSats, req.Msg.Memo}
	if err := h.proxy.Client.Call(ctx, "transfer_votecoin", params, &txid); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.TransferVotecoinResponse{Txid: txid}), nil
}

// --- Crypto utilities ---

func (h *Handler) GetNewEncryptionKey(ctx context.Context, req *connect.Request[pb.GetNewEncryptionKeyRequest]) (*connect.Response[pb.GetNewEncryptionKeyResponse], error) {
	var key string
	if err := h.proxy.Client.Call(ctx, "get_new_encryption_key", nil, &key); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetNewEncryptionKeyResponse{Key: key}), nil
}

func (h *Handler) GetNewVerifyingKey(ctx context.Context, req *connect.Request[pb.GetNewVerifyingKeyRequest]) (*connect.Response[pb.GetNewVerifyingKeyResponse], error) {
	var key string
	if err := h.proxy.Client.Call(ctx, "get_new_verifying_key", nil, &key); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetNewVerifyingKeyResponse{Key: key}), nil
}

func (h *Handler) EncryptMsg(ctx context.Context, req *connect.Request[pb.EncryptMsgRequest]) (*connect.Response[pb.EncryptMsgResponse], error) {
	var ciphertext string
	params := []any{req.Msg.EncryptionPubkey, req.Msg.Msg}
	if err := h.proxy.Client.Call(ctx, "encrypt_msg", params, &ciphertext); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.EncryptMsgResponse{Ciphertext: ciphertext}), nil
}

func (h *Handler) DecryptMsg(ctx context.Context, req *connect.Request[pb.DecryptMsgRequest]) (*connect.Response[pb.DecryptMsgResponse], error) {
	var plaintext string
	params := []any{req.Msg.EncryptionPubkey, req.Msg.Ciphertext}
	if err := h.proxy.Client.Call(ctx, "decrypt_msg", params, &plaintext); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.DecryptMsgResponse{Plaintext: plaintext}), nil
}

func (h *Handler) SignArbitraryMsg(ctx context.Context, req *connect.Request[pb.SignArbitraryMsgRequest]) (*connect.Response[pb.SignArbitraryMsgResponse], error) {
	var signature string
	params := []any{req.Msg.Msg, req.Msg.VerifyingKey}
	if err := h.proxy.Client.Call(ctx, "sign_arbitrary_msg", params, &signature); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.SignArbitraryMsgResponse{Signature: signature}), nil
}

func (h *Handler) SignArbitraryMsgAsAddr(ctx context.Context, req *connect.Request[pb.SignArbitraryMsgAsAddrRequest]) (*connect.Response[pb.SignArbitraryMsgAsAddrResponse], error) {
	var result struct {
		VerifyingKey string `json:"verifying_key"`
		Signature    string `json:"signature"`
	}
	params := []any{req.Msg.Msg, req.Msg.Address}
	if err := h.proxy.Client.Call(ctx, "sign_arbitrary_msg_as_addr", params, &result); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.SignArbitraryMsgAsAddrResponse{
		VerifyingKey: result.VerifyingKey,
		Signature:    result.Signature,
	}), nil
}

func (h *Handler) VerifySignature(ctx context.Context, req *connect.Request[pb.VerifySignatureRequest]) (*connect.Response[pb.VerifySignatureResponse], error) {
	var valid bool
	params := []any{req.Msg.Msg, req.Msg.Signature, req.Msg.VerifyingKey, req.Msg.Dst}
	if err := h.proxy.Client.Call(ctx, "verify_signature", params, &valid); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.VerifySignatureResponse{Valid: valid}), nil
}
