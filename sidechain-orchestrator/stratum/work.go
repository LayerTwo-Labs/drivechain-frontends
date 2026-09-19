// Package stratum serves Stratum v1 work to ASIC miners. A Source supplies
// the work: this node's block template, or an upstream pool.
package stratum

import (
	"context"
	"crypto/sha256"
	"fmt"
	"math/big"
	"time"

	"github.com/btcsuite/btcd/blockchain"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/wire"
)

// VersionMask holds the header version bits a miner may roll (BIP320).
const VersionMask uint32 = 0x1fffe000

// Work is one job in the form a Stratum miner receives it.
type Work struct {
	PrevHash chainhash.Hash
	// Coinb1 and Coinb2 surround the extranonce space of the coinbase.
	Coinb1, Coinb2 []byte
	// Extranonce1 starts the extranonce space. Only a pool sets it.
	Extranonce1 []byte
	// ExtranonceSize is the length of the extranonce space after Extranonce1.
	ExtranonceSize int
	Branch         []chainhash.Hash
	Version        int32
	Bits           uint32
	Time           uint32
	// VersionMask holds the version bits the source accepts rolled.
	VersionMask uint32
	// Clean tells miners to drop the work they hold.
	Clean bool

	// Relay sends every share to the source at Difficulty, and the source
	// judges it. Otherwise the server sets the difficulty and sends only the
	// shares that reach Target.
	Relay      bool
	Difficulty float64
	Target     *big.Int

	Height     uint32
	RewardSats int64

	upstreamJobID string
	upstream      *upstreamConn
	txs           [][]byte
	witness       bool
	workID        string
}

// Share is a solution a miner found for one Work.
type Share struct {
	Worker string
	Header wire.BlockHeader
	// Coinbase is the coinbase transaction without its witness.
	Coinbase []byte
	// Extranonce2 is the extranonce space after Work.Extranonce1.
	Extranonce2 []byte
	// VersionBits are the rolled version bits, zero when the miner rolled none.
	VersionBits uint32
	Rolled      bool
}

// Block is a block that a miner found and the node accepted.
type Block struct {
	Height     uint32
	Hash       chainhash.Hash
	RewardSats int64
	Worker     string
	FoundAt    time.Time
}

// Source supplies the work miners get and takes their shares.
type Source interface {
	// Run calls publish with each new Work until ctx ends or the source fails.
	Run(ctx context.Context, publish func(*Work)) error
	// Submit hands on a share. It returns the block the share completed, or
	// nil when the share completed none.
	Submit(ctx context.Context, w *Work, s Share) (*Block, error)
}

func doubleSHA256(b []byte) chainhash.Hash {
	first := sha256.Sum256(b)
	return chainhash.Hash(sha256.Sum256(first[:]))
}

// merkleBranch returns the hashes that fold a coinbase txid into the merkle
// root of a block whose other transactions are txids, in block order.
func merkleBranch(txids []chainhash.Hash) []chainhash.Hash {
	branch := []chainhash.Hash{}
	level := append([]chainhash.Hash{{}}, txids...)
	for len(level) > 1 {
		branch = append(branch, level[1])
		if len(level)%2 == 1 {
			level = append(level, level[len(level)-1])
		}
		next := make([]chainhash.Hash, 0, len(level)/2)
		for i := 0; i < len(level); i += 2 {
			next = append(next, doubleSHA256(append(level[i][:], level[i+1][:]...)))
		}
		level = next
	}
	return branch
}

func merkleRoot(coinbaseTxid chainhash.Hash, branch []chainhash.Hash) chainhash.Hash {
	root := coinbaseTxid
	for _, h := range branch {
		root = doubleSHA256(append(root[:], h[:]...))
	}
	return root
}

var diff1Target = blockchain.CompactToBig(0x1d00ffff)

func difficultyOf(n *big.Int) float64 {
	if n.Sign() <= 0 {
		return 0
	}
	d, _ := new(big.Float).Quo(new(big.Float).SetInt(diff1Target), new(big.Float).SetInt(n)).Float64()
	return d
}

func hashDifficulty(h chainhash.Hash) float64 {
	return difficultyOf(blockchain.HashToBig(&h))
}

// targetOf returns the largest hash that meets difficulty d.
func targetOf(d float64) *big.Int {
	if d <= 0 {
		return new(big.Int).Set(diff1Target)
	}
	t, _ := new(big.Float).Quo(new(big.Float).SetInt(diff1Target), big.NewFloat(d)).Int(nil)
	return t
}

// NetworkDifficulty returns the difficulty of the network target in bits.
func NetworkDifficulty(bits uint32) float64 {
	return difficultyOf(blockchain.CompactToBig(bits))
}

// stratumPrevHash writes a previous block hash in the Stratum word order:
// the header bytes with each 4-byte word reversed.
func stratumPrevHash(h chainhash.Hash) []byte {
	out := make([]byte, chainhash.HashSize)
	for i := 0; i < chainhash.HashSize; i += 4 {
		out[i], out[i+1], out[i+2], out[i+3] = h[i+3], h[i+2], h[i+1], h[i]
	}
	return out
}

func parseStratumPrevHash(b []byte) (chainhash.Hash, error) {
	if len(b) != chainhash.HashSize {
		return chainhash.Hash{}, fmt.Errorf("prevhash has %d bytes, want %d", len(b), chainhash.HashSize)
	}
	var h chainhash.Hash
	for i := 0; i < chainhash.HashSize; i += 4 {
		h[i], h[i+1], h[i+2], h[i+3] = b[i+3], b[i+2], b[i+1], b[i]
	}
	return h, nil
}

func solve(w *Work, extranonce1, extranonce2 []byte, ntime, nonce uint32, version int32) ([]byte, wire.BlockHeader) {
	coinbase := make([]byte, 0, len(w.Coinb1)+len(extranonce1)+len(extranonce2)+len(w.Coinb2))
	coinbase = append(coinbase, w.Coinb1...)
	coinbase = append(coinbase, extranonce1...)
	coinbase = append(coinbase, extranonce2...)
	coinbase = append(coinbase, w.Coinb2...)
	header := wire.BlockHeader{
		Version:    version,
		PrevBlock:  w.PrevHash,
		MerkleRoot: merkleRoot(doubleSHA256(coinbase), w.Branch),
		Timestamp:  time.Unix(int64(ntime), 0),
		Bits:       w.Bits,
		Nonce:      nonce,
	}
	return coinbase, header
}

func rollVersion(version int32, bits, mask uint32) (int32, error) {
	if bits&^mask != 0 {
		return 0, fmt.Errorf("version bits %08x fall outside the mask %08x", bits, mask)
	}
	return int32((uint32(version) &^ mask) | bits), nil
}

// splitExtranonce divides an extranonce space between a per-miner prefix and
// the part the miner rolls.
func splitExtranonce(size int) (prefix, miner int, err error) {
	if size < 2 {
		return 0, 0, fmt.Errorf("an extranonce space of %d bytes is too small to share", size)
	}
	prefix = min(4, size/2)
	return prefix, size - prefix, nil
}
