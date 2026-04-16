package multisig

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"time"
)

// Group represents a multisig group stored in the DB.
type Group struct {
	ID                string
	Name              string
	N                 int
	M                 int
	Created           int64
	Txid              string
	Descriptor        string
	DescriptorReceive string
	DescriptorChange  string
	WatchWalletName   string
	Balance           float64
	Utxos             int
	NextReceiveIndex  int
	NextChangeIndex   int
}

type Key struct {
	ID             int64
	GroupID        string
	Owner          string
	Xpub           string
	DerivationPath string
	Fingerprint    string
	OriginPath     string
	IsWallet       bool
	SortOrder      int
}

type KeyPSBT struct {
	KeyID         int64
	TransactionID string
	ActivePSBT    string
	InitialPSBT   string
}

type Address struct {
	GroupID  string
	AddrType string // "receive" or "change"
	Index    int
	Addr     string
	Used     bool
}

type UtxoDetail struct {
	GroupID       string
	Txid          string
	Vout          int
	Address       string
	Amount        float64
	Confirmations int
	ScriptPubKey  string
	Spendable     bool
	Solvable      bool
	Safe          bool
}

type Transaction struct {
	ID                 string
	GroupID            string
	InitialPSBT        string
	CombinedPSBT       string
	FinalHex           string
	Txid               string
	Status             int // maps to proto enum
	Type               int
	Created            int64
	BroadcastTime      *int64
	Amount             float64
	Destination        string
	Fee                float64
	Confirmations      int
	RequiredSignatures int
}

type TxKeyPSBT struct {
	TransactionID string
	KeyID         string
	PSBT          string
	IsSigned      bool
	SignedAt      *int64
}

type TxInput struct {
	TransactionID string
	Txid          string
	Vout          int
	Address       string
	Amount        float64
	Confirmations int
}

type SoloKey struct {
	Xpub           string
	DerivationPath string
	Fingerprint    string
	OriginPath     string
	Owner          string
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
	QueryRowContext(ctx context.Context, query string, args ...interface{}) *sql.Row
}

// ─── Groups ────────────────────────────────────────────────────────

func (s *Store) ListGroups(ctx context.Context) ([]Group, error) {
	rows, err := s.db.QueryContext(ctx, `
		SELECT id, name, n, m, created, COALESCE(txid,''), COALESCE(descriptor,''),
		       COALESCE(descriptor_receive,''), COALESCE(descriptor_change,''),
		       COALESCE(watch_wallet_name,''), balance, utxos, next_receive_index, next_change_index
		FROM multisig_groups ORDER BY created ASC`)
	if err != nil {
		return nil, fmt.Errorf("list groups: %w", err)
	}
	defer rows.Close()

	var groups []Group
	for rows.Next() {
		var g Group
		if err := rows.Scan(&g.ID, &g.Name, &g.N, &g.M, &g.Created,
			&g.Txid, &g.Descriptor, &g.DescriptorReceive, &g.DescriptorChange,
			&g.WatchWalletName, &g.Balance, &g.Utxos, &g.NextReceiveIndex, &g.NextChangeIndex); err != nil {
			return nil, fmt.Errorf("scan group: %w", err)
		}
		groups = append(groups, g)
	}
	return groups, rows.Err()
}

func (s *Store) SaveGroup(ctx context.Context, g Group) error {
	return saveGroupOn(ctx, s.db, g)
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

func (s *Store) DeleteGroup(ctx context.Context, id string) error {
	_, err := s.db.ExecContext(ctx, `DELETE FROM multisig_groups WHERE id = ?`, id)
	return err
}

// ─── Keys ──────────────────────────────────────────────────────────

func (s *Store) ListKeysForGroup(ctx context.Context, groupID string) ([]Key, error) {
	return listKeysForGroupOn(ctx, s.db, groupID)
}

func listKeysForGroupOn(ctx context.Context, e execer, groupID string) ([]Key, error) {
	rows, err := e.QueryContext(ctx, `
		SELECT id, group_id, owner, xpub, derivation_path, COALESCE(fingerprint,''),
		       COALESCE(origin_path,''), is_wallet, sort_order
		FROM multisig_keys WHERE group_id = ? ORDER BY sort_order ASC`, groupID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var keys []Key
	for rows.Next() {
		var k Key
		if err := rows.Scan(&k.ID, &k.GroupID, &k.Owner, &k.Xpub, &k.DerivationPath,
			&k.Fingerprint, &k.OriginPath, &k.IsWallet, &k.SortOrder); err != nil {
			return nil, err
		}
		keys = append(keys, k)
	}
	return keys, rows.Err()
}

func (s *Store) ReplaceKeysForGroup(ctx context.Context, groupID string, keys []Key) error {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback() //nolint:errcheck

	if err := replaceKeysForGroupOn(ctx, tx, groupID, keys); err != nil {
		return err
	}
	return tx.Commit()
}

func replaceKeysForGroupOn(ctx context.Context, e execer, groupID string, keys []Key) error {
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
	rows, err := s.db.QueryContext(ctx, `
		SELECT kp.key_id, kp.transaction_id, COALESCE(kp.active_psbt,''), COALESCE(kp.initial_psbt,'')
		FROM multisig_key_psbts kp
		JOIN multisig_keys k ON kp.key_id = k.id
		WHERE k.group_id = ?`, groupID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var psbts []KeyPSBT
	for rows.Next() {
		var p KeyPSBT
		if err := rows.Scan(&p.KeyID, &p.TransactionID, &p.ActivePSBT, &p.InitialPSBT); err != nil {
			return nil, err
		}
		psbts = append(psbts, p)
	}
	return psbts, rows.Err()
}

func (s *Store) SaveKeyPSBT(ctx context.Context, kp KeyPSBT) error {
	return saveKeyPSBTOn(ctx, s.db, kp)
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

func (s *Store) DeleteKeyPSBTsForTransaction(ctx context.Context, transactionID string) error {
	_, err := s.db.ExecContext(ctx, `DELETE FROM multisig_key_psbts WHERE transaction_id = ?`, transactionID)
	return err
}

// ─── Addresses ─────────────────────────────────────────────────────

func (s *Store) ListAddresses(ctx context.Context, groupID string) ([]Address, error) {
	rows, err := s.db.QueryContext(ctx, `
		SELECT group_id, addr_type, addr_index, address, used
		FROM multisig_addresses WHERE group_id = ? ORDER BY addr_type, addr_index`, groupID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var addrs []Address
	for rows.Next() {
		var a Address
		if err := rows.Scan(&a.GroupID, &a.AddrType, &a.Index, &a.Addr, &a.Used); err != nil {
			return nil, err
		}
		addrs = append(addrs, a)
	}
	return addrs, rows.Err()
}

func (s *Store) ReplaceAddresses(ctx context.Context, groupID string, addrs []Address) error {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback() //nolint:errcheck

	if err := replaceAddressesOn(ctx, tx, groupID, addrs); err != nil {
		return err
	}
	return tx.Commit()
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
	rows, err := s.db.QueryContext(ctx, `
		SELECT group_id, txid, vout, COALESCE(address,''), amount, confirmations,
		       COALESCE(script_pub_key,''), spendable, solvable, safe
		FROM multisig_utxo_details WHERE group_id = ?`, groupID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var utxos []UtxoDetail
	for rows.Next() {
		var u UtxoDetail
		if err := rows.Scan(&u.GroupID, &u.Txid, &u.Vout, &u.Address, &u.Amount,
			&u.Confirmations, &u.ScriptPubKey, &u.Spendable, &u.Solvable, &u.Safe); err != nil {
			return nil, err
		}
		utxos = append(utxos, u)
	}
	return utxos, rows.Err()
}

func (s *Store) ReplaceUtxoDetails(ctx context.Context, groupID string, utxos []UtxoDetail) error {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback() //nolint:errcheck

	if err := replaceUtxoDetailsOn(ctx, tx, groupID, utxos); err != nil {
		return err
	}
	return tx.Commit()
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
	rows, err := s.db.QueryContext(ctx, `SELECT transaction_id FROM multisig_group_transactions WHERE group_id = ?`, groupID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var ids []string
	for rows.Next() {
		var id string
		if err := rows.Scan(&id); err != nil {
			return nil, err
		}
		ids = append(ids, id)
	}
	return ids, rows.Err()
}

func (s *Store) ReplaceGroupTransactionIDs(ctx context.Context, groupID string, txIDs []string) error {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback() //nolint:errcheck

	if err := replaceGroupTransactionIDsOn(ctx, tx, groupID, txIDs); err != nil {
		return err
	}
	return tx.Commit()
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

func (s *Store) ListTransactions(ctx context.Context, groupID string) ([]Transaction, error) {
	query := `
		SELECT id, group_id, initial_psbt, COALESCE(combined_psbt,''), COALESCE(final_hex,''),
		       COALESCE(txid,''), status, type, created, broadcast_time, amount, destination, fee,
		       confirmations, required_signatures
		FROM multisig_transactions`
	var args []interface{}
	if groupID != "" {
		query += ` WHERE group_id = ?`
		args = append(args, groupID)
	}
	query += ` ORDER BY created ASC`

	rows, err := s.db.QueryContext(ctx, query, args...)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var txns []Transaction
	for rows.Next() {
		var t Transaction
		var broadcastTime sql.NullInt64
		if err := rows.Scan(&t.ID, &t.GroupID, &t.InitialPSBT, &t.CombinedPSBT, &t.FinalHex,
			&t.Txid, &t.Status, &t.Type, &t.Created, &broadcastTime, &t.Amount, &t.Destination,
			&t.Fee, &t.Confirmations, &t.RequiredSignatures); err != nil {
			return nil, err
		}
		if broadcastTime.Valid {
			t.BroadcastTime = &broadcastTime.Int64
		}
		txns = append(txns, t)
	}
	return txns, rows.Err()
}

func (s *Store) GetTransaction(ctx context.Context, id string) (*Transaction, error) {
	var t Transaction
	var broadcastTime sql.NullInt64
	err := s.db.QueryRowContext(ctx, `
		SELECT id, group_id, initial_psbt, COALESCE(combined_psbt,''), COALESCE(final_hex,''),
		       COALESCE(txid,''), status, type, created, broadcast_time, amount, destination, fee,
		       confirmations, required_signatures
		FROM multisig_transactions WHERE id = ?`, id).
		Scan(&t.ID, &t.GroupID, &t.InitialPSBT, &t.CombinedPSBT, &t.FinalHex,
			&t.Txid, &t.Status, &t.Type, &t.Created, &broadcastTime, &t.Amount, &t.Destination,
			&t.Fee, &t.Confirmations, &t.RequiredSignatures)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	if broadcastTime.Valid {
		t.BroadcastTime = &broadcastTime.Int64
	}
	return &t, nil
}

func (s *Store) GetTransactionByTxid(ctx context.Context, txid string) (*Transaction, error) {
	var t Transaction
	var broadcastTime sql.NullInt64
	err := s.db.QueryRowContext(ctx, `
		SELECT id, group_id, initial_psbt, COALESCE(combined_psbt,''), COALESCE(final_hex,''),
		       COALESCE(txid,''), status, type, created, broadcast_time, amount, destination, fee,
		       confirmations, required_signatures
		FROM multisig_transactions WHERE txid = ?`, txid).
		Scan(&t.ID, &t.GroupID, &t.InitialPSBT, &t.CombinedPSBT, &t.FinalHex,
			&t.Txid, &t.Status, &t.Type, &t.Created, &broadcastTime, &t.Amount, &t.Destination,
			&t.Fee, &t.Confirmations, &t.RequiredSignatures)
	if err == sql.ErrNoRows {
		return nil, nil
	}
	if err != nil {
		return nil, err
	}
	if broadcastTime.Valid {
		t.BroadcastTime = &broadcastTime.Int64
	}
	return &t, nil
}

func (s *Store) SaveTransaction(ctx context.Context, t Transaction) error {
	return saveTransactionOn(ctx, s.db, t)
}

func saveTransactionOn(ctx context.Context, e execer, t Transaction) error {
	var bt interface{}
	if t.BroadcastTime != nil {
		bt = *t.BroadcastTime
	}
	_, err := e.ExecContext(ctx, `
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
	rows, err := s.db.QueryContext(ctx, `
		SELECT transaction_id, key_id, COALESCE(psbt,''), is_signed, signed_at
		FROM multisig_tx_key_psbts WHERE transaction_id = ?`, transactionID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var psbts []TxKeyPSBT
	for rows.Next() {
		var p TxKeyPSBT
		var signedAt sql.NullInt64
		if err := rows.Scan(&p.TransactionID, &p.KeyID, &p.PSBT, &p.IsSigned, &signedAt); err != nil {
			return nil, err
		}
		if signedAt.Valid {
			p.SignedAt = &signedAt.Int64
		}
		psbts = append(psbts, p)
	}
	return psbts, rows.Err()
}

func (s *Store) ReplaceTxKeyPSBTs(ctx context.Context, transactionID string, psbts []TxKeyPSBT) error {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback() //nolint:errcheck

	if err := replaceTxKeyPSBTsOn(ctx, tx, transactionID, psbts); err != nil {
		return err
	}
	return tx.Commit()
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
	rows, err := s.db.QueryContext(ctx, `
		SELECT transaction_id, txid, vout, COALESCE(address,''), amount, confirmations
		FROM multisig_tx_inputs WHERE transaction_id = ?`, transactionID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var inputs []TxInput
	for rows.Next() {
		var inp TxInput
		if err := rows.Scan(&inp.TransactionID, &inp.Txid, &inp.Vout, &inp.Address, &inp.Amount, &inp.Confirmations); err != nil {
			return nil, err
		}
		inputs = append(inputs, inp)
	}
	return inputs, rows.Err()
}

func (s *Store) ReplaceTxInputs(ctx context.Context, transactionID string, inputs []TxInput) error {
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback() //nolint:errcheck

	if err := replaceTxInputsOn(ctx, tx, transactionID, inputs); err != nil {
		return err
	}
	return tx.Commit()
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
	rows, err := s.db.QueryContext(ctx, `
		SELECT xpub, derivation_path, COALESCE(fingerprint,''), COALESCE(origin_path,''), COALESCE(owner,'')
		FROM multisig_solo_keys`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var keys []SoloKey
	for rows.Next() {
		var k SoloKey
		if err := rows.Scan(&k.Xpub, &k.DerivationPath, &k.Fingerprint, &k.OriginPath, &k.Owner); err != nil {
			return nil, err
		}
		keys = append(keys, k)
	}
	return keys, rows.Err()
}

func (s *Store) AddSoloKey(ctx context.Context, k SoloKey) error {
	_, err := s.db.ExecContext(ctx, `
		INSERT OR IGNORE INTO multisig_solo_keys (xpub, derivation_path, fingerprint, origin_path, owner)
		VALUES (?, ?, ?, ?, ?)`, k.Xpub, k.DerivationPath, nullStr(k.Fingerprint), nullStr(k.OriginPath), nullStr(k.Owner))
	return err
}

// ─── Account Index ─────────────────────────────────────────────────

func (s *Store) GetNextAccountIndex(ctx context.Context, additionalUsed []int) (int, error) {
	maxIndex := 7999

	// Check keys
	rows, err := s.db.QueryContext(ctx, `SELECT derivation_path FROM multisig_keys WHERE is_wallet = 1`)
	if err != nil {
		return 8000, err
	}
	defer rows.Close()

	for rows.Next() {
		var path string
		if err := rows.Scan(&path); err != nil {
			continue
		}
		idx := extractAccountIndex(path)
		if idx > maxIndex {
			maxIndex = idx
		}
	}
	if err := rows.Err(); err != nil {
		return 8000, err
	}

	// Check solo keys
	soloRows, err := s.db.QueryContext(ctx, `SELECT derivation_path FROM multisig_solo_keys`)
	if err != nil {
		return maxIndex + 1, err
	}
	defer soloRows.Close()

	for soloRows.Next() {
		var path string
		if err := soloRows.Scan(&path); err != nil {
			continue
		}
		idx := extractAccountIndex(path)
		if idx > maxIndex {
			maxIndex = idx
		}
	}
	if err := soloRows.Err(); err != nil {
		return maxIndex + 1, err
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
	Group   Group
	Keys    []Key
	KeyPSBTs []KeyPSBT // KeyID is ignored; matched by xpub after key insert
	Addresses []Address
	UtxoDetails []UtxoDetail
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
	defer tx.Rollback() //nolint:errcheck

	if err := saveGroupOn(ctx, tx, p.Group); err != nil {
		return fmt.Errorf("save group: %w", err)
	}

	if err := replaceKeysForGroupOn(ctx, tx, p.Group.ID, p.Keys); err != nil {
		return fmt.Errorf("replace keys: %w", err)
	}

	// Resolve xpub → DB key ID for PSBTs.
	if len(p.XpubToPSBTs) > 0 {
		dbKeys, err := listKeysForGroupOn(ctx, tx, p.Group.ID)
		if err != nil {
			return fmt.Errorf("list keys: %w", err)
		}
		xpubToID := make(map[string]int64, len(dbKeys))
		for _, k := range dbKeys {
			xpubToID[k.Xpub] = k.ID
		}
		for xpub, psbts := range p.XpubToPSBTs {
			keyID, ok := xpubToID[xpub]
			if !ok {
				continue
			}
			for _, kp := range psbts {
				kp.KeyID = keyID
				if err := saveKeyPSBTOn(ctx, tx, kp); err != nil {
					return fmt.Errorf("save key psbt: %w", err)
				}
			}
		}
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
	defer tx.Rollback() //nolint:errcheck

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

	for _, groupRaw := range raw.Groups {
		var gj map[string]interface{}
		if err := json.Unmarshal(groupRaw, &gj); err != nil {
			continue
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

		if err := s.SaveGroup(ctx, g); err != nil {
			return fmt.Errorf("save group %s: %w", g.ID, err)
		}

		// Import keys
		if keysRaw, ok := gj["keys"].([]interface{}); ok {
			var keys []Key
			for i, kr := range keysRaw {
				kd, ok := kr.(map[string]interface{})
				if !ok {
					continue
				}
				keys = append(keys, Key{
					GroupID:        g.ID,
					Owner:          getString(kd, "owner"),
					Xpub:           getStringAlt(kd, "xpub", "pubkey"),
					DerivationPath: getString(kd, "path"),
					Fingerprint:    getString(kd, "fingerprint"),
					OriginPath:     getString(kd, "origin_path"),
					IsWallet:       getBool(kd, "is_wallet"),
					SortOrder:      i,
				})
			}
			if err := s.ReplaceKeysForGroup(ctx, g.ID, keys); err != nil {
				return fmt.Errorf("replace keys for %s: %w", g.ID, err)
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
				if err := s.ReplaceAddresses(ctx, g.ID, addrs); err != nil {
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
				if err := s.ReplaceGroupTransactionIDs(ctx, g.ID, ids); err != nil {
					return fmt.Errorf("replace tx ids for %s: %w", g.ID, err)
				}
			}
		}
	}

	// Import solo keys
	for _, sk := range raw.SoloKeys {
		if err := s.AddSoloKey(ctx, SoloKey{
			Xpub:           getString(sk, "xpub"),
			DerivationPath: getString(sk, "path"),
			Fingerprint:    getString(sk, "fingerprint"),
			OriginPath:     getString(sk, "origin_path"),
			Owner:          getString(sk, "owner"),
		}); err != nil {
			return fmt.Errorf("add solo key: %w", err)
		}
	}

	return nil
}

// ImportTransactionsFromJSON imports transactions from the old transactions.json format.
func (s *Store) ImportTransactionsFromJSON(ctx context.Context, data []byte) error {
	var txns []map[string]interface{}
	if err := json.Unmarshal(data, &txns); err != nil {
		return fmt.Errorf("unmarshal: %w", err)
	}

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
			if t, err := time.Parse(time.RFC3339, bt); err == nil {
				unix := t.Unix()
				broadcastTime = &unix
			}
		}

		var created int64
		if c := getString(tj, "created"); c != "" {
			if t, err := time.Parse(time.RFC3339, c); err == nil {
				created = t.Unix()
			}
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

		// Count required signatures from keyPSBTs length
		if keyPSBTs, ok := tj["keyPSBTs"].([]interface{}); ok {
			t.RequiredSignatures = len(keyPSBTs)
		}

		if t.ID == "" {
			continue
		}

		if err := s.SaveTransaction(ctx, t); err != nil {
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
					if t, err := time.Parse(time.RFC3339, sa); err == nil {
						unix := t.Unix()
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
				if err := s.ReplaceTxKeyPSBTs(ctx, t.ID, psbts); err != nil {
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
				if err := s.ReplaceTxInputs(ctx, t.ID, txInputs); err != nil {
					return fmt.Errorf("replace inputs for tx %s: %w", t.ID, err)
				}
			}
		}
	}

	return nil
}

// ─── helpers ───────────────────────────────────────────────────────

func nullStr(s string) interface{} {
	if s == "" {
		return nil
	}
	return s
}

func extractAccountIndex(path string) int {
	parts := splitPath(path)
	if len(parts) >= 3 {
		idx := trimQuote(parts[2])
		n := 0
		for _, c := range idx {
			if c >= '0' && c <= '9' {
				n = n*10 + int(c-'0')
			}
		}
		return n
	}
	return 0
}

func splitPath(path string) []string {
	// Split "m/84'/1'/8000'" -> ["m", "84'", "1'", "8000'"]
	var result []string
	current := ""
	for _, c := range path {
		if c == '/' {
			if current != "" {
				result = append(result, current)
			}
			current = ""
		} else {
			current += string(c)
		}
	}
	if current != "" {
		result = append(result, current)
	}
	return result
}

func trimQuote(s string) string {
	if len(s) > 0 && s[len(s)-1] == '\'' {
		return s[:len(s)-1]
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
	if v, ok := m[key]; ok {
		switch n := v.(type) {
		case float64:
			return int(n)
		case int:
			return n
		case json.Number:
			i, _ := n.Int64()
			return int(i)
		}
	}
	return 0
}

func getInt64(m map[string]interface{}, key string) int64 {
	if v, ok := m[key]; ok {
		switch n := v.(type) {
		case float64:
			return int64(n)
		case int64:
			return n
		case json.Number:
			i, _ := n.Int64()
			return i
		}
	}
	return 0
}

func getFloat(m map[string]interface{}, key string) float64 {
	if v, ok := m[key]; ok {
		switch n := v.(type) {
		case float64:
			return n
		case int:
			return float64(n)
		case json.Number:
			f, _ := n.Float64()
			return f
		}
	}
	return 0
}

func getBool(m map[string]interface{}, key string) bool {
	if v, ok := m[key]; ok {
		if b, ok := v.(bool); ok {
			return b
		}
	}
	return false
}
