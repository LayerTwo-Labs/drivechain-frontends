package sidechain

import (
	"context"
	"errors"
	"net"
	"os"

	"connectrpc.com/connect/v2"
)

// KeepErrorText sends the text of a plain handler error to the client.
// Connect v2 sends a plain error as CodeUnknown with no message.
func KeepErrorText() connect.ServerInterceptor {
	return func(next connect.ServerFunc) connect.ServerFunc {
		return func(ctx context.Context, spec connect.Spec, stream connect.ServerStream) error {
			return withErrorText(next(ctx, spec, stream))
		}
	}
}

func withErrorText(err error) error {
	if err == nil {
		return nil
	}
	if cerr, ok := errors.AsType[*connect.Error](err); ok && cerr != nil {
		if !cerr.IsRemote() {
			return err
		}
		return connect.NewError(connect.CodeInternal, err.Error()).WithCause(err)
	}
	return connect.NewError(plainErrorCode(err), err.Error()).WithCause(err)
}

func plainErrorCode(err error) connect.Code {
	switch {
	case errors.Is(err, context.Canceled):
		return connect.CodeCanceled
	case errors.Is(err, context.DeadlineExceeded), errors.Is(err, os.ErrDeadlineExceeded):
		return connect.CodeDeadlineExceeded
	case errors.As(err, new(*net.OpError)):
		return connect.CodeUnavailable
	default:
		return connect.CodeUnknown
	}
}
