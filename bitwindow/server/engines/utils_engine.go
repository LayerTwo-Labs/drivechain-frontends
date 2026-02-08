package engines

import (
	"crypto/rand"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"math/big"
	"net/url"
	"strconv"
	"strings"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
)

// Base58 alphabet
const base58Alphabet = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz"

// BitcoinURI represents a parsed BIP-0021 Bitcoin URI
type BitcoinURI struct {
	Address     string
	Amount      float64
	Label       string
	Message     string
	ExtraParams map[string]string
}

// ParseBitcoinURI parses a BIP-0021 Bitcoin URI
func ParseBitcoinURI(uri string) (*BitcoinURI, error) {
	lower := strings.ToLower(uri)
	if !strings.HasPrefix(lower, "bitcoin:") {
		return nil, fmt.Errorf("not a bitcoin URI")
	}

	// Split the URI into address and query parts
	rest := uri[8:] // Remove "bitcoin:"
	parts := strings.SplitN(rest, "?", 2)
	if len(parts) == 0 || parts[0] == "" {
		return nil, fmt.Errorf("no address specified")
	}

	result := &BitcoinURI{
		Address:     parts[0],
		ExtraParams: make(map[string]string),
	}

	// Parse query parameters if they exist
	if len(parts) > 1 {
		queryParts := strings.Split(parts[1], "&")
		for _, param := range queryParts {
			kv := strings.SplitN(param, "=", 2)
			if len(kv) != 2 {
				continue
			}

			key, err := url.QueryUnescape(kv[0])
			if err != nil {
				continue
			}
			value, err := url.QueryUnescape(kv[1])
			if err != nil {
				continue
			}

			// Check for required parameters we don't understand
			if strings.HasPrefix(key, "req-") {
				return nil, fmt.Errorf("required parameter not understood: %s", key)
			}

			switch key {
			case "amount":
				amount, err := strconv.ParseFloat(value, 64)
				if err != nil {
					return nil, fmt.Errorf("invalid amount format")
				}
				result.Amount = amount
			case "label":
				result.Label = value
			case "message":
				result.Message = value
			default:
				result.ExtraParams[key] = value
			}
		}
	}

	return result, nil
}

// ValidateBitcoinURI checks if a string is a valid Bitcoin URI
func ValidateBitcoinURI(uri string) bool {
	_, err := ParseBitcoinURI(uri)
	return err == nil
}

// Base58DecodeResult holds the result of Base58Check decoding
type Base58DecodeResult struct {
	VersionByte   int
	Payload       []byte
	Checksum      []byte
	ChecksumValid bool
	AddressType   string
}

// DecodeBase58Check decodes a Base58Check string
func DecodeBase58Check(input string) (*Base58DecodeResult, error) {
	// Decode Base58 to bytes
	decoded, err := base58Decode(input)
	if err != nil {
		return nil, err
	}

	if len(decoded) < 5 {
		return nil, fmt.Errorf("too short for valid Base58Check")
	}

	// Split payload and checksum
	payload := decoded[:len(decoded)-4]
	checksum := decoded[len(decoded)-4:]

	// Verify checksum
	calculatedChecksum := doubleHash(payload)[:4]
	checksumValid := bytesEqual(checksum, calculatedChecksum)

	// Extract version and data
	versionByte := int(payload[0])
	data := payload[1:]

	return &Base58DecodeResult{
		VersionByte:   versionByte,
		Payload:       data,
		Checksum:      checksum,
		ChecksumValid: checksumValid,
		AddressType:   getAddressType(versionByte),
	}, nil
}

// EncodeBase58Check encodes data to Base58Check format
func EncodeBase58Check(versionByte int, data []byte) (string, error) {
	// Combine version + data
	payload := make([]byte, 1+len(data))
	payload[0] = byte(versionByte)
	copy(payload[1:], data)

	// Calculate checksum
	checksum := doubleHash(payload)[:4]

	// Combine payload + checksum
	combined := make([]byte, len(payload)+4)
	copy(combined, payload)
	copy(combined[len(payload):], checksum)

	// Encode to Base58
	return base58Encode(combined), nil
}

func base58Decode(input string) ([]byte, error) {
	if input == "" {
		return []byte{}, nil
	}

	// Count leading zeros
	leadingZeros := 0
	for leadingZeros < len(input) && input[leadingZeros] == '1' {
		leadingZeros++
	}

	// Convert Base58 to BigInt
	value := big.NewInt(0)
	base := big.NewInt(58)

	for i := 0; i < len(input); i++ {
		char := input[i]
		index := strings.IndexByte(base58Alphabet, char)
		if index == -1 {
			return nil, fmt.Errorf("invalid Base58 character: %c", char)
		}
		value.Mul(value, base)
		value.Add(value, big.NewInt(int64(index)))
	}

	// Convert BigInt to bytes
	bytes := value.Bytes()

	// Add leading zeros
	result := make([]byte, leadingZeros+len(bytes))
	copy(result[leadingZeros:], bytes)

	return result, nil
}

func base58Encode(input []byte) string {
	if len(input) == 0 {
		return ""
	}

	// Count leading zeros
	leadingZeros := 0
	for leadingZeros < len(input) && input[leadingZeros] == 0 {
		leadingZeros++
	}

	// Convert bytes to BigInt
	value := new(big.Int).SetBytes(input)

	// Convert to Base58
	base := big.NewInt(58)
	var result []byte

	for value.Cmp(big.NewInt(0)) > 0 {
		mod := new(big.Int)
		value.DivMod(value, base, mod)
		result = append([]byte{base58Alphabet[mod.Int64()]}, result...)
	}

	// Add leading '1's for leading zeros
	for i := 0; i < leadingZeros; i++ {
		result = append([]byte{'1'}, result...)
	}

	return string(result)
}

func doubleHash(data []byte) []byte {
	first := sha256.Sum256(data)
	second := sha256.Sum256(first[:])
	return second[:]
}

func bytesEqual(a, b []byte) bool {
	if len(a) != len(b) {
		return false
	}
	for i := range a {
		if a[i] != b[i] {
			return false
		}
	}
	return true
}

func getAddressType(versionByte int) string {
	switch versionByte {
	case 0x00:
		return "P2PKH (Pay-to-PubKey-Hash) - Mainnet"
	case 0x05:
		return "P2SH (Pay-to-Script-Hash) - Mainnet"
	case 0x6F:
		return "P2PKH (Pay-to-PubKey-Hash) - Testnet"
	case 0xC4:
		return "P2SH (Pay-to-Script-Hash) - Testnet"
	case 0x80:
		return "Private Key (WIF) - Mainnet"
	case 0xEF:
		return "Private Key (WIF) - Testnet"
	default:
		return fmt.Sprintf("Unknown (0x%02X)", versionByte)
	}
}

// MerkleTreeResult holds the result of Merkle tree calculation
type MerkleTreeResult struct {
	MerkleRoot    string
	Levels        [][]string
	RCBLevels     [][]string // Reversed Concatenated Bytes
	FormattedText string
}

// CalculateMerkleTree calculates the Merkle tree from transaction IDs
func CalculateMerkleTree(txids []string) (*MerkleTreeResult, error) {
	if len(txids) == 0 {
		return nil, fmt.Errorf("no transactions provided")
	}

	// Parse hex strings to bytes
	leaves := make([][]byte, len(txids))
	for i, txid := range txids {
		bytes, err := hex.DecodeString(txid)
		if err != nil {
			return nil, fmt.Errorf("invalid txid hex: %s", txid)
		}
		leaves[i] = bytes
	}

	// Single transaction case
	if len(leaves) == 1 {
		return &MerkleTreeResult{
			MerkleRoot: hex.EncodeToString(leaves[0]),
			Levels:     [][]string{{hex.EncodeToString(leaves[0])}},
		}, nil
	}

	// Build all levels
	allLevels := [][][]byte{leaves}
	currentLevel := leaves

	for len(currentLevel) > 1 {
		var nextLevel [][]byte

		for i := 0; i < len(currentLevel); i += 2 {
			hash1 := currentLevel[i]
			var hash2 []byte
			if i+1 < len(currentLevel) {
				hash2 = currentLevel[i+1]
			} else {
				hash2 = hash1 // Duplicate last hash if odd
			}

			// Concatenate and double-hash
			combined := make([]byte, len(hash1)+len(hash2))
			copy(combined, hash1)
			copy(combined[len(hash1):], hash2)
			product := doubleHash(combined)
			nextLevel = append(nextLevel, product)
		}

		allLevels = append(allLevels, nextLevel)
		currentLevel = nextLevel
	}

	// Convert to hex strings
	levels := make([][]string, len(allLevels))
	for i, level := range allLevels {
		levels[i] = make([]string, len(level))
		for j, hash := range level {
			levels[i][j] = hex.EncodeToString(hash)
		}
	}

	// Calculate RCB levels
	rcbLevels := calculateRCBLevels(allLevels)

	// Format text output
	formattedText := formatMerkleTree(levels, rcbLevels)

	return &MerkleTreeResult{
		MerkleRoot:    levels[len(levels)-1][0],
		Levels:        levels,
		RCBLevels:     rcbLevels,
		FormattedText: formattedText,
	}, nil
}

func calculateRCBLevels(allLevels [][][]byte) [][]string {
	var rcbLevels [][]string

	for _, level := range allLevels {
		if len(level) < 2 {
			continue
		}

		// Make level even
		evenLevel := level
		if len(evenLevel)%2 != 0 {
			evenLevel = append(evenLevel, evenLevel[len(evenLevel)-1])
		}

		var rcbLevel []string
		for i := 0; i < len(evenLevel); i += 2 {
			// Reverse each hash
			hash1Reversed := reverseBytes(evenLevel[i])
			hash2Reversed := reverseBytes(evenLevel[i+1])
			rcb := hex.EncodeToString(hash1Reversed) + hex.EncodeToString(hash2Reversed)
			rcbLevel = append(rcbLevel, rcb)
		}

		rcbLevels = append(rcbLevels, rcbLevel)
	}

	return rcbLevels
}

func reverseBytes(b []byte) []byte {
	result := make([]byte, len(b))
	for i := range b {
		result[len(b)-1-i] = b[i]
	}
	return result
}

func formatMerkleTree(levels [][]string, rcbLevels [][]string) string {
	if len(levels) == 0 {
		return "No transactions provided"
	}

	var sb strings.Builder
	sb.WriteString("Merkle Tree for block header hashMerkleRoot:\n\n")

	// Display from root to leaves
	for levelNum := len(levels) - 1; levelNum >= 0; levelNum-- {
		level := levels[levelNum]

		sb.WriteString(fmt.Sprintf("Level %d", levelNum))
		switch {
		case levelNum == len(levels)-1:
			sb.WriteString(" Merkle Root:\n")
		case levelNum == 0:
			sb.WriteString(" (TxID):\n")
		default:
			sb.WriteString(":\n")
		}

		sb.WriteString("     ")

		// Add hashes with comma between pairs
		nodeCount := 0
		for i, hash := range level {
			nodeCount++
			if nodeCount == 2 && i != len(level)-1 {
				sb.WriteString(hash + ", ")
			} else {
				sb.WriteString(hash + " ")
			}
			if nodeCount == 2 {
				nodeCount = 0
			}
		}

		// Add RCB for this level if available
		if levelNum < len(rcbLevels) && levelNum != len(levels)-1 {
			sb.WriteString("\nRCB: ")
			for i, rcb := range rcbLevels[levelNum] {
				if i == len(rcbLevels[levelNum])-1 {
					sb.WriteString(rcb + "\n")
				} else {
					sb.WriteString(rcb + ",  ")
				}
			}
			sb.WriteString("\n")
		} else {
			sb.WriteString("\n\n")
		}
	}

	return sb.String()
}

// PaperWalletKeypair holds a generated paper wallet keypair
type PaperWalletKeypair struct {
	PrivateKeyWIF string
	PublicAddress string
	PrivateKeyHex string
}

// GeneratePaperWallet generates a new random keypair for paper wallets
func GeneratePaperWallet(chainParams *chaincfg.Params) (*PaperWalletKeypair, error) {
	// Generate random private key (32 bytes)
	privateKeyBytes := make([]byte, 32)
	_, err := rand.Read(privateKeyBytes)
	if err != nil {
		return nil, fmt.Errorf("failed to generate random bytes: %w", err)
	}

	// Create private key from bytes
	privateKey, _ := btcec.PrivKeyFromBytes(privateKeyBytes)

	// Create WIF
	wif, err := btcutil.NewWIF(privateKey, chainParams, true) // compressed
	if err != nil {
		return nil, fmt.Errorf("failed to create WIF: %w", err)
	}

	// Generate P2PKH address
	pubKeyHash := btcutil.Hash160(privateKey.PubKey().SerializeCompressed())
	address, err := btcutil.NewAddressPubKeyHash(pubKeyHash, chainParams)
	if err != nil {
		return nil, fmt.Errorf("failed to create address: %w", err)
	}

	return &PaperWalletKeypair{
		PrivateKeyWIF: wif.String(),
		PublicAddress: address.EncodeAddress(),
		PrivateKeyHex: hex.EncodeToString(privateKeyBytes),
	}, nil
}

// ValidateWIF validates a WIF private key
func ValidateWIF(wif string, chainParams *chaincfg.Params) bool {
	_, err := btcutil.DecodeWIF(wif)
	return err == nil
}

// WIFToAddress converts a WIF private key to its corresponding address
func WIFToAddress(wifStr string, chainParams *chaincfg.Params) (string, error) {
	wif, err := btcutil.DecodeWIF(wifStr)
	if err != nil {
		return "", fmt.Errorf("invalid WIF: %w", err)
	}

	// Generate P2PKH address
	pubKeyHash := btcutil.Hash160(wif.PrivKey.PubKey().SerializeCompressed())
	address, err := btcutil.NewAddressPubKeyHash(pubKeyHash, chainParams)
	if err != nil {
		return "", fmt.Errorf("failed to create address: %w", err)
	}

	return address.EncodeAddress(), nil
}
