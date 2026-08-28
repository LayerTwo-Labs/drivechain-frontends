package orchestrator

import (
	"context"
	"errors"
	"fmt"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
)

// A node behind a UTXO snapshot reports two chainstates. getblockchaininfo
// only ever shows the snapshot one, which reads 100% while the node still
// verifies the blocks below the snapshot.
const snapshotChainStates = `{
  "headers": 996466,
  "chainstates": [
    {
      "blocks": 796524,
      "bestblockhash": "00000000000000000001d4ef8c328dd61ed6e0c49056cfb990d89e9c49bfa9b7",
      "verificationprogress": 0.6125775303214621,
      "validated": true
    },
    {
      "blocks": 996466,
      "bestblockhash": "0000000000000000d8faf1f614361327d1a67ad73cfeff1aac91cc5909f59514",
      "verificationprogress": 1,
      "snapshot_blockhash": "0000000000b360c17636b7a6c366e3effbe91a847eb5d61b7a7b29476439e924",
      "validated": false
    }
  ]
}`

const plainChainStates = `{
  "headers": 996466,
  "chainstates": [
    {
      "blocks": 996466,
      "bestblockhash": "0000000000000000d8faf1f614361327d1a67ad73cfeff1aac91cc5909f59514",
      "verificationprogress": 1,
      "validated": true
    }
  ]
}`

func TestParseChainStatesFindsTheVerifiedHeightBehindASnapshot(t *testing.T) {
	states, err := parseChainStates([]byte(snapshotChainStates))
	require.NoError(t, err)

	assert.True(t, states.Snapshot.Present)
	assert.Equal(t, int64(996466), states.Snapshot.Height)
	assert.False(t, states.Snapshot.Validated)
	assert.Equal(t, int64(796524), states.VerifiedBlocks)
}

func TestParseChainStatesReportsNoVerifiedHeightWithoutASnapshot(t *testing.T) {
	states, err := parseChainStates([]byte(plainChainStates))
	require.NoError(t, err)

	assert.False(t, states.Snapshot.Present)
	assert.Zero(t, states.VerifiedBlocks)
}

func TestParseChainStatesTakesTheHighestBackgroundChainstate(t *testing.T) {
	raw := `{"chainstates":[
	  {"blocks": 700000},
	  {"blocks": 796524},
	  {"blocks": 996466, "snapshot_blockhash": "aa"}
	]}`
	states, err := parseChainStates([]byte(raw))
	require.NoError(t, err)

	assert.Equal(t, int64(796524), states.VerifiedBlocks)
}

func TestParseChainStatesRejectsGarbage(t *testing.T) {
	_, err := parseChainStates([]byte("not json"))
	assert.Error(t, err)
}

// CachedConnection holds its TTL only after a success, so an error out of this
// probe would re-run getchainstates on every 100ms sync poll.
func TestParseBlockHeightReadsTheHeight(t *testing.T) {
	height, err := parseBlockHeight([]byte(`{"hash":"ab","height":880000}`))
	require.NoError(t, err)
	assert.Equal(t, int64(880000), height)
}

func TestParseBlockHeightRejectsGarbage(t *testing.T) {
	_, err := parseBlockHeight([]byte("not json"))
	assert.Error(t, err)
}

// A Core with no getchainstates answers every poll the same way, so the probe
// caches "no snapshot" rather than re-asking at the 100ms sync cadence.
func TestCoreLacksMethodOnlyMatchesMethodNotFound(t *testing.T) {
	missing := &RPCError{Method: "getchainstates", Code: RPCMethodNotFound, Message: "Method not found"}
	assert.True(t, CoreLacksMethod(fmt.Errorf("probe: %w", missing)))

	busy := &RPCError{Method: "getchainstates", Code: -4, Message: "Wallet is currently rescanning"}
	assert.False(t, CoreLacksMethod(busy))
	assert.False(t, CoreLacksMethod(errors.New("context deadline exceeded")))
}

// A transient failure must stay an error, so CachedConnection keeps the last
// good heights instead of blanking the Verified row.
func TestChainStatesProbeReturnsTransientFailuresAsErrors(t *testing.T) {
	o := &Orchestrator{log: zerolog.Nop()}
	c := &chainStatesConnection{o: o}

	states, err := c.Fetch(t.Context())

	assert.Error(t, err)
	assert.Nil(t, states)
}

// Core keeps the snapshot chainstate but drops the background one once it
// finishes validating, so the verified height reads 0 with the goal still set.
func TestCompleteValidatedSnapshotReadsAFinishedVerificationAsDone(t *testing.T) {
	states := CoreChainStates{
		Snapshot:     ActiveSnapshot{Present: true, Validated: true},
		VerifiedGoal: 880000,
	}

	assert.Equal(t, int64(880000), completeValidatedSnapshot(states).VerifiedBlocks)
}

func TestCompleteValidatedSnapshotLeavesAnUnfinishedVerificationAlone(t *testing.T) {
	states := CoreChainStates{
		Snapshot:       ActiveSnapshot{Present: true, Validated: false},
		VerifiedBlocks: 796524,
		VerifiedGoal:   880000,
	}

	assert.Equal(t, int64(796524), completeValidatedSnapshot(states).VerifiedBlocks)
}

type stubChainStates struct {
	states *CoreChainStates
	err    error
}

func (s *stubChainStates) Fetch(context.Context) (*CoreChainStates, error) {
	return s.states, s.err
}

// GetSyncStatus keeps the cached heights when a refresh fails, so the Verified
// row survives a transient RPC timeout instead of blanking.
func TestCachedChainStatesKeepsTheLastGoodValueOnAFailedRefresh(t *testing.T) {
	stub := &stubChainStates{states: &CoreChainStates{VerifiedBlocks: 796524, VerifiedGoal: 880000}}
	cache := &CachedConnection[*CoreChainStates]{inner: stub, ttl: 0}

	good, err := cache.Fetch(t.Context())
	require.NoError(t, err)
	require.Equal(t, int64(796524), good.VerifiedBlocks)

	stub.states, stub.err = nil, errors.New("context deadline exceeded")
	states, err := cache.Fetch(t.Context())

	assert.Error(t, err)
	require.NotNil(t, states)
	assert.Equal(t, int64(796524), states.VerifiedBlocks)
	assert.Equal(t, int64(880000), states.VerifiedGoal)
}
