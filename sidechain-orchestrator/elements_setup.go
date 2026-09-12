package orchestrator

import (
	"context"
	"encoding/hex"
	"fmt"
	"os"
	"path/filepath"
	"time"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/elements"
)

func verifyElementsArtifact(cfg BinaryConfig, path string, archive bool) error {
	if cfg.Name != "liquid-signet" {
		return nil
	}
	pin := cfg.ArtifactPins[currentPlatform()]
	expected := pin.ExecutableSHA256
	if archive {
		expected = pin.ArchiveSHA256
	}
	decoded, err := hex.DecodeString(expected)
	if err != nil || len(decoded) != 32 {
		return fmt.Errorf("Elements Alpha has no valid artifact pin for %s", currentPlatform())
	}
	info, err := os.Lstat(path)
	if err != nil || !info.Mode().IsRegular() {
		return fmt.Errorf("Elements Alpha artifact must be a regular file: %s", path)
	}
	actual, _, err := hashFile(path)
	if err != nil {
		return err
	}
	if actual != expected {
		return fmt.Errorf("Elements Alpha artifact checksum mismatch; refusing %s", path)
	}
	return nil
}

type elementsAlphaHealthCheck struct {
	node *elements.Node
	err  error
}

func (h *elementsAlphaHealthCheck) Check(ctx context.Context) error {
	if h.err != nil {
		return h.err
	}
	ctx, cancel := context.WithTimeout(ctx, 60*time.Second)
	defer cancel()
	return h.node.VerifyAlpha(ctx)
}

func newElementsAlphaHealthCheck(cfg BinaryConfig) HealthChecker {
	dirs, ok := config.DirConfigByName(cfg.Name)
	if !ok {
		return &elementsAlphaHealthCheck{err: fmt.Errorf("no Elements Alpha directory configuration")}
	}
	cookie := filepath.Join(dirs.DatadirNetwork(config.NetworkECash, ""), config.ElementsAlphaChainDir, ".cookie")
	return &elementsAlphaHealthCheck{node: elements.NewNode(cfg.RPCHost(), cfg.Port, cookie)}
}

func (o *Orchestrator) prepareElementsAlphaArgs(cfg BinaryConfig, opts *StartOpts) error {
	if o.NodeMode() == NodeModeLight {
		return fmt.Errorf("Elements Alpha needs a local authenticated Alphanet parent; light mode is unsupported")
	}
	if o.BitcoinConf == nil {
		return fmt.Errorf("Elements Alpha parent configuration is unavailable")
	}
	if len(opts.TargetArgs) != 0 {
		return fmt.Errorf("managed Elements Alpha startup does not accept custom flags")
	}
	dirs, ok := config.DirConfigByName(cfg.Name)
	if !ok {
		return fmt.Errorf("no Elements Alpha directory configuration")
	}
	native := config.ElementsAlphaOptions{
		Network:      config.NetworkFromString(o.Network),
		DataDir:      dirs.DatadirNetwork(config.NetworkFromString(o.Network), ""),
		ParentHost:   o.BitcoinConf.GetRPCHost(),
		ParentPort:   o.BitcoinConf.GetRPCPort(),
		ParentCookie: o.BitcoinConf.GetRPCCookiePath(),
		RPCPort:      cfg.Port,
		P2PPort:      7066,
	}
	args, err := native.Install()
	if err != nil {
		return err
	}
	opts.TargetArgs = args
	return nil
}

// The legacy identifier is also a protobuf enum and an on-disk directory name.
// Do not confuse its July Signet package with the current slot-24 Alpha node.
const elementsSetupUnavailable = "Elements Alpha setup requires a checksum-pinned native release for this platform; see docs/elements-alpha-setup.md"

func checkElementsSetup(cfg BinaryConfig) error {
	if cfg.Name != "liquid-signet" {
		return nil
	}
	pin := cfg.ArtifactPins[currentPlatform()]
	if cfg.BinaryName != "elementsd" || cfg.Files[currentPlatform()] == "" || cfg.BaseURL("default") == "" {
		return fmt.Errorf("%s", elementsSetupUnavailable)
	}
	for _, hash := range []string{pin.ArchiveSHA256, pin.ExecutableSHA256} {
		decoded, err := hex.DecodeString(hash)
		if err != nil || len(decoded) != 32 {
			return fmt.Errorf("%s", elementsSetupUnavailable)
		}
	}
	return nil
}
