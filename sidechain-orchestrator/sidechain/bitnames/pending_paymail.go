package bitnames

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
)

// mempoolEntry is one transaction the node holds.
type mempoolEntry struct {
	TxID string `json:"txid"`
	Tx   struct {
		Outputs []struct {
			Address string          `json:"address"`
			Content json.RawMessage `json:"content"`
			Memo    string          `json:"memo"`
		} `json:"outputs"`
	} `json:"tx"`
}

// paymailOutput is one entry of the map GetPaymail returns. The memo carries
// the message, and the node writes it as a byte array.
type paymailOutput struct {
	Address string          `json:"address"`
	Content json.RawMessage `json:"content"`
	Memo    memoBytes       `json:"memo"`
}

// memoBytes writes the memo as an array of numbers, the way the node writes a
// Vec<u8>. Go writes a []byte as base64, which no reader of get_paymail parses.
type memoBytes []byte

func (m memoBytes) MarshalJSON() ([]byte, error) {
	numbers := make([]uint16, len(m))
	for i, b := range m {
		numbers[i] = uint16(b)
	}
	return json.Marshal(numbers)
}

// pendingPaymail returns the mempool outputs that pay one of the wallet's
// addresses and carry a memo. It keys them by outpoint, exactly as GetPaymail
// does, so one reader handles both.
//
// The node hides an unconfirmed output from get_paymail, because that call
// reads a block height for every output. A chat that waits for a block is not
// a chat, so this reads the mempool as well.
// mempoolTxids names every transaction the mempool holds.
func mempoolTxids(ctx context.Context, client mempoolReader) ([]string, error) {
	var entries []mempoolEntry
	if err := client.Call(ctx, "list_mempool", nil, &entries); err != nil {
		return nil, fmt.Errorf("read the mempool: %w", err)
	}
	txids := make([]string, 0, len(entries))
	for _, entry := range entries {
		txids = append(txids, entry.TxID)
	}
	return txids, nil
}

func pendingPaymail(ctx context.Context, client mempoolReader) (map[string]paymailOutput, error) {
	var addresses []string
	if err := client.Call(ctx, "get_wallet_addresses", nil, &addresses); err != nil {
		return nil, fmt.Errorf("read the wallet addresses: %w", err)
	}
	mine := make(map[string]bool, len(addresses))
	for _, address := range addresses {
		mine[address] = true
	}

	var entries []mempoolEntry
	if err := client.Call(ctx, "list_mempool", nil, &entries); err != nil {
		return nil, fmt.Errorf("read the mempool: %w", err)
	}

	if !holdsAMessage(entries, mine) {
		return map[string]paymailOutput{}, nil
	}

	// get_paymail hides a message that pays less than the postage, so the
	// pending view has to hide it too.
	postage, err := postageOf(ctx, client, mine)
	if err != nil {
		return nil, err
	}

	pending := make(map[string]paymailOutput)
	for _, entry := range entries {
		for vout, output := range entry.Tx.Outputs {
			if output.Memo == "" || !mine[output.Address] {
				continue
			}
			memo, err := hex.DecodeString(output.Memo)
			if err != nil {
				// A memo the node cannot spell as hex is not a message.
				continue
			}
			fee, known := postage[output.Address]
			if value, ok := sats(output.Content); !known || !ok || value < fee {
				continue
			}
			key := outpointKey(entry.TxID, vout)
			pending[key] = paymailOutput{
				Address: output.Address,
				Content: output.Content,
				Memo:    memo,
			}
		}
	}
	return pending, nil
}

// mempoolReader is the part of the node client that pendingPaymail uses.
type mempoolReader interface {
	Call(ctx context.Context, method string, params any, result any) error
}

// holdsAMessage says whether any output pays one of these addresses and
// carries a memo. The utxo set is large, so nothing reads it without a reason.
func holdsAMessage(entries []mempoolEntry, mine map[string]bool) bool {
	for _, entry := range entries {
		for _, output := range entry.Tx.Outputs {
			if output.Memo != "" && mine[output.Address] {
				return true
			}
		}
	}
	return false
}

// sats reads the value of an output, and says whether it holds one.
func sats(content json.RawMessage) (int64, bool) {
	var value struct {
		BitcoinSats *int64 `json:"BitcoinSats"`
	}
	if err := json.Unmarshal(content, &value); err != nil || value.BitcoinSats == nil {
		return 0, false
	}
	return *value.BitcoinSats, true
}

// postageOf reads the smallest payment each of my BitNames accepts. A message
// that pays less is not mail.
func postageOf(ctx context.Context, client mempoolReader, mine map[string]bool) (map[string]int64, error) {
	var utxos []struct {
		Output struct {
			Address string `json:"address"`
			Content struct {
				BitName string `json:"BitName"`
			} `json:"content"`
		} `json:"output"`
	}
	if err := client.Call(ctx, "list_utxos", nil, &utxos); err != nil {
		return nil, fmt.Errorf("read the utxos: %w", err)
	}

	postage := make(map[string]int64)
	for _, utxo := range utxos {
		if utxo.Output.Content.BitName == "" || !mine[utxo.Output.Address] {
			continue
		}
		var data struct {
			PaymailFeeSats *int64 `json:"paymail_fee_sats"`
		}
		if err := client.Call(ctx, "bitname_data", []any{utxo.Output.Content.BitName}, &data); err != nil {
			return nil, fmt.Errorf("read the BitName data: %w", err)
		}
		if data.PaymailFeeSats == nil {
			continue
		}
		fee, known := postage[utxo.Output.Address]
		if !known || *data.PaymailFeeSats < fee {
			postage[utxo.Output.Address] = *data.PaymailFeeSats
		}
	}
	return postage, nil
}

// outpointKey spells the outpoint the way the node writes it in get_paymail.
func outpointKey(txid string, vout int) string {
	return fmt.Sprintf(`{"Regular":{"txid":"%s","vout":%d}}`, txid, vout)
}
