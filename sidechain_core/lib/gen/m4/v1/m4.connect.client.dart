//
//  Generated code. Do not modify.
//  source: m4/v1/m4.proto
//

import "package:connectrpc/connect.dart" as connect;
import "m4.pb.dart" as m4v1m4;
import "m4.connect.spec.dart" as specs;

/// M4 Explorer Service
extension type M4ServiceClient (connect.Transport _transport) {
  /// Get M4 voting history
  Future<m4v1m4.GetM4HistoryResponse> getM4History(
    m4v1m4.GetM4HistoryRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.M4Service.getM4History,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Get user's vote preferences
  Future<m4v1m4.GetVotePreferencesResponse> getVotePreferences(
    m4v1m4.GetVotePreferencesRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.M4Service.getVotePreferences,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Set user's vote preference for a sidechain
  Future<m4v1m4.SetVotePreferenceResponse> setVotePreference(
    m4v1m4.SetVotePreferenceRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.M4Service.setVotePreference,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  /// Generate M4 bytes from current preferences
  Future<m4v1m4.GenerateM4BytesResponse> generateM4Bytes(
    m4v1m4.GenerateM4BytesRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.M4Service.generateM4Bytes,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
