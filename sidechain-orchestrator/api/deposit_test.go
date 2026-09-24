package api

import (
	"context"
	"io"
	"net/http"
	"testing"

	"connectrpc.com/connect"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/wrapperspb"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	commonpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/common/v1"
	enforcerpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	enforcerrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
	wpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

func TestDepositTreasuryReady(t *testing.T) {
	funded := &enforcerpb.GetCtipResponse_Ctip{Vout: 1, Value: 5000}
	for _, tc := range []struct {
		name     string
		treasury sidechainTreasury
		wallet   int
		ok       bool
	}{
		{name: "funded at the tip", treasury: sidechainTreasury{enforcerHeight: 110, ctip: funded, slotActive: true}, wallet: 110, ok: true},
		{name: "enforcer ahead of the wallet", treasury: sidechainTreasury{enforcerHeight: 111, ctip: funded, slotActive: true}, wallet: 110, ok: true},
		{name: "first deposit to an active slot", treasury: sidechainTreasury{enforcerHeight: 110, slotActive: true}, wallet: 110, ok: true},
		{name: "no ctip on an inactive slot", treasury: sidechainTreasury{enforcerHeight: 110}, wallet: 110},
		{name: "enforcer behind with a ctip", treasury: sidechainTreasury{enforcerHeight: 100, ctip: funded, slotActive: true}, wallet: 110},
		{name: "enforcer behind with no ctip", treasury: sidechainTreasury{enforcerHeight: 100, slotActive: true}, wallet: 110},
		{name: "wiped enforcer", treasury: sidechainTreasury{}, wallet: 110},
	} {
		t.Run(tc.name, func(t *testing.T) {
			err := depositTreasuryReady(tc.treasury, tc.wallet, 2)
			if tc.ok {
				require.NoError(t, err)
				return
			}
			require.Error(t, err)
		})
	}
}

func TestCreateDepositRefusesAStaleTreasury(t *testing.T) {
	funded := &enforcerpb.GetCtipResponse_Ctip{
		Txid:  &commonpb.ReverseHex{Hex: wrapperspb.String("5555555555555555555555555555555555555555555555555555555555555555")},
		Vout:  0,
		Value: 12000,
	}
	for _, tc := range []struct {
		name      string
		validator ctipValidator
		code      connect.Code
	}{
		{name: "enforcer behind the tip", validator: ctipValidator{height: 100, slots: []uint32{9}, ctip: funded}, code: connect.CodeFailedPrecondition},
		{name: "no ctip on an inactive slot", validator: ctipValidator{height: 110}, code: connect.CodeFailedPrecondition},
		{name: "first deposit to an active slot", validator: ctipValidator{height: 110, slots: []uint32{9}}},
	} {
		t.Run(tc.name, func(t *testing.T) {
			mux := http.NewServeMux()
			path, handler := enforcerrpc.NewValidatorServiceHandler(tc.validator)
			mux.Handle(path, handler)
			server := h2cServer(mux)
			t.Cleanup(server.Close)
			host, port := hostPort(t, server)
			cfg := orchestrator.BinaryConfig{Name: "enforcer", Host: host, Port: port}
			orch := orchestrator.New(t.TempDir(), string(config.NetworkECash), t.TempDir(), []orchestrator.BinaryConfig{cfg}, zerolog.New(io.Discard))
			require.NoError(t, orchestrator.WriteNodeMode(orch.BitwindowDir, orchestrator.NodeModeFull))

			log := zerolog.New(io.Discard)
			svc := wallet.NewService(t.TempDir(), log)
			svc.SetNetwork("signet")
			require.NoError(t, svc.Init())
			t.Cleanup(func() { svc.Close() })
			w, err := svc.CreateElectrumWallet("E", nil, nil, "", "", "", "", 0, "")
			require.NoError(t, err)
			net := &chaincfg.SigNetParams
			addrs, err := wallet.DeriveBIP84Addresses(w.Master.SeedHex, net, 0, 1)
			require.NoError(t, err)
			chain := &bip47TestChain{
				addr:    addrs[0],
				amount:  500_000,
				txid:    "4444444444444444444444444444444444444444444444444444444444444444",
				feeRate: 5,
			}
			eb := wallet.NewElectrumBackend(svc, chain, wallet.StaticParams(net), log)
			h := NewWalletHandler(svc)
			h.SetEngine(wallet.NewWalletEngine(svc, wallet.NewBackendRouter(svc, nil, eb), wallet.StaticParams(net), log))
			h.SetOrchestrator(orch)

			_, err = h.CreateDeposit(context.Background(), connect.NewRequest(&wpb.CreateDepositRequest{
				WalletId:    w.ID,
				Slot:        9,
				Destination: "sidechainaddress",
				AmountSats:  100_000,
				FeeSats:     1_000,
			}))
			if tc.code == 0 {
				require.NoError(t, err)
				require.Len(t, chain.broadcast, 1)
				return
			}
			require.Error(t, err)
			require.Equal(t, tc.code, connect.CodeOf(err))
			require.Empty(t, chain.broadcast)
		})
	}
}
