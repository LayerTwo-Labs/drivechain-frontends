package commands

import (
	"bytes"
	"crypto/sha256"
	"encoding/base64"
	"os"
	"path/filepath"
	"strings"
	"testing"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/replay"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/btcsuite/btcd/btcec/v2"
	"github.com/btcsuite/btcd/btcutil"
	"github.com/btcsuite/btcd/btcutil/psbt"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/stretchr/testify/require"
)

type burnMultisigPackets struct {
	original  string
	first     string
	second    string
	changed   string
	complete  string
	finalized string
}

func newBurnMultisigPackets(t *testing.T) burnMultisigPackets {
	t.Helper()
	keys := make([]*btcec.PrivateKey, 3)
	addresses := make([]*btcutil.AddressPubKey, 3)
	for i := range keys {
		keys[i], _ = btcec.PrivKeyFromBytes([]byte{byte(i + 1)})
		var err error
		addresses[i], err = btcutil.NewAddressPubKey(keys[i].PubKey().SerializeCompressed(), &chaincfg.MainNetParams)
		require.NoError(t, err)
	}
	witnessScript, err := txscript.MultiSigScript(addresses, 2)
	require.NoError(t, err)
	hash := sha256.Sum256(witnessScript)
	inputScript, err := txscript.NewScriptBuilder().AddOp(txscript.OP_0).AddData(hash[:]).Script()
	require.NoError(t, err)
	burnAddress, err := btcutil.DecodeAddress(burnTestAddress, &chaincfg.MainNetParams)
	require.NoError(t, err)
	burnScript, err := txscript.PayToAddrScript(burnAddress)
	require.NoError(t, err)
	dataScript, err := txscript.NewScriptBuilder().AddOp(txscript.OP_RETURN).AddData([]byte(burnTestReceiveAddress)).Script()
	require.NoError(t, err)
	changeAddress, err := btcutil.DecodeAddress(burnTestReceiveAddress, &chaincfg.MainNetParams)
	require.NoError(t, err)
	changeScript, err := txscript.PayToAddrScript(changeAddress)
	require.NoError(t, err)
	transaction := wire.NewMsgTx(2)
	transaction.LockTime = replay.ReplayLockTime
	transaction.AddTxIn(wire.NewTxIn(wire.NewOutPoint(&chainhash.Hash{1}, 0), nil, nil))
	transaction.TxIn[0].Sequence = 0xfffffffe
	transaction.AddTxOut(wire.NewTxOut(100000001, burnScript))
	transaction.AddTxOut(wire.NewTxOut(0, dataScript))
	transaction.AddTxOut(wire.NewTxOut(10000, changeScript))
	packet, err := psbt.NewFromUnsignedTx(transaction)
	require.NoError(t, err)
	packet.Inputs[0].WitnessUtxo = wire.NewTxOut(100010453, inputScript)
	packet.Inputs[0].WitnessScript = witnessScript
	original, err := packet.B64Encode()
	require.NoError(t, err)
	hashes := txscript.NewTxSigHashes(transaction, txscript.NewCannedPrevOutputFetcher(inputScript, 100010453))
	partials := make([]string, 2)
	for i := range partials {
		copy, err := psbt.NewFromRawBytes(strings.NewReader(original), true)
		require.NoError(t, err)
		signature, err := txscript.RawTxInWitnessSignature(transaction, hashes, 0, 100010453, witnessScript, txscript.SigHashAll, keys[i])
		require.NoError(t, err)
		copy.Inputs[0].PartialSigs = []*psbt.PartialSig{{PubKey: keys[i].PubKey().SerializeCompressed(), Signature: signature}}
		partials[i], err = copy.B64Encode()
		require.NoError(t, err)
	}
	packet.UnsignedTx.TxOut[0].Value--
	changed, err := packet.B64Encode()
	require.NoError(t, err)
	complete, err := (&wallet.ElectrumBackend{}).CombinePSBT([]string{original, partials[0], partials[1]})
	require.NoError(t, err)
	finalPacket, err := psbt.NewFromRawBytes(strings.NewReader(complete), true)
	require.NoError(t, err)
	require.NoError(t, psbt.MaybeFinalizeAll(finalPacket))
	require.NotEmpty(t, finalPacket.Inputs[0].FinalScriptWitness)
	finalized, err := finalPacket.B64Encode()
	require.NoError(t, err)
	return burnMultisigPackets{original: original, first: partials[0], second: partials[1], changed: changed, complete: complete, finalized: finalized}
}

func writeBurnTestPacket(t *testing.T, path, packet string, binary bool) {
	t.Helper()
	data := []byte(" \n" + packet + "\n")
	if binary {
		var err error
		data, err = base64.StdEncoding.DecodeString(packet)
		require.NoError(t, err)
	}
	require.NoError(t, os.WriteFile(path, data, 0o600))
}

func setBurnMultisig(f *burnTestFlow, ready bool) {
	f.daemon.wallets.Wallets[0].WatchOnly = true
	f.daemon.wallets.Wallets[0].Multisig = &pb.MultisigInfo{
		M: 2, N: 3,
		Cosigners: []*pb.MultisigCosignerInfo{{Held: false}, {Held: false}, {Held: false}},
	}
	f.daemon.signatureStatus = &pb.MultisigPsbtStatusResponse{Threshold: 2, Finalizable: ready}
	if ready {
		f.daemon.signatureStatus.Signatures = 2
	}
}

func TestBurnMultisigExportsAllExternalWallet(t *testing.T) {
	packets := newBurnMultisigPackets(t)
	path := filepath.Join(t.TempDir(), "burn.psbt")
	f := newBurnTestFlow(t, "--psbt-out", path, "--yes")
	setBurnMultisig(f, false)
	f.daemon.packet = packets.original
	require.NoError(t, f.run())
	raw, err := os.ReadFile(path)
	require.NoError(t, err)
	require.True(t, bytes.HasPrefix(raw, []byte{'p', 's', 'b', 't', 0xff}))
	require.Equal(t, packets.original, base64.StdEncoding.EncodeToString(raw))
	info, err := os.Stat(path)
	require.NoError(t, err)
	require.Equal(t, os.FileMode(0o600), info.Mode().Perm())
	require.Equal(t, packets.original, f.daemon.decoded.Input)
	require.Equal(t, packets.original, f.daemon.signatureRequest.PsbtBase64)
	require.Equal(t, "active-wallet", f.daemon.signatureRequest.WalletId)
	require.Nil(t, f.daemon.signed)
	require.Nil(t, f.daemon.finalized)
	require.Nil(t, f.daemon.broadcast)
	require.Contains(t, f.output.String(), "More cosigner signatures are necessary.")
	require.Contains(t, f.output.String(), "The command did not broadcast the burn.")
	require.NotContains(t, f.output.String(), "[y/N]")
}

func TestBurnMultisigReadsBinaryAndBase64(t *testing.T) {
	packets := newBurnMultisigPackets(t)
	for _, binary := range []bool{true, false} {
		name := "base64"
		if binary {
			name = "binary"
		}
		t.Run(name, func(t *testing.T) {
			path := filepath.Join(t.TempDir(), "burn.psbt")
			writeBurnTestPacket(t, path, packets.original, binary)
			packet, err := readPSBTFile(path)
			require.NoError(t, err)
			require.Equal(t, packets.original, packet)
			f := newBurnTestFlow(t, "--psbt-in", path, "--preview")
			setBurnMultisig(f, false)
			require.NoError(t, f.run())
			require.Equal(t, packet, f.daemon.decoded.Input)
			require.Nil(t, f.daemon.created)
			require.Nil(t, f.daemon.signed)
			require.Nil(t, f.daemon.broadcast)
		})
	}
}

func TestBurnMultisigCombinesTwoSignedFiles(t *testing.T) {
	packets := newBurnMultisigPackets(t)
	dir := t.TempDir()
	original := filepath.Join(dir, "original.psbt")
	first := filepath.Join(dir, "first.psbt")
	second := filepath.Join(dir, "second.psbt")
	writeBurnTestPacket(t, original, packets.original, true)
	writeBurnTestPacket(t, first, packets.first, true)
	writeBurnTestPacket(t, second, packets.second, false)
	f := newBurnTestFlow(t, "--psbt-in", original, "--signed-psbt", first, "--signed-psbt", second, "--yes")
	setBurnMultisig(f, true)
	require.NoError(t, f.run())
	require.Equal(t, []string{packets.original, packets.first, packets.second}, f.daemon.combined.PsbtBase64)
	require.Equal(t, packets.complete, f.daemon.decoded.Input)
	require.Equal(t, packets.complete, f.daemon.signatureRequest.PsbtBase64)
	require.Equal(t, packets.complete, f.daemon.finalized.PsbtBase64)
	require.Nil(t, f.daemon.created)
	require.Nil(t, f.daemon.signed)
	require.Equal(t, "active-wallet", f.daemon.broadcast.WalletId)
	require.Equal(t, "final-transaction", f.daemon.broadcast.TxHex)
	raw, err := os.ReadFile(original)
	require.NoError(t, err)
	require.Equal(t, packets.original, base64.StdEncoding.EncodeToString(raw))
	require.Contains(t, f.output.String(), "Burn sent: burn-txid")
}

func TestBurnMultisigChecksInputsBeforePreview(t *testing.T) {
	packets := newBurnMultisigPackets(t)
	packet, err := psbt.NewFromRawBytes(strings.NewReader(packets.original), true)
	require.NoError(t, err)
	packet.Inputs[0].WitnessUtxo = nil
	incomplete, err := packet.B64Encode()
	require.NoError(t, err)
	for _, source := range []string{"import", "combine"} {
		t.Run(source, func(t *testing.T) {
			dir := t.TempDir()
			input := filepath.Join(dir, "input.psbt")
			output := filepath.Join(dir, "output.psbt")
			writeBurnTestPacket(t, input, incomplete, true)
			args := []string{"--psbt-in", input, "--psbt-out", output, "--yes"}
			if source == "combine" {
				writeBurnTestPacket(t, input, packets.original, true)
				signed := filepath.Join(dir, "signed.psbt")
				writeBurnTestPacket(t, signed, packets.first, true)
				args = append(args, "--signed-psbt", signed)
			}
			f := newBurnTestFlow(t, args...)
			setBurnMultisig(f, true)
			f.daemon.combinedPSBT = incomplete

			require.ErrorContains(t, f.run(), "PSBT input 0 has no previous-output data")
			require.Nil(t, f.daemon.decoded)
			require.Nil(t, f.daemon.signed)
			require.Nil(t, f.daemon.finalized)
			require.Nil(t, f.daemon.broadcast)
			require.Empty(t, f.output.String())
			require.NoFileExists(t, output)
		})
	}
}

func TestBurnMultisigRejectsChangedTransaction(t *testing.T) {
	packets := newBurnMultisigPackets(t)
	dir := t.TempDir()
	original := filepath.Join(dir, "original.psbt")
	changed := filepath.Join(dir, "changed.psbt")
	writeBurnTestPacket(t, original, packets.original, true)
	writeBurnTestPacket(t, changed, packets.changed, false)
	f := newBurnTestFlow(t, "--psbt-in", original, "--signed-psbt", changed, "--yes")
	setBurnMultisig(f, true)
	require.ErrorContains(t, f.run(), "different transactions")
	require.Equal(t, []string{packets.original, packets.changed}, f.daemon.combined.PsbtBase64)
	require.Nil(t, f.daemon.decoded)
	require.Nil(t, f.daemon.signed)
	require.Nil(t, f.daemon.finalized)
	require.Nil(t, f.daemon.broadcast)
}

func TestBurnMultisigStopsWithPartialSignatures(t *testing.T) {
	packets := newBurnMultisigPackets(t)
	path := filepath.Join(t.TempDir(), "partial.psbt")
	writeBurnTestPacket(t, path, packets.first, true)
	f := newBurnTestFlow(t, "--psbt-in", path, "--yes")
	setBurnMultisig(f, false)
	f.daemon.signatureStatus.Signatures = 1
	require.ErrorContains(t, f.run(), "collect sufficient signatures")
	require.Equal(t, packets.first, f.daemon.signatureRequest.PsbtBase64)
	require.Nil(t, f.daemon.signed)
	require.Nil(t, f.daemon.finalized)
	require.Nil(t, f.daemon.broadcast)
	require.Contains(t, f.output.String(), "More cosigner signatures are necessary.")
	require.NotContains(t, f.output.String(), "Burn sent:")
}

func TestBurnMultisigFinalizesExactImportedPacket(t *testing.T) {
	packets := newBurnMultisigPackets(t)
	path := filepath.Join(t.TempDir(), "complete.psbt")
	writeBurnTestPacket(t, path, packets.complete, true)
	f := newBurnTestFlow(t, "--psbt-in", path, "--yes")
	setBurnMultisig(f, true)
	require.NoError(t, f.run())
	require.Nil(t, f.daemon.created)
	require.Nil(t, f.daemon.combined)
	require.Nil(t, f.daemon.signed)
	require.Equal(t, packets.complete, f.daemon.decoded.Input)
	require.Equal(t, packets.complete, f.daemon.finalized.PsbtBase64)
	require.Equal(t, "final-transaction", f.daemon.broadcast.TxHex)
	require.Contains(t, f.output.String(), "ECX credit pending: 0.01000001 ECX")
}

func TestBurnMultisigCombinesFinalizedCosignerFile(t *testing.T) {
	packets := newBurnMultisigPackets(t)
	dir := t.TempDir()
	original := filepath.Join(dir, "original.psbt")
	finalized := filepath.Join(dir, "finalized.psbt")
	writeBurnTestPacket(t, original, packets.original, true)
	writeBurnTestPacket(t, finalized, packets.finalized, false)
	f := newBurnTestFlow(t, "--psbt-in", original, "--signed-psbt", finalized, "--yes")
	setBurnMultisig(f, true)
	require.NoError(t, f.run())
	require.Equal(t, []string{packets.original, packets.finalized}, f.daemon.combined.PsbtBase64)
	require.Equal(t, f.daemon.decoded.Input, f.daemon.signatureRequest.PsbtBase64)
	require.Equal(t, f.daemon.decoded.Input, f.daemon.finalized.PsbtBase64)
	combined, err := psbt.NewFromRawBytes(strings.NewReader(f.daemon.decoded.Input), true)
	require.NoError(t, err)
	finalPacket, err := psbt.NewFromRawBytes(strings.NewReader(packets.finalized), true)
	require.NoError(t, err)
	require.Equal(t, finalPacket.Inputs[0].FinalScriptWitness, combined.Inputs[0].FinalScriptWitness)
	actual, err := (&wallet.ElectrumBackend{}).FinalizePSBT(f.daemon.decoded.Input)
	require.NoError(t, err)
	expected, err := (&wallet.ElectrumBackend{}).FinalizePSBT(packets.finalized)
	require.NoError(t, err)
	require.Equal(t, expected, actual)
	require.Nil(t, f.daemon.signed)
	require.NotNil(t, f.daemon.broadcast)
}

func TestBurnMultisigFlagsKeepSingleKeyExternalWalletsBlocked(t *testing.T) {
	packets := newBurnMultisigPackets(t)
	for _, kind := range []string{"watch-only", "hardware type", "hardware fingerprint"} {
		for _, flag := range []string{"--psbt-in", "--psbt-out"} {
			t.Run(kind+" "+flag, func(t *testing.T) {
				path := filepath.Join(t.TempDir(), "burn.psbt")
				if flag == "--psbt-in" {
					writeBurnTestPacket(t, path, packets.original, true)
				}
				f := newBurnTestFlow(t, flag, path)
				switch kind {
				case "watch-only":
					f.daemon.wallets.Wallets[0].WatchOnly = true
				case "hardware type":
					f.daemon.wallets.Wallets[0].HardwareDeviceType = "test-device"
				case "hardware fingerprint":
					f.daemon.wallets.Wallets[0].HardwareFingerprint = "12345678"
				}
				require.ErrorContains(t, f.run(), "use a software or multisig wallet")
				require.Nil(t, f.daemon.derived)
				require.Nil(t, f.daemon.created)
				require.Nil(t, f.daemon.signed)
				require.Nil(t, f.daemon.broadcast)
			})
		}
	}
}

func TestBurnMultisigExportsCombinedPacketWithoutBroadcast(t *testing.T) {
	packets := newBurnMultisigPackets(t)
	dir := t.TempDir()
	original := filepath.Join(dir, "original.psbt")
	signed := filepath.Join(dir, "signed.psbt")
	output := filepath.Join(dir, "combined.psbt")
	writeBurnTestPacket(t, original, packets.original, true)
	writeBurnTestPacket(t, signed, packets.first, false)
	f := newBurnTestFlow(t, "--psbt-in", original, "--signed-psbt", signed, "--psbt-out", output, "--yes")
	setBurnMultisig(f, false)
	require.NoError(t, f.run())
	packet, err := readPSBTFile(output)
	require.NoError(t, err)
	require.Equal(t, packets.first, packet)
	require.Nil(t, f.daemon.signed)
	require.Nil(t, f.daemon.finalized)
	require.Nil(t, f.daemon.broadcast)
}

func TestBurnMultisigKeepsExistingOutputFile(t *testing.T) {
	packets := newBurnMultisigPackets(t)
	path := filepath.Join(t.TempDir(), "existing.psbt")
	original := []byte("keep this file")
	require.NoError(t, os.WriteFile(path, original, 0o640))
	initialInfo, err := os.Stat(path)
	require.NoError(t, err)
	f := newBurnTestFlow(t, "--psbt-out", path)
	setBurnMultisig(f, false)
	f.daemon.packet = packets.original
	require.ErrorContains(t, f.run(), "create the PSBT file")
	raw, err := os.ReadFile(path)
	require.NoError(t, err)
	require.Equal(t, original, raw)
	info, err := os.Stat(path)
	require.NoError(t, err)
	require.Equal(t, initialInfo.Mode().Perm(), info.Mode().Perm())
	require.Nil(t, f.daemon.signed)
	require.Nil(t, f.daemon.broadcast)
}

func TestBurnMultisigReturnsFileErrors(t *testing.T) {
	packets := newBurnMultisigPackets(t)
	for _, name := range []string{"absent input", "bad binary", "bad base64", "directory input", "absent signature", "bad signature", "bad output parent", "bad output data"} {
		t.Run(name, func(t *testing.T) {
			dir := t.TempDir()
			path := filepath.Join(dir, "input.psbt")
			writeBurnTestPacket(t, path, packets.original, true)
			args := []string{"--psbt-in", path, "--yes"}
			var text string
			switch name {
			case "absent input":
				require.NoError(t, os.Remove(path))
				text = "read the PSBT file"
			case "bad binary":
				require.NoError(t, os.WriteFile(path, []byte{'p', 's', 'b', 't', 0xff}, 0o600))
				text = "read the PSBT data"
			case "bad base64":
				require.NoError(t, os.WriteFile(path, []byte("not a PSBT"), 0o600))
				text = "read the PSBT data"
			case "directory input":
				args = []string{"--psbt-in", dir, "--yes"}
				text = "read the PSBT file"
			case "absent signature":
				args = append(args, "--signed-psbt", filepath.Join(dir, "absent.psbt"))
				text = "read the PSBT file"
			case "bad signature":
				bad := filepath.Join(dir, "bad.psbt")
				require.NoError(t, os.WriteFile(bad, []byte("bad signature file"), 0o600))
				args = append(args, "--signed-psbt", bad)
				text = "read the PSBT data"
			case "bad output parent":
				args = []string{"--psbt-out", filepath.Join(path, "output.psbt")}
				text = "create the PSBT file"
			case "bad output data":
				args = []string{"--psbt-out", filepath.Join(dir, "output.psbt")}
				text = "read the PSBT data"
			}
			f := newBurnTestFlow(t, args...)
			setBurnMultisig(f, false)
			f.daemon.packet = packets.original
			if name == "bad output data" {
				f.daemon.packet = "bad-base64"
			}
			require.ErrorContains(t, f.run(), text)
			require.Nil(t, f.daemon.signed)
			require.Nil(t, f.daemon.finalized)
			require.Nil(t, f.daemon.broadcast)
		})
	}
}

func TestBurnMultisigReturnsRpcErrors(t *testing.T) {
	packets := newBurnMultisigPackets(t)
	for _, stage := range []string{"network", "status", "wallets", "derive", "combine", "decode", "signatures", "finalize", "broadcast"} {
		t.Run(stage, func(t *testing.T) {
			dir := t.TempDir()
			original := filepath.Join(dir, "original.psbt")
			signed := filepath.Join(dir, "signed.psbt")
			writeBurnTestPacket(t, original, packets.original, true)
			writeBurnTestPacket(t, signed, packets.complete, true)
			f := newBurnTestFlow(t, "--psbt-in", original, "--signed-psbt", signed, "--yes")
			setBurnMultisig(f, true)
			f.daemon.fail = stage
			require.ErrorContains(t, f.run(), "RPC failed")
			require.Equal(t, stage, f.daemon.calls[len(f.daemon.calls)-1])
			require.Nil(t, f.daemon.signed)
			require.NotContains(t, f.output.String(), "Burn sent:")
		})
	}
}

func TestBurnMultisigStopsAfterContextChanges(t *testing.T) {
	packets := newBurnMultisigPackets(t)
	for _, stage := range []string{"combine", "signatures"} {
		for _, change := range []string{"wallet", "network"} {
			t.Run(stage+" "+change, func(t *testing.T) {
				dir := t.TempDir()
				original := filepath.Join(dir, "original.psbt")
				signed := filepath.Join(dir, "signed.psbt")
				writeBurnTestPacket(t, original, packets.original, true)
				writeBurnTestPacket(t, signed, packets.complete, false)
				f := newBurnTestFlow(t, "--psbt-in", original, "--signed-psbt", signed, "--yes")
				setBurnMultisig(f, true)
				f.daemon.after[stage] = func() {
					if change == "wallet" {
						f.daemon.status.ActiveWalletId = "other-wallet"
					} else {
						f.daemon.network = "betanet"
					}
				}
				require.Error(t, f.run())
				require.Nil(t, f.daemon.signed)
				require.Nil(t, f.daemon.finalized)
				require.Nil(t, f.daemon.broadcast)
				if stage == "combine" {
					require.Nil(t, f.daemon.decoded)
				}
			})
		}
	}
}

func TestBurnMultisigChecksImportedOutputs(t *testing.T) {
	packets := newBurnMultisigPackets(t)
	cases := map[string]func(*burnTestDaemon){
		"first address":     func(d *burnTestDaemon) { d.addresses = []string{burnTestAddress} },
		"foreign change":    func(d *burnTestDaemon) { d.preview.Outputs[2].IsMine = false },
		"replay protection": func(d *burnTestDaemon) { d.preview.Locktime = 0 },
		"exact fee":         func(d *burnTestDaemon) { d.preview.FeeSats++ },
		"burn amount":       func(d *burnTestDaemon) { d.preview.Outputs[0].ValueSats-- },
	}
	for name, change := range cases {
		t.Run(name, func(t *testing.T) {
			path := filepath.Join(t.TempDir(), "complete.psbt")
			writeBurnTestPacket(t, path, packets.complete, true)
			f := newBurnTestFlow(t, "--psbt-in", path, "--yes")
			setBurnMultisig(f, true)
			change(f.daemon)
			require.Error(t, f.run())
			require.Nil(t, f.daemon.created)
			require.Nil(t, f.daemon.signed)
			require.Nil(t, f.daemon.finalized)
			require.Nil(t, f.daemon.broadcast)
		})
	}
}

func TestBurnMultisigReturnsExportTextErrors(t *testing.T) {
	packets := newBurnMultisigPackets(t)
	for _, failAt := range []int{1, 2, 3} {
		t.Run(strings.Repeat("write ", failAt), func(t *testing.T) {
			path := filepath.Join(t.TempDir(), "burn.psbt")
			f := newBurnTestFlow(t, "--psbt-out", path)
			setBurnMultisig(f, false)
			f.daemon.packet = packets.original
			f.ctx.App.Writer = &burnErrorWriter{failAt: failAt}
			require.ErrorContains(t, f.run(), "write failed")
			require.Nil(t, f.daemon.signed)
			require.Nil(t, f.daemon.broadcast)
			_, err := os.Stat(path)
			if failAt < 3 {
				require.ErrorIs(t, err, os.ErrNotExist)
			} else {
				require.NoError(t, err)
			}
		})
	}
}

func TestBurnMultisigRejectsInvalidFlagPairs(t *testing.T) {
	for _, args := range [][]string{
		{"--signed-psbt", "cosigner.psbt"},
		{"--psbt-in", "burn.psbt", "--fee-rate", "1"},
	} {
		t.Run(strings.Join(args, " "), func(t *testing.T) {
			f := newBurnTestFlow(t, args...)
			require.Error(t, f.run())
			require.Empty(t, f.daemon.calls)
		})
	}
}
