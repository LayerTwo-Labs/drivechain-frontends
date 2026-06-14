package datasource

import (
	"context"

	"connectrpc.com/connect"
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	"github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"google.golang.org/protobuf/types/known/emptypb"
)

// ChainReader is the read-only Bitcoin Core surface. It returns the btc-buf
// corepb messages bitwindow already consumes, so migrating a handler is a pure
// extraction (drop the service.Get + connect wrappers). A future remote impl
// serves the same messages.
type ChainReader interface {
	BlockchainInfo(context.Context, *corepb.GetBlockchainInfoRequest) (*corepb.GetBlockchainInfoResponse, error)
	BlockHash(context.Context, *corepb.GetBlockHashRequest) (*corepb.GetBlockHashResponse, error)
	Block(context.Context, *corepb.GetBlockRequest) (*corepb.GetBlockResponse, error)
	RawMempool(context.Context, *corepb.GetRawMempoolRequest) (*corepb.GetRawMempoolResponse, error)
	RawTransaction(context.Context, *corepb.GetRawTransactionRequest) (*corepb.GetRawTransactionResponse, error)
	NetworkInfo(context.Context, *corepb.GetNetworkInfoRequest) (*corepb.GetNetworkInfoResponse, error)
	NetTotals(context.Context, *corepb.GetNetTotalsRequest) (*corepb.GetNetTotalsResponse, error)
	PeerInfo(context.Context, *corepb.GetPeerInfoRequest) (*corepb.GetPeerInfoResponse, error)
	EstimateSmartFee(context.Context, *corepb.EstimateSmartFeeRequest) (*corepb.EstimateSmartFeeResponse, error)
	ListWallets(context.Context, *emptypb.Empty) (*corepb.ListWalletsResponse, error)
	ListUnspent(context.Context, *corepb.ListUnspentRequest) (*corepb.ListUnspentResponse, error)
	// ListWalletTransactions is Core's wallet tx history (listtransactions).
	// Named to disambiguate from EnforcerWalletReader.ListTransactions.
	ListWalletTransactions(context.Context, *corepb.ListTransactionsRequest) (*corepb.ListTransactionsResponse, error)
}

// BitcoindGetter lazily resolves the Core Connect client.
type BitcoindGetter func(context.Context) (bitcoindv1alphaconnect.BitcoinServiceClient, error)

// CoreSource implements ChainReader against the live Core Connect client.
type CoreSource struct {
	bitcoind BitcoindGetter
}

// NewCoreSource builds the local Core-backed reader from a client getter.
func NewCoreSource(bitcoind BitcoindGetter) *CoreSource {
	return &CoreSource{bitcoind: bitcoind}
}

func (c *CoreSource) BlockchainInfo(ctx context.Context, req *corepb.GetBlockchainInfoRequest) (*corepb.GetBlockchainInfoResponse, error) {
	cl, err := c.bitcoind(ctx)
	if err != nil {
		return nil, err
	}
	resp, err := cl.GetBlockchainInfo(ctx, connect.NewRequest(req))
	if err != nil {
		return nil, err
	}
	return resp.Msg, nil
}

func (c *CoreSource) BlockHash(ctx context.Context, req *corepb.GetBlockHashRequest) (*corepb.GetBlockHashResponse, error) {
	cl, err := c.bitcoind(ctx)
	if err != nil {
		return nil, err
	}
	resp, err := cl.GetBlockHash(ctx, connect.NewRequest(req))
	if err != nil {
		return nil, err
	}
	return resp.Msg, nil
}

func (c *CoreSource) Block(ctx context.Context, req *corepb.GetBlockRequest) (*corepb.GetBlockResponse, error) {
	cl, err := c.bitcoind(ctx)
	if err != nil {
		return nil, err
	}
	resp, err := cl.GetBlock(ctx, connect.NewRequest(req))
	if err != nil {
		return nil, err
	}
	return resp.Msg, nil
}

func (c *CoreSource) RawMempool(ctx context.Context, req *corepb.GetRawMempoolRequest) (*corepb.GetRawMempoolResponse, error) {
	cl, err := c.bitcoind(ctx)
	if err != nil {
		return nil, err
	}
	resp, err := cl.GetRawMempool(ctx, connect.NewRequest(req))
	if err != nil {
		return nil, err
	}
	return resp.Msg, nil
}

func (c *CoreSource) RawTransaction(ctx context.Context, req *corepb.GetRawTransactionRequest) (*corepb.GetRawTransactionResponse, error) {
	cl, err := c.bitcoind(ctx)
	if err != nil {
		return nil, err
	}
	resp, err := cl.GetRawTransaction(ctx, connect.NewRequest(req))
	if err != nil {
		return nil, err
	}
	return resp.Msg, nil
}

func (c *CoreSource) NetworkInfo(ctx context.Context, req *corepb.GetNetworkInfoRequest) (*corepb.GetNetworkInfoResponse, error) {
	cl, err := c.bitcoind(ctx)
	if err != nil {
		return nil, err
	}
	resp, err := cl.GetNetworkInfo(ctx, connect.NewRequest(req))
	if err != nil {
		return nil, err
	}
	return resp.Msg, nil
}

func (c *CoreSource) NetTotals(ctx context.Context, req *corepb.GetNetTotalsRequest) (*corepb.GetNetTotalsResponse, error) {
	cl, err := c.bitcoind(ctx)
	if err != nil {
		return nil, err
	}
	resp, err := cl.GetNetTotals(ctx, connect.NewRequest(req))
	if err != nil {
		return nil, err
	}
	return resp.Msg, nil
}

func (c *CoreSource) PeerInfo(ctx context.Context, req *corepb.GetPeerInfoRequest) (*corepb.GetPeerInfoResponse, error) {
	cl, err := c.bitcoind(ctx)
	if err != nil {
		return nil, err
	}
	resp, err := cl.GetPeerInfo(ctx, connect.NewRequest(req))
	if err != nil {
		return nil, err
	}
	return resp.Msg, nil
}

func (c *CoreSource) EstimateSmartFee(ctx context.Context, req *corepb.EstimateSmartFeeRequest) (*corepb.EstimateSmartFeeResponse, error) {
	cl, err := c.bitcoind(ctx)
	if err != nil {
		return nil, err
	}
	resp, err := cl.EstimateSmartFee(ctx, connect.NewRequest(req))
	if err != nil {
		return nil, err
	}
	return resp.Msg, nil
}

func (c *CoreSource) ListWallets(ctx context.Context, req *emptypb.Empty) (*corepb.ListWalletsResponse, error) {
	cl, err := c.bitcoind(ctx)
	if err != nil {
		return nil, err
	}
	resp, err := cl.ListWallets(ctx, connect.NewRequest(req))
	if err != nil {
		return nil, err
	}
	return resp.Msg, nil
}

func (c *CoreSource) ListUnspent(ctx context.Context, req *corepb.ListUnspentRequest) (*corepb.ListUnspentResponse, error) {
	cl, err := c.bitcoind(ctx)
	if err != nil {
		return nil, err
	}
	resp, err := cl.ListUnspent(ctx, connect.NewRequest(req))
	if err != nil {
		return nil, err
	}
	return resp.Msg, nil
}

func (c *CoreSource) ListWalletTransactions(ctx context.Context, req *corepb.ListTransactionsRequest) (*corepb.ListTransactionsResponse, error) {
	cl, err := c.bitcoind(ctx)
	if err != nil {
		return nil, err
	}
	resp, err := cl.ListTransactions(ctx, connect.NewRequest(req))
	if err != nil {
		return nil, err
	}
	return resp.Msg, nil
}

var _ ChainReader = (*CoreSource)(nil)

// Local is the full DataSource backed by live Core + enforcer clients. Composes
// the Core and enforcer readers; this is what the getters return today.
type Local struct {
	*CoreSource
	*EnforcerSource
}

// NewLocal builds the full local DataSource from the three client getters.
func NewLocal(bitcoind BitcoindGetter, validator ValidatorGetter, wallet WalletGetter) *Local {
	return &Local{
		CoreSource:     NewCoreSource(bitcoind),
		EnforcerSource: NewEnforcerSource(validator, wallet),
	}
}

var _ DataSource = (*Local)(nil)
