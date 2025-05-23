// Code generated by protoc-gen-connect-go. DO NOT EDIT.
//
// Source: drivechain/v1/drivechain.proto

package drivechainv1connect

import (
	connect "connectrpc.com/connect"
	context "context"
	errors "errors"
	v1 "github.com/LayerTwo-Labs/sidesail/bitwindow/server/gen/drivechain/v1"
	http "net/http"
	strings "strings"
)

// This is a compile-time assertion to ensure that this generated file and the connect package are
// compatible. If you get a compiler error that this constant is not defined, this code was
// generated with a version of connect newer than the one compiled into your binary. You can fix the
// problem by either regenerating this code with an older version of connect or updating the connect
// version compiled into your binary.
const _ = connect.IsAtLeastVersion1_13_0

const (
	// DrivechainServiceName is the fully-qualified name of the DrivechainService service.
	DrivechainServiceName = "drivechain.v1.DrivechainService"
)

// These constants are the fully-qualified names of the RPCs defined in this package. They're
// exposed at runtime as Spec.Procedure and as the final two segments of the HTTP route.
//
// Note that these are different from the fully-qualified method names used by
// google.golang.org/protobuf/reflect/protoreflect. To convert from these constants to
// reflection-formatted method names, remove the leading slash and convert the remaining slash to a
// period.
const (
	// DrivechainServiceListSidechainsProcedure is the fully-qualified name of the DrivechainService's
	// ListSidechains RPC.
	DrivechainServiceListSidechainsProcedure = "/drivechain.v1.DrivechainService/ListSidechains"
	// DrivechainServiceListSidechainProposalsProcedure is the fully-qualified name of the
	// DrivechainService's ListSidechainProposals RPC.
	DrivechainServiceListSidechainProposalsProcedure = "/drivechain.v1.DrivechainService/ListSidechainProposals"
)

// DrivechainServiceClient is a client for the drivechain.v1.DrivechainService service.
type DrivechainServiceClient interface {
	ListSidechains(context.Context, *connect.Request[v1.ListSidechainsRequest]) (*connect.Response[v1.ListSidechainsResponse], error)
	ListSidechainProposals(context.Context, *connect.Request[v1.ListSidechainProposalsRequest]) (*connect.Response[v1.ListSidechainProposalsResponse], error)
}

// NewDrivechainServiceClient constructs a client for the drivechain.v1.DrivechainService service.
// By default, it uses the Connect protocol with the binary Protobuf Codec, asks for gzipped
// responses, and sends uncompressed requests. To use the gRPC or gRPC-Web protocols, supply the
// connect.WithGRPC() or connect.WithGRPCWeb() options.
//
// The URL supplied here should be the base URL for the Connect or gRPC server (for example,
// http://api.acme.com or https://acme.com/grpc).
func NewDrivechainServiceClient(httpClient connect.HTTPClient, baseURL string, opts ...connect.ClientOption) DrivechainServiceClient {
	baseURL = strings.TrimRight(baseURL, "/")
	drivechainServiceMethods := v1.File_drivechain_v1_drivechain_proto.Services().ByName("DrivechainService").Methods()
	return &drivechainServiceClient{
		listSidechains: connect.NewClient[v1.ListSidechainsRequest, v1.ListSidechainsResponse](
			httpClient,
			baseURL+DrivechainServiceListSidechainsProcedure,
			connect.WithSchema(drivechainServiceMethods.ByName("ListSidechains")),
			connect.WithClientOptions(opts...),
		),
		listSidechainProposals: connect.NewClient[v1.ListSidechainProposalsRequest, v1.ListSidechainProposalsResponse](
			httpClient,
			baseURL+DrivechainServiceListSidechainProposalsProcedure,
			connect.WithSchema(drivechainServiceMethods.ByName("ListSidechainProposals")),
			connect.WithClientOptions(opts...),
		),
	}
}

// drivechainServiceClient implements DrivechainServiceClient.
type drivechainServiceClient struct {
	listSidechains         *connect.Client[v1.ListSidechainsRequest, v1.ListSidechainsResponse]
	listSidechainProposals *connect.Client[v1.ListSidechainProposalsRequest, v1.ListSidechainProposalsResponse]
}

// ListSidechains calls drivechain.v1.DrivechainService.ListSidechains.
func (c *drivechainServiceClient) ListSidechains(ctx context.Context, req *connect.Request[v1.ListSidechainsRequest]) (*connect.Response[v1.ListSidechainsResponse], error) {
	return c.listSidechains.CallUnary(ctx, req)
}

// ListSidechainProposals calls drivechain.v1.DrivechainService.ListSidechainProposals.
func (c *drivechainServiceClient) ListSidechainProposals(ctx context.Context, req *connect.Request[v1.ListSidechainProposalsRequest]) (*connect.Response[v1.ListSidechainProposalsResponse], error) {
	return c.listSidechainProposals.CallUnary(ctx, req)
}

// DrivechainServiceHandler is an implementation of the drivechain.v1.DrivechainService service.
type DrivechainServiceHandler interface {
	ListSidechains(context.Context, *connect.Request[v1.ListSidechainsRequest]) (*connect.Response[v1.ListSidechainsResponse], error)
	ListSidechainProposals(context.Context, *connect.Request[v1.ListSidechainProposalsRequest]) (*connect.Response[v1.ListSidechainProposalsResponse], error)
}

// NewDrivechainServiceHandler builds an HTTP handler from the service implementation. It returns
// the path on which to mount the handler and the handler itself.
//
// By default, handlers support the Connect, gRPC, and gRPC-Web protocols with the binary Protobuf
// and JSON codecs. They also support gzip compression.
func NewDrivechainServiceHandler(svc DrivechainServiceHandler, opts ...connect.HandlerOption) (string, http.Handler) {
	drivechainServiceMethods := v1.File_drivechain_v1_drivechain_proto.Services().ByName("DrivechainService").Methods()
	drivechainServiceListSidechainsHandler := connect.NewUnaryHandler(
		DrivechainServiceListSidechainsProcedure,
		svc.ListSidechains,
		connect.WithSchema(drivechainServiceMethods.ByName("ListSidechains")),
		connect.WithHandlerOptions(opts...),
	)
	drivechainServiceListSidechainProposalsHandler := connect.NewUnaryHandler(
		DrivechainServiceListSidechainProposalsProcedure,
		svc.ListSidechainProposals,
		connect.WithSchema(drivechainServiceMethods.ByName("ListSidechainProposals")),
		connect.WithHandlerOptions(opts...),
	)
	return "/drivechain.v1.DrivechainService/", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case DrivechainServiceListSidechainsProcedure:
			drivechainServiceListSidechainsHandler.ServeHTTP(w, r)
		case DrivechainServiceListSidechainProposalsProcedure:
			drivechainServiceListSidechainProposalsHandler.ServeHTTP(w, r)
		default:
			http.NotFound(w, r)
		}
	})
}

// UnimplementedDrivechainServiceHandler returns CodeUnimplemented from all methods.
type UnimplementedDrivechainServiceHandler struct{}

func (UnimplementedDrivechainServiceHandler) ListSidechains(context.Context, *connect.Request[v1.ListSidechainsRequest]) (*connect.Response[v1.ListSidechainsResponse], error) {
	return nil, connect.NewError(connect.CodeUnimplemented, errors.New("drivechain.v1.DrivechainService.ListSidechains is not implemented"))
}

func (UnimplementedDrivechainServiceHandler) ListSidechainProposals(context.Context, *connect.Request[v1.ListSidechainProposalsRequest]) (*connect.Response[v1.ListSidechainProposalsResponse], error) {
	return nil, connect.NewError(connect.CodeUnimplemented, errors.New("drivechain.v1.DrivechainService.ListSidechainProposals is not implemented"))
}
