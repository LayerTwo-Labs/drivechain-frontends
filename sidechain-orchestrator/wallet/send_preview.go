package wallet

import (
	"bytes"
	"context"
	"encoding/hex"
	"errors"
	"fmt"
	"math"
	"sort"
	"strings"
	"time"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/replay"
	"github.com/btcsuite/btcd/txscript"
	"github.com/btcsuite/btcd/wire"
	"github.com/samber/lo"
)

// SendPreview is the fee and size of a send that the backend built but did
// not sign or broadcast.
type SendPreview struct {
	FeeSats     int64
	VsizeVBytes int64
	// Inputs are the coins the send spends. A send that pins them pays FeeSats.
	Inputs []RequiredInput
}

// signedVsize is the vsize of tx after its inputs are signed. inputWeights
// holds the full weight of each input, in the order of tx.TxIn.
func signedVsize(tx *wire.MsgTx, inputWeights []int) (int64, error) {
	if len(inputWeights) != len(tx.TxIn) {
		return 0, fmt.Errorf("have %d input weights for %d inputs", len(inputWeights), len(tx.TxIn))
	}
	const unsignedInputBytes = 32 + 4 + 1 + 4
	const segwitMarkerAndFlagWeight = 2
	weight := (tx.SerializeSizeStripped()-unsignedInputBytes*len(tx.TxIn))*4 + segwitMarkerAndFlagWeight
	for _, w := range inputWeights {
		weight += w
	}
	return int64((weight + 3) / 4), nil
}

func refuseExcludedRequiredInputs(req SendRequest) error {
	for _, ex := range req.ExcludedInputs {
		for _, in := range req.RequiredInputs {
			if in.TxID == ex.TxID && in.Vout == ex.Vout {
				return connect.NewError(connect.CodeInvalidArgument,
					fmt.Errorf("input %s:%d is both required and excluded", in.TxID, in.Vout))
			}
		}
	}
	return nil
}

func requireSendPreviewRate(req SendRequest) error {
	if req.FeeRateSatPerVB <= 0 {
		return connect.NewError(connect.CodeInvalidArgument, errors.New("a send preview needs a fee rate"))
	}
	return nil
}

// PreviewSend funds the send with Core's coin selection at req's fee rate, and
// reports the fee and size without a signature or a broadcast.
func (p *CoreBackend) PreviewSend(ctx context.Context, walletID string, req SendRequest) (_ *SendPreview, err error) {
	if err := requireSendPreviewRate(req); err != nil {
		return nil, err
	}
	if err := refuseExcludedRequiredInputs(req); err != nil {
		return nil, err
	}
	name, err := p.walletName(ctx, walletID)
	if err != nil {
		return nil, err
	}
	p.previewRunMu.Lock()
	defer p.previewRunMu.Unlock()
	unlock, err := p.lockFrozenCoins(ctx, walletID, name)
	if err != nil {
		return nil, err
	}
	defer unlock()
	if len(req.ExcludedInputs) > 0 {
		excluded := lo.Map(req.ExcludedInputs, func(in RequiredInput, _ int) RawInput {
			return RawInput{TxID: in.TxID, Vout: in.Vout}
		})
		if err := p.rpc.LockUnspent(ctx, name, false, excluded); err != nil {
			return nil, fmt.Errorf("lock excluded inputs: %w", err)
		}
		defer func() {
			free, cancel := context.WithTimeout(context.WithoutCancel(ctx), 30*time.Second)
			defer cancel()
			if unlockErr := p.rpc.LockUnspent(free, name, true, excluded); unlockErr != nil && err == nil {
				err = fmt.Errorf("unlock excluded inputs: %w", unlockErr)
			}
		}()
	}

	protect := ReplayProtect(p.svc.Network(), req.AllowReplay)
	locktime := uint32(0)
	if protect {
		locktime = replay.ReplayLockTime
	}
	outputs, _ := buildSendOutputs(req)
	inputs := make([]RawInput, 0, len(req.RequiredInputs))
	for _, in := range req.RequiredInputs {
		inputs = append(inputs, RawInput{TxID: in.TxID, Vout: in.Vout})
	}

	// Core picks the change type from the destination types, so one cached
	// change address serves one set of destination kinds.
	kinds := lo.Uniq(lo.Map(lo.Keys(req.DestinationsSats), func(addr string, _ int) string {
		return fmt.Sprint(addressKind(addr, p.net()))
	}))
	sort.Strings(kinds)
	changeKey := p.net().Name + "|" + name + "|" + strings.Join(kinds, ",")
	p.previewMu.Lock()
	changeAddress := p.previewChange[changeKey]
	p.previewMu.Unlock()

	funded, err := p.fundWithCoreSelection(ctx, name, req, inputs, outputs, locktime, protect, changeAddress)
	if err != nil {
		return nil, err
	}
	raw, err := hex.DecodeString(funded.Hex)
	if err != nil {
		return nil, fmt.Errorf("decode funded transaction: %w", err)
	}
	var tx wire.MsgTx
	if err := tx.DeserializeNoWitness(bytes.NewReader(raw)); err != nil {
		return nil, fmt.Errorf("decode funded transaction: %w", err)
	}
	if changeAddress == "" && funded.ChangePos >= 0 {
		if funded.ChangePos >= len(tx.TxOut) {
			return nil, fmt.Errorf("change position %d is past %d outputs", funded.ChangePos, len(tx.TxOut))
		}
		_, addrs, _, err := txscript.ExtractPkScriptAddrs(tx.TxOut[funded.ChangePos].PkScript, p.net())
		if err != nil {
			return nil, fmt.Errorf("read change address: %w", err)
		}
		if len(addrs) != 1 {
			return nil, fmt.Errorf("change output pays %d addresses", len(addrs))
		}
		p.previewMu.Lock()
		if p.previewChange == nil {
			p.previewChange = make(map[string]string)
		}
		p.previewChange[changeKey] = addrs[0].EncodeAddress()
		p.previewMu.Unlock()
	}

	utxos, err := p.rpc.ListUnspentMinConf(ctx, name, 0)
	if err != nil {
		return nil, fmt.Errorf("list unspent: %w", err)
	}
	byOutpoint := make(map[string]UTXO, len(utxos))
	for _, u := range utxos {
		byOutpoint[fmt.Sprintf("%s:%d", u.TxID, u.Vout)] = u
	}
	weights := make([]int, 0, len(tx.TxIn))
	spent := make([]RequiredInput, 0, len(tx.TxIn))
	for _, in := range tx.TxIn {
		outpoint := in.PreviousOutPoint.String()
		u, ok := byOutpoint[outpoint]
		if !ok {
			return nil, fmt.Errorf("funded input %s is not a wallet UTXO", outpoint)
		}
		w, err := InputWeightUnits(u.Descriptor)
		if err != nil {
			return nil, fmt.Errorf("size input %s: %w", outpoint, err)
		}
		weights = append(weights, w)
		spent = append(spent, RequiredInput{
			TxID: u.TxID, Vout: u.Vout, AmountSats: int64(math.Round(u.Amount * 1e8)),
		})
	}
	vsize, err := signedVsize(&tx, weights)
	if err != nil {
		return nil, err
	}
	return &SendPreview{FeeSats: int64(math.Round(funded.Fee * 1e8)), VsizeVBytes: vsize, Inputs: spent}, nil
}

// PreviewSend selects coins for the send at req's fee rate, as Send does, and
// reports the fee and size without a signature or a broadcast.
func (p *ElectrumBackend) PreviewSend(ctx context.Context, walletID string, req SendRequest) (*SendPreview, error) {
	if err := requireSendPreviewRate(req); err != nil {
		return nil, err
	}
	if err := p.requireElectrum(walletID); err != nil {
		return nil, err
	}
	scan, err := p.scanForSend(ctx, walletID, req)
	if err != nil {
		return nil, err
	}
	packet, psbtInputs, _, err := p.buildSendPSBT(ctx, walletID, scan, req)
	if err != nil {
		return nil, err
	}
	w := p.svc.GetWalletByID(walletID)
	if w == nil {
		return nil, fmt.Errorf("wallet %s not found", walletID)
	}
	d, err := p.walletDescriptor(w)
	if err != nil {
		return nil, err
	}

	var feeSats int64
	weights := make([]int, 0, len(psbtInputs))
	spent := make([]RequiredInput, 0, len(psbtInputs))
	for _, in := range psbtInputs {
		feeSats += in.amount
		weights = append(weights, walletInputVsize(d)*4)
		spent = append(spent, RequiredInput{
			TxID: in.outpoint.Hash.String(), Vout: int(in.outpoint.Index), AmountSats: in.amount,
		})
	}
	for _, out := range packet.UnsignedTx.TxOut {
		feeSats -= out.Value
	}
	vsize, err := signedVsize(packet.UnsignedTx, weights)
	if err != nil {
		return nil, err
	}
	return &SendPreview{FeeSats: feeSats, VsizeVBytes: vsize, Inputs: spent}, nil
}
