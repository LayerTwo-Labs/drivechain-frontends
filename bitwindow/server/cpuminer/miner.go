/*
 * Copyright 2010 Jeff Garzik
 * Copyright 2012-2017 pooler
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation; either version 2 of the License, or (at your option)
 * any later version.  See COPYING for more details.
 */

package cpuminer

import (
	"bytes"
	"cmp"
	"context"
	"encoding/binary"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"math/big"
	"net/http"
	"os"
	"slices"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"
	"time"

	"github.com/btcsuite/btcd/blockchain"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"golang.org/x/sync/singleflight"
)

// Work represents a unit of mining work
type Work struct {
	version    int32
	prevblock  *chainhash.Hash
	timestamp  time.Time
	bits       uint32
	nonce      uint32
	merkleroot *chainhash.Hash

	Target *big.Int

	Height int
	Txs    string
	WorkID string

	JobID string
}

func (w *Work) copy() *Work {
	return &Work{
		version:    w.version,
		prevblock:  w.prevblock,
		timestamp:  w.timestamp,
		bits:       w.bits,
		nonce:      w.nonce,
		merkleroot: w.merkleroot,
		Target:     w.Target,
		Height:     w.Height,
		Txs:        w.Txs,
		WorkID:     w.WorkID,
		JobID:      w.JobID,
	}
}

func (w *Work) blockHeader() *wire.BlockHeader {
	return &wire.BlockHeader{
		Version:    w.version,
		PrevBlock:  *w.prevblock,
		Timestamp:  w.timestamp,
		MerkleRoot: *w.merkleroot,
		Bits:       w.bits,
		Nonce:      w.nonce,
	}
}

type gbtTransaction struct {
	Data string `json:"data"` // hex string
	Hash string `json:"hash"` // hex string
	Txid string `json:"txid"` // hex string
}

type gbtRpcResponse struct {
	Target            string            `json:"target"`            // hex string
	PreviousBlockhash string            `json:"previousblockhash"` // hex string
	Bits              string            `json:"bits"`              // hex string
	Height            int               `json:"height"`
	Curtime           uint32            `json:"curtime"`
	Version           uint32            `json:"version"`
	Rules             []string          `json:"rules"`
	Mutable           []string          `json:"mutable"`
	Transactions      []gbtTransaction  `json:"transactions"`
	CoinbaseTxn       json.RawMessage   `json:"coinbasetxn"`
	CoinbaseValue     uint64            `json:"coinbasevalue"`
	CoinbaseAux       map[string]string `json:"coinbaseaux"`
	WorkID            string            `json:"workid"`
}

// gbtWorkDecode decodes GetBlockTemplate response and constructs block
func gbtWorkDecode(val gbtRpcResponse, coinbaseAddr string, coinbaseSig string) (*Work, error) {
	var work Work

	var version, curtime uint32
	var cbtx []byte
	var merkleTree [][]byte
	var (
		coinbaseAppend = slices.Contains(val.Mutable, "coinbase/append")
		submitCoinbase = slices.Contains(val.Mutable, "submit/coinbase")
		segwit         = slices.Contains(val.Rules, "segwit")
	)

	// Get height
	work.Height = val.Height
	version = val.Version

	// Get curtime
	curtime = val.Curtime

	// Get bits
	bits, err := strconv.ParseUint(val.Bits, 16, 32)
	if err != nil {
		return nil, fmt.Errorf("invalid bits: %w", err)
	}

	target := blockchain.CompactToBig(uint32(bits))

	// Get transactions
	txCount := len(val.Transactions)
	txSize := 0
	for _, tx := range val.Transactions {
		txHex := tx.Data
		txSize += len(txHex) / 2
	}

	// Build coinbase transaction
	if len(val.CoinbaseTxn) > 0 {
		panic("coinbaseTxn not implemented")
		/*
			cbtxHex, ok := coinbaseTxn["data"].(string)
			if !ok {
				return fmt.Errorf("JSON invalid coinbasetxn")
			}
			cbtxSize := len(cbtxHex) / 2
			cbtx = make([]byte, cbtxSize+100)
			if cbtxSize < 60 {
				return fmt.Errorf("JSON invalid coinbasetxn")
			}
			if err := hex2bin(cbtx, cbtxHex); err != nil {
				return fmt.Errorf("JSON invalid coinbasetxn: %v", err)
			}
			cbtx = cbtx[:cbtxSize]
		*/
	} else {
		// Build coinbase from coinbasevalue
		if coinbaseAddr == "" {
			return nil, fmt.Errorf("no payout address provided")
		}

		cbtx = make([]byte, 256)
		le32enc(cbtx[0:], 1) // version
		cbtx[4] = 1          // in-counter
		// prev txout hash (32 bytes of zeros)
		for i := 5; i < 37; i++ {
			cbtx[i] = 0x00
		}
		le32enc(cbtx[37:], 0xffffffff) // prev txout index
		cbtxSize := 43

		// BIP 34: height in coinbase
		if work.Height >= 1 && work.Height <= 16 {
			cbtx[42] = byte(work.Height + 0x50)
			cbtx[cbtxSize] = 0x00 // OP_0; pads to 2 bytes
			cbtxSize++
		} else {
			n := work.Height
			for n != 0 {
				cbtx[cbtxSize] = byte(n & 0xff)
				cbtxSize++
				if n < 0x100 && n >= 0x80 {
					cbtx[cbtxSize] = 0
					cbtxSize++
				}
				n >>= 8
			}
			cbtx[42] = byte(cbtxSize - 43)
		}
		cbtx[41] = byte(cbtxSize - 42)       // scriptsig length
		le32enc(cbtx[cbtxSize:], 0xffffffff) // sequence
		cbtxSize += 4
		if segwit {
			cbtx[cbtxSize] = 2 // out-counter
		} else {
			cbtx[cbtxSize] = 1 // out-counter
		}
		cbtxSize++
		le32enc(cbtx[cbtxSize:], uint32(val.CoinbaseValue))       // value low
		le32enc(cbtx[cbtxSize+4:], uint32(val.CoinbaseValue>>32)) // value high
		cbtxSize += 8

		// Convert coinbase address to script
		addr, err := btcutil.DecodeAddress(coinbaseAddr, &chaincfg.MainNetParams)
		if err != nil {
			return nil, fmt.Errorf("invalid coinbase address %q: %w", coinbaseAddr, err)
		}
		pkScript, err := txscript.PayToAddrScript(addr)
		if err != nil {
			return nil, fmt.Errorf("convert coinbase address to script: %w", err)
		}

		cbtx[cbtxSize] = byte(len(pkScript)) // txout-script length
		cbtxSize++
		copy(cbtx[cbtxSize:], pkScript)
		cbtxSize += len(pkScript)

		if segwit {
			// SegWit witness commitment
			wtree := make([][]byte, txCount+2)
			for i := range wtree {
				wtree[i] = make([]byte, 32)
			}

			// Zero value for witness commitment
			for i := 0; i < 8; i++ {
				cbtx[cbtxSize+i] = 0
			}
			cbtxSize += 8
			cbtx[cbtxSize] = 38 // txout-script length
			cbtxSize++
			cbtx[cbtxSize] = 0x6a // OP_RETURN
			cbtxSize++
			cbtx[cbtxSize] = 0x24 // push 36 bytes
			cbtxSize++
			cbtx[cbtxSize] = 0xaa
			cbtxSize++
			cbtx[cbtxSize] = 0x21
			cbtxSize++
			cbtx[cbtxSize] = 0xa9
			cbtxSize++
			cbtx[cbtxSize] = 0xed
			cbtxSize++

			// Build witness merkle tree
			for i, tx := range val.Transactions {
				if err := decodeHex(wtree[1+i], tx.Hash); err != nil {
					return nil, fmt.Errorf("JSON invalid transaction hash: %v", err)
				}
				reverseBytes(wtree[1+i])
			}

			// Compute witness merkle root
			n := txCount + 1
			for n > 1 {
				if n%2 != 0 {
					copy(wtree[n], wtree[n-1])
					n++
				}
				n /= 2
				for i := 0; i < n; i++ {
					combined := append(wtree[2*i], wtree[2*i+1]...) //nolint:gocritic
					sha256d(wtree[i], combined)
				}
			}
			// Witness reserved value = 0
			for i := 0; i < 32; i++ {
				wtree[1][i] = 0
			}
			combined := append(wtree[0], wtree[1]...) //nolint:gocritic
			sha256d(cbtx[cbtxSize:], combined)
			cbtxSize += 32
		}
		le32enc(cbtx[cbtxSize:], 0) // lock time
		cbtxSize += 4
		cbtx = cbtx[:cbtxSize]
		coinbaseAppend = true
	}

	// Append coinbase signature/aux data if allowed
	if coinbaseAppend {
		xsig := make([]byte, 0, 100)
		if coinbaseSig != "" {
			xsig = append(xsig, []byte(coinbaseSig)...)
		}

		for _, s := range val.CoinbaseAux {
			buf := make([]byte, 100)
			n := len(s) / 2
			if n > 100 {
				return nil, fmt.Errorf("coinbaseaux too long: %d", n)
			}
			if err := decodeHex(buf, s); err != nil {
				return nil, fmt.Errorf("JSON invalid coinbaseaux: %v", err)
			}
			if len(xsig)+n <= 100 {
				xsig = append(xsig, buf[:n]...)
			}
		}

		if len(xsig) > 0 {
			ssigEnd := 42 + int(cbtx[41])
			pushLen := 0
			switch {
			case cbtx[41]+byte(len(xsig)) < 76:
				pushLen = 1
			case int(cbtx[41])+2+len(xsig) > 100:
				pushLen = 0
			default:
				pushLen = 2
			}
			n := len(xsig) + pushLen
			// Make room for xsig
			newCbtx := make([]byte, len(cbtx)+n)
			copy(newCbtx, cbtx[:ssigEnd])
			copy(newCbtx[ssigEnd+n:], cbtx[ssigEnd:])
			if pushLen == 2 {
				newCbtx[ssigEnd] = 0x4c // OP_PUSHDATA1
				ssigEnd++
			}
			if pushLen > 0 {
				newCbtx[ssigEnd] = byte(len(xsig))
				ssigEnd++
			}
			copy(newCbtx[ssigEnd:], xsig)
			cbtx = newCbtx
			cbtx[41] += byte(n)
		}
	}

	// Encode transaction count varint
	txcVi := make([]byte, 9)
	n := varint_encode(txcVi, uint64(1+txCount))
	txsHex := make([]byte, 2*(n+len(cbtx)+txSize)+1)
	hex.Encode(txsHex, txcVi[:n])
	hex.Encode(txsHex[2*n:], cbtx)
	txsEnd := 2*n + 2*len(cbtx)

	// Generate merkle root
	merkleTree = make([][]byte, ((1 + txCount + 1) &^ 1))
	for i := range merkleTree {
		merkleTree[i] = make([]byte, 32)
	}

	// Hash coinbase
	if segwit {
		if len(val.CoinbaseTxn) > 0 {
			panic("coinbaseTxn not implemented")
			/*
				cbtxTxid, ok := coinbaseTxn["txid"].(string)
				if !ok {
					return fmt.Errorf("JSON invalid coinbase txid")
				}
				if err := hex2bin(merkleTree[0], cbtxTxid); err != nil {
					return fmt.Errorf("JSON invalid coinbase txid: %v", err)
				}
				memrev(merkleTree[0])
			*/
		} else {
			sha256d(merkleTree[0], cbtx)
		}
	} else {
		sha256d(merkleTree[0], cbtx)
	}

	// Hash transactions
	for i, tx := range val.Transactions {
		txHex := tx.Data
		if segwit {
			if err := decodeHex(merkleTree[1+i], tx.Txid); err != nil {
				return nil, fmt.Errorf("invalid transaction txid: %w", err)
			}
			reverseBytes(merkleTree[1+i])
		} else {
			txSize := len(txHex) / 2
			txBytes := make([]byte, txSize)
			if err := decodeHex(txBytes, txHex); err != nil {
				return nil, fmt.Errorf("invalid transactions: %w", err)
			}
			sha256d(merkleTree[1+i], txBytes)
		}
		if !submitCoinbase {
			copy(txsHex[txsEnd:], []byte(txHex))
			txsEnd += len(txHex)
		}
	}

	// Build merkle tree
	n = 1 + txCount
	for n > 1 {
		if n%2 != 0 {
			copy(merkleTree[n], merkleTree[n-1])
			n++
		}
		n /= 2
		for i := 0; i < n; i++ {
			combined := append(merkleTree[2*i], merkleTree[2*i+1]...) //nolint:gocritic
			sha256d(merkleTree[i], combined)
		}
	}

	work.version = int32(version)
	work.prevblock, err = chainhash.NewHashFromStr(val.PreviousBlockhash)
	if err != nil {
		return nil, fmt.Errorf("JSON invalid previousblockhash: %v", err)
	}
	work.merkleroot, err = chainhash.NewHash(merkleTree[0])
	if err != nil {
		return nil, fmt.Errorf("JSON invalid merkle root: %v", err)
	}
	work.timestamp = time.Unix(int64(curtime), 0)
	work.bits = uint32(bits)
	work.nonce = 0 // start at zero!

	work.Target = target

	// Get workid
	if workid := val.WorkID; workid != "" {
		work.WorkID = workid
	}

	// Store transactions
	work.Txs = string(txsHex[:txsEnd])

	return &work, nil
}

type Config struct {
	Routines          int // Number of miner routines to run. Defaults to 1.
	CoinbaseAddress   string
	CoinbaseSignature string

	// Maximum time to spend scanning the current work. Defaults to 1 minute.
	ScanTime time.Duration

	RpcURL  string
	RpcUser string
	RpcPass string
}

func New(cfg Config) (*Miner, error) {
	if cfg.Routines == 0 {
		cfg.Routines = 1
	}

	if cfg.ScanTime == 0 {
		cfg.ScanTime = time.Minute
	}

	return &Miner{
		client:            http.DefaultClient,
		acceptedBlocks:    make(chan chainhash.Hash),
		routines:          cfg.Routines,
		scanTime:          cfg.ScanTime,
		rpcURL:            cfg.RpcURL,
		rpcUser:           cfg.RpcUser,
		rpcPass:           cfg.RpcPass,
		coinbaseAddress:   cfg.CoinbaseAddress,
		coinbaseSignature: cfg.CoinbaseSignature,
	}, nil
}

type Miner struct {
	routines                           int
	coinbaseAddress, coinbaseSignature string
	scanTime                           time.Duration

	rpcURL           string
	rpcUser, rpcPass string

	fetchWork singleflight.Group
	work      atomic.Pointer[Work]

	totalHashes atomic.Uint64

	client *http.Client

	acceptedBlocks chan chainhash.Hash
}

func (m *Miner) getNewWork(ctx context.Context) (*Work, error) {
	res, err, _ := m.fetchWork.Do("", func() (any, error) {
		start := time.Now()
		params := []any{
			map[string]any{
				"capabilities": []string{"coinbasetxn", "coinbasevalue", "longpoll", "workid"},
				"rules":        []string{"segwit"},
			},
		}

		val, err := m.jsonRpcCall(ctx, "getblocktemplate", params)
		if err != nil {
			return nil, fmt.Errorf("get new work: %w", err)
		}

		var parsed gbtRpcResponse
		if err := json.Unmarshal(val, &parsed); err != nil {
			return nil, fmt.Errorf("parse getblocktemplate response: %w", err)
		}

		decoded, err := gbtWorkDecode(parsed, m.coinbaseAddress, m.coinbaseSignature)
		if err != nil {
			return nil, fmt.Errorf("decode work: %w", err)
		}

		zerolog.Ctx(ctx).Debug().Msgf("Fetched new work in %s", time.Since(start))
		return decoded, nil
	})

	if err != nil {
		return nil, err
	}

	work := res.(*Work)
	m.work.Store(work)
	return work, nil
}

func (m *Miner) loadCurrentWork(ctx context.Context) (*Work, error) {
	work := m.work.Load()
	if work == nil {
		work, err := m.getNewWork(ctx)
		if err != nil {
			return nil, fmt.Errorf("get new work: %w", err)
		}
		return work, nil
	}

	return work, nil
}

// GetHashes returns the total number of hashes performed by the miner
func (m *Miner) GetHashes() uint64 {
	return m.totalHashes.Load()
}

func (m *Miner) AcceptedBlocks() <-chan chainhash.Hash {
	return m.acceptedBlocks
}

func (m *Miner) Start(ctx context.Context) error {
	if m.routines == 0 {
		panic("PROGRAMMER ERROR: zero routines")
	}
	errs := make(chan error)
	for i := 0; i < m.routines; i++ {
		go func() {
			log := zerolog.Ctx(ctx).With().Int("routine", i).Logger()
			ctx := log.WithContext(ctx)

			if err := m.runRoutine(ctx, i); err != nil && !errors.Is(err, context.Canceled) {
				errs <- fmt.Errorf("miner routine no. %d: %w", i, err)
			}
		}()
	}
	return <-errs
}

// minerThread is the main mining thread
func (m *Miner) runRoutine(ctx context.Context, routineID int) error {

	maxNonce := uint32(0xffffffff/m.routines*(routineID+1) - 0x20)

	for {
		// Get work
		work, err := m.loadCurrentWork(ctx)
		if err != nil {
			return fmt.Errorf("load current work: %w", err)
		}

		// Copy work
		work = work.copy()
		work.nonce = uint32(0xffffffff/m.routines) * uint32(routineID)

		// Scan nonces
		found, err := m.scanhashSha256d(ctx, work, maxNonce)
		if err != nil {
			return fmt.Errorf("scan hash: %w", err)
		}

		if !found {
			if _, err := m.getNewWork(ctx); err != nil {
				return fmt.Errorf("get new work: %w", err)
			}

			continue
		}

		// Submit work if found
		reason, err := m.submitUpstreamWork(ctx, work)
		if err != nil {
			return fmt.Errorf("submit work: %w", err)
		}

		switch lo.FromPtr(reason) {
		case "":

		// Ok, work just hasn't been updated yet
		case "duplicate":
			zerolog.Ctx(ctx).Debug().Msgf("Submitted duplicate block")

		// I believe this is due to multiple miners submitting at the same time?
		case "inconclusive":
			zerolog.Ctx(ctx).Debug().Msgf("Submitted inconclusive block")

		case "high-hash":
			zerolog.Ctx(ctx).Error().
				Msgf("Block rejected with too high hash (too little work), nonce was: %d", work.nonce)

		default:
			return fmt.Errorf("block rejected: %s", *reason)
		}
	}
}

var (
	testingTargetOnce sync.Once
	testingTarget     uint32
)

func getTestingTarget(ctx context.Context) *big.Int {
	testingTargetOnce.Do(func() {
		// The user can set TESTING_HASH_GOAL to indicate how many hashes they
		// want to churn through before they can be expected to find a block.
		raw := os.Getenv("TESTING_HASH_GOAL")
		if raw == "" {
			return
		}

		// Convert the goal to a valid compact target. Tolerate underscores
		parsed, err := strconv.Atoi(strings.ReplaceAll(raw, "_", ""))
		if err != nil {
			panic(fmt.Errorf("parse testing target: %w", err))
		}
		if parsed <= 0 {
			panic(fmt.Errorf("testing target must be greater than or equal to 1"))
		}

		// Expected hashes to find a block = 2^256 / target
		// So: target = 2^256 / expected_hashes
		target := new(big.Int).Div(
			new(big.Int).Lsh(big.NewInt(1), 256), // 2^256
			big.NewInt(int64(parsed)),
		)
		testingTarget = blockchain.BigToCompact(target)

		zerolog.Ctx(ctx).Info().
			Msgf("Testing target set to %#x (hash goal: %d)", testingTarget, parsed)
	})

	if testingTarget == 0 {
		return nil
	}

	return blockchain.CompactToBig(testingTarget)
}

// Bool return indicates if a solution was found
func (m *Miner) scanhashSha256d(
	ctx context.Context, work *Work, maxNonce uint32,
) (bool, error) {
	start := time.Now()

	var buf bytes.Buffer
	header := work.blockHeader()
	if err := header.Serialize(&buf); err != nil {
		return false, fmt.Errorf("serialize block header: %w", err)
	}

	data := buf.Bytes()
	if len(data) != 80 {
		return false, fmt.Errorf("unexpected block header size: %d", len(data))
	}

	hash := make([]byte, 32)

	for header.Nonce < maxNonce && time.Since(start) < m.scanTime {
		// Update nonce
		header.Nonce++
		binary.LittleEndian.PutUint32(data[76:], header.Nonce)

		sha256d(hash, data)

		m.totalHashes.Add(1)

		typedHash, err := chainhash.NewHash(hash)
		if err != nil {
			return false, err
		}

		if hashNum := blockchain.HashToBig(typedHash); hashNum.Cmp(
			cmp.Or(getTestingTarget(ctx), work.Target),
		) <= 0 {
			// IMPORTANT: Update work.nonce before returning!
			work.nonce = header.Nonce

			return true, nil
		}
	}

	return false, nil
}
