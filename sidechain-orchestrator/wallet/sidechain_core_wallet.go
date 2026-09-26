package wallet

import (
	"context"
	"encoding/hex"
	"fmt"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
)

// EnsureCoreWalletFromMnemonic creates a Bitcoin Core wallet holding the keys a
// BIP39 mnemonic describes. A Core derived sidechain takes no seed flag, so
// this is how its slot starter reaches the node; an existing wallet is loaded
// rather than rebuilt.
func EnsureCoreWalletFromMnemonic(
	ctx context.Context, rpc *CoreRPCClient, log zerolog.Logger,
	walletName, mnemonic string, net *chaincfg.Params,
) error {
	if mnemonic == "" {
		return fmt.Errorf("empty mnemonic")
	}
	starter := &WalletData{Master: MasterWallet{SeedHex: hex.EncodeToString(MnemonicToSeed(mnemonic, ""))}}
	d, err := DescriptorFor(starter, ScriptNativeSegwit, net)
	if err != nil {
		return err
	}
	imports, err := d.coreImports(net, "now")
	if err != nil {
		return err
	}
	return createAndImport(ctx, rpc, log, walletName, false, imports)
}
