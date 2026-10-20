package truthcoin

import (
	"context"
	"encoding/json"
	"fmt"

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

// WalletBalance returns the local wallet balance, in sats.
func (h *Handler) WalletBalance(ctx context.Context) (total, available int64, err error) {
	var result struct {
		TotalSats     int64 `json:"total_sats"`
		AvailableSats int64 `json:"available_sats"`
	}
	if err := h.proxy.Client.Call(ctx, "balance", nil, &result); err != nil {
		return 0, 0, err
	}
	return result.TotalSats, result.AvailableSats, nil
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
	params := []any{req.Address, req.AmountSats, req.SideFeeSats, req.MainFeeSats}
	var txid string
	if err := h.proxy.Client.Call(ctx, "create_withdrawal", params, &txid); err != nil {
		return nil, err
	}
	return &pb.WithdrawResponse{Txid: txid}, nil
}

func (h *Handler) Transfer(ctx context.Context, req *pb.TransferRequest) (*pb.TransferResponse, error) {
	params := []any{req.Address, req.AmountSats, req.FeeSats}
	var txid string
	if err := h.proxy.Client.Call(ctx, "create_transfer", params, &txid); err != nil {
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

// --- Truthcoin-specific methods ---

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
	return &pb.GetBlockResponse{BlockJson: optionalJSON(raw)}, nil
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

func (h *Handler) RefreshWallet(ctx context.Context, req *pb.RefreshWalletRequest) (*pb.RefreshWalletResponse, error) {
	if err := h.proxy.Client.Call(ctx, "refresh_wallet", nil, nil); err != nil {
		return nil, err
	}
	return &pb.RefreshWalletResponse{}, nil
}

func (h *Handler) GetTransaction(ctx context.Context, req *pb.GetTransactionRequest) (*pb.GetTransactionResponse, error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "get_transaction", []any{req.Txid})
	if err != nil {
		return nil, err
	}
	return &pb.GetTransactionResponse{TransactionJson: string(raw)}, nil
}

func (h *Handler) GetTransactionInfo(ctx context.Context, req *pb.GetTransactionInfoRequest) (*pb.GetTransactionInfoResponse, error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "get_transaction_info", []any{req.Txid})
	if err != nil {
		return nil, err
	}
	return &pb.GetTransactionInfoResponse{TransactionInfoJson: string(raw)}, nil
}

func (h *Handler) GetWalletAddresses(ctx context.Context, req *pb.GetWalletAddressesRequest) (*pb.GetWalletAddressesResponse, error) {
	var addresses []string
	if err := h.proxy.Client.Call(ctx, "get_wallet_addresses", nil, &addresses); err != nil {
		return nil, err
	}
	return &pb.GetWalletAddressesResponse{Addresses: addresses}, nil
}

func (h *Handler) MyUtxos(ctx context.Context, req *pb.MyUtxosRequest) (*pb.MyUtxosResponse, error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "get_wallet_utxos", nil)
	if err != nil {
		return nil, err
	}
	return &pb.MyUtxosResponse{UtxosJson: string(raw)}, nil
}

func (h *Handler) MyUnconfirmedUtxos(ctx context.Context, req *pb.MyUnconfirmedUtxosRequest) (*pb.MyUnconfirmedUtxosResponse, error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "my_unconfirmed_utxos", nil)
	if err != nil {
		return nil, err
	}
	return &pb.MyUnconfirmedUtxosResponse{UtxosJson: string(raw)}, nil
}

// --- Prediction Markets ---

func (h *Handler) CalculateInitialLiquidity(ctx context.Context, req *pb.CalculateInitialLiquidityRequest) (*pb.CalculateInitialLiquidityResponse, error) {
	request := map[string]any{"beta": req.Beta}
	if req.NumOutcomes != nil {
		request["num_outcomes"] = *req.NumOutcomes
	}
	if req.Dimensions != nil {
		request["dimensions"] = *req.Dimensions
	}
	raw, err := h.proxy.Client.CallRaw(ctx, "calculate_initial_liquidity", []any{request})
	if err != nil {
		return nil, err
	}
	return &pb.CalculateInitialLiquidityResponse{ResultJson: string(raw)}, nil
}

func (h *Handler) MarketCreate(ctx context.Context, req *pb.MarketCreateRequest) (*pb.MarketCreateResponse, error) {
	var dimensions []any
	if err := json.Unmarshal([]byte(req.Dimensions), &dimensions); err != nil {
		return nil, fmt.Errorf("unmarshal dimensions: %w", err)
	}
	request := map[string]any{
		"title":       req.Title,
		"description": req.Description,
		"dimensions":  dimensions,
		"tx_fee_sats": req.FeeSats,
	}
	if req.Beta != nil {
		request["beta"] = *req.Beta
	}
	if req.TradingFee != nil {
		request["trading_fee"] = *req.TradingFee
	}
	if req.InitialLiquidity != nil {
		request["initial_liquidity"] = *req.InitialLiquidity
	}
	var result struct {
		Txid string `json:"txid"`
	}
	if err := h.proxy.Client.Call(ctx, "market_create", []any{request}, &result); err != nil {
		return nil, err
	}
	return &pb.MarketCreateResponse{Txid: result.Txid}, nil
}

func (h *Handler) MarketList(ctx context.Context, req *pb.MarketListRequest) (*pb.MarketListResponse, error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "market_list", nil)
	if err != nil {
		return nil, err
	}
	return &pb.MarketListResponse{MarketsJson: string(raw)}, nil
}

func (h *Handler) MarketGet(ctx context.Context, req *pb.MarketGetRequest) (*pb.MarketGetResponse, error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "market_get", []any{req.MarketId})
	if err != nil {
		return nil, err
	}
	return &pb.MarketGetResponse{MarketJson: optionalJSON(raw)}, nil
}

func (h *Handler) MarketBuy(ctx context.Context, req *pb.MarketBuyRequest) (*pb.MarketBuyResponse, error) {
	request := map[string]any{
		"market_id":     req.MarketId,
		"outcome_index": req.OutcomeIndex,
		"shares_amount": int64(req.SharesAmount),
	}
	if req.DryRun != nil {
		request["dry_run"] = *req.DryRun
	}
	if req.MaxCost != nil {
		request["max_cost"] = *req.MaxCost
	}
	raw, err := h.proxy.Client.CallRaw(ctx, "market_buy", []any{request})
	if err != nil {
		return nil, err
	}
	return &pb.MarketBuyResponse{ResultJson: string(raw)}, nil
}

func (h *Handler) MarketSell(ctx context.Context, req *pb.MarketSellRequest) (*pb.MarketSellResponse, error) {
	request := map[string]any{
		"market_id":      req.MarketId,
		"outcome_index":  req.OutcomeIndex,
		"shares_amount":  req.SharesAmount,
		"seller_address": req.SellerAddress,
	}
	if req.DryRun != nil {
		request["dry_run"] = *req.DryRun
	}
	if req.MinProceeds != nil {
		request["min_proceeds"] = *req.MinProceeds
	}
	raw, err := h.proxy.Client.CallRaw(ctx, "market_sell", []any{request})
	if err != nil {
		return nil, err
	}
	return &pb.MarketSellResponse{ResultJson: string(raw)}, nil
}

func (h *Handler) MarketPositions(ctx context.Context, req *pb.MarketPositionsRequest) (*pb.MarketPositionsResponse, error) {
	params := []any{req.Address, req.MarketId}
	raw, err := h.proxy.Client.CallRaw(ctx, "market_positions", params)
	if err != nil {
		return nil, err
	}
	return &pb.MarketPositionsResponse{PositionsJson: string(raw)}, nil
}

func (h *Handler) MarketAmplifyBeta(ctx context.Context, req *pb.MarketAmplifyBetaRequest) (*pb.MarketAmplifyBetaResponse, error) {
	request := map[string]any{
		"market_id":   req.MarketId,
		"amount_sats": req.AmountSats,
	}
	var txid string
	if err := h.proxy.Client.Call(ctx, "market_amplify_beta", []any{request}, &txid); err != nil {
		return nil, err
	}
	return &pb.MarketAmplifyBetaResponse{Txid: txid}, nil
}

// --- Slots ---

func (h *Handler) claimDecisions(ctx context.Context, claim map[string]any) (string, error) {
	var result struct {
		Txid string `json:"txid"`
	}
	if err := h.proxy.Client.Call(ctx, "decision_claim", []any{claim}, &result); err != nil {
		return "", err
	}
	return result.Txid, nil
}

func (h *Handler) SlotStatus(ctx context.Context, req *pb.SlotStatusRequest) (*pb.SlotStatusResponse, error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "decision_status", nil)
	if err != nil {
		return nil, err
	}
	return &pb.SlotStatusResponse{StatusJson: string(raw)}, nil
}

func (h *Handler) SlotList(ctx context.Context, req *pb.SlotListRequest) (*pb.SlotListResponse, error) {
	filter := map[string]any{
		"period": req.Period,
		"status": req.Status,
	}
	raw, err := h.proxy.Client.CallRaw(ctx, "decision_list", []any{filter})
	if err != nil {
		return nil, err
	}
	return &pb.SlotListResponse{SlotsJson: string(raw)}, nil
}

func (h *Handler) SlotGet(ctx context.Context, req *pb.SlotGetRequest) (*pb.SlotGetResponse, error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "decision_get", []any{req.SlotId})
	if err != nil {
		return nil, err
	}
	return &pb.SlotGetResponse{SlotJson: optionalJSON(raw)}, nil
}

// optionalJSON maps the JSON null a node returns for a missing item to "",
// which the clients read as absent.
func optionalJSON(raw json.RawMessage) string {
	if string(raw) == "null" {
		return ""
	}
	return string(raw)
}

func (h *Handler) SlotClaim(ctx context.Context, req *pb.SlotClaimRequest) (*pb.SlotClaimResponse, error) {
	decisionType := "binary"
	if req.GetIsScaled() {
		decisionType = "scaled"
	}
	txid, err := h.claimDecisions(ctx, map[string]any{
		"decision_type": decisionType,
		"decisions": []any{map[string]any{
			"period_index": req.PeriodIndex,
			"header":       req.Question,
		}},
		"min":         req.Min,
		"max":         req.Max,
		"tx_fee_sats": req.FeeSats,
	})
	if err != nil {
		return nil, err
	}
	return &pb.SlotClaimResponse{Txid: txid}, nil
}

func (h *Handler) SlotClaimCategory(ctx context.Context, req *pb.SlotClaimCategoryRequest) (*pb.SlotClaimCategoryResponse, error) {
	decisions := []any{}
	if req.SlotsJson != "" {
		if err := json.Unmarshal([]byte(req.SlotsJson), &decisions); err != nil {
			return nil, fmt.Errorf("unmarshal slots: %w", err)
		}
	}
	txid, err := h.claimDecisions(ctx, map[string]any{
		"decision_type": "category",
		"decisions":     decisions,
		"tx_fee_sats":   req.FeeSats,
	})
	if err != nil {
		return nil, err
	}
	return &pb.SlotClaimCategoryResponse{Txid: txid}, nil
}

// --- Voting ---

func (h *Handler) GetVoterAddress(ctx context.Context, req *pb.GetVoterAddressRequest) (*pb.GetVoterAddressResponse, error) {
	var address string
	if err := h.proxy.Client.Call(ctx, "get_voter_address", nil, &address); err != nil {
		return nil, err
	}
	return &pb.GetVoterAddressResponse{Address: address}, nil
}

func (h *Handler) VoteVoter(ctx context.Context, req *pb.VoteVoterRequest) (*pb.VoteVoterResponse, error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "vote_voter", []any{req.Address})
	if err != nil {
		return nil, err
	}
	return &pb.VoteVoterResponse{VoterJson: optionalJSON(raw)}, nil
}

func (h *Handler) VoteVoters(ctx context.Context, req *pb.VoteVotersRequest) (*pb.VoteVotersResponse, error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "vote_voters", nil)
	if err != nil {
		return nil, err
	}
	return &pb.VoteVotersResponse{VotersJson: string(raw)}, nil
}

func (h *Handler) VoteSubmit(ctx context.Context, req *pb.VoteSubmitRequest) (*pb.VoteSubmitResponse, error) {
	var votes any
	if req.VotesJson != "" {
		if err := json.Unmarshal([]byte(req.VotesJson), &votes); err != nil {
			return nil, fmt.Errorf("unmarshal votes: %w", err)
		}
	}
	var txid string
	params := []any{votes, req.FeeSats}
	if err := h.proxy.Client.Call(ctx, "vote_submit", params, &txid); err != nil {
		return nil, err
	}
	return &pb.VoteSubmitResponse{Txid: txid}, nil
}

func (h *Handler) VoteList(ctx context.Context, req *pb.VoteListRequest) (*pb.VoteListResponse, error) {
	filter := map[string]any{
		"voter":       req.Voter,
		"decision_id": req.DecisionId,
		"period_id":   req.PeriodId,
	}
	raw, err := h.proxy.Client.CallRaw(ctx, "vote_list", []any{filter})
	if err != nil {
		return nil, err
	}
	return &pb.VoteListResponse{VotesJson: string(raw)}, nil
}

func (h *Handler) VotePeriod(ctx context.Context, req *pb.VotePeriodRequest) (*pb.VotePeriodResponse, error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "vote_period", []any{req.PeriodId})
	if err != nil {
		return nil, err
	}
	return &pb.VotePeriodResponse{PeriodJson: optionalJSON(raw)}, nil
}

// --- Votecoin ---

func (h *Handler) VotecoinTransfer(ctx context.Context, req *pb.VotecoinTransferRequest) (*pb.VotecoinTransferResponse, error) {
	var txid string
	params := []any{req.Dest, votecoinAmount(req.VotecoinAmount, req.Amount), req.FeeSats} //nolint:staticcheck // old clients send Amount
	if err := h.proxy.Client.Call(ctx, "transfer_votecoin", params, &txid); err != nil {
		return nil, err
	}
	return &pb.VotecoinTransferResponse{Txid: txid}, nil
}

func (h *Handler) VotecoinBalance(ctx context.Context, req *pb.VotecoinBalanceRequest) (*pb.VotecoinBalanceResponse, error) {
	var balance float64
	if err := h.proxy.Client.Call(ctx, "votecoin_balance", []any{req.Address}, &balance); err != nil {
		return nil, err
	}
	return &pb.VotecoinBalanceResponse{Balance: int64(balance), VotecoinBalance: balance}, nil //nolint:staticcheck // old clients read Balance
}

// votecoinAmount reads the deprecated whole-unit amount when an old client
// leaves the fractional field unset.
func votecoinAmount(amount *float64, deprecatedAmount int64) float64 {
	if amount != nil {
		return *amount
	}
	return float64(deprecatedAmount)
}

func (h *Handler) TransferVotecoin(ctx context.Context, req *pb.TransferVotecoinRequest) (*pb.TransferVotecoinResponse, error) {
	var txid string
	params := []any{req.Dest, votecoinAmount(req.VotecoinAmount, req.Amount), req.FeeSats} //nolint:staticcheck // old clients send Amount
	if err := h.proxy.Client.Call(ctx, "transfer_votecoin", params, &txid); err != nil {
		return nil, err
	}
	return &pb.TransferVotecoinResponse{Txid: txid}, nil
}

// --- Crypto utilities ---

func (h *Handler) GetNewEncryptionKey(ctx context.Context, req *pb.GetNewEncryptionKeyRequest) (*pb.GetNewEncryptionKeyResponse, error) {
	var key string
	if err := h.proxy.Client.Call(ctx, "get_new_encryption_key", nil, &key); err != nil {
		return nil, err
	}
	return &pb.GetNewEncryptionKeyResponse{Key: key}, nil
}

func (h *Handler) GetNewVerifyingKey(ctx context.Context, req *pb.GetNewVerifyingKeyRequest) (*pb.GetNewVerifyingKeyResponse, error) {
	var key string
	if err := h.proxy.Client.Call(ctx, "get_new_verifying_key", nil, &key); err != nil {
		return nil, err
	}
	return &pb.GetNewVerifyingKeyResponse{Key: key}, nil
}

func (h *Handler) EncryptMsg(ctx context.Context, req *pb.EncryptMsgRequest) (*pb.EncryptMsgResponse, error) {
	var ciphertext string
	params := []any{req.EncryptionPubkey, req.Msg}
	if err := h.proxy.Client.Call(ctx, "encrypt_msg", params, &ciphertext); err != nil {
		return nil, err
	}
	return &pb.EncryptMsgResponse{Ciphertext: ciphertext}, nil
}

func (h *Handler) DecryptMsg(ctx context.Context, req *pb.DecryptMsgRequest) (*pb.DecryptMsgResponse, error) {
	var plaintext string
	params := []any{req.EncryptionPubkey, req.Ciphertext}
	if err := h.proxy.Client.Call(ctx, "decrypt_msg", params, &plaintext); err != nil {
		return nil, err
	}
	return &pb.DecryptMsgResponse{Plaintext: plaintext}, nil
}

func (h *Handler) SignArbitraryMsg(ctx context.Context, req *pb.SignArbitraryMsgRequest) (*pb.SignArbitraryMsgResponse, error) {
	var signature string
	params := []any{req.VerifyingKey, req.Msg}
	if err := h.proxy.Client.Call(ctx, "sign_arbitrary_msg", params, &signature); err != nil {
		return nil, err
	}
	return &pb.SignArbitraryMsgResponse{Signature: signature}, nil
}

func (h *Handler) SignArbitraryMsgAsAddr(ctx context.Context, req *pb.SignArbitraryMsgAsAddrRequest) (*pb.SignArbitraryMsgAsAddrResponse, error) {
	var result struct {
		VerifyingKey string `json:"verifying_key"`
		Signature    string `json:"signature"`
	}
	params := []any{req.Address, req.Msg}
	if err := h.proxy.Client.Call(ctx, "sign_arbitrary_msg_as_addr", params, &result); err != nil {
		return nil, err
	}
	return &pb.SignArbitraryMsgAsAddrResponse{
		VerifyingKey: result.VerifyingKey,
		Signature:    result.Signature,
	}, nil
}

func (h *Handler) VerifySignature(ctx context.Context, req *pb.VerifySignatureRequest) (*pb.VerifySignatureResponse, error) {
	var valid bool
	params := []any{req.Signature, req.VerifyingKey, req.Dst, req.Msg}
	if err := h.proxy.Client.Call(ctx, "verify_signature", params, &valid); err != nil {
		return nil, err
	}
	return &pb.VerifySignatureResponse{Valid: valid}, nil
}
