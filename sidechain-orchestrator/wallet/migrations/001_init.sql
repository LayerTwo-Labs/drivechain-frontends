CREATE TABLE electrum_addresses (
    wallet_id            TEXT    NOT NULL,
    change               INTEGER NOT NULL,
    idx                  INTEGER NOT NULL,
    address              TEXT    NOT NULL,
    chain_funded_count   INTEGER NOT NULL,
    chain_funded_sum     INTEGER NOT NULL,
    chain_spent_count    INTEGER NOT NULL,
    chain_spent_sum      INTEGER NOT NULL,
    chain_tx_count       INTEGER NOT NULL,
    mempool_funded_count INTEGER NOT NULL,
    mempool_funded_sum   INTEGER NOT NULL,
    mempool_spent_count  INTEGER NOT NULL,
    mempool_spent_sum    INTEGER NOT NULL,
    mempool_tx_count     INTEGER NOT NULL,
    PRIMARY KEY (wallet_id, change, idx)
);

CREATE TABLE electrum_utxos (
    wallet_id    TEXT    NOT NULL,
    address      TEXT    NOT NULL,
    txid         TEXT    NOT NULL,
    vout         INTEGER NOT NULL,
    value        INTEGER NOT NULL,
    confirmed    INTEGER NOT NULL,
    block_height INTEGER NOT NULL,
    block_hash   TEXT    NOT NULL,
    block_time   INTEGER NOT NULL,
    PRIMARY KEY (wallet_id, txid, vout)
);

CREATE TABLE electrum_txs (
    wallet_id TEXT NOT NULL,
    address   TEXT NOT NULL,
    txid      TEXT NOT NULL,
    raw       TEXT NOT NULL,
    PRIMARY KEY (wallet_id, address, txid)
);
