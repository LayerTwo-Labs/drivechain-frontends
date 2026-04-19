package multisig_test

import (
	"context"
	"database/sql"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/multisig"
	_ "github.com/mattn/go-sqlite3"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func setupTestDB(t *testing.T) *sql.DB {
	t.Helper()

	db, err := sql.Open("sqlite3", ":memory:?_foreign_keys=on")
	require.NoError(t, err)

	// Replicate the schema from migrations 031 + 032.
	for _, ddl := range []string{
		`CREATE TABLE multisig_groups (
			id TEXT PRIMARY KEY,
			name TEXT NOT NULL,
			n INTEGER NOT NULL,
			m INTEGER NOT NULL,
			created INTEGER NOT NULL,
			txid TEXT,
			descriptor TEXT,
			descriptor_receive TEXT,
			descriptor_change TEXT,
			watch_wallet_name TEXT,
			balance REAL NOT NULL DEFAULT 0.0,
			utxos INTEGER NOT NULL DEFAULT 0,
			next_receive_index INTEGER NOT NULL DEFAULT 0,
			next_change_index INTEGER NOT NULL DEFAULT 0
		)`,
		`CREATE TABLE multisig_keys (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			group_id TEXT NOT NULL REFERENCES multisig_groups(id) ON DELETE CASCADE,
			owner TEXT NOT NULL,
			xpub TEXT NOT NULL,
			derivation_path TEXT NOT NULL,
			fingerprint TEXT,
			origin_path TEXT,
			is_wallet INTEGER NOT NULL DEFAULT 0,
			sort_order INTEGER NOT NULL DEFAULT 0
		)`,
		`CREATE TABLE multisig_key_psbts (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			key_id INTEGER NOT NULL REFERENCES multisig_keys(id) ON DELETE CASCADE,
			transaction_id TEXT NOT NULL,
			active_psbt TEXT,
			initial_psbt TEXT,
			UNIQUE(key_id, transaction_id)
		)`,
		`CREATE TABLE multisig_addresses (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			group_id TEXT NOT NULL REFERENCES multisig_groups(id) ON DELETE CASCADE,
			addr_type TEXT NOT NULL CHECK(addr_type IN ('receive', 'change')),
			addr_index INTEGER NOT NULL,
			address TEXT NOT NULL,
			used INTEGER NOT NULL DEFAULT 0,
			UNIQUE(group_id, addr_type, addr_index)
		)`,
		`CREATE TABLE multisig_utxo_details (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			group_id TEXT NOT NULL REFERENCES multisig_groups(id) ON DELETE CASCADE,
			txid TEXT NOT NULL,
			vout INTEGER NOT NULL,
			address TEXT,
			amount REAL NOT NULL,
			confirmations INTEGER NOT NULL DEFAULT 0,
			script_pub_key TEXT,
			spendable INTEGER NOT NULL DEFAULT 1,
			solvable INTEGER NOT NULL DEFAULT 1,
			safe INTEGER NOT NULL DEFAULT 1
		)`,
		`CREATE TABLE multisig_group_transactions (
			group_id TEXT NOT NULL REFERENCES multisig_groups(id) ON DELETE CASCADE,
			transaction_id TEXT NOT NULL,
			PRIMARY KEY(group_id, transaction_id)
		)`,
		// 032: FK on group_id
		`CREATE TABLE multisig_transactions (
			id TEXT PRIMARY KEY,
			group_id TEXT NOT NULL REFERENCES multisig_groups(id) ON DELETE CASCADE,
			initial_psbt TEXT NOT NULL DEFAULT '',
			combined_psbt TEXT,
			final_hex TEXT,
			txid TEXT,
			status INTEGER NOT NULL DEFAULT 1,
			type INTEGER NOT NULL DEFAULT 1,
			created INTEGER NOT NULL,
			broadcast_time INTEGER,
			amount REAL NOT NULL DEFAULT 0.0,
			destination TEXT NOT NULL DEFAULT '',
			fee REAL NOT NULL DEFAULT 0.0,
			confirmations INTEGER NOT NULL DEFAULT 0,
			required_signatures INTEGER NOT NULL DEFAULT 0
		)`,
		`CREATE TABLE multisig_tx_key_psbts (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			transaction_id TEXT NOT NULL REFERENCES multisig_transactions(id) ON DELETE CASCADE,
			key_id TEXT NOT NULL,
			psbt TEXT,
			is_signed INTEGER NOT NULL DEFAULT 0,
			signed_at INTEGER,
			UNIQUE(transaction_id, key_id)
		)`,
		`CREATE TABLE multisig_tx_inputs (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			transaction_id TEXT NOT NULL REFERENCES multisig_transactions(id) ON DELETE CASCADE,
			txid TEXT NOT NULL,
			vout INTEGER NOT NULL,
			address TEXT,
			amount REAL NOT NULL DEFAULT 0.0,
			confirmations INTEGER NOT NULL DEFAULT 0
		)`,
		`CREATE TABLE multisig_solo_keys (
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			xpub TEXT NOT NULL UNIQUE,
			derivation_path TEXT NOT NULL,
			fingerprint TEXT,
			origin_path TEXT,
			owner TEXT
		)`,
	} {
		_, err := db.Exec(ddl)
		require.NoError(t, err)
	}

	return db
}

func sampleGroup() multisig.Group {
	return multisig.Group{
		ID:      "grp-1",
		Name:    "Test Group",
		N:       2,
		M:       3,
		Created: 1700000000,
	}
}

// ─── Basic CRUD ────────────────────────────────────────────────────

func TestSaveAndListGroups(t *testing.T) {
	ctx := context.Background()
	store := multisig.NewStore(setupTestDB(t))

	g := sampleGroup()
	require.NoError(t, store.SaveGroup(ctx, g))

	groups, err := store.ListGroups(ctx)
	require.NoError(t, err)
	require.Len(t, groups, 1)
	assert.Equal(t, g.ID, groups[0].ID)
	assert.Equal(t, g.Name, groups[0].Name)
	assert.Equal(t, g.N, groups[0].N)
	assert.Equal(t, g.M, groups[0].M)
}

func TestSaveGroupUpsert(t *testing.T) {
	ctx := context.Background()
	store := multisig.NewStore(setupTestDB(t))

	g := sampleGroup()
	require.NoError(t, store.SaveGroup(ctx, g))

	g.Name = "Updated Name"
	g.Balance = 1.5
	require.NoError(t, store.SaveGroup(ctx, g))

	groups, err := store.ListGroups(ctx)
	require.NoError(t, err)
	require.Len(t, groups, 1)
	assert.Equal(t, "Updated Name", groups[0].Name)
	assert.Equal(t, 1.5, groups[0].Balance)
}

func TestDeleteGroupCascades(t *testing.T) {
	ctx := context.Background()
	store := multisig.NewStore(setupTestDB(t))

	g := sampleGroup()
	require.NoError(t, store.SaveGroup(ctx, g))

	keys := []multisig.Key{{GroupID: g.ID, Owner: "alice", Xpub: "xpub1", DerivationPath: "m/48'/0'/0'"}}
	require.NoError(t, store.ReplaceKeysForGroup(ctx, g.ID, keys))

	require.NoError(t, store.DeleteGroup(ctx, g.ID))

	groups, err := store.ListGroups(ctx)
	require.NoError(t, err)
	assert.Empty(t, groups)

	dbKeys, err := store.ListKeysForGroup(ctx, g.ID)
	require.NoError(t, err)
	assert.Empty(t, dbKeys)
}

func TestReplaceKeysForGroup(t *testing.T) {
	ctx := context.Background()
	store := multisig.NewStore(setupTestDB(t))

	g := sampleGroup()
	require.NoError(t, store.SaveGroup(ctx, g))

	keys := []multisig.Key{
		{GroupID: g.ID, Owner: "alice", Xpub: "xpub1", DerivationPath: "m/48'/0'/0'"},
		{GroupID: g.ID, Owner: "bob", Xpub: "xpub2", DerivationPath: "m/48'/0'/1'"},
	}
	require.NoError(t, store.ReplaceKeysForGroup(ctx, g.ID, keys))

	dbKeys, err := store.ListKeysForGroup(ctx, g.ID)
	require.NoError(t, err)
	require.Len(t, dbKeys, 2)
	assert.Equal(t, "alice", dbKeys[0].Owner)
	assert.Equal(t, "bob", dbKeys[1].Owner)

	// Replace with fewer keys
	require.NoError(t, store.ReplaceKeysForGroup(ctx, g.ID, keys[:1]))
	dbKeys, err = store.ListKeysForGroup(ctx, g.ID)
	require.NoError(t, err)
	assert.Len(t, dbKeys, 1)
}

func TestSaveAndGetTransaction(t *testing.T) {
	ctx := context.Background()
	store := multisig.NewStore(setupTestDB(t))

	g := sampleGroup()
	require.NoError(t, store.SaveGroup(ctx, g))

	bt := int64(1700001000)
	tx := multisig.Transaction{
		ID:            "tx-1",
		GroupID:       g.ID,
		InitialPSBT:   "psbt-data",
		Status:        1,
		Type:          2,
		Created:       1700000500,
		BroadcastTime: &bt,
		Amount:        0.5,
		Destination:   "bc1qtest",
		Fee:           0.0001,
	}
	require.NoError(t, store.SaveTransaction(ctx, tx))

	got, err := store.GetTransaction(ctx, "tx-1")
	require.NoError(t, err)
	require.NotNil(t, got)
	assert.Equal(t, tx.ID, got.ID)
	assert.Equal(t, tx.GroupID, got.GroupID)
	assert.Equal(t, tx.Amount, got.Amount)
	assert.NotNil(t, got.BroadcastTime)
	assert.Equal(t, bt, *got.BroadcastTime)
}

func TestGetTransactionByTxid(t *testing.T) {
	ctx := context.Background()
	store := multisig.NewStore(setupTestDB(t))

	g := sampleGroup()
	require.NoError(t, store.SaveGroup(ctx, g))

	tx := multisig.Transaction{
		ID:      "tx-2",
		GroupID: g.ID,
		Txid:    "abc123",
		Status:  5,
		Type:    1,
		Created: 1700000500,
	}
	require.NoError(t, store.SaveTransaction(ctx, tx))

	got, err := store.GetTransactionByTxid(ctx, "abc123")
	require.NoError(t, err)
	require.NotNil(t, got)
	assert.Equal(t, "tx-2", got.ID)

	// Non-existent
	got, err = store.GetTransactionByTxid(ctx, "nope")
	require.NoError(t, err)
	assert.Nil(t, got)
}

func TestSoloKeys(t *testing.T) {
	ctx := context.Background()
	store := multisig.NewStore(setupTestDB(t))

	sk := multisig.SoloKey{Xpub: "xpub-solo", DerivationPath: "m/84'/0'/0'", Owner: "alice"}
	require.NoError(t, store.AddSoloKey(ctx, sk))

	// Duplicate should be ignored (INSERT OR IGNORE)
	require.NoError(t, store.AddSoloKey(ctx, sk))

	keys, err := store.ListSoloKeys(ctx)
	require.NoError(t, err)
	require.Len(t, keys, 1)
	assert.Equal(t, "xpub-solo", keys[0].Xpub)
}

// ─── Atomic operations ─────────────────────────────────────────────

func TestSaveGroupAtomic(t *testing.T) {
	ctx := context.Background()
	store := multisig.NewStore(setupTestDB(t))

	g := sampleGroup()
	keys := []multisig.Key{
		{GroupID: g.ID, Owner: "alice", Xpub: "xpub1", DerivationPath: "m/48'/0'/8000'", IsWallet: true},
		{GroupID: g.ID, Owner: "bob", Xpub: "xpub2", DerivationPath: "m/48'/0'/8001'"},
	}
	addrs := []multisig.Address{
		{GroupID: g.ID, AddrType: "receive", Index: 0, Addr: "bc1q1"},
		{GroupID: g.ID, AddrType: "change", Index: 0, Addr: "bc1q2"},
	}
	utxos := []multisig.UtxoDetail{
		{GroupID: g.ID, Txid: "utxo-tx", Vout: 0, Amount: 1.0},
	}
	xpubPSBTs := map[string][]multisig.KeyPSBT{
		"xpub1": {
			{TransactionID: "tx-a", ActivePSBT: "signed-psbt", InitialPSBT: "initial-psbt"},
		},
	}

	require.NoError(t, store.SaveGroupAtomic(ctx, multisig.SaveGroupAtomicParams{
		Group:          g,
		Keys:           keys,
		XpubToPSBTs:    xpubPSBTs,
		Addresses:      addrs,
		UtxoDetails:    utxos,
		TransactionIDs: []string{"tx-a", "tx-b"},
	}))

	// Verify group
	groups, err := store.ListGroups(ctx)
	require.NoError(t, err)
	require.Len(t, groups, 1)

	// Verify keys
	dbKeys, err := store.ListKeysForGroup(ctx, g.ID)
	require.NoError(t, err)
	require.Len(t, dbKeys, 2)

	// Verify key PSBTs
	kpsbts, err := store.ListKeyPSBTs(ctx, g.ID)
	require.NoError(t, err)
	require.Len(t, kpsbts, 1)
	assert.Equal(t, "signed-psbt", kpsbts[0].ActivePSBT)

	// Verify addresses
	dbAddrs, err := store.ListAddresses(ctx, g.ID)
	require.NoError(t, err)
	assert.Len(t, dbAddrs, 2)

	// Verify UTXOs
	dbUtxos, err := store.ListUtxoDetails(ctx, g.ID)
	require.NoError(t, err)
	assert.Len(t, dbUtxos, 1)

	// Verify transaction IDs
	txIDs, err := store.ListGroupTransactionIDs(ctx, g.ID)
	require.NoError(t, err)
	assert.Equal(t, []string{"tx-a", "tx-b"}, txIDs)
}

func TestSaveTransactionAtomic(t *testing.T) {
	ctx := context.Background()
	store := multisig.NewStore(setupTestDB(t))

	g := sampleGroup()
	require.NoError(t, store.SaveGroup(ctx, g))

	bt := int64(1700001000)
	tx := multisig.Transaction{
		ID:            "tx-1",
		GroupID:       g.ID,
		InitialPSBT:   "psbt-data",
		Status:        1,
		Type:          2,
		Created:       1700000500,
		BroadcastTime: &bt,
		Amount:        0.5,
		Destination:   "bc1qtest",
		Fee:           0.0001,
	}
	keyPSBTs := []multisig.TxKeyPSBT{
		{TransactionID: tx.ID, KeyID: "key-1", PSBT: "psbt-1", IsSigned: true},
		{TransactionID: tx.ID, KeyID: "key-2", PSBT: "psbt-2"},
	}
	inputs := []multisig.TxInput{
		{TransactionID: tx.ID, Txid: "input-txid", Vout: 0, Amount: 1.0},
	}

	require.NoError(t, store.SaveTransactionAtomic(ctx, multisig.SaveTransactionAtomicParams{
		Transaction: tx,
		KeyPSBTs:    keyPSBTs,
		Inputs:      inputs,
	}))

	// Verify transaction
	got, err := store.GetTransaction(ctx, "tx-1")
	require.NoError(t, err)
	require.NotNil(t, got)
	assert.Equal(t, 0.5, got.Amount)

	// Verify key PSBTs
	dbPSBTs, err := store.ListTxKeyPSBTs(ctx, "tx-1")
	require.NoError(t, err)
	require.Len(t, dbPSBTs, 2)

	// Verify inputs
	dbInputs, err := store.ListTxInputs(ctx, "tx-1")
	require.NoError(t, err)
	require.Len(t, dbInputs, 1)
}

func TestSaveTransactionAtomic_FKViolation(t *testing.T) {
	ctx := context.Background()
	store := multisig.NewStore(setupTestDB(t))

	// Try saving a transaction with non-existent group_id — should fail due to FK.
	tx := multisig.Transaction{
		ID:      "tx-orphan",
		GroupID: "nonexistent-group",
		Status:  1,
		Type:    1,
		Created: 1700000500,
	}
	err := store.SaveTransactionAtomic(ctx, multisig.SaveTransactionAtomicParams{
		Transaction: tx,
	})
	require.Error(t, err, "FK constraint should reject orphan transaction")
}

func TestSaveGroupAtomic_UpdateExisting(t *testing.T) {
	ctx := context.Background()
	store := multisig.NewStore(setupTestDB(t))

	g := sampleGroup()
	// First save
	require.NoError(t, store.SaveGroupAtomic(ctx, multisig.SaveGroupAtomicParams{
		Group: g,
		Keys:  []multisig.Key{{GroupID: g.ID, Owner: "alice", Xpub: "xpub1", DerivationPath: "m/48'/0'/0'"}},
	}))

	// Update with different keys and balance
	g.Balance = 2.5
	g.Name = "Updated"
	require.NoError(t, store.SaveGroupAtomic(ctx, multisig.SaveGroupAtomicParams{
		Group: g,
		Keys:  []multisig.Key{{GroupID: g.ID, Owner: "charlie", Xpub: "xpub3", DerivationPath: "m/48'/0'/2'"}},
	}))

	groups, err := store.ListGroups(ctx)
	require.NoError(t, err)
	require.Len(t, groups, 1)
	assert.Equal(t, "Updated", groups[0].Name)
	assert.Equal(t, 2.5, groups[0].Balance)

	dbKeys, err := store.ListKeysForGroup(ctx, g.ID)
	require.NoError(t, err)
	require.Len(t, dbKeys, 1)
	assert.Equal(t, "charlie", dbKeys[0].Owner)
}

func TestGetNextAccountIndex(t *testing.T) {
	ctx := context.Background()
	store := multisig.NewStore(setupTestDB(t))

	g := sampleGroup()
	require.NoError(t, store.SaveGroup(ctx, g))

	// extractAccountIndex reads parts[2] of the derivation path.
	// For m/48'/8000'/0' → parts=[m,48',8000',0'] → parts[2]=8000' → 8000
	keys := []multisig.Key{
		{GroupID: g.ID, Owner: "a", Xpub: "x1", DerivationPath: "m/48'/8000'/0'", IsWallet: true},
		{GroupID: g.ID, Owner: "b", Xpub: "x2", DerivationPath: "m/48'/8005'/0'", IsWallet: true},
	}
	require.NoError(t, store.ReplaceKeysForGroup(ctx, g.ID, keys))

	next, err := store.GetNextAccountIndex(ctx, nil)
	require.NoError(t, err)
	assert.Equal(t, 8006, next)

	// With additional used indices
	next, err = store.GetNextAccountIndex(ctx, []int{9000})
	require.NoError(t, err)
	assert.Equal(t, 9001, next)
}
