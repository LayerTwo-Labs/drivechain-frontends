package sidechain

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
)

// MempoolOutput is one output of an unconfirmed transaction.
type MempoolOutput struct {
	Address   string
	Vout      uint32
	ValueSats int64
	// Withdrawal is true when the money leaves for the mainchain. The output
	// still names a change address, and the wallet never spends it again.
	Withdrawal bool
}

// MempoolInput is one coin an unconfirmed transaction spends, named the way a
// coin map keys it.
type MempoolInput struct {
	Key string
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
func Mempool(ctx context.Context, node Node) ([]MempoolTx, error) {
	if txs, ok := listMempool(ctx, node); ok {
		return txs, nil
	}
	return templateMempool(ctx, node)
}

// MempoolDelta is what the mempool does to this wallet, in sats.
//
// The two halves stay apart, because they land in different places: a coin on
// its way is pending, and a coin already spent leaves the confirmed count.
type MempoolDelta struct {
	// CreditSats is what the unconfirmed outputs pay us.
	CreditSats int64
	// DebitSats is what those transactions spend of our confirmed coins.
	DebitSats int64
	// ChainedDebitSats is what they spend of coins the mempool itself made.
	ChainedDebitSats int64
}

// DeltaFor reads what the mempool does to this wallet.
//
// ourCoins maps "txid:vout" to what that coin holds. Without the debit a
// transfer that pays change back counts the change on top of the coin it
// spends, and the wallet reads the same money twice.
//
// A transaction with no txid takes no part. Its outputs cannot be matched
// against what a later transaction spends, so counting them reads a chained
// spend twice over. Only list_mempool names a txid.
func DeltaFor(txs []MempoolTx, owned map[string]bool, ourCoins map[string]int64) MempoolDelta {
	// A child transaction spends a coin its parent made, and that coin never
	// reached the confirmed listing. Index it here, or the child's change
	// counts on top of a coin the wallet never held.
	memCoins := make(map[string]int64)
	for _, tx := range txs {
		if tx.Txid == "" {
			continue
		}
		for _, out := range tx.Outputs {
			if owned[out.Address] && !out.Withdrawal {
				memCoins[fmt.Sprintf("%s:%d", tx.Txid, out.Vout)] = out.ValueSats
			}
		}
	}

	var delta MempoolDelta
	for _, tx := range txs {
		if tx.Txid == "" {
			continue
		}
		for _, out := range tx.Outputs {
			// A withdrawal output carries a change address, and the money
			// still leaves the chain. Crediting it reads the payment back.
			if owned[out.Address] && !out.Withdrawal {
				delta.CreditSats += out.ValueSats
			}
		}
		for _, in := range tx.Inputs {
			if sats, ok := ourCoins[in.Key]; ok {
				delta.DebitSats += sats
				continue
			}
			delta.ChainedDebitSats += memCoins[in.Key]
		}
	}
	return delta
}

// OwnedOutputs are the unconfirmed outputs paying these addresses.
func OwnedOutputs(txs []MempoolTx, owned map[string]bool) []MempoolTx {
	out := make([]MempoolTx, 0, len(txs))
	for _, tx := range txs {
		kept := make([]MempoolOutput, 0, len(tx.Outputs))
		for _, o := range tx.Outputs {
			// A withdrawal is money on its way out, never a coin to spend.
			if owned[o.Address] && !o.Withdrawal {
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
	Inputs  []mempoolOutpoint `json:"inputs"`
	Outputs []struct {
		Address string          `json:"address"`
		Content json.RawMessage `json:"content"`
	} `json:"outputs"`
}

type mempoolOutpoint struct {
	Regular *struct {
		Txid string `json:"txid"`
		Vout uint32 `json:"vout"`
	} `json:"Regular"`
	Deposit *string `json:"Deposit"`
}

func (p *mempoolOutpoint) UnmarshalJSON(raw []byte) error {
	if bytes.HasPrefix(bytes.TrimSpace(raw), []byte("[")) {
		var pair []json.RawMessage
		if err := json.Unmarshal(raw, &pair); err != nil {
			return err
		}
		if len(pair) != 2 {
			return fmt.Errorf("a transaction input holds an outpoint and a hash, got %d parts", len(pair))
		}
		raw = pair[0]
	}
	type outpoint mempoolOutpoint
	return json.Unmarshal(raw, (*outpoint)(p))
}

// spends are the coins this transaction takes, each as the key its outpoint
// takes in a coin map. A coinbase names no coin a wallet holds.
func (b mempoolBody) spends() []MempoolInput {
	out := make([]MempoolInput, 0, len(b.Inputs))
	for _, in := range b.Inputs {
		switch {
		case in.Regular != nil:
			out = append(out, MempoolInput{Key: fmt.Sprintf("%s:%d", in.Regular.Txid, in.Regular.Vout)})
		case in.Deposit != nil:
			// A deposit outpoint is already the string "txid:vout".
			out = append(out, MempoolInput{Key: *in.Deposit})
		}
	}
	return out
}

func (b mempoolBody) outputs() []MempoolOutput {
	out := make([]MempoolOutput, 0, len(b.Outputs))
	for i, o := range b.Outputs {
		out = append(out, MempoolOutput{
			Address:    o.Address,
			Vout:       uint32(i),
			ValueSats:  OutputValueSats(o.Content),
			Withdrawal: IsWithdrawal(o.Content),
		})
	}
	return out
}

// IsWithdrawal is true when an output sends its money to the mainchain.
func IsWithdrawal(content json.RawMessage) bool {
	var out struct {
		Withdrawal        *withdrawalAmounts `json:"Withdrawal"`
		BitcoinWithdrawal *withdrawalAmounts `json:"BitcoinWithdrawal"`
	}
	if err := json.Unmarshal(content, &out); err != nil {
		return false
	}
	return out.Withdrawal != nil || out.BitcoinWithdrawal != nil
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
func listMempool(ctx context.Context, node Node) ([]MempoolTx, bool) {
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
// set the node holds, and it names no txid. A chain the BMM engine does not
// drive builds no template, so it answers nothing here.
func templateMempool(ctx context.Context, node Node) ([]MempoolTx, error) {
	bmm, ok := node.(BMMNode)
	if !ok {
		return nil, nil
	}
	template, err := bmm.GetBlockTemplate(ctx)
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
func WithMempoolUTXOs(ctx context.Context, node Node, confirmed json.RawMessage) json.RawMessage {
	owned, err := WalletAddresses(ctx, node)
	if err != nil || len(owned) == 0 {
		return confirmed
	}
	txs, err := Mempool(ctx, node)
	if err != nil {
		return confirmed
	}
	rows := mempoolUTXORows(OwnedOutputs(txs, owned))

	var listing []json.RawMessage
	if len(confirmed) > 0 {
		if err := json.Unmarshal(confirmed, &listing); err != nil {
			return confirmed
		}
	}
	// A coin an unconfirmed transaction spends is no longer spendable, so it
	// leaves the listing whether a block confirmed it or another mempool
	// transaction made it.
	kept := dropSpent(append(listing, rows...), spentKeys(txs))
	merged, err := json.Marshal(kept)
	if err != nil {
		return confirmed
	}
	return merged
}

// spentKeys names every coin the mempool spends.
func spentKeys(txs []MempoolTx) map[string]bool {
	spent := make(map[string]bool)
	for _, tx := range txs {
		for _, in := range tx.Inputs {
			spent[in.Key] = true
		}
	}
	return spent
}

// dropSpent removes each listed coin that the mempool already spends.
func dropSpent(rows []json.RawMessage, spent map[string]bool) []json.RawMessage {
	if len(spent) == 0 {
		return rows
	}
	kept := make([]json.RawMessage, 0, len(rows))
	for _, row := range rows {
		if key, ok := outpointKey(row); ok && spent[key] {
			continue
		}
		kept = append(kept, row)
	}
	return kept
}

// outpointKey reads the coin key out of one listed UTXO.
func outpointKey(row json.RawMessage) (string, bool) {
	var entry struct {
		Outpoint struct {
			Regular *struct {
				Txid string `json:"txid"`
				Vout uint32 `json:"vout"`
			} `json:"Regular"`
			Deposit *string `json:"Deposit"`
		} `json:"outpoint"`
	}
	if err := json.Unmarshal(row, &entry); err != nil {
		return "", false
	}
	switch {
	case entry.Outpoint.Regular != nil:
		return fmt.Sprintf("%s:%d", entry.Outpoint.Regular.Txid, entry.Outpoint.Regular.Vout), true
	case entry.Outpoint.Deposit != nil:
		return *entry.Outpoint.Deposit, true
	}
	return "", false
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
func WalletAddresses(ctx context.Context, node Node) (map[string]bool, error) {
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
func OurCoins(ctx context.Context, node Node) (map[string]int64, error) {
	raw, err := node.CallRaw(ctx, "get_wallet_utxos", nil)
	if err != nil {
		return nil, fmt.Errorf("read the wallet coins: %w", err)
	}
	var rows []struct {
		Outpoint struct {
			Regular *struct {
				Txid string `json:"txid"`
				Vout uint32 `json:"vout"`
			} `json:"Regular"`
			Deposit *string `json:"Deposit"`
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
		switch {
		case row.Outpoint.Regular != nil:
			key := fmt.Sprintf("%s:%d", row.Outpoint.Regular.Txid, row.Outpoint.Regular.Vout)
			coins[key] = OutputValueSats(row.Output.Content)
		case row.Outpoint.Deposit != nil:
			// A deposit outpoint is already the string an input names.
			coins[*row.Outpoint.Deposit] = OutputValueSats(row.Output.Content)
		}
	}
	return coins, nil
}
