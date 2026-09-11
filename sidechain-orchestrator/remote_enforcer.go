package orchestrator

import (
	"context"
	"fmt"
	"strings"
	"time"

	"connectrpc.com/connect"
	"connectrpc.com/grpchealth"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/enforcerproxy"
	enforcerpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/logfile"
)

// EnforcerURL returns the local enforcer URL or the bridge URL for light mode.
func (o *Orchestrator) EnforcerURL() (string, error) {
	if o.NodeMode() != NodeModeLight {
		cfg, ok := o.Configs()["enforcer"]
		if !ok || cfg.Port == 0 {
			return "", fmt.Errorf("enforcer is not configured")
		}
		return cfg.RPCURL(), nil
	}

	network := config.Network(o.CurrentNetwork())
	upstream := config.RemoteEnforcerURLForNetwork(network)
	if upstream == "" {
		return "", fmt.Errorf("%s has no remote enforcer endpoint", network)
	}

	o.remoteEnforcerMu.Lock()
	defer o.remoteEnforcerMu.Unlock()
	if o.remoteEnforcer != nil {
		if o.remoteNetwork == network {
			if o.remoteUpstream != upstream {
				if err := o.remoteEnforcer.SetUpstream(upstream); err != nil {
					return "", fmt.Errorf("change the remote enforcer endpoint: %w", err)
				}
				o.remoteUpstream = upstream
			}
			return o.remoteEnforcer.URL(), nil
		}
		if err := o.remoteEnforcer.Close(); err != nil {
			return "", fmt.Errorf("close the remote enforcer bridge: %w", err)
		}
		o.remoteEnforcer = nil
	}
	remote, err := enforcerproxy.NewRemote(upstream, logfile.StdLogger(o.log, logfile.TransportNoise))
	if err != nil {
		return "", fmt.Errorf("connect to the remote enforcer for %s: %w", network, err)
	}
	o.remoteEnforcer = remote
	o.remoteNetwork = network
	o.remoteUpstream = upstream
	return remote.URL(), nil
}

func (o *Orchestrator) closeRemoteEnforcer() error {
	o.remoteEnforcerMu.Lock()
	defer o.remoteEnforcerMu.Unlock()
	if o.remoteEnforcer == nil {
		return nil
	}
	o.monitorsMu.Lock()
	mon := o.monitors["enforcer"]
	o.monitorsMu.Unlock()
	if mon != nil {
		mon.StopAllTimers()
		mon.MarkStopped()
	}
	err := o.remoteEnforcer.Close()
	o.remoteEnforcer = nil
	o.remoteNetwork = ""
	o.remoteUpstream = ""
	if err != nil {
		return fmt.Errorf("close the remote enforcer bridge: %w", err)
	}
	return nil
}

type enforcerHealthCheck struct {
	orch  *Orchestrator
	local HealthChecker
}

func (h *enforcerHealthCheck) Check(ctx context.Context) error {
	if h.orch.NodeMode() != NodeModeLight {
		return h.local.Check(ctx)
	}
	client, err := h.orch.EnforcerValidator()
	if err != nil {
		return err
	}
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()
	endpoint, err := h.orch.EnforcerURL()
	if err != nil {
		return err
	}
	health := grpchealth.NewClient(h.orch.enforcerHTTP(), endpoint, connect.WithGRPC())
	status, err := health.Check(ctx, &grpchealth.CheckRequest{Service: "cusf.mainchain.v1.ValidatorService"})
	if err != nil {
		return fmt.Errorf("check the remote validator service: %w", err)
	}
	if status.Status != grpchealth.StatusServing {
		return fmt.Errorf("the remote validator service is not ready")
	}
	_, err = client.GetChainTip(ctx, connect.NewRequest(&enforcerpb.GetChainTipRequest{}))
	return err
}

func (o *Orchestrator) startRemoteEnforcer(ctx context.Context, ch chan<- StartupProgress) error {
	if _, err := o.EnforcerURL(); err != nil {
		return err
	}
	cfg := o.Configs()["enforcer"]
	mon := o.getOrCreateMonitor("enforcer", NewHealthChecker(cfg), enforcerStartupPatterns)
	mon.SetInitializing(true)
	defer mon.SetInitializing(false)
	ch <- StartupProgress{Stage: "remote-enforcer", Message: "Check the remote enforcer"}
	mon.StartConnectionTimer(ctx)
	if !mon.Connected() {
		if err := ctx.Err(); err != nil {
			return err
		}
		if err := mon.ConnectionError(); err != "" {
			return fmt.Errorf("remote validator: %s", err)
		}
		return fmt.Errorf("remote validator is not ready: %s", mon.StartupError())
	}
	return nil
}

// ConnectRemoteEnforcer starts the remote enforcer in light mode on a network
// that publishes one. The enforcer monitor retries a failed connect.
func (o *Orchestrator) ConnectRemoteEnforcer(ctx context.Context) error {
	if _, ok := o.Configs()["enforcer"]; !ok || o.NodeMode() != NodeModeLight ||
		config.RemoteEnforcerURLForNetwork(config.Network(o.CurrentNetwork())) == "" {
		return nil
	}
	ch, err := o.StartWithL1(ctx, "enforcer", StartOpts{})
	if err != nil {
		return fmt.Errorf("start the remote enforcer: %w", err)
	}
	go func() {
		for progress := range ch {
			if progress.Error != nil {
				o.log.Warn().Err(progress.Error).Msg("remote enforcer is not ready, the monitor retries")
			}
		}
	}()
	return nil
}

func (o *Orchestrator) restartRemoteOrphans(ctx context.Context, ch chan<- StartupProgress) error {
	for name, cfg := range o.Configs() {
		if cfg.ChainLayer != 2 || cfg.IsBitcoinCore || !o.process.IsAdopted(name) || !o.mayStopAdopted(name) {
			continue
		}
		spec, known := config.SidechainSpecByName(name)
		if !known || spec.EnforcerArg == "" {
			continue
		}
		progress, err := o.StartWithL1(ctx, name, StartOpts{ForceBackend: true})
		if err != nil {
			return fmt.Errorf("restart %s: %w", name, err)
		}
		var startErr error
		for update := range progress {
			if update.Error != nil {
				startErr = update.Error
			} else if !update.Done {
				ch <- update
			}
		}
		if startErr != nil {
			return fmt.Errorf("restart %s: %w", name, startErr)
		}
	}
	return nil
}

func (o *Orchestrator) prepareRemoteSidechainArgs(cfg BinaryConfig, opts *StartOpts) error {
	spec, ok := config.SidechainSpecByName(cfg.Name)
	if cfg.IsBitcoinCore || !ok || spec.EnforcerArg == "" {
		return fmt.Errorf("%s does not support a remote enforcer; select full mode", cfg.Name)
	}
	network := config.CusfNetworkName(config.Network(o.CurrentNetwork()), config.ECashNetworkID())
	if network == "" {
		return fmt.Errorf("%s on %s: %w", cfg.Name, o.CurrentNetwork(), errSidechainNetworkUnknown)
	}
	endpoint, err := o.EnforcerURL()
	if err != nil {
		return err
	}
	args, err := spec.EnforcerArgs(endpoint)
	if err != nil {
		return err
	}
	if scm := config.SidechainConfByName(o.SidechainConfs, cfg.Name); scm != nil && scm.Config != nil {
		if err := scm.SyncNetworkFromBitcoinConf(); err != nil {
			return fmt.Errorf("sync %s config: %w", cfg.Name, err)
		}
		if value := scm.Config.GetSetting("net-addr"); value != "" && !hasCLIFlag(opts.TargetArgs, "--net-addr") {
			args = append(args, "--net-addr="+value)
		}
		if value := scm.Config.GetSetting("zmq-addr"); spec.PortStyle == "zmq" && value != "" && !hasCLIFlag(opts.TargetArgs, "--zmq-addr") {
			args = append(args, "--zmq-addr="+value)
		}
	}
	for _, name := range []string{"--mainchain-grpc-url", "--mainchain-grpc-host", "--mainchain-grpc-port"} {
		opts.TargetArgs = replaceCLIFlag(opts.TargetArgs, name, "")
	}
	args = append(args, config.CliNetworkFlag+"="+network)
	for _, arg := range args {
		name, _, _ := strings.Cut(arg, "=")
		opts.TargetArgs = replaceCLIFlag(opts.TargetArgs, name, arg)
	}
	return nil
}

func replaceCLIFlag(args []string, name, value string) []string {
	result := make([]string, 0, len(args)+1)
	for i := 0; i < len(args); i++ {
		key, _, joined := strings.Cut(args[i], "=")
		if key != name {
			result = append(result, args[i])
			continue
		}
		if !joined && i+1 < len(args) && !strings.HasPrefix(args[i+1], "-") {
			i++
		}
	}
	if value != "" {
		result = append(result, value)
	}
	return result
}
