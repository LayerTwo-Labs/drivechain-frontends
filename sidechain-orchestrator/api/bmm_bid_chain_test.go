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

	got, roots, err := handlerOver(node).bidInputs(context.Background(), 9, "top")
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

	got, roots, err := handlerOver(node).bidInputs(context.Background(), 9, "bid")
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

// An unconfirmed parent that is not a bid of this slot belongs to somebody
// else. The walk stops there, because the wallet cannot respend it.
func TestBidInputsStopsAtAnotherSlot(t *testing.T) {
	node := &fakeNode{txs: map[string]fakeTx{
		"coin":    {confirmations: 4},
		"foreign": {vin: []string{"coin:0"}, slot: 4},
		"bid":     {vin: []string{"foreign:1"}, slot: 9},
	}}

	got, _, err := handlerOver(node).bidInputs(context.Background(), 9, "bid")
	if err != nil {
		t.Fatalf("bid inputs: %v", err)
	}
	if len(got) != 1 || got[0].Txid != "foreign" || got[0].Vout != 1 {
		t.Errorf("inputs = %+v, want foreign:1", got)
	}
}

// A transaction the node cannot read stops the walk, so the replacement keeps
// the outpoint it already holds.
func TestBidInputsKeepsAnUnknownParent(t *testing.T) {
	node := &fakeNode{txs: map[string]fakeTx{
		"bid": {vin: []string{"gone:2"}, slot: 9},
	}}

	got, _, err := handlerOver(node).bidInputs(context.Background(), 9, "bid")
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

	got, _, err := handlerOver(node).bidInputs(context.Background(), 9, "top")
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

	if _, _, err := handlerOver(node).bidInputs(context.Background(), 9, "a"); err == nil {
		t.Fatal("want an error for a loop, got none")
	}
}

// nodeWithFees answers getmempoolentry as well, so the floor test reads what
// the chain costs.
type nodeWithFees struct {
	*fakeNode
	// descendant names the fee of a transaction and everything over it, in BTC.
	descendant map[string]float64
}

func (n *nodeWithFees) call(ctx context.Context, method, paramsJSON, wallet string) (json.RawMessage, error) {
	if method != "getmempoolentry" {
		return n.fakeNode.call(ctx, method, paramsJSON, wallet)
	}
	var params []any
	if err := json.Unmarshal([]byte(paramsJSON), &params); err != nil {
		return nil, err
	}
	txid, _ := params[0].(string)
	fee, ok := n.descendant[txid]
	if !ok {
		return nil, fmt.Errorf("no mempool entry %s", txid)
	}
	return json.Marshal(map[string]any{"fees": map[string]any{"descendant": fee}})
}

// A replacement evicts every bid over the coins it takes, so it must pay more
// than all of them together.
func TestReplacementFloorCoversTheWholeChain(t *testing.T) {
	node := &nodeWithFees{
		fakeNode: &fakeNode{txs: map[string]fakeTx{
			"coin":   {confirmations: 6},
			"root":   {vin: []string{"coin:1"}, slot: 9},
			"middle": {vin: []string{"root:1"}, slot: 9},
			"top":    {vin: []string{"middle:1"}, slot: 9},
		}},
		// 74799 + 76562 + 1000 sats, the way the live chain read.
		descendant: map[string]float64{"root": 0.00152361, "top": 0.00001},
	}
	h := &BMMHandler{}
	h.SetCoreCaller(node.call)

	_, roots, err := h.bidInputs(context.Background(), 9, "top")
	if err != nil {
		t.Fatalf("bid inputs: %v", err)
	}
	floor, err := h.replacementFloorSats(context.Background(), roots)
	if err != nil {
		t.Fatalf("floor: %v", err)
	}
	if want := int64(152361) + replacementBumpSats; floor != want {
		t.Errorf("floor = %d, want %d", floor, want)
	}
}

// A bid the mempool no longer holds names no floor, so the opening bid stands.
func TestReplacementFloorOfAGoneBid(t *testing.T) {
	node := &nodeWithFees{fakeNode: &fakeNode{txs: map[string]fakeTx{}}, descendant: map[string]float64{}}
	h := &BMMHandler{}
	h.SetCoreCaller(node.call)

	floor, err := h.replacementFloorSats(context.Background(), []string{"gone"})
	if err != nil {
		t.Fatalf("floor: %v", err)
	}
	if floor != 0 {
		t.Errorf("floor = %d, want 0", floor)
	}
}

// A node that deprioritised the chain reports a fee under zero. The
// replacement then beats it at any price, so it names no floor.
func TestReplacementFloorOfADeprioritisedChain(t *testing.T) {
	node := &nodeWithFees{
		fakeNode:   &fakeNode{txs: map[string]fakeTx{}},
		descendant: map[string]float64{"root": -440999.99},
	}
	h := &BMMHandler{}
	h.SetCoreCaller(node.call)

	floor, err := h.replacementFloorSats(context.Background(), []string{"root"})
	if err != nil {
		t.Fatalf("floor: %v", err)
	}
	if floor != 0 {
		t.Errorf("floor = %d, want 0", floor)
	}
}
