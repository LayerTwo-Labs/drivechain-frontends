package miningpools

import (
	"cmp"
	"math/big"
	"slices"
	"strings"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/coinbases"
	"github.com/btcsuite/btcd/blockchain"
)

// Share is one pool's slice of a window of blocks.
type Share struct {
	Pool     Pool
	Blocks   uint32
	Empty    uint32
	Share    float64
	Hashrate float64
}

// Summary is a window of blocks split by pool. Every registered pool is
// listed, with zero blocks when it mined none.
type Summary struct {
	Shares          []Share
	Blocks          uint32
	FromHeight      uint32
	ToHeight        uint32
	NetworkHashrate float64
}

// Summarize attributes every block and estimates hashrate from the work the
// window took over the time it spanned.
func Summarize(rows []coinbases.Coinbase, pools []Pool) Summary {
	bySlug := make(map[string]*Share, len(pools)+1)
	for _, pool := range pools {
		bySlug[pool.Slug] = &Share{Pool: pool}
	}
	work := new(big.Int)
	for _, row := range rows {
		pool := Match(row.Script, row.Addresses, pools)
		share, ok := bySlug[pool.Slug]
		if !ok {
			share = &Share{Pool: pool}
			bySlug[pool.Slug] = share
		}
		share.Blocks++
		if row.TxCount == 1 {
			share.Empty++
		}
		work.Add(work, blockchain.CalcWork(row.Bits))
	}

	out := Summary{Blocks: uint32(len(rows))}
	if len(rows) > 0 {
		out.FromHeight = rows[0].Height
		out.ToHeight = rows[len(rows)-1].Height
		if span := rows[len(rows)-1].BlockTime.Sub(rows[0].BlockTime).Seconds(); span > 0 {
			total, _ := new(big.Float).SetInt(work).Float64()
			out.NetworkHashrate = total / span
		}
	}
	for _, share := range bySlug {
		if out.Blocks > 0 {
			share.Share = float64(share.Blocks) / float64(out.Blocks)
		}
		share.Hashrate = share.Share * out.NetworkHashrate
		out.Shares = append(out.Shares, *share)
	}
	slices.SortFunc(out.Shares, func(a, b Share) int {
		return cmp.Or(
			cmp.Compare(b.Blocks, a.Blocks),
			strings.Compare(strings.ToLower(a.Pool.Name), strings.ToLower(b.Pool.Name)),
		)
	})
	return out
}
