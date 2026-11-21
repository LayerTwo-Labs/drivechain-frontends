package api

import (
	"context"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
)

// binariesFeed reads the binary list one time for all WatchBinaries streams
// of one ForceBackend value, and wakes them on each change.
type binariesFeed = feed[[]*pb.BinaryStatusMsg]

func newBinariesFeed(orch *orchestrator.Orchestrator, opts orchestrator.DownloadOptions) *binariesFeed {
	return &binariesFeed{
		read: func(context.Context) ([]*pb.BinaryStatusMsg, error) {
			statuses := orch.ListAllState(opts)
			out := make([]*pb.BinaryStatusMsg, len(statuses))
			for i, s := range statuses {
				out[i] = statusToProto(s)
			}
			return out, nil
		},
		same:    sameBinaries,
		changed: orch.SubscribeBinaries,
		recheck: binariesRecheckInterval,
	}
}
