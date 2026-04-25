package commands

import (
	"fmt"
	"net/http"
	"os"
	"strconv"
	"strings"
	"text/tabwriter"
	"time"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	"github.com/urfave/cli/v2"
)

const satsPerBTC = 100_000_000

func newWalletClient(cctx *cli.Context) rpc.WalletManagerServiceClient {
	addr := cctx.String("rpcserver")
	url := fmt.Sprintf("http://%s", addr)
	return rpc.NewWalletManagerServiceClient(
		http.DefaultClient,
		url,
		connect.WithGRPC(),
	)
}

// resolveWalletID returns the positional wallet-id arg, falling back to the
// active wallet ID from GetWalletStatus when no arg was given. Returns a
// friendly error if no wallet is active.
func resolveWalletID(cctx *cli.Context, client rpc.WalletManagerServiceClient) (string, error) {
	if cctx.NArg() >= 1 {
		return cctx.Args().First(), nil
	}
	resp, err := client.GetWalletStatus(cctx.Context, connect.NewRequest(&pb.GetWalletStatusRequest{}))
	if err != nil {
		return "", fmt.Errorf("get wallet status: %w", err)
	}
	if !resp.Msg.HasWallet || resp.Msg.ActiveWalletId == "" {
		return "", fmt.Errorf("no active wallet — pass a wallet id or run `wallet setactive <id>`")
	}
	return resp.Msg.ActiveWalletId, nil
}

// confirmOrAbort prompts on stdin unless `--yes` was passed. Returns an error
// if the user declines.
func confirmOrAbort(cctx *cli.Context, prompt string) error {
	if cctx.Bool("yes") {
		return nil
	}
	fmt.Print(prompt + " [y/N] ")
	if !confirmYes() {
		return fmt.Errorf("aborted")
	}
	return nil
}

func satsToBtc(sats float64) string {
	return fmt.Sprintf("%.8f", sats/float64(satsPerBTC))
}

func satsToBtcInt(sats int64) string {
	return fmt.Sprintf("%.8f", float64(sats)/float64(satsPerBTC))
}

var walletCommand = &cli.Command{
	Name:  "wallet",
	Usage: "Manage wallets",
	Subcommands: []*cli.Command{
		walletStatusCommand,
		walletCreateCommand,
		walletListCommand,
		walletSetActiveCommand,
		walletDeleteCommand,
		walletLockCommand,
		walletUnlockCommand,
		walletEncryptCommand,
		walletChangePasswordCommand,
		walletRemoveEncryptionCommand,
		walletRenameCommand,
		walletSeedCommand,
		walletBalanceCommand,
		walletNewAddressCommand,
		walletAddressesCommand,
		walletTransactionsCommand,
		walletUnspentCommand,
		walletSendCommand,
		walletTxCommand,
		walletBumpFeeCommand,
		walletDeriveCommand,
		walletWatchOnlyCreateCommand,
		walletCoreCreateCommand,
		walletEnsureCoreCommand,
	},
}

var walletStatusCommand = &cli.Command{
	Name:  "status",
	Usage: "Show wallet status",
	Action: func(cctx *cli.Context) error {
		client := newWalletClient(cctx)
		resp, err := client.GetWalletStatus(cctx.Context, connect.NewRequest(&pb.GetWalletStatusRequest{}))
		if err != nil {
			return err
		}

		s := resp.Msg
		if !s.HasWallet {
			fmt.Println("no wallet is created yet. would you like to create a wallet now? [Y/n]")
			if confirmYes() {
				return walletCreateCommand.Action(cctx)
			}
			return nil
		}

		fmt.Printf("has wallet:  %v\n", s.HasWallet)
		fmt.Printf("encrypted:   %v\n", s.Encrypted)
		fmt.Printf("unlocked:    %v\n", s.Unlocked)
		if s.ActiveWalletId != "" {
			fmt.Printf("active:      %s\n", s.ActiveWalletId)
		}
		return nil
	},
}

var walletCreateCommand = &cli.Command{
	Name:  "create",
	Usage: "Generate a new wallet",
	Flags: []cli.Flag{
		&cli.StringFlag{
			Name:  "name",
			Usage: "wallet name",
			Value: "Enforcer Wallet",
		},
		&cli.StringFlag{
			Name:  "mnemonic",
			Usage: "custom BIP39 mnemonic (optional, generates new if empty)",
		},
		&cli.StringFlag{
			Name:  "passphrase",
			Usage: "BIP39 passphrase (optional)",
		},
	},
	Action: func(cctx *cli.Context) error {
		client := newWalletClient(cctx)
		resp, err := client.GenerateWallet(cctx.Context, connect.NewRequest(&pb.GenerateWalletRequest{
			Name:           cctx.String("name"),
			CustomMnemonic: cctx.String("mnemonic"),
			Passphrase:     cctx.String("passphrase"),
		}))
		if err != nil {
			return err
		}

		fmt.Printf("wallet created: %s\n", resp.Msg.WalletId)
		fmt.Printf("\n⚠️  BACK UP YOUR MNEMONIC:\n\n  %s\n\n", resp.Msg.Mnemonic)
		return nil
	},
}

var walletListCommand = &cli.Command{
	Name:  "list",
	Usage: "List all wallets",
	Flags: []cli.Flag{
		&cli.BoolFlag{
			Name:    "verbose",
			Aliases: []string{"v"},
			Usage:   "include gradient JSON column",
		},
	},
	Action: func(cctx *cli.Context) error {
		client := newWalletClient(cctx)
		resp, err := client.ListWallets(cctx.Context, connect.NewRequest(&pb.ListWalletsRequest{}))
		if err != nil {
			return err
		}

		if len(resp.Msg.Wallets) == 0 {
			fmt.Println("no wallets")
			return nil
		}

		activeID := resp.Msg.ActiveWalletId
		tw := tabwriter.NewWriter(os.Stdout, 0, 2, 2, ' ', 0)
		verbose := cctx.Bool("verbose")
		if verbose {
			_, _ = fmt.Fprintln(tw, "ACTIVE\tID\tNAME\tTYPE\tCREATED\tBIP47\tGRADIENT")
		} else {
			_, _ = fmt.Fprintln(tw, "ACTIVE\tID\tNAME\tTYPE\tCREATED\tBIP47")
		}
		for _, w := range resp.Msg.Wallets {
			marker := " "
			if w.Id == activeID {
				marker = "*"
			}
			bip47 := w.Bip47PaymentCode
			if bip47 == "" {
				bip47 = "-"
			}
			if verbose {
				grad := w.GradientJson
				if grad == "" {
					grad = "-"
				}
				_, _ = fmt.Fprintf(tw, "%s\t%s\t%s\t%s\t%s\t%s\t%s\n", marker, w.Id, w.Name, w.WalletType, w.CreatedAt, bip47, grad)
			} else {
				_, _ = fmt.Fprintf(tw, "%s\t%s\t%s\t%s\t%s\t%s\n", marker, w.Id, w.Name, w.WalletType, w.CreatedAt, bip47)
			}
		}
		return tw.Flush()
	},
}

var walletSetActiveCommand = &cli.Command{
	Name:      "setactive",
	Usage:     "Set the active wallet",
	ArgsUsage: "<wallet-id>",
	Action: func(cctx *cli.Context) error {
		if cctx.NArg() < 1 {
			return fmt.Errorf("usage: orchestratorctl wallet setactive <wallet-id>")
		}

		client := newWalletClient(cctx)
		_, err := client.SwitchWallet(cctx.Context, connect.NewRequest(&pb.SwitchWalletRequest{
			WalletId: cctx.Args().First(),
		}))
		if err != nil {
			return err
		}

		fmt.Printf("active wallet set to %s\n", cctx.Args().First())
		return nil
	},
}

var walletDeleteCommand = &cli.Command{
	Name:      "delete",
	Usage:     "Delete a wallet",
	ArgsUsage: "<wallet-id>",
	Flags: []cli.Flag{
		&cli.BoolFlag{
			Name:  "all",
			Usage: "delete ALL wallets (ignores wallet-id argument)",
		},
	},
	Action: func(cctx *cli.Context) error {
		client := newWalletClient(cctx)

		if cctx.Bool("all") {
			fmt.Print("delete ALL wallets? this cannot be undone. [y/N] ")
			if !confirmYes() {
				return fmt.Errorf("aborted")
			}
			_, err := client.DeleteAllWallets(cctx.Context, connect.NewRequest(&pb.DeleteAllWalletsRequest{}))
			if err != nil {
				return err
			}
			fmt.Println("all wallets deleted")
			return nil
		}

		if cctx.NArg() < 1 {
			return fmt.Errorf("usage: orchestratorctl wallet delete <wallet-id> [--all]")
		}

		walletID := cctx.Args().First()
		_, err := client.DeleteWallet(cctx.Context, connect.NewRequest(&pb.DeleteWalletRequest{
			WalletId: walletID,
		}))
		if err != nil {
			return err
		}

		fmt.Printf("deleted %s\n", walletID)
		return nil
	},
}

var walletLockCommand = &cli.Command{
	Name:  "lock",
	Usage: "Lock the wallet",
	Action: func(cctx *cli.Context) error {
		client := newWalletClient(cctx)
		_, err := client.LockWallet(cctx.Context, connect.NewRequest(&pb.LockWalletRequest{}))
		if err != nil {
			return err
		}
		fmt.Println("wallet locked")
		return nil
	},
}

var walletUnlockCommand = &cli.Command{
	Name:  "unlock",
	Usage: "Unlock the wallet with a password",
	Flags: []cli.Flag{
		&cli.StringFlag{
			Name:     "password",
			Usage:    "encryption password",
			Required: true,
		},
	},
	Action: func(cctx *cli.Context) error {
		client := newWalletClient(cctx)
		_, err := client.UnlockWallet(cctx.Context, connect.NewRequest(&pb.UnlockWalletRequest{
			Password: cctx.String("password"),
		}))
		if err != nil {
			return err
		}
		fmt.Println("wallet unlocked")
		return nil
	},
}

var walletEncryptCommand = &cli.Command{
	Name:  "encrypt",
	Usage: "Encrypt the wallet with a password",
	Flags: []cli.Flag{
		&cli.StringFlag{
			Name:     "password",
			Usage:    "encryption password",
			Required: true,
		},
	},
	Action: func(cctx *cli.Context) error {
		client := newWalletClient(cctx)
		_, err := client.EncryptWallet(cctx.Context, connect.NewRequest(&pb.EncryptWalletRequest{
			Password: cctx.String("password"),
		}))
		if err != nil {
			return err
		}
		fmt.Println("wallet encrypted")
		return nil
	},
}

var walletChangePasswordCommand = &cli.Command{
	Name:  "change-password",
	Usage: "Change the wallet encryption password",
	Flags: []cli.Flag{
		&cli.StringFlag{Name: "old", Usage: "current password", Required: true},
		&cli.StringFlag{Name: "new", Usage: "new password", Required: true},
		&cli.BoolFlag{Name: "yes", Usage: "skip the confirmation prompt"},
	},
	Action: func(cctx *cli.Context) error {
		if err := confirmOrAbort(cctx, "change wallet encryption password?"); err != nil {
			return err
		}
		client := newWalletClient(cctx)
		_, err := client.ChangePassword(cctx.Context, connect.NewRequest(&pb.ChangePasswordRequest{
			OldPassword: cctx.String("old"),
			NewPassword: cctx.String("new"),
		}))
		if err != nil {
			return err
		}
		fmt.Println("password changed")
		return nil
	},
}

var walletRemoveEncryptionCommand = &cli.Command{
	Name:  "remove-encryption",
	Usage: "Remove wallet encryption (keeps funds, removes password)",
	Flags: []cli.Flag{
		&cli.StringFlag{Name: "password", Usage: "current password", Required: true},
		&cli.BoolFlag{Name: "yes", Usage: "skip the confirmation prompt"},
	},
	Action: func(cctx *cli.Context) error {
		if err := confirmOrAbort(cctx, "remove wallet encryption (wallet will become unencrypted)?"); err != nil {
			return err
		}
		client := newWalletClient(cctx)
		_, err := client.RemoveEncryption(cctx.Context, connect.NewRequest(&pb.RemoveEncryptionRequest{
			Password: cctx.String("password"),
		}))
		if err != nil {
			return err
		}
		fmt.Println("encryption removed")
		return nil
	},
}

var walletRenameCommand = &cli.Command{
	Name:      "rename",
	Usage:     "Update a wallet's name or gradient metadata",
	ArgsUsage: "<wallet-id>",
	Flags: []cli.Flag{
		&cli.StringFlag{Name: "name", Usage: "new wallet name", Required: true},
		&cli.StringFlag{Name: "gradient", Usage: "gradient JSON (optional)"},
	},
	Action: func(cctx *cli.Context) error {
		if cctx.NArg() < 1 {
			return fmt.Errorf("usage: orchestratorctl wallet rename <wallet-id> --name NAME [--gradient JSON]")
		}
		client := newWalletClient(cctx)
		_, err := client.UpdateWalletMetadata(cctx.Context, connect.NewRequest(&pb.UpdateWalletMetadataRequest{
			WalletId:     cctx.Args().First(),
			Name:         cctx.String("name"),
			GradientJson: cctx.String("gradient"),
		}))
		if err != nil {
			return err
		}
		fmt.Println("metadata updated")
		return nil
	},
}

var walletSeedCommand = &cli.Command{
	Name:      "seed",
	Aliases:   []string{"mnemonic"},
	Usage:     "Show the seed + mnemonic for a wallet (SENSITIVE)",
	ArgsUsage: "<wallet-id>",
	Description: "Prints the 64-byte BIP39 seed as hex and the mnemonic words.\n" +
		"Pass an empty wallet-id or '-' to read the active enforcer wallet.",
	Action: func(cctx *cli.Context) error {
		walletID := ""
		if cctx.NArg() >= 1 && cctx.Args().First() != "-" {
			walletID = cctx.Args().First()
		}

		client := newWalletClient(cctx)
		resp, err := client.GetWalletSeed(cctx.Context, connect.NewRequest(&pb.GetWalletSeedRequest{
			WalletId: walletID,
		}))
		if err != nil {
			return err
		}

		fmt.Print("⚠️  SENSITIVE — do not share!\n\n")
		fmt.Printf("seed:     %s\n", resp.Msg.SeedHex)
		if resp.Msg.Mnemonic != "" {
			fmt.Printf("mnemonic: %s\n", resp.Msg.Mnemonic)
		}
		return nil
	},
}

var walletBalanceCommand = &cli.Command{
	Name:      "balance",
	Usage:     "Show the balance of a wallet",
	ArgsUsage: "[wallet-id]",
	Action: func(cctx *cli.Context) error {
		client := newWalletClient(cctx)
		walletID, err := resolveWalletID(cctx, client)
		if err != nil {
			return err
		}
		resp, err := client.GetBalance(cctx.Context, connect.NewRequest(&pb.GetBalanceRequest{WalletId: walletID}))
		if err != nil {
			return err
		}
		fmt.Printf("confirmed:   %s BTC (%.0f sats)\n", satsToBtc(resp.Msg.ConfirmedSats), resp.Msg.ConfirmedSats)
		fmt.Printf("unconfirmed: %s BTC (%.0f sats)\n", satsToBtc(resp.Msg.UnconfirmedSats), resp.Msg.UnconfirmedSats)
		return nil
	},
}

var walletNewAddressCommand = &cli.Command{
	Name:      "new-address",
	Usage:     "Generate a fresh receive address",
	ArgsUsage: "[wallet-id]",
	Action: func(cctx *cli.Context) error {
		client := newWalletClient(cctx)
		walletID, err := resolveWalletID(cctx, client)
		if err != nil {
			return err
		}
		resp, err := client.GetNewAddress(cctx.Context, connect.NewRequest(&pb.GetNewAddressRequest{WalletId: walletID}))
		if err != nil {
			return err
		}
		fmt.Println(resp.Msg.Address)
		return nil
	},
}

var walletAddressesCommand = &cli.Command{
	Name:      "addresses",
	Usage:     "List receive addresses for a wallet",
	ArgsUsage: "[wallet-id]",
	Action: func(cctx *cli.Context) error {
		client := newWalletClient(cctx)
		walletID, err := resolveWalletID(cctx, client)
		if err != nil {
			return err
		}
		resp, err := client.ListReceiveAddresses(cctx.Context, connect.NewRequest(&pb.ListReceiveAddressesRequest{WalletId: walletID}))
		if err != nil {
			return err
		}
		if len(resp.Msg.Addresses) == 0 {
			fmt.Println("no receive addresses")
			return nil
		}
		tw := tabwriter.NewWriter(os.Stdout, 0, 2, 2, ' ', 0)
		_, _ = fmt.Fprintln(tw, "ADDRESS\tRECEIVED (BTC)\tTX COUNT\tLABEL")
		for _, a := range resp.Msg.Addresses {
			label := a.Label
			if label == "" {
				label = "-"
			}
			_, _ = fmt.Fprintf(tw, "%s\t%s\t%d\t%s\n", a.Address, satsToBtcInt(a.AmountSats), a.TxCount, label)
		}
		return tw.Flush()
	},
}

var walletTransactionsCommand = &cli.Command{
	Name:      "transactions",
	Aliases:   []string{"txs"},
	Usage:     "List recent transactions",
	ArgsUsage: "[wallet-id]",
	Flags: []cli.Flag{
		&cli.IntFlag{Name: "count", Usage: "max transactions to return", Value: 100},
	},
	Action: func(cctx *cli.Context) error {
		client := newWalletClient(cctx)
		walletID, err := resolveWalletID(cctx, client)
		if err != nil {
			return err
		}
		resp, err := client.ListTransactions(cctx.Context, connect.NewRequest(&pb.ListTransactionsRequest{
			WalletId: walletID,
			Count:    int32(cctx.Int("count")),
		}))
		if err != nil {
			return err
		}
		if len(resp.Msg.Transactions) == 0 {
			fmt.Println("no transactions")
			return nil
		}
		tw := tabwriter.NewWriter(os.Stdout, 0, 2, 2, ' ', 0)
		_, _ = fmt.Fprintln(tw, "TIME\tCATEGORY\tAMOUNT (BTC)\tCONF\tTXID")
		for _, t := range resp.Msg.Transactions {
			ts := "-"
			if t.Time != 0 {
				ts = time.Unix(t.Time, 0).Format("2006-01-02 15:04")
			}
			_, _ = fmt.Fprintf(tw, "%s\t%s\t%s\t%d\t%s\n", ts, t.Category, satsToBtcInt(t.AmountSats), t.Confirmations, t.Txid)
		}
		return tw.Flush()
	},
}

var walletUnspentCommand = &cli.Command{
	Name:      "unspent",
	Aliases:   []string{"utxos"},
	Usage:     "List unspent outputs owned by a wallet",
	ArgsUsage: "[wallet-id]",
	Action: func(cctx *cli.Context) error {
		client := newWalletClient(cctx)
		walletID, err := resolveWalletID(cctx, client)
		if err != nil {
			return err
		}
		resp, err := client.ListUnspent(cctx.Context, connect.NewRequest(&pb.ListUnspentRequest{WalletId: walletID}))
		if err != nil {
			return err
		}
		if len(resp.Msg.Utxos) == 0 {
			fmt.Println("no unspent outputs")
			return nil
		}
		tw := tabwriter.NewWriter(os.Stdout, 0, 2, 2, ' ', 0)
		_, _ = fmt.Fprintln(tw, "OUTPOINT\tADDRESS\tBTC\tCONF\tLABEL")
		for _, u := range resp.Msg.Utxos {
			label := u.Label
			if label == "" {
				label = "-"
			}
			_, _ = fmt.Fprintf(tw, "%s:%d\t%s\t%s\t%d\t%s\n", u.Txid, u.Vout, u.Address, satsToBtcInt(u.AmountSats), u.Confirmations, label)
		}
		return tw.Flush()
	},
}

var walletSendCommand = &cli.Command{
	Name:      "send",
	Usage:     "Send sats from the wallet",
	ArgsUsage: "[wallet-id]",
	Description: "Single recipient via --to/--sats, or multi-recipient via --destination=ADDR:SATS (repeatable).\n" +
		"Either a feerate (--fee-rate, sat/vB) or a fixed fee (--fixed-fee-sats) may be given.",
	Flags: []cli.Flag{
		&cli.StringFlag{Name: "to", Usage: "recipient address (single-recipient shortcut)"},
		&cli.Int64Flag{Name: "sats", Usage: "amount in satoshis for --to"},
		&cli.StringSliceFlag{Name: "destination", Usage: "ADDR:SATS (repeatable)"},
		&cli.Int64Flag{Name: "fee-rate", Usage: "sat/vbyte (0 = default)"},
		&cli.Int64Flag{Name: "fixed-fee-sats", Usage: "exact fee in sats"},
		&cli.BoolFlag{Name: "subtract-fee", Usage: "deduct fee from the recipient amount"},
		&cli.StringFlag{Name: "op-return", Usage: "OP_RETURN payload, UTF-8"},
		&cli.StringFlag{Name: "op-return-hex", Usage: "OP_RETURN payload, raw hex (takes precedence over --op-return)"},
		&cli.BoolFlag{Name: "yes", Usage: "skip the confirmation prompt"},
	},
	Action: func(cctx *cli.Context) error {
		client := newWalletClient(cctx)
		walletID, err := resolveWalletID(cctx, client)
		if err != nil {
			return err
		}

		destinations, err := parseSendDestinations(cctx)
		if err != nil {
			return err
		}

		opReturnHex := cctx.String("op-return-hex")
		if opReturnHex == "" && cctx.String("op-return") != "" {
			opReturnHex = hexEncode([]byte(cctx.String("op-return")))
		}

		summary := describeSend(walletID, destinations, cctx)
		fmt.Println(summary)
		if err := confirmOrAbort(cctx, "send?"); err != nil {
			return err
		}

		resp, err := client.SendTransaction(cctx.Context, connect.NewRequest(&pb.SendTransactionRequest{
			WalletId:              walletID,
			Destinations:          destinations,
			FeeRateSatPerVbyte:    cctx.Int64("fee-rate"),
			FixedFeeSats:          cctx.Int64("fixed-fee-sats"),
			SubtractFeeFromAmount: cctx.Bool("subtract-fee"),
			OpReturnHex:           opReturnHex,
		}))
		if err != nil {
			return err
		}
		fmt.Printf("sent: %s\n", resp.Msg.Txid)
		return nil
	},
}

var walletTxCommand = &cli.Command{
	Name:      "tx",
	Usage:     "Show transaction details by txid",
	ArgsUsage: "[wallet-id] <txid>",
	Action: func(cctx *cli.Context) error {
		if cctx.NArg() == 0 {
			return fmt.Errorf("usage: orchestratorctl wallet tx [wallet-id] <txid>")
		}
		client := newWalletClient(cctx)

		var walletID, txid string
		switch cctx.NArg() {
		case 1:
			id, err := resolveWalletID(cctx, client)
			if err != nil {
				return err
			}
			walletID = id
			txid = cctx.Args().First()
		default:
			walletID = cctx.Args().First()
			txid = cctx.Args().Get(1)
		}

		resp, err := client.GetTransactionDetails(cctx.Context, connect.NewRequest(&pb.GetTransactionDetailsRequest{
			WalletId: walletID,
			Txid:     txid,
		}))
		if err != nil {
			return err
		}
		m := resp.Msg
		fmt.Printf("txid:           %s\n", m.Transaction.Txid)
		fmt.Printf("confirmations:  %d\n", m.Confirmations)
		fmt.Printf("blockhash:      %s\n", m.Blockhash)
		if m.BlockTime != 0 {
			fmt.Printf("block_time:     %s\n", time.Unix(m.BlockTime, 0).Format(time.RFC3339))
		}
		fmt.Printf("size:           %d bytes (%d vB, %d WU)\n", m.SizeBytes, m.VsizeVbytes, m.WeightWu)
		fmt.Printf("fee:            %s BTC (%d sats @ %.2f sat/vB)\n", satsToBtcInt(m.FeeSats), m.FeeSats, m.FeeRateSatVb)
		fmt.Printf("total input:    %s BTC\n", satsToBtcInt(m.TotalInputSats))
		fmt.Printf("total output:   %s BTC\n", satsToBtcInt(m.TotalOutputSats))

		if len(m.Inputs) > 0 {
			fmt.Println("\ninputs:")
			tw := tabwriter.NewWriter(os.Stdout, 0, 2, 2, ' ', 0)
			_, _ = fmt.Fprintln(tw, "  IDX\tPREV\tADDRESS\tSATS")
			for _, in := range m.Inputs {
				_, _ = fmt.Fprintf(tw, "  %d\t%s:%d\t%s\t%d\n", in.Index, in.PrevTxid, in.PrevVout, in.Address, in.ValueSats)
			}
			_ = tw.Flush()
		}
		if len(m.Outputs) > 0 {
			fmt.Println("\noutputs:")
			tw := tabwriter.NewWriter(os.Stdout, 0, 2, 2, ' ', 0)
			_, _ = fmt.Fprintln(tw, "  IDX\tADDRESS\tSATS\tTYPE")
			for _, out := range m.Outputs {
				_, _ = fmt.Fprintf(tw, "  %d\t%s\t%d\t%s\n", out.Index, out.Address, out.ValueSats, out.ScriptType)
			}
			_ = tw.Flush()
		}
		return nil
	},
}

var walletBumpFeeCommand = &cli.Command{
	Name:      "bump-fee",
	Usage:     "Replace a transaction with a higher-fee version (RBF)",
	ArgsUsage: "[wallet-id] <txid>",
	Flags: []cli.Flag{
		&cli.Int64Flag{Name: "fee-rate", Usage: "new fee rate in sat/vB (0 = automatic)"},
	},
	Action: func(cctx *cli.Context) error {
		if cctx.NArg() == 0 {
			return fmt.Errorf("usage: orchestratorctl wallet bump-fee [wallet-id] <txid> [--fee-rate N]")
		}
		client := newWalletClient(cctx)
		var walletID, txid string
		switch cctx.NArg() {
		case 1:
			id, err := resolveWalletID(cctx, client)
			if err != nil {
				return err
			}
			walletID = id
			txid = cctx.Args().First()
		default:
			walletID = cctx.Args().First()
			txid = cctx.Args().Get(1)
		}

		resp, err := client.BumpFee(cctx.Context, connect.NewRequest(&pb.BumpFeeRequest{
			WalletId:   walletID,
			Txid:       txid,
			NewFeeRate: cctx.Int64("fee-rate"),
		}))
		if err != nil {
			return err
		}
		fmt.Printf("replaced txid: %s\n", resp.Msg.NewTxid)
		return nil
	},
}

var walletDeriveCommand = &cli.Command{
	Name:      "derive",
	Usage:     "Derive a range of addresses without consuming them",
	ArgsUsage: "[wallet-id]",
	Flags: []cli.Flag{
		&cli.IntFlag{Name: "start", Usage: "start index (inclusive)", Value: 0},
		&cli.IntFlag{Name: "count", Usage: "how many to derive", Value: 10},
	},
	Action: func(cctx *cli.Context) error {
		client := newWalletClient(cctx)
		walletID, err := resolveWalletID(cctx, client)
		if err != nil {
			return err
		}
		resp, err := client.DeriveAddresses(cctx.Context, connect.NewRequest(&pb.DeriveAddressesRequest{
			WalletId:   walletID,
			StartIndex: int32(cctx.Int("start")),
			Count:      int32(cctx.Int("count")),
		}))
		if err != nil {
			return err
		}
		for i, a := range resp.Msg.Addresses {
			fmt.Printf("%d\t%s\n", int(cctx.Int("start"))+i, a)
		}
		return nil
	},
}

var walletWatchOnlyCreateCommand = &cli.Command{
	Name:  "watch-only-create",
	Usage: "Create a watch-only wallet from an xpub or descriptor",
	Flags: []cli.Flag{
		&cli.StringFlag{Name: "name", Usage: "wallet name", Required: true},
		&cli.StringFlag{Name: "xpub-or-descriptor", Usage: "xpub or output descriptor", Required: true},
		&cli.StringFlag{Name: "gradient", Usage: "gradient JSON (optional)"},
	},
	Action: func(cctx *cli.Context) error {
		client := newWalletClient(cctx)
		resp, err := client.CreateWatchOnlyWallet(cctx.Context, connect.NewRequest(&pb.CreateWatchOnlyWalletRequest{
			Name:             cctx.String("name"),
			XpubOrDescriptor: cctx.String("xpub-or-descriptor"),
			GradientJson:     cctx.String("gradient"),
		}))
		if err != nil {
			return err
		}
		fmt.Printf("watch-only wallet created: %s\n", resp.Msg.WalletId)
		return nil
	},
}

var walletCoreCreateCommand = &cli.Command{
	Name:      "core-create",
	Usage:     "Materialise a wallet.json entry as a Bitcoin Core descriptor wallet",
	ArgsUsage: "[wallet-id]",
	Action: func(cctx *cli.Context) error {
		client := newWalletClient(cctx)
		walletID, err := resolveWalletID(cctx, client)
		if err != nil {
			return err
		}
		resp, err := client.CreateBitcoinCoreWallet(cctx.Context, connect.NewRequest(&pb.CreateBitcoinCoreWalletRequest{
			WalletId: walletID,
		}))
		if err != nil {
			return err
		}
		fmt.Printf("core wallet ready: %s\n", resp.Msg.CoreWalletName)
		return nil
	},
}

var walletEnsureCoreCommand = &cli.Command{
	Name:  "ensure-core",
	Usage: "Create missing Bitcoin Core wallets for every entry in wallet.json",
	Action: func(cctx *cli.Context) error {
		client := newWalletClient(cctx)
		resp, err := client.EnsureCoreWallets(cctx.Context, connect.NewRequest(&pb.EnsureCoreWalletsRequest{}))
		if err != nil {
			return err
		}
		fmt.Printf("synced %d wallet(s)\n", resp.Msg.SyncedCount)
		return nil
	},
}

// parseSendDestinations combines --to/--sats and --destination flags into a
// single map. Returns an error if no destination is provided or values can't
// be parsed.
func parseSendDestinations(cctx *cli.Context) (map[string]int64, error) {
	dests := map[string]int64{}
	if to := cctx.String("to"); to != "" {
		sats := cctx.Int64("sats")
		if sats <= 0 {
			return nil, fmt.Errorf("--to requires --sats > 0")
		}
		dests[to] = sats
	}
	for _, d := range cctx.StringSlice("destination") {
		addr, satsStr, ok := strings.Cut(d, ":")
		if !ok {
			return nil, fmt.Errorf("invalid --destination %q (expected ADDR:SATS)", d)
		}
		sats, err := strconv.ParseInt(satsStr, 10, 64)
		if err != nil {
			return nil, fmt.Errorf("invalid sats in --destination %q: %w", d, err)
		}
		if sats <= 0 {
			return nil, fmt.Errorf("destination %q has non-positive sats", addr)
		}
		if _, exists := dests[addr]; exists {
			return nil, fmt.Errorf("duplicate destination address %q", addr)
		}
		dests[addr] = sats
	}
	if len(dests) == 0 {
		return nil, fmt.Errorf("no destinations — pass --to/--sats or --destination=ADDR:SATS")
	}
	return dests, nil
}

// describeSend returns a human-readable summary of a send request for use in
// the pre-confirmation prompt.
func describeSend(walletID string, dests map[string]int64, cctx *cli.Context) string {
	var b strings.Builder
	fmt.Fprintf(&b, "wallet: %s\n", walletID)
	for addr, sats := range dests {
		fmt.Fprintf(&b, "  → %s: %s BTC (%d sats)\n", addr, satsToBtcInt(sats), sats)
	}
	if fr := cctx.Int64("fee-rate"); fr > 0 {
		fmt.Fprintf(&b, "fee rate: %d sat/vB\n", fr)
	}
	if ff := cctx.Int64("fixed-fee-sats"); ff > 0 {
		fmt.Fprintf(&b, "fixed fee: %d sats\n", ff)
	}
	if cctx.Bool("subtract-fee") {
		b.WriteString("subtract fee from amount: yes\n")
	}
	if op := cctx.String("op-return"); op != "" {
		fmt.Fprintf(&b, "op_return: %s\n", op)
	}
	if op := cctx.String("op-return-hex"); op != "" {
		fmt.Fprintf(&b, "op_return_hex: %s\n", op)
	}
	return b.String()
}

// hexEncode is a tiny wrapper that avoids pulling in the full encoding/hex
// import surface for a single call site.
func hexEncode(data []byte) string {
	const hexDigits = "0123456789abcdef"
	out := make([]byte, len(data)*2)
	for i, b := range data {
		out[i*2] = hexDigits[b>>4]
		out[i*2+1] = hexDigits[b&0x0f]
	}
	return string(out)
}
