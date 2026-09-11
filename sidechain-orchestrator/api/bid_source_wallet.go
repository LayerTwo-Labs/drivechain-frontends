package api

import (
	"context"
	"encoding/hex"
	"fmt"
	"strings"

	"connectrpc.com/connect"
	"github.com/samber/lo"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	wpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

// walletBids reads our own bid out of the wallet. The wallet built and signed
// every bid of ours, so it answers without a mainchain node of its own.
type walletBids struct{ h *BMMHandler }

func (w walletBids) details(
	ctx context.Context, walletID, txid string,
) (*wpb.GetTransactionDetailsResponse, error) {
	if w.h.wallet == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("no wallet is wired"))
	}
	resp, err := w.h.wallet.GetTransactionDetails(ctx, connect.NewRequest(&wpb.GetTransactionDetailsRequest{
		WalletId: walletID,
		Txid:     txid,
	}))
	if err != nil {
		return nil, connect.NewError(connect.CodeNotFound, fmt.Errorf("read bid %s: %w", txid, err))
	}
	return resp.Msg, nil
}

func (w walletBids) spends(ctx context.Context, walletID, txid string) ([]*wpb.UnspentOutput, error) {
	details, err := w.details(ctx, walletID, txid)
	if err != nil {
		return nil, err
	}
	if len(details.Inputs) == 0 {
		return nil, connect.NewError(connect.CodeFailedPrecondition,
			fmt.Errorf("bid %s has no inputs to reuse", txid))
	}
	return lo.Map(details.Inputs, func(in *wpb.TransactionInput, _ int) *wpb.UnspentOutput {
		return &wpb.UnspentOutput{Txid: in.PrevTxid, Vout: in.PrevVout}
	}), nil
}

func (w walletBids) pending(ctx context.Context, walletID, txid string) bool {
	details, err := w.details(ctx, walletID, txid)
	if err != nil || details.Confirmations > 0 {
		return false
	}
	return m8Script(details)
}

// feeSats reads what our bid pays. A block that already took it leaves no
// price to beat.
func (w walletBids) feeSats(ctx context.Context, walletID, txid string) (int64, bool, error) {
	details, err := w.details(ctx, walletID, txid)
	if err != nil {
		return 0, false, err
	}
	if details.Confirmations > 0 {
		return 0, false, nil
	}
	return details.FeeSats, true, nil
}

// paidSats reads what our bid pays a miner. The wallet reports the fee the
// transaction carries, which no node delta changes.
func (w walletBids) paidSats(ctx context.Context, walletID, txid string) (int64, bool, error) {
	return w.feeSats(ctx, walletID, txid)
}

// evicted names the chain the walk passed through. Each sidechain bids from a
// coin of its own, so the only transactions over our bid are the bids the walk
// already found.
func (w walletBids) evicted(_ context.Context, _, chain []string) []string {
	return chain
}

// pendingListCount is how much history PendingTxids asks for. An Electrum
// wallet sorts an unconfirmed row, which carries no block time, after the
// whole confirmed history.
const pendingListCount = 100_000

// walletGone reports whether walletID no longer exists. The router answers
// "wallet <id> not found" for one a user deleted, and the handler carries that
// text through. A looser match would swallow "method not found" from a live
// wallet whose backend is at fault.
func walletGone(err error, walletID string) bool {
	return strings.Contains(err.Error(), "wallet "+walletID+" not found")
}

// PendingTxids names our own transactions no block carries yet, over every
// wallet in walletIDs. The first id names the current funding wallet.
func (w walletBids) PendingTxids(ctx context.Context, walletIDs []string) (map[string]bool, error) {
	if w.h.wallet == nil {
		return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("no wallet is wired"))
	}
	held := make(map[string]bool)
	for i, walletID := range lo.Uniq(walletIDs) {
		resp, err := w.h.wallet.ListTransactions(ctx, connect.NewRequest(&wpb.ListTransactionsRequest{
			WalletId: walletID,
			Count:    pendingListCount,
		}))
		if err != nil {
			// A stored round names its funding wallet forever, so the tail of
			// this list can name a wallet the user deleted since. Only that
			// answer is safe to skip; every other one hides a backend fault
			// and would report a stranded bid as absent.
			if i > 0 && walletGone(err, walletID) {
				continue
			}
			return nil, connect.NewError(connect.CodeUnavailable, fmt.Errorf("list the wallet transactions: %w", err))
		}
		for _, tx := range resp.Msg.Transactions {
			if tx.Confirmations == 0 {
				held[tx.Txid] = true
			}
		}
	}
	return held, nil
}

// mined reads the chain source, because the wallet cache lags a new block.
func (w walletBids) mined(ctx context.Context, txid string) (bool, error) {
	if w.h.wallet == nil {
		return false, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("no wallet is wired"))
	}
	status, err := w.h.wallet.TxStatus(ctx, txid)
	if err != nil {
		return false, connect.NewError(connect.CodeUnavailable, fmt.Errorf("read the chain status of %s: %w", txid, err))
	}
	return status.Confirmed, nil
}

// m8Script says whether the transaction carries a BMM request in its first
// output, which is where an M8 sits.
func m8Script(details *wpb.GetTransactionDetailsResponse) bool {
	if len(details.Outputs) == 0 {
		return false
	}
	script, err := hex.DecodeString(details.Outputs[0].ScriptPubkeyHex)
	if err != nil {
		return false
	}
	return orchestrator.ParseM8BmmRequestScript(script) != nil
}

// frozenCoins names the candidates a live bid of ours holds. The unconfirmed
// transactions of the wallet name the whole bid line, and a raise evicts that
// line together with any send built on it.
func (w walletBids) frozenCoins(
	ctx context.Context, walletID string, candidates []wallet.Outpoint,
) (map[string]bool, error) {
	pending, err := w.PendingTxids(ctx, []string{walletID})
	if err != nil {
		return nil, err
	}
	if len(pending) == 0 {
		return nil, nil
	}

	details := make(map[string]*wpb.GetTransactionDetailsResponse, len(pending))
	for txid := range pending {
		tx, err := w.details(ctx, walletID, txid)
		if err != nil {
			return nil, err
		}
		details[txid] = tx
	}

	onLine := make(map[string]bool)
	var onBidLine func(txid string) bool
	onBidLine = func(txid string) bool {
		if on, done := onLine[txid]; done {
			return on
		}
		tx, ok := details[txid]
		if !ok {
			// A block holds it, so no replacement can reach it.
			return false
		}
		on := m8Script(tx)
		for _, in := range tx.Inputs {
			if on {
				break
			}
			on = onBidLine(in.PrevTxid)
		}
		onLine[txid] = on
		return on
	}

	spent := make(map[string]bool)
	for txid := range pending {
		if !onBidLine(txid) {
			continue
		}
		for _, in := range details[txid].Inputs {
			spent[(wallet.Outpoint{TxID: in.PrevTxid, Vout: int(in.PrevVout)}).Key()] = true
		}
	}

	frozen := make(map[string]bool)
	for _, cand := range candidates {
		if onBidLine(cand.TxID) || spent[cand.Key()] {
			frozen[cand.Key()] = true
		}
	}
	return frozen, nil
}
