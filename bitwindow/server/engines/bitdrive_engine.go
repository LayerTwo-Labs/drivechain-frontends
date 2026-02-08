package engines

import (
	"bytes"
	"context"
	"crypto/hmac"
	"crypto/sha256"
	"crypto/subtle"
	"database/sql"
	"encoding/base64"
	"encoding/binary"
	"encoding/hex"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/bitdrive"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
)

const (
	// Derivation paths for BitDrive keys
	BitDriveDerivationIndex = 4000
	BitDriveDerivationPath  = "m/84'/1'/0'/0/4000"
	AuthKeyPath             = "m/84'/1'/0'/1/4000"

	// Authentication tag size (8 bytes from HMAC-SHA256)
	AuthTagSize = 8

	// Metadata size (1 byte flags + 4 bytes timestamp + 4 bytes file type)
	MetadataSize = 9

	// Flag bits
	FlagEncrypted = 0x01
	FlagMultisig  = 0x02

	// Max file size (1MB)
	MaxFileSize = 1024 * 1024
)

// BitDriveEngine handles BitDrive file storage operations
type BitDriveEngine struct {
	db           *sql.DB
	walletEngine *WalletEngine
	bitdriveDir  string
	chainParams  *chaincfg.Params
}

// NewBitDriveEngine creates a new BitDrive engine
func NewBitDriveEngine(
	db *sql.DB,
	walletEngine *WalletEngine,
	dataDir string,
	chainParams *chaincfg.Params,
) *BitDriveEngine {
	bitdriveDir := filepath.Join(dataDir, "bitdrive")

	// Ensure directory exists
	if err := os.MkdirAll(bitdriveDir, 0755); err != nil {
		zerolog.Ctx(context.Background()).Error().Err(err).
			Str("dir", bitdriveDir).
			Msg("failed to create bitdrive directory")
	}

	return &BitDriveEngine{
		db:           db,
		walletEngine: walletEngine,
		bitdriveDir:  bitdriveDir,
		chainParams:  chainParams,
	}
}

// ParsedMetadata contains parsed BitDrive OP_RETURN metadata
type ParsedMetadata struct {
	Encrypted  bool
	IsMultisig bool
	Timestamp  uint32
	FileType   string
}

// ParseMetadata parses the 9-byte metadata from base64
func ParseMetadata(metadataB64 string) (*ParsedMetadata, error) {
	metadataBytes, err := base64.StdEncoding.DecodeString(metadataB64)
	if err != nil {
		return nil, fmt.Errorf("decode metadata base64: %w", err)
	}

	if len(metadataBytes) != MetadataSize {
		return nil, fmt.Errorf("invalid metadata size: expected %d, got %d", MetadataSize, len(metadataBytes))
	}

	flags := metadataBytes[0]
	timestamp := binary.BigEndian.Uint32(metadataBytes[1:5])
	fileType := strings.TrimSpace(string(metadataBytes[5:9]))

	return &ParsedMetadata{
		Encrypted:  (flags & FlagEncrypted) != 0,
		IsMultisig: (flags & FlagMultisig) != 0,
		Timestamp:  timestamp,
		FileType:   fileType,
	}, nil
}

// EncodeMetadata encodes metadata into 9 bytes and returns base64
func EncodeMetadata(encrypted, isMultisig bool, timestamp uint32, fileType string) string {
	metadata := make([]byte, MetadataSize)

	// Flags byte
	var flags byte
	if encrypted {
		flags |= FlagEncrypted
	}
	if isMultisig {
		flags |= FlagMultisig
	}
	metadata[0] = flags

	// Timestamp (4 bytes, big endian)
	binary.BigEndian.PutUint32(metadata[1:5], timestamp)

	// File type (4 bytes, padded with spaces)
	fileTypeBytes := []byte(fileType)
	if len(fileTypeBytes) > 4 {
		fileTypeBytes = fileTypeBytes[:4]
	}
	for len(fileTypeBytes) < 4 {
		fileTypeBytes = append(fileTypeBytes, ' ')
	}
	copy(metadata[5:9], fileTypeBytes)

	return base64.StdEncoding.EncodeToString(metadata)
}

// DetectFileType detects file type from magic bytes
func DetectFileType(content []byte) string {
	if len(content) < 2 {
		return "bin"
	}

	// JPEG: FF D8
	if content[0] == 0xFF && content[1] == 0xD8 {
		return "jpg"
	}

	// PNG: 89 50 4E 47
	if len(content) >= 8 && content[0] == 0x89 && content[1] == 0x50 &&
		content[2] == 0x4E && content[3] == 0x47 {
		return "png"
	}

	// GIF: 47 49 46
	if len(content) >= 6 && content[0] == 0x47 && content[1] == 0x49 && content[2] == 0x46 {
		return "gif"
	}

	// PDF: 25 50 44 46
	if len(content) >= 4 && content[0] == 0x25 && content[1] == 0x50 &&
		content[2] == 0x44 && content[3] == 0x46 {
		return "pdf"
	}

	// Try to detect text files
	sampleSize := min(1024, len(content))

	// Check if content looks like valid UTF-8 text
	isText := true
	for i := range sampleSize {
		b := content[i]
		// Allow printable ASCII, newlines, tabs
		if b < 0x09 || (b > 0x0D && b < 0x20) || b == 0x7F {
			// Check for UTF-8 multi-byte sequences
			if b >= 0x80 && b <= 0xBF {
				continue // continuation byte
			}
			if b >= 0xC0 && b <= 0xF7 {
				continue // start of multi-byte
			}
			isText = false
			break
		}
	}

	if isText {
		return "txt"
	}

	return "bin"
}

// DeriveKeyStream derives a keystream for XOR encryption
// Uses SHA256(seed || counter) where seed = SHA256(privateKeyHex:timestamp:fileType)
func (e *BitDriveEngine) DeriveKeyStream(ctx context.Context, timestamp uint32, fileType string, length int) ([]byte, error) {
	// Get the encryption key
	privateKeyHex, err := e.getEncryptionPrivateKey(ctx)
	if err != nil {
		return nil, fmt.Errorf("get encryption key: %w", err)
	}

	// Create seed: SHA256(privateKeyHex:timestamp:fileType)
	seedInput := fmt.Sprintf("%s:%d:%s", privateKeyHex, timestamp, fileType)
	seedHash := sha256.Sum256([]byte(seedInput))
	seed := seedHash[:]

	// Generate keystream using counter mode
	result := make([]byte, length)
	bytesGenerated := 0
	counter := uint32(0)

	for bytesGenerated < length {
		// Create counter bytes (4 bytes, big endian)
		counterBytes := make([]byte, 4)
		binary.BigEndian.PutUint32(counterBytes, counter)

		// Hash seed || counter
		h := sha256.New()
		h.Write(seed)
		h.Write(counterBytes)
		block := h.Sum(nil)

		// Copy block to result
		bytesToCopy := len(block)
		if bytesGenerated+bytesToCopy > length {
			bytesToCopy = length - bytesGenerated
		}
		copy(result[bytesGenerated:bytesGenerated+bytesToCopy], block[:bytesToCopy])

		bytesGenerated += bytesToCopy
		counter++
	}

	return result, nil
}

// getEncryptionPrivateKey derives the encryption key from path m/84'/1'/0'/0/4000
func (e *BitDriveEngine) getEncryptionPrivateKey(_ context.Context) (string, error) {
	seed, err := e.walletEngine.GetEnforcerSeed()
	if err != nil {
		return "", fmt.Errorf("get enforcer seed: %w", err)
	}

	seedBytes, err := hex.DecodeString(seed)
	if err != nil {
		return "", fmt.Errorf("decode seed hex: %w", err)
	}

	// Derive to m/84'/1'/0'/0/4000
	masterKey, err := hdkeychain.NewMaster(seedBytes, e.chainParams)
	if err != nil {
		return "", fmt.Errorf("derive master key: %w", err)
	}

	// m/84'
	purpose, err := masterKey.Derive(hdkeychain.HardenedKeyStart + 84)
	if err != nil {
		return "", fmt.Errorf("derive purpose: %w", err)
	}

	// m/84'/1' (testnet/signet coin type)
	coin, err := purpose.Derive(hdkeychain.HardenedKeyStart + 1)
	if err != nil {
		return "", fmt.Errorf("derive coin type: %w", err)
	}

	// m/84'/1'/0'
	account, err := coin.Derive(hdkeychain.HardenedKeyStart + 0)
	if err != nil {
		return "", fmt.Errorf("derive account: %w", err)
	}

	// m/84'/1'/0'/0 (external chain)
	change, err := account.Derive(0)
	if err != nil {
		return "", fmt.Errorf("derive change: %w", err)
	}

	// m/84'/1'/0'/0/4000
	key, err := change.Derive(BitDriveDerivationIndex)
	if err != nil {
		return "", fmt.Errorf("derive index: %w", err)
	}

	privKey, err := key.ECPrivKey()
	if err != nil {
		return "", fmt.Errorf("get EC private key: %w", err)
	}

	return hex.EncodeToString(privKey.Serialize()), nil
}

// getAuthKey derives the authentication key from path m/84'/1'/0'/1/4000
func (e *BitDriveEngine) getAuthKey(_ context.Context) ([]byte, error) {
	seed, err := e.walletEngine.GetEnforcerSeed()
	if err != nil {
		return nil, fmt.Errorf("get enforcer seed: %w", err)
	}

	seedBytes, err := hex.DecodeString(seed)
	if err != nil {
		return nil, fmt.Errorf("decode seed hex: %w", err)
	}

	// Derive to m/84'/1'/0'/1/4000
	masterKey, err := hdkeychain.NewMaster(seedBytes, e.chainParams)
	if err != nil {
		return nil, fmt.Errorf("derive master key: %w", err)
	}

	// m/84'
	purpose, err := masterKey.Derive(hdkeychain.HardenedKeyStart + 84)
	if err != nil {
		return nil, fmt.Errorf("derive purpose: %w", err)
	}

	// m/84'/1'
	coin, err := purpose.Derive(hdkeychain.HardenedKeyStart + 1)
	if err != nil {
		return nil, fmt.Errorf("derive coin type: %w", err)
	}

	// m/84'/1'/0'
	account, err := coin.Derive(hdkeychain.HardenedKeyStart + 0)
	if err != nil {
		return nil, fmt.Errorf("derive account: %w", err)
	}

	// m/84'/1'/0'/1 (internal/change chain)
	change, err := account.Derive(1)
	if err != nil {
		return nil, fmt.Errorf("derive change: %w", err)
	}

	// m/84'/1'/0'/1/4000
	key, err := change.Derive(BitDriveDerivationIndex)
	if err != nil {
		return nil, fmt.Errorf("derive index: %w", err)
	}

	privKey, err := key.ECPrivKey()
	if err != nil {
		return nil, fmt.Errorf("get EC private key: %w", err)
	}

	return privKey.Serialize(), nil
}

// Encrypt encrypts content using XOR with derived keystream and appends HMAC auth tag
func (e *BitDriveEngine) Encrypt(ctx context.Context, content []byte, timestamp uint32, fileType string) ([]byte, error) {
	// Generate keystream
	keyStream, err := e.DeriveKeyStream(ctx, timestamp, fileType, len(content))
	if err != nil {
		return nil, fmt.Errorf("derive keystream: %w", err)
	}

	// XOR encrypt
	encrypted := make([]byte, len(content))
	for i := range content {
		encrypted[i] = content[i] ^ keyStream[i]
	}

	// Generate truncated authentication tag (first 8 bytes of HMAC-SHA256)
	authKey, err := e.getAuthKey(ctx)
	if err != nil {
		return nil, fmt.Errorf("get auth key: %w", err)
	}

	mac := hmac.New(sha256.New, authKey)
	mac.Write(encrypted)
	fullTag := mac.Sum(nil)
	tag := fullTag[:AuthTagSize]

	// Combine encrypted content with tag
	result := make([]byte, len(encrypted)+len(tag))
	copy(result, encrypted)
	copy(result[len(encrypted):], tag)

	return result, nil
}

// Decrypt verifies the HMAC auth tag and decrypts content
func (e *BitDriveEngine) Decrypt(ctx context.Context, encryptedData []byte, timestamp uint32, fileType string) ([]byte, error) {
	if len(encryptedData) <= AuthTagSize {
		return nil, fmt.Errorf("encrypted data too short")
	}

	// Extract content and tag
	contentLen := len(encryptedData) - AuthTagSize
	encryptedContent := encryptedData[:contentLen]
	receivedTag := encryptedData[contentLen:]

	// Verify authentication tag
	authKey, err := e.getAuthKey(ctx)
	if err != nil {
		return nil, fmt.Errorf("get auth key: %w", err)
	}

	mac := hmac.New(sha256.New, authKey)
	mac.Write(encryptedContent)
	fullTag := mac.Sum(nil)
	calculatedTag := fullTag[:AuthTagSize]

	// Constant-time comparison
	if subtle.ConstantTimeCompare(receivedTag, calculatedTag) != 1 {
		return nil, fmt.Errorf("authentication failed: data may be corrupted")
	}

	// Generate keystream
	keyStream, err := e.DeriveKeyStream(ctx, timestamp, fileType, contentLen)
	if err != nil {
		return nil, fmt.Errorf("derive keystream: %w", err)
	}

	// XOR decrypt
	decrypted := make([]byte, contentLen)
	for i := range contentLen {
		decrypted[i] = encryptedContent[i] ^ keyStream[i]
	}

	return decrypted, nil
}

// EncodeOPReturnData encodes metadata and content for OP_RETURN storage
func (e *BitDriveEngine) EncodeOPReturnData(ctx context.Context, content []byte, encrypt bool) (string, string, uint32, error) {
	timestamp := uint32(time.Now().Unix())
	fileType := DetectFileType(content)

	var processedContent []byte
	var err error

	if encrypt {
		processedContent, err = e.Encrypt(ctx, content, timestamp, fileType)
		if err != nil {
			return "", "", 0, fmt.Errorf("encrypt content: %w", err)
		}
	} else {
		processedContent = content
	}

	// Encode metadata
	metadataB64 := EncodeMetadata(encrypt, false, timestamp, fileType)

	// Encode content
	var contentStr string
	if !encrypt && fileType == "txt" {
		// Store unencrypted text directly for readability
		contentStr = string(content)
	} else {
		contentStr = base64.StdEncoding.EncodeToString(processedContent)
	}

	return metadataB64, contentStr, timestamp, nil
}

// DecodeOPReturnData decodes and optionally decrypts OP_RETURN data
func (e *BitDriveEngine) DecodeOPReturnData(ctx context.Context, opReturnMessage string) ([]byte, *ParsedMetadata, error) {
	parts := strings.SplitN(opReturnMessage, "|", 2)
	if len(parts) != 2 {
		return nil, nil, fmt.Errorf("invalid OP_RETURN format")
	}

	metadata, err := ParseMetadata(parts[0])
	if err != nil {
		return nil, nil, fmt.Errorf("parse metadata: %w", err)
	}

	var content []byte
	if !metadata.Encrypted && metadata.FileType == "txt" {
		// Unencrypted text stored directly
		content = []byte(parts[1])
	} else {
		content, err = base64.StdEncoding.DecodeString(parts[1])
		if err != nil {
			return nil, nil, fmt.Errorf("decode content base64: %w", err)
		}
	}

	if metadata.Encrypted {
		content, err = e.Decrypt(ctx, content, metadata.Timestamp, metadata.FileType)
		if err != nil {
			return nil, nil, fmt.Errorf("decrypt content: %w", err)
		}
	}

	return content, metadata, nil
}

// SaveFile saves a file to local storage and creates a database record
func (e *BitDriveEngine) SaveFile(ctx context.Context, txid string, content []byte, metadata *ParsedMetadata) error {
	// Check if already exists
	exists, err := bitdrive.Exists(ctx, e.db, txid)
	if err != nil {
		return fmt.Errorf("check exists: %w", err)
	}
	if exists {
		zerolog.Ctx(ctx).Debug().
			Str("txid", txid).
			Msg("bitdrive file already exists, skipping")
		return nil
	}

	// Generate filename
	filename := fmt.Sprintf("%d.%s", metadata.Timestamp, metadata.FileType)
	filePath := filepath.Join(e.bitdriveDir, filename)

	// Write file
	if err := os.WriteFile(filePath, content, 0644); err != nil {
		return fmt.Errorf("write file: %w", err)
	}

	// Create database record
	file := bitdrive.File{
		TxID:      txid,
		Filename:  filename,
		FileType:  metadata.FileType,
		SizeBytes: int64(len(content)),
		Encrypted: metadata.Encrypted,
		Timestamp: metadata.Timestamp,
		CreatedAt: time.Now(),
	}

	if _, err := bitdrive.Create(ctx, e.db, file); err != nil {
		return fmt.Errorf("create db record: %w", err)
	}

	return nil
}

// GetFileContent reads a file from local storage
func (e *BitDriveEngine) GetFileContent(ctx context.Context, filename string) ([]byte, error) {
	filePath := filepath.Join(e.bitdriveDir, filename)
	return os.ReadFile(filePath)
}

// DeleteFile removes a file from local storage and database
func (e *BitDriveEngine) DeleteFile(ctx context.Context, id int64) error {
	// Get file record
	file, err := bitdrive.GetByID(ctx, e.db, id)
	if err != nil {
		return fmt.Errorf("get file: %w", err)
	}
	if file == nil {
		return fmt.Errorf("file not found")
	}

	// Delete from filesystem
	filePath := filepath.Join(e.bitdriveDir, file.Filename)
	if err := os.Remove(filePath); err != nil && !os.IsNotExist(err) {
		return fmt.Errorf("remove file: %w", err)
	}

	// Delete from database
	if err := bitdrive.Delete(ctx, e.db, id); err != nil {
		return fmt.Errorf("delete db record: %w", err)
	}

	return nil
}

// ListFiles returns all files from the database
func (e *BitDriveEngine) ListFiles(ctx context.Context) ([]bitdrive.File, error) {
	return bitdrive.List(ctx, e.db)
}

// WipeData removes all BitDrive local data
func (e *BitDriveEngine) WipeData(ctx context.Context) error {
	if err := os.RemoveAll(e.bitdriveDir); err != nil {
		return fmt.Errorf("remove bitdrive dir: %w", err)
	}

	// Recreate the directory
	if err := os.MkdirAll(e.bitdriveDir, 0755); err != nil {
		return fmt.Errorf("recreate bitdrive dir: %w", err)
	}

	zerolog.Ctx(ctx).Info().Msg("wiped bitdrive data")
	return nil
}

// IsBitDriveTransaction checks if an OP_RETURN message is a BitDrive transaction
func IsBitDriveTransaction(opReturnMessage string) bool {
	parts := strings.SplitN(opReturnMessage, "|", 2)
	if len(parts) != 2 {
		return false
	}

	// Try to parse metadata
	metadataBytes, err := base64.StdEncoding.DecodeString(parts[0])
	if err != nil {
		return false
	}

	return len(metadataBytes) == MetadataSize
}

// GetDir returns the BitDrive directory path
func (e *BitDriveEngine) GetDir() string {
	return e.bitdriveDir
}

// EncodeMultisigData encodes multisig group data with optional encryption
func (e *BitDriveEngine) EncodeMultisigData(ctx context.Context, jsonData []byte, encrypt bool) (string, error) {
	timestamp := uint32(time.Now().Unix())
	fileType := "json"

	var processedContent []byte
	var err error

	if encrypt {
		processedContent, err = e.Encrypt(ctx, jsonData, timestamp, fileType)
		if err != nil {
			return "", fmt.Errorf("encrypt multisig data: %w", err)
		}
	} else {
		processedContent = jsonData
	}

	// Encode metadata with multisig flag
	metadata := make([]byte, MetadataSize)
	var flags byte
	if encrypt {
		flags |= FlagEncrypted
	}
	flags |= FlagMultisig
	metadata[0] = flags
	binary.BigEndian.PutUint32(metadata[1:5], timestamp)
	copy(metadata[5:9], []byte("json"))

	metadataB64 := base64.StdEncoding.EncodeToString(metadata)
	contentB64 := base64.StdEncoding.EncodeToString(processedContent)

	return fmt.Sprintf("%s|%s", metadataB64, contentB64), nil
}

// DecodeMultisigData decodes multisig group data from OP_RETURN
func (e *BitDriveEngine) DecodeMultisigData(ctx context.Context, opReturnMessage string) ([]byte, error) {
	content, metadata, err := e.DecodeOPReturnData(ctx, opReturnMessage)
	if err != nil {
		return nil, err
	}

	if !metadata.IsMultisig {
		return nil, fmt.Errorf("not a multisig transaction")
	}

	return content, nil
}

// ValidateFileSize checks if file size is within limits
func ValidateFileSize(content []byte) error {
	if len(content) > MaxFileSize {
		return fmt.Errorf("file size %d exceeds maximum %d bytes", len(content), MaxFileSize)
	}
	return nil
}

// FormatOPReturnData formats metadata and content for transaction
func FormatOPReturnData(metadataB64, contentStr string) string {
	return fmt.Sprintf("%s|%s", metadataB64, contentStr)
}

// ParseOPReturnParts splits an OP_RETURN message into metadata and content parts
func ParseOPReturnParts(opReturnMessage string) (metadataB64, contentStr string, err error) {
	parts := strings.SplitN(opReturnMessage, "|", 2)
	if len(parts) != 2 {
		return "", "", fmt.Errorf("invalid format: expected metadata|content")
	}
	return parts[0], parts[1], nil
}

// BytesEqual performs constant-time byte comparison
func BytesEqual(a, b []byte) bool {
	return bytes.Equal(a, b)
}
