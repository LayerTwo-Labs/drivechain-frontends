package wallet

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"sort"
	"strings"

	"github.com/btcsuite/btcd/btcutil"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
)

// ReadCoreCookie returns the user and password in a Core .cookie file.
func ReadCoreCookie(path string) (string, string, error) {
	raw, err := os.ReadFile(path)
	if err != nil {
		return "", "", fmt.Errorf("read the core cookie: %w", err)
	}
	user, password, ok := strings.Cut(strings.TrimSpace(string(raw)), ":")
	if !ok {
		return "", "", fmt.Errorf("the core cookie %s holds no user:password", path)
	}
	return user, password, nil
}

// CoreCall runs one Bitcoin Core RPC method.
type CoreCall func(ctx context.Context, method string, params ...any) (json.RawMessage, error)

// CoreECXBurns reads the burns at or above fromHeight from a Core node, newest first. A burn
// output is never spent, so the UTXO set holds every burn; the node needs no txindex.
func CoreECXBurns(ctx context.Context, call CoreCall, network ECXBurnNetwork, fromHeight int) ([]ECXBurn, error) {
	if err := checkCoreNetwork(ctx, call, network.ID); err != nil {
		return nil, err
	}
	raw, err := call(ctx, "scantxoutset", "start", []map[string]string{{"desc": "raw(" + ECXBurnScriptHex + ")"}})
	if err != nil {
		return nil, fmt.Errorf("scan the burn address: %w", err)
	}
	var scan struct {
		Success  bool `json:"success"`
		Unspents []struct {
			TxID   string `json:"txid"`
			Height int    `json:"height"`
		} `json:"unspents"`
	}
	if err := json.Unmarshal(raw, &scan); err != nil {
		return nil, fmt.Errorf("decode the burn address scan: %w", err)
	}
	if !scan.Success {
		return nil, fmt.Errorf("the burn address scan did not finish")
	}

	heights := map[string]int{}
	for _, u := range scan.Unspents {
		if u.Height >= fromHeight {
			heights[u.TxID] = u.Height
		}
	}

	var burns []ECXBurn
	for txid, height := range heights {
		tx, err := coreBurnTx(ctx, call, txid, height)
		if err != nil {
			return nil, err
		}
		if burn, ok := network.Burn(tx); ok {
			burns = append(burns, burn)
		}
	}
	sort.Slice(burns, func(i, j int) bool {
		if burns[i].Height != burns[j].Height {
			return burns[i].Height > burns[j].Height
		}
		return burns[i].TxID < burns[j].TxID
	})
	return burns, nil
}

// checkCoreNetwork refuses a node whose user-agent names another eCash network,
// because the burns of one chain must never take the credit rate of another.
func checkCoreNetwork(ctx context.Context, call CoreCall, want string) error {
	raw, err := call(ctx, "getnetworkinfo")
	if err != nil {
		return fmt.Errorf("read the node network: %w", err)
	}
	var info struct {
		Subversion string `json:"subversion"`
	}
	if err := json.Unmarshal(raw, &info); err != nil {
		return fmt.Errorf("decode the node network: %w", err)
	}
	got := coreECashID(info.Subversion)
	if got != want {
		if got == "" {
			got = "no eCash network"
		}
		return fmt.Errorf("the node at that URL runs %s, not %s (user agent %s)", got, want, info.Subversion)
	}
	return nil
}

// coreECashID returns the eCash network id in a user agent such as
// "/eCash Satoshi:31.1.0(ecash-alphanet; BitWindow-0.2)/", empty when it names none.
func coreECashID(subversion string) string {
	_, comments, ok := strings.Cut(subversion, "(")
	if !ok {
		return ""
	}
	comments, _, _ = strings.Cut(comments, ")")
	for _, comment := range strings.Split(comments, ";") {
		if id := config.ECashIDFromUAComment(strings.TrimSpace(comment)); id != "" {
			return id
		}
	}
	return ""
}

// coreBurnTx reads one confirmed transaction in the shape Burn reads.
func coreBurnTx(ctx context.Context, call CoreCall, txid string, height int) (EsploraTx, error) {
	raw, err := call(ctx, "getblockhash", height)
	if err != nil {
		return EsploraTx{}, fmt.Errorf("read the hash of block %d: %w", height, err)
	}
	var blockHash string
	if err := json.Unmarshal(raw, &blockHash); err != nil {
		return EsploraTx{}, fmt.Errorf("decode the hash of block %d: %w", height, err)
	}
	raw, err = call(ctx, "getrawtransaction", txid, true, blockHash)
	if err != nil {
		return EsploraTx{}, fmt.Errorf("read burn %s: %w", txid, err)
	}
	var tx struct {
		Vout []struct {
			Value        float64 `json:"value"`
			ScriptPubKey struct {
				Hex  string `json:"hex"`
				Type string `json:"type"`
			} `json:"scriptPubKey"`
		} `json:"vout"`
	}
	if err := json.Unmarshal(raw, &tx); err != nil {
		return EsploraTx{}, fmt.Errorf("decode burn %s: %w", txid, err)
	}

	out := EsploraTx{TxID: txid, Status: EsploraStatus{Confirmed: true, BlockHeight: height, BlockHash: blockHash}}
	for _, v := range tx.Vout {
		sats, err := btcutil.NewAmount(v.Value)
		if err != nil {
			return EsploraTx{}, fmt.Errorf("read an output value of burn %s: %w", txid, err)
		}
		kind := v.ScriptPubKey.Type
		if kind == "nulldata" {
			kind = "op_return"
		}
		out.Vout = append(out.Vout, EsploraVout{ScriptPubKey: v.ScriptPubKey.Hex, ScriptPubKeyType: kind, Value: int64(sats)})
	}
	return out, nil
}
