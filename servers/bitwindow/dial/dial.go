package dial

import (
	"context"
	"crypto/tls"
	"errors"
	"fmt"
	"net"
	"net/http"

	"connectrpc.com/connect"
	cryptorpc "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/cusf/crypto/v1/cryptov1connect"
	pb "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/cusf/mainchain/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/cusf/mainchain/v1/mainchainv1connect"
	"golang.org/x/net/http2"
)

// Enforcer creates a CUSF enforcer (validator & wallet) client.
func Enforcer(ctx context.Context, url string) (
	rpc.ValidatorServiceClient, rpc.WalletServiceClient, cryptorpc.CryptoServiceClient, error,
) {
	if url == "" {
		return nil, nil, nil, errors.New("empty validator url")
	}

	// Use the provided context directly with grpc.NewClient
	client := rpc.NewValidatorServiceClient(
		newInsecureClient(),
		fmt.Sprintf("http://%s", url),
		connect.WithGRPC(),
	)
	_, err := client.GetChainInfo(ctx, connect.NewRequest(&pb.GetChainInfoRequest{}))
	if err != nil {
		return nil, nil, nil, fmt.Errorf("get chain info: %w", err)
	}

	walletClient := rpc.NewWalletServiceClient(
		newInsecureClient(),
		fmt.Sprintf("http://%s", url),
		connect.WithGRPC(),
	)

	cryptoClient := cryptorpc.NewCryptoServiceClient(
		newInsecureClient(),
		fmt.Sprintf("http://%s", url),
		connect.WithGRPC(),
	)

	_, err = walletClient.GetBalance(ctx, connect.NewRequest(&pb.GetBalanceRequest{}))
	if err != nil {
		return nil, nil, nil, fmt.Errorf("get balance: %w", err)
	}

	return client, walletClient, cryptoClient, nil
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
