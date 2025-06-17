package apitests

import (
	"context"
	"database/sql"
	"net/http"
	"net/http/httptest"
	"testing"

	"connectrpc.com/connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/api"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/crypto/v1/cryptov1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1/mainchainv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/tests/mocks"
	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
	"go.uber.org/mock/gomock"
)

type config struct {
	wallet   mainchainv1connect.WalletServiceClient
	enforcer mainchainv1connect.ValidatorServiceClient
	crypto   cryptov1connect.CryptoServiceClient
	bitcoind bitcoindv1alphaconnect.BitcoinServiceClient
}

type ServerOpt func(opt *config)

func (o *config) populate(_ *testing.T, ctrl *gomock.Controller, options ...ServerOpt) {
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
		o.bitcoind = mocks.NewMockBitcoinServiceClient(ctrl)
	}
}

func newConfig(t *testing.T, ctrl *gomock.Controller, options ...ServerOpt) config {
	var conf config
	for _, opt := range options {
		opt(&conf)
	}
	conf.populate(t, ctrl)
	return conf
}

func WithWallet(wallet mainchainv1connect.WalletServiceClient) ServerOpt {
	return func(opt *config) { opt.wallet = wallet }
}

func WithValidator(validator mainchainv1connect.ValidatorServiceClient) ServerOpt {
	return func(opt *config) { opt.enforcer = validator }
}

func WithCrypto(crypto cryptov1connect.CryptoServiceClient) ServerOpt {
	return func(opt *config) { opt.crypto = crypto }
}

func WithBitcoind(bitcoind bitcoindv1alphaconnect.BitcoinServiceClient) ServerOpt {
	return func(opt *config) { opt.bitcoind = bitcoind }
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
	}

	srv, err := api.New(context.Background(), services, api.Config{
		GUIBootedMainchain: false,
		GUIBootedEnforcer:  false,
		OnShutdown: func() {
			zerolog.Ctx(context.Background()).Info().Msg("shutdown")
		},
	})
	require.NoError(t, err)

	return serve(t, srv)
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
