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

// MempoolInput is one coin an unconfirmed transaction spends.
type MempoolInput struct {
	Txid string
	Vout uint32
}

// MempoolTx is one transaction the sidechain holds but has not mined.
//
// Txid and SizeBytes are empty on a node that serves no list_mempool: the
// block template names neither, and only the node can compute a txid.
type MempoolTx struct {
	Txid      string
	SizeBytes int64
	Inputs    []MempoolInput
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

// NetCreditFor is what the mempool adds to this wallet, in sats: the outputs
// it pays us, less the coins of ours it spends.
//
// ourCoins maps "txid:vout" to what that coin holds. Without the subtraction a
// transfer that pays change back counts the change on top of the coin it
// spends, and the wallet reads the same money twice.
func NetCreditFor(txs []MempoolTx, owned map[string]bool, ourCoins map[string]int64) int64 {
	var total int64
	for _, tx := range txs {
		for _, out := range tx.Outputs {
			if owned[out.Address] {
				total += out.ValueSats
			}
		}
		for _, in := range tx.Inputs {
			total -= ourCoins[fmt.Sprintf("%s:%d", in.Txid, in.Vout)]
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
	Inputs []struct {
		Regular *struct {
			Txid string `json:"txid"`
			Vout uint32 `json:"vout"`
		} `json:"Regular"`
	} `json:"inputs"`
	Outputs []struct {
		Address string          `json:"address"`
		Content json.RawMessage `json:"content"`
	} `json:"outputs"`
}

// spends are the coins this transaction takes. Only a regular input names a
// coin this wallet can hold; a deposit and a coinbase come from elsewhere.
func (b mempoolBody) spends() []MempoolInput {
	out := make([]MempoolInput, 0, len(b.Inputs))
	for _, in := range b.Inputs {
		if in.Regular == nil {
			continue
		}
		out = append(out, MempoolInput{Txid: in.Regular.Txid, Vout: in.Regular.Vout})
	}
	return out
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
			Inputs:    row.Tx.spends(),
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
		out = append(out, MempoolTx{Inputs: tx.spends(), Outputs: tx.outputs()})
	}
	return out, nil
}

// WithMempoolUTXOs appends the wallet's unconfirmed coins to a node's own
// UTXO listing, in the same shape, each marked unconfirmed.
//
// Only a node that names its mempool txids contributes rows: a coin with no
// outpoint is not a coin. The balance counts those payments regardless.
func WithMempoolUTXOs(ctx context.Context, node SidechainRPCProxy, confirmed json.RawMessage) json.RawMessage {
	owned, err := WalletAddresses(ctx, node)
	if err != nil || len(owned) == 0 {
		return confirmed
	}
	txs, err := Mempool(ctx, node)
	if err != nil {
		return confirmed
	}
	rows := mempoolUTXORows(OwnedOutputs(txs, owned))
	if len(rows) == 0 {
		return confirmed
	}

	var listing []json.RawMessage
	if len(confirmed) > 0 {
		if err := json.Unmarshal(confirmed, &listing); err != nil {
			return confirmed
		}
	}
	merged, err := json.Marshal(append(listing, rows...))
	if err != nil {
		return confirmed
	}
	return merged
}

// mempoolUTXORows writes each unconfirmed output the way the node writes a
// confirmed one, plus the flag that says it is not mined.
func mempoolUTXORows(txs []MempoolTx) []json.RawMessage {
	var rows []json.RawMessage
	for _, tx := range txs {
		if tx.Txid == "" {
			continue
		}
		for _, out := range tx.Outputs {
			row, err := json.Marshal(map[string]any{
				"outpoint": map[string]any{
					"Regular": map[string]any{"txid": tx.Txid, "vout": out.Vout},
				},
				"output": map[string]any{
					"address": out.Address,
					"content": map[string]any{"Value": out.ValueSats},
				},
				"confirmed": false,
			})
			if err != nil {
				continue
			}
			rows = append(rows, row)
		}
	}
	return rows
}

// WalletAddresses reads the addresses a node's own wallet holds.
func WalletAddresses(ctx context.Context, node SidechainRPCProxy) (map[string]bool, error) {
	raw, err := node.CallRaw(ctx, "get_wallet_addresses", nil)
	if err != nil {
		return nil, fmt.Errorf("read the wallet addresses: %w", err)
	}
	var list []string
	if err := json.Unmarshal(raw, &list); err != nil {
		return nil, fmt.Errorf("read the wallet addresses: %w", err)
	}
	owned := make(map[string]bool, len(list))
	for _, address := range list {
		owned[address] = true
	}
	return owned, nil
}

// OurCoins maps each coin a node's wallet holds to what it holds, keyed
// "txid:vout". A caller reads it to know what an unconfirmed transaction
// spends of ours.
func OurCoins(ctx context.Context, node SidechainRPCProxy) (map[string]int64, error) {
	raw, err := node.GetWalletUtxos(ctx)
	if err != nil {
		return nil, fmt.Errorf("read the wallet coins: %w", err)
	}
	var rows []struct {
		Outpoint struct {
			Regular *struct {
				Txid string `json:"txid"`
				Vout uint32 `json:"vout"`
			} `json:"Regular"`
		} `json:"outpoint"`
		Output struct {
			Content json.RawMessage `json:"content"`
		} `json:"output"`
	}
	if err := json.Unmarshal(raw, &rows); err != nil {
		return nil, fmt.Errorf("read the wallet coins: %w", err)
	}
	coins := make(map[string]int64, len(rows))
	for _, row := range rows {
		if row.Outpoint.Regular == nil {
			continue
		}
		key := fmt.Sprintf("%s:%d", row.Outpoint.Regular.Txid, row.Outpoint.Regular.Vout)
		coins[key] = OutputValueSats(row.Output.Content)
	}
	return coins, nil
}
