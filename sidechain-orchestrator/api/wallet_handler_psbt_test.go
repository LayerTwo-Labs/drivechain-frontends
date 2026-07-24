package api

import (
	"context"
	"errors"
	"testing"

	"connectrpc.com/connect"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

// psbtTestEsplora is a minimal wallet.Esplora that funds a single address, so a
// handler-level test can drive the real electrum backend without a REST server.
type psbtTestEsplora struct {
	addr   string
	amount int64
	txid   string
}

func (e *psbtTestEsplora) AddressStats(_ context.Context, a string) (wallet.EsploraAddressStats, error) {
	if a == e.addr {
		return wallet.EsploraAddressStats{Address: a, ChainStats: wallet.EsploraTxoStats{FundedTxoCount: 1, FundedTxoSum: e.amount, TxCount: 1}}, nil
	}
	return wallet.EsploraAddressStats{Address: a}, nil
}

func (e *psbtTestEsplora) AddressUTXOs(_ context.Context, a string) ([]wallet.EsploraUTXO, error) {
	if a == e.addr {
		return []wallet.EsploraUTXO{{TxID: e.txid, Vout: 0, Value: e.amount, Status: wallet.EsploraStatus{Confirmed: true, BlockHeight: 100}}}, nil
	}
	return nil, nil
}

func (e *psbtTestEsplora) AddressTxs(context.Context, string) ([]wallet.EsploraTx, error) {
	return nil, nil
}
func (e *psbtTestEsplora) Tx(context.Context, string) (wallet.EsploraTx, error) {
	return wallet.EsploraTx{}, errors.New("not found")
}
func (e *psbtTestEsplora) TxHex(context.Context, string) (string, error) {
	return "", errors.New("not found")
}
func (e *psbtTestEsplora) Broadcast(context.Context, string) (string, error) { return "txid", nil }
func (e *psbtTestEsplora) TipHeight(context.Context) (int, error)            { return 110, nil }
func (e *psbtTestEsplora) FeeRateForTarget(context.Context, int, float64) float64 {
	return 2
}

// TestWalletHandlerPSBTRoundTrip drives the exposed PSBT RPCs through the real
// handler → engine → electrum backend stack: create → sign → finalize.
func TestWalletHandlerPSBTRoundTrip(t *testing.T) {
	log := zerolog.New(zerolog.NewTestWriter(t))
	svc := wallet.NewService(t.TempDir(), log)
	require.NoError(t, svc.Init())
	t.Cleanup(func() { svc.Close() })

	w, err := svc.CreateElectrumWallet("E", nil, nil, "", "", "", "", 0, "")
	require.NoError(t, err)

	net := &chaincfg.SigNetParams
	addrs, err := wallet.DeriveBIP84Addresses(w.Master.SeedHex, net, 0, 1)
	require.NoError(t, err)

	esplora := &psbtTestEsplora{
		addr:   addrs[0],
		amount: 200_000,
		txid:   "4444444444444444444444444444444444444444444444444444444444444444",
	}
	eb := wallet.NewElectrumBackend(svc, esplora, net, log)
	engine := wallet.NewWalletEngine(svc, wallet.NewBackendRouter(svc, nil, nil, eb), net, log)
	h := NewWalletHandler(svc)
	h.SetEngine(engine)

	ctx := context.Background()
	const dest = "tb1qw508d6qejxtdg4y5r3zarvary0c5xw7kxpjzsx"

	created, err := h.CreatePsbt(ctx, connect.NewRequest(&pb.CreatePsbtRequest{
		WalletId:           w.ID,
		Destinations:       map[string]int64{dest: 50_000},
		FeeRateSatPerVbyte: 2,
	}))
	require.NoError(t, err)
	require.NotEmpty(t, created.Msg.PsbtBase64)

	signed, err := h.SignPsbt(ctx, connect.NewRequest(&pb.SignPsbtRequest{
		WalletId:   w.ID,
		PsbtBase64: created.Msg.PsbtBase64,
	}))
	require.NoError(t, err)

	final, err := h.FinalizePsbt(ctx, connect.NewRequest(&pb.FinalizePsbtRequest{
		PsbtBase64: signed.Msg.PsbtBase64,
	}))
	require.NoError(t, err)
	require.NotEmpty(t, final.Msg.RawTxHex)
}

// TestWalletNeedsL1 covers the switch-time L1 decision: only electrum wallets
// skip the local Bitcoin backends.
func TestWalletNeedsL1(t *testing.T) {
	log := zerolog.New(zerolog.NewTestWriter(t))
	svc := wallet.NewService(t.TempDir(), log)
	require.NoError(t, svc.Init())
	t.Cleanup(func() { svc.Close() })

	full, err := svc.GenerateWallet("Full", "", "", nil)
	require.NoError(t, err)
	elec, err := svc.CreateElectrumWallet("E", nil, nil, "", "", "", "", 0, "")
	require.NoError(t, err)

	h := NewWalletHandler(svc)
	require.True(t, h.walletNeedsL1(full.ID), "non-electrum wallet needs L1")
	require.False(t, h.walletNeedsL1(elec.ID), "electrum wallet does not need L1")
	require.False(t, h.walletNeedsL1("nonexistent"), "unknown wallet does not need L1")
}

// TestListWalletsElectrumHasNoBip47Code: hot electrum wallets must not advertise
// a BIP47 payment code, since inbound BIP47 only watches bitcoinCore wallets.
func TestListWalletsElectrumHasNoBip47Code(t *testing.T) {
	log := zerolog.New(zerolog.NewTestWriter(t))
	svc := wallet.NewService(t.TempDir(), log)
	require.NoError(t, svc.Init())
	t.Cleanup(func() { svc.Close() })

	w, err := svc.CreateElectrumWallet("E", nil, nil, "", "", "", "", 0, "")
	require.NoError(t, err)

	h := NewWalletHandler(svc)
	resp, err := h.ListWallets(context.Background(), connect.NewRequest(&pb.ListWalletsRequest{}))
	require.NoError(t, err)

	found := false
	for _, mw := range resp.Msg.Wallets {
		if mw.Id == w.ID {
			found = true
			require.Empty(t, mw.Bip47PaymentCode, "electrum wallet must not advertise a BIP47 code")
		}
	}
	require.True(t, found)
}
