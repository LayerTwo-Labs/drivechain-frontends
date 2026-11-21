package daemon

import (
	"math"

	connectv1 "connectrpc.com/connect"
	"connectrpc.com/connect/v2/connecthttp"
)

// Every client is on loopback, so a gzip response costs CPU and heap for no gain.
const noResponseCompression = math.MaxInt

func mountOptions() []connecthttp.Option {
	return []connecthttp.Option{
		connecthttp.WithReadMaxBytes(0),
		connecthttp.WithCompressMinBytes(noResponseCompression),
	}
}

func coreProxyHandlerOptions(interceptors ...connectv1.Interceptor) connectv1.HandlerOption {
	return connectv1.WithHandlerOptions(
		connectv1.WithInterceptors(interceptors...),
		connectv1.WithCompressMinBytes(noResponseCompression),
	)
}
