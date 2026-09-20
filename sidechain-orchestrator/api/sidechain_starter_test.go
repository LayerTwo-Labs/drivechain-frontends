package api

import (
	"context"
	"testing"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

func starterHandler(t *testing.T) *WalletHandler {
	t.Helper()
	log := zerolog.Nop()
	svc := wallet.NewService(t.TempDir(), log)
	require.NoError(t, svc.Init())
	t.Cleanup(func() { svc.Close() })
	_, err := svc.GenerateWallet("Primary", "", "", nil)
	require.NoError(t, err)
	return NewWalletHandler(svc)
}

func ensureStarter(t *testing.T, h *WalletHandler, slot uint32, name string) string {
	t.Helper()
	resp, err := h.EnsureSidechainStarter(context.Background(),
		connect.NewRequest(&pb.EnsureSidechainStarterRequest{Slot: slot, Name: name}))
	require.NoError(t, err)
	return resp.Msg.Mnemonic
}

func TestEnsureSidechainStarterDerivesAnUnknownSlot(t *testing.T) {
	h := starterHandler(t)
	mnemonic := ensureStarter(t, h, 8, "SOL")
	require.NotEmpty(t, mnemonic)
	require.Len(t, splitWords(mnemonic), 12)
}

func TestEnsureSidechainStarterRepeatsTheSamePhrase(t *testing.T) {
	h := starterHandler(t)
	first := ensureStarter(t, h, 8, "SOL")
	second := ensureStarter(t, h, 8, "SOL")
	require.Equal(t, first, second)
}

func TestEnsureSidechainStarterGivesEachSlotItsOwnPhrase(t *testing.T) {
	h := starterHandler(t)
	require.NotEqual(t, ensureStarter(t, h, 8, "SOL"), ensureStarter(t, h, 9, "Thunder"))
}

func TestEnsureSidechainStarterReachesTheWalletList(t *testing.T) {
	h := starterHandler(t)
	mnemonic := ensureStarter(t, h, 8, "SOL")
	require.Equal(t, mnemonic, h.svc.GetSidechainMnemonic(8))
}

func TestEnsureSidechainStarterRejectsASlotAbove255(t *testing.T) {
	h := starterHandler(t)
	_, err := h.EnsureSidechainStarter(context.Background(),
		connect.NewRequest(&pb.EnsureSidechainStarterRequest{Slot: 256, Name: "SOL"}))
	require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
}

func TestEnsureSidechainStarterRejectsAnEmptyName(t *testing.T) {
	h := starterHandler(t)
	_, err := h.EnsureSidechainStarter(context.Background(),
		connect.NewRequest(&pb.EnsureSidechainStarterRequest{Slot: 8}))
	require.Equal(t, connect.CodeInvalidArgument, connect.CodeOf(err))
}

func TestEnsureSidechainStarterFailsWithoutAWallet(t *testing.T) {
	log := zerolog.Nop()
	svc := wallet.NewService(t.TempDir(), log)
	require.NoError(t, svc.Init())
	t.Cleanup(func() { svc.Close() })
	h := NewWalletHandler(svc)
	_, err := h.EnsureSidechainStarter(context.Background(),
		connect.NewRequest(&pb.EnsureSidechainStarterRequest{Slot: 8, Name: "SOL"}))
	require.Error(t, err)
}

func splitWords(phrase string) []string {
	words := []string{}
	word := ""
	for _, r := range phrase {
		if r == ' ' {
			if word != "" {
				words = append(words, word)
				word = ""
			}
			continue
		}
		word += string(r)
	}
	if word != "" {
		words = append(words, word)
	}
	return words
}
