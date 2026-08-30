package scanner

import (
	"context"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"net/http"
	"net/http/httptest"
	"slices"
	"sync"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	codec "github.com/LayerTwo-Labs/sidesail/coinnews/codec"
	"github.com/LayerTwo-Labs/sidesail/coinnews/server/store"
)

var genesisHash = "ff" + hexZero(62)

type forkBlock struct {
	prev     string
	height   int
	headline string
}

// forkCore serves a chain the test can replace, and keeps every block it
// ever served, as Core keeps the headers of a stale branch.
type forkCore struct {
	t *testing.T

	mu     sync.Mutex
	blocks map[string]forkBlock
	chain  []string
	// onGetBlock runs after getblock serves a block, so a test can move the chain mid-scan.
	onGetBlock func(hash string)
}

// branch adds blocks from height after parent, one per headline, and returns
// their hashes. An empty headline makes an empty block.
func (f *forkCore) branch(tag byte, parent string, headlines ...string) []string {
	f.mu.Lock()
	defer f.mu.Unlock()
	height := 0
	if parent != genesisHash {
		height = f.blocks[parent].height
	}
	var hashes []string
	for i, headline := range headlines {
		hash := fmt.Sprintf("%02x%04x", tag, height+i+1) + hexZero(58)
		f.blocks[hash] = forkBlock{prev: parent, height: height + i + 1, headline: headline}
		hashes = append(hashes, hash)
		parent = hash
	}
	return hashes
}

func (f *forkCore) setChain(chain ...string) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.chain = chain
}

func (f *forkCore) blockJSON(hash string) string {
	b := f.blocks[hash]
	txs := "[]"
	if b.headline != "" {
		story, err := codec.EncodeStory(codec.Story{Topic: codec.Topic{1, 2, 3, 4}, Headline: b.headline})
		require.NoError(f.t, err)
		txs = fmt.Sprintf(`[{"txid":%q,"vout":[{"scriptPubKey":{"hex":%q,"type":"nulldata"}}]}]`, hash, opReturnScript(story))
	}
	return fmt.Sprintf(`{"hash":%q,"previousblockhash":%q,"height":%d,"time":1,"mediantime":1,"tx":%s}`,
		hash, b.prev, b.height, txs)
}

func (f *forkCore) start() *httptest.Server {
	t := f.t
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		var req struct {
			Method string            `json:"method"`
			Params []json.RawMessage `json:"params"`
		}
		require.NoError(t, json.NewDecoder(r.Body).Decode(&req))
		w.Header().Set("content-type", "application/json")

		f.mu.Lock()
		var hook func()
		switch req.Method {
		case "getblockcount":
			_, _ = fmt.Fprintf(w, `{"result":%d,"error":null}`, len(f.chain))
		case "getblockhash":
			var h int
			require.NoError(t, json.Unmarshal(req.Params[0], &h))
			_, _ = fmt.Fprintf(w, `{"result":%q,"error":null}`, f.chain[h-1])
		case "getblock":
			var hash string
			require.NoError(t, json.Unmarshal(req.Params[0], &hash))
			_, _ = fmt.Fprintf(w, `{"result":%s,"error":null}`, f.blockJSON(hash))
			if f.onGetBlock != nil {
				on := f.onGetBlock
				hook = func() { on(hash) }
			}
		case "getblockheader":
			var hash string
			require.NoError(t, json.Unmarshal(req.Params[0], &hash))
			b, ok := f.blocks[hash]
			require.True(t, ok, "unknown block %s", hash)
			confirmations := -1
			if slices.Contains(f.chain, hash) {
				confirmations = len(f.chain) - b.height + 1
			}
			_, _ = fmt.Fprintf(w, `{"result":{"confirmations":%d,"previousblockhash":%q},"error":null}`, confirmations, b.prev)
		default:
			t.Errorf("unexpected method %q", req.Method)
		}
		f.mu.Unlock()
		if hook != nil {
			hook()
		}
	}))
	t.Cleanup(srv.Close)
	return srv
}

func opReturnScript(payload []byte) string {
	script := []byte{0x6a}
	if len(payload) <= 75 {
		script = append(script, byte(len(payload)))
	} else {
		script = append(script, 0x4c, byte(len(payload)))
	}
	return hex.EncodeToString(append(script, payload...))
}

func newForkScanner(t *testing.T) (*Scanner, *forkCore) {
	t.Helper()
	db, err := store.Open(context.Background(), t.TempDir()+"/coinnews.db")
	require.NoError(t, err)
	t.Cleanup(func() { _ = db.Close() })

	core := &forkCore{t: t, blocks: map[string]forkBlock{}}
	srv := core.start()
	return &Scanner{
		Client: &Client{URL: srv.URL, HTTP: srv.Client()},
		DB:     db,
		Log:    zerolog.Nop(),
	}, core
}

func headlines(t *testing.T, s *Scanner) []string {
	t.Helper()
	feed, err := store.ListFeed(context.Background(), s.DB, store.FeedFilter{Sort: store.SortNewest})
	require.NoError(t, err)
	var out []string
	for _, item := range feed {
		out = append(out, item.Headline)
	}
	slices.Sort(out)
	return out
}

func assertCursor(t *testing.T, s *Scanner, height uint32, hash string) {
	t.Helper()
	gotHeight, gotHash, err := store.LoadCursor(context.Background(), s.DB)
	require.NoError(t, err)
	assert.Equal(t, height, gotHeight)
	want, err := decodeHashLE(hash)
	require.NoError(t, err)
	assert.Equal(t, want, gotHash)
}

func TestScannerReorgPurgesOrphanedStories(t *testing.T) {
	t.Parallel()

	for _, tc := range []struct {
		name    string
		replace int
	}{
		{name: "two blocks replaced", replace: 2},
		{name: "shorter chain", replace: 1},
		{name: "deeper than twenty blocks", replace: 25},
	} {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			ctx := context.Background()
			s, core := newForkScanner(t)

			old := make([]string, 30)
			for i := range old {
				old[i] = fmt.Sprintf("old %02d", i+1)
			}
			oldChain := core.branch(0xa0, genesisHash, old...)
			core.setChain(oldChain...)
			require.NoError(t, s.catchUp(ctx))
			require.Len(t, headlines(t, s), 30)

			keep := 30 - tc.replace
			parent := genesisHash
			if keep > 0 {
				parent = oldChain[keep-1]
			}
			newChain := append(oldChain[:keep:keep], core.branch(0xb0, parent, make([]string, tc.replace)...)...)
			if tc.name == "shorter chain" {
				newChain = oldChain[:keep]
			}
			core.setChain(newChain...)
			require.NoError(t, s.catchUp(ctx))

			assert.Equal(t, old[:keep], headlines(t, s))
			assertCursor(t, s, uint32(len(newChain)), newChain[len(newChain)-1])
		})
	}
}

func TestScannerRebuildsAfterChainDropsToGenesis(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	s, core := newForkScanner(t)

	chain := core.branch(0xa0, genesisHash, "story")
	core.setChain(chain...)
	require.NoError(t, s.catchUp(ctx))
	core.setChain()
	require.NoError(t, s.catchUp(ctx))
	core.setChain(chain...)
	require.NoError(t, s.catchUp(ctx))

	assert.Equal(t, []string{"story"}, headlines(t, s))
}

// A reorg between two blocks of one catch-up must not leave the first block's
// stories behind.
func TestScannerReorgDuringCatchUp(t *testing.T) {
	t.Parallel()
	ctx := context.Background()
	s, core := newForkScanner(t)

	oldChain := core.branch(0xa0, genesisHash, "orphan", "orphan two")
	newChain := core.branch(0xb0, genesisHash, "", "", "")
	core.setChain(oldChain...)
	core.onGetBlock = func(hash string) {
		if hash == oldChain[0] {
			core.setChain(newChain...)
		}
	}

	require.ErrorIs(t, s.catchUp(ctx), errChainMoved)
	require.NoError(t, s.catchUp(ctx))

	assert.Empty(t, headlines(t, s))
	assertCursor(t, s, 3, newChain[2])
}
