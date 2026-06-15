package wallet

import (
	"bytes"
	"encoding/binary"
	"fmt"

	"github.com/btcsuite/btcd/btcutil/base58"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
)

// SLIP-0132 extended-key version bytes. Wallets like Sparrow export account keys
// as ypub/zpub (and testnet upub/vpub) to signal the address type. btcsuite's
// hdkeychain only parses xpub/tpub, so we remap these to the canonical version
// and infer the script kind from the header, matching drongo's ExtendedKey.
type slip132Header struct {
	version uint32
	kind    ScriptKind
	private bool
	mainnet bool
}

var slip132Headers = []slip132Header{
	// mainnet
	{0x0488ADE4, ScriptLegacy, true, true},        // xprv
	{0x0488B21E, ScriptLegacy, false, true},       // xpub
	{0x049D7878, ScriptNestedSegwit, true, true},  // yprv
	{0x049D7CB2, ScriptNestedSegwit, false, true}, // ypub
	{0x04B2430C, ScriptNativeSegwit, true, true},  // zprv
	{0x04B24746, ScriptNativeSegwit, false, true}, // zpub
	// testnet
	{0x04358394, ScriptLegacy, true, false},        // tprv
	{0x043587CF, ScriptLegacy, false, false},       // tpub
	{0x044A4E28, ScriptNestedSegwit, true, false},  // uprv
	{0x044A5262, ScriptNestedSegwit, false, false}, // upub
	{0x045F18BC, ScriptNativeSegwit, true, false},  // vprv
	{0x045F1CF6, ScriptNativeSegwit, false, false}, // vpub
}

// normalizeExtendedKey rewrites a SLIP-0132 extended key to its canonical
// xpub/tpub (or xprv/tprv) form so hdkeychain can parse it, and reports the
// script kind the header implies. Plain xpub/tpub keys pass through unchanged
// with hasKind=false (the caller keeps its default).
func normalizeExtendedKey(key string) (canonical string, kind ScriptKind, hasKind bool, err error) {
	raw := base58.Decode(key)
	if len(raw) != 82 {
		// Not an extended key we recognize; let the caller's parser report it.
		return key, 0, false, nil
	}
	if !bytes.Equal(chainhash.DoubleHashB(raw[:78])[:4], raw[78:82]) {
		return "", 0, false, fmt.Errorf("extended key %q has an invalid checksum", key)
	}

	version := binary.BigEndian.Uint32(raw[:4])
	var hdr *slip132Header
	for i := range slip132Headers {
		if slip132Headers[i].version == version {
			hdr = &slip132Headers[i]
			break
		}
	}
	if hdr == nil {
		return "", 0, false, fmt.Errorf("unknown extended key version %#08x", version)
	}

	// xpub/tpub already canonical: pass through and keep the caller's default.
	if hdr.kind == ScriptLegacy {
		return key, 0, false, nil
	}

	target := canonicalVersion(hdr.mainnet, hdr.private)
	binary.BigEndian.PutUint32(raw[:4], target)
	copy(raw[78:82], chainhash.DoubleHashB(raw[:78])[:4])
	return base58.Encode(raw), hdr.kind, true, nil
}

func canonicalVersion(mainnet, private bool) uint32 {
	switch {
	case mainnet && private:
		return 0x0488ADE4 // xprv
	case mainnet:
		return 0x0488B21E // xpub
	case private:
		return 0x04358394 // tprv
	default:
		return 0x043587CF // tpub
	}
}
