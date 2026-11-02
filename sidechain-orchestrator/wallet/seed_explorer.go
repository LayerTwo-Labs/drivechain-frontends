package wallet

import (
	"encoding/hex"
	"errors"
	"fmt"
	"strconv"
	"strings"

	"github.com/btcsuite/btcd/btcec/v2/schnorr"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/base58"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
)

// MaxExploredKeys caps the keys that one ExploreSeed call derives.
const MaxExploredKeys = 100

// ExploredKey is one child key of a seed, for display.
type ExploredKey struct {
	Path      string
	Address   string
	PublicKey string // compressed, hex
	WIF       string // compressed
}

// SeedExplorer holds the master keys of a seed and one page of child keys.
type SeedExplorer struct {
	SeedHex     string
	Xprv        string
	Xpub        string
	PaymentCode string // BIP47 v3, from the master public key
	Keys        []ExploredKey
}

// ExploreSeed derives the master keys of a mnemonic and the keys at
// basePath/start to basePath/start+count-1. The purpose level of basePath
// picks the address: 49 nested segwit, 84 segwit, 86 taproot, others P2PKH.
func ExploreSeed(mnemonic, passphrase, basePath string, start, count uint32, net *chaincfg.Params) (SeedExplorer, error) {
	if net == nil {
		return SeedExplorer{}, errors.New("no chain params")
	}
	if count > MaxExploredKeys {
		return SeedExplorer{}, fmt.Errorf("count %d is above the limit of %d", count, MaxExploredKeys)
	}
	if uint64(start)+uint64(count) > hdkeychain.HardenedKeyStart {
		return SeedExplorer{}, fmt.Errorf("index %d+%d is out of the non-hardened range", start, count)
	}
	normal, err := ParseMnemonic(mnemonic)
	if err != nil {
		return SeedExplorer{}, err
	}
	base, err := ParseKeystorePath(basePath)
	if err != nil {
		return SeedExplorer{}, err
	}
	levels, err := parseHDPath(base)
	if err != nil {
		return SeedExplorer{}, err
	}

	seed := MnemonicToSeed(normal, passphrase)
	master, err := hdkeychain.NewMaster(seed, net)
	if err != nil {
		return SeedExplorer{}, fmt.Errorf("create master key: %w", err)
	}
	masterPub, err := master.Neuter()
	if err != nil {
		return SeedExplorer{}, fmt.Errorf("neuter master key: %w", err)
	}
	masterECPub, err := master.ECPubKey()
	if err != nil {
		return SeedExplorer{}, fmt.Errorf("master public key: %w", err)
	}

	parent := master
	for _, level := range levels {
		parent, err = parent.Derive(level)
		if err != nil {
			return SeedExplorer{}, fmt.Errorf("derive %s: %w", base, err)
		}
	}

	purpose := pathPurpose(base)
	keys := make([]ExploredKey, 0, count)
	for i := start; i < start+count; i++ {
		key, err := exploreChild(parent, i, purpose, net)
		if err != nil {
			return SeedExplorer{}, fmt.Errorf("derive %s/%d: %w", base, i, err)
		}
		key.Path = base + "/" + strconv.FormatUint(uint64(i), 10)
		keys = append(keys, key)
	}

	return SeedExplorer{
		SeedHex:     hex.EncodeToString(seed),
		Xprv:        master.String(),
		Xpub:        masterPub.String(),
		PaymentCode: base58.CheckEncode(append([]byte{0x03}, masterECPub.SerializeCompressed()...), 0x22),
		Keys:        keys,
	}, nil
}

func exploreChild(parent *hdkeychain.ExtendedKey, index uint32, purpose uint32, net *chaincfg.Params) (ExploredKey, error) {
	child, err := parent.Derive(index)
	if err != nil {
		return ExploredKey{}, err
	}
	priv, err := child.ECPrivKey()
	if err != nil {
		return ExploredKey{}, err
	}
	pub := priv.PubKey()
	hash := btcutil.Hash160(pub.SerializeCompressed())

	var address btcutil.Address
	switch purpose {
	case 49:
		address, err = btcutil.NewAddressScriptHash(append([]byte{txscript.OP_0, txscript.OP_DATA_20}, hash...), net)
	case 84:
		address, err = btcutil.NewAddressWitnessPubKeyHash(hash, net)
	case 86:
		address, err = btcutil.NewAddressTaproot(schnorr.SerializePubKey(txscript.ComputeTaprootKeyNoScript(pub)), net)
	default:
		address, err = btcutil.NewAddressPubKeyHash(hash, net)
	}
	if err != nil {
		return ExploredKey{}, err
	}
	wif, err := btcutil.NewWIF(priv, net, true)
	if err != nil {
		return ExploredKey{}, err
	}
	return ExploredKey{
		Address:   address.EncodeAddress(),
		PublicKey: hex.EncodeToString(pub.SerializeCompressed()),
		WIF:       wif.String(),
	}, nil
}

// pathPurpose is the first level of a canonical path such as m/84'/0'/0'/0, or 0.
func pathPurpose(canonical string) uint32 {
	levels := strings.Split(strings.TrimPrefix(canonical, "m/"), "/")
	purpose, err := strconv.ParseUint(strings.TrimSuffix(levels[0], "'"), 10, 31)
	if err != nil {
		return 0
	}
	return uint32(purpose)
}
