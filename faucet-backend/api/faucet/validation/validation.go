package validation

import (
	"context"
	"errors"
	"fmt"
	"sync"

	"connectrpc.com/connect"
	"github.com/bufbuild/protovalidate-go"
	"google.golang.org/protobuf/proto"
)

var (
	validatorOnce sync.Once
	validatorErr  error
	validator     *protovalidate.Validator
)

func Validator() (*protovalidate.Validator, error) {
	validatorOnce.Do(func() {
		validator, validatorErr = protovalidate.New()
	})
	if validatorErr != nil {
		return nil, fmt.Errorf("setup protovalidate: %w", validatorErr)
	}
	return validator, nil

}

// Interceptor returns a Connect server interceptor that validates incoming requests,
// returning an error if they don't comply.
//
// Docs: https://github.com/bufbuild/protovalidate
func Interceptor() connect.UnaryInterceptorFunc {
	return func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			validator, err := Validator()
			if err != nil {
				return nil, err
			}

			if msg, ok := req.Any().(proto.Message); ok {
				if err := validator.Validate(msg); err != nil {
					return nil, handleValidationError(err)
				}
			}

			return next(ctx, req)
		}
	}
}

func handleValidationError(err error) error {
	validationErr := new(protovalidate.ValidationError)
	if !errors.As(err, &validationErr) {
		return err
	}

	return connect.NewError(connect.CodeInvalidArgument, validationErr)
}
