package coinnews

import (
	"context"
	"testing"

	"github.com/btcsuite/btcd/btcec/v2/schnorr"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	codec "github.com/LayerTwo-Labs/sidesail/coinnews/codec"
)

// TestLoadOrCreateIdentity_StableAndSignable proves the identity key is
// created once and reused, and that a Vote signed with it verifies under
// the published x-only pubkey.
func TestLoadOrCreateIdentity_StableAndSignable(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	db := database.Test(t)

	priv1, xpk1, err := LoadOrCreateIdentity(ctx, db)
	require.NoError(t, err)
	priv2, xpk2, err := LoadOrCreateIdentity(ctx, db)
	require.NoError(t, err)

	assert.Equal(t, xpk1, xpk2, "x-only pubkey must be stable across calls")
	assert.Equal(t, priv1.Serialize(), priv2.Serialize(), "private key must persist, not regenerate")

	var target codec.ItemID
	target[0] = 0x12
	digest := codec.VoteSigHash(codec.TypeUpvote, target)
	sig, err := schnorr.Sign(priv1, digest[:])
	require.NoError(t, err)

	var sigArr [codec.SchnorrSigLen]byte
	copy(sigArr[:], sig.Serialize())
	assert.True(t, codec.VerifyVoteSig(xpk1, codec.TypeUpvote, target, sigArr),
		"signature from identity key must verify under its published xpk")
}
