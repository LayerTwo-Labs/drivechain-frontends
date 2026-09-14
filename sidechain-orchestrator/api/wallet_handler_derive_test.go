package api

import (
	"bytes"
	"context"
	"testing"

	"connectrpc.com/connect"
	"github.com/btcsuite/btcd/btcutil/hdkeychain"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

func TestDeriveAddressesSupportsPublicMultisig(t *testing.T) {
	log := zerolog.New(zerolog.NewTestWriter(t))
	svc := wallet.NewService(t.TempDir(), log)
	require.NoError(t, svc.Init())
	t.Cleanup(func() { svc.Close() })
	net := &chaincfg.SigNetParams
	var cosigners []wallet.MultisigCosigner
	for i := byte(1); i <= 3; i++ {
		key, err := hdkeychain.NewMaster(bytes.Repeat([]byte{i}, 32), net)
		require.NoError(t, err)
		pub, err := key.Neuter()
		require.NoError(t, err)
		cosigners = append(cosigners, wallet.MultisigCosigner{Xpub: pub.String()})
	}
	w, err := svc.CreateElectrumMultisig("Receive", nil, 2, 3, "wsh", cosigners)
	require.NoError(t, err)
	require.Empty(t, w.Master.SeedHex)
	require.True(t, w.IsWatchOnly())
	backend := wallet.NewElectrumBackend(svc, &psbtTestEsplora{}, wallet.StaticParams(net), log)
	h := NewWalletHandler(svc)
	h.SetEngine(wallet.NewWalletEngine(svc, wallet.NewBackendRouter(svc, nil, backend), wallet.StaticParams(net), log))
	ctx := context.Background()
	request := connect.NewRequest(&pb.DeriveAddressesRequest{WalletId: w.ID, StartIndex: 0, Count: 1})
	first, err := h.DeriveAddresses(ctx, request)
	require.NoError(t, err)
	require.Len(t, first.Msg.Addresses, 1)
	next, err := backend.NextReceiveAddress(ctx, w.ID, wallet.ScriptUnknown)
	require.NoError(t, err)
	require.Zero(t, next.Index)
	require.Equal(t, first.Msg.Addresses[0], next.Address)
	again, err := h.DeriveAddresses(ctx, request)
	require.NoError(t, err)
	require.Equal(t, first.Msg.Addresses, again.Msg.Addresses)
}

func TestDeriveAddressesRejectsAbsentWallet(t *testing.T) {
	h, _ := newDecodeHandler(t, &decodeBackend{})
	_, err := h.DeriveAddresses(context.Background(), connect.NewRequest(&pb.DeriveAddressesRequest{
		WalletId: "absent", StartIndex: 0, Count: 1,
	}))
	require.Equal(t, connect.CodeNotFound, connect.CodeOf(err))
}
