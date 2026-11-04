// This is a generated file - do not edit.
//
// Generated from bitwindowd/v1/bitwindowd.proto.

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
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $1;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart' as $0;

import 'bitwindowd.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'bitwindowd.pbenum.dart';

class BitwindowdServiceStopRequest extends $pb.GeneratedMessage {
  factory BitwindowdServiceStopRequest({
    $core.bool? skipDownstream,
  }) {
    final result = BitwindowdServiceStopRequest._();
    if (skipDownstream != null) result.skipDownstream = skipDownstream;
    return result;
  }

  BitwindowdServiceStopRequest._();

  factory BitwindowdServiceStopRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BitwindowdServiceStopRequest()..mergeFromBuffer(data, registry);
  factory BitwindowdServiceStopRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BitwindowdServiceStopRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BitwindowdServiceStopRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: BitwindowdServiceStopRequest.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'skipDownstream')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BitwindowdServiceStopRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BitwindowdServiceStopRequest copyWith(void Function(BitwindowdServiceStopRequest) updates) =>
      super.copyWith((message) => updates(message as BitwindowdServiceStopRequest)) as BitwindowdServiceStopRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BitwindowdServiceStopRequest() / BitwindowdServiceStopRequest.new instead')
  static BitwindowdServiceStopRequest create() => BitwindowdServiceStopRequest._();
  static $pb.GeneratedMessage $_createMessage() => BitwindowdServiceStopRequest._();
  @$core.override
  BitwindowdServiceStopRequest createEmptyInstance() => BitwindowdServiceStopRequest._();
  @$core.pragma('dart2js:noInline')
  static BitwindowdServiceStopRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BitwindowdServiceStopRequest>(BitwindowdServiceStopRequest.$_createMessage);
  static BitwindowdServiceStopRequest? _defaultInstance;

  /// If true, only stop bitwindow itself without stopping downstream services (enforcer, bitcoind)
  @$pb.TagNumber(1)
  $core.bool get skipDownstream => $_getBF(0);
  @$pb.TagNumber(1)
  set skipDownstream($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSkipDownstream() => $_has(0);
  @$pb.TagNumber(1)
  void clearSkipDownstream() => $_clearField(1);
}

class CreateDenialRequest extends $pb.GeneratedMessage {
  factory CreateDenialRequest({
    $core.String? txid,
    $core.int? vout,
    $core.int? delaySeconds,
    $core.int? numHops,
    $core.Iterable<$fixnum.Int64>? targetUtxoSizes,
  }) {
    final result = CreateDenialRequest._();
    if (txid != null) result.txid = txid;
    if (vout != null) result.vout = vout;
    if (delaySeconds != null) result.delaySeconds = delaySeconds;
    if (numHops != null) result.numHops = numHops;
    if (targetUtxoSizes != null) result.targetUtxoSizes.addAll(targetUtxoSizes);
    return result;
  }

  CreateDenialRequest._();

  factory CreateDenialRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateDenialRequest()..mergeFromBuffer(data, registry);
  factory CreateDenialRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateDenialRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateDenialRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: CreateDenialRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aI(2, _omitFieldNames ? '' : 'vout', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'delaySeconds')
    ..aI(4, _omitFieldNames ? '' : 'numHops')
    ..p<$fixnum.Int64>(5, _omitFieldNames ? '' : 'targetUtxoSizes', $pb.PbFieldType.K6)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateDenialRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateDenialRequest copyWith(void Function(CreateDenialRequest) updates) =>
      super.copyWith((message) => updates(message as CreateDenialRequest)) as CreateDenialRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateDenialRequest() / CreateDenialRequest.new instead')
  static CreateDenialRequest create() => CreateDenialRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateDenialRequest._();
  @$core.override
  CreateDenialRequest createEmptyInstance() => CreateDenialRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateDenialRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateDenialRequest>(CreateDenialRequest.$_createMessage);
  static CreateDenialRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get vout => $_getIZ(1);
  @$pb.TagNumber(2)
  set vout($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearVout() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get delaySeconds => $_getIZ(2);
  @$pb.TagNumber(3)
  set delaySeconds($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDelaySeconds() => $_has(2);
  @$pb.TagNumber(3)
  void clearDelaySeconds() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get numHops => $_getIZ(3);
  @$pb.TagNumber(4)
  set numHops($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNumHops() => $_has(3);
  @$pb.TagNumber(4)
  void clearNumHops() => $_clearField(4);

  /// If set, create UTXOs of these specific sizes (in satoshis).
  /// Each hop will try to create one UTXO of the next target size.
  /// Max length should equal num_hops.
  @$pb.TagNumber(5)
  $pb.PbList<$fixnum.Int64> get targetUtxoSizes => $_getList(4);
}

class DenialInfo extends $pb.GeneratedMessage {
  factory DenialInfo({
    $fixnum.Int64? id,
    $core.int? numHops,
    $core.int? delaySeconds,
    $0.Timestamp? createTime,
    $0.Timestamp? cancelTime,
    $core.String? cancelReason,
    $0.Timestamp? nextExecutionTime,
    $core.Iterable<ExecutedDenial>? executions,
    $core.int? hopsCompleted,
    $core.bool? isChange,
    $core.Iterable<$fixnum.Int64>? targetUtxoSizes,
    $0.Timestamp? pausedAt,
  }) {
    final result = DenialInfo._();
    if (id != null) result.id = id;
    if (numHops != null) result.numHops = numHops;
    if (delaySeconds != null) result.delaySeconds = delaySeconds;
    if (createTime != null) result.createTime = createTime;
    if (cancelTime != null) result.cancelTime = cancelTime;
    if (cancelReason != null) result.cancelReason = cancelReason;
    if (nextExecutionTime != null) result.nextExecutionTime = nextExecutionTime;
    if (executions != null) result.executions.addAll(executions);
    if (hopsCompleted != null) result.hopsCompleted = hopsCompleted;
    if (isChange != null) result.isChange = isChange;
    if (targetUtxoSizes != null) result.targetUtxoSizes.addAll(targetUtxoSizes);
    if (pausedAt != null) result.pausedAt = pausedAt;
    return result;
  }

  DenialInfo._();

  factory DenialInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DenialInfo()..mergeFromBuffer(data, registry);
  factory DenialInfo.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DenialInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DenialInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: DenialInfo.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aI(2, _omitFieldNames ? '' : 'numHops')
    ..aI(3, _omitFieldNames ? '' : 'delaySeconds')
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'createTime', subBuilder: $0.Timestamp.$_createMessage)
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'cancelTime', subBuilder: $0.Timestamp.$_createMessage)
    ..aOS(6, _omitFieldNames ? '' : 'cancelReason')
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'nextExecutionTime', subBuilder: $0.Timestamp.$_createMessage)
    ..pPM<ExecutedDenial>(8, _omitFieldNames ? '' : 'executions', subBuilder: ExecutedDenial.$_createMessage)
    ..aI(9, _omitFieldNames ? '' : 'hopsCompleted', fieldType: $pb.PbFieldType.OU3)
    ..aOB(10, _omitFieldNames ? '' : 'isChange')
    ..p<$fixnum.Int64>(11, _omitFieldNames ? '' : 'targetUtxoSizes', $pb.PbFieldType.K6)
    ..aOM<$0.Timestamp>(12, _omitFieldNames ? '' : 'pausedAt', subBuilder: $0.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DenialInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DenialInfo copyWith(void Function(DenialInfo) updates) =>
      super.copyWith((message) => updates(message as DenialInfo)) as DenialInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DenialInfo() / DenialInfo.new instead')
  static DenialInfo create() => DenialInfo._();
  static $pb.GeneratedMessage $_createMessage() => DenialInfo._();
  @$core.override
  DenialInfo createEmptyInstance() => DenialInfo._();
  @$core.pragma('dart2js:noInline')
  static DenialInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DenialInfo>(DenialInfo.$_createMessage);
  static DenialInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get numHops => $_getIZ(1);
  @$pb.TagNumber(2)
  set numHops($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNumHops() => $_has(1);
  @$pb.TagNumber(2)
  void clearNumHops() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get delaySeconds => $_getIZ(2);
  @$pb.TagNumber(3)
  set delaySeconds($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDelaySeconds() => $_has(2);
  @$pb.TagNumber(3)
  void clearDelaySeconds() => $_clearField(3);

  @$pb.TagNumber(4)
  $0.Timestamp get createTime => $_getN(3);
  @$pb.TagNumber(4)
  set createTime($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCreateTime() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreateTime() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureCreateTime() => $_ensure(3);

  @$pb.TagNumber(5)
  $0.Timestamp get cancelTime => $_getN(4);
  @$pb.TagNumber(5)
  set cancelTime($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasCancelTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearCancelTime() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureCancelTime() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.String get cancelReason => $_getSZ(5);
  @$pb.TagNumber(6)
  set cancelReason($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCancelReason() => $_has(5);
  @$pb.TagNumber(6)
  void clearCancelReason() => $_clearField(6);

  @$pb.TagNumber(7)
  $0.Timestamp get nextExecutionTime => $_getN(6);
  @$pb.TagNumber(7)
  set nextExecutionTime($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasNextExecutionTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearNextExecutionTime() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureNextExecutionTime() => $_ensure(6);

  @$pb.TagNumber(8)
  $pb.PbList<ExecutedDenial> get executions => $_getList(7);

  @$pb.TagNumber(9)
  $core.int get hopsCompleted => $_getIZ(8);
  @$pb.TagNumber(9)
  set hopsCompleted($core.int value) => $_setUnsignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasHopsCompleted() => $_has(8);
  @$pb.TagNumber(9)
  void clearHopsCompleted() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get isChange => $_getBF(9);
  @$pb.TagNumber(10)
  set isChange($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasIsChange() => $_has(9);
  @$pb.TagNumber(10)
  void clearIsChange() => $_clearField(10);

  /// Target UTXO sizes user wants to create (one per hop)
  @$pb.TagNumber(11)
  $pb.PbList<$fixnum.Int64> get targetUtxoSizes => $_getList(10);

  @$pb.TagNumber(12)
  $0.Timestamp get pausedAt => $_getN(11);
  @$pb.TagNumber(12)
  set pausedAt($0.Timestamp value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasPausedAt() => $_has(11);
  @$pb.TagNumber(12)
  void clearPausedAt() => $_clearField(12);
  @$pb.TagNumber(12)
  $0.Timestamp ensurePausedAt() => $_ensure(11);
}

class ExecutedDenial extends $pb.GeneratedMessage {
  factory ExecutedDenial({
    $fixnum.Int64? id,
    $fixnum.Int64? denialId,
    $core.String? fromTxid,
    $core.int? fromVout,
    $core.String? toTxid,
    $0.Timestamp? createTime,
  }) {
    final result = ExecutedDenial._();
    if (id != null) result.id = id;
    if (denialId != null) result.denialId = denialId;
    if (fromTxid != null) result.fromTxid = fromTxid;
    if (fromVout != null) result.fromVout = fromVout;
    if (toTxid != null) result.toTxid = toTxid;
    if (createTime != null) result.createTime = createTime;
    return result;
  }

  ExecutedDenial._();

  factory ExecutedDenial.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExecutedDenial()..mergeFromBuffer(data, registry);
  factory ExecutedDenial.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExecutedDenial()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ExecutedDenial',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: ExecutedDenial.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aInt64(2, _omitFieldNames ? '' : 'denialId')
    ..aOS(3, _omitFieldNames ? '' : 'fromTxid')
    ..aI(4, _omitFieldNames ? '' : 'fromVout', fieldType: $pb.PbFieldType.OU3)
    ..aOS(5, _omitFieldNames ? '' : 'toTxid')
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'createTime', subBuilder: $0.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExecutedDenial clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExecutedDenial copyWith(void Function(ExecutedDenial) updates) =>
      super.copyWith((message) => updates(message as ExecutedDenial)) as ExecutedDenial;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ExecutedDenial() / ExecutedDenial.new instead')
  static ExecutedDenial create() => ExecutedDenial._();
  static $pb.GeneratedMessage $_createMessage() => ExecutedDenial._();
  @$core.override
  ExecutedDenial createEmptyInstance() => ExecutedDenial._();
  @$core.pragma('dart2js:noInline')
  static ExecutedDenial getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ExecutedDenial>(ExecutedDenial.$_createMessage);
  static ExecutedDenial? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get denialId => $_getI64(1);
  @$pb.TagNumber(2)
  set denialId($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDenialId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDenialId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fromTxid => $_getSZ(2);
  @$pb.TagNumber(3)
  set fromTxid($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFromTxid() => $_has(2);
  @$pb.TagNumber(3)
  void clearFromTxid() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get fromVout => $_getIZ(3);
  @$pb.TagNumber(4)
  set fromVout($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFromVout() => $_has(3);
  @$pb.TagNumber(4)
  void clearFromVout() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get toTxid => $_getSZ(4);
  @$pb.TagNumber(5)
  set toTxid($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasToTxid() => $_has(4);
  @$pb.TagNumber(5)
  void clearToTxid() => $_clearField(5);

  @$pb.TagNumber(6)
  $0.Timestamp get createTime => $_getN(5);
  @$pb.TagNumber(6)
  set createTime($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasCreateTime() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreateTime() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureCreateTime() => $_ensure(5);
}

class CancelDenialRequest extends $pb.GeneratedMessage {
  factory CancelDenialRequest({
    $fixnum.Int64? id,
  }) {
    final result = CancelDenialRequest._();
    if (id != null) result.id = id;
    return result;
  }

  CancelDenialRequest._();

  factory CancelDenialRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CancelDenialRequest()..mergeFromBuffer(data, registry);
  factory CancelDenialRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CancelDenialRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CancelDenialRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: CancelDenialRequest.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelDenialRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelDenialRequest copyWith(void Function(CancelDenialRequest) updates) =>
      super.copyWith((message) => updates(message as CancelDenialRequest)) as CancelDenialRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CancelDenialRequest() / CancelDenialRequest.new instead')
  static CancelDenialRequest create() => CancelDenialRequest._();
  static $pb.GeneratedMessage $_createMessage() => CancelDenialRequest._();
  @$core.override
  CancelDenialRequest createEmptyInstance() => CancelDenialRequest._();
  @$core.pragma('dart2js:noInline')
  static CancelDenialRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CancelDenialRequest>(CancelDenialRequest.$_createMessage);
  static CancelDenialRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class PauseDenialRequest extends $pb.GeneratedMessage {
  factory PauseDenialRequest({
    $fixnum.Int64? id,
  }) {
    final result = PauseDenialRequest._();
    if (id != null) result.id = id;
    return result;
  }

  PauseDenialRequest._();

  factory PauseDenialRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PauseDenialRequest()..mergeFromBuffer(data, registry);
  factory PauseDenialRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PauseDenialRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PauseDenialRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: PauseDenialRequest.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PauseDenialRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PauseDenialRequest copyWith(void Function(PauseDenialRequest) updates) =>
      super.copyWith((message) => updates(message as PauseDenialRequest)) as PauseDenialRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PauseDenialRequest() / PauseDenialRequest.new instead')
  static PauseDenialRequest create() => PauseDenialRequest._();
  static $pb.GeneratedMessage $_createMessage() => PauseDenialRequest._();
  @$core.override
  PauseDenialRequest createEmptyInstance() => PauseDenialRequest._();
  @$core.pragma('dart2js:noInline')
  static PauseDenialRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PauseDenialRequest>(PauseDenialRequest.$_createMessage);
  static PauseDenialRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class ResumeDenialRequest extends $pb.GeneratedMessage {
  factory ResumeDenialRequest({
    $fixnum.Int64? id,
  }) {
    final result = ResumeDenialRequest._();
    if (id != null) result.id = id;
    return result;
  }

  ResumeDenialRequest._();

  factory ResumeDenialRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ResumeDenialRequest()..mergeFromBuffer(data, registry);
  factory ResumeDenialRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ResumeDenialRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ResumeDenialRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: ResumeDenialRequest.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResumeDenialRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ResumeDenialRequest copyWith(void Function(ResumeDenialRequest) updates) =>
      super.copyWith((message) => updates(message as ResumeDenialRequest)) as ResumeDenialRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ResumeDenialRequest() / ResumeDenialRequest.new instead')
  static ResumeDenialRequest create() => ResumeDenialRequest._();
  static $pb.GeneratedMessage $_createMessage() => ResumeDenialRequest._();
  @$core.override
  ResumeDenialRequest createEmptyInstance() => ResumeDenialRequest._();
  @$core.pragma('dart2js:noInline')
  static ResumeDenialRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ResumeDenialRequest>(ResumeDenialRequest.$_createMessage);
  static ResumeDenialRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class CreateAddressBookEntryRequest extends $pb.GeneratedMessage {
  factory CreateAddressBookEntryRequest({
    $core.String? label,
    $core.String? address,
    Direction? direction,
  }) {
    final result = CreateAddressBookEntryRequest._();
    if (label != null) result.label = label;
    if (address != null) result.address = address;
    if (direction != null) result.direction = direction;
    return result;
  }

  CreateAddressBookEntryRequest._();

  factory CreateAddressBookEntryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateAddressBookEntryRequest()..mergeFromBuffer(data, registry);
  factory CreateAddressBookEntryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateAddressBookEntryRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateAddressBookEntryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: CreateAddressBookEntryRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'label')
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..aE<Direction>(3, _omitFieldNames ? '' : 'direction', enumValues: Direction.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateAddressBookEntryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateAddressBookEntryRequest copyWith(void Function(CreateAddressBookEntryRequest) updates) =>
      super.copyWith((message) => updates(message as CreateAddressBookEntryRequest)) as CreateAddressBookEntryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateAddressBookEntryRequest() / CreateAddressBookEntryRequest.new instead')
  static CreateAddressBookEntryRequest create() => CreateAddressBookEntryRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateAddressBookEntryRequest._();
  @$core.override
  CreateAddressBookEntryRequest createEmptyInstance() => CreateAddressBookEntryRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateAddressBookEntryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateAddressBookEntryRequest>(CreateAddressBookEntryRequest.$_createMessage);
  static CreateAddressBookEntryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get label => $_getSZ(0);
  @$pb.TagNumber(1)
  set label($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLabel() => $_has(0);
  @$pb.TagNumber(1)
  void clearLabel() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get address => $_getSZ(1);
  @$pb.TagNumber(2)
  set address($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => $_clearField(2);

  @$pb.TagNumber(3)
  Direction get direction => $_getN(2);
  @$pb.TagNumber(3)
  set direction(Direction value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasDirection() => $_has(2);
  @$pb.TagNumber(3)
  void clearDirection() => $_clearField(3);
}

class CreateAddressBookEntryResponse extends $pb.GeneratedMessage {
  factory CreateAddressBookEntryResponse({
    AddressBookEntry? entry,
  }) {
    final result = CreateAddressBookEntryResponse._();
    if (entry != null) result.entry = entry;
    return result;
  }

  CreateAddressBookEntryResponse._();

  factory CreateAddressBookEntryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateAddressBookEntryResponse()..mergeFromBuffer(data, registry);
  factory CreateAddressBookEntryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateAddressBookEntryResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateAddressBookEntryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: CreateAddressBookEntryResponse.$_createMessage)
    ..aOM<AddressBookEntry>(1, _omitFieldNames ? '' : 'entry', subBuilder: AddressBookEntry.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateAddressBookEntryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateAddressBookEntryResponse copyWith(void Function(CreateAddressBookEntryResponse) updates) =>
      super.copyWith((message) => updates(message as CreateAddressBookEntryResponse)) as CreateAddressBookEntryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateAddressBookEntryResponse() / CreateAddressBookEntryResponse.new instead')
  static CreateAddressBookEntryResponse create() => CreateAddressBookEntryResponse._();
  static $pb.GeneratedMessage $_createMessage() => CreateAddressBookEntryResponse._();
  @$core.override
  CreateAddressBookEntryResponse createEmptyInstance() => CreateAddressBookEntryResponse._();
  @$core.pragma('dart2js:noInline')
  static CreateAddressBookEntryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateAddressBookEntryResponse>(CreateAddressBookEntryResponse.$_createMessage);
  static CreateAddressBookEntryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  AddressBookEntry get entry => $_getN(0);
  @$pb.TagNumber(1)
  set entry(AddressBookEntry value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasEntry() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntry() => $_clearField(1);
  @$pb.TagNumber(1)
  AddressBookEntry ensureEntry() => $_ensure(0);
}

class AddressBookEntry extends $pb.GeneratedMessage {
  factory AddressBookEntry({
    $fixnum.Int64? id,
    $core.String? label,
    $core.String? address,
    Direction? direction,
    $0.Timestamp? createTime,
    $core.String? walletId,
    AddressType? type,
  }) {
    final result = AddressBookEntry._();
    if (id != null) result.id = id;
    if (label != null) result.label = label;
    if (address != null) result.address = address;
    if (direction != null) result.direction = direction;
    if (createTime != null) result.createTime = createTime;
    if (walletId != null) result.walletId = walletId;
    if (type != null) result.type = type;
    return result;
  }

  AddressBookEntry._();

  factory AddressBookEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AddressBookEntry()..mergeFromBuffer(data, registry);
  factory AddressBookEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AddressBookEntry()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddressBookEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: AddressBookEntry.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..aOS(3, _omitFieldNames ? '' : 'address')
    ..aE<Direction>(4, _omitFieldNames ? '' : 'direction', enumValues: Direction.values)
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'createTime', subBuilder: $0.Timestamp.$_createMessage)
    ..aOS(6, _omitFieldNames ? '' : 'walletId')
    ..aE<AddressType>(7, _omitFieldNames ? '' : 'type', enumValues: AddressType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddressBookEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddressBookEntry copyWith(void Function(AddressBookEntry) updates) =>
      super.copyWith((message) => updates(message as AddressBookEntry)) as AddressBookEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AddressBookEntry() / AddressBookEntry.new instead')
  static AddressBookEntry create() => AddressBookEntry._();
  static $pb.GeneratedMessage $_createMessage() => AddressBookEntry._();
  @$core.override
  AddressBookEntry createEmptyInstance() => AddressBookEntry._();
  @$core.pragma('dart2js:noInline')
  static AddressBookEntry getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddressBookEntry>(AddressBookEntry.$_createMessage);
  static AddressBookEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get address => $_getSZ(2);
  @$pb.TagNumber(3)
  set address($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddress() => $_clearField(3);

  @$pb.TagNumber(4)
  Direction get direction => $_getN(3);
  @$pb.TagNumber(4)
  set direction(Direction value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasDirection() => $_has(3);
  @$pb.TagNumber(4)
  void clearDirection() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.Timestamp get createTime => $_getN(4);
  @$pb.TagNumber(5)
  set createTime($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasCreateTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearCreateTime() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureCreateTime() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.String get walletId => $_getSZ(5);
  @$pb.TagNumber(6)
  set walletId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasWalletId() => $_has(5);
  @$pb.TagNumber(6)
  void clearWalletId() => $_clearField(6);

  /// Classified server-side on every read from the stored `address` string.
  /// Not persisted.
  @$pb.TagNumber(7)
  AddressType get type => $_getN(6);
  @$pb.TagNumber(7)
  set type(AddressType value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasType() => $_has(6);
  @$pb.TagNumber(7)
  void clearType() => $_clearField(7);
}

class ListAddressBookResponse extends $pb.GeneratedMessage {
  factory ListAddressBookResponse({
    $core.Iterable<AddressBookEntry>? entries,
  }) {
    final result = ListAddressBookResponse._();
    if (entries != null) result.entries.addAll(entries);
    return result;
  }

  ListAddressBookResponse._();

  factory ListAddressBookResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListAddressBookResponse()..mergeFromBuffer(data, registry);
  factory ListAddressBookResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListAddressBookResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListAddressBookResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: ListAddressBookResponse.$_createMessage)
    ..pPM<AddressBookEntry>(1, _omitFieldNames ? '' : 'entries', subBuilder: AddressBookEntry.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAddressBookResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListAddressBookResponse copyWith(void Function(ListAddressBookResponse) updates) =>
      super.copyWith((message) => updates(message as ListAddressBookResponse)) as ListAddressBookResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListAddressBookResponse() / ListAddressBookResponse.new instead')
  static ListAddressBookResponse create() => ListAddressBookResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListAddressBookResponse._();
  @$core.override
  ListAddressBookResponse createEmptyInstance() => ListAddressBookResponse._();
  @$core.pragma('dart2js:noInline')
  static ListAddressBookResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListAddressBookResponse>(ListAddressBookResponse.$_createMessage);
  static ListAddressBookResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<AddressBookEntry> get entries => $_getList(0);
}

class UpdateAddressBookEntryRequest extends $pb.GeneratedMessage {
  factory UpdateAddressBookEntryRequest({
    $fixnum.Int64? id,
    $core.String? label,
    $core.String? address,
  }) {
    final result = UpdateAddressBookEntryRequest._();
    if (id != null) result.id = id;
    if (label != null) result.label = label;
    if (address != null) result.address = address;
    return result;
  }

  UpdateAddressBookEntryRequest._();

  factory UpdateAddressBookEntryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateAddressBookEntryRequest()..mergeFromBuffer(data, registry);
  factory UpdateAddressBookEntryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateAddressBookEntryRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateAddressBookEntryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: UpdateAddressBookEntryRequest.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..aOS(3, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateAddressBookEntryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateAddressBookEntryRequest copyWith(void Function(UpdateAddressBookEntryRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateAddressBookEntryRequest)) as UpdateAddressBookEntryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UpdateAddressBookEntryRequest() / UpdateAddressBookEntryRequest.new instead')
  static UpdateAddressBookEntryRequest create() => UpdateAddressBookEntryRequest._();
  static $pb.GeneratedMessage $_createMessage() => UpdateAddressBookEntryRequest._();
  @$core.override
  UpdateAddressBookEntryRequest createEmptyInstance() => UpdateAddressBookEntryRequest._();
  @$core.pragma('dart2js:noInline')
  static UpdateAddressBookEntryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateAddressBookEntryRequest>(UpdateAddressBookEntryRequest.$_createMessage);
  static UpdateAddressBookEntryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get address => $_getSZ(2);
  @$pb.TagNumber(3)
  set address($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddress() => $_clearField(3);
}

class DeleteAddressBookEntryRequest extends $pb.GeneratedMessage {
  factory DeleteAddressBookEntryRequest({
    $fixnum.Int64? id,
  }) {
    final result = DeleteAddressBookEntryRequest._();
    if (id != null) result.id = id;
    return result;
  }

  DeleteAddressBookEntryRequest._();

  factory DeleteAddressBookEntryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteAddressBookEntryRequest()..mergeFromBuffer(data, registry);
  factory DeleteAddressBookEntryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteAddressBookEntryRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteAddressBookEntryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: DeleteAddressBookEntryRequest.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteAddressBookEntryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteAddressBookEntryRequest copyWith(void Function(DeleteAddressBookEntryRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteAddressBookEntryRequest)) as DeleteAddressBookEntryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DeleteAddressBookEntryRequest() / DeleteAddressBookEntryRequest.new instead')
  static DeleteAddressBookEntryRequest create() => DeleteAddressBookEntryRequest._();
  static $pb.GeneratedMessage $_createMessage() => DeleteAddressBookEntryRequest._();
  @$core.override
  DeleteAddressBookEntryRequest createEmptyInstance() => DeleteAddressBookEntryRequest._();
  @$core.pragma('dart2js:noInline')
  static DeleteAddressBookEntryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteAddressBookEntryRequest>(DeleteAddressBookEntryRequest.$_createMessage);
  static DeleteAddressBookEntryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class GetSyncInfoResponse extends $pb.GeneratedMessage {
  factory GetSyncInfoResponse({
    $fixnum.Int64? tipBlockHeight,
    $fixnum.Int64? tipBlockTime,
    $core.String? tipBlockHash,
    $0.Timestamp? tipBlockProcessedAt,
    $fixnum.Int64? headerHeight,
    $core.double? syncProgress,
    $core.String? startupMessage,
    $core.bool? waitsForCore,
  }) {
    final result = GetSyncInfoResponse._();
    if (tipBlockHeight != null) result.tipBlockHeight = tipBlockHeight;
    if (tipBlockTime != null) result.tipBlockTime = tipBlockTime;
    if (tipBlockHash != null) result.tipBlockHash = tipBlockHash;
    if (tipBlockProcessedAt != null) result.tipBlockProcessedAt = tipBlockProcessedAt;
    if (headerHeight != null) result.headerHeight = headerHeight;
    if (syncProgress != null) result.syncProgress = syncProgress;
    if (startupMessage != null) result.startupMessage = startupMessage;
    if (waitsForCore != null) result.waitsForCore = waitsForCore;
    return result;
  }

  GetSyncInfoResponse._();

  factory GetSyncInfoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSyncInfoResponse()..mergeFromBuffer(data, registry);
  factory GetSyncInfoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSyncInfoResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSyncInfoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: GetSyncInfoResponse.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'tipBlockHeight')
    ..aInt64(2, _omitFieldNames ? '' : 'tipBlockTime')
    ..aOS(3, _omitFieldNames ? '' : 'tipBlockHash')
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'tipBlockProcessedAt', subBuilder: $0.Timestamp.$_createMessage)
    ..aInt64(5, _omitFieldNames ? '' : 'headerHeight')
    ..aD(6, _omitFieldNames ? '' : 'syncProgress')
    ..aOS(7, _omitFieldNames ? '' : 'startupMessage')
    ..aOB(8, _omitFieldNames ? '' : 'waitsForCore')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSyncInfoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSyncInfoResponse copyWith(void Function(GetSyncInfoResponse) updates) =>
      super.copyWith((message) => updates(message as GetSyncInfoResponse)) as GetSyncInfoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetSyncInfoResponse() / GetSyncInfoResponse.new instead')
  static GetSyncInfoResponse create() => GetSyncInfoResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetSyncInfoResponse._();
  @$core.override
  GetSyncInfoResponse createEmptyInstance() => GetSyncInfoResponse._();
  @$core.pragma('dart2js:noInline')
  static GetSyncInfoResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetSyncInfoResponse>(GetSyncInfoResponse.$_createMessage);
  static GetSyncInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get tipBlockHeight => $_getI64(0);
  @$pb.TagNumber(1)
  set tipBlockHeight($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTipBlockHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearTipBlockHeight() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get tipBlockTime => $_getI64(1);
  @$pb.TagNumber(2)
  set tipBlockTime($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTipBlockTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearTipBlockTime() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get tipBlockHash => $_getSZ(2);
  @$pb.TagNumber(3)
  set tipBlockHash($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTipBlockHash() => $_has(2);
  @$pb.TagNumber(3)
  void clearTipBlockHash() => $_clearField(3);

  @$pb.TagNumber(4)
  $0.Timestamp get tipBlockProcessedAt => $_getN(3);
  @$pb.TagNumber(4)
  set tipBlockProcessedAt($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasTipBlockProcessedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearTipBlockProcessedAt() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureTipBlockProcessedAt() => $_ensure(3);

  @$pb.TagNumber(5)
  $fixnum.Int64 get headerHeight => $_getI64(4);
  @$pb.TagNumber(5)
  set headerHeight($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHeaderHeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearHeaderHeight() => $_clearField(5);

  /// sync progress between 0 and 1
  @$pb.TagNumber(6)
  $core.double get syncProgress => $_getN(5);
  @$pb.TagNumber(6)
  set syncProgress($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSyncProgress() => $_has(5);
  @$pb.TagNumber(6)
  void clearSyncProgress() => $_clearField(6);

  /// Non-empty while bitcoind is in a startup phase (e.g. "Verifying blocks…",
  /// "Rescanning…", "Loading wallet"). When set, the numeric height fields are
  /// 0/0 and the UI should render this message instead of "0/0 blocks".
  @$pb.TagNumber(7)
  $core.String get startupMessage => $_getSZ(6);
  @$pb.TagNumber(7)
  set startupMessage($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStartupMessage() => $_has(6);
  @$pb.TagNumber(7)
  void clearStartupMessage() => $_clearField(7);

  /// True while the block scan holds off until Bitcoin Core leaves initial
  /// block download. The height fields stand still, so the UI reports the wait
  /// instead of a progress bar at 0%.
  @$pb.TagNumber(8)
  $core.bool get waitsForCore => $_getBF(7);
  @$pb.TagNumber(8)
  set waitsForCore($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasWaitsForCore() => $_has(7);
  @$pb.TagNumber(8)
  void clearWaitsForCore() => $_clearField(8);
}

/// Request to set a transaction note
class SetTransactionNoteRequest extends $pb.GeneratedMessage {
  factory SetTransactionNoteRequest({
    $core.String? txid,
    $core.String? note,
    $core.String? walletId,
  }) {
    final result = SetTransactionNoteRequest._();
    if (txid != null) result.txid = txid;
    if (note != null) result.note = note;
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  SetTransactionNoteRequest._();

  factory SetTransactionNoteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetTransactionNoteRequest()..mergeFromBuffer(data, registry);
  factory SetTransactionNoteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetTransactionNoteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetTransactionNoteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: SetTransactionNoteRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aOS(2, _omitFieldNames ? '' : 'note')
    ..aOS(3, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetTransactionNoteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetTransactionNoteRequest copyWith(void Function(SetTransactionNoteRequest) updates) =>
      super.copyWith((message) => updates(message as SetTransactionNoteRequest)) as SetTransactionNoteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetTransactionNoteRequest() / SetTransactionNoteRequest.new instead')
  static SetTransactionNoteRequest create() => SetTransactionNoteRequest._();
  static $pb.GeneratedMessage $_createMessage() => SetTransactionNoteRequest._();
  @$core.override
  SetTransactionNoteRequest createEmptyInstance() => SetTransactionNoteRequest._();
  @$core.pragma('dart2js:noInline')
  static SetTransactionNoteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetTransactionNoteRequest>(SetTransactionNoteRequest.$_createMessage);
  static SetTransactionNoteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get note => $_getSZ(1);
  @$pb.TagNumber(2)
  set note($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNote() => $_has(1);
  @$pb.TagNumber(2)
  void clearNote() => $_clearField(2);

  /// Notes are per-wallet: the same transaction can appear in two of the user's
  /// wallets, and a note written on one must not show on the other.
  @$pb.TagNumber(3)
  $core.String get walletId => $_getSZ(2);
  @$pb.TagNumber(3)
  set walletId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWalletId() => $_has(2);
  @$pb.TagNumber(3)
  void clearWalletId() => $_clearField(3);
}

class ExportLabelsResponse extends $pb.GeneratedMessage {
  factory ExportLabelsResponse({
    $core.String? jsonl,
  }) {
    final result = ExportLabelsResponse._();
    if (jsonl != null) result.jsonl = jsonl;
    return result;
  }

  ExportLabelsResponse._();

  factory ExportLabelsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExportLabelsResponse()..mergeFromBuffer(data, registry);
  factory ExportLabelsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExportLabelsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ExportLabelsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: ExportLabelsResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'jsonl')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportLabelsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExportLabelsResponse copyWith(void Function(ExportLabelsResponse) updates) =>
      super.copyWith((message) => updates(message as ExportLabelsResponse)) as ExportLabelsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ExportLabelsResponse() / ExportLabelsResponse.new instead')
  static ExportLabelsResponse create() => ExportLabelsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ExportLabelsResponse._();
  @$core.override
  ExportLabelsResponse createEmptyInstance() => ExportLabelsResponse._();
  @$core.pragma('dart2js:noInline')
  static ExportLabelsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ExportLabelsResponse>(ExportLabelsResponse.$_createMessage);
  static ExportLabelsResponse? _defaultInstance;

  /// BIP329 JSONL: one JSON object per line.
  @$pb.TagNumber(1)
  $core.String get jsonl => $_getSZ(0);
  @$pb.TagNumber(1)
  set jsonl($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasJsonl() => $_has(0);
  @$pb.TagNumber(1)
  void clearJsonl() => $_clearField(1);
}

class ImportLabelsRequest extends $pb.GeneratedMessage {
  factory ImportLabelsRequest({
    $core.String? jsonl,
  }) {
    final result = ImportLabelsRequest._();
    if (jsonl != null) result.jsonl = jsonl;
    return result;
  }

  ImportLabelsRequest._();

  factory ImportLabelsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportLabelsRequest()..mergeFromBuffer(data, registry);
  factory ImportLabelsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportLabelsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportLabelsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: ImportLabelsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'jsonl')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportLabelsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportLabelsRequest copyWith(void Function(ImportLabelsRequest) updates) =>
      super.copyWith((message) => updates(message as ImportLabelsRequest)) as ImportLabelsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ImportLabelsRequest() / ImportLabelsRequest.new instead')
  static ImportLabelsRequest create() => ImportLabelsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ImportLabelsRequest._();
  @$core.override
  ImportLabelsRequest createEmptyInstance() => ImportLabelsRequest._();
  @$core.pragma('dart2js:noInline')
  static ImportLabelsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportLabelsRequest>(ImportLabelsRequest.$_createMessage);
  static ImportLabelsRequest? _defaultInstance;

  /// BIP329 JSONL: one JSON object per line.
  @$pb.TagNumber(1)
  $core.String get jsonl => $_getSZ(0);
  @$pb.TagNumber(1)
  set jsonl($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasJsonl() => $_has(0);
  @$pb.TagNumber(1)
  void clearJsonl() => $_clearField(1);
}

class ImportLabelsResponse extends $pb.GeneratedMessage {
  factory ImportLabelsResponse({
    $fixnum.Int64? importedAddresses,
    $fixnum.Int64? importedTransactions,
    $fixnum.Int64? importedOutputs,
    $fixnum.Int64? skipped,
  }) {
    final result = ImportLabelsResponse._();
    if (importedAddresses != null) result.importedAddresses = importedAddresses;
    if (importedTransactions != null) result.importedTransactions = importedTransactions;
    if (importedOutputs != null) result.importedOutputs = importedOutputs;
    if (skipped != null) result.skipped = skipped;
    return result;
  }

  ImportLabelsResponse._();

  factory ImportLabelsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportLabelsResponse()..mergeFromBuffer(data, registry);
  factory ImportLabelsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportLabelsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportLabelsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: ImportLabelsResponse.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'importedAddresses')
    ..aInt64(2, _omitFieldNames ? '' : 'importedTransactions')
    ..aInt64(3, _omitFieldNames ? '' : 'importedOutputs')
    ..aInt64(4, _omitFieldNames ? '' : 'skipped')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportLabelsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportLabelsResponse copyWith(void Function(ImportLabelsResponse) updates) =>
      super.copyWith((message) => updates(message as ImportLabelsResponse)) as ImportLabelsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ImportLabelsResponse() / ImportLabelsResponse.new instead')
  static ImportLabelsResponse create() => ImportLabelsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ImportLabelsResponse._();
  @$core.override
  ImportLabelsResponse createEmptyInstance() => ImportLabelsResponse._();
  @$core.pragma('dart2js:noInline')
  static ImportLabelsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImportLabelsResponse>(ImportLabelsResponse.$_createMessage);
  static ImportLabelsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get importedAddresses => $_getI64(0);
  @$pb.TagNumber(1)
  set importedAddresses($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasImportedAddresses() => $_has(0);
  @$pb.TagNumber(1)
  void clearImportedAddresses() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get importedTransactions => $_getI64(1);
  @$pb.TagNumber(2)
  set importedTransactions($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasImportedTransactions() => $_has(1);
  @$pb.TagNumber(2)
  void clearImportedTransactions() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get importedOutputs => $_getI64(2);
  @$pb.TagNumber(3)
  set importedOutputs($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasImportedOutputs() => $_has(2);
  @$pb.TagNumber(3)
  void clearImportedOutputs() => $_clearField(3);

  /// Lines skipped because they were blank, malformed, an unsupported type,
  /// or had an empty label/ref.
  @$pb.TagNumber(4)
  $fixnum.Int64 get skipped => $_getI64(3);
  @$pb.TagNumber(4)
  set skipped($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSkipped() => $_has(3);
  @$pb.TagNumber(4)
  void clearSkipped() => $_clearField(4);
}

class GetFireplaceStatsResponse extends $pb.GeneratedMessage {
  factory GetFireplaceStatsResponse({
    $fixnum.Int64? transactionCount24h,
    $fixnum.Int64? coinnewsCount7d,
    $fixnum.Int64? blockCount24h,
  }) {
    final result = GetFireplaceStatsResponse._();
    if (transactionCount24h != null) result.transactionCount24h = transactionCount24h;
    if (coinnewsCount7d != null) result.coinnewsCount7d = coinnewsCount7d;
    if (blockCount24h != null) result.blockCount24h = blockCount24h;
    return result;
  }

  GetFireplaceStatsResponse._();

  factory GetFireplaceStatsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetFireplaceStatsResponse()..mergeFromBuffer(data, registry);
  factory GetFireplaceStatsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetFireplaceStatsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetFireplaceStatsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: GetFireplaceStatsResponse.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'transactionCount24h', protoName: 'transaction_count_24h')
    ..aInt64(2, _omitFieldNames ? '' : 'coinnewsCount7d', protoName: 'coinnews_count_7d')
    ..aInt64(3, _omitFieldNames ? '' : 'blockCount24h', protoName: 'block_count_24h')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFireplaceStatsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFireplaceStatsResponse copyWith(void Function(GetFireplaceStatsResponse) updates) =>
      super.copyWith((message) => updates(message as GetFireplaceStatsResponse)) as GetFireplaceStatsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetFireplaceStatsResponse() / GetFireplaceStatsResponse.new instead')
  static GetFireplaceStatsResponse create() => GetFireplaceStatsResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetFireplaceStatsResponse._();
  @$core.override
  GetFireplaceStatsResponse createEmptyInstance() => GetFireplaceStatsResponse._();
  @$core.pragma('dart2js:noInline')
  static GetFireplaceStatsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetFireplaceStatsResponse>(GetFireplaceStatsResponse.$_createMessage);
  static GetFireplaceStatsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get transactionCount24h => $_getI64(0);
  @$pb.TagNumber(1)
  set transactionCount24h($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTransactionCount24h() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransactionCount24h() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get coinnewsCount7d => $_getI64(1);
  @$pb.TagNumber(2)
  set coinnewsCount7d($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCoinnewsCount7d() => $_has(1);
  @$pb.TagNumber(2)
  void clearCoinnewsCount7d() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get blockCount24h => $_getI64(2);
  @$pb.TagNumber(3)
  set blockCount24h($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBlockCount24h() => $_has(2);
  @$pb.TagNumber(3)
  void clearBlockCount24h() => $_clearField(3);
}

class SetMempoolWatchRequest extends $pb.GeneratedMessage {
  factory SetMempoolWatchRequest({
    $core.bool? enabled,
  }) {
    final result = SetMempoolWatchRequest._();
    if (enabled != null) result.enabled = enabled;
    return result;
  }

  SetMempoolWatchRequest._();

  factory SetMempoolWatchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetMempoolWatchRequest()..mergeFromBuffer(data, registry);
  factory SetMempoolWatchRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetMempoolWatchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetMempoolWatchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: SetMempoolWatchRequest.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'enabled')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetMempoolWatchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetMempoolWatchRequest copyWith(void Function(SetMempoolWatchRequest) updates) =>
      super.copyWith((message) => updates(message as SetMempoolWatchRequest)) as SetMempoolWatchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetMempoolWatchRequest() / SetMempoolWatchRequest.new instead')
  static SetMempoolWatchRequest create() => SetMempoolWatchRequest._();
  static $pb.GeneratedMessage $_createMessage() => SetMempoolWatchRequest._();
  @$core.override
  SetMempoolWatchRequest createEmptyInstance() => SetMempoolWatchRequest._();
  @$core.pragma('dart2js:noInline')
  static SetMempoolWatchRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetMempoolWatchRequest>(SetMempoolWatchRequest.$_createMessage);
  static SetMempoolWatchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get enabled => $_getBF(0);
  @$pb.TagNumber(1)
  set enabled($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEnabled() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnabled() => $_clearField(1);
}

class GetMempoolWatchStatusResponse extends $pb.GeneratedMessage {
  factory GetMempoolWatchStatusResponse({
    $core.bool? enabled,
    $core.bool? running,
    $core.String? error,
    $core.int? tipHeight,
    $fixnum.Int64? pendingCount,
  }) {
    final result = GetMempoolWatchStatusResponse._();
    if (enabled != null) result.enabled = enabled;
    if (running != null) result.running = running;
    if (error != null) result.error = error;
    if (tipHeight != null) result.tipHeight = tipHeight;
    if (pendingCount != null) result.pendingCount = pendingCount;
    return result;
  }

  GetMempoolWatchStatusResponse._();

  factory GetMempoolWatchStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetMempoolWatchStatusResponse()..mergeFromBuffer(data, registry);
  factory GetMempoolWatchStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetMempoolWatchStatusResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetMempoolWatchStatusResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: GetMempoolWatchStatusResponse.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'enabled')
    ..aOB(2, _omitFieldNames ? '' : 'running')
    ..aOS(3, _omitFieldNames ? '' : 'error')
    ..aI(4, _omitFieldNames ? '' : 'tipHeight', fieldType: $pb.PbFieldType.OU3)
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'pendingCount', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMempoolWatchStatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMempoolWatchStatusResponse copyWith(void Function(GetMempoolWatchStatusResponse) updates) =>
      super.copyWith((message) => updates(message as GetMempoolWatchStatusResponse)) as GetMempoolWatchStatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetMempoolWatchStatusResponse() / GetMempoolWatchStatusResponse.new instead')
  static GetMempoolWatchStatusResponse create() => GetMempoolWatchStatusResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetMempoolWatchStatusResponse._();
  @$core.override
  GetMempoolWatchStatusResponse createEmptyInstance() => GetMempoolWatchStatusResponse._();
  @$core.pragma('dart2js:noInline')
  static GetMempoolWatchStatusResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMempoolWatchStatusResponse>(GetMempoolWatchStatusResponse.$_createMessage);
  static GetMempoolWatchStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get enabled => $_getBF(0);
  @$pb.TagNumber(1)
  set enabled($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEnabled() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnabled() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get running => $_getBF(1);
  @$pb.TagNumber(2)
  set running($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRunning() => $_has(1);
  @$pb.TagNumber(2)
  void clearRunning() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get error => $_getSZ(2);
  @$pb.TagNumber(3)
  set error($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasError() => $_has(2);
  @$pb.TagNumber(3)
  void clearError() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get tipHeight => $_getIZ(3);
  @$pb.TagNumber(4)
  set tipHeight($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTipHeight() => $_has(3);
  @$pb.TagNumber(4)
  void clearTipHeight() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get pendingCount => $_getI64(4);
  @$pb.TagNumber(5)
  set pendingCount($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPendingCount() => $_has(4);
  @$pb.TagNumber(5)
  void clearPendingCount() => $_clearField(5);
}

/// Pages are ordered oldest first.
class ListMempoolTransactionsRequest extends $pb.GeneratedMessage {
  factory ListMempoolTransactionsRequest({
    $core.String? txid,
    $core.int? limit,
    $core.int? offset,
  }) {
    final result = ListMempoolTransactionsRequest._();
    if (txid != null) result.txid = txid;
    if (limit != null) result.limit = limit;
    if (offset != null) result.offset = offset;
    return result;
  }

  ListMempoolTransactionsRequest._();

  factory ListMempoolTransactionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListMempoolTransactionsRequest()..mergeFromBuffer(data, registry);
  factory ListMempoolTransactionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListMempoolTransactionsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListMempoolTransactionsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: ListMempoolTransactionsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aI(2, _omitFieldNames ? '' : 'limit', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'offset', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMempoolTransactionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMempoolTransactionsRequest copyWith(void Function(ListMempoolTransactionsRequest) updates) =>
      super.copyWith((message) => updates(message as ListMempoolTransactionsRequest)) as ListMempoolTransactionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListMempoolTransactionsRequest() / ListMempoolTransactionsRequest.new instead')
  static ListMempoolTransactionsRequest create() => ListMempoolTransactionsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListMempoolTransactionsRequest._();
  @$core.override
  ListMempoolTransactionsRequest createEmptyInstance() => ListMempoolTransactionsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListMempoolTransactionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListMempoolTransactionsRequest>(ListMempoolTransactionsRequest.$_createMessage);
  static ListMempoolTransactionsRequest? _defaultInstance;

  /// Prefix of the txid to match.
  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get limit => $_getIZ(1);
  @$pb.TagNumber(2)
  set limit($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLimit() => $_has(1);
  @$pb.TagNumber(2)
  void clearLimit() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get offset => $_getIZ(2);
  @$pb.TagNumber(3)
  set offset($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOffset() => $_has(2);
  @$pb.TagNumber(3)
  void clearOffset() => $_clearField(3);
}

class MempoolTransaction extends $pb.GeneratedMessage {
  factory MempoolTransaction({
    $core.String? txid,
    $fixnum.Int64? feeSats,
    $core.int? vsize,
    $core.double? feeRate,
    $0.Timestamp? firstSeen,
    $core.int? firstSeenHeight,
  }) {
    final result = MempoolTransaction._();
    if (txid != null) result.txid = txid;
    if (feeSats != null) result.feeSats = feeSats;
    if (vsize != null) result.vsize = vsize;
    if (feeRate != null) result.feeRate = feeRate;
    if (firstSeen != null) result.firstSeen = firstSeen;
    if (firstSeenHeight != null) result.firstSeenHeight = firstSeenHeight;
    return result;
  }

  MempoolTransaction._();

  factory MempoolTransaction.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MempoolTransaction()..mergeFromBuffer(data, registry);
  factory MempoolTransaction.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MempoolTransaction()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MempoolTransaction',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: MempoolTransaction.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'feeSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(3, _omitFieldNames ? '' : 'vsize', fieldType: $pb.PbFieldType.OU3)
    ..aD(4, _omitFieldNames ? '' : 'feeRate')
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'firstSeen', subBuilder: $0.Timestamp.$_createMessage)
    ..aI(6, _omitFieldNames ? '' : 'firstSeenHeight', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MempoolTransaction clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MempoolTransaction copyWith(void Function(MempoolTransaction) updates) =>
      super.copyWith((message) => updates(message as MempoolTransaction)) as MempoolTransaction;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MempoolTransaction() / MempoolTransaction.new instead')
  static MempoolTransaction create() => MempoolTransaction._();
  static $pb.GeneratedMessage $_createMessage() => MempoolTransaction._();
  @$core.override
  MempoolTransaction createEmptyInstance() => MempoolTransaction._();
  @$core.pragma('dart2js:noInline')
  static MempoolTransaction getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MempoolTransaction>(MempoolTransaction.$_createMessage);
  static MempoolTransaction? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get feeSats => $_getI64(1);
  @$pb.TagNumber(2)
  set feeSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFeeSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearFeeSats() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get vsize => $_getIZ(2);
  @$pb.TagNumber(3)
  set vsize($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVsize() => $_has(2);
  @$pb.TagNumber(3)
  void clearVsize() => $_clearField(3);

  /// The rate a block template weighs it at: ancestor package fee over
  /// package vsize, in sat/vB.
  @$pb.TagNumber(4)
  $core.double get feeRate => $_getN(3);
  @$pb.TagNumber(4)
  set feeRate($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFeeRate() => $_has(3);
  @$pb.TagNumber(4)
  void clearFeeRate() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.Timestamp get firstSeen => $_getN(4);
  @$pb.TagNumber(5)
  set firstSeen($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasFirstSeen() => $_has(4);
  @$pb.TagNumber(5)
  void clearFirstSeen() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureFirstSeen() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.int get firstSeenHeight => $_getIZ(5);
  @$pb.TagNumber(6)
  set firstSeenHeight($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFirstSeenHeight() => $_has(5);
  @$pb.TagNumber(6)
  void clearFirstSeenHeight() => $_clearField(6);
}

class ListMempoolTransactionsResponse extends $pb.GeneratedMessage {
  factory ListMempoolTransactionsResponse({
    $core.Iterable<MempoolTransaction>? transactions,
    $fixnum.Int64? total,
  }) {
    final result = ListMempoolTransactionsResponse._();
    if (transactions != null) result.transactions.addAll(transactions);
    if (total != null) result.total = total;
    return result;
  }

  ListMempoolTransactionsResponse._();

  factory ListMempoolTransactionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListMempoolTransactionsResponse()..mergeFromBuffer(data, registry);
  factory ListMempoolTransactionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListMempoolTransactionsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListMempoolTransactionsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: ListMempoolTransactionsResponse.$_createMessage)
    ..pPM<MempoolTransaction>(1, _omitFieldNames ? '' : 'transactions', subBuilder: MempoolTransaction.$_createMessage)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'total', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMempoolTransactionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMempoolTransactionsResponse copyWith(void Function(ListMempoolTransactionsResponse) updates) =>
      super.copyWith((message) => updates(message as ListMempoolTransactionsResponse))
          as ListMempoolTransactionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListMempoolTransactionsResponse() / ListMempoolTransactionsResponse.new instead')
  static ListMempoolTransactionsResponse create() => ListMempoolTransactionsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListMempoolTransactionsResponse._();
  @$core.override
  ListMempoolTransactionsResponse createEmptyInstance() => ListMempoolTransactionsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListMempoolTransactionsResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListMempoolTransactionsResponse>(
          ListMempoolTransactionsResponse.$_createMessage);
  static ListMempoolTransactionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<MempoolTransaction> get transactions => $_getList(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get total => $_getI64(1);
  @$pb.TagNumber(2)
  set total($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotal() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotal() => $_clearField(2);
}

class ListBlockStatsRequest extends $pb.GeneratedMessage {
  factory ListBlockStatsRequest({
    $core.int? fromHeight,
    $core.int? toHeight,
  }) {
    final result = ListBlockStatsRequest._();
    if (fromHeight != null) result.fromHeight = fromHeight;
    if (toHeight != null) result.toHeight = toHeight;
    return result;
  }

  ListBlockStatsRequest._();

  factory ListBlockStatsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListBlockStatsRequest()..mergeFromBuffer(data, registry);
  factory ListBlockStatsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListBlockStatsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListBlockStatsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: ListBlockStatsRequest.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'fromHeight', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'toHeight', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBlockStatsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBlockStatsRequest copyWith(void Function(ListBlockStatsRequest) updates) =>
      super.copyWith((message) => updates(message as ListBlockStatsRequest)) as ListBlockStatsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListBlockStatsRequest() / ListBlockStatsRequest.new instead')
  static ListBlockStatsRequest create() => ListBlockStatsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListBlockStatsRequest._();
  @$core.override
  ListBlockStatsRequest createEmptyInstance() => ListBlockStatsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListBlockStatsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListBlockStatsRequest>(ListBlockStatsRequest.$_createMessage);
  static ListBlockStatsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get fromHeight => $_getIZ(0);
  @$pb.TagNumber(1)
  set fromHeight($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFromHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearFromHeight() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get toHeight => $_getIZ(1);
  @$pb.TagNumber(2)
  set toHeight($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasToHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearToHeight() => $_clearField(2);
}

/// What a connected block showed about the fee market.
class BlockStats extends $pb.GeneratedMessage {
  factory BlockStats({
    $core.int? height,
    $core.double? minFeeRate,
    $fixnum.Int64? totalFeeSats,
  }) {
    final result = BlockStats._();
    if (height != null) result.height = height;
    if (minFeeRate != null) result.minFeeRate = minFeeRate;
    if (totalFeeSats != null) result.totalFeeSats = totalFeeSats;
    return result;
  }

  BlockStats._();

  factory BlockStats.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BlockStats()..mergeFromBuffer(data, registry);
  factory BlockStats.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BlockStats()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BlockStats',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: BlockStats.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'height', fieldType: $pb.PbFieldType.OU3)
    ..aD(2, _omitFieldNames ? '' : 'minFeeRate')
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'totalFeeSats', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockStats clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockStats copyWith(void Function(BlockStats) updates) =>
      super.copyWith((message) => updates(message as BlockStats)) as BlockStats;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BlockStats() / BlockStats.new instead')
  static BlockStats create() => BlockStats._();
  static $pb.GeneratedMessage $_createMessage() => BlockStats._();
  @$core.override
  BlockStats createEmptyInstance() => BlockStats._();
  @$core.pragma('dart2js:noInline')
  static BlockStats getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BlockStats>(BlockStats.$_createMessage);
  static BlockStats? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get height => $_getIZ(0);
  @$pb.TagNumber(1)
  set height($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeight() => $_clearField(1);

  /// Lowest fee rate the block included, in sat/vB.
  @$pb.TagNumber(2)
  $core.double get minFeeRate => $_getN(1);
  @$pb.TagNumber(2)
  set minFeeRate($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMinFeeRate() => $_has(1);
  @$pb.TagNumber(2)
  void clearMinFeeRate() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get totalFeeSats => $_getI64(2);
  @$pb.TagNumber(3)
  set totalFeeSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalFeeSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalFeeSats() => $_clearField(3);
}

class ListBlockStatsResponse extends $pb.GeneratedMessage {
  factory ListBlockStatsResponse({
    $core.Iterable<BlockStats>? blocks,
  }) {
    final result = ListBlockStatsResponse._();
    if (blocks != null) result.blocks.addAll(blocks);
    return result;
  }

  ListBlockStatsResponse._();

  factory ListBlockStatsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListBlockStatsResponse()..mergeFromBuffer(data, registry);
  factory ListBlockStatsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListBlockStatsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListBlockStatsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: ListBlockStatsResponse.$_createMessage)
    ..pPM<BlockStats>(1, _omitFieldNames ? '' : 'blocks', subBuilder: BlockStats.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBlockStatsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBlockStatsResponse copyWith(void Function(ListBlockStatsResponse) updates) =>
      super.copyWith((message) => updates(message as ListBlockStatsResponse)) as ListBlockStatsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListBlockStatsResponse() / ListBlockStatsResponse.new instead')
  static ListBlockStatsResponse create() => ListBlockStatsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListBlockStatsResponse._();
  @$core.override
  ListBlockStatsResponse createEmptyInstance() => ListBlockStatsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListBlockStatsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListBlockStatsResponse>(ListBlockStatsResponse.$_createMessage);
  static ListBlockStatsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<BlockStats> get blocks => $_getList(0);
}

/// A pool from pool.drivechain.info, or "Unknown". The payout fields are
/// empty on networks served by mempool's list.
class MiningPool extends $pb.GeneratedMessage {
  factory MiningPool({
    $core.String? name,
    $core.String? slug,
    $core.String? link,
    $core.String? operator,
    $core.String? mode,
    $core.int? feeBps,
    $core.String? stratumUrl,
    $core.String? payout,
  }) {
    final result = MiningPool._();
    if (name != null) result.name = name;
    if (slug != null) result.slug = slug;
    if (link != null) result.link = link;
    if (operator != null) result.operator = operator;
    if (mode != null) result.mode = mode;
    if (feeBps != null) result.feeBps = feeBps;
    if (stratumUrl != null) result.stratumUrl = stratumUrl;
    if (payout != null) result.payout = payout;
    return result;
  }

  MiningPool._();

  factory MiningPool.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MiningPool()..mergeFromBuffer(data, registry);
  factory MiningPool.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MiningPool()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MiningPool',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: MiningPool.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'slug')
    ..aOS(3, _omitFieldNames ? '' : 'link')
    ..aOS(4, _omitFieldNames ? '' : 'operator')
    ..aOS(5, _omitFieldNames ? '' : 'mode')
    ..aI(6, _omitFieldNames ? '' : 'feeBps', fieldType: $pb.PbFieldType.OU3)
    ..aOS(7, _omitFieldNames ? '' : 'stratumUrl')
    ..aOS(8, _omitFieldNames ? '' : 'payout')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MiningPool clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MiningPool copyWith(void Function(MiningPool) updates) =>
      super.copyWith((message) => updates(message as MiningPool)) as MiningPool;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MiningPool() / MiningPool.new instead')
  static MiningPool create() => MiningPool._();
  static $pb.GeneratedMessage $_createMessage() => MiningPool._();
  @$core.override
  MiningPool createEmptyInstance() => MiningPool._();
  @$core.pragma('dart2js:noInline')
  static MiningPool getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MiningPool>(MiningPool.$_createMessage);
  static MiningPool? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get slug => $_getSZ(1);
  @$pb.TagNumber(2)
  set slug($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSlug() => $_has(1);
  @$pb.TagNumber(2)
  void clearSlug() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get link => $_getSZ(2);
  @$pb.TagNumber(3)
  set link($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLink() => $_has(2);
  @$pb.TagNumber(3)
  void clearLink() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get operator => $_getSZ(3);
  @$pb.TagNumber(4)
  set operator($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOperator() => $_has(3);
  @$pb.TagNumber(4)
  void clearOperator() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get mode => $_getSZ(4);
  @$pb.TagNumber(5)
  set mode($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasMode() => $_has(4);
  @$pb.TagNumber(5)
  void clearMode() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get feeBps => $_getIZ(5);
  @$pb.TagNumber(6)
  set feeBps($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFeeBps() => $_has(5);
  @$pb.TagNumber(6)
  void clearFeeBps() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get stratumUrl => $_getSZ(6);
  @$pb.TagNumber(7)
  set stratumUrl($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStratumUrl() => $_has(6);
  @$pb.TagNumber(7)
  void clearStratumUrl() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get payout => $_getSZ(7);
  @$pb.TagNumber(8)
  set payout($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPayout() => $_has(7);
  @$pb.TagNumber(8)
  void clearPayout() => $_clearField(8);
}

class MiningPoolShare extends $pb.GeneratedMessage {
  factory MiningPoolShare({
    MiningPool? pool,
    $core.int? blockCount,
    $core.int? emptyBlocks,
    $core.double? share,
    $core.double? estimatedHashrate,
  }) {
    final result = MiningPoolShare._();
    if (pool != null) result.pool = pool;
    if (blockCount != null) result.blockCount = blockCount;
    if (emptyBlocks != null) result.emptyBlocks = emptyBlocks;
    if (share != null) result.share = share;
    if (estimatedHashrate != null) result.estimatedHashrate = estimatedHashrate;
    return result;
  }

  MiningPoolShare._();

  factory MiningPoolShare.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MiningPoolShare()..mergeFromBuffer(data, registry);
  factory MiningPoolShare.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MiningPoolShare()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MiningPoolShare',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: MiningPoolShare.$_createMessage)
    ..aOM<MiningPool>(1, _omitFieldNames ? '' : 'pool', subBuilder: MiningPool.$_createMessage)
    ..aI(2, _omitFieldNames ? '' : 'blockCount', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'emptyBlocks', fieldType: $pb.PbFieldType.OU3)
    ..aD(4, _omitFieldNames ? '' : 'share')
    ..aD(5, _omitFieldNames ? '' : 'estimatedHashrate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MiningPoolShare clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MiningPoolShare copyWith(void Function(MiningPoolShare) updates) =>
      super.copyWith((message) => updates(message as MiningPoolShare)) as MiningPoolShare;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MiningPoolShare() / MiningPoolShare.new instead')
  static MiningPoolShare create() => MiningPoolShare._();
  static $pb.GeneratedMessage $_createMessage() => MiningPoolShare._();
  @$core.override
  MiningPoolShare createEmptyInstance() => MiningPoolShare._();
  @$core.pragma('dart2js:noInline')
  static MiningPoolShare getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MiningPoolShare>(MiningPoolShare.$_createMessage);
  static MiningPoolShare? _defaultInstance;

  @$pb.TagNumber(1)
  MiningPool get pool => $_getN(0);
  @$pb.TagNumber(1)
  set pool(MiningPool value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPool() => $_has(0);
  @$pb.TagNumber(1)
  void clearPool() => $_clearField(1);
  @$pb.TagNumber(1)
  MiningPool ensurePool() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.int get blockCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set blockCount($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBlockCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlockCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get emptyBlocks => $_getIZ(2);
  @$pb.TagNumber(3)
  set emptyBlocks($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEmptyBlocks() => $_has(2);
  @$pb.TagNumber(3)
  void clearEmptyBlocks() => $_clearField(3);

  /// Fraction of the window's blocks, 0..1.
  @$pb.TagNumber(4)
  $core.double get share => $_getN(3);
  @$pb.TagNumber(4)
  set share($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasShare() => $_has(3);
  @$pb.TagNumber(4)
  void clearShare() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get estimatedHashrate => $_getN(4);
  @$pb.TagNumber(5)
  set estimatedHashrate($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEstimatedHashrate() => $_has(4);
  @$pb.TagNumber(5)
  void clearEstimatedHashrate() => $_clearField(5);
}

class ListMiningPoolsRequest extends $pb.GeneratedMessage {
  factory ListMiningPoolsRequest({
    MiningPoolWindow? window,
  }) {
    final result = ListMiningPoolsRequest._();
    if (window != null) result.window = window;
    return result;
  }

  ListMiningPoolsRequest._();

  factory ListMiningPoolsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListMiningPoolsRequest()..mergeFromBuffer(data, registry);
  factory ListMiningPoolsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListMiningPoolsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListMiningPoolsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: ListMiningPoolsRequest.$_createMessage)
    ..aE<MiningPoolWindow>(1, _omitFieldNames ? '' : 'window', enumValues: MiningPoolWindow.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMiningPoolsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMiningPoolsRequest copyWith(void Function(ListMiningPoolsRequest) updates) =>
      super.copyWith((message) => updates(message as ListMiningPoolsRequest)) as ListMiningPoolsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListMiningPoolsRequest() / ListMiningPoolsRequest.new instead')
  static ListMiningPoolsRequest create() => ListMiningPoolsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListMiningPoolsRequest._();
  @$core.override
  ListMiningPoolsRequest createEmptyInstance() => ListMiningPoolsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListMiningPoolsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListMiningPoolsRequest>(ListMiningPoolsRequest.$_createMessage);
  static ListMiningPoolsRequest? _defaultInstance;

  /// Unspecified means 24h.
  @$pb.TagNumber(1)
  MiningPoolWindow get window => $_getN(0);
  @$pb.TagNumber(1)
  set window(MiningPoolWindow value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasWindow() => $_has(0);
  @$pb.TagNumber(1)
  void clearWindow() => $_clearField(1);
}

class ListMiningPoolsResponse extends $pb.GeneratedMessage {
  factory ListMiningPoolsResponse({
    $core.Iterable<MiningPoolShare>? pools,
    $core.int? blockCount,
    $core.int? fromHeight,
    $core.int? toHeight,
    $core.double? networkHashrate,
    $core.bool? registryAvailable,
    $core.String? registrySource,
  }) {
    final result = ListMiningPoolsResponse._();
    if (pools != null) result.pools.addAll(pools);
    if (blockCount != null) result.blockCount = blockCount;
    if (fromHeight != null) result.fromHeight = fromHeight;
    if (toHeight != null) result.toHeight = toHeight;
    if (networkHashrate != null) result.networkHashrate = networkHashrate;
    if (registryAvailable != null) result.registryAvailable = registryAvailable;
    if (registrySource != null) result.registrySource = registrySource;
    return result;
  }

  ListMiningPoolsResponse._();

  factory ListMiningPoolsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListMiningPoolsResponse()..mergeFromBuffer(data, registry);
  factory ListMiningPoolsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListMiningPoolsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListMiningPoolsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: ListMiningPoolsResponse.$_createMessage)
    ..pPM<MiningPoolShare>(1, _omitFieldNames ? '' : 'pools', subBuilder: MiningPoolShare.$_createMessage)
    ..aI(2, _omitFieldNames ? '' : 'blockCount', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'fromHeight', fieldType: $pb.PbFieldType.OU3)
    ..aI(4, _omitFieldNames ? '' : 'toHeight', fieldType: $pb.PbFieldType.OU3)
    ..aD(5, _omitFieldNames ? '' : 'networkHashrate')
    ..aOB(6, _omitFieldNames ? '' : 'registryAvailable')
    ..aOS(7, _omitFieldNames ? '' : 'registrySource')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMiningPoolsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListMiningPoolsResponse copyWith(void Function(ListMiningPoolsResponse) updates) =>
      super.copyWith((message) => updates(message as ListMiningPoolsResponse)) as ListMiningPoolsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListMiningPoolsResponse() / ListMiningPoolsResponse.new instead')
  static ListMiningPoolsResponse create() => ListMiningPoolsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListMiningPoolsResponse._();
  @$core.override
  ListMiningPoolsResponse createEmptyInstance() => ListMiningPoolsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListMiningPoolsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListMiningPoolsResponse>(ListMiningPoolsResponse.$_createMessage);
  static ListMiningPoolsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<MiningPoolShare> get pools => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get blockCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set blockCount($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBlockCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlockCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get fromHeight => $_getIZ(2);
  @$pb.TagNumber(3)
  set fromHeight($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFromHeight() => $_has(2);
  @$pb.TagNumber(3)
  void clearFromHeight() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get toHeight => $_getIZ(3);
  @$pb.TagNumber(4)
  set toHeight($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasToHeight() => $_has(3);
  @$pb.TagNumber(4)
  void clearToHeight() => $_clearField(4);

  /// Work the window took over the time it spanned, in hashes per second.
  @$pb.TagNumber(5)
  $core.double get networkHashrate => $_getN(4);
  @$pb.TagNumber(5)
  set networkHashrate($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasNetworkHashrate() => $_has(4);
  @$pb.TagNumber(5)
  void clearNetworkHashrate() => $_clearField(5);

  /// False on networks without a pool registry; every block is then Unknown.
  @$pb.TagNumber(6)
  $core.bool get registryAvailable => $_getBF(5);
  @$pb.TagNumber(6)
  set registryAvailable($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasRegistryAvailable() => $_has(5);
  @$pb.TagNumber(6)
  void clearRegistryAvailable() => $_clearField(6);

  /// The registry URL, or "built-in" while the compiled-in seed is in use.
  @$pb.TagNumber(7)
  $core.String get registrySource => $_getSZ(6);
  @$pb.TagNumber(7)
  set registrySource($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasRegistrySource() => $_has(6);
  @$pb.TagNumber(7)
  void clearRegistrySource() => $_clearField(7);
}

class ListRecentTransactionsRequest extends $pb.GeneratedMessage {
  factory ListRecentTransactionsRequest({
    $fixnum.Int64? count,
  }) {
    final result = ListRecentTransactionsRequest._();
    if (count != null) result.count = count;
    return result;
  }

  ListRecentTransactionsRequest._();

  factory ListRecentTransactionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListRecentTransactionsRequest()..mergeFromBuffer(data, registry);
  factory ListRecentTransactionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListRecentTransactionsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListRecentTransactionsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: ListRecentTransactionsRequest.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'count')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListRecentTransactionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListRecentTransactionsRequest copyWith(void Function(ListRecentTransactionsRequest) updates) =>
      super.copyWith((message) => updates(message as ListRecentTransactionsRequest)) as ListRecentTransactionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListRecentTransactionsRequest() / ListRecentTransactionsRequest.new instead')
  static ListRecentTransactionsRequest create() => ListRecentTransactionsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListRecentTransactionsRequest._();
  @$core.override
  ListRecentTransactionsRequest createEmptyInstance() => ListRecentTransactionsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListRecentTransactionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListRecentTransactionsRequest>(ListRecentTransactionsRequest.$_createMessage);
  static ListRecentTransactionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get count => $_getI64(0);
  @$pb.TagNumber(1)
  set count($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearCount() => $_clearField(1);
}

class ListRecentTransactionsResponse extends $pb.GeneratedMessage {
  factory ListRecentTransactionsResponse({
    $core.Iterable<RecentTransaction>? transactions,
  }) {
    final result = ListRecentTransactionsResponse._();
    if (transactions != null) result.transactions.addAll(transactions);
    return result;
  }

  ListRecentTransactionsResponse._();

  factory ListRecentTransactionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListRecentTransactionsResponse()..mergeFromBuffer(data, registry);
  factory ListRecentTransactionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListRecentTransactionsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListRecentTransactionsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: ListRecentTransactionsResponse.$_createMessage)
    ..pPM<RecentTransaction>(1, _omitFieldNames ? '' : 'transactions', subBuilder: RecentTransaction.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListRecentTransactionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListRecentTransactionsResponse copyWith(void Function(ListRecentTransactionsResponse) updates) =>
      super.copyWith((message) => updates(message as ListRecentTransactionsResponse)) as ListRecentTransactionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListRecentTransactionsResponse() / ListRecentTransactionsResponse.new instead')
  static ListRecentTransactionsResponse create() => ListRecentTransactionsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListRecentTransactionsResponse._();
  @$core.override
  ListRecentTransactionsResponse createEmptyInstance() => ListRecentTransactionsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListRecentTransactionsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListRecentTransactionsResponse>(ListRecentTransactionsResponse.$_createMessage);
  static ListRecentTransactionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<RecentTransaction> get transactions => $_getList(0);
}

class RecentTransaction extends $pb.GeneratedMessage {
  factory RecentTransaction({
    $core.int? virtualSize,
    $0.Timestamp? time,
    $core.String? txid,
    $fixnum.Int64? feeSats,
    $core.int? confirmedInBlock,
  }) {
    final result = RecentTransaction._();
    if (virtualSize != null) result.virtualSize = virtualSize;
    if (time != null) result.time = time;
    if (txid != null) result.txid = txid;
    if (feeSats != null) result.feeSats = feeSats;
    if (confirmedInBlock != null) result.confirmedInBlock = confirmedInBlock;
    return result;
  }

  RecentTransaction._();

  factory RecentTransaction.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecentTransaction()..mergeFromBuffer(data, registry);
  factory RecentTransaction.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecentTransaction()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RecentTransaction',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: RecentTransaction.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'virtualSize', fieldType: $pb.PbFieldType.OU3)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'time', subBuilder: $0.Timestamp.$_createMessage)
    ..aOS(3, _omitFieldNames ? '' : 'txid')
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'feeSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(5, _omitFieldNames ? '' : 'confirmedInBlock', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecentTransaction clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecentTransaction copyWith(void Function(RecentTransaction) updates) =>
      super.copyWith((message) => updates(message as RecentTransaction)) as RecentTransaction;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RecentTransaction() / RecentTransaction.new instead')
  static RecentTransaction create() => RecentTransaction._();
  static $pb.GeneratedMessage $_createMessage() => RecentTransaction._();
  @$core.override
  RecentTransaction createEmptyInstance() => RecentTransaction._();
  @$core.pragma('dart2js:noInline')
  static RecentTransaction getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RecentTransaction>(RecentTransaction.$_createMessage);
  static RecentTransaction? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get virtualSize => $_getIZ(0);
  @$pb.TagNumber(1)
  set virtualSize($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVirtualSize() => $_has(0);
  @$pb.TagNumber(1)
  void clearVirtualSize() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get time => $_getN(1);
  @$pb.TagNumber(2)
  set time($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearTime() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTime() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get txid => $_getSZ(2);
  @$pb.TagNumber(3)
  set txid($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTxid() => $_has(2);
  @$pb.TagNumber(3)
  void clearTxid() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get feeSats => $_getI64(3);
  @$pb.TagNumber(4)
  set feeSats($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFeeSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearFeeSats() => $_clearField(4);

  /// Block height of the transaction, if confirmed
  @$pb.TagNumber(5)
  $core.int get confirmedInBlock => $_getIZ(4);
  @$pb.TagNumber(5)
  set confirmedInBlock($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasConfirmedInBlock() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfirmedInBlock() => $_clearField(5);
}

class ListBlocksRequest extends $pb.GeneratedMessage {
  factory ListBlocksRequest({
    $core.int? startHeight,
    $core.int? pageSize,
  }) {
    final result = ListBlocksRequest._();
    if (startHeight != null) result.startHeight = startHeight;
    if (pageSize != null) result.pageSize = pageSize;
    return result;
  }

  ListBlocksRequest._();

  factory ListBlocksRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListBlocksRequest()..mergeFromBuffer(data, registry);
  factory ListBlocksRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListBlocksRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListBlocksRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: ListBlocksRequest.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'startHeight', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'pageSize', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBlocksRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBlocksRequest copyWith(void Function(ListBlocksRequest) updates) =>
      super.copyWith((message) => updates(message as ListBlocksRequest)) as ListBlocksRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListBlocksRequest() / ListBlocksRequest.new instead')
  static ListBlocksRequest create() => ListBlocksRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListBlocksRequest._();
  @$core.override
  ListBlocksRequest createEmptyInstance() => ListBlocksRequest._();
  @$core.pragma('dart2js:noInline')
  static ListBlocksRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListBlocksRequest>(ListBlocksRequest.$_createMessage);
  static ListBlocksRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get startHeight => $_getIZ(0);
  @$pb.TagNumber(1)
  set startHeight($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStartHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearStartHeight() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get pageSize => $_getIZ(1);
  @$pb.TagNumber(2)
  set pageSize($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPageSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageSize() => $_clearField(2);
}

class Block extends $pb.GeneratedMessage {
  factory Block({
    $0.Timestamp? blockTime,
    $core.int? height,
    $core.String? hash,
    $core.int? confirmations,
    $core.int? version,
    $core.String? versionHex,
    $core.String? merkleRoot,
    $core.int? nonce,
    $core.String? bits,
    $core.double? difficulty,
    $core.String? previousBlockHash,
    $core.String? nextBlockHash,
    $core.int? strippedSize,
    $core.int? size,
    $core.int? weight,
    $core.Iterable<$core.String>? txids,
    MiningPool? pool,
  }) {
    final result = Block._();
    if (blockTime != null) result.blockTime = blockTime;
    if (height != null) result.height = height;
    if (hash != null) result.hash = hash;
    if (confirmations != null) result.confirmations = confirmations;
    if (version != null) result.version = version;
    if (versionHex != null) result.versionHex = versionHex;
    if (merkleRoot != null) result.merkleRoot = merkleRoot;
    if (nonce != null) result.nonce = nonce;
    if (bits != null) result.bits = bits;
    if (difficulty != null) result.difficulty = difficulty;
    if (previousBlockHash != null) result.previousBlockHash = previousBlockHash;
    if (nextBlockHash != null) result.nextBlockHash = nextBlockHash;
    if (strippedSize != null) result.strippedSize = strippedSize;
    if (size != null) result.size = size;
    if (weight != null) result.weight = weight;
    if (txids != null) result.txids.addAll(txids);
    if (pool != null) result.pool = pool;
    return result;
  }

  Block._();

  factory Block.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Block()..mergeFromBuffer(data, registry);
  factory Block.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Block()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Block',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: Block.$_createMessage)
    ..aOM<$0.Timestamp>(1, _omitFieldNames ? '' : 'blockTime', subBuilder: $0.Timestamp.$_createMessage)
    ..aI(2, _omitFieldNames ? '' : 'height', fieldType: $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'hash')
    ..aI(4, _omitFieldNames ? '' : 'confirmations')
    ..aI(5, _omitFieldNames ? '' : 'version')
    ..aOS(6, _omitFieldNames ? '' : 'versionHex')
    ..aOS(7, _omitFieldNames ? '' : 'merkleRoot')
    ..aI(8, _omitFieldNames ? '' : 'nonce', fieldType: $pb.PbFieldType.OU3)
    ..aOS(9, _omitFieldNames ? '' : 'bits')
    ..aD(10, _omitFieldNames ? '' : 'difficulty')
    ..aOS(11, _omitFieldNames ? '' : 'previousBlockHash')
    ..aOS(12, _omitFieldNames ? '' : 'nextBlockHash')
    ..aI(13, _omitFieldNames ? '' : 'strippedSize')
    ..aI(14, _omitFieldNames ? '' : 'size')
    ..aI(15, _omitFieldNames ? '' : 'weight')
    ..pPS(16, _omitFieldNames ? '' : 'txids')
    ..aOM<MiningPool>(17, _omitFieldNames ? '' : 'pool', subBuilder: MiningPool.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block copyWith(void Function(Block) updates) => super.copyWith((message) => updates(message as Block)) as Block;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Block() / Block.new instead')
  static Block create() => Block._();
  static $pb.GeneratedMessage $_createMessage() => Block._();
  @$core.override
  Block createEmptyInstance() => Block._();
  @$core.pragma('dart2js:noInline')
  static Block getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Block>(Block.$_createMessage);
  static Block? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Timestamp get blockTime => $_getN(0);
  @$pb.TagNumber(1)
  set blockTime($0.Timestamp value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBlockTime() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockTime() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Timestamp ensureBlockTime() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.int get height => $_getIZ(1);
  @$pb.TagNumber(2)
  set height($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeight() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get hash => $_getSZ(2);
  @$pb.TagNumber(3)
  set hash($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHash() => $_has(2);
  @$pb.TagNumber(3)
  void clearHash() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get confirmations => $_getIZ(3);
  @$pb.TagNumber(4)
  set confirmations($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConfirmations() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfirmations() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get version => $_getIZ(4);
  @$pb.TagNumber(5)
  set version($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearVersion() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get versionHex => $_getSZ(5);
  @$pb.TagNumber(6)
  set versionHex($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasVersionHex() => $_has(5);
  @$pb.TagNumber(6)
  void clearVersionHex() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get merkleRoot => $_getSZ(6);
  @$pb.TagNumber(7)
  set merkleRoot($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMerkleRoot() => $_has(6);
  @$pb.TagNumber(7)
  void clearMerkleRoot() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get nonce => $_getIZ(7);
  @$pb.TagNumber(8)
  set nonce($core.int value) => $_setUnsignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasNonce() => $_has(7);
  @$pb.TagNumber(8)
  void clearNonce() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get bits => $_getSZ(8);
  @$pb.TagNumber(9)
  set bits($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasBits() => $_has(8);
  @$pb.TagNumber(9)
  void clearBits() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.double get difficulty => $_getN(9);
  @$pb.TagNumber(10)
  set difficulty($core.double value) => $_setDouble(9, value);
  @$pb.TagNumber(10)
  $core.bool hasDifficulty() => $_has(9);
  @$pb.TagNumber(10)
  void clearDifficulty() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.String get previousBlockHash => $_getSZ(10);
  @$pb.TagNumber(11)
  set previousBlockHash($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasPreviousBlockHash() => $_has(10);
  @$pb.TagNumber(11)
  void clearPreviousBlockHash() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get nextBlockHash => $_getSZ(11);
  @$pb.TagNumber(12)
  set nextBlockHash($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasNextBlockHash() => $_has(11);
  @$pb.TagNumber(12)
  void clearNextBlockHash() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.int get strippedSize => $_getIZ(12);
  @$pb.TagNumber(13)
  set strippedSize($core.int value) => $_setSignedInt32(12, value);
  @$pb.TagNumber(13)
  $core.bool hasStrippedSize() => $_has(12);
  @$pb.TagNumber(13)
  void clearStrippedSize() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.int get size => $_getIZ(13);
  @$pb.TagNumber(14)
  set size($core.int value) => $_setSignedInt32(13, value);
  @$pb.TagNumber(14)
  $core.bool hasSize() => $_has(13);
  @$pb.TagNumber(14)
  void clearSize() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.int get weight => $_getIZ(14);
  @$pb.TagNumber(15)
  set weight($core.int value) => $_setSignedInt32(14, value);
  @$pb.TagNumber(15)
  $core.bool hasWeight() => $_has(14);
  @$pb.TagNumber(15)
  void clearWeight() => $_clearField(15);

  @$pb.TagNumber(16)
  $pb.PbList<$core.String> get txids => $_getList(15);

  /// Unset when the block's coinbase was not recorded.
  @$pb.TagNumber(17)
  MiningPool get pool => $_getN(16);
  @$pb.TagNumber(17)
  set pool(MiningPool value) => $_setField(17, value);
  @$pb.TagNumber(17)
  $core.bool hasPool() => $_has(16);
  @$pb.TagNumber(17)
  void clearPool() => $_clearField(17);
  @$pb.TagNumber(17)
  MiningPool ensurePool() => $_ensure(16);
}

class ListBlocksResponse extends $pb.GeneratedMessage {
  factory ListBlocksResponse({
    $core.Iterable<Block>? recentBlocks,
    $core.bool? hasMore,
  }) {
    final result = ListBlocksResponse._();
    if (recentBlocks != null) result.recentBlocks.addAll(recentBlocks);
    if (hasMore != null) result.hasMore = hasMore;
    return result;
  }

  ListBlocksResponse._();

  factory ListBlocksResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListBlocksResponse()..mergeFromBuffer(data, registry);
  factory ListBlocksResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListBlocksResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListBlocksResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: ListBlocksResponse.$_createMessage)
    ..pPM<Block>(4, _omitFieldNames ? '' : 'recentBlocks', subBuilder: Block.$_createMessage)
    ..aOB(5, _omitFieldNames ? '' : 'hasMore')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBlocksResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBlocksResponse copyWith(void Function(ListBlocksResponse) updates) =>
      super.copyWith((message) => updates(message as ListBlocksResponse)) as ListBlocksResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListBlocksResponse() / ListBlocksResponse.new instead')
  static ListBlocksResponse create() => ListBlocksResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListBlocksResponse._();
  @$core.override
  ListBlocksResponse createEmptyInstance() => ListBlocksResponse._();
  @$core.pragma('dart2js:noInline')
  static ListBlocksResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListBlocksResponse>(ListBlocksResponse.$_createMessage);
  static ListBlocksResponse? _defaultInstance;

  @$pb.TagNumber(4)
  $pb.PbList<Block> get recentBlocks => $_getList(0);

  @$pb.TagNumber(5)
  $core.bool get hasMore => $_getBF(1);
  @$pb.TagNumber(5)
  set hasMore($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(5)
  $core.bool hasHasMore() => $_has(1);
  @$pb.TagNumber(5)
  void clearHasMore() => $_clearField(5);
}

class GetNetworkStatsResponse extends $pb.GeneratedMessage {
  factory GetNetworkStatsResponse({
    $core.double? networkHashrate,
    $core.double? difficulty,
    $core.int? peerCount,
    $fixnum.Int64? totalBytesReceived,
    $fixnum.Int64? totalBytesSent,
    $fixnum.Int64? blockHeight,
    $core.double? avgBlockTime,
    $core.int? networkVersion,
    $core.String? subversion,
    $core.int? connectionsIn,
    $core.int? connectionsOut,
    ProcessBandwidth? bitcoindBandwidth,
    ProcessBandwidth? enforcerBandwidth,
  }) {
    final result = GetNetworkStatsResponse._();
    if (networkHashrate != null) result.networkHashrate = networkHashrate;
    if (difficulty != null) result.difficulty = difficulty;
    if (peerCount != null) result.peerCount = peerCount;
    if (totalBytesReceived != null) result.totalBytesReceived = totalBytesReceived;
    if (totalBytesSent != null) result.totalBytesSent = totalBytesSent;
    if (blockHeight != null) result.blockHeight = blockHeight;
    if (avgBlockTime != null) result.avgBlockTime = avgBlockTime;
    if (networkVersion != null) result.networkVersion = networkVersion;
    if (subversion != null) result.subversion = subversion;
    if (connectionsIn != null) result.connectionsIn = connectionsIn;
    if (connectionsOut != null) result.connectionsOut = connectionsOut;
    if (bitcoindBandwidth != null) result.bitcoindBandwidth = bitcoindBandwidth;
    if (enforcerBandwidth != null) result.enforcerBandwidth = enforcerBandwidth;
    return result;
  }

  GetNetworkStatsResponse._();

  factory GetNetworkStatsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNetworkStatsResponse()..mergeFromBuffer(data, registry);
  factory GetNetworkStatsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNetworkStatsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNetworkStatsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: GetNetworkStatsResponse.$_createMessage)
    ..aD(1, _omitFieldNames ? '' : 'networkHashrate')
    ..aD(2, _omitFieldNames ? '' : 'difficulty')
    ..aI(3, _omitFieldNames ? '' : 'peerCount')
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'totalBytesReceived', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'totalBytesSent', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aInt64(6, _omitFieldNames ? '' : 'blockHeight')
    ..aD(7, _omitFieldNames ? '' : 'avgBlockTime')
    ..aI(8, _omitFieldNames ? '' : 'networkVersion')
    ..aOS(9, _omitFieldNames ? '' : 'subversion')
    ..aI(10, _omitFieldNames ? '' : 'connectionsIn')
    ..aI(11, _omitFieldNames ? '' : 'connectionsOut')
    ..aOM<ProcessBandwidth>(12, _omitFieldNames ? '' : 'bitcoindBandwidth',
        subBuilder: ProcessBandwidth.$_createMessage)
    ..aOM<ProcessBandwidth>(13, _omitFieldNames ? '' : 'enforcerBandwidth',
        subBuilder: ProcessBandwidth.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNetworkStatsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNetworkStatsResponse copyWith(void Function(GetNetworkStatsResponse) updates) =>
      super.copyWith((message) => updates(message as GetNetworkStatsResponse)) as GetNetworkStatsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetNetworkStatsResponse() / GetNetworkStatsResponse.new instead')
  static GetNetworkStatsResponse create() => GetNetworkStatsResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetNetworkStatsResponse._();
  @$core.override
  GetNetworkStatsResponse createEmptyInstance() => GetNetworkStatsResponse._();
  @$core.pragma('dart2js:noInline')
  static GetNetworkStatsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNetworkStatsResponse>(GetNetworkStatsResponse.$_createMessage);
  static GetNetworkStatsResponse? _defaultInstance;

  /// Network hashrate in hashes per second
  @$pb.TagNumber(1)
  $core.double get networkHashrate => $_getN(0);
  @$pb.TagNumber(1)
  set networkHashrate($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNetworkHashrate() => $_has(0);
  @$pb.TagNumber(1)
  void clearNetworkHashrate() => $_clearField(1);

  /// Current difficulty
  @$pb.TagNumber(2)
  $core.double get difficulty => $_getN(1);
  @$pb.TagNumber(2)
  set difficulty($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDifficulty() => $_has(1);
  @$pb.TagNumber(2)
  void clearDifficulty() => $_clearField(2);

  /// Number of connected peers
  @$pb.TagNumber(3)
  $core.int get peerCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set peerCount($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPeerCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearPeerCount() => $_clearField(3);

  /// Total bytes received (from Bitcoin RPC)
  @$pb.TagNumber(4)
  $fixnum.Int64 get totalBytesReceived => $_getI64(3);
  @$pb.TagNumber(4)
  set totalBytesReceived($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTotalBytesReceived() => $_has(3);
  @$pb.TagNumber(4)
  void clearTotalBytesReceived() => $_clearField(4);

  /// Total bytes sent (from Bitcoin RPC)
  @$pb.TagNumber(5)
  $fixnum.Int64 get totalBytesSent => $_getI64(4);
  @$pb.TagNumber(5)
  set totalBytesSent($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTotalBytesSent() => $_has(4);
  @$pb.TagNumber(5)
  void clearTotalBytesSent() => $_clearField(5);

  /// Current block height
  @$pb.TagNumber(6)
  $fixnum.Int64 get blockHeight => $_getI64(5);
  @$pb.TagNumber(6)
  set blockHeight($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBlockHeight() => $_has(5);
  @$pb.TagNumber(6)
  void clearBlockHeight() => $_clearField(6);

  /// Average block time (seconds) over last 144 blocks
  @$pb.TagNumber(7)
  $core.double get avgBlockTime => $_getN(6);
  @$pb.TagNumber(7)
  set avgBlockTime($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAvgBlockTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearAvgBlockTime() => $_clearField(7);

  /// Network version (protocol version)
  @$pb.TagNumber(8)
  $core.int get networkVersion => $_getIZ(7);
  @$pb.TagNumber(8)
  set networkVersion($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasNetworkVersion() => $_has(7);
  @$pb.TagNumber(8)
  void clearNetworkVersion() => $_clearField(8);

  /// Subversion (user agent string)
  @$pb.TagNumber(9)
  $core.String get subversion => $_getSZ(8);
  @$pb.TagNumber(9)
  set subversion($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasSubversion() => $_has(8);
  @$pb.TagNumber(9)
  void clearSubversion() => $_clearField(9);

  /// Number of connections (in/out)
  @$pb.TagNumber(10)
  $core.int get connectionsIn => $_getIZ(9);
  @$pb.TagNumber(10)
  set connectionsIn($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasConnectionsIn() => $_has(9);
  @$pb.TagNumber(10)
  void clearConnectionsIn() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.int get connectionsOut => $_getIZ(10);
  @$pb.TagNumber(11)
  set connectionsOut($core.int value) => $_setSignedInt32(10, value);
  @$pb.TagNumber(11)
  $core.bool hasConnectionsOut() => $_has(10);
  @$pb.TagNumber(11)
  void clearConnectionsOut() => $_clearField(11);

  /// Per-process bandwidth statistics (OS-level)
  @$pb.TagNumber(12)
  ProcessBandwidth get bitcoindBandwidth => $_getN(11);
  @$pb.TagNumber(12)
  set bitcoindBandwidth(ProcessBandwidth value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasBitcoindBandwidth() => $_has(11);
  @$pb.TagNumber(12)
  void clearBitcoindBandwidth() => $_clearField(12);
  @$pb.TagNumber(12)
  ProcessBandwidth ensureBitcoindBandwidth() => $_ensure(11);

  @$pb.TagNumber(13)
  ProcessBandwidth get enforcerBandwidth => $_getN(12);
  @$pb.TagNumber(13)
  set enforcerBandwidth(ProcessBandwidth value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasEnforcerBandwidth() => $_has(12);
  @$pb.TagNumber(13)
  void clearEnforcerBandwidth() => $_clearField(13);
  @$pb.TagNumber(13)
  ProcessBandwidth ensureEnforcerBandwidth() => $_ensure(12);
}

class ProcessBandwidth extends $pb.GeneratedMessage {
  factory ProcessBandwidth({
    $core.String? processName,
    $core.int? pid,
    $core.double? rxBytesPerSec,
    $core.double? txBytesPerSec,
    $fixnum.Int64? totalRxBytes,
    $fixnum.Int64? totalTxBytes,
    $core.int? connectionCount,
  }) {
    final result = ProcessBandwidth._();
    if (processName != null) result.processName = processName;
    if (pid != null) result.pid = pid;
    if (rxBytesPerSec != null) result.rxBytesPerSec = rxBytesPerSec;
    if (txBytesPerSec != null) result.txBytesPerSec = txBytesPerSec;
    if (totalRxBytes != null) result.totalRxBytes = totalRxBytes;
    if (totalTxBytes != null) result.totalTxBytes = totalTxBytes;
    if (connectionCount != null) result.connectionCount = connectionCount;
    return result;
  }

  ProcessBandwidth._();

  factory ProcessBandwidth.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProcessBandwidth()..mergeFromBuffer(data, registry);
  factory ProcessBandwidth.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProcessBandwidth()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ProcessBandwidth',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: ProcessBandwidth.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'processName')
    ..aI(2, _omitFieldNames ? '' : 'pid')
    ..aD(3, _omitFieldNames ? '' : 'rxBytesPerSec')
    ..aD(4, _omitFieldNames ? '' : 'txBytesPerSec')
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'totalRxBytes', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(6, _omitFieldNames ? '' : 'totalTxBytes', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(7, _omitFieldNames ? '' : 'connectionCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProcessBandwidth clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProcessBandwidth copyWith(void Function(ProcessBandwidth) updates) =>
      super.copyWith((message) => updates(message as ProcessBandwidth)) as ProcessBandwidth;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ProcessBandwidth() / ProcessBandwidth.new instead')
  static ProcessBandwidth create() => ProcessBandwidth._();
  static $pb.GeneratedMessage $_createMessage() => ProcessBandwidth._();
  @$core.override
  ProcessBandwidth createEmptyInstance() => ProcessBandwidth._();
  @$core.pragma('dart2js:noInline')
  static ProcessBandwidth getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProcessBandwidth>(ProcessBandwidth.$_createMessage);
  static ProcessBandwidth? _defaultInstance;

  /// Process name
  @$pb.TagNumber(1)
  $core.String get processName => $_getSZ(0);
  @$pb.TagNumber(1)
  set processName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasProcessName() => $_has(0);
  @$pb.TagNumber(1)
  void clearProcessName() => $_clearField(1);

  /// Process ID
  @$pb.TagNumber(2)
  $core.int get pid => $_getIZ(1);
  @$pb.TagNumber(2)
  set pid($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPid() => $_has(1);
  @$pb.TagNumber(2)
  void clearPid() => $_clearField(2);

  /// Bytes received per second (current rate)
  @$pb.TagNumber(3)
  $core.double get rxBytesPerSec => $_getN(2);
  @$pb.TagNumber(3)
  set rxBytesPerSec($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRxBytesPerSec() => $_has(2);
  @$pb.TagNumber(3)
  void clearRxBytesPerSec() => $_clearField(3);

  /// Bytes sent per second (current rate)
  @$pb.TagNumber(4)
  $core.double get txBytesPerSec => $_getN(3);
  @$pb.TagNumber(4)
  set txBytesPerSec($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTxBytesPerSec() => $_has(3);
  @$pb.TagNumber(4)
  void clearTxBytesPerSec() => $_clearField(4);

  /// Total bytes received since process start
  @$pb.TagNumber(5)
  $fixnum.Int64 get totalRxBytes => $_getI64(4);
  @$pb.TagNumber(5)
  set totalRxBytes($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTotalRxBytes() => $_has(4);
  @$pb.TagNumber(5)
  void clearTotalRxBytes() => $_clearField(5);

  /// Total bytes sent since process start
  @$pb.TagNumber(6)
  $fixnum.Int64 get totalTxBytes => $_getI64(5);
  @$pb.TagNumber(6)
  set totalTxBytes($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTotalTxBytes() => $_has(5);
  @$pb.TagNumber(6)
  void clearTotalTxBytes() => $_clearField(6);

  /// Number of active connections
  @$pb.TagNumber(7)
  $core.int get connectionCount => $_getIZ(6);
  @$pb.TagNumber(7)
  set connectionCount($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasConnectionCount() => $_has(6);
  @$pb.TagNumber(7)
  void clearConnectionCount() => $_clearField(7);
}

class UpdateNetworkRequest extends $pb.GeneratedMessage {
  factory UpdateNetworkRequest({
    $core.String? network,
    $core.String? dataDir,
    $core.String? networkId,
  }) {
    final result = UpdateNetworkRequest._();
    if (network != null) result.network = network;
    if (dataDir != null) result.dataDir = dataDir;
    if (networkId != null) result.networkId = networkId;
    return result;
  }

  UpdateNetworkRequest._();

  factory UpdateNetworkRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateNetworkRequest()..mergeFromBuffer(data, registry);
  factory UpdateNetworkRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateNetworkRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateNetworkRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: UpdateNetworkRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'network')
    ..aOS(2, _omitFieldNames ? '' : 'dataDir')
    ..aOS(3, _omitFieldNames ? '' : 'networkId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateNetworkRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateNetworkRequest copyWith(void Function(UpdateNetworkRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateNetworkRequest)) as UpdateNetworkRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UpdateNetworkRequest() / UpdateNetworkRequest.new instead')
  static UpdateNetworkRequest create() => UpdateNetworkRequest._();
  static $pb.GeneratedMessage $_createMessage() => UpdateNetworkRequest._();
  @$core.override
  UpdateNetworkRequest createEmptyInstance() => UpdateNetworkRequest._();
  @$core.pragma('dart2js:noInline')
  static UpdateNetworkRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateNetworkRequest>(UpdateNetworkRequest.$_createMessage);
  static UpdateNetworkRequest? _defaultInstance;

  /// Target network: signet, mainnet, ecash, testnet, regtest.
  @$pb.TagNumber(1)
  $core.String get network => $_getSZ(0);
  @$pb.TagNumber(1)
  set network($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNetwork() => $_has(0);
  @$pb.TagNumber(1)
  void clearNetwork() => $_clearField(1);

  /// The user's answer to must_select_datadir, when they were asked.
  @$pb.TagNumber(2)
  $core.String get dataDir => $_getSZ(1);
  @$pb.TagNumber(2)
  set dataDir($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDataDir() => $_has(1);
  @$pb.TagNumber(2)
  void clearDataDir() => $_clearField(2);

  /// Catalog id of the picked row ("betanet"). The eCash rows share one
  /// network, so only the id names the fork. Empty falls back to network.
  @$pb.TagNumber(3)
  $core.String get networkId => $_getSZ(2);
  @$pb.TagNumber(3)
  set networkId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNetworkId() => $_has(2);
  @$pb.TagNumber(3)
  void clearNetworkId() => $_clearField(3);
}

class UpdateNetworkResponse extends $pb.GeneratedMessage {
  factory UpdateNetworkResponse() => UpdateNetworkResponse._();

  UpdateNetworkResponse._();

  factory UpdateNetworkResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateNetworkResponse()..mergeFromBuffer(data, registry);
  factory UpdateNetworkResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateNetworkResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateNetworkResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'),
      createEmptyInstance: UpdateNetworkResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateNetworkResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateNetworkResponse copyWith(void Function(UpdateNetworkResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateNetworkResponse)) as UpdateNetworkResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UpdateNetworkResponse() / UpdateNetworkResponse.new instead')
  static UpdateNetworkResponse create() => UpdateNetworkResponse._();
  static $pb.GeneratedMessage $_createMessage() => UpdateNetworkResponse._();
  @$core.override
  UpdateNetworkResponse createEmptyInstance() => UpdateNetworkResponse._();
  @$core.pragma('dart2js:noInline')
  static UpdateNetworkResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateNetworkResponse>(UpdateNetworkResponse.$_createMessage);
  static UpdateNetworkResponse? _defaultInstance;
}

class BitwindowdServiceApi {
  final $pb.RpcClient _client;

  BitwindowdServiceApi(this._client);

  /// Window-close + clean exit. Relays to orchestratord.Shutdown (which is
  /// detached and drains bitcoind/enforcer over ~90s in the background), then
  /// tears down bitwindowd itself. Acks fast so the Flutter window can destroy
  /// immediately. Pass skip_downstream=true to leave the orchestratord stack
  /// running (only bitwindowd dies).
  $async.Future<$1.Empty> stop($pb.ClientContext? ctx, BitwindowdServiceStopRequest request) =>
      _client.invoke<$1.Empty>(ctx, 'BitwindowdService', 'Stop', request, $1.Empty());

  /// Deniability operations
  $async.Future<$1.Empty> createDenial($pb.ClientContext? ctx, CreateDenialRequest request) =>
      _client.invoke<$1.Empty>(ctx, 'BitwindowdService', 'CreateDenial', request, $1.Empty());
  $async.Future<$1.Empty> cancelDenial($pb.ClientContext? ctx, CancelDenialRequest request) =>
      _client.invoke<$1.Empty>(ctx, 'BitwindowdService', 'CancelDenial', request, $1.Empty());
  $async.Future<$1.Empty> pauseDenial($pb.ClientContext? ctx, PauseDenialRequest request) =>
      _client.invoke<$1.Empty>(ctx, 'BitwindowdService', 'PauseDenial', request, $1.Empty());
  $async.Future<$1.Empty> resumeDenial($pb.ClientContext? ctx, ResumeDenialRequest request) =>
      _client.invoke<$1.Empty>(ctx, 'BitwindowdService', 'ResumeDenial', request, $1.Empty());

  /// Wallet operations
  $async.Future<CreateAddressBookEntryResponse> createAddressBookEntry(
          $pb.ClientContext? ctx, CreateAddressBookEntryRequest request) =>
      _client.invoke<CreateAddressBookEntryResponse>(
          ctx, 'BitwindowdService', 'CreateAddressBookEntry', request, CreateAddressBookEntryResponse());
  $async.Future<ListAddressBookResponse> listAddressBook($pb.ClientContext? ctx, $1.Empty request) => _client
      .invoke<ListAddressBookResponse>(ctx, 'BitwindowdService', 'ListAddressBook', request, ListAddressBookResponse());
  $async.Future<$1.Empty> updateAddressBookEntry($pb.ClientContext? ctx, UpdateAddressBookEntryRequest request) =>
      _client.invoke<$1.Empty>(ctx, 'BitwindowdService', 'UpdateAddressBookEntry', request, $1.Empty());
  $async.Future<$1.Empty> deleteAddressBookEntry($pb.ClientContext? ctx, DeleteAddressBookEntryRequest request) =>
      _client.invoke<$1.Empty>(ctx, 'BitwindowdService', 'DeleteAddressBookEntry', request, $1.Empty());
  $async.Future<GetSyncInfoResponse> getSyncInfo($pb.ClientContext? ctx, $1.Empty request) =>
      _client.invoke<GetSyncInfoResponse>(ctx, 'BitwindowdService', 'GetSyncInfo', request, GetSyncInfoResponse());
  $async.Future<$1.Empty> setTransactionNote($pb.ClientContext? ctx, SetTransactionNoteRequest request) =>
      _client.invoke<$1.Empty>(ctx, 'BitwindowdService', 'SetTransactionNote', request, $1.Empty());

  /// BIP329 label import/export. ExportLabels emits one JSONL object per
  /// labelled item (address book, tx note, UTXO label). ImportLabels parses
  /// BIP329 JSONL and writes into the matching store, skipping unknown or
  /// malformed lines.
  $async.Future<ExportLabelsResponse> exportLabels($pb.ClientContext? ctx, $1.Empty request) =>
      _client.invoke<ExportLabelsResponse>(ctx, 'BitwindowdService', 'ExportLabels', request, ExportLabelsResponse());
  $async.Future<ImportLabelsResponse> importLabels($pb.ClientContext? ctx, ImportLabelsRequest request) =>
      _client.invoke<ImportLabelsResponse>(ctx, 'BitwindowdService', 'ImportLabels', request, ImportLabelsResponse());
  $async.Future<GetFireplaceStatsResponse> getFireplaceStats($pb.ClientContext? ctx, $1.Empty request) =>
      _client.invoke<GetFireplaceStatsResponse>(
          ctx, 'BitwindowdService', 'GetFireplaceStats', request, GetFireplaceStatsResponse());

  /// Lists the most recent transactions, both confirmed and unconfirmed.
  $async.Future<ListRecentTransactionsResponse> listRecentTransactions(
          $pb.ClientContext? ctx, ListRecentTransactionsRequest request) =>
      _client.invoke<ListRecentTransactionsResponse>(
          ctx, 'BitwindowdService', 'ListRecentTransactions', request, ListRecentTransactionsResponse());

  /// Lists blocks with pagination support
  $async.Future<ListBlocksResponse> listBlocks($pb.ClientContext? ctx, ListBlocksRequest request) =>
      _client.invoke<ListBlocksResponse>(ctx, 'BitwindowdService', 'ListBlocks', request, ListBlocksResponse());

  /// Get network statistics
  $async.Future<GetNetworkStatsResponse> getNetworkStats($pb.ClientContext? ctx, $1.Empty request) => _client
      .invoke<GetNetworkStatsResponse>(ctx, 'BitwindowdService', 'GetNetworkStats', request, GetNetworkStatsResponse());

  /// Mempool watch: records every tx in the mempool and how long it has waited.
  $async.Future<$1.Empty> setMempoolWatch($pb.ClientContext? ctx, SetMempoolWatchRequest request) =>
      _client.invoke<$1.Empty>(ctx, 'BitwindowdService', 'SetMempoolWatch', request, $1.Empty());

  /// Forgets everything recorded and starts over from the current mempool.
  $async.Future<$1.Empty> resetMempoolWatch($pb.ClientContext? ctx, $1.Empty request) =>
      _client.invoke<$1.Empty>(ctx, 'BitwindowdService', 'ResetMempoolWatch', request, $1.Empty());
  $async.Future<GetMempoolWatchStatusResponse> getMempoolWatchStatus($pb.ClientContext? ctx, $1.Empty request) =>
      _client.invoke<GetMempoolWatchStatusResponse>(
          ctx, 'BitwindowdService', 'GetMempoolWatchStatus', request, GetMempoolWatchStatusResponse());
  $async.Future<ListMempoolTransactionsResponse> listMempoolTransactions(
          $pb.ClientContext? ctx, ListMempoolTransactionsRequest request) =>
      _client.invoke<ListMempoolTransactionsResponse>(
          ctx, 'BitwindowdService', 'ListMempoolTransactions', request, ListMempoolTransactionsResponse());
  $async.Future<ListBlockStatsResponse> listBlockStats($pb.ClientContext? ctx, ListBlockStatsRequest request) => _client
      .invoke<ListBlockStatsResponse>(ctx, 'BitwindowdService', 'ListBlockStats', request, ListBlockStatsResponse());

  /// Mining pools: which pools mined the recent blocks.
  $async.Future<ListMiningPoolsResponse> listMiningPools($pb.ClientContext? ctx, ListMiningPoolsRequest request) =>
      _client.invoke<ListMiningPoolsResponse>(
          ctx, 'BitwindowdService', 'ListMiningPools', request, ListMiningPoolsResponse());

  /// Swap bitcoind network. bitwindowd is the entry point so the DB swap
  /// (network-scoped folder) is co-located with the orchestrator update.
  /// Implementation: forward to orchestratord's SetBitcoinConfigNetwork
  /// (which rewrites bitcoin.conf and restarts bitcoind on the new chain),
  /// then exit so the launcher restarts bitwindowd with a fresh DB scoped
  /// to the new network. Returns once orchestratord acknowledges the swap;
  /// the bitwindowd process exit happens shortly after.
  $async.Future<UpdateNetworkResponse> updateNetwork($pb.ClientContext? ctx, UpdateNetworkRequest request) => _client
      .invoke<UpdateNetworkResponse>(ctx, 'BitwindowdService', 'UpdateNetwork', request, UpdateNetworkResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
