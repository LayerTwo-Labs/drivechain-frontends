package engines

import (
	"bytes"
	"context"
	"net/http"
	"net/http/httptest"
	"strconv"
	"strings"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"connectrpc.com/connect"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/btcsuite/btcd/wire"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/database"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/models/blocks"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	codec "github.com/LayerTwo-Labs/sidesail/coinnews/codec"
	orchpb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
	orchwallet "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/wallet"
)

// fakeEsplora serves a chain over the Esplora block routes. chain[0] is the
// genesis block.
type fakeEsplora struct {
	mu     sync.Mutex
	chain  []*wire.MsgBlock
	down   bool
	failed atomic.Int64
	reads  atomic.Int64
}

func (f *fakeEsplora) setChain(chain []*wire.MsgBlock) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.chain = chain
}

func (f *fakeEsplora) setDown(down bool) {
	f.mu.Lock()
	defer f.mu.Unlock()
	f.down = down
}

func (f *fakeEsplora) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	f.mu.Lock()
	defer f.mu.Unlock()
	if f.down {
		f.failed.Add(1)
		http.Error(w, "esplora is down", http.StatusInternalServerError)
		return
	}
	switch path := r.URL.Path; {
	case path == "/blocks/tip/height":
		_, _ = w.Write([]byte(strconv.Itoa(len(f.chain) - 1)))
	case strings.HasPrefix(path, "/block-height/"):
		height, err := strconv.Atoi(strings.TrimPrefix(path, "/block-height/"))
		if err != nil || height >= len(f.chain) {
			http.Error(w, "Block not found", http.StatusNotFound)
			return
		}
		_, _ = w.Write([]byte(f.chain[height].BlockHash().String()))
	case strings.HasPrefix(path, "/block/") && strings.HasSuffix(path, "/raw"):
		hash := strings.TrimSuffix(strings.TrimPrefix(path, "/block/"), "/raw")
		for _, block := range f.chain {
			if block.BlockHash().String() != hash {
				continue
			}
			f.reads.Add(1)
			var buf bytes.Buffer
			if err := block.Serialize(&buf); err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}
			_, _ = w.Write(buf.Bytes())
			return
		}
		http.Error(w, "Block not found", http.StatusNotFound)
	default:
		http.NotFound(w, r)
	}
}

func newFakeEsplora(t *testing.T, chain []*wire.MsgBlock) (*fakeEsplora, *orchwallet.EsploraClient) {
	t.Helper()
	fake := &fakeEsplora{chain: chain}
	srv := httptest.NewServer(fake)
	t.Cleanup(srv.Close)
	client := orchwallet.NewEsploraClient([]string{srv.URL}, zerolog.Nop())
	client.SetMinInterval(0)
	return fake, client
}

// chainWithStories builds a genesis block plus one block per headline. An
// empty headline gives a block with only a coinbase.
func chainWithStories(t *testing.T, base []*wire.MsgBlock, headlines ...string) []*wire.MsgBlock {
	t.Helper()
	chain := append([]*wire.MsgBlock{}, base...)
	if len(chain) == 0 {
		chain = append(chain, &wire.MsgBlock{
			Header:       wire.BlockHeader{Timestamp: time.Unix(1_700_000_000, 0)},
			Transactions: []*wire.MsgTx{testCoinbase(0)},
		})
	}
	for _, headline := range headlines {
		prev := chain[len(chain)-1]
		height := uint32(len(chain))
		txs := []*wire.MsgTx{testCoinbase(height)}
		if headline != "" {
			story, err := codec.EncodeStory(codec.Story{Topic: codec.Topic{0x48, 0x4e, 0x53, 0x21}, Headline: headline})
			require.NoError(t, err)
			txs = append(txs, &wire.MsgTx{
				TxIn:  []*wire.TxIn{{PreviousOutPoint: wire.OutPoint{Hash: chainhash.Hash{byte(height), 1}}}},
				TxOut: []*wire.TxOut{{PkScript: pkScript(t, story)}},
			})
		}
		chain = append(chain, &wire.MsgBlock{
			Header: wire.BlockHeader{
				PrevBlock: prev.BlockHash(),
				Timestamp: prev.Header.Timestamp.Add(10 * time.Minute),
				Nonce:     uint32(len(headline)),
			},
			Transactions: txs,
		})
	}
	return chain
}

func testCoinbase(height uint32) *wire.MsgTx {
	return &wire.MsgTx{
		TxIn: []*wire.TxIn{{
			PreviousOutPoint: wire.OutPoint{Index: wire.MaxPrevOutIndex},
			SignatureScript:  []byte{0x03, byte(height), byte(height >> 8), 0},
		}},
		TxOut: []*wire.TxOut{{Value: 50_0000_0000, PkScript: []byte{0x51}}},
	}
}

func esploraParser(t *testing.T) *Parser {
	t.Helper()
	db := database.Test(t)
	return &Parser{db: db, m4Engine: NewM4Engine(db), chainParams: &chaincfg.RegressionNetParams}
}

func storyHeadlines(t *testing.T, p *Parser) []string {
	t.Helper()
	rows, err := p.db.QueryContext(t.Context(), `
		SELECT s.headline FROM cn_stories s JOIN cn_items i ON i.item_id = s.item_id
		ORDER BY i.block_height`)
	require.NoError(t, err)
	defer func() { require.NoError(t, rows.Close()) }()
	var out []string
	for rows.Next() {
		var headline string
		require.NoError(t, rows.Scan(&headline))
		out = append(out, headline)
	}
	require.NoError(t, rows.Err())
	return out
}

func processedTipHeight(t *testing.T, p *Parser) uint32 {
	t.Helper()
	tip, err := blocks.GetProcessedTip(t.Context(), p.db)
	require.NoError(t, err)
	if tip == nil {
		return 0
	}
	return tip.Height
}

func TestEsploraTickIndexesCoinNewsOneTime(t *testing.T) {
	ctx := t.Context()
	fake, client := newFakeEsplora(t, chainWithStories(t, nil, "", "first story", "second story"))
	p := esploraParser(t)

	require.NoError(t, p.handleEsploraTick(ctx, client))
	require.Equal(t, []string{"first story", "second story"}, storyHeadlines(t, p))
	require.Equal(t, uint32(3), processedTipHeight(t, p))
	reads := fake.reads.Load()
	require.Equal(t, int64(3), reads)

	require.NoError(t, p.handleEsploraTick(ctx, client))
	require.Equal(t, []string{"first story", "second story"}, storyHeadlines(t, p))
	require.Equal(t, reads, fake.reads.Load(), "a second poll reads no block it already processed")
}

func TestEsploraTickReplaysAFork(t *testing.T) {
	ctx := t.Context()
	base := chainWithStories(t, nil, "kept story")
	fake, client := newFakeEsplora(t, chainWithStories(t, base, "orphan story"))
	p := esploraParser(t)

	require.NoError(t, p.handleEsploraTick(ctx, client))
	require.Equal(t, []string{"kept story", "orphan story"}, storyHeadlines(t, p))

	fake.setChain(chainWithStories(t, base, "replacement story"))
	require.NoError(t, p.handleEsploraTick(ctx, client))
	require.Equal(t, []string{"kept story", "replacement story"}, storyHeadlines(t, p))
}

func TestParserRetriesEsploraAfterAnOutage(t *testing.T) {
	fake, client := newFakeEsplora(t, chainWithStories(t, nil, "story after the outage"))
	fake.setDown(true)

	orch := mocks.NewMockWalletManagerServiceClient(gomock.NewController(t))
	orch.EXPECT().GetNodeMode(gomock.Any(), gomock.Any()).AnyTimes().
		Return(connect.NewResponse(&orchpb.GetNodeModeResponse{Mode: orchpb.NodeMode_NODE_MODE_LIGHT}), nil)

	p := esploraParser(t)
	p.nodeMode = NewNodeMode(orch)
	p.esplora = func(context.Context) *orchwallet.EsploraClient { return client }
	p.esploraPoll = 20 * time.Millisecond

	ctx, cancel := context.WithCancel(t.Context())
	done := make(chan error, 1)
	go func() { done <- p.Run(ctx) }()

	require.Eventually(t, func() bool { return fake.failed.Load() >= 2 }, 5*time.Second, 10*time.Millisecond,
		"the engine keeps polling while esplora is down")
	require.Empty(t, storyHeadlines(t, p))

	fake.setDown(false)
	require.Eventually(t, func() bool {
		tip, err := blocks.GetProcessedTip(context.Background(), p.db)
		return err == nil && tip != nil && tip.Height == 1
	}, 5*time.Second, 10*time.Millisecond)
	require.Equal(t, []string{"story after the outage"}, storyHeadlines(t, p))

	cancel()
	select {
	case err := <-done:
		require.NoError(t, err)
	case <-time.After(5 * time.Second):
		t.Fatal("Run did not return after its context ended")
	}
}
