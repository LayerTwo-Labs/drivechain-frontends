// Package datasource abstracts every read-only chain/drivechain data fetch that
// bitwindow + the orchestrator make from Bitcoin Core and the BIP300301
// enforcer, behind a single interface. The current ("local") implementation is
// wired straight to those endpoints; a future PR adds a remote implementation
// plus wallet-type-based selection (electrum wallets, which run no local Core
// or enforcer, get their read data from a remote server instead).
//
// Read-only only: writes/broadcast/signing and crypto primitives are NOT here.
package datasource

import (
	"context"

	"connectrpc.com/connect"

	v1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
)

// DataSource is the full read-only surface: mainchain/enforcer reads plus
// Bitcoin Core chain reads. It is composed of segregated readers so callers can
// depend only on what they use, and so the Core reader (whose backing client
// differs between services) can be supplied independently.
type DataSource interface {
	DrivechainReader
	EnforcerWalletReader
	ChainReader
}

// DrivechainReader is the read-only enforcer ValidatorService surface — chain
// tip/headers, sidechains, proposals, two-way-peg data. Returns the shared
// cusf.mainchain.v1 proto messages (both services already speak them), so the
// local impl is a thin unwrap of the Connect client.
type DrivechainReader interface {
	ChainTip(context.Context, *v1.GetChainTipRequest) (*v1.GetChainTipResponse, error)
	ChainInfo(context.Context, *v1.GetChainInfoRequest) (*v1.GetChainInfoResponse, error)
	BlockHeaderInfo(context.Context, *v1.GetBlockHeaderInfoRequest) (*v1.GetBlockHeaderInfoResponse, error)
	BlockInfo(context.Context, *v1.GetBlockInfoRequest) (*v1.GetBlockInfoResponse, error)
	Sidechains(context.Context, *v1.GetSidechainsRequest) (*v1.GetSidechainsResponse, error)
	SidechainProposals(context.Context, *v1.GetSidechainProposalsRequest) (*v1.GetSidechainProposalsResponse, error)
	TwoWayPegData(context.Context, *v1.GetTwoWayPegDataRequest) (*v1.GetTwoWayPegDataResponse, error)
	Ctip(context.Context, *v1.GetCtipRequest) (*v1.GetCtipResponse, error)
	BmmHStarCommitment(context.Context, *v1.GetBmmHStarCommitmentRequest) (*v1.GetBmmHStarCommitmentResponse, error)
}

// EnforcerWalletReader is the read-only enforcer WalletService surface.
type EnforcerWalletReader interface {
	Balance(context.Context, *v1.GetBalanceRequest) (*v1.GetBalanceResponse, error)
	WalletInfo(context.Context, *v1.GetInfoRequest) (*v1.GetInfoResponse, error)
	ListTransactions(context.Context, *v1.ListTransactionsRequest) (*v1.ListTransactionsResponse, error)
	ListSidechainDeposits(context.Context, *v1.ListSidechainDepositTransactionsRequest) (*v1.ListSidechainDepositTransactionsResponse, error)
	ListUnspentOutputs(context.Context, *v1.ListUnspentOutputsRequest) (*v1.ListUnspentOutputsResponse, error)
}

// Getter lazily resolves a Connect client, mirroring bitwindow's
// service.Service[T].Get — we take a func rather than the concrete type so the
// datasource package (in the orchestrator module) doesn't import bitwindow.
type ValidatorGetter func(context.Context) (mainchainv1connect.ValidatorServiceClient, error)
type WalletGetter func(context.Context) (mainchainv1connect.WalletServiceClient, error)

// EnforcerSource implements DrivechainReader + EnforcerWalletReader against the
// live enforcer Connect clients. Shared by both services — they hold the same
// client types.
type EnforcerSource struct {
	validator ValidatorGetter
	wallet    WalletGetter
}

// NewEnforcerSource builds the local enforcer-backed reader from client getters.
func NewEnforcerSource(validator ValidatorGetter, wallet WalletGetter) *EnforcerSource {
	return &EnforcerSource{validator: validator, wallet: wallet}
}

func (e *EnforcerSource) ChainTip(ctx context.Context, req *v1.GetChainTipRequest) (*v1.GetChainTipResponse, error) {
	c, err := e.validator(ctx)
	if err != nil {
		return nil, err
	}
	resp, err := c.GetChainTip(ctx, connect.NewRequest(req))
	if err != nil {
		return nil, err
	}
	return resp.Msg, nil
}

func (e *EnforcerSource) ChainInfo(ctx context.Context, req *v1.GetChainInfoRequest) (*v1.GetChainInfoResponse, error) {
	c, err := e.validator(ctx)
	if err != nil {
		return nil, err
	}
	resp, err := c.GetChainInfo(ctx, connect.NewRequest(req))
	if err != nil {
		return nil, err
	}
	return resp.Msg, nil
}

func (e *EnforcerSource) BlockHeaderInfo(ctx context.Context, req *v1.GetBlockHeaderInfoRequest) (*v1.GetBlockHeaderInfoResponse, error) {
	c, err := e.validator(ctx)
	if err != nil {
		return nil, err
	}
	resp, err := c.GetBlockHeaderInfo(ctx, connect.NewRequest(req))
	if err != nil {
		return nil, err
	}
	return resp.Msg, nil
}

func (e *EnforcerSource) BlockInfo(ctx context.Context, req *v1.GetBlockInfoRequest) (*v1.GetBlockInfoResponse, error) {
	c, err := e.validator(ctx)
	if err != nil {
		return nil, err
	}
	resp, err := c.GetBlockInfo(ctx, connect.NewRequest(req))
	if err != nil {
		return nil, err
	}
	return resp.Msg, nil
}

func (e *EnforcerSource) Sidechains(ctx context.Context, req *v1.GetSidechainsRequest) (*v1.GetSidechainsResponse, error) {
	c, err := e.validator(ctx)
	if err != nil {
		return nil, err
	}
	resp, err := c.GetSidechains(ctx, connect.NewRequest(req))
	if err != nil {
		return nil, err
	}
	return resp.Msg, nil
}

func (e *EnforcerSource) SidechainProposals(ctx context.Context, req *v1.GetSidechainProposalsRequest) (*v1.GetSidechainProposalsResponse, error) {
	c, err := e.validator(ctx)
	if err != nil {
		return nil, err
	}
	resp, err := c.GetSidechainProposals(ctx, connect.NewRequest(req))
	if err != nil {
		return nil, err
	}
	return resp.Msg, nil
}

func (e *EnforcerSource) TwoWayPegData(ctx context.Context, req *v1.GetTwoWayPegDataRequest) (*v1.GetTwoWayPegDataResponse, error) {
	c, err := e.validator(ctx)
	if err != nil {
		return nil, err
	}
	resp, err := c.GetTwoWayPegData(ctx, connect.NewRequest(req))
	if err != nil {
		return nil, err
	}
	return resp.Msg, nil
}

func (e *EnforcerSource) Ctip(ctx context.Context, req *v1.GetCtipRequest) (*v1.GetCtipResponse, error) {
	c, err := e.validator(ctx)
	if err != nil {
		return nil, err
	}
	resp, err := c.GetCtip(ctx, connect.NewRequest(req))
	if err != nil {
		return nil, err
	}
	return resp.Msg, nil
}

func (e *EnforcerSource) BmmHStarCommitment(ctx context.Context, req *v1.GetBmmHStarCommitmentRequest) (*v1.GetBmmHStarCommitmentResponse, error) {
	c, err := e.validator(ctx)
	if err != nil {
		return nil, err
	}
	resp, err := c.GetBmmHStarCommitment(ctx, connect.NewRequest(req))
	if err != nil {
		return nil, err
	}
	return resp.Msg, nil
}

func (e *EnforcerSource) Balance(ctx context.Context, req *v1.GetBalanceRequest) (*v1.GetBalanceResponse, error) {
	c, err := e.wallet(ctx)
	if err != nil {
		return nil, err
	}
	resp, err := c.GetBalance(ctx, connect.NewRequest(req))
	if err != nil {
		return nil, err
	}
	return resp.Msg, nil
}

func (e *EnforcerSource) WalletInfo(ctx context.Context, req *v1.GetInfoRequest) (*v1.GetInfoResponse, error) {
	c, err := e.wallet(ctx)
	if err != nil {
		return nil, err
	}
	resp, err := c.GetInfo(ctx, connect.NewRequest(req))
	if err != nil {
		return nil, err
	}
	return resp.Msg, nil
}

func (e *EnforcerSource) ListTransactions(ctx context.Context, req *v1.ListTransactionsRequest) (*v1.ListTransactionsResponse, error) {
	c, err := e.wallet(ctx)
	if err != nil {
		return nil, err
	}
	resp, err := c.ListTransactions(ctx, connect.NewRequest(req))
	if err != nil {
		return nil, err
	}
	return resp.Msg, nil
}

func (e *EnforcerSource) ListSidechainDeposits(ctx context.Context, req *v1.ListSidechainDepositTransactionsRequest) (*v1.ListSidechainDepositTransactionsResponse, error) {
	c, err := e.wallet(ctx)
	if err != nil {
		return nil, err
	}
	resp, err := c.ListSidechainDepositTransactions(ctx, connect.NewRequest(req))
	if err != nil {
		return nil, err
	}
	return resp.Msg, nil
}

func (e *EnforcerSource) ListUnspentOutputs(ctx context.Context, req *v1.ListUnspentOutputsRequest) (*v1.ListUnspentOutputsResponse, error) {
	c, err := e.wallet(ctx)
	if err != nil {
		return nil, err
	}
	resp, err := c.ListUnspentOutputs(ctx, connect.NewRequest(req))
	if err != nil {
		return nil, err
	}
	return resp.Msg, nil
}

var (
	_ DrivechainReader     = (*EnforcerSource)(nil)
	_ EnforcerWalletReader = (*EnforcerSource)(nil)
)
