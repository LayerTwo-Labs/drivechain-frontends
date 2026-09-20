package stratum

import (
	"bufio"
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/binary"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"math"
	"math/big"
	"net"
	"runtime"
	"sync"
	"sync/atomic"
	"time"

	"github.com/btcsuite/btcd/blockchain"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/wire"
	"github.com/rs/zerolog"
)

const (
	// CPUWorker is the worker name the hasher on this computer authorizes with.
	CPUWorker = "cpu"
	// CPUAddress stands in for the IP address of a miner on the network.
	CPUAddress = "this computer"

	// cpuStartDifficulty is low, because one processor needs many minutes for
	// a share at the difficulty an ASIC starts on.
	cpuStartDifficulty = 1.0 / 1024
	cpuMinDifficulty   = 1.0 / 1048576
	// cpuRetry is the wait before the hasher connects again. A target change
	// drops every miner, the hasher too.
	cpuRetry = 2 * time.Second
	// scanStep is how many nonces a thread hashes before it looks for new work.
	scanStep = 1 << 14
	// idleWait is how long a thread waits when the server sent no job yet.
	idleWait = 100 * time.Millisecond
)

// CPUThreads returns the default number of hash threads: half the processors,
// so the rest of the machine keeps the other half.
func CPUThreads() int {
	return max(1, runtime.NumCPU()/2)
}

type cpuRun struct {
	cancel  context.CancelFunc
	done    chan struct{}
	threads int
}

// SetCPU starts or stops the hasher on this computer. The hasher connects as
// a Stratum miner, so it mines to the same target as every other miner. A
// thread count of zero or less takes the default.
func (s *Server) SetCPU(on bool, threads int) {
	if threads <= 0 {
		threads = CPUThreads()
	}
	s.mu.Lock()
	if on == s.cpuWanted && threads == s.cpuThreads {
		s.mu.Unlock()
		return
	}
	restart := s.cpuWanted && s.cpu != nil
	s.cpuWanted, s.cpuThreads = on, threads
	s.mu.Unlock()
	if restart {
		s.stopCPU()
	}

	s.mu.Lock()
	defer s.mu.Unlock()
	if on && s.ctx != nil && s.ctx.Err() == nil {
		s.startCPULocked()
	}
}

// CPUOn reports whether the hasher on this computer runs, and how many
// threads it runs.
func (s *Server) CPUOn() (bool, int) {
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.cpuWanted, s.cpuThreads
}

func (s *Server) startCPULocked() {
	ctx, cancel := context.WithCancel(s.ctx)
	run := &cpuRun{cancel: cancel, done: make(chan struct{}), threads: s.cpuThreads}
	s.cpu = run
	go func() {
		defer close(run.done)
		s.runCPU(ctx, run.threads)
	}()
}

func (s *Server) stopCPU() {
	s.mu.Lock()
	run := s.cpu
	s.cpu = nil
	s.mu.Unlock()
	if run == nil {
		return
	}
	run.cancel()
	<-run.done
}

func (s *Server) runCPU(ctx context.Context, threads int) {
	for ctx.Err() == nil {
		s.cpuSession(ctx, threads)
		select {
		case <-ctx.Done():
		case <-time.After(cpuRetry):
		}
	}
}

// cpuSession serves one connection between the hasher and this server. The
// two ends share a pipe, so the hasher reaches no port.
func (s *Server) cpuSession(ctx context.Context, threads int) {
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()
	local, remote := net.Pipe()
	go func() {
		<-ctx.Done()
		_ = local.Close()
		_ = remote.Close()
	}()

	var wg sync.WaitGroup
	wg.Add(1)
	go func() {
		defer wg.Done()
		defer cancel()
		if err := mineLocally(ctx, local, threads, s.log); err != nil && ctx.Err() == nil {
			s.log.Warn().Err(err).Msg("stratum: the hasher on this computer stopped")
		}
	}()
	s.serveConn(ctx, remote, true)
	cancel()
	wg.Wait()
}

// cpuJob is the work of one mining.notify.
type cpuJob struct {
	id       string
	prevHash chainhash.Hash
	coinb1   []byte
	coinb2   []byte
	branch   []chainhash.Hash
	version  int32
	bits     uint32
	ntime    uint32
}

// cpuHasher talks Stratum v1 to a server over conn and hashes the work it gets.
type cpuHasher struct {
	conn    net.Conn
	log     zerolog.Logger
	threads int

	writeMu sync.Mutex
	seq     atomic.Uint64

	mu          sync.Mutex
	extranonce1 []byte
	en2Size     int
	difficulty  float64
	job         *cpuJob
	generation  uint64
}

// mineLocally hashes for a server over conn until ctx ends or conn fails.
func mineLocally(ctx context.Context, conn net.Conn, threads int, log zerolog.Logger) error {
	h := &cpuHasher{conn: conn, log: log, threads: threads}
	return h.run(ctx)
}

func (h *cpuHasher) run(ctx context.Context) error {
	if err := h.write(1, "mining.subscribe", []any{"bitwindow-cpu"}); err != nil {
		return err
	}
	if err := h.write(2, "mining.suggest_difficulty", []any{cpuStartDifficulty}); err != nil {
		return err
	}
	if err := h.write(3, "mining.authorize", []any{CPUWorker, "x"}); err != nil {
		return err
	}

	// A server that drops this connection stops the threads too, so the
	// hasher connects again instead of hashing work nobody takes.
	ctx, cancel := context.WithCancel(ctx)
	var wg sync.WaitGroup
	defer wg.Wait()
	defer cancel()
	for i := 0; i < h.threads; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			h.grind(ctx)
		}()
	}
	return h.read()
}

func (h *cpuHasher) write(id any, method string, params []any) error {
	line, err := json.Marshal(map[string]any{"id": id, "method": method, "params": params})
	if err != nil {
		return err
	}
	h.writeMu.Lock()
	defer h.writeMu.Unlock()
	if _, err := h.conn.Write(append(line, '\n')); err != nil {
		return fmt.Errorf("write %s: %w", method, err)
	}
	return nil
}

func (h *cpuHasher) read() error {
	scanner := bufio.NewScanner(h.conn)
	scanner.Buffer(make([]byte, 0, 4096), maxLineSize)
	for scanner.Scan() {
		var msg message
		if err := json.Unmarshal(scanner.Bytes(), &msg); err != nil {
			return fmt.Errorf("decode %s: %w", scanner.Bytes(), err)
		}
		switch {
		case string(msg.ID) == "1":
			if err := h.subscribed(msg.Result); err != nil {
				return err
			}
		case msg.Method == "mining.set_difficulty":
			h.setDifficulty(msg.Params)
		case msg.Method == "mining.notify":
			if err := h.notified(msg.Params); err != nil {
				return err
			}
		}
	}
	return scanner.Err()
}

func (h *cpuHasher) subscribed(result json.RawMessage) error {
	var parts []json.RawMessage
	if err := json.Unmarshal(result, &parts); err != nil || len(parts) < 3 {
		return fmt.Errorf("the subscribe reply %s carries no extranonce", result)
	}
	var text string
	if err := json.Unmarshal(parts[1], &text); err != nil {
		return fmt.Errorf("extranonce1 %s: %w", parts[1], err)
	}
	extranonce1, err := hex.DecodeString(text)
	if err != nil {
		return fmt.Errorf("extranonce1 %q: %w", text, err)
	}
	var size int
	if err := json.Unmarshal(parts[2], &size); err != nil {
		return fmt.Errorf("extranonce2 size %s: %w", parts[2], err)
	}
	if size < 1 {
		return fmt.Errorf("the extranonce2 size is %d bytes", size)
	}
	h.mu.Lock()
	h.extranonce1, h.en2Size = extranonce1, size
	h.mu.Unlock()
	return nil
}

func (h *cpuHasher) setDifficulty(raw json.RawMessage) {
	d, err := parseDifficulty(raw)
	if err != nil {
		h.log.Debug().Err(err).Msg("stratum: the hasher got a difficulty it cannot read")
		return
	}
	h.mu.Lock()
	h.difficulty = d
	h.mu.Unlock()
}

func (h *cpuHasher) notified(raw json.RawMessage) error {
	job, err := parseNotify(raw)
	if err != nil {
		return err
	}
	h.mu.Lock()
	h.job = job
	h.generation++
	h.mu.Unlock()
	return nil
}

func parseNotify(raw json.RawMessage) (*cpuJob, error) {
	var params []json.RawMessage
	if err := json.Unmarshal(raw, &params); err != nil || len(params) < 8 {
		return nil, fmt.Errorf("notify needs eight params, got %s", raw)
	}
	var id, prevText, coinb1Text, coinb2Text, versionText, bitsText, ntimeText string
	var branchText []string
	targets := []any{&id, &prevText, &coinb1Text, &coinb2Text, &branchText, &versionText, &bitsText, &ntimeText}
	for i, target := range targets {
		if err := json.Unmarshal(params[i], target); err != nil {
			return nil, fmt.Errorf("notify param %d: %w", i, err)
		}
	}

	prevWords, err := hex.DecodeString(prevText)
	if err != nil {
		return nil, fmt.Errorf("prevhash %q: %w", prevText, err)
	}
	prev, err := parseStratumPrevHash(prevWords)
	if err != nil {
		return nil, err
	}
	coinb1, err := hex.DecodeString(coinb1Text)
	if err != nil {
		return nil, fmt.Errorf("coinb1: %w", err)
	}
	coinb2, err := hex.DecodeString(coinb2Text)
	if err != nil {
		return nil, fmt.Errorf("coinb2: %w", err)
	}
	branch := make([]chainhash.Hash, 0, len(branchText))
	for _, text := range branchText {
		b, err := hex.DecodeString(text)
		if err != nil || len(b) != chainhash.HashSize {
			return nil, fmt.Errorf("merkle branch entry %q", text)
		}
		branch = append(branch, chainhash.Hash(b))
	}
	version, err := parseHex32(versionText)
	if err != nil {
		return nil, fmt.Errorf("version: %w", err)
	}
	bits, err := parseHex32(bitsText)
	if err != nil {
		return nil, fmt.Errorf("bits: %w", err)
	}
	ntime, err := parseHex32(ntimeText)
	if err != nil {
		return nil, fmt.Errorf("ntime: %w", err)
	}
	return &cpuJob{
		id:       id,
		prevHash: prev,
		coinb1:   coinb1,
		coinb2:   coinb2,
		branch:   branch,
		version:  int32(version),
		bits:     bits,
		ntime:    ntime,
	}, nil
}

// snapshot returns the work a thread hashes. ok is false before the first job.
func (h *cpuHasher) snapshot() (job *cpuJob, extranonce1 []byte, en2Size int, difficulty float64, generation uint64, ok bool) {
	h.mu.Lock()
	defer h.mu.Unlock()
	if h.job == nil || h.extranonce1 == nil || h.difficulty <= 0 {
		return nil, nil, 0, 0, 0, false
	}
	return h.job, h.extranonce1, h.en2Size, h.difficulty, h.generation, true
}

func (h *cpuHasher) currentGeneration() uint64 {
	h.mu.Lock()
	defer h.mu.Unlock()
	return h.generation
}

func (h *cpuHasher) grind(ctx context.Context) {
	for ctx.Err() == nil {
		job, extranonce1, en2Size, difficulty, generation, ok := h.snapshot()
		if !ok {
			select {
			case <-ctx.Done():
			case <-time.After(idleWait):
			}
			continue
		}
		extranonce2 := encodeExtranonce2(h.seq.Add(1), en2Size)
		if err := h.scan(ctx, job, extranonce1, extranonce2, difficulty, generation); err != nil {
			if ctx.Err() == nil {
				h.log.Debug().Err(err).Msg("stratum: the hasher could not send a share")
			}
			return
		}
	}
}

// scan hashes one extranonce2 over the nonce space. It stops at the first
// share, and at every new job.
func (h *cpuHasher) scan(
	ctx context.Context, job *cpuJob, extranonce1, extranonce2 []byte, difficulty float64, generation uint64,
) error {
	var buf bytes.Buffer
	header := cpuHeader(job, extranonce1, extranonce2)
	if err := header.Serialize(&buf); err != nil {
		return err
	}
	data := buf.Bytes()
	target := targetOf(difficulty)

	for nonce := uint64(0); nonce <= math.MaxUint32; nonce++ {
		if nonce%scanStep == 0 && (ctx.Err() != nil || h.currentGeneration() != generation) {
			return nil
		}
		binary.LittleEndian.PutUint32(data[76:], uint32(nonce))
		if !meetsTarget(data, target) {
			continue
		}
		return h.submit(job, extranonce2, uint32(nonce))
	}
	return nil
}

func meetsTarget(header []byte, target *big.Int) bool {
	first := sha256.Sum256(header)
	hash := chainhash.Hash(sha256.Sum256(first[:]))
	return blockchain.HashToBig(&hash).Cmp(target) <= 0
}

func (h *cpuHasher) submit(job *cpuJob, extranonce2 []byte, nonce uint32) error {
	return h.write(0, "mining.submit", []any{
		CPUWorker,
		job.id,
		hex.EncodeToString(extranonce2),
		fmt.Sprintf("%08x", job.ntime),
		fmt.Sprintf("%08x", nonce),
	})
}

func cpuHeader(job *cpuJob, extranonce1, extranonce2 []byte) wire.BlockHeader {
	coinbase := make([]byte, 0, len(job.coinb1)+len(extranonce1)+len(extranonce2)+len(job.coinb2))
	coinbase = append(coinbase, job.coinb1...)
	coinbase = append(coinbase, extranonce1...)
	coinbase = append(coinbase, extranonce2...)
	coinbase = append(coinbase, job.coinb2...)
	return wire.BlockHeader{
		Version:    job.version,
		PrevBlock:  job.prevHash,
		MerkleRoot: merkleRoot(doubleSHA256(coinbase), job.branch),
		Timestamp:  time.Unix(int64(job.ntime), 0),
		Bits:       job.bits,
	}
}

// encodeExtranonce2 writes n into the last bytes of a size-byte extranonce2.
func encodeExtranonce2(n uint64, size int) []byte {
	full := make([]byte, 8)
	binary.BigEndian.PutUint64(full, n)
	out := make([]byte, size)
	copy(out[max(0, size-8):], full[max(0, 8-size):])
	return out
}
