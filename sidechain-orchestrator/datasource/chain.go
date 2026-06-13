package datasource

import "context"

// ChainReader is the read-only Bitcoin Core surface. Its return types are
// neutral structs (not tied to btc-buf corerpc or the orchestrator's JSON-RPC
// structs) because the two services back it with different clients — bitwindow
// via the corerpc Connect proxy, the orchestrator via raw JSON-RPC — and a
// future remote impl serves the same shapes. Each backing impl maps its native
// result into these.
type ChainReader interface {
	BlockchainInfo(ctx context.Context) (*BlockchainInfo, error)
	BlockCount(ctx context.Context) (int64, error)
	BlockHash(ctx context.Context, height int64) (string, error)
	Block(ctx context.Context, hash string) (*Block, error)
	RawTransaction(ctx context.Context, txid string) (*Transaction, error)
	MempoolTxIDs(ctx context.Context) ([]string, error)
	EstimateSmartFee(ctx context.Context, confTarget int64) (float64, error)
}

// BlockchainInfo mirrors the consumed fields of bitcoind `getblockchaininfo`.
type BlockchainInfo struct {
	Chain                string
	Blocks               int64
	Headers              int64
	BestBlockHash        string
	InitialBlockDownload bool
	VerificationProgress float64
}

// BlockHeader mirrors the consumed fields of a bitcoind block header.
type BlockHeader struct {
	Hash          string
	Height        int64
	Time          int64
	PreviousHash  string
	MerkleRoot    string
	Bits          string
	Nonce         uint32
	Difficulty    float64
	Version       int32
	Confirmations int64
}

// Block is a bitcoind block with its transaction ids (verbosity 1).
type Block struct {
	Header BlockHeader
	TxIDs  []string
	Size   int64
	Weight int64
}

// Transaction mirrors the consumed fields of a raw bitcoind transaction.
type Transaction struct {
	TxID          string
	Hex           string
	BlockHash     string
	BlockTime     int64
	Time          int64
	Confirmations int64
}
