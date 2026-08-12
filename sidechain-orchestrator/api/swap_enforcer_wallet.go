package api

import (
	"context"
	"errors"

	"connectrpc.com/connect"
	"github.com/samber/lo"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/walletmanager/v1"
)

func (h *WalletHandler) SwapEnforcerWallet(
	ctx context.Context,
	req *connect.Request[pb.SwapEnforcerWalletRequest],
	stream *connect.ServerStream[pb.SwapEnforcerWalletProgressResponse],
) error {
	if h.orch == nil {
		return connect.NewError(connect.CodeFailedPrecondition, errors.New("orchestrator is not available"))
	}

	planned := lo.Map(orchestrator.SwapEnforcerWalletPlan(), func(step orchestrator.SwapEnforcerWalletStep, _ int) *pb.SwapEnforcerWalletStep {
		return &pb.SwapEnforcerWalletStep{StepId: step.ID, Name: step.Name}
	})
	if err := stream.Send(&pb.SwapEnforcerWalletProgressResponse{Steps: planned}); err != nil {
		return err
	}

	var sendErr error
	var failedStep string
	progress := func(stepID string, status orchestrator.SwapEnforcerWalletStepStatus, detail string, stepErr error) {
		if status == orchestrator.SwapEnforcerWalletStepFailed {
			failedStep = stepID
		}
		if sendErr != nil {
			return
		}
		msg := &pb.SwapEnforcerWalletProgressResponse{
			Status: &pb.SwapEnforcerWalletProgressStatus{
				StepId: stepID,
				State:  swapStepStatusToProto(status),
				Detail: detail,
			},
		}
		if stepErr != nil {
			msg.Status.Error = stepErr.Error()
		}
		if err := stream.Send(msg); err != nil {
			sendErr = err
		}
	}

	walletID, err := h.orch.SwapEnforcerWallet(ctx, orchestrator.SwapEnforcerWalletRequest{
		Mnemonic: req.Msg.Mnemonic,
		Name:     req.Msg.Name,
	}, progress)
	if err != nil {
		if sendErr != nil {
			return sendErr
		}
		if failedStep == orchestrator.SwapEnforcerStepValidate {
			return connect.NewError(connect.CodeInvalidArgument, err)
		}
		return connect.NewError(connect.CodeInternal, err)
	}
	if sendErr != nil {
		return sendErr
	}

	return stream.Send(&pb.SwapEnforcerWalletProgressResponse{
		WalletId: walletID,
		Status: &pb.SwapEnforcerWalletProgressStatus{
			Complete: true,
			State:    pb.SwapEnforcerWalletStepState_SWAP_ENFORCER_WALLET_STEP_STATE_COMPLETED,
		},
	})
}

func swapStepStatusToProto(status orchestrator.SwapEnforcerWalletStepStatus) pb.SwapEnforcerWalletStepState {
	switch status {
	case orchestrator.SwapEnforcerWalletStepStarted:
		return pb.SwapEnforcerWalletStepState_SWAP_ENFORCER_WALLET_STEP_STATE_STARTED
	case orchestrator.SwapEnforcerWalletStepCompleted:
		return pb.SwapEnforcerWalletStepState_SWAP_ENFORCER_WALLET_STEP_STATE_COMPLETED
	case orchestrator.SwapEnforcerWalletStepFailed:
		return pb.SwapEnforcerWalletStepState_SWAP_ENFORCER_WALLET_STEP_STATE_FAILED
	default:
		return pb.SwapEnforcerWalletStepState_SWAP_ENFORCER_WALLET_STEP_STATE_UNSPECIFIED
	}
}
