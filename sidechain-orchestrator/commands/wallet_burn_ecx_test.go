package commands

import (
	"bytes"
	"context"
	"encoding/hex"
	"errors"
	"flag"
	"io"
	"math"
	"net/http"
	"net/http/httptest"
	"strconv"
	"strings"
	"testing"

	"connectrpc.com/connect"
	confpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	confrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/replay"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
	"github.com/stretchr/testify/require"
	"github.com/urfave/cli/v2"
	"google.golang.org/protobuf/proto"
)

const burnTestAddress = "1BoatSLRHtKNngkdXEeobR76b53LETtpyT"
const burnTestReceiveAddress = "bc1qcr8te4kr609gcawutmrza0j4xv80jy8z306fyu"

type burnTestDaemon struct {
	rpc.UnimplementedWalletManagerServiceHandler
	confrpc.UnimplementedBitcoinConfServiceHandler
	network          string
	status           *pb.GetWalletStatusResponse
	wallets          *pb.ListWalletsResponse
	addresses        []string
	preview          *pb.DecodeTransactionResponse
	fail             string
	after            map[string]func()
	calls            []string
	derived          *pb.DeriveAddressesRequest
	created          *pb.CreatePsbtRequest
	decoded          *pb.DecodeTransactionRequest
	signed           *pb.SignPsbtRequest
	finalized        *pb.FinalizePsbtRequest
	broadcast        *pb.BroadcastTransactionRequest
	packet           string
	signedPSBT       string
	combined         *pb.CombinePsbtRequest
	combinedPSBT     string
	signatureRequest *pb.MultisigPsbtStatusRequest
	signatureStatus  *pb.MultisigPsbtStatusResponse
}

func (d *burnTestDaemon) step(name string) error {
	d.calls = append(d.calls, name)
	if d.fail == name {
		return connect.NewError(connect.CodeUnavailable, errors.New("RPC failed"))
	}
	if change := d.after[name]; change != nil {
		change()
		delete(d.after, name)
	}
	return nil
}

func (d *burnTestDaemon) ListNetworks(context.Context, *connect.Request[confpb.ListNetworksRequest]) (*connect.Response[confpb.ListNetworksResponse], error) {
	if err := d.step("network"); err != nil {
		return nil, err
	}
	return connect.NewResponse(&confpb.ListNetworksResponse{Networks: []*confpb.NetworkOption{
		{Id: d.network, Network: "ecash", IsCurrent: true},
	}}), nil
}

func (d *burnTestDaemon) GetWalletStatus(context.Context, *connect.Request[pb.GetWalletStatusRequest]) (*connect.Response[pb.GetWalletStatusResponse], error) {
	if err := d.step("status"); err != nil {
		return nil, err
	}
	return connect.NewResponse(d.status), nil
}

func (d *burnTestDaemon) ListWallets(context.Context, *connect.Request[pb.ListWalletsRequest]) (*connect.Response[pb.ListWalletsResponse], error) {
	if err := d.step("wallets"); err != nil {
		return nil, err
	}
	return connect.NewResponse(d.wallets), nil
}

func (d *burnTestDaemon) DeriveAddresses(_ context.Context, req *connect.Request[pb.DeriveAddressesRequest]) (*connect.Response[pb.DeriveAddressesResponse], error) {
	d.derived = proto.Clone(req.Msg).(*pb.DeriveAddressesRequest)
	if err := d.step("derive"); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.DeriveAddressesResponse{Addresses: d.addresses}), nil
}

func (d *burnTestDaemon) CreatePsbt(_ context.Context, req *connect.Request[pb.CreatePsbtRequest]) (*connect.Response[pb.CreatePsbtResponse], error) {
	d.created = proto.Clone(req.Msg).(*pb.CreatePsbtRequest)
	if err := d.step("create"); err != nil {
		return nil, err
	}
	packet := d.packet
	if packet == "" {
		packet = "unsigned-psbt"
	}
	return connect.NewResponse(&pb.CreatePsbtResponse{PsbtBase64: packet}), nil
}

func (d *burnTestDaemon) CombinePsbt(_ context.Context, req *connect.Request[pb.CombinePsbtRequest]) (*connect.Response[pb.CombinePsbtResponse], error) {
	d.combined = proto.Clone(req.Msg).(*pb.CombinePsbtRequest)
	if err := d.step("combine"); err != nil {
		return nil, err
	}
	packet := d.combinedPSBT
	if packet == "" {
		var err error
		packet, err = (&wallet.ElectrumBackend{}).CombinePSBT(req.Msg.PsbtBase64)
		if err != nil {
			return nil, err
		}
	}
	return connect.NewResponse(&pb.CombinePsbtResponse{PsbtBase64: packet}), nil
}

func (d *burnTestDaemon) MultisigPsbtStatus(_ context.Context, req *connect.Request[pb.MultisigPsbtStatusRequest]) (*connect.Response[pb.MultisigPsbtStatusResponse], error) {
	d.signatureRequest = proto.Clone(req.Msg).(*pb.MultisigPsbtStatusRequest)
	if err := d.step("signatures"); err != nil {
		return nil, err
	}
	status := d.signatureStatus
	if status == nil {
		status = &pb.MultisigPsbtStatusResponse{Threshold: 2}
	}
	return connect.NewResponse(status), nil
}

func (d *burnTestDaemon) DecodeTransaction(_ context.Context, req *connect.Request[pb.DecodeTransactionRequest]) (*connect.Response[pb.DecodeTransactionResponse], error) {
	d.decoded = proto.Clone(req.Msg).(*pb.DecodeTransactionRequest)
	if err := d.step("decode"); err != nil {
		return nil, err
	}
	return connect.NewResponse(d.preview), nil
}

func (d *burnTestDaemon) SignPsbt(_ context.Context, req *connect.Request[pb.SignPsbtRequest]) (*connect.Response[pb.SignPsbtResponse], error) {
	d.signed = proto.Clone(req.Msg).(*pb.SignPsbtRequest)
	if err := d.step("sign"); err != nil {
		return nil, err
	}
	packet := d.signedPSBT
	if packet == "" {
		packet = "signed-psbt"
	}
	return connect.NewResponse(&pb.SignPsbtResponse{PsbtBase64: packet}), nil
}

func (d *burnTestDaemon) FinalizePsbt(_ context.Context, req *connect.Request[pb.FinalizePsbtRequest]) (*connect.Response[pb.FinalizePsbtResponse], error) {
	d.finalized = proto.Clone(req.Msg).(*pb.FinalizePsbtRequest)
	if err := d.step("finalize"); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.FinalizePsbtResponse{RawTxHex: "final-transaction"}), nil
}

func (d *burnTestDaemon) BroadcastTransaction(_ context.Context, req *connect.Request[pb.BroadcastTransactionRequest]) (*connect.Response[pb.BroadcastTransactionResponse], error) {
	d.broadcast = proto.Clone(req.Msg).(*pb.BroadcastTransactionRequest)
	if err := d.step("broadcast"); err != nil {
		return nil, err
	}
	return connect.NewResponse(&pb.BroadcastTransactionResponse{Txid: "burn-txid"}), nil
}

type burnTestFlow struct {
	ctx    *cli.Context
	daemon *burnTestDaemon
	client rpc.WalletManagerServiceClient
	conf   confrpc.BitcoinConfServiceClient
	output *bytes.Buffer
}

func newBurnTestFlow(t *testing.T, args ...string) *burnTestFlow {
	t.Helper()
	burn, err := btcutil.DecodeAddress(burnTestAddress, &chaincfg.MainNetParams)
	require.NoError(t, err)
	burnScript, err := txscript.PayToAddrScript(burn)
	require.NoError(t, err)
	dataScript, err := txscript.NewScriptBuilder().AddOp(txscript.OP_RETURN).AddData([]byte(burnTestReceiveAddress)).Script()
	require.NoError(t, err)
	daemon := &burnTestDaemon{
		network: "alphanet",
		status:  &pb.GetWalletStatusResponse{HasWallet: true, Unlocked: true, ActiveWalletId: "active-wallet"},
		wallets: &pb.ListWalletsResponse{
			ActiveWalletId: "active-wallet",
			Wallets: []*pb.WalletMetadata{
				{Id: "active-wallet", WalletType: pb.WalletType_WALLET_TYPE_ELECTRUM},
				{Id: "other-wallet", WalletType: pb.WalletType_WALLET_TYPE_ELECTRUM},
			},
		},
		addresses: []string{burnTestReceiveAddress},
		preview: &pb.DecodeTransactionResponse{
			IsPsbt: true, HasFee: true, HasTotalInput: true,
			Locktime: int32(replay.ReplayLockTime),
			Inputs:   []*pb.TransactionInput{{Sequence: 0xfffffffe}},
			FeeSats:  452, TotalInputSats: 100010453, TotalOutputSats: 100010001,
			Outputs: []*pb.TransactionOutput{
				{ValueSats: 100000001, ScriptPubkeyHex: hex.EncodeToString(burnScript)},
				{ScriptPubkeyHex: hex.EncodeToString(dataScript)},
				{ValueSats: 10000, ScriptPubkeyHex: "0014deadbeef", IsChange: true, IsMine: true},
			},
		},
		after: map[string]func(){},
	}
	mux := http.NewServeMux()
	path, handler := rpc.NewWalletManagerServiceHandler(daemon)
	mux.Handle(path, handler)
	path, handler = confrpc.NewBitcoinConfServiceHandler(daemon)
	mux.Handle(path, handler)
	server := httptest.NewServer(mux)
	t.Cleanup(server.Close)
	set := flag.NewFlagSet("burn-ecx", flag.ContinueOnError)
	for _, f := range newWalletBurnECXCommand(burnTestAddress, 1000).Flags {
		require.NoError(t, f.Apply(set))
	}
	require.NoError(t, set.Parse(append([]string{"--sats", "100000001"}, args...)))
	output := &bytes.Buffer{}
	app := &cli.App{Reader: strings.NewReader("yes\n"), Writer: output}
	ctx := cli.NewContext(app, set, nil)
	ctx.Context = context.Background()
	return &burnTestFlow{
		ctx: ctx, daemon: daemon, output: output,
		client: rpc.NewWalletManagerServiceClient(server.Client(), server.URL),
		conf:   confrpc.NewBitcoinConfServiceClient(server.Client(), server.URL),
	}
}

func (f *burnTestFlow) run() error {
	return runWalletBurnECX(f.ctx, f.client, f.conf, burnTestAddress, 1000)
}

func TestBurnECXPreview(t *testing.T) {
	f := newBurnTestFlow(t, "--preview", "--yes", "--fee-rate", "2")
	require.NoError(t, f.run())
	require.Equal(t, "active-wallet", f.daemon.derived.WalletId)
	require.Zero(t, f.daemon.derived.StartIndex)
	require.EqualValues(t, 1, f.daemon.derived.Count)
	require.Equal(t, map[string]int64{burnTestAddress: 100000001}, f.daemon.created.Destinations)
	require.EqualValues(t, 2, f.daemon.created.FeeRateSatPerVbyte)
	require.Equal(t, hex.EncodeToString([]byte(burnTestReceiveAddress)), f.daemon.created.OpReturnHex)
	require.False(t, f.daemon.created.SubtractFeeFromAmount)
	require.False(t, f.daemon.created.AllowReplay)
	require.Empty(t, f.daemon.created.RequiredInputs)
	require.Equal(t, "unsigned-psbt", f.daemon.decoded.Input)
	require.Nil(t, f.daemon.signed)
	require.Nil(t, f.daemon.broadcast)
	for _, text := range []string{
		"Burn Transaction",
		"Alphanet burn: 1.00000001 coins (100000001 satoshis)",
		"To BitcoinEater: " + burnTestAddress,
		"This transaction burns Alphanet coins.",
		"OP_RETURN: 0 satoshis", "ECX address: " + burnTestReceiveAddress,
		"The address used is the first address of this wallet.",
		"You will receive 1/100 of the amount you burn as real ECX at this address.",
		"The credit rounds up to a whole ECX satoshi.",
		"Real ECX credit: 0.01000001 ECX", "Network fee: 0.00000452 Alphanet coins (452 satoshis)",
		"Total from Alphanet: 1.00000453 coins", "You cannot reverse this burn",
	} {
		require.Contains(t, f.output.String(), text)
	}
	require.NotContains(t, f.output.String(), "[y/N]")
	t.Log(f.output.String())
}

func TestBurnECXPrintsBackendWarningBeforeApproval(t *testing.T) {
	f := newBurnTestFlow(t)
	f.daemon.preview.WarningMessage = "This transaction burns Alphanet coins for a claim of real ECX. You cannot reverse this transaction."
	require.NoError(t, f.run())
	text := f.output.String()
	warning := strings.Index(text, "Warning: "+f.daemon.preview.WarningMessage)
	approval := strings.Index(text, "Burn these Alphanet coins? [y/N]")
	require.GreaterOrEqual(t, warning, 0)
	require.Greater(t, approval, warning)
	require.NotNil(t, f.daemon.broadcast)
}

func TestBurnECXPreviewKeepsBackendWarningText(t *testing.T) {
	f := newBurnTestFlow(t, "--preview")
	f.daemon.preview.WarningMessage = "Check each output before the signature."
	require.NoError(t, f.run())
	require.Contains(t, f.output.String(), "Warning: "+f.daemon.preview.WarningMessage+"\n")
	require.Nil(t, f.daemon.signed)
	require.Nil(t, f.daemon.broadcast)
}

func TestBurnECXStopsWhenTheWarningCannotPrint(t *testing.T) {
	f := newBurnTestFlow(t)
	f.daemon.preview.WarningMessage = "Check each output before the signature."
	f.ctx.App.Writer = &burnErrorWriter{failAt: 2}
	require.ErrorContains(t, f.run(), "write the transaction warning")
	require.Nil(t, f.daemon.signed)
	require.Nil(t, f.daemon.broadcast)
}

func TestBurnECXSendsThePreview(t *testing.T) {
	f := newBurnTestFlow(t, "--yes", "other-wallet")
	require.NoError(t, f.run())
	require.Equal(t, "other-wallet", f.daemon.derived.WalletId)
	require.Equal(t, "other-wallet", f.daemon.created.WalletId)
	require.Equal(t, "other-wallet", f.daemon.decoded.WalletId)
	require.True(t, f.daemon.decoded.CheckOwnership)
	require.Equal(t, "other-wallet", f.daemon.signed.WalletId)
	require.Equal(t, "unsigned-psbt", f.daemon.signed.PsbtBase64)
	require.Equal(t, "signed-psbt", f.daemon.finalized.PsbtBase64)
	require.Equal(t, "other-wallet", f.daemon.broadcast.WalletId)
	require.Equal(t, "final-transaction", f.daemon.broadcast.TxHex)
	require.Contains(t, f.output.String(), "Burn sent: burn-txid\nECX credit pending: 0.01000001 ECX")
	require.Contains(t, f.output.String(), "ECX address: "+burnTestReceiveAddress)
	require.Contains(t, f.output.String(), "Your real ECX credit remains pending.")
	require.NotContains(t, f.output.String(), "Betanet")
	require.NotContains(t, f.output.String(), "[y/N]")
}

func TestBurnECXCreditsOneCoinForOneHundredAlphanetCoins(t *testing.T) {
	const amount int64 = 10000000000
	f := newBurnTestFlow(t, "--sats", strconv.FormatInt(amount, 10), "--yes")
	f.daemon.preview.Outputs[0].ValueSats = amount
	f.daemon.preview.TotalOutputSats = amount + 10000
	f.daemon.preview.TotalInputSats = amount + 10452

	require.NoError(t, f.run())

	require.Equal(t, map[string]int64{burnTestAddress: amount}, f.daemon.created.Destinations)
	require.False(t, f.daemon.created.SubtractFeeFromAmount)
	require.False(t, f.daemon.created.AllowReplay)
	require.Contains(t, f.output.String(), "Alphanet burn: 100.00000000 coins (10000000000 satoshis)")
	require.Contains(t, f.output.String(), "Real ECX credit: 1.00000000 ECX")
	require.Contains(t, f.output.String(), "ECX credit pending: 1.00000000 ECX")
	require.Contains(t, f.output.String(), "Network fee: 0.00000452 Alphanet coins (452 satoshis)")
	require.Contains(t, f.output.String(), "Total from Alphanet: 100.00000452 coins")
	require.Equal(t, "unsigned-psbt", f.daemon.signed.PsbtBase64)
	require.Equal(t, "final-transaction", f.daemon.broadcast.TxHex)
}

func TestBurnECXChecksExplicitApproval(t *testing.T) {
	for _, answer := range []string{"\n", "no\n", "YES\n", "y\n", " yes \n", ""} {
		t.Run(strconv.Quote(answer), func(t *testing.T) {
			f := newBurnTestFlow(t)
			f.ctx.App.Reader = strings.NewReader(answer)
			err := f.run()
			if strings.EqualFold(strings.TrimSpace(answer), "y") || strings.EqualFold(strings.TrimSpace(answer), "yes") {
				require.NoError(t, err)
				require.NotNil(t, f.daemon.broadcast)
			} else {
				require.Error(t, err)
				require.Nil(t, f.daemon.signed)
				require.Nil(t, f.daemon.broadcast)
			}
		})
	}
}

func TestBurnECXRejectsInvalidArguments(t *testing.T) {
	for _, args := range [][]string{
		{"--sats", "0"}, {"--sats", "1000"}, {"--sats", "-1"},
		{"--fee-rate", "-1"}, {"active-wallet", "other-wallet"}, {"active-wallet", "--yes"},
	} {
		t.Run(strings.Join(args, " "), func(t *testing.T) {
			f := newBurnTestFlow(t, args...)
			require.Error(t, f.run())
			require.Empty(t, f.daemon.calls)
		})
	}
}

func TestBurnECXAcceptsOneSatoshiAboveTheMinimum(t *testing.T) {
	f := newBurnTestFlow(t, "--sats", "1001", "--preview")
	f.daemon.preview.Outputs[0].ValueSats = 1001
	f.daemon.preview.TotalOutputSats = 11001
	f.daemon.preview.TotalInputSats = 11453
	require.NoError(t, f.run())
	require.EqualValues(t, 1001, f.daemon.created.Destinations[burnTestAddress])
	require.Contains(t, f.output.String(), "Real ECX credit: 0.00000011 ECX")
}

func TestBurnECXChecksOneFirstAddress(t *testing.T) {
	for _, addresses := range [][]string{nil, {""}, {burnTestReceiveAddress, "another-address"}} {
		f := newBurnTestFlow(t, "--yes")
		f.daemon.addresses = addresses
		require.ErrorContains(t, f.run(), "first address")
		require.Nil(t, f.daemon.created)
	}
}

func TestBurnECXRejectsUnsupportedWallets(t *testing.T) {
	cases := map[string]func(*burnTestDaemon){
		"no wallet":    func(d *burnTestDaemon) { d.status.HasWallet = false },
		"locked":       func(d *burnTestDaemon) { d.status.Encrypted = true; d.status.Unlocked = false },
		"absent":       func(d *burnTestDaemon) { d.wallets.Wallets = nil },
		"watch-only":   func(d *burnTestDaemon) { d.wallets.Wallets[0].WatchOnly = true },
		"hardware":     func(d *burnTestDaemon) { d.wallets.Wallets[0].HardwareDeviceType = "trezor" },
		"multisig":     func(d *burnTestDaemon) { d.wallets.Wallets[0].Multisig = &pb.MultisigInfo{M: 2, N: 3} },
		"no active ID": func(d *burnTestDaemon) { d.status.ActiveWalletId = "" },
	}
	for name, change := range cases {
		t.Run(name, func(t *testing.T) {
			f := newBurnTestFlow(t)
			change(f.daemon)
			require.Error(t, f.run())
			require.Nil(t, f.daemon.derived)
		})
	}
}

func TestBurnECXRejectsOtherWalletTypes(t *testing.T) {
	for _, walletType := range []pb.WalletType{
		pb.WalletType_WALLET_TYPE_BITCOIN_CORE,
		pb.WalletType_WALLET_TYPE_ENFORCER,
		pb.WalletType_WALLET_TYPE_UNSPECIFIED,
	} {
		t.Run(walletType.String(), func(t *testing.T) {
			f := newBurnTestFlow(t, "--preview")
			f.daemon.wallets.Wallets[0].WalletType = walletType
			require.ErrorContains(t, f.run(), "use an Electrum wallet")
			require.Nil(t, f.daemon.derived)
			require.Nil(t, f.daemon.created)
		})
	}
}

func TestBurnECXStopsAfterContextChanges(t *testing.T) {
	for _, stage := range []string{"derive", "create", "decode", "sign", "finalize"} {
		for _, change := range []string{"network", "wallet", "wallet removed", "wallet locked"} {
			t.Run(stage+" "+change, func(t *testing.T) {
				f := newBurnTestFlow(t, "--yes")
				f.daemon.after[stage] = func() {
					switch change {
					case "network":
						f.daemon.network = "betanet"
					case "wallet":
						f.daemon.status.ActiveWalletId = "other-wallet"
					case "wallet removed":
						f.daemon.wallets.Wallets = nil
					case "wallet locked":
						f.daemon.status.Encrypted = true
						f.daemon.status.Unlocked = false
					}
				}
				require.Error(t, f.run())
				require.Nil(t, f.daemon.broadcast)
			})
		}
	}
}

func TestBurnECXRejectsOtherNetworks(t *testing.T) {
	for _, network := range []string{"betanet", "mainnet", "signet", "", "ecash"} {
		t.Run(network, func(t *testing.T) {
			f := newBurnTestFlow(t)
			f.daemon.network = network
			require.ErrorContains(t, f.run(), "only on Alphanet")
			require.Equal(t, []string{"network"}, f.daemon.calls)
		})
	}
}

func TestBurnECXReturnsRpcErrors(t *testing.T) {
	for _, stage := range []string{"network", "status", "wallets", "derive", "create", "decode", "sign", "finalize", "broadcast"} {
		t.Run(stage, func(t *testing.T) {
			f := newBurnTestFlow(t, "--yes")
			f.daemon.fail = stage
			require.ErrorContains(t, f.run(), "RPC failed")
			require.Equal(t, stage, f.daemon.calls[len(f.daemon.calls)-1])
			require.NotContains(t, f.output.String(), "Burn sent:")
		})
	}
}

func TestBurnECXRejectsInvalidPreview(t *testing.T) {
	cases := map[string]func(*pb.DecodeTransactionResponse){
		"no PSBT":         func(p *pb.DecodeTransactionResponse) { p.IsPsbt = false },
		"no fee":          func(p *pb.DecodeTransactionResponse) { p.HasFee = false },
		"no input total":  func(p *pb.DecodeTransactionResponse) { p.HasTotalInput = false },
		"wrong fee":       func(p *pb.DecodeTransactionResponse) { p.FeeSats++ },
		"fee overflow":    func(p *pb.DecodeTransactionResponse) { p.FeeSats = math.MaxInt64 },
		"negative fee":    func(p *pb.DecodeTransactionResponse) { p.FeeSats = -1 },
		"wrong burn":      func(p *pb.DecodeTransactionResponse) { p.Outputs[0].ValueSats-- },
		"wrong address":   func(p *pb.DecodeTransactionResponse) { p.Outputs[1].ScriptPubkeyHex = "6a0178" },
		"data value":      func(p *pb.DecodeTransactionResponse) { p.Outputs[1].ValueSats = 1 },
		"missing data":    func(p *pb.DecodeTransactionResponse) { p.Outputs = p.Outputs[:1] },
		"duplicate burn":  func(p *pb.DecodeTransactionResponse) { p.Outputs = append(p.Outputs, p.Outputs[0]) },
		"foreign output":  func(p *pb.DecodeTransactionResponse) { p.Outputs[2].IsChange = false },
		"false change":    func(p *pb.DecodeTransactionResponse) { p.Outputs[2].IsMine = false },
		"no replay stamp": func(p *pb.DecodeTransactionResponse) { p.Locktime = 0 },
		"final input":     func(p *pb.DecodeTransactionResponse) { p.Inputs[0].Sequence = 0xffffffff },
		"invalid script":  func(p *pb.DecodeTransactionResponse) { p.Outputs[0].ScriptPubkeyHex = "xyz" },
		"wrong total":     func(p *pb.DecodeTransactionResponse) { p.TotalOutputSats++ },
		"negative output": func(p *pb.DecodeTransactionResponse) { p.Outputs[2].ValueSats = -1 },
		"output overflow": func(p *pb.DecodeTransactionResponse) { p.Outputs[2].ValueSats = math.MaxInt64 },
	}
	for name, change := range cases {
		t.Run(name, func(t *testing.T) {
			f := newBurnTestFlow(t, "--yes")
			change(f.daemon.preview)
			require.Error(t, f.run())
			require.Nil(t, f.daemon.signed)
			require.Empty(t, f.output.String())
		})
	}
}

type burnErrorReader struct{}

func (burnErrorReader) Read([]byte) (int, error) { return 0, errors.New("read failed") }

type burnReaderFunc func([]byte) (int, error)

func (f burnReaderFunc) Read(p []byte) (int, error) { return f(p) }

func TestBurnECXChecksTheContextAfterApproval(t *testing.T) {
	for _, change := range []string{"network", "wallet"} {
		t.Run(change, func(t *testing.T) {
			f := newBurnTestFlow(t)
			f.ctx.App.Reader = burnReaderFunc(func(p []byte) (int, error) {
				if change == "network" {
					f.daemon.network = "betanet"
				} else {
					f.daemon.status.ActiveWalletId = "other-wallet"
				}
				return copy(p, "yes\n"), nil
			})
			require.Error(t, f.run())
			require.Nil(t, f.daemon.signed)
		})
	}
}

type burnErrorWriter struct {
	writes int
	failAt int
}

func (w *burnErrorWriter) Write(p []byte) (int, error) {
	w.writes++
	if w.writes == w.failAt {
		return 0, errors.New("write failed")
	}
	return len(p), nil
}

func TestBurnECXReturnsInputError(t *testing.T) {
	f := newBurnTestFlow(t)
	f.ctx.App.Reader = burnErrorReader{}
	require.ErrorContains(t, f.run(), "read failed")
	require.Nil(t, f.daemon.signed)
}

func TestBurnECXReturnsOutputErrors(t *testing.T) {
	for _, failAt := range []int{1, 2, 3} {
		t.Run(strconv.Itoa(failAt), func(t *testing.T) {
			f := newBurnTestFlow(t)
			f.ctx.App.Writer = &burnErrorWriter{failAt: failAt}
			err := f.run()
			require.ErrorContains(t, err, "write failed")
			if failAt < 3 {
				require.Nil(t, f.daemon.signed)
			} else {
				require.NotNil(t, f.daemon.broadcast)
				require.ErrorContains(t, err, "burn-txid")
			}
		})
	}
}

func TestBurnCoinTextUsesExactIntegers(t *testing.T) {
	require.Equal(t, "92233720368.54775807", formatBurnCoins(math.MaxInt64, 8))
	require.Equal(t, "0.00000000", formatBurnCoins(0, 8))
}

func TestBurnECXCreditUsesEightDecimals(t *testing.T) {
	for _, test := range []struct {
		sats   int64
		credit string
	}{
		{0, "0.00000000"},
		{1, "0.00000001"},
		{99, "0.00000001"},
		{100, "0.00000001"},
		{101, "0.00000002"},
		{1001, "0.00000011"},
		{99999999, "0.01000000"},
		{100000000, "0.01000000"},
		{100000001, "0.01000001"},
		{9999999999, "1.00000000"},
		{10000000000, "1.00000000"},
		{10000000001, "1.00000001"},
		{9007199254740993, "900719.92547410"},
		{math.MaxInt64, "922337203.68547759"},
	} {
		t.Run(strconv.FormatInt(test.sats, 10), func(t *testing.T) {
			require.Equal(t, test.credit, formatBurnCoins(wallet.ECXCreditSats(test.sats), 8))
		})
	}
}

func TestBurnECXCommandChecksTheAmountFlag(t *testing.T) {
	app := &cli.App{Commands: []*cli.Command{walletCommand}, Writer: io.Discard, ErrWriter: io.Discard}
	require.ErrorContains(t, app.Run([]string{"drivechain-cli", "wallet", "burn-ecx"}), "sats")
}

func TestBurnECXCommandChecksTheProductionMinimum(t *testing.T) {
	for _, amount := range []int64{wallet.ECXBurnMinimumSats - 1, wallet.ECXBurnMinimumSats} {
		t.Run(strconv.FormatInt(amount, 10), func(t *testing.T) {
			app := &cli.App{
				Commands: []*cli.Command{walletCommand}, Flags: GlobalFlags,
				Writer: io.Discard, ErrWriter: io.Discard,
			}
			err := app.Run([]string{
				"drivechain-cli", "--rpcserver", "127.0.0.1:0", "--bitwindow-dir", t.TempDir(),
				"wallet", "burn-ecx", "--sats", strconv.FormatInt(amount, 10), "--preview",
			})
			require.ErrorContains(t, err, "the burn amount must exceed 100000000000 Alphanet satoshis")
		})
	}
}

func TestBurnECXAcceptsOneSatoshiAboveTheProductionMinimum(t *testing.T) {
	const amount = wallet.ECXBurnMinimumSats + 1
	f := newBurnTestFlow(t, "--sats", strconv.FormatInt(amount, 10), "--yes")
	address, err := btcutil.DecodeAddress(wallet.ECXBurnAddress, &chaincfg.MainNetParams)
	require.NoError(t, err)
	script, err := txscript.PayToAddrScript(address)
	require.NoError(t, err)
	f.daemon.preview.Outputs[0].ValueSats = amount
	f.daemon.preview.Outputs[0].ScriptPubkeyHex = hex.EncodeToString(script)
	f.daemon.preview.TotalOutputSats = amount + 10000
	f.daemon.preview.TotalInputSats = amount + 10452

	require.NoError(t, runWalletBurnECX(f.ctx, f.client, f.conf, wallet.ECXBurnAddress, wallet.ECXBurnMinimumSats))
	require.Equal(t, map[string]int64{wallet.ECXBurnAddress: amount}, f.daemon.created.Destinations)
	require.Contains(t, f.output.String(), "Alphanet burn: 1000.00000001 coins (100000000001 satoshis)")
	require.Contains(t, f.output.String(), "To BitcoinEater: "+wallet.ECXBurnAddress)
	require.Contains(t, f.output.String(), "Real ECX credit: 10.00000001 ECX")
	require.Contains(t, f.output.String(), "ECX credit pending: 10.00000001 ECX")
	require.NotNil(t, f.daemon.broadcast)
}
