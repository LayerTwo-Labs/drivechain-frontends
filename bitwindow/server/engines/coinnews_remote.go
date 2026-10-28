package engines

import (
	"context"
	"errors"
	"net/http"
	"sync"
	"time"

	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/rs/zerolog"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	coinnewsv1 "github.com/LayerTwo-Labs/sidesail/coinnews/server/gen/coinnews/v1"
	"github.com/LayerTwo-Labs/sidesail/coinnews/server/gen/coinnews/v1/coinnewsv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/config/netcatalog"
)

// ErrNoIndexer means the network publishes no CoinNews indexer, so the caller
// reads its own database instead.
var ErrNoIndexer = errors.New("this network publishes no coin news indexer")

// RemoteCoinNews reads a published CoinNews indexer.
type RemoteCoinNews interface {
	// ListFrontPage returns items ranked by fee, newest-first on ties. It
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
	FeeSats   int64
	TxID      string
	Vout      uint32
}

// connectRemote reads a coinnewsd deployment over ConnectRPC.
type connectRemote struct {
	network    string
	ecashID    string
	catalogURL string

	mu       sync.Mutex
	resolved bool
	client   coinnewsv1connect.CoinNewsServiceClient
	failedAt time.Time
	fallback coinnewsv1connect.CoinNewsServiceClient
}

// A failed fetch can take the whole fetch timeout, so it is not tried again on each call.
const catalogRetryAfter = time.Minute

// NewRemoteCoinNews returns a reader for the network's published CoinNews
// indexer. On eCash, ecashID selects the catalog entry. It reads the document
// on the first call, not here: the API handlers this runs from must not wait
// on a slow endpoint.
func NewRemoteCoinNews(network, ecashID string) RemoteCoinNews {
	return &connectRemote{network: network, ecashID: ecashID, catalogURL: netcatalog.DefaultURL}
}

// resolve reads the indexer URL the network publishes. It keeps the answer of
// the first fetch that works. Until then, it reads the embedded catalog.
func (r *connectRemote) resolve(ctx context.Context) coinnewsv1connect.CoinNewsServiceClient {
	r.mu.Lock()
	defer r.mu.Unlock()
	if r.resolved {
		return r.client
	}
	if !r.failedAt.IsZero() && time.Since(r.failedAt) < catalogRetryAfter {
		return r.fallback
	}
	catalog, err := netcatalog.Fetch(ctx, r.catalogURL)
	if err != nil {
		zerolog.Ctx(ctx).Warn().Err(err).Msg("coinnews: read the embedded catalog")
		r.failedAt = time.Now()
		r.fallback = r.clientFor(netcatalog.Embedded())
		return r.fallback
	}
	r.client = r.clientFor(catalog)
	r.resolved = true
	return r.client
}

func (r *connectRemote) clientFor(catalog netcatalog.Catalog) coinnewsv1connect.CoinNewsServiceClient {
	var net netcatalog.Network
	var ok bool
	if r.network == string(config.NetworkECash) {
		net, ok = catalog.ByID(r.ecashID)
	} else {
		net, ok = catalog.ForNetwork(r.network)
	}
	if !ok || net.Services.CoinNews.URL == "" {
		return nil
	}
	return coinnewsv1connect.NewCoinNewsServiceClient(connect.NewClient(connecthttp.NewTransport(
		&http.Client{Timeout: 30 * time.Second},
		net.Services.CoinNews.URL,
		connecthttp.WithReadMaxBytes(0),
	)))
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
	res, err := client.ListFrontPage(ctx, req)
	if err != nil {
		return nil, err
	}

	out := make([]RemoteItem, len(res.Items))
	for i, item := range res.Items {
		out[i] = RemoteItem{
			ItemIDHex: item.ItemIdHex,
			TopicHex:  item.TopicHex,
			Headline:  item.Headline,
			URL:       item.Url,
			Body:      item.Body,
			Subtype:   int32(item.Subtype),
			NSFW:      item.Nsfw,
			BlockTime: item.BlockTime.AsTime(),
			FeeSats:   item.FeeSats,
			TxID:      item.Txid,
			Vout:      item.Vout,
		}
	}
	return out, nil
}
