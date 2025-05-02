package api_health

import (
	"context"
	"database/sql"
	"errors"
	"time"

	"connectrpc.com/connect"
	commonv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/common/v1"
	cryptov1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/crypto/v1"
	cryptorpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/crypto/v1/cryptov1connect"
	mainchainv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/cusf/mainchain/v1/mainchainv1connect"
	healthv1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/health/v1"
	rpc "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/health/v1/healthv1connect"
	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/logpool"
	service "github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	bitcoindv1alpha "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	coreproxy "github.com/barebitcoin/btc-buf/server"
	"github.com/rs/zerolog"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/wrapperspb"
)

var _ rpc.HealthServiceHandler = new(Server)

// New creates a new Server and starts the balance update loop
func New(
	database *sql.DB,
	bitcoind *service.Service[*coreproxy.Bitcoind],
	enforcer *service.Service[validatorrpc.ValidatorServiceClient],
	wallet *service.Service[validatorrpc.WalletServiceClient],
	crypto *service.Service[cryptorpc.CryptoServiceClient],
) *Server {
	s := &Server{
		database: database,
		bitcoind: bitcoind,
		enforcer: enforcer,
		wallet:   wallet,
		crypto:   crypto,
	}
	return s
}

type Server struct {
	database *sql.DB
	bitcoind *service.Service[*coreproxy.Bitcoind]
	enforcer *service.Service[validatorrpc.ValidatorServiceClient]
	wallet   *service.Service[validatorrpc.WalletServiceClient]
	crypto   *service.Service[cryptorpc.CryptoServiceClient]
}

// Check implements healthv1connect.HealthServiceHandler.
func (s *Server) Check(ctx context.Context, _ *connect.Request[emptypb.Empty]) (*connect.Response[healthv1.CheckResponse], error) {

	statuses, err := s.getServiceStatuses(ctx)
	if err != nil {
		return nil, connect.NewError(connect.CodeInternal, err)
	}

	zerolog.Ctx(ctx).Info().
		Int("total_services", len(statuses)).
		Msg("All health checks completed")

	return connect.NewResponse(&healthv1.CheckResponse{
		ServiceStatuses: statuses,
	}), nil
}

func (s *Server) Watch(ctx context.Context, _ *connect.Request[emptypb.Empty], stream *connect.ServerStream[healthv1.CheckResponse]) error {
	ticker := time.NewTicker(time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		case <-ticker.C:
			statuses, err := s.getServiceStatuses(ctx)
			if err != nil {
				return err
			}
			err = stream.Send(&healthv1.CheckResponse{
				ServiceStatuses: statuses,
			})
			if err != nil {
				return err
			}
		}
	}
}

// Generic helper function for service health checks
func checkHealth[T any](
	ctx context.Context,
	serviceName string,
	svc *service.Service[T],
	healthCheck func(context.Context, T) error,
) *healthv1.CheckResponse_ServiceStatus {
	ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
	defer cancel()

	if !svc.IsConnected() {
		return &healthv1.CheckResponse_ServiceStatus{
			ServiceName: serviceName,
			Status:      healthv1.CheckResponse_STATUS_NOT_SERVING,
		}
	}

	client, err := svc.Get(ctx)
	if err != nil {
		return &healthv1.CheckResponse_ServiceStatus{
			ServiceName: serviceName,
			Status:      healthv1.CheckResponse_STATUS_NOT_SERVING,
		}
	}

	if err := healthCheck(ctx, client); err != nil {
		if errors.Is(err, context.DeadlineExceeded) {
			zerolog.Ctx(ctx).Warn().Msgf("%s health check timed out", serviceName)
		}
		return &healthv1.CheckResponse_ServiceStatus{
			ServiceName: serviceName,
			Status:      healthv1.CheckResponse_STATUS_NOT_SERVING,
		}
	}

	return &healthv1.CheckResponse_ServiceStatus{
		ServiceName: serviceName,
		Status:      healthv1.CheckResponse_STATUS_SERVING,
	}
}

func (s *Server) getServiceStatuses(ctx context.Context) ([]*healthv1.CheckResponse_ServiceStatus, error) {
	pool := logpool.NewWithResults[*healthv1.CheckResponse_ServiceStatus](ctx, "health-check")

	// Database check
	pool.Go("database", func(ctx context.Context) (*healthv1.CheckResponse_ServiceStatus, error) {
		ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
		defer cancel()

		if err := s.database.PingContext(ctx); err != nil {
			return &healthv1.CheckResponse_ServiceStatus{
				ServiceName: "database",
				Status:      healthv1.CheckResponse_STATUS_NOT_SERVING,
			}, nil
		}
		return &healthv1.CheckResponse_ServiceStatus{
			ServiceName: "database",
			Status:      healthv1.CheckResponse_STATUS_SERVING,
		}, nil
	})

	pool.Go("bitcoind", func(ctx context.Context) (*healthv1.CheckResponse_ServiceStatus, error) {
		return checkHealth(ctx, "bitcoind", s.bitcoind, func(ctx context.Context, client *coreproxy.Bitcoind) error {
			_, err := client.GetBlockchainInfo(ctx, connect.NewRequest(&bitcoindv1alpha.GetBlockchainInfoRequest{}))
			return err
		}), nil
	})

	pool.Go("enforcer", func(ctx context.Context) (*healthv1.CheckResponse_ServiceStatus, error) {
		return checkHealth(ctx, "enforcer", s.enforcer, func(ctx context.Context, client validatorrpc.ValidatorServiceClient) error {
			_, err := client.GetChainInfo(ctx, connect.NewRequest(&mainchainv1.GetChainInfoRequest{}))
			return err
		}), nil
	})

	pool.Go("wallet", func(ctx context.Context) (*healthv1.CheckResponse_ServiceStatus, error) {
		return checkHealth(ctx, "wallet", s.wallet, func(ctx context.Context, client validatorrpc.WalletServiceClient) error {
			_, err := client.GetInfo(ctx, connect.NewRequest(&mainchainv1.GetInfoRequest{}))
			return err
		}), nil
	})

	pool.Go("crypto", func(ctx context.Context) (*healthv1.CheckResponse_ServiceStatus, error) {
		return checkHealth(ctx, "crypto", s.crypto, func(ctx context.Context, client cryptorpc.CryptoServiceClient) error {
			_, err := client.Ripemd160(ctx, connect.NewRequest(&cryptov1.Ripemd160Request{
				Msg: &commonv1.Hex{
					Hex: &wrapperspb.StringValue{
						Value: "test",
					},
				},
			}))
			return err
		}), nil
	})

	statuses, err := pool.Wait(ctx)
	if err != nil {
		zerolog.Ctx(ctx).Error().Err(err).Msg("could not get service statuses")
		return nil, err
	}

	return statuses, nil
}
