package datasource

import (
	"context"
	"net/http"
	"time"

	"github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
)

// NewRemote builds a DataSource backed by a hosted, read-only orchestrator at
// baseURL (e.g. https://orchestrator.signet.drivechain.info). Electrum wallets
// run no local Core or enforcer, so their chain/drivechain reads come from this
// remote instance, which bridges the Core proxy and the enforcer Validator and
// Wallet services behind one host. Cookie-free: the remote is public read-only,
// not local-auth gated, and speaks the Connect protocol over HTTPS.
func NewRemote(baseURL string) *Local {
	hc := &http.Client{Timeout: 30 * time.Second}
	bitcoind := func(context.Context) (bitcoindv1alphaconnect.BitcoinServiceClient, error) {
		return bitcoindv1alphaconnect.NewBitcoinServiceClient(hc, baseURL), nil
	}
	validator := func(context.Context) (mainchainv1connect.ValidatorServiceClient, error) {
		return mainchainv1connect.NewValidatorServiceClient(hc, baseURL), nil
	}
	wallet := func(context.Context) (mainchainv1connect.WalletServiceClient, error) {
		return mainchainv1connect.NewWalletServiceClient(hc, baseURL), nil
	}
	return NewLocal(bitcoind, validator, wallet)
}
