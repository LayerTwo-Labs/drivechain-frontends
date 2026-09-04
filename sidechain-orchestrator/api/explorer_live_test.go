package api

import (
	"context"
	"os"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/sidechainesplora"
)

// A live index answers every route the explorer reads, in the shape the
// handler maps. Set EXPLORER_LIVE_TEST to run it against the hosted index.
func TestExplorerReadsALiveIndex(t *testing.T) {
	if os.Getenv("EXPLORER_LIVE_TEST") == "" {
		t.Skip("set EXPLORER_LIVE_TEST to read the hosted index")
	}
	url := config.SidechainEsploraURLForNetwork("thunder", config.NetworkECash)
	if url == "" {
		t.Fatal("no index is hosted for thunder on eCash")
	}
	client := sidechainesplora.New(url)
	ctx, cancel := context.WithTimeout(context.Background(), 60*time.Second)
	defer cancel()

	blocks, err := client.Blocks(ctx)
	if err != nil {
		t.Fatalf("read the blocks: %v", err)
	}
	if len(blocks) == 0 {
		t.Fatal("the index holds no blocks")
	}
	tip := newBlock(blocks[0])
	if tip.GetHash() == "" || tip.GetMerkleRoot() == "" {
		t.Errorf("the tip reads %+v, want a hash and a merkle root", tip)
	}
	if tip.GetMainchainHeight() == 0 {
		t.Errorf("block %d names no mainchain height", tip.GetHeight())
	}

	feed, err := client.RecentActivity(ctx)
	if err != nil {
		t.Fatalf("read the activity feed: %v", err)
	}
	for _, row := range activityList(feed) {
		if row.GetId() == "" {
			t.Errorf("an activity row carries no id: %+v", row)
		}
		if row.GetKind() == 0 {
			t.Errorf("row %s names no kind", row.GetId())
		}
	}

	rows, err := client.BlockActivity(ctx, blocks[0].ID)
	if err != nil {
		t.Fatalf("read the block activity: %v", err)
	}
	if len(rows) != blocks[0].TxCount {
		t.Errorf("block %d carries %d rows, and its header counts %d transactions",
			blocks[0].Height, len(rows), blocks[0].TxCount)
	}

	// The bundle route answers whether or not a bundle exists.
	if _, err := client.Withdrawals(ctx); err != nil {
		t.Fatalf("read the withdrawals: %v", err)
	}

	// Thunder holds slot 9, and the escrow holds its coins.
	info, err := client.Sidechain(ctx, 9)
	if err != nil {
		t.Fatalf("read the sidechain: %v", err)
	}
	if info.Slot != 9 || info.ActivationHeight == 0 {
		t.Errorf("the slot reads %+v, want slot 9 with an activation height", info)
	}
	if info.Treasury == nil || info.Treasury.ValueSats == 0 {
		t.Errorf("the treasury reads %+v, want the coins the escrow holds", info.Treasury)
	}

	// A transaction the feed names reads back with its coins on both sides.
	for _, row := range feed {
		if row.Kind == sidechainesplora.KindDeposit {
			continue
		}
		tx, err := client.Tx(ctx, row.ID)
		if err != nil {
			t.Fatalf("read transaction %s: %v", row.ID, err)
		}
		out := newTransaction(tx)
		if len(out.GetInputs()) == 0 || len(out.GetOutputs()) == 0 {
			t.Errorf("transaction %s reads %d in and %d out",
				row.ID, len(out.GetInputs()), len(out.GetOutputs()))
		}
		break
	}
}
