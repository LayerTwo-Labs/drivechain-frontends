package api

import (
	"context"
	"encoding/json"
	"fmt"
	"testing"

	"connectrpc.com/connect"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/explorer/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/sidechainesplora"
)

// A bundle pays its highest mainchain fee first, and each withdrawal costs the
// same weight, so the cumulative weight rises by a fixed step.
func TestParseBundleOrdersByMainchainFeeAndCountsWeight(t *testing.T) {
	// The payouts sit in spend_utxos, as [outpoint, output] pairs. The tx
	// beside them is the mainchain transaction, and it carries no content.
	raw := json.RawMessage(`{
		"height_created": 812401,
		"spend_utxos": [
			[{"Regular": {"txid": "aa", "vout": 0}},
			 {"address": "s1", "content": {"Withdrawal": {"value": 500000, "main_fee": 900, "main_address": "bc1qlow"}}}],
			[{"Regular": {"txid": "bb", "vout": 0}},
			 {"address": "s2", "content": {"Value": 40000}}],
			[{"Regular": {"txid": "cc", "vout": 0}},
			 {"address": "s3", "content": {"Withdrawal": {"value": 100000, "main_fee": 1200, "main_address": "bc1qhigh"}}}]
		],
		"tx": {"vout": [{"value": 0.005}]}
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
		"null":  json.RawMessage("null"),
		"empty": nil,
		"no payouts": json.RawMessage(
			`{"spend_utxos":[[{"Regular":{"txid":"aa","vout":0}},{"content":{"Value":1}}]]}`),
		"tx only": json.RawMessage(`{"tx":{"vout":[{"value":0.005}]}}`),
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

// A Core derived sidechain speaks Core's own method names. A block read must
// not send get_block_hash to it.
func TestCoreBlockReadsCoreShapes(t *testing.T) {
	node := &recordingNode{answers: map[string]string{
		"getblockhash": `"0000ab"`,
		"getblock": `{"hash":"0000ab","height":7,"merkleroot":"mm",
		              "previousblockhash":"0000aa","time":1700000000,
		              "size":285,"tx":["t1","t2"]}`,
	}}
	src := source{name: "bbc", node: node, core: true}

	block, activity, err := coreBlockAtHeight(context.Background(), src, 7)
	if err != nil {
		t.Fatalf("read the block: %v", err)
	}
	if block.GetHeight() != 7 || block.GetHash() != "0000ab" {
		t.Errorf("the block reads %+v, want height 7 at 0000ab", block)
	}
	if block.GetTxCount() != 2 || len(activity) != 2 {
		t.Errorf("the block counts %d transactions and lists %d",
			block.GetTxCount(), len(activity))
	}
	if block.GetBlockTime() != 1700000000 {
		t.Errorf("block time = %d, want the time Core reports", block.GetBlockTime())
	}
	for _, method := range node.called {
		if method == "get_block_hash" || method == "get_block" {
			t.Errorf("a Core node was asked %q, which it does not serve", method)
		}
	}
}

// A sidechain node reads a block by hash and never by height, so the walk
// follows prev_side_hash from the tip.
func TestNodeWalksBackByThePreviousHash(t *testing.T) {
	node := &recordingNode{
		count: 3,
		answers: map[string]string{
			"get_best_sidechain_block_hash": `"cc"`,
		},
		byHash: map[string]string{
			"cc": `{"header":{"merkle_root":"m3","prev_side_hash":"bb","prev_main_hash":"x3"},"body":{"transactions":[]}}`,
			"bb": `{"header":{"merkle_root":"m2","prev_side_hash":"aa","prev_main_hash":"x2"},"body":{"transactions":[]}}`,
			"aa": `{"header":{"merkle_root":"m1","prev_main_hash":"x1"},"body":{"transactions":[]}}`,
		},
	}
	src := source{name: "thunder", node: node}

	hash, err := nodeHashAtHeight(context.Background(), src, 0)
	if err != nil {
		t.Fatalf("walk to height 0: %v", err)
	}
	if hash != "aa" {
		t.Errorf("height 0 hashes to %q, want aa", hash)
	}
	for _, method := range node.called {
		if method == "get_block_hash" {
			t.Error("the walk asked for get_block_hash, which no node serves")
		}
	}
}

// recordingNode answers a fixed set of RPCs and records what it was asked.
type recordingNode struct {
	sidechain.SidechainRPCProxy
	count   int64
	answers map[string]string
	byHash  map[string]string
	called  []string
}

func (n *recordingNode) GetBlockCount(context.Context) (int64, error) {
	return n.count, nil
}

func (n *recordingNode) CallRaw(_ context.Context, method string, params any) (json.RawMessage, error) {
	n.called = append(n.called, method)
	if method == "get_block" || method == "get_block_index" {
		list, ok := params.([]string)
		if !ok || len(list) != 1 {
			return nil, fmt.Errorf("%s takes a list of one hash, got %#v", method, params)
		}
		body, ok := n.byHash[list[0]]
		if !ok {
			return nil, fmt.Errorf("no block %q", list[0])
		}
		if method == "get_block_index" {
			return nil, fmt.Errorf("this node serves no block index")
		}
		return json.RawMessage(body), nil
	}
	body, ok := n.answers[method]
	if !ok {
		return nil, fmt.Errorf("no answer for %q", method)
	}
	return json.RawMessage(body), nil
}

// A node block names no height, so a block opened by hash must resolve one.
// Every overview card opens by hash alone.
func TestNodeBlockOpenedByHashKeepsItsHeight(t *testing.T) {
	node := &recordingNode{
		count: 3,
		answers: map[string]string{
			"get_best_sidechain_block_hash": `"cc"`,
		},
		byHash: map[string]string{
			"cc": `{"header":{"merkle_root":"m3","prev_side_hash":"bb","prev_main_hash":"x3"},"body":{"transactions":[]}}`,
			"bb": `{"header":{"merkle_root":"m2","prev_side_hash":"aa","prev_main_hash":"x2"},"body":{"transactions":[]}}`,
			"aa": `{"header":{"merkle_root":"m1","prev_main_hash":"x1"},"body":{"transactions":[]}}`,
		},
	}
	src := source{name: "thunder", node: node}

	for hash, want := range map[string]uint32{"cc": 2, "bb": 1, "aa": 0} {
		height, err := nodeHeightOfHash(context.Background(), src, hash)
		if err != nil {
			t.Fatalf("resolve the height of %s: %v", hash, err)
		}
		if height != want {
			t.Errorf("%s sits at height %d, want %d", hash, height, want)
		}
	}
}

// A node keeps no transaction index. It says so rather than answering an
// empty transaction.
func TestNodeTransactionSaysWhenItHoldsNone(t *testing.T) {
	node := &recordingNode{answers: map[string]string{"get_transaction": `null`}}
	src := source{name: "thunder", node: node}

	if _, err := nodeTransaction(context.Background(), src, "abc"); err == nil {
		t.Fatal("a missing transaction reads as found")
	} else if connect.CodeOf(err) != connect.CodeNotFound {
		t.Errorf("a missing transaction answers %s, want NotFound", connect.CodeOf(err))
	}
}

// A node transaction names its outputs, and a withdrawal names its payout.
func TestNodeTransactionReadsAWithdrawal(t *testing.T) {
	node := &recordingNode{answers: map[string]string{
		"get_transaction": `{
			"inputs":[{"Regular":{"txid":"prev","vout":0}}],
			"outputs":[
				{"address":"s1","content":{"Value":40000}},
				{"address":"s2","content":{"Withdrawal":{"value":50000,"main_fee":1200,"main_address":"bc1qout"}}}
			]}`,
	}}
	src := source{name: "thunder", node: node}

	out, err := nodeTransaction(context.Background(), src, "abc")
	if err != nil {
		t.Fatalf("read the transaction: %v", err)
	}
	if out.GetKind() != pb.Kind_KIND_WITHDRAWAL {
		t.Errorf("kind = %s, want a withdrawal", out.GetKind())
	}
	if len(out.GetInputs()) != 1 || out.GetInputs()[0].GetTxid() != "prev" {
		t.Errorf("the inputs read %+v, want the coin it spends", out.GetInputs())
	}
	if got := out.GetOutputs()[0].GetValueSats(); got != 40000 {
		t.Errorf("the plain output is worth %d, want 40000", got)
	}
	if got := out.GetOutputs()[1].GetMainAddress(); got != "bc1qout" {
		t.Errorf("the payout goes to %q, want bc1qout", got)
	}
}

// Two block layouts exist. Thunder nests the header and the body; bitassets,
// bitnames and truthcoin flatten both and add a height.
func TestNodeBlockReadsBothLayouts(t *testing.T) {
	const nested = `{"header":{"merkle_root":"mm","prev_side_hash":"pp","prev_main_hash":"xx"},
	                 "body":{"transactions":[{},{}]}}`
	const flat = `{"merkle_root":"mm","prev_side_hash":"pp","prev_main_hash":"xx",
	               "transactions":[{},{}],"height":41,"coinbase":[]}`

	for name, body := range map[string]string{"nested": nested, "flat": flat} {
		t.Run(name, func(t *testing.T) {
			node := &recordingNode{byHash: map[string]string{"aa": body}}
			src := source{name: "chain", node: node}

			block, _, err := nodeBlock(context.Background(), src, "aa", 41)
			if err != nil {
				t.Fatalf("read the block: %v", err)
			}
			if block.GetMerkleRoot() != "mm" {
				t.Errorf("merkle root = %q, want mm", block.GetMerkleRoot())
			}
			if block.GetPrevHash() != "pp" {
				t.Errorf("previous hash = %q, want pp", block.GetPrevHash())
			}
			if block.GetMainchainHash() != "xx" {
				t.Errorf("mainchain hash = %q, want xx", block.GetMainchainHash())
			}
			if block.GetTxCount() != 2 {
				t.Errorf("transactions = %d, want 2", block.GetTxCount())
			}
			if block.GetHeight() != 41 {
				t.Errorf("height = %d, want 41", block.GetHeight())
			}
		})
	}
}

// Thunder and photon wrap the transaction with the block that carries it.
// Every other chain returns the transaction alone.
func TestNodeTransactionReadsBothLayouts(t *testing.T) {
	const inner = `{"inputs":[{"Regular":{"txid":"prev","vout":0}}],
	                "outputs":[{"address":"s1","content":{"Value":40000}}]}`
	wrapped := `{"block_hash":"bb","tx":` + inner + `}`

	for name, body := range map[string]string{"wrapped": wrapped, "bare": inner} {
		t.Run(name, func(t *testing.T) {
			node := &recordingNode{answers: map[string]string{"get_transaction": body}}
			src := source{name: "chain", node: node}

			out, err := nodeTransaction(context.Background(), src, "abc")
			if err != nil {
				t.Fatalf("read the transaction: %v", err)
			}
			if len(out.GetInputs()) != 1 || len(out.GetOutputs()) != 1 {
				t.Fatalf("the transaction reads %d in and %d out, want 1 and 1",
					len(out.GetInputs()), len(out.GetOutputs()))
			}
			if out.GetOutputs()[0].GetValueSats() != 40000 {
				t.Errorf("the output is worth %d, want 40000", out.GetOutputs()[0].GetValueSats())
			}
			if name == "wrapped" && (!out.GetConfirmed() || out.GetBlockHash() != "bb") {
				t.Errorf("the wrapper names block bb, and the transaction reads %v %q",
					out.GetConfirmed(), out.GetBlockHash())
			}
		})
	}
}

// A Core derived chain reads a transaction with Core's own RPC.
func TestCoreTransactionReadsCoreShapes(t *testing.T) {
	node := &recordingNode{answers: map[string]string{
		"getrawtransaction": `{"txid":"t1","blockhash":"bb","time":1700000000,
		                       "confirmations":6,"size":225,
		                       "vin":[{"txid":"prev","vout":1}],
		                       "vout":[{"value":0.0004,"scriptPubKey":{"address":"bc1qx"}}]}`,
	}}
	src := source{name: "bbc", node: node, core: true}

	out, err := coreTransaction(context.Background(), src, "t1")
	if err != nil {
		t.Fatalf("read the transaction: %v", err)
	}
	if !out.GetConfirmed() || out.GetBlockHash() != "bb" {
		t.Errorf("the transaction reads %v %q, want a confirmed one in bb",
			out.GetConfirmed(), out.GetBlockHash())
	}
	if got := out.GetOutputs()[0].GetValueSats(); got != 40000 {
		t.Errorf("the output is worth %d sats, want 40000", got)
	}
	for _, method := range node.called {
		if method == "get_transaction" {
			t.Error("a Core node was asked get_transaction, which it does not serve")
		}
	}
}

// A chain that sends a bare transaction carries its confirmation and its fee
// in get_transaction_info.
func TestNodeTransactionReadsTheInfoForABareTransaction(t *testing.T) {
	node := &recordingNode{answers: map[string]string{
		"get_transaction":      `{"inputs":[],"outputs":[{"address":"s1","content":{"Value":10}}]}`,
		"get_transaction_info": `{"confirmations":4,"fee_sats":1200}`,
	}}
	src := source{name: "bitassets", node: node}

	out, err := nodeTransaction(context.Background(), src, "abc")
	if err != nil {
		t.Fatalf("read the transaction: %v", err)
	}
	if !out.GetConfirmed() {
		t.Error("a mined transaction reads as unconfirmed")
	}
	if out.GetFeeSats() != 1200 {
		t.Errorf("fee = %d, want 1200", out.GetFeeSats())
	}
}

// A deposit has no sidechain transaction, so the address view builds one row
// out of the coin the mainchain sent.
func TestDepositReadsAsAnAddressRow(t *testing.T) {
	out := depositTransaction("s1", sidechainesplora.UTXO{
		Txid: "mainchaintxid", Vout: 1, Value: 123456,
		OutpointKind: sidechainesplora.KindDeposit, ContentType: "value",
		Status: sidechainesplora.Status{Confirmed: true, BlockHeight: 34},
	})
	if out.GetKind() != pb.Kind_KIND_DEPOSIT {
		t.Errorf("kind = %s, want a deposit", out.GetKind())
	}
	if len(out.GetInputs()) != 0 {
		t.Errorf("a deposit spends %d coins on this chain, want none", len(out.GetInputs()))
	}
	if got := out.GetOutputs()[0].GetValueSats(); got != 123456 {
		t.Errorf("the deposit is worth %d, want 123456", got)
	}
	if out.GetBlockHeight() != 34 {
		t.Errorf("block height = %d, want 34", out.GetBlockHeight())
	}
}

// A transaction that waits for a block reads back with no block, so the page
// can mark it unconfirmed rather than losing it.
func TestUnconfirmedTransactionKeepsItsCoins(t *testing.T) {
	tx := sidechainesplora.Tx{
		Txid: "pending",
		Fee:  1000,
		Size: 16,
		Vin: []sidechainesplora.Vin{{
			Txid: "prev", Vout: 0,
			Prevout: &sidechainesplora.Vout{
				ScriptPubKeyAddress: "s1", Value: 500000, ContentType: "value",
			},
		}},
		Vout: []sidechainesplora.Vout{{
			ScriptPubKeyAddress: "s2", Value: 499000, ContentType: "value",
		}},
		Status: sidechainesplora.Status{Confirmed: false},
	}

	out := newTransaction(tx)
	if out.GetConfirmed() {
		t.Error("a transaction in the mempool reads as confirmed")
	}
	if out.GetBlockHeight() != 0 || out.GetBlockHash() != "" {
		t.Errorf("an unconfirmed transaction names block %d %q, want none",
			out.GetBlockHeight(), out.GetBlockHash())
	}
	if len(out.GetInputs()) != 1 || len(out.GetOutputs()) != 1 {
		t.Fatalf("the transaction reads %d in and %d out, want 1 and 1",
			len(out.GetInputs()), len(out.GetOutputs()))
	}
	if out.GetFeeSats() != 1000 || out.GetSizeBytes() != 16 {
		t.Errorf("fee = %d and size = %d, want 1000 and 16",
			out.GetFeeSats(), out.GetSizeBytes())
	}
}

// The overview puts the unconfirmed rows first, and each one reads without a
// block.
func TestActivityKeepsTheUnconfirmedRowsFirst(t *testing.T) {
	rows := activityList([]sidechainesplora.Activity{
		{Kind: sidechainesplora.KindTransfer, ID: "pending", Value: 1, Fee: 1000},
		{Kind: sidechainesplora.KindTransfer, ID: "mined", Value: 2, Fee: 900,
			Status: sidechainesplora.Status{Confirmed: true, BlockHeight: 48}},
	})
	if len(rows) != 2 {
		t.Fatalf("the feed holds %d rows, want 2", len(rows))
	}
	if rows[0].GetConfirmed() || rows[0].GetBlockHeight() != 0 {
		t.Errorf("the first row reads %+v, want an unconfirmed one", rows[0])
	}
	if !rows[1].GetConfirmed() || rows[1].GetBlockHeight() != 48 {
		t.Errorf("the second row reads %+v, want block 48", rows[1])
	}
}

// A node holds no previous outputs, so it never knows what a block collected
// in fees.
func TestNodeBlockNeverClaimsToKnowItsFees(t *testing.T) {
	body := `{"header":{"merkle_root":"mm","prev_main_hash":"xx"},"body":{"transactions":[]}}`
	node := &recordingNode{byHash: map[string]string{"aa": body}}
	src := source{name: "thunder", node: node}

	block, _, err := nodeBlock(context.Background(), src, "aa", 48)
	if err != nil {
		t.Fatalf("read the block: %v", err)
	}
	if block.GetFeesKnown() {
		t.Error("a node block claims to know its fees")
	}
}

// A transaction pays out its plain outputs, and a withdrawal costs both its
// payout and its mainchain fee.
func TestBodyTransactionSumsWhatItPaidOut(t *testing.T) {
	var tx nodeBodyTx
	raw := `{"outputs":[
		{"address":"s1","content":{"Value":50000000}},
		{"address":"s2","content":{"Value":9000}},
		{"address":"s3","content":{"Withdrawal":{"value":50000,"main_fee":1200,"main_address":"bc1q"}}}
	]}`
	if err := json.Unmarshal([]byte(raw), &tx); err != nil {
		t.Fatalf("read the transaction: %v", err)
	}
	const want = 50000000 + 9000 + 50000 + 1200
	if got := tx.paidOut(); got != want {
		t.Errorf("the transaction paid out %d, want %d", got, want)
	}
}

// An indexed block knows its fees, so the page shows them rather than a blank.
func TestIndexedBlockKnowsItsFees(t *testing.T) {
	out := newBlock(sidechainesplora.Block{
		ID: "bb", Height: 48, MerkleRoot: "mm", Fees: 2000, TxCount: 2, Size: 32,
	})
	if !out.GetFeesKnown() {
		t.Error("an indexed block reads as not knowing its fees")
	}
	if out.GetFeesSats() != 2000 {
		t.Errorf("fees = %d, want 2000", out.GetFeesSats())
	}
}
