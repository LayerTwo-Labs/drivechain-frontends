-- Local CoinNews voting identity. A single secp256k1 keypair this node
-- signs Votes with; author_xpk is the BIP-340 x-only pubkey published in
-- the Vote envelope. Singleton row (id = 1).
CREATE TABLE cn_identity (
    id         INTEGER PRIMARY KEY CHECK (id = 1),
    privkey    BLOB(32) NOT NULL,
    author_xpk BLOB(32) NOT NULL
);
