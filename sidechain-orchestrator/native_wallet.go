package orchestrator

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"sync"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
)

var nativeWalletSetupMu sync.Mutex

const bitcoinGenesis = "000000000019d6689c085ae165831e934ff763ae46a2a6c172b3f1b60a8ce26f"

// The bundle contains the GUI, daemon, CLI, and their libraries/assets.
// A release becomes installable only after its production identity and hashes are frozen.
type NativeWalletSpec struct {
	Ready            bool                   `json:"ready"`
	Version          string                 `json:"version"`
	Binary           map[string]string      `json:"binary"`
	Daemon           map[string]string      `json:"daemon"`
	CLI              map[string]string      `json:"cli"`
	DownloadURLs     map[string]string      `json:"download_urls"`
	Files            map[string]string      `json:"files"`
	ExtractSubfolder map[string]string      `json:"extract_subfolder"`
	ArtifactPins     map[string]ArtifactPin `json:"artifact_pins"`
	DaemonSHA256     map[string]string      `json:"daemon_sha256"`
	CLISHA256        map[string]string      `json:"cli_sha256"`
	Identity         ElementsWalletIdentity `json:"identity"`
	NodeArgs         []string               `json:"node_args"`
}

type ElementsWalletIdentity struct {
	Name             string `json:"name"`
	Target           string `json:"target"`
	Ready            bool   `json:"ready"`
	Genesis          string `json:"genesis"`
	Asset            string `json:"asset"`
	ParentGenesis    string `json:"parentGenesis"`
	ParentForkHeight int    `json:"parentForkHeight"`
	ChainDirectory   string `json:"chain_directory"`
}

func nativeWalletSelected(cfg BinaryConfig, network string) bool {
	return cfg.NativeWallet != nil && network == string(config.NetworkECash) && config.ECashNetworkID() != "alphanet"
}

func validateNativeWallet(cfg BinaryConfig, network string) error {
	if !nativeWalletSelected(cfg, network) {
		return nil
	}
	w := cfg.NativeWallet
	if !w.Ready || !w.Identity.Ready {
		return fmt.Errorf("Elements wallet and node for the BTC to ECX fork at block 973,728 await a production release with finalized sidechain identity")
	}
	i := w.Identity
	if config.PublishedForkHeight(config.NetworkECash) != 973728 || i.Target != "btc-ecx-mainnet" || i.ParentGenesis != bitcoinGenesis || i.ParentForkHeight != 973728 {
		return fmt.Errorf("Elements wallet requires the BTC to ECX fork at block 973,728")
	}
	if !isSHA256(i.Genesis) || !isSHA256(i.Asset) || i.Genesis == strings.Repeat("0", 64) || i.Asset == strings.Repeat("0", 64) ||
		i.Genesis == "672af009bd90bfc6527a5a9dda4c83aba0048c15cff3697d07e89a7f96fa5bcd" ||
		i.Genesis == "a7754ce0debc40baddbd8c47e79d19209685f22c63edaaf8b69cf54116374d7f" {
		return fmt.Errorf("Elements wallet needs a distinct production genesis and native asset")
	}
	if w.Version == "" || !filepath.IsLocal(w.Version) || strings.ContainsAny(w.Version, `/\`) {
		return fmt.Errorf("invalid Elements release version")
	}
	if !filepath.IsLocal(i.ChainDirectory) || strings.ContainsAny(i.ChainDirectory, `/\`) {
		return fmt.Errorf("invalid Elements chain directory")
	}
	for _, entry := range []string{w.Binary[currentOS()], w.Daemon[currentOS()], w.CLI[currentOS()]} {
		if !filepath.IsLocal(entry) || strings.ContainsAny(entry, "\r\n\x00") {
			return fmt.Errorf("invalid Elements bundle executable")
		}
	}
	if !isSHA256(w.DaemonSHA256[currentPlatform()]) || !isSHA256(w.CLISHA256[currentPlatform()]) || len(w.ArtifactPins) == 0 {
		return fmt.Errorf("Elements release needs wallet, node, and CLI checksums")
	}
	c := w.component(cfg.Name)
	if c.Files[currentPlatform()] == "" || !strings.HasPrefix(c.BaseURL(network), "https://") {
		return fmt.Errorf("Elements bundle is unavailable for %s", currentPlatform())
	}
	for _, arg := range w.NodeArgs {
		// Parent/node identity and credentials belong to the reviewed node/configuration.
		if !strings.HasPrefix(arg, "-") || strings.HasPrefix(arg, "--") || strings.ContainsAny(arg, "\r\n\x00") {
			return fmt.Errorf("invalid Elements node argument")
		}
		for _, flag := range []string{"-chain", "-datadir", "-rpc", "-daemon", "-server", "-pid", "-conf", "-includeconf", "-mainchainrpc"} {
			if strings.HasPrefix(arg, flag) {
				return fmt.Errorf("Elements release overrides a setup-owned argument")
			}
		}
	}
	return checkArtifactPins(c, currentPlatform())
}

func (w *NativeWalletSpec) component(node string) BinaryConfig {
	return BinaryConfig{Name: node + "-wallet", DisplayName: "Elements wallet and node", BinaryName: w.Binary[currentOS()], Version: w.Version,
		DownloadURLs: w.DownloadURLs, Files: w.Files, ExtractSubfolder: w.ExtractSubfolder, ArtifactPins: w.ArtifactPins,
		InstallSubdir: filepath.Join("native-wallet", node, w.Version), PreserveTree: true,
		BundleChecksums: map[string]string{platformExecutable(w.Binary[currentOS()]): w.ArtifactPins[currentPlatform()].ExecutableSHA256, platformExecutable(w.Daemon[currentOS()]): w.DaemonSHA256[currentPlatform()], platformExecutable(w.CLI[currentOS()]): w.CLISHA256[currentPlatform()]}}
}

func nativeNodeConfig(cfg BinaryConfig, network string) BinaryConfig {
	if !nativeWalletSelected(cfg, network) || !cfg.NativeWallet.Ready {
		return cfg
	}
	w := cfg.NativeWallet
	cfg.BinaryName = w.Daemon[currentOS()]
	cfg.CLIBinaryName = w.CLI[currentOS()]
	cfg.Version = w.Version
	cfg.InstallSubdir = w.component(cfg.Name).InstallSubdir
	cfg.PreserveTree = true
	cfg.AltDownloadURLs = nil
	cfg.AltFiles = nil
	cfg.CLIFiles = nil
	cfg.ArtifactPins = map[string]ArtifactPin{currentPlatform(): {ExecutableSHA256: w.DaemonSHA256[currentPlatform()], ArchiveSHA256: w.ArtifactPins[currentPlatform()].ArchiveSHA256}}
	return cfg
}

func installedBinaryPath(dir string, cfg BinaryConfig) string {
	return filepath.Join(BinDir(dir), cfg.InstallSubdir, filepath.FromSlash(platformExecutable(cfg.BinaryName)))
}
func platformExecutable(name string) string {
	if currentOS() == "windows" {
		return name + ".exe"
	}
	return name
}
func nativeCLIPath(dir string, cfg BinaryConfig) string {
	cli := cfg
	cli.BinaryName = cfg.CLIBinaryName
	return installedBinaryPath(dir, cli)
}
func nativeDataDir(cfg BinaryConfig, network string) (string, error) {
	dirs, ok := config.DirConfigByName(cfg.Name)
	if !ok {
		return "", fmt.Errorf("no Elements data directory")
	}
	// Never reuse a legacy chain database, even when the catalog entry is old.
	return filepath.Join(dirs.DatadirNetwork(config.Network(network), ""), "blue-current", cfg.NativeWallet.Identity.Genesis), nil
}

func verifyNativeBundle(dir string, cfg BinaryConfig) error {
	w := cfg.NativeWallet
	gui := w.component(cfg.Name)
	node := nativeNodeConfig(cfg, string(config.NetworkECash))
	cli := node
	cli.BinaryName = node.CLIBinaryName
	cli.ArtifactPins = map[string]ArtifactPin{currentPlatform(): {ExecutableSHA256: w.CLISHA256[currentPlatform()]}}
	for _, part := range []BinaryConfig{gui, node, cli} {
		if err := verifyArtifactPin(part, installedBinaryPath(dir, part), false); err != nil {
			return err
		}
	}
	return nil
}

func (d *DownloadManager) downloadNativeBundle(ctx context.Context, cfg BinaryConfig, network string, force bool) (<-chan DownloadProgress, error) {
	if err := validateNativeWallet(cfg, network); err != nil {
		return nil, err
	}
	if _, err := os.Stat(installedBinaryPath(d.dataDir, cfg.NativeWallet.component(cfg.Name))); !force && err == nil {
		if err := verifyNativeBundle(d.dataDir, cfg); errors.Is(err, os.ErrNotExist) {
			force = true
		} else if err != nil {
			return nil, err
		}
	}
	inner, err := d.DownloadWithOptions(ctx, cfg.NativeWallet.component(cfg.Name), network, force, DownloadOptions{ForceBackend: true})
	if err != nil {
		return nil, err
	}
	out := make(chan DownloadProgress, 100)
	go func() {
		defer close(out)
		defer d.state.Delete(cfg.Name)
		for p := range inner {
			if p.Done {
				if err := verifyNativeBundle(d.dataDir, cfg); err != nil {
					p.Done = false
					p.Error = err
				}
			}
			d.state.Store(cfg.Name, DownloadState{Running: !p.Done && p.Error == nil, Message: p.Message, MBDownloaded: p.MBDownloaded, MBTotal: p.MBTotal})
			select {
			case out <- p:
			case <-ctx.Done():
				return
			}
		}
	}()
	return out, nil
}

func (o *Orchestrator) nativeCLI(ctx context.Context, cfg BinaryConfig, walletName, method string, args ...string) ([]byte, error) {
	folder, err := nativeDataDir(cfg, o.CurrentNetwork())
	if err != nil {
		return nil, err
	}
	node := nativeNodeConfig(cfg, o.CurrentNetwork())
	cliConfig := node
	cliConfig.BinaryName = node.CLIBinaryName
	cliConfig.ArtifactPins = map[string]ArtifactPin{currentPlatform(): {ExecutableSHA256: cfg.NativeWallet.CLISHA256[currentPlatform()]}}
	if err := verifyArtifactPin(cliConfig, nativeCLIPath(o.DataDir, node), false); err != nil {
		return nil, err
	}
	flags := []string{"-chain=elements", "-datadir=" + folder, fmt.Sprintf("-rpcport=%d", cfg.Port)}
	if walletName != "" {
		flags = append(flags, "-rpcwallet="+walletName)
	}
	flags = append(flags, method)
	flags = append(flags, args...)
	ctx, cancel := context.WithTimeout(ctx, 15*time.Second)
	defer cancel()
	// Do not include stderr/arguments in errors: node errors can contain private paths.
	output, err := exec.CommandContext(ctx, nativeCLIPath(o.DataDir, node), flags...).Output()
	if err != nil {
		return nil, fmt.Errorf("Elements %s failed: %w", method, err)
	}
	return output, nil
}

func (o *Orchestrator) verifyNativeIdentity(ctx context.Context, cfg BinaryConfig) error {
	genesis, err := o.nativeCLI(ctx, cfg, "", "getblockhash", "0")
	if err != nil {
		return err
	}
	if strings.Trim(strings.TrimSpace(string(genesis)), `"`) != cfg.NativeWallet.Identity.Genesis {
		return fmt.Errorf("Elements node belongs to a different chain")
	}
	raw, err := o.nativeCLI(ctx, cfg, "", "getsidechaininfo")
	if err != nil {
		return err
	}
	var info struct {
		Asset  string `json:"pegged_asset"`
		Parent string `json:"parent_blockhash"`
	}
	if err = json.Unmarshal(raw, &info); err != nil {
		return err
	}
	if info.Asset != cfg.NativeWallet.Identity.Asset || info.Parent != bitcoinGenesis {
		return fmt.Errorf("Elements node has the wrong asset or BTC parent")
	}
	return nil
}

func (o *Orchestrator) ensureNativeWallet(ctx context.Context, cfg BinaryConfig) error {
	nativeWalletSetupMu.Lock()
	defer nativeWalletSetupMu.Unlock()
	if err := o.verifyNativeIdentity(ctx, cfg); err != nil {
		return err
	}
	raw, err := o.nativeCLI(ctx, cfg, "", "listwallets")
	if err != nil {
		return err
	}
	var loaded []string
	if err = json.Unmarshal(raw, &loaded); err != nil {
		return err
	}
	for _, name := range loaded {
		if name == sidechain.CoreWalletName {
			return nil
		}
	}
	raw, err = o.nativeCLI(ctx, cfg, "", "listwalletdir")
	if err != nil {
		return err
	}
	var dir struct {
		Wallets []struct {
			Name string `json:"name"`
		} `json:"wallets"`
	}
	if err = json.Unmarshal(raw, &dir); err != nil {
		return err
	}
	for _, entry := range dir.Wallets {
		if entry.Name == sidechain.CoreWalletName {
			_, err = o.nativeCLI(ctx, cfg, "", "loadwallet", sidechain.CoreWalletName)
			return err
		}
	}
	_, err = o.nativeCLI(ctx, cfg, "", "createwallet", sidechain.CoreWalletName)
	return err
}

func (o *Orchestrator) prepareNativeNode(cfg BinaryConfig, opts *StartOpts) error {
	if err := validateNativeWallet(cfg, o.CurrentNetwork()); err != nil {
		return err
	}
	if o.BitcoinConf == nil {
		return fmt.Errorf("configure the BTC to ECX parent node first")
	}
	if o.NodeMode() == NodeModeLight {
		return fmt.Errorf("Elements requires a local authenticated BTC to ECX parent node")
	}
	folder, err := nativeDataDir(cfg, o.CurrentNetwork())
	if err != nil {
		return err
	}
	if err = os.MkdirAll(folder, 0o700); err != nil {
		return err
	}
	// Ignore caller overrides: the bundle/profile determine which chain owns this folder.
	opts.TargetArgs = append([]string{"-chain=elements", "-datadir=" + folder, fmt.Sprintf("-rpcport=%d", cfg.Port), "-server=1", "-daemon=0", "-pid=" + filepath.Join(folder, "blue-current-node.pid"), "-rpcbind=127.0.0.1", "-rpcallowip=127.0.0.1",
		"-mainchainrpccookiefile=" + o.BitcoinConf.GetRPCCookiePath(), fmt.Sprintf("-mainchainrpcport=%d", o.BitcoinConf.GetRPCPort()), "-mainchainrpchost=127.0.0.1"}, cfg.NativeWallet.NodeArgs...)
	return nil
}

func (o *Orchestrator) openNativeWallet(ctx context.Context, cfg BinaryConfig) error {
	if err := verifyNativeBundle(o.DataDir, cfg); err != nil {
		return err
	}
	if err := o.ensureNativeWallet(ctx, cfg); err != nil {
		return err
	}
	gui := sidechainGUIProcessName(cfg.Name)
	if o.process.IsRunning(gui) {
		return nil
	}
	component := cfg.NativeWallet.component(cfg.Name)
	folder, err := nativeDataDir(cfg, o.CurrentNetwork())
	if err != nil {
		return err
	}
	profile, err := o.writeNativeWalletProfile(cfg, component, folder)
	if err != nil {
		return err
	}
	_, err = o.process.StartWithOptions(ctx, component, []string{"--node-profile", profile}, nil, ProcessStartOptions{ForceBackend: true, ProcessName: gui, PidName: gui, WorkDir: filepath.Dir(installedBinaryPath(o.DataDir, component))})
	if errors.Is(err, ErrAlreadyRunning) {
		return nil
	}
	return err
}

func (o *Orchestrator) writeNativeWalletProfile(cfg, component BinaryConfig, folder string) (string, error) {
	node := nativeNodeConfig(cfg, o.CurrentNetwork())
	profile := map[string]any{"schema": "elements-blue-current-node-v1", "name": cfg.NativeWallet.Identity.Name,
		"cli": nativeCLIPath(o.DataDir, node), "daemon": installedBinaryPath(o.DataDir, node), "chain": "elements", "datadir": folder,
		"rpcport": cfg.Port, "wallet": sidechain.CoreWalletName, "startNode": false, "nodeArgs": []string{}, "identity": cfg.NativeWallet.Identity}
	data, err := json.MarshalIndent(profile, "", "  ")
	if err != nil {
		return "", err
	}
	dir := filepath.Join(o.DataDir, "native-wallet-profiles")
	if err = os.MkdirAll(dir, 0o700); err != nil {
		return "", err
	}
	path := filepath.Join(dir, cfg.Name+".json")
	file, err := os.CreateTemp(dir, "profile-*")
	if err != nil {
		return "", err
	}
	defer os.Remove(file.Name())
	if _, err = file.Write(data); err == nil {
		err = file.Sync()
	}
	closeErr := file.Close()
	if err != nil {
		return "", err
	}
	if closeErr != nil {
		return "", closeErr
	}
	// Windows cannot atomically replace an open existing file. Profiles contain no credentials.
	if err = os.Rename(file.Name(), path); err != nil {
		if removeErr := os.Remove(path); removeErr != nil && !os.IsNotExist(removeErr) {
			return "", removeErr
		}
		err = os.Rename(file.Name(), path)
	}
	return path, err
}

func (o *Orchestrator) finishNativeTarget(ctx context.Context, cfg BinaryConfig, opts StartOpts, ch chan<- StartupProgress) error {
	if nativeWalletSelected(cfg, o.CurrentNetwork()) {
		if err := o.ensureNativeWallet(ctx, cfg); err != nil {
			return err
		}
		if !opts.ForceBackend && !o.BackendOnly() {
			if err := o.openNativeWallet(ctx, cfg); err != nil {
				return err
			}
		}
	}
	ch <- StartupProgress{Stage: "done", Message: fmt.Sprintf("%s started", cfg.DisplayName), Done: true}
	return nil
}

// Authentication and identity are part of readiness, not just an open port.
type nativeWalletHealth struct {
	orch *Orchestrator
	cfg  BinaryConfig
}

func (h nativeWalletHealth) Check(ctx context.Context) error {
	return h.orch.verifyNativeIdentity(ctx, h.cfg)
}
func (o *Orchestrator) resolvedNativeConfig(cfg BinaryConfig) BinaryConfig {
	cfg = nativeNodeConfig(cfg, o.CurrentNetwork())
	if nativeWalletSelected(cfg, o.CurrentNetwork()) {
		cfg.CustomHealthCheck = nativeWalletHealth{o, cfg}
	}
	return cfg
}
