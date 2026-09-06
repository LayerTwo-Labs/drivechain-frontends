package thunderwallet

import (
	"encoding/json"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// A light wallet lists the coins a block carries beside the ones on their way.
// Without the flag the view reads a payment on its way as money already mined.
func TestMarshalUTXOsMarksThePendingCoins(t *testing.T) {
	coin := func(vout uint32, sats uint64) Coin {
		return Coin{
			OutPoint:  OutPoint{Kind: KindRegular, Vout: vout},
			ValueSats: sats,
		}
	}

	raw, err := MarshalUTXOsWithPending([]Coin{coin(0, 2000)}, []Coin{coin(1, 10000)})
	require.NoError(t, err)

	var rows []struct {
		Confirmed *bool `json:"confirmed"`
		Output    struct {
			Content struct {
				Value uint64 `json:"Value"`
			} `json:"content"`
		} `json:"output"`
	}
	require.NoError(t, json.Unmarshal(raw, &rows))
	require.Len(t, rows, 2)

	require.NotNil(t, rows[0].Confirmed)
	assert.True(t, *rows[0].Confirmed)
	assert.Equal(t, uint64(2000), rows[0].Output.Content.Value)

	require.NotNil(t, rows[1].Confirmed)
	assert.False(t, *rows[1].Confirmed, "a coin no block carries reads as unconfirmed")
	assert.Equal(t, uint64(10000), rows[1].Output.Content.Value)
}

// The older name keeps its meaning: every coin it writes is mined.
func TestMarshalUTXOsCallsEveryCoinConfirmed(t *testing.T) {
	raw, err := MarshalUTXOs([]Coin{{OutPoint: OutPoint{Kind: KindRegular}}})
	require.NoError(t, err)

	var rows []map[string]any
	require.NoError(t, json.Unmarshal(raw, &rows))
	require.Len(t, rows, 1)
	assert.Equal(t, true, rows[0]["confirmed"])
}
