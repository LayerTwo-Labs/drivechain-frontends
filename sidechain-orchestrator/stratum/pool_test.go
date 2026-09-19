package stratum_test

import (
	"bufio"
	"context"
	"encoding/json"
	"fmt"
	"net"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/stratum"
)

// fakePool is an upstream Stratum pool. Each connection gets the next
// extranonce1 from its list.
type fakePool struct {
	ln          net.Listener
	extranonce1 []string
	size        int
	difficulty  float64
	silent      bool

	mu      sync.Mutex
	conns   []net.Conn
	submits [][]string
	worker  string
}

func startFakePool(t *testing.T, extranonce1 ...string) *fakePool {
	return startFakePoolSized(t, 8, extranonce1...)
}

func startFakePoolSized(t *testing.T, size int, extranonce1 ...string) *fakePool {
	t.Helper()
	ln, err := net.Listen("tcp", "127.0.0.1:0")
	require.NoError(t, err)
	p := &fakePool{ln: ln, extranonce1: extranonce1, size: size, difficulty: 1e-9}
	t.Cleanup(func() {
		_ = ln.Close()
		p.dropAll()
	})
	go p.accept()
	return p
}

func (p *fakePool) url() string { return "stratum+tcp://" + p.ln.Addr().String() }

func (p *fakePool) dropAll() {
	p.mu.Lock()
	defer p.mu.Unlock()
	for _, c := range p.conns {
		_ = c.Close()
	}
	p.conns = nil
}

func (p *fakePool) connections() int {
	p.mu.Lock()
	defer p.mu.Unlock()
	return len(p.conns)
}

func (p *fakePool) accept() {
	for n := 0; ; n++ {
		conn, err := p.ln.Accept()
		if err != nil {
			return
		}
		p.mu.Lock()
		p.conns = append(p.conns, conn)
		p.mu.Unlock()
		go p.serve(conn, p.extranonce1[min(n, len(p.extranonce1)-1)])
	}
}

func (p *fakePool) send(conn net.Conn, v any) {
	raw, err := json.Marshal(v)
	if err != nil {
		panic(err)
	}
	_, _ = conn.Write(append(raw, '\n'))
}

func (p *fakePool) serve(conn net.Conn, extranonce1 string) {
	scanner := bufio.NewScanner(conn)
	for scanner.Scan() {
		var req struct {
			ID     int               `json:"id"`
			Method string            `json:"method"`
			Params []json.RawMessage `json:"params"`
		}
		if err := json.Unmarshal(scanner.Bytes(), &req); err != nil {
			return
		}
		switch req.Method {
		case "mining.configure":
			p.send(conn, map[string]any{"id": req.ID, "result": map[string]any{"version-rolling": true, "version-rolling.mask": "1fffe000"}, "error": nil})
		case "mining.subscribe":
			p.send(conn, map[string]any{"id": req.ID, "result": []any{[]any{}, extranonce1, p.size}, "error": nil})
		case "mining.authorize":
			var worker string
			_ = json.Unmarshal(req.Params[0], &worker)
			p.mu.Lock()
			p.worker = worker
			p.mu.Unlock()
			p.send(conn, map[string]any{"id": req.ID, "result": true, "error": nil})
			p.send(conn, map[string]any{"id": nil, "method": "mining.set_difficulty", "params": []any{p.difficulty}})
			p.send(conn, map[string]any{"id": nil, "method": "mining.notify", "params": []any{
				"up-" + extranonce1,
				strings.Repeat("ab", 32),
				"01000000010000000000000000000000000000000000000000000000000000000000000000ffffffff2003f4010004",
				"ffffffff0100f2052a01000000160014000000000000000000000000000000000000000000000000",
				[]string{},
				"20000000",
				"207fffff",
				fmt.Sprintf("%08x", time.Now().Add(-time.Minute).Unix()),
				true,
			}})
		case "mining.submit":
			if p.silent {
				continue
			}
			params := make([]string, len(req.Params))
			for i, raw := range req.Params {
				_ = json.Unmarshal(raw, &params[i])
			}
			p.mu.Lock()
			p.submits = append(p.submits, params)
			accept := len(p.submits) != 2
			p.mu.Unlock()
			if accept {
				p.send(conn, map[string]any{"id": req.ID, "result": true, "error": nil})
			} else {
				p.send(conn, map[string]any{"id": req.ID, "result": nil, "error": []any{23, "low difficulty share", nil}})
			}
		}
	}
}

func TestPoolRelay(t *testing.T) {
	pool := startFakePool(t, "aabbccdd", "11223344")
	source, err := stratum.NewPoolSource(pool.url(), "bc1qpayout", "x", zerolog.Nop())
	require.NoError(t, err)
	server, addr, _ := serve(t, source)
	require.Eventually(t, source.Connected, 5*time.Second, 10*time.Millisecond)
	assert.Equal(t, pool.ln.Addr().String(), source.Host())

	miner := dialMiner(t, addr)
	miner.start("avalon.1")
	// Upstream extranonce1, then this miner's prefix inside the extranonce2.
	assert.Equal(t, []byte{0xaa, 0xbb, 0xcc, 0xdd, 0, 0, 0, 0}, miner.extranonce1)
	assert.Equal(t, 4, miner.extranonce2Size)

	j := parseJob(t, miner.next("mining.notify"))
	assert.Equal(t, 1e-9, miner.difficulty)

	const versionBits = 0x00002000
	first := grind(t, miner, j, []byte{1, 2, 3, 4}, versionBits, miner.difficulty)
	reply := miner.submit("avalon.1", j, first, versionBits)
	require.Equal(t, "true", string(reply.Result))

	second := grind(t, miner, j, []byte{5, 6, 7, 8}, 0, miner.difficulty)
	reply = miner.submit("avalon.1", j, second, 0)
	assert.JSONEq(t, `[23, "low difficulty share", null]`, string(reply.Error))

	pool.mu.Lock()
	submits := pool.submits
	worker := pool.worker
	pool.mu.Unlock()
	assert.Equal(t, "bc1qpayout", worker)
	require.Len(t, submits, 2)
	assert.Equal(t, []string{
		"bc1qpayout",
		"up-aabbccdd",
		"0000000001020304",
		fmt.Sprintf("%08x", j.ntime),
		fmt.Sprintf("%08x", first.header.Nonce),
		"00002000",
	}, submits[0])

	status := server.Status()
	assert.Equal(t, uint64(1), status.Accepted)
	assert.Equal(t, uint64(1), status.Rejected)
	require.Len(t, status.Miners, 1)
	assert.Equal(t, uint64(1), status.Miners[0].Accepted)
	assert.Equal(t, uint64(1), status.Miners[0].Rejected)

	t.Run("a lost pool connection comes back", func(t *testing.T) {
		pool.dropAll()
		// The new upstream extranonce1 changes every miner's, so the server
		// drops them and they reconnect.
		_, err := miner.read()
		require.Error(t, err)
		assert.True(t, source.Connected())
		assert.Equal(t, 1, pool.connections())

		again := dialMiner(t, addr)
		again.start("avalon.1")
		assert.Equal(t, []byte{0x11, 0x22, 0x33, 0x44, 0, 0, 0, 0}, again.extranonce1)
		j := parseJob(t, again.next("mining.notify"))
		share := grind(t, again, j, []byte{9, 9, 9, 9}, 0, again.difficulty)
		reply := again.submit("avalon.1", j, share, 0)
		require.Equal(t, "true", string(reply.Result))

		pool.mu.Lock()
		last := pool.submits[len(pool.submits)-1]
		pool.mu.Unlock()
		assert.Equal(t, "up-11223344", last[1])
		assert.Equal(t, "0000000009090909", last[2])
	})
}

func TestSetSourceMovesMiners(t *testing.T) {
	node := &fakeNode{template: segwitTemplate(t, 500, nil), got: make(chan struct{}, 4)}
	solo, err := stratum.NewSoloSource(context.Background(), node, zerolog.Nop())
	require.NoError(t, err)
	server, addr, _ := serve(t, solo)

	miner := dialMiner(t, addr)
	miner.start("avalon.1")
	j := parseJob(t, miner.next("mining.notify"))
	assert.Len(t, miner.extranonce1, 4)
	share := grind(t, miner, j, make([]byte, 8), 0, miner.difficulty)
	require.Equal(t, "true", string(miner.submit("avalon.1", j, share, 0).Result))
	require.Positive(t, server.Status().BestShare)

	pool := startFakePool(t, "aabbccdd")
	source, err := stratum.NewPoolSource(pool.url(), "bc1qpayout", "x", zerolog.Nop())
	require.NoError(t, err)
	server.SetSource(source)

	_, err = miner.read()
	require.Error(t, err)

	require.Eventually(t, func() bool { return server.Status().NetworkDifficulty > 0 }, 5*time.Second, 10*time.Millisecond)
	assert.Zero(t, server.Status().BestShare)
	moved := dialMiner(t, addr)
	moved.start("avalon.1")
	assert.Equal(t, []byte{0xaa, 0xbb, 0xcc, 0xdd, 0, 0, 0, 0}, moved.extranonce1)
	j = parseJob(t, moved.next("mining.notify"))
	assert.Equal(t, uint32(0x207fffff), j.bits)
	assert.Equal(t, 1e-9, moved.difficulty)
}

func TestClosedConnectionsGiveTheirPrefixBack(t *testing.T) {
	// A two-byte pool extranonce2 leaves one prefix byte, so 256 miners at most.
	pool := startFakePoolSized(t, 2, "aabbccdd")
	source, err := stratum.NewPoolSource(pool.url(), "bc1qpayout", "x", zerolog.Nop())
	require.NoError(t, err)
	server, addr, _ := serve(t, source)
	require.Eventually(t, func() bool { return server.Status().NetworkDifficulty > 0 }, 5*time.Second, 10*time.Millisecond)

	for range 300 {
		miner := dialMiner(t, addr)
		reply := miner.call("mining.subscribe", "test-miner/1.0")
		require.Equal(t, "null", string(reply.Error))
		require.NoError(t, miner.conn.Close())
	}
}

func TestAPoolThatStopsAnsweringIsDialedAgain(t *testing.T) {
	pool := startFakePool(t, "aabbccdd")
	pool.silent = true
	source, err := stratum.NewPoolSource(pool.url(), "bc1qpayout", "x", zerolog.Nop())
	require.NoError(t, err)
	server, addr, _ := serve(t, source)
	require.Eventually(t, func() bool { return server.Status().NetworkDifficulty > 0 }, 5*time.Second, 10*time.Millisecond)

	miner := dialMiner(t, addr)
	miner.start("avalon.1")
	j := parseJob(t, miner.next("mining.notify"))
	share := grind(t, miner, j, []byte{1, 2, 3, 4}, 0, miner.difficulty)
	reply := miner.submit("avalon.1", j, share, 0)
	assert.Contains(t, string(reply.Error), "did not answer")

	require.Eventually(t, func() bool { return pool.connections() == 2 && source.Connected() }, 10*time.Second, 20*time.Millisecond)
}
