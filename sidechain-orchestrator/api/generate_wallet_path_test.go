package api

import (
	"context"
	"testing"

	"connectrpc.com/connect/v2"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
)

// A Core wallet infers its address kind from the path, so a caller that states
// no script type may still ask for any standard path. SailCreateWalletPage is
// one such caller: it sends a typed path and no type at all.
func TestGenerateWalletAcceptsAStandardPathWithNoScriptType(t *testing.T) {
	h, _, _, _, _ := newRoutedHandler(t)

	resp, err := h.GenerateWallet(context.Background(), &pb.GenerateWalletRequest{
		Name:           "Taproot",
		DerivationPath: "m/86'/1'/0'",
	})
	require.NoError(t, err)
	assert.Equal(t, "taproot", h.svc.GetWalletByID(resp.WalletId).ScriptType)
}

// A stated type and a path that disagree would scan addresses the wallet does
// not own, so the pair is refused rather than silently resolved.
func TestGenerateWalletRefusesAPathThatFightsTheScriptType(t *testing.T) {
	h, _, _, _, _ := newRoutedHandler(t)

	_, err := h.GenerateWallet(context.Background(), &pb.GenerateWalletRequest{
		Name:           "Mismatch",
		DerivationPath: "m/86'/1'/0'",
		ScriptType:     "legacy",
	})
	require.Error(t, err)
	assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
}

func TestGenerateWalletRefusesABadMnemonic(t *testing.T) {
	h, _, _, _, _ := newRoutedHandler(t)

	_, err := h.GenerateWallet(context.Background(), &pb.GenerateWalletRequest{
		Name:           "Bad",
		CustomMnemonic: "abandon abandon abandon",
	})
	require.Error(t, err)
	assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
}

func TestCreateWatchOnlyWalletRefusesABadKey(t *testing.T) {
	h, _, _, _, _ := newRoutedHandler(t)

	_, err := h.CreateWatchOnlyWallet(context.Background(), &pb.CreateWatchOnlyWalletRequest{
		Name:             "Bad",
		XpubOrDescriptor: "not-a-key",
	})
	require.Error(t, err)
	assert.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
}

func TestDeleteWalletCodes(t *testing.T) {
	h, _, _, _, coreID := newRoutedHandler(t)
	require.Equal(t, coreID, h.svc.StarterWalletID())

	_, err := h.DeleteWallet(context.Background(), &pb.DeleteWalletRequest{WalletId: "missing"})
	assert.Equal(t, connect.CodeNotFound, connect.CodeOf(err))

	_, err = h.DeleteWallet(context.Background(), &pb.DeleteWalletRequest{WalletId: coreID})
	assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
}
