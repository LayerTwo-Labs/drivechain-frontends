package engines

import (
	"context"
	"net/http"
	"time"

	coinnewsv1 "github.com/LayerTwo-Labs/sidesail/coinnews/server/gen/coinnews/v1"
	"github.com/LayerTwo-Labs/sidesail/coinnews/server/gen/coinnews/v1/coinnewsv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"

	"connectrpc.com/connect"
)

// RemoteCoinNews reads a published CoinNews indexer.
type RemoteCoinNews interface {
	// ListFrontPage returns items ranked by score, newest-first on ties.
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
	client coinnewsv1connect.CoinNewsServiceClient
}

// NewRemoteCoinNews returns a reader for the network's published CoinNews
// indexer, or nil when the network publishes none.
func NewRemoteCoinNews(bitwindowDir, network string) RemoteCoinNews {
	catalog, _ := netcatalog.Load(bitwindowDir)
	net, ok := catalog.ForNetwork(network)
	if !ok || net.Services.CoinNews.URL == "" {
		return nil
	}
	return &connectRemote{
		client: coinnewsv1connect.NewCoinNewsServiceClient(
			&http.Client{Timeout: 30 * time.Second},
			net.Services.CoinNews.URL,
		),
	}
}

func (r *connectRemote) ListFrontPage(ctx context.Context, topicHex string, limit uint32) ([]RemoteItem, error) {
	req := &coinnewsv1.ListFrontPageRequest{Limit: limit}
	if topicHex != "" {
		req.TopicHex = &topicHex
	}
	res, err := r.client.ListFrontPage(ctx, connect.NewRequest(req))
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
