package utxometadata_test

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/utxometadata"
)

func TestGet(t *testing.T) {
	db := database.Test(t)
	frozen := true
	labelA, labelB := "a", "b"
	require.NoError(t, utxometadata.Set(t.Context(), db, "tx:0", &frozen, &labelA))
	require.NoError(t, utxometadata.Set(t.Context(), db, "tx:1", nil, &labelB))

	t.Run("all entries", func(t *testing.T) {
		got, err := utxometadata.Get(t.Context(), db, nil)
		require.NoError(t, err)
		require.Len(t, got, 2)
		assert.True(t, got["tx:0"].IsFrozen)
		assert.Equal(t, "a", got["tx:0"].Label)
		assert.False(t, got["tx:1"].IsFrozen)
		assert.Equal(t, "b", got["tx:1"].Label)
	})

	t.Run("named entries skip unknown outpoints", func(t *testing.T) {
		got, err := utxometadata.Get(t.Context(), db, []string{"tx:1", "tx:9"})
		require.NoError(t, err)
		require.Len(t, got, 1)
		assert.Equal(t, "b", got["tx:1"].Label)
	})
}

func TestSet(t *testing.T) {
	db := database.Test(t)
	frozen, thawed := true, false
	label, relabel := "cold", "hot"

	t.Run("new entry takes defaults for nil fields", func(t *testing.T) {
		require.NoError(t, utxometadata.Set(t.Context(), db, "set:0", nil, &label))

		got, err := utxometadata.Get(t.Context(), db, []string{"set:0"})
		require.NoError(t, err)
		assert.False(t, got["set:0"].IsFrozen)
		assert.Equal(t, "cold", got["set:0"].Label)
	})

	t.Run("partial update keeps the other field", func(t *testing.T) {
		require.NoError(t, utxometadata.Set(t.Context(), db, "set:0", &frozen, nil))

		got, err := utxometadata.Get(t.Context(), db, []string{"set:0"})
		require.NoError(t, err)
		assert.True(t, got["set:0"].IsFrozen)
		assert.Equal(t, "cold", got["set:0"].Label)

		require.NoError(t, utxometadata.Set(t.Context(), db, "set:0", nil, &relabel))

		got, err = utxometadata.Get(t.Context(), db, []string{"set:0"})
		require.NoError(t, err)
		assert.True(t, got["set:0"].IsFrozen)
		assert.Equal(t, "hot", got["set:0"].Label)
	})

	t.Run("frozen outpoints follow the flag", func(t *testing.T) {
		require.NoError(t, utxometadata.Set(t.Context(), db, "set:1", &frozen, nil))

		got, err := utxometadata.FrozenOutpoints(t.Context(), db)
		require.NoError(t, err)
		assert.ElementsMatch(t, []string{"set:0", "set:1"}, got)

		require.NoError(t, utxometadata.Set(t.Context(), db, "set:0", &thawed, nil))

		got, err = utxometadata.FrozenOutpoints(t.Context(), db)
		require.NoError(t, err)
		assert.Equal(t, []string{"set:1"}, got)
	})
}
