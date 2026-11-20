package api

import (
	"io"
	"net"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"

	"github.com/rs/zerolog"
	"github.com/stretchr/testify/require"

	orchestrator "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator"
	pb "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/orchestrator/v1"
)

func TestCoreRawCallUsesTheRPCConnectHost(t *testing.T) {
	var host string
	core := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		host = r.Host
		_, _ = w.Write([]byte(`{"result":{"fees":{"base":0.0000276}},"error":null,"id":"drivechaind"}`))
	}))
	t.Cleanup(core.Close)
	coreHost, port, err := net.SplitHostPort(core.Listener.Addr().String())
	require.NoError(t, err)

	bitwindowDir := t.TempDir()
	conf := "chain=signet\n[signet]\nrpcuser=u\nrpcpassword=p\nrpcconnect=" + coreHost + "\nrpcport=" + port + "\n"
	require.NoError(t, os.WriteFile(filepath.Join(bitwindowDir, "bitwindow-bitcoin.conf"), []byte(conf), 0o644))
	orch := orchestrator.New(t.TempDir(), "signet", bitwindowDir, []orchestrator.BinaryConfig{}, zerolog.New(io.Discard))

	resp, err := NewHandler(orch).CoreRawCall(t.Context(), &pb.CoreRawCallRequest{Method: "getmempoolentry", ParamsJson: `["aa"]`})
	require.NoError(t, err)
	require.JSONEq(t, `{"fees":{"base":0.0000276}}`, resp.ResultJson)
	require.Equal(t, net.JoinHostPort(coreHost, port), host)
}
