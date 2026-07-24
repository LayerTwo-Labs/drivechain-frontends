package wallet

import (
	"context"
	"encoding/json"
	"testing"

	"github.com/btcsuite/btcd/chaincfg"
	"github.com/stretchr/testify/require"
)

// fakeRunner returns an HWIRunner whose call captures the request it was given
// and replies with a canned raw JSON body / error.
func fakeRunner(chain, out string, err error, captured *map[string]any) *HWIRunner {
	return &HWIRunner{
		chain: chain,
		call: func(_ context.Context, req map[string]any) (json.RawMessage, error) {
			*captured = req
			return json.RawMessage(out), err
		},
	}
}

func TestHwiChainArg(t *testing.T) {
	cases := map[*chaincfg.Params]string{
		&chaincfg.MainNetParams:       "main",
		&chaincfg.SigNetParams:        "signet",
		&chaincfg.RegressionNetParams: "regtest",
		&chaincfg.TestNet3Params:      "test",
	}
	for net, want := range cases {
		if got := hwiChainArg(net); got != want {
			t.Errorf("hwiChainArg(%s) = %q, want %q", net.Name, got, want)
		}
	}
}

func TestEnumerate(t *testing.T) {
	out := `[{"type":"trezor","model":"trezor_1","path":"webusb:001","fingerprint":"1a2b3c4d","needs_pin_sent":true},
	         {"type":"ledger","model":"ledger_nano_s","path":"hid:002","error":"unlock device","code":-12}]`
	var req map[string]any
	r := fakeRunner("test", out, nil, &req)
	devices, err := r.Enumerate(context.Background(), "")
	require.NoError(t, err)
	require.Len(t, devices, 2)
	require.Equal(t, "trezor", devices[0].Type)
	require.True(t, devices[0].NeedsPinSent)
	require.Equal(t, "unlock device", devices[1].Error)
	require.Equal(t, "enumerate", req["cmd"])
	require.Equal(t, "test", req["chain"])
}

func TestGetXpub(t *testing.T) {
	var req map[string]any
	r := fakeRunner("main", `{"xpub":"xpub6C..."}`, nil, &req)
	xpub, err := r.GetXpub(context.Background(), HardwareSelector{Type: "trezor", Fingerprint: "1a2b3c4d"}, "m/48'/0'/0'/2'")
	require.NoError(t, err)
	require.Equal(t, "xpub6C...", xpub)
	require.Equal(t, "getxpub", req["cmd"])
	require.Equal(t, "main", req["chain"])
	require.Equal(t, "trezor", req["type"])
	require.Equal(t, "1a2b3c4d", req["fingerprint"])
	require.Equal(t, "m/48'/0'/0'/2'", req["derivation_path"])
}

func TestSignPSBT(t *testing.T) {
	var req map[string]any
	r := fakeRunner("regtest", `{"psbt":"cHNidP8signed","signed":true}`, nil, &req)
	signed, err := r.SignPSBT(context.Background(), HardwareSelector{Fingerprint: "1a2b3c4d"}, "cHNidP8unsigned")
	require.NoError(t, err)
	require.Equal(t, "cHNidP8signed", signed)
	require.Equal(t, "signtx", req["cmd"])
	require.Equal(t, "cHNidP8unsigned", req["psbt"])
}

func TestPinFlow(t *testing.T) {
	var req map[string]any
	r := fakeRunner("test", `{"success":true}`, nil, &req)
	require.NoError(t, r.PromptPin(context.Background(), HardwareSelector{Type: "trezor", Path: "webusb:001"}))
	require.Equal(t, "promptpin", req["cmd"])
	require.Equal(t, "webusb:001", req["device_path"])

	require.NoError(t, r.SendPin(context.Background(), HardwareSelector{Type: "trezor", Path: "webusb:001"}, "789"))
	require.Equal(t, "sendpin", req["cmd"])
	require.Equal(t, "789", req["pin"])

	// A rejected PIN comes back as success=false.
	rejected := fakeRunner("test", `{"success":false}`, nil, &req)
	require.Error(t, rejected.SendPin(context.Background(), HardwareSelector{}, "111"))
}

func TestSignPSBTEmptyResult(t *testing.T) {
	var req map[string]any
	r := fakeRunner("test", `{"psbt":"","signed":false}`, nil, &req)
	_, err := r.SignPSBT(context.Background(), HardwareSelector{}, "cHNidP8")
	require.Error(t, err)
}
