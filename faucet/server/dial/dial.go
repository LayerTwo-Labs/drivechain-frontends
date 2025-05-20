package dial

import (
	"context"
	"crypto/tls"
	"errors"
	"fmt"
	"net"
	"net/http"
	"sync"
	"time"

	"connectrpc.com/connect"
	validatordpb "github.com/LayerTwo-Labs/sidesail/faucet/server/gen/cusf/mainchain/v1"
	validatordrpc "github.com/LayerTwo-Labs/sidesail/faucet/server/gen/cusf/mainchain/v1/mainchainv1connect"
	"github.com/rs/zerolog"
	"golang.org/x/net/http2"
)

// EnforcerValidator creates a CUSF enforcer (validator & wallet) client.
func EnforcerValidator(ctx context.Context, url string) (
	validatordrpc.ValidatorServiceClient, error,
) {
	if url == "" {
		return nil, errors.New("empty validator url")
	}

	client := validatordrpc.NewValidatorServiceClient(
		getSharedClient(ctx),
		fmt.Sprintf("http://%s", url),
		connect.WithGRPC(),
	)
	_, err := client.GetSidechains(ctx, connect.NewRequest(&validatordpb.GetSidechainsRequest{}))
	if err != nil {
		return nil, fmt.Errorf("validator: get sidechains: %w", err)
	}

	return client, nil
}

var (
	// Shared HTTP client for all connections
	sharedClient *http.Client
	clientOnce   sync.Once
)

// getSharedClient returns a singleton HTTP client for all connections
func getSharedClient(ctx context.Context) *http.Client {
	clientOnce.Do(func() {
		sharedClient = &http.Client{
			Transport: &http2.Transport{
				AllowHTTP: true,
				DialTLS: func(network, addr string, _ *tls.Config) (net.Conn, error) {
					return net.Dial(network, addr)
				},
				// Without explicit timeouts here, clients linger indefinitely
				IdleConnTimeout:  15 * time.Second,
				ReadIdleTimeout:  30 * time.Second, // Close if no data received for 30s
				PingTimeout:      15 * time.Second,
				WriteByteTimeout: 10 * time.Second,

				CountError: func(errType string) {
					zerolog.Ctx(ctx).Error().Msgf("HTTP/2 transport error: %s", errType)
				},
			},
			Timeout: 30 * time.Second, // Overall request timeout
		}
	})
	return sharedClient
}
