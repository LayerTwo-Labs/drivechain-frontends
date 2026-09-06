package wallet

import (
	"context"
	"fmt"
	"strings"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	bip32 "github.com/tyler-smith/go-bip32"
	bip39 "github.com/tyler-smith/go-bip39"
)

// EnsureCoreWalletFromMnemonic creates a Bitcoin Core wallet holding the keys a
// BIP39 mnemonic describes. A Core derived sidechain takes no seed flag, so
// this is how its slot starter reaches the node; an existing wallet is loaded
// rather than rebuilt.
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
			Timestamp: "now",
			Range:     []int{0, 999},
		},
		{
			Desc:      mustAddChecksum(fmt.Sprintf("%s%s/1/*%s", open, origin, close)),
			Active:    true,
			Timestamp: "now",
			Internal:  true,
			Range:     []int{0, 999},
		},
	}

	return createAndImport(ctx, rpc, log, walletName, false, descriptors)
}

// EnsureLegacyCoreWalletFromMnemonic provisions a pre-descriptor Core fork's wallet from a BIP39
// mnemonic. Such a fork (FreeBank) has no createwallet/importdescriptors — it auto-creates its own
// HD wallet at startup — so instead we re-seed that wallet with sethdseed. The seed is a
// deterministic 32-byte key derived from the mnemonic, so the fork re-derives the same addresses
// whenever it is set again; that is what folds the wallet into the unified one-mnemonic backup, the
// way the descriptor chains are. The wallet is the node's single legacy wallet at the root endpoint.
func EnsureLegacyCoreWalletFromMnemonic(
	ctx context.Context, rpc *CoreRPCClient, log zerolog.Logger,
	mnemonic string, net *chaincfg.Params,
) error {
	if net == nil {
		return fmt.Errorf("no chain params for this network; cannot derive a legacy wallet seed")
	}
	if mnemonic == "" {
		return fmt.Errorf("empty mnemonic")
	}

	wif, err := deriveLegacySeedWIF(mnemonic, net)
	if err != nil {
		return err
	}

	// sethdseed(newkeypool=true, seed=wif): adopt the seed and regenerate the keypool from it.
	if _, err := rpc.call(ctx, "", "sethdseed", true, wif); err != nil {
		// Re-running provisioning re-sends the same seed; the fork already holds it as its HD master.
		if strings.Contains(err.Error(), "Already have this key") {
			log.Info().Msg("legacy wallet: HD seed already set from the mnemonic")
			return nil
		}
		return fmt.Errorf("sethdseed: %w", err)
	}
	log.Info().Msg("legacy wallet: HD seed set from the mnemonic (wallet joins the unified backup)")
	return nil
}

// deriveLegacySeedWIF turns a BIP39 mnemonic into the WIF a pre-descriptor Core fork's sethdseed
// accepts as its HD seed. It derives a fixed BIP44 (legacy) account key and WIF-encodes its 32-byte
// private key for the fork's network. The path only has to be stable: the fork re-derives its own
// m/0'/0'/i tree from whatever seed it is given, so the resulting addresses depend on this key alone,
// which is what makes the wallet reproducible from the mnemonic.
func deriveLegacySeedWIF(mnemonic string, net *chaincfg.Params) (string, error) {
	masterKey, err := bip32.NewMasterKey(bip39.NewSeed(mnemonic, ""))
	if err != nil {
		return "", fmt.Errorf("create master key: %w", err)
	}
	account, err := deriveAccountKey(masterKey, AccountPath{Purpose: 44, Coin: net.HDCoinType})
	if err != nil {
		return "", fmt.Errorf("derive legacy account key: %w", err)
	}
	if len(account.Key) != 32 {
		return "", fmt.Errorf("unexpected account key length %d (want 32)", len(account.Key))
	}
	// A pre-segwit Core fork's WIF prefix matches Bitcoin's for the same network (mainnet 0x80,
	// test/regtest 0xEF), so the L1 params' PrivateKeyID is correct here.
	privKey, _ := btcec.PrivKeyFromBytes(account.Key)
	wif, err := btcutil.NewWIF(privKey, net, true)
	if err != nil {
		return "", fmt.Errorf("encode wif seed: %w", err)
	}
	return wif.String(), nil
}
