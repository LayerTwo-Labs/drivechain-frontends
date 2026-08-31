package thunderwallet

import (
	"fmt"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
)

// MainScriptPubKey reads the mainchain script a payout goes to.
//
// A withdrawal signature covers this script, so it must match what the
// mainchain would build for the address. Light mode reads it here, because it
// runs no bitcoind to ask.
func MainScriptPubKey(address string, params *chaincfg.Params) ([]byte, error) {
	if params == nil {
		return nil, fmt.Errorf("the network is not known")
	}
	decoded, err := btcutil.DecodeAddress(address, params)
	if err != nil {
		return nil, fmt.Errorf("read the mainchain address %q: %w", address, err)
	}
	if !decoded.IsForNet(params) {
		return nil, fmt.Errorf("the address %q belongs to another network", address)
	}
	script, err := txscript.PayToAddrScript(decoded)
	if err != nil {
		return nil, fmt.Errorf("build the script for %q: %w", address, err)
	}
	return script, nil
}
