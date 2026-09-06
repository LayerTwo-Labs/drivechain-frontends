package sidechain

import (
	"context"
	"encoding/json"
	"fmt"
)

// MempoolOutput is one output of an unconfirmed transaction.
type MempoolOutput struct {
	Address   string
	Vout      uint32
	ValueSats int64
}

// MempoolTx is one transaction the sidechain holds but has not mined.
//
// Txid and SizeBytes are empty on a node that serves no list_mempool: the
// block template names neither, and only the node can compute a txid.
type MempoolTx struct {
	Txid      string
	SizeBytes int64
	Outputs   []MempoolOutput
}

// Mempool reads the unconfirmed set.
//
// list_mempool answers it whole, with a txid per transaction. A node without
// that method answers the block template instead, which holds the same
// transactions and no txid.
func Mempool(ctx context.Context, node SidechainRPCProxy) ([]MempoolTx, error) {
	if txs, ok := listMempool(ctx, node); ok {
		return txs, nil
	}
	return templateMempool(ctx, node)
}

// CreditFor is what these transactions pay the given addresses, in sats.
func CreditFor(txs []MempoolTx, owned map[string]bool) int64 {
	var total int64
	for _, tx := range txs {
		for _, out := range tx.Outputs {
			if owned[out.Address] {
				total += out.ValueSats
			}
		}
	}
	return total
}

// OwnedOutputs are the unconfirmed outputs paying these addresses.
func OwnedOutputs(txs []MempoolTx, owned map[string]bool) []MempoolTx {
	out := make([]MempoolTx, 0, len(txs))
	for _, tx := range txs {
		kept := make([]MempoolOutput, 0, len(tx.Outputs))
		for _, o := range tx.Outputs {
			if owned[o.Address] {
				kept = append(kept, o)
			}
		}
		if len(kept) == 0 {
			continue
		}
		out = append(out, MempoolTx{Txid: tx.Txid, SizeBytes: tx.SizeBytes, Outputs: kept})
	}
	return out
}

// mempoolBody is the transaction shape both feeds share.
type mempoolBody struct {
	Outputs []struct {
		Address string          `json:"address"`
		Content json.RawMessage `json:"content"`
	} `json:"outputs"`
}

func (b mempoolBody) outputs() []MempoolOutput {
	out := make([]MempoolOutput, 0, len(b.Outputs))
	for i, o := range b.Outputs {
		out = append(out, MempoolOutput{
			Address:   o.Address,
			Vout:      uint32(i),
			ValueSats: OutputValueSats(o.Content),
		})
	}
	return out
}

// OutputValueSats reads the sats an output holds. A single asset chain names
// it Value, a multi asset chain names it BitcoinSats, and a withdrawal costs
// its payout and its mainchain fee together.
func OutputValueSats(content json.RawMessage) int64 {
	var withdrawal struct {
		Withdrawal        *withdrawalAmounts `json:"Withdrawal"`
		BitcoinWithdrawal *withdrawalAmounts `json:"BitcoinWithdrawal"`
	}
	if err := json.Unmarshal(content, &withdrawal); err == nil {
		if w := withdrawal.Withdrawal; w != nil {
			return w.total()
		}
		if w := withdrawal.BitcoinWithdrawal; w != nil {
			return w.total()
		}
	}
	var plain struct {
		Value       *int64 `json:"Value"`
		BitcoinSats *int64 `json:"BitcoinSats"`
	}
	if err := json.Unmarshal(content, &plain); err != nil {
		return 0
	}
	switch {
	case plain.Value != nil:
		return *plain.Value
	case plain.BitcoinSats != nil:
		return *plain.BitcoinSats
	}
	return 0
}

type withdrawalAmounts struct {
	Value       int64 `json:"value"`
	MainFee     int64 `json:"main_fee"`
	ValueSats   int64 `json:"value_sats"`
	MainFeeSats int64 `json:"main_fee_sats"`
}

func (w withdrawalAmounts) total() int64 {
	return max(w.Value, w.ValueSats) + max(w.MainFee, w.MainFeeSats)
}

// listMempool reads the node's own mempool listing. It answers false on a
// node that serves no such method.
func listMempool(ctx context.Context, node SidechainRPCProxy) ([]MempoolTx, bool) {
	raw, err := node.CallRaw(ctx, "list_mempool", nil)
	if err != nil || len(raw) == 0 || string(raw) == "null" {
		return nil, false
	}
	var rows []struct {
		Txid string      `json:"txid"`
		Size int64       `json:"size"`
		Tx   mempoolBody `json:"tx"`
	}
	if err := json.Unmarshal(raw, &rows); err != nil {
		return nil, false
	}
	out := make([]MempoolTx, 0, len(rows))
	for _, row := range rows {
		out = append(out, MempoolTx{
			Txid:      row.Txid,
			SizeBytes: row.Size,
			Outputs:   row.Tx.outputs(),
		})
	}
	return out, true
}

// templateMempool reads the block the node would mine next. Its body is the
// set the node holds, and it names no txid.
func templateMempool(ctx context.Context, node SidechainRPCProxy) ([]MempoolTx, error) {
	template, err := node.GetBlockTemplate(ctx)
	if err != nil {
		return nil, fmt.Errorf("read the block template: %w", err)
	}
	if template == nil || len(template.Block) == 0 {
		return nil, nil
	}
	var block struct {
		Body struct {
			Transactions []mempoolBody `json:"transactions"`
		} `json:"body"`
		Transactions []mempoolBody `json:"transactions"`
	}
	if err := json.Unmarshal(template.Block, &block); err != nil {
		return nil, fmt.Errorf("read the template body: %w", err)
	}
	body := block.Body.Transactions
	if len(body) == 0 {
		body = block.Transactions
	}
	out := make([]MempoolTx, 0, len(body))
	for _, tx := range body {
		out = append(out, MempoolTx{Outputs: tx.outputs()})
	}
	return out, nil
}
