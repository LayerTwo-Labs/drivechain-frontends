-- Demo mode sidechains table for persistent demo data on mainnet
CREATE TABLE IF NOT EXISTS demo_sidechains (
    slot INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    balance_satoshi INTEGER NOT NULL DEFAULT 0,
    hashid1 TEXT NOT NULL DEFAULT '',
    hashid2 TEXT NOT NULL DEFAULT '',
    last_deposit_at INTEGER NOT NULL
);

-- Seed initial demo sidechain data
INSERT OR IGNORE INTO demo_sidechains (slot, title, description, balance_satoshi, hashid1, hashid2, last_deposit_at) VALUES
    (2, 'BitNames', 'Decentralized naming system for Bitcoin addresses and identities', 175000000, '0000000000000000000000000000000000000000000000000000000000000002', '0000000000000000000000000000000002', strftime('%s', 'now')),
    (4, 'BitAssets', 'Create and trade digital assets backed by Bitcoin', 425000000, '0000000000000000000000000000000000000000000000000000000000000004', '0000000000000000000000000000000004', strftime('%s', 'now')),
    (9, 'Thunder', 'Large blocks and fraud proofs for fast Bitcoin payments', 250000000, '0000000000000000000000000000000000000000000000000000000000000009', '0000000000000000000000000000000009', strftime('%s', 'now')),
    (13, 'Truthcoin', 'Bitcoin Hivemind prediction market sidechain', 150000000, '0000000000000000000000000000000000000000000000000000000000000013', '0000000000000000000000000000000013', strftime('%s', 'now')),
    (98, 'ZSide', 'Privacy-preserving sidechain with shielded transactions', 88000000, '0000000000000000000000000000000000000000000000000000000000000098', '0000000000000000000000000000000098', strftime('%s', 'now')),
    (99, 'Photon', 'High-performance sidechain for scalable Bitcoin applications', 320000000, '0000000000000000000000000000000000000000000000000000000000000099', '0000000000000000000000000000000099', strftime('%s', 'now'));

-- Demo mode recent actions table for simulated sidechain activity
CREATE TABLE IF NOT EXISTS demo_recent_actions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    action_type TEXT NOT NULL,  -- 'deposit', 'withdrawal', 'withdrawal_ack', 'sidechain_proposal', 'sidechain_ack'
    sidechain_slot INTEGER NOT NULL,
    sidechain_name TEXT NOT NULL,
    amount_satoshi INTEGER,     -- For deposits/withdrawals
    ack_count INTEGER,          -- For ack-type actions (current acks)
    ack_total INTEGER,          -- For ack-type actions (total needed)
    extra_info TEXT,            -- Additional info like "Ethereum at slot 9"
    created_at INTEGER NOT NULL DEFAULT (strftime('%s', 'now')),
    FOREIGN KEY (sidechain_slot) REFERENCES demo_sidechains(slot)
);
