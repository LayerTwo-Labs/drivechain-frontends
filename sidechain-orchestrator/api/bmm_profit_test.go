package api

import (
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/engines"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/engines/bmmstate"
)

func wonRound(bidState string) bmmstate.Round {
	return bmmstate.Round{
		Result:         engines.ResultWon,
		BlockWorthSats: 5000,
		WinnerBidSats:  1200,
		OurBids:        []bmmstate.Bid{{BidSats: 1200, IsOurs: true, State: bidState}},
	}
}

// A connected block pays its fees, so the round earns what the block is worth
// less what the bid cost.
func TestProfitCountsAConnectedBlock(t *testing.T) {
	out := roundToProto(wonRound(engines.BidConnected))

	require.True(t, out.HasProfit)
	require.EqualValues(t, 3800, out.ProfitSats)
}

// The engine abandons a won block the chain left behind. The miner keeps the
// bid, and the block pays nothing, so the round costs what it bid.
func TestProfitCountsAnAbandonedBlockAsACost(t *testing.T) {
	out := roundToProto(wonRound(engines.BidMissed))

	require.True(t, out.HasProfit)
	require.EqualValues(t, -1200, out.ProfitSats)
}

// A bid no miner took is never paid.
func TestALostRoundReportsNoProfit(t *testing.T) {
	round := wonRound(engines.BidMissed)
	round.Result = engines.ResultLost

	out := roundToProto(round)

	require.False(t, out.HasProfit)
	require.Zero(t, out.ProfitSats)
}
