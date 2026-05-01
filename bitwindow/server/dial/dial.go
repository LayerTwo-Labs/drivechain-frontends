package dial

import (
	"context"
	"crypto/tls"
	"errors"
	"fmt"
	"net"
	"net/http"
	"strings"
	"sync"
	"time"

	"connectrpc.com/connect"
	commonv1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/common/v1"
	cryptov1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/crypto/v1"
	cryptorpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/crypto/v1/cryptov1connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bitassets"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bitnames"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/coinshift"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/photon"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/thunder"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/truthcoin"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/rs/zerolog"
	"golang.org/x/net/http2"
	"google.golang.org/protobuf/types/known/wrapperspb"
)

// EnforcerValidator creates a CUSF enforcer (validator & wallet) client.
// Bitcoind returns a btc-buf BitcoinService client against the orchestrator's
// hosted core proxy. orchestratorAddr is a full URL (config.OrchestratorAddr
// defaults to "http://localhost:30400"); a bare host:port also works and gets
// prefixed with http://. Single canonical bitcoind RPC route — no direct dial.
func Bitcoind(ctx context.Context, orchestratorAddr string) (corerpc.BitcoinServiceClient, error) {
	if orchestratorAddr == "" {
		return nil, errors.New("empty orchestrator addr")
	}
	return corerpc.NewBitcoinServiceClient(
		getSharedClient(ctx),
		ensureHTTPScheme(orchestratorAddr),
		connect.WithGRPC(),
	), nil
}

// ensureHTTPScheme returns addr unchanged if it already has an http:// or
// https:// scheme; otherwise prefixes http://. Guards against the
// double-prefix bug where callers passing a full URL ended up with
// "http://http://..." which Connect dialed as if "http" were a hostname.
func ensureHTTPScheme(addr string) string {
	lower := strings.ToLower(addr)
	if strings.HasPrefix(lower, "http://") || strings.HasPrefix(lower, "https://") {
		return addr
	}
	return "http://" + addr
}

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

	_, err := client.CreateNewAddress(ctx, connect.NewRequest(&pb.CreateNewAddressRequest{}))
	if err != nil {
		return nil, fmt.Errorf("create new address: %w", err)
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

	if _, err := client.Ripemd160(ctx, connect.NewRequest(&cryptov1.Ripemd160Request{
		Msg: &commonv1.Hex{
			Hex: &wrapperspb.StringValue{
				Value: "deadbeef", // make sure this is valid hex
			},
		},
	})); err != nil {
		return nil, fmt.Errorf("ripemd160: %w", err)
	}

	return client, nil
}

// Thunder creates a Thunder sidechain client
func Thunder(ctx context.Context, host string, port int) (*thunder.Client, error) {
	if host == "" {
		return nil, errors.New("empty thunder host")
	}

	client := thunder.NewClient(host, port)

	// Test connection with a simple call
	_, err := client.Balance(ctx)
	if err != nil {
		return nil, fmt.Errorf("thunder connection test: %w", err)
	}

	return client, nil
}

// BitNames creates a BitNames sidechain client
func BitNames(ctx context.Context, host string, port int) (*bitnames.Client, error) {
	if host == "" {
		return nil, errors.New("empty bitnames host")
	}

	client := bitnames.NewClient(host, port)

	// Test connection with a simple call
	_, err := client.Balance(ctx)
	if err != nil {
		return nil, fmt.Errorf("bitnames connection test: %w", err)
	}

	return client, nil
}

// BitAssets creates a BitAssets sidechain client
func BitAssets(ctx context.Context, host string, port int) (*bitassets.Client, error) {
	if host == "" {
		return nil, errors.New("empty bitassets host")
	}

	client := bitassets.NewClient(host, port)

	// Test connection with a simple call
	_, err := client.Balance(ctx)
	if err != nil {
		return nil, fmt.Errorf("bitassets connection test: %w", err)
	}

	return client, nil
}

// Truthcoin creates a Truthcoin sidechain client
func Truthcoin(ctx context.Context, host string, port int) (*truthcoin.Client, error) {
	if host == "" {
		return nil, errors.New("empty truthcoin host")
	}

	client := truthcoin.NewClient(host, port)

	// Test connection with a simple call
	_, err := client.Balance(ctx)
	if err != nil {
		return nil, fmt.Errorf("truthcoin connection test: %w", err)
	}

	return client, nil
}

// Photon creates a Photon sidechain client
func Photon(ctx context.Context, host string, port int) (*photon.Client, error) {
	if host == "" {
		return nil, errors.New("empty photon host")
	}

	client := photon.NewClient(host, port)

	// Test connection with a simple call
	_, err := client.Balance(ctx)
	if err != nil {
		return nil, fmt.Errorf("photon connection test: %w", err)
	}

	return client, nil
}

// CoinShift creates a CoinShift sidechain client
func CoinShift(ctx context.Context, host string, port int) (*coinshift.Client, error) {
	if host == "" {
		return nil, errors.New("empty coinshift host")
	}

	client := coinshift.NewClient(host, port)

	// Test connection with a simple call
	_, err := client.Balance(ctx)
	if err != nil {
		return nil, fmt.Errorf("coinshift connection test: %w", err)
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
