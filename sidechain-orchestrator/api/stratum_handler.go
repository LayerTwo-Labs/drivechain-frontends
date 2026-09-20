package api

import (
	"cmp"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"math"
	"net"
	"net/http"
	"path/filepath"
	"strconv"
	"strings"
	"sync"
	"time"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"
	"google.golang.org/protobuf/types/known/timestamppb"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/cgminer"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/enforcerproxy"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/stratum/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/stratum/v1/stratumv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/stratum"
)

var _ stratumv1connect.StratumServiceHandler = (*StratumHandler)(nil)

const (
	defaultStratumPort        = 3333
	devicePoll                = 10 * time.Second
	deviceTimeout             = 3 * time.Second
	poolStatsTimeout          = 3 * time.Second
	poolStatsTTL              = time.Minute
	targetSolo                = "solo"
	targetPool                = "pool"
	targetCustom              = "custom"
	catalogPoolWorkerPassword = "x"
	maxCPUThreads             = 256
	defaultPoolBlocks         = 20
	hashrateSample            = 10 * time.Second
	historyFlush              = time.Minute
	// networkHashrateKey holds the network hashrate in the stats cache. It is
	// no URL, so no pool can take it.
	networkHashrateKey = "network"
	// poolBlocksTTL is how long a pool block list stands. Every row costs one
	// verbose block read from the node, and the page polls every two seconds.
	poolBlocksTTL = time.Minute
)

// StratumNetwork is what the Stratum handler reads about the running network.
type StratumNetwork interface {
	CurrentNetwork() string
	RunningCatalogEntry() (netcatalog.Network, bool)
}

// StratumSettingsStore persists the work target and the mining settings.
type StratumSettingsStore interface {
	StratumSettings() orchestrator.StratumSettings
	SetStratumSettings(orchestrator.StratumSettings) error
}

// HoldDaemon keeps the daemon alive until the returned function runs. The
// miners outlive the app window, and the daemon lease counts no miner.
type HoldDaemon func() func()

// StratumDeps are the parts of the daemon the Stratum handler drives.
type StratumDeps struct {
	Network  StratumNetwork
	Settings StratumSettingsStore
	// PayoutAddress is the wallet address a mined block pays. The enforcer
	// builds every coinbase to it.
	PayoutAddress func(context.Context) (string, error)
	Core          CoreRawCaller
	// HistoryPath is the file the hashrate history reads and writes.
	HistoryPath string
	// HoldDaemon keeps the daemon alive while the miners must keep going.
	HoldDaemon HoldDaemon
	Log        zerolog.Logger
}

// StratumHandler runs the Stratum server for miners on the local network. The
// server lives on the daemon context, so it keeps running with no client.
type StratumHandler struct {
	ctx        context.Context
	network    StratumNetwork
	settings   StratumSettingsStore
	payout     func(context.Context) (string, error)
	core       CoreRawCaller
	holdDaemon HoldDaemon
	history    *stratum.History
	log        zerolog.Logger

	newNode    func() (stratum.Node, error)
	listen     func(port uint32) (net.Listener, error)
	readDevice func(ctx context.Context, ip string) (cgminer.Device, error)
	setMode    func(ctx context.Context, ip string, mode cgminer.WorkMode) error
	httpClient *http.Client

	statsMu sync.Mutex
	stats   map[string]poolStatsEntry

	blocksMu    sync.Mutex
	blocks20    *pb.ListPoolBlocksResponse
	blocksAt    time.Time
	blocksLimit uint32

	// opMu makes Start, Stop and SetTarget run one at a time. mu guards the
	// fields below and is never held across network calls.
	opMu    sync.Mutex
	mu      sync.Mutex
	run     *stratumRun
	lastErr string
	blocks  []stratum.Block
	release func()
}

type stratumRun struct {
	server *stratum.Server
	port   uint32
	cancel context.CancelFunc
	done   chan struct{}
	pool   *stratum.PoolSource

	devicesMu sync.Mutex
	devices   map[string]cgminer.Device
}

func NewStratumHandler(ctx context.Context, deps StratumDeps) *StratumHandler {
	h := &StratumHandler{
		ctx:        ctx,
		network:    deps.Network,
		settings:   deps.Settings,
		payout:     deps.PayoutAddress,
		core:       deps.Core,
		holdDaemon: deps.HoldDaemon,
		history:    stratum.NewHistory(deps.HistoryPath),
		log:        deps.Log,
		newNode: func() (stratum.Node, error) {
			return stratum.NewEnforcerNode(enforcerproxy.DefaultJSONRPCAddr)
		},
		listen: func(port uint32) (net.Listener, error) {
			return net.Listen("tcp", net.JoinHostPort("0.0.0.0", strconv.FormatUint(uint64(port), 10)))
		},
		readDevice: func(ctx context.Context, ip string) (cgminer.Device, error) {
			return cgminer.ReadDevice(ctx, net.JoinHostPort(ip, cgminer.Port))
		},
		setMode: func(ctx context.Context, ip string, mode cgminer.WorkMode) error {
			return cgminer.SetWorkMode(ctx, net.JoinHostPort(ip, cgminer.Port), mode)
		},
		httpClient: &http.Client{Timeout: poolStatsTimeout},
		stats:      map[string]poolStatsEntry{},
	}
	go h.recordHashrate(ctx)
	return h
}

func (h *StratumHandler) mineable() error {
	current := h.network.CurrentNetwork()
	if network, ok := config.LookupNetwork(current); !ok || network != config.NetworkECash {
		return connect.NewError(connect.CodeFailedPrecondition,
			fmt.Errorf("mining is only available on eCash, not %s", cmp.Or(current, "an unknown network")))
	}
	return nil
}

func (h *StratumHandler) StartStratum(
	ctx context.Context, req *connect.Request[pb.StartStratumRequest],
) (*connect.Response[pb.StartStratumResponse], error) {
	if err := h.mineable(); err != nil {
		return nil, err
	}
	port := cmp.Or(req.Msg.Port, h.settings.StratumSettings().Port, defaultStratumPort)
	if port > 65535 {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("port %d is out of range", port))
	}

	h.opMu.Lock()
	defer h.opMu.Unlock()
	if err := h.start(ctx, port, h.settings.StratumSettings()); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.StartStratumResponse{}), nil
}

// start listens and serves miners under settings. The caller holds opMu.
func (h *StratumHandler) start(ctx context.Context, port uint32, settings orchestrator.StratumSettings) error {
	h.mu.Lock()
	running := h.run
	h.mu.Unlock()
	if running != nil {
		if running.port == port {
			return nil
		}
		return connect.NewError(connect.CodeFailedPrecondition,
			fmt.Errorf("the stratum server already runs on port %d", running.port))
	}

	ready, err := h.prepare(ctx, port, settings)
	if err != nil {
		return err
	}
	h.serve(ready, settings)
	return nil
}

// readyRun is a listener and a work source that a serve takes over.
type readyRun struct {
	listener net.Listener
	port     uint32
	source   stratum.Source
	pool     *stratum.PoolSource
}

// prepare builds everything a start can fail on. The caller holds opMu.
func (h *StratumHandler) prepare(
	ctx context.Context, port uint32, settings orchestrator.StratumSettings,
) (readyRun, error) {
	source, pool, err := h.sourceFor(ctx, settings)
	if err != nil {
		return readyRun{}, err
	}
	ln, err := h.listen(port)
	if err != nil {
		return readyRun{}, connect.NewError(connect.CodeUnavailable, fmt.Errorf("listen on port %d: %w", port, err))
	}
	return readyRun{listener: ln, port: port, source: source, pool: pool}, nil
}

// serve takes over a prepared listener. It cannot fail. The caller holds opMu.
func (h *StratumHandler) serve(ready readyRun, settings orchestrator.StratumSettings) {
	ln, port, source, pool := ready.listener, ready.port, ready.source, ready.pool

	server := stratum.NewServer(source, h.log)
	server.SetCPU(settings.CPUMining, int(settings.CPUThreads))
	runCtx, cancel := context.WithCancel(h.ctx)
	run := &stratumRun{server: server, port: port, cancel: cancel, done: make(chan struct{}), pool: pool}
	h.mu.Lock()
	h.run, h.lastErr, h.blocks = run, "", nil
	h.mu.Unlock()

	go func() {
		err := server.Serve(runCtx, ln)
		cancel()
		h.mu.Lock()
		if h.run == run {
			h.run = nil
			h.blocks = server.Status().Blocks
			if err != nil {
				h.lastErr = err.Error()
			}
		}
		h.mu.Unlock()
		close(run.done)
		h.applyHold()
		if err != nil {
			h.log.Error().Err(err).Msg("stratum server stopped")
		}
	}()
	go h.pollDevices(runCtx, run)
	h.applyHold()

	h.log.Info().Uint32("port", port).Msg("stratum server started")
}

func (h *StratumHandler) StopStratum(
	context.Context, *connect.Request[pb.StopStratumRequest],
) (*connect.Response[pb.StopStratumResponse], error) {
	h.Stop()
	return connect.NewResponse(&pb.StopStratumResponse{}), nil
}

// Reset stops the server and forgets its blocks and its hashrate history,
// which belong to the network that ran before. The history moves to the
// directory of the network that runs now.
func (h *StratumHandler) Reset(networkDir string) {
	h.Stop()
	h.mu.Lock()
	h.blocks, h.lastErr = nil, ""
	h.mu.Unlock()
	h.forgetPoolBlocks()
	h.statsMu.Lock()
	delete(h.stats, networkHashrateKey)
	h.statsMu.Unlock()
	h.history.Rebind(HashrateHistoryPath(networkDir))
}

// HashrateHistoryPath is the file the hashrate chart reads and writes.
func HashrateHistoryPath(networkDir string) string {
	return filepath.Join(networkDir, "hashrate_history.json")
}

// Stop stops the server and waits until every connection closes.
func (h *StratumHandler) Stop() {
	h.opMu.Lock()
	defer h.opMu.Unlock()
	h.stop()
}

// stop stops the server and waits. The caller holds opMu.
func (h *StratumHandler) stop() {
	h.mu.Lock()
	run := h.run
	h.mu.Unlock()
	if run == nil {
		return
	}
	run.cancel()
	<-run.done
	h.applyHold()
}

// sourceFor builds the work source a target needs. A solo source reads its
// first template here, so a node that serves none fails the call.
func (h *StratumHandler) sourceFor(ctx context.Context, s orchestrator.StratumSettings) (stratum.Source, *stratum.PoolSource, error) {
	switch s.Target {
	case "", targetSolo:
		node, err := h.newNode()
		if err != nil {
			return nil, nil, connect.NewError(connect.CodeInternal, err)
		}
		source, err := stratum.NewSoloSource(ctx, node, h.log)
		if err != nil {
			return nil, nil, connect.NewError(connect.CodeUnavailable, fmt.Errorf("read a block template: %w", err))
		}
		return source, nil, nil
	case targetPool:
		pool, ok := h.catalogPool(s.PoolID)
		if !ok {
			return nil, nil, connect.NewError(connect.CodeFailedPrecondition,
				fmt.Errorf("the running network lists no pool %q", s.PoolID))
		}
		address, err := h.payoutAddress(ctx)
		if err != nil {
			return nil, nil, err
		}
		source, err := stratum.NewPoolSource(pool.url, address, catalogPoolWorkerPassword, h.log)
		if err != nil {
			return nil, nil, connect.NewError(connect.CodeInvalidArgument, err)
		}
		return source, source, nil
	case targetCustom:
		source, err := stratum.NewPoolSource(s.URL, s.Worker, s.Password, h.log)
		if err != nil {
			return nil, nil, connect.NewError(connect.CodeInvalidArgument, err)
		}
		return source, source, nil
	}
	return nil, nil, connect.NewError(connect.CodeInternal, fmt.Errorf("unknown stratum target %q", s.Target))
}

type catalogPool struct {
	id, name, url, fee, statsURL string
}

// catalogPoolIdentity names a pool after the domain of its host:
// pool.beta.bip300.xyz is "bip300 pool".
func catalogPoolIdentity(poolURL string) (id, name string, err error) {
	hostport, err := stratum.ParsePoolURL(poolURL)
	if err != nil {
		return "", "", err
	}
	host, _, err := net.SplitHostPort(hostport)
	if err != nil {
		return "", "", err
	}
	labels := strings.Split(host, ".")
	if net.ParseIP(host) != nil || len(labels) < 2 {
		return host, host, nil
	}
	label := labels[len(labels)-2]
	return label, label + " pool", nil
}

func (h *StratumHandler) catalogPools() []catalogPool {
	entry, ok := h.network.RunningCatalogEntry()
	if !ok {
		return nil
	}
	published := entry.Services.MiningPool
	if published.Stratum == nil || *published.Stratum == "" {
		return nil
	}
	id, name, err := catalogPoolIdentity(*published.Stratum)
	if err != nil {
		h.log.Warn().Err(err).Str("url", *published.Stratum).Msg("the catalog pool URL does not parse")
		return nil
	}
	return []catalogPool{{
		id:       id,
		name:     cmp.Or(published.Name, name),
		url:      *published.Stratum,
		fee:      published.Fee,
		statsURL: published.StatsURL,
	}}
}

func (h *StratumHandler) catalogPool(id string) (catalogPool, bool) {
	for _, pool := range h.catalogPools() {
		if pool.id == id {
			return pool, true
		}
	}
	return catalogPool{}, false
}

func (h *StratumHandler) ListTargets(
	ctx context.Context, _ *connect.Request[pb.ListTargetsRequest],
) (*connect.Response[pb.ListTargetsResponse], error) {
	resp := &pb.ListTargetsResponse{}
	for _, pool := range h.catalogPools() {
		entry := &pb.CatalogPool{Id: pool.id, Name: pool.name, Url: pool.url, Fee: pool.fee}
		if hashrate, ok := h.poolHashrate(ctx, pool.statsURL); ok {
			entry.Hashrate = &hashrate
		}
		resp.Pools = append(resp.Pools, entry)
	}
	return connect.NewResponse(resp), nil
}

type poolStatsEntry struct {
	at       time.Time
	hashrate float64
	ok       bool
}

// parsePoolOverview reads the pool hashrate from a pool overview reply. ok is
// false for a shape it does not know.
func parsePoolOverview(body []byte) (hashrate float64, ok bool) {
	var overview struct {
		Hashrate5m *float64 `json:"hashrate_5m"`
	}
	if err := json.Unmarshal(body, &overview); err != nil || overview.Hashrate5m == nil || *overview.Hashrate5m < 0 {
		return 0, false
	}
	return *overview.Hashrate5m, true
}

// poolHashrate reads a pool's hashrate from its stats URL, at most once a
// minute. A pool that does not answer shows no hashrate.
func (h *StratumHandler) poolHashrate(ctx context.Context, statsURL string) (float64, bool) {
	if statsURL == "" {
		return 0, false
	}
	h.statsMu.Lock()
	cached, found := h.stats[statsURL]
	h.statsMu.Unlock()
	if found && time.Since(cached.at) < poolStatsTTL {
		return cached.hashrate, cached.ok
	}

	entry := poolStatsEntry{at: time.Now()}
	body, err := h.fetchPoolStats(ctx, statsURL)
	if err != nil {
		h.log.Debug().Err(err).Str("url", statsURL).Msg("stratum: the pool stats did not load")
	} else {
		entry.hashrate, entry.ok = parsePoolOverview(body)
	}
	h.statsMu.Lock()
	h.stats[statsURL] = entry
	h.statsMu.Unlock()
	return entry.hashrate, entry.ok
}

func (h *StratumHandler) fetchPoolStats(ctx context.Context, statsURL string) ([]byte, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, statsURL, nil)
	if err != nil {
		return nil, err
	}
	resp, err := h.httpClient.Do(req)
	if err != nil {
		return nil, err
	}
	defer func() { _ = resp.Body.Close() }()
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("status %s", resp.Status)
	}
	return io.ReadAll(io.LimitReader(resp.Body, 1<<20))
}

func (h *StratumHandler) SetTarget(
	ctx context.Context, req *connect.Request[pb.SetTargetRequest],
) (*connect.Response[pb.SetTargetResponse], error) {
	target := req.Msg.GetTarget()
	h.opMu.Lock()
	defer h.opMu.Unlock()

	next := h.settings.StratumSettings()
	switch target.GetKind() {
	case pb.TargetKind_TARGET_KIND_SOLO:
		next.Target = targetSolo
	case pb.TargetKind_TARGET_KIND_POOL:
		if _, ok := h.catalogPool(target.GetPoolId()); !ok {
			return nil, connect.NewError(connect.CodeInvalidArgument,
				fmt.Errorf("the running network lists no pool %q", target.GetPoolId()))
		}
		if _, err := h.payoutAddress(ctx); err != nil {
			return nil, err
		}
		next.Target, next.PoolID = targetPool, target.GetPoolId()
	case pb.TargetKind_TARGET_KIND_CUSTOM:
		if _, err := stratum.ParsePoolURL(target.GetUrl()); err != nil {
			return nil, connect.NewError(connect.CodeInvalidArgument, err)
		}
		if target.GetWorker() == "" {
			return nil, connect.NewError(connect.CodeInvalidArgument, errors.New("a custom pool needs a worker name"))
		}
		next.Target, next.URL, next.Worker, next.Password = targetCustom, target.GetUrl(), target.GetWorker(), target.GetPassword()
	default:
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("unknown target kind %s", target.GetKind()))
	}

	if next == h.settings.StratumSettings() {
		return connect.NewResponse(&pb.SetTargetResponse{}), nil
	}
	h.mu.Lock()
	run := h.run
	h.mu.Unlock()
	var source stratum.Source
	var pool *stratum.PoolSource
	if run != nil {
		var err error
		source, pool, err = h.sourceFor(ctx, next)
		if err != nil {
			return nil, err
		}
	}
	if err := h.settings.SetStratumSettings(next); err != nil {
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("save the stratum target: %w", err))
	}
	h.forgetPoolBlocks()
	if run != nil {
		run.server.SetSource(source)
		h.mu.Lock()
		run.pool = pool
		h.mu.Unlock()
	}
	return connect.NewResponse(&pb.SetTargetResponse{}), nil
}

func targetToProto(s orchestrator.StratumSettings) *pb.Target {
	switch s.Target {
	case targetPool:
		return &pb.Target{Kind: pb.TargetKind_TARGET_KIND_POOL, PoolId: s.PoolID}
	case targetCustom:
		return &pb.Target{Kind: pb.TargetKind_TARGET_KIND_CUSTOM, Url: s.URL, Worker: s.Worker, Password: s.Password}
	}
	return &pb.Target{Kind: pb.TargetKind_TARGET_KIND_SOLO}
}

func (h *StratumHandler) GetStratumStatus(
	ctx context.Context, _ *connect.Request[pb.GetStratumStatusRequest],
) (*connect.Response[pb.GetStratumStatusResponse], error) {
	h.mu.Lock()
	run, lastErr, blocks := h.run, h.lastErr, h.blocks
	var pool *stratum.PoolSource
	if run != nil {
		pool = run.pool
	}
	h.mu.Unlock()

	settings := h.settings.StratumSettings()
	resp := &pb.GetStratumStatusResponse{
		Error:    lastErr,
		Target:   targetToProto(settings),
		Settings: settingsToProto(settings),
	}
	if address, err := h.payoutAddress(ctx); err != nil {
		h.log.Debug().Err(err).Msg("stratum: no payout address yet")
	} else {
		resp.PayoutAddress = address
	}
	if run != nil {
		status := run.server.Status()
		blocks = status.Blocks
		resp.NetworkHashrate = h.networkHashrate(ctx)
		on, threads := run.server.CPUOn()
		resp.Settings.CpuMining = on
		resp.Settings.CpuThreads = uint32(threads)
		for _, share := range status.Shares {
			resp.RecentShares = append(resp.RecentShares, &pb.AcceptedShare{
				Time:   timestamppb.New(share.At),
				Worker: share.Worker,
				Target: share.Target,
				Actual: share.Actual,
				Hash:   share.Hash.String(),
				Block:  share.Block,
			})
		}
		resp.Running, resp.Port = true, run.port
		ip, ok, err := stratum.LANIPv4()
		if err != nil {
			return nil, connect.NewError(connect.CodeInternal, err)
		}
		if ok {
			resp.PoolUrl = fmt.Sprintf("stratum+tcp://%s", net.JoinHostPort(ip.String(), strconv.FormatUint(uint64(run.port), 10)))
		}
		resp.Hashrate = status.Hashrate
		resp.BestShare = status.BestShare
		resp.BestShareWon = status.BestShareWon
		resp.NetworkDifficulty = status.NetworkDifficulty
		resp.AcceptedShares = status.Accepted
		resp.RejectedShares = status.Rejected
		devices := run.deviceSnapshot()
		for _, m := range status.Miners {
			resp.Miners = append(resp.Miners, minerToProto(m, devices[m.Address]))
		}
		if pool != nil {
			resp.PoolConnected, resp.PoolHost = pool.Connected(), pool.Host()
		}
	}
	for _, b := range blocks {
		block := &pb.FoundBlock{
			Height:     b.Height,
			Hash:       b.Hash.String(),
			RewardSats: b.RewardSats,
			Worker:     b.Worker,
			FoundTime:  timestamppb.New(b.FoundAt),
		}
		confirmations, err := h.confirmations(ctx, b.Hash.String())
		if err != nil {
			h.log.Debug().Err(err).Stringer("block", b.Hash).Msg("stratum: the node did not give the confirmations")
		} else {
			block.Confirmations = &confirmations
		}
		resp.BlocksFound = append(resp.BlocksFound, block)
	}
	return connect.NewResponse(resp), nil
}

func (h *StratumHandler) confirmations(ctx context.Context, hash string) (int32, error) {
	if h.core == nil {
		return 0, errors.New("no bitcoind seam")
	}
	raw, err := h.core(ctx, "getblockheader", fmt.Sprintf("[%q]", hash), "")
	if err != nil {
		return 0, err
	}
	var header struct {
		Confirmations int32 `json:"confirmations"`
	}
	if err := json.Unmarshal(raw, &header); err != nil {
		return 0, fmt.Errorf("decode block header: %w", err)
	}
	return header.Confirmations, nil
}

func minerToProto(m stratum.MinerStatus, d cgminer.Device) *pb.ConnectedMiner {
	miner := &pb.ConnectedMiner{
		Worker:             m.Worker,
		Address:            m.Address,
		Hashrate:           m.Hashrate,
		BestShare:          m.BestShare,
		AcceptedShares:     m.Accepted,
		RejectedShares:     m.Rejected,
		TemperatureCelsius: d.TemperatureCelsius,
		FanPercent:         d.FanPercent,
		PowerWatts:         d.PowerWatts,
	}
	if !m.LastShare.IsZero() {
		miner.LastShareTime = timestamppb.New(m.LastShare)
	}
	if d.WorkMode != nil {
		miner.WorkMode = workModeToProto(*d.WorkMode)
	}
	return miner
}

func workModeToProto(m cgminer.WorkMode) pb.WorkMode {
	switch m {
	case cgminer.WorkModeLow:
		return pb.WorkMode_WORK_MODE_LOW
	case cgminer.WorkModeMid:
		return pb.WorkMode_WORK_MODE_MID
	case cgminer.WorkModeHigh:
		return pb.WorkMode_WORK_MODE_HIGH
	}
	return pb.WorkMode_WORK_MODE_UNSPECIFIED
}

func workModeFromProto(m pb.WorkMode) (cgminer.WorkMode, bool) {
	switch m {
	case pb.WorkMode_WORK_MODE_LOW:
		return cgminer.WorkModeLow, true
	case pb.WorkMode_WORK_MODE_MID:
		return cgminer.WorkModeMid, true
	case pb.WorkMode_WORK_MODE_HIGH:
		return cgminer.WorkModeHigh, true
	}
	return 0, false
}

func (h *StratumHandler) SetWorkMode(
	ctx context.Context, req *connect.Request[pb.SetWorkModeRequest],
) (*connect.Response[pb.SetWorkModeResponse], error) {
	mode, ok := workModeFromProto(req.Msg.Mode)
	if !ok {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("unknown work mode %s", req.Msg.Mode))
	}
	h.mu.Lock()
	run := h.run
	h.mu.Unlock()
	if run == nil || !hasMiner(run.server.Status().Miners, req.Msg.Address) {
		return nil, connect.NewError(connect.CodeNotFound, fmt.Errorf("no miner connects from %q", req.Msg.Address))
	}
	ctx, cancel := context.WithTimeout(ctx, deviceTimeout)
	defer cancel()
	if err := h.setMode(ctx, req.Msg.Address, mode); err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, fmt.Errorf("set the work mode of %s: %w", req.Msg.Address, err))
	}
	run.devicesMu.Lock()
	if d, ok := run.devices[req.Msg.Address]; ok {
		d.WorkMode = &mode
		run.devices[req.Msg.Address] = d
	}
	run.devicesMu.Unlock()
	return connect.NewResponse(&pb.SetWorkModeResponse{}), nil
}

func hasMiner(miners []stratum.MinerStatus, address string) bool {
	for _, m := range miners {
		if m.Address == address {
			return true
		}
	}
	return false
}

func (r *stratumRun) deviceSnapshot() map[string]cgminer.Device {
	r.devicesMu.Lock()
	defer r.devicesMu.Unlock()
	out := make(map[string]cgminer.Device, len(r.devices))
	for k, v := range r.devices {
		out[k] = v
	}
	return out
}

// pollDevices reads the device API of every connected miner. A miner that
// does not answer shows no device values.
func (h *StratumHandler) pollDevices(ctx context.Context, run *stratumRun) {
	ticker := time.NewTicker(devicePoll)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case <-ticker.C:
		}
		addresses := map[string]struct{}{}
		for _, m := range run.server.Status().Miners {
			addresses[m.Address] = struct{}{}
		}
		devices := map[string]cgminer.Device{}
		var mu sync.Mutex
		var wg sync.WaitGroup
		for address := range addresses {
			wg.Add(1)
			go func() {
				defer wg.Done()
				readCtx, cancel := context.WithTimeout(ctx, deviceTimeout)
				defer cancel()
				d, err := h.readDevice(readCtx, address)
				if err != nil {
					h.log.Debug().Err(err).Str("miner", address).Msg("stratum: the device API did not answer")
					return
				}
				mu.Lock()
				devices[address] = d
				mu.Unlock()
			}()
		}
		wg.Wait()
		run.devicesMu.Lock()
		run.devices = devices
		run.devicesMu.Unlock()
	}
}

// payoutAddress returns the wallet address a mined block pays. The daemon
// hands the enforcer the same address, and it builds every coinbase.
func (h *StratumHandler) payoutAddress(ctx context.Context) (string, error) {
	if h.payout == nil {
		return "", connect.NewError(connect.CodeFailedPrecondition, errors.New("no wallet to pay a block to"))
	}
	address, err := h.payout(ctx)
	if err != nil {
		return "", connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("get a payout address: %w", err))
	}
	return address, nil
}

func (h *StratumHandler) SetMiningSettings(
	ctx context.Context, req *connect.Request[pb.SetMiningSettingsRequest],
) (*connect.Response[pb.SetMiningSettingsResponse], error) {
	if req.Msg.Port != nil && (req.Msg.GetPort() < 1 || req.Msg.GetPort() > 65535) {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			fmt.Errorf("port %d is out of range", req.Msg.GetPort()))
	}
	if req.Msg.CpuThreads != nil && req.Msg.GetCpuThreads() > maxCPUThreads {
		return nil, connect.NewError(connect.CodeInvalidArgument,
			fmt.Errorf("a thread count of %d is over the limit of %d", req.Msg.GetCpuThreads(), maxCPUThreads))
	}

	h.opMu.Lock()
	defer h.opMu.Unlock()
	current := h.settings.StratumSettings()
	next := current
	if req.Msg.Port != nil {
		next.Port = req.Msg.GetPort()
	}
	if req.Msg.CpuMining != nil {
		next.CPUMining = req.Msg.GetCpuMining()
	}
	if req.Msg.CpuThreads != nil {
		next.CPUThreads = req.Msg.GetCpuThreads()
	}
	if req.Msg.KeepMiningOnClose != nil {
		next.KeepMiningOnClose = req.Msg.GetKeepMiningOnClose()
	}
	if next == current {
		return connect.NewResponse(&pb.SetMiningSettingsResponse{}), nil
	}
	if next.CPUMining {
		if err := h.mineable(); err != nil {
			return nil, err
		}
	}

	h.mu.Lock()
	run := h.run
	h.mu.Unlock()
	// The hasher needs a server. A switch on with none starts one, before the
	// save, so a start that fails leaves the switch off.
	if run == nil && next.CPUMining {
		if err := h.start(ctx, cmp.Or(next.Port, defaultStratumPort), next); err != nil {
			return nil, err
		}
		if err := h.settings.SetStratumSettings(next); err != nil {
			h.stop()
			return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("save the mining settings: %w", err))
		}
		return connect.NewResponse(&pb.SetMiningSettingsResponse{}), nil
	}

	// A running server listens on the port it started on, so a new port needs
	// a new listener. The new port binds first, so a bind that fails leaves
	// every miner on the old one.
	// A saved port of zero means the default, so compare the port the server
	// listens on, not the one the settings hold.
	port := cmp.Or(next.Port, defaultStratumPort)
	var ready readyRun
	rebind := run != nil && port != run.port
	if rebind {
		var err error
		ready, err = h.prepare(ctx, port, next)
		if err != nil {
			return nil, err
		}
	}
	if err := h.settings.SetStratumSettings(next); err != nil {
		if rebind {
			_ = ready.listener.Close()
		}
		return nil, connect.NewError(connect.CodeInternal, fmt.Errorf("save the mining settings: %w", err))
	}
	if rebind {
		h.stop()
		h.serve(ready, next)
		return connect.NewResponse(&pb.SetMiningSettingsResponse{}), nil
	}
	if run != nil {
		run.server.SetCPU(next.CPUMining, int(next.CPUThreads))
	}
	h.applyHold()
	return connect.NewResponse(&pb.SetMiningSettingsResponse{}), nil
}

func settingsToProto(s orchestrator.StratumSettings) *pb.MiningSettings {
	threads := s.CPUThreads
	if threads == 0 {
		threads = uint32(stratum.CPUThreads())
	}
	return &pb.MiningSettings{
		Port:              cmp.Or(s.Port, defaultStratumPort),
		CpuMining:         s.CPUMining,
		CpuThreads:        threads,
		KeepMiningOnClose: s.KeepMiningOnClose,
	}
}

// recordHashrate samples the total hashrate into the history and writes the
// buckets to the file.
func (h *StratumHandler) recordHashrate(ctx context.Context) {
	sample := time.NewTicker(hashrateSample)
	defer sample.Stop()
	flush := time.NewTicker(historyFlush)
	defer flush.Stop()
	for {
		select {
		case <-ctx.Done():
			if err := h.history.Flush(time.Now()); err != nil {
				h.log.Warn().Err(err).Msg("stratum: write the hashrate history")
			}
			return
		case now := <-sample.C:
			h.mu.Lock()
			run := h.run
			h.mu.Unlock()
			var rate float64
			if run != nil {
				rate = run.server.Status().Hashrate
			}
			h.history.Record(rate, now)
		case now := <-flush.C:
			if err := h.history.Flush(now); err != nil {
				h.log.Warn().Err(err).Msg("stratum: write the hashrate history")
			}
		}
	}
}

func rangeOf(r pb.HashrateRange) stratum.Range {
	switch r {
	case pb.HashrateRange_HASHRATE_RANGE_HOUR:
		return stratum.RangeHour
	case pb.HashrateRange_HASHRATE_RANGE_WEEK:
		return stratum.RangeWeek
	}
	return stratum.RangeDay
}

func (h *StratumHandler) GetHashrateHistory(
	_ context.Context, req *connect.Request[pb.GetHashrateHistoryRequest],
) (*connect.Response[pb.GetHashrateHistoryResponse], error) {
	points, peak := h.history.Read(rangeOf(req.Msg.GetRange()), time.Now())
	resp := &pb.GetHashrateHistoryResponse{Peak: peak}
	for _, p := range points {
		resp.Points = append(resp.Points, &pb.HashratePoint{Time: timestamppb.New(p.At), Hashrate: p.Hashrate})
	}
	h.mu.Lock()
	run := h.run
	h.mu.Unlock()
	if run != nil {
		resp.Current = run.server.Status().Hashrate
	}
	return connect.NewResponse(resp), nil
}

func (h *StratumHandler) ListPoolBlocks(
	ctx context.Context, req *connect.Request[pb.ListPoolBlocksRequest],
) (*connect.Response[pb.ListPoolBlocksResponse], error) {
	limit := cmp.Or(req.Msg.GetLimit(), defaultPoolBlocks)
	if cached := h.cachedPoolBlocks(limit); cached != nil {
		return connect.NewResponse(cached), nil
	}
	resp, err := h.readPoolBlocks(ctx, limit)
	if err != nil {
		return nil, err
	}
	h.keepPoolBlocks(limit, resp)
	return connect.NewResponse(resp), nil
}

// cachedPoolBlocks returns the last list while it still stands.
func (h *StratumHandler) cachedPoolBlocks(limit uint32) *pb.ListPoolBlocksResponse {
	h.blocksMu.Lock()
	defer h.blocksMu.Unlock()
	if h.blocks20 == nil || h.blocksLimit != limit || time.Since(h.blocksAt) >= poolBlocksTTL {
		return nil
	}
	return h.blocks20
}

func (h *StratumHandler) keepPoolBlocks(limit uint32, resp *pb.ListPoolBlocksResponse) {
	h.blocksMu.Lock()
	defer h.blocksMu.Unlock()
	h.blocks20, h.blocksLimit, h.blocksAt = resp, limit, time.Now()
}

// forgetPoolBlocks drops the cached list, which belongs to the pool or the
// network that ran before.
func (h *StratumHandler) forgetPoolBlocks() {
	h.blocksMu.Lock()
	defer h.blocksMu.Unlock()
	h.blocks20 = nil
}

func (h *StratumHandler) readPoolBlocks(ctx context.Context, limit uint32) (*pb.ListPoolBlocksResponse, error) {
	settings := h.settings.StratumSettings()
	if settings.Target != targetPool {
		return &pb.ListPoolBlocksResponse{
			Unavailable: "this list holds the blocks of a pool from the catalog only",
		}, nil
	}
	pool, ok := h.catalogPool(settings.PoolID)
	if !ok || pool.statsURL == "" {
		return &pb.ListPoolBlocksResponse{Unavailable: "this pool publishes no block list"}, nil
	}
	address, err := h.payoutAddress(ctx)
	if err != nil {
		return nil, err
	}
	blocksURL, err := stratum.PoolBlocksURL(pool.statsURL, int(limit))
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}
	blocks, err := stratum.FetchPoolBlocks(ctx, h.httpClient, blocksURL)
	if err != nil {
		h.log.Debug().Err(err).Str("url", blocksURL).Msg("stratum: the pool block list did not load")
		return &pb.ListPoolBlocksResponse{Unavailable: fmt.Sprintf("the pool did not answer: %v", err)}, nil
	}

	resp := &pb.ListPoolBlocksResponse{}
	for _, block := range blocks {
		row := &pb.PoolBlock{
			Height:     block.Height,
			Hash:       block.Hash,
			RewardSats: block.RewardSats,
			FeeSats:    block.FeeSats,
			Finder:     block.Finder,
			Mine:       finderIsOurs(block.Finder, address),
		}
		if !block.FoundAt.IsZero() {
			row.FoundTime = timestamppb.New(block.FoundAt)
		}
		payout, confirmations, err := h.coinbasePayout(ctx, block.Hash, address)
		if err != nil {
			h.log.Debug().Err(err).Str("block", block.Hash).Msg("stratum: the node did not give the block")
		} else {
			row.MyPayoutSats = &payout
			row.Confirmations = &confirmations
		}
		resp.Blocks = append(resp.Blocks, row)
	}
	return resp, nil
}

// finderIsOurs reports whether a pool credits a block to this installation.
// Every miner here reaches the pool under one worker name, and the pool may
// add a suffix of its own.
func finderIsOurs(finder, worker string) bool {
	if worker == "" || finder == "" {
		return false
	}
	return finder == worker || strings.HasPrefix(finder, worker+".")
}

// coinbasePayout sums the coinbase outputs of a block that pay address.
func (h *StratumHandler) coinbasePayout(ctx context.Context, hash, address string) (int64, int32, error) {
	if h.core == nil {
		return 0, 0, errors.New("no bitcoind seam")
	}
	if address == "" {
		return 0, 0, errors.New("no payout address")
	}
	raw, err := h.core(ctx, "getblock", fmt.Sprintf("[%q,2]", hash), "")
	if err != nil {
		return 0, 0, err
	}
	return coinbasePayout(raw, address)
}

// coinbasePayout reads a verbose getblock reply and sums the coinbase outputs
// that pay address.
func coinbasePayout(raw json.RawMessage, address string) (int64, int32, error) {
	var block struct {
		Confirmations int32 `json:"confirmations"`
		Tx            []struct {
			Vout []struct {
				Value        float64 `json:"value"`
				ScriptPubKey struct {
					Address string `json:"address"`
				} `json:"scriptPubKey"`
			} `json:"vout"`
		} `json:"tx"`
	}
	if err := json.Unmarshal(raw, &block); err != nil {
		return 0, 0, fmt.Errorf("decode the block: %w", err)
	}
	if len(block.Tx) == 0 {
		return 0, block.Confirmations, nil
	}
	var sats int64
	for _, out := range block.Tx[0].Vout {
		if out.ScriptPubKey.Address == address {
			sats += int64(math.Round(out.Value * 1e8))
		}
	}
	return sats, block.Confirmations, nil
}

// networkHashrate reads the hashrate of the whole network from the local
// node, at most once a minute. A node that does not answer reads zero.
func (h *StratumHandler) networkHashrate(ctx context.Context) float64 {
	h.statsMu.Lock()
	cached, found := h.stats[networkHashrateKey]
	h.statsMu.Unlock()
	if found && time.Since(cached.at) < poolStatsTTL {
		return cached.hashrate
	}
	entry := poolStatsEntry{at: time.Now()}
	if h.core != nil {
		raw, err := h.core(ctx, "getnetworkhashps", "[]", "")
		if err != nil {
			h.log.Debug().Err(err).Msg("stratum: the node did not give the network hashrate")
		} else if err := json.Unmarshal(raw, &entry.hashrate); err != nil {
			h.log.Debug().Err(err).Msg("stratum: the network hashrate does not read as a number")
			entry.hashrate = 0
		}
	}
	h.statsMu.Lock()
	h.stats[networkHashrateKey] = entry
	h.statsMu.Unlock()
	return entry.hashrate
}

// applyHold holds the daemon while the server runs and the user asked the
// miners to keep going. The daemon lease counts client connections, and a
// miner is none, so the lease would drain the stack under the miners.
func (h *StratumHandler) applyHold() {
	if h.holdDaemon == nil {
		return
	}
	h.mu.Lock()
	keep := h.run != nil && h.settings.StratumSettings().KeepMiningOnClose
	var release func()
	switch {
	case keep && h.release == nil:
		h.release = h.holdDaemon()
	case !keep && h.release != nil:
		release, h.release = h.release, nil
	}
	h.mu.Unlock()
	if release != nil {
		release()
	}
}
