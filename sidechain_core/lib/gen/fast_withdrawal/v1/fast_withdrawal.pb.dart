// This is a generated file - do not edit.
//
// Generated from fast_withdrawal/v1/fast_withdrawal.proto.

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

import 'fast_withdrawal.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'fast_withdrawal.pbenum.dart';

class InitiateFastWithdrawalRequest extends $pb.GeneratedMessage {
  factory InitiateFastWithdrawalRequest({
    $core.String? sidechain,
    $fixnum.Int64? amount,
    $core.String? destination,
  }) {
    final result = InitiateFastWithdrawalRequest._();
    if (sidechain != null) result.sidechain = sidechain;
    if (amount != null) result.amount = amount;
    if (destination != null) result.destination = destination;
    return result;
  }

  InitiateFastWithdrawalRequest._();

  factory InitiateFastWithdrawalRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InitiateFastWithdrawalRequest()..mergeFromBuffer(data, registry);
  factory InitiateFastWithdrawalRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      InitiateFastWithdrawalRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'InitiateFastWithdrawalRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'fast_withdrawal.v1'),
      createEmptyInstance: InitiateFastWithdrawalRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'sidechain')
    ..aInt64(2, _omitFieldNames ? '' : 'amount')
    ..aOS(3, _omitFieldNames ? '' : 'destination')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InitiateFastWithdrawalRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  InitiateFastWithdrawalRequest copyWith(void Function(InitiateFastWithdrawalRequest) updates) =>
      super.copyWith((message) => updates(message as InitiateFastWithdrawalRequest)) as InitiateFastWithdrawalRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use InitiateFastWithdrawalRequest() / InitiateFastWithdrawalRequest.new instead')
  static InitiateFastWithdrawalRequest create() => InitiateFastWithdrawalRequest._();
  static $pb.GeneratedMessage $_createMessage() => InitiateFastWithdrawalRequest._();
  @$core.override
  InitiateFastWithdrawalRequest createEmptyInstance() => InitiateFastWithdrawalRequest._();
  @$core.pragma('dart2js:noInline')
  static InitiateFastWithdrawalRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<InitiateFastWithdrawalRequest>(InitiateFastWithdrawalRequest.$_createMessage);
  static InitiateFastWithdrawalRequest? _defaultInstance;

  /// Sidechain name (thunder, bitnames, bitassets, etc.)
  @$pb.TagNumber(1)
  $core.String get sidechain => $_getSZ(0);
  @$pb.TagNumber(1)
  set sidechain($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSidechain() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechain() => $_clearField(1);

  /// Amount in satoshis
  @$pb.TagNumber(2)
  $fixnum.Int64 get amount => $_getI64(1);
  @$pb.TagNumber(2)
  set amount($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => $_clearField(2);

  /// Destination address on mainchain
  @$pb.TagNumber(3)
  $core.String get destination => $_getSZ(2);
  @$pb.TagNumber(3)
  set destination($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDestination() => $_has(2);
  @$pb.TagNumber(3)
  void clearDestination() => $_clearField(3);
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
    final result = FastWithdrawalUpdate._();
    if (status != null) result.status = status;
    if (txid != null) result.txid = txid;
    if (error != null) result.error = error;
    if (blockHash != null) result.blockHash = blockHash;
    if (timestamp != null) result.timestamp = timestamp;
    if (message != null) result.message = message;
    return result;
  }

  FastWithdrawalUpdate._();

  factory FastWithdrawalUpdate.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FastWithdrawalUpdate()..mergeFromBuffer(data, registry);
  factory FastWithdrawalUpdate.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FastWithdrawalUpdate()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FastWithdrawalUpdate',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'fast_withdrawal.v1'),
      createEmptyInstance: FastWithdrawalUpdate.$_createMessage)
    ..aE<FastWithdrawalUpdate_Status>(1, _omitFieldNames ? '' : 'status',
        enumValues: FastWithdrawalUpdate_Status.values)
    ..aOS(2, _omitFieldNames ? '' : 'txid')
    ..aOS(3, _omitFieldNames ? '' : 'error')
    ..aOS(4, _omitFieldNames ? '' : 'blockHash')
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'timestamp', subBuilder: $0.Timestamp.$_createMessage)
    ..aOS(6, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FastWithdrawalUpdate clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FastWithdrawalUpdate copyWith(void Function(FastWithdrawalUpdate) updates) =>
      super.copyWith((message) => updates(message as FastWithdrawalUpdate)) as FastWithdrawalUpdate;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FastWithdrawalUpdate() / FastWithdrawalUpdate.new instead')
  static FastWithdrawalUpdate create() => FastWithdrawalUpdate._();
  static $pb.GeneratedMessage $_createMessage() => FastWithdrawalUpdate._();
  @$core.override
  FastWithdrawalUpdate createEmptyInstance() => FastWithdrawalUpdate._();
  @$core.pragma('dart2js:noInline')
  static FastWithdrawalUpdate getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FastWithdrawalUpdate>(FastWithdrawalUpdate.$_createMessage);
  static FastWithdrawalUpdate? _defaultInstance;

  @$pb.TagNumber(1)
  FastWithdrawalUpdate_Status get status => $_getN(0);
  @$pb.TagNumber(1)
  set status(FastWithdrawalUpdate_Status value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStatus() => $_has(0);
  @$pb.TagNumber(1)
  void clearStatus() => $_clearField(1);

  /// Transaction ID when detected
  @$pb.TagNumber(2)
  $core.String get txid => $_getSZ(1);
  @$pb.TagNumber(2)
  set txid($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearTxid() => $_clearField(2);

  /// Error message if failed
  @$pb.TagNumber(3)
  $core.String get error => $_getSZ(2);
  @$pb.TagNumber(3)
  set error($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasError() => $_has(2);
  @$pb.TagNumber(3)
  void clearError() => $_clearField(3);

  /// Block hash when confirmed
  @$pb.TagNumber(4)
  $core.String get blockHash => $_getSZ(3);
  @$pb.TagNumber(4)
  set blockHash($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBlockHash() => $_has(3);
  @$pb.TagNumber(4)
  void clearBlockHash() => $_clearField(4);

  /// Timestamp of this update
  @$pb.TagNumber(5)
  $0.Timestamp get timestamp => $_getN(4);
  @$pb.TagNumber(5)
  set timestamp($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimestamp() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureTimestamp() => $_ensure(4);

  /// Human-readable status message
  @$pb.TagNumber(6)
  $core.String get message => $_getSZ(5);
  @$pb.TagNumber(6)
  set message($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMessage() => $_has(5);
  @$pb.TagNumber(6)
  void clearMessage() => $_clearField(6);
}

/// FastWithdrawalService handles fast withdrawal initiation and monitoring
class FastWithdrawalServiceApi {
  final $pb.RpcClient _client;

  FastWithdrawalServiceApi(this._client);

  /// InitiateFastWithdrawal starts a fast withdrawal and streams status updates
  $async.Future<FastWithdrawalUpdate> initiateFastWithdrawal(
          $pb.ClientContext? ctx, InitiateFastWithdrawalRequest request) =>
      _client.invoke<FastWithdrawalUpdate>(
          ctx, 'FastWithdrawalService', 'InitiateFastWithdrawal', request, FastWithdrawalUpdate());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
