CREATE TABLE bip47_send_state (
    wallet_id TEXT NOT NULL,
    recipient_payment_code TEXT NOT NULL,
    notification_txid TEXT,
    notification_broadcast_at TIMESTAMP,
    next_send_index INTEGER NOT NULL DEFAULT 0,
    last_used_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (wallet_id, recipient_payment_code)
);
