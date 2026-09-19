package api

import (
	"cmp"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
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
)

// StratumNetwork is what the Stratum handler reads about the running network.
type StratumNetwork interface {
	CurrentNetwork() string
	RunningCatalogEntry() (netcatalog.Network, bool)
}

// StratumSettingsStore persists the work target.
type StratumSettingsStore interface {
	StratumSettings() orchestrator.StratumSettings
	SetStratumSettings(orchestrator.StratumSettings) error
}

// StratumHandler runs the Stratum server for miners on the local network. The
// server lives on the daemon context, so it keeps running with no client.
type StratumHandler struct {
	ctx        context.Context
	network    StratumNetwork
	settings   StratumSettingsStore
	newAddress func(context.Context) (string, error)
	core       CoreRawCaller
	log        zerolog.Logger

	newNode    func() (stratum.Node, error)
	listen     func(port uint32) (net.Listener, error)
	readDevice func(ctx context.Context, ip string) (cgminer.Device, error)
	setMode    func(ctx context.Context, ip string, mode cgminer.WorkMode) error
	httpClient *http.Client

	statsMu sync.Mutex
	stats   map[string]poolStatsEntry

	// opMu makes Start, Stop and SetTarget run one at a time. mu guards the
	// fields below and is never held across network calls.
	opMu    sync.Mutex
	mu      sync.Mutex
	run     *stratumRun
	lastErr string
	blocks  []stratum.Block
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

func NewStratumHandler(
	ctx context.Context,
	network StratumNetwork,
	settings StratumSettingsStore,
	newAddress func(context.Context) (string, error),
	core CoreRawCaller,
	log zerolog.Logger,
) *StratumHandler {
	return &StratumHandler{
		ctx:        ctx,
		network:    network,
		settings:   settings,
		newAddress: newAddress,
		core:       core,
		log:        log,
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
	port := cmp.Or(req.Msg.Port, defaultStratumPort)
	if port > 65535 {
		return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("port %d is out of range", port))
	}

	h.opMu.Lock()
	defer h.opMu.Unlock()
	h.mu.Lock()
	running := h.run
	h.mu.Unlock()
	if running != nil {
		if running.port == port {
			return connect.NewResponse(&pb.StartStratumResponse{}), nil
		}
		return nil, connect.NewError(connect.CodeFailedPrecondition,
			fmt.Errorf("the stratum server already runs on port %d", running.port))
	}

	source, pool, err := h.sourceFor(ctx, h.settings.StratumSettings())
	if err != nil {
		return nil, err
	}
	ln, err := h.listen(port)
	if err != nil {
		return nil, connect.NewError(connect.CodeUnavailable, fmt.Errorf("listen on port %d: %w", port, err))
	}

	server := stratum.NewServer(source, h.log)
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
		if err != nil {
			h.log.Error().Err(err).Msg("stratum server stopped")
		}
	}()
	go h.pollDevices(runCtx, run)

	h.log.Info().Uint32("port", port).Msg("stratum server started")
	return connect.NewResponse(&pb.StartStratumResponse{}), nil
}

func (h *StratumHandler) StopStratum(
	context.Context, *connect.Request[pb.StopStratumRequest],
) (*connect.Response[pb.StopStratumResponse], error) {
	h.Stop()
	return connect.NewResponse(&pb.StopStratumResponse{}), nil
}

// Reset stops the server and forgets its blocks, which belong to the
// network that ran before.
func (h *StratumHandler) Reset() {
	h.Stop()
	h.mu.Lock()
	h.blocks, h.lastErr = nil, ""
	h.mu.Unlock()
}

// Stop stops the server and waits until every connection closes.
func (h *StratumHandler) Stop() {
	h.opMu.Lock()
	defer h.opMu.Unlock()
	h.mu.Lock()
	run := h.run
	h.mu.Unlock()
	if run == nil {
		return
	}
	run.cancel()
	<-run.done
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
		source, err := stratum.NewPoolSource(pool.url, s.PayoutAddress, catalogPoolWorkerPassword, h.log)
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
		if next.PayoutAddress == "" {
			address, err := h.newAddress(ctx)
			if err != nil {
				return nil, connect.NewError(connect.CodeFailedPrecondition, fmt.Errorf("get a payout address: %w", err))
			}
			next.PayoutAddress = address
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
	resp := &pb.GetStratumStatusResponse{Error: lastErr, Target: targetToProto(settings)}
	if settings.Target == targetPool {
		resp.PayoutAddress = settings.PayoutAddress
	}
	if run != nil {
		status := run.server.Status()
		blocks = status.Blocks
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
