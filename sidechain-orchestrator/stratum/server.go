package stratum

import (
	"bufio"
	"bytes"
	"cmp"
	"context"
	"encoding/binary"
	"encoding/hex"
	"encoding/json"
	"errors"
	"fmt"
	"math"
	"net"
	"slices"
	"strconv"
	"sync"
	"time"

	"github.com/btcsuite/btcd/blockchain"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/rs/zerolog"
)

const (
	maxJobs     = 16
	maxLineSize = 16 * 1024
	outboxSize  = 64
	// handshakeTimeout closes a connection that does not subscribe and
	// authorize in time. A started miner may send no share for a long time.
	handshakeTimeout  = 2 * time.Minute
	writeTimeout      = 10 * time.Second
	maxFutureNtime    = 2 * time.Hour
	retargetCheck     = 15 * time.Second
	submitTimeout     = 30 * time.Second
	subscriptionLabel = "bitwindow"
	// maxRecentShares is how many accepted shares the server keeps for the
	// recent shares list.
	maxRecentShares = 200
)

// Server serves work from one Source to Stratum v1 miners.
type Server struct {
	log zerolog.Logger

	mu         sync.Mutex
	ctx        context.Context
	stop       context.CancelCauseFunc
	source     Source
	sourceStop context.CancelFunc
	sourceDone chan struct{}
	layout     *layout
	jobs       map[string]*job
	jobOrder   []string
	current    *job
	jobSeq     uint64
	sessions   map[*session]struct{}
	prefixes   map[uint64]struct{}
	nextPrefix uint64
	best       float64
	bestWon    bool
	accepted   uint64
	rejected   uint64
	blocks     []Block
	shares     []AcceptedShare
	cpuWanted  bool
	cpuThreads int
	cpu        *cpuRun
}

// layout is how the extranonce space of the current work divides between
// connections.
type layout struct {
	extranonce1 []byte
	prefixSize  int
	minerSize   int
	mask        uint32
}

func layoutOf(w *Work) (layout, error) {
	prefix, miner, err := splitExtranonce(w.ExtranonceSize)
	if err != nil {
		return layout{}, err
	}
	return layout{extranonce1: w.Extranonce1, prefixSize: prefix, minerSize: miner, mask: w.VersionMask}, nil
}

func (l layout) equal(o layout) bool {
	return bytes.Equal(l.extranonce1, o.extranonce1) && l.prefixSize == o.prefixSize &&
		l.minerSize == o.minerSize && l.mask == o.mask
}

type job struct {
	id     string
	work   *Work
	source Source
	seen   map[string]struct{}
}

type session struct {
	conn net.Conn
	ip   string
	out  chan []byte

	subscribed   bool
	authorized   bool
	started      bool
	layout       *layout
	prefixNumber uint64
	prefix       []byte
	extranonce1  []byte
	worker       string
	mask         uint32
	difficulty   float64
	// floor is the lowest difficulty this session gets. The hasher on this
	// computer needs a lower one than an ASIC.
	floor float64
	// jobDifficulty is the difficulty in force when each job went out. A
	// share for that job needs only that difficulty.
	jobDifficulty map[string]float64
	// aliases are the job ids this session alone got, for work it already
	// holds, after its difficulty went up.
	aliases        map[string]*job
	suggested      float64
	connected      time.Time
	retargetAt     time.Time
	retargetShares int
	accepted       uint64
	rejected       uint64
	best           float64
	lastShare      time.Time
	samples        []shareSample
}

// send queues a line. A miner too slow to take its lines loses the connection.
func (sess *session) send(line []byte) {
	select {
	case sess.out <- line:
	default:
		_ = sess.conn.Close()
	}
}

func NewServer(source Source, log zerolog.Logger) *Server {
	return &Server{
		log:      log,
		source:   source,
		jobs:     map[string]*job{},
		sessions: map[*session]struct{}{},
		prefixes: map[uint64]struct{}{},
	}
}

// Serve accepts miners on ln until ctx ends or the source fails.
func (s *Server) Serve(ctx context.Context, ln net.Listener) error {
	ctx, stop := context.WithCancelCause(ctx)
	defer stop(nil)

	s.mu.Lock()
	s.ctx, s.stop = ctx, stop
	s.startSourceLocked(s.source)
	if s.cpuWanted {
		s.startCPULocked()
	}
	s.mu.Unlock()

	var wg sync.WaitGroup
	wg.Add(2)
	go func() {
		defer wg.Done()
		for {
			conn, err := ln.Accept()
			if err != nil {
				if ctx.Err() == nil {
					stop(fmt.Errorf("accept: %w", err))
				}
				return
			}
			wg.Add(1)
			go func() {
				defer wg.Done()
				s.serveConn(ctx, conn, false)
			}()
		}
	}()
	go func() {
		defer wg.Done()
		s.retargetLoop(ctx)
	}()

	<-ctx.Done()
	closeErr := ln.Close()
	s.stopCPU()
	s.mu.Lock()
	s.dropSessionsLocked()
	sourceStop, sourceDone := s.sourceStop, s.sourceDone
	s.mu.Unlock()
	sourceStop()
	<-sourceDone
	wg.Wait()

	if err := context.Cause(ctx); err != nil && !errors.Is(err, context.Canceled) {
		return err
	}
	if closeErr != nil && !errors.Is(closeErr, net.ErrClosed) {
		return fmt.Errorf("close listener: %w", closeErr)
	}
	return nil
}

// SetSource moves every miner to new work. Miners reconnect, because the new
// source divides the extranonce space its own way.
func (s *Server) SetSource(source Source) {
	s.mu.Lock()
	stop, done := s.sourceStop, s.sourceDone
	s.source = source
	s.mu.Unlock()
	if stop != nil {
		stop()
		<-done
	}

	s.mu.Lock()
	defer s.mu.Unlock()
	s.dropSessionsLocked()
	s.layout, s.current = nil, nil
	s.prefixes, s.nextPrefix = map[uint64]struct{}{}, 0
	s.jobs, s.jobOrder = map[string]*job{}, nil
	s.accepted, s.rejected, s.best, s.shares = 0, 0, 0, nil
	s.bestWon = false
	if s.ctx != nil && s.ctx.Err() == nil {
		s.startSourceLocked(source)
	}
}

func (s *Server) startSourceLocked(source Source) {
	ctx, cancel := context.WithCancel(s.ctx)
	done := make(chan struct{})
	s.sourceStop, s.sourceDone = cancel, done
	stop := s.stop
	go func() {
		defer close(done)
		err := source.Run(ctx, func(w *Work) { s.publish(source, w) })
		if err != nil && ctx.Err() == nil {
			stop(fmt.Errorf("work source: %w", err))
		}
	}()
}

func (s *Server) dropSessionsLocked() {
	for sess := range s.sessions {
		_ = sess.conn.Close()
	}
}

func (s *Server) publish(source Source, w *Work) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if source != s.source {
		return
	}
	l, err := layoutOf(w)
	if err != nil {
		s.stop(err)
		return
	}
	if s.layout == nil || !s.layout.equal(l) {
		s.dropSessionsLocked()
		s.layout = &l
		s.prefixes, s.nextPrefix = map[uint64]struct{}{}, 0
		s.jobs, s.jobOrder = map[string]*job{}, nil
	}
	if w.Clean {
		s.jobs, s.jobOrder = map[string]*job{}, nil
	}

	s.jobSeq++
	j := &job{id: strconv.FormatUint(s.jobSeq, 16), work: w, source: source, seen: map[string]struct{}{}}
	s.jobs[j.id] = j
	s.jobOrder = append(s.jobOrder, j.id)
	if len(s.jobOrder) > maxJobs {
		delete(s.jobs, s.jobOrder[0])
		s.jobOrder = s.jobOrder[1:]
	}
	s.current = j

	notify, err := notificationLine("mining.notify", notifyParams(j.id, w, w.Clean))
	if err != nil {
		s.stop(fmt.Errorf("encode notify: %w", err))
		return
	}
	for sess := range s.sessions {
		if !sess.started {
			continue
		}
		s.setDifficultyLocked(sess, s.difficultyFor(sess, sess.difficulty, w))
		for id, base := range sess.aliases {
			if s.jobs[base.id] != base {
				delete(sess.aliases, id)
			}
		}
		for id := range sess.jobDifficulty {
			if _, ok := s.jobs[id]; !ok && sess.aliases[id] == nil {
				delete(sess.jobDifficulty, id)
			}
		}
		sess.jobDifficulty[j.id] = sess.difficulty
		sess.send(notify)
	}
}

func (s *Server) difficultyFor(sess *session, want float64, w *Work) float64 {
	if w.Relay {
		return w.Difficulty
	}
	return clampDifficulty(want, sess.floor, NetworkDifficulty(w.Bits))
}

func (s *Server) setDifficultyLocked(sess *session, d float64) {
	if d == sess.difficulty {
		return
	}
	line, err := notificationLine("mining.set_difficulty", []any{d})
	if err != nil {
		_ = sess.conn.Close()
		return
	}
	sess.difficulty = d
	sess.send(line)
}

func (s *Server) retargetLoop(ctx context.Context) {
	ticker := time.NewTicker(retargetCheck)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case now := <-ticker.C:
			s.mu.Lock()
			for sess := range s.sessions {
				if sess.started && dueForRetarget(sess.retargetShares, now.Sub(sess.retargetAt)) {
					s.retargetLocked(sess, now)
				}
			}
			s.mu.Unlock()
		}
	}
}

func (s *Server) retargetLocked(sess *session, now time.Time) {
	if s.current == nil || s.current.work.Relay {
		return
	}
	next := retarget(sess.difficulty, sess.retargetShares, now.Sub(sess.retargetAt))
	sess.retargetAt, sess.retargetShares = now, 0
	before := sess.difficulty
	s.setDifficultyLocked(sess, s.difficultyFor(sess, next, s.current.work))
	if sess.difficulty > before {
		s.renotifyLocked(sess)
	}
}

// renotifyLocked sends the current work again under a new job id, so a miner
// that applies a new difficulty from its next job moves to it at once.
func (s *Server) renotifyLocked(sess *session) {
	s.jobSeq++
	id := strconv.FormatUint(s.jobSeq, 16)
	notify, err := notificationLine("mining.notify", notifyParams(id, s.current.work, false))
	if err != nil {
		_ = sess.conn.Close()
		return
	}
	sess.aliases[id] = s.current
	sess.jobDifficulty[id] = sess.difficulty
	sess.send(notify)
}

// serveConn runs one miner. The local hasher gets its own address and its own
// difficulty floor.
func (s *Server) serveConn(ctx context.Context, conn net.Conn, local bool) {
	ip, floor := CPUAddress, float64(cpuMinDifficulty)
	if !local {
		ip, floor = conn.RemoteAddr().String(), float64(minDifficulty)
		if host, _, err := net.SplitHostPort(ip); err == nil {
			ip = host
		}
	}
	sess := &session{conn: conn, ip: ip, floor: floor, out: make(chan []byte, outboxSize), connected: time.Now()}

	s.mu.Lock()
	if s.layout == nil {
		s.mu.Unlock()
		_ = conn.Close()
		return
	}
	s.sessions[sess] = struct{}{}
	s.mu.Unlock()

	writerDone := make(chan struct{})
	go func() {
		defer close(writerDone)
		for line := range sess.out {
			if err := conn.SetWriteDeadline(time.Now().Add(writeTimeout)); err != nil {
				_ = conn.Close()
				continue
			}
			if _, err := conn.Write(line); err != nil {
				_ = conn.Close()
			}
		}
	}()
	defer func() {
		s.mu.Lock()
		delete(s.sessions, sess)
		if sess.subscribed && sess.layout == s.layout {
			delete(s.prefixes, sess.prefixNumber)
		}
		s.mu.Unlock()
		close(sess.out)
		<-writerDone
		_ = conn.Close()
	}()

	scanner := bufio.NewScanner(conn)
	scanner.Buffer(make([]byte, 0, 4096), maxLineSize)
	for {
		s.mu.Lock()
		deadline := time.Time{}
		if !sess.started {
			deadline = sess.connected.Add(handshakeTimeout)
		}
		s.mu.Unlock()
		if err := conn.SetReadDeadline(deadline); err != nil {
			return
		}
		if !scanner.Scan() {
			return
		}
		line := bytes.TrimSpace(scanner.Bytes())
		if len(line) == 0 {
			continue
		}
		var msg message
		if err := json.Unmarshal(line, &msg); err != nil {
			s.log.Debug().Str("miner", ip).Err(err).Msg("stratum: drop a miner that sent bad JSON")
			return
		}
		s.handle(ctx, sess, msg)
	}
}

func (s *Server) handle(ctx context.Context, sess *session, msg message) {
	switch msg.Method {
	case "mining.configure":
		result, err := s.configure(sess, msg.Params)
		s.reply(sess, msg.ID, result, err)
	case "mining.subscribe":
		s.mu.Lock()
		result, err := s.subscribeLocked(sess)
		s.replyLocked(sess, msg.ID, result, err)
		s.startLocked(sess)
		s.mu.Unlock()
	case "mining.authorize":
		params, err := stringParams(msg.Params)
		s.mu.Lock()
		if err != nil || len(params) == 0 {
			s.replyLocked(sess, msg.ID, nil, rejectf(codeOther, "authorize needs a worker name"))
		} else {
			sess.worker, sess.authorized = params[0], true
			s.replyLocked(sess, msg.ID, true, nil)
			s.startLocked(sess)
		}
		s.mu.Unlock()
	case "mining.suggest_difficulty":
		d, err := parseDifficulty(msg.Params)
		s.mu.Lock()
		if err == nil {
			sess.suggested = d
			if sess.started && s.current != nil {
				before := sess.difficulty
				s.setDifficultyLocked(sess, s.difficultyFor(sess, d, s.current.work))
				if sess.difficulty > before {
					s.renotifyLocked(sess)
				}
			}
		}
		if !isNull(msg.ID) {
			if err != nil {
				s.replyLocked(sess, msg.ID, nil, rejectf(codeOther, "%v", err))
			} else {
				s.replyLocked(sess, msg.ID, true, nil)
			}
		}
		s.mu.Unlock()
	case "mining.extranonce.subscribe":
		s.reply(sess, msg.ID, true, nil)
	case "mining.submit":
		s.submit(ctx, sess, msg)
	default:
		if !isNull(msg.ID) {
			s.reply(sess, msg.ID, nil, rejectf(codeOther, "unknown method %q", msg.Method))
		}
	}
}

func isNull(id json.RawMessage) bool {
	return len(id) == 0 || string(id) == "null"
}

func (s *Server) reply(sess *session, id json.RawMessage, result any, err *stratumError) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.replyLocked(sess, id, result, err)
}

func (s *Server) replyLocked(sess *session, id json.RawMessage, result any, err *stratumError) {
	line, encErr := responseLine(id, result, err)
	if encErr != nil {
		_ = sess.conn.Close()
		return
	}
	sess.send(line)
}

func (s *Server) configure(sess *session, raw json.RawMessage) (any, *stratumError) {
	var params []json.RawMessage
	if err := json.Unmarshal(raw, &params); err != nil || len(params) == 0 {
		return nil, rejectf(codeOther, "configure needs a list of extensions")
	}
	var names []string
	if err := json.Unmarshal(params[0], &names); err != nil {
		return nil, rejectf(codeOther, "configure extensions are not a list of names")
	}
	options := map[string]any{}
	if len(params) > 1 {
		if err := json.Unmarshal(params[1], &options); err != nil {
			return nil, rejectf(codeOther, "configure options are not an object")
		}
	}

	s.mu.Lock()
	defer s.mu.Unlock()
	result := map[string]any{}
	for _, name := range names {
		if name != "version-rolling" {
			result[name] = false
			continue
		}
		requested := uint32(math.MaxUint32)
		if text, ok := options["version-rolling.mask"].(string); ok {
			parsed, err := strconv.ParseUint(text, 16, 32)
			if err != nil {
				return nil, rejectf(codeOther, "version-rolling.mask %q is not hex", text)
			}
			requested = uint32(parsed)
		}
		var mask uint32
		if s.layout != nil {
			mask = s.layout.mask & requested
		}
		sess.mask = mask
		result["version-rolling"] = mask != 0
		result["version-rolling.mask"] = fmt.Sprintf("%08x", mask)
	}
	return result, nil
}

func (s *Server) subscribeLocked(sess *session) (any, *stratumError) {
	if s.layout == nil {
		return nil, rejectf(codeOther, "no work to give out yet")
	}
	if !sess.subscribed {
		number, ok := s.claimPrefixLocked()
		if !ok {
			return nil, rejectf(codeOther, "every extranonce prefix is in use")
		}
		prefix := make([]byte, 8)
		binary.BigEndian.PutUint64(prefix, number)
		sess.layout, sess.prefixNumber = s.layout, number
		sess.prefix = prefix[8-s.layout.prefixSize:]
		sess.extranonce1 = append(bytes.Clone(s.layout.extranonce1), sess.prefix...)
		sess.subscribed = true
	}
	return []any{
		[]any{
			[]string{"mining.set_difficulty", subscriptionLabel},
			[]string{"mining.notify", subscriptionLabel},
		},
		hex.EncodeToString(sess.extranonce1),
		s.layout.minerSize,
	}, nil
}

// claimPrefixLocked takes a free extranonce prefix. A closed connection
// gives its prefix back.
func (s *Server) claimPrefixLocked() (uint64, bool) {
	space := uint64(1) << (8 * s.layout.prefixSize)
	if uint64(len(s.prefixes)) >= space {
		return 0, false
	}
	for {
		number := s.nextPrefix % space
		s.nextPrefix++
		if _, used := s.prefixes[number]; !used {
			s.prefixes[number] = struct{}{}
			return number, true
		}
	}
}

// startLocked sends the first difficulty and job once a miner has subscribed
// and authorized.
func (s *Server) startLocked(sess *session) {
	if sess.started || !sess.subscribed || !sess.authorized || s.current == nil {
		return
	}
	now := time.Now()
	sess.started = true
	sess.retargetAt = now
	want := float64(startDifficulty)
	if sess.suggested > 0 {
		want = sess.suggested
	}
	d := s.difficultyFor(sess, want, s.current.work)
	line, err := notificationLine("mining.set_difficulty", []any{d})
	if err != nil {
		_ = sess.conn.Close()
		return
	}
	sess.difficulty = d
	sess.jobDifficulty = map[string]float64{s.current.id: d}
	sess.aliases = map[string]*job{}
	sess.send(line)
	notify, err := notificationLine("mining.notify", notifyParams(s.current.id, s.current.work, true))
	if err != nil {
		_ = sess.conn.Close()
		return
	}
	sess.send(notify)
}

// shareCheck is a share that passed every check the server makes itself.
type shareCheck struct {
	work       *Work
	source     Source
	share      Share
	difficulty float64
	// credit is the difficulty the share had to reach.
	credit float64
	hash   chainhash.Hash
	// won is true when the hash meets the network target of the job.
	won bool
	// block is true when this server must send the share to its own node.
	block bool
}

// AcceptedShare is one share the server took.
type AcceptedShare struct {
	At     time.Time
	Worker string
	// Target is the difficulty the share had to reach, Actual the one it
	// reached.
	Target float64
	Actual float64
	Hash   chainhash.Hash
	Block  bool
}

func (s *Server) submit(ctx context.Context, sess *session, msg message) {
	s.mu.Lock()
	checked, rejected := s.checkShareLocked(sess, msg.Params, time.Now())
	if rejected != nil {
		sess.rejected++
		s.rejected++
		s.replyLocked(sess, msg.ID, nil, rejected)
		s.mu.Unlock()
		return
	}
	relay := checked.work.Relay
	if !relay {
		s.acceptLocked(sess, checked, time.Now())
		s.replyLocked(sess, msg.ID, true, nil)
	}
	s.mu.Unlock()

	if !relay && !checked.block {
		return
	}
	submitCtx, cancel := context.WithTimeout(ctx, submitTimeout)
	defer cancel()
	block, err := checked.source.Submit(submitCtx, checked.work, checked.share)

	s.mu.Lock()
	defer s.mu.Unlock()
	if relay {
		if err != nil {
			sess.rejected++
			s.rejected++
			var rej *stratumError
			if !errors.As(err, &rej) {
				rej = rejectf(codeOther, "%v", err)
			}
			s.replyLocked(sess, msg.ID, nil, rej)
			return
		}
		s.acceptLocked(sess, checked, time.Now())
		s.replyLocked(sess, msg.ID, true, nil)
	}
	if err != nil {
		s.log.Error().Err(err).Str("worker", sess.worker).Msg("stratum: submit a block")
		return
	}
	if block != nil {
		block.FoundAt = time.Now()
		s.blocks = append([]Block{*block}, s.blocks...)
		s.log.Info().Uint32("height", block.Height).Stringer("hash", block.Hash).Str("worker", block.Worker).Msg("stratum: block found")
	}
}

func (s *Server) acceptLocked(sess *session, checked shareCheck, now time.Time) {
	difficulty := checked.difficulty
	sess.accepted++
	s.accepted++
	sess.best = math.Max(sess.best, difficulty)
	if difficulty >= s.best {
		s.best, s.bestWon = difficulty, checked.won
	}
	sess.lastShare = now
	sess.samples = append(pruneSamples(sess.samples, now), shareSample{at: now, difficulty: checked.credit})
	s.shares = append(s.shares, AcceptedShare{
		At:     now,
		Worker: sess.worker,
		Target: checked.credit,
		Actual: difficulty,
		Hash:   checked.hash,
		Block:  checked.won,
	})
	if len(s.shares) > maxRecentShares {
		s.shares = s.shares[len(s.shares)-maxRecentShares:]
	}
	if checked.credit >= sess.difficulty {
		sess.retargetShares++
	}
	if dueForRetarget(sess.retargetShares, now.Sub(sess.retargetAt)) {
		s.retargetLocked(sess, now)
	}
}

func (s *Server) checkShareLocked(sess *session, raw json.RawMessage, now time.Time) (shareCheck, *stratumError) {
	if !sess.subscribed {
		return shareCheck{}, rejectf(codeNotSubscribe, "not subscribed")
	}
	if !sess.authorized {
		return shareCheck{}, rejectf(codeUnauthorized, "unauthorized worker")
	}
	params, err := stringParams(raw)
	if err != nil || len(params) < 5 {
		return shareCheck{}, rejectf(codeOther, "submit needs five params")
	}
	j, ok := s.jobs[params[1]]
	if !ok {
		j, ok = sess.aliases[params[1]]
	}
	if !ok {
		return shareCheck{}, rejectf(codeJobNotFound, "job not found")
	}
	w := j.work
	extranonce2, err := hex.DecodeString(params[2])
	if err != nil || len(extranonce2) != s.layout.minerSize {
		return shareCheck{}, rejectf(codeOther, "extranonce2 must be %d bytes", s.layout.minerSize)
	}
	ntime, err := parseHex32(params[3])
	if err != nil {
		return shareCheck{}, rejectf(codeOther, "ntime: %v", err)
	}
	if ntime < w.Time || int64(ntime) > now.Add(maxFutureNtime).Unix() {
		return shareCheck{}, rejectf(codeOther, "ntime out of range")
	}
	nonce, err := parseHex32(params[4])
	if err != nil {
		return shareCheck{}, rejectf(codeOther, "nonce: %v", err)
	}
	version := w.Version
	var bits uint32
	rolled := len(params) > 5 && params[5] != ""
	if rolled {
		bits, err = parseHex32(params[5])
		if err != nil {
			return shareCheck{}, rejectf(codeOther, "version bits: %v", err)
		}
		version, err = rollVersion(w.Version, bits, sess.mask)
		if err != nil {
			return shareCheck{}, rejectf(codeOther, "%v", err)
		}
	}

	key := string(sess.extranonce1) + string(extranonce2) + params[3] + params[4] + strconv.FormatUint(uint64(bits), 16)
	if _, dup := j.seen[key]; dup {
		return shareCheck{}, rejectf(codeDuplicate, "duplicate share")
	}

	coinbase, header := solve(w, sess.extranonce1, extranonce2, ntime, nonce, version)
	hash := header.BlockHash()
	difficulty := hashDifficulty(hash)
	required := sess.difficulty
	if sent, ok := sess.jobDifficulty[params[1]]; ok {
		required = math.Min(required, sent)
	}
	if w.Relay {
		required = w.Difficulty
	}
	if difficulty < required {
		return shareCheck{}, rejectf(codeLowDiff, "low difficulty share")
	}
	j.seen[key] = struct{}{}

	value := blockchain.HashToBig(&hash)
	won := value.Cmp(blockchain.CompactToBig(w.Bits)) <= 0
	return shareCheck{
		work:   w,
		source: j.source,
		share: Share{
			Worker:      sess.worker,
			Header:      header,
			Coinbase:    coinbase,
			Extranonce2: append(bytes.Clone(sess.prefix), extranonce2...),
			VersionBits: bits,
			Rolled:      rolled,
		},
		difficulty: difficulty,
		credit:     required,
		hash:       hash,
		won:        won,
		block:      !w.Relay && value.Cmp(w.Target) <= 0,
	}, nil
}

// MinerStatus describes one connected miner.
type MinerStatus struct {
	Worker    string
	Address   string
	Hashrate  float64
	BestShare float64
	Accepted  uint64
	Rejected  uint64
	LastShare time.Time
}

// Status is a snapshot of the server.
type Status struct {
	Hashrate  float64
	BestShare float64
	// BestShareWon is true when the best share met the target of its own job.
	BestShareWon      bool
	NetworkDifficulty float64
	Accepted          uint64
	Rejected          uint64
	Miners            []MinerStatus
	Blocks            []Block
	// Shares are the last accepted shares, newest first.
	Shares []AcceptedShare
}

func (s *Server) Status() Status {
	s.mu.Lock()
	defer s.mu.Unlock()
	now := time.Now()
	status := Status{
		BestShare:    s.best,
		BestShareWon: s.bestWon,
		Accepted:     s.accepted,
		Rejected:     s.rejected,
		Blocks:       append([]Block(nil), s.blocks...),
		Shares:       newestFirst(s.shares),
	}
	if s.current != nil {
		status.NetworkDifficulty = NetworkDifficulty(s.current.work.Bits)
	}
	for sess := range s.sessions {
		if !sess.started {
			continue
		}
		rate := hashrate(sess.samples, sess.connected, now)
		status.Hashrate += rate
		status.Miners = append(status.Miners, MinerStatus{
			Worker:    sess.worker,
			Address:   sess.ip,
			Hashrate:  rate,
			BestShare: sess.best,
			Accepted:  sess.accepted,
			Rejected:  sess.rejected,
			LastShare: sess.lastShare,
		})
	}
	slices.SortFunc(status.Miners, func(a, b MinerStatus) int {
		return cmp.Or(cmp.Compare(a.Address, b.Address), cmp.Compare(a.Worker, b.Worker))
	})
	return status
}

func newestFirst(shares []AcceptedShare) []AcceptedShare {
	out := make([]AcceptedShare, len(shares))
	for i, share := range shares {
		out[len(shares)-1-i] = share
	}
	return out
}
