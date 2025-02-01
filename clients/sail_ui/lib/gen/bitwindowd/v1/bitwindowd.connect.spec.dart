//
//  Generated code. Do not modify.
//  source: bitwindowd/v1/bitwindowd.proto
//

import 'package:connectrpc/connect.dart' as connect;
import 'package:sail_ui/gen/google/protobuf/empty.pb.dart' as googleprotobufempty;
import 'package:sail_ui/gen/bitwindowd/v1/bitwindowd.pb.dart' as bitwindowdv1bitwindowd;

abstract final class BitwindowdService {
  /// Fully-qualified name of the BitwindowdService service.
  static const name = 'bitwindowd.v1.BitwindowdService';

  static const stop = connect.Spec(
    '/$name/Stop',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    googleprotobufempty.Empty.new,
  );

  /// Deniability operations
  static const createDenial = connect.Spec(
    '/$name/CreateDenial',
    connect.StreamType.unary,
    bitwindowdv1bitwindowd.CreateDenialRequest.new,
    bitwindowdv1bitwindowd.CreateDenialResponse.new,
  );

  static const listDenials = connect.Spec(
    '/$name/ListDenials',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    bitwindowdv1bitwindowd.ListDenialsResponse.new,
  );

  static const cancelDenial = connect.Spec(
    '/$name/CancelDenial',
    connect.StreamType.unary,
    bitwindowdv1bitwindowd.CancelDenialRequest.new,
    googleprotobufempty.Empty.new,
  );
}
