package stratum_test

import (
	"bufio"
	"crypto/sha256"
	"encoding/binary"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"math/big"
	"net"
	"testing"
	"time"

	"github.com/btcsuite/btcd/blockchain"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/wire"
	"github.com/stretchr/testify/require"
)

type line struct {
	ID     json.RawMessage   `json:"id"`
	Method string            `json:"method"`
	Params []json.RawMessage `json:"params"`
	Result json.RawMessage   `json:"result"`
	Error  json.RawMessage   `json:"error"`
}

// testMiner speaks Stratum v1 the way an ASIC does.
type testMiner struct {
	t      *testing.T
	conn   net.Conn
	reader *bufio.Reader
	nextID int
	notes  []line

	extranonce1     []byte
	extranonce2Size int
	difficulty      float64
}

func dialMiner(t *testing.T, addr string) *testMiner {
	t.Helper()
	var conn net.Conn
	require.Eventually(t, func() bool {
		c, err := net.Dial("tcp", addr)
		if err != nil {
			return false
		}
		conn = c
		return true
	}, 5*time.Second, 20*time.Millisecond)
	t.Cleanup(func() { _ = conn.Close() })
	return &testMiner{t: t, conn: conn, reader: bufio.NewReader(conn)}
}

func (m *testMiner) read() (line, error) {
	if err := m.conn.SetReadDeadline(time.Now().Add(20 * time.Second)); err != nil {
		return line{}, err
	}
	raw, err := m.reader.ReadBytes('\n')
	if err != nil {
		return line{}, err
	}
	var l line
	if err := json.Unmarshal(raw, &l); err != nil {
		return line{}, fmt.Errorf("decode %s: %w", raw, err)
	}
	return l, nil
}

// call sends a request and returns its reply. Notifications on the way are
// kept for next.
func (m *testMiner) call(method string, params ...any) line {
	m.t.Helper()
	m.nextID++
	id := m.nextID
	raw, err := json.Marshal(map[string]any{"id": id, "method": method, "params": params})
	require.NoError(m.t, err)
	_, err = m.conn.Write(append(raw, '\n'))
	require.NoError(m.t, err)
	for {
		l, err := m.read()
		require.NoError(m.t, err)
		if l.Method != "" {
			m.notes = append(m.notes, l)
			continue
		}
		if string(l.ID) == fmt.Sprint(id) {
			return l
		}
	}
}

func (m *testMiner) next(method string) line {
	m.t.Helper()
	for {
		if len(m.notes) > 0 {
			l := m.notes[0]
			m.notes = m.notes[1:]
			if l.Method == "mining.set_difficulty" {
				require.NoError(m.t, json.Unmarshal(l.Params[0], &m.difficulty))
			}
			if l.Method == method {
				return l
			}
			continue
		}
		l, err := m.read()
		require.NoError(m.t, err)
		m.notes = append(m.notes, l)
	}
}

func (m *testMiner) start(worker string) {
	m.t.Helper()
	reply := m.call("mining.configure", []string{"version-rolling"}, map[string]any{"version-rolling.mask": "ffffffff"})
	require.Equal(m.t, "null", string(reply.Error))

	reply = m.call("mining.subscribe", "test-miner/1.0")
	var sub []json.RawMessage
	require.NoError(m.t, json.Unmarshal(reply.Result, &sub))
	var en1 string
	require.NoError(m.t, json.Unmarshal(sub[1], &en1))
	require.NoError(m.t, json.Unmarshal(sub[2], &m.extranonce2Size))
	var err error
	m.extranonce1, err = hex.DecodeString(en1)
	require.NoError(m.t, err)

	reply = m.call("mining.authorize", worker, "x")
	require.Equal(m.t, "true", string(reply.Result))
}

type job struct {
	id       string
	prevHash chainhash.Hash
	coinb1   []byte
	coinb2   []byte
	branch   [][]byte
	version  uint32
	bits     uint32
	ntime    uint32
}

func parseJob(t *testing.T, l line) job {
	t.Helper()
	var j job
	var prev, coinb1, coinb2, version, bits, ntime string
	var branch []string
	for i, target := range []any{&j.id, &prev, &coinb1, &coinb2, &branch, &version, &bits, &ntime} {
		require.NoError(t, json.Unmarshal(l.Params[i], target))
	}
	words, err := hex.DecodeString(prev)
	require.NoError(t, err)
	for i := 0; i < 32; i += 4 {
		j.prevHash[i], j.prevHash[i+1], j.prevHash[i+2], j.prevHash[i+3] = words[i+3], words[i+2], words[i+1], words[i]
	}
	j.coinb1, err = hex.DecodeString(coinb1)
	require.NoError(t, err)
	j.coinb2, err = hex.DecodeString(coinb2)
	require.NoError(t, err)
	for _, b := range branch {
		h, err := hex.DecodeString(b)
		require.NoError(t, err)
		j.branch = append(j.branch, h)
	}
	for text, out := range map[string]*uint32{version: &j.version, bits: &j.bits, ntime: &j.ntime} {
		b, err := hex.DecodeString(text)
		require.NoError(t, err)
		*out = binary.BigEndian.Uint32(b)
	}
	return j
}

func sha256d(b []byte) []byte {
	first := sha256.Sum256(b)
	second := sha256.Sum256(first[:])
	return second[:]
}

// solution is a share the test miner found.
type solution struct {
	extranonce2 []byte
	coinbase    []byte
	header      wire.BlockHeader
}

// grind rolls the nonce until the header meets difficulty.
func grind(t *testing.T, m *testMiner, j job, extranonce2 []byte, versionBits uint32, difficulty float64) solution {
	t.Helper()
	coinbase := append(append(append(append([]byte{}, j.coinb1...), m.extranonce1...), extranonce2...), j.coinb2...)
	root := sha256d(coinbase)
	for _, h := range j.branch {
		root = sha256d(append(root, h...))
	}
	var merkle chainhash.Hash
	copy(merkle[:], root)

	diff1 := blockchain.CompactToBig(0x1d00ffff)
	target, _ := new(big.Float).Quo(new(big.Float).SetInt(diff1), big.NewFloat(difficulty)).Int(nil)
	header := wire.BlockHeader{
		Version:    int32(j.version&^0x1fffe000 | versionBits),
		PrevBlock:  j.prevHash,
		MerkleRoot: merkle,
		Timestamp:  time.Unix(int64(j.ntime), 0),
		Bits:       j.bits,
	}
	for nonce := uint32(0); nonce < 1<<20; nonce++ {
		header.Nonce = nonce
		hash := header.BlockHash()
		if blockchain.HashToBig(&hash).Cmp(target) <= 0 {
			return solution{extranonce2: extranonce2, coinbase: coinbase, header: header}
		}
	}
	t.Fatal("no nonce meets the difficulty")
	return solution{}
}

func (m *testMiner) submit(worker string, j job, s solution, versionBits uint32) line {
	m.t.Helper()
	return m.call("mining.submit", worker, j.id, hex.EncodeToString(s.extranonce2),
		fmt.Sprintf("%08x", j.ntime), fmt.Sprintf("%08x", s.header.Nonce), fmt.Sprintf("%08x", versionBits))
}
