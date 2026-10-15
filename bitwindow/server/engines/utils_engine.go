package engines

import (
	"bytes"
	"crypto/rand"
	"encoding/hex"
	"errors"
	"fmt"
	"net/url"
	"strconv"
	"strings"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/base58"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
)

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
		return nil, errors.New("not a bitcoin URI")
	}

	// Split the URI into address and query parts
	rest := uri[8:] // Remove "bitcoin:"
	parts := strings.SplitN(rest, "?", 2)
	if len(parts) == 0 || parts[0] == "" {
		return nil, errors.New("no address specified")
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
					return nil, errors.New("invalid amount format")
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
	decoded := base58.Decode(input)
	if len(decoded) == 0 && input != "" {
		return nil, errors.New("invalid Base58 string")
	}

	if len(decoded) < 5 {
		return nil, errors.New("too short for valid Base58Check")
	}

	// Split payload and checksum
	payload := decoded[:len(decoded)-4]
	checksum := decoded[len(decoded)-4:]

	// Verify checksum
	checksumValid := bytes.Equal(checksum, chainhash.DoubleHashB(payload)[:4])

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
func EncodeBase58Check(versionByte int, data []byte) string {
	return base58.CheckEncode(data, byte(versionByte))
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
		return nil, errors.New("no transactions provided")
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
		levels := [][]string{{hex.EncodeToString(leaves[0])}}
		return &MerkleTreeResult{
			MerkleRoot:    hex.EncodeToString(leaves[0]),
			Levels:        levels,
			FormattedText: FormatMerkleTree(levels, nil),
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
			product := chainhash.DoubleHashB(combined)
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
	formattedText := FormatMerkleTree(levels, rcbLevels)

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

// FormatMerkleTree renders the tree. Pass nil rcbLevels to omit the RCB rows.
func FormatMerkleTree(levels [][]string, rcbLevels [][]string) string {
	if len(levels) == 0 {
		return "No transactions provided"
	}

	var sb strings.Builder
	sb.WriteString("Merkle Tree for block header hashMerkleRoot:\n\n")

	// Display from root to leaves
	for levelNum := len(levels) - 1; levelNum >= 0; levelNum-- {
		level := levels[levelNum]

		fmt.Fprintf(&sb, "Level %d", levelNum)
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
		return nil, fmt.Errorf("generate random bytes: %w", err)
	}

	// Create private key from bytes
	privateKey, _ := btcec.PrivKeyFromBytes(privateKeyBytes)

	// Create WIF
	wif, err := btcutil.NewWIF(privateKey, chainParams, true) // compressed
	if err != nil {
		return nil, fmt.Errorf("create WIF: %w", err)
	}

	// Generate P2PKH address
	pubKeyHash := btcutil.Hash160(privateKey.PubKey().SerializeCompressed())
	address, err := btcutil.NewAddressPubKeyHash(pubKeyHash, chainParams)
	if err != nil {
		return nil, fmt.Errorf("create address: %w", err)
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
		return "", fmt.Errorf("create address: %w", err)
	}

	return address.EncodeAddress(), nil
}
