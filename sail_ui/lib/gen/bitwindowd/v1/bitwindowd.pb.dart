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

class CreateDenialRequest extends $pb.GeneratedMessage {
  factory CreateDenialRequest({
    $core.String? txid,
    $core.int? vout,
    $core.int? delaySeconds,
    $core.int? numHops,
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

class BitwindowdServiceApi {
  $pb.RpcClient _client;
  BitwindowdServiceApi(this._client);

  $async.Future<$1.Empty> stop($pb.ClientContext? ctx, $1.Empty request) =>
    _client.invoke<$1.Empty>(ctx, 'BitwindowdService', 'Stop', request, $1.Empty())
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
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
