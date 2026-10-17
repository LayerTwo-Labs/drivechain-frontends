package dial

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"strings"
	"sync"
	"time"

	"connectrpc.com/connect"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/rs/zerolog"
	"google.golang.org/protobuf/types/known/wrapperspb"

	commonv1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/common/v1"
	cryptov1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/crypto/v1"
	cryptorpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/crypto/v1/cryptov1connect"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
	orchrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1/orchestratorv1connect"
	walletmanagerrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1/walletmanagerv1connect"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/localauth"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bitassets"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/bitnames"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/coinshift"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/photon"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/thunder"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/sidechain/truthcoin"
)

// Bitcoind returns a btc-buf BitcoinService client against the orchestrator's
// hosted core proxy, with the local-auth cookie in cookieDir. orchestratorAddr
// is a full URL (config.OrchestratorAddr defaults to "http://localhost:30400");
// a bare host:port also works and gets prefixed with http://.
func Bitcoind(ctx context.Context, orchestratorAddr, cookieDir string) (corerpc.BitcoinServiceClient, error) {
	if orchestratorAddr == "" {
		return nil, errors.New("empty orchestrator addr")
	}
	return corerpc.NewBitcoinServiceClient(
		getSharedClient(ctx),
		ensureHTTPScheme(orchestratorAddr),
		connect.WithGRPC(),
		connect.WithInterceptors(localauth.Interceptor(cookieDir)),
	), nil
}

// Orchestrator returns an OrchestratorService client for drivechaind at addr,
// with the local-auth cookie in cookieDir.
func Orchestrator(addr, cookieDir string) orchrpc.OrchestratorServiceClient {
	return orchrpc.NewOrchestratorServiceClient(
		http.DefaultClient,
		addr,
		connect.WithGRPC(),
		connect.WithInterceptors(localauth.Interceptor(cookieDir)),
	)
}

// BitcoinConf returns a BitcoinConfService client for drivechaind at addr,
// with the local-auth cookie in cookieDir.
func BitcoinConf(addr, cookieDir string) orchrpc.BitcoinConfServiceClient {
	return orchrpc.NewBitcoinConfServiceClient(
		http.DefaultClient,
		addr,
		connect.WithGRPC(),
		connect.WithInterceptors(localauth.Interceptor(cookieDir)),
	)
}

// WalletManager returns a WalletManagerService client for drivechaind at addr,
// with the local-auth cookie in cookieDir.
func WalletManager(addr, cookieDir string) walletmanagerrpc.WalletManagerServiceClient {
	return walletmanagerrpc.NewWalletManagerServiceClient(
		http.DefaultClient,
		addr,
		connect.WithInterceptors(localauth.Interceptor(cookieDir)),
	)
}

// ensureHTTPScheme returns addr unchanged if it has an http or https scheme;
// otherwise prefixes http://.
func ensureHTTPScheme(addr string) string {
	lower := strings.ToLower(addr)
	if strings.HasPrefix(lower, "http://") || strings.HasPrefix(lower, "https://") {
		return addr
	}
	return "http://" + addr
}

// EnforcerValidator returns a validator client through the local orchestrator,
// with the local-auth cookie in cookieDir.
func EnforcerValidator(ctx context.Context, url, cookieDir string) (
	rpc.ValidatorServiceClient, error,
) {
	if url == "" {
		return nil, errors.New("empty validator url")
	}

	client := rpc.NewValidatorServiceClient(
		getSharedClient(ctx),
		ensureHTTPScheme(url),
		connect.WithGRPC(),
		connect.WithInterceptors(localauth.Interceptor(cookieDir)),
	)
	_, err := client.GetSidechains(ctx, connect.NewRequest(&pb.GetSidechainsRequest{}))
	if err != nil {
		return nil, fmt.Errorf("get sidechains: %w", err)
	}

	return client, nil
}

// EnforcerBlockProducer creates a CUSF enforcer block producer client. The
// block producer runs with no wallet, so its health check reads policy state
// rather than an address.
func EnforcerBlockProducer(ctx context.Context, url string) (
	rpc.BlockProducerServiceClient, error,
) {
	if url == "" {
		return nil, errors.New("empty block producer url")
	}

	client := rpc.NewBlockProducerServiceClient(
		getSharedClient(ctx),
		ensureHTTPScheme(url),
		connect.WithGRPC(),
	)

	_, err := client.GetBlockProducerState(ctx, connect.NewRequest(&pb.GetBlockProducerStateRequest{}))
	if err != nil {
		return nil, fmt.Errorf("get block producer state: %w", err)
	}

	return client, nil
}

// EnforcerMining creates a CUSF enforcer mining client. The enforcer serves it
// on regtest and signet only, so a dial failure here is normal on mainnet.
func EnforcerMining(ctx context.Context, url string) (
	rpc.MiningServiceClient, error,
) {
	if url == "" {
		return nil, errors.New("empty mining url")
	}

	return rpc.NewMiningServiceClient(
		getSharedClient(ctx),
		ensureHTTPScheme(url),
		connect.WithGRPC(),
	), nil
}

// EnforcerCrypto creates a CUSF enforcer (crypto) client.
func EnforcerCrypto(ctx context.Context, url string) (
	cryptorpc.CryptoServiceClient, error,
) {
	if url == "" {
		return nil, errors.New("empty crypto url")
	}

	client := cryptorpc.NewCryptoServiceClient(
		getSharedClient(ctx),
		ensureHTTPScheme(url),
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

func Thunder(ctx context.Context, host string, port int) (*thunder.Client, error) {
	return dialSidechain(ctx, "thunder", host, thunder.NewClient(host, port))
}

func BitNames(ctx context.Context, host string, port int) (*bitnames.Client, error) {
	return dialSidechain(ctx, "bitnames", host, bitnames.NewClient(host, port))
}

func BitAssets(ctx context.Context, host string, port int) (*bitassets.Client, error) {
	return dialSidechain(ctx, "bitassets", host, bitassets.NewClient(host, port))
}

func Truthcoin(ctx context.Context, host string, port int, cookieFile string) (*truthcoin.Client, error) {
	return dialSidechain(ctx, "truthcoin", host, truthcoin.NewClient(host, port, cookieFile))
}

func Photon(ctx context.Context, host string, port int) (*photon.Client, error) {
	return dialSidechain(ctx, "photon", host, photon.NewClient(host, port))
}

func CoinShift(ctx context.Context, host string, port int, cookieFile string) (*coinshift.Client, error) {
	return dialSidechain(ctx, "coinshift", host, coinshift.NewClient(host, port, cookieFile))
}

type balancer[B any] interface {
	Balance(ctx context.Context) (B, error)
}

func dialSidechain[C balancer[B], B any](ctx context.Context, name, host string, client C) (C, error) {
	if host == "" {
		var zero C
		return zero, fmt.Errorf("empty %s host", name)
	}
	if _, err := client.Balance(ctx); err != nil {
		var zero C
		return zero, fmt.Errorf("%s connection test: %w", name, err)
	}
	return client, nil
}

var (
	// Shared HTTP client for all connections
	sharedClient *http.Client
	clientOnce   sync.Once
)

func getSharedClient(ctx context.Context) *http.Client {
	clientOnce.Do(func() {
		protocols := new(http.Protocols)
		protocols.SetUnencryptedHTTP2(true)

		sharedClient = &http.Client{
			Transport: &http.Transport{
				Protocols: protocols,
				// Without explicit timeouts here, clients linger indefinitely
				IdleConnTimeout: 15 * time.Second,
				HTTP2: &http.HTTP2Config{
					SendPingTimeout:  30 * time.Second, // Close if no data received for 30s
					PingTimeout:      15 * time.Second,
					WriteByteTimeout: 10 * time.Second,

					// A metrics counter, not a fault report: an idle connection
					// closes on its own keepalive and counts an error here.
					CountError: func(errType string) {
						zerolog.Ctx(ctx).Debug().Msgf("HTTP/2 transport error: %s", errType)
					},
				},
			},
			Timeout: 30 * time.Second, // Overall request timeout
		}
	})
	return sharedClient
}
