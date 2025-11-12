-- M4 Explorer / SCDB State Tracking
-- Migration 007: Add tables for M4 messages, withdrawal bundles, and sidechains

-- Active sidechains tracked by the node
CREATE TABLE IF NOT EXISTS sidechains (
    slot INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    version TEXT,
    activated_height INTEGER,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Withdrawal bundles being voted on
CREATE TABLE IF NOT EXISTS withdrawal_bundles (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    sidechain_slot INTEGER NOT NULL,
    bundle_hash TEXT NOT NULL,
    work_score INTEGER NOT NULL DEFAULT 1,
    blocks_left INTEGER NOT NULL,
    max_age INTEGER NOT NULL DEFAULT 26300,
    first_seen_height INTEGER NOT NULL,
    last_updated_height INTEGER NOT NULL,
    status TEXT NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(sidechain_slot, bundle_hash),
    FOREIGN KEY (sidechain_slot) REFERENCES sidechains(slot)
);

-- M3 messages (withdrawal bundle proposals) parsed from blocks
CREATE TABLE IF NOT EXISTS m3_messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    block_height INTEGER NOT NULL,
    block_hash TEXT NOT NULL,
    block_time TIMESTAMP NOT NULL,
    sidechain_slot INTEGER NOT NULL,
    bundle_hash TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(block_height, sidechain_slot, bundle_hash),
    FOREIGN KEY (sidechain_slot) REFERENCES sidechains(slot)
);

-- M4 messages parsed from blocks
CREATE TABLE IF NOT EXISTS m4_messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    block_height INTEGER NOT NULL,
    block_hash TEXT NOT NULL,
    block_time TIMESTAMP NOT NULL,
    raw_bytes BLOB NOT NULL,
    version INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    UNIQUE(block_height, block_hash)
);

-- Individual votes per sidechain extracted from M4
CREATE TABLE IF NOT EXISTS m4_votes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    m4_message_id INTEGER NOT NULL,
    sidechain_slot INTEGER NOT NULL,
    vote_type TEXT NOT NULL,
    bundle_hash TEXT,
    bundle_index INTEGER,

    FOREIGN KEY (m4_message_id) REFERENCES m4_messages(id) ON DELETE CASCADE,
    FOREIGN KEY (sidechain_slot) REFERENCES sidechains(slot)
);

-- User vote preferences (what they want to vote for)
CREATE TABLE IF NOT EXISTS m4_vote_preferences (
    sidechain_slot INTEGER PRIMARY KEY,
    vote_type TEXT NOT NULL,
    bundle_hash TEXT,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (sidechain_slot) REFERENCES sidechains(slot)
);

-- Insert default sidechains (can be updated from enforcer)
INSERT OR IGNORE INTO sidechains (slot, name, description) VALUES
    (0, 'Thunder', 'Thunder Network - Payment channels sidechain'),
    (1, 'BitNames', 'BitNames - Decentralized naming system'),
    (2, 'ZSide', 'ZSide - Privacy-focused sidechain'),
    (3, 'BitAssets', 'BitAssets - Asset issuance sidechain');
