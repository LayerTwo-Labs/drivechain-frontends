package orchestrator

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"
)

// The boot path hands this an unbounded context, so an unresponsive host must
// fail on its own deadline rather than holding up the L1 stack.
func TestFetchSnapshotListingTimesOutOnHungServer(t *testing.T) {
	block := make(chan struct{})
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		<-block // never responds
	}))
	t.Cleanup(func() { close(block); srv.Close() })

	// Shorten the wait: the point is that a deadline exists and fires, not how
	// long the production one is.
	ctx, cancel := context.WithTimeout(t.Context(), 300*time.Millisecond)
	defer cancel()

	done := make(chan error, 1)
	go func() {
		_, err := fetchSnapshotListing(ctx, srv.URL+"/")
		done <- err
	}()

	select {
	case err := <-done:
		if err == nil {
			t.Error("expected an error from a server that never responds")
		}
	case <-time.After(5 * time.Second):
		t.Fatal("fetchSnapshotListing hung past its deadline")
	}
}
