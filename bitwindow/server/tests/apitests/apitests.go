package apitests

import (
	"context"
	"database/sql"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/api"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/config"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/crypto/v1/cryptov1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1/mainchainv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	"github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/btcsuite/btcd/chaincfg"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
)

type configg struct {
	wallet   mainchainv1connect.WalletServiceClient
	enforcer mainchainv1connect.ValidatorServiceClient
	crypto   cryptov1connect.CryptoServiceClient
	bitcoind bitcoindv1alphaconnect.BitcoinServiceClient
}

type ServerOpt func(opt *configg)

func (o *configg) populate(_ *testing.T, ctrl *gomock.Controller, options ...ServerOpt) {
	for _, option := range options {
		option(o)
	}

	if o.wallet == nil {
		o.wallet = mocks.NewMockWalletServiceClient(ctrl)
	}
	if o.enforcer == nil {
		o.enforcer = mocks.NewMockValidatorServiceClient(ctrl)
	}
	if o.crypto == nil {
		o.crypto = mocks.NewMockCryptoServiceClient(ctrl)
	}
	if o.bitcoind == nil {
		o.bitcoind = defaultBitcoindMock(ctrl)
	}
}

func newConfig(t *testing.T, ctrl *gomock.Controller, options ...ServerOpt) configg {
	var conf configg
	for _, opt := range options {
		opt(&conf)
	}
	conf.populate(t, ctrl)
	return conf
}

func WithWallet(wallet mainchainv1connect.WalletServiceClient) ServerOpt {
	return func(opt *configg) { opt.wallet = wallet }
}

func WithValidator(validator mainchainv1connect.ValidatorServiceClient) ServerOpt {
	return func(opt *configg) { opt.enforcer = validator }
}

func WithCrypto(crypto cryptov1connect.CryptoServiceClient) ServerOpt {
	return func(opt *configg) { opt.crypto = crypto }
}

func WithBitcoind(bitcoind bitcoindv1alphaconnect.BitcoinServiceClient) ServerOpt {
	return func(opt *configg) { opt.bitcoind = bitcoind }
}

// API creates a new external API Connect server that we can send test requests to
func API(t *testing.T, database *sql.DB, options ...ServerOpt) (connect.HTTPClient, string) {
	ctrl := gomock.NewController(t)

	logger := zerolog.New(zerolog.NewConsoleWriter()).
		With().
		Timestamp().
		Logger().
		Level(zerolog.InfoLevel)
	zerolog.DefaultContextLogger = &logger

	conf := newConfig(t, ctrl, options...)

	// Create a temporary directory with a valid wallet.json for tests
	walletDir := t.TempDir()
	createTestWalletJSON(t, walletDir)

	// Create connectors that return our mock clients
	services := api.Services{
		Database: database,
		WalletConnector: func(ctx context.Context) (mainchainv1connect.WalletServiceClient, error) {
			return conf.wallet, nil
		},
		EnforcerConnector: func(ctx context.Context) (mainchainv1connect.ValidatorServiceClient, error) {
			return conf.enforcer, nil
		},
		CryptoConnector: func(ctx context.Context) (cryptov1connect.CryptoServiceClient, error) {
			return conf.crypto, nil
		},
		BitcoindConnector: func(ctx context.Context) (bitcoindv1alphaconnect.BitcoinServiceClient, error) {
			return conf.bitcoind, nil
		},
		ChainParams: &chaincfg.SigNetParams,
		WalletDir:   walletDir,
	}

	srv, err := api.New(context.Background(), services, config.Config{
		GuiBootedMainchain: false,
		GuiBootedEnforcer:  false,
	}, nil, func(ctx context.Context) {
		zerolog.Ctx(context.Background()).Info().Msg("shutdown")
	})
	require.NoError(t, err)

	return serve(t, srv)
}

// createTestWalletJSON creates a valid wallet.json file in the given directory
// for use in tests. This wallet uses a fixed test seed and is configured as an
// enforcer wallet type.
func createTestWalletJSON(t *testing.T, walletDir string) {
	t.Helper()

	// Fixed test seed (64 bytes = 128 hex chars)
	// This is a deterministic test seed - DO NOT use in production
	testSeedHex := "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f"

	walletData := map[string]any{
		"version":        1,
		"activeWalletId": "test-wallet-id-1234",
		"wallets": []map[string]any{
			{
				"id":          "test-wallet-id-1234",
				"name":        "Test Wallet",
				"wallet_type": "enforcer",
				"master": map[string]any{
					"seed_hex": testSeedHex,
				},
				"l1": map[string]any{
					"mnemonic": "abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about",
				},
			},
		},
	}

	data, err := json.MarshalIndent(walletData, "", "  ")
	require.NoError(t, err)

	walletPath := filepath.Join(walletDir, "wallet.json")
	err = os.WriteFile(walletPath, data, 0600)
	require.NoError(t, err)
}

func serve(t *testing.T, server *api.Server) (connect.HTTPClient, string) {
	testServer := httptest.NewServer(server.Handler())

	client := testServer.Client()
	client.Transport = ctxTransport{t, client.Transport}

	return client, testServer.URL
}

type ctxTransport struct {
	t *testing.T
	http.RoundTripper
}

func (c ctxTransport) RoundTrip(r *http.Request) (*http.Response, error) {
	r.Header.Set("x-bitwindow-test", c.t.Name())

	return c.RoundTripper.RoundTrip(r)
}

var _ http.RoundTripper = new(ctxTransport)

// defaultBitcoindMock creates a mock bitcoind client with default expectations
// for background operations like ensureWatchWallet
func defaultBitcoindMock(ctrl *gomock.Controller) bitcoindv1alphaconnect.BitcoinServiceClient {
	mock := mocks.NewMockBitcoinServiceClient(ctrl)

	// Background goroutines may call these methods
	mock.EXPECT().
		ListWallets(gomock.Any(), gomock.Any()).
		Return(&connect.Response[corepb.ListWalletsResponse]{
			Msg: &corepb.ListWalletsResponse{
				Wallets: []string{},
			},
		}, nil).
		AnyTimes()

	mock.EXPECT().
		CreateWallet(gomock.Any(), gomock.Any()).
		Return(&connect.Response[corepb.CreateWalletResponse]{
			Msg: &corepb.CreateWalletResponse{
				Name: "cheque_watch",
			},
		}, nil).
		AnyTimes()

	return mock
}
