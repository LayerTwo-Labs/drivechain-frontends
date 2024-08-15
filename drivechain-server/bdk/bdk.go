package bdk

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"os/exec"
	"slices"
	"strings"
	"time"

	"github.com/btcsuite/btcd/btcutil"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"github.com/tidwall/gjson"
)

type Wallet struct {
	Descriptor string
	Network    string
	Datadir    string
	Electrum   string
}

func (w *Wallet) exec(ctx context.Context, args ...string) ([]byte, error) {
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

	cmd := exec.CommandContext(ctx, "bdk-cli", fullArgs...)

	// TODO: check for bdk-cli bin existence
	res, err := cmd.CombinedOutput()
	if err != nil {
		errorMessage := err.Error()
		if exitErr, ok := lo.ErrorsAs[*exec.ExitError](err); ok {
			errorMessage = string(exitErr.Stderr)
		}

		return nil, fmt.Errorf("exec: bdk-cli wallet %q: %s",
			command, errorMessage,
		)
	}

	zerolog.Ctx(ctx).Trace().
		Stringer("duration", time.Since(start)).
		Msgf("bdk-cli wallet %s: %s",
			command, string(res),
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
	_, err := w.exec(ctx, "sync")
	return err
}

func (w *Wallet) GetNewAddress(ctx context.Context) (string, error) {
	res, err := w.exec(ctx, "get_new_address")
	if err != nil {
		return "", err
	}

	return gjson.GetBytes(res, "address").String(), nil
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

	return Balance{}, err
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
