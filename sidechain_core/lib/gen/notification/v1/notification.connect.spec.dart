//
//  Generated code. Do not modify.
//  source: notification/v1/notification.proto
//

import "package:connectrpc/connect.dart" as connect;
import "../../google/protobuf/empty.pb.dart" as googleprotobufempty;
import "notification.pb.dart" as notificationv1notification;

abstract final class NotificationService {
  /// Fully-qualified name of the NotificationService service.
  static const name = 'notification.v1.NotificationService';

  /// Watch returns a stream of notification events
  static const watch = connect.Spec(
    '/$name/Watch',
    connect.StreamType.server,
    googleprotobufempty.Empty.new,
    notificationv1notification.WatchResponse.new,
  );
}
