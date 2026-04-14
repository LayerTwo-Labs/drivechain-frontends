//
//  Generated code. Do not modify.
//  source: fast_withdrawal/v1/fast_withdrawal.proto
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
import 'fast_withdrawal.pbenum.dart';

export 'fast_withdrawal.pbenum.dart';

class InitiateFastWithdrawalRequest extends $pb.GeneratedMessage {
  factory InitiateFastWithdrawalRequest({
    $core.String? sidechain,
    $fixnum.Int64? amount,
    $core.String? destination,
  }) {
    final $result = create();
    if (sidechain != null) {
      $result.sidechain = sidechain;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (destination != null) {
      $result.destination = destination;
    }
    return $result;
  }
  InitiateFastWithdrawalRequest._() : super();
  factory InitiateFastWithdrawalRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory InitiateFastWithdrawalRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InitiateFastWithdrawalRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'fast_withdrawal.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'sidechain')
    ..aInt64(2, _omitFieldNames ? '' : 'amount')
    ..aOS(3, _omitFieldNames ? '' : 'destination')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  InitiateFastWithdrawalRequest clone() => InitiateFastWithdrawalRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  InitiateFastWithdrawalRequest copyWith(void Function(InitiateFastWithdrawalRequest) updates) => super.copyWith((message) => updates(message as InitiateFastWithdrawalRequest)) as InitiateFastWithdrawalRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static InitiateFastWithdrawalRequest create() => InitiateFastWithdrawalRequest._();
  InitiateFastWithdrawalRequest createEmptyInstance() => create();
  static $pb.PbList<InitiateFastWithdrawalRequest> createRepeated() => $pb.PbList<InitiateFastWithdrawalRequest>();
  @$core.pragma('dart2js:noInline')
  static InitiateFastWithdrawalRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<InitiateFastWithdrawalRequest>(create);
  static InitiateFastWithdrawalRequest? _defaultInstance;

  /// Sidechain name (thunder, bitnames, bitassets, etc.)
  @$pb.TagNumber(1)
  $core.String get sidechain => $_getSZ(0);
  @$pb.TagNumber(1)
  set sidechain($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechain() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechain() => clearField(1);

  /// Amount in satoshis
  @$pb.TagNumber(2)
  $fixnum.Int64 get amount => $_getI64(1);
  @$pb.TagNumber(2)
  set amount($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => clearField(2);

  /// Destination address on mainchain
  @$pb.TagNumber(3)
  $core.String get destination => $_getSZ(2);
  @$pb.TagNumber(3)
  set destination($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDestination() => $_has(2);
  @$pb.TagNumber(3)
  void clearDestination() => clearField(3);
}

class FastWithdrawalUpdate extends $pb.GeneratedMessage {
  factory FastWithdrawalUpdate({
    FastWithdrawalUpdate_Status? status,
    $core.String? txid,
    $core.String? error,
    $core.String? blockHash,
    $0.Timestamp? timestamp,
    $core.String? message,
  }) {
    final $result = create();
    if (status != null) {
      $result.status = status;
    }
    if (txid != null) {
      $result.txid = txid;
    }
    if (error != null) {
      $result.error = error;
    }
    if (blockHash != null) {
      $result.blockHash = blockHash;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    if (message != null) {
      $result.message = message;
    }
    return $result;
  }
  FastWithdrawalUpdate._() : super();
  factory FastWithdrawalUpdate.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FastWithdrawalUpdate.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FastWithdrawalUpdate', package: const $pb.PackageName(_omitMessageNames ? '' : 'fast_withdrawal.v1'), createEmptyInstance: create)
    ..e<FastWithdrawalUpdate_Status>(1, _omitFieldNames ? '' : 'status', $pb.PbFieldType.OE, defaultOrMaker: FastWithdrawalUpdate_Status.STATUS_UNSPECIFIED, valueOf: FastWithdrawalUpdate_Status.valueOf, enumValues: FastWithdrawalUpdate_Status.values)
    ..aOS(2, _omitFieldNames ? '' : 'txid')
    ..aOS(3, _omitFieldNames ? '' : 'error')
    ..aOS(4, _omitFieldNames ? '' : 'blockHash')
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'timestamp', subBuilder: $0.Timestamp.create)
    ..aOS(6, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FastWithdrawalUpdate clone() => FastWithdrawalUpdate()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FastWithdrawalUpdate copyWith(void Function(FastWithdrawalUpdate) updates) => super.copyWith((message) => updates(message as FastWithdrawalUpdate)) as FastWithdrawalUpdate;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FastWithdrawalUpdate create() => FastWithdrawalUpdate._();
  FastWithdrawalUpdate createEmptyInstance() => create();
  static $pb.PbList<FastWithdrawalUpdate> createRepeated() => $pb.PbList<FastWithdrawalUpdate>();
  @$core.pragma('dart2js:noInline')
  static FastWithdrawalUpdate getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FastWithdrawalUpdate>(create);
  static FastWithdrawalUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  FastWithdrawalUpdate_Status get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(FastWithdrawalUpdate_Status v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => clearField(1);

  /// Transaction ID when detected
  @$pb.TagNumber(2)
  $core.String get txid => $_getSZ(1);
  @$pb.TagNumber(2)
  set txid($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearTxid() => clearField(2);

  /// Error message if failed
  @$pb.TagNumber(3)
  $core.String get error => $_getSZ(2);
  @$pb.TagNumber(3)
  set error($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasError() => $_has(2);
  @$pb.TagNumber(3)
  void clearError() => clearField(3);

  /// Block hash when confirmed
  @$pb.TagNumber(4)
  $core.String get blockHash => $_getSZ(3);
  @$pb.TagNumber(4)
  set blockHash($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasBlockHash() => $_has(3);
  @$pb.TagNumber(4)
  void clearBlockHash() => clearField(4);

  /// Timestamp of this update
  @$pb.TagNumber(5)
  $0.Timestamp get timestamp => $_getN(4);
  @$pb.TagNumber(5)
  set timestamp($0.Timestamp v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimestamp() => clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureTimestamp() => $_ensure(4);

  /// Human-readable status message
  @$pb.TagNumber(6)
  $core.String get message => $_getSZ(5);
  @$pb.TagNumber(6)
  set message($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasMessage() => $_has(5);
  @$pb.TagNumber(6)
  void clearMessage() => clearField(6);
}

class FastWithdrawalServiceApi {
  $pb.RpcClient _client;
  FastWithdrawalServiceApi(this._client);

  $async.Future<FastWithdrawalUpdate> initiateFastWithdrawal($pb.ClientContext? ctx, InitiateFastWithdrawalRequest request) =>
    _client.invoke<FastWithdrawalUpdate>(ctx, 'FastWithdrawalService', 'InitiateFastWithdrawal', request, FastWithdrawalUpdate())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
