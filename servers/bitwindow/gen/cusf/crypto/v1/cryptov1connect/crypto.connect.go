// CUSF crypto service

// Code generated by protoc-gen-connect-go. DO NOT EDIT.
//
// Source: cusf/crypto/v1/crypto.proto

package cryptov1connect

import (
	connect "connectrpc.com/connect"
	context "context"
	errors "errors"
	v1 "github.com/LayerTwo-Labs/sidesail/servers/bitwindow/gen/cusf/crypto/v1"
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
	// CryptoServiceName is the fully-qualified name of the CryptoService service.
	CryptoServiceName = "cusf.crypto.v1.CryptoService"
)

// These constants are the fully-qualified names of the RPCs defined in this package. They're
// exposed at runtime as Spec.Procedure and as the final two segments of the HTTP route.
//
// Note that these are different from the fully-qualified method names used by
// google.golang.org/protobuf/reflect/protoreflect. To convert from these constants to
// reflection-formatted method names, remove the leading slash and convert the remaining slash to a
// period.
const (
	// CryptoServiceHmacSha512Procedure is the fully-qualified name of the CryptoService's HmacSha512
	// RPC.
	CryptoServiceHmacSha512Procedure = "/cusf.crypto.v1.CryptoService/HmacSha512"
	// CryptoServiceRipemd160Procedure is the fully-qualified name of the CryptoService's Ripemd160 RPC.
	CryptoServiceRipemd160Procedure = "/cusf.crypto.v1.CryptoService/Ripemd160"
	// CryptoServiceSecp256K1SecretKeyToPublicKeyProcedure is the fully-qualified name of the
	// CryptoService's Secp256k1SecretKeyToPublicKey RPC.
	CryptoServiceSecp256K1SecretKeyToPublicKeyProcedure = "/cusf.crypto.v1.CryptoService/Secp256k1SecretKeyToPublicKey"
	// CryptoServiceSecp256K1SignProcedure is the fully-qualified name of the CryptoService's
	// Secp256k1Sign RPC.
	CryptoServiceSecp256K1SignProcedure = "/cusf.crypto.v1.CryptoService/Secp256k1Sign"
	// CryptoServiceSecp256K1VerifyProcedure is the fully-qualified name of the CryptoService's
	// Secp256k1Verify RPC.
	CryptoServiceSecp256K1VerifyProcedure = "/cusf.crypto.v1.CryptoService/Secp256k1Verify"
)

// These variables are the protoreflect.Descriptor objects for the RPCs defined in this package.
var (
	cryptoServiceServiceDescriptor                             = v1.File_cusf_crypto_v1_crypto_proto.Services().ByName("CryptoService")
	cryptoServiceHmacSha512MethodDescriptor                    = cryptoServiceServiceDescriptor.Methods().ByName("HmacSha512")
	cryptoServiceRipemd160MethodDescriptor                     = cryptoServiceServiceDescriptor.Methods().ByName("Ripemd160")
	cryptoServiceSecp256K1SecretKeyToPublicKeyMethodDescriptor = cryptoServiceServiceDescriptor.Methods().ByName("Secp256k1SecretKeyToPublicKey")
	cryptoServiceSecp256K1SignMethodDescriptor                 = cryptoServiceServiceDescriptor.Methods().ByName("Secp256k1Sign")
	cryptoServiceSecp256K1VerifyMethodDescriptor               = cryptoServiceServiceDescriptor.Methods().ByName("Secp256k1Verify")
)

// CryptoServiceClient is a client for the cusf.crypto.v1.CryptoService service.
type CryptoServiceClient interface {
	HmacSha512(context.Context, *connect.Request[v1.HmacSha512Request]) (*connect.Response[v1.HmacSha512Response], error)
	Ripemd160(context.Context, *connect.Request[v1.Ripemd160Request]) (*connect.Response[v1.Ripemd160Response], error)
	Secp256K1SecretKeyToPublicKey(context.Context, *connect.Request[v1.Secp256K1SecretKeyToPublicKeyRequest]) (*connect.Response[v1.Secp256K1SecretKeyToPublicKeyResponse], error)
	Secp256K1Sign(context.Context, *connect.Request[v1.Secp256K1SignRequest]) (*connect.Response[v1.Secp256K1SignResponse], error)
	Secp256K1Verify(context.Context, *connect.Request[v1.Secp256K1VerifyRequest]) (*connect.Response[v1.Secp256K1VerifyResponse], error)
}

// NewCryptoServiceClient constructs a client for the cusf.crypto.v1.CryptoService service. By
// default, it uses the Connect protocol with the binary Protobuf Codec, asks for gzipped responses,
// and sends uncompressed requests. To use the gRPC or gRPC-Web protocols, supply the
// connect.WithGRPC() or connect.WithGRPCWeb() options.
//
// The URL supplied here should be the base URL for the Connect or gRPC server (for example,
// http://api.acme.com or https://acme.com/grpc).
func NewCryptoServiceClient(httpClient connect.HTTPClient, baseURL string, opts ...connect.ClientOption) CryptoServiceClient {
	baseURL = strings.TrimRight(baseURL, "/")
	return &cryptoServiceClient{
		hmacSha512: connect.NewClient[v1.HmacSha512Request, v1.HmacSha512Response](
			httpClient,
			baseURL+CryptoServiceHmacSha512Procedure,
			connect.WithSchema(cryptoServiceHmacSha512MethodDescriptor),
			connect.WithClientOptions(opts...),
		),
		ripemd160: connect.NewClient[v1.Ripemd160Request, v1.Ripemd160Response](
			httpClient,
			baseURL+CryptoServiceRipemd160Procedure,
			connect.WithSchema(cryptoServiceRipemd160MethodDescriptor),
			connect.WithClientOptions(opts...),
		),
		secp256K1SecretKeyToPublicKey: connect.NewClient[v1.Secp256K1SecretKeyToPublicKeyRequest, v1.Secp256K1SecretKeyToPublicKeyResponse](
			httpClient,
			baseURL+CryptoServiceSecp256K1SecretKeyToPublicKeyProcedure,
			connect.WithSchema(cryptoServiceSecp256K1SecretKeyToPublicKeyMethodDescriptor),
			connect.WithClientOptions(opts...),
		),
		secp256K1Sign: connect.NewClient[v1.Secp256K1SignRequest, v1.Secp256K1SignResponse](
			httpClient,
			baseURL+CryptoServiceSecp256K1SignProcedure,
			connect.WithSchema(cryptoServiceSecp256K1SignMethodDescriptor),
			connect.WithClientOptions(opts...),
		),
		secp256K1Verify: connect.NewClient[v1.Secp256K1VerifyRequest, v1.Secp256K1VerifyResponse](
			httpClient,
			baseURL+CryptoServiceSecp256K1VerifyProcedure,
			connect.WithSchema(cryptoServiceSecp256K1VerifyMethodDescriptor),
			connect.WithClientOptions(opts...),
		),
	}
}

// cryptoServiceClient implements CryptoServiceClient.
type cryptoServiceClient struct {
	hmacSha512                    *connect.Client[v1.HmacSha512Request, v1.HmacSha512Response]
	ripemd160                     *connect.Client[v1.Ripemd160Request, v1.Ripemd160Response]
	secp256K1SecretKeyToPublicKey *connect.Client[v1.Secp256K1SecretKeyToPublicKeyRequest, v1.Secp256K1SecretKeyToPublicKeyResponse]
	secp256K1Sign                 *connect.Client[v1.Secp256K1SignRequest, v1.Secp256K1SignResponse]
	secp256K1Verify               *connect.Client[v1.Secp256K1VerifyRequest, v1.Secp256K1VerifyResponse]
}

// HmacSha512 calls cusf.crypto.v1.CryptoService.HmacSha512.
func (c *cryptoServiceClient) HmacSha512(ctx context.Context, req *connect.Request[v1.HmacSha512Request]) (*connect.Response[v1.HmacSha512Response], error) {
	return c.hmacSha512.CallUnary(ctx, req)
}

// Ripemd160 calls cusf.crypto.v1.CryptoService.Ripemd160.
func (c *cryptoServiceClient) Ripemd160(ctx context.Context, req *connect.Request[v1.Ripemd160Request]) (*connect.Response[v1.Ripemd160Response], error) {
	return c.ripemd160.CallUnary(ctx, req)
}

// Secp256K1SecretKeyToPublicKey calls cusf.crypto.v1.CryptoService.Secp256k1SecretKeyToPublicKey.
func (c *cryptoServiceClient) Secp256K1SecretKeyToPublicKey(ctx context.Context, req *connect.Request[v1.Secp256K1SecretKeyToPublicKeyRequest]) (*connect.Response[v1.Secp256K1SecretKeyToPublicKeyResponse], error) {
	return c.secp256K1SecretKeyToPublicKey.CallUnary(ctx, req)
}

// Secp256K1Sign calls cusf.crypto.v1.CryptoService.Secp256k1Sign.
func (c *cryptoServiceClient) Secp256K1Sign(ctx context.Context, req *connect.Request[v1.Secp256K1SignRequest]) (*connect.Response[v1.Secp256K1SignResponse], error) {
	return c.secp256K1Sign.CallUnary(ctx, req)
}

// Secp256K1Verify calls cusf.crypto.v1.CryptoService.Secp256k1Verify.
func (c *cryptoServiceClient) Secp256K1Verify(ctx context.Context, req *connect.Request[v1.Secp256K1VerifyRequest]) (*connect.Response[v1.Secp256K1VerifyResponse], error) {
	return c.secp256K1Verify.CallUnary(ctx, req)
}

// CryptoServiceHandler is an implementation of the cusf.crypto.v1.CryptoService service.
type CryptoServiceHandler interface {
	HmacSha512(context.Context, *connect.Request[v1.HmacSha512Request]) (*connect.Response[v1.HmacSha512Response], error)
	Ripemd160(context.Context, *connect.Request[v1.Ripemd160Request]) (*connect.Response[v1.Ripemd160Response], error)
	Secp256K1SecretKeyToPublicKey(context.Context, *connect.Request[v1.Secp256K1SecretKeyToPublicKeyRequest]) (*connect.Response[v1.Secp256K1SecretKeyToPublicKeyResponse], error)
	Secp256K1Sign(context.Context, *connect.Request[v1.Secp256K1SignRequest]) (*connect.Response[v1.Secp256K1SignResponse], error)
	Secp256K1Verify(context.Context, *connect.Request[v1.Secp256K1VerifyRequest]) (*connect.Response[v1.Secp256K1VerifyResponse], error)
}

// NewCryptoServiceHandler builds an HTTP handler from the service implementation. It returns the
// path on which to mount the handler and the handler itself.
//
// By default, handlers support the Connect, gRPC, and gRPC-Web protocols with the binary Protobuf
// and JSON codecs. They also support gzip compression.
func NewCryptoServiceHandler(svc CryptoServiceHandler, opts ...connect.HandlerOption) (string, http.Handler) {
	cryptoServiceHmacSha512Handler := connect.NewUnaryHandler(
		CryptoServiceHmacSha512Procedure,
		svc.HmacSha512,
		connect.WithSchema(cryptoServiceHmacSha512MethodDescriptor),
		connect.WithHandlerOptions(opts...),
	)
	cryptoServiceRipemd160Handler := connect.NewUnaryHandler(
		CryptoServiceRipemd160Procedure,
		svc.Ripemd160,
		connect.WithSchema(cryptoServiceRipemd160MethodDescriptor),
		connect.WithHandlerOptions(opts...),
	)
	cryptoServiceSecp256K1SecretKeyToPublicKeyHandler := connect.NewUnaryHandler(
		CryptoServiceSecp256K1SecretKeyToPublicKeyProcedure,
		svc.Secp256K1SecretKeyToPublicKey,
		connect.WithSchema(cryptoServiceSecp256K1SecretKeyToPublicKeyMethodDescriptor),
		connect.WithHandlerOptions(opts...),
	)
	cryptoServiceSecp256K1SignHandler := connect.NewUnaryHandler(
		CryptoServiceSecp256K1SignProcedure,
		svc.Secp256K1Sign,
		connect.WithSchema(cryptoServiceSecp256K1SignMethodDescriptor),
		connect.WithHandlerOptions(opts...),
	)
	cryptoServiceSecp256K1VerifyHandler := connect.NewUnaryHandler(
		CryptoServiceSecp256K1VerifyProcedure,
		svc.Secp256K1Verify,
		connect.WithSchema(cryptoServiceSecp256K1VerifyMethodDescriptor),
		connect.WithHandlerOptions(opts...),
	)
	return "/cusf.crypto.v1.CryptoService/", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		switch r.URL.Path {
		case CryptoServiceHmacSha512Procedure:
			cryptoServiceHmacSha512Handler.ServeHTTP(w, r)
		case CryptoServiceRipemd160Procedure:
			cryptoServiceRipemd160Handler.ServeHTTP(w, r)
		case CryptoServiceSecp256K1SecretKeyToPublicKeyProcedure:
			cryptoServiceSecp256K1SecretKeyToPublicKeyHandler.ServeHTTP(w, r)
		case CryptoServiceSecp256K1SignProcedure:
			cryptoServiceSecp256K1SignHandler.ServeHTTP(w, r)
		case CryptoServiceSecp256K1VerifyProcedure:
			cryptoServiceSecp256K1VerifyHandler.ServeHTTP(w, r)
		default:
			http.NotFound(w, r)
		}
	})
}

// UnimplementedCryptoServiceHandler returns CodeUnimplemented from all methods.
type UnimplementedCryptoServiceHandler struct{}

func (UnimplementedCryptoServiceHandler) HmacSha512(context.Context, *connect.Request[v1.HmacSha512Request]) (*connect.Response[v1.HmacSha512Response], error) {
	return nil, connect.NewError(connect.CodeUnimplemented, errors.New("cusf.crypto.v1.CryptoService.HmacSha512 is not implemented"))
}

func (UnimplementedCryptoServiceHandler) Ripemd160(context.Context, *connect.Request[v1.Ripemd160Request]) (*connect.Response[v1.Ripemd160Response], error) {
	return nil, connect.NewError(connect.CodeUnimplemented, errors.New("cusf.crypto.v1.CryptoService.Ripemd160 is not implemented"))
}

func (UnimplementedCryptoServiceHandler) Secp256K1SecretKeyToPublicKey(context.Context, *connect.Request[v1.Secp256K1SecretKeyToPublicKeyRequest]) (*connect.Response[v1.Secp256K1SecretKeyToPublicKeyResponse], error) {
	return nil, connect.NewError(connect.CodeUnimplemented, errors.New("cusf.crypto.v1.CryptoService.Secp256k1SecretKeyToPublicKey is not implemented"))
}

func (UnimplementedCryptoServiceHandler) Secp256K1Sign(context.Context, *connect.Request[v1.Secp256K1SignRequest]) (*connect.Response[v1.Secp256K1SignResponse], error) {
	return nil, connect.NewError(connect.CodeUnimplemented, errors.New("cusf.crypto.v1.CryptoService.Secp256k1Sign is not implemented"))
}

func (UnimplementedCryptoServiceHandler) Secp256K1Verify(context.Context, *connect.Request[v1.Secp256K1VerifyRequest]) (*connect.Response[v1.Secp256K1VerifyResponse], error) {
	return nil, connect.NewError(connect.CodeUnimplemented, errors.New("cusf.crypto.v1.CryptoService.Secp256k1Verify is not implemented"))
}