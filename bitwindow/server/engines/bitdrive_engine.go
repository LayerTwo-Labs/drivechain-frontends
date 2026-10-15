package engines

import (
	"context"
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"crypto/subtle"
	"database/sql"
	"encoding/base64"
	"encoding/binary"
	"encoding/hex"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strings"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/bitdrive"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/opreturns"
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

	// Per-file random nonce size (bytes). Prepended to the ciphertext body and
	// mixed into the keystream seed so two files sharing a timestamp and file
	// type never reuse the XOR keystream (two-time pad).
	NonceSize = 16

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
) (*BitDriveEngine, error) {
	bitdriveDir := filepath.Join(dataDir, "bitdrive")
	if err := os.MkdirAll(bitdriveDir, 0755); err != nil {
		return nil, fmt.Errorf("create bitdrive dir %s: %w", bitdriveDir, err)
	}

	return &BitDriveEngine{
		db:           db,
		walletEngine: walletEngine,
		bitdriveDir:  bitdriveDir,
		chainParams:  chainParams,
	}, nil
}

// ParsedMetadata contains parsed BitDrive OP_RETURN metadata
type ParsedMetadata struct {
	Encrypted  bool
	IsMultisig bool
	Timestamp  uint32
	FileType   string

	// Raw is the exact 9-byte metadata this was parsed from. Encrypt/Decrypt
	// authenticate these bytes, so tampering with the flags, timestamp or file
	// type fails the auth tag instead of silently decrypting to garbage.
	Raw []byte
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
		Raw:        metadataBytes,
	}, nil
}

// EncodeMetadata encodes metadata into 9 bytes and returns base64
func EncodeMetadata(encrypted, isMultisig bool, timestamp uint32, fileType string) string {
	return base64.StdEncoding.EncodeToString(EncodeMetadataBytes(encrypted, isMultisig, timestamp, fileType))
}

// EncodeMetadataBytes encodes metadata into its 9-byte on-chain representation
func EncodeMetadataBytes(encrypted, isMultisig bool, timestamp uint32, fileType string) []byte {
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

	return metadata
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

	// Every byte must be checked, not a leading sample: "txt" is stored raw and
	// retrieval hex-encodes anything above 0x7E, breaking the content framing.
	for _, b := range content {
		if b < 0x09 || (b > 0x0D && b < 0x20) || b >= 0x7F {
			return "bin"
		}
	}

	return "txt"
}

// DeriveKeyStream derives a keystream for XOR encryption
// Uses SHA256(seed || counter) where seed = SHA256(privateKeyHex:timestamp:fileType: || nonce).
// The per-file random nonce guarantees that two files sharing a timestamp and
// file type never derive the same keystream.
func (e *BitDriveEngine) DeriveKeyStream(ctx context.Context, nonce []byte, timestamp uint32, fileType string, length int) ([]byte, error) {
	// Get the encryption key
	privateKeyHex, err := e.getEncryptionPrivateKey(ctx)
	if err != nil {
		return nil, fmt.Errorf("get encryption key: %w", err)
	}

	// Create seed: SHA256(privateKeyHex:timestamp:fileType: || nonce)
	seedInput := fmt.Sprintf("%s:%d:%s:", privateKeyHex, timestamp, fileType)
	seedHasher := sha256.New()
	seedHasher.Write([]byte(seedInput))
	seedHasher.Write(nonce)
	seed := seedHasher.Sum(nil)

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
	seed, err := e.walletEngine.GetStarterSeed()
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
	seed, err := e.walletEngine.GetStarterSeed()
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

// Encrypt encrypts content using XOR with derived keystream and appends HMAC auth tag.
// The output layout is: nonce (NonceSize) || ciphertext || tag (AuthTagSize). The
// random per-file nonce is mixed into the keystream so repeated (timestamp, fileType)
// tuples never reuse the keystream. metadata is the 9-byte metadata prefix that
// travels alongside the ciphertext; it is authenticated as associated data because
// the keystream is derived from the timestamp and file type it carries.
func (e *BitDriveEngine) Encrypt(ctx context.Context, content []byte, timestamp uint32, fileType string, metadata []byte) ([]byte, error) {
	// Generate a random per-file nonce
	nonce := make([]byte, NonceSize)
	if _, err := rand.Read(nonce); err != nil {
		return nil, fmt.Errorf("generate nonce: %w", err)
	}

	// Generate keystream
	keyStream, err := e.DeriveKeyStream(ctx, nonce, timestamp, fileType, len(content))
	if err != nil {
		return nil, fmt.Errorf("derive keystream: %w", err)
	}

	// XOR encrypt
	encrypted := make([]byte, len(content))
	for i := range content {
		encrypted[i] = content[i] ^ keyStream[i]
	}

	tag, err := e.authTag(ctx, metadata, nonce, encrypted)
	if err != nil {
		return nil, err
	}

	// Combine nonce, encrypted content, and tag
	result := make([]byte, NonceSize+len(encrypted)+len(tag))
	copy(result, nonce)
	copy(result[NonceSize:], encrypted)
	copy(result[NonceSize+len(encrypted):], tag)

	return result, nil
}

// Decrypt verifies the HMAC auth tag and decrypts content. metadata must be the
// 9-byte metadata prefix the ciphertext arrived with: it is authenticated as
// associated data, so a tampered timestamp or file type is rejected rather than
// feeding a wrong keystream seed into DeriveKeyStream.
func (e *BitDriveEngine) Decrypt(ctx context.Context, encryptedData []byte, timestamp uint32, fileType string, metadata []byte) ([]byte, error) {
	if len(encryptedData) <= NonceSize+AuthTagSize {
		return nil, fmt.Errorf("encrypted data too short")
	}

	// Extract nonce, content, and tag
	nonce := encryptedData[:NonceSize]
	contentLen := len(encryptedData) - NonceSize - AuthTagSize
	encryptedContent := encryptedData[NonceSize : NonceSize+contentLen]
	receivedTag := encryptedData[NonceSize+contentLen:]

	calculatedTag, err := e.authTag(ctx, metadata, nonce, encryptedContent)
	if err != nil {
		return nil, err
	}

	// Constant-time comparison
	if subtle.ConstantTimeCompare(receivedTag, calculatedTag) != 1 {
		return nil, fmt.Errorf("authentication failed: data may be corrupted")
	}

	// Generate keystream
	keyStream, err := e.DeriveKeyStream(ctx, nonce, timestamp, fileType, contentLen)
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

// authTag is the first AuthTagSize bytes of an HMAC-SHA256 over the metadata,
// nonce and ciphertext. All three are fixed-length or trailing, so the
// concatenation is unambiguous.
func (e *BitDriveEngine) authTag(ctx context.Context, metadata, nonce, ciphertext []byte) ([]byte, error) {
	authKey, err := e.getAuthKey(ctx)
	if err != nil {
		return nil, fmt.Errorf("get auth key: %w", err)
	}

	mac := hmac.New(sha256.New, authKey)
	mac.Write(metadata)
	mac.Write(nonce)
	mac.Write(ciphertext)
	return mac.Sum(nil)[:AuthTagSize], nil
}

// EncodeOPReturnData encodes metadata and content for OP_RETURN storage
func (e *BitDriveEngine) EncodeOPReturnData(ctx context.Context, content []byte, encrypt bool) (string, string, uint32, error) {
	return e.encodeContent(ctx, content, encrypt, false, DetectFileType(content))
}

// encodeContent returns the base64 metadata, the content part and the
// timestamp of a BitDrive OP_RETURN message.
func (e *BitDriveEngine) encodeContent(
	ctx context.Context, content []byte, encrypt, isMultisig bool, fileType string,
) (string, string, uint32, error) {
	timestamp := uint32(time.Now().Unix())

	// Encode metadata up front so it can be authenticated with the ciphertext
	metadataBytes := EncodeMetadataBytes(encrypt, isMultisig, timestamp, fileType)
	metadataB64 := base64.StdEncoding.EncodeToString(metadataBytes)

	if !encrypt && fileType == "txt" {
		// Store unencrypted text directly for readability
		return metadataB64, string(content), timestamp, nil
	}

	processedContent := content
	if encrypt {
		var err error
		processedContent, err = e.Encrypt(ctx, content, timestamp, fileType, metadataBytes)
		if err != nil {
			return "", "", 0, fmt.Errorf("encrypt content: %w", err)
		}
	}

	return metadataB64, base64.StdEncoding.EncodeToString(processedContent), timestamp, nil
}

// DecodeOPReturnData decodes and optionally decrypts OP_RETURN data
func (e *BitDriveEngine) DecodeOPReturnData(ctx context.Context, opReturnMessage string) ([]byte, *ParsedMetadata, error) {
	metadataB64, contentStr, err := ParseOPReturnParts(opReturnMessage)
	if err != nil {
		return nil, nil, err
	}

	metadata, err := ParseMetadata(metadataB64)
	if err != nil {
		return nil, nil, fmt.Errorf("parse metadata: %w", err)
	}

	var content []byte
	if !metadata.Encrypted && metadata.FileType == "txt" {
		// Unencrypted text stored directly
		content = []byte(contentStr)
	} else {
		content, err = base64.StdEncoding.DecodeString(contentStr)
		if err != nil {
			return nil, nil, fmt.Errorf("decode content base64: %w", err)
		}
	}

	if metadata.Encrypted {
		content, err = e.Decrypt(ctx, content, metadata.Timestamp, metadata.FileType, metadata.Raw)
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

	// Generate filename. The txid is included so that two distinct
	// transactions sharing the same timestamp and file type do not collide
	// on the same local path and overwrite each other.
	filename := fmt.Sprintf("%d_%s.%s", metadata.Timestamp, txid, metadata.FileType)
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

// PendingBitDriveFile is a BitDrive OP_RETURN that has no local file.
type PendingBitDriveFile struct {
	OPReturn opreturns.OPReturn
	Metadata *ParsedMetadata
}

// ScanForFiles finds the BitDrive OP_RETURNs that have no local file. It also
// gives the count of BitDrive OP_RETURNs it read. It skips multisig data.
func (e *BitDriveEngine) ScanForFiles(ctx context.Context) ([]PendingBitDriveFile, int, error) {
	log := zerolog.Ctx(ctx)

	allOpReturns, err := opreturns.List(ctx, e.db, 0)
	if err != nil {
		return nil, 0, fmt.Errorf("list OP_RETURNs: %w", err)
	}

	var pending []PendingBitDriveFile
	scanned := 0
	for _, opReturn := range allOpReturns {
		opReturnMessage := opreturns.OPReturnToReadable(opReturn.Data)
		if !IsBitDriveTransaction(opReturnMessage) {
			continue
		}
		scanned++

		metadataB64, _, err := ParseOPReturnParts(opReturnMessage)
		if err != nil {
			log.Warn().Err(err).Str("txid", opReturn.TxID).Msg("skip BitDrive OP_RETURN with bad parts")
			continue
		}
		metadata, err := ParseMetadata(metadataB64)
		if err != nil {
			log.Warn().Err(err).Str("txid", opReturn.TxID).Msg("skip BitDrive OP_RETURN with bad metadata")
			continue
		}
		if metadata.IsMultisig {
			continue
		}

		exists, err := bitdrive.Exists(ctx, e.db, opReturn.TxID)
		if err != nil {
			return nil, 0, fmt.Errorf("check file %s: %w", opReturn.TxID, err)
		}
		if exists {
			continue
		}

		pending = append(pending, PendingBitDriveFile{OPReturn: opReturn, Metadata: metadata})
	}

	log.Info().
		Int("pending", len(pending)).
		Int("total_scanned", scanned).
		Msg("scanned for BitDrive files")

	return pending, scanned, nil
}

// DownloadPendingFiles saves each file that ScanForFiles finds. It gives the
// counts of saved and failed files.
func (e *BitDriveEngine) DownloadPendingFiles(ctx context.Context) (uint32, uint32, error) {
	log := zerolog.Ctx(ctx)

	pending, _, err := e.ScanForFiles(ctx)
	if err != nil {
		return 0, 0, fmt.Errorf("scan for files: %w", err)
	}

	var downloaded, failed uint32
	for _, p := range pending {
		txid := p.OPReturn.TxID
		content, metadata, err := e.DecodeOPReturnData(ctx, opreturns.OPReturnToReadable(p.OPReturn.Data))
		if err != nil {
			log.Warn().Err(err).Str("txid", txid).Msg("failed to decode content")
			failed++
			continue
		}

		if err := e.SaveFile(ctx, txid, content, metadata); err != nil {
			log.Warn().Err(err).Str("txid", txid).Msg("failed to save file")
			failed++
			continue
		}

		downloaded++
	}

	log.Info().
		Uint32("downloaded", downloaded).
		Uint32("failed", failed).
		Msg("downloaded pending BitDrive files")

	return downloaded, failed, nil
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
	metadataB64, _, err := ParseOPReturnParts(opReturnMessage)
	if err != nil {
		return false
	}

	_, err = ParseMetadata(metadataB64)
	return err == nil
}

// GetDir returns the BitDrive directory path
func (e *BitDriveEngine) GetDir() string {
	return e.bitdriveDir
}

// OpenDir opens the BitDrive directory in the OS file manager.
func (e *BitDriveEngine) OpenDir(ctx context.Context) error {
	dir := e.bitdriveDir

	// Ensure the directory exists before trying to open it.
	if err := os.MkdirAll(dir, 0755); err != nil {
		return fmt.Errorf("ensure bitdrive dir: %w", err)
	}

	name, args := dirOpenCommand(dir)

	log := zerolog.Ctx(ctx).With().Str("cmd", name).Strs("args", args).Logger()
	log.Info().Msg("opening bitdrive directory")

	// The RPC context ends at handler return, so a CommandContext kills the opener.
	cmd := exec.Command(name, args...)
	if err := cmd.Start(); err != nil {
		return fmt.Errorf("open directory: %w", err)
	}
	go func() {
		if err := cmd.Wait(); err != nil {
			log.Warn().Err(err).Msg("bitdrive directory opener exited with error")
		}
	}()

	return nil
}

var dirOpenCommand = func(dir string) (string, []string) {
	switch runtime.GOOS {
	case "darwin":
		return "open", []string{dir}
	case "windows":
		return "explorer", []string{strings.ReplaceAll(dir, "/", "\\")}
	default:
		return "xdg-open", []string{dir}
	}
}

// EncodeMultisigData encodes multisig group data with optional encryption
func (e *BitDriveEngine) EncodeMultisigData(ctx context.Context, jsonData []byte, encrypt bool) (string, error) {
	metadataB64, contentStr, _, err := e.encodeContent(ctx, jsonData, encrypt, true, "json")
	if err != nil {
		return "", err
	}
	return FormatOPReturnData(metadataB64, contentStr), nil
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
