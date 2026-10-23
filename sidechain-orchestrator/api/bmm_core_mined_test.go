package api

import (
	"context"
	"encoding/json"
	"errors"
	"testing"

	"github.com/stretchr/testify/require"
)

func TestCoreMinedReadsTransactionConfirmations(t *testing.T) {
	for _, test := range []struct {
		name  string
		body  string
		mined bool
	}{
		{name: "mined", body: `{"confirmations":2}`, mined: true},
		{name: "mempool", body: `{}`, mined: false},
		{name: "unconfirmed", body: `{"confirmations":0}`, mined: false},
		{name: "conflict", body: `{"confirmations":-1}`, mined: false},
	} {
		t.Run(test.name, func(t *testing.T) {
			h, _ := newBMMModeHandler(t)
			require.True(t, h.ReadsMempool())
			var calls int
			h.SetCoreCaller(func(_ context.Context, method, params, wallet string) (json.RawMessage, error) {
				calls++
				require.Equal(t, "getrawtransaction", method)
				require.JSONEq(t, `["bid",true]`, params)
				require.Empty(t, wallet)
				return json.RawMessage(test.body), nil
			})

			mined, err := h.Mined(context.Background(), "bid")

			require.NoError(t, err)
			require.Equal(t, test.mined, mined)
			require.Equal(t, 1, calls)
		})
	}
}

func TestCoreMinedReturnsReadAndDecodeErrors(t *testing.T) {
	for _, name := range []string{"read", "decode"} {
		t.Run(name, func(t *testing.T) {
			h, _ := newBMMModeHandler(t)
			readError := errors.New("the transaction is unavailable")
			h.SetCoreCaller(func(_ context.Context, _, _, _ string) (json.RawMessage, error) {
				if name == "read" {
					return nil, readError
				}
				return json.RawMessage(`{"confirmations":"invalid"}`), nil
			})

			mined, err := h.Mined(context.Background(), "bid")

			require.False(t, mined)
			if name == "read" {
				require.ErrorIs(t, err, readError)
			} else {
				var decodeError *json.UnmarshalTypeError
				require.ErrorAs(t, err, &decodeError)
			}
		})
	}
}
