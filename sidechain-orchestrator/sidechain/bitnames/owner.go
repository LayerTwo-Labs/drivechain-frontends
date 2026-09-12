package bitnames

import (
	"context"
	"errors"
	"fmt"
)

var errBitNameNotFound = errors.New("no utxo holds the bitname")

// utxoEntry is one entry of the list_utxos answer.
type utxoEntry struct {
	Output struct {
		Address string `json:"address"`
		Content struct {
			BitName string `json:"BitName"`
		} `json:"content"`
	} `json:"output"`
}

// BitNameOwner returns the address that holds a BitName. A message pays the
// holder, so a chat needs this address, and bitname_data does not carry it.
func BitNameOwner(ctx context.Context, client mempoolReader, bitname string) (string, error) {
	if bitname == "" {
		return "", fmt.Errorf("bitname is empty")
	}

	var entries []utxoEntry
	if err := client.Call(ctx, "list_utxos", nil, &entries); err != nil {
		return "", fmt.Errorf("read the utxos: %w", err)
	}

	for _, entry := range entries {
		if entry.Output.Content.BitName == bitname {
			return entry.Output.Address, nil
		}
	}
	return "", fmt.Errorf("%w %s", errBitNameNotFound, bitname)
}
