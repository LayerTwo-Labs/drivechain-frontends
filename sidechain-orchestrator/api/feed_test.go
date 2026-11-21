package api

import (
	"context"
	"testing"
	"time"

	"github.com/stretchr/testify/require"
)

func TestFeedSubscribeWaitsForNoSlowRead(t *testing.T) {
	release := make(chan struct{})
	f := &feed[int]{
		read: func(context.Context) (int, error) {
			<-release
			return 7, nil
		},
		same:    func(a, b int) bool { return a == b },
		changed: func(context.Context) <-chan struct{} { return nil },
	}

	done := make(chan struct{})
	go func() {
		f.subscribe(t.Context())
		close(done)
	}()
	select {
	case <-done:
	case <-time.After(time.Second):
		t.Fatal("subscribe waited for the first read")
	}

	close(release)
	got, err := f.latest()
	require.NoError(t, err)
	require.Equal(t, 7, got)
}
