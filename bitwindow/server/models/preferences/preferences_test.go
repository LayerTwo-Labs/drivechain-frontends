package preferences_test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/preferences"
)

func TestPreferences(t *testing.T) {
	db := database.Test(t)

	t.Run("missing key reads empty", func(t *testing.T) {
		got, err := preferences.Get(t.Context(), db, preferences.KeyMempoolWatchEnabled)
		require.NoError(t, err)
		assert.Empty(t, got)
	})

	t.Run("set then overwrite", func(t *testing.T) {
		require.NoError(t, preferences.Set(t.Context(), db, preferences.KeyCoinSelectionStrategy, "largest"))
		require.NoError(t, preferences.Set(t.Context(), db, preferences.KeyCoinSelectionStrategy, "smallest"))

		got, err := preferences.Get(t.Context(), db, preferences.KeyCoinSelectionStrategy)
		require.NoError(t, err)
		assert.Equal(t, "smallest", got)
	})
}
