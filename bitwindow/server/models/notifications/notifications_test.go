package notifications_test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/notifications"
)

func TestNotifiedEvents(t *testing.T) {
	db := database.Test(t)

	t.Run("unknown event is not notified", func(t *testing.T) {
		got, err := notifications.HasBeenNotified(t.Context(), db, notifications.EventTypeTransactionConf, "tx-1")
		require.NoError(t, err)
		assert.False(t, got)
	})

	t.Run("marked event is notified for its own type only", func(t *testing.T) {
		require.NoError(t, notifications.MarkNotified(t.Context(), db, notifications.EventTypeTransactionConf, "tx-2"))

		got, err := notifications.HasBeenNotified(t.Context(), db, notifications.EventTypeTransactionConf, "tx-2")
		require.NoError(t, err)
		assert.True(t, got)

		got, err = notifications.HasBeenNotified(t.Context(), db, notifications.EventTypeDepositDropped, "tx-2")
		require.NoError(t, err)
		assert.False(t, got)
	})
}
