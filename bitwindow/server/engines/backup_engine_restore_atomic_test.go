package engines

import (
	"archive/zip"
	"bytes"
	"encoding/json"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/multisig"
)

// TestRestoreBackup_MalformedTransactionsRollsBack verifies that when a ZIP
// backup carries valid multisig group data but a malformed transactions.json,
// RestoreBackup returns an error (rather than swallowing it) and leaves no
// partial DB state — in particular no committed group→transaction links that
// reference transactions which never got imported (orphan link rows).
func TestRestoreBackup_MalformedTransactionsRollsBack(t *testing.T) {
	db := database.Test(t)
	e := &BackupEngine{
		db:            db,
		walletDir:     t.TempDir(),
		multisigStore: multisig.NewStore(db),
	}

	walletData, _ := json.Marshal(map[string]interface{}{"master": "seed", "l1": "key"})

	msData, _ := json.Marshal(map[string]interface{}{
		"groups": []interface{}{
			map[string]interface{}{
				"id":   "grp-1",
				"name": "g1",
				"n":    1,
				"m":    1,
				"keys": []interface{}{
					map[string]interface{}{"owner": "me", "xpub": "xpub-1", "path": "m/0"},
				},
				"addresses": map[string]interface{}{
					"receive": []interface{}{
						map[string]interface{}{"index": 0, "address": "addr-1", "used": false},
					},
				},
				"transaction_ids": []interface{}{"orphan-tx"},
			},
		},
	})

	var buf bytes.Buffer
	zw := zip.NewWriter(&buf)
	w, _ := zw.Create("wallet.json")
	_, _ = w.Write(walletData)
	w, _ = zw.Create("multisig/multisig.json")
	_, _ = w.Write(msData)
	w, _ = zw.Create("transactions.json")
	_, _ = w.Write([]byte("[{ this is not valid json"))
	_ = zw.Close()

	err := e.RestoreBackup(testCtx(), buf.Bytes(), "backup.zip")
	if err == nil {
		t.Fatal("expected error from malformed transactions.json, got nil")
	}

	// The failed transaction import must roll the whole restore back: no groups
	// and no group→transaction links should have been committed.
	var groups, links int
	if err := db.QueryRow(`SELECT COUNT(*) FROM multisig_groups`).Scan(&groups); err != nil {
		t.Fatalf("count groups: %v", err)
	}
	if groups != 0 {
		t.Fatalf("expected 0 groups after rolled-back restore, got %d", groups)
	}
	if err := db.QueryRow(`SELECT COUNT(*) FROM multisig_group_transactions`).Scan(&links); err != nil {
		t.Fatalf("count links: %v", err)
	}
	if links != 0 {
		t.Fatalf("expected 0 group->tx links after rolled-back restore, got %d", links)
	}
}

// TestRestoreBackup_ValidBackupImportsAtomically is the control: a well-formed
// backup restores successfully with the group and its transaction both present
// and the link resolving to a real transaction.
func TestRestoreBackup_ValidBackupImportsAtomically(t *testing.T) {
	db := database.Test(t)
	e := &BackupEngine{
		db:            db,
		walletDir:     t.TempDir(),
		multisigStore: multisig.NewStore(db),
	}

	walletData, _ := json.Marshal(map[string]interface{}{"master": "seed", "l1": "key"})

	msData, _ := json.Marshal(map[string]interface{}{
		"groups": []interface{}{
			map[string]interface{}{
				"id":              "grp-1",
				"name":            "g1",
				"n":               1,
				"m":               1,
				"transaction_ids": []interface{}{"tx-1"},
			},
		},
	})

	txData, _ := json.Marshal([]interface{}{
		map[string]interface{}{"id": "tx-1", "groupId": "grp-1", "status": "confirmed", "type": "deposit"},
	})

	var buf bytes.Buffer
	zw := zip.NewWriter(&buf)
	w, _ := zw.Create("wallet.json")
	_, _ = w.Write(walletData)
	w, _ = zw.Create("multisig/multisig.json")
	_, _ = w.Write(msData)
	w, _ = zw.Create("transactions.json")
	_, _ = w.Write(txData)
	_ = zw.Close()

	if err := e.RestoreBackup(testCtx(), buf.Bytes(), "backup.zip"); err != nil {
		t.Fatalf("expected no error, got %v", err)
	}

	var orphans int
	if err := db.QueryRow(`
		SELECT COUNT(*) FROM multisig_group_transactions gt
		WHERE gt.transaction_id NOT IN (SELECT id FROM multisig_transactions)`).Scan(&orphans); err != nil {
		t.Fatalf("count orphan links: %v", err)
	}
	if orphans != 0 {
		t.Fatalf("expected 0 orphan links after valid restore, got %d", orphans)
	}
}
