package addressbook

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"time"

	"connectrpc.com/connect"
	database "github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1"
	"github.com/mattn/go-sqlite3"
)

// ErrDuplicateAddress is the error of Create when the book holds the address
// and direction.
var ErrDuplicateAddress = errors.New("address book already holds this address and direction")

type Entry struct {
	ID        int64
	Label     string
	Address   string
	Direction Direction
	WalletID  *string
	CreatedAt time.Time
}

type Direction string

const (
	DirectionSend    Direction = "send"
	DirectionReceive Direction = "receive"
)

func Create(ctx context.Context, db *sql.DB, walletID *string, label, address string, direction Direction) error {
	_, err := db.ExecContext(ctx,
		`INSERT INTO address_book (wallet_id, label, address, direction) VALUES (?, ?, ?, ?)`,
		walletID, label, address, direction)
	var sqliteErr sqlite3.Error
	if errors.As(err, &sqliteErr) && sqliteErr.ExtendedCode == sqlite3.ErrConstraintUnique {
		return ErrDuplicateAddress
	}
	return err
}

// Upsert adds an entry, or sets the label of the entry that holds the address
// and direction.
func Upsert(ctx context.Context, db *sql.DB, walletID *string, label, address string, direction Direction) error {
	_, err := db.ExecContext(ctx,
		`INSERT INTO address_book (wallet_id, label, address, direction) VALUES (?, ?, ?, ?)
		ON CONFLICT(address, direction) DO UPDATE SET label = excluded.label`,
		walletID, label, address, direction)
	return err
}

func List(ctx context.Context, db *sql.DB) ([]Entry, error) {
	rows, err := db.QueryContext(ctx, `SELECT id, label, address, direction, COALESCE(wallet_id, ''), created_at FROM address_book`)
	if err != nil {
		return nil, err
	}
	defer database.SafeDefer(ctx, rows.Close)

	var entries []Entry
	for rows.Next() {
		var entry Entry
		if err := rows.Scan(&entry.ID, &entry.Label, &entry.Address, &entry.Direction, &entry.WalletID, &entry.CreatedAt); err != nil {
			return nil, err
		}
		entries = append(entries, entry)
	}
	return entries, rows.Err()
}

// LabelsByAddress maps each address to the label of its first entry.
func LabelsByAddress(ctx context.Context, db *sql.DB) (map[string]string, error) {
	entries, err := List(ctx, db)
	if err != nil {
		return nil, err
	}
	labels := make(map[string]string, len(entries))
	for _, entry := range entries {
		if _, ok := labels[entry.Address]; !ok {
			labels[entry.Address] = entry.Label
		}
	}
	return labels, nil
}

func UpdateLabel(ctx context.Context, db *sql.DB, id int64, newLabel string) error {
	rows, err := db.ExecContext(ctx,
		`UPDATE address_book SET label = ? WHERE id = ?`,
		newLabel, id)
	if err != nil {
		return err
	}

	n, err := rows.RowsAffected()
	if err != nil {
		return fmt.Errorf("count updated entries: %w", err)
	}
	if n == 0 {
		return connect.NewError(connect.CodeNotFound, fmt.Errorf("address book entry not found"))
	}

	return nil
}

func Delete(ctx context.Context, db *sql.DB, id int64) error {
	res, err := db.ExecContext(ctx,
		`DELETE FROM address_book WHERE id = ?`,
		id)
	if err != nil {
		return err
	}

	n, err := res.RowsAffected()
	if err != nil {
		return fmt.Errorf("count deleted entries: %w", err)
	}
	if n == 0 {
		return connect.NewError(connect.CodeNotFound, fmt.Errorf("address book entry not found"))
	}

	return nil
}

func DirectionFromProto(d pb.Direction) (Direction, error) {
	switch d {
	case pb.Direction_DIRECTION_SEND:
		return DirectionSend, nil
	case pb.Direction_DIRECTION_RECEIVE:
		return DirectionReceive, nil
	case pb.Direction_DIRECTION_UNSPECIFIED:
		fallthrough
	default:
		return "", fmt.Errorf("invalid direction: %s", d)
	}
}

func DirectionToProto(d Direction) pb.Direction {
	switch d {
	case DirectionSend:
		return pb.Direction_DIRECTION_SEND
	case DirectionReceive:
		return pb.Direction_DIRECTION_RECEIVE
	default:
		return pb.Direction_DIRECTION_UNSPECIFIED
	}
}
