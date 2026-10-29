package commands

import (
	"bytes"
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"strings"
	"testing"

	"github.com/btcsuite/btcd/txscript"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

func TestRunECashBurnsWritesTheAlphanetCSV(t *testing.T) {
	payout, err := txscript.NewScriptBuilder().AddOp(txscript.OP_RETURN).
		AddData([]byte("bc1qgkavkjygu5d952s7kspkyp3q2vrgg99rsuz2z5")).Script()
	require.NoError(t, err)
	call := func(_ context.Context, method string, params ...any) (json.RawMessage, error) {
		switch method {
		case "getnetworkinfo":
			return json.RawMessage(`{"subversion":"/eCash Satoshi:31.1.0(ecash-alphanet; BitWindow-0.2)/"}`), nil
		case "scantxoutset":
			return json.RawMessage(`{"success":true,"unspents":[{"txid":"old","height":1},{"txid":"a","height":963700}]}`), nil
		case "getblockhash":
			return json.Marshal(fmt.Sprint(params[0]))
		case "getrawtransaction":
			return json.RawMessage(`{"vout":[{"value":2000,"scriptPubKey":{"hex":"` + wallet.ECXBurnScriptHex +
				`","type":"pubkeyhash"}},{"value":0,"scriptPubKey":{"hex":"` + hex.EncodeToString(payout) + `","type":"nulldata"}}]}`), nil
		}
		return nil, fmt.Errorf("unexpected method %s", method)
	}

	var out bytes.Buffer
	require.NoError(t, runECashBurns(context.Background(), &out, call, "alphanet"))

	lines := strings.Split(strings.TrimSpace(out.String()), "\n")
	require.Len(t, lines, 2, "a header and the one burn after the fork")
	assert.Equal(t, "2000.00000000,bc1qgkavkjygu5d952s7kspkyp3q2vrgg99rsuz2z5,20.00000000", lines[1],
		"alphanet credits one ECX for each 100 coins")
}

func TestRunECashBurnsRefusesAnotherNetwork(t *testing.T) {
	err := runECashBurns(context.Background(), &bytes.Buffer{}, nil, "ecash")
	require.ErrorContains(t, err, "no burn network")
}
