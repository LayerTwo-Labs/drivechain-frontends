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

func floorServer(floor float64) (*Server, *session) {
	w := &Work{ExtranonceSize: 12, Bits: 0x170331db, Version: 0x20000000}
	current := &job{id: "1", work: w, seen: map[string]struct{}{}}
	s := &Server{jobs: map[string]*job{"1": current}, current: current, jobSeq: 1, workerFloor: floor}
	sess := &session{out: make(chan []byte, 8), floor: minDifficulty, subscribed: true}
	return s, sess
}

func authorize(t *testing.T, s *Server, sess *session, password string) {
	t.Helper()
	s.handle(context.Background(), sess, message{
		ID:     json.RawMessage("1"),
		Method: "mining.authorize",
		Params: json.RawMessage(fmt.Sprintf(`["w", %q]`, password)),
	})
}

func TestAMinimumDifficultyHoldsTheWorker(t *testing.T) {
	s, sess := floorServer(65536)
	authorize(t, s, sess, "x")
	require.True(t, sess.started)
	assert.Equal(t, 65536.0, sess.difficulty)

	now := time.Now()
	sess.retargetAt, sess.retargetShares = now.Add(-5*time.Minute), 0
	s.retargetLocked(sess, now)
	assert.Equal(t, 65536.0, sess.difficulty)

	sess.retargetAt, sess.retargetShares = now.Add(-5*time.Second), earlyRetargetShares
	s.retargetLocked(sess, now)
	assert.Greater(t, sess.difficulty, 65536.0)

	t.Run("a raised floor applies at the next retarget", func(t *testing.T) {
		s.SetMinDifficulty(1e6)
		sess.retargetAt, sess.retargetShares = now.Add(-5*time.Minute), 0
		s.retargetLocked(sess, now)
		assert.Equal(t, 1e6, sess.difficulty)
	})

	t.Run("no floor starts at the default", func(t *testing.T) {
		s, sess := floorServer(0)
		authorize(t, s, sess, "x")
		assert.Equal(t, float64(startDifficulty), sess.difficulty)
	})

	t.Run("the hasher on this computer has no floor of the user", func(t *testing.T) {
		s, sess := floorServer(65536)
		sess.local, sess.floor = true, cpuMinDifficulty
		authorize(t, s, sess, "x")
		assert.Equal(t, float64(startDifficulty), sess.difficulty)
	})
}

func TestAPasswordDifficultyHoldsTheWorker(t *testing.T) {
	s, sess := floorServer(0)
	authorize(t, s, sess, "x,d=131072")
	require.True(t, sess.started)
	assert.Equal(t, 131072.0, sess.difficulty)

	now := time.Now()
	sess.retargetAt, sess.retargetShares = now.Add(-5*time.Minute), 0
	s.retargetLocked(sess, now)
	assert.Equal(t, 131072.0, sess.difficulty)

	t.Run("the higher floor wins", func(t *testing.T) {
		s, sess := floorServer(1e6)
		authorize(t, s, sess, "d=131072")
		assert.Equal(t, 1e6, sess.difficulty)
	})

	t.Run("a bad value fails the authorize", func(t *testing.T) {
		s, sess := floorServer(0)
		authorize(t, s, sess, "d=abc")
		assert.False(t, sess.authorized)
	})
}

func TestPasswordDifficulty(t *testing.T) {
	tests := []struct {
		password string
		want     float64
		fails    bool
	}{
		{password: "x", want: 0},
		{password: "", want: 0},
		{password: "d=500000", want: 500000},
		{password: "x,d=65536", want: 65536},
		{password: "x d=1e6", want: 1e6},
		{password: "x;d=2048", want: 2048},
		{password: "d=0", fails: true},
		{password: "d=-5", fails: true},
		{password: "d=NaN", fails: true},
	}
	for _, tt := range tests {
		t.Run(tt.password, func(t *testing.T) {
			got, err := passwordDifficulty(tt.password)
			if tt.fails {
				assert.Error(t, err)
				return
			}
			require.NoError(t, err)
			assert.Equal(t, tt.want, got)
		})
	}
}
