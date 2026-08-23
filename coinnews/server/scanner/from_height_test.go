package scanner

import (
	"context"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"sync"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	"github.com/LayerTwo-Labs/sidesail/coinnews/server/store"
)

// fakeCore answers the three RPCs the scanner uses and records every height
// it was asked to fetch. Blocks carry no transactions, so nothing is indexed.
type fakeCore struct {
	tip uint32

	mu     sync.Mutex
	served []uint32
}

func (f *fakeCore) heights() []uint32 {
	f.mu.Lock()
	defer f.mu.Unlock()
	return append([]uint32(nil), f.served...)
}

func (f *fakeCore) start(t *testing.T) *httptest.Server {
	t.Helper()
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Method string            `json:"method"`
			Params []json.RawMessage `json:"params"`
		}
		require.NoError(t, json.NewDecoder(r.Body).Decode(&req))
		w.Header().Set("content-type", "application/json")

		switch req.Method {
		case "getblockcount":
			_, _ = fmt.Fprintf(w, `{"result":%d,"error":null}`, f.tip)
		case "getblockhash":
			var h uint32
			require.NoError(t, json.Unmarshal(req.Params[0], &h))
			f.mu.Lock()
			f.served = append(f.served, h)
			f.mu.Unlock()
			// A hash the scanner can decode: 32 bytes, height in the low byte.
			_, _ = fmt.Fprintf(w, `{"result":"%064x","error":null}`, h)
		case "getblock":
			_, _ = fmt.Fprint(w, `{"result":{"hash":"00","height":0,"time":1,"mediantime":1,"tx":[]},"error":null}`)
		default:
			t.Errorf("unexpected method %q", req.Method)
		}
	}))
	t.Cleanup(srv.Close)
	return srv
}

func runScanner(t *testing.T, core *fakeCore, from uint32) {
	t.Helper()
	ctx := context.Background()

	db, err := store.Open(ctx, t.TempDir()+"/coinnews.db")
	require.NoError(t, err)
	t.Cleanup(func() { _ = db.Close() })

	srv := core.start(t)
	s := &Scanner{
		Client:     &Client{URL: srv.URL, HTTP: srv.Client()},
		DB:         db,
		Log:        zerolog.Nop(),
		FromHeight: from,
	}
	require.NoError(t, s.catchUp(ctx))
}

func TestScannerStartsAtFromHeight(t *testing.T) {
	t.Parallel()
	core := &fakeCore{tip: 1000}
	runScanner(t, core, 900)

	served := core.heights()
	require.NotEmpty(t, served)
	assert.Equal(t, uint32(900), served[0], "first block fetched")
	assert.Equal(t, uint32(1000), served[len(served)-1], "last block fetched")
	assert.Len(t, served, 101, "900..1000 inclusive")
}

func TestScannerWithoutFromHeightStartsAtGenesis(t *testing.T) {
	t.Parallel()
	core := &fakeCore{tip: 10}
	runScanner(t, core, 0)

	assert.Equal(t, []uint32{1, 2, 3, 4, 5, 6, 7, 8, 9, 10}, core.heights())
}

func TestScannerFromHeightNeverRewindsCursor(t *testing.T) {
	t.Parallel()
	ctx := context.Background()

	db, err := store.Open(ctx, t.TempDir()+"/coinnews.db")
	require.NoError(t, err)
	t.Cleanup(func() { _ = db.Close() })

	// A cursor already past the configured start height.
	require.NoError(t, store.SaveCursor(ctx, db, 500, [32]byte{}))

	core := &fakeCore{tip: 503}
	srv := core.start(t)
	s := &Scanner{
		Client:     &Client{URL: srv.URL, HTTP: srv.Client()},
		DB:         db,
		Log:        zerolog.Nop(),
		FromHeight: 100,
	}
	require.NoError(t, s.catchUp(ctx))

	assert.Equal(t, []uint32{501, 502, 503}, core.heights(), "resumes at the cursor, not at FromHeight")
}

func TestScannerFromHeightAboveTipIndexesNothing(t *testing.T) {
	t.Parallel()
	core := &fakeCore{tip: 50}
	runScanner(t, core, 900)

	assert.Empty(t, core.heights())
}
