package orchestrator

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func listingServer(t *testing.T, body string) *httptest.Server {
	t.Helper()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != "/SHA256SUMS" {
			w.WriteHeader(http.StatusNotFound)
			return
		}
		_, _ = w.Write([]byte(body))
	}))
	t.Cleanup(srv.Close)
	return srv
}

// The commitment height and filename come from the published listing, so a new
// snapshot needs no code change. The highest entry wins.
func TestFetchSnapshotListingPicksHighestHeight(t *testing.T) {
	srv := listingServer(t,
		"aaa  utxo-957600.dat\n"+
			"bbb  utxo-1000000.dat\n"+
			"ccc  some-other-file.tar.gz\n")

	got, err := fetchSnapshotListing(t.Context(), srv.URL+"/")
	if err != nil {
		t.Fatalf("fetchSnapshotListing: %v", err)
	}
	if got.Height != 1000000 {
		t.Errorf("Height = %d, want 1000000", got.Height)
	}
	if got.SHA256 != "bbb" {
		t.Errorf("SHA256 = %q, want bbb", got.SHA256)
	}
	if want := srv.URL + "/utxo-1000000.dat"; got.URL != want {
		t.Errorf("URL = %q, want %q", got.URL, want)
	}
}

func TestFetchSnapshotListingRejectsListingWithoutSnapshot(t *testing.T) {
	srv := listingServer(t, "aaa  readme.txt\n")

	if _, err := fetchSnapshotListing(t.Context(), srv.URL+"/"); err == nil {
		t.Error("expected an error when the listing has no utxo-<height>.dat")
	}
}

func TestSnapshotFileNameFallsBackWhenURLHasNoSegment(t *testing.T) {
	if got := snapshotFileName("https://example.com/utxo-42.dat"); got != "utxo-42.dat" {
		t.Errorf("snapshotFileName = %q, want utxo-42.dat", got)
	}
	if got := snapshotFileName("/"); got != "utxo-snapshot.dat" {
		t.Errorf("snapshotFileName(/) = %q, want the fallback", got)
	}
	// A presigned or cache-busted URL carries a query string that would be an
	// invalid filename on Windows; only the path segment may reach disk.
	if got := snapshotFileName("https://example.com/utxo-42.dat?X-Amz-Signature=abc"); got != "utxo-42.dat" {
		t.Errorf("snapshotFileName with query = %q, want utxo-42.dat", got)
	}
}

// The pending snapshot is consumed exactly once: the apply runs on the way back
// up from a restart, and a later restart must not silently re-wipe and reload.
func TestPendingSnapshotIsTakenOnce(t *testing.T) {
	o := &Orchestrator{}
	o.SetPendingSnapshot(&SnapshotSource{Path: "/tmp/utxo.dat"})

	if got := o.takePendingSnapshot(); got == nil || got.Path != "/tmp/utxo.dat" {
		t.Fatalf("first take = %+v, want the pending source", got)
	}
	if got := o.takePendingSnapshot(); got != nil {
		t.Errorf("second take = %+v, want nil", got)
	}
}

func TestApplyUserSnapshotRejectsEmptySource(t *testing.T) {
	o := &Orchestrator{}
	if _, err := o.ApplyUserSnapshot(t.Context(), SnapshotSource{}); err == nil {
		t.Error("expected an error when neither URL nor Path is set")
	}
}

func TestApplyUserSnapshotRejectsMissingFile(t *testing.T) {
	o := &Orchestrator{}
	_, err := o.ApplyUserSnapshot(t.Context(), SnapshotSource{Path: "/definitely/not/here.dat"})
	if err == nil {
		t.Error("expected an error for a file that does not exist")
	}
	if o.pendingSnapshot != nil {
		t.Error("a rejected source must not be left pending")
	}
}
