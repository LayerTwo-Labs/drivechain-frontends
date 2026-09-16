package api

import (
	"context"
	"encoding/hex"
	"fmt"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

const ecxBurnWarning = "This transaction burns Alphanet coins for a claim of real ECX."

func (h *WalletHandler) transactionWarning(outputs []*pb.TransactionOutput) string {
	if config.NetworkFromString(h.svc.Network()) != config.NetworkECash || config.ECashNetworkID() != "alphanet" {
		return ""
	}
	return burnTransactionWarning(outputs)
}

func burnTransactionWarning(outputs []*pb.TransactionOutput) string {
	var hasBurn, hasAddress bool
	for _, output := range outputs {
		script, err := hex.DecodeString(output.ScriptPubkeyHex)
		if err != nil {
			return ""
		}
		if output.ValueSats > 0 && hex.EncodeToString(script) == wallet.ECXBurnScriptHex {
			hasBurn = true
		}
		if output.ValueSats == 0 && hasClaimAddress(script) {
			hasAddress = true
		}
	}
	if hasBurn && hasAddress {
		return ecxBurnWarning
	}
	return ""
}

func hasClaimAddress(script []byte) bool {
	tokens := txscript.MakeScriptTokenizer(0, script)
	if !tokens.Next() || tokens.Opcode() != txscript.OP_RETURN || !tokens.Next() {
		return false
	}
	data := tokens.Data()
	if len(data) == 0 || tokens.Next() || tokens.Err() != nil {
		return false
	}
	address, err := btcutil.DecodeAddress(string(data), &chaincfg.MainNetParams)
	if err != nil {
		return false
	}
	_, publicKey := address.(*btcutil.AddressPubKey)
	return !publicKey && address.IsForNet(&chaincfg.MainNetParams)
}

func (h *WalletHandler) setTransactionWarnings(ctx context.Context, walletID string, entries []*pb.TransactionEntry) error {
	if config.NetworkFromString(h.svc.Network()) != config.NetworkECash || config.ECashNetworkID() != "alphanet" {
		return nil
	}
	warnings := make(map[string]string)
	for _, entry := range entries {
		if _, seen := warnings[entry.Txid]; seen {
			continue
		}
		if message, found := h.ecxBurnWarnings.Load(entry.Txid); found {
			warnings[entry.Txid] = message.(string)
			continue
		}
		tx, err := h.engine.Backend().GetWalletTransaction(ctx, walletID, entry.Txid)
		if err != nil {
			return fmt.Errorf("read transaction %s for its warning: %w", entry.Txid, err)
		}
		decoded, err := wallet.DecodeTransaction(tx.Hex, h.engine.Network())
		if err != nil {
			return fmt.Errorf("decode transaction %s for its warning: %w", entry.Txid, err)
		}
		if decoded.Form != wallet.DecodedFormRawTx {
			return fmt.Errorf("transaction %s has no raw transaction data", entry.Txid)
		}
		warnings[entry.Txid] = burnTransactionWarning(decodedToResponse(decoded).Outputs)
		h.ecxBurnWarnings.Store(entry.Txid, warnings[entry.Txid])
	}
	for _, entry := range entries {
		entry.WarningMessage = warnings[entry.Txid]
	}
	return nil
}
