package api

import (
	"context"
	"encoding/json"
	"fmt"
	"strings"
	"testing"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/explorer/v1"
)

// This is the M8 a live mainchain block carried for thunder, slot 9. The
// script holds the tag, the slot, the sidechain block hash, then the parent
// mainchain hash in reverse byte order.
const liveBidScript = "6a4400bf00094d6adc93a9b0f528d6625b9990c765255947b0c06eb1cbda33cc0adc0eb69322" +
	"065e35407b1ff889317a733d36f7b71104618f0ffa6552c70000000000000000"

const liveSidechainHash = "4d6adc93a9b0f528d6625b9990c765255947b0c06eb1cbda33cc0adc0eb69322"

const liveParentHash = "0000000000000000c75265fa0f8f610411b7f7363d737a3189f81f7b40355e06"

// The winning bid is the M8 that commits to this sidechain block. Core states
// the fee, so the bid reads back with no input walk.
func TestFindBidPicksTheM8ForOneBlock(t *testing.T) {
	mined := mainchainBlock{
		Hash:   "00000000000000009563c32a953b8a55ed4e6bc23ab4f0078d04651142442497",
		Height: 996817,
	}
	if err := json.Unmarshal(json.RawMessage(fmt.Sprintf(`[
		{"txid":"a2b2e63d","fee":0,"vout":[{"n":0,"scriptPubKey":{"hex":"6a25d6e1c5df"}}]},
		{"txid":"61d66813","fee":0.00003,"vout":[{"n":0,"scriptPubKey":{"hex":%q}}]},
		{"txid":"c8e5d438","fee":0.000013,"vout":[{"n":0,"scriptPubKey":{"hex":"6a33300deb25"}}]}
	]`, liveBidScript)), &mined.Tx); err != nil {
		t.Fatalf("read the block: %v", err)
	}

	bid := findBid(mined, 9, liveSidechainHash, liveParentHash)
	if bid == nil {
		t.Fatal("no bid matched, and one M8 commits to this block")
	}
	if bid.GetTxid() != "61d66813" {
		t.Errorf("the bid is %s, want 61d66813", bid.GetTxid())
	}
	if bid.GetVout() != 0 {
		t.Errorf("the M8 sits at output %d, want 0", bid.GetVout())
	}
	if bid.GetSats() != 3000 {
		t.Errorf("the bid paid %d sats, want 3000", bid.GetSats())
	}
	if bid.GetBlockHeight() != 996817 {
		t.Errorf("the carrier block is %d, want 996817", bid.GetBlockHeight())
	}
}

// An M8 for another slot, or for another block, is not this block's bid.
func TestFindBidIgnoresAnotherSlotAndAnotherBlock(t *testing.T) {
	mined := mainchainBlock{Hash: "mm", Height: 1}
	if err := json.Unmarshal(json.RawMessage(fmt.Sprintf(
		`[{"txid":"61d66813","fee":0.00003,"vout":[{"n":0,"scriptPubKey":{"hex":%q}}]}]`,
		liveBidScript,
	)), &mined.Tx); err != nil {
		t.Fatalf("read the block: %v", err)
	}

	if bid := findBid(mined, 8, liveSidechainHash, liveParentHash); bid != nil {
		t.Errorf("slot 8 matched a slot 9 bid: %s", bid.GetTxid())
	}
	if bid := findBid(mined, 9, "ff", liveParentHash); bid != nil {
		t.Errorf("another block matched: %s", bid.GetTxid())
	}
}

// A miner takes a bid in the block after the one the header names, so the
// lookup reads that child block.
func TestResolveBidReadsTheBlockAfterTheHeader(t *testing.T) {
	const parent = liveParentHash
	const carrier = "00000000000000009563c32a953b8a55ed4e6bc23ab4f0078d04651142442497"

	var asked []string
	handler := &ExplorerHandler{}
	handler.SetCoreCaller(func(_ context.Context, method, params, _ string) (json.RawMessage, error) {
		asked = append(asked, method+" "+params)
		switch method {
		case "getblockheader":
			return json.RawMessage(fmt.Sprintf(`{"nextblockhash":%q}`, carrier)), nil
		case "getblock":
			return json.RawMessage(fmt.Sprintf(
				`{"hash":%q,"height":996817,"tx":[
					{"txid":"61d66813","fee":0.00003,"vout":[{"n":0,"scriptPubKey":{"hex":%q}}]}
				]}`, carrier, liveBidScript)), nil
		}
		return nil, fmt.Errorf("no answer for %s", method)
	})

	block := &pb.Block{Hash: liveSidechainHash, MainchainHash: parent}
	handler.resolveBid(context.Background(), 9, block)

	if block.GetBid() == nil {
		t.Fatal("the block names no bid")
	}
	if got := block.GetBid().GetSats(); got != 3000 {
		t.Errorf("the bid paid %d sats, want 3000", got)
	}
	if len(asked) != 2 || asked[0] != fmt.Sprintf("getblockheader [%q]", parent) {
		t.Errorf("the lookup asked %v", asked)
	}
}

// A block with no mainchain hash, and a chain with no bitcoind, both answer
// without a bid rather than an error.
func TestResolveBidStaysQuietWithoutASource(t *testing.T) {
	handler := &ExplorerHandler{}
	block := &pb.Block{Hash: liveSidechainHash}
	handler.resolveBid(context.Background(), 9, block)
	if block.GetBid() != nil {
		t.Error("a header with no mainchain hash named a bid")
	}

	block = &pb.Block{Hash: liveSidechainHash, MainchainHash: "aa"}
	handler.resolveBid(context.Background(), 9, block)
	if block.GetBid() != nil {
		t.Error("an install with no bitcoind named a bid")
	}
}

// A valid M8 sits at output zero. A copy of the payload anywhere else is not
// a bid, and it must not carry that transaction's fee onto the page.
func TestFindBidIgnoresAnM8AwayFromOutputZero(t *testing.T) {
	mined := mainchainBlock{Hash: "mm", Height: 1}
	if err := json.Unmarshal(json.RawMessage(fmt.Sprintf(`[
		{"txid":"c0p1ed","fee":0.01,"vout":[
			{"n":0,"scriptPubKey":{"hex":"6a0500"}},
			{"n":1,"scriptPubKey":{"hex":%q}}
		]},
		{"txid":"61d66813","fee":0.00003,"vout":[{"n":0,"scriptPubKey":{"hex":%q}}]}
	]`, liveBidScript, liveBidScript)), &mined.Tx); err != nil {
		t.Fatalf("read the block: %v", err)
	}

	bid := findBid(mined, 9, liveSidechainHash, liveParentHash)
	if bid == nil {
		t.Fatal("no bid matched, and one M8 sits at output zero")
	}
	if bid.GetTxid() != "61d66813" {
		t.Errorf("the bid is %s, want 61d66813", bid.GetTxid())
	}
	if bid.GetSats() != 3000 {
		t.Errorf("the bid paid %d sats, want 3000", bid.GetSats())
	}
}

// An M8 that names another parent could never mine this block, whatever else
// it commits to.
func TestFindBidIgnoresAnotherParent(t *testing.T) {
	mined := mainchainBlock{Hash: "mm", Height: 1}
	if err := json.Unmarshal(json.RawMessage(fmt.Sprintf(
		`[{"txid":"61d66813","fee":0.00003,"vout":[{"n":0,"scriptPubKey":{"hex":%q}}]}]`,
		liveBidScript,
	)), &mined.Tx); err != nil {
		t.Fatalf("read the block: %v", err)
	}

	other := "00000000000000000000000000000000000000000000000000000000000000ff"
	if bid := findBid(mined, 9, liveSidechainHash, other); bid != nil {
		t.Errorf("a bid built on another parent matched: %s", bid.GetTxid())
	}
}

// The fee is the bid, so a valid M8 output pays nothing. A burn that carries
// the same bytes is not a bid.
func TestFindBidIgnoresAValueBearingM8(t *testing.T) {
	mined := mainchainBlock{Hash: "mm", Height: 1}
	if err := json.Unmarshal(json.RawMessage(fmt.Sprintf(`[
		{"txid":"burn","fee":0.5,"vout":[{"n":0,"value":0.25,"scriptPubKey":{"hex":%q}}]},
		{"txid":"61d66813","fee":0.00003,"vout":[{"n":0,"value":0,"scriptPubKey":{"hex":%q}}]}
	]`, liveBidScript, liveBidScript)), &mined.Tx); err != nil {
		t.Fatalf("read the block: %v", err)
	}

	bid := findBid(mined, 9, liveSidechainHash, liveParentHash)
	if bid == nil {
		t.Fatal("no bid matched, and one M8 pays nothing")
	}
	if bid.GetTxid() != "61d66813" {
		t.Errorf("the bid is %s, want 61d66813", bid.GetTxid())
	}
}

// A sidechain block connects when a miner takes its M8, which is the block
// after the one the header names. Those two can be hours apart, so the age
// reads from the carrier.
func TestResolveMainchainReadsTheCarrierTime(t *testing.T) {
	const parent = "0000000000000000c75265fa0f8f610411b7f7363d737a3189f81f7b40355e06"
	const carrier = "00000000000000009563c32a953b8a55ed4e6bc23ab4f0078d04651142442497"

	var asked int
	handler := &ExplorerHandler{mainchain: newMainchainCache()}
	handler.SetCoreCaller(func(_ context.Context, method, params, _ string) (json.RawMessage, error) {
		if method != "getblockheader" {
			return nil, fmt.Errorf("no answer for %s", method)
		}
		asked++
		if strings.Contains(params, parent) {
			return json.RawMessage(fmt.Sprintf(
				`{"height":996816,"time":1000,"nextblockhash":%q}`, carrier)), nil
		}
		return json.RawMessage(`{"height":996817,"time":9581}`), nil
	})

	block := &pb.Block{Hash: liveSidechainHash, MainchainHash: parent}
	handler.resolveMainchain(context.Background(), block)

	if got := block.GetMainchainHeight(); got != 996816 {
		t.Errorf("the header names block %d, want 996816", got)
	}
	if got := block.GetBlockTime(); got != 9581 {
		t.Errorf("the block connected at %d, want the carrier time 9581", got)
	}

	// A second block on the same parent answers from the cache.
	asked = 0
	again := &pb.Block{Hash: "bb", MainchainHash: parent}
	handler.resolveMainchain(context.Background(), again)
	if asked != 0 {
		t.Errorf("the second read asked bitcoind %d times, want 0", asked)
	}
	if again.GetBlockTime() != 9581 {
		t.Errorf("the cached time reads %d, want 9581", again.GetBlockTime())
	}
}

// A parent with no block after it carries no M8 yet, so the page reads it
// again rather than holding a time of zero.
func TestResolveMainchainRetriesAParentWithNoCarrier(t *testing.T) {
	const parent = "0000000000000000c75265fa0f8f610411b7f7363d737a3189f81f7b40355e06"

	var asked int
	handler := &ExplorerHandler{mainchain: newMainchainCache()}
	handler.SetCoreCaller(func(_ context.Context, method, params, _ string) (json.RawMessage, error) {
		asked++
		return json.RawMessage(`{"height":996816,"time":1000}`), nil
	})

	block := &pb.Block{Hash: liveSidechainHash, MainchainHash: parent}
	handler.resolveMainchain(context.Background(), block)
	if block.GetMainchainHeight() != 996816 {
		t.Errorf("the header names block %d, want 996816", block.GetMainchainHeight())
	}
	if block.GetBlockTime() != 0 {
		t.Errorf("a block with no carrier states a time of %d", block.GetBlockTime())
	}

	asked = 0
	handler.resolveMainchain(context.Background(), &pb.Block{Hash: "bb", MainchainHash: parent})
	if asked == 0 {
		t.Error("the page cached a parent that carries no M8 yet")
	}
}
