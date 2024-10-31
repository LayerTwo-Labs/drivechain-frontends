package drivechain

import (
	"github.com/btcsuite/btcd/txscript"
)

// DrivechainSidechainDeposit creates a new script used to deposit funds to a
// sidechain, using OP_NOP5 (OP_DRIVECHAIN) to specify which sidechain the UTXO
// is for.
// This implements BIP300-M5: https://en.bitcoin.it/wiki/BIP_0300
func ScriptSidechainDeposit(slot uint8) ([]byte, error) {
	const OP_DRIVECHAIN = txscript.OP_NOP5
	return txscript.NewScriptBuilder().AddOp(OP_DRIVECHAIN).AddData([]byte{slot}).Script()
}

// DrivechainDepositAddress creates a new script to deposit funds to a
// specific address on a sidechain. It's used in the same transaction as
// ScriptSidechainDeposit.
// This script tags along with BIP300-M5: https://en.bitcoin.it/wiki/BIP_0300
func ScriptDepositAddress(depositAddress string) ([]byte, error) {

	return txscript.NewScriptBuilder().AddOp(txscript.OP_RETURN).AddData([]byte(depositAddress)).Script()
}
