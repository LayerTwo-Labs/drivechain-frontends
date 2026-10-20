package localauth_test

import (
	"context"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	connectv1 "connectrpc.com/connect"
	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/wrapperspb"

	"github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/localauth"
)

func authServer(t *testing.T, dir string) *httptest.Server {
	t.Helper()
	server := connect.NewServer(localauth.ServerInterceptor(dir))
	for _, streamType := range []connect.StreamType{connect.StreamTypeUnary, connect.StreamTypeServer} {
		server.Register(connect.Method{
			Spec: connect.Spec{Procedure: authProcedure(streamType), StreamType: streamType},
			Handler: func(ctx context.Context, _ connect.Spec, stream connect.ServerStream) error {
				message := new(wrapperspb.StringValue)
				if err := stream.Receive(message); err != nil {
					return err
				}
				info, _ := connect.CallInfoForServerContext(ctx)
				info.ResponseHeader().Set("X-Test-Header", info.RequestHeader().Get("X-Test-Header"))
				info.ResponseTrailer().Set("X-Test-Trailer", "complete")
				if dir != "" && localauth.TokenFromContext(ctx) == "" {
					return connect.NewError(connect.CodeInternal, "the auth token is absent")
				}
				if err := stream.Send(message); err != nil {
					return err
				}
				if streamType == connect.StreamTypeServer {
					return stream.Send(wrapperspb.String("second"))
				}
				return nil
			},
		})
	}
	mux := http.NewServeMux()
	connecthttp.Mount(mux, server, connecthttp.WithReadMaxBytes(0))
	httpServer := httptest.NewUnstartedServer(mux)
	httpServer.EnableHTTP2 = true
	httpServer.StartTLS()
	t.Cleanup(httpServer.Close)
	return httpServer
}

func authProcedure(streamType connect.StreamType) string {
	if streamType == connect.StreamTypeServer {
		return "/localauth.test.v2.EchoService/Stream"
	}
	return "/localauth.test.v2.EchoService/Echo"
}

func TestV1ClientsUseV2Auth(t *testing.T) {
	for _, protocol := range []struct {
		name    string
		options []connectv1.ClientOption
	}{
		{name: "Connect"},
		{name: "gRPC", options: []connectv1.ClientOption{connectv1.WithGRPC()}},
		{name: "gRPC-Web", options: []connectv1.ClientOption{connectv1.WithGRPCWeb()}},
	} {
		t.Run(protocol.name, func(t *testing.T) {
			dir := t.TempDir()
			_, err := localauth.WriteCookie(dir)
			require.NoError(t, err)
			server := authServer(t, dir)

			for _, authorized := range []bool{false, true} {
				options := append([]connectv1.ClientOption{}, protocol.options...)
				if authorized {
					options = append(options, connectv1.WithInterceptors(localauth.Interceptor(dir)))
				}
				client := connectv1.NewClient[wrapperspb.StringValue, wrapperspb.StringValue](
					server.Client(), server.URL+authProcedure(connect.StreamTypeUnary), options...,
				)
				request := connectv1.NewRequest(wrapperspb.String("first"))
				request.Header().Set("X-Test-Header", "metadata")
				response, err := client.CallUnary(t.Context(), request)
				if !authorized {
					require.Equal(t, connectv1.CodeUnauthenticated, connectv1.CodeOf(err), "%v", err)
				} else {
					require.NoError(t, err)
					require.Equal(t, "first", response.Msg.Value)
					require.Equal(t, "metadata", response.Header().Get("X-Test-Header"))
					require.Equal(t, "complete", response.Trailer().Get("X-Test-Trailer"))
				}

				client = connectv1.NewClient[wrapperspb.StringValue, wrapperspb.StringValue](
					server.Client(), server.URL+authProcedure(connect.StreamTypeServer), options...,
				)
				request = connectv1.NewRequest(wrapperspb.String("first"))
				request.Header().Set("X-Test-Header", "metadata")
				stream, err := client.CallServerStream(t.Context(), request)
				if !authorized {
					if err == nil {
						require.False(t, stream.Receive())
						err = stream.Err()
						require.NoError(t, stream.Close())
					}
					require.Equal(t, connectv1.CodeUnauthenticated, connectv1.CodeOf(err), "%v", err)
					continue
				}
				require.NoError(t, err)
				var messages []string
				for stream.Receive() {
					messages = append(messages, stream.Msg().Value)
				}
				require.NoError(t, stream.Err())
				require.NoError(t, stream.Close())
				require.Equal(t, []string{"first", "second"}, messages)
				require.Equal(t, "metadata", stream.ResponseHeader().Get("X-Test-Header"))
				require.Equal(t, "complete", stream.ResponseTrailer().Get("X-Test-Trailer"))
			}
		})
	}
}

func TestV2ClientAuth(t *testing.T) {
	dir := t.TempDir()
	token, err := localauth.WriteCookie(dir)
	require.NoError(t, err)
	server := authServer(t, dir)
	for _, tt := range []struct {
		name  string
		dir   string
		token string
		code  connect.Code
	}{
		{name: "the client reads the cookie", dir: dir},
		{name: "the context holds the token", token: token},
		{name: "the token is absent", code: connect.CodeUnauthenticated},
		{name: "the context token is wrong", dir: dir, token: "wrong", code: connect.CodeUnauthenticated},
	} {
		t.Run(tt.name, func(t *testing.T) {
			client := connect.NewClient(
				connecthttp.NewTransport(server.Client(), server.URL, connecthttp.WithReadMaxBytes(0)),
				localauth.ClientInterceptor(tt.dir),
			)
			for _, streamType := range []connect.StreamType{connect.StreamTypeUnary, connect.StreamTypeServer} {
				ctx, info := connect.NewClientContext(localauth.WithToken(t.Context(), tt.token))
				info.RequestHeader().Set("X-Test-Header", "metadata")
				spec := connect.Spec{Procedure: authProcedure(streamType), StreamType: streamType}
				if streamType == connect.StreamTypeUnary {
					response := new(wrapperspb.StringValue)
					err := client.CallUnary(ctx, spec, wrapperspb.String("first"), response)
					if tt.code != 0 {
						require.Equal(t, tt.code, connect.CodeOf(err))
						continue
					}
					require.NoError(t, err)
					require.Equal(t, "first", response.Value)
				} else {
					stream, err := client.CallServerStream(ctx, spec, wrapperspb.String("first"))
					require.NoError(t, err)
					response := new(wrapperspb.StringValue)
					err = stream.Receive(response)
					if tt.code != 0 {
						require.Equal(t, tt.code, connect.CodeOf(err))
						require.NoError(t, stream.Close())
						continue
					}
					require.NoError(t, err)
					require.Equal(t, "first", response.Value)
					require.NoError(t, stream.Receive(response))
					require.Equal(t, "second", response.Value)
					require.ErrorIs(t, stream.Receive(response), io.EOF)
					require.NoError(t, stream.Close())
				}
				require.Equal(t, "metadata", info.ResponseHeader().Get("X-Test-Header"))
				require.Equal(t, "complete", info.ResponseTrailer().Get("X-Test-Trailer"))
			}
		})
	}
}

func TestV2AuthWithNoCookie(t *testing.T) {
	for _, test := range []struct {
		name string
		dir  string
		code connect.Code
	}{
		{name: "auth is disabled"},
		{name: "the server cookie is absent", dir: t.TempDir(), code: connect.CodeUnauthenticated},
	} {
		t.Run(test.name, func(t *testing.T) {
			server := authServer(t, test.dir)
			client := connect.NewClient(
				connecthttp.NewTransport(server.Client(), server.URL, connecthttp.WithReadMaxBytes(0)),
				localauth.ClientInterceptor(test.dir),
			)
			err := client.CallUnary(t.Context(), connect.Spec{Procedure: authProcedure(connect.StreamTypeUnary)},
				wrapperspb.String("first"), new(wrapperspb.StringValue))
			if test.code != 0 {
				require.Equal(t, test.code, connect.CodeOf(err))
			} else {
				require.NoError(t, err)
			}
		})
	}
}

func TestV2KeepsTheReadLimit(t *testing.T) {
	server := authServer(t, "")
	client := connect.NewClient(connecthttp.NewTransport(server.Client(), server.URL, connecthttp.WithReadMaxBytes(0)))
	message := strings.Repeat("a", 5<<20)
	response := new(wrapperspb.StringValue)
	err := client.CallUnary(t.Context(), connect.Spec{Procedure: authProcedure(connect.StreamTypeUnary)},
		wrapperspb.String(message), response)
	require.NoError(t, err)
	require.Equal(t, message, response.Value)
}
