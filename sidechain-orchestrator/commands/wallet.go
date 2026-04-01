package commands

import (
	"fmt"
	"net/http"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	"github.com/urfave/cli/v2"
)

func newWalletClient(cctx *cli.Context) rpc.WalletManagerServiceClient {
	addr := cctx.String("rpcserver")
	url := fmt.Sprintf("http://%s", addr)
	return rpc.NewWalletManagerServiceClient(
		http.DefaultClient,
		url,
		connect.WithGRPC(),
	)
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
		walletMnemonicCommand,
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

		for _, w := range resp.Msg.Wallets {
			fmt.Printf("  %-20s %-14s %s\n", w.Name, w.WalletType, w.Id)
		}
		return nil
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
		_, err := client.SetActiveWallet(cctx.Context, connect.NewRequest(&pb.SetActiveWalletRequest{
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

var walletMnemonicCommand = &cli.Command{
	Name:      "mnemonic",
	Usage:     "Show the mnemonic for a wallet",
	ArgsUsage: "<wallet-id>",
	Action: func(cctx *cli.Context) error {
		if cctx.NArg() < 1 {
			return fmt.Errorf("usage: orchestratorctl wallet mnemonic <wallet-id>")
		}

		client := newWalletClient(cctx)

		resp, err := client.GetMnemonic(cctx.Context, connect.NewRequest(&pb.GetMnemonicRequest{
			WalletId: cctx.Args().First(),
		}))
		if err != nil {
			return err
		}

		fmt.Print("⚠️  SENSITIVE — do not share!\n\n")
		fmt.Printf("master:  %s\n", resp.Msg.MasterMnemonic)
		fmt.Printf("L1:      %s\n", resp.Msg.L1Mnemonic)
		for _, sc := range resp.Msg.SidechainMnemonics {
			fmt.Printf("sc[%d] %s: %s\n", sc.Slot, sc.Name, sc.Mnemonic)
		}
		return nil
	},
}
