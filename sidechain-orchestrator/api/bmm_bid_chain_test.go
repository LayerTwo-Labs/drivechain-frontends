package api

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"strings"
	"testing"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
)

// fakeNode answers the two Core reads the bid walk makes.
type fakeNode struct {
	// txs names each transaction the node holds, by txid.
	txs map[string]fakeTx
}

type fakeTx struct {
	// vin names what the transaction spends, as "txid:vout".
	vin []string
	// slot marks a bid for that sidechain. A zero slot names no bid.
	slot int
	// confirmations above zero says a block carries it.
	confirmations int
}

func (n *fakeNode) call(_ context.Context, method, paramsJSON, _ string) (json.RawMessage, error) {
	if method != "getrawtransaction" {
		return nil, fmt.Errorf("the walk called %s", method)
	}
	var params []any
	if err := json.Unmarshal([]byte(paramsJSON), &params); err != nil {
		return nil, err
	}
	txid, _ := params[0].(string)
	tx, ok := n.txs[txid]
	if !ok {
		return nil, fmt.Errorf("no transaction %s", txid)
	}

	out := map[string]any{"confirmations": tx.confirmations}
	vin := make([]map[string]any, 0, len(tx.vin))
	for _, in := range tx.vin {
		parts := strings.Split(in, ":")
		var vout int
		_, _ = fmt.Sscanf(parts[1], "%d", &vout)
		vin = append(vin, map[string]any{"txid": parts[0], "vout": vout})
	}
	out["vin"] = vin

	if tx.slot > 0 {
		script, err := orchestrator.M8BmmRequestScript(
			uint8(tx.slot), strings.Repeat("ab", 32), strings.Repeat("cd", 32))
		if err != nil {
			return nil, err
		}
		out["vout"] = []map[string]any{{
			"scriptPubKey": map[string]any{"hex": hex.EncodeToString(script)},
		}}
	}
	return json.Marshal(out)
}

func handlerOver(node *fakeNode) *BMMHandler {
	h := &BMMHandler{}
	h.SetCoreCaller(node.call)
	return h
}

// A new bid takes the change of the bid before it. A replacement must respend
// the coins under the whole chain, or the stranded bids below it hold every
// later bid out of a block.
func TestBidInputsWalksToTheConfirmedCoins(t *testing.T) {
	node := &fakeNode{txs: map[string]fakeTx{
		"coin":   {confirmations: 6},
		"root":   {vin: []string{"coin:1"}, slot: 9},
		"middle": {vin: []string{"root:1"}, slot: 9},
		"top":    {vin: []string{"middle:1"}, slot: 9},
	}}

	got, roots, err := handlerOver(node).bidInputs(context.Background(), "top")
	if err != nil {
		t.Fatalf("bid inputs: %v", err)
	}
	if len(got) != 1 {
		t.Fatalf("got %d inputs, want the one confirmed coin", len(got))
	}
	if got[0].Txid != "coin" || got[0].Vout != 1 {
		t.Errorf("input = %s:%d, want coin:1", got[0].Txid, got[0].Vout)
	}
	// The mempool counts the fee of the whole chain under the root, and the
	// replacement must beat all of it.
	if len(roots) != 1 || roots[0] != "root" {
		t.Errorf("roots = %v, want the bottom bid", roots)
	}
}

// A bid that stands on its own respends its own inputs.
func TestBidInputsKeepsAConfirmedInput(t *testing.T) {
	node := &fakeNode{txs: map[string]fakeTx{
		"coin": {confirmations: 3},
		"bid":  {vin: []string{"coin:0"}, slot: 9},
	}}

	got, roots, err := handlerOver(node).bidInputs(context.Background(), "bid")
	if err != nil {
		t.Fatalf("bid inputs: %v", err)
	}
	if len(got) != 1 || got[0].Txid != "coin" || got[0].Vout != 0 {
		t.Errorf("inputs = %+v, want coin:0", got)
	}
	if len(roots) != 1 || roots[0] != "bid" {
		t.Errorf("roots = %v, want the bid itself", roots)
	}
}

// One wallet funds the bids of every slot, so a bid for another slot can sit
// between two of ours. The walk goes through it, or the stranded bid under it
// holds our chain out of every block.
func TestBidInputsWalksThroughAnotherSlot(t *testing.T) {
	node := &fakeNode{txs: map[string]fakeTx{
		"coin":    {confirmations: 4},
		"foreign": {vin: []string{"coin:0"}, slot: 4},
		"bid":     {vin: []string{"foreign:1"}, slot: 9},
	}}

	got, _, err := handlerOver(node).bidInputs(context.Background(), "bid")
	if err != nil {
		t.Fatalf("bid inputs: %v", err)
	}
	if len(got) != 1 || got[0].Txid != "coin" || got[0].Vout != 0 {
		t.Errorf("inputs = %+v, want coin:0", got)
	}
}

// An ordinary payment is not a bid. The walk stops there, because a
// replacement must never undo what a user sent.
func TestBidInputsStopsAtAPayment(t *testing.T) {
	node := &fakeNode{txs: map[string]fakeTx{
		"coin":    {confirmations: 4},
		"payment": {vin: []string{"coin:0"}},
		"bid":     {vin: []string{"payment:1"}, slot: 9},
	}}

	got, _, err := handlerOver(node).bidInputs(context.Background(), "bid")
	if err != nil {
		t.Fatalf("bid inputs: %v", err)
	}
	if len(got) != 1 || got[0].Txid != "payment" || got[0].Vout != 1 {
		t.Errorf("inputs = %+v, want payment:1", got)
	}
}

// A transaction the node cannot read stops the walk, so the replacement keeps
// the outpoint it already holds.
func TestBidInputsKeepsAnUnknownParent(t *testing.T) {
	node := &fakeNode{txs: map[string]fakeTx{
		"bid": {vin: []string{"gone:2"}, slot: 9},
	}}

	got, _, err := handlerOver(node).bidInputs(context.Background(), "bid")
	if err != nil {
		t.Fatalf("bid inputs: %v", err)
	}
	if len(got) != 1 || got[0].Txid != "gone" {
		t.Errorf("inputs = %+v, want gone:2", got)
	}
}

// Two inputs of one chain can name the same coin. It reaches the replacement
// one time.
func TestBidInputsNamesEachCoinOneTime(t *testing.T) {
	node := &fakeNode{txs: map[string]fakeTx{
		"coin": {confirmations: 2},
		"root": {vin: []string{"coin:0", "coin:0"}, slot: 9},
		"top":  {vin: []string{"root:0", "root:1"}, slot: 9},
	}}

	got, _, err := handlerOver(node).bidInputs(context.Background(), "top")
	if err != nil {
		t.Fatalf("bid inputs: %v", err)
	}
	if len(got) != 1 {
		t.Errorf("inputs = %+v, want the coin one time", got)
	}
}

// A chain that names itself would walk forever.
func TestBidInputsRefusesALoop(t *testing.T) {
	node := &fakeNode{txs: map[string]fakeTx{
		"a": {vin: []string{"b:0"}, slot: 9},
		"b": {vin: []string{"a:0"}, slot: 9},
	}}

	if _, _, err := handlerOver(node).bidInputs(context.Background(), "a"); err == nil {
		t.Fatal("want an error for a loop, got none")
	}
}

// nodeWithFees answers the mempool reads the floor makes: what each
// transaction pays after the node's own deltas, and what sits over it.
type nodeWithFees struct {
	*fakeNode
	// modified names the fee of one transaction in BTC, after the deltas.
	modified map[string]float64
	// descendants names what the mempool holds over one transaction.
	descendants map[string][]string
}

func (n *nodeWithFees) call(ctx context.Context, method, paramsJSON, wallet string) (json.RawMessage, error) {
	var params []any
	if err := json.Unmarshal([]byte(paramsJSON), &params); err != nil {
		return nil, err
	}
	txid, _ := params[0].(string)

	switch method {
	case "getmempoolentry":
		fee, ok := n.modified[txid]
		if !ok {
			return nil, fmt.Errorf("no mempool entry %s", txid)
		}
		return json.Marshal(map[string]any{"fees": map[string]any{"modified": fee}})
	case "getmempooldescendants":
		return json.Marshal(n.descendants[txid])
	default:
		return n.fakeNode.call(ctx, method, paramsJSON, wallet)
	}
}

func floorOver(t *testing.T, node *nodeWithFees, roots []string) int64 {
	t.Helper()
	h := &BMMHandler{}
	h.SetCoreCaller(node.call)
	floor, err := h.replacementFloorSats(context.Background(), roots)
	if err != nil {
		t.Fatalf("floor: %v", err)
	}
	return floor
}

// A replacement evicts every bid over the coins it takes, so it must pay more
// than all of them together.
func TestReplacementFloorCoversTheWholeChain(t *testing.T) {
	node := &nodeWithFees{
		fakeNode: &fakeNode{txs: map[string]fakeTx{}},
		// 74799 + 76562 + 1000 sats, the way the live chain read.
		modified:    map[string]float64{"root": 0.00074799, "middle": 0.00076562, "top": 0.00001},
		descendants: map[string][]string{"root": {"middle", "top"}},
	}

	if want := int64(152361) + replacementBumpSats; floorOver(t, node, []string{"root"}) != want {
		t.Errorf("floor = %d, want %d", floorOver(t, node, []string{"root"}), want)
	}
}

// One chain can name two roots, and a bid over both belongs to each root's
// descendants. Counting it twice asks for a fee no ceiling allows.
func TestReplacementFloorCountsEachTransactionOneTime(t *testing.T) {
	node := &nodeWithFees{
		fakeNode:    &fakeNode{txs: map[string]fakeTx{}},
		modified:    map[string]float64{"root": 0.00001, "top": 0.00002},
		descendants: map[string][]string{"root": {"top"}},
	}

	if want := int64(3000) + replacementBumpSats; floorOver(t, node, []string{"root", "top"}) != want {
		t.Errorf("floor = %d, want %d", floorOver(t, node, []string{"root", "top"}), want)
	}
}

// A node that deprioritised the chain reports a fee under zero. The
// replacement then beats it at any price, so it names no floor.
func TestReplacementFloorOfADeprioritisedChain(t *testing.T) {
	node := &nodeWithFees{
		fakeNode:    &fakeNode{txs: map[string]fakeTx{}},
		modified:    map[string]float64{"root": -210000.0},
		descendants: map[string][]string{},
	}

	if floorOver(t, node, []string{"root"}) != 0 {
		t.Errorf("floor = %d, want 0", floorOver(t, node, []string{"root"}))
	}
}

// A bid the mempool no longer holds names no floor, so the opening bid stands.
func TestReplacementFloorOfAGoneBid(t *testing.T) {
	node := &nodeWithFees{
		fakeNode:    &fakeNode{txs: map[string]fakeTx{}},
		modified:    map[string]float64{},
		descendants: map[string][]string{},
	}

	if floorOver(t, node, []string{"gone"}) != 0 {
		t.Errorf("floor = %d, want 0", floorOver(t, node, []string{"gone"}))
	}
}
