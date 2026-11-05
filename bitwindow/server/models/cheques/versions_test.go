package cheques_test

import (
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/cheques"
)

func TestChequeVersionsKeepSeparateCounters(t *testing.T) {
	db := database.Test(t)
	ctx := t.Context()
	legacyID, err := cheques.Create(ctx, db, testWalletID, 0, 1000, "legacy-address")
	require.NoError(t, err)
	versionedID, err := cheques.CreateVersioned(ctx, db, testWalletID, 0, 2000, "new-address", 1, "root", "network")
	require.NoError(t, err)
	legacy, err := cheques.Get(ctx, db, testWalletID, legacyID)
	require.NoError(t, err)
	require.Zero(t, legacy.KeyVersion)
	require.Empty(t, legacy.KeyDomain)
	require.Empty(t, legacy.KeyScope)
	versioned, err := cheques.Get(ctx, db, testWalletID, versionedID)
	require.NoError(t, err)
	require.Equal(t, uint32(1), versioned.KeyVersion)
	require.Equal(t, "root", versioned.KeyDomain)
	require.Equal(t, "network", versioned.KeyScope)

	_, err = cheques.CreateVersioned(ctx, db, "same-seed-wallet", 1, 1000, "next-address", 1, "root", "network")
	require.NoError(t, err)
	require.NoError(t, cheques.Delete(ctx, db, testWalletID, versionedID))
	next, err := cheques.GetNextDomainIndex(ctx, db, "root")
	require.NoError(t, err)
	require.Equal(t, uint32(2), next)
	legacyNext, err := cheques.GetNextIndex(ctx, db, testWalletID)
	require.NoError(t, err)
	require.Equal(t, uint32(1), legacyNext)
	otherNext, err := cheques.GetNextDomainIndex(ctx, db, "other-root")
	require.NoError(t, err)
	require.Zero(t, otherNext)
	_, err = cheques.CreateVersioned(ctx, db, testWalletID, 0, 1000, "other-domain-address", 1, "other-root", "other-network")
	require.NoError(t, err)
}

func TestChequeVersionRecoveryKeepsTheOwner(t *testing.T) {
	db := database.Test(t)
	ctx := t.Context()
	id, err := cheques.CreateVersioned(ctx, db, testWalletID, 0, 2000, "shared-address", 1, "root", "network")
	require.NoError(t, err)
	err = cheques.CreateOrUpdateFromRecoveryVersioned(ctx, db, "same-seed-wallet", 0, "shared-address",
		[]cheques.FundingOutput{{Txid: "receipt", ValueSats: 1000}}, 1000, 1, "root", "network")
	require.NoError(t, err)
	row, err := cheques.Get(ctx, db, testWalletID, id)
	require.NoError(t, err)
	require.Equal(t, testWalletID, row.WalletID)
	require.Equal(t, "network", row.KeyScope)
	require.Equal(t, uint64(2000), row.ExpectedAmountSats)
	require.NotNil(t, row.ActualAmountSats)
	require.Equal(t, uint64(1000), *row.ActualAmountSats)
	rows, err := cheques.List(ctx, db, "same-seed-wallet")
	require.NoError(t, err)
	require.Empty(t, rows)
}

func TestChequeVersionRecoveryKeepsTheCounter(t *testing.T) {
	db := database.Test(t)
	ctx := t.Context()
	for _, index := range []uint32{25, 2} {
		address := "high-address"
		if index == 2 {
			address = "low-address"
		}
		for range 2 {
			err := cheques.CreateOrUpdateFromRecoveryVersioned(ctx, db, testWalletID, index, address,
				[]cheques.FundingOutput{{Txid: "receipt", Vout: int32(index), ValueSats: 1000}}, 1000, 1, "root", "network")
			require.NoError(t, err)
		}
	}
	next, err := cheques.GetNextDomainIndex(ctx, db, "root")
	require.NoError(t, err)
	require.Equal(t, uint32(26), next)
	legacyNext, err := cheques.GetNextIndex(ctx, db, testWalletID)
	require.NoError(t, err)
	require.Zero(t, legacyNext)
	row, err := cheques.GetByAddress(ctx, db, testWalletID, "high-address")
	require.NoError(t, err)
	require.Equal(t, uint32(1), row.KeyVersion)
	require.Equal(t, "root", row.KeyDomain)
	require.Equal(t, "network", row.KeyScope)
	require.Equal(t, []string{"receipt"}, row.FundedTxids)
}

func TestChequeVersionRecoveryRejectsScopeChange(t *testing.T) {
	db := database.Test(t)
	ctx := t.Context()
	id, err := cheques.CreateVersioned(ctx, db, testWalletID, 0, 2000, "shared-address", 1, "root", "network")
	require.NoError(t, err)
	err = cheques.CreateOrUpdateFromRecoveryVersioned(ctx, db, "same-seed-wallet", 0, "shared-address",
		[]cheques.FundingOutput{{Txid: "receipt", ValueSats: 1000}}, 1000, 1, "root", "other-network")
	require.ErrorContains(t, err, "recovered cheque key differs")
	row, err := cheques.Get(ctx, db, testWalletID, id)
	require.NoError(t, err)
	require.Equal(t, "network", row.KeyScope)
	require.Nil(t, row.ActualAmountSats)
	require.Empty(t, row.FundedTxids)
}

func TestChequeVersionRejectsInvalidKeys(t *testing.T) {
	for _, test := range []struct {
		name    string
		version uint32
		domain  string
		scope   string
		message string
	}{
		{"legacy domain", 0, "root", "", "legacy cheque must not"},
		{"legacy scope", 0, "", "network", "legacy cheque must not"},
		{"absent domain", 1, "", "network", "must have a key domain"},
		{"absent scope", 1, "root", "", "must have a key scope"},
		{"unknown version", 2, "root", "network", "unsupported cheque key version"},
	} {
		t.Run(test.name, func(t *testing.T) {
			db := database.Test(t)
			_, err := cheques.CreateVersioned(t.Context(), db, testWalletID, 0, 1000, "address", test.version, test.domain, test.scope)
			require.ErrorContains(t, err, test.message)
			err = cheques.CreateOrUpdateFromRecoveryVersioned(t.Context(), db, testWalletID, 0, "address", nil, 1000, test.version, test.domain, test.scope)
			require.ErrorContains(t, err, test.message)
			rows, err := cheques.List(t.Context(), db, testWalletID)
			require.NoError(t, err)
			require.Empty(t, rows)
		})
	}
}

func TestChequeVersionKeepsLegacyReceipt(t *testing.T) {
	db := database.Test(t)
	id, err := cheques.Create(t.Context(), db, testWalletID, 0, 1000, "legacy-address")
	require.NoError(t, err)
	_, err = db.ExecContext(t.Context(), `UPDATE cheques SET funded_txid = 'first,second' WHERE id = ?`, id)
	require.NoError(t, err)
	row, err := cheques.Get(t.Context(), db, testWalletID, id)
	require.NoError(t, err)
	require.NotNil(t, row.LegacyFundedTxid)
	require.Equal(t, "first,second", *row.LegacyFundedTxid)
	require.Equal(t, []string{"first", "second"}, row.FundedTxids)
	require.True(t, row.IsPartiallyFunded())
	require.NoError(t, cheques.UpdateFunding(t.Context(), db, testWalletID, id,
		[]cheques.FundingOutput{{Txid: "second", ValueSats: 500}}, 500))
	row, err = cheques.Get(t.Context(), db, testWalletID, id)
	require.NoError(t, err)
	require.Equal(t, []string{"first", "second"}, row.FundedTxids)
}

func TestChequeVersionCounterErrorRollsBack(t *testing.T) {
	for _, recovery := range []bool{false, true} {
		name := "create"
		if recovery {
			name = "recovery"
		}
		t.Run(name, func(t *testing.T) {
			db := database.Test(t)
			_, err := db.ExecContext(t.Context(), `
				CREATE TRIGGER reject_domain_counter BEFORE INSERT ON cheque_domain_counters
				BEGIN SELECT RAISE(ABORT, 'test counter error'); END
			`)
			require.NoError(t, err)
			if recovery {
				err = cheques.CreateOrUpdateFromRecoveryVersioned(t.Context(), db, testWalletID, 0, "address",
					[]cheques.FundingOutput{{Txid: "receipt", ValueSats: 1000}}, 1000, 1, "root", "network")
			} else {
				_, err = cheques.CreateVersioned(t.Context(), db, testWalletID, 0, 1000, "address", 1, "root", "network")
			}
			require.ErrorContains(t, err, "test counter error")
			rows, err := cheques.List(t.Context(), db, testWalletID)
			require.NoError(t, err)
			require.Empty(t, rows)
			next, err := cheques.GetNextDomainIndex(t.Context(), db, "root")
			require.NoError(t, err)
			require.Zero(t, next)
		})
	}
}

func TestChequeBackupKeepsChequesWithoutWallet(t *testing.T) {
	ctx := t.Context()
	source := database.Test(t)
	_, err := source.ExecContext(ctx, `INSERT INTO cheques (wallet_id, derivation_index, expected_amount_sats, address) VALUES ('', 4, 1000, 'pre-025-address')`)
	require.NoError(t, err)
	_, err = source.ExecContext(ctx, `INSERT INTO cheque_index_counters (wallet_id, next_index) VALUES ('', 5)`)
	require.NoError(t, err)
	backup, err := cheques.ExportBackup(ctx, source)
	require.NoError(t, err)

	target := database.Test(t)
	tx, err := target.BeginTx(ctx, nil)
	require.NoError(t, err)
	require.NoError(t, cheques.ImportBackupTx(ctx, tx, *backup))
	require.NoError(t, tx.Commit())

	restored, err := cheques.GetByAddress(ctx, target, "", "pre-025-address")
	require.NoError(t, err)
	require.Equal(t, uint32(4), restored.DerivationIndex)
	next, err := cheques.GetNextIndex(ctx, target, "")
	require.NoError(t, err)
	require.Equal(t, uint32(5), next)
}

func TestChequeRecoveryClaimsUnownedLegacyCheque(t *testing.T) {
	ctx := t.Context()
	db := database.Test(t)
	_, err := db.ExecContext(ctx, `INSERT INTO cheques (wallet_id, derivation_index, expected_amount_sats, address) VALUES ('', 3, 1000, 'pre-025-address')`)
	require.NoError(t, err)

	outputs := []cheques.FundingOutput{{Txid: "aa", Vout: 0, ValueSats: 1000}}
	require.NoError(t, cheques.CreateOrUpdateFromRecovery(ctx, db, testWalletID, 3, "pre-025-address", outputs, 1000))

	claimed, err := cheques.GetByAddress(ctx, db, testWalletID, "pre-025-address")
	require.NoError(t, err)
	require.Equal(t, uint32(3), claimed.DerivationIndex)
	require.True(t, claimed.IsFunded())
	next, err := cheques.GetNextIndex(ctx, db, testWalletID)
	require.NoError(t, err)
	require.Equal(t, uint32(4), next)
}

func TestChequeBackupRestoresAfterClaim(t *testing.T) {
	ctx := t.Context()
	db := database.Test(t)
	_, err := db.ExecContext(ctx, `INSERT INTO cheques (wallet_id, derivation_index, expected_amount_sats, address) VALUES ('', 3, 1000, 'pre-025-address')`)
	require.NoError(t, err)
	backup, err := cheques.ExportBackup(ctx, db)
	require.NoError(t, err)
	require.NoError(t, cheques.CreateOrUpdateFromRecovery(ctx, db, testWalletID, 3, "pre-025-address", nil, 1000))

	tx, err := db.BeginTx(ctx, nil)
	require.NoError(t, err)
	require.NoError(t, cheques.ImportBackupTx(ctx, tx, *backup))
	require.NoError(t, tx.Commit())

	claimed, err := cheques.GetByAddress(ctx, db, testWalletID, "pre-025-address")
	require.NoError(t, err)
	require.Equal(t, uint32(3), claimed.DerivationIndex)
}

func TestChequeBackupClaimsUnownedChequeOnRestore(t *testing.T) {
	ctx := t.Context()
	source := database.Test(t)
	_, err := source.ExecContext(ctx, `INSERT INTO cheques (wallet_id, derivation_index, expected_amount_sats, address) VALUES ('', 3, 1000, 'pre-025-address')`)
	require.NoError(t, err)
	outputs := []cheques.FundingOutput{{Txid: "aa", Vout: 0, ValueSats: 1000}}
	require.NoError(t, cheques.CreateOrUpdateFromRecovery(ctx, source, testWalletID, 3, "pre-025-address", outputs, 1000))
	backup, err := cheques.ExportBackup(ctx, source)
	require.NoError(t, err)

	target := database.Test(t)
	_, err = target.ExecContext(ctx, `INSERT INTO cheques (wallet_id, derivation_index, expected_amount_sats, address) VALUES ('', 3, 1000, 'pre-025-address')`)
	require.NoError(t, err)
	tx, err := target.BeginTx(ctx, nil)
	require.NoError(t, err)
	require.NoError(t, cheques.ImportBackupTx(ctx, tx, *backup))
	require.NoError(t, tx.Commit())

	restored, err := cheques.GetByAddress(ctx, target, testWalletID, "pre-025-address")
	require.NoError(t, err)
	require.Equal(t, uint32(3), restored.DerivationIndex)
	require.True(t, restored.IsFunded())
}
