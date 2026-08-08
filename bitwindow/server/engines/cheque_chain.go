package engines

import (
	"context"
	"errors"
	"fmt"
	"math"
	"strings"
	"time"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/rs/zerolog"
	"github.com/samber/lo"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/timestamppb"
)

// ChequeWalletName is the watch-only Bitcoin Core wallet cheque addresses are
// imported into when Core is serving them.
const ChequeWalletName = "cheque_watch"

// ErrNoChequeChain means neither chain source can answer for an address.
var ErrNoChequeChain = errors.New("no chain source available for cheque addresses")

// IsWalletAlreadyLoadedErr reports whether err is bitcoind's "-35 wallet already
// loaded" response. It's benign — the wallet IS loaded.
func IsWalletAlreadyLoadedErr(err error) bool {
	return err != nil && strings.Contains(err.Error(), "already loaded")
}

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
	Name() string
	Available(ctx context.Context) bool
	// rescanFrom bounds how far back Core must look. A cheque address cannot
	// hold coins older than itself; an arbitrary WIF can.
	AddressUnspent(ctx context.Context, address string, rescanFrom time.Time) ([]ChequeUTXO, error)
	FeeRateSatPerVByte(ctx context.Context, confTarget int32) (float64, error)
	Broadcast(ctx context.Context, txHex string) (string, error)
}

// MinChequeFeeRate is the relay floor every estimate is clamped to.
const MinChequeFeeRate = 1.0

// ElectrumChequeChain reads cheque addresses over the orchestrator's electrum
// backend, which indexes every address — no wallet, no import, no rescan.
type ElectrumChequeChain struct {
	engine *WalletEngine
}

func NewElectrumChequeChain(engine *WalletEngine) *ElectrumChequeChain {
	return &ElectrumChequeChain{engine: engine}
}

func (c *ElectrumChequeChain) Name() string { return "electrum" }

func (c *ElectrumChequeChain) Available(ctx context.Context) bool {
	return c.engine != nil && c.engine.HasOrchestratorClient()
}

func (c *ElectrumChequeChain) AddressUnspent(ctx context.Context, address string, _ time.Time) ([]ChequeUTXO, error) {
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

// CoreChequeChain reads cheque addresses through a watch-only Bitcoin Core
// wallet — Core cannot see a foreign address without watching it.
type CoreChequeChain struct {
	bitcoind *service.Service[corerpc.BitcoinServiceClient]
}

func NewCoreChequeChain(bitcoind *service.Service[corerpc.BitcoinServiceClient]) *CoreChequeChain {
	return &CoreChequeChain{bitcoind: bitcoind}
}

func (c *CoreChequeChain) Name() string { return "bitcoin core" }

func (c *CoreChequeChain) Available(ctx context.Context) bool {
	return c.bitcoind != nil && c.bitcoind.IsConnected()
}

func (c *CoreChequeChain) AddressUnspent(ctx context.Context, address string, rescanFrom time.Time) ([]ChequeUTXO, error) {
	bitcoind, err := c.bitcoind.Get(ctx)
	if err != nil {
		return nil, fmt.Errorf("bitcoind not available: %w", err)
	}
	if err := c.ensureWatchWallet(ctx, bitcoind); err != nil {
		return nil, err
	}
	if err := c.importAddress(ctx, bitcoind, address, rescanFrom); err != nil {
		return nil, err
	}

	utxos, err := bitcoind.ListUnspent(ctx, connect.NewRequest(&corepb.ListUnspentRequest{
		MinimumConfirmations: lo.ToPtr(uint32(0)),
		Addresses:            []string{address},
		Wallet:               ChequeWalletName,
	}))
	if err != nil {
		return nil, fmt.Errorf("list unspent: %w", err)
	}

	return lo.Map(utxos.Msg.Unspent, func(u *corepb.UnspentOutput, _ int) ChequeUTXO {
		return ChequeUTXO{
			TxID:          u.Txid,
			Vout:          int32(u.Vout),
			ValueSats:     int64(math.Round(u.Amount * 1e8)),
			Confirmations: int32(u.Confirmations),
		}
	}), nil
}

func (c *CoreChequeChain) FeeRateSatPerVByte(ctx context.Context, confTarget int32) (float64, error) {
	bitcoind, err := c.bitcoind.Get(ctx)
	if err != nil {
		return 0, fmt.Errorf("bitcoind not available: %w", err)
	}
	resp, err := bitcoind.EstimateSmartFee(ctx, connect.NewRequest(&corepb.EstimateSmartFeeRequest{
		ConfTarget: int64(confTarget),
	}))
	if err != nil {
		return 0, err
	}
	// Core answers in BTC/kvB; regtest has no estimate at all and returns 0.
	rate := resp.Msg.FeeRate * 1e8 / 1000
	if rate < MinChequeFeeRate {
		rate = MinChequeFeeRate
	}
	return rate, nil
}

func (c *CoreChequeChain) Broadcast(ctx context.Context, txHex string) (string, error) {
	bitcoind, err := c.bitcoind.Get(ctx)
	if err != nil {
		return "", fmt.Errorf("bitcoind not available: %w", err)
	}
	res, err := bitcoind.SendRawTransaction(ctx, connect.NewRequest(&corepb.SendRawTransactionRequest{
		Tx: &corepb.RawTransaction{Hex: txHex},
	}))
	if err != nil {
		return "", err
	}
	return res.Msg.Txid, nil
}

// ensureWatchWallet creates or loads the watch-only cheque wallet.
func (c *CoreChequeChain) ensureWatchWallet(ctx context.Context, bitcoind corerpc.BitcoinServiceClient) error {
	wallets, err := bitcoind.ListWallets(ctx, connect.NewRequest(&emptypb.Empty{}))
	if err != nil {
		return fmt.Errorf("list wallets: %w", err)
	}
	if lo.Contains(wallets.Msg.Wallets, ChequeWalletName) {
		return nil
	}

	zerolog.Ctx(ctx).Info().Msg("creating cheque wallet (watch-only)")
	_, err = bitcoind.CreateWallet(ctx, connect.NewRequest(&corepb.CreateWalletRequest{
		Name:               ChequeWalletName,
		DisablePrivateKeys: true,
		Blank:              true,
	}))
	if err == nil {
		return nil
	}

	// Already on disk but unloaded: load it rather than failing.
	if strings.Contains(err.Error(), "already exists") || strings.Contains(err.Error(), "Database already exists") {
		_, loadErr := bitcoind.LoadWallet(ctx, connect.NewRequest(&corepb.LoadWalletRequest{
			Filename: ChequeWalletName,
		}))
		if loadErr != nil && !IsWalletAlreadyLoadedErr(loadErr) {
			return fmt.Errorf("load cheque wallet: %w", loadErr)
		}
		return nil
	}
	return fmt.Errorf("create cheque wallet: %w", err)
}

// importAddress watches one cheque address, rescanning back to rescanFrom so
// coins funded before the import are found. Idempotent.
func (c *CoreChequeChain) importAddress(ctx context.Context, bitcoind corerpc.BitcoinServiceClient, address string, rescanFrom time.Time) error {
	descInfo, err := bitcoind.GetDescriptorInfo(ctx, connect.NewRequest(&corepb.GetDescriptorInfoRequest{
		Descriptor_: fmt.Sprintf("addr(%s)", address),
	}))
	if err != nil {
		return fmt.Errorf("get descriptor info: %w", err)
	}

	resp, err := bitcoind.ImportDescriptors(ctx, connect.NewRequest(&corepb.ImportDescriptorsRequest{
		Wallet: ChequeWalletName,
		Requests: []*corepb.ImportDescriptorsRequest_Request{
			{
				Descriptor_: descInfo.Msg.Descriptor_,
				// btc-buf maps nil to "now" (no rescan), which would leave
				// already-funded outputs invisible.
				Timestamp: timestamppb.New(rescanFrom),
				Internal:  false,
			},
		},
	}))
	if err != nil {
		return fmt.Errorf("import descriptors: %w", err)
	}
	if len(resp.Msg.Responses) > 0 && !resp.Msg.Responses[0].Success && resp.Msg.Responses[0].Error != nil {
		if msg := resp.Msg.Responses[0].Error.Message; !strings.Contains(msg, "already") {
			return fmt.Errorf("import failed: %s", msg)
		}
	}
	return nil
}

// ChequeChainRouter prefers electrum and falls back to Core, so regtest and
// dev setups with no electrum endpoint keep working.
type ChequeChainRouter struct {
	electrum ChequeChain
	core     ChequeChain
}

func NewChequeChainRouter(electrum, core ChequeChain) *ChequeChainRouter {
	return &ChequeChainRouter{electrum: electrum, core: core}
}

func (r *ChequeChainRouter) Name() string { return "cheque chain router" }

func (r *ChequeChainRouter) Available(ctx context.Context) bool {
	return r.pick(ctx) != nil
}

// candidates lists the chains to try in order. Availability is only a claim —
// electrum reports itself up whenever the orchestrator is dialled, even on a
// network with no endpoint — so an unavailable chain is demoted, not dropped.
func (r *ChequeChainRouter) candidates(ctx context.Context) []ChequeChain {
	var ready, rest []ChequeChain
	for _, chain := range []ChequeChain{r.electrum, r.core} {
		if chain == nil {
			continue
		}
		if chain.Available(ctx) {
			ready = append(ready, chain)
		} else {
			rest = append(rest, chain)
		}
	}
	return append(ready, rest...)
}

func (r *ChequeChainRouter) pick(ctx context.Context) ChequeChain {
	candidates := r.candidates(ctx)
	if len(candidates) == 0 {
		return nil
	}
	return candidates[0]
}

func (r *ChequeChainRouter) AddressUnspent(ctx context.Context, address string, rescanFrom time.Time) ([]ChequeUTXO, error) {
	var lastErr error
	for _, chain := range r.candidates(ctx) {
		utxos, err := chain.AddressUnspent(ctx, address, rescanFrom)
		if err == nil {
			return utxos, nil
		}
		lastErr = fmt.Errorf("%s: %w", chain.Name(), err)
		zerolog.Ctx(ctx).Warn().Err(err).Str("chain", chain.Name()).Msg("cheque address lookup failed, trying next chain")
	}
	if lastErr == nil {
		return nil, ErrNoChequeChain
	}
	return nil, lastErr
}

func (r *ChequeChainRouter) FeeRateSatPerVByte(ctx context.Context, confTarget int32) (float64, error) {
	for _, chain := range r.candidates(ctx) {
		rate, err := chain.FeeRateSatPerVByte(ctx, confTarget)
		if err == nil {
			return rate, nil
		}
		zerolog.Ctx(ctx).Warn().Err(err).Str("chain", chain.Name()).Msg("fee estimate failed, trying next chain")
	}
	// A cheque sweep must not be blocked by a missing estimate.
	return MinChequeFeeRate, nil
}

func (r *ChequeChainRouter) Broadcast(ctx context.Context, txHex string) (string, error) {
	var lastErr error
	for _, chain := range r.candidates(ctx) {
		txid, err := chain.Broadcast(ctx, txHex)
		if err == nil {
			return txid, nil
		}
		lastErr = fmt.Errorf("%s: %w", chain.Name(), err)
	}
	if lastErr == nil {
		return "", ErrNoChequeChain
	}
	return "", lastErr
}
