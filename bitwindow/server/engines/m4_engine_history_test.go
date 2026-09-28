package engines

import (
	"context"
	"fmt"
	"testing"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/m4"
	"github.com/stretchr/testify/require"
)

// The production database has one connection, so a nested query deadlocks.
func TestGetM4History_OneConnection(t *testing.T) {
	db := database.Test(t)
	db.SetMaxOpenConns(1)
	e := NewM4Engine(db)

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	for height := uint32(100); height <= 101; height++ {
		require.NoError(t, e.persistM4Message(ctx, &m4.M4Message{
			BlockHeight: height,
			BlockHash:   fmt.Sprintf("hash-%d", height),
			BlockTime:   time.Unix(int64(height), 0),
			RawBytes:    []byte{0x00},
		}))
		var id int64
		require.NoError(t, db.QueryRowContext(ctx, `SELECT id FROM m4_messages WHERE block_height = ?`, height).Scan(&id))
		require.NoError(t, e.persistM4Votes(ctx, id, []m4.M4Vote{
			{SidechainSlot: 0, VoteType: m4.VoteTypeAbstain},
			{SidechainSlot: 1, VoteType: m4.VoteTypeAbstain},
		}))
	}

	history, err := e.GetM4History(ctx, 10)
	require.NoError(t, err)
	require.Len(t, history, 2)
	require.Equal(t, uint32(101), history[0].BlockHeight)
	require.Len(t, history[0].Votes, 2)
	require.Len(t, history[1].Votes, 2)
}
