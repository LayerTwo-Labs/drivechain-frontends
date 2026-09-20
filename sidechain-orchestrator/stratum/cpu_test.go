package stratum_test

import (
	"context"
	"sync"
	"testing"
	"time"

	"github.com/btcsuite/btcd/blockchain"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/stratum"
)

// easyBits is a network difficulty of 1, so the hasher on this computer finds
// a share in a second but no block.
const easyBits = 0x1d00ffff

// fixedSource gives one work and never changes it.
type fixedSource struct {
	work *stratum.Work

	mu      sync.Mutex
	submits int
}

func (s *fixedSource) Run(ctx context.Context, publish func(*stratum.Work)) error {
	publish(s.work)
	<-ctx.Done()
	return ctx.Err()
}

func (s *fixedSource) Submit(context.Context, *stratum.Work, stratum.Share) (*stratum.Block, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.submits++
	return nil, nil
}

func fixedWork() *fixedSource {
	return &fixedSource{work: &stratum.Work{
		Coinb1:         []byte{0x01, 0x02, 0x03, 0x04},
		Coinb2:         []byte{0x05, 0x06, 0x07, 0x08},
		ExtranonceSize: 12,
		Version:        0x20000000,
		Bits:           easyBits,
		Time:           uint32(time.Now().Add(-time.Minute).Unix()),
		VersionMask:    stratum.VersionMask,
		Target:         blockchain.CompactToBig(easyBits),
		Clean:          true,
	}}
}

// cpuMiner returns the row of the hasher on this computer.
func cpuMiner(status stratum.Status) (stratum.MinerStatus, bool) {
	for _, m := range status.Miners {
		if m.Worker == stratum.CPUWorker {
			return m, true
		}
	}
	return stratum.MinerStatus{}, false
}

func TestTheHasherOnThisComputerSendsShares(t *testing.T) {
	server, _, _ := serve(t, fixedWork())
	server.SetCPU(true, 2)
	on, threads := server.CPUOn()
	require.True(t, on)
	require.Equal(t, 2, threads)

	var miner stratum.MinerStatus
	require.Eventually(t, func() bool {
		var ok bool
		miner, ok = cpuMiner(server.Status())
		return ok && miner.Accepted > 0
	}, 30*time.Second, 50*time.Millisecond)

	assert.Equal(t, stratum.CPUAddress, miner.Address)
	assert.Positive(t, miner.Hashrate)
	assert.Positive(t, miner.BestShare)
	assert.Zero(t, miner.Rejected)
	assert.Positive(t, server.Status().Accepted)

	t.Run("the switch off takes the row away", func(t *testing.T) {
		server.SetCPU(false, 2)
		on, _ := server.CPUOn()
		assert.False(t, on)
		require.Eventually(t, func() bool {
			_, ok := cpuMiner(server.Status())
			return !ok
		}, 10*time.Second, 50*time.Millisecond)
	})
}

// The switch may go on before the server listens. The hasher then starts with
// the server.
func TestTheHasherStartsWithTheServer(t *testing.T) {
	source := fixedWork()
	server := stratum.NewServer(source, zerolog.Nop())
	server.SetCPU(true, 2)

	serveServer(t, server)

	require.Eventually(t, func() bool {
		miner, ok := cpuMiner(server.Status())
		return ok && miner.Accepted > 0
	}, 30*time.Second, 50*time.Millisecond)
}

// A target change drops every miner. The hasher connects again on its own.
func TestTheHasherConnectsAgainAfterATargetChange(t *testing.T) {
	server, _, _ := serve(t, fixedWork())
	server.SetCPU(true, 2)

	require.Eventually(t, func() bool {
		miner, ok := cpuMiner(server.Status())
		return ok && miner.Accepted > 0
	}, 30*time.Second, 50*time.Millisecond)

	server.SetSource(fixedWork())

	require.Eventually(t, func() bool {
		miner, ok := cpuMiner(server.Status())
		return ok && miner.Accepted > 0
	}, 30*time.Second, 50*time.Millisecond)
}
