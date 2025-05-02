//
//  Generated code. Do not modify.
//  source: health/v1/health.proto
//

import "package:connectrpc/connect.dart" as connect;
import "../../google/protobuf/empty.pb.dart" as googleprotobufempty;
import "health.pb.dart" as healthv1health;

abstract final class HealthService {
  /// Fully-qualified name of the HealthService service.
  static const name = 'health.v1.HealthService';

  /// Check status of requested services
  /// buf:lint:ignore RPC_REQUEST_RESPONSE_UNIQUE
  static const check = connect.Spec(
    '/$name/Check',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    healthv1health.CheckResponse.new,
  );

  /// buf:lint:ignore RPC_REQUEST_RESPONSE_UNIQUE
  /// buf:lint:ignore RPC_RESPONSE_STANDARD_NAME
  static const watch = connect.Spec(
    '/$name/Watch',
    connect.StreamType.server,
    googleprotobufempty.Empty.new,
    healthv1health.CheckResponse.new,
  );
}
