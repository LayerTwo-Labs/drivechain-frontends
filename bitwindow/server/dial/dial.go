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
	commonv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/common/v1"
	cryptov1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/crypto/v1"
	cryptorpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/crypto/v1/cryptov1connect"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1/mainchainv1connect"
	"github.com/rs/zerolog"
	"golang.org/x/net/http2"
	"google.golang.org/protobuf/types/known/wrapperspb"
)

// EnforcerValidator creates a CUSF enforcer (validator & wallet) client.
func EnforcerValidator(ctx context.Context, url string) (
	rpc.ValidatorServiceClient, error,
) {
	if url == "" {
		return nil, errors.New("empty validator url")
	}

	client := rpc.NewValidatorServiceClient(
		getSharedClient(ctx),
		fmt.Sprintf("http://%s", url),
		connect.WithGRPC(),
	)
	_, err := client.GetSidechains(ctx, connect.NewRequest(&pb.GetSidechainsRequest{}))
	if err != nil {
		return nil, fmt.Errorf("get sidechains: %w", err)
	}

	return client, nil
}

// EnforcerWallet creates a CUSF enforcer (wallet) client.
func EnforcerWallet(ctx context.Context, url string) (
	rpc.WalletServiceClient, error,
) {
	if url == "" {
		return nil, errors.New("empty validator url")
	}

	client := rpc.NewWalletServiceClient(
		getSharedClient(ctx),
		fmt.Sprintf("http://%s", url),
		connect.WithGRPC(),
	)

	_, err := client.GetBalance(ctx, connect.NewRequest(&pb.GetBalanceRequest{}))
	if err != nil {
		return nil, fmt.Errorf("get balance: %w", err)
	}

	return client, nil
}

// EnforcerCrypto creates a CUSF enforcer (crypto) client.
func EnforcerCrypto(ctx context.Context, url string) (
	cryptorpc.CryptoServiceClient, error,
) {
	if url == "" {
		return nil, errors.New("empty validator url")
	}

	client := cryptorpc.NewCryptoServiceClient(
		getSharedClient(ctx),
		fmt.Sprintf("http://%s", url),
		connect.WithGRPC(),
	)

	_, err := client.Ripemd160(ctx, connect.NewRequest(&cryptov1.Ripemd160Request{
		Msg: &commonv1.Hex{
			Hex: &wrapperspb.StringValue{
				Value: "test",
			},
		},
	}))
	if err != nil {
		return nil, fmt.Errorf("ripemd160: %w", err)
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
			// Request-level timeout
			Timeout: 30 * time.Second, // Overall request timeout
		}
	})
	return sharedClient
}
