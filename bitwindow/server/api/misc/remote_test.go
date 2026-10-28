package misc_test

import (
	"context"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/api/misc"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	miscv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/misc/v1"
)

type stubRemote []engines.RemoteItem

func (s stubRemote) ListFrontPage(context.Context, string, uint32) ([]engines.RemoteItem, error) {
	return s, nil
}

func TestService_ListCoinNews_RemoteFee(t *testing.T) {
	t.Parallel()
	remote := stubRemote{
		{ItemIDHex: "aa", Headline: "Dear", FeeSats: 5000, BlockTime: time.Now()},
		{ItemIDHex: "bb", Headline: "Cheap", FeeSats: 100, BlockTime: time.Now()},
	}
	srv := misc.New(database.Test(t), nil, nil, nil, remote)

	resp, err := srv.ListCoinNews(t.Context(), &miscv1.ListCoinNewsRequest{})
	require.NoError(t, err)
	require.Len(t, resp.CoinNews, 2)
	assert.Equal(t, "Dear", resp.CoinNews[0].Headline)
	assert.EqualValues(t, 5000, resp.CoinNews[0].FeeSats)
	assert.EqualValues(t, 100, resp.CoinNews[1].FeeSats)
}
