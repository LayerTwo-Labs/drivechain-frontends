//
//  Generated code. Do not modify.
//  source: misc/v1/misc.proto
//

import 'package:connectrpc/connect.dart' as connect;
import 'package:sail_ui/gen/google/protobuf/empty.pb.dart' as googleprotobufempty;
import 'package:sail_ui/gen/misc/v1/misc.pb.dart' as miscv1misc;

abstract final class MiscService {
  /// Fully-qualified name of the MiscService service.
  static const name = 'misc.v1.MiscService';

  static const listOPReturn = connect.Spec(
    '/$name/ListOPReturn',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    miscv1misc.ListOPReturnResponse.new,
  );

  static const broadcastNews = connect.Spec(
    '/$name/BroadcastNews',
    connect.StreamType.unary,
    miscv1misc.BroadcastNewsRequest.new,
    miscv1misc.BroadcastNewsResponse.new,
  );

  static const createTopic = connect.Spec(
    '/$name/CreateTopic',
    connect.StreamType.unary,
    miscv1misc.CreateTopicRequest.new,
    miscv1misc.CreateTopicResponse.new,
  );

  static const listTopics = connect.Spec(
    '/$name/ListTopics',
    connect.StreamType.unary,
    googleprotobufempty.Empty.new,
    miscv1misc.ListTopicsResponse.new,
  );

  static const listCoinNews = connect.Spec(
    '/$name/ListCoinNews',
    connect.StreamType.unary,
    miscv1misc.ListCoinNewsRequest.new,
    miscv1misc.ListCoinNewsResponse.new,
  );
}
