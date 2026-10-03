package wallet

import (
	"context"
	"os"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

// Each wallet carries its own sidechain seed, and a sidechain starts with the
// one of the active wallet.
func TestSidechainStarterComesFromTheActiveWallet(t *testing.T) {
	svc := newTestService(t)
	first, err := svc.GenerateWallet("First", "", "", testSlots)
	require.NoError(t, err)
	second, err := svc.GenerateWallet("Second", "", "", testSlots)
	require.NoError(t, err)
	require.NotEqual(t, first.Sidechains[0].Mnemonic, second.Sidechains[0].Mnemonic)
	slot := first.Sidechains[0].Slot

	starterOf := func() string {
		path, err := svc.WriteSidechainStarterFor(svc.SidechainWalletID(), slot)
		require.NoError(t, err)
		raw, err := os.ReadFile(path)
		require.NoError(t, err)
		return string(raw)
	}

	t.Run("the new wallet is active", func(t *testing.T) {
		require.Equal(t, second.ID, svc.SidechainWalletID())
		require.Equal(t, second.Sidechains[0].Mnemonic, starterOf())
	})

	t.Run("a switch selects the other seed", func(t *testing.T) {
		require.NoError(t, svc.SwitchWallet(first.ID))
		require.Equal(t, first.ID, svc.SidechainWalletID())
		require.Equal(t, first.Sidechains[0].Mnemonic, starterOf())
		got, err := svc.GetOrDeriveSidechainStarterFor(svc.SidechainWalletID(), slot, "Thunder")
		require.NoError(t, err)
		require.Equal(t, first.Sidechains[0].Mnemonic, got)
	})

	// A Core derived sidechain keeps its wallet in Core under one name, so it
	// stays on the starter wallet.
	t.Run("the starter functions stay on the starter wallet", func(t *testing.T) {
		require.NoError(t, svc.SwitchWallet(second.ID))
		got, err := svc.GetOrDeriveSidechainStarter(slot, "Thunder")
		require.NoError(t, err)
		require.Equal(t, first.Sidechains[0].Mnemonic, got)
		require.Equal(t, first.ID, svc.StarterWalletID())
	})
}

// With an encrypted file the sidechains learn their wallet only at the unlock,
// so the unlock must tell the subscribers.
func TestUnlockTellsTheSubscribers(t *testing.T) {
	svc, _, _ := generateAndEncrypt(t, "correct horse")
	svc.LockWallet()

	ctx, cancel := context.WithCancel(context.Background())
	defer cancel()
	changed := svc.Subscribe(ctx)
	// The file watcher reports the encryption late, so wait for quiet first.
	for quiet := false; !quiet; {
		select {
		case <-changed:
		case <-time.After(time.Second):
			quiet = true
		}
	}

	require.NoError(t, svc.UnlockWallet("correct horse"))
	select {
	case <-changed:
	case <-time.After(5 * time.Second):
		t.Fatal("the unlock told no subscriber")
	}
}
