package bitassets

import (
	"context"
	"encoding/json"
	"fmt"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bitassets/v1"
	svc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bitassets/v1/bitassetsv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

var _ svc.BitAssetsServiceHandler = (*Handler)(nil)

// Handler implements BitAssetsServiceHandler by proxying to the bitassets binary's JSON-RPC.
// Common methods delegate to the proxy field; BitAssets-specific methods are
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
	// The node names this call bitcoin_balance, not balance.
	var result struct {
		TotalSats     int64 `json:"total_sats"`
		AvailableSats int64 `json:"available_sats"`
	}
	if err := h.proxy.Client.Call(ctx, "bitcoin_balance", nil, &result); err != nil {
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
	txid, err := h.proxy.Withdraw(ctx, req.Address, req.AmountSats, req.SideFeeSats, req.MainFeeSats)
	if err != nil {
		return nil, err
	}
	return &pb.WithdrawResponse{Txid: txid}, nil
}

func (h *Handler) Transfer(ctx context.Context, req *pb.TransferRequest) (*pb.TransferResponse, error) {
	// BitAssets transfer accepts [dest, value, fee, memo]
	params := []any{req.Address, req.AmountSats, req.FeeSats}
	if req.Memo != nil {
		params = append(params, *req.Memo)
	} else {
		params = append(params, nil)
	}
	var txid string
	if err := h.proxy.Client.Call(ctx, "transfer", params, &txid); err != nil {
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

// --- BitAssets-specific methods ---

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

func (h *Handler) GetBitAssetData(ctx context.Context, req *pb.GetBitAssetDataRequest) (*pb.GetBitAssetDataResponse, error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "bitasset_data", []any{req.AssetId})
	if err != nil {
		return nil, err
	}
	return &pb.GetBitAssetDataResponse{DataJson: string(raw)}, nil
}

func (h *Handler) ListBitAssets(ctx context.Context, req *pb.ListBitAssetsRequest) (*pb.ListBitAssetsResponse, error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "bitassets", nil)
	if err != nil {
		return nil, err
	}
	return &pb.ListBitAssetsResponse{BitassetsJson: string(raw)}, nil
}

func (h *Handler) RegisterBitAsset(ctx context.Context, req *pb.RegisterBitAssetRequest) (*pb.RegisterBitAssetResponse, error) {
	var data any
	if req.DataJson != "" {
		if err := json.Unmarshal([]byte(req.DataJson), &data); err != nil {
			return nil, fmt.Errorf("unmarshal data: %w", err)
		}
	}
	var txid string
	params := []any{req.PlaintextName, req.InitialSupply, data}
	if err := h.proxy.Client.Call(ctx, "register_bitasset", params, &txid); err != nil {
		return nil, err
	}
	return &pb.RegisterBitAssetResponse{Txid: txid}, nil
}

func (h *Handler) ReserveBitAsset(ctx context.Context, req *pb.ReserveBitAssetRequest) (*pb.ReserveBitAssetResponse, error) {
	var txid string
	if err := h.proxy.Client.Call(ctx, "reserve_bitasset", []any{req.Name}, &txid); err != nil {
		return nil, err
	}
	return &pb.ReserveBitAssetResponse{Txid: txid}, nil
}

func (h *Handler) TransferBitAsset(ctx context.Context, req *pb.TransferBitAssetRequest) (*pb.TransferBitAssetResponse, error) {
	var txid string
	// BitAssets transfer_bitasset accepts [dest, asset_id, amount, fee_sats, memo]
	params := []any{req.Dest, req.AssetId, req.Amount, req.FeeSats, nil}
	if err := h.proxy.Client.Call(ctx, "transfer_bitasset", params, &txid); err != nil {
		return nil, err
	}
	return &pb.TransferBitAssetResponse{Txid: txid}, nil
}

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

func (h *Handler) DecryptMsg(ctx context.Context, req *pb.DecryptMsgRequest) (*pb.DecryptMsgResponse, error) {
	var plaintext string
	params := []any{req.EncryptionPubkey, req.Ciphertext}
	if err := h.proxy.Client.Call(ctx, "decrypt_msg", params, &plaintext); err != nil {
		return nil, err
	}
	return &pb.DecryptMsgResponse{Plaintext: plaintext}, nil
}

func (h *Handler) EncryptMsg(ctx context.Context, req *pb.EncryptMsgRequest) (*pb.EncryptMsgResponse, error) {
	var ciphertext string
	params := []any{req.EncryptionPubkey, req.Msg}
	if err := h.proxy.Client.Call(ctx, "encrypt_msg", params, &ciphertext); err != nil {
		return nil, err
	}
	return &pb.EncryptMsgResponse{Ciphertext: ciphertext}, nil
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
	// The sign_arbitrary_msg methods sign with the arbitrary dst.
	params := []any{req.Signature, req.VerifyingKey, "arbitrary", req.Msg}
	if err := h.proxy.Client.Call(ctx, "verify_signature", params, &valid); err != nil {
		return nil, err
	}
	return &pb.VerifySignatureResponse{Valid: valid}, nil
}

func (h *Handler) GetWalletAddresses(ctx context.Context, req *pb.GetWalletAddressesRequest) (*pb.GetWalletAddressesResponse, error) {
	var addresses []string
	if err := h.proxy.Client.Call(ctx, "get_wallet_addresses", nil, &addresses); err != nil {
		return nil, err
	}
	return &pb.GetWalletAddressesResponse{Addresses: addresses}, nil
}

func (h *Handler) MyUnconfirmedUtxos(ctx context.Context, req *pb.MyUnconfirmedUtxosRequest) (*pb.MyUnconfirmedUtxosResponse, error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "my_unconfirmed_utxos", nil)
	if err != nil {
		return nil, err
	}
	return &pb.MyUnconfirmedUtxosResponse{UtxosJson: string(raw)}, nil
}

func (h *Handler) OpenapiSchema(ctx context.Context, req *pb.OpenapiSchemaRequest) (*pb.OpenapiSchemaResponse, error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "openapi_schema", nil)
	if err != nil {
		return nil, err
	}
	return &pb.OpenapiSchemaResponse{SchemaJson: string(raw)}, nil
}

// --- AMM methods ---

func (h *Handler) AmmBurn(ctx context.Context, req *pb.AmmBurnRequest) (*pb.AmmBurnResponse, error) {
	var txid string
	params := []any{req.Asset0, req.Asset1, req.LpTokenAmount}
	if err := h.proxy.Client.Call(ctx, "amm_burn", params, &txid); err != nil {
		return nil, err
	}
	return &pb.AmmBurnResponse{Txid: txid}, nil
}

func (h *Handler) AmmMint(ctx context.Context, req *pb.AmmMintRequest) (*pb.AmmMintResponse, error) {
	var txid string
	params := []any{req.Asset0, req.Asset1, req.Amount0, req.Amount1}
	if err := h.proxy.Client.Call(ctx, "amm_mint", params, &txid); err != nil {
		return nil, err
	}
	return &pb.AmmMintResponse{Txid: txid}, nil
}

func (h *Handler) AmmSwap(ctx context.Context, req *pb.AmmSwapRequest) (*pb.AmmSwapResponse, error) {
	var amountReceive int64
	params := []any{req.AssetSpend, req.AssetReceive, req.AmountSpend}
	if err := h.proxy.Client.Call(ctx, "amm_swap", params, &amountReceive); err != nil {
		return nil, err
	}
	return &pb.AmmSwapResponse{AmountReceive: amountReceive}, nil
}

func (h *Handler) GetAmmPoolState(ctx context.Context, req *pb.GetAmmPoolStateRequest) (*pb.GetAmmPoolStateResponse, error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "get_amm_pool_state", []any{req.Asset0, req.Asset1})
	if err != nil {
		return nil, err
	}
	return &pb.GetAmmPoolStateResponse{PoolStateJson: string(raw)}, nil
}

func (h *Handler) GetAmmPrice(ctx context.Context, req *pb.GetAmmPriceRequest) (*pb.GetAmmPriceResponse, error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "get_amm_price", []any{req.Base, req.Quote})
	if err != nil {
		return nil, err
	}
	return &pb.GetAmmPriceResponse{PriceJson: string(raw)}, nil
}

// --- Dutch Auction methods ---

func (h *Handler) DutchAuctionBid(ctx context.Context, req *pb.DutchAuctionBidRequest) (*pb.DutchAuctionBidResponse, error) {
	var baseAmount int64
	params := []any{req.DutchAuctionId, req.BidSize}
	if err := h.proxy.Client.Call(ctx, "dutch_auction_bid", params, &baseAmount); err != nil {
		return nil, err
	}
	return &pb.DutchAuctionBidResponse{BaseAmount: baseAmount}, nil
}

func (h *Handler) DutchAuctionCollect(ctx context.Context, req *pb.DutchAuctionCollectRequest) (*pb.DutchAuctionCollectResponse, error) {
	var result []int64
	if err := h.proxy.Client.Call(ctx, "dutch_auction_collect", []any{req.DutchAuctionId}, &result); err != nil {
		return nil, err
	}
	resp := &pb.DutchAuctionCollectResponse{}
	if len(result) >= 1 {
		resp.BaseAmount = result[0]
	}
	if len(result) >= 2 {
		resp.QuoteAmount = result[1]
	}
	return resp, nil
}

func (h *Handler) DutchAuctionCreate(ctx context.Context, req *pb.DutchAuctionCreateRequest) (*pb.DutchAuctionCreateResponse, error) {
	var txid string
	params := []any{
		req.StartBlock,
		req.Duration,
		req.BaseAsset,
		req.BaseAmount,
		req.QuoteAsset,
		req.InitialPrice,
		req.FinalPrice,
	}
	if err := h.proxy.Client.Call(ctx, "dutch_auction_create", params, &txid); err != nil {
		return nil, err
	}
	return &pb.DutchAuctionCreateResponse{Txid: txid}, nil
}

func (h *Handler) DutchAuctions(ctx context.Context, req *pb.DutchAuctionsRequest) (*pb.DutchAuctionsResponse, error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "dutch_auctions", nil)
	if err != nil {
		return nil, err
	}
	return &pb.DutchAuctionsResponse{AuctionsJson: string(raw)}, nil
}
