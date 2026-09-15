package commands

import (
	"bytes"
	"context"
	"flag"
	"io"
	"os"
	"path/filepath"
	"strconv"
	"strings"
	"testing"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/psbt"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/stretchr/testify/require"
	"github.com/urfave/cli/v2"
)

const signTestWarning = "This transaction burns Alphanet coins for a claim of real ECX. You cannot reverse this transaction."

func newSignTestContext(t *testing.T, f *burnTestFlow, args ...string) *cli.Context {
	t.Helper()
	set := flag.NewFlagSet("sign-psbt", flag.ContinueOnError)
	for _, value := range walletSignPSBTCommand.Flags {
		require.NoError(t, value.Apply(set))
	}
	require.NoError(t, set.Parse(args))
	ctx := cli.NewContext(f.ctx.App, set, nil)
	ctx.Context = context.Background()
	return ctx
}

func newSignTestFlow(t *testing.T, args ...string) (*burnTestFlow, *cli.Context, burnMultisigPackets, string) {
	t.Helper()
	packets := newBurnMultisigPackets(t)
	dir := t.TempDir()
	input, output := filepath.Join(dir, "unsigned.psbt"), filepath.Join(dir, "signed.psbt")
	writeBurnTestPacket(t, input, packets.original, true)
	f := newBurnTestFlow(t)
	setBurnMultisig(f, false)
	f.daemon.wallets.Wallets[0].Multisig.Cosigners[0].Held = true
	f.daemon.wallets.Wallets[0].Multisig.Cosigners[1].Held = true
	f.daemon.signedPSBT = packets.complete
	f.daemon.preview.WarningMessage = signTestWarning
	f.daemon.preview.Outputs[0].Address = burnTestAddress
	for index, output := range f.daemon.preview.Outputs {
		output.Index = int32(index)
	}
	ctx := newSignTestContext(t, f, append([]string{"--psbt-in", input, "--psbt-out", output}, args...)...)
	return f, ctx, packets, output
}

func TestWalletSignPSBTCommandIsPublic(t *testing.T) {
	app := &cli.App{Commands: []*cli.Command{walletCommand}, Writer: io.Discard, ErrWriter: io.Discard}
	require.ErrorContains(t, app.Run([]string{"drivechain-cli", "wallet", "sign-psbt"}), "psbt-in")
}

func TestWalletSignPSBTChecksInputsBeforeWalletCalls(t *testing.T) {
	f, ctx, packets, path := newSignTestFlow(t, "--yes")
	packet, err := psbt.NewFromRawBytes(strings.NewReader(packets.original), true)
	require.NoError(t, err)
	packet.Inputs[0].WitnessUtxo = nil
	text, err := packet.B64Encode()
	require.NoError(t, err)
	writeBurnTestPacket(t, ctx.String("psbt-in"), text, true)

	require.ErrorContains(t, runWalletSignPSBT(ctx, f.client), "PSBT input 0 has no previous-output data")

	require.Empty(t, f.daemon.calls)
	require.Empty(t, f.output.String())
	require.NoFileExists(t, path)
}

func TestWalletSignPSBTShowsThePreviewBeforeApproval(t *testing.T) {
	f, ctx, packets, path := newSignTestFlow(t)
	ctx.App.Reader = burnReaderFunc(func(p []byte) (int, error) {
		require.Nil(t, f.daemon.signed)
		text := f.output.String()
		for _, value := range []string{
			"Wallet: active-wallet", "Output 0: 100000001 satoshis", "Address: " + burnTestAddress,
			"Output 1: 0 satoshis", "OP_RETURN data: " + strconv.Quote(burnTestReceiveAddress),
			"Output 2: 10000 satoshis", "Script: 0014deadbeef", "Network fee: 452 satoshis",
		} {
			require.Contains(t, text, value)
		}
		warning := strings.Index(text, "Warning: "+signTestWarning)
		prompt := strings.Index(text, "Sign this PSBT with the local wallet keys? [y/N]")
		require.GreaterOrEqual(t, warning, 0)
		require.Greater(t, prompt, warning)
		return copy(p, "yes\n"), nil
	})

	require.NoError(t, runWalletSignPSBT(ctx, f.client))

	require.Equal(t, "active-wallet", f.daemon.decoded.WalletId)
	require.Equal(t, f.daemon.decoded.Input, f.daemon.signed.PsbtBase64)
	require.Equal(t, packets.original, f.daemon.signed.PsbtBase64)
	require.Equal(t, "active-wallet", f.daemon.signed.WalletId)
	packet, err := readPSBTFile(path)
	require.NoError(t, err)
	require.Equal(t, packets.complete, packet)
	info, err := os.Stat(path)
	require.NoError(t, err)
	require.Equal(t, os.FileMode(0o600), info.Mode().Perm())
	require.Nil(t, f.daemon.finalized)
	require.Nil(t, f.daemon.broadcast)
	require.Contains(t, f.output.String(), "The command did not broadcast the transaction.")
}

func TestWalletSignPSBTReadsBase64WithAnExplicitWallet(t *testing.T) {
	f, ctx, packets, path := newSignTestFlow(t, "--yes", "other-wallet")
	writeBurnTestPacket(t, ctx.String("psbt-in"), packets.original, false)
	ctx.App.Reader = burnErrorReader{}

	require.NoError(t, runWalletSignPSBT(ctx, f.client))

	require.Equal(t, "other-wallet", f.daemon.decoded.WalletId)
	require.Equal(t, "other-wallet", f.daemon.signed.WalletId)
	require.Equal(t, packets.original, f.daemon.signed.PsbtBase64)
	require.NotContains(t, f.daemon.calls, "status")
	require.NotContains(t, f.output.String(), "[y/N]")
	require.Contains(t, f.output.String(), "Warning: "+signTestWarning)
	packet, err := readPSBTFile(path)
	require.NoError(t, err)
	require.Equal(t, packets.complete, packet)
}

func TestWalletSignPSBTKeepsWarningText(t *testing.T) {
	for _, message := range []string{"", strings.Repeat(signTestWarning+" ", 4)} {
		t.Run(strconv.Quote(message), func(t *testing.T) {
			f, ctx, _, _ := newSignTestFlow(t, "--yes")
			f.daemon.preview.WarningMessage = message
			require.NoError(t, runWalletSignPSBT(ctx, f.client))
			if message == "" {
				require.NotContains(t, f.output.String(), "Warning:")
			} else {
				require.Contains(t, f.output.String(), "Warning: "+message+"\n")
			}
		})
	}
}

func TestWalletSignPSBTChecksApproval(t *testing.T) {
	for _, answer := range []string{"y\n", "YES\n", " yes \n", "no\n", "\n", ""} {
		t.Run(strconv.Quote(answer), func(t *testing.T) {
			f, ctx, _, path := newSignTestFlow(t)
			ctx.App.Reader = strings.NewReader(answer)
			err := runWalletSignPSBT(ctx, f.client)
			if strings.EqualFold(strings.TrimSpace(answer), "y") || strings.EqualFold(strings.TrimSpace(answer), "yes") {
				require.NoError(t, err)
				require.NotNil(t, f.daemon.signed)
			} else {
				require.Error(t, err)
				require.Nil(t, f.daemon.signed)
				_, err := os.Stat(path)
				require.ErrorIs(t, err, os.ErrNotExist)
			}
			require.Nil(t, f.daemon.broadcast)
		})
	}
}

func TestWalletSignPSBTRejectsUnsupportedWallets(t *testing.T) {
	for _, walletType := range []pb.WalletType{
		pb.WalletType_WALLET_TYPE_ENFORCER, pb.WalletType_WALLET_TYPE_UNSPECIFIED,
	} {
		t.Run(walletType.String(), func(t *testing.T) {
			f, ctx, _, _ := newSignTestFlow(t, "--yes")
			f.daemon.wallets.Wallets[0].WalletType = walletType
			require.ErrorContains(t, runWalletSignPSBT(ctx, f.client), "Electrum or Bitcoin Core wallet")
			require.Nil(t, f.daemon.decoded)
			require.Nil(t, f.daemon.signed)
		})
	}
}

func TestWalletSignPSBTRejectsCoreWalletsWithoutLocalKeys(t *testing.T) {
	cases := map[string]struct {
		watchOnly    bool
		hardwareType string
		fingerprint  string
	}{
		"watch-only":           {watchOnly: true},
		"hardware device":      {hardwareType: "ledger"},
		"hardware fingerprint": {fingerprint: "12345678"},
	}
	for name, tc := range cases {
		t.Run(name, func(t *testing.T) {
			f, ctx, packets, path := newSignTestFlow(t, "--yes")
			selected := f.daemon.wallets.Wallets[0]
			selected.WalletType = pb.WalletType_WALLET_TYPE_BITCOIN_CORE
			selected.Multisig = nil
			selected.WatchOnly = tc.watchOnly
			selected.HardwareDeviceType = tc.hardwareType
			selected.HardwareFingerprint = tc.fingerprint
			f.daemon.signedPSBT = packets.original

			require.ErrorContains(t, runWalletSignPSBT(ctx, f.client), "local private keys")
			require.Nil(t, f.daemon.decoded)
			require.Nil(t, f.daemon.signed)
			require.NoFileExists(t, path)
		})
	}
}

func TestWalletSignPSBTKeepsPartialElectrumSignatures(t *testing.T) {
	f, ctx, packets, path := newSignTestFlow(t, "--yes")
	f.daemon.wallets.Wallets[0].WatchOnly = false
	f.daemon.wallets.Wallets[0].Multisig.Cosigners[1].Held = false
	f.daemon.signedPSBT = packets.first

	require.NoError(t, runWalletSignPSBT(ctx, f.client))
	stored, err := readPSBTFile(path)
	require.NoError(t, err)
	require.Equal(t, packets.first, stored)
	require.Nil(t, f.daemon.finalized)
	require.Nil(t, f.daemon.broadcast)
}

func TestWalletSignPSBTReturnsRPCFailures(t *testing.T) {
	for _, stage := range []string{"status", "wallets", "decode", "sign"} {
		t.Run(stage, func(t *testing.T) {
			f, ctx, _, path := newSignTestFlow(t, "--yes")
			f.daemon.fail = stage
			require.ErrorContains(t, runWalletSignPSBT(ctx, f.client), "RPC failed")
			require.Nil(t, f.daemon.broadcast)
			_, err := os.Stat(path)
			require.ErrorIs(t, err, os.ErrNotExist)
		})
	}
}

func TestWalletSignPSBTReturnsInputAndFileFailures(t *testing.T) {
	for _, failure := range []string{"missing input", "invalid input", "missing output directory", "approval", "signed data"} {
		t.Run(failure, func(t *testing.T) {
			f, ctx, _, path := newSignTestFlow(t)
			switch failure {
			case "missing input":
				require.NoError(t, os.Remove(ctx.String("psbt-in")))
			case "invalid input":
				require.NoError(t, os.WriteFile(ctx.String("psbt-in"), []byte("invalid"), 0o600))
			case "missing output directory":
				require.NoError(t, ctx.Set("psbt-out", filepath.Join(path, "missing", "signed.psbt")))
			case "approval":
				ctx.App.Reader = burnErrorReader{}
			case "signed data":
				f.daemon.signedPSBT = "invalid base64"
			}
			require.Error(t, runWalletSignPSBT(ctx, f.client))
			require.Nil(t, f.daemon.broadcast)
		})
	}
}

func TestWalletSignPSBTReturnsOutputFailures(t *testing.T) {
	for _, failAt := range []int{1, 2, 3, 4} {
		t.Run(strconv.Itoa(failAt), func(t *testing.T) {
			f, ctx, _, path := newSignTestFlow(t)
			ctx.App.Writer = &burnErrorWriter{failAt: failAt}
			err := runWalletSignPSBT(ctx, f.client)
			require.ErrorContains(t, err, "write failed")
			if failAt < 4 {
				require.Nil(t, f.daemon.signed)
			} else {
				require.NotNil(t, f.daemon.signed)
				_, err := readPSBTFile(path)
				require.NoError(t, err)
			}
			require.Nil(t, f.daemon.broadcast)
		})
	}
}

func TestWalletSignPSBTKeepsAnOldOutputFile(t *testing.T) {
	for _, afterPreview := range []bool{false, true} {
		t.Run(strconv.FormatBool(afterPreview), func(t *testing.T) {
			f, ctx, _, path := newSignTestFlow(t)
			old := []byte("old file")
			if afterPreview {
				ctx.App.Reader = burnReaderFunc(func(p []byte) (int, error) {
					require.NoError(t, os.WriteFile(path, old, 0o600))
					return copy(p, "yes\n"), nil
				})
			} else {
				require.NoError(t, os.WriteFile(path, old, 0o600))
			}
			require.Error(t, runWalletSignPSBT(ctx, f.client))
			actual, err := os.ReadFile(path)
			require.NoError(t, err)
			require.Equal(t, old, actual)
			if !afterPreview {
				require.Empty(t, f.daemon.calls)
			}
			require.Nil(t, f.daemon.broadcast)
		})
	}
}

func TestWalletSignPSBTRejectsAnIncompletePreview(t *testing.T) {
	for name, change := range map[string]func(*pb.DecodeTransactionResponse){
		"raw transaction": func(p *pb.DecodeTransactionResponse) { p.IsPsbt = false },
		"unknown fee":     func(p *pb.DecodeTransactionResponse) { p.HasFee = false },
		"negative fee":    func(p *pb.DecodeTransactionResponse) { p.FeeSats = -1 },
		"script hex":      func(p *pb.DecodeTransactionResponse) { p.Outputs[0].ScriptPubkeyHex = "xx" },
		"return data":     func(p *pb.DecodeTransactionResponse) { p.Outputs[1].ScriptPubkeyHex = "6a4c" },
	} {
		t.Run(name, func(t *testing.T) {
			f, ctx, _, _ := newSignTestFlow(t, "--yes")
			change(f.daemon.preview)
			require.Error(t, runWalletSignPSBT(ctx, f.client))
			require.Nil(t, f.daemon.signed)
		})
	}
}

func TestWalletSignPSBTCompletesTheBurnFileFlow(t *testing.T) {
	packets := newBurnMultisigPackets(t)
	dir := t.TempDir()
	input, output := filepath.Join(dir, "burn.psbt"), filepath.Join(dir, "signed.psbt")
	f := newBurnTestFlow(t, "--psbt-out", input, "--yes")
	setBurnMultisig(f, false)
	f.daemon.wallets.Wallets[0].Multisig.Cosigners[0].Held = true
	f.daemon.wallets.Wallets[0].Multisig.Cosigners[1].Held = true
	f.daemon.packet = packets.original
	f.daemon.signedPSBT = packets.complete

	require.NoError(t, f.run())
	require.Nil(t, f.daemon.signed)
	require.Nil(t, f.daemon.broadcast)

	ctx := newSignTestContext(t, f, "--psbt-in", input, "--psbt-out", output, "--yes", "active-wallet")
	require.NoError(t, runWalletSignPSBT(ctx, f.client))
	require.Equal(t, packets.original, f.daemon.signed.PsbtBase64)
	require.Equal(t, "active-wallet", f.daemon.signed.WalletId)
	require.Nil(t, f.daemon.finalized)
	require.Nil(t, f.daemon.broadcast)

	f.daemon.calls = nil
	f.daemon.signatureStatus = &pb.MultisigPsbtStatusResponse{Threshold: 2, Signatures: 2, Finalizable: true}
	require.NoError(t, f.ctx.Set("psbt-out", ""))
	require.NoError(t, f.ctx.Set("psbt-in", output))
	require.NoError(t, f.run())

	require.NotContains(t, f.daemon.calls, "sign")
	require.Equal(t, packets.complete, f.daemon.decoded.Input)
	require.Equal(t, packets.complete, f.daemon.finalized.PsbtBase64)
	require.Equal(t, "active-wallet", f.daemon.broadcast.WalletId)
	require.Contains(t, f.output.String(), "Burn sent: burn-txid")
	unsigned, err := os.ReadFile(input)
	require.NoError(t, err)
	signed, err := os.ReadFile(output)
	require.NoError(t, err)
	require.False(t, bytes.Equal(unsigned, signed))
}

func TestWalletSignPSBTCompletesTheCoreBurnFileFlow(t *testing.T) {
	packet, err := psbt.NewFromRawBytes(strings.NewReader(newBurnMultisigPackets(t).original), true)
	require.NoError(t, err)
	key, _ := btcec.PrivKeyFromBytes([]byte{1})
	pubkey := key.PubKey().SerializeCompressed()
	hash := btcutil.Hash160(pubkey)
	script, err := txscript.NewScriptBuilder().AddOp(txscript.OP_0).AddData(hash).Script()
	require.NoError(t, err)
	scriptCode, err := txscript.NewScriptBuilder().AddOp(txscript.OP_DUP).AddOp(txscript.OP_HASH160).
		AddData(hash).AddOp(txscript.OP_EQUALVERIFY).AddOp(txscript.OP_CHECKSIG).Script()
	require.NoError(t, err)
	value := packet.Inputs[0].WitnessUtxo.Value
	packet.Inputs[0] = psbt.PInput{WitnessUtxo: wire.NewTxOut(value, script)}
	unsigned, err := packet.B64Encode()
	require.NoError(t, err)
	hashes := txscript.NewTxSigHashes(packet.UnsignedTx, txscript.NewCannedPrevOutputFetcher(script, value))
	signature, err := txscript.RawTxInWitnessSignature(packet.UnsignedTx, hashes, 0, value, scriptCode, txscript.SigHashAll, key)
	require.NoError(t, err)
	packet.Inputs[0].PartialSigs = []*psbt.PartialSig{{PubKey: pubkey, Signature: signature}}
	signed, err := packet.B64Encode()
	require.NoError(t, err)
	_, err = (&wallet.ElectrumBackend{}).FinalizePSBT(signed)
	require.NoError(t, err)

	dir := t.TempDir()
	input, output := filepath.Join(dir, "burn.psbt"), filepath.Join(dir, "signed.psbt")
	f := newBurnTestFlow(t, "--psbt-out", input, "--yes")
	f.daemon.wallets.Wallets[0].WalletType = pb.WalletType_WALLET_TYPE_BITCOIN_CORE
	f.daemon.packet = unsigned
	f.daemon.signedPSBT = signed

	require.NoError(t, f.run())
	require.Nil(t, f.daemon.signed)
	require.Nil(t, f.daemon.broadcast)

	ctx := newSignTestContext(t, f, "--psbt-in", input, "--psbt-out", output, "--yes", "active-wallet")
	require.NoError(t, runWalletSignPSBT(ctx, f.client))
	require.Equal(t, unsigned, f.daemon.signed.PsbtBase64)
	require.Equal(t, "active-wallet", f.daemon.signed.WalletId)
	require.Nil(t, f.daemon.finalized)
	require.Nil(t, f.daemon.broadcast)
	stored, err := readPSBTFile(output)
	require.NoError(t, err)
	require.Equal(t, signed, stored)

	f.daemon.calls = nil
	require.NoError(t, f.ctx.Set("psbt-out", ""))
	require.NoError(t, f.ctx.Set("psbt-in", output))
	require.NoError(t, f.run())

	require.NotContains(t, f.daemon.calls, "sign")
	require.Equal(t, signed, f.daemon.decoded.Input)
	require.Equal(t, signed, f.daemon.finalized.PsbtBase64)
	require.Equal(t, "active-wallet", f.daemon.broadcast.WalletId)
	require.Contains(t, f.output.String(), "Burn sent: burn-txid")
}
