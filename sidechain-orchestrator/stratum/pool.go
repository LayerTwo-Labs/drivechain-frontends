package stratum

import (
	"bufio"
	"bytes"
	"context"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"net"
	"net/url"
	"strconv"
	"sync"
	"sync/atomic"
	"time"

	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/rs/zerolog"
)

const (
	poolDialTimeout = 10 * time.Second
	poolCallTimeout = 10 * time.Second
	minBackoff      = time.Second
	maxBackoff      = 30 * time.Second
	userAgent       = "bitwindow-stratum/1.0"
)

var errNoAnswer = errors.New("the pool did not answer")

// ParsePoolURL returns the host:port of a stratum+tcp URL.
func ParsePoolURL(raw string) (string, error) {
	u, err := url.Parse(raw)
	if err != nil {
		return "", fmt.Errorf("pool URL %q: %w", raw, err)
	}
	if u.Scheme != "stratum+tcp" {
		return "", fmt.Errorf("pool URL %q must start with stratum+tcp://", raw)
	}
	host, port, err := net.SplitHostPort(u.Host)
	if err != nil || host == "" || port == "" {
		return "", fmt.Errorf("pool URL %q needs a host and a port", raw)
	}
	return u.Host, nil
}

// PoolSource relays work between the miners and one upstream pool. Each miner
// gets its own prefix inside the pool's extranonce2.
type PoolSource struct {
	host     string
	worker   string
	password string
	log      zerolog.Logger

	mu   sync.Mutex
	conn *upstreamConn
}

func NewPoolSource(poolURL, worker, password string, log zerolog.Logger) (*PoolSource, error) {
	host, err := ParsePoolURL(poolURL)
	if err != nil {
		return nil, err
	}
	if worker == "" {
		return nil, fmt.Errorf("a pool needs a worker name")
	}
	return &PoolSource{host: host, worker: worker, password: password, log: log}, nil
}

func (p *PoolSource) Host() string { return p.host }

func (p *PoolSource) Connected() bool {
	p.mu.Lock()
	defer p.mu.Unlock()
	return p.conn != nil
}

func (p *PoolSource) Run(ctx context.Context, publish func(*Work)) error {
	backoff := minBackoff
	for {
		ready, err := p.session(ctx, publish)
		if ctx.Err() != nil {
			return ctx.Err()
		}
		if ready {
			backoff = minBackoff
		}
		p.log.Warn().Err(err).Str("pool", p.host).Dur("retry_in", backoff).Msg("stratum: pool connection lost")
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-time.After(backoff):
		}
		backoff = min(backoff*2, maxBackoff)
	}
}

// session holds one connection to the pool until it fails. ready reports
// whether the pool accepted the worker first.
func (p *PoolSource) session(ctx context.Context, publish func(*Work)) (ready bool, err error) {
	dialer := net.Dialer{Timeout: poolDialTimeout}
	conn, err := dialer.DialContext(ctx, "tcp", p.host)
	if err != nil {
		return false, fmt.Errorf("dial pool: %w", err)
	}
	uc := newUpstreamConn(conn)
	defer uc.close()
	go uc.read()
	stopOnCancel := context.AfterFunc(ctx, uc.close)
	defer stopOnCancel()

	if err := uc.handshake(ctx, p.worker, p.password); err != nil {
		return false, err
	}
	p.mu.Lock()
	p.conn = uc
	p.mu.Unlock()
	defer func() {
		p.mu.Lock()
		p.conn = nil
		p.mu.Unlock()
	}()
	p.log.Info().Str("pool", p.host).Str("worker", p.worker).Msg("stratum: pool connected")

	for {
		select {
		case <-uc.done:
			return true, uc.err()
		case note := <-uc.notes:
			if err := uc.apply(note, publish); err != nil {
				return true, err
			}
		}
	}
}

func (p *PoolSource) Submit(ctx context.Context, w *Work, s Share) (*Block, error) {
	p.mu.Lock()
	uc := p.conn
	p.mu.Unlock()
	if uc == nil || uc != w.upstream {
		return nil, rejectf(codeJobNotFound, "the pool connection for this job closed")
	}
	params := []any{
		p.worker,
		w.upstreamJobID,
		hex.EncodeToString(s.Extranonce2),
		fmt.Sprintf("%08x", uint32(s.Header.Timestamp.Unix())),
		fmt.Sprintf("%08x", s.Header.Nonce),
	}
	if s.Rolled {
		params = append(params, fmt.Sprintf("%08x", s.VersionBits))
	}
	result, err := uc.call(ctx, "mining.submit", params)
	if errors.Is(err, errNoAnswer) {
		uc.close()
	}
	if err != nil {
		return nil, err
	}
	var accepted bool
	if err := json.Unmarshal(result, &accepted); err != nil || !accepted {
		return nil, rejectf(codeOther, "the pool rejected the share")
	}
	return nil, nil
}

type upstreamConn struct {
	conn    net.Conn
	writeMu sync.Mutex
	nextID  atomic.Int64

	pendingMu sync.Mutex
	pending   map[int64]chan message

	notes     chan message
	done      chan struct{}
	closeOnce sync.Once
	readErr   error

	extranonce1     []byte
	extranonce2Size int
	mask            uint32
	difficulty      float64
}

func newUpstreamConn(conn net.Conn) *upstreamConn {
	return &upstreamConn{
		conn:       conn,
		pending:    map[int64]chan message{},
		notes:      make(chan message, 256),
		done:       make(chan struct{}),
		difficulty: 1,
	}
}

func (uc *upstreamConn) close() {
	uc.closeOnce.Do(func() {
		_ = uc.conn.Close()
	})
}

func (uc *upstreamConn) err() error {
	if uc.readErr != nil {
		return uc.readErr
	}
	return errors.New("the pool closed the connection")
}

func (uc *upstreamConn) read() {
	defer close(uc.done)
	defer uc.close()
	scanner := bufio.NewScanner(uc.conn)
	scanner.Buffer(make([]byte, 0, 4096), 1024*1024)
	for scanner.Scan() {
		line := bytes.TrimSpace(scanner.Bytes())
		if len(line) == 0 {
			continue
		}
		var msg message
		if err := json.Unmarshal(line, &msg); err != nil {
			uc.readErr = fmt.Errorf("the pool sent bad JSON: %w", err)
			return
		}
		if msg.Method != "" {
			select {
			case uc.notes <- msg:
			default:
				uc.readErr = errors.New("the pool sent notifications faster than they apply")
				return
			}
			continue
		}
		var id int64
		if err := json.Unmarshal(msg.ID, &id); err != nil {
			continue
		}
		uc.pendingMu.Lock()
		ch, ok := uc.pending[id]
		delete(uc.pending, id)
		uc.pendingMu.Unlock()
		if ok {
			ch <- msg
		}
	}
	uc.readErr = scanner.Err()
}

func (uc *upstreamConn) call(ctx context.Context, method string, params []any) (json.RawMessage, error) {
	id := uc.nextID.Add(1)
	ch := make(chan message, 1)
	uc.pendingMu.Lock()
	uc.pending[id] = ch
	uc.pendingMu.Unlock()
	defer func() {
		uc.pendingMu.Lock()
		delete(uc.pending, id)
		uc.pendingMu.Unlock()
	}()

	line, err := encodeLine(map[string]any{"id": id, "method": method, "params": params})
	if err != nil {
		return nil, err
	}
	uc.writeMu.Lock()
	err = uc.conn.SetWriteDeadline(time.Now().Add(poolCallTimeout))
	if err == nil {
		_, err = uc.conn.Write(line)
	}
	uc.writeMu.Unlock()
	if err != nil {
		uc.close()
		return nil, fmt.Errorf("send %s: %w", method, err)
	}

	timer := time.NewTimer(poolCallTimeout)
	defer timer.Stop()
	select {
	case msg := <-ch:
		if err := replyError(msg.Error); err != nil {
			return nil, err
		}
		return msg.Result, nil
	case <-timer.C:
		return nil, fmt.Errorf("%s: %w", method, errNoAnswer)
	case <-uc.done:
		return nil, fmt.Errorf("%s: %w", method, uc.err())
	case <-ctx.Done():
		return nil, ctx.Err()
	}
}

func (uc *upstreamConn) handshake(ctx context.Context, worker, password string) error {
	result, err := uc.call(ctx, "mining.configure", []any{
		[]string{"version-rolling"},
		map[string]any{"version-rolling.mask": fmt.Sprintf("%08x", VersionMask), "version-rolling.min-bit-count": 2},
	})
	var rejected *stratumError
	switch {
	case errors.As(err, &rejected), errors.Is(err, errNoAnswer):
		uc.mask = 0
	case err != nil:
		return err
	default:
		uc.mask = configuredMask(result)
	}

	result, err = uc.call(ctx, "mining.subscribe", []any{userAgent})
	if err != nil {
		return err
	}
	uc.extranonce1, uc.extranonce2Size, err = parseSubscribe(result)
	if err != nil {
		return err
	}

	result, err = uc.call(ctx, "mining.authorize", []any{worker, password})
	if err != nil {
		return err
	}
	var authorized bool
	if err := json.Unmarshal(result, &authorized); err != nil || !authorized {
		return fmt.Errorf("the pool refused worker %q", worker)
	}
	return nil
}

func configuredMask(result json.RawMessage) uint32 {
	var reply map[string]any
	if err := json.Unmarshal(result, &reply); err != nil {
		return 0
	}
	if on, _ := reply["version-rolling"].(bool); !on {
		return 0
	}
	text, _ := reply["version-rolling.mask"].(string)
	mask, err := strconv.ParseUint(text, 16, 32)
	if err != nil {
		return 0
	}
	return uint32(mask) & VersionMask
}

func parseSubscribe(result json.RawMessage) ([]byte, int, error) {
	en1, size, err := parseExtranonce(result, 1)
	if err != nil {
		return nil, 0, fmt.Errorf("subscribe: %w", err)
	}
	return en1, size, nil
}

// parseExtranonce reads an extranonce1 and extranonce2 size that sit at
// index at and at+1 of a list.
func parseExtranonce(raw json.RawMessage, at int) ([]byte, int, error) {
	var list []json.RawMessage
	if err := json.Unmarshal(raw, &list); err != nil || len(list) < at+2 {
		return nil, 0, fmt.Errorf("bad extranonce reply %s", raw)
	}
	var en1Hex string
	var size int
	if err := json.Unmarshal(list[at], &en1Hex); err != nil {
		return nil, 0, fmt.Errorf("extranonce1: %w", err)
	}
	if err := json.Unmarshal(list[at+1], &size); err != nil {
		return nil, 0, fmt.Errorf("extranonce2 size: %w", err)
	}
	en1, err := hex.DecodeString(en1Hex)
	if err != nil {
		return nil, 0, fmt.Errorf("extranonce1 %q: %w", en1Hex, err)
	}
	return en1, size, nil
}

func (uc *upstreamConn) apply(note message, publish func(*Work)) error {
	switch note.Method {
	case "mining.set_difficulty":
		d, err := parseDifficulty(note.Params)
		if err != nil {
			return err
		}
		uc.difficulty = d
	case "mining.set_extranonce":
		en1, size, err := parseExtranonce(note.Params, 0)
		if err != nil {
			return fmt.Errorf("set_extranonce: %w", err)
		}
		uc.extranonce1, uc.extranonce2Size = en1, size
	case "mining.notify":
		w, err := uc.parseNotify(note.Params)
		if err != nil {
			return err
		}
		publish(w)
	case "client.reconnect":
		return errors.New("the pool asked for a reconnect")
	}
	return nil
}

func (uc *upstreamConn) parseNotify(raw json.RawMessage) (*Work, error) {
	var params []json.RawMessage
	if err := json.Unmarshal(raw, &params); err != nil || len(params) < 9 {
		return nil, fmt.Errorf("bad notify: %s", raw)
	}
	var jobID, prevHex, coinb1Hex, coinb2Hex, versionHex, bitsHex, timeHex string
	var branchHex []string
	var clean bool
	for i, target := range []any{&jobID, &prevHex, &coinb1Hex, &coinb2Hex, &branchHex, &versionHex, &bitsHex, &timeHex, &clean} {
		if err := json.Unmarshal(params[i], target); err != nil {
			return nil, fmt.Errorf("notify param %d: %w", i, err)
		}
	}
	prevBytes, err := hex.DecodeString(prevHex)
	if err != nil {
		return nil, fmt.Errorf("notify prevhash: %w", err)
	}
	prev, err := parseStratumPrevHash(prevBytes)
	if err != nil {
		return nil, err
	}
	coinb1, err := hex.DecodeString(coinb1Hex)
	if err != nil {
		return nil, fmt.Errorf("notify coinb1: %w", err)
	}
	coinb2, err := hex.DecodeString(coinb2Hex)
	if err != nil {
		return nil, fmt.Errorf("notify coinb2: %w", err)
	}
	branch := make([]chainhash.Hash, len(branchHex))
	for i, h := range branchHex {
		b, err := hex.DecodeString(h)
		if err != nil || len(b) != chainhash.HashSize {
			return nil, fmt.Errorf("notify merkle branch %d: %q", i, h)
		}
		copy(branch[i][:], b)
	}
	version, err := parseHex32(versionHex)
	if err != nil {
		return nil, fmt.Errorf("notify version: %w", err)
	}
	bits, err := parseHex32(bitsHex)
	if err != nil {
		return nil, fmt.Errorf("notify nbits: %w", err)
	}
	ntime, err := parseHex32(timeHex)
	if err != nil {
		return nil, fmt.Errorf("notify ntime: %w", err)
	}
	return &Work{
		PrevHash:       prev,
		Coinb1:         coinb1,
		Coinb2:         coinb2,
		Extranonce1:    uc.extranonce1,
		ExtranonceSize: uc.extranonce2Size,
		Branch:         branch,
		Version:        int32(version),
		Bits:           bits,
		Time:           ntime,
		VersionMask:    uc.mask,
		Clean:          clean,
		Relay:          true,
		Difficulty:     uc.difficulty,
		Target:         targetOf(uc.difficulty),
		upstreamJobID:  jobID,
		upstream:       uc,
	}, nil
}
