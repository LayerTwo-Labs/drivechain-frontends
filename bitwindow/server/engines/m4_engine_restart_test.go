package engines

import (
	"encoding/binary"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/wrapperspb"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/m4"
	validatorpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
)

func TestM4RestartKeepsTheRepeatVote(t *testing.T) {
	for _, version := range []byte{0x01, 0x03} {
		name := "index vote"
		if version == 0x03 {
			name = "leading vote"
		}
		t.Run(name, func(t *testing.T) {
			ctx := t.Context()
			conf := config.Config{Datadir: t.TempDir(), BitcoinCoreNetwork: config.NetworkMainnet}
			db, err := database.New(ctx, conf)
			require.NoError(t, err)
			t.Cleanup(func() { require.NoError(t, db.Close()) })
			engine := NewM4Engine(db, conf.BitcoinCoreNetwork)
			seedBundle(t, ctx, engine, "bundle-a", 100)
			_, err = db.ExecContext(ctx, `UPDATE withdrawal_bundles SET work_score = 50`)
			require.NoError(t, err)
			sidechains := []*validatorpb.GetSidechainsResponse_SidechainInfo{{
				SidechainNumber:  wrapperspb.UInt32(0),
				ActivationHeight: wrapperspb.UInt32(10),
			}}
			payload := binary.BigEndian.AppendUint32(nil, m4.M4CommitmentHeader)
			payload = append(payload, version)
			if version == 0x01 {
				payload = append(payload, 0x00)
			}
			first := coinbaseBlockOf(opReturnScript(t, payload), time.Unix(1700000000, 0))
			require.NoError(t, engine.ProcessBlock(ctx, 150, first))

			_, err = db.ExecContext(ctx, `CREATE TRIGGER refuse_m4_marker BEFORE UPDATE OF applied ON m4_messages
				BEGIN SELECT RAISE(ABORT, 'marker refused'); END`)
			require.NoError(t, err)
			require.ErrorContains(t, engine.ApplyPendingM4(ctx, 150, sidechains, nil), "marker refused")
			_, err = db.ExecContext(ctx, `DROP TRIGGER refuse_m4_marker`)
			require.NoError(t, err)
			score, _, _ := bundleState(t, ctx, engine, "bundle-a")
			require.Equal(t, 51, score)
			var applied int
			require.NoError(t, db.QueryRowContext(ctx, `SELECT applied FROM m4_messages WHERE block_height = 150`).Scan(&applied))
			require.Zero(t, applied)
			require.NoError(t, db.Close())

			db, err = database.New(ctx, conf)
			require.NoError(t, err)
			engine = NewM4Engine(db, conf.BitcoinCoreNetwork)
			payload = binary.BigEndian.AppendUint32(nil, m4.M4CommitmentHeader)
			payload = append(payload, 0x00)
			second := coinbaseBlockOf(opReturnScript(t, payload), time.Unix(1700000600, 0))
			require.NoError(t, engine.ProcessBlock(ctx, 151, second))
			require.NoError(t, engine.ApplyPendingM4(ctx, 151, sidechains, nil))
			score, _, _ = bundleState(t, ctx, engine, "bundle-a")
			assert.Equal(t, 52, score)
			history, err := engine.GetM4History(ctx, 2)
			require.NoError(t, err)
			for _, message := range history {
				if assert.Len(t, message.Votes, 1) {
					assert.Equal(t, "bundle-a", valueOfHash(message.Votes[0].BundleHash))
				}
			}
		})
	}
}

func valueOfHash(value *string) string {
	if value == nil {
		return ""
	}
	return *value
}
