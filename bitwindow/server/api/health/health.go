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
	corepb "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha"
	corerpc "github.com/barebitcoin/btc-buf/gen/bitcoin/bitcoind/v1alpha/bitcoindv1alphaconnect"
	"github.com/rs/zerolog"
	"google.golang.org/protobuf/types/known/emptypb"
	"google.golang.org/protobuf/types/known/wrapperspb"
)

var _ rpc.HealthServiceHandler = new(Server)

// New creates a new Server and starts the balance update loop
func New(
	database *sql.DB,
	bitcoind *service.Service[corerpc.BitcoinServiceClient],
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
	bitcoind *service.Service[corerpc.BitcoinServiceClient]
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

	return connect.NewResponse(&healthv1.CheckResponse{
		ServiceStatuses: statuses,
	}), nil
}

func (s *Server) Watch(ctx context.Context, _ *connect.Request[emptypb.Empty], stream *connect.ServerStream[healthv1.CheckResponse]) error {
	type serviceStatusEvent struct {
		name   string
		status bool
	}
	myUpdateCh := make(chan serviceStatusEvent, 10)

	// listens for status changes from all running services,
	// and sends a status update whenever the status changes
	// any update from any service triggers an event to be sent
	// on the stream
	go func() {
		for status := range s.bitcoind.ConnectedChan() {
			myUpdateCh <- serviceStatusEvent{name: "bitcoind", status: status}
		}
	}()
	go func() {
		for status := range s.enforcer.ConnectedChan() {
			myUpdateCh <- serviceStatusEvent{name: "enforcer", status: status}
		}
	}()
	go func() {
		for status := range s.wallet.ConnectedChan() {
			myUpdateCh <- serviceStatusEvent{name: "wallet", status: status}
		}
	}()
	go func() {
		for status := range s.crypto.ConnectedChan() {
			myUpdateCh <- serviceStatusEvent{name: "crypto", status: status}
		}
	}()

	// get initial status and send it when a client subscribes
	statuses, err := s.getServiceStatuses(ctx)
	if err != nil {
		return err
	}
	if err := stream.Send(&healthv1.CheckResponse{ServiceStatuses: statuses}); err != nil {
		return err
	}

	statusMap := make(map[string]*healthv1.CheckResponse_ServiceStatus)
	for _, st := range statuses {
		statusMap[st.ServiceName] = st
	}

	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		case event := <-myUpdateCh:
			// a service status changed, pushing update on stream
			statusMap[event.name].Status = connectedBoolToEnum(event.status)
			zerolog.Ctx(ctx).Info().
				Str("service", event.name).
				Bool("connected", event.status).
				Msg("service status changed")

			var updated []*healthv1.CheckResponse_ServiceStatus
			for _, st := range statusMap {
				updated = append(updated, st)
			}
			if err := stream.Send(&healthv1.CheckResponse{ServiceStatuses: updated}); err != nil {
				return err
			}
		}
	}
}

func connectedBoolToEnum(connected bool) healthv1.CheckResponse_Status {
	if connected {
		return healthv1.CheckResponse_STATUS_SERVING
	}
	return healthv1.CheckResponse_STATUS_NOT_SERVING
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
		return checkHealth(ctx, "bitcoind", s.bitcoind, func(ctx context.Context, client corerpc.BitcoinServiceClient) error {
			_, err := client.GetBlockchainInfo(ctx, connect.NewRequest(&corepb.GetBlockchainInfoRequest{}))
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
						// pass a valid hex string here, so that the
						// server doesn't throw an error
						Value: "deadbeef",
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
