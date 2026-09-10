package api

import (
	"context"
	"os"
	"testing"
	"time"

	"connectrpc.com/connect"
	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/lease"
	"github.com/stretchr/testify/require"
)

func TestAdoptOwnerRejectsLateLease(t *testing.T) {
	for _, wait := range []bool{true, false} {
		name := "after_exit_decision"
		if wait {
			name = "before_exit_request"
		}
		t.Run(name, func(t *testing.T) {
			t.Parallel()
			ctx, cancel := context.WithCancel(context.Background())
			defer cancel()
			fired := make(chan struct{})
			returned := make(chan struct{})
			clients := lease.New(0x7FFFFFF0, 0, func() {
				close(fired)
				if wait {
					<-ctx.Done()
				}
				close(returned)
			})
			done := make(chan struct{})
			go func() {
				defer close(done)
				clients.Run(ctx)
			}()
			t.Cleanup(func() {
				cancel()
				<-done
			})
			select {
			case <-fired:
			case <-time.After(10 * time.Second):
				t.Fatal("the lease did not expire")
			}
			if !wait {
				<-returned
			}
			orch := &orchestrator.Orchestrator{}
			orch.SetLease(clients)
			response, err := NewHandler(orch).AdoptOwner(ctx, connect.NewRequest(&pb.AdoptOwnerRequest{
				OwnerPid: int32(os.Getpid()),
			}))
			require.Equal(t, connect.CodeUnavailable, connect.CodeOf(err))
			require.Nil(t, response)
		})
	}
}

func TestAdoptOwnerAcceptsLiveLease(t *testing.T) {
	orch := &orchestrator.Orchestrator{}
	orch.SetLease(lease.New(os.Getpid(), time.Minute, func() {}))
	response, err := NewHandler(orch).AdoptOwner(context.Background(), connect.NewRequest(&pb.AdoptOwnerRequest{
		OwnerPid: int32(os.Getpid()),
	}))
	require.NoError(t, err)
	require.False(t, response.Msg.CanceledExit)
}
