package wallet

import (
	"bytes"
	"encoding/csv"
	"encoding/hex"
	"fmt"
	"strings"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/txscript"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
)

// ECXBurnAddress receives Alphanet or Betanet coins for an ECX claim.
const ECXBurnAddress = "1BitcoinEaterAddressDontSendf59kuE"

// ECXBurnScriptHex is the output script for ECXBurnAddress.
const ECXBurnScriptHex = "76a914759d6677091e973b9e9d99f19c68fbf43e3f05f988ac"

// ECXBurnMinimumSats is the lowest burn this claim accepts, in satoshis of the burn network.
const ECXBurnMinimumSats int64 = 100_000_000_000

// ECXBurnNetwork is an eCash network that accepts the burn.
type ECXBurnNetwork struct {
	ID   string
	Name string
	// CreditDivisor is the number of burn satoshis for one ECX satoshi.
	CreditDivisor int64
}

// ECXBurnNetworkByID returns the burn network for an eCash network id. Name is "" for each other id.
func ECXBurnNetworkByID(id string) ECXBurnNetwork {
	switch id {
	case "alphanet":
		return ECXBurnNetwork{ID: "alphanet", Name: "Alphanet", CreditDivisor: 100}
	case "betanet":
		return ECXBurnNetwork{ID: "betanet", Name: "Betanet", CreditDivisor: 50}
	default:
		return ECXBurnNetwork{}
	}
}

// CreditSats returns ceil(burnSats / CreditDivisor) in ECX satoshis.
func (n ECXBurnNetwork) CreditSats(burnSats int64) int64 {
	credit := burnSats / n.CreditDivisor
	if burnSats%n.CreditDivisor > 0 {
		credit++
	}
	return credit
}

// ECXBurn is one burn of at least ECXBurnMinimumSats.
type ECXBurn struct {
	TxID string
	// Height is 0 while the burn is in the mempool.
	Height        int
	BurnSats      int64
	PayoutAddress string
	PayoutSats    int64
}

// Burn returns the burn in tx, or false when tx burns less than ECXBurnMinimumSats.
func (n ECXBurnNetwork) Burn(tx EsploraTx) (ECXBurn, bool) {
	burn := ECXBurn{TxID: tx.TxID}
	if tx.Status.Confirmed {
		burn.Height = tx.Status.BlockHeight
	}
	for _, out := range tx.Vout {
		switch {
		case out.ScriptPubKey == ECXBurnScriptHex:
			burn.BurnSats += out.Value
		case burn.PayoutAddress == "" && out.ScriptPubKeyType == "op_return":
			burn.PayoutAddress = opReturnAddress(out.ScriptPubKey)
		}
	}
	if burn.BurnSats < ECXBurnMinimumSats {
		return ECXBurn{}, false
	}
	burn.PayoutSats = n.CreditSats(burn.BurnSats)
	return burn, true
}

// opReturnAddress returns the eCash address an OP_RETURN holds, or "" for any other payload.
func opReturnAddress(scriptHex string) string {
	script, err := hex.DecodeString(scriptHex)
	if err != nil {
		return ""
	}
	pushes, err := txscript.PushedData(script)
	if err != nil {
		return ""
	}
	text := string(bytes.Join(pushes, nil))
	params := config.ChainParamsFor(config.NetworkECash)
	address, err := btcutil.DecodeAddress(text, params)
	if err != nil || !address.IsForNet(params) {
		return ""
	}
	return text
}

// ECXBurnCSV returns burns as CSV with the columns burn_amount,payout_address,payout_amount, amounts in coins.
func ECXBurnCSV(burns []ECXBurn) (string, error) {
	var out strings.Builder
	w := csv.NewWriter(&out)
	if err := w.Write([]string{"burn_amount", "payout_address", "payout_amount"}); err != nil {
		return "", err
	}
	for _, burn := range burns {
		if err := w.Write([]string{coins(burn.BurnSats), burn.PayoutAddress, coins(burn.PayoutSats)}); err != nil {
			return "", err
		}
	}
	w.Flush()
	return out.String(), w.Error()
}

func coins(sats int64) string {
	return fmt.Sprintf("%d.%08d", sats/100_000_000, sats%100_000_000)
}
