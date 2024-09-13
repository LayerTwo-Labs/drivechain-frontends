package bdk

import (
	"bytes"
	"context"
	"embed"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"slices"
	"strings"
	"sync"
	"time"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"github.com/tidwall/gjson"

	"crypto/aes"
	"crypto/cipher"
	"crypto/rand"
	"io"

	"golang.org/x/crypto/scrypt"
)

//go:embed bin/*
var bdkCliBinary embed.FS

var (
	bdkCliPath     string
	bdkCliPathOnce sync.Once
)

type Wallet struct {
	// Ensures only a single access to BDK can happen at the same time
	mu sync.Mutex

	Descriptor string
	Network    string
	Datadir    string
	Electrum   string
}

var validNetworks = []string{
	"bitcoin", // mainnet
	"testnet",
	"signet",
	"regtest",
}

func getBdkCliPath() (string, error) {
	var err error
	bdkCliPathOnce.Do(func() {
		var tempDir string
		tempDir, err = os.MkdirTemp("", "bdk-cli")
		if err != nil {
			return
		}

		var bdkCliBytes []byte
		bdkCliBytes, err = bdkCliBinary.ReadFile("bin/bdk-cli")
		if err != nil {
			return
		}

		bdkCliPath = filepath.Join(tempDir, "bdk-cli")
		err = os.WriteFile(bdkCliPath, bdkCliBytes, 0755)
	})

	if err != nil {
		return "", err
	}

	return bdkCliPath, nil
}

func (w *Wallet) exec(ctx context.Context, args ...string) ([]byte, error) {
	if !slices.Contains(validNetworks, w.Network) {
		return nil, fmt.Errorf("invalid network: %q", w.Network)
	}

	w.mu.Lock()
	defer w.mu.Unlock()

	start := time.Now()

	fullArgs := slices.Concat([]string{
		"--datadir", w.Datadir,
		"--network", w.Network,
		"wallet",
		"--descriptor", w.Descriptor,
		"--server", w.Electrum,
	},
		args,
	)

	command := lo.FirstOrEmpty(lo.Filter(args, func(arg string, idx int) bool {
		return !strings.HasPrefix(arg, "-")
	}))
	if command == "" {
		return nil, errors.New("bdk: exec: empty command")
	}

	bdkCliPath, err := getBdkCliPath()
	if err != nil {
		return nil, fmt.Errorf("failed to get bdk-cli path: %w", err)
	}

	cmd := exec.CommandContext(ctx, bdkCliPath, fullArgs...)

	res, err := cmd.CombinedOutput()
	if err != nil {
		errorMessage := err.Error()
		if exitErr, ok := lo.ErrorsAs[*exec.ExitError](err); ok {
			errorMessage = string(res)
			if len(exitErr.Stderr) != 0 {
				errorMessage = string(exitErr.Stderr)
			}
		}

		zerolog.Ctx(ctx).Err(err).Msgf("exec: %q errored",
			strings.Join(slices.Concat([]string{bdkCliPath}, fullArgs), " "),
		)

		return nil, fmt.Errorf("exec: bdk-cli wallet %q: %s",
			command, errorMessage,
		)
	}

	compacted := bytes.NewBuffer(nil)
	if err := json.Compact(compacted, res); err != nil {
		// Revert back to non-compacted
		compacted = bytes.NewBuffer(res)
	}

	zerolog.Ctx(ctx).Trace().
		Stringer("duration", time.Since(start)).
		Msgf("bdk-cli wallet %s: %s",
			command, compacted.String(),
		)

	// https://github.com/bitcoindevkit/bdk-cli/issues/170
	if !gjson.ValidBytes(res) {
		_, errorMessage, _ := strings.Cut(string(res), "] ")
		errorMessage = strings.TrimSpace(errorMessage)

		return nil, fmt.Errorf("bdk-cli wallet %s errored: %s", command, errorMessage)
	}

	return res, nil
}

func (w *Wallet) Sync(ctx context.Context) error {
	ctx, cancel := context.WithTimeout(ctx, time.Second*5)
	defer cancel()

	_, err := w.exec(ctx, "sync")
	return err
}

// GetNewAddress returns a new unused address from the wallet, as well as
// the index of this address in the wallet descriptor.
func (w *Wallet) GetNewAddress(ctx context.Context) (string, uint, error) {
	// Must include the verbose flag to get the index.
	res, err := w.exec(ctx, "--verbose", "get_new_address")
	if err != nil {
		return "", 0, err
	}

	var parsed struct {
		Address string `json:"address"`
		Index   uint   `json:"index"`
	}

	if err := json.Unmarshal(res, &parsed); err != nil {
		return "", 0, err
	}
	return parsed.Address, parsed.Index, nil
}

type Balance struct {
	Confirmed        btcutil.Amount `json:"confirmed"`
	Immature         btcutil.Amount `json:"immature"`
	TrustedPending   btcutil.Amount `json:"trusted_pending"`
	UntrustedPending btcutil.Amount `json:"untrusted_pending"`
}

func (w *Wallet) GetBalance(ctx context.Context) (Balance, error) {
	res, err := w.exec(ctx, "get_balance")
	if err != nil {
		return Balance{}, err
	}

	var parsed struct {
		Satoshi Balance `json:"satoshi"`
	}
	if err := json.Unmarshal(res, &parsed); err != nil {
		return Balance{}, err
	}

	return parsed.Satoshi, err
}

// CreateTransaction creates a new transaction (but does not do any signing!).
// By default, a 1 sat/vbyte fee rate is used. The bdk-cli wallet has no way
// of fetching fee rates, so this has to be obtained elsewhere.
func (w *Wallet) CreateTransaction(
	ctx context.Context, destinations map[string]btcutil.Amount,
	satsPerVbyte float64,
) (string, error) {
	if len(destinations) == 0 {
		return "", errors.New("empty destinations")
	}

	args := []string{
		"--verbose", "create_tx",
		"--enable_rbf",
		"--fee_rate", fmt.Sprint(satsPerVbyte),
	}
	for dest, amount := range destinations {
		args = append(args, "--to", fmt.Sprintf("%s:%d", dest, amount))
	}

	res, err := w.exec(ctx, args...)
	if err != nil {
		return "", err
	}

	var parsed transactionResult
	if err := json.Unmarshal(res, &parsed); err != nil {
		return "", fmt.Errorf("unmarshal newly created PSBT: %w", err)
	}

	return parsed.PSBT, nil
}

func (w *Wallet) SignTransaction(ctx context.Context, psbt string) (string, error) {
	res, err := w.exec(ctx, "--verbose", "sign", "--psbt", psbt)
	if err != nil {
		return "", err
	}

	var parsed transactionResult
	if err := json.Unmarshal(res, &parsed); err != nil {
		return "", fmt.Errorf("unmarshal signed SBT: %w", err)
	}

	if !parsed.IsFinalized {
		return "", fmt.Errorf("signed PSBT was not finalized: %s", string(res))
	}

	return parsed.PSBT, nil
}

func (w *Wallet) BroadcastTransaction(ctx context.Context, psbt string) (string, error) {
	res, err := w.exec(ctx, "--verbose", "broadcast", "--psbt", psbt)
	if err != nil {
		return "", err
	}

	return gjson.GetBytes(res, "txid").String(), nil
}

func (w *Wallet) ListTransactions(ctx context.Context) ([]Transaction, error) {
	res, err := w.exec(ctx, "--verbose", "list_transactions")
	if err != nil {
		return nil, err
	}

	var txs []Transaction
	if err := json.Unmarshal(res, &txs); err != nil {
		return nil, err
	}

	return txs, nil
}

type transactionDetails struct {
	TXID string `json:"txid"`
}

type transactionResult struct {
	IsFinalized bool                `json:"is_finalized"`
	Details     *transactionDetails `json:"details"` // present in create_tx, not sign?
	PSBT        string              `json:"psbt"`
}

type Transaction struct {
	ConfirmationTime *struct {
		Height    int `json:"height"`
		Timestamp int `json:"timestamp"`
	} `json:"confirmation_time"`
	Fee      btcutil.Amount `json:"fee"`
	Received btcutil.Amount `json:"received"`
	Sent     btcutil.Amount `json:"sent"`
	TXID     string         `json:"txid"`
}

// NewWallet either creates a new wallet or loads an existing one
func NewWallet(datadir, network, electrum, passphrase string) (*Wallet, error) {
	keyFile := filepath.Join(datadir, "wallet.key")
	var xprv string

	if _, err := os.Stat(keyFile); err == nil {
		xprv, err = loadExistingWallet(keyFile, passphrase)
		if err != nil {
			return nil, fmt.Errorf("failed to load existing wallet: %w", err)
		}
	} else {
		xprv, err = createNewWallet(keyFile, passphrase)
		if err != nil {
			return nil, fmt.Errorf("failed to create new wallet: %w", err)
		}
	}

	return &Wallet{
		Descriptor: fmt.Sprintf("wpkh(%s/84h/1h/0h/0/*)", xprv),
		Network:    network,
		Datadir:    datadir,
		Electrum:   electrum,
	}, nil
}

func loadExistingWallet(keyFile, passphrase string) (string, error) {
	encryptedMnemonic, err := os.ReadFile(keyFile)
	if err != nil {
		return "", fmt.Errorf("failed to read existing key file: %w", err)
	}

	mnemonic, err := decryptKey(encryptedMnemonic, passphrase)
	if err != nil {
		return "", fmt.Errorf("failed to decrypt mnemonic: %w", err)
	}

	bdkCliPath, err := getBdkCliPath()
	if err != nil {
		return "", fmt.Errorf("failed to get bdk-cli path: %w", err)
	}

	res, err := exec.Command(bdkCliPath, "key", "restore", "--mnemonic", mnemonic).Output()
	if err != nil {
		return "", fmt.Errorf("failed to restore key: %w", err)
	}

	xprv := gjson.GetBytes(res, "xprv").String()
	if xprv == "" {
		return "", fmt.Errorf("failed to parse xprv from bdk-cli output")
	}

	return xprv, nil
}

func createNewWallet(keyFile, passphrase string) (string, error) {
	bdkCliPath, err := getBdkCliPath()
	if err != nil {
		return "", fmt.Errorf("failed to get bdk-cli path: %w", err)
	}

	res, err := exec.Command(bdkCliPath, "key", "generate").Output()
	if err != nil {
		return "", fmt.Errorf("failed to generate new key: %w", err)
	}

	mnemonic := gjson.GetBytes(res, "mnemonic").String()
	if mnemonic == "" {
		return "", fmt.Errorf("failed to parse mnemonic from bdk-cli output")
	}

	xprv := gjson.GetBytes(res, "xprv").String()
	if xprv == "" {
		return "", fmt.Errorf("failed to parse xprv from bdk-cli output")
	}

	var dataToSave []byte
	if passphrase != "" {
		encryptedMnemonic, err := encryptKey(mnemonic, passphrase)
		if err != nil {
			return "", fmt.Errorf("failed to encrypt mnemonic: %w", err)
		}
		dataToSave = encryptedMnemonic
	} else {
		dataToSave = []byte(mnemonic)
	}

	err = os.WriteFile(keyFile, dataToSave, 0600)
	if err != nil {
		return "", fmt.Errorf("failed to save mnemonic to file: %w", err)
	}

	return xprv, nil
}

func encryptKey(key, passphrase string) ([]byte, error) {
	if passphrase == "" {
		return []byte(key), nil
	}

	salt := make([]byte, 8)
	if _, err := io.ReadFull(rand.Reader, salt); err != nil {
		return nil, err
	}

	key32, err := scrypt.Key([]byte(passphrase), salt, 32768, 8, 1, 32)
	if err != nil {
		return nil, err
	}

	block, err := aes.NewCipher(key32)
	if err != nil {
		return nil, err
	}

	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return nil, err
	}

	nonce := make([]byte, gcm.NonceSize())
	if _, err = io.ReadFull(rand.Reader, nonce); err != nil {
		return nil, err
	}

	ciphertext := gcm.Seal(nil, nonce, []byte(key), nil)
	return append(append(salt, nonce...), ciphertext...), nil
}

func decryptKey(data []byte, passphrase string) (string, error) {
	if passphrase == "" {
		return string(data), nil
	}

	salt := data[:8]
	nonce := data[8:20]
	ciphertext := data[20:]

	key32, err := scrypt.Key([]byte(passphrase), salt, 32768, 8, 1, 32)
	if err != nil {
		return "", err
	}

	block, err := aes.NewCipher(key32)
	if err != nil {
		return "", err
	}

	gcm, err := cipher.NewGCM(block)
	if err != nil {
		return "", err
	}

	plaintext, err := gcm.Open(nil, nonce, ciphertext, nil)
	if err != nil {
		return "", err
	}

	return string(plaintext), nil
}
