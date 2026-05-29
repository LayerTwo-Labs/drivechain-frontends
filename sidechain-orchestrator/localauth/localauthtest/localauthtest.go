// Package localauthtest provides test helpers for localauth, mirroring the
// bbtest.AuthContext pattern: build a context carrying a valid local-auth token
// so a test can make authenticated client calls.
//
//	ctx := localauthtest.AuthContext(t, bitwindowDir)
//	resp, err := client.GetWalletSeed(ctx, req) // authenticates via the cookie
package localauthtest

import (
	"context"
	"testing"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/localauth"
)

// AuthContext returns a context carrying the local-auth token from the cookie
// at dir, for making authenticated client calls in tests. Fails the test if the
// cookie cannot be read. When no cookie exists the token is empty, which is the
// correct "auth disabled" state.
func AuthContext(t testing.TB, dir string) context.Context {
	t.Helper()
	token, err := localauth.ReadCookie(dir)
	if err != nil {
		t.Fatalf("localauthtest: read cookie in %s: %v", dir, err)
	}
	return localauth.WithToken(context.Background(), token)
}
