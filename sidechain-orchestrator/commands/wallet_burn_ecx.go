package commands

import (
	"bufio"
	"bytes"
	"encoding/hex"
	"fmt"
	"io"
	"math"
	"net/http"
	"strconv"
	"strings"

	"connectrpc.com/connect"
	confpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	confrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/localauth"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/replay"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/txscript"
	"github.com/urfave/cli/v2"
)

func newWalletBurnECXCommand(burnAddress string, minimumSats int64) *cli.Command {
	return &cli.Command{
		Name:      "burn-ecx",
		Usage:     "Burn Alphanet coins for real ECX",
		ArgsUsage: "[wallet-id]",
		Flags: []cli.Flag{
			&cli.Int64Flag{Name: "sats", Usage: "amount to burn in Alphanet satoshis", Required: true},
			&cli.Int64Flag{Name: "fee-rate", Usage: "fee rate in sat/vB (0 = default)"},
			&cli.BoolFlag{Name: "preview", Usage: "show the transaction without a signature or broadcast"},
			&cli.BoolFlag{Name: "yes", Usage: "approve the burn without a prompt"},
			&cli.StringFlag{Name: "psbt-out", Usage: "export the PSBT to a new file without a broadcast"},
			&cli.StringFlag{Name: "psbt-in", Usage: "read an existing burn PSBT from a file"},
			&cli.StringSliceFlag{Name: "signed-psbt", Usage: "combine a cosigner PSBT file with --psbt-in; repeat for each cosigner"},
		},
		Action: func(cctx *cli.Context) error {
			conf := confrpc.NewBitcoinConfServiceClient(
				http.DefaultClient,
				"http://"+cctx.String("rpcserver"),
				connect.WithGRPC(),
				connect.WithInterceptors(localauth.Interceptor(cookieDir(cctx))),
			)
			return runWalletBurnECX(cctx, newWalletClient(cctx), conf, burnAddress, minimumSats)
		},
	}
}

type burnWalletState struct {
	walletID string
	active   bool
	external bool
	multisig bool
}

func (s *burnWalletState) check(cctx *cli.Context, client rpc.WalletManagerServiceClient, conf confrpc.BitcoinConfServiceClient) error {
	networks, err := conf.ListNetworks(cctx.Context, connect.NewRequest(&confpb.ListNetworksRequest{}))
	if err != nil {
		return fmt.Errorf("read the network: %w", err)
	}
	alphanet := false
	for _, network := range networks.Msg.Networks {
		if network.IsCurrent {
			alphanet = network.Id == "alphanet" && network.Network == "ecash"
			break
		}
	}
	if !alphanet {
		return fmt.Errorf("the burn is available only on Alphanet")
	}
	status, err := client.GetWalletStatus(cctx.Context, connect.NewRequest(&pb.GetWalletStatusRequest{}))
	if err != nil {
		return fmt.Errorf("read the wallet status: %w", err)
	}
	if !status.Msg.HasWallet {
		return fmt.Errorf("select a wallet to burn coins")
	}
	if status.Msg.Encrypted && !status.Msg.Unlocked {
		return fmt.Errorf("unlock this wallet to burn coins")
	}
	if s.active {
		if s.walletID == "" {
			s.walletID = status.Msg.ActiveWalletId
		}
		if s.walletID == "" || status.Msg.ActiveWalletId != s.walletID {
			return fmt.Errorf("the active wallet changed; create the burn again")
		}
	}
	wallets, err := client.ListWallets(cctx.Context, connect.NewRequest(&pb.ListWalletsRequest{}))
	if err != nil {
		return fmt.Errorf("read the wallets: %w", err)
	}
	if s.active && wallets.Msg.ActiveWalletId != s.walletID {
		return fmt.Errorf("the active wallet changed; create the burn again")
	}
	for _, wallet := range wallets.Msg.Wallets {
		if wallet.Id != s.walletID {
			continue
		}
		if wallet.WalletType != pb.WalletType_WALLET_TYPE_ELECTRUM && wallet.WalletType != pb.WalletType_WALLET_TYPE_BITCOIN_CORE {
			return fmt.Errorf("use an Electrum or Bitcoin Core wallet for this burn")
		}
		s.multisig = wallet.Multisig != nil
		if !s.multisig && (wallet.WatchOnly || wallet.HardwareDeviceType != "" || wallet.HardwareFingerprint != "") {
			return fmt.Errorf("use a software or multisig wallet for this burn")
		}
		if s.multisig && !s.external {
			return fmt.Errorf("use --psbt-out to collect external signatures for this wallet")
		}
		return nil
	}
	return fmt.Errorf("wallet %q is absent", s.walletID)
}

func runWalletBurnECX(cctx *cli.Context, client rpc.WalletManagerServiceClient, conf confrpc.BitcoinConfServiceClient, burnAddress string, minimumSats int64) error {
	if cctx.NArg() > 1 || (cctx.NArg() == 1 && strings.HasPrefix(cctx.Args().First(), "-")) {
		return fmt.Errorf("write the flags before the optional wallet ID")
	}
	if minimumSats < 0 {
		return fmt.Errorf("the burn minimum cannot be negative")
	}
	amount := cctx.Int64("sats")
	if amount < minimumSats {
		return fmt.Errorf("the burn must be at least %d Alphanet satoshis", minimumSats)
	}
	if cctx.Int64("fee-rate") < 0 {
		return fmt.Errorf("the fee rate cannot be negative")
	}
	inputPath, outputPath := cctx.String("psbt-in"), cctx.String("psbt-out")
	if inputPath == "" && len(cctx.StringSlice("signed-psbt")) != 0 {
		return fmt.Errorf("use --psbt-in with --signed-psbt")
	}
	if inputPath != "" && cctx.IsSet("fee-rate") {
		return fmt.Errorf("the fee rate applies only to a new PSBT")
	}
	burn, err := btcutil.DecodeAddress(burnAddress, &chaincfg.MainNetParams)
	if err != nil {
		return fmt.Errorf("read the burn address: %w", err)
	}
	if !burn.IsForNet(&chaincfg.MainNetParams) {
		return fmt.Errorf("the burn address must use the Alphanet address format")
	}
	burnScript, err := txscript.PayToAddrScript(burn)
	if err != nil {
		return fmt.Errorf("create the burn script: %w", err)
	}
	state := burnWalletState{
		walletID: cctx.Args().First(), active: cctx.NArg() == 0,
		external: inputPath != "" || outputPath != "",
	}
	if err := state.check(cctx, client, conf); err != nil {
		return err
	}
	derived, err := client.DeriveAddresses(cctx.Context, connect.NewRequest(&pb.DeriveAddressesRequest{
		WalletId: state.walletID, StartIndex: 0, Count: 1,
	}))
	if err != nil {
		return fmt.Errorf("derive the first wallet address: %w", err)
	}
	if len(derived.Msg.Addresses) != 1 || derived.Msg.Addresses[0] == "" {
		return fmt.Errorf("the wallet returned no first address")
	}
	address := derived.Msg.Addresses[0]
	dataScript, err := txscript.NewScriptBuilder().AddOp(txscript.OP_RETURN).AddData([]byte(address)).Script()
	if err != nil {
		return fmt.Errorf("create the address script: %w", err)
	}
	if err := state.check(cctx, client, conf); err != nil {
		return err
	}
	var packet string
	if inputPath != "" {
		packet, err = readPSBTFile(inputPath)
		if err != nil {
			return err
		}
	} else {
		created, err := client.CreatePsbt(cctx.Context, connect.NewRequest(&pb.CreatePsbtRequest{
			WalletId:           state.walletID,
			Destinations:       map[string]int64{burnAddress: amount},
			FeeRateSatPerVbyte: cctx.Int64("fee-rate"),
			OpReturnHex:        hex.EncodeToString([]byte(address)),
		}))
		if err != nil {
			return fmt.Errorf("create the burn transaction: %w", err)
		}
		packet = created.Msg.PsbtBase64
	}
	if err := state.check(cctx, client, conf); err != nil {
		return err
	}
	if paths := cctx.StringSlice("signed-psbt"); len(paths) != 0 {
		packets := []string{packet}
		for _, path := range paths {
			signed, err := readPSBTFile(path)
			if err != nil {
				return err
			}
			packets = append(packets, signed)
		}
		combined, err := client.CombinePsbt(cctx.Context, connect.NewRequest(&pb.CombinePsbtRequest{PsbtBase64: packets}))
		if err != nil {
			return fmt.Errorf("combine the burn signatures: %w", err)
		}
		if err := state.check(cctx, client, conf); err != nil {
			return err
		}
		packet = combined.Msg.PsbtBase64
	}
	if inputPath != "" {
		if err := wallet.CheckPSBTInputs(packet); err != nil {
			return err
		}
	}
	decoded, err := client.DecodeTransaction(cctx.Context, connect.NewRequest(&pb.DecodeTransactionRequest{
		WalletId: state.walletID, Input: packet, CheckOwnership: true,
	}))
	if err != nil {
		return fmt.Errorf("read the burn transaction: %w", err)
	}
	if err := checkBurnPreview(decoded.Msg, amount, burnScript, dataScript); err != nil {
		return err
	}
	if err := state.check(cctx, client, conf); err != nil {
		return err
	}
	ready := true
	if state.multisig {
		status, err := client.MultisigPsbtStatus(cctx.Context, connect.NewRequest(&pb.MultisigPsbtStatusRequest{
			WalletId: state.walletID, PsbtBase64: packet,
		}))
		if err != nil {
			return fmt.Errorf("read the burn signatures: %w", err)
		}
		if err := state.check(cctx, client, conf); err != nil {
			return err
		}
		ready = status.Msg.Finalizable
	}
	creditSats := wallet.ECXCreditSats(amount)
	preview := fmt.Sprintf("Burn Transaction\nWallet: %s\nAlphanet burn: %s coins (%d satoshis)\nTo BitcoinEater: %s\nThis transaction burns Alphanet coins.\nOP_RETURN: 0 satoshis\nECX address: %s\nThe address used is the first address of this wallet.\nYou will receive 1/100 of the amount you burn as real ECX at this address.\nThe credit rounds up to a whole ECX satoshi.\nReal ECX credit: %s ECX\nNetwork fee: %s Alphanet coins (%d satoshis)\nTotal from Alphanet: %s coins\nYou cannot reverse this burn\n",
		state.walletID, formatBurnCoins(amount, 8), amount, burnAddress, address, formatBurnCoins(creditSats, 8),
		formatBurnCoins(decoded.Msg.FeeSats, 8), decoded.Msg.FeeSats, formatBurnCoins(amount+decoded.Msg.FeeSats, 8))
	if _, err := io.WriteString(cctx.App.Writer, preview); err != nil {
		return fmt.Errorf("write the burn preview: %w", err)
	}
	if err := writeTransactionWarning(cctx.App.Writer, decoded.Msg.WarningMessage); err != nil {
		return err
	}
	if !ready {
		if _, err := io.WriteString(cctx.App.Writer, "More cosigner signatures are necessary.\n"); err != nil {
			return fmt.Errorf("write the signature status: %w", err)
		}
	}
	if outputPath != "" {
		if err := writePSBTFile(outputPath, packet); err != nil {
			return err
		}
		if _, err := fmt.Fprintf(cctx.App.Writer, "PSBT file: %s\nThe command did not broadcast the burn.\n", outputPath); err != nil {
			return fmt.Errorf("write the export result: %w", err)
		}
		return nil
	}
	if cctx.Bool("preview") {
		return nil
	}
	if !ready {
		return fmt.Errorf("collect sufficient signatures before the burn")
	}
	if !cctx.Bool("yes") {
		if _, err := io.WriteString(cctx.App.Writer, "Burn these Alphanet coins? [y/N] "); err != nil {
			return fmt.Errorf("write the burn prompt: %w", err)
		}
		answer, err := bufio.NewReader(cctx.App.Reader).ReadString('\n')
		if err != nil {
			return fmt.Errorf("read the burn approval: %w", err)
		}
		answer = strings.TrimSpace(answer)
		if !strings.EqualFold(answer, "y") && !strings.EqualFold(answer, "yes") {
			return fmt.Errorf("you did not approve the burn")
		}
	}
	if err := state.check(cctx, client, conf); err != nil {
		return err
	}
	if inputPath == "" {
		signed, err := client.SignPsbt(cctx.Context, connect.NewRequest(&pb.SignPsbtRequest{
			WalletId: state.walletID, PsbtBase64: packet,
		}))
		if err != nil {
			return fmt.Errorf("sign the burn transaction: %w", err)
		}
		if err := state.check(cctx, client, conf); err != nil {
			return err
		}
		packet = signed.Msg.PsbtBase64
	}
	final, err := client.FinalizePsbt(cctx.Context, connect.NewRequest(&pb.FinalizePsbtRequest{PsbtBase64: packet}))
	if err != nil {
		return fmt.Errorf("finalize the burn transaction: %w", err)
	}
	if err := state.check(cctx, client, conf); err != nil {
		return err
	}
	sent, err := client.BroadcastTransaction(cctx.Context, connect.NewRequest(&pb.BroadcastTransactionRequest{
		WalletId: state.walletID, TxHex: final.Msg.RawTxHex,
	}))
	if err != nil {
		return fmt.Errorf("broadcast the burn transaction: %w", err)
	}
	receipt := fmt.Sprintf("Burn sent: %s\nECX credit pending: %s ECX\nECX address: %s\nYour real ECX credit remains pending.\n",
		sent.Msg.Txid, formatBurnCoins(creditSats, 8), address)
	if _, err := io.WriteString(cctx.App.Writer, receipt); err != nil {
		return fmt.Errorf("write the receipt for %s: %w", sent.Msg.Txid, err)
	}
	return nil
}

func checkBurnPreview(preview *pb.DecodeTransactionResponse, amount int64, burnScript, dataScript []byte) error {
	if !preview.IsPsbt || !preview.HasFee || !preview.HasTotalInput || preview.FeeSats < 0 || preview.FeeSats > math.MaxInt64-amount {
		return fmt.Errorf("the transaction has no exact fee")
	}
	sequences := make([]uint32, len(preview.Inputs))
	for i, input := range preview.Inputs {
		sequences[i] = uint32(input.Sequence)
	}
	if !replay.Protected(uint32(preview.Locktime), sequences) {
		return fmt.Errorf("the burn transaction must keep Alphanet replay protection")
	}
	var burnCount, dataCount int
	var total int64
	for _, output := range preview.Outputs {
		if output.ValueSats < 0 || output.ValueSats > math.MaxInt64-total {
			return fmt.Errorf("the transaction has an invalid output amount")
		}
		total += output.ValueSats
		script, err := hex.DecodeString(output.ScriptPubkeyHex)
		if err != nil {
			return fmt.Errorf("read the output script: %w", err)
		}
		switch {
		case bytes.Equal(script, burnScript) && output.ValueSats == amount:
			burnCount++
		case bytes.Equal(script, dataScript) && output.ValueSats == 0:
			dataCount++
		case output.IsChange && output.IsMine:
		default:
			return fmt.Errorf("the transaction contains an unexpected output")
		}
	}
	if burnCount != 1 || dataCount != 1 {
		return fmt.Errorf("the transaction must contain the burn and the zero-value address output")
	}
	if total != preview.TotalOutputSats || preview.TotalInputSats < total || preview.TotalInputSats-total != preview.FeeSats {
		return fmt.Errorf("the transaction fee does not match its inputs and outputs")
	}
	return nil
}

func formatBurnCoins(sats int64, decimals int) string {
	digits := strconv.FormatInt(sats, 10)
	if len(digits) <= decimals {
		digits = strings.Repeat("0", decimals+1-len(digits)) + digits
	}
	return digits[:len(digits)-decimals] + "." + digits[len(digits)-decimals:]
}
