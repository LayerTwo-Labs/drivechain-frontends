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

// TestMergeBundlesCollapsesColdScan proves a full scan with no cache collapses
// the submitted and succeeded events of one M6ID into a single row that keeps
// the submission height, instead of emitting both.
func TestMergeBundlesCollapsesColdScan(t *testing.T) {
	s := &Server{}

	const m6id = "abc123"

	scanned := []*pb.WithdrawalBundle{{
		M6Id:        m6id,
		BlockHeight: 60,
		Status:      "pending",
		MaxAge:      withdrawalVerificationPeriod,
	}, {
		M6Id:           m6id,
		BlockHeight:    70,
		Status:         "succeeded",
		MaxAge:         withdrawalVerificationPeriod,
		SequenceNumber: 7,
		TransactionHex: "deadbeef",
	}}

	merged := s.mergeBundles(nil, scanned)
	require.Len(t, merged, 1)
	require.Equal(t, "succeeded", merged[0].Status)
	require.Equal(t, uint32(60), merged[0].BlockHeight)
	require.Equal(t, uint64(7), merged[0].SequenceNumber)
	require.Equal(t, "deadbeef", merged[0].TransactionHex)
}

// TestMergeBundlesSortsByHeight proves the map rebuild returns a stable order.
func TestMergeBundlesSortsByHeight(t *testing.T) {
	s := &Server{}

	scanned := []*pb.WithdrawalBundle{
		{M6Id: "c", BlockHeight: 90, Status: "pending"},
		{M6Id: "a", BlockHeight: 60, Status: "pending"},
		{M6Id: "b", BlockHeight: 60, Status: "pending"},
	}

	merged := s.mergeBundles(nil, scanned)
	require.Len(t, merged, 3)
	require.Equal(t, []string{"a", "b", "c"}, []string{merged[0].M6Id, merged[1].M6Id, merged[2].M6Id})
}
