package commands

import (
	"encoding/hex"
	"fmt"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/m1"
	"github.com/urfave/cli/v2"
)

var m1Command = &cli.Command{
	Name:  "m1",
	Usage: "Build the M1 coinbase output that proposes a sidechain",
	Description: "BIP300 ignores an M1 that is not a coinbase output, so this command " +
		"prints a script for whoever assembles the block. It starts no daemon and " +
		"broadcasts nothing.",
	Flags: []cli.Flag{
		&cli.UintFlag{Name: "slot", Usage: "sidechain slot, 0 to 255", Required: true},
		&cli.StringFlag{Name: "title", Usage: "sidechain title", Required: true},
		&cli.StringFlag{Name: "description", Usage: "sidechain description"},
		&cli.StringFlag{Name: "hashid1", Usage: "release tarball hash, 64 hex characters", Required: true},
		&cli.StringFlag{Name: "hashid2", Usage: "build commit hash, 40 hex characters", Required: true},
	},
	Action: func(cctx *cli.Context) error {
		slot := cctx.Uint("slot")
		if slot > 255 {
			return fmt.Errorf("slot is %d, and a slot holds 0 to 255", slot)
		}

		declaration := m1.Declaration{
			Title:       cctx.String("title"),
			Description: cctx.String("description"),
		}
		if err := fillHash(declaration.HashID1[:], cctx.String("hashid1"), "hashid1"); err != nil {
			return err
		}
		if err := fillHash(declaration.HashID2[:], cctx.String("hashid2"), "hashid2"); err != nil {
			return err
		}

		script, description, err := m1.Script(uint8(slot), declaration)
		if err != nil {
			return err
		}
		hash := m1.DescriptionHash(description)

		fmt.Printf("scriptPubKey: %x\n", script)
		fmt.Printf("value:        0\n")
		fmt.Printf("description:  %x\n", description)
		fmt.Printf("sha256d(D):   %x\n", hash)
		fmt.Printf("\nAdd the output to the coinbase transaction. A miner ACKs it with an M2 that carries sha256d(D).\n")
		return nil
	},
}

func fillHash(dst []byte, value string, name string) error {
	raw, err := hex.DecodeString(value)
	if err != nil {
		return fmt.Errorf("%s is not hex: %w", name, err)
	}
	if len(raw) != len(dst) {
		return fmt.Errorf("%s is %d bytes, and the field holds %d", name, len(raw), len(dst))
	}
	copy(dst, raw)
	return nil
}
