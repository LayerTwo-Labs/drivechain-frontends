package api

import (
	"context"
	"encoding/json"
	"fmt"
	"testing"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/explorer/v1"
)

// Two thunder builds both report 0.17.6 and write a deposit differently. These
// are the two get_block_index replies, one from a node on a laptop and one from
// the alphanet server, for the same block.
func TestBlockIndexReadsBothDepositShapes(t *testing.T) {
	const (
		named  = `{"txs":[],"deposits":[{"outpoint":{"Deposit":"cef2cf2f248f78ae41109532e9a85d775fd724506834b076e745e941e31888bc:0"},"output":{"address":"rQyAxKGtdbyiEM852yMtoRWfgVD","content":{"Value":54300}}}],"bundle_spends":[]}`
		paired = `{"txs":[],"deposits":[[{"Deposit":"cef2cf2f248f78ae41109532e9a85d775fd724506834b076e745e941e31888bc:0"},{"address":"rQyAxKGtdbyiEM852yMtoRWfgVD","content":{"Value":54300}}]],"bundle_spends":[]}`
	)
	for name, raw := range map[string]string{"named fields": named, "a pair": paired} {
		t.Run(name, func(t *testing.T) {
			var index nodeBlockIndex
			if err := json.Unmarshal(json.RawMessage(raw), &index); err != nil {
				t.Fatalf("read the block index: %v", err)
			}
			if got := len(index.Deposits); got != 1 {
				t.Fatalf("the block holds %d deposits, want 1", got)
			}
			only := index.Deposits[0]
			if only.Address != "rQyAxKGtdbyiEM852yMtoRWfgVD" {
				t.Errorf("the deposit paid %s", only.Address)
			}
			if only.ValueSats != 54300 {
				t.Errorf("the deposit is worth %d sats, want 54300", only.ValueSats)
			}
			want := "cef2cf2f248f78ae41109532e9a85d775fd724506834b076e745e941e31888bc"
			if got := depositTxid(only.Outpoint); got != want {
				t.Errorf("the outpoint names %s, want %s", got, want)
			}
		})
	}
}

// The reader refuses a deposit it cannot name, rather than reading it as an
// empty one. A block whose deposits all read empty looks like a block with no
// deposits, which is how a shape change hides.
func TestDepositWithNoOutpointIsRefused(t *testing.T) {
	var d nodeDeposit
	err := d.UnmarshalJSON([]byte(`{"output":{"address":"sc1","content":{"Value":1}}}`))
	if err == nil {
		t.Fatal("the read passed, and a deposit with no outpoint must fail")
	}
}

// A block that holds a deposit reports it, both as a row and as a count. A
// deposit never sits in the block body, so the body count alone reads zero.
func TestNodeBlockReportsWhatWasDeposited(t *testing.T) {
	node := &recordingNode{
		count: 1,
		answers: map[string]string{
			"get_best_sidechain_block_hash": `"aa"`,
		},
		byHash: map[string]string{
			"aa": `{"header":{"merkle_root":"m1","prev_main_hash":"x1"},"body":{"transactions":[]}}`,
		},
		index: map[string]string{
			"aa": `{"txs":[],"deposits":[
				{"outpoint":{"Deposit":"7215d16e:0"},"output":{"address":"sc1","content":{"Value":12300}}},
				{"outpoint":{"Deposit":"d9f0a85c:0"},"output":{"address":"sc2","content":{"Value":200000000}}}
			]}`,
		},
	}
	src := source{name: "thunder", node: node, cache: newBlockCache()}

	block, activity, err := nodeBlock(context.Background(), src, "aa", 0)
	if err != nil {
		t.Fatalf("read the block: %v", err)
	}
	if got := block.GetDepositCount(); got != 2 {
		t.Errorf("deposit count = %d, want 2", got)
	}
	if got := block.GetDepositValueSats(); got != 200012300 {
		t.Errorf("deposited = %d sats, want 200012300", got)
	}
	if got := len(activity); got != 2 {
		t.Fatalf("the block lists %d rows, want 2", got)
	}
	if activity[0].GetKind() != pb.Kind_KIND_DEPOSIT {
		t.Errorf("the first row reads %s, want a deposit", activity[0].GetKind())
	}
	if got := activity[0].GetAddress(); got != "sc1" {
		t.Errorf("the first row paid %s, want sc1", got)
	}
	if got := activity[0].GetValueSats(); got != 12300 {
		t.Errorf("the first row is worth %d sats, want 12300", got)
	}
}

// A block index that answers a shape no reader knows is an error, not an
// empty block. A silent fallback hid every deposit.
func TestNodeBlockRefusesABlockIndexItCannotRead(t *testing.T) {
	node := &recordingNode{
		byHash: map[string]string{
			"aa": `{"header":{"merkle_root":"m1","prev_main_hash":"x1"},"body":{"transactions":[]}}`,
		},
		index: map[string]string{"aa": `{"txs":[],"deposits":[{"outpoint":"7215d16e:0"}]}`},
	}
	src := source{name: "thunder", node: node, cache: newBlockCache()}

	if _, _, err := nodeBlock(context.Background(), src, "aa", 0); err == nil {
		t.Fatal("the read passed, and it must refuse a shape it cannot read")
	}
}

// The overview lists the newest transactions whatever their age. A chain that
// saw nothing for weeks still names what it did last.
func TestOverviewWalksPastTheBlockWindowForRows(t *testing.T) {
	// The chain holds 40 blocks. Only the oldest one carries a transaction,
	// so a walk that stops at the block window lists nothing.
	const tip = 39
	node := &recordingNode{
		count: tip + 1,
		answers: map[string]string{
			"get_best_sidechain_block_hash": `"b39"`,
		},
		byHash: map[string]string{},
		index:  map[string]string{},
	}
	for height := 0; height <= tip; height++ {
		hash := fmt.Sprintf("b%d", height)
		prev := ""
		if height > 0 {
			prev = fmt.Sprintf(`"prev_side_hash":"b%d",`, height-1)
		}
		node.byHash[hash] = fmt.Sprintf(
			`{"header":{%s"merkle_root":"m%d","prev_main_hash":"x%d"},"body":{"transactions":[]}}`,
			prev, height, height,
		)
		node.index[hash] = `{"txs":[],"deposits":[]}`
	}
	node.index["b0"] = `{"txs":[],"deposits":[
		{"outpoint":{"Deposit":"7215d16e:0"},"output":{"address":"sc1","content":{"Value":12300}}}
	]}`

	src := source{name: "thunder", node: node, cache: newBlockCache()}
	out, err := nodeOverview(context.Background(), src)
	if err != nil {
		t.Fatalf("read the overview: %v", err)
	}
	if got := len(out.GetBlocks()); got != blockListSize {
		t.Errorf("the strip holds %d blocks, want %d", got, blockListSize)
	}
	if got := len(out.GetRecent()); got != 1 {
		t.Fatalf("the overview lists %d rows, want 1", got)
	}
	if got := out.GetRecent()[0].GetAddress(); got != "sc1" {
		t.Errorf("the row paid %s, want sc1", got)
	}
}

// The walk stops at the scan depth, so an empty chain never reads forever.
func TestOverviewStopsAtTheScanDepth(t *testing.T) {
	const height = activityScanDepth + 50
	node := &recordingNode{
		count: height + 1,
		answers: map[string]string{
			"get_best_sidechain_block_hash": `"b0"`,
		},
		byHash: map[string]string{},
		index:  map[string]string{},
	}
	// Every block names the same parent, so the walk only stops on its cap.
	node.byHash["b0"] = `{"header":{"prev_side_hash":"b0","merkle_root":"m","prev_main_hash":"x"},"body":{"transactions":[]}}`
	node.index["b0"] = `{"txs":[],"deposits":[]}`

	src := source{name: "thunder", node: node, cache: newBlockCache()}
	if _, err := nodeOverview(context.Background(), src); err != nil {
		t.Fatalf("read the overview: %v", err)
	}
	var reads int
	for _, method := range node.called {
		if method == "get_block" {
			reads++
		}
	}
	if reads > activityScanDepth {
		t.Errorf("the walk read %d blocks, and the cap is %d", reads, activityScanDepth)
	}
}

// The cache answers a copy. A caller that stamps a row must never write into
// what the next reader gets.
func TestBlockCacheAnswersACopy(t *testing.T) {
	cache := newBlockCache()
	block, rows := cache.put("thunder:aa",
		&pb.Block{Hash: "aa", Height: 3},
		[]*pb.Activity{{Id: "tx1"}},
		true,
	)
	block.Height = 99
	rows[0].BlockTime = 12345

	again, rowsAgain, _, ok := cache.get("thunder:aa")
	if !ok {
		t.Fatal("the cache holds no block")
	}
	if again.GetHeight() != 3 {
		t.Errorf("the cached height reads %d, want 3", again.GetHeight())
	}
	if rowsAgain[0].GetBlockTime() != 0 {
		t.Errorf("the cached row reads a time of %d, want 0", rowsAgain[0].GetBlockTime())
	}
}

// A node that failed to answer the block index named no row. The cache must
// hold none of that, or the block stays empty after the node recovers.
func TestNodeBlockCachesNoIncompleteRead(t *testing.T) {
	node := &recordingNode{
		byHash: map[string]string{
			"aa": `{"header":{"merkle_root":"m1","prev_main_hash":"x1"},"body":{"transactions":[]}}`,
		},
		index: map[string]string{},
	}
	src := source{name: "thunder", node: node, cache: newBlockCache()}
	ctx := context.Background()

	if _, _, err := nodeBlock(ctx, src, "aa", 0); err != nil {
		t.Fatalf("read the block: %v", err)
	}
	if _, _, _, ok := src.cache.get(src.cacheKey("aa")); ok {
		t.Fatal("the cache holds a block the node never named the rows of")
	}

	node.index["aa"] = `{"txs":[],"deposits":[
		{"outpoint":{"Deposit":"7215d16e:0"},"output":{"address":"sc1","content":{"Value":12300}}}
	]}`
	_, activity, err := nodeBlock(ctx, src, "aa", 0)
	if err != nil {
		t.Fatalf("read the block again: %v", err)
	}
	if len(activity) != 1 {
		t.Fatalf("the second read lists %d rows, want 1", len(activity))
	}
	if _, _, _, ok := src.cache.get(src.cacheKey("aa")); !ok {
		t.Error("the cache holds no block after a complete read")
	}
}

// A hosted index lists the deposit rows and states no total. The block reads
// the total back from those rows, so the page never says zero over a list.
func TestCountDepositsFillsWhatAnIndexLeavesEmpty(t *testing.T) {
	block := &pb.Block{Hash: "aa"}
	rows := []*pb.Activity{
		{Kind: pb.Kind_KIND_TRANSFER, Id: "tx1", ValueSats: 500},
		{Kind: pb.Kind_KIND_DEPOSIT, Id: "d1", ValueSats: 12300},
		{Kind: pb.Kind_KIND_DEPOSIT, Id: "d2", ValueSats: 200000000},
	}
	countDeposits(block, rows)

	if got := block.GetDepositCount(); got != 2 {
		t.Errorf("deposit count = %d, want 2", got)
	}
	if got := block.GetDepositValueSats(); got != 200012300 {
		t.Errorf("deposited = %d sats, want 200012300", got)
	}

	// A source that states its own total keeps it.
	stated := &pb.Block{Hash: "bb", DepositCount: 1, DepositValueSats: 7}
	countDeposits(stated, rows)
	if stated.GetDepositCount() != 1 || stated.GetDepositValueSats() != 7 {
		t.Errorf("the stated total changed to %d / %d", stated.GetDepositCount(), stated.GetDepositValueSats())
	}
}

// The walk reads up to the scan depth, and only a kept block or one that
// carried a row costs a mainchain lookup.
func TestOverviewResolvesOnlyTheBlocksThePageUses(t *testing.T) {
	const tip = 39
	node := &recordingNode{
		count:   tip + 1,
		answers: map[string]string{"get_best_sidechain_block_hash": `"b39"`},
		byHash:  map[string]string{},
		index:   map[string]string{},
	}
	for height := 0; height <= tip; height++ {
		hash := fmt.Sprintf("b%d", height)
		prev := ""
		if height > 0 {
			prev = fmt.Sprintf(`"prev_side_hash":"b%d",`, height-1)
		}
		node.byHash[hash] = fmt.Sprintf(
			`{"header":{%s"merkle_root":"m%d","prev_main_hash":"x%d"},"body":{"transactions":[]}}`,
			prev, height, height,
		)
		node.index[hash] = `{"txs":[],"deposits":[]}`
	}
	node.index["b0"] = `{"txs":[],"deposits":[
		{"outpoint":{"Deposit":"7215d16e:0"},"output":{"address":"sc1","content":{"Value":12300}}}
	]}`

	var asked []string
	src := source{
		name:  "thunder",
		node:  node,
		cache: newBlockCache(),
		resolve: func(_ context.Context, blocks ...*pb.Block) {
			for _, block := range blocks {
				asked = append(asked, block.GetMainchainHash())
				block.BlockTime = 1700000000
			}
		},
	}
	out, err := nodeOverview(context.Background(), src)
	if err != nil {
		t.Fatalf("read the overview: %v", err)
	}
	// Six kept blocks, plus the one block that carried the deposit.
	if len(asked) != blockListSize+1 {
		t.Errorf("the page resolved %d blocks, want %d", len(asked), blockListSize+1)
	}
	if len(out.GetRecent()) != 1 {
		t.Fatalf("the overview lists %d rows, want 1", len(out.GetRecent()))
	}
	if out.GetRecent()[0].GetBlockTime() != 1700000000 {
		t.Error("the row carries no block time")
	}
}

// A node that names no height takes the one the walk counted. That count can
// move between two calls, so the cache must never hold it.
func TestNodeBlockRestampsAHeightTheNodeNeverNamed(t *testing.T) {
	node := &recordingNode{
		byHash: map[string]string{
			"aa": `{"header":{"merkle_root":"m1","prev_main_hash":"x1"},"body":{"transactions":[]}}`,
		},
		index: map[string]string{"aa": `{"txs":[],"deposits":[
			{"outpoint":{"Deposit":"7215d16e:0"},"output":{"address":"sc1","content":{"Value":12300}}}
		]}`},
	}
	src := source{name: "thunder", node: node, cache: newBlockCache()}
	ctx := context.Background()

	if _, _, err := nodeBlock(ctx, src, "aa", 41); err != nil {
		t.Fatalf("read the block: %v", err)
	}
	block, activity, err := nodeBlock(ctx, src, "aa", 42)
	if err != nil {
		t.Fatalf("read the block again: %v", err)
	}
	if block.GetHeight() != 42 {
		t.Errorf("the cached block reads height %d, want 42", block.GetHeight())
	}
	if len(activity) != 1 || activity[0].GetBlockHeight() != 42 {
		t.Errorf("the row names height %d, want 42", activity[0].GetBlockHeight())
	}
}

// A node that serves no block index names no row, whatever the walk reads.
// The page reads the strip and stops, rather than the whole scan depth on
// every refresh.
func TestOverviewStopsAtTheStripWithoutABlockIndex(t *testing.T) {
	const tip = 99
	node := &recordingNode{
		count:   tip + 1,
		answers: map[string]string{"get_best_sidechain_block_hash": `"b99"`},
		byHash:  map[string]string{},
		index:   map[string]string{},
	}
	for height := 0; height <= tip; height++ {
		prev := ""
		if height > 0 {
			prev = fmt.Sprintf(`"prev_side_hash":"b%d",`, height-1)
		}
		node.byHash[fmt.Sprintf("b%d", height)] = fmt.Sprintf(
			`{"header":{%s"merkle_root":"m%d","prev_main_hash":"x%d"},"body":{"transactions":[]}}`,
			prev, height, height,
		)
	}

	src := source{name: "thunder", node: node, cache: newBlockCache()}
	out, err := nodeOverview(context.Background(), src)
	if err != nil {
		t.Fatalf("read the overview: %v", err)
	}
	if len(out.GetBlocks()) != blockListSize {
		t.Errorf("the strip holds %d blocks, want %d", len(out.GetBlocks()), blockListSize)
	}
	var reads int
	for _, method := range node.called {
		if method == "get_block" {
			reads++
		}
	}
	if reads != blockListSize {
		t.Errorf("the walk read %d blocks, want %d", reads, blockListSize)
	}
}
