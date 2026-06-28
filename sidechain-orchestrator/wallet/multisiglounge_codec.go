package wallet

import (
	"encoding/base64"
	"encoding/binary"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"strconv"
	"strings"

	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
)

// MultisigGroupData is the JSON-serialized multisig group published in an
// OP_RETURN, with field names byte-identical to the BitWindow Dart
// `multisigData` map so existing on-chain groups decode unchanged. Optional
// fields use omitempty only where the Dart map omits them; required fields are
// always present.
type MultisigGroupData struct {
	ID                string             `json:"id"`
	Name              string             `json:"name"`
	N                 int                `json:"n"`
	M                 int                `json:"m"`
	Keys              []MultisigGroupKey `json:"keys"`
	Created           int64              `json:"created"`
	DescriptorReceive string             `json:"descriptorReceive,omitempty"`
	DescriptorChange  string             `json:"descriptorChange,omitempty"`
	WatchWalletName   string             `json:"watch_wallet_name,omitempty"`
	Txid              string             `json:"txid,omitempty"`
}

// MultisigGroupKey mirrors the Dart MultisigKey.toJson() field names exactly.
type MultisigGroupKey struct {
	Owner          string            `json:"owner"`
	Xpub           string            `json:"xpub"`
	DerivationPath string            `json:"path"`
	Fingerprint    *string           `json:"fingerprint"`
	OriginPath     *string           `json:"origin_path"`
	IsWallet       bool              `json:"is_wallet"`
	ActivePSBTs    map[string]string `json:"active_psbts,omitempty"`
	InitialPSBTs   map[string]string `json:"initial_psbts,omitempty"`
}

const (
	// multisigOpReturnFlag is the metadata flag byte (MULTISIG_FLAG in Dart). A
	// decoder requires (flags & 0x02) != 0.
	multisigOpReturnFlag byte = 0x02
	// multisigOpReturnMetaLen is the fixed metadata length: 1 flag byte +
	// 4-byte big-endian uint32 timestamp + 4-byte filetype.
	multisigOpReturnMetaLen  = 9
	multisigOpReturnFileType = "json"
)

// EncodeGroupOpReturn builds the OP_RETURN message string for a multisig group,
// byte-identical to the Dart _broadcastMultisigGroup format:
//
//	base64(metadata) + "|" + base64(utf8(json(group)))
//
// metadata (9 bytes): [flags=0x02][uint32 big-endian unix-seconds ts]["json"].
func EncodeGroupOpReturn(group MultisigGroupData, unixTimestamp uint32) (string, error) {
	jsonBytes, err := json.Marshal(group)
	if err != nil {
		return "", fmt.Errorf("marshal group json: %w", err)
	}

	meta := make([]byte, multisigOpReturnMetaLen)
	meta[0] = multisigOpReturnFlag
	binary.BigEndian.PutUint32(meta[1:5], unixTimestamp)
	ft := []byte(fmt.Sprintf("%-4s", multisigOpReturnFileType)) // right-pad to 4 with spaces
	copy(meta[5:9], ft)

	metaB64 := base64.StdEncoding.EncodeToString(meta)
	contentB64 := base64.StdEncoding.EncodeToString(jsonBytes)
	return metaB64 + "|" + contentB64, nil
}

// DecodeGroupOpReturn parses an OP_RETURN message string into a multisig group,
// validating the Dart envelope: exactly two "|"-separated base64 parts, 9-byte
// metadata, and the multisig flag set. Returns the decoded group JSON.
func DecodeGroupOpReturn(message string) (MultisigGroupData, error) {
	if !strings.Contains(message, "|") {
		return MultisigGroupData{}, errors.New("invalid OP_RETURN format: missing separator")
	}
	parts := strings.Split(message, "|")
	if len(parts) != 2 {
		return MultisigGroupData{}, fmt.Errorf("invalid OP_RETURN structure: expected 2 parts, got %d", len(parts))
	}

	meta, err := base64.StdEncoding.DecodeString(parts[0])
	if err != nil {
		return MultisigGroupData{}, fmt.Errorf("decode metadata base64: %w", err)
	}
	if len(meta) != multisigOpReturnMetaLen {
		return MultisigGroupData{}, fmt.Errorf("invalid metadata length: got %d, want %d", len(meta), multisigOpReturnMetaLen)
	}
	if meta[0]&multisigOpReturnFlag == 0 {
		return MultisigGroupData{}, errors.New("OP_RETURN does not have the multisig flag set")
	}

	content, err := base64.StdEncoding.DecodeString(parts[1])
	if err != nil {
		return MultisigGroupData{}, fmt.Errorf("decode content base64: %w", err)
	}

	var group MultisigGroupData
	if err := json.Unmarshal(content, &group); err != nil {
		return MultisigGroupData{}, fmt.Errorf("parse group json: %w", err)
	}
	return group, nil
}

// DeriveAccountXpub derives the account extended public key at a full BIP32 path
// (e.g. "m/48'/1'/0'/2'") from a hex seed and returns its base58 string. This is
// the same xpub the BitWindow wallet stores for a cosigner key, so a group key's
// xpub matching this output means the key belongs to the wallet.
func DeriveAccountXpub(seedHex, path string, net *chaincfg.Params) (string, error) {
	if net == nil {
		return "", errors.New("no chain params; cannot derive account xpub")
	}
	seed, err := hex.DecodeString(seedHex)
	if err != nil {
		return "", fmt.Errorf("decode seed hex: %w", err)
	}
	master, err := hdkeychain.NewMaster(seed, net)
	if err != nil {
		return "", fmt.Errorf("create master key: %w", err)
	}

	levels, err := parseHDPath(path)
	if err != nil {
		return "", err
	}
	key := master
	for _, lvl := range levels {
		key, err = key.Derive(lvl)
		if err != nil {
			return "", fmt.Errorf("derive %d: %w", lvl, err)
		}
	}
	pub, err := key.Neuter()
	if err != nil {
		return "", err
	}
	return pub.String(), nil
}

// parseHDPath parses "m/48'/1'/0'/2'" into hardened-aware child indices.
func parseHDPath(path string) ([]uint32, error) {
	s := strings.TrimSpace(path)
	s = strings.TrimPrefix(s, "m/")
	s = strings.TrimPrefix(s, "M/")
	if s == "" {
		return nil, fmt.Errorf("empty derivation path %q", path)
	}
	parts := strings.Split(s, "/")
	out := make([]uint32, 0, len(parts))
	for _, seg := range parts {
		hardened := false
		if c := seg[len(seg)-1]; c == '\'' || c == 'h' || c == 'H' {
			hardened = true
			seg = seg[:len(seg)-1]
		}
		n, err := strconv.ParseUint(seg, 10, 32)
		if err != nil {
			return nil, fmt.Errorf("parse path segment %q: %w", seg, err)
		}
		v := uint32(n)
		if hardened {
			v += hdkeychain.HardenedKeyStart
		}
		out = append(out, v)
	}
	return out, nil
}

// ExtractOpReturnMessage finds the single OP_RETURN output in a decoded
// transaction and returns its pushed data as a UTF-8 string — the BitWindow
// OP_RETURN message. Errors if there is no nulldata output.
func ExtractOpReturnMessage(outputs []RawTxOut) (string, error) {
	for _, out := range outputs {
		script, err := hex.DecodeString(out.ScriptPubKey.Hex)
		if err != nil {
			continue
		}
		if len(script) == 0 || script[0] != txscript.OP_RETURN {
			continue
		}
		pushed, err := txscript.PushedData(script)
		if err != nil || len(pushed) == 0 {
			continue
		}
		return string(pushed[0]), nil
	}
	return "", errors.New("no OP_RETURN output found in transaction")
}
