package wallet

import (
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// Each wallet carries its own seed, so a moved pin restarts every sidechain
// against coins the user does not hold. The delete has to refuse.
func TestDeleteWalletRefusesTheStarter(t *testing.T) {
	svc := newTestService(t)

	first, err := svc.GenerateWallet("First", "", "", testSlots)
	require.NoError(t, err)
	second, err := svc.GenerateWallet("Second", "", "", testSlots)
	require.NoError(t, err)

	require.Equal(t, first.ID, svc.StarterWalletID(), "the first seeded wallet holds the pin")

	err = svc.DeleteWallet(first.ID)
	require.Error(t, err)
	assert.Contains(t, err.Error(), "derives the sidechain starters")

	require.NoError(t, svc.DeleteWallet(second.ID), "any other wallet still deletes")
	assert.Equal(t, first.ID, svc.StarterWalletID(), "the pin never moves")
}
