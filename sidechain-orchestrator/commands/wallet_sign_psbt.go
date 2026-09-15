package commands

import (
	"bufio"
	"encoding/hex"
	"fmt"
	"io"
	"os"
	"strings"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/btcsuite/btcd/txscript"
	"github.com/urfave/cli/v2"
)

var walletSignPSBTCommand = &cli.Command{
	Name:      "sign-psbt",
	Usage:     "Add local wallet signatures to a PSBT file without a broadcast",
	ArgsUsage: "[wallet-id]",
	Flags: []cli.Flag{
		&cli.StringFlag{Name: "psbt-in", Usage: "read a binary or base64 PSBT file", Required: true},
		&cli.StringFlag{Name: "psbt-out", Usage: "write the signed PSBT to a new file", Required: true},
		&cli.BoolFlag{Name: "yes", Usage: "approve the signatures without a prompt"},
	},
	Action: func(cctx *cli.Context) error {
		return runWalletSignPSBT(cctx, newWalletClient(cctx))
	},
}

func runWalletSignPSBT(cctx *cli.Context, client rpc.WalletManagerServiceClient) error {
	if cctx.NArg() > 1 || (cctx.NArg() == 1 && strings.HasPrefix(cctx.Args().First(), "-")) {
		return fmt.Errorf("write the flags before the optional wallet ID")
	}
	inputPath, outputPath := cctx.String("psbt-in"), cctx.String("psbt-out")
	if inputPath == "" || outputPath == "" {
		return fmt.Errorf("use --psbt-in and --psbt-out")
	}
	if _, err := os.Lstat(outputPath); err == nil {
		return fmt.Errorf("the PSBT output file already exists")
	} else if !os.IsNotExist(err) {
		return fmt.Errorf("check the PSBT output file: %w", err)
	}
	packet, err := readPSBTFile(inputPath)
	if err != nil {
		return err
	}
	if err := wallet.CheckPSBTInputs(packet); err != nil {
		return err
	}
	walletID, err := resolveWalletID(cctx, client)
	if err != nil {
		return err
	}
	wallets, err := client.ListWallets(cctx.Context, connect.NewRequest(&pb.ListWalletsRequest{}))
	if err != nil {
		return fmt.Errorf("read the wallets: %w", err)
	}
	var selected *pb.WalletMetadata
	for _, wallet := range wallets.Msg.Wallets {
		if wallet.Id == walletID {
			selected = wallet
			break
		}
	}
	if selected == nil {
		return fmt.Errorf("wallet %q is absent", walletID)
	}
	if selected.WalletType != pb.WalletType_WALLET_TYPE_ELECTRUM && selected.WalletType != pb.WalletType_WALLET_TYPE_BITCOIN_CORE {
		return fmt.Errorf("use an Electrum or Bitcoin Core wallet to sign this PSBT")
	}
	if selected.WalletType == pb.WalletType_WALLET_TYPE_BITCOIN_CORE &&
		(selected.WatchOnly || selected.HardwareDeviceType != "" || selected.HardwareFingerprint != "") {
		return fmt.Errorf("use a Bitcoin Core wallet with local private keys to sign this PSBT")
	}
	decoded, err := client.DecodeTransaction(cctx.Context, connect.NewRequest(&pb.DecodeTransactionRequest{
		WalletId: walletID, Input: packet,
	}))
	if err != nil {
		return fmt.Errorf("read the PSBT transaction: %w", err)
	}
	if !decoded.Msg.IsPsbt || !decoded.Msg.HasFee || decoded.Msg.FeeSats < 0 {
		return fmt.Errorf("the PSBT has no exact network fee")
	}
	preview := fmt.Sprintf("Sign PSBT\nWallet: %s\n", walletID)
	for _, output := range decoded.Msg.Outputs {
		preview += fmt.Sprintf("Output %d: %d satoshis\n", output.Index, output.ValueSats)
		if output.Address != "" {
			preview += fmt.Sprintf("  Address: %s\n", output.Address)
		}
		if output.ScriptPubkeyHex != "" {
			preview += fmt.Sprintf("  Script: %s\n", output.ScriptPubkeyHex)
			script, err := hex.DecodeString(output.ScriptPubkeyHex)
			if err != nil {
				return fmt.Errorf("read output %d script: %w", output.Index, err)
			}
			if len(script) > 0 && script[0] == txscript.OP_RETURN {
				data, err := txscript.PushedData(script)
				if err != nil {
					return fmt.Errorf("read output %d data: %w", output.Index, err)
				}
				for _, value := range data {
					preview += fmt.Sprintf("  OP_RETURN data: %q\n", value)
				}
			}
		} else if output.ScriptPubkeyAsm != "" {
			preview += fmt.Sprintf("  Script: %s\n", output.ScriptPubkeyAsm)
		}
	}
	preview += fmt.Sprintf("Network fee: %d satoshis\n", decoded.Msg.FeeSats)
	if _, err := io.WriteString(cctx.App.Writer, preview); err != nil {
		return fmt.Errorf("write the PSBT preview: %w", err)
	}
	if err := writeTransactionWarning(cctx.App.Writer, decoded.Msg.WarningMessage); err != nil {
		return err
	}
	if !cctx.Bool("yes") {
		if _, err := io.WriteString(cctx.App.Writer, "Sign this PSBT with the local wallet keys? [y/N] "); err != nil {
			return fmt.Errorf("write the signature prompt: %w", err)
		}
		answer, err := bufio.NewReader(cctx.App.Reader).ReadString('\n')
		if err != nil {
			return fmt.Errorf("read the signature approval: %w", err)
		}
		answer = strings.TrimSpace(answer)
		if !strings.EqualFold(answer, "y") && !strings.EqualFold(answer, "yes") {
			return fmt.Errorf("you did not approve the signatures")
		}
	}
	signed, err := client.SignPsbt(cctx.Context, connect.NewRequest(&pb.SignPsbtRequest{
		WalletId: walletID, PsbtBase64: packet,
	}))
	if err != nil {
		return fmt.Errorf("sign the PSBT: %w", err)
	}
	if err := writePSBTFile(outputPath, signed.Msg.PsbtBase64); err != nil {
		return err
	}
	if _, err := fmt.Fprintf(cctx.App.Writer, "PSBT file: %s\nThe command did not broadcast the transaction.\n", outputPath); err != nil {
		return fmt.Errorf("write the signature result: %w", err)
	}
	return nil
}
