package multisig_test

import (
	"bytes"
	"database/sql"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/multisig"
)

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
	ctx := t.Context()
	store := multisig.NewStore(database.Test(t))

	g := sampleGroup()
	require.NoError(t, store.SaveGroupAtomic(ctx, multisig.SaveGroupAtomicParams{Group: g}))

	groups, err := store.ListGroups(ctx)
	require.NoError(t, err)
	require.Len(t, groups, 1)
	assert.Equal(t, g.ID, groups[0].ID)
	assert.Equal(t, g.Name, groups[0].Name)
	assert.Equal(t, g.N, groups[0].N)
	assert.Equal(t, g.M, groups[0].M)
}

func TestSaveGroupUpsert(t *testing.T) {
	ctx := t.Context()
	store := multisig.NewStore(database.Test(t))

	g := sampleGroup()
	require.NoError(t, store.SaveGroupAtomic(ctx, multisig.SaveGroupAtomicParams{Group: g}))

	g.Name = "Updated Name"
	g.Balance = 1.5
	require.NoError(t, store.SaveGroupAtomic(ctx, multisig.SaveGroupAtomicParams{Group: g}))

	groups, err := store.ListGroups(ctx)
	require.NoError(t, err)
	require.Len(t, groups, 1)
	assert.Equal(t, "Updated Name", groups[0].Name)
	assert.Equal(t, 1.5, groups[0].Balance)
}

func countRows(t *testing.T, db *sql.DB, query string, args ...any) int {
	t.Helper()
	var n int
	require.NoError(t, db.QueryRowContext(t.Context(), query, args...).Scan(&n))
	return n
}

func saveGroupWithChildren(t *testing.T, store *multisig.Store, groupID string) {
	t.Helper()
	ctx := t.Context()
	g := sampleGroup()
	g.ID = groupID
	txID := "tx-" + groupID
	require.NoError(t, store.SaveGroupAtomic(ctx, multisig.SaveGroupAtomicParams{
		Group:          g,
		Keys:           []multisig.Key{{GroupID: g.ID, Owner: "alice", Xpub: "xpub-" + groupID, DerivationPath: "m/48'/0'/0'"}},
		XpubToPSBTs:    map[string][]multisig.KeyPSBT{"xpub-" + groupID: {{TransactionID: txID, ActivePSBT: "psbt"}}},
		Addresses:      []multisig.Address{{GroupID: g.ID, AddrType: "receive", Addr: "bc1q-" + groupID}},
		UtxoDetails:    []multisig.UtxoDetail{{GroupID: g.ID, Txid: "utxo-" + groupID, Amount: 1.0}},
		TransactionIDs: []string{txID},
	}))
	require.NoError(t, store.SaveTransactionAtomic(ctx, multisig.SaveTransactionAtomicParams{
		Transaction: multisig.Transaction{ID: txID, GroupID: g.ID, Status: 1, Type: 1, Created: 1700000500},
		KeyPSBTs:    []multisig.TxKeyPSBT{{TransactionID: txID, KeyID: "key-1", PSBT: "psbt-1"}},
		Inputs:      []multisig.TxInput{{TransactionID: txID, Txid: "input-" + groupID, Amount: 1.0}},
	}))
}

func TestDeleteGroup(t *testing.T) {
	ctx := t.Context()
	db := database.Test(t)
	store := multisig.NewStore(db)

	saveGroupWithChildren(t, store, "grp-1")
	saveGroupWithChildren(t, store, "grp-2")

	require.NoError(t, store.DeleteGroup(ctx, "grp-1"))

	for _, tc := range []struct {
		table string
		query string
		arg   string
	}{
		{"groups", `SELECT COUNT(*) FROM multisig_groups WHERE id = ?`, "grp-"},
		{"keys", `SELECT COUNT(*) FROM multisig_keys WHERE group_id = ?`, "grp-"},
		{"key psbts", `SELECT COUNT(*) FROM multisig_key_psbts WHERE transaction_id = ?`, "tx-grp-"},
		{"addresses", `SELECT COUNT(*) FROM multisig_addresses WHERE group_id = ?`, "grp-"},
		{"utxo details", `SELECT COUNT(*) FROM multisig_utxo_details WHERE group_id = ?`, "grp-"},
		{"group transactions", `SELECT COUNT(*) FROM multisig_group_transactions WHERE group_id = ?`, "grp-"},
		{"transactions", `SELECT COUNT(*) FROM multisig_transactions WHERE group_id = ?`, "grp-"},
		{"tx key psbts", `SELECT COUNT(*) FROM multisig_tx_key_psbts WHERE transaction_id = ?`, "tx-grp-"},
		{"tx inputs", `SELECT COUNT(*) FROM multisig_tx_inputs WHERE transaction_id = ?`, "tx-grp-"},
	} {
		t.Run(tc.table, func(t *testing.T) {
			assert.Zero(t, countRows(t, db, tc.query, tc.arg+"1"))
			assert.Equal(t, 1, countRows(t, db, tc.query, tc.arg+"2"))
		})
	}
}

func TestSaveAndGetTransaction(t *testing.T) {
	ctx := t.Context()
	store := multisig.NewStore(database.Test(t))

	g := sampleGroup()
	require.NoError(t, store.SaveGroupAtomic(ctx, multisig.SaveGroupAtomicParams{Group: g}))

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
	require.NoError(t, store.SaveTransactionAtomic(ctx, multisig.SaveTransactionAtomicParams{Transaction: tx}))

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
	ctx := t.Context()
	store := multisig.NewStore(database.Test(t))

	g := sampleGroup()
	require.NoError(t, store.SaveGroupAtomic(ctx, multisig.SaveGroupAtomicParams{Group: g}))

	tx := multisig.Transaction{
		ID:      "tx-2",
		GroupID: g.ID,
		Txid:    "abc123",
		Status:  5,
		Type:    1,
		Created: 1700000500,
	}
	require.NoError(t, store.SaveTransactionAtomic(ctx, multisig.SaveTransactionAtomicParams{Transaction: tx}))

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
	ctx := t.Context()
	store := multisig.NewStore(database.Test(t))

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
	ctx := t.Context()
	store := multisig.NewStore(database.Test(t))

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
	ctx := t.Context()
	store := multisig.NewStore(database.Test(t))

	g := sampleGroup()
	require.NoError(t, store.SaveGroupAtomic(ctx, multisig.SaveGroupAtomicParams{Group: g}))

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

func TestSaveTransactionAtomic_CrossGroupCollisionRejected(t *testing.T) {
	ctx := t.Context()
	store := multisig.NewStore(database.Test(t))

	groupA := sampleGroup()
	require.NoError(t, store.SaveGroupAtomic(ctx, multisig.SaveGroupAtomicParams{Group: groupA}))
	groupB := sampleGroup()
	groupB.ID = "grp-2"
	groupB.Name = "Other Group"
	require.NoError(t, store.SaveGroupAtomic(ctx, multisig.SaveGroupAtomicParams{Group: groupB}))

	// Group A saves a transaction with a signed PSBT and an input.
	require.NoError(t, store.SaveTransactionAtomic(ctx, multisig.SaveTransactionAtomicParams{
		Transaction: multisig.Transaction{
			ID: "tx-collide", GroupID: groupA.ID, InitialPSBT: "psbt-a", Status: 1, Type: 1, Created: 1700000500,
		},
		KeyPSBTs: []multisig.TxKeyPSBT{{TransactionID: "tx-collide", KeyID: "key-a", PSBT: "signed-psbt-a", IsSigned: true}},
		Inputs:   []multisig.TxInput{{TransactionID: "tx-collide", Txid: "input-a", Vout: 0, Amount: 1.0}},
	}))

	// Group B tries to save a transaction whose id collides with group A's — must be rejected.
	err := store.SaveTransactionAtomic(ctx, multisig.SaveTransactionAtomicParams{
		Transaction: multisig.Transaction{
			ID: "tx-collide", GroupID: groupB.ID, InitialPSBT: "psbt-b", Status: 1, Type: 1, Created: 1700000600,
		},
		KeyPSBTs: []multisig.TxKeyPSBT{{TransactionID: "tx-collide", KeyID: "key-b", PSBT: "unsigned-psbt-b"}},
		Inputs:   []multisig.TxInput{{TransactionID: "tx-collide", Txid: "input-b", Vout: 0, Amount: 2.0}},
	})
	require.ErrorContains(t, err, "already belongs to group")

	// Group A's transaction, PSBT and input must be untouched.
	got, err := store.GetTransaction(ctx, "tx-collide")
	require.NoError(t, err)
	require.NotNil(t, got)
	assert.Equal(t, groupA.ID, got.GroupID)
	assert.Equal(t, "psbt-a", got.InitialPSBT)

	dbPSBTs, err := store.ListTxKeyPSBTs(ctx, "tx-collide")
	require.NoError(t, err)
	require.Len(t, dbPSBTs, 1)
	assert.Equal(t, "signed-psbt-a", dbPSBTs[0].PSBT)
	assert.True(t, dbPSBTs[0].IsSigned)

	dbInputs, err := store.ListTxInputs(ctx, "tx-collide")
	require.NoError(t, err)
	require.Len(t, dbInputs, 1)
	assert.Equal(t, "input-a", dbInputs[0].Txid)

	// Group B still sees no transaction under the colliding id.
	bTxns, err := store.ListTransactions(ctx, groupB.ID)
	require.NoError(t, err)
	assert.Empty(t, bTxns)
}

func TestSaveGroupAtomic_UpdateExisting(t *testing.T) {
	ctx := t.Context()
	db := database.Test(t)
	store := multisig.NewStore(db)

	g := sampleGroup()
	// First save
	require.NoError(t, store.SaveGroupAtomic(ctx, multisig.SaveGroupAtomicParams{
		Group:       g,
		Keys:        []multisig.Key{{GroupID: g.ID, Owner: "alice", Xpub: "xpub1", DerivationPath: "m/48'/0'/0'"}},
		XpubToPSBTs: map[string][]multisig.KeyPSBT{"xpub1": {{TransactionID: "tx-a", ActivePSBT: "psbt"}}},
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

	assert.Zero(t, countRows(t, db, `SELECT COUNT(*) FROM multisig_key_psbts`))
}

func TestGetNextAccountIndex(t *testing.T) {
	ctx := t.Context()
	store := multisig.NewStore(database.Test(t))

	g := sampleGroup()

	// The shipped path shape is m/84'/coin'/account'.
	keys := []multisig.Key{
		{GroupID: g.ID, Owner: "a", Xpub: "x1", DerivationPath: "m/84'/1'/8000'", IsWallet: true},
		{GroupID: g.ID, Owner: "b", Xpub: "x2", DerivationPath: "m/84'/1'/8005'", IsWallet: true},
	}
	require.NoError(t, store.SaveGroupAtomic(ctx, multisig.SaveGroupAtomicParams{Group: g, Keys: keys}))

	next, err := store.GetNextAccountIndex(ctx, nil)
	require.NoError(t, err)
	assert.Equal(t, 8006, next)

	// With additional used indices
	next, err = store.GetNextAccountIndex(ctx, []int{9000})
	require.NoError(t, err)
	assert.Equal(t, 9001, next)

	require.NoError(t, store.AddSoloKey(ctx, multisig.SoloKey{Xpub: "solo1", DerivationPath: "m/84'/1'/8010'"}))
	next, err = store.GetNextAccountIndex(ctx, nil)
	require.NoError(t, err)
	assert.Equal(t, 8011, next)
}

func TestGetNextAccountIndexAdvancesAcrossSessions(t *testing.T) {
	ctx := t.Context()
	store := multisig.NewStore(database.Test(t))

	g := sampleGroup()
	require.NoError(t, store.SaveGroupAtomic(ctx, multisig.SaveGroupAtomicParams{Group: g}))

	first, err := store.GetNextAccountIndex(ctx, nil)
	require.NoError(t, err)
	assert.Equal(t, 8000, first)

	// A key stored at the allocated index must push the next allocation forward,
	// even though the caller passes no additionally used indices.
	require.NoError(t, store.SaveGroupAtomic(ctx, multisig.SaveGroupAtomicParams{Group: g, Keys: []multisig.Key{
		{GroupID: g.ID, Owner: "a", Xpub: "x1", DerivationPath: "m/84'/1'/8000'", IsWallet: true},
	}}))

	second, err := store.GetNextAccountIndex(ctx, nil)
	require.NoError(t, err)
	assert.Equal(t, 8001, second, "second allocation reused the first account index")
}

func TestSaveGroupAtomic_UnknownPSBTXpub(t *testing.T) {
	ctx := t.Context()
	store := multisig.NewStore(database.Test(t))

	g := sampleGroup()
	err := store.SaveGroupAtomic(ctx, multisig.SaveGroupAtomicParams{
		Group: g,
		Keys: []multisig.Key{
			{GroupID: g.ID, Owner: "alice", Xpub: "xpub1", DerivationPath: "m/48'/0'/8000'"},
		},
		XpubToPSBTs: map[string][]multisig.KeyPSBT{
			"xpub-unknown": {{TransactionID: "tx-a", ActivePSBT: "psbt"}},
		},
	})
	require.ErrorContains(t, err, "psbt xpub xpub-unknown has no key")

	groups, err := store.ListGroups(ctx)
	require.NoError(t, err)
	require.Empty(t, groups)
}

func TestImportFromJSON_BadGroup(t *testing.T) {
	store := multisig.NewStore(database.Test(t))

	err := store.ImportFromJSON(t.Context(), []byte(`{"groups":[[1,2]]}`))
	require.ErrorContains(t, err, "unmarshal group")
}

func TestImportFromJSON_FailedImportWritesNothing(t *testing.T) {
	ctx := t.Context()
	store := multisig.NewStore(database.Test(t))

	data := `{
		"groups": [{
			"id": "grp-1", "name": "G", "n": 2, "m": 3,
			"keys": [{"owner": "alice", "xpub": "xpub1", "path": "m/48'/0'/0'"}],
			"addresses": {"receive": [{"index": 0, "address": "bc1q1"}, {"index": 0, "address": "bc1q2"}]}
		}],
		"solo_keys": [{"xpub": "solo1", "path": "m/84'/0'/0'"}]
	}`
	err := store.ImportFromJSON(ctx, []byte(data))
	require.ErrorContains(t, err, "UNIQUE constraint failed")

	groups, err := store.ListGroups(ctx)
	require.NoError(t, err)
	assert.Empty(t, groups)
	keys, err := store.ListKeysForGroup(ctx, "grp-1")
	require.NoError(t, err)
	assert.Empty(t, keys)
	soloKeys, err := store.ListSoloKeys(ctx)
	require.NoError(t, err)
	assert.Empty(t, soloKeys)
}

func TestImportTransactionsFromJSON_FailedImportWritesNothing(t *testing.T) {
	ctx := t.Context()
	store := multisig.NewStore(database.Test(t))

	g := sampleGroup()
	require.NoError(t, store.SaveGroupAtomic(ctx, multisig.SaveGroupAtomicParams{Group: g}))

	data := `[
		{"id": "tx-1", "groupId": "` + g.ID + `", "inputs": [{"txid": "in-1", "vout": 0}]},
		{"id": "tx-2", "groupId": "` + g.ID + `", "keyPSBTs": [{"keyId": "k1"}, {"keyId": "k1"}]}
	]`
	err := store.ImportTransactionsFromJSON(ctx, []byte(data))
	require.ErrorContains(t, err, "UNIQUE constraint failed")

	txns, err := store.ListTransactions(ctx, g.ID)
	require.NoError(t, err)
	assert.Empty(t, txns)
	inputs, err := store.ListTxInputs(ctx, "tx-1")
	require.NoError(t, err)
	assert.Empty(t, inputs)
}

func TestImportTransactionsFromJSON_BadTime(t *testing.T) {
	var logs bytes.Buffer
	ctx := zerolog.New(&logs).WithContext(t.Context())
	store := multisig.NewStore(database.Test(t))

	g := sampleGroup()
	require.NoError(t, store.SaveGroupAtomic(ctx, multisig.SaveGroupAtomicParams{Group: g}))

	data := `[{"id":"tx-1","groupId":"` + g.ID + `","created":"yesterday","broadcastTime":"2024-01-02T03:04:05Z"}]`
	require.NoError(t, store.ImportTransactionsFromJSON(ctx, []byte(data)))

	got, err := store.GetTransaction(ctx, "tx-1")
	require.NoError(t, err)
	assert.Equal(t, int64(0), got.Created)
	require.NotNil(t, got.BroadcastTime)
	assert.Equal(t, int64(1704164645), *got.BroadcastTime)
	assert.Contains(t, logs.String(), `"field":"created"`)
}

func TestListTransactions(t *testing.T) {
	ctx := t.Context()
	store := multisig.NewStore(database.Test(t))

	g := sampleGroup()
	require.NoError(t, store.SaveGroupAtomic(ctx, multisig.SaveGroupAtomicParams{Group: g}))
	other := sampleGroup()
	other.ID = "group-other"
	require.NoError(t, store.SaveGroupAtomic(ctx, multisig.SaveGroupAtomicParams{Group: other}))

	require.NoError(t, store.SaveTransactionAtomic(ctx, multisig.SaveTransactionAtomicParams{Transaction: multisig.Transaction{ID: "tx-late", GroupID: g.ID, Status: 1, Type: 1, Created: 20}}))
	require.NoError(t, store.SaveTransactionAtomic(ctx, multisig.SaveTransactionAtomicParams{Transaction: multisig.Transaction{ID: "tx-early", GroupID: g.ID, Status: 1, Type: 1, Created: 10}}))
	require.NoError(t, store.SaveTransactionAtomic(ctx, multisig.SaveTransactionAtomicParams{Transaction: multisig.Transaction{ID: "tx-other", GroupID: other.ID, Status: 1, Type: 1, Created: 5}}))

	t.Run("one group, oldest first", func(t *testing.T) {
		txns, err := store.ListTransactions(t.Context(), g.ID)
		require.NoError(t, err)
		require.Len(t, txns, 2)
		assert.Equal(t, "tx-early", txns[0].ID)
		assert.Equal(t, "tx-late", txns[1].ID)
	})
	t.Run("all groups", func(t *testing.T) {
		txns, err := store.ListTransactions(t.Context(), "")
		require.NoError(t, err)
		require.Len(t, txns, 3)
		assert.Equal(t, "tx-other", txns[0].ID)
	})
	t.Run("get missing id", func(t *testing.T) {
		got, err := store.GetTransaction(t.Context(), "missing")
		require.NoError(t, err)
		assert.Nil(t, got)
	})
}

func TestImportTransactionsFromJSON_RequiredSignatures(t *testing.T) {
	ctx := t.Context()
	store := multisig.NewStore(database.Test(t))

	g := sampleGroup()
	require.NoError(t, store.SaveGroupAtomic(ctx, multisig.SaveGroupAtomicParams{Group: g}))

	keyPSBTs := `"keyPSBTs": [{"keyId": "k1"}, {"keyId": "k2"}, {"keyId": "k3"}]`
	data := `[
		{"id": "tx-2of3", "groupId": "` + g.ID + `", "requiredSignatures": 2, ` + keyPSBTs + `},
		{"id": "tx-old", "groupId": "` + g.ID + `", ` + keyPSBTs + `}
	]`
	require.NoError(t, store.ImportTransactionsFromJSON(ctx, []byte(data)))

	for id, want := range map[string]int{"tx-2of3": 2, "tx-old": 3} {
		t.Run(id, func(t *testing.T) {
			got, err := store.GetTransaction(t.Context(), id)
			require.NoError(t, err)
			require.NotNil(t, got)
			assert.Equal(t, want, got.RequiredSignatures)
		})
	}
}

func TestImportFromJSON_KeyPSBTs(t *testing.T) {
	const withPSBTs = `{"groups":[{"id":"grp-1","name":"G","n":2,"m":2,"keys":[
		{"owner":"me","xpub":"tpubA","path":"m/48'/1'/0'/2'","active_psbts":{"tx-1":"active-1"},"initial_psbts":{"tx-1":"initial-1","tx-2":"initial-2"}},
		{"owner":"bob","xpub":"tpubB","path":"m/48'/1'/1'/2'"}]}]}`
	const withoutPSBTs = `{"groups":[{"id":"grp-1","name":"G","n":2,"m":2,"keys":[
		{"owner":"me","xpub":"tpubA","path":"m/48'/1'/0'/2'"},
		{"owner":"bob","xpub":"tpubB","path":"m/48'/1'/1'/2'"}]}]}`

	listPSBTs := func(t *testing.T, store *multisig.Store) []multisig.KeyPSBT {
		t.Helper()
		keys, err := store.ListKeysForGroup(t.Context(), "grp-1")
		require.NoError(t, err)
		require.Len(t, keys, 2)
		psbts, err := store.ListKeyPSBTs(t.Context(), "grp-1")
		require.NoError(t, err)
		for i := range psbts {
			require.Equal(t, keys[0].ID, psbts[i].KeyID)
			psbts[i].KeyID = 0
		}
		return psbts
	}
	want := []multisig.KeyPSBT{
		{TransactionID: "tx-1", ActivePSBT: "active-1", InitialPSBT: "initial-1"},
		{TransactionID: "tx-2", InitialPSBT: "initial-2"},
	}

	t.Run("reads key psbts", func(t *testing.T) {
		store := multisig.NewStore(database.Test(t))
		require.NoError(t, store.ImportFromJSON(t.Context(), []byte(withPSBTs)))

		assert.ElementsMatch(t, want, listPSBTs(t, store))
	})

	t.Run("keeps key psbts on a restore over the group", func(t *testing.T) {
		store := multisig.NewStore(database.Test(t))
		require.NoError(t, store.ImportFromJSON(t.Context(), []byte(withPSBTs)))
		require.NoError(t, store.ImportFromJSON(t.Context(), []byte(withoutPSBTs)))

		assert.ElementsMatch(t, want, listPSBTs(t, store))
	})

	t.Run("replaces key psbts of the same transaction", func(t *testing.T) {
		store := multisig.NewStore(database.Test(t))
		require.NoError(t, store.ImportFromJSON(t.Context(), []byte(withoutPSBTs)))
		require.NoError(t, store.SaveGroupAtomic(t.Context(), multisig.SaveGroupAtomicParams{
			Group: multisig.Group{ID: "grp-1", Name: "G", N: 2, M: 2},
			Keys: []multisig.Key{
				{Owner: "me", Xpub: "tpubA", DerivationPath: "m/48'/1'/0'/2'"},
				{Owner: "bob", Xpub: "tpubB", DerivationPath: "m/48'/1'/1'/2'"},
			},
			XpubToPSBTs: map[string][]multisig.KeyPSBT{"tpubA": {{TransactionID: "tx-1", ActivePSBT: "old"}}},
		}))
		require.NoError(t, store.ImportFromJSON(t.Context(), []byte(withPSBTs)))

		assert.ElementsMatch(t, want, listPSBTs(t, store))
	})
}
