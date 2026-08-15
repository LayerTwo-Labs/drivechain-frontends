package engines

import (
	"context"

	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/samber/lo"
)

// ChequeUTXO is one output paying a cheque address.
type ChequeUTXO struct {
	TxID          string
	Vout          int32
	ValueSats     int64
	Confirmations int32
}

// ChequeChain is the chain access a cheque needs: reads of an address the
// wallet does not own, a fee estimate, and a broadcast.
type ChequeChain interface {
	AddressUnspent(ctx context.Context, address string) ([]ChequeUTXO, error)
	FeeRateSatPerVByte(ctx context.Context, confTarget int32) (float64, error)
	Broadcast(ctx context.Context, txHex string) (string, error)
}

// ElectrumChequeChain reads cheque addresses over the orchestrator's electrum
// backend, which indexes every address — no wallet, no import, no rescan.
type ElectrumChequeChain struct {
	engine *WalletEngine
}

func NewElectrumChequeChain(engine *WalletEngine) *ElectrumChequeChain {
	return &ElectrumChequeChain{engine: engine}
}

func (c *ElectrumChequeChain) AddressUnspent(ctx context.Context, address string) ([]ChequeUTXO, error) {
	utxos, _, err := c.engine.ChequeAddressUnspent(ctx, address)
	if err != nil {
		return nil, err
	}
	return lo.Map(utxos, func(u *orchpb.AddressUnspentOutput, _ int) ChequeUTXO {
		return ChequeUTXO{
			TxID:          u.Txid,
			Vout:          u.Vout,
			ValueSats:     u.ValueSats,
			Confirmations: u.Confirmations,
		}
	}), nil
}

func (c *ElectrumChequeChain) FeeRateSatPerVByte(ctx context.Context, confTarget int32) (float64, error) {
	return c.engine.EstimateFeeRate(ctx, confTarget)
}

func (c *ElectrumChequeChain) Broadcast(ctx context.Context, txHex string) (string, error) {
	return c.engine.BroadcastChequeTx(ctx, txHex)
}
