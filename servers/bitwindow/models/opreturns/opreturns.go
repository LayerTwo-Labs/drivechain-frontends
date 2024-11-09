package opreturns

import (
	"context"
	"database/sql"
	"encoding/hex"
	"fmt"
	"time"
	"unicode"
)

func Persist(
	ctx context.Context, db *sql.DB, height *int32, txid string, vout int32,
	data []byte, feeSatoshi int64, createdAt time.Time,
) error {
	_, err := db.ExecContext(ctx, `
		INSERT INTO op_returns (
			txid,
			vout,
			op_return_data,
			fee_satoshi,
			height,
			created_at
		) VALUES (?, ?, ?, ?, ?, ?)
		ON CONFLICT (txid, vout) DO UPDATE SET
			op_return_data = excluded.op_return_data,
			height = excluded.height,
			fee_satoshi = excluded.fee_satoshi
	`, txid, vout, data, feeSatoshi, height, createdAt)
	if err != nil {
		return fmt.Errorf("could not persist op_return: %w", err)
	}

	return nil
}

type OPReturn struct {
	ID         string
	TxID       string
	Vout       int32
	Data       []byte
	FeeSatoshi int64
	Height     *int32
	CreatedAt  time.Time
}

func Select(ctx context.Context, db *sql.DB) ([]OPReturn, error) {
	rows, err := db.QueryContext(ctx, `
		SELECT id, txid, vout, op_return_data, fee_satoshi, height, created_at
		FROM op_returns
		ORDER BY created_at DESC
	`)
	if err != nil {
		return nil, fmt.Errorf("could not query op_returns: %w", err)
	}
	defer rows.Close()

	var opReturns []OPReturn
	for rows.Next() {
		var opReturn OPReturn
		err := rows.Scan(&opReturn.ID, &opReturn.TxID, &opReturn.Vout, &opReturn.Data, &opReturn.FeeSatoshi, &opReturn.Height, &opReturn.CreatedAt)
		if err != nil {
			return nil, fmt.Errorf("could not scan op_return: %w", err)
		}
		opReturns = append(opReturns, opReturn)
	}

	if err := rows.Err(); err != nil {
		return nil, fmt.Errorf("could not iterate op_returns: %w", err)
	}

	return opReturns, nil
}

func OPReturnToReadable(data []byte) string {
	// Convert to string first to properly handle UTF-8 encoding
	str := string(data)

	isHumanReadable := true
	for _, r := range str {
		// Check if character is printable AND in basic ASCII range
		// This prevents invalid UTF-8 sequences from being considered readable
		if !unicode.IsPrint(r) || r > 127 {
			isHumanReadable = false
			break
		}
	}

	if isHumanReadable {
		return str
	}

	return hex.EncodeToString(data)
}
