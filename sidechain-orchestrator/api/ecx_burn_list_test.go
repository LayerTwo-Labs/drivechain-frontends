package api

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"

	"connectrpc.com/connect/v2"
	"github.com/btcsuite/btcd/txscript"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

func burnPayout(t *testing.T, address string) wallet.EsploraVout {
	script, err := txscript.NewScriptBuilder().AddOp(txscript.OP_RETURN).AddData([]byte(address)).Script()
	require.NoError(t, err)
	return wallet.EsploraVout{ScriptPubKey: hex.EncodeToString(script), ScriptPubKeyType: "op_return"}
}

func burnOutput(sats int64) wallet.EsploraVout {
	return wallet.EsploraVout{ScriptPubKey: wallet.ECXBurnScriptHex, ScriptPubKeyType: "p2pkh", Value: sats}
}

func TestListECXBurns(t *testing.T) {
	history := []wallet.EsploraTx{
		{TxID: "mempool", Vout: []wallet.EsploraVout{burnOutput(1_388_900_019_620), burnPayout(t, "bc1q09fs5766lx954ezwr2fd0xhg2605fcatjzlnvg")}},
		{TxID: "second", Status: wallet.EsploraStatus{Confirmed: true, BlockHeight: 974030}, Vout: []wallet.EsploraVout{burnPayout(t, "bc1qh4lnn2qwm7977mw6yx9g4r24t2ws7rxae8r6rz"), burnOutput(111_100_000_000)}},
		{TxID: "replay", Status: wallet.EsploraStatus{Confirmed: true, BlockHeight: 973974}, Vout: []wallet.EsploraVout{burnOutput(546), burnPayout(t, "omni")}},
		{TxID: "first", Status: wallet.EsploraStatus{Confirmed: true, BlockHeight: 971002}, Vout: []wallet.EsploraVout{burnOutput(280_800_010_000), burnPayout(t, "bc1qh4lnn2qwm7977mw6yx9g4r24t2ws7rxae8r6rz")}},
		{TxID: "before the fork", Status: wallet.EsploraStatus{Confirmed: true, BlockHeight: 967679}, Vout: []wallet.EsploraVout{burnOutput(200_000_000_000), burnPayout(t, "old")}},
	}
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/address/"+wallet.ECXBurnAddress+"/txs" {
			http.Error(w, "unexpected page: "+r.URL.Path, http.StatusNotFound)
			return
		}
		_ = json.NewEncoder(w).Encode(history)
	}))
	defer srv.Close()

	resp, err := listECXBurns(context.Background(), wallet.NewEsploraClient([]string{srv.URL}, zerolog.Nop()), wallet.ECXBurnNetworkByID("betanet"), 967680)
	require.NoError(t, err)
	require.Equal(t, []*pb.EcxBurn{
		{Txid: "mempool", BurnSats: 1_388_900_019_620, PayoutAddress: "bc1q09fs5766lx954ezwr2fd0xhg2605fcatjzlnvg", PayoutSats: 27_778_000_393},
		{Txid: "second", Height: 974030, BurnSats: 111_100_000_000, PayoutAddress: "bc1qh4lnn2qwm7977mw6yx9g4r24t2ws7rxae8r6rz", PayoutSats: 2_222_000_000},
		{Txid: "first", Height: 971002, BurnSats: 280_800_010_000, PayoutAddress: "bc1qh4lnn2qwm7977mw6yx9g4r24t2ws7rxae8r6rz", PayoutSats: 5_616_000_200},
	}, resp.Burns)
	require.EqualValues(t, 1_780_800_029_620, resp.TotalBurnSats)
	require.EqualValues(t, 35_616_000_593, resp.TotalPayoutSats)
	require.EqualValues(t, 2, resp.PayoutAddressCount)
	require.Equal(t, "burn_amount,payout_address,payout_amount\n"+
		"13889.00019620,bc1q09fs5766lx954ezwr2fd0xhg2605fcatjzlnvg,277.78000393\n"+
		"1111.00000000,bc1qh4lnn2qwm7977mw6yx9g4r24t2ws7rxae8r6rz,22.22000000\n"+
		"2808.00010000,bc1qh4lnn2qwm7977mw6yx9g4r24t2ws7rxae8r6rz,56.16000200\n", resp.Csv)
}

func TestListECXBurnsReportsAnUnreachableIndex(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		http.Error(w, "down", http.StatusBadRequest)
	}))
	defer srv.Close()

	_, err := listECXBurns(context.Background(), wallet.NewEsploraClient([]string{srv.URL}, zerolog.Nop()), wallet.ECXBurnNetworkByID("betanet"), 967680)
	require.ErrorContains(t, err, "read the burn address history")
}

func TestListEcxBurnsReadsANode(t *testing.T) {
	payout := burnPayout(t, "bc1qgkavkjygu5d952s7kspkyp3q2vrgg99rsuz2z5")
	var gotUser, gotPassword string
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		gotUser, gotPassword, _ = r.BasicAuth()
		var req struct {
			Method string `json:"method"`
		}
		require.NoError(t, json.NewDecoder(r.Body).Decode(&req))
		var result any
		switch req.Method {
		case "getnetworkinfo":
			result = map[string]any{"subversion": "/eCash Satoshi:31.1.0(ecash-alphanet; BitWindow-0.2)/"}
		case "scantxoutset":
			result = map[string]any{"success": true, "unspents": []map[string]any{{"txid": "a", "height": 963700}}}
		case "getblockhash":
			result = "hash"
		case "getrawtransaction":
			result = map[string]any{"vout": []map[string]any{
				{"value": 3000, "scriptPubKey": map[string]any{"hex": wallet.ECXBurnScriptHex, "type": "pubkeyhash"}},
				{"value": 0, "scriptPubKey": map[string]any{"hex": payout.ScriptPubKey, "type": "nulldata"}},
			}}
		}
		require.NoError(t, json.NewEncoder(w).Encode(map[string]any{"result": result, "error": nil}))
	}))
	defer srv.Close()
	cookie := filepath.Join(t.TempDir(), ".cookie")
	require.NoError(t, os.WriteFile(cookie, []byte("__cookie__:secret"), 0o600))

	resp, err := (&WalletHandler{}).ListEcxBurns(context.Background(), &pb.ListEcxBurnsRequest{
		NetworkId: "alphanet", CoreUrl: srv.URL, CoreCookiePath: cookie,
	})
	require.NoError(t, err)
	require.Len(t, resp.Burns, 1)
	require.EqualValues(t, 300_000_000_000, resp.Burns[0].BurnSats)
	require.EqualValues(t, 3_000_000_000, resp.Burns[0].PayoutSats, "alphanet credits one ECX for each 100 coins")
	require.Equal(t, []string{"__cookie__", "secret"}, []string{gotUser, gotPassword})
}

func TestListEcxBurnsRefusesANodeOfAnotherNetwork(t *testing.T) {
	_, err := (&WalletHandler{}).ListEcxBurns(context.Background(), &pb.ListEcxBurnsRequest{
		NetworkId: "ecash", CoreUrl: "http://127.0.0.1:1",
	})
	require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
}
