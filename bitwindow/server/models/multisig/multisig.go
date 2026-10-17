package multisig

import (
	"context"
	"database/sql"
	"encoding/json"
	"errors"
	"fmt"
	"slices"
	"strings"
	"time"

	sq "github.com/Masterminds/squirrel"
	"github.com/rs/zerolog"
	"github.com/samber/lo"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
)

type Group struct {
	ID                string  `db:"id"`
	Name              string  `db:"name"`
	N                 int     `db:"n"`
	M                 int     `db:"m"`
	Created           int64   `db:"created"`
	Txid              string  `db:"txid"`
	Descriptor        string  `db:"descriptor"`
	DescriptorReceive string  `db:"descriptor_receive"`
	DescriptorChange  string  `db:"descriptor_change"`
	WatchWalletName   string  `db:"watch_wallet_name"`
	Balance           float64 `db:"balance"`
	Utxos             int     `db:"utxos"`
	NextReceiveIndex  int     `db:"next_receive_index"`
	NextChangeIndex   int     `db:"next_change_index"`
}

type Key struct {
	ID             int64  `db:"id"`
	GroupID        string `db:"group_id"`
	Owner          string `db:"owner"`
	Xpub           string `db:"xpub"`
	DerivationPath string `db:"derivation_path"`
	Fingerprint    string `db:"fingerprint"`
	OriginPath     string `db:"origin_path"`
	IsWallet       bool   `db:"is_wallet"`
	SortOrder      int    `db:"sort_order"`
}

type KeyPSBT struct {
	KeyID         int64  `db:"key_id"`
	TransactionID string `db:"transaction_id"`
	ActivePSBT    string `db:"active_psbt"`
	InitialPSBT   string `db:"initial_psbt"`
}

type Address struct {
	GroupID  string `db:"group_id"`
	AddrType string `db:"addr_type"` // "receive" or "change"
	Index    int    `db:"addr_index"`
	Addr     string `db:"address"`
	Used     bool   `db:"used"`
}

type UtxoDetail struct {
	GroupID       string  `db:"group_id"`
	Txid          string  `db:"txid"`
	Vout          int     `db:"vout"`
	Address       string  `db:"address"`
	Amount        float64 `db:"amount"`
	Confirmations int     `db:"confirmations"`
	ScriptPubKey  string  `db:"script_pub_key"`
	Spendable     bool    `db:"spendable"`
	Solvable      bool    `db:"solvable"`
	Safe          bool    `db:"safe"`
}

type Transaction struct {
	ID                 string  `db:"id"`
	GroupID            string  `db:"group_id"`
	InitialPSBT        string  `db:"initial_psbt"`
	CombinedPSBT       string  `db:"combined_psbt"`
	FinalHex           string  `db:"final_hex"`
	Txid               string  `db:"txid"`
	Status             int     `db:"status"` // maps to proto enum
	Type               int     `db:"type"`
	Created            int64   `db:"created"`
	BroadcastTime      *int64  `db:"broadcast_time"`
	Amount             float64 `db:"amount"`
	Destination        string  `db:"destination"`
	Fee                float64 `db:"fee"`
	Confirmations      int     `db:"confirmations"`
	RequiredSignatures int     `db:"required_signatures"`
}

type TxKeyPSBT struct {
	TransactionID string `db:"transaction_id"`
	KeyID         string `db:"key_id"`
	PSBT          string `db:"psbt"`
	IsSigned      bool   `db:"is_signed"`
	SignedAt      *int64 `db:"signed_at"`
}

type TxInput struct {
	TransactionID string  `db:"transaction_id"`
	Txid          string  `db:"txid"`
	Vout          int     `db:"vout"`
	Address       string  `db:"address"`
	Amount        float64 `db:"amount"`
	Confirmations int     `db:"confirmations"`
}

type SoloKey struct {
	Xpub           string `db:"xpub"`
	DerivationPath string `db:"derivation_path"`
	Fingerprint    string `db:"fingerprint"`
	OriginPath     string `db:"origin_path"`
	Owner          string `db:"owner"`
}

// Store provides DB access for multisig data.
type Store struct {
	db *sql.DB
}

func NewStore(db *sql.DB) *Store {
	return &Store{db: db}
}

// execer abstracts *sql.DB and *sql.Tx for shared query helpers.
type execer interface {
	ExecContext(ctx context.Context, query string, args ...interface{}) (sql.Result, error)
	QueryContext(ctx context.Context, query string, args ...interface{}) (*sql.Rows, error)
}

// ─── Groups ────────────────────────────────────────────────────────

func (s *Store) ListGroups(ctx context.Context) ([]Group, error) {
	groups, err := database.Select[Group](ctx, s.db, `
		SELECT id, name, n, m, created, COALESCE(txid,'') AS txid, COALESCE(descriptor,'') AS descriptor,
		       COALESCE(descriptor_receive,'') AS descriptor_receive, COALESCE(descriptor_change,'') AS descriptor_change,
		       COALESCE(watch_wallet_name,'') AS watch_wallet_name, balance, utxos, next_receive_index, next_change_index
		FROM multisig_groups ORDER BY created ASC`)
	if err != nil {
		return nil, fmt.Errorf("list groups: %w", err)
	}
	return groups, nil
}

func saveGroupOn(ctx context.Context, e execer, g Group) error {
	_, err := e.ExecContext(ctx, `
		INSERT INTO multisig_groups (id, name, n, m, created, txid, descriptor, descriptor_receive,
		    descriptor_change, watch_wallet_name, balance, utxos, next_receive_index, next_change_index)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
		ON CONFLICT(id) DO UPDATE SET
		    name=excluded.name, n=excluded.n, m=excluded.m, created=excluded.created,
		    txid=excluded.txid, descriptor=excluded.descriptor,
		    descriptor_receive=excluded.descriptor_receive, descriptor_change=excluded.descriptor_change,
		    watch_wallet_name=excluded.watch_wallet_name, balance=excluded.balance, utxos=excluded.utxos,
		    next_receive_index=excluded.next_receive_index, next_change_index=excluded.next_change_index`,
		g.ID, g.Name, g.N, g.M, g.Created, nullStr(g.Txid), nullStr(g.Descriptor),
		nullStr(g.DescriptorReceive), nullStr(g.DescriptorChange), nullStr(g.WatchWalletName),
		g.Balance, g.Utxos, g.NextReceiveIndex, g.NextChangeIndex)
	return err
}

// DeleteGroup deletes the group and all of its child rows.
func (s *Store) DeleteGroup(ctx context.Context, id string) error {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin tx: %w", err)
	}
	defer database.SafeDefer(ctx, tx.Rollback)

	// SQLite foreign keys are off, so ON DELETE CASCADE does not run.
	for _, query := range []string{
		`DELETE FROM multisig_tx_key_psbts WHERE transaction_id IN (SELECT id FROM multisig_transactions WHERE group_id = ?)`,
		`DELETE FROM multisig_tx_inputs WHERE transaction_id IN (SELECT id FROM multisig_transactions WHERE group_id = ?)`,
		`DELETE FROM multisig_transactions WHERE group_id = ?`,
		`DELETE FROM multisig_key_psbts WHERE key_id IN (SELECT id FROM multisig_keys WHERE group_id = ?)`,
		`DELETE FROM multisig_keys WHERE group_id = ?`,
		`DELETE FROM multisig_addresses WHERE group_id = ?`,
		`DELETE FROM multisig_utxo_details WHERE group_id = ?`,
		`DELETE FROM multisig_group_transactions WHERE group_id = ?`,
		`DELETE FROM multisig_groups WHERE id = ?`,
	} {
		if _, err := tx.ExecContext(ctx, query, id); err != nil {
			return fmt.Errorf("delete group %s: %w", id, err)
		}
	}
	return tx.Commit()
}

// ─── Keys ──────────────────────────────────────────────────────────

func (s *Store) ListKeysForGroup(ctx context.Context, groupID string) ([]Key, error) {
	return listKeysForGroupOn(ctx, s.db, groupID)
}

func listKeysForGroupOn(ctx context.Context, e execer, groupID string) ([]Key, error) {
	return database.Select[Key](ctx, e, `
		SELECT id, group_id, owner, xpub, derivation_path, COALESCE(fingerprint,'') AS fingerprint,
		       COALESCE(origin_path,'') AS origin_path, is_wallet, sort_order
		FROM multisig_keys WHERE group_id = ? ORDER BY sort_order ASC`, groupID)
}

func replaceKeysForGroupOn(ctx context.Context, e execer, groupID string, keys []Key) error {
	if _, err := e.ExecContext(ctx, `
		DELETE FROM multisig_key_psbts WHERE key_id IN (SELECT id FROM multisig_keys WHERE group_id = ?)`, groupID); err != nil {
		return err
	}
	if _, err := e.ExecContext(ctx, `DELETE FROM multisig_keys WHERE group_id = ?`, groupID); err != nil {
		return err
	}

	for i, k := range keys {
		_, err := e.ExecContext(ctx, `
			INSERT INTO multisig_keys (group_id, owner, xpub, derivation_path, fingerprint, origin_path, is_wallet, sort_order)
			VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
			groupID, k.Owner, k.Xpub, k.DerivationPath, nullStr(k.Fingerprint), nullStr(k.OriginPath), k.IsWallet, i)
		if err != nil {
			return err
		}
	}
	return nil
}

// ─── Key PSBTs ─────────────────────────────────────────────────────

func (s *Store) ListKeyPSBTs(ctx context.Context, groupID string) ([]KeyPSBT, error) {
	return database.Select[KeyPSBT](ctx, s.db, `
		SELECT kp.key_id, kp.transaction_id, COALESCE(kp.active_psbt,'') AS active_psbt, COALESCE(kp.initial_psbt,'') AS initial_psbt
		FROM multisig_key_psbts kp
		JOIN multisig_keys k ON kp.key_id = k.id
		WHERE k.group_id = ?`, groupID)
}

func saveKeyPSBTOn(ctx context.Context, e execer, kp KeyPSBT) error {
	_, err := e.ExecContext(ctx, `
		INSERT INTO multisig_key_psbts (key_id, transaction_id, active_psbt, initial_psbt)
		VALUES (?, ?, ?, ?)
		ON CONFLICT(key_id, transaction_id) DO UPDATE SET
		    active_psbt=excluded.active_psbt, initial_psbt=excluded.initial_psbt`,
		kp.KeyID, kp.TransactionID, nullStr(kp.ActivePSBT), nullStr(kp.InitialPSBT))
	return err
}

// saveKeyPSBTsByXpubOn resolves each xpub to its key ID in the group and saves the PSBTs.
func saveKeyPSBTsByXpubOn(ctx context.Context, e execer, groupID string, xpubToPSBTs map[string][]KeyPSBT) error {
	if len(xpubToPSBTs) == 0 {
		return nil
	}
	dbKeys, err := listKeysForGroupOn(ctx, e, groupID)
	if err != nil {
		return fmt.Errorf("list keys: %w", err)
	}
	xpubToID := make(map[string]int64, len(dbKeys))
	for _, k := range dbKeys {
		xpubToID[k.Xpub] = k.ID
	}
	for xpub, psbts := range xpubToPSBTs {
		keyID, ok := xpubToID[xpub]
		if !ok {
			return fmt.Errorf("psbt xpub %s has no key in group %s", xpub, groupID)
		}
		for _, kp := range psbts {
			kp.KeyID = keyID
			if err := saveKeyPSBTOn(ctx, e, kp); err != nil {
				return fmt.Errorf("save key psbt: %w", err)
			}
		}
	}
	return nil
}

func listKeyPSBTsByXpubOn(ctx context.Context, e execer, groupID string) (map[string][]KeyPSBT, error) {
	rows, err := database.Select[struct {
		Xpub          string `db:"xpub"`
		TransactionID string `db:"transaction_id"`
		ActivePSBT    string `db:"active_psbt"`
		InitialPSBT   string `db:"initial_psbt"`
	}](ctx, e, `
		SELECT k.xpub, kp.transaction_id, COALESCE(kp.active_psbt,'') AS active_psbt, COALESCE(kp.initial_psbt,'') AS initial_psbt
		FROM multisig_key_psbts kp
		JOIN multisig_keys k ON kp.key_id = k.id
		WHERE k.group_id = ?`, groupID)
	if err != nil {
		return nil, err
	}
	out := make(map[string][]KeyPSBT, len(rows))
	for _, r := range rows {
		out[r.Xpub] = append(out[r.Xpub], KeyPSBT{TransactionID: r.TransactionID, ActivePSBT: r.ActivePSBT, InitialPSBT: r.InitialPSBT})
	}
	return out, nil
}

// ─── Addresses ─────────────────────────────────────────────────────

func (s *Store) ListAddresses(ctx context.Context, groupID string) ([]Address, error) {
	return database.Select[Address](ctx, s.db, `
		SELECT group_id, addr_type, addr_index, address, used
		FROM multisig_addresses WHERE group_id = ? ORDER BY addr_type, addr_index`, groupID)
}

func replaceAddressesOn(ctx context.Context, e execer, groupID string, addrs []Address) error {
	if _, err := e.ExecContext(ctx, `DELETE FROM multisig_addresses WHERE group_id = ?`, groupID); err != nil {
		return err
	}

	for _, a := range addrs {
		if _, err := e.ExecContext(ctx, `
			INSERT INTO multisig_addresses (group_id, addr_type, addr_index, address, used)
			VALUES (?, ?, ?, ?, ?)`, groupID, a.AddrType, a.Index, a.Addr, a.Used); err != nil {
			return err
		}
	}
	return nil
}

// ─── UTXO details ──────────────────────────────────────────────────

func (s *Store) ListUtxoDetails(ctx context.Context, groupID string) ([]UtxoDetail, error) {
	return database.Select[UtxoDetail](ctx, s.db, `
		SELECT group_id, txid, vout, COALESCE(address,'') AS address, amount, confirmations,
		       COALESCE(script_pub_key,'') AS script_pub_key, spendable, solvable, safe
		FROM multisig_utxo_details WHERE group_id = ?`, groupID)
}

func replaceUtxoDetailsOn(ctx context.Context, e execer, groupID string, utxos []UtxoDetail) error {
	if _, err := e.ExecContext(ctx, `DELETE FROM multisig_utxo_details WHERE group_id = ?`, groupID); err != nil {
		return err
	}

	for _, u := range utxos {
		if _, err := e.ExecContext(ctx, `
			INSERT INTO multisig_utxo_details (group_id, txid, vout, address, amount, confirmations, script_pub_key, spendable, solvable, safe)
			VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
			groupID, u.Txid, u.Vout, u.Address, u.Amount, u.Confirmations, u.ScriptPubKey, u.Spendable, u.Solvable, u.Safe); err != nil {
			return err
		}
	}
	return nil
}

// ─── Group ↔ Transaction links ─────────────────────────────────────

func (s *Store) ListGroupTransactionIDs(ctx context.Context, groupID string) ([]string, error) {
	return database.Select[string](ctx, s.db, `SELECT transaction_id FROM multisig_group_transactions WHERE group_id = ?`, groupID)
}

func replaceGroupTransactionIDsOn(ctx context.Context, e execer, groupID string, txIDs []string) error {
	if _, err := e.ExecContext(ctx, `DELETE FROM multisig_group_transactions WHERE group_id = ?`, groupID); err != nil {
		return err
	}

	for _, txID := range txIDs {
		if _, err := e.ExecContext(ctx, `INSERT INTO multisig_group_transactions (group_id, transaction_id) VALUES (?, ?)`, groupID, txID); err != nil {
			return err
		}
	}
	return nil
}

// ─── Transactions ──────────────────────────────────────────────────

var selectTransaction = sq.
	Select(
		"id", "group_id", "initial_psbt", "COALESCE(combined_psbt,'') AS combined_psbt", "COALESCE(final_hex,'') AS final_hex",
		"COALESCE(txid,'') AS txid", "status", "type", "created", "broadcast_time", "amount", "destination", "fee",
		"confirmations", "required_signatures",
	).
	From("multisig_transactions").
	PlaceholderFormat(sq.Question)

func (s *Store) ListTransactions(ctx context.Context, groupID string) ([]Transaction, error) {
	builder := selectTransaction.OrderBy("created ASC")
	if groupID != "" {
		builder = builder.Where(sq.Eq{"group_id": groupID})
	}
	query, args := builder.MustSql()

	return database.Select[Transaction](ctx, s.db, query, args...)
}

func (s *Store) GetTransaction(ctx context.Context, id string) (*Transaction, error) {
	return s.getTransactionWhere(ctx, sq.Eq{"id": id})
}

func (s *Store) GetTransactionByTxid(ctx context.Context, txid string) (*Transaction, error) {
	return s.getTransactionWhere(ctx, sq.Eq{"txid": txid})
}

func (s *Store) getTransactionWhere(ctx context.Context, where sq.Eq) (*Transaction, error) {
	query, args := selectTransaction.Where(where).Limit(1).MustSql()
	t, err := database.Get[Transaction](ctx, s.db, query, args...)
	switch {
	case errors.Is(err, sql.ErrNoRows):
		return nil, nil
	case err != nil:
		return nil, err
	}
	return &t, nil
}

func saveTransactionOn(ctx context.Context, e execer, t Transaction) error {
	// A client ID can collide across groups, and a move would wipe the signer PSBTs of the first group.
	existingGroupID, err := database.Get[string](ctx, e,
		`SELECT group_id FROM multisig_transactions WHERE id = ?`, t.ID,
	)
	switch {
	case errors.Is(err, sql.ErrNoRows):
		// No existing row — safe to insert.
	case err != nil:
		return err
	case existingGroupID != t.GroupID:
		return fmt.Errorf("transaction %s already belongs to group %s, refusing to reassign to group %s",
			t.ID, existingGroupID, t.GroupID)
	}

	var bt interface{}
	if t.BroadcastTime != nil {
		bt = *t.BroadcastTime
	}
	_, err = e.ExecContext(ctx, `
		INSERT INTO multisig_transactions (id, group_id, initial_psbt, combined_psbt, final_hex,
		    txid, status, type, created, broadcast_time, amount, destination, fee, confirmations, required_signatures)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
		ON CONFLICT(id) DO UPDATE SET
		    group_id=excluded.group_id, initial_psbt=excluded.initial_psbt,
		    combined_psbt=excluded.combined_psbt, final_hex=excluded.final_hex,
		    txid=excluded.txid, status=excluded.status, type=excluded.type, created=excluded.created,
		    broadcast_time=excluded.broadcast_time, amount=excluded.amount, destination=excluded.destination,
		    fee=excluded.fee, confirmations=excluded.confirmations, required_signatures=excluded.required_signatures`,
		t.ID, t.GroupID, t.InitialPSBT, nullStr(t.CombinedPSBT), nullStr(t.FinalHex),
		nullStr(t.Txid), t.Status, t.Type, t.Created, bt, t.Amount, t.Destination, t.Fee,
		t.Confirmations, t.RequiredSignatures)
	return err
}

// ─── Transaction Key PSBTs ─────────────────────────────────────────

func (s *Store) ListTxKeyPSBTs(ctx context.Context, transactionID string) ([]TxKeyPSBT, error) {
	return database.Select[TxKeyPSBT](ctx, s.db, `
		SELECT transaction_id, key_id, COALESCE(psbt,'') AS psbt, is_signed, signed_at
		FROM multisig_tx_key_psbts WHERE transaction_id = ?`, transactionID)
}

func replaceTxKeyPSBTsOn(ctx context.Context, e execer, transactionID string, psbts []TxKeyPSBT) error {
	if _, err := e.ExecContext(ctx, `DELETE FROM multisig_tx_key_psbts WHERE transaction_id = ?`, transactionID); err != nil {
		return err
	}

	for _, p := range psbts {
		var sa interface{}
		if p.SignedAt != nil {
			sa = *p.SignedAt
		}
		if _, err := e.ExecContext(ctx, `
			INSERT INTO multisig_tx_key_psbts (transaction_id, key_id, psbt, is_signed, signed_at)
			VALUES (?, ?, ?, ?, ?)`, transactionID, p.KeyID, nullStr(p.PSBT), p.IsSigned, sa); err != nil {
			return err
		}
	}
	return nil
}

// ─── Transaction Inputs ────────────────────────────────────────────

func (s *Store) ListTxInputs(ctx context.Context, transactionID string) ([]TxInput, error) {
	return database.Select[TxInput](ctx, s.db, `
		SELECT transaction_id, txid, vout, COALESCE(address,'') AS address, amount, confirmations
		FROM multisig_tx_inputs WHERE transaction_id = ?`, transactionID)
}

func replaceTxInputsOn(ctx context.Context, e execer, transactionID string, inputs []TxInput) error {
	if _, err := e.ExecContext(ctx, `DELETE FROM multisig_tx_inputs WHERE transaction_id = ?`, transactionID); err != nil {
		return err
	}

	for _, inp := range inputs {
		if _, err := e.ExecContext(ctx, `
			INSERT INTO multisig_tx_inputs (transaction_id, txid, vout, address, amount, confirmations)
			VALUES (?, ?, ?, ?, ?, ?)`, transactionID, inp.Txid, inp.Vout, inp.Address, inp.Amount, inp.Confirmations); err != nil {
			return err
		}
	}
	return nil
}

// ─── Solo Keys ─────────────────────────────────────────────────────

func (s *Store) ListSoloKeys(ctx context.Context) ([]SoloKey, error) {
	return database.Select[SoloKey](ctx, s.db, `
		SELECT xpub, derivation_path, COALESCE(fingerprint,'') AS fingerprint, COALESCE(origin_path,'') AS origin_path, COALESCE(owner,'') AS owner
		FROM multisig_solo_keys`)
}

func (s *Store) AddSoloKey(ctx context.Context, k SoloKey) error {
	return addSoloKeyOn(ctx, s.db, k)
}

func addSoloKeyOn(ctx context.Context, e execer, k SoloKey) error {
	_, err := e.ExecContext(ctx, `
		INSERT OR IGNORE INTO multisig_solo_keys (xpub, derivation_path, fingerprint, origin_path, owner)
		VALUES (?, ?, ?, ?, ?)`, k.Xpub, k.DerivationPath, nullStr(k.Fingerprint), nullStr(k.OriginPath), nullStr(k.Owner))
	return err
}

// ─── Account Index ─────────────────────────────────────────────────

func (s *Store) GetNextAccountIndex(ctx context.Context, additionalUsed []int) (int, error) {
	maxIndex := 7999

	paths, err := database.Select[string](ctx, s.db, `
		SELECT derivation_path FROM multisig_keys WHERE is_wallet = 1
		UNION ALL
		SELECT derivation_path FROM multisig_solo_keys`)
	if err != nil {
		return 0, fmt.Errorf("query derivation paths: %w", err)
	}

	for _, path := range paths {
		idx := extractAccountIndex(path)
		if idx > maxIndex {
			maxIndex = idx
		}
	}

	for _, idx := range additionalUsed {
		if idx > maxIndex {
			maxIndex = idx
		}
	}

	return maxIndex + 1, nil
}

// ─── Atomic composite operations ──────────────────────────────────

// SaveGroupAtomicParams contains all the data needed to save a group and its
// associated keys, PSBTs, addresses, UTXOs, and transaction links in a single
// database transaction.
type SaveGroupAtomicParams struct {
	Group          Group
	Keys           []Key
	Addresses      []Address
	UtxoDetails    []UtxoDetail
	TransactionIDs []string
	// XpubToPSBTs maps xpub -> list of KeyPSBT (KeyID filled after insert).
	XpubToPSBTs map[string][]KeyPSBT
}

// SaveGroupAtomic persists the group and all related child data in a single
// database transaction. If any step fails the entire operation is rolled back.
func (s *Store) SaveGroupAtomic(ctx context.Context, p SaveGroupAtomicParams) error {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin tx: %w", err)
	}
	defer database.SafeDefer(ctx, tx.Rollback)

	if err := saveGroupOn(ctx, tx, p.Group); err != nil {
		return fmt.Errorf("save group: %w", err)
	}

	if err := replaceKeysForGroupOn(ctx, tx, p.Group.ID, p.Keys); err != nil {
		return fmt.Errorf("replace keys: %w", err)
	}

	if err := saveKeyPSBTsByXpubOn(ctx, tx, p.Group.ID, p.XpubToPSBTs); err != nil {
		return err
	}

	if err := replaceAddressesOn(ctx, tx, p.Group.ID, p.Addresses); err != nil {
		return fmt.Errorf("replace addresses: %w", err)
	}

	if err := replaceUtxoDetailsOn(ctx, tx, p.Group.ID, p.UtxoDetails); err != nil {
		return fmt.Errorf("replace utxos: %w", err)
	}

	if err := replaceGroupTransactionIDsOn(ctx, tx, p.Group.ID, p.TransactionIDs); err != nil {
		return fmt.Errorf("replace tx ids: %w", err)
	}

	return tx.Commit()
}

// SaveTransactionAtomicParams contains all data for an atomic transaction save.
type SaveTransactionAtomicParams struct {
	Transaction Transaction
	KeyPSBTs    []TxKeyPSBT
	Inputs      []TxInput
}

// SaveTransactionAtomic persists a transaction and its key PSBTs and inputs in
// a single database transaction.
func (s *Store) SaveTransactionAtomic(ctx context.Context, p SaveTransactionAtomicParams) error {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin tx: %w", err)
	}
	defer database.SafeDefer(ctx, tx.Rollback)

	if err := saveTransactionOn(ctx, tx, p.Transaction); err != nil {
		return fmt.Errorf("save transaction: %w", err)
	}

	if err := replaceTxKeyPSBTsOn(ctx, tx, p.Transaction.ID, p.KeyPSBTs); err != nil {
		return fmt.Errorf("replace key psbts: %w", err)
	}

	if err := replaceTxInputsOn(ctx, tx, p.Transaction.ID, p.Inputs); err != nil {
		return fmt.Errorf("replace inputs: %w", err)
	}

	return tx.Commit()
}

// ─── Migration helper ──────────────────────────────────────────────

// ImportFromJSON imports groups + solo_keys from the old multisig.json format.
func (s *Store) ImportFromJSON(ctx context.Context, data []byte) error {
	var raw struct {
		Groups   []json.RawMessage        `json:"groups"`
		SoloKeys []map[string]interface{} `json:"solo_keys"`
	}
	if err := json.Unmarshal(data, &raw); err != nil {
		return fmt.Errorf("unmarshal json: %w", err)
	}

	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin tx: %w", err)
	}
	defer database.SafeDefer(ctx, tx.Rollback)

	for _, groupRaw := range raw.Groups {
		var gj map[string]interface{}
		if err := json.Unmarshal(groupRaw, &gj); err != nil {
			return fmt.Errorf("unmarshal group: %w", err)
		}

		g := Group{
			ID:                getString(gj, "id"),
			Name:              getString(gj, "name"),
			N:                 getInt(gj, "n"),
			M:                 getInt(gj, "m"),
			Created:           getInt64(gj, "created"),
			Txid:              getString(gj, "txid"),
			Descriptor:        getString(gj, "descriptor"),
			DescriptorReceive: getStringAlt(gj, "descriptorReceive", "descriptor_receive"),
			DescriptorChange:  getStringAlt(gj, "descriptorChange", "descriptor_change"),
			WatchWalletName:   getString(gj, "watch_wallet_name"),
			Balance:           getFloat(gj, "balance"),
			Utxos:             getInt(gj, "utxos"),
			NextReceiveIndex:  getInt(gj, "next_receive_index"),
			NextChangeIndex:   getInt(gj, "next_change_index"),
		}
		if g.ID == "" {
			continue
		}

		if err := saveGroupOn(ctx, tx, g); err != nil {
			return fmt.Errorf("save group %s: %w", g.ID, err)
		}

		// Import keys
		if keysRaw, ok := gj["keys"].([]interface{}); ok {
			existingPSBTs, err := listKeyPSBTsByXpubOn(ctx, tx, g.ID)
			if err != nil {
				return fmt.Errorf("list key psbts for %s: %w", g.ID, err)
			}

			var keys []Key
			xpubToPSBTs := make(map[string][]KeyPSBT)
			for i, kr := range keysRaw {
				kd, ok := kr.(map[string]interface{})
				if !ok {
					continue
				}
				k := Key{
					GroupID:        g.ID,
					Owner:          getString(kd, "owner"),
					Xpub:           getStringAlt(kd, "xpub", "pubkey"),
					DerivationPath: getString(kd, "path"),
					Fingerprint:    getString(kd, "fingerprint"),
					OriginPath:     getString(kd, "origin_path"),
					IsWallet:       getBool(kd, "is_wallet"),
					SortOrder:      i,
				}
				keys = append(keys, k)
				// The imported PSBTs come last, so they replace an existing PSBT of the same transaction.
				xpubToPSBTs[k.Xpub] = slices.Concat(existingPSBTs[k.Xpub], keyPSBTsFromJSON(kd))
			}
			if err := replaceKeysForGroupOn(ctx, tx, g.ID, keys); err != nil {
				return fmt.Errorf("replace keys for %s: %w", g.ID, err)
			}
			if err := saveKeyPSBTsByXpubOn(ctx, tx, g.ID, xpubToPSBTs); err != nil {
				return fmt.Errorf("save key psbts for %s: %w", g.ID, err)
			}
		}

		// Import addresses
		if addrData, ok := gj["addresses"].(map[string]interface{}); ok {
			var addrs []Address
			for _, addrType := range []string{"receive", "change"} {
				if addrList, ok := addrData[addrType].([]interface{}); ok {
					for _, ad := range addrList {
						adMap, ok := ad.(map[string]interface{})
						if !ok {
							continue
						}
						addrs = append(addrs, Address{
							GroupID:  g.ID,
							AddrType: addrType,
							Index:    getInt(adMap, "index"),
							Addr:     getString(adMap, "address"),
							Used:     getBool(adMap, "used"),
						})
					}
				}
			}
			if len(addrs) > 0 {
				if err := replaceAddressesOn(ctx, tx, g.ID, addrs); err != nil {
					return fmt.Errorf("replace addresses for %s: %w", g.ID, err)
				}
			}
		}

		// Import transaction IDs
		if txIDs, ok := gj["transaction_ids"].([]interface{}); ok {
			var ids []string
			for _, id := range txIDs {
				if s, ok := id.(string); ok {
					ids = append(ids, s)
				}
			}
			if len(ids) > 0 {
				if err := replaceGroupTransactionIDsOn(ctx, tx, g.ID, ids); err != nil {
					return fmt.Errorf("replace tx ids for %s: %w", g.ID, err)
				}
			}
		}
	}

	// Import solo keys
	for _, sk := range raw.SoloKeys {
		if err := addSoloKeyOn(ctx, tx, SoloKey{
			Xpub:           getString(sk, "xpub"),
			DerivationPath: getString(sk, "path"),
			Fingerprint:    getString(sk, "fingerprint"),
			OriginPath:     getString(sk, "origin_path"),
			Owner:          getString(sk, "owner"),
		}); err != nil {
			return fmt.Errorf("add solo key: %w", err)
		}
	}

	return tx.Commit()
}

func keyPSBTsFromJSON(kd map[string]interface{}) []KeyPSBT {
	active, _ := kd["active_psbts"].(map[string]interface{})
	initial, _ := kd["initial_psbts"].(map[string]interface{})
	txIDs := lo.Uniq(append(lo.Keys(active), lo.Keys(initial)...))
	return lo.Map(txIDs, func(txID string, _ int) KeyPSBT {
		return KeyPSBT{
			TransactionID: txID,
			ActivePSBT:    getString(active, txID),
			InitialPSBT:   getString(initial, txID),
		}
	})
}

func parseImportTime(ctx context.Context, txID, field, value string) (int64, bool) {
	t, err := time.Parse(time.RFC3339, value)
	if err != nil {
		zerolog.Ctx(ctx).Warn().Err(err).Str("tx_id", txID).Str("field", field).Msg("skip bad time in multisig import")
		return 0, false
	}
	return t.Unix(), true
}

// ImportTransactionsFromJSON imports transactions from the old transactions.json format.
func (s *Store) ImportTransactionsFromJSON(ctx context.Context, data []byte) error {
	var txns []map[string]interface{}
	if err := json.Unmarshal(data, &txns); err != nil {
		return fmt.Errorf("unmarshal: %w", err)
	}

	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return fmt.Errorf("begin tx: %w", err)
	}
	defer database.SafeDefer(ctx, tx.Rollback)

	statusMap := map[string]int{
		"needsSignatures":     1,
		"awaitingSignedPSBTs": 2,
		"readyToCombine":      3,
		"readyForBroadcast":   4,
		"broadcasted":         5,
		"confirmed":           6,
		"completed":           7,
		"voided":              8,
	}

	typeMap := map[string]int{
		"deposit":    1,
		"withdrawal": 2,
	}

	for _, tj := range txns {
		status := statusMap[getString(tj, "status")]
		if status == 0 {
			status = 1
		}
		txType := typeMap[getString(tj, "type")]
		if txType == 0 {
			txType = 1
		}

		var broadcastTime *int64
		if bt := getString(tj, "broadcastTime"); bt != "" {
			if unix, ok := parseImportTime(ctx, getString(tj, "id"), "broadcastTime", bt); ok {
				broadcastTime = &unix
			}
		}

		var created int64
		if c := getString(tj, "created"); c != "" {
			created, _ = parseImportTime(ctx, getString(tj, "id"), "created", c)
		}

		t := Transaction{
			ID:            getString(tj, "id"),
			GroupID:       getString(tj, "groupId"),
			InitialPSBT:   getString(tj, "initialPSBT"),
			CombinedPSBT:  getString(tj, "combinedPSBT"),
			FinalHex:      getString(tj, "finalHex"),
			Txid:          getString(tj, "txid"),
			Status:        status,
			Type:          txType,
			Created:       created,
			BroadcastTime: broadcastTime,
			Amount:        getFloat(tj, "amount"),
			Destination:   getString(tj, "destination"),
			Fee:           getFloat(tj, "fee"),
			Confirmations: getInt(tj, "confirmations"),
		}

		if _, ok := tj["requiredSignatures"]; ok {
			t.RequiredSignatures = getInt(tj, "requiredSignatures")
		} else if keyPSBTs, ok := tj["keyPSBTs"].([]interface{}); ok {
			t.RequiredSignatures = len(keyPSBTs)
		}

		if t.ID == "" {
			continue
		}

		if err := saveTransactionOn(ctx, tx, t); err != nil {
			return fmt.Errorf("save tx %s: %w", t.ID, err)
		}

		// Import key PSBTs
		if keyPSBTs, ok := tj["keyPSBTs"].([]interface{}); ok {
			var psbts []TxKeyPSBT
			for _, kp := range keyPSBTs {
				kpMap, ok := kp.(map[string]interface{})
				if !ok {
					continue
				}
				var signedAt *int64
				if sa := getString(kpMap, "signedAt"); sa != "" {
					if unix, ok := parseImportTime(ctx, t.ID, "signedAt", sa); ok {
						signedAt = &unix
					}
				}
				psbts = append(psbts, TxKeyPSBT{
					TransactionID: t.ID,
					KeyID:         getString(kpMap, "keyId"),
					PSBT:          getString(kpMap, "psbt"),
					IsSigned:      getBool(kpMap, "isSigned"),
					SignedAt:      signedAt,
				})
			}
			if len(psbts) > 0 {
				if err := replaceTxKeyPSBTsOn(ctx, tx, t.ID, psbts); err != nil {
					return fmt.Errorf("replace key psbts for tx %s: %w", t.ID, err)
				}
			}
		}

		// Import inputs
		if inputs, ok := tj["inputs"].([]interface{}); ok {
			var txInputs []TxInput
			for _, inp := range inputs {
				inpMap, ok := inp.(map[string]interface{})
				if !ok {
					continue
				}
				txInputs = append(txInputs, TxInput{
					TransactionID: t.ID,
					Txid:          getString(inpMap, "txid"),
					Vout:          getInt(inpMap, "vout"),
					Address:       getString(inpMap, "address"),
					Amount:        getFloat(inpMap, "amount"),
					Confirmations: getInt(inpMap, "confirmations"),
				})
			}
			if len(txInputs) > 0 {
				if err := replaceTxInputsOn(ctx, tx, t.ID, txInputs); err != nil {
					return fmt.Errorf("replace inputs for tx %s: %w", t.ID, err)
				}
			}
		}
	}

	return tx.Commit()
}

// ─── helpers ───────────────────────────────────────────────────────

func nullStr(s string) interface{} {
	if s == "" {
		return nil
	}
	return s
}

// Read the account component of "m/purpose'/coin'/account'/...". The root is
// optional: the keystore parser accepts a rootless "purpose'/coin'/account'"
// too, and its account sits one component earlier. A short non-standard path
// falls back to its last component.
func extractAccountIndex(path string) int {
	parts := splitPath(path)
	if len(parts) > 0 && (parts[0] == "m" || parts[0] == "M") {
		parts = parts[1:]
	}
	if len(parts) >= 3 {
		return parseIndex(parts[2])
	}
	if len(parts) >= 2 {
		return parseIndex(parts[1])
	}
	return 0
}

// Parse a path component ("8000'" -> 8000), 0 if it isn't a plain number.
// BIP32 writes the hardened marker as ', h or H, and all three are accepted.
func parseIndex(part string) int {
	idx := trimHardened(part)
	if idx == "" {
		return 0
	}
	n := 0
	for _, c := range idx {
		if c < '0' || c > '9' {
			return 0
		}
		n = n*10 + int(c-'0')
	}
	return n
}

func splitPath(path string) []string {
	return strings.FieldsFunc(path, func(c rune) bool { return c == '/' })
}

func trimHardened(s string) string {
	if len(s) > 0 {
		switch s[len(s)-1] {
		case '\'', 'h', 'H':
			return s[:len(s)-1]
		}
	}
	return s
}

func getString(m map[string]interface{}, key string) string {
	if v, ok := m[key]; ok {
		if s, ok := v.(string); ok {
			return s
		}
	}
	return ""
}

func getStringAlt(m map[string]interface{}, keys ...string) string {
	for _, k := range keys {
		if s := getString(m, k); s != "" {
			return s
		}
	}
	return ""
}

func getInt(m map[string]interface{}, key string) int {
	return int(getFloat(m, key))
}

func getInt64(m map[string]interface{}, key string) int64 {
	return int64(getFloat(m, key))
}

func getFloat(m map[string]interface{}, key string) float64 {
	n, _ := m[key].(float64)
	return n
}

func getBool(m map[string]interface{}, key string) bool {
	if v, ok := m[key]; ok {
		if b, ok := v.(bool); ok {
			return b
		}
	}
	return false
}
