// Package localauth is a bitcoin-cookie-style local auth shared by orchestratord
// and bitwindowd. The orchestrator writes a random token to
// <bitwindowDir>/.auth.cookie (0600) — beside wallet.json — and every RPC must
// carry it. A process that can read that file (same OS user) is trusted; a
// browser doing DNS-rebinding, a remote client, or another user cannot read it
// and is rejected. A non-empty cookie directory means auth is required: if the
// cookie is missing, inbound RPCs fail closed. Pass an empty directory only for
// explicit insecure/test no-op behavior.
//
// The token rides in context.Context (see WithToken / TokenFromContext), and a
// single connect.Interceptor wires both ends: on a client it attaches the token
// (from ctx, else the cookie); on a server it validates the header and injects
// the token into ctx. Tests build an authed context with
// localauthtest.AuthContext(t, dir).
package localauth

import (
	"context"
	"crypto/hmac"
	"crypto/rand"
	"crypto/sha256"
	"crypto/subtle"
	"encoding/hex"
	"errors"
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"strings"

	"connectrpc.com/connect"
)

const (
	// CookieFile is the cookie filename, kept beside wallet.json.
	CookieFile = ".auth.cookie"
	authHeader = "Authorization"
	scheme     = "Bearer "

	// TokenRejectedMessage is the exact error returned when a presented token
	// doesn't match the cookie — the client's signal to refetch and retry.
	// Matched verbatim by the Flutter interceptor; keep the two in sync.
	TokenRejectedMessage = "token invalid"
)

// --- cookie file -----------------------------------------------------------

// CookiePath returns the cookie path inside the bitwindow data directory.
func CookiePath(dir string) string { return filepath.Join(dir, CookieFile) }

// WriteCookie generates a fresh 32-byte random token and atomically writes it
// 0600 to dir/.auth.cookie, returning the token. The orchestrator calls this
// once at startup when local auth is enabled.
func WriteCookie(dir string) (string, error) {
	buf := make([]byte, 32)
	if _, err := rand.Read(buf); err != nil {
		return "", fmt.Errorf("generate auth token: %w", err)
	}
	token := hex.EncodeToString(buf)
	path := CookiePath(dir)
	tmp := path + ".tmp"
	if err := os.MkdirAll(dir, 0700); err != nil {
		return "", fmt.Errorf("create auth cookie dir: %w", err)
	}
	if err := os.WriteFile(tmp, []byte(token), 0600); err != nil {
		return "", fmt.Errorf("write auth cookie: %w", err)
	}
	if err := os.Rename(tmp, path); err != nil {
		return "", fmt.Errorf("install auth cookie: %w", err)
	}
	return token, nil
}

// RemoveCookie deletes the cookie. Absent file is not an error.
func RemoveCookie(dir string) error {
	if err := os.Remove(CookiePath(dir)); err != nil && !os.IsNotExist(err) {
		return err
	}
	return nil
}

// ReadCookie returns the token, or "" (no error) when the cookie is absent.
func ReadCookie(dir string) (string, error) {
	if dir == "" {
		return "", nil
	}
	b, err := os.ReadFile(CookiePath(dir))
	if os.IsNotExist(err) {
		return "", nil
	}
	if err != nil {
		return "", fmt.Errorf("read auth cookie: %w", err)
	}
	return strings.TrimSpace(string(b)), nil
}

// --- context carrier -------------------------------------------------------

type tokenKey struct{}

// WithToken returns a context carrying the bearer token. The client side of
// Interceptor sends it; the server side injects the validated token so handlers
// can read it back with TokenFromContext.
func WithToken(ctx context.Context, token string) context.Context {
	return context.WithValue(ctx, tokenKey{}, token)
}

// TokenFromContext returns the token carried by ctx, or "".
func TokenFromContext(ctx context.Context) string {
	token, _ := ctx.Value(tokenKey{}).(string)
	return token
}

// ChallengeResponse returns a deterministic proof that the responder knows the
// local-auth token without sending the token itself.
func ChallengeResponse(token, nonce string) string {
	mac := hmac.New(sha256.New, []byte(token))
	_, _ = mac.Write([]byte(nonce))
	return hex.EncodeToString(mac.Sum(nil))
}

// VerifyChallengeResponse checks a challenge response in constant time.
func VerifyChallengeResponse(token, nonce, response string) bool {
	want := ChallengeResponse(token, nonce)
	return subtle.ConstantTimeCompare([]byte(response), []byte(want)) == 1
}

// --- connect interceptor ---------------------------------------------------

// Interceptor authenticates local RPCs against the cookie at dir. One value
// serves both roles: on a client call it attaches the bearer token (from ctx if
// present, else the cookie); on a server call it requires the token to match
// the cookie and injects it into ctx. When dir is non-empty and the cookie is
// missing, server calls fail closed. Passing an empty dir is the explicit no-op
// mode for tests/insecure tooling. Add it to both client and handler options:
//
//	ic := localauth.Interceptor(dir)
//	connect.WithInterceptors(ic) // on NewXxxServiceClient and NewXxxServiceHandler
func Interceptor(dir string) connect.Interceptor { return interceptor{dir: dir} }

// Middleware applies the same bearer-token check as the server side of
// Interceptor to a raw http.Handler (non-Connect routes). Empty dir is the
// explicit no-op mode; a missing or mismatched token fails closed with 401.
func Middleware(dir string, next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if _, err := verify(r.Context(), r.Header, dir); err != nil {
			http.Error(w, "unauthorized", http.StatusUnauthorized)
			return
		}
		next.ServeHTTP(w, r)
	})
}

type interceptor struct{ dir string }

func (i interceptor) WrapUnary(next connect.UnaryFunc) connect.UnaryFunc {
	return func(ctx context.Context, req connect.AnyRequest) (connect.AnyResponse, error) {
		if req.Spec().IsClient {
			attach(ctx, req.Header(), i.dir)
			return next(ctx, req)
		}
		ctx, err := verify(ctx, req.Header(), i.dir)
		if err != nil {
			return nil, err
		}
		return next(ctx, req)
	}
}

func (i interceptor) WrapStreamingClient(next connect.StreamingClientFunc) connect.StreamingClientFunc {
	return func(ctx context.Context, spec connect.Spec) connect.StreamingClientConn {
		conn := next(ctx, spec)
		attach(ctx, conn.RequestHeader(), i.dir)
		return conn
	}
}

func (i interceptor) WrapStreamingHandler(next connect.StreamingHandlerFunc) connect.StreamingHandlerFunc {
	return func(ctx context.Context, conn connect.StreamingHandlerConn) error {
		ctx, err := verify(ctx, conn.RequestHeader(), i.dir)
		if err != nil {
			return err
		}
		return next(ctx, conn)
	}
}

// attach adds the bearer token to outgoing headers: the ctx token if set (e.g.
// from localauthtest.AuthContext), otherwise the cookie. No token ⇒ no header.
func attach(ctx context.Context, h http.Header, dir string) {
	token := TokenFromContext(ctx)
	if token == "" {
		token, _ = ReadCookie(dir)
	}
	if token != "" {
		h.Set(authHeader, scheme+token)
	}
}

// verify checks an inbound header against the cookie. Empty dir ⇒ pass
// (explicit insecure/test mode). Missing cookie, missing header, or mismatch ⇒
// CodeUnauthenticated. Match ⇒ pass with the token injected into ctx.
func verify(ctx context.Context, h http.Header, dir string) (context.Context, error) {
	if dir == "" {
		return ctx, nil
	}
	want, err := ReadCookie(dir)
	if err != nil {
		return ctx, connect.NewError(connect.CodeInternal, fmt.Errorf("read auth cookie: %w", err))
	}
	if want == "" {
		return ctx, connect.NewError(connect.CodeUnauthenticated, errors.New("local auth cookie is missing"))
	}
	got := strings.TrimPrefix(h.Get(authHeader), scheme)
	if subtle.ConstantTimeCompare([]byte(got), []byte(want)) != 1 {
		return ctx, connect.NewError(connect.CodeUnauthenticated, errors.New(TokenRejectedMessage))
	}
	return WithToken(ctx, want), nil
}
