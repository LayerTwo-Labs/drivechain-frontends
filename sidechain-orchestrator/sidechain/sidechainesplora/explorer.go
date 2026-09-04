package sidechainesplora

import (
	"context"
	"encoding/json"
	"strconv"
)

// Activity kinds, as the index writes them.
const (
	KindTransfer   = "transfer"
	KindWithdrawal = "withdrawal"
	KindDeposit    = "deposit"
)

// Block is one sidechain block, as /block/{hash} returns it.
type Block struct {
	ID           string  `json:"id"`
	Height       uint32  `json:"height"`
	Timestamp    *int64  `json:"timestamp"`
	TxCount      int     `json:"tx_count"`
	Size         int     `json:"size"`
	MerkleRoot   string  `json:"merkle_root"`
	PreviousHash *string `json:"previousblockhash"`
	// MainchainHash is the mainchain block this header merge mined against.
	MainchainHash string `json:"mainchain_blockhash"`
	// MainchainHeight is the height of that block, when an enforcer resolved it.
	MainchainHeight *uint32 `json:"mainchain_height"`
	Fees            int64   `json:"fees"`
}

// Activity is one thing that happened on the chain: a transaction, or a
// deposit the mainchain sent.
type Activity struct {
	Kind   string `json:"kind"`
	ID     string `json:"id"`
	Value  int64  `json:"value"`
	Fee    int64  `json:"fee"`
	Size   int    `json:"size"`
	Status Status `json:"status"`
}

// MempoolInfo counts what waits for the next block.
type MempoolInfo struct {
	Count int   `json:"count"`
	VSize int64 `json:"vsize"`
	Fees  int64 `json:"total_fee"`
}

// SidechainInfo is the mainchain escrow view of one slot.
type SidechainInfo struct {
	Slot             uint32 `json:"slot"`
	Title            string `json:"title"`
	ActivationHeight uint32 `json:"activation_height"`
	// Treasury is the output the escrow holds for this slot. A slot the
	// enforcer knows no treasury for carries none.
	Treasury *Treasury `json:"treasury"`
}

// Treasury is the escrow output of one slot.
type Treasury struct {
	Txid      string `json:"txid"`
	Vout      uint32 `json:"vout"`
	ValueSats int64  `json:"value_sats"`
}

// WithdrawalState is the bundle a chain proposes to the mainchain. Bundle is
// the node's own JSON, unchanged.
type WithdrawalState struct {
	Bundle           json.RawMessage `json:"bundle"`
	LastFailedHeight *uint32         `json:"last_failed_height"`
}

// Blocks lists the newest block headers, newest first.
func (c *Client) Blocks(ctx context.Context) ([]Block, error) {
	var out []Block
	err := c.get(ctx, "/blocks", &out)
	return out, err
}

// BlocksBefore lists the block headers at or below one height, newest first.
// A height of zero starts at the tip.
func (c *Client) BlocksBefore(ctx context.Context, height uint32) ([]Block, error) {
	if height == 0 {
		return c.Blocks(ctx)
	}
	var out []Block
	err := c.get(ctx, "/blocks/"+strconv.FormatUint(uint64(height), 10), &out)
	return out, err
}

// Block reads one block by hash.
func (c *Client) Block(ctx context.Context, hash string) (Block, error) {
	var out Block
	err := c.get(ctx, "/block/"+hash, &out)
	return out, err
}

// BlockHashAtHeight reads the hash of the block at one height.
func (c *Client) BlockHashAtHeight(ctx context.Context, height uint32) (string, error) {
	return c.getText(ctx, "/block-height/"+strconv.FormatUint(uint64(height), 10))
}

// BlockActivity lists what one block carried, with the deposits it applied.
func (c *Client) BlockActivity(ctx context.Context, hash string) ([]Activity, error) {
	var out []Activity
	err := c.get(ctx, "/block/"+hash+"/activity", &out)
	return out, err
}

// RecentActivity lists the newest rows on the chain, unconfirmed first.
func (c *Client) RecentActivity(ctx context.Context) ([]Activity, error) {
	var out []Activity
	err := c.get(ctx, "/txs/recent", &out)
	return out, err
}

// Tx reads one transaction, with the coins on both sides.
func (c *Client) Tx(ctx context.Context, txid string) (Tx, error) {
	var out Tx
	err := c.get(ctx, "/tx/"+txid, &out)
	return out, err
}

// AddressMempoolTxs lists the unconfirmed transactions that touch one address.
func (c *Client) AddressMempoolTxs(ctx context.Context, address string) ([]Tx, error) {
	var out []Tx
	err := c.get(ctx, "/address/"+address+"/txs/mempool", &out)
	return out, err
}

// Mempool counts what waits for the next block.
func (c *Client) Mempool(ctx context.Context) (MempoolInfo, error) {
	var out MempoolInfo
	err := c.get(ctx, "/mempool", &out)
	return out, err
}

// Sidechain reads the mainchain escrow view of one slot.
func (c *Client) Sidechain(ctx context.Context, slot uint32) (SidechainInfo, error) {
	var out SidechainInfo
	err := c.get(ctx, "/drivechain/sidechain/"+strconv.FormatUint(uint64(slot), 10), &out)
	return out, err
}

// Withdrawals reads the bundle the chain proposes to the mainchain.
func (c *Client) Withdrawals(ctx context.Context) (WithdrawalState, error) {
	var out WithdrawalState
	err := c.get(ctx, "/drivechain/withdrawals", &out)
	return out, err
}
