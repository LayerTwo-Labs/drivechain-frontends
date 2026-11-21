package main

import (
	"context"
	"fmt"
	"net/http"
	"path/filepath"
	"runtime"
	"strconv"
	"time"

	connect "connectrpc.com/connect/v2"
	"github.com/rs/zerolog"

	dial "github.com/LayerTwo-Labs/sidesail/bitwindow/server/dial"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/lease"
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

// keepHandler lets a relaunched app keep this bitwindowd and its drivechaind.
// POST ?owner=<pid>&path=<bitwindowd file> answers 200 when both daemons run
// the files the app would start, and 409 when the app must replace them.
func keepHandler(addr, bitwindowDir string, clients *lease.Lease) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
			return
		}
		path := r.URL.Query().Get("path")
		owner, err := strconv.Atoi(r.URL.Query().Get("owner"))
		if path == "" || err != nil || owner <= 0 {
			http.Error(w, "need a path and an owner pid", http.StatusBadRequest)
			return
		}
		log := zerolog.Ctx(r.Context())

		same, err := selfbuild.Runs(path)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		if !same {
			http.Error(w, "bitwindowd runs another build", http.StatusConflict)
			return
		}
		ctx, cancel := context.WithTimeout(r.Context(), 2*time.Second)
		defer cancel()
		adopted, err := adoptOrchestrator(ctx, addr, bitwindowDir, drivechaindBeside(path), owner)
		if err != nil {
			http.Error(w, err.Error(), http.StatusBadGateway)
			return
		}
		if !adopted {
			http.Error(w, "drivechaind runs another build or exits", http.StatusConflict)
			return
		}
		if !clients.SetOwner(owner) {
			http.Error(w, "bitwindowd exits", http.StatusConflict)
			return
		}
		log.Info().Int("owner_pid", owner).Msg("a relaunched app kept this bitwindowd and drivechaind")
		w.WriteHeader(http.StatusOK)
	})
}
