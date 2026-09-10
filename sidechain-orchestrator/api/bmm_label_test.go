package api

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"testing"

	"github.com/stretchr/testify/require"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
)

const (
	labelTip      = "00000000000000000000a1b2c3d4e5f60718293a4b5c6d7e8f90a1b2c3d4e5f6"
	labelOldTip   = "00000000000000000000ffeeddccbbaa99887766554433221100ffeeddccbbaa"
	labelCritical = "1111111111111111111111111111111111111111111111111111111111111111"
)

func bidScriptHex(t *testing.T, slot uint8, prevMain string) string {
	t.Helper()
	script, err := orchestrator.M8BmmRequestScript(slot, labelCritical, prevMain)
	require.NoError(t, err)
	return hex.EncodeToString(script)
}

func TestBidLabelReadsALiveBid(t *testing.T) {
	bid := BidLabel(bidScriptHex(t, 9, labelTip), labelTip)

	require.NotNil(t, bid)
	require.Equal(t, uint32(9), bid.Slot)
	require.Equal(t, labelCritical, bid.CriticalHash)
	require.Equal(t, labelTip, bid.PrevMainHash)
	require.False(t, bid.Lost)
}

// The tip moved past the block the bid names, so no miner can take it.
func TestBidLabelCallsAStrandedBidLost(t *testing.T) {
	bid := BidLabel(bidScriptHex(t, 9, labelOldTip), labelTip)

	require.NotNil(t, bid)
	require.True(t, bid.Lost)
}

// A read that misses the tip must not call a winnable bid lost.
func TestBidLabelKeepsABidLiveWithoutATip(t *testing.T) {
	bid := BidLabel(bidScriptHex(t, 9, labelOldTip), "")

	require.NotNil(t, bid)
	require.False(t, bid.Lost)
}

func TestBidLabelIgnoresEveryOtherScript(t *testing.T) {
	for name, scriptHex := range map[string]string{
		"a payment":          "0014c0ffee0000000000000000000000000000000000",
		"a plain op_return":  "6a0b68656c6c6f20776f726c64",
		"an empty script":    "",
		"a broken hex":       "zz",
		"a short bmm script": "6a0300bf00",
	} {
		t.Run(name, func(t *testing.T) {
			require.Nil(t, BidLabel(scriptHex, labelTip))
		})
	}
}

// fakeCore answers the reads BidLabels makes, and counts every call.
type fakeCore struct {
	tip     string
	scripts map[string]string
	// dropped names the transactions the mempool does not hold.
	dropped map[string]bool
	calls   int
	tipErr  error
}

func (f *fakeCore) call(_ context.Context, method, params string) (json.RawMessage, error) {
	f.calls++
	switch method {
	case "getbestblockhash":
		if f.tipErr != nil {
			return nil, f.tipErr
		}
		return json.Marshal(f.tip)
	case "getrawtransaction":
		var args []any
		if err := json.Unmarshal([]byte(params), &args); err != nil {
			return nil, err
		}
		txid, _ := args[0].(string)
		script, ok := f.scripts[txid]
		if !ok {
			return nil, fmt.Errorf("no such transaction %s", txid)
		}
		return json.Marshal(map[string]any{
			"vout": []map[string]any{{"scriptPubKey": map[string]any{"hex": script}}},
		})
	case "getmempoolentry":
		var args []any
		if err := json.Unmarshal([]byte(params), &args); err != nil {
			return nil, err
		}
		txid, _ := args[0].(string)
		if f.dropped[txid] {
			return nil, fmt.Errorf("transaction %s not in mempool", txid)
		}
		return json.Marshal(map[string]any{})
	}
	return nil, fmt.Errorf("unexpected method %s", method)
}

func TestBidLabelsNamesOnlyTheBids(t *testing.T) {
	core := &fakeCore{
		tip: labelTip,
		scripts: map[string]string{
			"live":    bidScriptHex(t, 9, labelTip),
			"lost":    bidScriptHex(t, 9, labelOldTip),
			"payment": "0014c0ffee0000000000000000000000000000000000",
		},
	}

	bids := BidLabels(context.Background(), core.call, []string{"live", "lost", "payment", "missing"})

	require.Len(t, bids, 2)
	require.False(t, bids["live"].Lost)
	require.True(t, bids["lost"].Lost)
}

func TestBidLabelsReadsEachTxidOneTime(t *testing.T) {
	core := &fakeCore{tip: labelTip, scripts: map[string]string{"live": bidScriptHex(t, 9, labelTip)}}

	bids := BidLabels(context.Background(), core.call, []string{"live", "live", "live"})

	require.Len(t, bids, 1)
	require.Equal(t, 3, core.calls, "one tip read, one transaction read and one mempool read")
}

// An RBF raise leaves the replaced bid in the wallet with no confirmations. A
// cancel of it can evict the live bid, so it gets no label.
func TestBidLabelsSkipsAReplacedBid(t *testing.T) {
	core := &fakeCore{
		tip: labelTip,
		scripts: map[string]string{
			"replaced": bidScriptHex(t, 9, labelOldTip),
			"live":     bidScriptHex(t, 9, labelTip),
		},
		dropped: map[string]bool{"replaced": true},
	}

	bids := BidLabels(context.Background(), core.call, []string{"replaced", "live"})

	require.Len(t, bids, 1)
	require.Contains(t, bids, "live")
}

func TestBidLabelsCallsNothingWithoutATxid(t *testing.T) {
	core := &fakeCore{tip: labelTip}

	require.Nil(t, BidLabels(context.Background(), core.call, nil))
	require.Zero(t, core.calls)
}

// A node that cannot name its tip leaves every row unlabelled.
func TestBidLabelsStopsWhenTheTipReadFails(t *testing.T) {
	core := &fakeCore{tipErr: fmt.Errorf("no node")}

	require.Nil(t, BidLabels(context.Background(), core.call, []string{"live"}))
}
