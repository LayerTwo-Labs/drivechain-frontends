package api

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"math"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/explorer/v1"
)

// mainchainBlock is a mainchain block at verbosity 3. Core computes the fee
// there, so no input walk is necessary.
type mainchainBlock struct {
	Hash   string `json:"hash"`
	Height uint32 `json:"height"`
	Tx     []struct {
		Txid string  `json:"txid"`
		Fee  float64 `json:"fee"`
		Vout []struct {
			N            uint32  `json:"n"`
			Value        float64 `json:"value"`
			ScriptPubKey struct {
				Hex string `json:"hex"`
			} `json:"scriptPubKey"`
		} `json:"vout"`
	} `json:"tx"`
}

// SetCoreCaller wires the bitcoind seam the bid lookup reads.
func (h *ExplorerHandler) SetCoreCaller(c CoreRawCaller) { h.core = c }

func (h *ExplorerHandler) coreCall(ctx context.Context, method, paramsJSON string) (json.RawMessage, error) {
	if h.core == nil {
		return nil, fmt.Errorf("no bitcoind seam")
	}
	return h.core(ctx, method, paramsJSON, "")
}

// resolveBid names the winning BMM bid for one sidechain block: the M8
// outpoint on the mainchain, and the fee it paid.
//
// A header names the mainchain block the bid was built on. A miner takes that
// bid in the very next block, so the M8 sits one block later.
func (h *ExplorerHandler) resolveBid(ctx context.Context, slot uint32, block *pb.Block) {
	if block == nil || block.GetBid() != nil || block.GetMainchainHash() == "" {
		return
	}
	carrier, err := h.nextMainchainHash(ctx, block.GetMainchainHash())
	if err != nil || carrier == "" {
		return
	}
	raw, err := h.coreCall(ctx, "getblock", fmt.Sprintf("[%q,3]", carrier))
	if err != nil {
		return
	}
	var mined mainchainBlock
	if err := json.Unmarshal(raw, &mined); err != nil {
		return
	}
	block.Bid = findBid(mined, uint8(slot), block.GetHash(), block.GetMainchainHash())
}

// nextMainchainHash names the block that follows one mainchain block.
func (h *ExplorerHandler) nextMainchainHash(ctx context.Context, hash string) (string, error) {
	raw, err := h.coreCall(ctx, "getblockheader", fmt.Sprintf("[%q]", hash))
	if err != nil {
		return "", err
	}
	var header struct {
		NextBlockHash string `json:"nextblockhash"`
	}
	if err := json.Unmarshal(raw, &header); err != nil {
		return "", fmt.Errorf("read the mainchain header %s: %w", hash, err)
	}
	return header.NextBlockHash, nil
}

// findBid picks the M8 in a mainchain block that commits to one sidechain
// block. A valid M8 sits at output zero, so a copy anywhere else is not a bid.
// It also names the parent it was built on, and only that parent can mine it.
func findBid(mined mainchainBlock, slot uint8, criticalHash, prevMainHash string) *pb.Bid {
	for _, tx := range mined.Tx {
		// The fee is the bid, so the M8 output itself pays nothing.
		if len(tx.Vout) == 0 || tx.Vout[0].N != 0 || tx.Vout[0].Value != 0 {
			continue
		}
		script, err := hex.DecodeString(tx.Vout[0].ScriptPubKey.Hex)
		if err != nil {
			continue
		}
		request := orchestrator.ParseM8BmmRequestScript(script)
		if request == nil || request.Slot != slot || request.CriticalHash != criticalHash {
			continue
		}
		if request.PrevMainHash != prevMainHash {
			continue
		}
		return &pb.Bid{
			Txid:        tx.Txid,
			Sats:        int64(math.Round(tx.Fee * 1e8)),
			BlockHash:   mined.Hash,
			BlockHeight: mined.Height,
		}
	}
	return nil
}
