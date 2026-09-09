package orchestrator

import (
	"context"
	"net/http"
	"net/http/httptest"
	"sync/atomic"
	"testing"
	"time"

	"connectrpc.com/connect"
	"connectrpc.com/grpchealth"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	enforcerpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	enforcerrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
)

func TestRemoteHealthFailureClearsStartupState(t *testing.T) {
	for _, target := range []string{"thunder", "enforcer"} {
		t.Run(target, func(t *testing.T) {
			const service = "cusf.mainchain.v1.ValidatorService"
			checker := grpchealth.NewStaticChecker(service)
			checker.SetStatus(service, grpchealth.StatusNotServing)
			mux := http.NewServeMux()
			path, handler := grpchealth.NewHandler(checker)
			var checks atomic.Int32
			mux.Handle(path, http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				handler.ServeHTTP(w, r)
				checks.Add(1)
			}))
			mux.Handle(enforcerrpc.ValidatorServiceGetChainTipProcedure, connect.NewUnaryHandler(
				enforcerrpc.ValidatorServiceGetChainTipProcedure,
				func(context.Context, *connect.Request[enforcerpb.GetChainTipRequest]) (*connect.Response[enforcerpb.GetChainTipResponse], error) {
					return connect.NewResponse(&enforcerpb.GetChainTipResponse{BlockHeaderInfo: &enforcerpb.BlockHeaderInfo{Height: 42}}), nil
				},
			))
			server := httptest.NewUnstartedServer(mux)
			server.Config.Protocols = new(http.Protocols)
			server.Config.Protocols.SetHTTP1(true)
			server.Config.Protocols.SetUnencryptedHTTP2(true)
			server.Start()
			t.Cleanup(server.Close)
			o := remoteTestOrchestrator(t, server.URL)
			ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
			defer cancel()
			progress, err := o.StartWithL1(ctx, target, StartOpts{ForceBackend: true})
			require.NoError(t, err)
			var startErr error
			for update := range progress {
				require.False(t, update.Done)
				if update.Error != nil {
					startErr = update.Error
				}
			}
			require.ErrorContains(t, startErr, "the remote validator service is not ready")
			targetState := o.Status(target)
			require.False(t, targetState.Initializing)
			require.False(t, targetState.Connected)
			require.Contains(t, targetState.ConnectionError, "the remote validator service is not ready")
			mon := o.monitors["enforcer"]
			require.Eventually(t, func() bool {
				mon.mu.Lock()
				defer mon.mu.Unlock()
				return checks.Load() >= 3 && mon.checkDone == nil
			}, 4*time.Second, 10*time.Millisecond)
			state := o.Status("enforcer")
			assert.False(t, state.Initializing)
			require.False(t, state.Connected)
			require.Contains(t, state.ConnectionError, "the remote validator service is not ready")
			require.Empty(t, o.process.ListRunning())

			checker.SetStatus(service, grpchealth.StatusServing)
			require.Eventually(t, func() bool {
				state := o.Status("enforcer")
				return state.Connected && !state.Initializing && state.ConnectionError == ""
			}, 3*time.Second, 10*time.Millisecond)
			if target == "thunder" {
				require.Equal(t, targetState.ConnectionError, o.Status(target).ConnectionError)
				require.False(t, o.Status(target).Connected)
			}
		})
	}
}
