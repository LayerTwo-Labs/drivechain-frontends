package dial

import (
	"context"
	"crypto/tls"
	"errors"
	"fmt"
	"net"
	"net/http"
	"time"

	"connectrpc.com/connect"
	pb "github.com/LayerTwo-Labs/sidesail/drivechain-server/gen/cusf/mainchain/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/drivechain-server/gen/cusf/mainchain/v1/mainchainv1connect"
	"github.com/btcsuite/btcd/chaincfg/chainhash"
	"github.com/rs/zerolog"
	"golang.org/x/net/http2"
)

// Enforcer creates a CUSF enforcer (validator) client.
func Enforcer(ctx context.Context, url string) (rpc.ValidatorServiceClient, error) {
	start := time.Now()

	if url == "" {
		return nil, errors.New("empty validator url")
	}

	// Use the provided context directly with grpc.NewClient
	client := rpc.NewValidatorServiceClient(
		newInsecureClient(),
		fmt.Sprintf("http://%s", url),
		connect.WithGRPC(),
	)
	var tip *connect.Response[pb.GetChainTipResponse]
	var blockHash *chainhash.Hash
	var err error
	for attempt := range 3 {
		tip, err = client.GetChainTip(ctx, connect.NewRequest(&pb.GetChainTipRequest{}))
		if err == nil {
			blockHash, err = chainhash.NewHash([]byte(tip.Msg.BlockHeaderInfo.BlockHash.Hex.Value))
			if err == nil {
				break
			}
		}

		sleepDuration := time.Second * time.Duration(attempt+1)
		zerolog.Ctx(ctx).Info().
			Int("attempt", attempt+1).
			Err(err).
			Msgf("failed to get chain tip. trying again in %s", sleepDuration)
		if attempt < 4 {
			time.Sleep(sleepDuration)
		}
	}
	if err != nil {
		return client, fmt.Errorf("get mainchain tip and parse blockhash after 3 attempts: %w", err)
	}

	zerolog.Ctx(ctx).Debug().
		Stringer("duration", time.Since(start)).
		Str("url", url).
		Str("tip", blockHash.String()).
		Msg("connected to enforcer")

	return client, nil
}

// https://connectrpc.com/docs/go/deployment/#h2c
func newInsecureClient() *http.Client {
	return &http.Client{
		Transport: &http2.Transport{
			AllowHTTP: true,
			DialTLS: func(network, addr string, _ *tls.Config) (net.Conn, error) {
				// If you're also using this client for non-h2c traffic, you may want
				// to delegate to tls.Dial if the network isn't TCP or the addr isn't
				// in an allowlist.
				return net.Dial(network, addr)
			},
		},
	}
}
