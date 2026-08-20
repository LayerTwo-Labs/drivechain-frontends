package wallet

import (
	"context"
	"database/sql"
	"encoding/json"
	"time"
)

// electrumScanTables are the per-wallet chain-state tables, cleared together
// when a wallet's scan is rewritten or removed.
var electrumScanTables = []string{
	"electrum_addresses",
	"electrum_utxos",
	"electrum_txs",
	"electrum_tx_addresses",
	"electrum_sync",
}

// persistedAddr is one scanned chain address and the data fetched for it:
// stats plus the UTXOs and transactions that back balance/history reads.
type persistedAddr struct {
	Kind    ScriptKind
	Change  bool
	Index   uint32
	Address string
	Status  string
	Stats   EsploraAddressStats
	UTXOs   []EsploraUTXO
	Txs     []EsploraTx
}

// persistedScan is a wallet's scan on one network as stored in electrum.db, so
// a cold boot rebuilds it without re-querying the chain.
type persistedScan struct {
	WalletID string
	Addrs    []persistedAddr
}

// loadElectrumScan reads a wallet's persisted scan for a network; ok is false
// when it has no stored addresses there.
func (s *Service) loadElectrumScan(network, walletID string) (*persistedScan, bool) {
	db := s.db()
	if db == nil {
		return nil, false
	}
	ctx := context.Background()

	// Sequential: the db is MaxOpenConns(1), so a query must not run while
	// another statement's rows are still open.
	byAddr, order, ok := s.loadElectrumAddrs(ctx, network, walletID)
	if !ok || len(order) == 0 {
		return nil, false
	}
	if !s.loadElectrumUTXOs(ctx, network, walletID, byAddr) {
		return nil, false
	}
	if !s.loadElectrumTxs(ctx, network, walletID, byAddr) {
		return nil, false
	}

	ps := &persistedScan{WalletID: walletID}
	for _, addr := range order {
		ps.Addrs = append(ps.Addrs, *byAddr[addr])
	}
	return ps, true
}

func (s *Service) loadElectrumAddrs(ctx context.Context, network, walletID string) (map[string]*persistedAddr, []string, bool) {
	db := s.db()
	if db == nil {
		return nil, nil, false
	}
	rows, err := db.QueryContext(ctx, `
		SELECT address, kind, change, idx, status,
		       chain_funded_count, chain_funded_sum, chain_spent_count, chain_spent_sum, chain_tx_count,
		       mempool_funded_count, mempool_funded_sum, mempool_spent_count, mempool_spent_sum, mempool_tx_count
		FROM electrum_addresses WHERE network = ? AND wallet_id = ? ORDER BY kind, change, idx`, network, walletID)
	if err != nil {
		s.log.Warn().Err(err).Msg("load electrum addresses failed")
		return nil, nil, false
	}
	defer rows.Close() //nolint:errcheck

	byAddr := map[string]*persistedAddr{}
	var order []string
	for rows.Next() {
		var a persistedAddr
		var kind string
		cs, ms := &a.Stats.ChainStats, &a.Stats.MempoolStats
		if err := rows.Scan(&a.Address, &kind, &a.Change, &a.Index, &a.Status,
			&cs.FundedTxoCount, &cs.FundedTxoSum, &cs.SpentTxoCount, &cs.SpentTxoSum, &cs.TxCount,
			&ms.FundedTxoCount, &ms.FundedTxoSum, &ms.SpentTxoCount, &ms.SpentTxoSum, &ms.TxCount); err != nil {
			s.log.Warn().Err(err).Msg("scan electrum address failed")
			return nil, nil, false
		}
		a.Kind = parseScriptKind(kind)
		a.Stats.Address = a.Address
		byAddr[a.Address] = &a
		order = append(order, a.Address)
	}
	return byAddr, order, rows.Err() == nil
}

func (s *Service) loadElectrumUTXOs(ctx context.Context, network, walletID string, byAddr map[string]*persistedAddr) bool {
	db := s.db()
	if db == nil {
		return false
	}
	rows, err := db.QueryContext(ctx, `
		SELECT address, txid, vout, value, confirmed, block_height, block_hash, block_time
		FROM electrum_utxos WHERE network = ? AND wallet_id = ?`, network, walletID)
	if err != nil {
		s.log.Warn().Err(err).Msg("load electrum utxos failed")
		return false
	}
	defer rows.Close() //nolint:errcheck

	for rows.Next() {
		var addr string
		var u EsploraUTXO
		var confirmed int
		if err := rows.Scan(&addr, &u.TxID, &u.Vout, &u.Value,
			&confirmed, &u.Status.BlockHeight, &u.Status.BlockHash, &u.Status.BlockTime); err != nil {
			s.log.Warn().Err(err).Msg("scan electrum utxo failed")
			return false
		}
		u.Status.Confirmed = confirmed != 0
		if a, ok := byAddr[addr]; ok {
			a.UTXOs = append(a.UTXOs, u)
		}
	}
	return rows.Err() == nil
}

// loadElectrumTxs joins the deduplicated transaction bodies back onto the
// addresses that reference them.
func (s *Service) loadElectrumTxs(ctx context.Context, network, walletID string, byAddr map[string]*persistedAddr) bool {
	db := s.db()
	if db == nil {
		return false
	}
	rows, err := db.QueryContext(ctx, `
		SELECT l.address, t.raw
		FROM electrum_tx_addresses l
		JOIN electrum_txs t
		  ON t.network = l.network AND t.wallet_id = l.wallet_id AND t.txid = l.txid
		WHERE l.network = ? AND l.wallet_id = ?`, network, walletID)
	if err != nil {
		s.log.Warn().Err(err).Msg("load electrum txs failed")
		return false
	}
	defer rows.Close() //nolint:errcheck

	for rows.Next() {
		var addr, raw string
		if err := rows.Scan(&addr, &raw); err != nil {
			s.log.Warn().Err(err).Msg("scan electrum tx failed")
			return false
		}
		var tx EsploraTx
		if err := json.Unmarshal([]byte(raw), &tx); err != nil {
			s.log.Warn().Err(err).Msg("decode electrum tx failed")
			return false
		}
		if a, ok := byAddr[addr]; ok {
			a.Txs = append(a.Txs, tx)
		}
	}
	return rows.Err() == nil
}

// loadSyncCheckpoint returns the chain tip a wallet's stored scan reflects, so
// a cold read resumes from there instead of re-walking every address.
func (s *Service) loadSyncCheckpoint(network, walletID string) (int, bool) {
	db := s.db()
	if db == nil {
		return 0, false
	}
	var tip int
	if err := db.QueryRowContext(context.Background(),
		`SELECT tip_height FROM electrum_sync WHERE network = ? AND wallet_id = ?`,
		network, walletID).Scan(&tip); err != nil {
		return 0, false
	}
	// A scan taken while the tip was unknown stored 0, which is not a height.
	return tip, tip > 0
}

// saveSyncCheckpoint records the tip a wallet's stored scan reflects, without
// rewriting the scan itself.
func (s *Service) saveSyncCheckpoint(network, walletID string, tip int) error {
	db := s.db()
	if db == nil || tip <= 0 {
		return nil
	}
	_, err := db.ExecContext(context.Background(),
		`INSERT INTO electrum_sync (network, wallet_id, tip_height, synced_at) VALUES (?,?,?,?)
		 ON CONFLICT (network, wallet_id) DO UPDATE SET
		  tip_height = excluded.tip_height, synced_at = excluded.synced_at`,
		network, walletID, tip, time.Now().Unix())
	return err
}

// firstUnusedAddress returns the lowest-index address on a kind's chain with no
// history. ok is false when none is stored; the caller then derives the index.
func (s *Service) firstUnusedAddress(network, walletID string, kind ScriptKind, change bool) (string, uint32, bool) {
	db := s.db()
	if db == nil {
		return "", 0, false
	}
	var addr string
	var idx uint32
	err := db.QueryRowContext(context.Background(),
		`SELECT address, idx FROM electrum_addresses
		 WHERE network = ? AND wallet_id = ? AND kind = ? AND change = ? AND chain_tx_count = 0 AND mempool_tx_count = 0
		 ORDER BY idx LIMIT 1`, network, walletID, kind.String(), change).Scan(&addr, &idx)
	if err != nil {
		return "", 0, false
	}
	return addr, idx, true
}

// maxAddressIndex returns the highest stored address index on a kind's chain, or
// -1 when none are stored. Used to derive the next address past what is known.
func (s *Service) maxAddressIndex(network, walletID string, kind ScriptKind, change bool) int {
	db := s.db()
	if db == nil {
		return -1
	}
	var max sql.NullInt64
	if err := db.QueryRowContext(context.Background(),
		`SELECT MAX(idx) FROM electrum_addresses WHERE network = ? AND wallet_id = ? AND kind = ? AND change = ?`,
		network, walletID, kind.String(), change).Scan(&max); err != nil || !max.Valid {
		return -1
	}
	return int(max.Int64)
}

// saveElectrumScan replaces a wallet's stored scan for one network in a single
// transaction. tip is the chain height the scan reflects.
func (s *Service) saveElectrumScan(network, walletID string, ps *persistedScan, tip int) error {
	db := s.db()
	if db == nil {
		return nil
	}
	ctx := context.Background()
	tx, err := db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback() //nolint:errcheck // rolled back unless Commit succeeds

	for _, table := range electrumScanTables {
		if _, err := tx.ExecContext(ctx,
			"DELETE FROM "+table+" WHERE network = ? AND wallet_id = ?", network, walletID); err != nil {
			return err
		}
	}
	if err := insertScanRows(ctx, tx, network, walletID, ps); err != nil {
		return err
	}
	if _, err := tx.ExecContext(ctx,
		`INSERT INTO electrum_sync (network, wallet_id, tip_height, synced_at) VALUES (?,?,?,?)`,
		network, walletID, tip, time.Now().Unix()); err != nil {
		return err
	}
	return tx.Commit()
}

func insertScanRows(ctx context.Context, tx *sql.Tx, network, walletID string, ps *persistedScan) error {
	for _, a := range ps.Addrs {
		cs, ms := a.Stats.ChainStats, a.Stats.MempoolStats
		if _, err := tx.ExecContext(ctx, `INSERT INTO electrum_addresses
			(network, wallet_id, kind, change, idx, address, status,
			 chain_funded_count, chain_funded_sum, chain_spent_count, chain_spent_sum, chain_tx_count,
			 mempool_funded_count, mempool_funded_sum, mempool_spent_count, mempool_spent_sum, mempool_tx_count)
			VALUES (?,?,?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?)`,
			network, walletID, a.Kind.String(), a.Change, a.Index, a.Address, a.Status,
			cs.FundedTxoCount, cs.FundedTxoSum, cs.SpentTxoCount, cs.SpentTxoSum, cs.TxCount,
			ms.FundedTxoCount, ms.FundedTxoSum, ms.SpentTxoCount, ms.SpentTxoSum, ms.TxCount); err != nil {
			return err
		}
		for _, u := range a.UTXOs {
			if _, err := tx.ExecContext(ctx, `INSERT INTO electrum_utxos
				(network, wallet_id, address, txid, vout, value, confirmed, block_height, block_hash, block_time)
				VALUES (?,?,?,?,?,?,?,?,?,?)`,
				network, walletID, a.Address, u.TxID, u.Vout, u.Value, boolToInt(u.Status.Confirmed),
				u.Status.BlockHeight, u.Status.BlockHash, u.Status.BlockTime); err != nil {
				return err
			}
		}
		for _, t := range a.Txs {
			raw, err := json.Marshal(t)
			if err != nil {
				return err
			}
			if _, err := tx.ExecContext(ctx, `INSERT INTO electrum_txs (network, wallet_id, txid, raw)
				VALUES (?,?,?,?) ON CONFLICT (network, wallet_id, txid) DO UPDATE SET raw = excluded.raw`,
				network, walletID, t.TxID, string(raw)); err != nil {
				return err
			}
			if _, err := tx.ExecContext(ctx,
				`INSERT INTO electrum_tx_addresses (network, wallet_id, address, txid) VALUES (?,?,?,?)`,
				network, walletID, a.Address, t.TxID); err != nil {
				return err
			}
		}
	}
	return nil
}

// deleteElectrumScan removes a wallet's stored scan on every network, because
// deleting a wallet deletes it everywhere.
func (s *Service) deleteElectrumScan(walletID string) {
	db := s.db()
	if db == nil {
		return
	}
	ctx := context.Background()
	for _, table := range electrumScanTables {
		if _, err := db.ExecContext(ctx, "DELETE FROM "+table+" WHERE wallet_id = ?", walletID); err != nil {
			s.log.Warn().Err(err).Str("table", table).Msg("delete electrum scan failed")
		}
	}
}

// ClearNetworkScans drops every wallet's stored scan on one network. The eCash
// networks share a network key, so a move between two of them keeps the same
// key while the chain underneath changes — and a cold read would serve the
// retired fork's balances, transactions and UTXOs without a chain call.
func (s *Service) ClearNetworkScans(network string) {
	db := s.db()
	if db == nil || network == "" {
		return
	}
	ctx := context.Background()
	for _, table := range electrumScanTables {
		if _, err := db.ExecContext(ctx, "DELETE FROM "+table+" WHERE network = ?", network); err != nil {
			s.log.Warn().Err(err).Str("table", table).Str("network", network).
				Msg("clear network electrum scans failed")
		}
	}
}

// wipeElectrumScans clears every wallet's stored scan, used on a full reset.
func (s *Service) wipeElectrumScans() {
	db := s.db()
	if db == nil {
		return
	}
	ctx := context.Background()
	for _, table := range electrumScanTables {
		if _, err := db.ExecContext(ctx, "DELETE FROM "+table); err != nil {
			s.log.Warn().Err(err).Str("table", table).Msg("wipe electrum scans failed")
		}
	}
}

func boolToInt(b bool) int {
	if b {
		return 1
	}
	return 0
}
