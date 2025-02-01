//
//  Generated code. Do not modify.
//  source: bitwindowd/v1/bitwindowd.proto
//

import 'package:connectrpc/connect.dart' as connect;
import 'package:sail_ui/gen/google/protobuf/empty.pb.dart' as googleprotobufempty;
import 'package:sail_ui/gen/bitwindowd/v1/bitwindowd.connect.spec.dart' as specs;

extension type BitwindowdServiceClient (connect.Transport _transport) {
  Future<googleprotobufempty.Empty> stop(
    googleprotobufempty.Empty input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitwindowdService.stop,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
