//
//  Generated code. Do not modify.
//  source: bitwindowd/v1/bitwindowd.proto
//

import 'package:connectrpc/connect.dart' as connect;
import 'package:sail_ui/gen/google/protobuf/empty.pb.dart' as googleprotobufempty;
import 'package:sail_ui/gen/bitwindowd/v1/bitwindowd.connect.spec.dart' as specs;
import 'package:sail_ui/gen/bitwindowd/v1/bitwindowd.pb.dart' as bitwindowdv1bitwindowd;

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

  /// Deniability operations
  Future<bitwindowdv1bitwindowd.CreateDenialResponse> createDenial(
    bitwindowdv1bitwindowd.CreateDenialRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitwindowdService.createDenial,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<bitwindowdv1bitwindowd.ListDenialsResponse> listDenials(
    googleprotobufempty.Empty input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitwindowdService.listDenials,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<googleprotobufempty.Empty> cancelDenial(
    bitwindowdv1bitwindowd.CancelDenialRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.BitwindowdService.cancelDenial,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
