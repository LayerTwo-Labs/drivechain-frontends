package engines

import (
	"slices"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/coinbases"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
)

// coinbaseFacts is what the block's coinbase shows about who mined it.
func coinbaseFacts(height uint32, block *wire.MsgBlock, params *chaincfg.Params) coinbases.Coinbase {
	coinbase := block.Transactions[0]
	facts := coinbases.Coinbase{
		Height:    height,
		Hash:      block.Header.BlockHash().String(),
		BlockTime: block.Header.Timestamp,
		Bits:      block.Header.Bits,
		TxCount:   uint32(len(block.Transactions)),
		Script:    coinbase.TxIn[0].SignatureScript,
	}
	if params == nil {
		return facts
	}
	for _, out := range coinbase.TxOut {
		_, addrs, _, err := txscript.ExtractPkScriptAddrs(out.PkScript, params)
		if err != nil {
			continue
		}
		for _, addr := range addrs {
			if encoded := addr.EncodeAddress(); !slices.Contains(facts.Addresses, encoded) {
				facts.Addresses = append(facts.Addresses, encoded)
			}
		}
	}
	return facts
}
