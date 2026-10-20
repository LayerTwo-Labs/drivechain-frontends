package enforcer

import (
	"context"
	"errors"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	connectv1 "connectrpc.com/connect"
	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/wrapperspb"

	"github.com/LayerTwo-Labs/sidesail/bitwindow/server/service"
	mainchainv1 "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1"
	validatorrpc "github.com/LayerTwo-Labs/sidesail/sidechain-orchestrator/gen/cusf/mainchain/v1/mainchainv1connect"
)

type testStreamReader struct {
	receive func() (*wrapperspb.Int32Value, error)
	close   func() error
}

func (r testStreamReader) Receive() (*wrapperspb.Int32Value, error) {
	return r.receive()
}

func (r testStreamReader) Close() error {
	return r.close()
}

func testCallInfo(t *testing.T) *connect.CallInfo {
	t.Helper()
	_, info := connect.NewClientContext(t.Context())
	return info
}

type testStreamWriter func(*wrapperspb.Int32Value) error

func (w testStreamWriter) Send(msg *wrapperspb.Int32Value) error {
	return w(msg)
}

func TestForwardStreamMessages(t *testing.T) {
	messages := []*wrapperspb.Int32Value{wrapperspb.Int32(1), wrapperspb.Int32(2), wrapperspb.Int32(3)}
	reads, closes := 0, 0
	in := testStreamReader{
		receive: func() (*wrapperspb.Int32Value, error) {
			reads++
			if reads > len(messages) {
				return nil, io.EOF
			}
			return messages[reads-1], nil
		},
		close: func() error {
			closes++
			return nil
		},
	}
	var sent []*wrapperspb.Int32Value
	out := testStreamWriter(func(msg *wrapperspb.Int32Value) error {
		sent = append(sent, msg)
		return nil
	})

	require.NoError(t, forwardStream(t.Context(), "test", testCallInfo(t), in, out))
	require.Equal(t, len(messages)+1, reads)
	require.Equal(t, 1, closes)
	require.Len(t, sent, len(messages))
	for i := range messages {
		require.Same(t, messages[i], sent[i])
	}
}

func TestForwardStreamErrors(t *testing.T) {
	receiveErr := connect.NewError(connect.CodeUnavailable, "receive failed")
	sendErr := errors.New("send failed")
	closeErr := errors.New("close failed")
	for _, tt := range []struct {
		name       string
		receiveErr error
		sendErr    error
		closeErr   error
	}{
		{name: "empty stream", receiveErr: io.EOF},
		{name: "receive fails", receiveErr: receiveErr},
		{name: "send fails", sendErr: sendErr},
		{name: "close fails", closeErr: closeErr},
		{name: "receive and close fail", receiveErr: receiveErr, closeErr: closeErr},
		{name: "send and close fail", sendErr: sendErr, closeErr: closeErr},
	} {
		t.Run(tt.name, func(t *testing.T) {
			reads, sends, closes := 0, 0, 0
			in := testStreamReader{
				receive: func() (*wrapperspb.Int32Value, error) {
					reads++
					if tt.receiveErr != nil {
						return nil, tt.receiveErr
					}
					if reads > 1 {
						return nil, io.EOF
					}
					return wrapperspb.Int32(1), nil
				},
				close: func() error {
					closes++
					return tt.closeErr
				},
			}
			out := testStreamWriter(func(*wrapperspb.Int32Value) error {
				sends++
				return tt.sendErr
			})

			err := forwardStream(t.Context(), "test", testCallInfo(t), in, out)
			require.Equal(t, 1, closes)
			switch {
			case tt.receiveErr != nil:
				require.Equal(t, 1, reads)
				require.Zero(t, sends)
			case tt.sendErr != nil:
				require.Equal(t, 1, reads)
				require.Equal(t, 1, sends)
			default:
				require.Equal(t, 2, reads)
				require.Equal(t, 1, sends)
			}
			if tt.receiveErr == io.EOF {
				require.NoError(t, err)
				return
			}
			if tt.receiveErr != nil {
				require.ErrorIs(t, err, tt.receiveErr)
				require.Equal(t, connect.CodeUnavailable, connect.CodeOf(err))
			}
			if tt.sendErr != nil {
				require.ErrorIs(t, err, tt.sendErr)
				require.ErrorContains(t, err, "forward stream message")
			}
			if tt.closeErr != nil {
				require.ErrorIs(t, err, tt.closeErr)
			}
		})
	}
}

func TestForwardStreamCancellation(t *testing.T) {
	for _, method := range []string{"receive", "send"} {
		t.Run(method, func(t *testing.T) {
			ctx, cancel := context.WithCancel(t.Context())
			defer cancel()
			entered := make(chan struct{})
			closes := 0
			in := testStreamReader{
				receive: func() (*wrapperspb.Int32Value, error) {
					if method == "receive" {
						close(entered)
						<-ctx.Done()
						return nil, ctx.Err()
					}
					return wrapperspb.Int32(1), nil
				},
				close: func() error {
					closes++
					return nil
				},
			}
			out := testStreamWriter(func(*wrapperspb.Int32Value) error {
				close(entered)
				<-ctx.Done()
				return ctx.Err()
			})
			result := make(chan error, 1)
			go func() {
				result <- forwardStream(ctx, "test", testCallInfo(t), in, out)
			}()

			select {
			case <-entered:
			case <-time.After(5 * time.Second):
				t.Fatal("the stream did not start")
			}
			cancel()
			select {
			case err := <-result:
				require.ErrorIs(t, err, context.Canceled)
				require.Equal(t, 1, closes)
			case <-time.After(5 * time.Second):
				t.Fatal("the stream did not stop")
			}
		})
	}
}

type metadataValidator struct {
	validatorrpc.UnimplementedValidatorServiceHandler
	requests chan []string
	fail     bool
}

var errUpstream = connect.NewError(connect.CodeFailedPrecondition, "upstream failed")

func (s metadataValidator) GetChainTip(ctx context.Context, _ *mainchainv1.GetChainTipRequest) (*mainchainv1.GetChainTipResponse, error) {
	info, ok := connect.CallInfoForServerContext(ctx)
	if !ok {
		return nil, errors.New("the call info is absent")
	}
	s.requests <- info.RequestHeader().Values("X-Test-Request")
	info.ResponseHeader().SetValues("X-Test-Header", []string{"header one", "header two"})
	info.ResponseTrailer().SetValues("X-Test-Trailer", []string{"trailer one", "trailer two"})
	if s.fail {
		return nil, errUpstream
	}
	return &mainchainv1.GetChainTipResponse{}, nil
}

func (s metadataValidator) SubscribeHeaderSyncProgress(ctx context.Context, _ *mainchainv1.SubscribeHeaderSyncProgressRequest, stream validatorrpc.ValidatorServiceSubscribeHeaderSyncProgressServerStream) error {
	info, ok := connect.CallInfoForServerContext(ctx)
	if !ok {
		return errors.New("the call info is absent")
	}
	s.requests <- info.RequestHeader().Values("X-Test-Request")
	info.ResponseHeader().SetValues("X-Test-Header", []string{"header one", "header two"})
	info.ResponseTrailer().SetValues("X-Test-Trailer", []string{"trailer one", "trailer two"})
	if err := stream.Send(&mainchainv1.SubscribeHeaderSyncProgressResponse{CurrentHeight: wrapperspb.UInt32(42)}); err != nil {
		return err
	}
	if s.fail {
		return errUpstream
	}
	return nil
}

func metadataProxy(t *testing.T, requests chan []string, fail bool) *httptest.Server {
	t.Helper()
	upstream := connect.NewServer()
	validatorrpc.RegisterValidatorServiceHandler(upstream, metadataValidator{requests: requests, fail: fail})
	upstreamMux := http.NewServeMux()
	connecthttp.Mount(upstreamMux, upstream, connecthttp.WithReadMaxBytes(0))
	upstreamServer := httptest.NewUnstartedServer(upstreamMux)
	upstreamServer.EnableHTTP2 = true
	upstreamServer.StartTLS()
	t.Cleanup(upstreamServer.Close)

	client := validatorrpc.NewValidatorServiceClient(connect.NewClient(
		connecthttp.NewTransport(upstreamServer.Client(), upstreamServer.URL, connecthttp.WithGRPC(), connecthttp.WithReadMaxBytes(0)),
	))
	validator := service.New("validator", func(context.Context) (validatorrpc.ValidatorServiceClient, error) {
		return client, nil
	})
	proxy := connect.NewServer()
	validatorrpc.RegisterValidatorServiceHandler(proxy, New(validator, nil, nil, nil, nil))
	mux := http.NewServeMux()
	connecthttp.Mount(mux, proxy, connecthttp.WithReadMaxBytes(0))
	server := httptest.NewServer(mux)
	t.Cleanup(server.Close)
	return server
}

func TestProxyUnaryMetadata(t *testing.T) {
	requests := make(chan []string, 1)
	server := metadataProxy(t, requests, false)
	client := connectv1.NewClient[mainchainv1.GetChainTipRequest, mainchainv1.GetChainTipResponse](
		server.Client(), server.URL+validatorrpc.ValidatorServiceGetChainTipProcedure,
	)
	req := connectv1.NewRequest(&mainchainv1.GetChainTipRequest{})
	req.Header()["X-Test-Request"] = []string{"request one", "request two"}

	resp, err := client.CallUnary(t.Context(), req)
	require.NoError(t, err)
	assert.Equal(t, []string{"request one", "request two"}, <-requests)
	assert.Equal(t, []string{"header one", "header two"}, resp.Header().Values("X-Test-Header"))
	assert.Equal(t, []string{"trailer one", "trailer two"}, resp.Trailer().Values("X-Test-Trailer"))
}

func TestProxyStreamRequestMetadata(t *testing.T) {
	requests := make(chan []string, 1)
	server := metadataProxy(t, requests, false)
	client := connectv1.NewClient[mainchainv1.SubscribeHeaderSyncProgressRequest, mainchainv1.SubscribeHeaderSyncProgressResponse](
		server.Client(), server.URL+validatorrpc.ValidatorServiceSubscribeHeaderSyncProgressProcedure,
	)
	req := connectv1.NewRequest(&mainchainv1.SubscribeHeaderSyncProgressRequest{})
	req.Header()["X-Test-Request"] = []string{"request one", "request two"}

	stream, err := client.CallServerStream(t.Context(), req)
	require.NoError(t, err)
	t.Cleanup(func() { require.NoError(t, stream.Close()) })
	require.True(t, stream.Receive())
	require.Equal(t, uint32(42), stream.Msg().GetCurrentHeight().GetValue())
	require.False(t, stream.Receive())
	require.NoError(t, stream.Err())
	assert.Equal(t, []string{"request one", "request two"}, <-requests)
}

func TestProxyUnaryErrorMetadata(t *testing.T) {
	requests := make(chan []string, 1)
	server := metadataProxy(t, requests, true)
	client := connectv1.NewClient[mainchainv1.GetChainTipRequest, mainchainv1.GetChainTipResponse](
		server.Client(), server.URL+validatorrpc.ValidatorServiceGetChainTipProcedure,
	)

	_, err := client.CallUnary(t.Context(), connectv1.NewRequest(&mainchainv1.GetChainTipRequest{}))
	<-requests
	var connectErr *connectv1.Error
	require.ErrorAs(t, err, &connectErr)
	assert.Equal(t, []string{"header one", "header two"}, connectErr.Meta().Values("X-Test-Header"))
	assert.Equal(t, []string{"trailer one", "trailer two"}, connectErr.Meta().Values("X-Test-Trailer"))
}

func TestProxyStreamResponseMetadata(t *testing.T) {
	for _, fail := range []bool{false, true} {
		t.Run(map[bool]string{false: "success", true: "failure"}[fail], func(t *testing.T) {
			requests := make(chan []string, 1)
			server := metadataProxy(t, requests, fail)
			client := connectv1.NewClient[mainchainv1.SubscribeHeaderSyncProgressRequest, mainchainv1.SubscribeHeaderSyncProgressResponse](
				server.Client(), server.URL+validatorrpc.ValidatorServiceSubscribeHeaderSyncProgressProcedure,
			)

			stream, err := client.CallServerStream(t.Context(), connectv1.NewRequest(&mainchainv1.SubscribeHeaderSyncProgressRequest{}))
			require.NoError(t, err)
			t.Cleanup(func() { require.NoError(t, stream.Close()) })
			require.True(t, stream.Receive())
			require.False(t, stream.Receive())
			<-requests
			if fail {
				assert.Equal(t, connectv1.CodeInternal, connectv1.CodeOf(stream.Err()))
			} else {
				require.NoError(t, stream.Err())
			}
			assert.Equal(t, []string{"header one", "header two"}, stream.ResponseHeader().Values("X-Test-Header"))
			assert.Equal(t, []string{"trailer one", "trailer two"}, stream.ResponseTrailer().Values("X-Test-Trailer"))
		})
	}
}
