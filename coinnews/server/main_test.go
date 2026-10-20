package main

import (
	"net/http/httptest"
	"testing"

	connectv1 "connectrpc.com/connect"
	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"connectrpc.com/grpcreflect/v2"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/emptypb"

	"github.com/LayerTwo-Labs/sidesail/coinnews/server/api"
	pb "github.com/LayerTwo-Labs/sidesail/coinnews/server/gen/coinnews/v1"
	"github.com/LayerTwo-Labs/sidesail/coinnews/server/gen/coinnews/v1/coinnewsv1connect"
	"github.com/LayerTwo-Labs/sidesail/coinnews/server/store"
)

func TestEnvUintUnsetReturnsFallback(t *testing.T) {
	n, err := envUint("COINNEWS_TEST_HEIGHT", 963648)
	require.NoError(t, err)
	assert.Equal(t, uint64(963648), n)
}

func TestEnvUintReadsValue(t *testing.T) {
	t.Setenv("COINNEWS_TEST_HEIGHT", "963648")
	n, err := envUint("COINNEWS_TEST_HEIGHT", 0)
	require.NoError(t, err)
	assert.Equal(t, uint64(963648), n)
}

// A set-but-unparsable value must never fall back to 0 — that silently sends
// the scanner to genesis, which is what the setting exists to avoid.
func TestEnvUintRejectsInvalidValues(t *testing.T) {
	for _, v := range []string{"96364a", "-1", "4294967296", "", " 963648", "963_648", "1.5"} {
		t.Run(v, func(t *testing.T) {
			t.Setenv("COINNEWS_TEST_HEIGHT", v)
			_, err := envUint("COINNEWS_TEST_HEIGHT", 963648)
			require.Error(t, err)
			assert.Contains(t, err.Error(), "COINNEWS_TEST_HEIGHT")
		})
	}
}

func TestEnvUintAcceptsMaxUint32(t *testing.T) {
	t.Setenv("COINNEWS_TEST_HEIGHT", "4294967295")
	n, err := envUint("COINNEWS_TEST_HEIGHT", 0)
	require.NoError(t, err)
	assert.Equal(t, uint64(4294967295), n)
}

func TestCoinNewsV1Client(t *testing.T) {
	db, err := store.Open(t.Context(), t.TempDir()+"/coinnews.db")
	require.NoError(t, err)
	t.Cleanup(func() { require.NoError(t, db.Close()) })
	server := httptest.NewUnstartedServer(corsMiddleware(newMux(&api.Handler{DB: db})))
	server.EnableHTTP2 = true
	server.StartTLS()
	t.Cleanup(server.Close)

	for _, protocol := range []struct {
		name    string
		options []connectv1.ClientOption
	}{
		{name: "Connect"},
		{name: "JSON", options: []connectv1.ClientOption{connectv1.WithProtoJSON()}},
		{name: "gRPC", options: []connectv1.ClientOption{connectv1.WithGRPC()}},
		{name: "gRPCWeb", options: []connectv1.ClientOption{connectv1.WithGRPCWeb()}},
	} {
		t.Run(protocol.name, func(t *testing.T) {
			client := connectv1.NewClient[emptypb.Empty, pb.ListTopicsResponse](
				server.Client(), server.URL+coinnewsv1connect.CoinNewsServiceListTopicsProcedure, protocol.options...,
			)
			response, err := client.CallUnary(t.Context(), connectv1.NewRequest(&emptypb.Empty{}))
			require.NoError(t, err)
			assert.Empty(t, response.Msg.Topics)
			assert.Equal(t, "*", response.Header().Get("Access-Control-Allow-Origin"))

			author := connectv1.NewClient[pb.ListByAuthorRequest, pb.ListByAuthorResponse](
				server.Client(), server.URL+coinnewsv1connect.CoinNewsServiceListByAuthorProcedure, protocol.options...,
			)
			_, err = author.CallUnary(t.Context(), connectv1.NewRequest(&pb.ListByAuthorRequest{AuthorXpkHex: "invalid"}))
			var rpcError *connectv1.Error
			require.ErrorAs(t, err, &rpcError)
			assert.Equal(t, connectv1.CodeInvalidArgument, rpcError.Code())
			assert.Equal(t, "author_xpk_hex must be 32 bytes hex", rpcError.Message())
		})
	}

	reflection := grpcreflect.NewClient(connect.NewClient(connecthttp.NewTransport(server.Client(), server.URL)))
	stream := reflection.NewStream(t.Context())
	names, err := stream.ListServices()
	require.NoError(t, err)
	require.Len(t, names, 1)
	assert.Equal(t, coinnewsv1connect.CoinNewsServiceName, string(names[0]))
	err = stream.Close()
	require.NoError(t, err)
}
