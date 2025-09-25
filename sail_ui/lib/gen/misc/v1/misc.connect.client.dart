//
//  Generated code. Do not modify.
//  source: misc/v1/misc.proto
//

import "package:connectrpc/connect.dart" as connect;
import "misc.pb.dart" as miscv1misc;
import "../../google/protobuf/empty.pb.dart" as googleprotobufempty;
import "misc.connect.spec.dart" as specs;

extension type MiscServiceClient(connect.Transport _transport) {
  Future<miscv1misc.ListOPReturnResponse> listOPReturn(
    googleprotobufempty.Empty input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MiscService.listOPReturn,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<miscv1misc.BroadcastNewsResponse> broadcastNews(
    miscv1misc.BroadcastNewsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MiscService.broadcastNews,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<miscv1misc.CreateTopicResponse> createTopic(
    miscv1misc.CreateTopicRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MiscService.createTopic,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<miscv1misc.ListTopicsResponse> listTopics(
    googleprotobufempty.Empty input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MiscService.listTopics,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<miscv1misc.ListCoinNewsResponse> listCoinNews(
    miscv1misc.ListCoinNewsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.MiscService.listCoinNews,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
