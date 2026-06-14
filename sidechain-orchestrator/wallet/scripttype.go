package wallet

import (
	"crypto/sha256"
	"fmt"
	"sort"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcec/v2/schnorr"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
)

// ScriptKind is the output/address type of an electrum wallet. Each single-sig
// kind maps to a BIP-standard derivation purpose and a scriptPubKey form. All
// address and script construction goes through btcutil/txscript — there is no
// hand-rolled script assembly here.
type ScriptKind int

const (
	ScriptUnknown      ScriptKind = iota
	ScriptLegacy                  // P2PKH, BIP44 (purpose 44')
	ScriptNestedSegwit            // P2SH-P2WPKH, BIP49 (purpose 49')
	ScriptNativeSegwit            // P2WPKH, BIP84 (purpose 84')
	ScriptTaproot                 // P2TR key-path, BIP86 (purpose 86')
	ScriptMultisig                // P2WSH sortedmulti
)

// Purpose returns the BIP-standard derivation purpose for a single-sig kind.
func (k ScriptKind) Purpose() (uint32, bool) {
	switch k {
	case ScriptLegacy:
		return 44, true
	case ScriptNestedSegwit:
		return 49, true
	case ScriptNativeSegwit:
		return 84, true
	case ScriptTaproot:
		return 86, true
	default:
		return 0, false
	}
}

func (k ScriptKind) String() string {
	switch k {
	case ScriptLegacy:
		return "legacy"
	case ScriptNestedSegwit:
		return "nested-segwit"
	case ScriptNativeSegwit:
		return "native-segwit"
	case ScriptTaproot:
		return "taproot"
	case ScriptMultisig:
		return "multisig"
	default:
		return "unknown"
	}
}

// derivedScript is the fully resolved output for one address: its encoded
// address, scriptPubKey, and the auxiliary scripts/keys a signer needs.
type derivedScript struct {
	address       btcutil.Address
	scriptPubKey  []byte
	redeemScript  []byte // P2SH-P2WPKH: the witness program wrapped by the P2SH
	witnessScript []byte // P2WSH multisig: the k-of-n script
	tapInternal   *btcec.PublicKey
}

// singleSigOutput builds the address and scripts for one compressed pubkey
// under a single-sig kind, using only btcutil/txscript primitives.
func singleSigOutput(kind ScriptKind, pub *btcec.PublicKey, net *chaincfg.Params) (derivedScript, error) {
	pkHash := btcutil.Hash160(pub.SerializeCompressed())

	switch kind {
	case ScriptLegacy:
		addr, err := btcutil.NewAddressPubKeyHash(pkHash, net)
		if err != nil {
			return derivedScript{}, err
		}
		return finishSingleSig(addr, nil, nil)

	case ScriptNativeSegwit:
		addr, err := btcutil.NewAddressWitnessPubKeyHash(pkHash, net)
		if err != nil {
			return derivedScript{}, err
		}
		return finishSingleSig(addr, nil, nil)

	case ScriptNestedSegwit:
		wpkh, err := btcutil.NewAddressWitnessPubKeyHash(pkHash, net)
		if err != nil {
			return derivedScript{}, err
		}
		redeem, err := txscript.PayToAddrScript(wpkh)
		if err != nil {
			return derivedScript{}, err
		}
		addr, err := btcutil.NewAddressScriptHash(redeem, net)
		if err != nil {
			return derivedScript{}, err
		}
		return finishSingleSig(addr, redeem, nil)

	case ScriptTaproot:
		tapKey := txscript.ComputeTaprootKeyNoScript(pub)
		addr, err := btcutil.NewAddressTaproot(schnorr.SerializePubKey(tapKey), net)
		if err != nil {
			return derivedScript{}, err
		}
		ds, err := finishSingleSig(addr, nil, nil)
		if err != nil {
			return derivedScript{}, err
		}
		ds.tapInternal = pub
		return ds, nil

	default:
		return derivedScript{}, fmt.Errorf("not a single-sig script kind: %s", kind)
	}
}

func finishSingleSig(addr btcutil.Address, redeem []byte, _ []byte) (derivedScript, error) {
	script, err := txscript.PayToAddrScript(addr)
	if err != nil {
		return derivedScript{}, err
	}
	return derivedScript{address: addr, scriptPubKey: script, redeemScript: redeem}, nil
}

// multisigWitnessScript builds the BIP67 sorted multisig witness script for a
// k-of-n policy over the given compressed pubkeys.
func multisigWitnessScript(threshold int, pubs []*btcec.PublicKey, net *chaincfg.Params) ([]byte, error) {
	sorted := append([]*btcec.PublicKey(nil), pubs...)
	sort.Slice(sorted, func(i, j int) bool {
		return bytesLess(sorted[i].SerializeCompressed(), sorted[j].SerializeCompressed())
	})
	addrPubs := make([]*btcutil.AddressPubKey, len(sorted))
	for i, p := range sorted {
		ap, err := btcutil.NewAddressPubKey(p.SerializeCompressed(), net)
		if err != nil {
			return nil, err
		}
		addrPubs[i] = ap
	}
	return txscript.MultiSigScript(addrPubs, threshold)
}

// multisigOutput builds the P2WSH address + scripts for a sorted k-of-n policy.
func multisigOutput(threshold int, pubs []*btcec.PublicKey, net *chaincfg.Params) (derivedScript, []byte, error) {
	witnessScript, err := multisigWitnessScript(threshold, pubs, net)
	if err != nil {
		return derivedScript{}, nil, err
	}
	wsh := sha256.Sum256(witnessScript)
	addr, err := btcutil.NewAddressWitnessScriptHash(wsh[:], net)
	if err != nil {
		return derivedScript{}, nil, err
	}
	script, err := txscript.PayToAddrScript(addr)
	if err != nil {
		return derivedScript{}, nil, err
	}
	return derivedScript{address: addr, scriptPubKey: script, witnessScript: witnessScript}, witnessScript, nil
}

func bytesLess(a, b []byte) bool {
	for i := 0; i < len(a) && i < len(b); i++ {
		if a[i] != b[i] {
			return a[i] < b[i]
		}
	}
	return len(a) < len(b)
}
