package engines

import (
	"archive/zip"
	"bytes"
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/multisig"
	"github.com/rs/zerolog"
)

// BackupEngine handles wallet backup and restore operations.
type BackupEngine struct {
	db            *sql.DB
	walletDir     string // dir containing wallet.json
	multisigStore *multisig.Store
}

// NewBackupEngine creates a new BackupEngine.
func NewBackupEngine(db *sql.DB, walletDir string) *BackupEngine {
	return &BackupEngine{
		db:            db,
		walletDir:     walletDir,
		multisigStore: multisig.NewStore(db),
	}
}

// BackupContents describes what a backup file contains.
type BackupContents struct {
	HasWallet       bool
	HasMultisig     bool
	HasTransactions bool
}

// CreateBackup produces a ZIP archive containing wallet.json plus
// multisig and transaction data exported from the DB.
func (e *BackupEngine) CreateBackup(ctx context.Context) ([]byte, string, error) {
	log := zerolog.Ctx(ctx)
	var buf bytes.Buffer
	zw := zip.NewWriter(&buf)

	// README
	readme := `BitWindow Wallet Backup
=======================

CONTENTS
--------
1. wallet.json - Master wallet data (seed, derived keys, sidechain seeds)
2. multisig/multisig.json - Multisig group configurations (exported from DB)
3. transactions.json - Transaction history (exported from DB)

All sidechain wallets are DERIVED from the master seed in wallet.json.
Restoring this backup restores ALL your sidechain wallets automatically.

HOW TO RESTORE
--------------
1. Open BitWindow
2. Settings > Your Wallet > Restore Wallet
3. Select this file

SECURITY
--------
Keep this file secure. Anyone with access can control ALL your funds.
`
	if err := addToZip(zw, "README.txt", []byte(readme)); err != nil {
		return nil, "", fmt.Errorf("write readme: %w", err)
	}

	// wallet.json
	walletPath := filepath.Join(e.walletDir, "wallet.json")
	if data, err := os.ReadFile(walletPath); err == nil {
		if err := addToZip(zw, "wallet.json", data); err != nil {
			return nil, "", fmt.Errorf("write wallet.json: %w", err)
		}
		log.Info().Msg("backup: added wallet.json")
	} else {
		log.Warn().Err(err).Msg("backup: wallet.json not found")
	}

	// multisig data from DB
	multisigJSON, err := e.exportMultisigJSON(ctx)
	if err != nil {
		log.Warn().Err(err).Msg("backup: failed to export multisig data")
	} else if multisigJSON != nil {
		if err := addToZip(zw, "multisig/multisig.json", multisigJSON); err != nil {
			return nil, "", fmt.Errorf("write multisig.json: %w", err)
		}
		log.Info().Msg("backup: added multisig.json")
	}

	// transaction data from DB
	txJSON, err := e.exportTransactionsJSON(ctx)
	if err != nil {
		log.Warn().Err(err).Msg("backup: failed to export transactions")
	} else if txJSON != nil {
		if err := addToZip(zw, "transactions.json", txJSON); err != nil {
			return nil, "", fmt.Errorf("write transactions.json: %w", err)
		}
		log.Info().Msg("backup: added transactions.json")
	}

	if err := zw.Close(); err != nil {
		return nil, "", fmt.Errorf("close zip: %w", err)
	}

	filename := fmt.Sprintf("bitwindow-backup-%s.zip", time.Now().Format("2006-01-02_15-04-05"))
	log.Info().Str("filename", filename).Int("size", buf.Len()).Msg("backup created")
	return buf.Bytes(), filename, nil
}

// ValidateBackup validates a backup file (ZIP or JSON) and reports contents.
func (e *BackupEngine) ValidateBackup(_ context.Context, data []byte, filename string) (*BackupContents, error) {
	ext := strings.ToLower(filepath.Ext(filename))

	switch ext {
	case ".json":
		return e.validateJSON(data)
	case ".zip":
		return e.validateZIP(data)
	default:
		return nil, fmt.Errorf("unsupported file type %q, expected .zip or .json", ext)
	}
}

// RestoreBackup restores wallet data from a backup file.
// The caller is responsible for stopping/restarting services.
func (e *BackupEngine) RestoreBackup(ctx context.Context, data []byte, filename string) error {
	log := zerolog.Ctx(ctx)
	ext := strings.ToLower(filepath.Ext(filename))

	var walletJSON, multisigJSON, txJSON []byte
	var err error

	switch ext {
	case ".json":
		walletJSON = data
		// Validate it's valid wallet JSON
		if err := validateWalletJSON(data); err != nil {
			return fmt.Errorf("invalid wallet.json: %w", err)
		}
	case ".zip":
		walletJSON, multisigJSON, txJSON, err = extractZIP(data)
		if err != nil {
			return fmt.Errorf("extract zip: %w", err)
		}
	default:
		return fmt.Errorf("unsupported file type %q", ext)
	}

	if walletJSON == nil {
		return fmt.Errorf("backup does not contain wallet.json")
	}

	// Restore wallet.json
	walletPath := filepath.Join(e.walletDir, "wallet.json")
	if err := os.WriteFile(walletPath, walletJSON, 0600); err != nil {
		return fmt.Errorf("write wallet.json: %w", err)
	}
	log.Info().Msg("restore: wrote wallet.json")

	// Import multisig data into DB
	if multisigJSON != nil {
		if err := e.multisigStore.ImportFromJSON(ctx, multisigJSON); err != nil {
			log.Warn().Err(err).Msg("restore: failed to import multisig data")
		} else {
			log.Info().Msg("restore: imported multisig data")
		}
	}

	// Import transaction data into DB
	if txJSON != nil {
		if err := e.multisigStore.ImportTransactionsFromJSON(ctx, txJSON); err != nil {
			log.Warn().Err(err).Msg("restore: failed to import transactions")
		} else {
			log.Info().Msg("restore: imported transactions")
		}
	}

	return nil
}

// HasCurrentWallet returns true if wallet.json exists.
func (e *BackupEngine) HasCurrentWallet() bool {
	_, err := os.Stat(filepath.Join(e.walletDir, "wallet.json"))
	return err == nil
}

// --- internal helpers ---

func addToZip(zw *zip.Writer, name string, data []byte) error {
	w, err := zw.Create(name)
	if err != nil {
		return err
	}
	_, err = w.Write(data)
	return err
}

func (e *BackupEngine) exportMultisigJSON(ctx context.Context) ([]byte, error) {
	groups, err := e.multisigStore.ListGroups(ctx)
	if err != nil {
		return nil, err
	}
	if len(groups) == 0 {
		soloKeys, err := e.multisigStore.ListSoloKeys(ctx)
		if err != nil || len(soloKeys) == 0 {
			return nil, nil // nothing to export
		}
	}

	// Build the legacy JSON format for compatibility
	type exportData struct {
		Groups   []map[string]interface{} `json:"groups"`
		SoloKeys []map[string]interface{} `json:"solo_keys"`
	}

	var export exportData

	for _, g := range groups {
		keys, _ := e.multisigStore.ListKeysForGroup(ctx, g.ID)
		addrs, _ := e.multisigStore.ListAddresses(ctx, g.ID)
		txIDs, _ := e.multisigStore.ListGroupTransactionIDs(ctx, g.ID)

		gm := map[string]interface{}{
			"id":                g.ID,
			"name":              g.Name,
			"n":                 g.N,
			"m":                 g.M,
			"created":           g.Created,
			"txid":              g.Txid,
			"descriptor":        g.Descriptor,
			"descriptorReceive": g.DescriptorReceive,
			"descriptorChange":  g.DescriptorChange,
			"watchWalletName":   g.WatchWalletName,
			"balance":           g.Balance,
			"utxos":             g.Utxos,
			"nextReceiveIndex":  g.NextReceiveIndex,
			"nextChangeIndex":   g.NextChangeIndex,
			"transactionIds":    txIDs,
		}

		var keyList []map[string]interface{}
		for _, k := range keys {
			keyList = append(keyList, map[string]interface{}{
				"owner":          k.Owner,
				"xpub":           k.Xpub,
				"derivationPath": k.DerivationPath,
				"fingerprint":    k.Fingerprint,
				"originPath":     k.OriginPath,
				"isWallet":       k.IsWallet,
				"sortOrder":      k.SortOrder,
			})
		}
		gm["keys"] = keyList

		var addrList []map[string]interface{}
		for _, a := range addrs {
			addrList = append(addrList, map[string]interface{}{
				"type":  a.AddrType,
				"index": a.Index,
				"addr":  a.Addr,
				"used":  a.Used,
			})
		}
		gm["addresses"] = addrList

		export.Groups = append(export.Groups, gm)
	}

	soloKeys, _ := e.multisigStore.ListSoloKeys(ctx)
	for _, sk := range soloKeys {
		export.SoloKeys = append(export.SoloKeys, map[string]interface{}{
			"xpub":           sk.Xpub,
			"derivationPath": sk.DerivationPath,
			"fingerprint":    sk.Fingerprint,
			"originPath":     sk.OriginPath,
			"owner":          sk.Owner,
		})
	}

	return json.MarshalIndent(export, "", "  ")
}

func (e *BackupEngine) exportTransactionsJSON(ctx context.Context) ([]byte, error) {
	groups, err := e.multisigStore.ListGroups(ctx)
	if err != nil {
		return nil, err
	}

	var allTxns []map[string]interface{}

	for _, g := range groups {
		txns, err := e.multisigStore.ListTransactions(ctx, g.ID)
		if err != nil {
			continue
		}
		for _, tx := range txns {
			keyPSBTs, _ := e.multisigStore.ListTxKeyPSBTs(ctx, tx.ID)
			inputs, _ := e.multisigStore.ListTxInputs(ctx, tx.ID)

			tm := map[string]interface{}{
				"id":                 tx.ID,
				"groupId":            tx.GroupID,
				"initialPsbt":        tx.InitialPSBT,
				"combinedPsbt":       tx.CombinedPSBT,
				"finalHex":           tx.FinalHex,
				"txid":               tx.Txid,
				"status":             tx.Status,
				"type":               tx.Type,
				"created":            tx.Created,
				"amount":             tx.Amount,
				"destination":        tx.Destination,
				"fee":                tx.Fee,
				"confirmations":      tx.Confirmations,
				"requiredSignatures": tx.RequiredSignatures,
			}
			if tx.BroadcastTime != nil {
				tm["broadcastTime"] = *tx.BroadcastTime
			}

			var kpList []map[string]interface{}
			for _, kp := range keyPSBTs {
				kpm := map[string]interface{}{
					"keyId":  kp.KeyID,
					"psbt":   kp.PSBT,
					"signed": kp.IsSigned,
				}
				if kp.SignedAt != nil {
					kpm["signedAt"] = *kp.SignedAt
				}
				kpList = append(kpList, kpm)
			}
			tm["keyPsbts"] = kpList

			var inList []map[string]interface{}
			for _, in := range inputs {
				inList = append(inList, map[string]interface{}{
					"txid":          in.Txid,
					"vout":          in.Vout,
					"address":       in.Address,
					"amount":        in.Amount,
					"confirmations": in.Confirmations,
				})
			}
			tm["inputs"] = inList

			allTxns = append(allTxns, tm)
		}
	}

	if len(allTxns) == 0 {
		return nil, nil
	}

	return json.MarshalIndent(allTxns, "", "  ")
}

func validateWalletJSON(data []byte) error {
	var wallet map[string]interface{}
	if err := json.Unmarshal(data, &wallet); err != nil {
		return fmt.Errorf("invalid JSON: %w", err)
	}

	// Check old format (master/l1 at root) or new format (wallets array)
	_, hasOldMaster := wallet["master"]
	_, hasOldL1 := wallet["l1"]
	isOldFormat := hasOldMaster && hasOldL1

	wallets, hasWallets := wallet["wallets"]
	isNewFormat := hasWallets

	if !isOldFormat && !isNewFormat {
		return fmt.Errorf("missing master/l1 or wallets array")
	}

	if isNewFormat {
		walletsList, ok := wallets.([]interface{})
		if !ok || len(walletsList) == 0 {
			return fmt.Errorf("wallets array is empty")
		}
		first, ok := walletsList[0].(map[string]interface{})
		if !ok {
			return fmt.Errorf("invalid wallet entry")
		}
		if _, ok := first["master"]; !ok {
			return fmt.Errorf("wallet entry missing master")
		}
		if _, ok := first["l1"]; !ok {
			return fmt.Errorf("wallet entry missing l1")
		}
	}

	return nil
}

func (e *BackupEngine) validateJSON(data []byte) (*BackupContents, error) {
	if err := validateWalletJSON(data); err != nil {
		return nil, fmt.Errorf("invalid wallet.json: %w", err)
	}
	return &BackupContents{HasWallet: true}, nil
}

func (e *BackupEngine) validateZIP(data []byte) (*BackupContents, error) {
	r, err := zip.NewReader(bytes.NewReader(data), int64(len(data)))
	if err != nil {
		return nil, fmt.Errorf("invalid zip: %w", err)
	}

	contents := &BackupContents{}
	for _, f := range r.File {
		switch f.Name {
		case "wallet.json":
			rc, err := f.Open()
			if err != nil {
				return nil, fmt.Errorf("open wallet.json in zip: %w", err)
			}
			walletData, err := io.ReadAll(rc)
			rc.Close()
			if err != nil {
				return nil, fmt.Errorf("read wallet.json in zip: %w", err)
			}
			if err := validateWalletJSON(walletData); err != nil {
				return nil, fmt.Errorf("wallet.json invalid: %w", err)
			}
			contents.HasWallet = true
		case "multisig/multisig.json", "multisig\\multisig.json":
			rc, err := f.Open()
			if err != nil {
				continue
			}
			msData, err := io.ReadAll(rc)
			rc.Close()
			if err != nil {
				continue
			}
			var tmp interface{}
			if json.Unmarshal(msData, &tmp) == nil {
				contents.HasMultisig = true
			}
		case "transactions.json":
			rc, err := f.Open()
			if err != nil {
				continue
			}
			txData, err := io.ReadAll(rc)
			rc.Close()
			if err != nil {
				continue
			}
			var tmp interface{}
			if json.Unmarshal(txData, &tmp) == nil {
				contents.HasTransactions = true
			}
		}
	}

	if !contents.HasWallet {
		return nil, fmt.Errorf("backup is missing wallet.json")
	}

	return contents, nil
}

func extractZIP(data []byte) (walletJSON, multisigJSON, txJSON []byte, err error) {
	r, err := zip.NewReader(bytes.NewReader(data), int64(len(data)))
	if err != nil {
		return nil, nil, nil, fmt.Errorf("invalid zip: %w", err)
	}

	for _, f := range r.File {
		rc, err := f.Open()
		if err != nil {
			continue
		}
		content, err := io.ReadAll(rc)
		rc.Close()
		if err != nil {
			continue
		}

		switch f.Name {
		case "wallet.json":
			walletJSON = content
		case "multisig/multisig.json", "multisig\\multisig.json":
			multisigJSON = content
		case "transactions.json":
			txJSON = content
		}
	}

	return
}
