package localauth

import (
	"context"
	"net/http"
	"testing"

	"connectrpc.com/connect"
)

func TestCookieRoundTrip(t *testing.T) {
	dir := t.TempDir()

	if got, _ := ReadCookie(dir); got != "" {
		t.Fatalf("absent cookie should read empty, got %q", got)
	}

	token, err := WriteCookie(dir)
	if err != nil {
		t.Fatal(err)
	}
	if token == "" {
		t.Fatal("token should be non-empty")
	}

	got, err := ReadCookie(dir)
	if err != nil {
		t.Fatal(err)
	}
	if got != token {
		t.Fatalf("read %q, wrote %q", got, token)
	}

	if err := RemoveCookie(dir); err != nil {
		t.Fatal(err)
	}
	if got, _ := ReadCookie(dir); got != "" {
		t.Fatalf("removed cookie should read empty, got %q", got)
	}
	// Removing an absent cookie is fine.
	if err := RemoveCookie(dir); err != nil {
		t.Fatalf("removing absent cookie should be a no-op, got %v", err)
	}
}

func TestContextCarrier(t *testing.T) {
	ctx := context.Background()
	if got := TokenFromContext(ctx); got != "" {
		t.Fatalf("empty ctx should carry no token, got %q", got)
	}
	ctx = WithToken(ctx, "abc")
	if got := TokenFromContext(ctx); got != "abc" {
		t.Fatalf("got %q, want abc", got)
	}
}

func TestChallengeResponse(t *testing.T) {
	token := "secret-token"
	nonce := "nonce"
	resp := ChallengeResponse(token, nonce)

	if resp == "" {
		t.Fatal("empty challenge response")
	}
	if !VerifyChallengeResponse(token, nonce, resp) {
		t.Fatal("expected challenge response to verify")
	}
	if VerifyChallengeResponse(token, nonce, ChallengeResponse("other-token", nonce)) {
		t.Fatal("response for another token verified")
	}
	if VerifyChallengeResponse(token, nonce, ChallengeResponse(token, "other-nonce")) {
		t.Fatal("response for another nonce verified")
	}
}

func TestAttachPrefersContextThenCookie(t *testing.T) {
	dir := t.TempDir()
	token, err := WriteCookie(dir)
	if err != nil {
		t.Fatal(err)
	}

	// No ctx token -> falls back to the cookie.
	h := http.Header{}
	attach(context.Background(), h, dir)
	if got := h.Get(authHeader); got != scheme+token {
		t.Fatalf("cookie fallback: got %q, want %q", got, scheme+token)
	}

	// ctx token wins over the cookie.
	h = http.Header{}
	attach(WithToken(context.Background(), "ctx-token"), h, dir)
	if got := h.Get(authHeader); got != scheme+"ctx-token" {
		t.Fatalf("ctx token: got %q, want %q", got, scheme+"ctx-token")
	}

	// No cookie and no ctx token -> no header at all. The server side will
	// reject this when a non-empty auth dir is configured.
	h = http.Header{}
	attach(context.Background(), h, t.TempDir())
	if got := h.Get(authHeader); got != "" {
		t.Fatalf("missing cookie: expected no header, got %q", got)
	}
}

func TestVerify(t *testing.T) {
	dir := t.TempDir()

	// Empty dir is the explicit insecure/test no-op.
	if _, err := verify(context.Background(), http.Header{}, ""); err != nil {
		t.Fatalf("empty dir should pass, got %v", err)
	}

	// Non-empty dir with no cookie fails closed.
	if _, err := verify(context.Background(), http.Header{}, dir); connect.CodeOf(err) != connect.CodeUnauthenticated {
		t.Fatalf("missing cookie should be rejected with Unauthenticated, got %v", err)
	}

	token, err := WriteCookie(dir)
	if err != nil {
		t.Fatal(err)
	}

	// Missing token -> rejected.
	if _, err := verify(context.Background(), http.Header{}, dir); err == nil {
		t.Fatal("missing token should be rejected")
	}

	// Wrong token -> rejected.
	wrong := http.Header{}
	wrong.Set(authHeader, scheme+"nope")
	if _, err := verify(context.Background(), wrong, dir); err == nil {
		t.Fatal("wrong token should be rejected")
	}

	// Correct token -> passes and injects the token into ctx.
	ok := http.Header{}
	ok.Set(authHeader, scheme+token)
	ctx, err := verify(context.Background(), ok, dir)
	if err != nil {
		t.Fatalf("correct token should pass, got %v", err)
	}
	if got := TokenFromContext(ctx); got != token {
		t.Fatalf("verified token not injected into ctx: got %q", got)
	}
}

// attach then verify is the full client->server round trip.
func TestAttachThenVerifyRoundTrip(t *testing.T) {
	dir := t.TempDir()
	if _, err := WriteCookie(dir); err != nil {
		t.Fatal(err)
	}

	h := http.Header{}
	attach(context.Background(), h, dir) // client side
	if _, err := verify(context.Background(), h, dir); err != nil {
		t.Fatalf("round trip should authenticate, got %v", err)
	}
}
