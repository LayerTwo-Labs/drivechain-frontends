package engines

import (
	"context"
	"errors"
	"net/http"
	"sync"
	"time"

	coinnewsv1 "github.com/LayerTwo-Labs/sidesail/coinnews/server/gen/coinnews/v1"
	"github.com/LayerTwo-Labs/sidesail/coinnews/server/gen/coinnews/v1/coinnewsv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"

	"connectrpc.com/connect"
)

// ErrNoIndexer means the network publishes no CoinNews indexer, so the caller
// reads its own database instead.
var ErrNoIndexer = errors.New("this network publishes no coin news indexer")

// RemoteCoinNews reads a published CoinNews indexer.
type RemoteCoinNews interface {
	// ListFrontPage returns items ranked by score, newest-first on ties. It
	// returns ErrNoIndexer when the network publishes none.
	ListFrontPage(ctx context.Context, topicHex string, limit uint32) ([]RemoteItem, error)
}

// RemoteItem is one indexed CoinNews story as the indexer renders it.
type RemoteItem struct {
	ItemIDHex string
	TopicHex  string
	Headline  string
	URL       string
	Body      string
	Subtype   int32
	NSFW      bool
	BlockTime time.Time
	Points    int32
	Upvotes   int32
	Downvotes int32
	Score     float64
	TxID      string
	Vout      uint32
}

// connectRemote reads a coinnewsd deployment over ConnectRPC.
type connectRemote struct {
	network string
	once    sync.Once
	client  coinnewsv1connect.CoinNewsServiceClient
}

// NewRemoteCoinNews returns a reader for the network's published CoinNews
// indexer. It reads the document on the first call, not here: the API handlers
// this runs from must not wait on a slow endpoint.
func NewRemoteCoinNews(network string) RemoteCoinNews {
	return &connectRemote{network: network}
}

// resolve reads the indexer URL the network publishes, once.
func (r *connectRemote) resolve(ctx context.Context) coinnewsv1connect.CoinNewsServiceClient {
	r.once.Do(func() {
		net, ok := netcatalog.Resolve(ctx).ForNetwork(r.network)
		if !ok || net.Services.CoinNews.URL == "" {
			return
		}
		r.client = coinnewsv1connect.NewCoinNewsServiceClient(
			&http.Client{Timeout: 30 * time.Second},
			net.Services.CoinNews.URL,
		)
	})
	return r.client
}

func (r *connectRemote) ListFrontPage(ctx context.Context, topicHex string, limit uint32) ([]RemoteItem, error) {
	client := r.resolve(ctx)
	if client == nil {
		return nil, ErrNoIndexer
	}
	req := &coinnewsv1.ListFrontPageRequest{Limit: limit}
	if topicHex != "" {
		req.TopicHex = &topicHex
	}
	res, err := client.ListFrontPage(ctx, connect.NewRequest(req))
	if err != nil {
		return nil, err
	}

	out := make([]RemoteItem, len(res.Msg.Items))
	for i, item := range res.Msg.Items {
		out[i] = RemoteItem{
			ItemIDHex: item.ItemIdHex,
			TopicHex:  item.TopicHex,
			Headline:  item.Headline,
			URL:       item.Url,
			Body:      item.Body,
			Subtype:   int32(item.Subtype),
			NSFW:      item.Nsfw,
			BlockTime: item.BlockTime.AsTime(),
			Points:    item.Points,
			Upvotes:   item.Upvotes,
			Downvotes: item.Downvotes,
			Score:     item.Score,
			TxID:      item.Txid,
			Vout:      item.Vout,
		}
	}
	return out, nil
}
