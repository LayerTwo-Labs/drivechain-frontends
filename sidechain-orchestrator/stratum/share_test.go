package stratum

import (
	"context"
	"encoding/json"
	"fmt"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// A job keeps the difficulty it went out at, so a retarget after it never
// turns a share the miner found for it into a low difficulty share.
func TestShareNeedsTheDifficultyOfItsJob(t *testing.T) {
	now := time.Unix(1_800_000_000, 0)
	w := &Work{
		Coinb1:         []byte{1, 2, 3},
		Coinb2:         []byte{4, 5, 6},
		ExtranonceSize: 12,
		Version:        0x20000000,
		Bits:           0x207fffff,
		Time:           uint32(now.Unix()),
		Target:         targetOf(1e30),
	}
	l, err := layoutOf(w)
	require.NoError(t, err)
	s := &Server{layout: &l, jobs: map[string]*job{"1": {id: "1", work: w, seen: map[string]struct{}{}}}}

	check := func(jobDifficulty map[string]float64) *stratumError {
		sess := &session{
			subscribed:    true,
			authorized:    true,
			extranonce1:   []byte{0, 0, 0, 1},
			difficulty:    1e30,
			jobDifficulty: jobDifficulty,
		}
		params, err := json.Marshal([]string{"w", "1", "0000000000000000", fmt.Sprintf("%08x", w.Time), "00000000"})
		require.NoError(t, err)
		s.jobs["1"].seen = map[string]struct{}{}
		_, rejected := s.checkShareLocked(sess, params, now)
		return rejected
	}

	assert.Nil(t, check(map[string]float64{"1": 1e-12}))
	rejected := check(map[string]float64{})
	require.NotNil(t, rejected)
	assert.Equal(t, codeLowDiff, rejected.code)
}

// A miner may apply a new difficulty from its next job, so a rise comes with
// the same work under a new job id.
func TestARiseInDifficultySendsANewJob(t *testing.T) {
	now := time.Unix(1_800_000_000, 0)
	w := &Work{ExtranonceSize: 12, Bits: 0x1b04864c, Version: 0x20000000}
	current := &job{id: "1", work: w, seen: map[string]struct{}{}}
	s := &Server{jobs: map[string]*job{"1": current}, current: current, jobSeq: 1}
	sess := &session{
		out:            make(chan []byte, 8),
		started:        true,
		difficulty:     minDifficulty,
		retargetAt:     now.Add(-5 * time.Second),
		retargetShares: earlyRetargetShares,
		jobDifficulty:  map[string]float64{"1": minDifficulty},
		aliases:        map[string]*job{},
	}

	s.retargetLocked(sess, now)

	require.Greater(t, sess.difficulty, float64(minDifficulty))
	require.Len(t, sess.aliases, 1)
	for id, base := range sess.aliases {
		assert.Same(t, current, base)
		assert.Equal(t, sess.difficulty, sess.jobDifficulty[id])
	}
	assert.Equal(t, float64(minDifficulty), sess.jobDifficulty["1"])
	assert.Len(t, sess.out, 2)

	t.Run("a suggestion that raises it", func(t *testing.T) {
		sess.out = make(chan []byte, 8)
		s.handle(context.Background(), sess, message{
			Method: "mining.suggest_difficulty",
			Params: json.RawMessage(fmt.Sprintf("[%v]", sess.difficulty*2)),
		})
		assert.Len(t, sess.aliases, 2)
		assert.Len(t, sess.out, 2)
	})
}
