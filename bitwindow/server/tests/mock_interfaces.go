//go:generate mockgen -source=../gen/cusf/mainchain/v1/mainchainv1connect/wallet.connect.go -destination=mocks/mock_wallet.go -package=mocks
//go:generate mockgen -source=../gen/cusf/mainchain/v1/mainchainv1connect/validator.connect.go -destination=mocks/mock_validator.go -package=mocks
//go:generate mockgen -source=../gen/cusf/crypto/v1/cryptov1connect/crypto.connect.go -destination=mocks/mock_crypto.go -package=mocks
//go:generate mockgen -destination=mocks/mock_bitcoind.go -package=mocks github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect BitcoinServiceClient

package service
