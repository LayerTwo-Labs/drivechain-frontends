package api

import (
	"encoding/json"
	"sort"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/explorer/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/sidechainesplora"
)

// contentWithdrawal is a withdrawal output as a chain writes it. The two
// spellings both appear on the wire: get_transaction writes the plain pair,
// and the human readable form renames them.
type contentWithdrawal struct {
	Withdrawal *struct {
		Value       uint64 `json:"value"`
		MainFee     uint64 `json:"main_fee"`
		ValueSats   uint64 `json:"value_sats"`
		MainFeeSats uint64 `json:"main_fee_sats"`
		MainAddress string `json:"main_address"`
	} `json:"Withdrawal"`
}

// nodeBundle is the pending withdrawal bundle as a node writes it.
//
// The payouts sit in spend_utxos, as [outpoint, output] pairs. The tx beside
// them is the mainchain transaction, and its outputs carry no content.
type nodeBundle struct {
	HeightCreated uint32            `json:"height_created"`
	SpendUtxos    []json.RawMessage `json:"spend_utxos"`
}

// spentOutput reads the output half of one spend_utxos pair.
type spentOutput struct {
	Content json.RawMessage `json:"content"`
}

// parseBundle reads the node's own bundle JSON into the explorer shape. A
// chain with no bundle answers a message that says so.
func parseBundle(raw json.RawMessage) *pb.WithdrawalBundle {
	out := &pb.WithdrawalBundle{MaxWeight: maxWithdrawalBundleWeight}
	if len(raw) == 0 || string(raw) == "null" {
		return out
	}
	var bundle nodeBundle
	if err := json.Unmarshal(raw, &bundle); err != nil {
		return out
	}

	for _, pair := range bundle.SpendUtxos {
		var spent []json.RawMessage
		if err := json.Unmarshal(pair, &spent); err != nil || len(spent) != 2 {
			continue
		}
		var output spentOutput
		if err := json.Unmarshal(spent[1], &output); err != nil {
			continue
		}
		w, ok := readWithdrawal(output.Content)
		if !ok {
			continue
		}
		out.Withdrawals = append(out.Withdrawals, w)
	}
	if len(out.Withdrawals) == 0 {
		return out
	}

	// The bundle pays the highest mainchain fee first, which is the order the
	// chain itself takes them in.
	sort.SliceStable(out.Withdrawals, func(i, j int) bool {
		return out.Withdrawals[i].MainFeeSats > out.Withdrawals[j].MainFeeSats
	})

	out.Present = true
	out.HeightCreated = bundle.HeightCreated
	weight := uint32(baseWithdrawalBundleWeight)
	for _, w := range out.Withdrawals {
		weight += weightPerWithdrawalOutput
		w.CumulativeWeight = weight
		out.TotalValueSats += w.ValueSats
		out.TotalMainFeesSats += w.MainFeeSats
	}
	out.TotalWeight = weight
	return out
}

// readWithdrawal reads one withdrawal output. An output that carries a plain
// value is not part of the payout, so it answers false.
func readWithdrawal(raw json.RawMessage) (*pb.Withdrawal, bool) {
	var content contentWithdrawal
	if err := json.Unmarshal(raw, &content); err != nil || content.Withdrawal == nil {
		return nil, false
	}
	return &pb.Withdrawal{
		MainAddress: content.Withdrawal.MainAddress,
		ValueSats:   int64(max(content.Withdrawal.Value, content.Withdrawal.ValueSats)),
		MainFeeSats: int64(max(content.Withdrawal.MainFee, content.Withdrawal.MainFeeSats)),
	}, true
}

// newTransaction reads one indexed transaction into the explorer shape.
func newTransaction(tx sidechainesplora.Tx) *pb.Transaction {
	out := &pb.Transaction{
		Txid:        tx.Txid,
		Kind:        pb.Kind_KIND_TRANSFER,
		FeeSats:     tx.Fee,
		SizeBytes:   int64(tx.Size),
		Confirmed:   tx.Status.Confirmed,
		BlockHeight: tx.Status.BlockHeight,
		BlockHash:   tx.Status.BlockHash,
		BlockTime:   tx.Status.BlockTime,
	}

	for _, in := range tx.Vin {
		coin := &pb.Coin{Txid: in.Txid, Vout: in.Vout}
		if in.Prevout != nil {
			coin.Address = in.Prevout.ScriptPubKeyAddress
			coin.ValueSats = in.Prevout.Value
			coin.OutpointKind = in.Prevout.OutpointKind
			coin.ContentType = in.Prevout.ContentType
			if in.Prevout.OutpointKind == sidechainesplora.KindDeposit {
				out.Kind = pb.Kind_KIND_DEPOSIT
			}
		}
		out.Inputs = append(out.Inputs, coin)
	}

	for _, o := range tx.Vout {
		coin := &pb.Coin{
			Address:      o.ScriptPubKeyAddress,
			ValueSats:    o.Value,
			OutpointKind: o.OutpointKind,
			ContentType:  o.ContentType,
		}
		if w, ok := readWithdrawal(o.Content); ok {
			coin.MainAddress = w.MainAddress
			coin.MainFeeSats = w.MainFeeSats
			out.Kind = pb.Kind_KIND_WITHDRAWAL
		}
		out.Outputs = append(out.Outputs, coin)
	}
	return out
}
