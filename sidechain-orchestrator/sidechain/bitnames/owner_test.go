package bitnames

import (
	"context"
	"encoding/json"
	"testing"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/bitnames/v1"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// utxoNode answers list_utxos with the shape the live node returns.
type utxoNode struct{ utxos string }

func (u utxoNode) Call(_ context.Context, method string, _ any, result any) error {
	if method != "list_utxos" {
		return nil
	}
	return json.Unmarshal([]byte(u.utxos), result)
}

// This is the shape the live alphanet node returned for list_utxos.
const liveUTXOs = `[
 {"outpoint":{"Regular":{"txid":"aa","vout":0}},
  "output":{"address":"3Cdqkd4J2uqAN4HLKuAY8en68tzZ",
            "content":{"BitNameReservation":["b85229ad"]},"memo":""}},
 {"outpoint":{"Regular":{"txid":"bb","vout":0}},
  "output":{"address":"3U7uB5WkWrWxsdtqdrbgsZ6Y4FXt",
            "content":{"BitName":"d228dfbdab4f8a9eb5eb4962ab38f4364b0b8b3035ce41eafd91ff672a6c6076"},"memo":""}},
 {"outpoint":{"Regular":{"txid":"cc","vout":0}},
  "output":{"address":"3yGh6d2CpN4yHjRMsUDLpEN38Uiq",
            "content":{"BitName":"18c785f51acec3d37ff6cd5ebcfa816d45c33fb6584a5a829c402d18b48cab7e"},"memo":""}},
 {"outpoint":{"Coinbase":{"merkle_root":"dd","vout":0}},
  "output":{"address":"8G8dvEzV7oFUNCLbVBXLbW1qQ43","content":{"BitcoinSats":100},"memo":""}}
]`

// A message pays the holder of the BitName. bitname_data does not carry the
// address, so the owner comes from the utxo that holds the name.
func TestBitNameOwnerFindsTheHolder(t *testing.T) {
	node := utxoNode{utxos: liveUTXOs}

	ecash, err := BitNameOwner(context.Background(), node,
		"d228dfbdab4f8a9eb5eb4962ab38f4364b0b8b3035ce41eafd91ff672a6c6076")
	require.NoError(t, err)
	assert.Equal(t, "3U7uB5WkWrWxsdtqdrbgsZ6Y4FXt", ecash)

	other, err := BitNameOwner(context.Background(), node,
		"18c785f51acec3d37ff6cd5ebcfa816d45c33fb6584a5a829c402d18b48cab7e")
	require.NoError(t, err)
	assert.Equal(t, "3yGh6d2CpN4yHjRMsUDLpEN38Uiq", other)
}

// A reservation is not a registered name, so it holds no owner to pay.
func TestBitNameOwnerSkipsAReservation(t *testing.T) {
	_, err := BitNameOwner(context.Background(), utxoNode{utxos: liveUTXOs}, "b85229ad")
	require.Error(t, err)
	assert.Contains(t, err.Error(), "no utxo holds the bitname")
}

func TestBitNameOwnerRefusesAnEmptyName(t *testing.T) {
	_, err := BitNameOwner(context.Background(), utxoNode{utxos: liveUTXOs}, "")
	require.Error(t, err)
	assert.Contains(t, err.Error(), "empty")
}

func TestBitNameOwnerReportsAnUnknownName(t *testing.T) {
	_, err := BitNameOwner(context.Background(), utxoNode{utxos: liveUTXOs}, "ffff")
	require.Error(t, err)
	assert.Contains(t, err.Error(), "ffff")
}

func TestGetBitNameOwnerDistinguishesLookupErrors(t *testing.T) {
	for _, test := range []struct {
		name  string
		utxos string
		code  connect.Code
	}{
		{name: "unknown name", utxos: `[]`, code: connect.CodeNotFound},
		{name: "invalid node response", utxos: `{}`, code: connect.CodeUnknown},
	} {
		t.Run(test.name, func(t *testing.T) {
			proxy, _ := sendMethodNode(t, map[string]string{"list_utxos": test.utxos})
			_, err := NewHandler(proxy).GetBitNameOwner(context.Background(), connect.NewRequest(
				&pb.GetBitNameOwnerRequest{Bitname: "unknown"},
			))
			require.Error(t, err)
			assert.Equal(t, test.code, connect.CodeOf(err))
		})
	}
}
