package engines

import (
	"context"
	"fmt"
	"math"
	"sort"

	"connectrpc.com/connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
)

// CoreOutpoint is a Bitcoin Core wallet UTXO that a transaction must spend.
type CoreOutpoint struct {
	Txid string
	Vout uint32
}

// SendCoreWithFixedFee creates and broadcasts a Bitcoin Core transaction paying
// exactly fixedFeeSats. Core's send RPC takes a fee rate and no absolute fee, so
// the inputs are picked here (largest first) and spent through the raw
// transaction path, which pays the fee as given.
func SendCoreWithFixedFee(
	ctx context.Context,
	bitcoind corerpc.BitcoinServiceClient,
	walletName string,
	destinationsSats map[string]uint64,
	fixedFeeSats uint64,
) (string, error) {
	unspent, err := bitcoind.ListUnspent(ctx, connect.NewRequest(&corepb.ListUnspentRequest{
		Wallet: walletName,
	}))
	if err != nil {
		return "", fmt.Errorf("list unspent: %w", err)
	}

	neededSats := fixedFeeSats
	for _, sats := range destinationsSats {
		neededSats += sats
	}

	candidates := unspent.Msg.Unspent
	sort.Slice(candidates, func(i, j int) bool {
		return candidates[i].Amount > candidates[j].Amount
	})

	var totalInSats uint64
	selected := make([]CoreOutpoint, 0, len(candidates))
	for _, u := range candidates {
		if totalInSats >= neededSats {
			break
		}
		selected = append(selected, CoreOutpoint{Txid: u.Txid, Vout: u.Vout})
		totalInSats += uint64(math.Round(u.Amount * 1e8))
	}

	if totalInSats < neededSats {
		return "", fmt.Errorf("wallet UTXOs (%d sats) insufficient for outputs + fee (%d sats)", totalInSats, neededSats)
	}

	return SendCoreWithRequiredInputs(ctx, bitcoind, walletName, selected, destinationsSats, 0, fixedFeeSats)
}

// SendCoreWithRequiredInputs creates and broadcasts a Bitcoin Core transaction
// spending exactly the given outpoints. Input values are looked up from Bitcoin
// Core's own UTXO set (callers do not reliably know them), and any remainder
// after destinations + fee is returned as change instead of being silently paid
// to the miner.
func SendCoreWithRequiredInputs(
	ctx context.Context,
	bitcoind corerpc.BitcoinServiceClient,
	walletName string,
	requiredInputs []CoreOutpoint,
	destinationsSats map[string]uint64,
	feeSatPerVbyte uint64,
	fixedFeeSats uint64,
) (string, error) {
	log := zerolog.Ctx(ctx)

	const dustLimit = 546

	// Resolve input values from Core rather than trusting the caller.
	unspent, err := bitcoind.ListUnspent(ctx, connect.NewRequest(&corepb.ListUnspentRequest{
		MinimumConfirmations: lo.ToPtr(uint32(0)),
		Wallet:               walletName,
	}))
	if err != nil {
		return "", fmt.Errorf("list unspent: %w", err)
	}
	valueByOutpoint := make(map[CoreOutpoint]uint64, len(unspent.Msg.Unspent))
	for _, u := range unspent.Msg.Unspent {
		valueByOutpoint[CoreOutpoint{Txid: u.Txid, Vout: u.Vout}] = uint64(math.Round(u.Amount * 1e8))
	}

	var totalInSats uint64
	inputs := make([]*corepb.CreateRawTransactionRequest_Input, 0, len(requiredInputs))
	for _, op := range requiredInputs {
		valSats, ok := valueByOutpoint[op]
		if !ok {
			return "", fmt.Errorf("required input %s:%d not found in wallet UTXO set", op.Txid, op.Vout)
		}
		totalInSats += valSats
		inputs = append(inputs, &corepb.CreateRawTransactionRequest_Input{Txid: op.Txid, Vout: op.Vout})
	}

	var totalOutSats uint64
	for _, sats := range destinationsSats {
		totalOutSats += sats
	}

	// Explicit fixed fee wins; otherwise estimate from the rate (default
	// 2 sat/vB, matching the cheque-sweep path). Output/input vbyte sizes
	// mirror the P2WPKH estimate used in buildSweepTx.
	var feeSats uint64
	if fixedFeeSats > 0 {
		feeSats = fixedFeeSats
	} else {
		rate := feeSatPerVbyte
		if rate == 0 {
			rate = 2
		}
		estVbytes := uint64(len(inputs)*68 + (len(destinationsSats)+1)*31 + 11)
		feeSats = estVbytes * rate
	}

	if totalInSats < totalOutSats+feeSats {
		return "", fmt.Errorf("required inputs (%d sats) insufficient for outputs + fee (%d sats)", totalInSats, totalOutSats+feeSats)
	}

	outputs := make(map[string]float64, len(destinationsSats)+1)
	for addr, sats := range destinationsSats {
		outputs[addr] = float64(sats) / 1e8
	}

	changeSats := totalInSats - totalOutSats - feeSats
	if changeSats >= dustLimit {
		changeResp, err := bitcoind.GetNewAddress(ctx, connect.NewRequest(&corepb.GetNewAddressRequest{
			Wallet: walletName,
		}))
		if err != nil {
			return "", fmt.Errorf("get change address: %w", err)
		}
		outputs[changeResp.Msg.Address] = float64(changeSats) / 1e8
	}

	createResp, err := bitcoind.CreateRawTransaction(ctx, connect.NewRequest(&corepb.CreateRawTransactionRequest{
		Inputs:  inputs,
		Outputs: outputs,
	}))
	if err != nil {
		return "", fmt.Errorf("create raw transaction: %w", err)
	}
	log.Debug().Msgf("created raw transaction with change: %s", createResp.Msg.Tx.Hex)

	signResp, err := bitcoind.SignRawTransactionWithWallet(ctx, connect.NewRequest(&corepb.SignRawTransactionWithWalletRequest{
		HexString: createResp.Msg.Tx.Hex,
		Wallet:    walletName,
	}))
	if err != nil {
		return "", fmt.Errorf("sign transaction: %w", err)
	}
	if !signResp.Msg.Complete {
		return "", fmt.Errorf("transaction signing incomplete")
	}

	sendResp, err := bitcoind.SendRawTransaction(ctx, connect.NewRequest(&corepb.SendRawTransactionRequest{
		Tx: &corepb.RawTransaction{Hex: signResp.Msg.Hex},
	}))
	if err != nil {
		return "", fmt.Errorf("broadcast transaction: %w", err)
	}

	return sendResp.Msg.Txid, nil
}
