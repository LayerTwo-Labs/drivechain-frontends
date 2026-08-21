package wallet

import (
	"context"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestSplitCacheRoundTrip(t *testing.T) {
	ctx := context.Background()
	db, err := OpenElectrumDB(ctx, filepath.Join(t.TempDir(), "electrum.db"))
	require.NoError(t, err)
	defer func() { _ = db.Close() }()

	svc := &Service{electrumDB: db}

	statuses, err := svc.SplitStatuses(ctx)
	require.NoError(t, err)
	require.Empty(t, statuses)

	require.NoError(t, svc.SaveSplitStatus(ctx, "aa:0", true))
	require.NoError(t, svc.SaveSplitStatus(ctx, "bb:1", false))
	require.NoError(t, svc.SaveSplitStatus(ctx, "bb:1", false))

	statuses, err = svc.SplitStatuses(ctx)
	require.NoError(t, err)
	require.Equal(t, map[string]bool{"aa:0": true, "bb:1": false}, statuses)
}
