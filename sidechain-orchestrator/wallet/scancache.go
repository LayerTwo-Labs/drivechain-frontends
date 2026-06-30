package wallet

import (
	"context"
	"database/sql"
	"encoding/json"
)

// electrumScanTables are the per-wallet chain-state tables, cleared together
// when a wallet's scan is rewritten or removed.
var electrumScanTables = []string{"electrum_addresses", "electrum_utxos", "electrum_txs"}

// persistedAddr is one scanned chain address and the Esplora data fetched for
// it: stats plus the UTXOs and transactions that back balance/history reads.
// Keys and scripts are re-derived from the seed on load, so only fetched data
// is persisted.
type persistedAddr struct {
	Kind    ScriptKind
	Change  bool
	Index   uint32
	Address string
	Stats   EsploraAddressStats
	UTXOs   []EsploraUTXO
	Txs     []EsploraTx
}

// persistedScan is a wallet's scan as stored in electrum.db, so a cold boot
// rebuilds it without re-querying Esplora.
type persistedScan struct {
	WalletID string
	Addrs    []persistedAddr
}

// loadElectrumScan reads a wallet's persisted scan from electrum.db; ok is false
// when the wallet has no stored addresses (or the db is unavailable). Reads run
// sequentially — the db is MaxOpenConns(1), so a query must not be issued while
// another's rows are still open.
func (s *Service) loadElectrumScan(walletID string) (*persistedScan, bool) {
	if s.electrumDB == nil {
		return nil, false
	}
	ctx := context.Background()

	byAddr, order, ok := s.loadElectrumAddrs(ctx, walletID)
	if !ok || len(order) == 0 {
		return nil, false
	}
	if !s.loadElectrumUTXOs(ctx, walletID, byAddr) {
		return nil, false
	}
	if !s.loadElectrumTxs(ctx, walletID, byAddr) {
		return nil, false
	}

	ps := &persistedScan{WalletID: walletID}
	for _, addr := range order {
		ps.Addrs = append(ps.Addrs, *byAddr[addr])
	}
	return ps, true
}

func (s *Service) loadElectrumAddrs(ctx context.Context, walletID string) (map[string]*persistedAddr, []string, bool) {
	rows, err := s.electrumDB.QueryContext(ctx, `
		SELECT address, kind, change, idx,
		       chain_funded_count, chain_funded_sum, chain_spent_count, chain_spent_sum, chain_tx_count,
		       mempool_funded_count, mempool_funded_sum, mempool_spent_count, mempool_spent_sum, mempool_tx_count
		FROM electrum_addresses WHERE wallet_id = ? ORDER BY kind, change, idx`, walletID)
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
		if err := rows.Scan(&a.Address, &kind, &a.Change, &a.Index,
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

func (s *Service) loadElectrumUTXOs(ctx context.Context, walletID string, byAddr map[string]*persistedAddr) bool {
	rows, err := s.electrumDB.QueryContext(ctx, `
		SELECT address, txid, vout, value, confirmed, block_height, block_hash, block_time
		FROM electrum_utxos WHERE wallet_id = ?`, walletID)
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

func (s *Service) loadElectrumTxs(ctx context.Context, walletID string, byAddr map[string]*persistedAddr) bool {
	rows, err := s.electrumDB.QueryContext(ctx, `
		SELECT address, raw FROM electrum_txs WHERE wallet_id = ?`, walletID)
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

// firstUnusedAddress returns the lowest-index address on a kind's chain with no
// on-chain or mempool history — the next address to hand out for receiving.
// ok is false when the wallet has no stored addresses for that chain yet, or
// every one is used; the caller then derives the next index locally.
func (s *Service) firstUnusedAddress(walletID string, kind ScriptKind, change bool) (string, bool) {
	if s.electrumDB == nil {
		return "", false
	}
	var addr string
	err := s.electrumDB.QueryRowContext(context.Background(),
		`SELECT address FROM electrum_addresses
		 WHERE wallet_id = ? AND kind = ? AND change = ? AND chain_tx_count = 0 AND mempool_tx_count = 0
		 ORDER BY idx LIMIT 1`, walletID, kind.String(), change).Scan(&addr)
	if err != nil {
		return "", false
	}
	return addr, true
}

// maxAddressIndex returns the highest stored address index on a kind's chain, or
// -1 when none are stored. Used to derive the next address past what is known.
func (s *Service) maxAddressIndex(walletID string, kind ScriptKind, change bool) int {
	if s.electrumDB == nil {
		return -1
	}
	var max sql.NullInt64
	if err := s.electrumDB.QueryRowContext(context.Background(),
		`SELECT MAX(idx) FROM electrum_addresses WHERE wallet_id = ? AND kind = ? AND change = ?`,
		walletID, kind.String(), change).Scan(&max); err != nil || !max.Valid {
		return -1
	}
	return int(max.Int64)
}

// saveElectrumScan replaces a wallet's stored scan with ps in a single
// transaction.
func (s *Service) saveElectrumScan(walletID string, ps *persistedScan) error {
	if s.electrumDB == nil {
		return nil
	}
	ctx := context.Background()
	tx, err := s.electrumDB.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback() //nolint:errcheck // rolled back unless Commit succeeds

	for _, table := range electrumScanTables {
		if _, err := tx.ExecContext(ctx, "DELETE FROM "+table+" WHERE wallet_id = ?", walletID); err != nil {
			return err
		}
	}
	for _, a := range ps.Addrs {
		cs, ms := a.Stats.ChainStats, a.Stats.MempoolStats
		if _, err := tx.ExecContext(ctx, `INSERT INTO electrum_addresses
			(wallet_id, kind, change, idx, address,
			 chain_funded_count, chain_funded_sum, chain_spent_count, chain_spent_sum, chain_tx_count,
			 mempool_funded_count, mempool_funded_sum, mempool_spent_count, mempool_spent_sum, mempool_tx_count)
			VALUES (?,?,?,?,?, ?,?,?,?,?, ?,?,?,?,?)`,
			walletID, a.Kind.String(), a.Change, a.Index, a.Address,
			cs.FundedTxoCount, cs.FundedTxoSum, cs.SpentTxoCount, cs.SpentTxoSum, cs.TxCount,
			ms.FundedTxoCount, ms.FundedTxoSum, ms.SpentTxoCount, ms.SpentTxoSum, ms.TxCount); err != nil {
			return err
		}
		for _, u := range a.UTXOs {
			if _, err := tx.ExecContext(ctx, `INSERT INTO electrum_utxos
				(wallet_id, address, txid, vout, value, confirmed, block_height, block_hash, block_time)
				VALUES (?,?,?,?,?,?,?,?,?)`,
				walletID, a.Address, u.TxID, u.Vout, u.Value, boolToInt(u.Status.Confirmed),
				u.Status.BlockHeight, u.Status.BlockHash, u.Status.BlockTime); err != nil {
				return err
			}
		}
		for _, t := range a.Txs {
			raw, err := json.Marshal(t)
			if err != nil {
				return err
			}
			if _, err := tx.ExecContext(ctx, `INSERT INTO electrum_txs (wallet_id, address, txid, raw) VALUES (?,?,?,?)`,
				walletID, a.Address, t.TxID, string(raw)); err != nil {
				return err
			}
		}
	}
	return tx.Commit()
}

// deleteElectrumScan removes a single wallet's stored scan.
func (s *Service) deleteElectrumScan(walletID string) {
	if s.electrumDB == nil {
		return
	}
	ctx := context.Background()
	for _, table := range electrumScanTables {
		if _, err := s.electrumDB.ExecContext(ctx, "DELETE FROM "+table+" WHERE wallet_id = ?", walletID); err != nil {
			s.log.Warn().Err(err).Str("table", table).Msg("delete electrum scan failed")
		}
	}
}

// wipeElectrumScans clears every wallet's stored scan, used on a full reset.
func (s *Service) wipeElectrumScans() {
	if s.electrumDB == nil {
		return
	}
	ctx := context.Background()
	for _, table := range electrumScanTables {
		if _, err := s.electrumDB.ExecContext(ctx, "DELETE FROM "+table); err != nil {
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
