package api

import (
	"bytes"
	"context"
	"encoding/hex"
	"io"
	"net/http"
	"testing"
	"time"

	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/wire"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config"
	enforcerrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
	wpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

// depositHarness wires a wallet handler to a funded test chain and an enforcer
// that reports the given active slots.
func depositHarness(t *testing.T, slots ...uint32) (*WalletHandler, *bip47TestChain, string) {
	t.Helper()
	mux := http.NewServeMux()
	rpcServer := connect.NewServer()
	enforcerrpc.RegisterValidatorServiceHandler(rpcServer, ctipValidator{height: 110, slots: slots})
	connecthttp.Mount(mux, rpcServer, connecthttp.WithReadMaxBytes(0))
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
	chain := newBip47TestChain(t, addrs[0], 500_000, 5)
	eb := wallet.NewElectrumBackend(svc, chain, wallet.StaticParams(net), log)
	h := NewWalletHandler(svc)
	h.SetEngine(wallet.NewWalletEngine(svc, wallet.NewBackendRouter(svc, nil, eb), wallet.StaticParams(net), log))
	h.SetOrchestrator(orch)
	return h, chain, w.ID
}

func TestCreateDepositBroadcastsARequest(t *testing.T) {
	h, chain, walletID := depositHarness(t, 9)

	resp, err := h.CreateDeposit(context.Background(), &wpb.CreateDepositRequest{
		WalletId:    walletID,
		Slot:        9,
		Destination: "sidechainaddress",
		AmountSats:  100_000,
		FeeSats:     1_000,
	})
	require.NoError(t, err)
	require.Len(t, chain.broadcast, 1)

	raw, err := hex.DecodeString(chain.broadcast[0])
	require.NoError(t, err)
	var tx wire.MsgTx
	require.NoError(t, tx.Deserialize(bytes.NewReader(raw)))
	assert.Equal(t, tx.TxID(), resp.Txid)

	require.GreaterOrEqual(t, len(tx.TxOut), 2)
	assert.Equal(t, orchestrator.M8TreasuryScript(9), tx.TxOut[0].PkScript, "the request output comes first")
	assert.EqualValues(t, 100_000, tx.TxOut[0].Value, "the request holds only the amount")
	assert.Equal(t, append([]byte{0x6a, byte(len("sidechainaddress"))}, "sidechainaddress"...), tx.TxOut[1].PkScript,
		"the address follows the request output")
	require.Len(t, tx.TxIn, 1, "a request spends only the wallet's coin, never a CTIP")
	assert.Equal(t, chain.txid, tx.TxIn[0].PreviousOutPoint.Hash.String())

	deposits, err := h.svc.SidechainDeposits(context.Background(), 9, walletID)
	require.NoError(t, err)
	require.Len(t, deposits, 1)
	assert.Equal(t, "sidechainaddress", deposits[0].Destination)
}

func TestCreateDepositRefusesAnInactiveSlot(t *testing.T) {
	h, chain, walletID := depositHarness(t)

	_, err := h.CreateDeposit(context.Background(), &wpb.CreateDepositRequest{
		WalletId:    walletID,
		Slot:        9,
		Destination: "sidechainaddress",
		AmountSats:  100_000,
		FeeSats:     1_000,
	})
	require.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
	require.Empty(t, chain.broadcast)
}

// A dropped deposit sits in no block, so zero is its real count.
func TestDepositConfirmationsSkipsADroppedDeposit(t *testing.T) {
	h := &WalletHandler{}
	dropped := wallet.SidechainDeposit{Txid: "gone", DroppedAt: time.Now()}
	require.Zero(t, h.depositConfirmations(context.Background(), dropped))
}

// The broadcast cannot be undone, so a busy store is worth a retry.
func TestRecordDepositRetriesABusyStore(t *testing.T) {
	ctx := context.Background()
	svc := wallet.NewService(t.TempDir(), zerolog.Nop())
	svc.SetNetwork("signet")
	require.NoError(t, svc.Init())
	defer svc.Close()

	h := &WalletHandler{svc: svc}
	err := h.recordDeposit(ctx, wallet.SidechainDeposit{Txid: "dep", WalletID: "w", Slot: 2, AmountSats: 5})

	require.NoError(t, err)
	deposits, err := svc.SidechainDeposits(ctx, 2, "")
	require.NoError(t, err)
	require.Len(t, deposits, 1)
}

func TestListTransactionsTagsADepositRequest(t *testing.T) {
	depositRaw, _, depositTx := warningTransaction(t, warningOutputs(t)[1:])
	plainRaw, _, plainTx := warningTransaction(t, warningOutputs(t)[:1])
	backend := &warningBackend{
		hexByID: map[string]string{depositTx.TxID: depositRaw, plainTx.TxID: plainRaw},
		transactions: []wallet.WalletTransaction{
			{TxID: depositTx.TxID, Category: "send"},
			{TxID: plainTx.TxID, Category: "send"},
		},
	}
	require.NotEqual(t, depositTx.TxID, plainTx.TxID)
	h, walletID := newWarningHandler(t, backend)
	require.NoError(t, h.svc.RecordSidechainDeposit(context.Background(), wallet.SidechainDeposit{
		Txid: depositTx.TxID, WalletID: walletID, Slot: 9, Destination: "sidechainaddress", AmountSats: 100_000,
	}))

	resp, err := h.ListTransactions(context.Background(), &wpb.ListTransactionsRequest{WalletId: walletID})
	require.NoError(t, err)
	require.Len(t, resp.Transactions, 2)
	for _, entry := range resp.Transactions {
		if entry.Txid != depositTx.TxID {
			assert.Nil(t, entry.SidechainDeposit)
			continue
		}
		require.NotNil(t, entry.SidechainDeposit)
		assert.EqualValues(t, 9, entry.SidechainDeposit.Slot)
		assert.Equal(t, "sidechainaddress", entry.SidechainDeposit.Destination)
	}
}
