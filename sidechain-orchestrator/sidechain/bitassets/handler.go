package bitassets

import (
	"context"
	"encoding/json"
	"fmt"

	"connectrpc.com/connect"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bitassets/v1"
	svc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bitassets/v1/bitassetsv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

var _ svc.BitAssetsServiceHandler = (*Handler)(nil)

// Handler implements BitAssetsServiceHandler by proxying to the bitassets binary's JSON-RPC.
// Common methods delegate to the embedded JSONRPCProxy; BitAssets-specific methods are
// implemented directly using the proxy's Client.
type Handler struct {
	proxy *sidechain.JSONRPCProxy
}

func NewHandler(proxy *sidechain.JSONRPCProxy) *Handler {
	return &Handler{proxy: proxy}
}

// --- Common SidechainRPCProxy methods ---

func (h *Handler) GetBalance(ctx context.Context, req *connect.Request[pb.GetBalanceRequest]) (*connect.Response[pb.GetBalanceResponse], error) {
	// BitAssets uses "bitcoin_balance" instead of "balance"
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
	// BitAssets transfer accepts [dest, value, fee, memo]
	params := []any{req.Msg.Address, req.Msg.AmountSats, req.Msg.FeeSats}
	if req.Msg.Memo != nil {
		params = append(params, *req.Msg.Memo)
	} else {
		params = append(params, nil)
	}
	var txid string
	if err := h.proxy.Client.Call(ctx, "transfer", params, &txid); err != nil {
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

// --- BitAssets-specific methods ---

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

func (h *Handler) GetBitAssetData(ctx context.Context, req *connect.Request[pb.GetBitAssetDataRequest]) (*connect.Response[pb.GetBitAssetDataResponse], error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "bitasset_data", req.Msg.AssetId)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetBitAssetDataResponse{DataJson: string(raw)}), nil
}

func (h *Handler) ListBitAssets(ctx context.Context, req *connect.Request[pb.ListBitAssetsRequest]) (*connect.Response[pb.ListBitAssetsResponse], error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "bitassets", nil)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.ListBitAssetsResponse{BitassetsJson: string(raw)}), nil
}

func (h *Handler) RegisterBitAsset(ctx context.Context, req *connect.Request[pb.RegisterBitAssetRequest]) (*connect.Response[pb.RegisterBitAssetResponse], error) {
	var data any
	if req.Msg.DataJson != "" {
		if err := json.Unmarshal([]byte(req.Msg.DataJson), &data); err != nil {
			return nil, fmt.Errorf("unmarshal data: %w", err)
		}
	}
	var txid string
	params := []any{req.Msg.PlaintextName, req.Msg.InitialSupply, data}
	if err := h.proxy.Client.Call(ctx, "register_bitasset", params, &txid); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.RegisterBitAssetResponse{Txid: txid}), nil
}

func (h *Handler) ReserveBitAsset(ctx context.Context, req *connect.Request[pb.ReserveBitAssetRequest]) (*connect.Response[pb.ReserveBitAssetResponse], error) {
	var txid string
	if err := h.proxy.Client.Call(ctx, "reserve_bitasset", []any{req.Msg.Name}, &txid); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.ReserveBitAssetResponse{Txid: txid}), nil
}

func (h *Handler) TransferBitAsset(ctx context.Context, req *connect.Request[pb.TransferBitAssetRequest]) (*connect.Response[pb.TransferBitAssetResponse], error) {
	var txid string
	params := []any{req.Msg.AssetId, req.Msg.Dest, req.Msg.Amount, req.Msg.FeeSats}
	if err := h.proxy.Client.Call(ctx, "transfer_bitasset", params, &txid); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.TransferBitAssetResponse{Txid: txid}), nil
}

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

func (h *Handler) DecryptMsg(ctx context.Context, req *connect.Request[pb.DecryptMsgRequest]) (*connect.Response[pb.DecryptMsgResponse], error) {
	var plaintext string
	params := []any{req.Msg.EncryptionPubkey, req.Msg.Ciphertext}
	if err := h.proxy.Client.Call(ctx, "decrypt_msg", params, &plaintext); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.DecryptMsgResponse{Plaintext: plaintext}), nil
}

func (h *Handler) EncryptMsg(ctx context.Context, req *connect.Request[pb.EncryptMsgRequest]) (*connect.Response[pb.EncryptMsgResponse], error) {
	var ciphertext string
	params := []any{req.Msg.EncryptionPubkey, req.Msg.Msg}
	if err := h.proxy.Client.Call(ctx, "encrypt_msg", params, &ciphertext); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.EncryptMsgResponse{Ciphertext: ciphertext}), nil
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
	params := []any{req.Msg.Msg, req.Msg.Signature, req.Msg.VerifyingKey}
	if err := h.proxy.Client.Call(ctx, "verify_signature", params, &valid); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.VerifySignatureResponse{Valid: valid}), nil
}

func (h *Handler) GetWalletAddresses(ctx context.Context, req *connect.Request[pb.GetWalletAddressesRequest]) (*connect.Response[pb.GetWalletAddressesResponse], error) {
	var addresses []string
	if err := h.proxy.Client.Call(ctx, "get_wallet_addresses", nil, &addresses); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetWalletAddressesResponse{Addresses: addresses}), nil
}

func (h *Handler) MyUnconfirmedUtxos(ctx context.Context, req *connect.Request[pb.MyUnconfirmedUtxosRequest]) (*connect.Response[pb.MyUnconfirmedUtxosResponse], error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "my_unconfirmed_utxos", nil)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.MyUnconfirmedUtxosResponse{UtxosJson: string(raw)}), nil
}

func (h *Handler) OpenapiSchema(ctx context.Context, req *connect.Request[pb.OpenapiSchemaRequest]) (*connect.Response[pb.OpenapiSchemaResponse], error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "openapi_schema", nil)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.OpenapiSchemaResponse{SchemaJson: string(raw)}), nil
}

// --- AMM methods ---

func (h *Handler) AmmBurn(ctx context.Context, req *connect.Request[pb.AmmBurnRequest]) (*connect.Response[pb.AmmBurnResponse], error) {
	var txid string
	params := []any{req.Msg.Asset0, req.Msg.Asset1, req.Msg.LpTokenAmount}
	if err := h.proxy.Client.Call(ctx, "amm_burn", params, &txid); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.AmmBurnResponse{Txid: txid}), nil
}

func (h *Handler) AmmMint(ctx context.Context, req *connect.Request[pb.AmmMintRequest]) (*connect.Response[pb.AmmMintResponse], error) {
	var txid string
	params := []any{req.Msg.Asset0, req.Msg.Asset1, req.Msg.Amount0, req.Msg.Amount1}
	if err := h.proxy.Client.Call(ctx, "amm_mint", params, &txid); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.AmmMintResponse{Txid: txid}), nil
}

func (h *Handler) AmmSwap(ctx context.Context, req *connect.Request[pb.AmmSwapRequest]) (*connect.Response[pb.AmmSwapResponse], error) {
	var amountReceive int64
	params := []any{req.Msg.AssetSpend, req.Msg.AssetReceive, req.Msg.AmountSpend}
	if err := h.proxy.Client.Call(ctx, "amm_swap", params, &amountReceive); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.AmmSwapResponse{AmountReceive: amountReceive}), nil
}

func (h *Handler) GetAmmPoolState(ctx context.Context, req *connect.Request[pb.GetAmmPoolStateRequest]) (*connect.Response[pb.GetAmmPoolStateResponse], error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "get_amm_pool_state", []any{req.Msg.Asset0, req.Msg.Asset1})
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetAmmPoolStateResponse{PoolStateJson: string(raw)}), nil
}

func (h *Handler) GetAmmPrice(ctx context.Context, req *connect.Request[pb.GetAmmPriceRequest]) (*connect.Response[pb.GetAmmPriceResponse], error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "get_amm_price", []any{req.Msg.Base, req.Msg.Quote})
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetAmmPriceResponse{PriceJson: string(raw)}), nil
}

// --- Dutch Auction methods ---

func (h *Handler) DutchAuctionBid(ctx context.Context, req *connect.Request[pb.DutchAuctionBidRequest]) (*connect.Response[pb.DutchAuctionBidResponse], error) {
	var baseAmount int64
	params := []any{req.Msg.DutchAuctionId, req.Msg.BidSize}
	if err := h.proxy.Client.Call(ctx, "dutch_auction_bid", params, &baseAmount); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.DutchAuctionBidResponse{BaseAmount: baseAmount}), nil
}

func (h *Handler) DutchAuctionCollect(ctx context.Context, req *connect.Request[pb.DutchAuctionCollectRequest]) (*connect.Response[pb.DutchAuctionCollectResponse], error) {
	var result []int64
	if err := h.proxy.Client.Call(ctx, "dutch_auction_collect", req.Msg.DutchAuctionId, &result); err != nil {
		return nil, err
	}
	resp := &pb.DutchAuctionCollectResponse{}
	if len(result) >= 1 {
		resp.BaseAmount = result[0]
	}
	if len(result) >= 2 {
		resp.QuoteAmount = result[1]
	}
	return connect.NewResponse(resp), nil
}

func (h *Handler) DutchAuctionCreate(ctx context.Context, req *connect.Request[pb.DutchAuctionCreateRequest]) (*connect.Response[pb.DutchAuctionCreateResponse], error) {
	var txid string
	params := []any{
		req.Msg.StartBlock,
		req.Msg.Duration,
		req.Msg.BaseAsset,
		req.Msg.BaseAmount,
		req.Msg.QuoteAsset,
		req.Msg.InitialPrice,
		req.Msg.FinalPrice,
	}
	if err := h.proxy.Client.Call(ctx, "dutch_auction_create", params, &txid); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.DutchAuctionCreateResponse{Txid: txid}), nil
}

func (h *Handler) DutchAuctions(ctx context.Context, req *connect.Request[pb.DutchAuctionsRequest]) (*connect.Response[pb.DutchAuctionsResponse], error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "dutch_auctions", nil)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.DutchAuctionsResponse{AuctionsJson: string(raw)}), nil
}
