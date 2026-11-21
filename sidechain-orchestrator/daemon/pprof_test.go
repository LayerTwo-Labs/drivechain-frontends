package daemon

import (
	"io"
	"net/http"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"
)

func TestListenPprofRefusesNonLoopbackHost(t *testing.T) {
	for _, addr := range []string{"0.0.0.0:0", ":0", "192.168.1.10:0", "example.com:0"} {
		_, err := listenPprof(t.Context(), addr, zerolog.Nop())
		require.ErrorContains(t, err, "loopback", addr)
	}
}

func TestListenPprofServesHeapOnLoopback(t *testing.T) {
	addr, err := listenPprof(t.Context(), "127.0.0.1:0", zerolog.Nop())
	require.NoError(t, err)

	resp, err := http.Get("http://" + addr.String() + "/debug/pprof/heap?debug=1")
	require.NoError(t, err)
	defer resp.Body.Close() //nolint:errcheck
	body, err := io.ReadAll(resp.Body)
	require.NoError(t, err)
	require.Equal(t, http.StatusOK, resp.StatusCode)
	require.Contains(t, string(body), "HeapInuse")
}
