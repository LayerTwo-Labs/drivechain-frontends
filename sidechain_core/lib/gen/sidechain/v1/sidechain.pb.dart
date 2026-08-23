//
//  Generated code. Do not modify.
//  source: sidechain/v1/sidechain.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import '../../google/protobuf/timestamp.pb.dart' as $0;

class GetDetectedWithdrawalsRequest extends $pb.GeneratedMessage {
  factory GetDetectedWithdrawalsRequest({
    $core.String? sidechain,
    $core.int? limit,
  }) {
    final $result = create();
    if (sidechain != null) {
      $result.sidechain = sidechain;
    }
    if (limit != null) {
      $result.limit = limit;
    }
    return $result;
  }
  GetDetectedWithdrawalsRequest._() : super();
  factory GetDetectedWithdrawalsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetDetectedWithdrawalsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetDetectedWithdrawalsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'sidechain.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sidechain')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'limit', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetDetectedWithdrawalsRequest clone() => GetDetectedWithdrawalsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetDetectedWithdrawalsRequest copyWith(void Function(GetDetectedWithdrawalsRequest) updates) => super.copyWith((message) => updates(message as GetDetectedWithdrawalsRequest)) as GetDetectedWithdrawalsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDetectedWithdrawalsRequest create() => GetDetectedWithdrawalsRequest._();
  GetDetectedWithdrawalsRequest createEmptyInstance() => create();
  static $pb.PbList<GetDetectedWithdrawalsRequest> createRepeated() => $pb.PbList<GetDetectedWithdrawalsRequest>();
  @$core.pragma('dart2js:noInline')
  static GetDetectedWithdrawalsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetDetectedWithdrawalsRequest>(create);
  static GetDetectedWithdrawalsRequest? _defaultInstance;

  /// Optional filter by sidechain name
  @$pb.TagNumber(1)
  $core.String get sidechain => $_getSZ(0);
  @$pb.TagNumber(1)
  set sidechain($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechain() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechain() => clearField(1);

  /// Optional limit on number of results
  @$pb.TagNumber(2)
  $core.int get limit => $_getIZ(1);
  @$pb.TagNumber(2)
  set limit($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLimit() => $_has(1);
  @$pb.TagNumber(2)
  void clearLimit() => clearField(2);
}

class GetDetectedWithdrawalsResponse extends $pb.GeneratedMessage {
  factory GetDetectedWithdrawalsResponse({
    $core.Iterable<DetectedWithdrawal>? withdrawals,
  }) {
    final $result = create();
    if (withdrawals != null) {
      $result.withdrawals.addAll(withdrawals);
    }
    return $result;
  }
  GetDetectedWithdrawalsResponse._() : super();
  factory GetDetectedWithdrawalsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetDetectedWithdrawalsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetDetectedWithdrawalsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'sidechain.v1'), createEmptyInstance: create)
    ..pc<DetectedWithdrawal>(1, _omitFieldNames ? '' : 'withdrawals', $pb.PbFieldType.PM, subBuilder: DetectedWithdrawal.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetDetectedWithdrawalsResponse clone() => GetDetectedWithdrawalsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetDetectedWithdrawalsResponse copyWith(void Function(GetDetectedWithdrawalsResponse) updates) => super.copyWith((message) => updates(message as GetDetectedWithdrawalsResponse)) as GetDetectedWithdrawalsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetDetectedWithdrawalsResponse create() => GetDetectedWithdrawalsResponse._();
  GetDetectedWithdrawalsResponse createEmptyInstance() => create();
  static $pb.PbList<GetDetectedWithdrawalsResponse> createRepeated() => $pb.PbList<GetDetectedWithdrawalsResponse>();
  @$core.pragma('dart2js:noInline')
  static GetDetectedWithdrawalsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetDetectedWithdrawalsResponse>(create);
  static GetDetectedWithdrawalsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<DetectedWithdrawal> get withdrawals => $_getList(0);
}

class GetWithdrawalByTxidRequest extends $pb.GeneratedMessage {
  factory GetWithdrawalByTxidRequest({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  GetWithdrawalByTxidRequest._() : super();
  factory GetWithdrawalByTxidRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetWithdrawalByTxidRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWithdrawalByTxidRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'sidechain.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetWithdrawalByTxidRequest clone() => GetWithdrawalByTxidRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetWithdrawalByTxidRequest copyWith(void Function(GetWithdrawalByTxidRequest) updates) => super.copyWith((message) => updates(message as GetWithdrawalByTxidRequest)) as GetWithdrawalByTxidRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetWithdrawalByTxidRequest create() => GetWithdrawalByTxidRequest._();
  GetWithdrawalByTxidRequest createEmptyInstance() => create();
  static $pb.PbList<GetWithdrawalByTxidRequest> createRepeated() => $pb.PbList<GetWithdrawalByTxidRequest>();
  @$core.pragma('dart2js:noInline')
  static GetWithdrawalByTxidRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetWithdrawalByTxidRequest>(create);
  static GetWithdrawalByTxidRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class GetWithdrawalByTxidResponse extends $pb.GeneratedMessage {
  factory GetWithdrawalByTxidResponse({
    DetectedWithdrawal? withdrawal,
  }) {
    final $result = create();
    if (withdrawal != null) {
      $result.withdrawal = withdrawal;
    }
    return $result;
  }
  GetWithdrawalByTxidResponse._() : super();
  factory GetWithdrawalByTxidResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetWithdrawalByTxidResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWithdrawalByTxidResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'sidechain.v1'), createEmptyInstance: create)
    ..aOM<DetectedWithdrawal>(1, _omitFieldNames ? '' : 'withdrawal', subBuilder: DetectedWithdrawal.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetWithdrawalByTxidResponse clone() => GetWithdrawalByTxidResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetWithdrawalByTxidResponse copyWith(void Function(GetWithdrawalByTxidResponse) updates) => super.copyWith((message) => updates(message as GetWithdrawalByTxidResponse)) as GetWithdrawalByTxidResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetWithdrawalByTxidResponse create() => GetWithdrawalByTxidResponse._();
  GetWithdrawalByTxidResponse createEmptyInstance() => create();
  static $pb.PbList<GetWithdrawalByTxidResponse> createRepeated() => $pb.PbList<GetWithdrawalByTxidResponse>();
  @$core.pragma('dart2js:noInline')
  static GetWithdrawalByTxidResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetWithdrawalByTxidResponse>(create);
  static GetWithdrawalByTxidResponse? _defaultInstance;

  @$pb.TagNumber(1)
  DetectedWithdrawal get withdrawal => $_getN(0);
  @$pb.TagNumber(1)
  set withdrawal(DetectedWithdrawal v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasWithdrawal() => $_has(0);
  @$pb.TagNumber(1)
  void clearWithdrawal() => clearField(1);
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
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (sidechain != null) {
      $result.sidechain = sidechain;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (destination != null) {
      $result.destination = destination;
    }
    if (detectedAt != null) {
      $result.detectedAt = detectedAt;
    }
    if (blockHash != null) {
      $result.blockHash = blockHash;
    }
    return $result;
  }
  DetectedWithdrawal._() : super();
  factory DetectedWithdrawal.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DetectedWithdrawal.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DetectedWithdrawal', package: const $pb.PackageName(_omitMessageNames ? '' : 'sidechain.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aOS(2, _omitFieldNames ? '' : 'sidechain')
    ..aInt64(3, _omitFieldNames ? '' : 'amount')
    ..aOS(4, _omitFieldNames ? '' : 'destination')
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'detectedAt', subBuilder: $0.Timestamp.create)
    ..aOS(6, _omitFieldNames ? '' : 'blockHash')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DetectedWithdrawal clone() => DetectedWithdrawal()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DetectedWithdrawal copyWith(void Function(DetectedWithdrawal) updates) => super.copyWith((message) => updates(message as DetectedWithdrawal)) as DetectedWithdrawal;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DetectedWithdrawal create() => DetectedWithdrawal._();
  DetectedWithdrawal createEmptyInstance() => create();
  static $pb.PbList<DetectedWithdrawal> createRepeated() => $pb.PbList<DetectedWithdrawal>();
  @$core.pragma('dart2js:noInline')
  static DetectedWithdrawal getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DetectedWithdrawal>(create);
  static DetectedWithdrawal? _defaultInstance;

  /// Transaction ID of the withdrawal
  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  /// Sidechain name (thunder, bitnames, etc.)
  @$pb.TagNumber(2)
  $core.String get sidechain => $_getSZ(1);
  @$pb.TagNumber(2)
  set sidechain($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSidechain() => $_has(1);
  @$pb.TagNumber(2)
  void clearSidechain() => clearField(2);

  /// Amount in satoshis
  @$pb.TagNumber(3)
  $fixnum.Int64 get amount => $_getI64(2);
  @$pb.TagNumber(3)
  set amount($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmount() => clearField(3);

  /// Destination address on mainchain
  @$pb.TagNumber(4)
  $core.String get destination => $_getSZ(3);
  @$pb.TagNumber(4)
  set destination($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDestination() => $_has(3);
  @$pb.TagNumber(4)
  void clearDestination() => clearField(4);

  /// When the withdrawal was first detected
  @$pb.TagNumber(5)
  $0.Timestamp get detectedAt => $_getN(4);
  @$pb.TagNumber(5)
  set detectedAt($0.Timestamp v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasDetectedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearDetectedAt() => clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureDetectedAt() => $_ensure(4);

  /// Block hash if confirmed (optional)
  @$pb.TagNumber(6)
  $core.String get blockHash => $_getSZ(5);
  @$pb.TagNumber(6)
  set blockHash($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasBlockHash() => $_has(5);
  @$pb.TagNumber(6)
  void clearBlockHash() => clearField(6);
}

class SidechainServiceApi {
  $pb.RpcClient _client;
  SidechainServiceApi(this._client);

  $async.Future<GetDetectedWithdrawalsResponse> getDetectedWithdrawals($pb.ClientContext? ctx, GetDetectedWithdrawalsRequest request) =>
    _client.invoke<GetDetectedWithdrawalsResponse>(ctx, 'SidechainService', 'GetDetectedWithdrawals', request, GetDetectedWithdrawalsResponse())
  ;
  $async.Future<GetWithdrawalByTxidResponse> getWithdrawalByTxid($pb.ClientContext? ctx, GetWithdrawalByTxidRequest request) =>
    _client.invoke<GetWithdrawalByTxidResponse>(ctx, 'SidechainService', 'GetWithdrawalByTxid', request, GetWithdrawalByTxidResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
