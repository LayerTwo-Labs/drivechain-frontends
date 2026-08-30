package wallet

import (
	"context"
	"fmt"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	bip32 "github.com/tyler-smith/go-bip32"
	bip39 "github.com/tyler-smith/go-bip39"
)

// EnsureCoreWalletFromMnemonic creates a Bitcoin Core wallet holding the keys a
// BIP39 mnemonic describes. A Core derived sidechain takes no seed flag, so
// this is how its slot starter reaches the node; an existing wallet is loaded
// rather than rebuilt. The descriptors import at timestamp 0: the starter is
// derived from the master seed, so a restored seed — or a wallet recreated over
// chainstate the node kept — can hold coins older than the import, which "now"
// would leave unseen.
func EnsureCoreWalletFromMnemonic(
	ctx context.Context, rpc *CoreRPCClient, log zerolog.Logger,
	walletName, mnemonic string, net *chaincfg.Params,
) error {
	if net == nil {
		return fmt.Errorf("no chain params for this network; cannot derive wallet descriptors")
	}
	if mnemonic == "" {
		return fmt.Errorf("empty mnemonic")
	}

	masterKey, err := bip32.NewMasterKey(bip39.NewSeed(mnemonic, ""))
	if err != nil {
		return fmt.Errorf("create master key: %w", err)
	}

	const kind = ScriptNativeSegwit
	purpose, ok := kind.Purpose()
	if !ok {
		return fmt.Errorf("no derivation purpose for script kind %s", kind)
	}
	path := AccountPath{Purpose: purpose, Coin: net.HDCoinType}
	account, err := deriveAccountKey(masterKey, path)
	if err != nil {
		return err
	}

	open, close, ok := coreDescriptorWrapper(kind)
	if !ok {
		return fmt.Errorf("unsupported core descriptor kind %s", kind)
	}
	origin := fmt.Sprintf("[%s/%s]%s", masterFingerprint(masterKey), path.Origin("'"), serializeKeyForNetwork(account, net))
	descriptors := []ImportDescriptor{
		{
			Desc:      mustAddChecksum(fmt.Sprintf("%s%s/0/*%s", open, origin, close)),
			Active:    true,
			Timestamp: int64(0),
			Range:     []int{0, 999},
		},
		{
			Desc:      mustAddChecksum(fmt.Sprintf("%s%s/1/*%s", open, origin, close)),
			Active:    true,
			Timestamp: int64(0),
			Internal:  true,
			Range:     []int{0, 999},
		},
	}

	return createAndImport(ctx, rpc, log, walletName, false, descriptors)
}
