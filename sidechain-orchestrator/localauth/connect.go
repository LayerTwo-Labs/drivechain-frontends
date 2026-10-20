package localauth

import (
	"context"
	"net/http"

	"connectrpc.com/connect/v2"
)

// ClientInterceptor sends the local auth token with each v2 call.
func ClientInterceptor(dir string) connect.ClientInterceptor {
	return func(next connect.ClientFunc) connect.ClientFunc {
		return func(ctx context.Context, spec connect.Spec) (connect.ClientStream, error) {
			token := TokenFromContext(ctx)
			if token == "" {
				var err error
				token, err = ReadCookie(dir)
				if err != nil {
					return nil, err
				}
			}
			if token != "" {
				info, _ := connect.CallInfoForClientContext(ctx)
				info.RequestHeader().Set(authHeader, scheme+token)
			}
			return next(ctx, spec)
		}
	}
}

// ServerInterceptor checks the local auth token for each v2 call.
func ServerInterceptor(dir string) connect.ServerInterceptor {
	return func(next connect.ServerFunc) connect.ServerFunc {
		return func(ctx context.Context, spec connect.Spec, stream connect.ServerStream) error {
			info, _ := connect.CallInfoForServerContext(ctx)
			ctx, err := verifyToken(ctx, http.Header{authHeader: {info.RequestHeader().Get(authHeader)}}, dir)
			if err != nil {
				return connect.NewError(connect.Code(err.Code()), err.Message()).WithCause(err)
			}
			return next(ctx, spec, stream)
		}
	}
}
