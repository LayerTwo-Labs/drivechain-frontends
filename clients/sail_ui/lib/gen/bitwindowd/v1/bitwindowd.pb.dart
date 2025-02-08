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
    $core.String? initialTxid,
    $core.int? initialVout,
    $core.int? delaySeconds,
    $core.int? numHops,
  }) {
    final $result = create();
    if (initialTxid != null) {
      $result.initialTxid = initialTxid;
    }
    if (initialVout != null) {
      $result.initialVout = initialVout;
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
    ..aOS(1, _omitFieldNames ? '' : 'initialTxid')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'initialVout', $pb.PbFieldType.O3)
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
  $core.String get initialTxid => $_getSZ(0);
  @$pb.TagNumber(1)
  set initialTxid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasInitialTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearInitialTxid() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get initialVout => $_getIZ(1);
  @$pb.TagNumber(2)
  set initialVout($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasInitialVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearInitialVout() => clearField(2);

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

class Denial extends $pb.GeneratedMessage {
  factory Denial({
    $fixnum.Int64? id,
    $core.String? initialTxid,
    $core.int? initialVout,
    $core.int? delaySeconds,
    $core.int? numHops,
    $0.Timestamp? createdAt,
    $0.Timestamp? cancelledAt,
    $0.Timestamp? nextExecution,
    $core.Iterable<ExecutedDenial>? executions,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (initialTxid != null) {
      $result.initialTxid = initialTxid;
    }
    if (initialVout != null) {
      $result.initialVout = initialVout;
    }
    if (delaySeconds != null) {
      $result.delaySeconds = delaySeconds;
    }
    if (numHops != null) {
      $result.numHops = numHops;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (cancelledAt != null) {
      $result.cancelledAt = cancelledAt;
    }
    if (nextExecution != null) {
      $result.nextExecution = nextExecution;
    }
    if (executions != null) {
      $result.executions.addAll(executions);
    }
    return $result;
  }
  Denial._() : super();
  factory Denial.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Denial.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Denial', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'initialTxid')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'initialVout', $pb.PbFieldType.O3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'delaySeconds', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'numHops', $pb.PbFieldType.O3)
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'createdAt', subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'cancelledAt', subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'nextExecution', subBuilder: $0.Timestamp.create)
    ..pc<ExecutedDenial>(9, _omitFieldNames ? '' : 'executions', $pb.PbFieldType.PM, subBuilder: ExecutedDenial.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Denial clone() => Denial()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Denial copyWith(void Function(Denial) updates) => super.copyWith((message) => updates(message as Denial)) as Denial;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Denial create() => Denial._();
  Denial createEmptyInstance() => create();
  static $pb.PbList<Denial> createRepeated() => $pb.PbList<Denial>();
  @$core.pragma('dart2js:noInline')
  static Denial getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Denial>(create);
  static Denial? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get initialTxid => $_getSZ(1);
  @$pb.TagNumber(2)
  set initialTxid($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasInitialTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearInitialTxid() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get initialVout => $_getIZ(2);
  @$pb.TagNumber(3)
  set initialVout($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasInitialVout() => $_has(2);
  @$pb.TagNumber(3)
  void clearInitialVout() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get delaySeconds => $_getIZ(3);
  @$pb.TagNumber(4)
  set delaySeconds($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDelaySeconds() => $_has(3);
  @$pb.TagNumber(4)
  void clearDelaySeconds() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get numHops => $_getIZ(4);
  @$pb.TagNumber(5)
  set numHops($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasNumHops() => $_has(4);
  @$pb.TagNumber(5)
  void clearNumHops() => clearField(5);

  @$pb.TagNumber(6)
  $0.Timestamp get createdAt => $_getN(5);
  @$pb.TagNumber(6)
  set createdAt($0.Timestamp v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasCreatedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreatedAt() => clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureCreatedAt() => $_ensure(5);

  @$pb.TagNumber(7)
  $0.Timestamp get cancelledAt => $_getN(6);
  @$pb.TagNumber(7)
  set cancelledAt($0.Timestamp v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasCancelledAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearCancelledAt() => clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureCancelledAt() => $_ensure(6);

  @$pb.TagNumber(8)
  $0.Timestamp get nextExecution => $_getN(7);
  @$pb.TagNumber(8)
  set nextExecution($0.Timestamp v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasNextExecution() => $_has(7);
  @$pb.TagNumber(8)
  void clearNextExecution() => clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureNextExecution() => $_ensure(7);

  @$pb.TagNumber(9)
  $core.List<ExecutedDenial> get executions => $_getList(8);
}

class ListDenialsResponse extends $pb.GeneratedMessage {
  factory ListDenialsResponse({
    $core.Iterable<Denial>? denials,
  }) {
    final $result = create();
    if (denials != null) {
      $result.denials.addAll(denials);
    }
    return $result;
  }
  ListDenialsResponse._() : super();
  factory ListDenialsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListDenialsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListDenialsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitwindowd.v1'), createEmptyInstance: create)
    ..pc<Denial>(1, _omitFieldNames ? '' : 'denials', $pb.PbFieldType.PM, subBuilder: Denial.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListDenialsResponse clone() => ListDenialsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListDenialsResponse copyWith(void Function(ListDenialsResponse) updates) => super.copyWith((message) => updates(message as ListDenialsResponse)) as ListDenialsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListDenialsResponse create() => ListDenialsResponse._();
  ListDenialsResponse createEmptyInstance() => create();
  static $pb.PbList<ListDenialsResponse> createRepeated() => $pb.PbList<ListDenialsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListDenialsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListDenialsResponse>(create);
  static ListDenialsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Denial> get denials => $_getList(0);
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

class ExecutedDenial extends $pb.GeneratedMessage {
  factory ExecutedDenial({
    $fixnum.Int64? id,
    $fixnum.Int64? denialId,
    $core.String? fromTxid,
    $core.int? fromVout,
    $core.String? toTxid,
    $core.int? toVout,
    $0.Timestamp? createdAt,
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
    if (toVout != null) {
      $result.toVout = toVout;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
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
    ..a<$core.int>(4, _omitFieldNames ? '' : 'fromVout', $pb.PbFieldType.O3)
    ..aOS(5, _omitFieldNames ? '' : 'toTxid')
    ..a<$core.int>(6, _omitFieldNames ? '' : 'toVout', $pb.PbFieldType.O3)
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'createdAt', subBuilder: $0.Timestamp.create)
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
  set fromVout($core.int v) { $_setSignedInt32(3, v); }
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
  $core.int get toVout => $_getIZ(5);
  @$pb.TagNumber(6)
  set toVout($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasToVout() => $_has(5);
  @$pb.TagNumber(6)
  void clearToVout() => clearField(6);

  @$pb.TagNumber(7)
  $0.Timestamp get createdAt => $_getN(6);
  @$pb.TagNumber(7)
  set createdAt($0.Timestamp v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasCreatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreatedAt() => clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureCreatedAt() => $_ensure(6);
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

class AddressBookEntry extends $pb.GeneratedMessage {
  factory AddressBookEntry({
    $fixnum.Int64? id,
    $core.String? label,
    $core.String? address,
    Direction? direction,
    $0.Timestamp? createdAt,
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
    if (createdAt != null) {
      $result.createdAt = createdAt;
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
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'createdAt', subBuilder: $0.Timestamp.create)
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
  $0.Timestamp get createdAt => $_getN(4);
  @$pb.TagNumber(5)
  set createdAt($0.Timestamp v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasCreatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearCreatedAt() => clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureCreatedAt() => $_ensure(4);
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

class BitwindowdServiceApi {
  $pb.RpcClient _client;
  BitwindowdServiceApi(this._client);

  $async.Future<$1.Empty> stop($pb.ClientContext? ctx, $1.Empty request) =>
    _client.invoke<$1.Empty>(ctx, 'BitwindowdService', 'Stop', request, $1.Empty())
  ;
  $async.Future<$1.Empty> createDenial($pb.ClientContext? ctx, CreateDenialRequest request) =>
    _client.invoke<$1.Empty>(ctx, 'BitwindowdService', 'CreateDenial', request, $1.Empty())
  ;
  $async.Future<ListDenialsResponse> listDenials($pb.ClientContext? ctx, $1.Empty request) =>
    _client.invoke<ListDenialsResponse>(ctx, 'BitwindowdService', 'ListDenials', request, ListDenialsResponse())
  ;
  $async.Future<$1.Empty> cancelDenial($pb.ClientContext? ctx, CancelDenialRequest request) =>
    _client.invoke<$1.Empty>(ctx, 'BitwindowdService', 'CancelDenial', request, $1.Empty())
  ;
  $async.Future<$1.Empty> createAddressBookEntry($pb.ClientContext? ctx, CreateAddressBookEntryRequest request) =>
    _client.invoke<$1.Empty>(ctx, 'BitwindowdService', 'CreateAddressBookEntry', request, $1.Empty())
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
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
