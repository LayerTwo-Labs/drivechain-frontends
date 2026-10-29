package commands

import (
	"testing"

	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
)

func TestDownloadLanded(t *testing.T) {
	for _, tc := range []struct {
		name   string
		status *pb.BinaryStatusMsg
		force  bool
		want   bool
	}{
		{"nothing on disk", &pb.BinaryStatusMsg{}, false, false},
		{"a plain download lands", &pb.BinaryStatusMsg{Downloaded: true, DownloadedTimestampUnix: 100}, false, true},
		{"a forced download sees the old file", &pb.BinaryStatusMsg{Downloaded: true, DownloadedTimestampUnix: 100}, true, false},
		{"a forced download sees a new file", &pb.BinaryStatusMsg{Downloaded: true, DownloadedTimestampUnix: 200}, true, true},
		{"a forced download with no old file", &pb.BinaryStatusMsg{Downloaded: false}, true, false},
	} {
		t.Run(tc.name, func(t *testing.T) {
			require.Equal(t, tc.want, downloadLanded(tc.status, tc.force, 100))
		})
	}
}
