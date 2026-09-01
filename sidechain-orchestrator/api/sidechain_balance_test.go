package api

import (
	"context"
	"net"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"

	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
)

// TestFetchSidechainBalanceZSide feeds the exact balance JSON a zside node
// emits and checks it is not silently read as zero.
func TestFetchSidechainBalanceZSide(t *testing.T) {
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_, _ = w.Write([]byte(`{"result":{
			"total_shielded_sats": 60000,
			"total_transparent_sats": 40000,
			"available_shielded_sats": 50000,
			"available_transparent_sats": 30000
		}}`))
	}))
	defer srv.Close()

	port := srv.Listener.Addr().(*net.TCPAddr).Port
	confirmed, pending, err := (&Handler{}).fetchSidechainBalance(
		context.Background(), pb.BinaryType_BINARY_TYPE_ZSIDE, port,
	)
	require.NoError(t, err)
	assert.Equal(t, int64(80_000), confirmed)
	assert.Equal(t, int64(20_000), pending)
}
