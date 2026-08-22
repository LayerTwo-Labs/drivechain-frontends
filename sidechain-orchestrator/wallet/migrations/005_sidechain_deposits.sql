-- Deposits BitWindow made itself. The enforcer used to keep this list in its
-- own wallet, and it runs none, so the record lives here now.
CREATE TABLE sidechain_deposits (
    network     TEXT NOT NULL,
    txid        TEXT NOT NULL,
    wallet_id   TEXT NOT NULL,
    slot        INTEGER NOT NULL,
    destination TEXT NOT NULL,
    amount_sats INTEGER NOT NULL,
    created_at  INTEGER NOT NULL,
    PRIMARY KEY (network, txid)
);
