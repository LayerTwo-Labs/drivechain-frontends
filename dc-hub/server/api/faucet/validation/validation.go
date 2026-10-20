package validation

import (
	"context"
	"errors"
	"fmt"
	"sync"

	"connectrpc.com/connect/v2"
	"github.com/bufbuild/protovalidate-go"
	"google.golang.org/protobuf/proto"
)

var (
	validatorOnce sync.Once
	validatorErr  error
	validator     protovalidate.Validator
)

func Validator() (protovalidate.Validator, error) {
	validatorOnce.Do(func() {
		validator, validatorErr = protovalidate.New()
	})
	if validatorErr != nil {
		return nil, fmt.Errorf("setup protovalidate: %w", validatorErr)
	}
	return validator, nil
}

// Interceptor checks unary request constraints.
func Interceptor() connect.ServerInterceptor {
	return func(next connect.ServerFunc) connect.ServerFunc {
		return func(ctx context.Context, spec connect.Spec, stream connect.ServerStream) error {
			if spec.StreamType != connect.StreamTypeUnary {
				return next(ctx, spec, stream)
			}
			validator, err := Validator()
			if err != nil {
				return err
			}

			return next(ctx, spec, &requestStream{ServerStream: stream, validator: validator})
		}
	}
}

type requestStream struct {
	connect.ServerStream
	validator protovalidate.Validator
}

func (s *requestStream) Receive(msg any) error {
	if err := s.ServerStream.Receive(msg); err != nil {
		return err
	}
	if message, ok := msg.(proto.Message); ok {
		if err := s.validator.Validate(message); err != nil {
			return handleValidationError(err)
		}
	}
	return nil
}

func handleValidationError(err error) error {
	validationErr := new(protovalidate.ValidationError)
	if !errors.As(err, &validationErr) {
		return err
	}

	return connect.NewError(connect.CodeInvalidArgument, validationErr.Error()).WithCause(validationErr)
}
