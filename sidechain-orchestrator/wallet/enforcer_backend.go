package wallet

import (
	"context"
	"errors"
	"fmt"
	"sort"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/types/known/wrapperspb"

	commonv1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/common/v1"
	enforcerpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	enforcerrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
)

// EnforcerBackend serves the enforcer-type wallet by relaying to the
// BIP300/301 enforcer daemon's wallet service (BDK). The enforcer selects
// coins and signs itself, so the local raw-tx primitives are unsupported.
type EnforcerBackend struct {
	client enforcerrpc.WalletServiceClient
}

var _ Backend = (*EnforcerBackend)(nil)

// NewEnforcerBackend wraps the enforcer's wallet service client.
func NewEnforcerBackend(client enforcerrpc.WalletServiceClient) *EnforcerBackend {
	return &EnforcerBackend{client: client}
}

func (p *EnforcerBackend) unsupported(op string) error {
	return fmt.Errorf("enforcer wallet: %s is not supported", op)
}

func (p *EnforcerBackend) Ensure(ctx context.Context, walletID string) (string, error) {
	return "", errors.New("enforcer wallet has no backend-managed state")
}

func (p *EnforcerBackend) EnsureAll(ctx context.Context) (int, error) {
	return 0, nil
}

func (p *EnforcerBackend) Balance(ctx context.Context, walletID string) (float64, float64, error) {
	resp, err := p.client.GetBalance(ctx, connect.NewRequest(&enforcerpb.GetBalanceRequest{}))
	if err != nil {
		return 0, 0, fmt.Errorf("enforcer/wallet: get balance: %w", err)
	}
	return float64(resp.Msg.ConfirmedSats) / 1e8, float64(resp.Msg.PendingSats) / 1e8, nil
}

func (p *EnforcerBackend) ListUnspent(ctx context.Context, walletID string) ([]UTXO, error) {
	resp, err := p.client.ListUnspentOutputs(ctx, connect.NewRequest(&enforcerpb.ListUnspentOutputsRequest{}))
	if err != nil {
		return nil, fmt.Errorf("enforcer/wallet: list unspent: %w", err)
	}
	utxos := make([]UTXO, 0, len(resp.Msg.Outputs))
	for _, u := range resp.Msg.Outputs {
		confirmations := 0
		if u.IsConfirmed {
			confirmations = 1
		}
		utxos = append(utxos, UTXO{
			TxID:          u.Txid.GetHex().GetValue(),
			Vout:          int(u.Vout),
			Address:       u.Address.GetValue(),
			Amount:        float64(u.ValueSats) / 1e8,
			Confirmations: confirmations,
			Spendable:     true,
			Solvable:      true,
			ReceivedAt:    bdkReceivedAt(u),
		})
	}
	return utxos, nil
}

// bdkReceivedAt picks the best timestamp for a BDK UTXO row: the wallet's
// first-seen mempool stamp, falling back to the confirmation timestamp.
func bdkReceivedAt(u *enforcerpb.ListUnspentOutputsResponse_Output) int64 {
	if ts := u.UnconfirmedLastSeen; ts != nil && (ts.GetSeconds() > 0 || ts.GetNanos() > 0) {
		return ts.GetSeconds()
	}
	if ts := u.ConfirmedAtTime; ts != nil && (ts.GetSeconds() > 0 || ts.GetNanos() > 0) {
		return ts.GetSeconds()
	}
	return 0
}

func (p *EnforcerBackend) listAll(ctx context.Context) ([]WalletTransaction, error) {
	resp, err := p.client.ListTransactions(ctx, connect.NewRequest(&enforcerpb.ListTransactionsRequest{}))
	if err != nil {
		return nil, fmt.Errorf("enforcer/wallet: list transactions: %w", err)
	}
	txs := make([]WalletTransaction, 0, len(resp.Msg.Transactions))
	for _, tx := range resp.Msg.Transactions {
		amountSats := int64(tx.ReceivedSats) - int64(tx.SentSats)
		var confirmations int
		var blockTime int64
		if tx.ConfirmationInfo != nil {
			confirmations = int(tx.ConfirmationInfo.Height)
			if tx.ConfirmationInfo.Timestamp != nil {
				blockTime = tx.ConfirmationInfo.Timestamp.Seconds
			}
		}
		txs = append(txs, WalletTransaction{
			TxID:          tx.Txid.GetHex().GetValue(),
			Amount:        float64(amountSats) / 1e8,
			Fee:           float64(tx.FeeSats) / 1e8,
			Confirmations: confirmations,
			BlockTime:     blockTime,
			Time:          blockTime,
		})
	}
	return txs, nil
}

func (p *EnforcerBackend) ListTransactions(ctx context.Context, walletID string, count int) ([]WalletTransaction, error) {
	return p.listAll(ctx)
}

func (p *EnforcerBackend) ListTransactionsRange(ctx context.Context, walletID string, count, skip int) ([]WalletTransaction, error) {
	txs, err := p.listAll(ctx)
	if err != nil {
		return nil, err
	}
	if skip >= len(txs) {
		return nil, nil
	}
	txs = txs[skip:]
	if count > 0 && count < len(txs) {
		txs = txs[:count]
	}
	return txs, nil
}

// ListReceivedByAddress aggregates the wallet's UTXOs per address and mints
// one fresh address so an unused entry is always available — BDK has no
// native listreceivedbyaddress.
func (p *EnforcerBackend) ListReceivedByAddress(ctx context.Context, walletID string) ([]ReceivedByAddress, error) {
	resp, err := p.client.ListUnspentOutputs(ctx, connect.NewRequest(&enforcerpb.ListUnspentOutputsRequest{}))
	if err != nil {
		return nil, fmt.Errorf("enforcer/wallet: list unspent outputs: %w", err)
	}
	byAddr := make(map[string]int64)
	for _, u := range resp.Msg.Outputs {
		byAddr[u.Address.GetValue()] += int64(u.ValueSats)
	}

	addrResp, err := p.client.CreateNewAddress(ctx, connect.NewRequest(&enforcerpb.CreateNewAddressRequest{}))
	if err != nil {
		return nil, fmt.Errorf("enforcer/wallet: create new address: %w", err)
	}
	if _, ok := byAddr[addrResp.Msg.Address]; !ok {
		byAddr[addrResp.Msg.Address] = 0
	}

	addrs := make([]ReceivedByAddress, 0, len(byAddr))
	for addr, sats := range byAddr {
		addrs = append(addrs, ReceivedByAddress{
			Address: addr,
			Amount:  float64(sats) / 1e8,
		})
	}
	sort.Slice(addrs, func(i, j int) bool { return addrs[i].Address < addrs[j].Address })
	return addrs, nil
}

// GetWalletTransaction resolves a txid through the wallet's transaction
// list — the enforcer exposes no per-tx lookup.
func (p *EnforcerBackend) GetWalletTransaction(ctx context.Context, walletID, txid string) (*WalletTx, error) {
	txs, err := p.listAll(ctx)
	if err != nil {
		return nil, err
	}
	for i := range txs {
		if txs[i].TxID != txid {
			continue
		}
		return &WalletTx{
			TxID:          txs[i].TxID,
			Amount:        txs[i].Amount,
			Fee:           txs[i].Fee,
			Confirmations: int32(txs[i].Confirmations),
			BlockTime:     txs[i].BlockTime,
			Time:          txs[i].Time,
		}, nil
	}
	return nil, fmt.Errorf("transaction %s not found in enforcer wallet", txid)
}

func (p *EnforcerBackend) AddressHDPath(ctx context.Context, walletID, address string) (string, error) {
	return "", p.unsupported("address hd path lookup")
}

func (p *EnforcerBackend) NextReceiveAddress(ctx context.Context, walletID string) (string, error) {
	resp, err := p.client.CreateNewAddress(ctx, connect.NewRequest(&enforcerpb.CreateNewAddressRequest{}))
	if err != nil {
		return "", fmt.Errorf("enforcer/wallet: create new address: %w", err)
	}
	return resp.Msg.Address, nil
}

func (p *EnforcerBackend) NextChangeAddress(ctx context.Context, walletID string) (string, error) {
	return p.NextReceiveAddress(ctx, walletID)
}

func (p *EnforcerBackend) WatchKeys(ctx context.Context, walletID string, keys []WatchKey) error {
	return p.unsupported("watching extra keys")
}

// Send relays to the enforcer's all-in-one SendTransaction: the daemon does
// coin selection, change, signing, and broadcast.
func (p *EnforcerBackend) Send(ctx context.Context, walletID string, req SendRequest) (string, error) {
	if req.ReplayProtect {
		return "", connect.NewError(
			connect.CodeInvalidArgument,
			errors.New("replay protection is only supported for Bitcoin Core wallets"),
		)
	}

	var feeRate *enforcerpb.SendTransactionRequest_FeeRate
	if req.FeeRateSatPerVB > 0 {
		feeRate = &enforcerpb.SendTransactionRequest_FeeRate{
			Fee: &enforcerpb.SendTransactionRequest_FeeRate_SatPerVbyte{SatPerVbyte: uint64(req.FeeRateSatPerVB)},
		}
	}
	if req.FixedFeeSats > 0 {
		feeRate = &enforcerpb.SendTransactionRequest_FeeRate{
			Fee: &enforcerpb.SendTransactionRequest_FeeRate_Sats{Sats: uint64(req.FixedFeeSats)},
		}
	}

	var opReturn *commonv1.Hex
	if req.OpReturnHex != "" {
		opReturn = &commonv1.Hex{
			Hex: &wrapperspb.StringValue{Value: req.OpReturnHex},
		}
	}

	destinations := make(map[string]uint64, len(req.DestinationsSats))
	for addr, sats := range req.DestinationsSats {
		destinations[addr] = uint64(sats)
	}

	requiredUtxos := make([]*enforcerpb.SendTransactionRequest_RequiredUtxo, 0, len(req.RequiredInputs))
	for _, u := range req.RequiredInputs {
		if u.TxID == "" {
			continue
		}
		requiredUtxos = append(requiredUtxos, &enforcerpb.SendTransactionRequest_RequiredUtxo{
			Txid: &commonv1.ReverseHex{Hex: &wrapperspb.StringValue{Value: u.TxID}},
			Vout: uint32(u.Vout),
		})
	}

	resp, err := p.client.SendTransaction(ctx, connect.NewRequest(&enforcerpb.SendTransactionRequest{
		Destinations:    destinations,
		FeeRate:         feeRate,
		OpReturnMessage: opReturn,
		RequiredUtxos:   requiredUtxos,
	}))
	if err != nil {
		return "", fmt.Errorf("enforcer/wallet: send transaction: %w", err)
	}
	return resp.Msg.Txid.GetHex().GetValue(), nil
}

func (p *EnforcerBackend) SignTransaction(ctx context.Context, walletID, rawHex string) (*SignRawTransactionResult, error) {
	return nil, p.unsupported("raw transaction signing")
}

func (p *EnforcerBackend) BumpFee(ctx context.Context, walletID, txid string, newFeeRate int64) (string, error) {
	return "", p.unsupported("fee bumping")
}

// Chain is unavailable on the enforcer wallet service; chain-level lookups
// route to the chain wallet backend via the router.
func (p *EnforcerBackend) Chain() ChainSource {
	return unavailableChain{reason: "enforcer wallet has no chain source"}
}

// unavailableChain is a ChainSource that always errors.
type unavailableChain struct {
	reason string
}

func (c unavailableChain) GetRawTransaction(ctx context.Context, txid string) (*RawTransaction, error) {
	return nil, errors.New(c.reason)
}

func (c unavailableChain) Broadcast(ctx context.Context, rawHex string) (string, error) {
	return "", errors.New(c.reason)
}
