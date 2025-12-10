package m4_test

import (
	"context"
	"testing"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	m4pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/m4/v1"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/m4/v1/m4v1connect"
	m4models "github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/m4"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/apitests"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

func TestService_GetVotePreferences(t *testing.T) {
	t.Parallel()

	t.Run("returns empty preferences when none set", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		cli := m4v1connect.NewM4ServiceClient(apitests.API(t, db))

		resp, err := cli.GetVotePreferences(context.Background(), connect.NewRequest(&m4pb.GetVotePreferencesRequest{}))
		require.NoError(t, err)
		assert.Empty(t, resp.Msg.Preferences)
	})

	t.Run("returns stored preferences", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		cli := m4v1connect.NewM4ServiceClient(apitests.API(t, db))

		// Set a preference first
		_, err := cli.SetVotePreference(context.Background(), connect.NewRequest(&m4pb.SetVotePreferenceRequest{
			SidechainSlot: 0,
			VoteType:      "abstain",
		}))
		require.NoError(t, err)

		// Get preferences
		resp, err := cli.GetVotePreferences(context.Background(), connect.NewRequest(&m4pb.GetVotePreferencesRequest{}))
		require.NoError(t, err)
		require.Len(t, resp.Msg.Preferences, 1)
		assert.Equal(t, uint32(0), resp.Msg.Preferences[0].SidechainSlot)
		assert.Equal(t, "abstain", resp.Msg.Preferences[0].VoteType)
	})

	t.Run("returns multiple preferences", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		cli := m4v1connect.NewM4ServiceClient(apitests.API(t, db))

		// Set multiple preferences
		_, err := cli.SetVotePreference(context.Background(), connect.NewRequest(&m4pb.SetVotePreferenceRequest{
			SidechainSlot: 0,
			VoteType:      "abstain",
		}))
		require.NoError(t, err)

		_, err = cli.SetVotePreference(context.Background(), connect.NewRequest(&m4pb.SetVotePreferenceRequest{
			SidechainSlot: 1,
			VoteType:      "alarm",
		}))
		require.NoError(t, err)

		bundleHash := "deadbeef1234567890abcdef1234567890abcdef1234567890abcdef12345678"
		_, err = cli.SetVotePreference(context.Background(), connect.NewRequest(&m4pb.SetVotePreferenceRequest{
			SidechainSlot: 2,
			VoteType:      "upvote",
			BundleHash:    &bundleHash,
		}))
		require.NoError(t, err)

		// Get preferences
		resp, err := cli.GetVotePreferences(context.Background(), connect.NewRequest(&m4pb.GetVotePreferencesRequest{}))
		require.NoError(t, err)
		require.Len(t, resp.Msg.Preferences, 3)

		// Verify order (by sidechain slot)
		assert.Equal(t, uint32(0), resp.Msg.Preferences[0].SidechainSlot)
		assert.Equal(t, uint32(1), resp.Msg.Preferences[1].SidechainSlot)
		assert.Equal(t, uint32(2), resp.Msg.Preferences[2].SidechainSlot)
	})
}

func TestService_SetVotePreference(t *testing.T) {
	t.Parallel()

	t.Run("valid abstain vote", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		cli := m4v1connect.NewM4ServiceClient(apitests.API(t, db))

		resp, err := cli.SetVotePreference(context.Background(), connect.NewRequest(&m4pb.SetVotePreferenceRequest{
			SidechainSlot: 0,
			VoteType:      "abstain",
		}))
		require.NoError(t, err)
		assert.True(t, resp.Msg.Success)
	})

	t.Run("valid alarm vote", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		cli := m4v1connect.NewM4ServiceClient(apitests.API(t, db))

		resp, err := cli.SetVotePreference(context.Background(), connect.NewRequest(&m4pb.SetVotePreferenceRequest{
			SidechainSlot: 0,
			VoteType:      "alarm",
		}))
		require.NoError(t, err)
		assert.True(t, resp.Msg.Success)
	})

	t.Run("valid upvote with bundle hash", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		cli := m4v1connect.NewM4ServiceClient(apitests.API(t, db))

		bundleHash := "deadbeef1234567890abcdef1234567890abcdef1234567890abcdef12345678"
		resp, err := cli.SetVotePreference(context.Background(), connect.NewRequest(&m4pb.SetVotePreferenceRequest{
			SidechainSlot: 0,
			VoteType:      "upvote",
			BundleHash:    &bundleHash,
		}))
		require.NoError(t, err)
		assert.True(t, resp.Msg.Success)
	})

	t.Run("invalid vote type returns error", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		cli := m4v1connect.NewM4ServiceClient(apitests.API(t, db))

		_, err := cli.SetVotePreference(context.Background(), connect.NewRequest(&m4pb.SetVotePreferenceRequest{
			SidechainSlot: 0,
			VoteType:      "invalid_type",
		}))
		require.Error(t, err)
	})

	t.Run("updates existing preference", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		cli := m4v1connect.NewM4ServiceClient(apitests.API(t, db))

		// Set initial preference
		_, err := cli.SetVotePreference(context.Background(), connect.NewRequest(&m4pb.SetVotePreferenceRequest{
			SidechainSlot: 0,
			VoteType:      "abstain",
		}))
		require.NoError(t, err)

		// Update to different preference
		_, err = cli.SetVotePreference(context.Background(), connect.NewRequest(&m4pb.SetVotePreferenceRequest{
			SidechainSlot: 0,
			VoteType:      "alarm",
		}))
		require.NoError(t, err)

		// Verify update
		resp, err := cli.GetVotePreferences(context.Background(), connect.NewRequest(&m4pb.GetVotePreferencesRequest{}))
		require.NoError(t, err)
		require.Len(t, resp.Msg.Preferences, 1)
		assert.Equal(t, "alarm", resp.Msg.Preferences[0].VoteType)
	})

	t.Run("max sidechain slot (255)", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		cli := m4v1connect.NewM4ServiceClient(apitests.API(t, db))

		resp, err := cli.SetVotePreference(context.Background(), connect.NewRequest(&m4pb.SetVotePreferenceRequest{
			SidechainSlot: 255,
			VoteType:      "abstain",
		}))
		require.NoError(t, err)
		assert.True(t, resp.Msg.Success)

		// Verify
		prefs, err := cli.GetVotePreferences(context.Background(), connect.NewRequest(&m4pb.GetVotePreferencesRequest{}))
		require.NoError(t, err)
		require.Len(t, prefs.Msg.Preferences, 1)
		assert.Equal(t, uint32(255), prefs.Msg.Preferences[0].SidechainSlot)
	})
}

func TestService_GetM4History(t *testing.T) {
	t.Parallel()

	t.Run("returns empty history when no blocks processed", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		cli := m4v1connect.NewM4ServiceClient(apitests.API(t, db))

		resp, err := cli.GetM4History(context.Background(), connect.NewRequest(&m4pb.GetM4HistoryRequest{}))
		require.NoError(t, err)
		assert.Empty(t, resp.Msg.History)
	})

	t.Run("respects limit parameter", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		cli := m4v1connect.NewM4ServiceClient(apitests.API(t, db))

		// Request with limit=0 (should default to 6)
		resp, err := cli.GetM4History(context.Background(), connect.NewRequest(&m4pb.GetM4HistoryRequest{
			Limit: 0,
		}))
		require.NoError(t, err)
		// With no data, it will just be empty
		assert.Empty(t, resp.Msg.History)
	})
}

func TestService_GenerateM4Bytes(t *testing.T) {
	t.Parallel()

	t.Run("no pending bundles returns not required", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		cli := m4v1connect.NewM4ServiceClient(apitests.API(t, db))

		resp, err := cli.GenerateM4Bytes(context.Background(), connect.NewRequest(&m4pb.GenerateM4BytesRequest{}))
		require.NoError(t, err)
		assert.Empty(t, resp.Msg.Hex)
		assert.Contains(t, resp.Msg.Interpretation, "Not required")
	})
}

// Direct M4Engine tests for database operations
func TestM4Engine_VotePreferences(t *testing.T) {
	t.Parallel()

	t.Run("set and get vote preference directly", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctx := context.Background()
		engine := engines.NewM4Engine(db)

		// Set abstain preference
		err := engine.SetVotePreference(ctx, 0, m4models.VoteTypeAbstain, nil)
		require.NoError(t, err)

		// Get preferences
		prefs, err := engine.GetVotePreferences(ctx)
		require.NoError(t, err)
		require.Len(t, prefs, 1)
		assert.Equal(t, uint8(0), prefs[0].SidechainSlot)
		assert.Equal(t, m4models.VoteTypeAbstain, prefs[0].VoteType)
	})

	t.Run("update existing preference", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctx := context.Background()
		engine := engines.NewM4Engine(db)

		// Set initial preference
		err := engine.SetVotePreference(ctx, 0, m4models.VoteTypeAbstain, nil)
		require.NoError(t, err)

		// Update to alarm
		err = engine.SetVotePreference(ctx, 0, m4models.VoteTypeAlarm, nil)
		require.NoError(t, err)

		// Verify only one preference exists with updated value
		prefs, err := engine.GetVotePreferences(ctx)
		require.NoError(t, err)
		require.Len(t, prefs, 1)
		assert.Equal(t, m4models.VoteTypeAlarm, prefs[0].VoteType)
	})

	t.Run("set upvote with bundle hash", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctx := context.Background()
		engine := engines.NewM4Engine(db)

		bundleHash := "deadbeef1234567890abcdef1234567890abcdef1234567890abcdef12345678"
		err := engine.SetVotePreference(ctx, 5, m4models.VoteTypeUpvote, &bundleHash)
		require.NoError(t, err)

		prefs, err := engine.GetVotePreferences(ctx)
		require.NoError(t, err)
		require.Len(t, prefs, 1)
		assert.Equal(t, uint8(5), prefs[0].SidechainSlot)
		assert.Equal(t, m4models.VoteTypeUpvote, prefs[0].VoteType)
		require.NotNil(t, prefs[0].BundleHash)
		assert.Equal(t, bundleHash, *prefs[0].BundleHash)
	})

	t.Run("multiple sidechains", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctx := context.Background()
		engine := engines.NewM4Engine(db)

		// Set preferences for multiple sidechains
		err := engine.SetVotePreference(ctx, 0, m4models.VoteTypeAbstain, nil)
		require.NoError(t, err)

		err = engine.SetVotePreference(ctx, 1, m4models.VoteTypeAlarm, nil)
		require.NoError(t, err)

		bundleHash := "abcd1234"
		err = engine.SetVotePreference(ctx, 2, m4models.VoteTypeUpvote, &bundleHash)
		require.NoError(t, err)

		// Verify all preferences
		prefs, err := engine.GetVotePreferences(ctx)
		require.NoError(t, err)
		require.Len(t, prefs, 3)

		// Should be ordered by sidechain slot
		assert.Equal(t, uint8(0), prefs[0].SidechainSlot)
		assert.Equal(t, uint8(1), prefs[1].SidechainSlot)
		assert.Equal(t, uint8(2), prefs[2].SidechainSlot)
	})
}

func TestM4Engine_GetM4History(t *testing.T) {
	t.Parallel()

	t.Run("empty history", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctx := context.Background()
		engine := engines.NewM4Engine(db)

		history, err := engine.GetM4History(ctx, 10)
		require.NoError(t, err)
		assert.Empty(t, history)
	})
}

func TestM4Engine_GetWithdrawalBundles(t *testing.T) {
	t.Parallel()

	t.Run("empty bundles", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctx := context.Background()
		engine := engines.NewM4Engine(db)

		bundles, err := engine.GetWithdrawalBundles(ctx, nil)
		require.NoError(t, err)
		assert.Empty(t, bundles)
	})

	t.Run("filter by sidechain slot", func(t *testing.T) {
		t.Parallel()

		db := database.Test(t)
		ctx := context.Background()
		engine := engines.NewM4Engine(db)

		// Query for specific sidechain (should be empty)
		slot := uint8(0)
		bundles, err := engine.GetWithdrawalBundles(ctx, &slot)
		require.NoError(t, err)
		assert.Empty(t, bundles)
	})
}
