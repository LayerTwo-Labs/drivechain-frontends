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
	pb "github.com/LayerTwo-Labs/sidesail/drivechain-server/gen/validator/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/drivechain-server/gen/validator/v1/validatorv1connect"
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

	tip, err := client.GetMainChainTip(ctx, connect.NewRequest(&pb.GetMainChainTipRequest{}))
	if err != nil {
		return nil, fmt.Errorf("get mainchain tip: %w", err)
	}

	blockHash, err := chainhash.NewHash(tip.Msg.BlockHash)
	if err != nil {
		return nil, fmt.Errorf("parse blockhash: %w", err)
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
