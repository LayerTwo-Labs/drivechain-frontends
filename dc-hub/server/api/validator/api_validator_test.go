package validator

import (
	"context"
	"errors"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"

	"connectrpc.com/connect/v2"
	"connectrpc.com/connect/v2/connecthttp"
	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"google.golang.org/protobuf/types/known/wrapperspb"

	"github.com/LayerTwo-Labs/sidesail/dc-hub/server/connector"
	mainchainv1 "github.com/LayerTwo-Labs/sidesail/dc-hub/server/gen/cusf/mainchain/v1"
	"github.com/LayerTwo-Labs/sidesail/dc-hub/server/gen/cusf/mainchain/v1/mainchainv1connect"
)

type metadataValidator struct {
	mainchainv1connect.UnimplementedValidatorServiceHandler
	fail bool
}

func setTestMetadata(ctx context.Context) error {
	info, ok := connect.CallInfoForServerContext(ctx)
	if !ok {
		return errors.New("the call info is absent")
	}
	info.ResponseHeader().SetValues("X-Test-Header", []string{"header one", "header two"})
	info.ResponseTrailer().SetValues("X-Test-Trailer", []string{"trailer one", "trailer two"})
	return nil
}

func (s metadataValidator) GetChainTip(ctx context.Context, _ *mainchainv1.GetChainTipRequest) (*mainchainv1.GetChainTipResponse, error) {
	if err := setTestMetadata(ctx); err != nil {
		return nil, err
	}
	if s.fail {
		return nil, connect.NewError(connect.CodeFailedPrecondition, "upstream failed")
	}
	return &mainchainv1.GetChainTipResponse{}, nil
}

func (s metadataValidator) SubscribeHeaderSyncProgress(ctx context.Context, _ *mainchainv1.SubscribeHeaderSyncProgressRequest, stream mainchainv1connect.ValidatorServiceSubscribeHeaderSyncProgressServerStream) error {
	if err := setTestMetadata(ctx); err != nil {
		return err
	}
	if err := stream.Send(&mainchainv1.SubscribeHeaderSyncProgressResponse{CurrentHeight: wrapperspb.UInt32(42)}); err != nil {
		return err
	}
	if s.fail {
		return connect.NewError(connect.CodeFailedPrecondition, "upstream failed")
	}
	return nil
}

func serve(t *testing.T, handler mainchainv1connect.ValidatorServiceHandler) mainchainv1connect.ValidatorServiceClient {
	t.Helper()
	server := connect.NewServer()
	mainchainv1connect.RegisterValidatorServiceHandler(server, handler)
	mux := http.NewServeMux()
	connecthttp.Mount(mux, server)
	httpServer := httptest.NewServer(mux)
	t.Cleanup(httpServer.Close)
	return mainchainv1connect.NewValidatorServiceClient(connect.NewClient(connecthttp.NewTransport(httpServer.Client(), httpServer.URL)))
}

func metadataProxy(t *testing.T, fail bool) mainchainv1connect.ValidatorServiceClient {
	t.Helper()
	upstream := serve(t, metadataValidator{fail: fail})
	validator := connector.New("validator", func(context.Context) (mainchainv1connect.ValidatorServiceClient, error) {
		return upstream, nil
	})
	return serve(t, New(validator))
}

func assertTestMetadata(t *testing.T, info *connect.CallInfo) {
	t.Helper()
	assert.Equal(t, []string{"header one", "header two"}, info.ResponseHeader().Values("X-Test-Header"))
	assert.Equal(t, []string{"trailer one", "trailer two"}, info.ResponseTrailer().Values("X-Test-Trailer"))
}

func TestProxyUnaryMetadata(t *testing.T) {
	for _, fail := range []bool{false, true} {
		t.Run(map[bool]string{false: "success", true: "failure"}[fail], func(t *testing.T) {
			ctx, info := connect.NewClientContext(t.Context())
			_, err := metadataProxy(t, fail).GetChainTip(ctx, &mainchainv1.GetChainTipRequest{})
			if fail {
				assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
			} else {
				require.NoError(t, err)
			}
			assertTestMetadata(t, info)
		})
	}
}

func TestProxyStreamMetadata(t *testing.T) {
	for _, fail := range []bool{false, true} {
		t.Run(map[bool]string{false: "success", true: "failure"}[fail], func(t *testing.T) {
			ctx, info := connect.NewClientContext(t.Context())
			stream, err := metadataProxy(t, fail).SubscribeHeaderSyncProgress(ctx, &mainchainv1.SubscribeHeaderSyncProgressRequest{})
			require.NoError(t, err)
			t.Cleanup(func() { require.NoError(t, stream.Close()) })

			msg, err := stream.Receive()
			require.NoError(t, err)
			assert.Equal(t, uint32(42), msg.GetCurrentHeight().GetValue())
			_, err = stream.Receive()
			if fail {
				assert.Equal(t, connect.CodeFailedPrecondition, connect.CodeOf(err))
			} else {
				require.ErrorIs(t, err, io.EOF)
			}
			assertTestMetadata(t, info)
		})
	}
}
