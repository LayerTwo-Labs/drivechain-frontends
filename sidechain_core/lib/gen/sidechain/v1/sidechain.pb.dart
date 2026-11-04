// This is a generated file - do not edit.
//
// Generated from sidechain/v1/sidechain.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class GetDetectedWithdrawalsRequest extends $pb.GeneratedMessage {
  factory GetDetectedWithdrawalsRequest({
    $core.String? sidechain,
    $core.int? limit,
  }) {
    final result = GetDetectedWithdrawalsRequest._();
    if (sidechain != null) result.sidechain = sidechain;
    if (limit != null) result.limit = limit;
    return result;
  }

  GetDetectedWithdrawalsRequest._();

  factory GetDetectedWithdrawalsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetDetectedWithdrawalsRequest()..mergeFromBuffer(data, registry);
  factory GetDetectedWithdrawalsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetDetectedWithdrawalsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetDetectedWithdrawalsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'sidechain.v1'),
      createEmptyInstance: GetDetectedWithdrawalsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sidechain')
    ..aI(2, _omitFieldNames ? '' : 'limit')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDetectedWithdrawalsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDetectedWithdrawalsRequest copyWith(void Function(GetDetectedWithdrawalsRequest) updates) =>
      super.copyWith((message) => updates(message as GetDetectedWithdrawalsRequest)) as GetDetectedWithdrawalsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetDetectedWithdrawalsRequest() / GetDetectedWithdrawalsRequest.new instead')
  static GetDetectedWithdrawalsRequest create() => GetDetectedWithdrawalsRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetDetectedWithdrawalsRequest._();
  @$core.override
  GetDetectedWithdrawalsRequest createEmptyInstance() => GetDetectedWithdrawalsRequest._();
  @$core.pragma('dart2js:noInline')
  static GetDetectedWithdrawalsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDetectedWithdrawalsRequest>(GetDetectedWithdrawalsRequest.$_createMessage);
  static GetDetectedWithdrawalsRequest? _defaultInstance;

  /// Optional filter by sidechain name
  @$pb.TagNumber(1)
  $core.String get sidechain => $_getSZ(0);
  @$pb.TagNumber(1)
  set sidechain($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSidechain() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechain() => $_clearField(1);

  /// Optional limit on number of results
  @$pb.TagNumber(2)
  $core.int get limit => $_getIZ(1);
  @$pb.TagNumber(2)
  set limit($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLimit() => $_has(1);
  @$pb.TagNumber(2)
  void clearLimit() => $_clearField(2);
}

class GetDetectedWithdrawalsResponse extends $pb.GeneratedMessage {
  factory GetDetectedWithdrawalsResponse({
    $core.Iterable<DetectedWithdrawal>? withdrawals,
  }) {
    final result = GetDetectedWithdrawalsResponse._();
    if (withdrawals != null) result.withdrawals.addAll(withdrawals);
    return result;
  }

  GetDetectedWithdrawalsResponse._();

  factory GetDetectedWithdrawalsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetDetectedWithdrawalsResponse()..mergeFromBuffer(data, registry);
  factory GetDetectedWithdrawalsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetDetectedWithdrawalsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetDetectedWithdrawalsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'sidechain.v1'),
      createEmptyInstance: GetDetectedWithdrawalsResponse.$_createMessage)
    ..pPM<DetectedWithdrawal>(1, _omitFieldNames ? '' : 'withdrawals', subBuilder: DetectedWithdrawal.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDetectedWithdrawalsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetDetectedWithdrawalsResponse copyWith(void Function(GetDetectedWithdrawalsResponse) updates) =>
      super.copyWith((message) => updates(message as GetDetectedWithdrawalsResponse)) as GetDetectedWithdrawalsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetDetectedWithdrawalsResponse() / GetDetectedWithdrawalsResponse.new instead')
  static GetDetectedWithdrawalsResponse create() => GetDetectedWithdrawalsResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetDetectedWithdrawalsResponse._();
  @$core.override
  GetDetectedWithdrawalsResponse createEmptyInstance() => GetDetectedWithdrawalsResponse._();
  @$core.pragma('dart2js:noInline')
  static GetDetectedWithdrawalsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetDetectedWithdrawalsResponse>(GetDetectedWithdrawalsResponse.$_createMessage);
  static GetDetectedWithdrawalsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<DetectedWithdrawal> get withdrawals => $_getList(0);
}

class GetWithdrawalByTxidRequest extends $pb.GeneratedMessage {
  factory GetWithdrawalByTxidRequest({
    $core.String? txid,
  }) {
    final result = GetWithdrawalByTxidRequest._();
    if (txid != null) result.txid = txid;
    return result;
  }

  GetWithdrawalByTxidRequest._();

  factory GetWithdrawalByTxidRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetWithdrawalByTxidRequest()..mergeFromBuffer(data, registry);
  factory GetWithdrawalByTxidRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetWithdrawalByTxidRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWithdrawalByTxidRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'sidechain.v1'),
      createEmptyInstance: GetWithdrawalByTxidRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWithdrawalByTxidRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWithdrawalByTxidRequest copyWith(void Function(GetWithdrawalByTxidRequest) updates) =>
      super.copyWith((message) => updates(message as GetWithdrawalByTxidRequest)) as GetWithdrawalByTxidRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetWithdrawalByTxidRequest() / GetWithdrawalByTxidRequest.new instead')
  static GetWithdrawalByTxidRequest create() => GetWithdrawalByTxidRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetWithdrawalByTxidRequest._();
  @$core.override
  GetWithdrawalByTxidRequest createEmptyInstance() => GetWithdrawalByTxidRequest._();
  @$core.pragma('dart2js:noInline')
  static GetWithdrawalByTxidRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetWithdrawalByTxidRequest>(GetWithdrawalByTxidRequest.$_createMessage);
  static GetWithdrawalByTxidRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class GetWithdrawalByTxidResponse extends $pb.GeneratedMessage {
  factory GetWithdrawalByTxidResponse({
    DetectedWithdrawal? withdrawal,
  }) {
    final result = GetWithdrawalByTxidResponse._();
    if (withdrawal != null) result.withdrawal = withdrawal;
    return result;
  }

  GetWithdrawalByTxidResponse._();

  factory GetWithdrawalByTxidResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetWithdrawalByTxidResponse()..mergeFromBuffer(data, registry);
  factory GetWithdrawalByTxidResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetWithdrawalByTxidResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWithdrawalByTxidResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'sidechain.v1'),
      createEmptyInstance: GetWithdrawalByTxidResponse.$_createMessage)
    ..aOM<DetectedWithdrawal>(1, _omitFieldNames ? '' : 'withdrawal', subBuilder: DetectedWithdrawal.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWithdrawalByTxidResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWithdrawalByTxidResponse copyWith(void Function(GetWithdrawalByTxidResponse) updates) =>
      super.copyWith((message) => updates(message as GetWithdrawalByTxidResponse)) as GetWithdrawalByTxidResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetWithdrawalByTxidResponse() / GetWithdrawalByTxidResponse.new instead')
  static GetWithdrawalByTxidResponse create() => GetWithdrawalByTxidResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetWithdrawalByTxidResponse._();
  @$core.override
  GetWithdrawalByTxidResponse createEmptyInstance() => GetWithdrawalByTxidResponse._();
  @$core.pragma('dart2js:noInline')
  static GetWithdrawalByTxidResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetWithdrawalByTxidResponse>(GetWithdrawalByTxidResponse.$_createMessage);
  static GetWithdrawalByTxidResponse? _defaultInstance;

  @$pb.TagNumber(1)
  DetectedWithdrawal get withdrawal => $_getN(0);
  @$pb.TagNumber(1)
  set withdrawal(DetectedWithdrawal value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasWithdrawal() => $_has(0);
  @$pb.TagNumber(1)
  void clearWithdrawal() => $_clearField(1);
  @$pb.TagNumber(1)
  DetectedWithdrawal ensureWithdrawal() => $_ensure(0);
}

class DetectedWithdrawal extends $pb.GeneratedMessage {
  factory DetectedWithdrawal({
    $core.String? txid,
    $core.String? sidechain,
    $fixnum.Int64? amount,
    $core.String? destination,
    $0.Timestamp? detectedAt,
    $core.String? blockHash,
  }) {
    final result = DetectedWithdrawal._();
    if (txid != null) result.txid = txid;
    if (sidechain != null) result.sidechain = sidechain;
    if (amount != null) result.amount = amount;
    if (destination != null) result.destination = destination;
    if (detectedAt != null) result.detectedAt = detectedAt;
    if (blockHash != null) result.blockHash = blockHash;
    return result;
  }

  DetectedWithdrawal._();

  factory DetectedWithdrawal.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DetectedWithdrawal()..mergeFromBuffer(data, registry);
  factory DetectedWithdrawal.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DetectedWithdrawal()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DetectedWithdrawal',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'sidechain.v1'),
      createEmptyInstance: DetectedWithdrawal.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aOS(2, _omitFieldNames ? '' : 'sidechain')
    ..aInt64(3, _omitFieldNames ? '' : 'amount')
    ..aOS(4, _omitFieldNames ? '' : 'destination')
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'detectedAt', subBuilder: $0.Timestamp.$_createMessage)
    ..aOS(6, _omitFieldNames ? '' : 'blockHash')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectedWithdrawal clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DetectedWithdrawal copyWith(void Function(DetectedWithdrawal) updates) =>
      super.copyWith((message) => updates(message as DetectedWithdrawal)) as DetectedWithdrawal;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DetectedWithdrawal() / DetectedWithdrawal.new instead')
  static DetectedWithdrawal create() => DetectedWithdrawal._();
  static $pb.GeneratedMessage $_createMessage() => DetectedWithdrawal._();
  @$core.override
  DetectedWithdrawal createEmptyInstance() => DetectedWithdrawal._();
  @$core.pragma('dart2js:noInline')
  static DetectedWithdrawal getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DetectedWithdrawal>(DetectedWithdrawal.$_createMessage);
  static DetectedWithdrawal? _defaultInstance;

  /// Transaction ID of the withdrawal
  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  /// Sidechain name (thunder, bitnames, etc.)
  @$pb.TagNumber(2)
  $core.String get sidechain => $_getSZ(1);
  @$pb.TagNumber(2)
  set sidechain($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSidechain() => $_has(1);
  @$pb.TagNumber(2)
  void clearSidechain() => $_clearField(2);

  /// Amount in satoshis
  @$pb.TagNumber(3)
  $fixnum.Int64 get amount => $_getI64(2);
  @$pb.TagNumber(3)
  set amount($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmount() => $_clearField(3);

  /// Destination address on mainchain
  @$pb.TagNumber(4)
  $core.String get destination => $_getSZ(3);
  @$pb.TagNumber(4)
  set destination($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDestination() => $_has(3);
  @$pb.TagNumber(4)
  void clearDestination() => $_clearField(4);

  /// When the withdrawal was first detected
  @$pb.TagNumber(5)
  $0.Timestamp get detectedAt => $_getN(4);
  @$pb.TagNumber(5)
  set detectedAt($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasDetectedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearDetectedAt() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureDetectedAt() => $_ensure(4);

  /// Block hash if confirmed (optional)
  @$pb.TagNumber(6)
  $core.String get blockHash => $_getSZ(5);
  @$pb.TagNumber(6)
  set blockHash($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBlockHash() => $_has(5);
  @$pb.TagNumber(6)
  void clearBlockHash() => $_clearField(6);
}

/// SidechainService provides API for sidechain monitoring and fast withdrawal detection
class SidechainServiceApi {
  final $pb.RpcClient _client;

  SidechainServiceApi(this._client);

  /// GetDetectedWithdrawals returns all detected fast withdrawal transactions
  $async.Future<GetDetectedWithdrawalsResponse> getDetectedWithdrawals(
          $pb.ClientContext? ctx, GetDetectedWithdrawalsRequest request) =>
      _client.invoke<GetDetectedWithdrawalsResponse>(
          ctx, 'SidechainService', 'GetDetectedWithdrawals', request, GetDetectedWithdrawalsResponse());

  /// GetWithdrawalByTxid returns a specific withdrawal by transaction ID
  $async.Future<GetWithdrawalByTxidResponse> getWithdrawalByTxid(
          $pb.ClientContext? ctx, GetWithdrawalByTxidRequest request) =>
      _client.invoke<GetWithdrawalByTxidResponse>(
          ctx, 'SidechainService', 'GetWithdrawalByTxid', request, GetWithdrawalByTxidResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
