package api

import (
	"testing"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain"
	"github.com/stretchr/testify/assert"
)

func TestMainchainSyncPhaseToProto(t *testing.T) {
	for phase, want := range map[sidechain.MainchainSyncPhase]pb.MainchainSyncPhase{
		"":                             pb.MainchainSyncPhase_MAINCHAIN_SYNC_PHASE_UNSPECIFIED,
		sidechain.MainchainSyncHeaders: pb.MainchainSyncPhase_MAINCHAIN_SYNC_PHASE_HEADERS,
		sidechain.MainchainSyncWriting: pb.MainchainSyncPhase_MAINCHAIN_SYNC_PHASE_WRITING,
		sidechain.MainchainSyncState:   pb.MainchainSyncPhase_MAINCHAIN_SYNC_PHASE_STATE,
		"rewind":                       pb.MainchainSyncPhase_MAINCHAIN_SYNC_PHASE_OTHER,
	} {
		assert.Equal(t, want, mainchainSyncPhaseToProto(phase), "phase %q", phase)
	}
}
