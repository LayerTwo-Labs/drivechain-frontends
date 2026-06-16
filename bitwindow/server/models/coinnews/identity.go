package coinnews

import (
	"context"
	"database/sql"
	"fmt"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcec/v2/schnorr"
)

// LoadOrCreateIdentity returns this node's CoinNews signing key, creating
// and persisting a fresh secp256k1 keypair on first use. The returned
// x-only pubkey is what a Vote publishes as its AuthorXPK.
func LoadOrCreateIdentity(ctx context.Context, db *sql.DB) (*btcec.PrivateKey, [32]byte, error) {
	var privBytes []byte
	var xpk [32]byte
	row := db.QueryRowContext(ctx, `SELECT privkey, author_xpk FROM cn_identity WHERE id = 1`)
	switch err := row.Scan(&privBytes, &xpkSlice{&xpk}); err {
	case nil:
		if len(privBytes) != 32 {
			return nil, [32]byte{}, fmt.Errorf("coinnews: stored privkey is %d bytes, want 32", len(privBytes))
		}
		priv, _ := btcec.PrivKeyFromBytes(privBytes)
		return priv, xpk, nil
	case sql.ErrNoRows:
		return createIdentity(ctx, db)
	default:
		return nil, [32]byte{}, fmt.Errorf("coinnews: load identity: %w", err)
	}
}

func createIdentity(ctx context.Context, db *sql.DB) (*btcec.PrivateKey, [32]byte, error) {
	priv, err := btcec.NewPrivateKey()
	if err != nil {
		return nil, [32]byte{}, fmt.Errorf("coinnews: generate identity: %w", err)
	}
	var xpk [32]byte
	copy(xpk[:], schnorr.SerializePubKey(priv.PubKey()))

	if _, err := db.ExecContext(ctx, `
		INSERT INTO cn_identity (id, privkey, author_xpk) VALUES (1, ?, ?)
	`, priv.Serialize(), xpk[:]); err != nil {
		return nil, [32]byte{}, fmt.Errorf("coinnews: persist identity: %w", err)
	}
	return priv, xpk, nil
}

// xpkSlice adapts a fixed [32]byte into a sql.Scanner so the author_xpk
// BLOB lands directly in the array without an intermediate copy.
type xpkSlice struct{ dst *[32]byte }

func (x xpkSlice) Scan(src any) error {
	b, ok := src.([]byte)
	if !ok {
		return fmt.Errorf("coinnews: author_xpk is %T, want []byte", src)
	}
	if len(b) != 32 {
		return fmt.Errorf("coinnews: author_xpk is %d bytes, want 32", len(b))
	}
	copy(x.dst[:], b)
	return nil
}
