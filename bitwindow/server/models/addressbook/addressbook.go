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
	ID        int64     `db:"id"`
	Label     string    `db:"label"`
	Address   string    `db:"address"`
	Direction Direction `db:"direction"`
	WalletID  *string   `db:"wallet_id"`
	CreatedAt time.Time `db:"created_at"`
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
	if err != nil {
		return fmt.Errorf("upsert address book entry: %w", err)
	}
	return nil
}

func List(ctx context.Context, db *sql.DB) ([]Entry, error) {
	return database.Select[Entry](ctx, db, `SELECT id, label, address, direction, COALESCE(wallet_id, '') AS wallet_id, created_at FROM address_book ORDER BY id`)
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
	err := database.CheckOne(db.ExecContext(ctx,
		`UPDATE address_book SET label = ? WHERE id = ?`,
		newLabel, id))
	if errors.Is(err, sql.ErrNoRows) {
		return connect.NewError(connect.CodeNotFound, fmt.Errorf("address book entry not found"))
	}
	return err
}

func Delete(ctx context.Context, db *sql.DB, id int64) error {
	err := database.CheckOne(db.ExecContext(ctx,
		`DELETE FROM address_book WHERE id = ?`,
		id))
	if errors.Is(err, sql.ErrNoRows) {
		return connect.NewError(connect.CodeNotFound, fmt.Errorf("address book entry not found"))
	}
	return err
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
