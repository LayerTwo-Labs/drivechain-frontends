package coinnews

import (
	"context"
	"database/sql"
	"errors"
	"fmt"

	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcec/v2/schnorr"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
)

// LoadOrCreateIdentity returns this node's CoinNews signing key, creating
// and persisting a fresh secp256k1 keypair on first use. The returned
// x-only pubkey is what a Vote publishes as its AuthorXPK.
func LoadOrCreateIdentity(ctx context.Context, db *sql.DB) (*btcec.PrivateKey, [32]byte, error) {
	type identity struct {
		Privkey   []byte   `db:"privkey"`
		AuthorXPK xonlyKey `db:"author_xpk"`
	}
	id, err := database.Get[identity](ctx, db, `SELECT privkey, author_xpk FROM cn_identity WHERE id = 1`)
	switch {
	case err == nil:
		if len(id.Privkey) != 32 {
			return nil, [32]byte{}, fmt.Errorf("coinnews: stored privkey is %d bytes, want 32", len(id.Privkey))
		}
		priv, _ := btcec.PrivKeyFromBytes(id.Privkey)
		return priv, id.AuthorXPK, nil
	case errors.Is(err, sql.ErrNoRows):
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

type xonlyKey [32]byte

func (x *xonlyKey) Scan(src any) error {
	b, ok := src.([]byte)
	if !ok {
		return fmt.Errorf("coinnews: author_xpk is %T, want []byte", src)
	}
	if len(b) != 32 {
		return fmt.Errorf("coinnews: author_xpk is %d bytes, want 32", len(b))
	}
	copy(x[:], b)
	return nil
}
