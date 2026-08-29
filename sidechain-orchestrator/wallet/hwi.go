package wallet

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"strings"

	"github.com/btcsuite/btcd/btcutil/psbt"
	"github.com/btcsuite/btcd/chaincfg"
)

// HardwareDevice is one entry from enumerate. Error/Code are set when the
// device was found but could not be opened.
type HardwareDevice struct {
	Type                string `json:"type"`
	Model               string `json:"model"`
	Label               string `json:"label"`
	Path                string `json:"path"`
	Fingerprint         string `json:"fingerprint"`
	NeedsPinSent        bool   `json:"needs_pin_sent"`
	NeedsPassphraseSent bool   `json:"needs_passphrase_sent"`
	Error               string `json:"error"`
	Code                int    `json:"code"`
}

// HardwareSelector identifies which enumerated device a command targets.
type HardwareSelector struct {
	Type        string
	Path        string
	Fingerprint string
	Passphrase  string
}

// HWIRunner drives hardware wallets through the persistent daemon.
type HWIRunner struct {
	chain string
	// Sends one request to the daemon; swappable in tests.
	call func(ctx context.Context, req map[string]any) (json.RawMessage, error)
}

func NewHWIRunner(net *chaincfg.Params) *HWIRunner {
	return &HWIRunner{chain: hwiChainArg(net), call: hwiCall}
}

// hwiChainArg names the coin a device validates against. A custom network takes
// the coin its address encoding belongs to: the device refuses a coin type 0h
// path under any coin but mainnet, and it shows an address in that coin's form.
func hwiChainArg(net *chaincfg.Params) string {
	switch net.Name {
	case "mainnet":
		return "main"
	case "signet":
		return "signet"
	case "regtest", "simnet":
		return "regtest"
	}
	switch net.Bech32HRPSegwit {
	case chaincfg.MainNetParams.Bech32HRPSegwit:
		return "main"
	case chaincfg.TestNet3Params.Bech32HRPSegwit:
		return "test"
	case chaincfg.RegressionNetParams.Bech32HRPSegwit:
		return "regtest"
	}
	// A guess here reaches the device as the wrong coin, and it costs a refused
	// path or a signature over the wrong script.
	panic(fmt.Sprintf("hwi: unknown network %q with address prefix %q",
		net.Name, net.Bech32HRPSegwit))
}

func (r *HWIRunner) request(cmd string, sel HardwareSelector) map[string]any {
	return map[string]any{
		"cmd":         cmd,
		"chain":       r.chain,
		"type":        sel.Type,
		"device_path": sel.Path,
		"fingerprint": sel.Fingerprint,
		"passphrase":  sel.Passphrase,
	}
}

// Enumerate lists connected devices. A passphrase, when set, makes a
// passphrase-protected device report its passphrase-wallet fingerprint.
func (r *HWIRunner) Enumerate(ctx context.Context, passphrase string) ([]HardwareDevice, error) {
	raw, err := r.call(ctx, map[string]any{"cmd": "enumerate", "chain": r.chain, "passphrase": passphrase})
	if err != nil {
		return nil, err
	}
	var devices []HardwareDevice
	if err := json.Unmarshal(raw, &devices); err != nil {
		return nil, fmt.Errorf("decode hwi enumerate: %w", err)
	}
	kept := devices[:0]
	for _, d := range devices {
		if d.Type == "" && d.Model == "" {
			continue
		}
		kept = append(kept, d)
	}
	return kept, nil
}

// GetXpub returns the account xpub at a BIP32 path from the selected device.
func (r *HWIRunner) GetXpub(ctx context.Context, sel HardwareSelector, path string) (string, error) {
	req := r.request("getxpub", sel)
	req["derivation_path"] = path
	raw, err := r.call(ctx, req)
	if err != nil {
		return "", err
	}
	var res struct {
		Xpub string `json:"xpub"`
	}
	if err := json.Unmarshal(raw, &res); err != nil {
		return "", fmt.Errorf("decode hwi getxpub: %w", err)
	}
	if res.Xpub == "" {
		return "", errors.New("hwi getxpub returned no xpub")
	}
	return res.Xpub, nil
}

// SignPSBT sends a base64 PSBT to the device and returns the signed PSBT.
func (r *HWIRunner) SignPSBT(ctx context.Context, sel HardwareSelector, psbtBase64 string) (string, error) {
	packet, err := psbt.NewFromRawBytes(strings.NewReader(psbtBase64), true)
	if err != nil {
		return "", fmt.Errorf("read psbt for the device: %w", err)
	}
	if err := checkDeviceCanSignPaths(packet, sel.Fingerprint); err != nil {
		return "", err
	}
	if err := r.checkDeviceHoldsWalletKeys(ctx, sel, packet); err != nil {
		return "", err
	}
	req := r.request("signtx", sel)
	req["psbt"] = psbtBase64
	raw, err := r.call(ctx, req)
	if err != nil {
		return "", err
	}
	var res struct {
		PSBT   string `json:"psbt"`
		Signed bool   `json:"signed"`
	}
	if err := json.Unmarshal(raw, &res); err != nil {
		return "", fmt.Errorf("decode hwi signtx: %w", err)
	}
	if res.PSBT == "" {
		return "", errors.New("hwi signtx returned no psbt")
	}
	if err := checkDeviceSignatures(res.PSBT); err != nil {
		return "", err
	}
	return res.PSBT, nil
}

// checkDeviceSignatures rejects a signature the device gives for another
// transaction. The broadcast is the next step that reads a signature, so a
// device fault reaches the user as a broadcast failure and names no device.
func checkDeviceSignatures(psbtBase64 string) error {
	packet, err := psbt.NewFromRawBytes(strings.NewReader(psbtBase64), true)
	if err != nil {
		return fmt.Errorf("read the psbt the device signed: %w", err)
	}
	// A packet the device gives back can lack a prevout this check needs. Check
	// the signatures it carries, and leave the rest to the finalizer.
	if !packetHasSignedPrevOuts(packet) {
		return nil
	}
	if err := verifySignatures(packet); err != nil {
		return fmt.Errorf("the device signed a different transaction: %w", err)
	}
	return nil
}

// packetHasSignedPrevOuts reports whether every input names the output it
// spends and at least one input carries a signature.
func packetHasSignedPrevOuts(packet *psbt.Packet) bool {
	signed := false
	for i := range packet.Inputs {
		out, err := authenticatedPrevOut(packet, i)
		if err != nil || out == nil {
			return false
		}
		in := &packet.Inputs[i]
		if len(in.PartialSigs) > 0 || len(in.TaprootKeySpendSig) > 0 || len(in.TaprootScriptSpendSig) > 0 {
			signed = true
		}
	}
	return signed
}

// DisplayAddress shows an address for the given output descriptor on the device.
func (r *HWIRunner) DisplayAddress(ctx context.Context, sel HardwareSelector, descriptor string) (string, error) {
	req := r.request("displayaddress", sel)
	req["descriptor"] = descriptor
	raw, err := r.call(ctx, req)
	if err != nil {
		return "", err
	}
	var res struct {
		Address string `json:"address"`
	}
	if err := json.Unmarshal(raw, &res); err != nil {
		return "", fmt.Errorf("decode hwi displayaddress: %w", err)
	}
	return res.Address, nil
}

// PromptPin tells a locked device to show its scrambled PIN matrix.
func (r *HWIRunner) PromptPin(ctx context.Context, sel HardwareSelector) error {
	raw, err := r.call(ctx, r.request("promptpin", sel))
	if err != nil {
		return err
	}
	return hwiCheckSuccess(raw, "could not request PIN")
}

// SendPin unlocks the device with the PIN as matrix positions.
func (r *HWIRunner) SendPin(ctx context.Context, sel HardwareSelector, pin string) error {
	req := r.request("sendpin", sel)
	req["pin"] = pin
	raw, err := r.call(ctx, req)
	if err != nil {
		return err
	}
	return hwiCheckSuccess(raw, "incorrect PIN")
}

// Close releases the device so the next enumerate isn't blocked.
func (r *HWIRunner) Close(ctx context.Context, sel HardwareSelector) error {
	_, err := r.call(ctx, r.request("close", sel))
	return err
}

func hwiCheckSuccess(raw json.RawMessage, failMsg string) error {
	var res struct {
		Success bool `json:"success"`
	}
	if err := json.Unmarshal(raw, &res); err != nil {
		return fmt.Errorf("decode hwi response: %w", err)
	}
	if !res.Success {
		return errors.New(failMsg)
	}
	return nil
}
