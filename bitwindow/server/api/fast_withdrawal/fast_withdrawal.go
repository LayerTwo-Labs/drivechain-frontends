package fast_withdrawal

import (
	"context"
	"fmt"
	"time"

	"connectrpc.com/connect"
	"github.com/rs/zerolog"
	"google.golang.org/protobuf/types/known/timestamppb"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/engines"
	pb "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/fast_withdrawal/v1"
)

type Server struct {
	// Monitor engine for withdrawal detection
	monitor *engines.SidechainMonitorEngine
}

func New(monitor *engines.SidechainMonitorEngine) *Server {
	return &Server{monitor: monitor}
}

// InitiateFastWithdrawal starts a fast withdrawal and streams status updates
func (s *Server) InitiateFastWithdrawal(
	ctx context.Context,
	req *connect.Request[pb.InitiateFastWithdrawalRequest],
	stream *connect.ServerStream[pb.FastWithdrawalUpdate],
) error {
	log := zerolog.Ctx(ctx).With().
		Str("sidechain", req.Msg.Sidechain).
		Int64("amount", req.Msg.Amount).
		Str("destination", req.Msg.Destination).
		Logger()

	// Send initial status
	if err := stream.Send(&pb.FastWithdrawalUpdate{
		Status:    pb.FastWithdrawalUpdate_STATUS_INITIATING,
		Message:   "Initiating fast withdrawal...",
		Timestamp: timestamppb.Now(),
	}); err != nil {
		return err
	}

	// Initiate withdrawal on sidechain
	txid, err := s.monitor.InitiateFastWithdrawal(ctx, fastWithdrawalServerURL, req.Msg.Sidechain, req.Msg.Amount, req.Msg.Destination)
	if err != nil {
		log.Error().Err(err).Msg("initiate sidechain withdrawal")
		errorMsg := err.Error()
		return stream.Send(&pb.FastWithdrawalUpdate{
			Status:    pb.FastWithdrawalUpdate_STATUS_FAILED,
			Error:     &errorMsg,
			Message:   fmt.Sprintf("Failed to initiate withdrawal: %v", err),
			Timestamp: timestamppb.Now(),
		})
	}

	// Send pending status
	if err := stream.Send(&pb.FastWithdrawalUpdate{
		Status:    pb.FastWithdrawalUpdate_STATUS_PENDING,
		Message:   "Withdrawal submitted, waiting for detection...",
		Timestamp: timestamppb.Now(),
	}); err != nil {
		return err
	}

	// Monitor for withdrawal detection
	return s.monitorWithdrawal(ctx, stream, req.Msg.Sidechain, txid)
}

// TODO: Make this configurable or try multiple servers
const fastWithdrawalServerURL = "https://fw1.drivechain.info"

// monitorWithdrawal monitors for withdrawal detection and confirmation
func (s *Server) monitorWithdrawal(ctx context.Context, stream *connect.ServerStream[pb.FastWithdrawalUpdate], sidechain string, expectedTxid string) error {
	log := zerolog.Ctx(ctx)

	// Poll for detection with timeout
	timeout := time.After(5 * time.Minute) // 5-minute timeout
	ticker := time.NewTicker(2 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return ctx.Err()

		case <-timeout:
			log.Warn().Msg("withdrawal detection timeout")
			timeoutMsg := "detection timeout"
			return stream.Send(&pb.FastWithdrawalUpdate{
				Status:    pb.FastWithdrawalUpdate_STATUS_FAILED,
				Error:     &timeoutMsg,
				Message:   "Withdrawal not detected within 5 minutes",
				Timestamp: timestamppb.Now(),
			})

		case <-ticker.C:
			// Check if withdrawal was detected
			withdrawal, err := s.monitor.GetWithdrawalByTxid(ctx, expectedTxid)
			if err != nil {
				log.Warn().Err(err).Msg("error checking withdrawal status")
				continue
			}

			if withdrawal != nil && withdrawal.Sidechain == sidechain {
				// Found! Send detected status
				if err := stream.Send(&pb.FastWithdrawalUpdate{
					Status:    pb.FastWithdrawalUpdate_STATUS_DETECTED,
					Txid:      &withdrawal.Txid,
					Message:   fmt.Sprintf("Withdrawal detected: %s", withdrawal.Txid),
					Timestamp: timestamppb.Now(),
				}); err != nil {
					return err
				}

				// Check for confirmation
				if withdrawal.BlockHash != nil {
					return stream.Send(&pb.FastWithdrawalUpdate{
						Status:    pb.FastWithdrawalUpdate_STATUS_CONFIRMED,
						Txid:      &withdrawal.Txid,
						BlockHash: withdrawal.BlockHash,
						Message:   "Withdrawal confirmed on sidechain",
						Timestamp: timestamppb.Now(),
					})
				}

				// Continue monitoring for confirmation
				return s.monitorConfirmation(ctx, stream, withdrawal.Txid)
			}
		}
	}
}

// monitorConfirmation monitors for withdrawal confirmation
func (s *Server) monitorConfirmation(ctx context.Context, stream *connect.ServerStream[pb.FastWithdrawalUpdate], txid string) error {
	log := zerolog.Ctx(ctx)

	timeout := time.After(10 * time.Minute) // 10-minute timeout for confirmation
	ticker := time.NewTicker(5 * time.Second)
	defer ticker.Stop()

	for {
		select {
		case <-ctx.Done():
			return ctx.Err()

		case <-timeout:
			log.Info().Msg("confirmation monitoring timeout - withdrawal likely completed")
			return stream.Send(&pb.FastWithdrawalUpdate{
				Status:    pb.FastWithdrawalUpdate_STATUS_COMPLETED,
				Txid:      &txid,
				Message:   "Withdrawal monitoring completed",
				Timestamp: timestamppb.Now(),
			})

		case <-ticker.C:
			// Check for confirmation
			withdrawal, err := s.monitor.GetWithdrawalByTxid(ctx, txid)
			if err != nil {
				log.Warn().Err(err).Msg("error checking withdrawal confirmation")
				continue
			}

			if withdrawal != nil && withdrawal.BlockHash != nil {
				return stream.Send(&pb.FastWithdrawalUpdate{
					Status:    pb.FastWithdrawalUpdate_STATUS_CONFIRMED,
					Txid:      &withdrawal.Txid,
					BlockHash: withdrawal.BlockHash,
					Message:   "Withdrawal confirmed on sidechain",
					Timestamp: timestamppb.Now(),
				})
			}
		}
	}
}
