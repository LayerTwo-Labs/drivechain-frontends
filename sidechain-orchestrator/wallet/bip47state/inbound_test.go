package bip47state

import (
	"testing"

	"github.com/stretchr/testify/require"
)

func TestInboundStore_RoundTrip(t *testing.T) {
	dir := t.TempDir()
	s := NewInboundStore(dir)

	const wid = "W1"
	const sender = "PMsenderAAA"
	require.NoError(t, s.RecordInbound(wid, sender, "txid1", 100, 1700000000))

	got, err := s.Get(wid, sender)
	require.NoError(t, err)
	require.NotNil(t, got)
	require.Equal(t, "txid1", got.FirstNotificationTxID)
	require.Equal(t, int32(100), got.FirstSeenHeight)
	require.Equal(t, int64(1700000000), got.FirstSeenBlockTime)
	require.Equal(t, uint32(0), got.ImportedThroughIndex)

	// Second RecordInbound is a no-op — first record wins.
	require.NoError(t, s.RecordInbound(wid, sender, "txid2-ignored", 200, 1800000000))
	got, _ = s.Get(wid, sender)
	require.Equal(t, "txid1", got.FirstNotificationTxID)

	// BumpImportedIndex advances; reads back fresh on a new store instance.
	require.NoError(t, s.BumpImportedIndex(wid, sender, 25))
	s2 := NewInboundStore(dir)
	got2, err := s2.Get(wid, sender)
	require.NoError(t, err)
	require.Equal(t, uint32(25), got2.ImportedThroughIndex)

	// BumpImportedIndex with a lower value is a no-op.
	require.NoError(t, s2.BumpImportedIndex(wid, sender, 10))
	got3, _ := s2.Get(wid, sender)
	require.Equal(t, uint32(25), got3.ImportedThroughIndex)
}

func TestInboundStore_ScanCursor(t *testing.T) {
	dir := t.TempDir()
	s := NewInboundStore(dir)

	n, err := s.ScanCursor("W1")
	require.NoError(t, err)
	require.Equal(t, 0, n)

	require.NoError(t, s.SetScanCursor("W1", 42))

	s2 := NewInboundStore(dir)
	n2, err := s2.ScanCursor("W1")
	require.NoError(t, err)
	require.Equal(t, 42, n2)
}

func TestInboundStore_ListByWallet(t *testing.T) {
	dir := t.TempDir()
	s := NewInboundStore(dir)

	require.NoError(t, s.RecordInbound("W1", "PMa", "t1", 0, 0))
	require.NoError(t, s.RecordInbound("W1", "PMb", "t2", 0, 0))
	require.NoError(t, s.RecordInbound("W2", "PMc", "t3", 0, 0))

	rows, err := s.ListByWallet("W1")
	require.NoError(t, err)
	require.Len(t, rows, 2)
	require.Equal(t, "PMa", rows[0].SenderPaymentCode)
	require.Equal(t, "PMb", rows[1].SenderPaymentCode)
}
