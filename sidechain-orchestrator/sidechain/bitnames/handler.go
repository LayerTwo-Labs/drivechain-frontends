package bitnames

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"

	"connectrpc.com/connect/v2"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bitnames/v1"
	svc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bitnames/v1/bitnamesv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

var _ svc.BitnamesServiceHandler = (*Handler)(nil)

// Handler implements BitnamesServiceHandler by proxying to the bitnames binary's JSON-RPC.
// Common methods delegate to the proxy field; BitNames-specific methods are
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
	params := []any{req.Address, req.AmountSats, req.SideFeeSats, req.MainFeeSats}
	var txid string
	if err := h.proxy.Client.Call(ctx, "create_withdrawal", params, &txid); err != nil {
		return nil, err
	}
	return &pb.WithdrawResponse{Txid: txid}, nil
}

func (h *Handler) Transfer(ctx context.Context, req *pb.TransferRequest) (*pb.TransferResponse, error) {
	// create_transfer takes a 4th memo parameter here.
	params := []any{req.Address, req.AmountSats, req.FeeSats}
	if req.Memo != nil {
		params = append(params, *req.Memo)
	} else {
		params = append(params, nil)
	}
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

// --- BitNames-specific methods ---

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

func (h *Handler) GetBitNameData(ctx context.Context, req *pb.GetBitNameDataRequest) (*pb.GetBitNameDataResponse, error) {
	var details nodeBitnameDetails
	if err := h.proxy.Client.Call(ctx, "bitname_data", []any{req.Name}, &details); err != nil {
		return nil, err
	}
	raw, err := json.Marshal(details.toClient())
	if err != nil {
		return nil, fmt.Errorf("marshal bitname data: %w", err)
	}
	return &pb.GetBitNameDataResponse{DataJson: string(raw)}, nil
}

func (h *Handler) ListBitNames(ctx context.Context, req *pb.ListBitNamesRequest) (*pb.ListBitNamesResponse, error) {
	var entries []nodeBitnameEntry
	if err := h.proxy.Client.Call(ctx, "bitnames", nil, &entries); err != nil {
		return nil, err
	}
	listed := make([]BitnameEntry, len(entries))
	for i, entry := range entries {
		listed[i] = BitnameEntry{Hash: entry.Hash, Details: entry.Details.toClient()}
	}
	raw, err := json.Marshal(listed)
	if err != nil {
		return nil, fmt.Errorf("marshal bitnames: %w", err)
	}
	return &pb.ListBitNamesResponse{BitnamesJson: string(raw)}, nil
}

func (h *Handler) RegisterBitName(ctx context.Context, req *pb.RegisterBitNameRequest) (*pb.RegisterBitNameResponse, error) {
	var data any
	if req.DataJson != "" {
		var client BitNameData
		if err := json.Unmarshal([]byte(req.DataJson), &client); err != nil {
			return nil, fmt.Errorf("unmarshal data: %w", err)
		}
		node, err := client.toNode()
		if err != nil {
			return nil, connect.NewError(connect.CodeInvalidArgument, err.Error()).WithCause(err)
		}
		data = node
	}
	var txid string
	params := []any{req.PlainName, data}
	if err := h.proxy.Client.Call(ctx, "register_bitname", params, &txid); err != nil {
		return nil, err
	}
	return &pb.RegisterBitNameResponse{Txid: txid}, nil
}

func (h *Handler) ReserveBitName(ctx context.Context, req *pb.ReserveBitNameRequest) (*pb.ReserveBitNameResponse, error) {
	var txid string
	if err := h.proxy.Client.Call(ctx, "reserve_bitname", []any{req.Name}, &txid); err != nil {
		return nil, err
	}
	return &pb.ReserveBitNameResponse{Txid: txid}, nil
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
	params := []any{req.EncryptionPubkey, req.Ciphertext, true}
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

func (h *Handler) GetBitNameOwner(
	ctx context.Context, req *pb.GetBitNameOwnerRequest,
) (*pb.GetBitNameOwnerResponse, error) {
	address, err := BitNameOwner(ctx, h.proxy.Client, req.Bitname)
	if errors.Is(err, errBitNameNotFound) {
		return nil, connect.NewError(connect.CodeNotFound, err.Error()).WithCause(err)
	}
	if err != nil {
		return nil, err
	}
	return &pb.GetBitNameOwnerResponse{Address: address}, nil
}

// GetPendingPaymail is not available: the node lists no mempool.
func (h *Handler) GetPendingPaymail(
	context.Context, *pb.GetPendingPaymailRequest,
) (*pb.GetPendingPaymailResponse, error) {
	return nil, connect.NewError(connect.CodeUnimplemented, "the bitnames node does not list its mempool")
}

func (h *Handler) GetPaymail(ctx context.Context, req *pb.GetPaymailRequest) (*pb.GetPaymailResponse, error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "get_paymail", nil)
	if err != nil {
		return nil, err
	}
	return &pb.GetPaymailResponse{PaymailJson: string(raw)}, nil
}

// dataServerAddress returns the address to read data from. A resolver reads
// the ipv4 address, then the ipv6 address.
func dataServerAddress(data BitNameData) (string, error) {
	if data.SocketAddrV4 != nil && *data.SocketAddrV4 != "" {
		return *data.SocketAddrV4, nil
	}
	if data.SocketAddrV6 != nil && *data.SocketAddrV6 != "" {
		return *data.SocketAddrV6, nil
	}
	// A name registered elsewhere can hold a host instead of an address.
	if data.SocketAddrHost != nil && *data.SocketAddrHost != "" {
		return *data.SocketAddrHost, nil
	}
	return "", fmt.Errorf("bitname holds no socket address")
}

func (h *Handler) ResolveCommit(ctx context.Context, req *pb.ResolveCommitRequest) (*pb.ResolveCommitResponse, error) {
	var details nodeBitnameDetails
	if err := h.proxy.Client.Call(ctx, "bitname_data", []any{req.Bitname}, &details); err != nil {
		return nil, err
	}
	data := details.toClient()

	if data.Commitment == nil || *data.Commitment == "" {
		return nil, connect.Errorf(connect.CodeFailedPrecondition,
			"bitname %s holds no commitment", req.Bitname)
	}

	address, err := dataServerAddress(details.nodeBitNameData.toClient())
	if err != nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, err.Error()).WithCause(err)
	}

	raw, digest, err := FetchCommitment(ctx, address)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, err.Error()).WithCause(err)
	}

	return &pb.ResolveCommitResponse{
		Commitment: *data.Commitment,
		DataJson:   string(raw),
		// Another client may write the digest in upper case hex.
		Matches: strings.EqualFold(digest, *data.Commitment),
	}, nil
}

func (h *Handler) ReadCommitment(ctx context.Context, req *pb.ReadCommitmentRequest) (*pb.ReadCommitmentResponse, error) {
	if req.Address == "" {
		return nil, connect.Errorf(connect.CodeInvalidArgument, "address is empty")
	}

	raw, digest, served, err := FetchCommitmentAt(ctx, req.Address)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, err.Error()).WithCause(err)
	}

	return &pb.ReadCommitmentResponse{
		DataJson:     string(raw),
		Commitment:   digest,
		SocketAddrV4: served.V4,
		SocketAddrV6: served.V6,
	}, nil
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

func (h *Handler) GetWalletAddresses(ctx context.Context, req *pb.GetWalletAddressesRequest) (*pb.GetWalletAddressesResponse, error) {
	var addresses []string
	if err := h.proxy.Client.Call(ctx, "get_wallet_addresses", nil, &addresses); err != nil {
		return nil, err
	}
	return &pb.GetWalletAddressesResponse{Addresses: addresses}, nil
}

func (h *Handler) MyUtxos(ctx context.Context, req *pb.MyUtxosRequest) (*pb.MyUtxosResponse, error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "my_utxos", nil)
	if err != nil {
		return nil, err
	}
	return &pb.MyUtxosResponse{UtxosJson: string(raw)}, nil
}

func (h *Handler) OpenapiSchema(ctx context.Context, req *pb.OpenapiSchemaRequest) (*pb.OpenapiSchemaResponse, error) {
	raw, err := h.proxy.Client.CallRaw(ctx, "openapi_schema", nil)
	if err != nil {
		return nil, err
	}
	return &pb.OpenapiSchemaResponse{SchemaJson: string(raw)}, nil
}
