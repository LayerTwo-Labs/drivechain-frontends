package dial

import (
	"context"
	"crypto/tls"
	"errors"
	"fmt"
	"net"
	"net/http"

	"connectrpc.com/connect"
	commonv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/common/v1"
	cryptov1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/crypto/v1"
	cryptorpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/crypto/v1/cryptov1connect"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1/mainchainv1connect"
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

	// Use the provided context directly with grpc.NewClient
	client := rpc.NewValidatorServiceClient(
		newInsecureClient(),
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
		newInsecureClient(),
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
		newInsecureClient(),
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
