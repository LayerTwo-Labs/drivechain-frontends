package api

import (
	"encoding/json"
	"testing"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/explorer/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/sidechainesplora"
)

// A bundle pays its highest mainchain fee first, and each withdrawal costs the
// same weight, so the cumulative weight rises by a fixed step.
func TestParseBundleOrdersByMainchainFeeAndCountsWeight(t *testing.T) {
	raw := json.RawMessage(`{
		"height_created": 812401,
		"tx": {"outputs": [
			{"content": {"Withdrawal": {"value": 500000, "main_fee": 900, "main_address": "bc1qlow"}}},
			{"content": {"Value": 40000}},
			{"content": {"Withdrawal": {"value": 100000, "main_fee": 1200, "main_address": "bc1qhigh"}}}
		]}
	}`)

	bundle := parseBundle(raw)
	if !bundle.GetPresent() {
		t.Fatal("the bundle reads as absent")
	}
	if got := bundle.GetHeightCreated(); got != 812401 {
		t.Errorf("height created = %d, want 812401", got)
	}
	if got := len(bundle.GetWithdrawals()); got != 2 {
		t.Fatalf("the bundle holds %d withdrawals, want 2", got)
	}
	if got := bundle.GetWithdrawals()[0].GetMainAddress(); got != "bc1qhigh" {
		t.Errorf("the first payout goes to %s, want bc1qhigh", got)
	}
	if got := bundle.GetTotalValueSats(); got != 600000 {
		t.Errorf("total value = %d, want 600000", got)
	}
	if got := bundle.GetTotalMainFeesSats(); got != 2100 {
		t.Errorf("total mainchain fees = %d, want 2100", got)
	}

	first := baseWithdrawalBundleWeight + weightPerWithdrawalOutput
	if got := bundle.GetWithdrawals()[0].GetCumulativeWeight(); got != uint32(first) {
		t.Errorf("the first weight = %d, want %d", got, first)
	}
	second := first + weightPerWithdrawalOutput
	if got := bundle.GetWithdrawals()[1].GetCumulativeWeight(); got != uint32(second) {
		t.Errorf("the second weight = %d, want %d", got, second)
	}
	if got := bundle.GetTotalWeight(); got != uint32(second) {
		t.Errorf("total weight = %d, want %d", got, second)
	}
	if got := bundle.GetMaxWeight(); got != maxWithdrawalBundleWeight {
		t.Errorf("max weight = %d, want %d", got, maxWithdrawalBundleWeight)
	}
}

// A chain with no bundle still answers, and the answer says so.
func TestParseBundleWithNoBundle(t *testing.T) {
	for name, raw := range map[string]json.RawMessage{
		"null":   json.RawMessage("null"),
		"empty":  nil,
		"broken": json.RawMessage(`{"tx":{"outputs":[{"content":{"Value":1}}]}}`),
	} {
		t.Run(name, func(t *testing.T) {
			bundle := parseBundle(raw)
			if bundle.GetPresent() {
				t.Error("the bundle reads as present")
			}
			if got := len(bundle.GetWithdrawals()); got != 0 {
				t.Errorf("the bundle holds %d withdrawals, want none", got)
			}
		})
	}
}

// A withdrawal transaction names its mainchain address and fee, so a reader
// sees where the money goes.
func TestTransactionNamesTheWithdrawalPayout(t *testing.T) {
	tx := sidechainesplora.Tx{
		Txid: "abc",
		Fee:  1000,
		Size: 240,
		Vin: []sidechainesplora.Vin{{
			Txid: "prev", Vout: 0,
			Prevout: &sidechainesplora.Vout{
				ScriptPubKeyAddress: "side1", Value: 200000,
				OutpointKind: "regular", ContentType: "value",
			},
		}},
		Vout: []sidechainesplora.Vout{{
			ScriptPubKeyAddress: "side2", Value: 51200,
			ContentType: "withdrawal",
			Content: json.RawMessage(
				`{"Withdrawal":{"value":50000,"main_fee":1200,"main_address":"bc1qout"}}`),
		}},
		Status: sidechainesplora.Status{Confirmed: true, BlockHeight: 44},
	}

	out := newTransaction(tx)
	if out.GetKind() != pb.Kind_KIND_WITHDRAWAL {
		t.Errorf("kind = %s, want a withdrawal", out.GetKind())
	}
	if got := out.GetOutputs()[0].GetMainAddress(); got != "bc1qout" {
		t.Errorf("mainchain address = %q, want bc1qout", got)
	}
	if got := out.GetOutputs()[0].GetMainFeeSats(); got != 1200 {
		t.Errorf("mainchain fee = %d, want 1200", got)
	}
	if got := out.GetBlockHeight(); got != 44 {
		t.Errorf("block height = %d, want 44", got)
	}
}

// A transaction that spends a deposit reads as a deposit, because that is what
// a reader is looking for on an address page.
func TestTransactionSpendingADepositReadsAsOne(t *testing.T) {
	tx := sidechainesplora.Tx{
		Txid: "abc",
		Vin: []sidechainesplora.Vin{{
			Prevout: &sidechainesplora.Vout{
				ScriptPubKeyAddress: "side1", Value: 100000,
				OutpointKind: sidechainesplora.KindDeposit,
			},
		}},
		Vout: []sidechainesplora.Vout{{
			ScriptPubKeyAddress: "side2", Value: 99000, ContentType: "value",
		}},
	}
	if got := newTransaction(tx).GetKind(); got != pb.Kind_KIND_DEPOSIT {
		t.Errorf("kind = %s, want a deposit", got)
	}
}

// A deposit outpoint reads "txid:vout", so the feed keeps the mainchain txid.
func TestDepositTxidDropsTheVout(t *testing.T) {
	const outpoint = "f6a58d2c6be916d78d:1"
	if got := depositTxid(outpoint); got != "f6a58d2c6be916d78d" {
		t.Errorf("deposit txid = %q, want the mainchain txid", got)
	}
	if got := depositTxid("nocolon"); got != "nocolon" {
		t.Errorf("a bare id reads as %q, want it unchanged", got)
	}
}
