package wallet

import (
	"context"
	"encoding/hex"
	"fmt"
	"slices"

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
	imports, err := d.coreImports(net, int64(0))
	if err != nil {
		return err
	}
	if err := createAndImport(ctx, rpc, log, walletName, false, true, imports); err != nil {
		return err
	}

	// A starter imported at "now" misses every coin sent to it before, so it
	// rescans from genesis one time. Core stores a genesis import as birthday 1.
	stamps, err := rpc.ActiveDescriptorTimestamps(ctx, walletName)
	if err != nil {
		return fmt.Errorf("list descriptors: %w", err)
	}
	if !slices.ContainsFunc(stamps, func(ts int64) bool { return ts > 1 }) {
		return nil
	}
	log.Info().Str("wallet", walletName).Msg("rescanning the sidechain starter from genesis")
	results, err := rpc.ImportDescriptorsAndWait(ctx, walletName, imports)
	if err != nil {
		return fmt.Errorf("import descriptors: %w", err)
	}
	return importResultsErr(results)
}
