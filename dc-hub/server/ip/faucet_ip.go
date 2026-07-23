package faucet_ip

import (
	"context"
	"errors"
	"fmt"
	"net/http"
	"net/netip"
	"strings"

	"connectrpc.com/connect"
	"github.com/gorilla/mux"
)

type (
	ctxKeyType int
	ipPromise  struct {
		err error
		ip  IP
	}
)

const ctxKeyValue ctxKeyType = iota + 1

type IP struct {
	IP netip.Addr
}

func FromContext(ctx context.Context) (IP, error) {
	promise, ok := ctx.Value(ctxKeyValue).(*ipPromise)
	if !ok {
		return IP{}, errors.New("did not find IP address in context")
	}
	if promise == nil {
		return IP{}, errors.New("IP was wiped from context")
	}
	return promise.ip, promise.err
}

func Middleware() mux.MiddlewareFunc {
	return func(handler http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			ip, err := ParseIP(r.Header, r.RemoteAddr)
			if err != nil {
				http.Error(w, fmt.Sprintf("Failed to parse IP: %v", err), http.StatusBadRequest)
				return
			}
			ctx := context.WithValue(r.Context(), ctxKeyValue, &ipPromise{ip: IP{IP: ip}})
			r = r.WithContext(ctx)
			handler.ServeHTTP(w, r)
		})
	}
}

func Interceptor() connect.Interceptor {
	return connect.UnaryInterceptorFunc(func(next connect.UnaryFunc) connect.UnaryFunc {
		return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
			ip, err := ParseIP(req.Header(), req.Peer().Addr)
			if err != nil {
				return nil, connect.NewError(connect.CodeInvalidArgument, fmt.Errorf("failed to parse IP: %w", err))
			}
			ctx = context.WithValue(ctx, ctxKeyValue, &ipPromise{ip: IP{IP: ip}})
			return next(ctx, req)
		}
	})
}

func ParseIP(headers http.Header, fallback string) (netip.Addr, error) {
	potentialHeaders := []string{"x-faucet-ip", "X-Forwarded-For"}

	for _, header := range potentialHeaders {
		forwarded := headers.Get(header)
		if forwarded != "" {
			allForwarded := strings.Split(forwarded, ",")
			if len(allForwarded) >= 1 {
				forwarded = allForwarded[0]
			}
			parsed, err := netip.ParseAddr(forwarded)
			if err == nil {
				return parsed, nil
			}
		}
	}

	parsed, err := netip.ParseAddrPort(fallback)
	if err != nil {
		return netip.Addr{}, fmt.Errorf("parse fallback address: %w", err)
	}

	return parsed.Addr(), nil
}
