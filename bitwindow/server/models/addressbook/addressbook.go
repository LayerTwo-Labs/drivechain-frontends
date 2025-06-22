package addressbook

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	"connectrpc.com/connect"
	database "github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitwindowd/v1"
)

type Entry struct {
	ID        int64
	Label     string
	Address   string
	Direction Direction
	CreatedAt time.Time
}

type Direction string

const (
	DirectionSend    Direction = "send"
	DirectionReceive Direction = "receive"
)

func Create(ctx context.Context, db *sql.DB, label, address string, direction Direction) error {
	_, err := db.ExecContext(ctx,
		`INSERT INTO address_book (label, address, direction) VALUES (?, ?, ?)`,
		label, address, direction)
	return err
}

func List(ctx context.Context, db *sql.DB) ([]Entry, error) {
	rows, err := db.QueryContext(ctx, `SELECT id, label, address, direction, created_at FROM address_book`)
	if err != nil {
		return nil, err
	}
	defer database.SafeDefer(ctx, rows.Close)

	var entries []Entry
	for rows.Next() {
		var entry Entry
		if err := rows.Scan(&entry.ID, &entry.Label, &entry.Address, &entry.Direction, &entry.CreatedAt); err != nil {
			return nil, err
		}
		entries = append(entries, entry)
	}
	return entries, rows.Err()
}

func UpdateLabel(ctx context.Context, db *sql.DB, id int64, newLabel string) error {
	rows, err := db.ExecContext(ctx,
		`UPDATE address_book SET label = ? WHERE id = ?`,
		newLabel, id)
	if err != nil {
		return err
	}

	if rows, _ := rows.RowsAffected(); rows == 0 {
		return connect.NewError(connect.CodeNotFound, fmt.Errorf("address book entry not found"))
	}

	return nil
}

func Delete(ctx context.Context, db *sql.DB, id int64) error {
	rows, err := db.ExecContext(ctx,
		`DELETE FROM address_book WHERE id = ?`,
		id)

	if rows, _ := rows.RowsAffected(); rows == 0 {
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

const (
	ErrUniqueAddress = "UNIQUE constraint failed: address_book.address, address_book.direction"
)
