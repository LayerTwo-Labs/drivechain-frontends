package scanner

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"sync"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	codec "github.com/LayerTwo-Labs/sidesail/coinnews/codec"
	"github.com/LayerTwo-Labs/sidesail/coinnews/server/store"
)

// forkCore serves a one-block chain whose hash at height 1 the test can swap,
// modelling a reorg that replaces the block the cursor sits on.
type forkCore struct {
	blocks map[string]string // block hash -> getblock result

	mu     sync.Mutex
	hashAt string
}

func (f *forkCore) setHash(hash string) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.hashAt = hash
}

func (f *forkCore) hash() string {
	f.mu.Lock()
	defer f.mu.Unlock()
	return f.hashAt
}

func (f *forkCore) start(t *testing.T) *httptest.Server {
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
			_, _ = fmt.Fprint(w, `{"result":1,"error":null}`)
		case "getblockhash":
			_, _ = fmt.Fprintf(w, `{"result":%q,"error":null}`, f.hash())
		case "getblock":
			var hash string
			require.NoError(t, json.Unmarshal(req.Params[0], &hash))
			_, _ = fmt.Fprintf(w, `{"result":%s,"error":null}`, f.blocks[hash])
		default:
			t.Errorf("unexpected method %q", req.Method)
		}
	}))
	t.Cleanup(srv.Close)
	return srv
}

// opReturnScript wraps a payload in a single-push OP_RETURN, display hex.
func opReturnScript(payload []byte) string {
	script := []byte{0x6a}
	if len(payload) <= 75 {
		script = append(script, byte(len(payload)))
	} else {
		script = append(script, 0x4c, byte(len(payload)))
	}
	return hex.EncodeToString(append(script, payload...))
}

// A reorg that replaces the block at the cursor keeps the height, so the
// scanner must catch it by hash and drop the story the orphan carried.
func TestScannerReorgAtCursorPurgesOrphanedStory(t *testing.T) {
	t.Parallel()
	ctx := context.Background()

	db, err := store.Open(ctx, t.TempDir()+"/coinnews.db")
	require.NoError(t, err)
	t.Cleanup(func() { _ = db.Close() })

	storyBytes, err := codec.EncodeStory(codec.Story{
		Topic:    codec.Topic{1, 2, 3, 4},
		Headline: "orphaned by the reorg",
	})
	require.NoError(t, err)

	oldHash, newHash := "aa"+hexZero(62), "bb"+hexZero(62)
	txid := "cc" + hexZero(62)
	core := &forkCore{
		hashAt: oldHash,
		blocks: map[string]string{
			oldHash: fmt.Sprintf(
				`{"hash":%q,"height":1,"time":1,"mediantime":1,"tx":[{"txid":%q,"vout":[{"scriptPubKey":{"hex":%q,"type":"nulldata"}}]}]}`,
				oldHash, txid, opReturnScript(storyBytes)),
			newHash: fmt.Sprintf(`{"hash":%q,"height":1,"time":1,"mediantime":1,"tx":[]}`, newHash),
		},
	}
	srv := core.start(t)
	s := &Scanner{
		Client: &Client{URL: srv.URL, HTTP: srv.Client()},
		DB:     db,
		Log:    zerolog.Nop(),
	}

	require.NoError(t, s.catchUp(ctx))
	feed, err := store.ListFeed(ctx, db, store.FeedFilter{Sort: store.SortNewest})
	require.NoError(t, err)
	require.Len(t, feed, 1)

	core.setHash(newHash)
	require.NoError(t, s.catchUp(ctx))

	feed, err = store.ListFeed(ctx, db, store.FeedFilter{Sort: store.SortNewest})
	require.NoError(t, err)
	assert.Empty(t, feed, "the orphaned story is gone")

	height, hash, err := store.LoadCursor(ctx, db)
	require.NoError(t, err)
	assert.Equal(t, uint32(1), height)
	want, err := decodeHashLE(newHash)
	require.NoError(t, err)
	assert.Equal(t, want, hash, "cursor tracks the replacement block")
}
