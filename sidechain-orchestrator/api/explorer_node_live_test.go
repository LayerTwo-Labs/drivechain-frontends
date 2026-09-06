package api

import (
	"context"
	"os"
	"strconv"
	"testing"
	"time"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/explorer/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

// A live node answers the overview in the shape the page reads, deposits
// included. Set EXPLORER_NODE_TEST to the node's RPC port to run it.
func TestExplorerReadsALiveNode(t *testing.T) {
	port := os.Getenv("EXPLORER_NODE_TEST")
	if port == "" {
		t.Skip("set EXPLORER_NODE_TEST to a sidechain RPC port")
	}
	number, err := strconv.Atoi(port)
	if err != nil {
		t.Fatalf("read the port: %v", err)
	}

	ctx, cancel := context.WithTimeout(context.Background(), 120*time.Second)
	defer cancel()

	src := source{
		name:  "thunder",
		node:  sidechain.NewJSONRPCProxy("127.0.0.1", number),
		cache: newBlockCache(),
	}
	out, err := nodeOverview(ctx, src)
	if err != nil {
		t.Fatalf("read the overview: %v", err)
	}
	if len(out.GetBlocks()) == 0 {
		t.Fatal("the node holds no blocks")
	}
	t.Logf("tip %d, %d blocks, %d rows", out.GetTipHeight(), len(out.GetBlocks()), len(out.GetRecent()))

	var deposits int
	for _, row := range out.GetRecent() {
		if row.GetKind() != pb.Kind_KIND_DEPOSIT {
			continue
		}
		deposits++
		if row.GetAddress() == "" {
			t.Errorf("deposit %s names no address", row.GetId())
		}
		if row.GetValueSats() == 0 {
			t.Errorf("deposit %s is worth nothing", row.GetId())
		}
		t.Logf("deposit %s paid %d sats to %s in block %d",
			row.GetId(), row.GetValueSats(), row.GetAddress(), row.GetBlockHeight())
	}
	if len(out.GetRecent()) == 0 {
		t.Error("the overview lists no rows, and the chain saw transactions")
	}
}
