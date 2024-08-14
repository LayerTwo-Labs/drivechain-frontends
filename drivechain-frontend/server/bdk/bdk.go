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

	command := lo.FirstOrEmpty(args)
	if command == "" {
		return nil, errors.New("bdk: exec: empty command")
	}

	cmd := exec.CommandContext(ctx, "bdk-cli", fullArgs...)

	// TODO: check for bdk-cli bin existence
	res, err := cmd.CombinedOutput()
	if err != nil {
		return nil, fmt.Errorf("exec: bdk-cli wallet %q: %w",
			command, err,
		)
	}

	zerolog.Ctx(ctx).Trace().
		Msgf("bdk-cli wallet %s: %s in %s",
			command, string(res), time.Since(start),
		)

	// https://github.com/bitcoindevkit/bdk-cli/issues/170
	if json.Unmarshal(res, new(struct{})) != nil {
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
