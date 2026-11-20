package chaindata

import (
	"context"
	"strings"

	"connectrpc.com/connect"
	"google.golang.org/protobuf/proto"
)

// Interceptor answers the repeated reads of the btc-buf Core proxy from the
// cache, and marks the wallet reads as stale after each other call.
func (e *Engine) Interceptor() connect.Interceptor {
	return connect.UnaryInterceptorFunc(func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			procedure := req.Spec().Procedure
			method := strings.ToLower(procedure[strings.LastIndex(procedure, "/")+1:])
			if !readOnly(method) {
				res, err := next(ctx, req)
				e.Fire(EventWrite)
				return res, err
			}
			msg, ok := req.Any().(proto.Message)
			if !ok {
				return next(ctx, req)
			}
			key, err := proto.MarshalOptions{Deterministic: true}.Marshal(msg)
			if err != nil {
				return next(ctx, req)
			}
			res, err := e.responses.Get(ctx, method, procedure+"\x00"+string(key), func(ctx context.Context) (any, error) {
				return next(ctx, req)
			})
			if err != nil {
				return nil, err
			}
			return res.(connect.AnyResponse), nil
		}
	})
}
