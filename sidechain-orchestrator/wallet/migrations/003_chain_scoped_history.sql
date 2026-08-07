-- Wallet chain state now lives in one database with the network as the leading
-- key column, so a wallet keeps separate history per chain and a network swap
-- is a field change rather than a database reopen. The scan is a rebuildable
-- cache, so the tables are recreated empty and refilled by the next live scan.
DROP TABLE electrum_addresses;
DROP TABLE electrum_utxos;
DROP TABLE electrum_txs;

CREATE TABLE electrum_addresses (
    network              TEXT    NOT NULL,
    wallet_id            TEXT    NOT NULL,
    kind                 TEXT    NOT NULL,
    change               INTEGER NOT NULL,
    idx                  INTEGER NOT NULL,
    address              TEXT    NOT NULL,
    status               TEXT    NOT NULL,
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
    PRIMARY KEY (network, wallet_id, kind, change, idx)
);

CREATE TABLE electrum_utxos (
    network      TEXT    NOT NULL,
    wallet_id    TEXT    NOT NULL,
    address      TEXT    NOT NULL,
    txid         TEXT    NOT NULL,
    vout         INTEGER NOT NULL,
    value        INTEGER NOT NULL,
    confirmed    INTEGER NOT NULL,
    block_height INTEGER NOT NULL,
    block_hash   TEXT    NOT NULL,
    block_time   INTEGER NOT NULL,
    PRIMARY KEY (network, wallet_id, address, txid, vout)
);

CREATE TABLE electrum_txs (
    network   TEXT NOT NULL,
    wallet_id TEXT NOT NULL,
    txid      TEXT NOT NULL,
    raw       TEXT NOT NULL,
    PRIMARY KEY (network, wallet_id, txid)
);

CREATE TABLE electrum_tx_addresses (
    network   TEXT NOT NULL,
    wallet_id TEXT NOT NULL,
    address   TEXT NOT NULL,
    txid      TEXT NOT NULL,
    PRIMARY KEY (network, wallet_id, address, txid)
);

CREATE TABLE electrum_sync (
    network    TEXT    NOT NULL,
    wallet_id  TEXT    NOT NULL,
    tip_height INTEGER NOT NULL,
    synced_at  INTEGER NOT NULL,
    PRIMARY KEY (network, wallet_id)
);
