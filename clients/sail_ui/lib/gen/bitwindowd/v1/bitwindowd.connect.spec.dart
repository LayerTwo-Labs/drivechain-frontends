//
//  Generated code. Do not modify.
//  source: bitwindowd/v1/bitwindowd.proto
//

import 'package:connectrpc/connect.dart' as connect;
import 'package:sail_ui/gen/google/protobuf/empty.pb.dart' as googleprotobufempty;

abstract final class BitwindowdService {
  /// Fully-qualified name of the BitwindowdService service.
  static const name = 'bitwindowd.v1.BitwindowdService';

  static const stop = connect.Spec(
    '/$name/Stop',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    googleprotobufempty.Empty.new,
  );
}
