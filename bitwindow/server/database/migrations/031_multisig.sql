-- Multisig groups
CREATE TABLE IF NOT EXISTS multisig_groups (
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
);

-- Multisig keys (belong to a group)
CREATE TABLE IF NOT EXISTS multisig_keys (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    group_id TEXT NOT NULL REFERENCES multisig_groups(id) ON DELETE CASCADE,
    owner TEXT NOT NULL,
    xpub TEXT NOT NULL,
    derivation_path TEXT NOT NULL,
    fingerprint TEXT,
    origin_path TEXT,
    is_wallet INTEGER NOT NULL DEFAULT 0,
    sort_order INTEGER NOT NULL DEFAULT 0
);

-- Active/initial PSBTs for keys (per transaction)
CREATE TABLE IF NOT EXISTS multisig_key_psbts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    key_id INTEGER NOT NULL REFERENCES multisig_keys(id) ON DELETE CASCADE,
    transaction_id TEXT NOT NULL,
    active_psbt TEXT,
    initial_psbt TEXT,
    UNIQUE(key_id, transaction_id)
);

-- Addresses derived for groups
CREATE TABLE IF NOT EXISTS multisig_addresses (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    group_id TEXT NOT NULL REFERENCES multisig_groups(id) ON DELETE CASCADE,
    addr_type TEXT NOT NULL CHECK(addr_type IN ('receive', 'change')),
    addr_index INTEGER NOT NULL,
    address TEXT NOT NULL,
    used INTEGER NOT NULL DEFAULT 0,
    UNIQUE(group_id, addr_type, addr_index)
);

-- UTXO details for groups (ephemeral, refreshed on balance update)
CREATE TABLE IF NOT EXISTS multisig_utxo_details (
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
);

-- Transaction IDs linked to groups
CREATE TABLE IF NOT EXISTS multisig_group_transactions (
    group_id TEXT NOT NULL REFERENCES multisig_groups(id) ON DELETE CASCADE,
    transaction_id TEXT NOT NULL,
    PRIMARY KEY(group_id, transaction_id)
);

-- Multisig transactions
CREATE TABLE IF NOT EXISTS multisig_transactions (
    id TEXT PRIMARY KEY,
    group_id TEXT NOT NULL,
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
);

-- Key PSBT statuses per transaction
CREATE TABLE IF NOT EXISTS multisig_tx_key_psbts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    transaction_id TEXT NOT NULL REFERENCES multisig_transactions(id) ON DELETE CASCADE,
    key_id TEXT NOT NULL,
    psbt TEXT,
    is_signed INTEGER NOT NULL DEFAULT 0,
    signed_at INTEGER,
    UNIQUE(transaction_id, key_id)
);

-- Transaction inputs (UTXOs spent)
CREATE TABLE IF NOT EXISTS multisig_tx_inputs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    transaction_id TEXT NOT NULL REFERENCES multisig_transactions(id) ON DELETE CASCADE,
    txid TEXT NOT NULL,
    vout INTEGER NOT NULL,
    address TEXT,
    amount REAL NOT NULL DEFAULT 0.0,
    confirmations INTEGER NOT NULL DEFAULT 0
);

-- Solo keys
CREATE TABLE IF NOT EXISTS multisig_solo_keys (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    xpub TEXT NOT NULL UNIQUE,
    derivation_path TEXT NOT NULL,
    fingerprint TEXT,
    origin_path TEXT,
    owner TEXT
);
