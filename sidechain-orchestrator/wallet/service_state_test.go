package wallet

import (
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

func TestServiceState(t *testing.T) {
	dir := t.TempDir()
	log := zerolog.New(zerolog.NewTestWriter(t))
	svc := NewService(dir, log)
	require.NoError(t, svc.Init())
	t.Cleanup(svc.Close)
	require.Equal(t, StateNoWallet, svc.State())

	_, err := svc.GenerateWallet("State", "", "", testSlots)
	require.NoError(t, err)
	require.Equal(t, StateUnlocked, svc.State())

	reloaded := NewService(dir, log)
	require.NoError(t, reloaded.Init())
	require.Equal(t, StateUnlocked, reloaded.State(), "an unencrypted wallet loads unlocked")
	reloaded.Close()

	require.NoError(t, svc.EncryptWallet("pass"))
	require.Equal(t, StateUnlocked, svc.State())

	svc.LockWallet()
	require.Equal(t, StateLocked, svc.State())

	require.ErrorIs(t, svc.UnlockWallet("wrong"), ErrIncorrectPassword)
	require.Equal(t, StateLocked, svc.State())

	require.NoError(t, svc.UnlockWallet("pass"))
	require.Equal(t, StateUnlocked, svc.State())

	require.NoError(t, svc.DeleteAllWallets(nil, nil))
	require.Equal(t, StateNoWallet, svc.State())
}
