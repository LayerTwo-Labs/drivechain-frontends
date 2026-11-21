package main

import (
	"context"
	"fmt"
	"path/filepath"
	"runtime"

	connect "connectrpc.com/connect/v2"

	dial "github.com/LayerTwo-Labs/sidesail/bitwindow/server/dial"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/selfbuild"
)

// drivechaindBeside is the drivechaind file in the folder of the bitwindowd at path.
func drivechaindBeside(path string) string {
	name := "drivechaind"
	if runtime.GOOS == "windows" {
		name += ".exe"
	}
	return filepath.Join(filepath.Dir(path), name)
}

// adoptOrchestrator makes ownerPID the owner of the drivechaind at addr when
// it runs the file at path. It returns false when the daemon is another build,
// or when its exit already started.
func adoptOrchestrator(ctx context.Context, addr, bitwindowDir, path string, ownerPID int) (bool, error) {
	base, err := orchestratorURL(addr)
	if err != nil {
		return false, err
	}
	same, err := selfbuild.Ask(ctx, base.String(), path)
	if err != nil || !same {
		return false, err
	}
	_, err = dial.Orchestrator(addr, bitwindowDir).AdoptOwner(ctx, &orchpb.AdoptOwnerRequest{OwnerPid: int32(ownerPID)})
	if connect.CodeOf(err) == connect.CodeUnavailable {
		return false, nil
	}
	if err != nil {
		return false, fmt.Errorf("adopt drivechaind: %w", err)
	}
	return true, nil
}
