//
//  Generated code. Do not modify.
//  source: bitwindowd/v1/bitwindowd.proto
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

import '../../google/protobuf/empty.pb.dart' as $1;
import '../../google/protobuf/timestamp.pb.dart' as $0;
import 'bitwindowd.pbenum.dart';

export 'bitwindowd.pbenum.dart';

class StopBitwindowRequest extends $pb.GeneratedMessage {
  factory StopBitwindowRequest({
    $core.bool? skipDownstream,
  }) {
    final $result = create();
    if (skipDownstream != null) {
      $result.skipDownstream = skipDownstream;
    }
    return $result;
  }
  StopBitwindowRequest._() : super();
  factory StopBitwindowRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StopBitwindowRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StopBitwindowRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'skipDownstream')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StopBitwindowRequest clone() => StopBitwindowRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StopBitwindowRequest copyWith(void Function(StopBitwindowRequest) updates) => super.copyWith((message) => updates(message as StopBitwindowRequest)) as StopBitwindowRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StopBitwindowRequest create() => StopBitwindowRequest._();
  StopBitwindowRequest createEmptyInstance() => create();
  static $pb.PbList<StopBitwindowRequest> createRepeated() => $pb.PbList<StopBitwindowRequest>();
  @$core.pragma('dart2js:noInline')
  static StopBitwindowRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StopBitwindowRequest>(create);
  static StopBitwindowRequest? _defaultInstance;

  /// If true, only stop bitwindow itself without stopping downstream services (enforcer, bitcoind)
  @$pb.TagNumber(1)
  $core.bool get skipDownstream => $_getBF(0);
  @$pb.TagNumber(1)
  set skipDownstream($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSkipDownstream() => $_has(0);
  @$pb.TagNumber(1)
  void clearSkipDownstream() => clearField(1);
}

class CreateDenialRequest extends $pb.GeneratedMessage {
  factory CreateDenialRequest({
    $core.String? txid,
    $core.int? vout,
    $core.int? delaySeconds,
    $core.int? numHops,
    $core.Iterable<$fixnum.Int64>? targetUtxoSizes,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (vout != null) {
      $result.vout = vout;
    }
    if (delaySeconds != null) {
      $result.delaySeconds = delaySeconds;
    }
    if (numHops != null) {
      $result.numHops = numHops;
    }
    if (targetUtxoSizes != null) {
      $result.targetUtxoSizes.addAll(targetUtxoSizes);
    }
    return $result;
  }
  CreateDenialRequest._() : super();
  factory CreateDenialRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateDenialRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateDenialRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'vout', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'delaySeconds', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'numHops', $pb.PbFieldType.O3)
    ..p<$fixnum.Int64>(5, _omitFieldNames ? '' : 'targetUtxoSizes', $pb.PbFieldType.K6)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateDenialRequest clone() => CreateDenialRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateDenialRequest copyWith(void Function(CreateDenialRequest) updates) => super.copyWith((message) => updates(message as CreateDenialRequest)) as CreateDenialRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateDenialRequest create() => CreateDenialRequest._();
  CreateDenialRequest createEmptyInstance() => create();
  static $pb.PbList<CreateDenialRequest> createRepeated() => $pb.PbList<CreateDenialRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateDenialRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateDenialRequest>(create);
  static CreateDenialRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get vout => $_getIZ(1);
  @$pb.TagNumber(2)
  set vout($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearVout() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get delaySeconds => $_getIZ(2);
  @$pb.TagNumber(3)
  set delaySeconds($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDelaySeconds() => $_has(2);
  @$pb.TagNumber(3)
  void clearDelaySeconds() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get numHops => $_getIZ(3);
  @$pb.TagNumber(4)
  set numHops($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasNumHops() => $_has(3);
  @$pb.TagNumber(4)
  void clearNumHops() => clearField(4);

  /// If set, create UTXOs of these specific sizes (in satoshis).
  /// Each hop will try to create one UTXO of the next target size.
  /// Max length should equal num_hops.
  @$pb.TagNumber(5)
  $core.List<$fixnum.Int64> get targetUtxoSizes => $_getList(4);
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
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (numHops != null) {
      $result.numHops = numHops;
    }
    if (delaySeconds != null) {
      $result.delaySeconds = delaySeconds;
    }
    if (createTime != null) {
      $result.createTime = createTime;
    }
    if (cancelTime != null) {
      $result.cancelTime = cancelTime;
    }
    if (cancelReason != null) {
      $result.cancelReason = cancelReason;
    }
    if (nextExecutionTime != null) {
      $result.nextExecutionTime = nextExecutionTime;
    }
    if (executions != null) {
      $result.executions.addAll(executions);
    }
    if (hopsCompleted != null) {
      $result.hopsCompleted = hopsCompleted;
    }
    if (isChange != null) {
      $result.isChange = isChange;
    }
    if (targetUtxoSizes != null) {
      $result.targetUtxoSizes.addAll(targetUtxoSizes);
    }
    return $result;
  }
  DenialInfo._() : super();
  factory DenialInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DenialInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DenialInfo', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'numHops', $pb.PbFieldType.O3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'delaySeconds', $pb.PbFieldType.O3)
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'createTime', subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'cancelTime', subBuilder: $0.Timestamp.create)
    ..aOS(6, _omitFieldNames ? '' : 'cancelReason')
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'nextExecutionTime', subBuilder: $0.Timestamp.create)
    ..pc<ExecutedDenial>(8, _omitFieldNames ? '' : 'executions', $pb.PbFieldType.PM, subBuilder: ExecutedDenial.create)
    ..a<$core.int>(9, _omitFieldNames ? '' : 'hopsCompleted', $pb.PbFieldType.OU3)
    ..aOB(10, _omitFieldNames ? '' : 'isChange')
    ..p<$fixnum.Int64>(11, _omitFieldNames ? '' : 'targetUtxoSizes', $pb.PbFieldType.K6)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DenialInfo clone() => DenialInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DenialInfo copyWith(void Function(DenialInfo) updates) => super.copyWith((message) => updates(message as DenialInfo)) as DenialInfo;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DenialInfo create() => DenialInfo._();
  DenialInfo createEmptyInstance() => create();
  static $pb.PbList<DenialInfo> createRepeated() => $pb.PbList<DenialInfo>();
  @$core.pragma('dart2js:noInline')
  static DenialInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DenialInfo>(create);
  static DenialInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get numHops => $_getIZ(1);
  @$pb.TagNumber(2)
  set numHops($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasNumHops() => $_has(1);
  @$pb.TagNumber(2)
  void clearNumHops() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get delaySeconds => $_getIZ(2);
  @$pb.TagNumber(3)
  set delaySeconds($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDelaySeconds() => $_has(2);
  @$pb.TagNumber(3)
  void clearDelaySeconds() => clearField(3);

  @$pb.TagNumber(4)
  $0.Timestamp get createTime => $_getN(3);
  @$pb.TagNumber(4)
  set createTime($0.Timestamp v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasCreateTime() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreateTime() => clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureCreateTime() => $_ensure(3);

  @$pb.TagNumber(5)
  $0.Timestamp get cancelTime => $_getN(4);
  @$pb.TagNumber(5)
  set cancelTime($0.Timestamp v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasCancelTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearCancelTime() => clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureCancelTime() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.String get cancelReason => $_getSZ(5);
  @$pb.TagNumber(6)
  set cancelReason($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasCancelReason() => $_has(5);
  @$pb.TagNumber(6)
  void clearCancelReason() => clearField(6);

  @$pb.TagNumber(7)
  $0.Timestamp get nextExecutionTime => $_getN(6);
  @$pb.TagNumber(7)
  set nextExecutionTime($0.Timestamp v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasNextExecutionTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearNextExecutionTime() => clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureNextExecutionTime() => $_ensure(6);

  @$pb.TagNumber(8)
  $core.List<ExecutedDenial> get executions => $_getList(7);

  @$pb.TagNumber(9)
  $core.int get hopsCompleted => $_getIZ(8);
  @$pb.TagNumber(9)
  set hopsCompleted($core.int v) { $_setUnsignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasHopsCompleted() => $_has(8);
  @$pb.TagNumber(9)
  void clearHopsCompleted() => clearField(9);

  @$pb.TagNumber(10)
  $core.bool get isChange => $_getBF(9);
  @$pb.TagNumber(10)
  set isChange($core.bool v) { $_setBool(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasIsChange() => $_has(9);
  @$pb.TagNumber(10)
  void clearIsChange() => clearField(10);

  /// Target UTXO sizes user wants to create (one per hop)
  @$pb.TagNumber(11)
  $core.List<$fixnum.Int64> get targetUtxoSizes => $_getList(10);
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
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (denialId != null) {
      $result.denialId = denialId;
    }
    if (fromTxid != null) {
      $result.fromTxid = fromTxid;
    }
    if (fromVout != null) {
      $result.fromVout = fromVout;
    }
    if (toTxid != null) {
      $result.toTxid = toTxid;
    }
    if (createTime != null) {
      $result.createTime = createTime;
    }
    return $result;
  }
  ExecutedDenial._() : super();
  factory ExecutedDenial.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ExecutedDenial.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ExecutedDenial', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aInt64(2, _omitFieldNames ? '' : 'denialId')
    ..aOS(3, _omitFieldNames ? '' : 'fromTxid')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'fromVout', $pb.PbFieldType.OU3)
    ..aOS(5, _omitFieldNames ? '' : 'toTxid')
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'createTime', subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ExecutedDenial clone() => ExecutedDenial()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ExecutedDenial copyWith(void Function(ExecutedDenial) updates) => super.copyWith((message) => updates(message as ExecutedDenial)) as ExecutedDenial;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ExecutedDenial create() => ExecutedDenial._();
  ExecutedDenial createEmptyInstance() => create();
  static $pb.PbList<ExecutedDenial> createRepeated() => $pb.PbList<ExecutedDenial>();
  @$core.pragma('dart2js:noInline')
  static ExecutedDenial getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ExecutedDenial>(create);
  static ExecutedDenial? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get denialId => $_getI64(1);
  @$pb.TagNumber(2)
  set denialId($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDenialId() => $_has(1);
  @$pb.TagNumber(2)
  void clearDenialId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get fromTxid => $_getSZ(2);
  @$pb.TagNumber(3)
  set fromTxid($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFromTxid() => $_has(2);
  @$pb.TagNumber(3)
  void clearFromTxid() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get fromVout => $_getIZ(3);
  @$pb.TagNumber(4)
  set fromVout($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFromVout() => $_has(3);
  @$pb.TagNumber(4)
  void clearFromVout() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get toTxid => $_getSZ(4);
  @$pb.TagNumber(5)
  set toTxid($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasToTxid() => $_has(4);
  @$pb.TagNumber(5)
  void clearToTxid() => clearField(5);

  @$pb.TagNumber(6)
  $0.Timestamp get createTime => $_getN(5);
  @$pb.TagNumber(6)
  set createTime($0.Timestamp v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasCreateTime() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreateTime() => clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureCreateTime() => $_ensure(5);
}

class CancelDenialRequest extends $pb.GeneratedMessage {
  factory CancelDenialRequest({
    $fixnum.Int64? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  CancelDenialRequest._() : super();
  factory CancelDenialRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CancelDenialRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CancelDenialRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CancelDenialRequest clone() => CancelDenialRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CancelDenialRequest copyWith(void Function(CancelDenialRequest) updates) => super.copyWith((message) => updates(message as CancelDenialRequest)) as CancelDenialRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CancelDenialRequest create() => CancelDenialRequest._();
  CancelDenialRequest createEmptyInstance() => create();
  static $pb.PbList<CancelDenialRequest> createRepeated() => $pb.PbList<CancelDenialRequest>();
  @$core.pragma('dart2js:noInline')
  static CancelDenialRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CancelDenialRequest>(create);
  static CancelDenialRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class CreateAddressBookEntryRequest extends $pb.GeneratedMessage {
  factory CreateAddressBookEntryRequest({
    $core.String? label,
    $core.String? address,
    Direction? direction,
  }) {
    final $result = create();
    if (label != null) {
      $result.label = label;
    }
    if (address != null) {
      $result.address = address;
    }
    if (direction != null) {
      $result.direction = direction;
    }
    return $result;
  }
  CreateAddressBookEntryRequest._() : super();
  factory CreateAddressBookEntryRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateAddressBookEntryRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateAddressBookEntryRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'label')
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..e<Direction>(3, _omitFieldNames ? '' : 'direction', $pb.PbFieldType.OE, defaultOrMaker: Direction.DIRECTION_UNSPECIFIED, valueOf: Direction.valueOf, enumValues: Direction.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateAddressBookEntryRequest clone() => CreateAddressBookEntryRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateAddressBookEntryRequest copyWith(void Function(CreateAddressBookEntryRequest) updates) => super.copyWith((message) => updates(message as CreateAddressBookEntryRequest)) as CreateAddressBookEntryRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateAddressBookEntryRequest create() => CreateAddressBookEntryRequest._();
  CreateAddressBookEntryRequest createEmptyInstance() => create();
  static $pb.PbList<CreateAddressBookEntryRequest> createRepeated() => $pb.PbList<CreateAddressBookEntryRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateAddressBookEntryRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateAddressBookEntryRequest>(create);
  static CreateAddressBookEntryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get label => $_getSZ(0);
  @$pb.TagNumber(1)
  set label($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLabel() => $_has(0);
  @$pb.TagNumber(1)
  void clearLabel() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get address => $_getSZ(1);
  @$pb.TagNumber(2)
  set address($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => clearField(2);

  @$pb.TagNumber(3)
  Direction get direction => $_getN(2);
  @$pb.TagNumber(3)
  set direction(Direction v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasDirection() => $_has(2);
  @$pb.TagNumber(3)
  void clearDirection() => clearField(3);
}

class CreateAddressBookEntryResponse extends $pb.GeneratedMessage {
  factory CreateAddressBookEntryResponse({
    AddressBookEntry? entry,
  }) {
    final $result = create();
    if (entry != null) {
      $result.entry = entry;
    }
    return $result;
  }
  CreateAddressBookEntryResponse._() : super();
  factory CreateAddressBookEntryResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateAddressBookEntryResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateAddressBookEntryResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'), createEmptyInstance: create)
    ..aOM<AddressBookEntry>(1, _omitFieldNames ? '' : 'entry', subBuilder: AddressBookEntry.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateAddressBookEntryResponse clone() => CreateAddressBookEntryResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateAddressBookEntryResponse copyWith(void Function(CreateAddressBookEntryResponse) updates) => super.copyWith((message) => updates(message as CreateAddressBookEntryResponse)) as CreateAddressBookEntryResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateAddressBookEntryResponse create() => CreateAddressBookEntryResponse._();
  CreateAddressBookEntryResponse createEmptyInstance() => create();
  static $pb.PbList<CreateAddressBookEntryResponse> createRepeated() => $pb.PbList<CreateAddressBookEntryResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateAddressBookEntryResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateAddressBookEntryResponse>(create);
  static CreateAddressBookEntryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  AddressBookEntry get entry => $_getN(0);
  @$pb.TagNumber(1)
  set entry(AddressBookEntry v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasEntry() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntry() => clearField(1);
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
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (label != null) {
      $result.label = label;
    }
    if (address != null) {
      $result.address = address;
    }
    if (direction != null) {
      $result.direction = direction;
    }
    if (createTime != null) {
      $result.createTime = createTime;
    }
    if (walletId != null) {
      $result.walletId = walletId;
    }
    return $result;
  }
  AddressBookEntry._() : super();
  factory AddressBookEntry.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddressBookEntry.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddressBookEntry', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..aOS(3, _omitFieldNames ? '' : 'address')
    ..e<Direction>(4, _omitFieldNames ? '' : 'direction', $pb.PbFieldType.OE, defaultOrMaker: Direction.DIRECTION_UNSPECIFIED, valueOf: Direction.valueOf, enumValues: Direction.values)
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'createTime', subBuilder: $0.Timestamp.create)
    ..aOS(6, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddressBookEntry clone() => AddressBookEntry()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddressBookEntry copyWith(void Function(AddressBookEntry) updates) => super.copyWith((message) => updates(message as AddressBookEntry)) as AddressBookEntry;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddressBookEntry create() => AddressBookEntry._();
  AddressBookEntry createEmptyInstance() => create();
  static $pb.PbList<AddressBookEntry> createRepeated() => $pb.PbList<AddressBookEntry>();
  @$core.pragma('dart2js:noInline')
  static AddressBookEntry getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddressBookEntry>(create);
  static AddressBookEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get address => $_getSZ(2);
  @$pb.TagNumber(3)
  set address($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddress() => clearField(3);

  @$pb.TagNumber(4)
  Direction get direction => $_getN(3);
  @$pb.TagNumber(4)
  set direction(Direction v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasDirection() => $_has(3);
  @$pb.TagNumber(4)
  void clearDirection() => clearField(4);

  @$pb.TagNumber(5)
  $0.Timestamp get createTime => $_getN(4);
  @$pb.TagNumber(5)
  set createTime($0.Timestamp v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasCreateTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearCreateTime() => clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureCreateTime() => $_ensure(4);

  @$pb.TagNumber(6)
  $core.String get walletId => $_getSZ(5);
  @$pb.TagNumber(6)
  set walletId($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasWalletId() => $_has(5);
  @$pb.TagNumber(6)
  void clearWalletId() => clearField(6);
}

class ListAddressBookResponse extends $pb.GeneratedMessage {
  factory ListAddressBookResponse({
    $core.Iterable<AddressBookEntry>? entries,
  }) {
    final $result = create();
    if (entries != null) {
      $result.entries.addAll(entries);
    }
    return $result;
  }
  ListAddressBookResponse._() : super();
  factory ListAddressBookResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListAddressBookResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListAddressBookResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'), createEmptyInstance: create)
    ..pc<AddressBookEntry>(1, _omitFieldNames ? '' : 'entries', $pb.PbFieldType.PM, subBuilder: AddressBookEntry.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListAddressBookResponse clone() => ListAddressBookResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListAddressBookResponse copyWith(void Function(ListAddressBookResponse) updates) => super.copyWith((message) => updates(message as ListAddressBookResponse)) as ListAddressBookResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListAddressBookResponse create() => ListAddressBookResponse._();
  ListAddressBookResponse createEmptyInstance() => create();
  static $pb.PbList<ListAddressBookResponse> createRepeated() => $pb.PbList<ListAddressBookResponse>();
  @$core.pragma('dart2js:noInline')
  static ListAddressBookResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListAddressBookResponse>(create);
  static ListAddressBookResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<AddressBookEntry> get entries => $_getList(0);
}

class UpdateAddressBookEntryRequest extends $pb.GeneratedMessage {
  factory UpdateAddressBookEntryRequest({
    $fixnum.Int64? id,
    $core.String? label,
    $core.String? address,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (label != null) {
      $result.label = label;
    }
    if (address != null) {
      $result.address = address;
    }
    return $result;
  }
  UpdateAddressBookEntryRequest._() : super();
  factory UpdateAddressBookEntryRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UpdateAddressBookEntryRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateAddressBookEntryRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..aOS(3, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UpdateAddressBookEntryRequest clone() => UpdateAddressBookEntryRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UpdateAddressBookEntryRequest copyWith(void Function(UpdateAddressBookEntryRequest) updates) => super.copyWith((message) => updates(message as UpdateAddressBookEntryRequest)) as UpdateAddressBookEntryRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UpdateAddressBookEntryRequest create() => UpdateAddressBookEntryRequest._();
  UpdateAddressBookEntryRequest createEmptyInstance() => create();
  static $pb.PbList<UpdateAddressBookEntryRequest> createRepeated() => $pb.PbList<UpdateAddressBookEntryRequest>();
  @$core.pragma('dart2js:noInline')
  static UpdateAddressBookEntryRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UpdateAddressBookEntryRequest>(create);
  static UpdateAddressBookEntryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get address => $_getSZ(2);
  @$pb.TagNumber(3)
  set address($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddress() => clearField(3);
}

class DeleteAddressBookEntryRequest extends $pb.GeneratedMessage {
  factory DeleteAddressBookEntryRequest({
    $fixnum.Int64? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  DeleteAddressBookEntryRequest._() : super();
  factory DeleteAddressBookEntryRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeleteAddressBookEntryRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteAddressBookEntryRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeleteAddressBookEntryRequest clone() => DeleteAddressBookEntryRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeleteAddressBookEntryRequest copyWith(void Function(DeleteAddressBookEntryRequest) updates) => super.copyWith((message) => updates(message as DeleteAddressBookEntryRequest)) as DeleteAddressBookEntryRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteAddressBookEntryRequest create() => DeleteAddressBookEntryRequest._();
  DeleteAddressBookEntryRequest createEmptyInstance() => create();
  static $pb.PbList<DeleteAddressBookEntryRequest> createRepeated() => $pb.PbList<DeleteAddressBookEntryRequest>();
  @$core.pragma('dart2js:noInline')
  static DeleteAddressBookEntryRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteAddressBookEntryRequest>(create);
  static DeleteAddressBookEntryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class GetSyncInfoResponse extends $pb.GeneratedMessage {
  factory GetSyncInfoResponse({
    $fixnum.Int64? tipBlockHeight,
    $fixnum.Int64? tipBlockTime,
    $core.String? tipBlockHash,
    $0.Timestamp? tipBlockProcessedAt,
    $fixnum.Int64? headerHeight,
    $core.double? syncProgress,
  }) {
    final $result = create();
    if (tipBlockHeight != null) {
      $result.tipBlockHeight = tipBlockHeight;
    }
    if (tipBlockTime != null) {
      $result.tipBlockTime = tipBlockTime;
    }
    if (tipBlockHash != null) {
      $result.tipBlockHash = tipBlockHash;
    }
    if (tipBlockProcessedAt != null) {
      $result.tipBlockProcessedAt = tipBlockProcessedAt;
    }
    if (headerHeight != null) {
      $result.headerHeight = headerHeight;
    }
    if (syncProgress != null) {
      $result.syncProgress = syncProgress;
    }
    return $result;
  }
  GetSyncInfoResponse._() : super();
  factory GetSyncInfoResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetSyncInfoResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSyncInfoResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'tipBlockHeight')
    ..aInt64(2, _omitFieldNames ? '' : 'tipBlockTime')
    ..aOS(3, _omitFieldNames ? '' : 'tipBlockHash')
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'tipBlockProcessedAt', subBuilder: $0.Timestamp.create)
    ..aInt64(5, _omitFieldNames ? '' : 'headerHeight')
    ..a<$core.double>(6, _omitFieldNames ? '' : 'syncProgress', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetSyncInfoResponse clone() => GetSyncInfoResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetSyncInfoResponse copyWith(void Function(GetSyncInfoResponse) updates) => super.copyWith((message) => updates(message as GetSyncInfoResponse)) as GetSyncInfoResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSyncInfoResponse create() => GetSyncInfoResponse._();
  GetSyncInfoResponse createEmptyInstance() => create();
  static $pb.PbList<GetSyncInfoResponse> createRepeated() => $pb.PbList<GetSyncInfoResponse>();
  @$core.pragma('dart2js:noInline')
  static GetSyncInfoResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetSyncInfoResponse>(create);
  static GetSyncInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get tipBlockHeight => $_getI64(0);
  @$pb.TagNumber(1)
  set tipBlockHeight($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTipBlockHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearTipBlockHeight() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get tipBlockTime => $_getI64(1);
  @$pb.TagNumber(2)
  set tipBlockTime($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTipBlockTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearTipBlockTime() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get tipBlockHash => $_getSZ(2);
  @$pb.TagNumber(3)
  set tipBlockHash($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTipBlockHash() => $_has(2);
  @$pb.TagNumber(3)
  void clearTipBlockHash() => clearField(3);

  @$pb.TagNumber(4)
  $0.Timestamp get tipBlockProcessedAt => $_getN(3);
  @$pb.TagNumber(4)
  set tipBlockProcessedAt($0.Timestamp v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasTipBlockProcessedAt() => $_has(3);
  @$pb.TagNumber(4)
  void clearTipBlockProcessedAt() => clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureTipBlockProcessedAt() => $_ensure(3);

  @$pb.TagNumber(5)
  $fixnum.Int64 get headerHeight => $_getI64(4);
  @$pb.TagNumber(5)
  set headerHeight($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasHeaderHeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearHeaderHeight() => clearField(5);

  /// sync progress between 0 and 1
  @$pb.TagNumber(6)
  $core.double get syncProgress => $_getN(5);
  @$pb.TagNumber(6)
  set syncProgress($core.double v) { $_setDouble(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasSyncProgress() => $_has(5);
  @$pb.TagNumber(6)
  void clearSyncProgress() => clearField(6);
}

/// Request to set a transaction note
class SetTransactionNoteRequest extends $pb.GeneratedMessage {
  factory SetTransactionNoteRequest({
    $core.String? txid,
    $core.String? note,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (note != null) {
      $result.note = note;
    }
    return $result;
  }
  SetTransactionNoteRequest._() : super();
  factory SetTransactionNoteRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetTransactionNoteRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetTransactionNoteRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aOS(2, _omitFieldNames ? '' : 'note')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetTransactionNoteRequest clone() => SetTransactionNoteRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetTransactionNoteRequest copyWith(void Function(SetTransactionNoteRequest) updates) => super.copyWith((message) => updates(message as SetTransactionNoteRequest)) as SetTransactionNoteRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetTransactionNoteRequest create() => SetTransactionNoteRequest._();
  SetTransactionNoteRequest createEmptyInstance() => create();
  static $pb.PbList<SetTransactionNoteRequest> createRepeated() => $pb.PbList<SetTransactionNoteRequest>();
  @$core.pragma('dart2js:noInline')
  static SetTransactionNoteRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetTransactionNoteRequest>(create);
  static SetTransactionNoteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get note => $_getSZ(1);
  @$pb.TagNumber(2)
  set note($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasNote() => $_has(1);
  @$pb.TagNumber(2)
  void clearNote() => clearField(2);
}

class GetFireplaceStatsResponse extends $pb.GeneratedMessage {
  factory GetFireplaceStatsResponse({
    $fixnum.Int64? transactionCount24h,
    $fixnum.Int64? coinnewsCount7d,
    $fixnum.Int64? blockCount24h,
  }) {
    final $result = create();
    if (transactionCount24h != null) {
      $result.transactionCount24h = transactionCount24h;
    }
    if (coinnewsCount7d != null) {
      $result.coinnewsCount7d = coinnewsCount7d;
    }
    if (blockCount24h != null) {
      $result.blockCount24h = blockCount24h;
    }
    return $result;
  }
  GetFireplaceStatsResponse._() : super();
  factory GetFireplaceStatsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetFireplaceStatsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetFireplaceStatsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'transactionCount24h', protoName: 'transaction_count_24h')
    ..aInt64(2, _omitFieldNames ? '' : 'coinnewsCount7d', protoName: 'coinnews_count_7d')
    ..aInt64(3, _omitFieldNames ? '' : 'blockCount24h', protoName: 'block_count_24h')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetFireplaceStatsResponse clone() => GetFireplaceStatsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetFireplaceStatsResponse copyWith(void Function(GetFireplaceStatsResponse) updates) => super.copyWith((message) => updates(message as GetFireplaceStatsResponse)) as GetFireplaceStatsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFireplaceStatsResponse create() => GetFireplaceStatsResponse._();
  GetFireplaceStatsResponse createEmptyInstance() => create();
  static $pb.PbList<GetFireplaceStatsResponse> createRepeated() => $pb.PbList<GetFireplaceStatsResponse>();
  @$core.pragma('dart2js:noInline')
  static GetFireplaceStatsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetFireplaceStatsResponse>(create);
  static GetFireplaceStatsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get transactionCount24h => $_getI64(0);
  @$pb.TagNumber(1)
  set transactionCount24h($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTransactionCount24h() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransactionCount24h() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get coinnewsCount7d => $_getI64(1);
  @$pb.TagNumber(2)
  set coinnewsCount7d($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCoinnewsCount7d() => $_has(1);
  @$pb.TagNumber(2)
  void clearCoinnewsCount7d() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get blockCount24h => $_getI64(2);
  @$pb.TagNumber(3)
  set blockCount24h($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasBlockCount24h() => $_has(2);
  @$pb.TagNumber(3)
  void clearBlockCount24h() => clearField(3);
}

class ListRecentTransactionsRequest extends $pb.GeneratedMessage {
  factory ListRecentTransactionsRequest({
    $fixnum.Int64? count,
  }) {
    final $result = create();
    if (count != null) {
      $result.count = count;
    }
    return $result;
  }
  ListRecentTransactionsRequest._() : super();
  factory ListRecentTransactionsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListRecentTransactionsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListRecentTransactionsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'count')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListRecentTransactionsRequest clone() => ListRecentTransactionsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListRecentTransactionsRequest copyWith(void Function(ListRecentTransactionsRequest) updates) => super.copyWith((message) => updates(message as ListRecentTransactionsRequest)) as ListRecentTransactionsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListRecentTransactionsRequest create() => ListRecentTransactionsRequest._();
  ListRecentTransactionsRequest createEmptyInstance() => create();
  static $pb.PbList<ListRecentTransactionsRequest> createRepeated() => $pb.PbList<ListRecentTransactionsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListRecentTransactionsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListRecentTransactionsRequest>(create);
  static ListRecentTransactionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get count => $_getI64(0);
  @$pb.TagNumber(1)
  set count($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearCount() => clearField(1);
}

class ListRecentTransactionsResponse extends $pb.GeneratedMessage {
  factory ListRecentTransactionsResponse({
    $core.Iterable<RecentTransaction>? transactions,
  }) {
    final $result = create();
    if (transactions != null) {
      $result.transactions.addAll(transactions);
    }
    return $result;
  }
  ListRecentTransactionsResponse._() : super();
  factory ListRecentTransactionsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListRecentTransactionsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListRecentTransactionsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'), createEmptyInstance: create)
    ..pc<RecentTransaction>(1, _omitFieldNames ? '' : 'transactions', $pb.PbFieldType.PM, subBuilder: RecentTransaction.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListRecentTransactionsResponse clone() => ListRecentTransactionsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListRecentTransactionsResponse copyWith(void Function(ListRecentTransactionsResponse) updates) => super.copyWith((message) => updates(message as ListRecentTransactionsResponse)) as ListRecentTransactionsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListRecentTransactionsResponse create() => ListRecentTransactionsResponse._();
  ListRecentTransactionsResponse createEmptyInstance() => create();
  static $pb.PbList<ListRecentTransactionsResponse> createRepeated() => $pb.PbList<ListRecentTransactionsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListRecentTransactionsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListRecentTransactionsResponse>(create);
  static ListRecentTransactionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<RecentTransaction> get transactions => $_getList(0);
}

class RecentTransaction extends $pb.GeneratedMessage {
  factory RecentTransaction({
    $core.int? virtualSize,
    $0.Timestamp? time,
    $core.String? txid,
    $fixnum.Int64? feeSats,
    $core.int? confirmedInBlock,
  }) {
    final $result = create();
    if (virtualSize != null) {
      $result.virtualSize = virtualSize;
    }
    if (time != null) {
      $result.time = time;
    }
    if (txid != null) {
      $result.txid = txid;
    }
    if (feeSats != null) {
      $result.feeSats = feeSats;
    }
    if (confirmedInBlock != null) {
      $result.confirmedInBlock = confirmedInBlock;
    }
    return $result;
  }
  RecentTransaction._() : super();
  factory RecentTransaction.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RecentTransaction.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RecentTransaction', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'virtualSize', $pb.PbFieldType.OU3)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'time', subBuilder: $0.Timestamp.create)
    ..aOS(3, _omitFieldNames ? '' : 'txid')
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'feeSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'confirmedInBlock', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RecentTransaction clone() => RecentTransaction()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RecentTransaction copyWith(void Function(RecentTransaction) updates) => super.copyWith((message) => updates(message as RecentTransaction)) as RecentTransaction;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RecentTransaction create() => RecentTransaction._();
  RecentTransaction createEmptyInstance() => create();
  static $pb.PbList<RecentTransaction> createRepeated() => $pb.PbList<RecentTransaction>();
  @$core.pragma('dart2js:noInline')
  static RecentTransaction getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RecentTransaction>(create);
  static RecentTransaction? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get virtualSize => $_getIZ(0);
  @$pb.TagNumber(1)
  set virtualSize($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasVirtualSize() => $_has(0);
  @$pb.TagNumber(1)
  void clearVirtualSize() => clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get time => $_getN(1);
  @$pb.TagNumber(2)
  set time($0.Timestamp v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearTime() => clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTime() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get txid => $_getSZ(2);
  @$pb.TagNumber(3)
  set txid($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTxid() => $_has(2);
  @$pb.TagNumber(3)
  void clearTxid() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get feeSats => $_getI64(3);
  @$pb.TagNumber(4)
  set feeSats($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFeeSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearFeeSats() => clearField(4);

  /// Block height of the transaction, if confirmed
  @$pb.TagNumber(5)
  $core.int get confirmedInBlock => $_getIZ(4);
  @$pb.TagNumber(5)
  set confirmedInBlock($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasConfirmedInBlock() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfirmedInBlock() => clearField(5);
}

class ListBlocksRequest extends $pb.GeneratedMessage {
  factory ListBlocksRequest({
    $core.int? startHeight,
    $core.int? pageSize,
  }) {
    final $result = create();
    if (startHeight != null) {
      $result.startHeight = startHeight;
    }
    if (pageSize != null) {
      $result.pageSize = pageSize;
    }
    return $result;
  }
  ListBlocksRequest._() : super();
  factory ListBlocksRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListBlocksRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListBlocksRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'startHeight', $pb.PbFieldType.OU3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'pageSize', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListBlocksRequest clone() => ListBlocksRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListBlocksRequest copyWith(void Function(ListBlocksRequest) updates) => super.copyWith((message) => updates(message as ListBlocksRequest)) as ListBlocksRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListBlocksRequest create() => ListBlocksRequest._();
  ListBlocksRequest createEmptyInstance() => create();
  static $pb.PbList<ListBlocksRequest> createRepeated() => $pb.PbList<ListBlocksRequest>();
  @$core.pragma('dart2js:noInline')
  static ListBlocksRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListBlocksRequest>(create);
  static ListBlocksRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get startHeight => $_getIZ(0);
  @$pb.TagNumber(1)
  set startHeight($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasStartHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearStartHeight() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get pageSize => $_getIZ(1);
  @$pb.TagNumber(2)
  set pageSize($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPageSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageSize() => clearField(2);
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
  }) {
    final $result = create();
    if (blockTime != null) {
      $result.blockTime = blockTime;
    }
    if (height != null) {
      $result.height = height;
    }
    if (hash != null) {
      $result.hash = hash;
    }
    if (confirmations != null) {
      $result.confirmations = confirmations;
    }
    if (version != null) {
      $result.version = version;
    }
    if (versionHex != null) {
      $result.versionHex = versionHex;
    }
    if (merkleRoot != null) {
      $result.merkleRoot = merkleRoot;
    }
    if (nonce != null) {
      $result.nonce = nonce;
    }
    if (bits != null) {
      $result.bits = bits;
    }
    if (difficulty != null) {
      $result.difficulty = difficulty;
    }
    if (previousBlockHash != null) {
      $result.previousBlockHash = previousBlockHash;
    }
    if (nextBlockHash != null) {
      $result.nextBlockHash = nextBlockHash;
    }
    if (strippedSize != null) {
      $result.strippedSize = strippedSize;
    }
    if (size != null) {
      $result.size = size;
    }
    if (weight != null) {
      $result.weight = weight;
    }
    if (txids != null) {
      $result.txids.addAll(txids);
    }
    return $result;
  }
  Block._() : super();
  factory Block.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Block.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Block', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'), createEmptyInstance: create)
    ..aOM<$0.Timestamp>(1, _omitFieldNames ? '' : 'blockTime', subBuilder: $0.Timestamp.create)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'height', $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'hash')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'confirmations', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'version', $pb.PbFieldType.O3)
    ..aOS(6, _omitFieldNames ? '' : 'versionHex')
    ..aOS(7, _omitFieldNames ? '' : 'merkleRoot')
    ..a<$core.int>(8, _omitFieldNames ? '' : 'nonce', $pb.PbFieldType.OU3)
    ..aOS(9, _omitFieldNames ? '' : 'bits')
    ..a<$core.double>(10, _omitFieldNames ? '' : 'difficulty', $pb.PbFieldType.OD)
    ..aOS(11, _omitFieldNames ? '' : 'previousBlockHash')
    ..aOS(12, _omitFieldNames ? '' : 'nextBlockHash')
    ..a<$core.int>(13, _omitFieldNames ? '' : 'strippedSize', $pb.PbFieldType.O3)
    ..a<$core.int>(14, _omitFieldNames ? '' : 'size', $pb.PbFieldType.O3)
    ..a<$core.int>(15, _omitFieldNames ? '' : 'weight', $pb.PbFieldType.O3)
    ..pPS(16, _omitFieldNames ? '' : 'txids')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Block clone() => Block()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Block copyWith(void Function(Block) updates) => super.copyWith((message) => updates(message as Block)) as Block;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block create() => Block._();
  Block createEmptyInstance() => create();
  static $pb.PbList<Block> createRepeated() => $pb.PbList<Block>();
  @$core.pragma('dart2js:noInline')
  static Block getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Block>(create);
  static Block? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Timestamp get blockTime => $_getN(0);
  @$pb.TagNumber(1)
  set blockTime($0.Timestamp v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBlockTime() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockTime() => clearField(1);
  @$pb.TagNumber(1)
  $0.Timestamp ensureBlockTime() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.int get height => $_getIZ(1);
  @$pb.TagNumber(2)
  set height($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeight() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get hash => $_getSZ(2);
  @$pb.TagNumber(3)
  set hash($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasHash() => $_has(2);
  @$pb.TagNumber(3)
  void clearHash() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get confirmations => $_getIZ(3);
  @$pb.TagNumber(4)
  set confirmations($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasConfirmations() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfirmations() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get version => $_getIZ(4);
  @$pb.TagNumber(5)
  set version($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearVersion() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get versionHex => $_getSZ(5);
  @$pb.TagNumber(6)
  set versionHex($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasVersionHex() => $_has(5);
  @$pb.TagNumber(6)
  void clearVersionHex() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get merkleRoot => $_getSZ(6);
  @$pb.TagNumber(7)
  set merkleRoot($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasMerkleRoot() => $_has(6);
  @$pb.TagNumber(7)
  void clearMerkleRoot() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get nonce => $_getIZ(7);
  @$pb.TagNumber(8)
  set nonce($core.int v) { $_setUnsignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasNonce() => $_has(7);
  @$pb.TagNumber(8)
  void clearNonce() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get bits => $_getSZ(8);
  @$pb.TagNumber(9)
  set bits($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasBits() => $_has(8);
  @$pb.TagNumber(9)
  void clearBits() => clearField(9);

  @$pb.TagNumber(10)
  $core.double get difficulty => $_getN(9);
  @$pb.TagNumber(10)
  set difficulty($core.double v) { $_setDouble(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasDifficulty() => $_has(9);
  @$pb.TagNumber(10)
  void clearDifficulty() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get previousBlockHash => $_getSZ(10);
  @$pb.TagNumber(11)
  set previousBlockHash($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasPreviousBlockHash() => $_has(10);
  @$pb.TagNumber(11)
  void clearPreviousBlockHash() => clearField(11);

  @$pb.TagNumber(12)
  $core.String get nextBlockHash => $_getSZ(11);
  @$pb.TagNumber(12)
  set nextBlockHash($core.String v) { $_setString(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasNextBlockHash() => $_has(11);
  @$pb.TagNumber(12)
  void clearNextBlockHash() => clearField(12);

  @$pb.TagNumber(13)
  $core.int get strippedSize => $_getIZ(12);
  @$pb.TagNumber(13)
  set strippedSize($core.int v) { $_setSignedInt32(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasStrippedSize() => $_has(12);
  @$pb.TagNumber(13)
  void clearStrippedSize() => clearField(13);

  @$pb.TagNumber(14)
  $core.int get size => $_getIZ(13);
  @$pb.TagNumber(14)
  set size($core.int v) { $_setSignedInt32(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasSize() => $_has(13);
  @$pb.TagNumber(14)
  void clearSize() => clearField(14);

  @$pb.TagNumber(15)
  $core.int get weight => $_getIZ(14);
  @$pb.TagNumber(15)
  set weight($core.int v) { $_setSignedInt32(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasWeight() => $_has(14);
  @$pb.TagNumber(15)
  void clearWeight() => clearField(15);

  @$pb.TagNumber(16)
  $core.List<$core.String> get txids => $_getList(15);
}

class ListBlocksResponse extends $pb.GeneratedMessage {
  factory ListBlocksResponse({
    $core.Iterable<Block>? recentBlocks,
    $core.bool? hasMore,
  }) {
    final $result = create();
    if (recentBlocks != null) {
      $result.recentBlocks.addAll(recentBlocks);
    }
    if (hasMore != null) {
      $result.hasMore = hasMore;
    }
    return $result;
  }
  ListBlocksResponse._() : super();
  factory ListBlocksResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListBlocksResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListBlocksResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'), createEmptyInstance: create)
    ..pc<Block>(4, _omitFieldNames ? '' : 'recentBlocks', $pb.PbFieldType.PM, subBuilder: Block.create)
    ..aOB(5, _omitFieldNames ? '' : 'hasMore')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListBlocksResponse clone() => ListBlocksResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListBlocksResponse copyWith(void Function(ListBlocksResponse) updates) => super.copyWith((message) => updates(message as ListBlocksResponse)) as ListBlocksResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListBlocksResponse create() => ListBlocksResponse._();
  ListBlocksResponse createEmptyInstance() => create();
  static $pb.PbList<ListBlocksResponse> createRepeated() => $pb.PbList<ListBlocksResponse>();
  @$core.pragma('dart2js:noInline')
  static ListBlocksResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListBlocksResponse>(create);
  static ListBlocksResponse? _defaultInstance;

  @$pb.TagNumber(4)
  $core.List<Block> get recentBlocks => $_getList(0);

  @$pb.TagNumber(5)
  $core.bool get hasMore => $_getBF(1);
  @$pb.TagNumber(5)
  set hasMore($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(5)
  $core.bool hasHasMore() => $_has(1);
  @$pb.TagNumber(5)
  void clearHasMore() => clearField(5);
}

class MineBlocksResponse_HashRate extends $pb.GeneratedMessage {
  factory MineBlocksResponse_HashRate({
    $core.double? hashRate,
  }) {
    final $result = create();
    if (hashRate != null) {
      $result.hashRate = hashRate;
    }
    return $result;
  }
  MineBlocksResponse_HashRate._() : super();
  factory MineBlocksResponse_HashRate.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MineBlocksResponse_HashRate.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MineBlocksResponse.HashRate', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'hashRate', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MineBlocksResponse_HashRate clone() => MineBlocksResponse_HashRate()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MineBlocksResponse_HashRate copyWith(void Function(MineBlocksResponse_HashRate) updates) => super.copyWith((message) => updates(message as MineBlocksResponse_HashRate)) as MineBlocksResponse_HashRate;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MineBlocksResponse_HashRate create() => MineBlocksResponse_HashRate._();
  MineBlocksResponse_HashRate createEmptyInstance() => create();
  static $pb.PbList<MineBlocksResponse_HashRate> createRepeated() => $pb.PbList<MineBlocksResponse_HashRate>();
  @$core.pragma('dart2js:noInline')
  static MineBlocksResponse_HashRate getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MineBlocksResponse_HashRate>(create);
  static MineBlocksResponse_HashRate? _defaultInstance;

  /// Hashes per second
  @$pb.TagNumber(1)
  $core.double get hashRate => $_getN(0);
  @$pb.TagNumber(1)
  set hashRate($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHashRate() => $_has(0);
  @$pb.TagNumber(1)
  void clearHashRate() => clearField(1);
}

class MineBlocksResponse_BlockFound extends $pb.GeneratedMessage {
  factory MineBlocksResponse_BlockFound({
    $core.String? blockHash,
  }) {
    final $result = create();
    if (blockHash != null) {
      $result.blockHash = blockHash;
    }
    return $result;
  }
  MineBlocksResponse_BlockFound._() : super();
  factory MineBlocksResponse_BlockFound.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MineBlocksResponse_BlockFound.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MineBlocksResponse.BlockFound', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'blockHash')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MineBlocksResponse_BlockFound clone() => MineBlocksResponse_BlockFound()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MineBlocksResponse_BlockFound copyWith(void Function(MineBlocksResponse_BlockFound) updates) => super.copyWith((message) => updates(message as MineBlocksResponse_BlockFound)) as MineBlocksResponse_BlockFound;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MineBlocksResponse_BlockFound create() => MineBlocksResponse_BlockFound._();
  MineBlocksResponse_BlockFound createEmptyInstance() => create();
  static $pb.PbList<MineBlocksResponse_BlockFound> createRepeated() => $pb.PbList<MineBlocksResponse_BlockFound>();
  @$core.pragma('dart2js:noInline')
  static MineBlocksResponse_BlockFound getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MineBlocksResponse_BlockFound>(create);
  static MineBlocksResponse_BlockFound? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get blockHash => $_getSZ(0);
  @$pb.TagNumber(1)
  set blockHash($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBlockHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHash() => clearField(1);
}

enum MineBlocksResponse_Event {
  blockFound, 
  hashRate, 
  notSet
}

class MineBlocksResponse extends $pb.GeneratedMessage {
  factory MineBlocksResponse({
    MineBlocksResponse_BlockFound? blockFound,
    MineBlocksResponse_HashRate? hashRate,
  }) {
    final $result = create();
    if (blockFound != null) {
      $result.blockFound = blockFound;
    }
    if (hashRate != null) {
      $result.hashRate = hashRate;
    }
    return $result;
  }
  MineBlocksResponse._() : super();
  factory MineBlocksResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MineBlocksResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, MineBlocksResponse_Event> _MineBlocksResponse_EventByTag = {
    1 : MineBlocksResponse_Event.blockFound,
    2 : MineBlocksResponse_Event.hashRate,
    0 : MineBlocksResponse_Event.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MineBlocksResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'), createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<MineBlocksResponse_BlockFound>(1, _omitFieldNames ? '' : 'blockFound', subBuilder: MineBlocksResponse_BlockFound.create)
    ..aOM<MineBlocksResponse_HashRate>(2, _omitFieldNames ? '' : 'hashRate', subBuilder: MineBlocksResponse_HashRate.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MineBlocksResponse clone() => MineBlocksResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MineBlocksResponse copyWith(void Function(MineBlocksResponse) updates) => super.copyWith((message) => updates(message as MineBlocksResponse)) as MineBlocksResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MineBlocksResponse create() => MineBlocksResponse._();
  MineBlocksResponse createEmptyInstance() => create();
  static $pb.PbList<MineBlocksResponse> createRepeated() => $pb.PbList<MineBlocksResponse>();
  @$core.pragma('dart2js:noInline')
  static MineBlocksResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MineBlocksResponse>(create);
  static MineBlocksResponse? _defaultInstance;

  MineBlocksResponse_Event whichEvent() => _MineBlocksResponse_EventByTag[$_whichOneof(0)]!;
  void clearEvent() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  MineBlocksResponse_BlockFound get blockFound => $_getN(0);
  @$pb.TagNumber(1)
  set blockFound(MineBlocksResponse_BlockFound v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBlockFound() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockFound() => clearField(1);
  @$pb.TagNumber(1)
  MineBlocksResponse_BlockFound ensureBlockFound() => $_ensure(0);

  @$pb.TagNumber(2)
  MineBlocksResponse_HashRate get hashRate => $_getN(1);
  @$pb.TagNumber(2)
  set hashRate(MineBlocksResponse_HashRate v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasHashRate() => $_has(1);
  @$pb.TagNumber(2)
  void clearHashRate() => clearField(2);
  @$pb.TagNumber(2)
  MineBlocksResponse_HashRate ensureHashRate() => $_ensure(1);
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
    final $result = create();
    if (networkHashrate != null) {
      $result.networkHashrate = networkHashrate;
    }
    if (difficulty != null) {
      $result.difficulty = difficulty;
    }
    if (peerCount != null) {
      $result.peerCount = peerCount;
    }
    if (totalBytesReceived != null) {
      $result.totalBytesReceived = totalBytesReceived;
    }
    if (totalBytesSent != null) {
      $result.totalBytesSent = totalBytesSent;
    }
    if (blockHeight != null) {
      $result.blockHeight = blockHeight;
    }
    if (avgBlockTime != null) {
      $result.avgBlockTime = avgBlockTime;
    }
    if (networkVersion != null) {
      $result.networkVersion = networkVersion;
    }
    if (subversion != null) {
      $result.subversion = subversion;
    }
    if (connectionsIn != null) {
      $result.connectionsIn = connectionsIn;
    }
    if (connectionsOut != null) {
      $result.connectionsOut = connectionsOut;
    }
    if (bitcoindBandwidth != null) {
      $result.bitcoindBandwidth = bitcoindBandwidth;
    }
    if (enforcerBandwidth != null) {
      $result.enforcerBandwidth = enforcerBandwidth;
    }
    return $result;
  }
  GetNetworkStatsResponse._() : super();
  factory GetNetworkStatsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetNetworkStatsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNetworkStatsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'networkHashrate', $pb.PbFieldType.OD)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'difficulty', $pb.PbFieldType.OD)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'peerCount', $pb.PbFieldType.O3)
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'totalBytesReceived', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'totalBytesSent', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aInt64(6, _omitFieldNames ? '' : 'blockHeight')
    ..a<$core.double>(7, _omitFieldNames ? '' : 'avgBlockTime', $pb.PbFieldType.OD)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'networkVersion', $pb.PbFieldType.O3)
    ..aOS(9, _omitFieldNames ? '' : 'subversion')
    ..a<$core.int>(10, _omitFieldNames ? '' : 'connectionsIn', $pb.PbFieldType.O3)
    ..a<$core.int>(11, _omitFieldNames ? '' : 'connectionsOut', $pb.PbFieldType.O3)
    ..aOM<ProcessBandwidth>(12, _omitFieldNames ? '' : 'bitcoindBandwidth', subBuilder: ProcessBandwidth.create)
    ..aOM<ProcessBandwidth>(13, _omitFieldNames ? '' : 'enforcerBandwidth', subBuilder: ProcessBandwidth.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetNetworkStatsResponse clone() => GetNetworkStatsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetNetworkStatsResponse copyWith(void Function(GetNetworkStatsResponse) updates) => super.copyWith((message) => updates(message as GetNetworkStatsResponse)) as GetNetworkStatsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetNetworkStatsResponse create() => GetNetworkStatsResponse._();
  GetNetworkStatsResponse createEmptyInstance() => create();
  static $pb.PbList<GetNetworkStatsResponse> createRepeated() => $pb.PbList<GetNetworkStatsResponse>();
  @$core.pragma('dart2js:noInline')
  static GetNetworkStatsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetNetworkStatsResponse>(create);
  static GetNetworkStatsResponse? _defaultInstance;

  /// Network hashrate in hashes per second
  @$pb.TagNumber(1)
  $core.double get networkHashrate => $_getN(0);
  @$pb.TagNumber(1)
  set networkHashrate($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasNetworkHashrate() => $_has(0);
  @$pb.TagNumber(1)
  void clearNetworkHashrate() => clearField(1);

  /// Current difficulty
  @$pb.TagNumber(2)
  $core.double get difficulty => $_getN(1);
  @$pb.TagNumber(2)
  set difficulty($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDifficulty() => $_has(1);
  @$pb.TagNumber(2)
  void clearDifficulty() => clearField(2);

  /// Number of connected peers
  @$pb.TagNumber(3)
  $core.int get peerCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set peerCount($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPeerCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearPeerCount() => clearField(3);

  /// Total bytes received (from Bitcoin RPC)
  @$pb.TagNumber(4)
  $fixnum.Int64 get totalBytesReceived => $_getI64(3);
  @$pb.TagNumber(4)
  set totalBytesReceived($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTotalBytesReceived() => $_has(3);
  @$pb.TagNumber(4)
  void clearTotalBytesReceived() => clearField(4);

  /// Total bytes sent (from Bitcoin RPC)
  @$pb.TagNumber(5)
  $fixnum.Int64 get totalBytesSent => $_getI64(4);
  @$pb.TagNumber(5)
  set totalBytesSent($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTotalBytesSent() => $_has(4);
  @$pb.TagNumber(5)
  void clearTotalBytesSent() => clearField(5);

  /// Current block height
  @$pb.TagNumber(6)
  $fixnum.Int64 get blockHeight => $_getI64(5);
  @$pb.TagNumber(6)
  set blockHeight($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasBlockHeight() => $_has(5);
  @$pb.TagNumber(6)
  void clearBlockHeight() => clearField(6);

  /// Average block time (seconds) over last 144 blocks
  @$pb.TagNumber(7)
  $core.double get avgBlockTime => $_getN(6);
  @$pb.TagNumber(7)
  set avgBlockTime($core.double v) { $_setDouble(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasAvgBlockTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearAvgBlockTime() => clearField(7);

  /// Network version (protocol version)
  @$pb.TagNumber(8)
  $core.int get networkVersion => $_getIZ(7);
  @$pb.TagNumber(8)
  set networkVersion($core.int v) { $_setSignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasNetworkVersion() => $_has(7);
  @$pb.TagNumber(8)
  void clearNetworkVersion() => clearField(8);

  /// Subversion (user agent string)
  @$pb.TagNumber(9)
  $core.String get subversion => $_getSZ(8);
  @$pb.TagNumber(9)
  set subversion($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasSubversion() => $_has(8);
  @$pb.TagNumber(9)
  void clearSubversion() => clearField(9);

  /// Number of connections (in/out)
  @$pb.TagNumber(10)
  $core.int get connectionsIn => $_getIZ(9);
  @$pb.TagNumber(10)
  set connectionsIn($core.int v) { $_setSignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasConnectionsIn() => $_has(9);
  @$pb.TagNumber(10)
  void clearConnectionsIn() => clearField(10);

  @$pb.TagNumber(11)
  $core.int get connectionsOut => $_getIZ(10);
  @$pb.TagNumber(11)
  set connectionsOut($core.int v) { $_setSignedInt32(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasConnectionsOut() => $_has(10);
  @$pb.TagNumber(11)
  void clearConnectionsOut() => clearField(11);

  /// Per-process bandwidth statistics (OS-level)
  @$pb.TagNumber(12)
  ProcessBandwidth get bitcoindBandwidth => $_getN(11);
  @$pb.TagNumber(12)
  set bitcoindBandwidth(ProcessBandwidth v) { setField(12, v); }
  @$pb.TagNumber(12)
  $core.bool hasBitcoindBandwidth() => $_has(11);
  @$pb.TagNumber(12)
  void clearBitcoindBandwidth() => clearField(12);
  @$pb.TagNumber(12)
  ProcessBandwidth ensureBitcoindBandwidth() => $_ensure(11);

  @$pb.TagNumber(13)
  ProcessBandwidth get enforcerBandwidth => $_getN(12);
  @$pb.TagNumber(13)
  set enforcerBandwidth(ProcessBandwidth v) { setField(13, v); }
  @$pb.TagNumber(13)
  $core.bool hasEnforcerBandwidth() => $_has(12);
  @$pb.TagNumber(13)
  void clearEnforcerBandwidth() => clearField(13);
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
    final $result = create();
    if (processName != null) {
      $result.processName = processName;
    }
    if (pid != null) {
      $result.pid = pid;
    }
    if (rxBytesPerSec != null) {
      $result.rxBytesPerSec = rxBytesPerSec;
    }
    if (txBytesPerSec != null) {
      $result.txBytesPerSec = txBytesPerSec;
    }
    if (totalRxBytes != null) {
      $result.totalRxBytes = totalRxBytes;
    }
    if (totalTxBytes != null) {
      $result.totalTxBytes = totalTxBytes;
    }
    if (connectionCount != null) {
      $result.connectionCount = connectionCount;
    }
    return $result;
  }
  ProcessBandwidth._() : super();
  factory ProcessBandwidth.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ProcessBandwidth.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ProcessBandwidth', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'processName')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'pid', $pb.PbFieldType.O3)
    ..a<$core.double>(3, _omitFieldNames ? '' : 'rxBytesPerSec', $pb.PbFieldType.OD)
    ..a<$core.double>(4, _omitFieldNames ? '' : 'txBytesPerSec', $pb.PbFieldType.OD)
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'totalRxBytes', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(6, _omitFieldNames ? '' : 'totalTxBytes', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'connectionCount', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ProcessBandwidth clone() => ProcessBandwidth()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ProcessBandwidth copyWith(void Function(ProcessBandwidth) updates) => super.copyWith((message) => updates(message as ProcessBandwidth)) as ProcessBandwidth;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProcessBandwidth create() => ProcessBandwidth._();
  ProcessBandwidth createEmptyInstance() => create();
  static $pb.PbList<ProcessBandwidth> createRepeated() => $pb.PbList<ProcessBandwidth>();
  @$core.pragma('dart2js:noInline')
  static ProcessBandwidth getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProcessBandwidth>(create);
  static ProcessBandwidth? _defaultInstance;

  /// Process name
  @$pb.TagNumber(1)
  $core.String get processName => $_getSZ(0);
  @$pb.TagNumber(1)
  set processName($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasProcessName() => $_has(0);
  @$pb.TagNumber(1)
  void clearProcessName() => clearField(1);

  /// Process ID
  @$pb.TagNumber(2)
  $core.int get pid => $_getIZ(1);
  @$pb.TagNumber(2)
  set pid($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPid() => $_has(1);
  @$pb.TagNumber(2)
  void clearPid() => clearField(2);

  /// Bytes received per second (current rate)
  @$pb.TagNumber(3)
  $core.double get rxBytesPerSec => $_getN(2);
  @$pb.TagNumber(3)
  set rxBytesPerSec($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRxBytesPerSec() => $_has(2);
  @$pb.TagNumber(3)
  void clearRxBytesPerSec() => clearField(3);

  /// Bytes sent per second (current rate)
  @$pb.TagNumber(4)
  $core.double get txBytesPerSec => $_getN(3);
  @$pb.TagNumber(4)
  set txBytesPerSec($core.double v) { $_setDouble(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTxBytesPerSec() => $_has(3);
  @$pb.TagNumber(4)
  void clearTxBytesPerSec() => clearField(4);

  /// Total bytes received since process start
  @$pb.TagNumber(5)
  $fixnum.Int64 get totalRxBytes => $_getI64(4);
  @$pb.TagNumber(5)
  set totalRxBytes($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTotalRxBytes() => $_has(4);
  @$pb.TagNumber(5)
  void clearTotalRxBytes() => clearField(5);

  /// Total bytes sent since process start
  @$pb.TagNumber(6)
  $fixnum.Int64 get totalTxBytes => $_getI64(5);
  @$pb.TagNumber(6)
  set totalTxBytes($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTotalTxBytes() => $_has(5);
  @$pb.TagNumber(6)
  void clearTotalTxBytes() => clearField(6);

  /// Number of active connections
  @$pb.TagNumber(7)
  $core.int get connectionCount => $_getIZ(6);
  @$pb.TagNumber(7)
  set connectionCount($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasConnectionCount() => $_has(6);
  @$pb.TagNumber(7)
  void clearConnectionCount() => clearField(7);
}

class BitwindowdServiceApi {
  $pb.RpcClient _client;
  BitwindowdServiceApi(this._client);

  $async.Future<$1.Empty> stop($pb.ClientContext? ctx, StopBitwindowRequest request) =>
    _client.invoke<$1.Empty>(ctx, 'BitwindowdService', 'Stop', request, $1.Empty())
  ;
  $async.Future<MineBlocksResponse> mineBlocks($pb.ClientContext? ctx, $1.Empty request) =>
    _client.invoke<MineBlocksResponse>(ctx, 'BitwindowdService', 'MineBlocks', request, MineBlocksResponse())
  ;
  $async.Future<$1.Empty> createDenial($pb.ClientContext? ctx, CreateDenialRequest request) =>
    _client.invoke<$1.Empty>(ctx, 'BitwindowdService', 'CreateDenial', request, $1.Empty())
  ;
  $async.Future<$1.Empty> cancelDenial($pb.ClientContext? ctx, CancelDenialRequest request) =>
    _client.invoke<$1.Empty>(ctx, 'BitwindowdService', 'CancelDenial', request, $1.Empty())
  ;
  $async.Future<CreateAddressBookEntryResponse> createAddressBookEntry($pb.ClientContext? ctx, CreateAddressBookEntryRequest request) =>
    _client.invoke<CreateAddressBookEntryResponse>(ctx, 'BitwindowdService', 'CreateAddressBookEntry', request, CreateAddressBookEntryResponse())
  ;
  $async.Future<ListAddressBookResponse> listAddressBook($pb.ClientContext? ctx, $1.Empty request) =>
    _client.invoke<ListAddressBookResponse>(ctx, 'BitwindowdService', 'ListAddressBook', request, ListAddressBookResponse())
  ;
  $async.Future<$1.Empty> updateAddressBookEntry($pb.ClientContext? ctx, UpdateAddressBookEntryRequest request) =>
    _client.invoke<$1.Empty>(ctx, 'BitwindowdService', 'UpdateAddressBookEntry', request, $1.Empty())
  ;
  $async.Future<$1.Empty> deleteAddressBookEntry($pb.ClientContext? ctx, DeleteAddressBookEntryRequest request) =>
    _client.invoke<$1.Empty>(ctx, 'BitwindowdService', 'DeleteAddressBookEntry', request, $1.Empty())
  ;
  $async.Future<GetSyncInfoResponse> getSyncInfo($pb.ClientContext? ctx, $1.Empty request) =>
    _client.invoke<GetSyncInfoResponse>(ctx, 'BitwindowdService', 'GetSyncInfo', request, GetSyncInfoResponse())
  ;
  $async.Future<$1.Empty> setTransactionNote($pb.ClientContext? ctx, SetTransactionNoteRequest request) =>
    _client.invoke<$1.Empty>(ctx, 'BitwindowdService', 'SetTransactionNote', request, $1.Empty())
  ;
  $async.Future<GetFireplaceStatsResponse> getFireplaceStats($pb.ClientContext? ctx, $1.Empty request) =>
    _client.invoke<GetFireplaceStatsResponse>(ctx, 'BitwindowdService', 'GetFireplaceStats', request, GetFireplaceStatsResponse())
  ;
  $async.Future<ListRecentTransactionsResponse> listRecentTransactions($pb.ClientContext? ctx, ListRecentTransactionsRequest request) =>
    _client.invoke<ListRecentTransactionsResponse>(ctx, 'BitwindowdService', 'ListRecentTransactions', request, ListRecentTransactionsResponse())
  ;
  $async.Future<ListBlocksResponse> listBlocks($pb.ClientContext? ctx, ListBlocksRequest request) =>
    _client.invoke<ListBlocksResponse>(ctx, 'BitwindowdService', 'ListBlocks', request, ListBlocksResponse())
  ;
  $async.Future<GetNetworkStatsResponse> getNetworkStats($pb.ClientContext? ctx, $1.Empty request) =>
    _client.invoke<GetNetworkStatsResponse>(ctx, 'BitwindowdService', 'GetNetworkStats', request, GetNetworkStatsResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
