package bitnames

import (
	"context"
	"encoding/json"
	"fmt"

	"connectrpc.com/connect"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bitnames/v1"
	svc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bitnames/v1/bitnamesv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

var _ svc.BitnamesServiceHandler = (*Handler)(nil)

// Handler implements BitnamesServiceHandler by proxying to the bitnames binary's JSON-RPC.
// Common methods delegate to the embedded JSONRPCProxy; BitNames-specific methods are
// implemented directly using the proxy's Client.
type Handler struct {
	proxy *sidechain.JSONRPCProxy
}

func NewHandler(proxy *sidechain.JSONRPCProxy) *Handler {
	return &Handler{proxy: proxy}
}

// --- Common SidechainRPCProxy methods ---

func (h *Handler) GetBalance(ctx context.Context, req *connect.Request[pb.GetBalanceRequest]) (*connect.Response[pb.GetBalanceResponse], error) {
	total, available, err := h.proxy.GetBalance(ctx)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetBalanceResponse{
		TotalSats:     total,
		AvailableSats: available,
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
	// BitNames transfer accepts [dest, value, fee, memo]
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

// --- BitNames-specific methods ---

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

func (h *Handler) GetBitNameData(ctx context.Context, req *connect.Request[pb.GetBitNameDataRequest]) (*connect.Response[pb.GetBitNameDataResponse], error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "bitname_data", req.Msg.Name)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetBitNameDataResponse{DataJson: string(raw)}), nil
}

func (h *Handler) ListBitNames(ctx context.Context, req *connect.Request[pb.ListBitNamesRequest]) (*connect.Response[pb.ListBitNamesResponse], error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "bitnames", nil)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.ListBitNamesResponse{BitnamesJson: string(raw)}), nil
}

func (h *Handler) RegisterBitName(ctx context.Context, req *connect.Request[pb.RegisterBitNameRequest]) (*connect.Response[pb.RegisterBitNameResponse], error) {
	var data any
	if req.Msg.DataJson != "" {
		if err := json.Unmarshal([]byte(req.Msg.DataJson), &data); err != nil {
			return nil, fmt.Errorf("unmarshal data: %w", err)
		}
	}
	var txid string
	params := []any{req.Msg.PlainName, data}
	if err := h.proxy.Client.Call(ctx, "register_bitname", params, &txid); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.RegisterBitNameResponse{Txid: txid}), nil
}

func (h *Handler) ReserveBitName(ctx context.Context, req *connect.Request[pb.ReserveBitNameRequest]) (*connect.Response[pb.ReserveBitNameResponse], error) {
	var txid string
	if err := h.proxy.Client.Call(ctx, "reserve_bitname", []any{req.Msg.Name}, &txid); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.ReserveBitNameResponse{Txid: txid}), nil
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
	params := []any{req.Msg.EncryptionPubkey, req.Msg.Ciphertext, true}
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

func (h *Handler) GetPaymail(ctx context.Context, req *connect.Request[pb.GetPaymailRequest]) (*connect.Response[pb.GetPaymailResponse], error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "get_paymail", nil)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.GetPaymailResponse{PaymailJson: string(raw)}), nil
}

func (h *Handler) ResolveCommit(ctx context.Context, req *connect.Request[pb.ResolveCommitRequest]) (*connect.Response[pb.ResolveCommitResponse], error) {
	var commitment string
	if err := h.proxy.Client.Call(ctx, "resolve_commit", req.Msg.Bitname, &commitment); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.ResolveCommitResponse{Commitment: commitment}), nil
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

func (h *Handler) OpenapiSchema(ctx context.Context, req *connect.Request[pb.OpenapiSchemaRequest]) (*connect.Response[pb.OpenapiSchemaResponse], error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "openapi_schema", nil)
	if err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.OpenapiSchemaResponse{SchemaJson: string(raw)}), nil
}
