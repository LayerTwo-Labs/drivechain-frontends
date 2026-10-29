package wallet

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"slices"
)

// StrandedReleaser abandons the wallet transactions that can never confirm.
type StrandedReleaser interface {
	// ReleaseStranded abandons the transactions that can never enter the
	// current chain. retiredLockTimes are the replay locktimes of the other
	// eCash networks. It returns false when the chain is not synced yet.
	ReleaseStranded(ctx context.Context, retiredLockTimes []uint32) (bool, error)
}

var _ StrandedReleaser = (*CoreBackend)(nil)

// TxCheck is what Core says about one unconfirmed wallet transaction.
type TxCheck struct {
	InMempool bool
	// RetiredLock is true when the mempool refused it as non-final for the
	// replay locktime of another eCash network, which this chain never reaches.
	RetiredLock bool
	// Accepted is true when the mempool takes the transaction now.
	Accepted bool
	// MissingInputs is true when the mempool refused it for an input the chain
	// does not hold unspent.
	MissingInputs bool
	// Inputs is set only when MissingInputs is true.
	Inputs []TxInput
}

// TxInput is one input of a transaction the mempool refused for its inputs.
type TxInput struct {
	Parent string
	// Unspent is true when the chain or the mempool holds the output unspent.
	Unspent bool
}

// mempoolMissingInputs are the reject reasons for an input the chain does not
// hold unspent.
var mempoolMissingInputs = []string{"missing-inputs", "bad-txns-inputs-missingorspent"}

// StrandedTxIDs selects the unconfirmed, not abandoned transactions that can
// never enter the chain: a retired replay locktime, or an input that is not
// unspent and whose parent is no wallet transaction that can still confirm.
func StrandedTxIDs(txs []WalletTransaction, checks map[string]TxCheck) []string {
	abandoned := make(map[string]bool)
	for _, tx := range txs {
		if tx.Abandoned {
			abandoned[tx.TxID] = true
		}
	}
	var candidates []string
	seen := make(map[string]bool)
	for _, tx := range txs {
		if tx.Confirmations != 0 || abandoned[tx.TxID] || seen[tx.TxID] {
			continue
		}
		seen[tx.TxID] = true
		check, ok := checks[tx.TxID]
		if !ok || check.InMempool || check.Accepted || (!check.RetiredLock && !check.MissingInputs) {
			continue
		}
		candidates = append(candidates, tx.TxID)
	}

	// A wallet parent keeps its child only while the parent can still confirm.
	stranded := make(map[string]bool)
	for changed := true; changed; {
		changed = false
		for _, txid := range candidates {
			if stranded[txid] {
				continue
			}
			check := checks[txid]
			lost := check.RetiredLock || slices.ContainsFunc(check.Inputs, func(in TxInput) bool {
				if in.Unspent {
					return false
				}
				_, wallet := checks[in.Parent]
				return !wallet || stranded[in.Parent]
			})
			if lost {
				stranded[txid] = true
				changed = true
			}
		}
	}
	return slices.DeleteFunc(candidates, func(txid string) bool { return !stranded[txid] })
}

// ReleaseStranded abandons the stranded transactions of every Core wallet.
func (p *CoreBackend) ReleaseStranded(ctx context.Context, retiredLockTimes []uint32) (bool, error) {
	synced, err := p.chainSynced(ctx)
	if err != nil || !synced {
		return false, err
	}
	var errs []error
	for _, w := range p.svc.GetAllWallets() {
		if w.WalletType != WalletTypeBitcoinCore {
			continue
		}
		name, err := p.walletName(ctx, w.ID)
		if err != nil {
			errs = append(errs, fmt.Errorf("load core wallet %s: %w", w.ID, err))
			continue
		}
		if err := p.releaseStrandedIn(ctx, name, retiredLockTimes); err != nil {
			errs = append(errs, fmt.Errorf("release core wallet %s: %w", name, err))
		}
	}
	if err := errors.Join(errs...); err != nil {
		return false, err
	}
	return true, nil
}

// chainSynced reports whether Core holds every block of the best header, so a
// transaction with no confirmation is not in a block Core still has to read.
func (p *CoreBackend) chainSynced(ctx context.Context) (bool, error) {
	raw, err := p.rpc.GetBlockchainInfo(ctx)
	if err != nil {
		return false, err
	}
	var info struct {
		Blocks               int64 `json:"blocks"`
		Headers              int64 `json:"headers"`
		InitialBlockDownload bool  `json:"initialblockdownload"`
	}
	if err := json.Unmarshal(raw, &info); err != nil {
		return false, fmt.Errorf("decode getblockchaininfo: %w", err)
	}
	return !info.InitialBlockDownload && info.Headers > 0 && info.Blocks >= info.Headers, nil
}

func (p *CoreBackend) releaseStrandedIn(ctx context.Context, name string, retiredLockTimes []uint32) error {
	txs, err := p.rpc.ListAllTransactions(ctx, name)
	if err != nil {
		return err
	}
	checks := make(map[string]TxCheck)
	for _, tx := range txs {
		if tx.Confirmations != 0 || tx.Abandoned {
			continue
		}
		if _, ok := checks[tx.TxID]; ok {
			continue
		}
		check, err := p.checkUnconfirmed(ctx, name, tx.TxID, retiredLockTimes)
		if err != nil {
			return fmt.Errorf("check %s: %w", tx.TxID, err)
		}
		checks[tx.TxID] = check
	}
	var errs []error
	for _, txid := range StrandedTxIDs(txs, checks) {
		if err := p.rpc.AbandonTransaction(ctx, name, txid); err != nil {
			errs = append(errs, fmt.Errorf("abandon %s: %w", txid, err))
			continue
		}
		p.log.Info().Str("wallet", name).Str("txid", txid).Msg("abandoned a transaction that can never confirm")
	}
	return errors.Join(errs...)
}

func (p *CoreBackend) checkUnconfirmed(ctx context.Context, name, txid string, retiredLockTimes []uint32) (TxCheck, error) {
	in, err := p.rpc.InMempool(ctx, txid)
	if err != nil || in {
		return TxCheck{InMempool: in}, err
	}
	tx, err := p.rpc.GetDecodedWalletTransaction(ctx, name, txid)
	if err != nil {
		return TxCheck{}, err
	}
	accepted, reason, err := p.rpc.TestMempoolAccept(ctx, tx.Hex)
	if err != nil {
		return TxCheck{}, err
	}
	check := TxCheck{
		Accepted:    accepted,
		RetiredLock: reason == "non-final" && slices.Contains(retiredLockTimes, tx.Decoded.LockTime),
	}
	check.MissingInputs = slices.Contains(mempoolMissingInputs, reason)
	if !check.MissingInputs {
		return check, nil
	}
	for _, vin := range tx.Decoded.Vin {
		unspent, err := p.rpc.OutputUnspent(ctx, vin.TxID, vin.Vout)
		if err != nil {
			return TxCheck{}, err
		}
		check.Inputs = append(check.Inputs, TxInput{Parent: vin.TxID, Unspent: unspent})
	}
	return check, nil
}
