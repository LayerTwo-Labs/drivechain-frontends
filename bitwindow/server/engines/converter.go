package engines

import (
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"errors"
	"fmt"
	"regexp"
	"strconv"
	"strings"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcec/v2/schnorr"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/base58"
	"github.com/btcsuite/btcd/btcutil/bech32"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
	"golang.org/x/crypto/ripemd160" //nolint:staticcheck // RIPEMD-160 is part of HASH160.
)

// ConverterFormat says how the converter reads its input.
type ConverterFormat int

const (
	ConverterAuto ConverterFormat = iota
	ConverterHex
	ConverterBase64
	ConverterBase58
	ConverterBase58Check
	ConverterBech32
	ConverterASCII
	ConverterWIF
	ConverterPassphrase
)

func (f ConverterFormat) label() string {
	switch f {
	case ConverterHex:
		return "Hex"
	case ConverterBase64:
		return "Base64"
	case ConverterBase58:
		return "Base58"
	case ConverterBase58Check:
		return "Base58Check"
	case ConverterBech32:
		return "Bech32 / Bech32m"
	case ConverterWIF:
		return "WIF private key"
	case ConverterPassphrase:
		return "Brainwallet passphrase"
	case ConverterAuto:
		return "Auto-detect"
	case ConverterASCII:
		return "ASCII"
	default:
		return "ASCII"
	}
}

// ConverterRow is one labelled output value.
type ConverterRow struct {
	Label string
	Value string
}

// ConvertResult is everything the converter says about one input.
type ConvertResult struct {
	Detected  ConverterFormat
	Error     string
	Encodings []ConverterRow
	Hashes    []ConverterRow
	Keys      []ConverterRow
}

var (
	bech32Pattern = regexp.MustCompile(`^(bc|tb|bcrt)1[02-9ac-hj-np-z]{6,}$`)
	hexPattern    = regexp.MustCompile(`^[0-9a-fA-F]+$`)
)

// Convert reads input under format and shows its encodings, its hashes, and,
// for a 32-byte secret, its keys and addresses on params.
func Convert(input string, format ConverterFormat, params *chaincfg.Params) ConvertResult {
	if strings.TrimSpace(input) == "" {
		return ConvertResult{Detected: ConverterASCII}
	}

	detected := format
	if format == ConverterAuto {
		detected = detectFormat(input)
	}

	data, err := converterBytes(input, detected)
	if err != nil {
		return ConvertResult{Detected: detected, Error: fmt.Sprintf("Could not read input as %s: %s", detected.label(), err)}
	}

	return ConvertResult{
		Detected:  detected,
		Encodings: converterEncodings(input, data),
		Hashes:    converterHashes(data),
		Keys:      converterKeys(data, detected, params),
	}
}

type base58CheckDecoded struct {
	version byte
	data    []byte
	valid   bool
}

// decodeBase58Check splits a Base58Check string even when the checksum is wrong.
func decodeBase58Check(s string) (base58CheckDecoded, bool) {
	raw := base58.Decode(s)
	if len(raw) < 5 {
		return base58CheckDecoded{}, false
	}
	payload, checksum := raw[:len(raw)-4], raw[len(raw)-4:]
	sum := doubleSHA256(payload)
	return base58CheckDecoded{
		version: payload[0],
		data:    payload[1:],
		valid:   string(sum[:4]) == string(checksum),
	}, true
}

func looksHex(s string) bool {
	return s != "" && len(s)%2 == 0 && hexPattern.MatchString(s)
}

func detectFormat(input string) ConverterFormat {
	trimmed := strings.TrimSpace(input)
	if trimmed == "" {
		return ConverterASCII
	}
	if bech32Pattern.MatchString(strings.ToLower(trimmed)) {
		return ConverterBech32
	}
	if decoded, ok := decodeBase58Check(trimmed); ok && decoded.valid {
		if len(decoded.data) == 32 || len(decoded.data) == 33 {
			return ConverterWIF
		}
		return ConverterBase58Check
	}
	if looksHex(trimmed) {
		return ConverterHex
	}
	return ConverterASCII
}

func converterBytes(input string, format ConverterFormat) ([]byte, error) {
	trimmed := strings.TrimSpace(input)
	switch format {
	case ConverterHex:
		if !looksHex(trimmed) {
			return nil, errors.New("not valid hex")
		}
		return hex.DecodeString(trimmed)
	case ConverterBase64:
		normal := strings.NewReplacer("-", "+", "_", "/").Replace(trimmed)
		return base64.StdEncoding.Strict().DecodeString(normal)
	case ConverterBase58:
		raw := base58.Decode(trimmed)
		if len(raw) == 0 {
			return nil, errors.New("not valid Base58")
		}
		return raw, nil
	case ConverterBase58Check:
		decoded, ok := decodeBase58Check(trimmed)
		if !ok {
			return nil, errors.New("not valid Base58Check")
		}
		return decoded.data, nil
	case ConverterWIF:
		// A bad checksum here would present a mistyped key as spendable.
		decoded, ok := decodeBase58Check(trimmed)
		if !ok {
			return nil, errors.New("not valid Base58Check")
		}
		if !decoded.valid {
			return nil, errors.New("WIF checksum does not match")
		}
		return decoded.data, nil
	case ConverterBech32:
		return witnessProgram(strings.ToLower(trimmed))
	case ConverterPassphrase:
		sum := sha256.Sum256([]byte(input))
		return sum[:], nil
	case ConverterASCII, ConverterAuto:
		return []byte(input), nil
	default:
		return []byte(input), nil
	}
}

// witnessProgram decodes a segwit address of any HRP. The witness version
// picks bech32 or bech32m.
func witnessProgram(address string) ([]byte, error) {
	_, data, encoding, err := bech32.DecodeGeneric(address)
	if err != nil {
		return nil, err
	}
	if len(data) == 0 {
		return nil, errors.New("no witness version")
	}
	version := data[0]
	if version > 16 {
		return nil, fmt.Errorf("witness version %d is above 16", version)
	}
	if version == 0 && encoding != bech32.Version0 {
		return nil, errors.New("witness version 0 needs bech32")
	}
	if version != 0 && encoding != bech32.VersionM {
		return nil, fmt.Errorf("witness version %d needs bech32m", version)
	}
	program, err := bech32.ConvertBits(data[1:], 5, 8, false)
	if err != nil {
		return nil, err
	}
	if len(program) < 2 || len(program) > 40 {
		return nil, fmt.Errorf("witness program has %d bytes", len(program))
	}
	if version == 0 && len(program) != 20 && len(program) != 32 {
		return nil, fmt.Errorf("version 0 program has %d bytes", len(program))
	}
	return program, nil
}

func converterEncodings(input string, data []byte) []ConverterRow {
	rows := []ConverterRow{
		{"Hex", hex.EncodeToString(data)},
		{"Base64", base64.StdEncoding.EncodeToString(data)},
		{"Base58", base58.Encode(data)},
		{"Byte length", strconv.Itoa(len(data))},
	}

	printable := true
	for _, b := range data {
		if b < 0x20 || b >= 0x7f {
			printable = false
			break
		}
	}
	if printable {
		rows = append(rows, ConverterRow{"ASCII", string(data)})
	}

	if decoded, ok := decodeBase58Check(strings.TrimSpace(input)); ok {
		valid := "no"
		if decoded.valid {
			valid = "yes"
		}
		rows = append(rows,
			ConverterRow{"Base58Check version", fmt.Sprintf("0x%02X", decoded.version)},
			ConverterRow{"Base58Check valid", valid},
		)
	}
	return rows
}

func converterHashes(data []byte) []ConverterRow {
	single := sha256.Sum256(data)
	double := doubleSHA256(data)
	return []ConverterRow{
		{"SHA-256", hex.EncodeToString(single[:])},
		{"SHA-256d", hex.EncodeToString(double[:])},
		{"RIPEMD-160", hex.EncodeToString(ripemd(data))},
		{"HASH160", hex.EncodeToString(btcutil.Hash160(data))},
	}
}

func converterKeys(data []byte, detected ConverterFormat, params *chaincfg.Params) []ConverterRow {
	isSecret := len(data) == 32 || (len(data) == 33 && detected == ConverterWIF)
	if !isSecret {
		return nil
	}

	secret := data[:32]
	rows := []ConverterRow{
		{"Private key (hex)", hex.EncodeToString(secret)},
		{"WIF (compressed)", base58.CheckEncode(append(append([]byte{}, secret...), 0x01), params.PrivateKeyID)},
		{"WIF (uncompressed)", base58.CheckEncode(secret, params.PrivateKeyID)},
	}

	var scalar btcec.ModNScalar
	if overflow := scalar.SetByteSlice(secret); overflow || scalar.IsZero() {
		return append(rows, ConverterRow{"Public key", "not derivable: the secret is not in the range 1 to n-1"})
	}
	priv, _ := btcec.PrivKeyFromBytes(secret)
	pub := priv.PubKey()

	hash := btcutil.Hash160(pub.SerializeCompressed())
	segwit, err := segwitAddress(params.Bech32HRPSegwit, 0, hash)
	if err != nil {
		return append(rows, ConverterRow{"Public key", "not derivable: " + err.Error()})
	}
	taproot, err := segwitAddress(params.Bech32HRPSegwit, 1, schnorr.SerializePubKey(txscript.ComputeTaprootKeyNoScript(pub)))
	if err != nil {
		return append(rows, ConverterRow{"Public key", "not derivable: " + err.Error()})
	}

	return append(rows,
		ConverterRow{"Public key (compressed)", hex.EncodeToString(pub.SerializeCompressed())},
		ConverterRow{"Public key (uncompressed)", hex.EncodeToString(pub.SerializeUncompressed())},
		ConverterRow{"HASH160 of pubkey", hex.EncodeToString(hash)},
		ConverterRow{"P2PKH address", base58.CheckEncode(hash, params.PubKeyHashAddrID)},
		ConverterRow{"P2WPKH address", segwit},
		ConverterRow{"P2TR address", taproot},
	)
}

func segwitAddress(hrp string, version byte, program []byte) (string, error) {
	converted, err := bech32.ConvertBits(program, 8, 5, true)
	if err != nil {
		return "", err
	}
	data := append([]byte{version}, converted...)
	if version == 0 {
		return bech32.Encode(hrp, data)
	}
	return bech32.EncodeM(hrp, data)
}

func doubleSHA256(data []byte) [32]byte {
	first := sha256.Sum256(data)
	return sha256.Sum256(first[:])
}

func ripemd(data []byte) []byte {
	h := ripemd160.New()
	h.Write(data)
	return h.Sum(nil)
}
