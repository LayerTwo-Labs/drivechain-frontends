package commands

import (
	"bytes"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/urfave/cli/v2"
	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/types/known/timestamppb"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/stratum/v1"
)

func TestStratumTarget(t *testing.T) {
	assert.Equal(t, pb.TargetKind_TARGET_KIND_SOLO, stratumTarget("solo", "", "", "").Kind)

	pool := stratumTarget("bip300", "", "", "")
	assert.Equal(t, pb.TargetKind_TARGET_KIND_POOL, pool.Kind)
	assert.Equal(t, "bip300", pool.PoolId)

	custom := stratumTarget("custom", "stratum+tcp://pool.example.com:3333", "bc1qme.rig", "x")
	assert.Equal(t, pb.TargetKind_TARGET_KIND_CUSTOM, custom.Kind)
	assert.Equal(t, "bc1qme.rig", custom.Worker)
}

func TestStratumTargetRejectsAFlagAfterTheArgument(t *testing.T) {
	app := &cli.App{Name: "drivechain-cli", Flags: GlobalFlags, Commands: []*cli.Command{miningCommand}}
	err := app.Run([]string{"drivechain-cli", "mining", "stratum", "target", "custom", "--url", "stratum+tcp://pool.example.com:3333"})
	require.ErrorContains(t, err, `unknown argument "--url"`)
}

func TestPrintStratumStatus(t *testing.T) {
	now := time.Unix(1_800_000_000, 0)
	temperature := 64.0
	status := &pb.GetStratumStatusResponse{
		Running:           true,
		Port:              3333,
		PoolUrl:           "stratum+tcp://192.168.1.20:3333",
		Hashrate:          6.02e12,
		BestShare:         1_234_567,
		NetworkDifficulty: 90_000_000,
		AcceptedShares:    512,
		RejectedShares:    2,
		Target:            &pb.Target{Kind: pb.TargetKind_TARGET_KIND_SOLO},
		Miners: []*pb.ConnectedMiner{{
			Worker:             "avalon.1",
			Address:            "192.168.1.40",
			Hashrate:           6.02e12,
			AcceptedShares:     512,
			RejectedShares:     2,
			LastShareTime:      timestamppb.New(now.Add(-3 * time.Second)),
			TemperatureCelsius: &temperature,
			WorkMode:           pb.WorkMode_WORK_MODE_HIGH,
		}},
		BlocksFound: []*pb.FoundBlock{{
			Height:        958400,
			Hash:          "00000000000000000001",
			RewardSats:    312_500_000,
			Worker:        "avalon.1",
			FoundTime:     timestamppb.New(now.Add(-time.Hour)),
			Confirmations: proto.Int32(12),
		}},
	}

	var out bytes.Buffer
	require.NoError(t, printStratumStatus(&out, status, now))
	text := out.String()
	assert.Contains(t, text, "running on port 3333")
	assert.Contains(t, text, "stratum+tcp://192.168.1.20:3333")
	assert.Contains(t, text, "solo, your node")
	assert.Contains(t, text, "6.02 TH/s")
	assert.Contains(t, text, "512 accepted, 2 rejected")
	assert.Contains(t, text, "64 °C")
	assert.Contains(t, text, "high")
	assert.Contains(t, text, "3s ago")
	assert.Contains(t, text, "958400")
	assert.Contains(t, text, "312500000")
}
