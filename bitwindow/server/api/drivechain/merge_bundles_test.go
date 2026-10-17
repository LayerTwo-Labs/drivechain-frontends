package drivechain

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/proto"

	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/drivechain/v1"
)

const testBundleMaxAge uint32 = 26300

// TestMergeBundlesRevivesFailedBundle proves a re-proposed M6ID that was cached
// as failed comes back as pending at its new submission height, so the age is
// recomputed against the fresh voting window instead of the original one.
func TestMergeBundlesRevivesFailedBundle(t *testing.T) {
	s := &Server{bundleMaxAge: testBundleMaxAge}

	const m6id = "abc123"

	cached := []*pb.WithdrawalBundle{{
		M6Id:        m6id,
		BlockHeight: 100,
		Status:      "failed",
		MaxAge:      testBundleMaxAge,
	}}

	resubmitted := []*pb.WithdrawalBundle{{
		M6Id:        m6id,
		BlockHeight: 30000,
		Status:      "pending",
		MaxAge:      testBundleMaxAge,
	}}

	merged := s.mergeBundles(cached, resubmitted)
	require.Len(t, merged, 1)
	require.Equal(t, "pending", merged[0].Status)
	require.Equal(t, uint32(30000), merged[0].BlockHeight)

	aged := s.updateBundleAges(merged, 30010)
	require.Len(t, aged, 1)
	require.Equal(t, uint32(10), aged[0].Age)
	require.Equal(t, testBundleMaxAge-10, aged[0].BlocksLeft)
}

func TestMergeBundlesCollapsesColdScan(t *testing.T) {
	s := &Server{bundleMaxAge: testBundleMaxAge}

	const m6id = "abc123"

	scanned := []*pb.WithdrawalBundle{{
		M6Id:        m6id,
		BlockHeight: 60,
		Status:      "pending",
		MaxAge:      testBundleMaxAge,
	}, {
		M6Id:           m6id,
		BlockHeight:    70,
		Status:         "succeeded",
		MaxAge:         testBundleMaxAge,
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

func TestMergeBundlesSortsByHeight(t *testing.T) {
	s := &Server{bundleMaxAge: testBundleMaxAge}

	scanned := []*pb.WithdrawalBundle{
		{M6Id: "c", BlockHeight: 90, Status: "pending"},
		{M6Id: "a", BlockHeight: 60, Status: "pending"},
		{M6Id: "b", BlockHeight: 60, Status: "pending"},
	}

	merged := s.mergeBundles(nil, scanned)
	require.Len(t, merged, 3)
	require.Equal(t, []string{"a", "b", "c"}, []string{merged[0].M6Id, merged[1].M6Id, merged[2].M6Id})
}

func TestUpdateBundleAges(t *testing.T) {
	s := &Server{bundleMaxAge: testBundleMaxAge}

	cached := &pb.WithdrawalBundle{
		M6Id:           "abc123",
		SidechainId:    9,
		BlockHeight:    100,
		Status:         "pending",
		MaxAge:         testBundleMaxAge,
		SequenceNumber: 4,
		TransactionHex: "beef",
		Age:            1,
		BlocksLeft:     testBundleMaxAge - 1,
	}
	before := proto.Clone(cached)

	aged := s.updateBundleAges([]*pb.WithdrawalBundle{cached}, 110)

	want := proto.Clone(cached).(*pb.WithdrawalBundle)
	want.Age = 10
	want.BlocksLeft = testBundleMaxAge - 10
	require.Len(t, aged, 1)
	assert.True(t, proto.Equal(want, aged[0]))
	assert.True(t, proto.Equal(before, cached))

	short := &Server{bundleMaxAge: 10}
	aged = short.updateBundleAges([]*pb.WithdrawalBundle{{M6Id: "abc123", BlockHeight: 100, Status: "pending"}}, 103)
	require.Len(t, aged, 1)
	assert.Equal(t, uint32(7), aged[0].BlocksLeft)
}
