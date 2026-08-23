//
//  Generated code. Do not modify.
//  source: notification/v1/notification.proto
//

import "package:connectrpc/connect.dart" as connect;
import "notification.pb.dart" as notificationv1notification;
import "../../google/protobuf/empty.pb.dart" as googleprotobufempty;
import "notification.connect.spec.dart" as specs;

extension type NotificationServiceClient (connect.Transport _transport) {
  /// Watch returns a stream of notification events
  Stream<notificationv1notification.WatchResponse> watch(
    googleprotobufempty.Empty input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).server(
      specs.NotificationService.watch,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
