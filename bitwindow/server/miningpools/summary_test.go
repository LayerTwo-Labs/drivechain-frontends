package miningpools

import (
	"math/big"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/coinbases"
	"github.com/btcsuite/btcd/blockchain"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

const testBits = 0x1d00ffff

func block(height uint32, at time.Time, tag string, txCount uint32) coinbases.Coinbase {
	return coinbases.Coinbase{
		Height:    height,
		BlockTime: at,
		Bits:      testBits,
		TxCount:   txCount,
		Script:    []byte("\x03\x01\x02\x03" + tag),
	}
}

func TestSummarize(t *testing.T) {
	t.Parallel()

	pools := betanetPools(t)
	start := time.Unix(1_800_000_000, 0)

	t.Run("an empty window lists every pool with no blocks", func(t *testing.T) {
		t.Parallel()
		summary := Summarize(nil, pools)

		assert.Zero(t, summary.Blocks)
		assert.Zero(t, summary.NetworkHashrate)
		require.Len(t, summary.Shares, len(pools))
		for _, share := range summary.Shares {
			assert.Zero(t, share.Blocks)
			assert.Zero(t, share.Share)
		}
	})

	t.Run("blocks split by pool, most blocks first", func(t *testing.T) {
		t.Parallel()
		rows := []coinbases.Coinbase{
			block(100, start, "/ecpool.tech/", 3),
			block(101, start.Add(10*time.Minute), "/bip300xyz/", 1),
			block(102, start.Add(20*time.Minute), "/ecpool.tech/", 5),
			block(103, start.Add(30*time.Minute), "/nobody/", 2),
		}
		summary := Summarize(rows, pools)

		assert.EqualValues(t, 4, summary.Blocks)
		assert.EqualValues(t, 100, summary.FromHeight)
		assert.EqualValues(t, 103, summary.ToHeight)
		require.Len(t, summary.Shares, len(pools)+1)

		first := summary.Shares[0]
		assert.Equal(t, "eCPool.tech", first.Pool.Name)
		assert.EqualValues(t, 2, first.Blocks)
		assert.Zero(t, first.Empty)
		assert.InDelta(t, 0.5, first.Share, 1e-9)
		assert.InDelta(t, summary.NetworkHashrate/2, first.Hashrate, 1e-3)

		names := make(map[string]Share)
		for _, share := range summary.Shares {
			names[share.Pool.Name] = share
		}
		assert.EqualValues(t, 1, names["bip300.xyz"].Empty)
		assert.EqualValues(t, 1, names[Unknown.Name].Blocks)
		assert.Zero(t, names["ePool"].Blocks)
	})

	t.Run("the hashrate is the work after the first block over the span", func(t *testing.T) {
		t.Parallel()
		rows := []coinbases.Coinbase{
			block(100, start, "", 1),
			block(101, start.Add(5*time.Minute), "", 1),
			block(102, start.Add(10*time.Minute), "", 1),
		}
		summary := Summarize(rows, nil)

		work := new(big.Int).Mul(blockchain.CalcWork(testBits), big.NewInt(2))
		want, _ := new(big.Float).Quo(new(big.Float).SetInt(work), big.NewFloat(600)).Float64()
		assert.InDelta(t, want, summary.NetworkHashrate, want*1e-12)
	})

	t.Run("one block spans no time and gives no hashrate", func(t *testing.T) {
		t.Parallel()
		summary := Summarize([]coinbases.Coinbase{block(100, start, "", 1)}, nil)

		assert.EqualValues(t, 1, summary.Blocks)
		assert.Zero(t, summary.NetworkHashrate)
		require.Len(t, summary.Shares, 1)
		assert.Equal(t, Unknown.Name, summary.Shares[0].Pool.Name)
		assert.InDelta(t, 1.0, summary.Shares[0].Share, 1e-9)
	})
}
