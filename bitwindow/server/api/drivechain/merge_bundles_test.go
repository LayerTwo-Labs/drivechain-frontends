package api_drivechain

import (
	"testing"

	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/drivechain/v1"
	"github.com/stretchr/testify/require"
)

// TestMergeBundlesRevivesFailedBundle proves a re-proposed M6ID that was cached
// as failed comes back as pending at its new submission height, so the age is
// recomputed against the fresh voting window instead of the original one.
func TestMergeBundlesRevivesFailedBundle(t *testing.T) {
	s := &Server{}

	const m6id = "abc123"

	cached := []*pb.WithdrawalBundle{{
		M6Id:        m6id,
		BlockHeight: 100,
		Status:      "failed",
		MaxAge:      withdrawalVerificationPeriod,
	}}

	resubmitted := []*pb.WithdrawalBundle{{
		M6Id:        m6id,
		BlockHeight: 30000,
		Status:      "pending",
		MaxAge:      withdrawalVerificationPeriod,
	}}

	merged := s.mergeBundles(cached, resubmitted)
	require.Len(t, merged, 1)
	require.Equal(t, "pending", merged[0].Status)
	require.Equal(t, uint32(30000), merged[0].BlockHeight)

	aged := s.updateBundleAges(merged, 30010)
	require.Len(t, aged, 1)
	require.Equal(t, uint32(10), aged[0].Age)
	require.Equal(t, withdrawalVerificationPeriod-10, aged[0].BlocksLeft)
}
