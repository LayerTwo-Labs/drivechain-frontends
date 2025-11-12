//
//  Generated code. Do not modify.
//  source: m4/v1/m4.proto
//

import "package:connectrpc/connect.dart" as connect;
import "m4.pb.dart" as m4v1m4;

/// M4 Explorer Service
abstract final class M4Service {
  /// Fully-qualified name of the M4Service service.
  static const name = 'm4.v1.M4Service';

  /// Get M4 voting history
  static const getM4History = connect.Spec(
    '/$name/GetM4History',
    connect.StreamType.unary,
    m4v1m4.GetM4HistoryRequest.new,
    m4v1m4.GetM4HistoryResponse.new,
  );

  /// Get user's vote preferences
  static const getVotePreferences = connect.Spec(
    '/$name/GetVotePreferences',
    connect.StreamType.unary,
    m4v1m4.GetVotePreferencesRequest.new,
    m4v1m4.GetVotePreferencesResponse.new,
  );

  /// Set user's vote preference for a sidechain
  static const setVotePreference = connect.Spec(
    '/$name/SetVotePreference',
    connect.StreamType.unary,
    m4v1m4.SetVotePreferenceRequest.new,
    m4v1m4.SetVotePreferenceResponse.new,
  );

  /// Generate M4 bytes from current preferences
  static const generateM4Bytes = connect.Spec(
    '/$name/GenerateM4Bytes',
    connect.StreamType.unary,
    m4v1m4.GenerateM4BytesRequest.new,
    m4v1m4.GenerateM4BytesResponse.new,
  );
}
