package api

import (
	"context"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/stretchr/testify/require"
)

var userRows = map[string]string{
	"address_book":       `INSERT INTO address_book (label, address, direction) VALUES ('rent', 'bc1qrent', 'send')`,
	"transaction_notes":  `INSERT INTO transaction_notes (wallet_id, txid, note) VALUES ('w1', 'aa', 'lunch')`,
	"cheques":            `INSERT INTO cheques (wallet_id, derivation_index, expected_amount_sats, address) VALUES ('w1', 0, 1000, 'bc1qcheque')`,
	"denials":            `INSERT INTO denials (initial_txid, initial_vout, delay_duration, num_hops, created_at) VALUES ('bb', 0, 60, 3, CURRENT_TIMESTAMP)`,
	"preferences":        `INSERT INTO preferences (key, value, updated_at) VALUES ('theme', 'dark', 0)`,
	"wallet_psbt_drafts": `INSERT INTO wallet_psbt_drafts (id, wallet_id, psbt_base64, created_at, updated_at) VALUES ('d1', 'w1', 'cHNidP8=', 0, 0)`,
	"multisig_groups":    `INSERT INTO multisig_groups (id, name, n, m, created) VALUES ('g1', 'family', 3, 2, 0)`,
	"utxo_metadata":      `INSERT INTO utxo_metadata (outpoint, label, created_at, updated_at) VALUES ('cc:0', 'savings', 0, 0)`,
	"cn_identity":        `INSERT INTO cn_identity (id, privkey, author_xpk) VALUES (1, x'01', x'02')`,
	"bip47_send_state":   `INSERT INTO bip47_send_state (wallet_id, recipient_payment_code) VALUES ('w1', 'PM8T')`,
}

var chainRows = map[string]string{
	"processed_blocks":   `INSERT INTO processed_blocks (height, block_hash, txids, block_time) VALUES (10, 'h10', '[]', CURRENT_TIMESTAMP)`,
	"op_returns":         `INSERT INTO op_returns (txid, vout, op_return_data, fee_sats, height) VALUES ('dd', 0, '00', 1, 10)`,
	"cn_items":           `INSERT INTO cn_items (item_id, txid, vout, block_height, tx_index, vout_index, type_tag, block_time) VALUES (x'00', 'ee', 0, 10, 1, 0, 1, CURRENT_TIMESTAMP)`,
	"m4_messages":        `INSERT INTO m4_messages (block_height, block_hash, block_time, raw_bytes, version) VALUES (10, 'h10', CURRENT_TIMESTAMP, x'00', 1)`,
	"withdrawal_bundles": `INSERT INTO withdrawal_bundles (sidechain_slot, bundle_hash, blocks_left, first_seen_height, last_updated_height) VALUES (0, 'b1', 10, 10, 10)`,
}

func TestAChainResetKeepsTheUserRows(t *testing.T) {
	ctx := context.Background()
	conf := config.Config{Datadir: t.TempDir()}
	require.NoError(t, conf.Finalize(config.NetworkECash))

	db, err := database.New(ctx, conf)
	require.NoError(t, err)
	for _, rows := range []map[string]string{userRows, chainRows} {
		for table, insert := range rows {
			_, err := db.ExecContext(ctx, insert)
			require.NoError(t, err, table)
		}
	}
	_, err = db.ExecContext(ctx, `INSERT INTO cn_topics (topic, name, retention_days, created_height, txid) VALUES (x'b1b1b1b1', 'Mined topic', 7, 10, 'ff')`)
	require.NoError(t, err)
	require.NoError(t, db.Close())

	require.NoError(t, resetChainDatabase(ctx, conf, 0))

	db, err = database.New(ctx, conf)
	require.NoError(t, err)
	t.Cleanup(func() { require.NoError(t, db.Close()) })

	count := func(query string) int {
		var n int
		require.NoError(t, db.QueryRowContext(ctx, query).Scan(&n))
		return n
	}
	for table := range userRows {
		require.Equal(t, 1, count(`SELECT COUNT(*) FROM `+table), "user table %s", table)
	}
	for table := range chainRows {
		require.Zero(t, count(`SELECT COUNT(*) FROM `+table), "chain table %s", table)
	}
	require.Zero(t, count(`SELECT COUNT(*) FROM cn_topics WHERE txid != ''`), "mined topics")
	require.Equal(t, 2, count(`SELECT COUNT(*) FROM cn_topics WHERE txid = ''`), "default topics")
}
