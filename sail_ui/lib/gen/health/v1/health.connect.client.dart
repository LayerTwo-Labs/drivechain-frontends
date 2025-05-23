//
//  Generated code. Do not modify.
//  source: health/v1/health.proto
//

import "package:connectrpc/connect.dart" as connect;
import "health.pb.dart" as healthv1health;
import "../../google/protobuf/empty.pb.dart" as googleprotobufempty;
import "health.connect.spec.dart" as specs;

extension type HealthServiceClient (connect.Transport _transport) {
  /// Check status of requested services
  /// buf:lint:ignore RPC_REQUEST_RESPONSE_UNIQUE
  Future<healthv1health.CheckResponse> check(
    googleprotobufempty.Empty input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.HealthService.check,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// buf:lint:ignore RPC_REQUEST_RESPONSE_UNIQUE
  /// buf:lint:ignore RPC_RESPONSE_STANDARD_NAME
  Stream<healthv1health.CheckResponse> watch(
    googleprotobufempty.Empty input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.HealthService.watch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
