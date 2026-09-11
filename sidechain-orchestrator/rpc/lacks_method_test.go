package rpc

import (
	"context"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestLacksMethod(t *testing.T) {
	for name, tc := range map[string]struct {
		body string
		want bool
	}{
		"method not found": {`{"jsonrpc":"2.0","id":1,"error":{"code":-32601,"message":"Method not found"}}`, true},
		"other rpc error":  {`{"jsonrpc":"2.0","id":1,"error":{"code":-32603,"message":"Internal error"}}`, false},
		"malformed reply":  {`not json`, false},
	} {
		t.Run(name, func(t *testing.T) {
			srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
				_, _ = w.Write([]byte(tc.body))
			}))
			defer srv.Close()

			err := clientFor(t, srv).Call(context.Background(), "mainchain_sync_progress", nil, nil)
			assert.Error(t, err)
			assert.Equal(t, tc.want, LacksMethod(err))
		})
	}
}
