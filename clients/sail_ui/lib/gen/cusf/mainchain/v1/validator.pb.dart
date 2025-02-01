//
//  Generated code. Do not modify.
//  source: cusf/mainchain/v1/validator.proto
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

import '../../../google/protobuf/wrappers.pb.dart' as $0;
import '../../common/v1/common.pb.dart' as $1;
import 'common.pb.dart' as $3;
import 'validator.pbenum.dart';

export 'validator.pbenum.dart';

class BlockHeaderInfo extends $pb.GeneratedMessage {
  factory BlockHeaderInfo({
    $1.ReverseHex? blockHash,
    $1.ReverseHex? prevBlockHash,
    $core.int? height,
    $1.ConsensusHex? work,
  }) {
    final $result = create();
    if (blockHash != null) {
      $result.blockHash = blockHash;
    }
    if (prevBlockHash != null) {
      $result.prevBlockHash = prevBlockHash;
    }
    if (height != null) {
      $result.height = height;
    }
    if (work != null) {
      $result.work = work;
    }
    return $result;
  }
  BlockHeaderInfo._() : super();
  factory BlockHeaderInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BlockHeaderInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BlockHeaderInfo', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$1.ReverseHex>(1, _omitFieldNames ? '' : 'blockHash', subBuilder: $1.ReverseHex.create)
    ..aOM<$1.ReverseHex>(2, _omitFieldNames ? '' : 'prevBlockHash', subBuilder: $1.ReverseHex.create)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'height', $pb.PbFieldType.OU3)
    ..aOM<$1.ConsensusHex>(4, _omitFieldNames ? '' : 'work', subBuilder: $1.ConsensusHex.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BlockHeaderInfo clone() => BlockHeaderInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BlockHeaderInfo copyWith(void Function(BlockHeaderInfo) updates) => super.copyWith((message) => updates(message as BlockHeaderInfo)) as BlockHeaderInfo;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlockHeaderInfo create() => BlockHeaderInfo._();
  BlockHeaderInfo createEmptyInstance() => create();
  static $pb.PbList<BlockHeaderInfo> createRepeated() => $pb.PbList<BlockHeaderInfo>();
  @$core.pragma('dart2js:noInline')
  static BlockHeaderInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BlockHeaderInfo>(create);
  static BlockHeaderInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $1.ReverseHex get blockHash => $_getN(0);
  @$pb.TagNumber(1)
  set blockHash($1.ReverseHex v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBlockHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHash() => clearField(1);
  @$pb.TagNumber(1)
  $1.ReverseHex ensureBlockHash() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.ReverseHex get prevBlockHash => $_getN(1);
  @$pb.TagNumber(2)
  set prevBlockHash($1.ReverseHex v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasPrevBlockHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrevBlockHash() => clearField(2);
  @$pb.TagNumber(2)
  $1.ReverseHex ensurePrevBlockHash() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.int get height => $_getIZ(2);
  @$pb.TagNumber(3)
  set height($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasHeight() => $_has(2);
  @$pb.TagNumber(3)
  void clearHeight() => clearField(3);

  /// Total work as a uint256, little-endian
  @$pb.TagNumber(4)
  $1.ConsensusHex get work => $_getN(3);
  @$pb.TagNumber(4)
  set work($1.ConsensusHex v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasWork() => $_has(3);
  @$pb.TagNumber(4)
  void clearWork() => clearField(4);
  @$pb.TagNumber(4)
  $1.ConsensusHex ensureWork() => $_ensure(3);
}

class Deposit_Output extends $pb.GeneratedMessage {
  factory Deposit_Output({
    $1.Hex? address,
    $0.UInt64Value? valueSats,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (valueSats != null) {
      $result.valueSats = valueSats;
    }
    return $result;
  }
  Deposit_Output._() : super();
  factory Deposit_Output.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Deposit_Output.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Deposit.Output', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$1.Hex>(2, _omitFieldNames ? '' : 'address', subBuilder: $1.Hex.create)
    ..aOM<$0.UInt64Value>(3, _omitFieldNames ? '' : 'valueSats', subBuilder: $0.UInt64Value.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Deposit_Output clone() => Deposit_Output()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Deposit_Output copyWith(void Function(Deposit_Output) updates) => super.copyWith((message) => updates(message as Deposit_Output)) as Deposit_Output;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Deposit_Output create() => Deposit_Output._();
  Deposit_Output createEmptyInstance() => create();
  static $pb.PbList<Deposit_Output> createRepeated() => $pb.PbList<Deposit_Output>();
  @$core.pragma('dart2js:noInline')
  static Deposit_Output getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Deposit_Output>(create);
  static Deposit_Output? _defaultInstance;

  @$pb.TagNumber(2)
  $1.Hex get address => $_getN(0);
  @$pb.TagNumber(2)
  set address($1.Hex v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(2)
  void clearAddress() => clearField(2);
  @$pb.TagNumber(2)
  $1.Hex ensureAddress() => $_ensure(0);

  @$pb.TagNumber(3)
  $0.UInt64Value get valueSats => $_getN(1);
  @$pb.TagNumber(3)
  set valueSats($0.UInt64Value v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasValueSats() => $_has(1);
  @$pb.TagNumber(3)
  void clearValueSats() => clearField(3);
  @$pb.TagNumber(3)
  $0.UInt64Value ensureValueSats() => $_ensure(1);
}

class Deposit extends $pb.GeneratedMessage {
  factory Deposit({
    $0.UInt64Value? sequenceNumber,
    $3.OutPoint? outpoint,
    Deposit_Output? output,
  }) {
    final $result = create();
    if (sequenceNumber != null) {
      $result.sequenceNumber = sequenceNumber;
    }
    if (outpoint != null) {
      $result.outpoint = outpoint;
    }
    if (output != null) {
      $result.output = output;
    }
    return $result;
  }
  Deposit._() : super();
  factory Deposit.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Deposit.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Deposit', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$0.UInt64Value>(1, _omitFieldNames ? '' : 'sequenceNumber', subBuilder: $0.UInt64Value.create)
    ..aOM<$3.OutPoint>(2, _omitFieldNames ? '' : 'outpoint', subBuilder: $3.OutPoint.create)
    ..aOM<Deposit_Output>(3, _omitFieldNames ? '' : 'output', subBuilder: Deposit_Output.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Deposit clone() => Deposit()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Deposit copyWith(void Function(Deposit) updates) => super.copyWith((message) => updates(message as Deposit)) as Deposit;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Deposit create() => Deposit._();
  Deposit createEmptyInstance() => create();
  static $pb.PbList<Deposit> createRepeated() => $pb.PbList<Deposit>();
  @$core.pragma('dart2js:noInline')
  static Deposit getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Deposit>(create);
  static Deposit? _defaultInstance;

  @$pb.TagNumber(1)
  $0.UInt64Value get sequenceNumber => $_getN(0);
  @$pb.TagNumber(1)
  set sequenceNumber($0.UInt64Value v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSequenceNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearSequenceNumber() => clearField(1);
  @$pb.TagNumber(1)
  $0.UInt64Value ensureSequenceNumber() => $_ensure(0);

  @$pb.TagNumber(2)
  $3.OutPoint get outpoint => $_getN(1);
  @$pb.TagNumber(2)
  set outpoint($3.OutPoint v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasOutpoint() => $_has(1);
  @$pb.TagNumber(2)
  void clearOutpoint() => clearField(2);
  @$pb.TagNumber(2)
  $3.OutPoint ensureOutpoint() => $_ensure(1);

  @$pb.TagNumber(3)
  Deposit_Output get output => $_getN(2);
  @$pb.TagNumber(3)
  set output(Deposit_Output v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasOutput() => $_has(2);
  @$pb.TagNumber(3)
  void clearOutput() => clearField(3);
  @$pb.TagNumber(3)
  Deposit_Output ensureOutput() => $_ensure(2);
}

class WithdrawalBundleEvent_Event_Failed extends $pb.GeneratedMessage {
  factory WithdrawalBundleEvent_Event_Failed() => create();
  WithdrawalBundleEvent_Event_Failed._() : super();
  factory WithdrawalBundleEvent_Event_Failed.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WithdrawalBundleEvent_Event_Failed.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawalBundleEvent.Event.Failed', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WithdrawalBundleEvent_Event_Failed clone() => WithdrawalBundleEvent_Event_Failed()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WithdrawalBundleEvent_Event_Failed copyWith(void Function(WithdrawalBundleEvent_Event_Failed) updates) => super.copyWith((message) => updates(message as WithdrawalBundleEvent_Event_Failed)) as WithdrawalBundleEvent_Event_Failed;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WithdrawalBundleEvent_Event_Failed create() => WithdrawalBundleEvent_Event_Failed._();
  WithdrawalBundleEvent_Event_Failed createEmptyInstance() => create();
  static $pb.PbList<WithdrawalBundleEvent_Event_Failed> createRepeated() => $pb.PbList<WithdrawalBundleEvent_Event_Failed>();
  @$core.pragma('dart2js:noInline')
  static WithdrawalBundleEvent_Event_Failed getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WithdrawalBundleEvent_Event_Failed>(create);
  static WithdrawalBundleEvent_Event_Failed? _defaultInstance;
}

class WithdrawalBundleEvent_Event_Succeeded extends $pb.GeneratedMessage {
  factory WithdrawalBundleEvent_Event_Succeeded({
    $0.UInt64Value? sequenceNumber,
    $1.ConsensusHex? transaction,
  }) {
    final $result = create();
    if (sequenceNumber != null) {
      $result.sequenceNumber = sequenceNumber;
    }
    if (transaction != null) {
      $result.transaction = transaction;
    }
    return $result;
  }
  WithdrawalBundleEvent_Event_Succeeded._() : super();
  factory WithdrawalBundleEvent_Event_Succeeded.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WithdrawalBundleEvent_Event_Succeeded.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawalBundleEvent.Event.Succeeded', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$0.UInt64Value>(1, _omitFieldNames ? '' : 'sequenceNumber', subBuilder: $0.UInt64Value.create)
    ..aOM<$1.ConsensusHex>(2, _omitFieldNames ? '' : 'transaction', subBuilder: $1.ConsensusHex.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WithdrawalBundleEvent_Event_Succeeded clone() => WithdrawalBundleEvent_Event_Succeeded()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WithdrawalBundleEvent_Event_Succeeded copyWith(void Function(WithdrawalBundleEvent_Event_Succeeded) updates) => super.copyWith((message) => updates(message as WithdrawalBundleEvent_Event_Succeeded)) as WithdrawalBundleEvent_Event_Succeeded;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WithdrawalBundleEvent_Event_Succeeded create() => WithdrawalBundleEvent_Event_Succeeded._();
  WithdrawalBundleEvent_Event_Succeeded createEmptyInstance() => create();
  static $pb.PbList<WithdrawalBundleEvent_Event_Succeeded> createRepeated() => $pb.PbList<WithdrawalBundleEvent_Event_Succeeded>();
  @$core.pragma('dart2js:noInline')
  static WithdrawalBundleEvent_Event_Succeeded getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WithdrawalBundleEvent_Event_Succeeded>(create);
  static WithdrawalBundleEvent_Event_Succeeded? _defaultInstance;

  @$pb.TagNumber(1)
  $0.UInt64Value get sequenceNumber => $_getN(0);
  @$pb.TagNumber(1)
  set sequenceNumber($0.UInt64Value v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSequenceNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearSequenceNumber() => clearField(1);
  @$pb.TagNumber(1)
  $0.UInt64Value ensureSequenceNumber() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.ConsensusHex get transaction => $_getN(1);
  @$pb.TagNumber(2)
  set transaction($1.ConsensusHex v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasTransaction() => $_has(1);
  @$pb.TagNumber(2)
  void clearTransaction() => clearField(2);
  @$pb.TagNumber(2)
  $1.ConsensusHex ensureTransaction() => $_ensure(1);
}

class WithdrawalBundleEvent_Event_Submitted extends $pb.GeneratedMessage {
  factory WithdrawalBundleEvent_Event_Submitted() => create();
  WithdrawalBundleEvent_Event_Submitted._() : super();
  factory WithdrawalBundleEvent_Event_Submitted.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WithdrawalBundleEvent_Event_Submitted.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawalBundleEvent.Event.Submitted', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WithdrawalBundleEvent_Event_Submitted clone() => WithdrawalBundleEvent_Event_Submitted()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WithdrawalBundleEvent_Event_Submitted copyWith(void Function(WithdrawalBundleEvent_Event_Submitted) updates) => super.copyWith((message) => updates(message as WithdrawalBundleEvent_Event_Submitted)) as WithdrawalBundleEvent_Event_Submitted;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WithdrawalBundleEvent_Event_Submitted create() => WithdrawalBundleEvent_Event_Submitted._();
  WithdrawalBundleEvent_Event_Submitted createEmptyInstance() => create();
  static $pb.PbList<WithdrawalBundleEvent_Event_Submitted> createRepeated() => $pb.PbList<WithdrawalBundleEvent_Event_Submitted>();
  @$core.pragma('dart2js:noInline')
  static WithdrawalBundleEvent_Event_Submitted getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WithdrawalBundleEvent_Event_Submitted>(create);
  static WithdrawalBundleEvent_Event_Submitted? _defaultInstance;
}

enum WithdrawalBundleEvent_Event_Event {
  failed, 
  succeeded, 
  submitted, 
  notSet
}

class WithdrawalBundleEvent_Event extends $pb.GeneratedMessage {
  factory WithdrawalBundleEvent_Event({
    WithdrawalBundleEvent_Event_Failed? failed,
    WithdrawalBundleEvent_Event_Succeeded? succeeded,
    WithdrawalBundleEvent_Event_Submitted? submitted,
  }) {
    final $result = create();
    if (failed != null) {
      $result.failed = failed;
    }
    if (succeeded != null) {
      $result.succeeded = succeeded;
    }
    if (submitted != null) {
      $result.submitted = submitted;
    }
    return $result;
  }
  WithdrawalBundleEvent_Event._() : super();
  factory WithdrawalBundleEvent_Event.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WithdrawalBundleEvent_Event.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, WithdrawalBundleEvent_Event_Event> _WithdrawalBundleEvent_Event_EventByTag = {
    1 : WithdrawalBundleEvent_Event_Event.failed,
    2 : WithdrawalBundleEvent_Event_Event.succeeded,
    3 : WithdrawalBundleEvent_Event_Event.submitted,
    0 : WithdrawalBundleEvent_Event_Event.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawalBundleEvent.Event', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..oo(0, [1, 2, 3])
    ..aOM<WithdrawalBundleEvent_Event_Failed>(1, _omitFieldNames ? '' : 'failed', subBuilder: WithdrawalBundleEvent_Event_Failed.create)
    ..aOM<WithdrawalBundleEvent_Event_Succeeded>(2, _omitFieldNames ? '' : 'succeeded', subBuilder: WithdrawalBundleEvent_Event_Succeeded.create)
    ..aOM<WithdrawalBundleEvent_Event_Submitted>(3, _omitFieldNames ? '' : 'submitted', subBuilder: WithdrawalBundleEvent_Event_Submitted.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WithdrawalBundleEvent_Event clone() => WithdrawalBundleEvent_Event()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WithdrawalBundleEvent_Event copyWith(void Function(WithdrawalBundleEvent_Event) updates) => super.copyWith((message) => updates(message as WithdrawalBundleEvent_Event)) as WithdrawalBundleEvent_Event;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WithdrawalBundleEvent_Event create() => WithdrawalBundleEvent_Event._();
  WithdrawalBundleEvent_Event createEmptyInstance() => create();
  static $pb.PbList<WithdrawalBundleEvent_Event> createRepeated() => $pb.PbList<WithdrawalBundleEvent_Event>();
  @$core.pragma('dart2js:noInline')
  static WithdrawalBundleEvent_Event getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WithdrawalBundleEvent_Event>(create);
  static WithdrawalBundleEvent_Event? _defaultInstance;

  WithdrawalBundleEvent_Event_Event whichEvent() => _WithdrawalBundleEvent_Event_EventByTag[$_whichOneof(0)]!;
  void clearEvent() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  WithdrawalBundleEvent_Event_Failed get failed => $_getN(0);
  @$pb.TagNumber(1)
  set failed(WithdrawalBundleEvent_Event_Failed v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasFailed() => $_has(0);
  @$pb.TagNumber(1)
  void clearFailed() => clearField(1);
  @$pb.TagNumber(1)
  WithdrawalBundleEvent_Event_Failed ensureFailed() => $_ensure(0);

  @$pb.TagNumber(2)
  WithdrawalBundleEvent_Event_Succeeded get succeeded => $_getN(1);
  @$pb.TagNumber(2)
  set succeeded(WithdrawalBundleEvent_Event_Succeeded v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasSucceeded() => $_has(1);
  @$pb.TagNumber(2)
  void clearSucceeded() => clearField(2);
  @$pb.TagNumber(2)
  WithdrawalBundleEvent_Event_Succeeded ensureSucceeded() => $_ensure(1);

  @$pb.TagNumber(3)
  WithdrawalBundleEvent_Event_Submitted get submitted => $_getN(2);
  @$pb.TagNumber(3)
  set submitted(WithdrawalBundleEvent_Event_Submitted v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasSubmitted() => $_has(2);
  @$pb.TagNumber(3)
  void clearSubmitted() => clearField(3);
  @$pb.TagNumber(3)
  WithdrawalBundleEvent_Event_Submitted ensureSubmitted() => $_ensure(2);
}

class WithdrawalBundleEvent extends $pb.GeneratedMessage {
  factory WithdrawalBundleEvent({
    $1.ConsensusHex? m6id,
    WithdrawalBundleEvent_Event? event,
  }) {
    final $result = create();
    if (m6id != null) {
      $result.m6id = m6id;
    }
    if (event != null) {
      $result.event = event;
    }
    return $result;
  }
  WithdrawalBundleEvent._() : super();
  factory WithdrawalBundleEvent.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WithdrawalBundleEvent.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawalBundleEvent', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$1.ConsensusHex>(1, _omitFieldNames ? '' : 'm6id', subBuilder: $1.ConsensusHex.create)
    ..aOM<WithdrawalBundleEvent_Event>(2, _omitFieldNames ? '' : 'event', subBuilder: WithdrawalBundleEvent_Event.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WithdrawalBundleEvent clone() => WithdrawalBundleEvent()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WithdrawalBundleEvent copyWith(void Function(WithdrawalBundleEvent) updates) => super.copyWith((message) => updates(message as WithdrawalBundleEvent)) as WithdrawalBundleEvent;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WithdrawalBundleEvent create() => WithdrawalBundleEvent._();
  WithdrawalBundleEvent createEmptyInstance() => create();
  static $pb.PbList<WithdrawalBundleEvent> createRepeated() => $pb.PbList<WithdrawalBundleEvent>();
  @$core.pragma('dart2js:noInline')
  static WithdrawalBundleEvent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WithdrawalBundleEvent>(create);
  static WithdrawalBundleEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $1.ConsensusHex get m6id => $_getN(0);
  @$pb.TagNumber(1)
  set m6id($1.ConsensusHex v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasM6id() => $_has(0);
  @$pb.TagNumber(1)
  void clearM6id() => clearField(1);
  @$pb.TagNumber(1)
  $1.ConsensusHex ensureM6id() => $_ensure(0);

  @$pb.TagNumber(2)
  WithdrawalBundleEvent_Event get event => $_getN(1);
  @$pb.TagNumber(2)
  set event(WithdrawalBundleEvent_Event v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasEvent() => $_has(1);
  @$pb.TagNumber(2)
  void clearEvent() => clearField(2);
  @$pb.TagNumber(2)
  WithdrawalBundleEvent_Event ensureEvent() => $_ensure(1);
}

enum BlockInfo_Event_Event {
  deposit, 
  withdrawalBundle, 
  notSet
}

class BlockInfo_Event extends $pb.GeneratedMessage {
  factory BlockInfo_Event({
    Deposit? deposit,
    WithdrawalBundleEvent? withdrawalBundle,
  }) {
    final $result = create();
    if (deposit != null) {
      $result.deposit = deposit;
    }
    if (withdrawalBundle != null) {
      $result.withdrawalBundle = withdrawalBundle;
    }
    return $result;
  }
  BlockInfo_Event._() : super();
  factory BlockInfo_Event.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BlockInfo_Event.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, BlockInfo_Event_Event> _BlockInfo_Event_EventByTag = {
    1 : BlockInfo_Event_Event.deposit,
    2 : BlockInfo_Event_Event.withdrawalBundle,
    0 : BlockInfo_Event_Event.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BlockInfo.Event', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<Deposit>(1, _omitFieldNames ? '' : 'deposit', subBuilder: Deposit.create)
    ..aOM<WithdrawalBundleEvent>(2, _omitFieldNames ? '' : 'withdrawalBundle', subBuilder: WithdrawalBundleEvent.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BlockInfo_Event clone() => BlockInfo_Event()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BlockInfo_Event copyWith(void Function(BlockInfo_Event) updates) => super.copyWith((message) => updates(message as BlockInfo_Event)) as BlockInfo_Event;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlockInfo_Event create() => BlockInfo_Event._();
  BlockInfo_Event createEmptyInstance() => create();
  static $pb.PbList<BlockInfo_Event> createRepeated() => $pb.PbList<BlockInfo_Event>();
  @$core.pragma('dart2js:noInline')
  static BlockInfo_Event getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BlockInfo_Event>(create);
  static BlockInfo_Event? _defaultInstance;

  BlockInfo_Event_Event whichEvent() => _BlockInfo_Event_EventByTag[$_whichOneof(0)]!;
  void clearEvent() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  Deposit get deposit => $_getN(0);
  @$pb.TagNumber(1)
  set deposit(Deposit v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasDeposit() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeposit() => clearField(1);
  @$pb.TagNumber(1)
  Deposit ensureDeposit() => $_ensure(0);

  @$pb.TagNumber(2)
  WithdrawalBundleEvent get withdrawalBundle => $_getN(1);
  @$pb.TagNumber(2)
  set withdrawalBundle(WithdrawalBundleEvent v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasWithdrawalBundle() => $_has(1);
  @$pb.TagNumber(2)
  void clearWithdrawalBundle() => clearField(2);
  @$pb.TagNumber(2)
  WithdrawalBundleEvent ensureWithdrawalBundle() => $_ensure(1);
}

/// Specific to an individual sidechain slot
class BlockInfo extends $pb.GeneratedMessage {
  factory BlockInfo({
    $1.ConsensusHex? bmmCommitment,
    $core.Iterable<BlockInfo_Event>? events,
  }) {
    final $result = create();
    if (bmmCommitment != null) {
      $result.bmmCommitment = bmmCommitment;
    }
    if (events != null) {
      $result.events.addAll(events);
    }
    return $result;
  }
  BlockInfo._() : super();
  factory BlockInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BlockInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BlockInfo', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$1.ConsensusHex>(1, _omitFieldNames ? '' : 'bmmCommitment', subBuilder: $1.ConsensusHex.create)
    ..pc<BlockInfo_Event>(2, _omitFieldNames ? '' : 'events', $pb.PbFieldType.PM, subBuilder: BlockInfo_Event.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BlockInfo clone() => BlockInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BlockInfo copyWith(void Function(BlockInfo) updates) => super.copyWith((message) => updates(message as BlockInfo)) as BlockInfo;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlockInfo create() => BlockInfo._();
  BlockInfo createEmptyInstance() => create();
  static $pb.PbList<BlockInfo> createRepeated() => $pb.PbList<BlockInfo>();
  @$core.pragma('dart2js:noInline')
  static BlockInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BlockInfo>(create);
  static BlockInfo? _defaultInstance;

  /// repeated Deposit deposits = 1;
  /// repeated WithdrawalBundleEvent withdrawal_bundle_events = 2;
  @$pb.TagNumber(1)
  $1.ConsensusHex get bmmCommitment => $_getN(0);
  @$pb.TagNumber(1)
  set bmmCommitment($1.ConsensusHex v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBmmCommitment() => $_has(0);
  @$pb.TagNumber(1)
  void clearBmmCommitment() => clearField(1);
  @$pb.TagNumber(1)
  $1.ConsensusHex ensureBmmCommitment() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.List<BlockInfo_Event> get events => $_getList(1);
}

class GetBlockHeaderInfoRequest extends $pb.GeneratedMessage {
  factory GetBlockHeaderInfoRequest({
    $1.ReverseHex? blockHash,
  }) {
    final $result = create();
    if (blockHash != null) {
      $result.blockHash = blockHash;
    }
    return $result;
  }
  GetBlockHeaderInfoRequest._() : super();
  factory GetBlockHeaderInfoRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBlockHeaderInfoRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockHeaderInfoRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$1.ReverseHex>(1, _omitFieldNames ? '' : 'blockHash', subBuilder: $1.ReverseHex.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBlockHeaderInfoRequest clone() => GetBlockHeaderInfoRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBlockHeaderInfoRequest copyWith(void Function(GetBlockHeaderInfoRequest) updates) => super.copyWith((message) => updates(message as GetBlockHeaderInfoRequest)) as GetBlockHeaderInfoRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBlockHeaderInfoRequest create() => GetBlockHeaderInfoRequest._();
  GetBlockHeaderInfoRequest createEmptyInstance() => create();
  static $pb.PbList<GetBlockHeaderInfoRequest> createRepeated() => $pb.PbList<GetBlockHeaderInfoRequest>();
  @$core.pragma('dart2js:noInline')
  static GetBlockHeaderInfoRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBlockHeaderInfoRequest>(create);
  static GetBlockHeaderInfoRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $1.ReverseHex get blockHash => $_getN(0);
  @$pb.TagNumber(1)
  set blockHash($1.ReverseHex v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBlockHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHash() => clearField(1);
  @$pb.TagNumber(1)
  $1.ReverseHex ensureBlockHash() => $_ensure(0);
}

class GetBlockHeaderInfoResponse extends $pb.GeneratedMessage {
  factory GetBlockHeaderInfoResponse({
    BlockHeaderInfo? headerInfo,
  }) {
    final $result = create();
    if (headerInfo != null) {
      $result.headerInfo = headerInfo;
    }
    return $result;
  }
  GetBlockHeaderInfoResponse._() : super();
  factory GetBlockHeaderInfoResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBlockHeaderInfoResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockHeaderInfoResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<BlockHeaderInfo>(1, _omitFieldNames ? '' : 'headerInfo', subBuilder: BlockHeaderInfo.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBlockHeaderInfoResponse clone() => GetBlockHeaderInfoResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBlockHeaderInfoResponse copyWith(void Function(GetBlockHeaderInfoResponse) updates) => super.copyWith((message) => updates(message as GetBlockHeaderInfoResponse)) as GetBlockHeaderInfoResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBlockHeaderInfoResponse create() => GetBlockHeaderInfoResponse._();
  GetBlockHeaderInfoResponse createEmptyInstance() => create();
  static $pb.PbList<GetBlockHeaderInfoResponse> createRepeated() => $pb.PbList<GetBlockHeaderInfoResponse>();
  @$core.pragma('dart2js:noInline')
  static GetBlockHeaderInfoResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBlockHeaderInfoResponse>(create);
  static GetBlockHeaderInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  BlockHeaderInfo get headerInfo => $_getN(0);
  @$pb.TagNumber(1)
  set headerInfo(BlockHeaderInfo v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasHeaderInfo() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeaderInfo() => clearField(1);
  @$pb.TagNumber(1)
  BlockHeaderInfo ensureHeaderInfo() => $_ensure(0);
}

class GetBlockInfoRequest extends $pb.GeneratedMessage {
  factory GetBlockInfoRequest({
    $1.ReverseHex? blockHash,
    $0.UInt32Value? sidechainId,
  }) {
    final $result = create();
    if (blockHash != null) {
      $result.blockHash = blockHash;
    }
    if (sidechainId != null) {
      $result.sidechainId = sidechainId;
    }
    return $result;
  }
  GetBlockInfoRequest._() : super();
  factory GetBlockInfoRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBlockInfoRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockInfoRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$1.ReverseHex>(1, _omitFieldNames ? '' : 'blockHash', subBuilder: $1.ReverseHex.create)
    ..aOM<$0.UInt32Value>(2, _omitFieldNames ? '' : 'sidechainId', subBuilder: $0.UInt32Value.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBlockInfoRequest clone() => GetBlockInfoRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBlockInfoRequest copyWith(void Function(GetBlockInfoRequest) updates) => super.copyWith((message) => updates(message as GetBlockInfoRequest)) as GetBlockInfoRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBlockInfoRequest create() => GetBlockInfoRequest._();
  GetBlockInfoRequest createEmptyInstance() => create();
  static $pb.PbList<GetBlockInfoRequest> createRepeated() => $pb.PbList<GetBlockInfoRequest>();
  @$core.pragma('dart2js:noInline')
  static GetBlockInfoRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBlockInfoRequest>(create);
  static GetBlockInfoRequest? _defaultInstance;

  /// The block to fetch information about.
  @$pb.TagNumber(1)
  $1.ReverseHex get blockHash => $_getN(0);
  @$pb.TagNumber(1)
  set blockHash($1.ReverseHex v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBlockHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHash() => clearField(1);
  @$pb.TagNumber(1)
  $1.ReverseHex ensureBlockHash() => $_ensure(0);

  /// The sidechain to filter for events relating to.
  @$pb.TagNumber(2)
  $0.UInt32Value get sidechainId => $_getN(1);
  @$pb.TagNumber(2)
  set sidechainId($0.UInt32Value v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasSidechainId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSidechainId() => clearField(2);
  @$pb.TagNumber(2)
  $0.UInt32Value ensureSidechainId() => $_ensure(1);
}

class GetBlockInfoResponse extends $pb.GeneratedMessage {
  factory GetBlockInfoResponse({
    BlockHeaderInfo? headerInfo,
    BlockInfo? blockInfo,
  }) {
    final $result = create();
    if (headerInfo != null) {
      $result.headerInfo = headerInfo;
    }
    if (blockInfo != null) {
      $result.blockInfo = blockInfo;
    }
    return $result;
  }
  GetBlockInfoResponse._() : super();
  factory GetBlockInfoResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBlockInfoResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockInfoResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<BlockHeaderInfo>(1, _omitFieldNames ? '' : 'headerInfo', subBuilder: BlockHeaderInfo.create)
    ..aOM<BlockInfo>(2, _omitFieldNames ? '' : 'blockInfo', subBuilder: BlockInfo.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBlockInfoResponse clone() => GetBlockInfoResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBlockInfoResponse copyWith(void Function(GetBlockInfoResponse) updates) => super.copyWith((message) => updates(message as GetBlockInfoResponse)) as GetBlockInfoResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBlockInfoResponse create() => GetBlockInfoResponse._();
  GetBlockInfoResponse createEmptyInstance() => create();
  static $pb.PbList<GetBlockInfoResponse> createRepeated() => $pb.PbList<GetBlockInfoResponse>();
  @$core.pragma('dart2js:noInline')
  static GetBlockInfoResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBlockInfoResponse>(create);
  static GetBlockInfoResponse? _defaultInstance;

  /// Information about the block itself.
  @$pb.TagNumber(1)
  BlockHeaderInfo get headerInfo => $_getN(0);
  @$pb.TagNumber(1)
  set headerInfo(BlockHeaderInfo v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasHeaderInfo() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeaderInfo() => clearField(1);
  @$pb.TagNumber(1)
  BlockHeaderInfo ensureHeaderInfo() => $_ensure(0);

  /// Information about the block, filtered for events relating to
  /// a specific sidechain.
  @$pb.TagNumber(2)
  BlockInfo get blockInfo => $_getN(1);
  @$pb.TagNumber(2)
  set blockInfo(BlockInfo v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasBlockInfo() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlockInfo() => clearField(2);
  @$pb.TagNumber(2)
  BlockInfo ensureBlockInfo() => $_ensure(1);
}

class GetBmmHStarCommitmentRequest extends $pb.GeneratedMessage {
  factory GetBmmHStarCommitmentRequest({
    $1.ReverseHex? blockHash,
    $0.UInt32Value? sidechainId,
  }) {
    final $result = create();
    if (blockHash != null) {
      $result.blockHash = blockHash;
    }
    if (sidechainId != null) {
      $result.sidechainId = sidechainId;
    }
    return $result;
  }
  GetBmmHStarCommitmentRequest._() : super();
  factory GetBmmHStarCommitmentRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBmmHStarCommitmentRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBmmHStarCommitmentRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$1.ReverseHex>(1, _omitFieldNames ? '' : 'blockHash', subBuilder: $1.ReverseHex.create)
    ..aOM<$0.UInt32Value>(2, _omitFieldNames ? '' : 'sidechainId', subBuilder: $0.UInt32Value.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBmmHStarCommitmentRequest clone() => GetBmmHStarCommitmentRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBmmHStarCommitmentRequest copyWith(void Function(GetBmmHStarCommitmentRequest) updates) => super.copyWith((message) => updates(message as GetBmmHStarCommitmentRequest)) as GetBmmHStarCommitmentRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBmmHStarCommitmentRequest create() => GetBmmHStarCommitmentRequest._();
  GetBmmHStarCommitmentRequest createEmptyInstance() => create();
  static $pb.PbList<GetBmmHStarCommitmentRequest> createRepeated() => $pb.PbList<GetBmmHStarCommitmentRequest>();
  @$core.pragma('dart2js:noInline')
  static GetBmmHStarCommitmentRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBmmHStarCommitmentRequest>(create);
  static GetBmmHStarCommitmentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $1.ReverseHex get blockHash => $_getN(0);
  @$pb.TagNumber(1)
  set blockHash($1.ReverseHex v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBlockHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHash() => clearField(1);
  @$pb.TagNumber(1)
  $1.ReverseHex ensureBlockHash() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.UInt32Value get sidechainId => $_getN(1);
  @$pb.TagNumber(2)
  set sidechainId($0.UInt32Value v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasSidechainId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSidechainId() => clearField(2);
  @$pb.TagNumber(2)
  $0.UInt32Value ensureSidechainId() => $_ensure(1);
}

class GetBmmHStarCommitmentResponse_BlockNotFoundError extends $pb.GeneratedMessage {
  factory GetBmmHStarCommitmentResponse_BlockNotFoundError({
    $1.ReverseHex? blockHash,
  }) {
    final $result = create();
    if (blockHash != null) {
      $result.blockHash = blockHash;
    }
    return $result;
  }
  GetBmmHStarCommitmentResponse_BlockNotFoundError._() : super();
  factory GetBmmHStarCommitmentResponse_BlockNotFoundError.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBmmHStarCommitmentResponse_BlockNotFoundError.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBmmHStarCommitmentResponse.BlockNotFoundError', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$1.ReverseHex>(1, _omitFieldNames ? '' : 'blockHash', subBuilder: $1.ReverseHex.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBmmHStarCommitmentResponse_BlockNotFoundError clone() => GetBmmHStarCommitmentResponse_BlockNotFoundError()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBmmHStarCommitmentResponse_BlockNotFoundError copyWith(void Function(GetBmmHStarCommitmentResponse_BlockNotFoundError) updates) => super.copyWith((message) => updates(message as GetBmmHStarCommitmentResponse_BlockNotFoundError)) as GetBmmHStarCommitmentResponse_BlockNotFoundError;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBmmHStarCommitmentResponse_BlockNotFoundError create() => GetBmmHStarCommitmentResponse_BlockNotFoundError._();
  GetBmmHStarCommitmentResponse_BlockNotFoundError createEmptyInstance() => create();
  static $pb.PbList<GetBmmHStarCommitmentResponse_BlockNotFoundError> createRepeated() => $pb.PbList<GetBmmHStarCommitmentResponse_BlockNotFoundError>();
  @$core.pragma('dart2js:noInline')
  static GetBmmHStarCommitmentResponse_BlockNotFoundError getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBmmHStarCommitmentResponse_BlockNotFoundError>(create);
  static GetBmmHStarCommitmentResponse_BlockNotFoundError? _defaultInstance;

  @$pb.TagNumber(1)
  $1.ReverseHex get blockHash => $_getN(0);
  @$pb.TagNumber(1)
  set blockHash($1.ReverseHex v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBlockHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHash() => clearField(1);
  @$pb.TagNumber(1)
  $1.ReverseHex ensureBlockHash() => $_ensure(0);
}

class GetBmmHStarCommitmentResponse_Commitment extends $pb.GeneratedMessage {
  factory GetBmmHStarCommitmentResponse_Commitment({
    $1.ConsensusHex? commitment,
  }) {
    final $result = create();
    if (commitment != null) {
      $result.commitment = commitment;
    }
    return $result;
  }
  GetBmmHStarCommitmentResponse_Commitment._() : super();
  factory GetBmmHStarCommitmentResponse_Commitment.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBmmHStarCommitmentResponse_Commitment.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBmmHStarCommitmentResponse.Commitment', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$1.ConsensusHex>(1, _omitFieldNames ? '' : 'commitment', subBuilder: $1.ConsensusHex.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBmmHStarCommitmentResponse_Commitment clone() => GetBmmHStarCommitmentResponse_Commitment()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBmmHStarCommitmentResponse_Commitment copyWith(void Function(GetBmmHStarCommitmentResponse_Commitment) updates) => super.copyWith((message) => updates(message as GetBmmHStarCommitmentResponse_Commitment)) as GetBmmHStarCommitmentResponse_Commitment;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBmmHStarCommitmentResponse_Commitment create() => GetBmmHStarCommitmentResponse_Commitment._();
  GetBmmHStarCommitmentResponse_Commitment createEmptyInstance() => create();
  static $pb.PbList<GetBmmHStarCommitmentResponse_Commitment> createRepeated() => $pb.PbList<GetBmmHStarCommitmentResponse_Commitment>();
  @$core.pragma('dart2js:noInline')
  static GetBmmHStarCommitmentResponse_Commitment getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBmmHStarCommitmentResponse_Commitment>(create);
  static GetBmmHStarCommitmentResponse_Commitment? _defaultInstance;

  @$pb.TagNumber(1)
  $1.ConsensusHex get commitment => $_getN(0);
  @$pb.TagNumber(1)
  set commitment($1.ConsensusHex v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasCommitment() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommitment() => clearField(1);
  @$pb.TagNumber(1)
  $1.ConsensusHex ensureCommitment() => $_ensure(0);
}

enum GetBmmHStarCommitmentResponse_Result {
  blockNotFound, 
  commitment, 
  notSet
}

class GetBmmHStarCommitmentResponse extends $pb.GeneratedMessage {
  factory GetBmmHStarCommitmentResponse({
    GetBmmHStarCommitmentResponse_BlockNotFoundError? blockNotFound,
    GetBmmHStarCommitmentResponse_Commitment? commitment,
  }) {
    final $result = create();
    if (blockNotFound != null) {
      $result.blockNotFound = blockNotFound;
    }
    if (commitment != null) {
      $result.commitment = commitment;
    }
    return $result;
  }
  GetBmmHStarCommitmentResponse._() : super();
  factory GetBmmHStarCommitmentResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBmmHStarCommitmentResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, GetBmmHStarCommitmentResponse_Result> _GetBmmHStarCommitmentResponse_ResultByTag = {
    1 : GetBmmHStarCommitmentResponse_Result.blockNotFound,
    2 : GetBmmHStarCommitmentResponse_Result.commitment,
    0 : GetBmmHStarCommitmentResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBmmHStarCommitmentResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<GetBmmHStarCommitmentResponse_BlockNotFoundError>(1, _omitFieldNames ? '' : 'blockNotFound', subBuilder: GetBmmHStarCommitmentResponse_BlockNotFoundError.create)
    ..aOM<GetBmmHStarCommitmentResponse_Commitment>(2, _omitFieldNames ? '' : 'commitment', subBuilder: GetBmmHStarCommitmentResponse_Commitment.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBmmHStarCommitmentResponse clone() => GetBmmHStarCommitmentResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBmmHStarCommitmentResponse copyWith(void Function(GetBmmHStarCommitmentResponse) updates) => super.copyWith((message) => updates(message as GetBmmHStarCommitmentResponse)) as GetBmmHStarCommitmentResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBmmHStarCommitmentResponse create() => GetBmmHStarCommitmentResponse._();
  GetBmmHStarCommitmentResponse createEmptyInstance() => create();
  static $pb.PbList<GetBmmHStarCommitmentResponse> createRepeated() => $pb.PbList<GetBmmHStarCommitmentResponse>();
  @$core.pragma('dart2js:noInline')
  static GetBmmHStarCommitmentResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBmmHStarCommitmentResponse>(create);
  static GetBmmHStarCommitmentResponse? _defaultInstance;

  GetBmmHStarCommitmentResponse_Result whichResult() => _GetBmmHStarCommitmentResponse_ResultByTag[$_whichOneof(0)]!;
  void clearResult() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  GetBmmHStarCommitmentResponse_BlockNotFoundError get blockNotFound => $_getN(0);
  @$pb.TagNumber(1)
  set blockNotFound(GetBmmHStarCommitmentResponse_BlockNotFoundError v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBlockNotFound() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockNotFound() => clearField(1);
  @$pb.TagNumber(1)
  GetBmmHStarCommitmentResponse_BlockNotFoundError ensureBlockNotFound() => $_ensure(0);

  @$pb.TagNumber(2)
  GetBmmHStarCommitmentResponse_Commitment get commitment => $_getN(1);
  @$pb.TagNumber(2)
  set commitment(GetBmmHStarCommitmentResponse_Commitment v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasCommitment() => $_has(1);
  @$pb.TagNumber(2)
  void clearCommitment() => clearField(2);
  @$pb.TagNumber(2)
  GetBmmHStarCommitmentResponse_Commitment ensureCommitment() => $_ensure(1);
}

class GetChainInfoRequest extends $pb.GeneratedMessage {
  factory GetChainInfoRequest() => create();
  GetChainInfoRequest._() : super();
  factory GetChainInfoRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetChainInfoRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetChainInfoRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetChainInfoRequest clone() => GetChainInfoRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetChainInfoRequest copyWith(void Function(GetChainInfoRequest) updates) => super.copyWith((message) => updates(message as GetChainInfoRequest)) as GetChainInfoRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetChainInfoRequest create() => GetChainInfoRequest._();
  GetChainInfoRequest createEmptyInstance() => create();
  static $pb.PbList<GetChainInfoRequest> createRepeated() => $pb.PbList<GetChainInfoRequest>();
  @$core.pragma('dart2js:noInline')
  static GetChainInfoRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetChainInfoRequest>(create);
  static GetChainInfoRequest? _defaultInstance;
}

class GetChainInfoResponse extends $pb.GeneratedMessage {
  factory GetChainInfoResponse({
    Network? network,
  }) {
    final $result = create();
    if (network != null) {
      $result.network = network;
    }
    return $result;
  }
  GetChainInfoResponse._() : super();
  factory GetChainInfoResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetChainInfoResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetChainInfoResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..e<Network>(1, _omitFieldNames ? '' : 'network', $pb.PbFieldType.OE, defaultOrMaker: Network.NETWORK_UNSPECIFIED, valueOf: Network.valueOf, enumValues: Network.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetChainInfoResponse clone() => GetChainInfoResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetChainInfoResponse copyWith(void Function(GetChainInfoResponse) updates) => super.copyWith((message) => updates(message as GetChainInfoResponse)) as GetChainInfoResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetChainInfoResponse create() => GetChainInfoResponse._();
  GetChainInfoResponse createEmptyInstance() => create();
  static $pb.PbList<GetChainInfoResponse> createRepeated() => $pb.PbList<GetChainInfoResponse>();
  @$core.pragma('dart2js:noInline')
  static GetChainInfoResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetChainInfoResponse>(create);
  static GetChainInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Network get network => $_getN(0);
  @$pb.TagNumber(1)
  set network(Network v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasNetwork() => $_has(0);
  @$pb.TagNumber(1)
  void clearNetwork() => clearField(1);
}

class GetChainTipRequest extends $pb.GeneratedMessage {
  factory GetChainTipRequest() => create();
  GetChainTipRequest._() : super();
  factory GetChainTipRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetChainTipRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetChainTipRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetChainTipRequest clone() => GetChainTipRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetChainTipRequest copyWith(void Function(GetChainTipRequest) updates) => super.copyWith((message) => updates(message as GetChainTipRequest)) as GetChainTipRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetChainTipRequest create() => GetChainTipRequest._();
  GetChainTipRequest createEmptyInstance() => create();
  static $pb.PbList<GetChainTipRequest> createRepeated() => $pb.PbList<GetChainTipRequest>();
  @$core.pragma('dart2js:noInline')
  static GetChainTipRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetChainTipRequest>(create);
  static GetChainTipRequest? _defaultInstance;
}

class GetChainTipResponse extends $pb.GeneratedMessage {
  factory GetChainTipResponse({
    BlockHeaderInfo? blockHeaderInfo,
  }) {
    final $result = create();
    if (blockHeaderInfo != null) {
      $result.blockHeaderInfo = blockHeaderInfo;
    }
    return $result;
  }
  GetChainTipResponse._() : super();
  factory GetChainTipResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetChainTipResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetChainTipResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<BlockHeaderInfo>(1, _omitFieldNames ? '' : 'blockHeaderInfo', subBuilder: BlockHeaderInfo.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetChainTipResponse clone() => GetChainTipResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetChainTipResponse copyWith(void Function(GetChainTipResponse) updates) => super.copyWith((message) => updates(message as GetChainTipResponse)) as GetChainTipResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetChainTipResponse create() => GetChainTipResponse._();
  GetChainTipResponse createEmptyInstance() => create();
  static $pb.PbList<GetChainTipResponse> createRepeated() => $pb.PbList<GetChainTipResponse>();
  @$core.pragma('dart2js:noInline')
  static GetChainTipResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetChainTipResponse>(create);
  static GetChainTipResponse? _defaultInstance;

  @$pb.TagNumber(1)
  BlockHeaderInfo get blockHeaderInfo => $_getN(0);
  @$pb.TagNumber(1)
  set blockHeaderInfo(BlockHeaderInfo v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBlockHeaderInfo() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHeaderInfo() => clearField(1);
  @$pb.TagNumber(1)
  BlockHeaderInfo ensureBlockHeaderInfo() => $_ensure(0);
}

class GetCoinbasePSBTRequest_ProposeSidechain extends $pb.GeneratedMessage {
  factory GetCoinbasePSBTRequest_ProposeSidechain({
    $0.UInt32Value? sidechainNumber,
    $1.ConsensusHex? data,
  }) {
    final $result = create();
    if (sidechainNumber != null) {
      $result.sidechainNumber = sidechainNumber;
    }
    if (data != null) {
      $result.data = data;
    }
    return $result;
  }
  GetCoinbasePSBTRequest_ProposeSidechain._() : super();
  factory GetCoinbasePSBTRequest_ProposeSidechain.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetCoinbasePSBTRequest_ProposeSidechain.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCoinbasePSBTRequest.ProposeSidechain', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$0.UInt32Value>(1, _omitFieldNames ? '' : 'sidechainNumber', subBuilder: $0.UInt32Value.create)
    ..aOM<$1.ConsensusHex>(2, _omitFieldNames ? '' : 'data', subBuilder: $1.ConsensusHex.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetCoinbasePSBTRequest_ProposeSidechain clone() => GetCoinbasePSBTRequest_ProposeSidechain()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetCoinbasePSBTRequest_ProposeSidechain copyWith(void Function(GetCoinbasePSBTRequest_ProposeSidechain) updates) => super.copyWith((message) => updates(message as GetCoinbasePSBTRequest_ProposeSidechain)) as GetCoinbasePSBTRequest_ProposeSidechain;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCoinbasePSBTRequest_ProposeSidechain create() => GetCoinbasePSBTRequest_ProposeSidechain._();
  GetCoinbasePSBTRequest_ProposeSidechain createEmptyInstance() => create();
  static $pb.PbList<GetCoinbasePSBTRequest_ProposeSidechain> createRepeated() => $pb.PbList<GetCoinbasePSBTRequest_ProposeSidechain>();
  @$core.pragma('dart2js:noInline')
  static GetCoinbasePSBTRequest_ProposeSidechain getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCoinbasePSBTRequest_ProposeSidechain>(create);
  static GetCoinbasePSBTRequest_ProposeSidechain? _defaultInstance;

  @$pb.TagNumber(1)
  $0.UInt32Value get sidechainNumber => $_getN(0);
  @$pb.TagNumber(1)
  set sidechainNumber($0.UInt32Value v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechainNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainNumber() => clearField(1);
  @$pb.TagNumber(1)
  $0.UInt32Value ensureSidechainNumber() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.ConsensusHex get data => $_getN(1);
  @$pb.TagNumber(2)
  set data($1.ConsensusHex v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => clearField(2);
  @$pb.TagNumber(2)
  $1.ConsensusHex ensureData() => $_ensure(1);
}

class GetCoinbasePSBTRequest_AckSidechain extends $pb.GeneratedMessage {
  factory GetCoinbasePSBTRequest_AckSidechain({
    $0.UInt32Value? sidechainNumber,
    $1.ConsensusHex? dataHash,
  }) {
    final $result = create();
    if (sidechainNumber != null) {
      $result.sidechainNumber = sidechainNumber;
    }
    if (dataHash != null) {
      $result.dataHash = dataHash;
    }
    return $result;
  }
  GetCoinbasePSBTRequest_AckSidechain._() : super();
  factory GetCoinbasePSBTRequest_AckSidechain.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetCoinbasePSBTRequest_AckSidechain.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCoinbasePSBTRequest.AckSidechain', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$0.UInt32Value>(1, _omitFieldNames ? '' : 'sidechainNumber', subBuilder: $0.UInt32Value.create)
    ..aOM<$1.ConsensusHex>(2, _omitFieldNames ? '' : 'dataHash', subBuilder: $1.ConsensusHex.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetCoinbasePSBTRequest_AckSidechain clone() => GetCoinbasePSBTRequest_AckSidechain()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetCoinbasePSBTRequest_AckSidechain copyWith(void Function(GetCoinbasePSBTRequest_AckSidechain) updates) => super.copyWith((message) => updates(message as GetCoinbasePSBTRequest_AckSidechain)) as GetCoinbasePSBTRequest_AckSidechain;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCoinbasePSBTRequest_AckSidechain create() => GetCoinbasePSBTRequest_AckSidechain._();
  GetCoinbasePSBTRequest_AckSidechain createEmptyInstance() => create();
  static $pb.PbList<GetCoinbasePSBTRequest_AckSidechain> createRepeated() => $pb.PbList<GetCoinbasePSBTRequest_AckSidechain>();
  @$core.pragma('dart2js:noInline')
  static GetCoinbasePSBTRequest_AckSidechain getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCoinbasePSBTRequest_AckSidechain>(create);
  static GetCoinbasePSBTRequest_AckSidechain? _defaultInstance;

  @$pb.TagNumber(1)
  $0.UInt32Value get sidechainNumber => $_getN(0);
  @$pb.TagNumber(1)
  set sidechainNumber($0.UInt32Value v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechainNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainNumber() => clearField(1);
  @$pb.TagNumber(1)
  $0.UInt32Value ensureSidechainNumber() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.ConsensusHex get dataHash => $_getN(1);
  @$pb.TagNumber(2)
  set dataHash($1.ConsensusHex v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasDataHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearDataHash() => clearField(2);
  @$pb.TagNumber(2)
  $1.ConsensusHex ensureDataHash() => $_ensure(1);
}

class GetCoinbasePSBTRequest_ProposeBundle extends $pb.GeneratedMessage {
  factory GetCoinbasePSBTRequest_ProposeBundle({
    $0.UInt32Value? sidechainNumber,
    $1.ReverseHex? bundleTxid,
  }) {
    final $result = create();
    if (sidechainNumber != null) {
      $result.sidechainNumber = sidechainNumber;
    }
    if (bundleTxid != null) {
      $result.bundleTxid = bundleTxid;
    }
    return $result;
  }
  GetCoinbasePSBTRequest_ProposeBundle._() : super();
  factory GetCoinbasePSBTRequest_ProposeBundle.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetCoinbasePSBTRequest_ProposeBundle.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCoinbasePSBTRequest.ProposeBundle', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$0.UInt32Value>(1, _omitFieldNames ? '' : 'sidechainNumber', subBuilder: $0.UInt32Value.create)
    ..aOM<$1.ReverseHex>(2, _omitFieldNames ? '' : 'bundleTxid', subBuilder: $1.ReverseHex.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetCoinbasePSBTRequest_ProposeBundle clone() => GetCoinbasePSBTRequest_ProposeBundle()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetCoinbasePSBTRequest_ProposeBundle copyWith(void Function(GetCoinbasePSBTRequest_ProposeBundle) updates) => super.copyWith((message) => updates(message as GetCoinbasePSBTRequest_ProposeBundle)) as GetCoinbasePSBTRequest_ProposeBundle;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCoinbasePSBTRequest_ProposeBundle create() => GetCoinbasePSBTRequest_ProposeBundle._();
  GetCoinbasePSBTRequest_ProposeBundle createEmptyInstance() => create();
  static $pb.PbList<GetCoinbasePSBTRequest_ProposeBundle> createRepeated() => $pb.PbList<GetCoinbasePSBTRequest_ProposeBundle>();
  @$core.pragma('dart2js:noInline')
  static GetCoinbasePSBTRequest_ProposeBundle getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCoinbasePSBTRequest_ProposeBundle>(create);
  static GetCoinbasePSBTRequest_ProposeBundle? _defaultInstance;

  @$pb.TagNumber(1)
  $0.UInt32Value get sidechainNumber => $_getN(0);
  @$pb.TagNumber(1)
  set sidechainNumber($0.UInt32Value v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechainNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainNumber() => clearField(1);
  @$pb.TagNumber(1)
  $0.UInt32Value ensureSidechainNumber() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.ReverseHex get bundleTxid => $_getN(1);
  @$pb.TagNumber(2)
  set bundleTxid($1.ReverseHex v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasBundleTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearBundleTxid() => clearField(2);
  @$pb.TagNumber(2)
  $1.ReverseHex ensureBundleTxid() => $_ensure(1);
}

class GetCoinbasePSBTRequest_AckBundles_RepeatPrevious extends $pb.GeneratedMessage {
  factory GetCoinbasePSBTRequest_AckBundles_RepeatPrevious() => create();
  GetCoinbasePSBTRequest_AckBundles_RepeatPrevious._() : super();
  factory GetCoinbasePSBTRequest_AckBundles_RepeatPrevious.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetCoinbasePSBTRequest_AckBundles_RepeatPrevious.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCoinbasePSBTRequest.AckBundles.RepeatPrevious', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetCoinbasePSBTRequest_AckBundles_RepeatPrevious clone() => GetCoinbasePSBTRequest_AckBundles_RepeatPrevious()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetCoinbasePSBTRequest_AckBundles_RepeatPrevious copyWith(void Function(GetCoinbasePSBTRequest_AckBundles_RepeatPrevious) updates) => super.copyWith((message) => updates(message as GetCoinbasePSBTRequest_AckBundles_RepeatPrevious)) as GetCoinbasePSBTRequest_AckBundles_RepeatPrevious;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCoinbasePSBTRequest_AckBundles_RepeatPrevious create() => GetCoinbasePSBTRequest_AckBundles_RepeatPrevious._();
  GetCoinbasePSBTRequest_AckBundles_RepeatPrevious createEmptyInstance() => create();
  static $pb.PbList<GetCoinbasePSBTRequest_AckBundles_RepeatPrevious> createRepeated() => $pb.PbList<GetCoinbasePSBTRequest_AckBundles_RepeatPrevious>();
  @$core.pragma('dart2js:noInline')
  static GetCoinbasePSBTRequest_AckBundles_RepeatPrevious getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCoinbasePSBTRequest_AckBundles_RepeatPrevious>(create);
  static GetCoinbasePSBTRequest_AckBundles_RepeatPrevious? _defaultInstance;
}

class GetCoinbasePSBTRequest_AckBundles_LeadingBy50 extends $pb.GeneratedMessage {
  factory GetCoinbasePSBTRequest_AckBundles_LeadingBy50() => create();
  GetCoinbasePSBTRequest_AckBundles_LeadingBy50._() : super();
  factory GetCoinbasePSBTRequest_AckBundles_LeadingBy50.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetCoinbasePSBTRequest_AckBundles_LeadingBy50.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCoinbasePSBTRequest.AckBundles.LeadingBy50', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetCoinbasePSBTRequest_AckBundles_LeadingBy50 clone() => GetCoinbasePSBTRequest_AckBundles_LeadingBy50()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetCoinbasePSBTRequest_AckBundles_LeadingBy50 copyWith(void Function(GetCoinbasePSBTRequest_AckBundles_LeadingBy50) updates) => super.copyWith((message) => updates(message as GetCoinbasePSBTRequest_AckBundles_LeadingBy50)) as GetCoinbasePSBTRequest_AckBundles_LeadingBy50;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCoinbasePSBTRequest_AckBundles_LeadingBy50 create() => GetCoinbasePSBTRequest_AckBundles_LeadingBy50._();
  GetCoinbasePSBTRequest_AckBundles_LeadingBy50 createEmptyInstance() => create();
  static $pb.PbList<GetCoinbasePSBTRequest_AckBundles_LeadingBy50> createRepeated() => $pb.PbList<GetCoinbasePSBTRequest_AckBundles_LeadingBy50>();
  @$core.pragma('dart2js:noInline')
  static GetCoinbasePSBTRequest_AckBundles_LeadingBy50 getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCoinbasePSBTRequest_AckBundles_LeadingBy50>(create);
  static GetCoinbasePSBTRequest_AckBundles_LeadingBy50? _defaultInstance;
}

class GetCoinbasePSBTRequest_AckBundles_Upvotes extends $pb.GeneratedMessage {
  factory GetCoinbasePSBTRequest_AckBundles_Upvotes({
    $core.Iterable<$core.int>? upvotes,
  }) {
    final $result = create();
    if (upvotes != null) {
      $result.upvotes.addAll(upvotes);
    }
    return $result;
  }
  GetCoinbasePSBTRequest_AckBundles_Upvotes._() : super();
  factory GetCoinbasePSBTRequest_AckBundles_Upvotes.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetCoinbasePSBTRequest_AckBundles_Upvotes.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCoinbasePSBTRequest.AckBundles.Upvotes', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..p<$core.int>(1, _omitFieldNames ? '' : 'upvotes', $pb.PbFieldType.KU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetCoinbasePSBTRequest_AckBundles_Upvotes clone() => GetCoinbasePSBTRequest_AckBundles_Upvotes()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetCoinbasePSBTRequest_AckBundles_Upvotes copyWith(void Function(GetCoinbasePSBTRequest_AckBundles_Upvotes) updates) => super.copyWith((message) => updates(message as GetCoinbasePSBTRequest_AckBundles_Upvotes)) as GetCoinbasePSBTRequest_AckBundles_Upvotes;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCoinbasePSBTRequest_AckBundles_Upvotes create() => GetCoinbasePSBTRequest_AckBundles_Upvotes._();
  GetCoinbasePSBTRequest_AckBundles_Upvotes createEmptyInstance() => create();
  static $pb.PbList<GetCoinbasePSBTRequest_AckBundles_Upvotes> createRepeated() => $pb.PbList<GetCoinbasePSBTRequest_AckBundles_Upvotes>();
  @$core.pragma('dart2js:noInline')
  static GetCoinbasePSBTRequest_AckBundles_Upvotes getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCoinbasePSBTRequest_AckBundles_Upvotes>(create);
  static GetCoinbasePSBTRequest_AckBundles_Upvotes? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get upvotes => $_getList(0);
}

enum GetCoinbasePSBTRequest_AckBundles_AckBundles {
  repeatPrevious, 
  leadingBy50, 
  upvotes, 
  notSet
}

class GetCoinbasePSBTRequest_AckBundles extends $pb.GeneratedMessage {
  factory GetCoinbasePSBTRequest_AckBundles({
    GetCoinbasePSBTRequest_AckBundles_RepeatPrevious? repeatPrevious,
    GetCoinbasePSBTRequest_AckBundles_LeadingBy50? leadingBy50,
    GetCoinbasePSBTRequest_AckBundles_Upvotes? upvotes,
  }) {
    final $result = create();
    if (repeatPrevious != null) {
      $result.repeatPrevious = repeatPrevious;
    }
    if (leadingBy50 != null) {
      $result.leadingBy50 = leadingBy50;
    }
    if (upvotes != null) {
      $result.upvotes = upvotes;
    }
    return $result;
  }
  GetCoinbasePSBTRequest_AckBundles._() : super();
  factory GetCoinbasePSBTRequest_AckBundles.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetCoinbasePSBTRequest_AckBundles.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, GetCoinbasePSBTRequest_AckBundles_AckBundles> _GetCoinbasePSBTRequest_AckBundles_AckBundlesByTag = {
    1 : GetCoinbasePSBTRequest_AckBundles_AckBundles.repeatPrevious,
    2 : GetCoinbasePSBTRequest_AckBundles_AckBundles.leadingBy50,
    3 : GetCoinbasePSBTRequest_AckBundles_AckBundles.upvotes,
    0 : GetCoinbasePSBTRequest_AckBundles_AckBundles.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCoinbasePSBTRequest.AckBundles', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..oo(0, [1, 2, 3])
    ..aOM<GetCoinbasePSBTRequest_AckBundles_RepeatPrevious>(1, _omitFieldNames ? '' : 'repeatPrevious', subBuilder: GetCoinbasePSBTRequest_AckBundles_RepeatPrevious.create)
    ..aOM<GetCoinbasePSBTRequest_AckBundles_LeadingBy50>(2, _omitFieldNames ? '' : 'leadingBy50', protoName: 'leading_by_50', subBuilder: GetCoinbasePSBTRequest_AckBundles_LeadingBy50.create)
    ..aOM<GetCoinbasePSBTRequest_AckBundles_Upvotes>(3, _omitFieldNames ? '' : 'upvotes', subBuilder: GetCoinbasePSBTRequest_AckBundles_Upvotes.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetCoinbasePSBTRequest_AckBundles clone() => GetCoinbasePSBTRequest_AckBundles()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetCoinbasePSBTRequest_AckBundles copyWith(void Function(GetCoinbasePSBTRequest_AckBundles) updates) => super.copyWith((message) => updates(message as GetCoinbasePSBTRequest_AckBundles)) as GetCoinbasePSBTRequest_AckBundles;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCoinbasePSBTRequest_AckBundles create() => GetCoinbasePSBTRequest_AckBundles._();
  GetCoinbasePSBTRequest_AckBundles createEmptyInstance() => create();
  static $pb.PbList<GetCoinbasePSBTRequest_AckBundles> createRepeated() => $pb.PbList<GetCoinbasePSBTRequest_AckBundles>();
  @$core.pragma('dart2js:noInline')
  static GetCoinbasePSBTRequest_AckBundles getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCoinbasePSBTRequest_AckBundles>(create);
  static GetCoinbasePSBTRequest_AckBundles? _defaultInstance;

  GetCoinbasePSBTRequest_AckBundles_AckBundles whichAckBundles() => _GetCoinbasePSBTRequest_AckBundles_AckBundlesByTag[$_whichOneof(0)]!;
  void clearAckBundles() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  GetCoinbasePSBTRequest_AckBundles_RepeatPrevious get repeatPrevious => $_getN(0);
  @$pb.TagNumber(1)
  set repeatPrevious(GetCoinbasePSBTRequest_AckBundles_RepeatPrevious v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasRepeatPrevious() => $_has(0);
  @$pb.TagNumber(1)
  void clearRepeatPrevious() => clearField(1);
  @$pb.TagNumber(1)
  GetCoinbasePSBTRequest_AckBundles_RepeatPrevious ensureRepeatPrevious() => $_ensure(0);

  @$pb.TagNumber(2)
  GetCoinbasePSBTRequest_AckBundles_LeadingBy50 get leadingBy50 => $_getN(1);
  @$pb.TagNumber(2)
  set leadingBy50(GetCoinbasePSBTRequest_AckBundles_LeadingBy50 v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasLeadingBy50() => $_has(1);
  @$pb.TagNumber(2)
  void clearLeadingBy50() => clearField(2);
  @$pb.TagNumber(2)
  GetCoinbasePSBTRequest_AckBundles_LeadingBy50 ensureLeadingBy50() => $_ensure(1);

  @$pb.TagNumber(3)
  GetCoinbasePSBTRequest_AckBundles_Upvotes get upvotes => $_getN(2);
  @$pb.TagNumber(3)
  set upvotes(GetCoinbasePSBTRequest_AckBundles_Upvotes v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasUpvotes() => $_has(2);
  @$pb.TagNumber(3)
  void clearUpvotes() => clearField(3);
  @$pb.TagNumber(3)
  GetCoinbasePSBTRequest_AckBundles_Upvotes ensureUpvotes() => $_ensure(2);
}

class GetCoinbasePSBTRequest extends $pb.GeneratedMessage {
  factory GetCoinbasePSBTRequest({
    $core.Iterable<GetCoinbasePSBTRequest_ProposeSidechain>? proposeSidechains,
    $core.Iterable<GetCoinbasePSBTRequest_AckSidechain>? ackSidechains,
    $core.Iterable<GetCoinbasePSBTRequest_ProposeBundle>? proposeBundles,
    GetCoinbasePSBTRequest_AckBundles? ackBundles,
  }) {
    final $result = create();
    if (proposeSidechains != null) {
      $result.proposeSidechains.addAll(proposeSidechains);
    }
    if (ackSidechains != null) {
      $result.ackSidechains.addAll(ackSidechains);
    }
    if (proposeBundles != null) {
      $result.proposeBundles.addAll(proposeBundles);
    }
    if (ackBundles != null) {
      $result.ackBundles = ackBundles;
    }
    return $result;
  }
  GetCoinbasePSBTRequest._() : super();
  factory GetCoinbasePSBTRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetCoinbasePSBTRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCoinbasePSBTRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..pc<GetCoinbasePSBTRequest_ProposeSidechain>(1, _omitFieldNames ? '' : 'proposeSidechains', $pb.PbFieldType.PM, subBuilder: GetCoinbasePSBTRequest_ProposeSidechain.create)
    ..pc<GetCoinbasePSBTRequest_AckSidechain>(2, _omitFieldNames ? '' : 'ackSidechains', $pb.PbFieldType.PM, subBuilder: GetCoinbasePSBTRequest_AckSidechain.create)
    ..pc<GetCoinbasePSBTRequest_ProposeBundle>(3, _omitFieldNames ? '' : 'proposeBundles', $pb.PbFieldType.PM, subBuilder: GetCoinbasePSBTRequest_ProposeBundle.create)
    ..aOM<GetCoinbasePSBTRequest_AckBundles>(4, _omitFieldNames ? '' : 'ackBundles', subBuilder: GetCoinbasePSBTRequest_AckBundles.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetCoinbasePSBTRequest clone() => GetCoinbasePSBTRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetCoinbasePSBTRequest copyWith(void Function(GetCoinbasePSBTRequest) updates) => super.copyWith((message) => updates(message as GetCoinbasePSBTRequest)) as GetCoinbasePSBTRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCoinbasePSBTRequest create() => GetCoinbasePSBTRequest._();
  GetCoinbasePSBTRequest createEmptyInstance() => create();
  static $pb.PbList<GetCoinbasePSBTRequest> createRepeated() => $pb.PbList<GetCoinbasePSBTRequest>();
  @$core.pragma('dart2js:noInline')
  static GetCoinbasePSBTRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCoinbasePSBTRequest>(create);
  static GetCoinbasePSBTRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<GetCoinbasePSBTRequest_ProposeSidechain> get proposeSidechains => $_getList(0);

  @$pb.TagNumber(2)
  $core.List<GetCoinbasePSBTRequest_AckSidechain> get ackSidechains => $_getList(1);

  @$pb.TagNumber(3)
  $core.List<GetCoinbasePSBTRequest_ProposeBundle> get proposeBundles => $_getList(2);

  @$pb.TagNumber(4)
  GetCoinbasePSBTRequest_AckBundles get ackBundles => $_getN(3);
  @$pb.TagNumber(4)
  set ackBundles(GetCoinbasePSBTRequest_AckBundles v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasAckBundles() => $_has(3);
  @$pb.TagNumber(4)
  void clearAckBundles() => clearField(4);
  @$pb.TagNumber(4)
  GetCoinbasePSBTRequest_AckBundles ensureAckBundles() => $_ensure(3);
}

class GetCoinbasePSBTResponse extends $pb.GeneratedMessage {
  factory GetCoinbasePSBTResponse({
    $1.ConsensusHex? psbt,
  }) {
    final $result = create();
    if (psbt != null) {
      $result.psbt = psbt;
    }
    return $result;
  }
  GetCoinbasePSBTResponse._() : super();
  factory GetCoinbasePSBTResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetCoinbasePSBTResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCoinbasePSBTResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$1.ConsensusHex>(1, _omitFieldNames ? '' : 'psbt', subBuilder: $1.ConsensusHex.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetCoinbasePSBTResponse clone() => GetCoinbasePSBTResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetCoinbasePSBTResponse copyWith(void Function(GetCoinbasePSBTResponse) updates) => super.copyWith((message) => updates(message as GetCoinbasePSBTResponse)) as GetCoinbasePSBTResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCoinbasePSBTResponse create() => GetCoinbasePSBTResponse._();
  GetCoinbasePSBTResponse createEmptyInstance() => create();
  static $pb.PbList<GetCoinbasePSBTResponse> createRepeated() => $pb.PbList<GetCoinbasePSBTResponse>();
  @$core.pragma('dart2js:noInline')
  static GetCoinbasePSBTResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCoinbasePSBTResponse>(create);
  static GetCoinbasePSBTResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $1.ConsensusHex get psbt => $_getN(0);
  @$pb.TagNumber(1)
  set psbt($1.ConsensusHex v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => clearField(1);
  @$pb.TagNumber(1)
  $1.ConsensusHex ensurePsbt() => $_ensure(0);
}

class GetCtipRequest extends $pb.GeneratedMessage {
  factory GetCtipRequest({
    $0.UInt32Value? sidechainNumber,
  }) {
    final $result = create();
    if (sidechainNumber != null) {
      $result.sidechainNumber = sidechainNumber;
    }
    return $result;
  }
  GetCtipRequest._() : super();
  factory GetCtipRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetCtipRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCtipRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$0.UInt32Value>(1, _omitFieldNames ? '' : 'sidechainNumber', subBuilder: $0.UInt32Value.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetCtipRequest clone() => GetCtipRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetCtipRequest copyWith(void Function(GetCtipRequest) updates) => super.copyWith((message) => updates(message as GetCtipRequest)) as GetCtipRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCtipRequest create() => GetCtipRequest._();
  GetCtipRequest createEmptyInstance() => create();
  static $pb.PbList<GetCtipRequest> createRepeated() => $pb.PbList<GetCtipRequest>();
  @$core.pragma('dart2js:noInline')
  static GetCtipRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCtipRequest>(create);
  static GetCtipRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.UInt32Value get sidechainNumber => $_getN(0);
  @$pb.TagNumber(1)
  set sidechainNumber($0.UInt32Value v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechainNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainNumber() => clearField(1);
  @$pb.TagNumber(1)
  $0.UInt32Value ensureSidechainNumber() => $_ensure(0);
}

class GetCtipResponse_Ctip extends $pb.GeneratedMessage {
  factory GetCtipResponse_Ctip({
    $1.ReverseHex? txid,
    $core.int? vout,
    $fixnum.Int64? value,
    $fixnum.Int64? sequenceNumber,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (vout != null) {
      $result.vout = vout;
    }
    if (value != null) {
      $result.value = value;
    }
    if (sequenceNumber != null) {
      $result.sequenceNumber = sequenceNumber;
    }
    return $result;
  }
  GetCtipResponse_Ctip._() : super();
  factory GetCtipResponse_Ctip.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetCtipResponse_Ctip.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCtipResponse.Ctip', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$1.ReverseHex>(1, _omitFieldNames ? '' : 'txid', subBuilder: $1.ReverseHex.create)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'vout', $pb.PbFieldType.OU3)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'value', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'sequenceNumber', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetCtipResponse_Ctip clone() => GetCtipResponse_Ctip()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetCtipResponse_Ctip copyWith(void Function(GetCtipResponse_Ctip) updates) => super.copyWith((message) => updates(message as GetCtipResponse_Ctip)) as GetCtipResponse_Ctip;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCtipResponse_Ctip create() => GetCtipResponse_Ctip._();
  GetCtipResponse_Ctip createEmptyInstance() => create();
  static $pb.PbList<GetCtipResponse_Ctip> createRepeated() => $pb.PbList<GetCtipResponse_Ctip>();
  @$core.pragma('dart2js:noInline')
  static GetCtipResponse_Ctip getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCtipResponse_Ctip>(create);
  static GetCtipResponse_Ctip? _defaultInstance;

  @$pb.TagNumber(1)
  $1.ReverseHex get txid => $_getN(0);
  @$pb.TagNumber(1)
  set txid($1.ReverseHex v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
  @$pb.TagNumber(1)
  $1.ReverseHex ensureTxid() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.int get vout => $_getIZ(1);
  @$pb.TagNumber(2)
  set vout($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearVout() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get value => $_getI64(2);
  @$pb.TagNumber(3)
  set value($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearValue() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get sequenceNumber => $_getI64(3);
  @$pb.TagNumber(4)
  set sequenceNumber($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSequenceNumber() => $_has(3);
  @$pb.TagNumber(4)
  void clearSequenceNumber() => clearField(4);
}

class GetCtipResponse extends $pb.GeneratedMessage {
  factory GetCtipResponse({
    GetCtipResponse_Ctip? ctip,
  }) {
    final $result = create();
    if (ctip != null) {
      $result.ctip = ctip;
    }
    return $result;
  }
  GetCtipResponse._() : super();
  factory GetCtipResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetCtipResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCtipResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<GetCtipResponse_Ctip>(1, _omitFieldNames ? '' : 'ctip', subBuilder: GetCtipResponse_Ctip.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetCtipResponse clone() => GetCtipResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetCtipResponse copyWith(void Function(GetCtipResponse) updates) => super.copyWith((message) => updates(message as GetCtipResponse)) as GetCtipResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetCtipResponse create() => GetCtipResponse._();
  GetCtipResponse createEmptyInstance() => create();
  static $pb.PbList<GetCtipResponse> createRepeated() => $pb.PbList<GetCtipResponse>();
  @$core.pragma('dart2js:noInline')
  static GetCtipResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCtipResponse>(create);
  static GetCtipResponse? _defaultInstance;

  @$pb.TagNumber(1)
  GetCtipResponse_Ctip get ctip => $_getN(0);
  @$pb.TagNumber(1)
  set ctip(GetCtipResponse_Ctip v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasCtip() => $_has(0);
  @$pb.TagNumber(1)
  void clearCtip() => clearField(1);
  @$pb.TagNumber(1)
  GetCtipResponse_Ctip ensureCtip() => $_ensure(0);
}

class GetSidechainProposalsRequest extends $pb.GeneratedMessage {
  factory GetSidechainProposalsRequest() => create();
  GetSidechainProposalsRequest._() : super();
  factory GetSidechainProposalsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetSidechainProposalsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainProposalsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetSidechainProposalsRequest clone() => GetSidechainProposalsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetSidechainProposalsRequest copyWith(void Function(GetSidechainProposalsRequest) updates) => super.copyWith((message) => updates(message as GetSidechainProposalsRequest)) as GetSidechainProposalsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSidechainProposalsRequest create() => GetSidechainProposalsRequest._();
  GetSidechainProposalsRequest createEmptyInstance() => create();
  static $pb.PbList<GetSidechainProposalsRequest> createRepeated() => $pb.PbList<GetSidechainProposalsRequest>();
  @$core.pragma('dart2js:noInline')
  static GetSidechainProposalsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetSidechainProposalsRequest>(create);
  static GetSidechainProposalsRequest? _defaultInstance;
}

class GetSidechainProposalsResponse_SidechainProposal extends $pb.GeneratedMessage {
  factory GetSidechainProposalsResponse_SidechainProposal({
    $0.UInt32Value? sidechainNumber,
    $1.ConsensusHex? description,
    $1.ReverseHex? descriptionSha256dHash,
    $0.UInt32Value? voteCount,
    $0.UInt32Value? proposalHeight,
    $0.UInt32Value? proposalAge,
    $3.SidechainDeclaration? declaration,
  }) {
    final $result = create();
    if (sidechainNumber != null) {
      $result.sidechainNumber = sidechainNumber;
    }
    if (description != null) {
      $result.description = description;
    }
    if (descriptionSha256dHash != null) {
      $result.descriptionSha256dHash = descriptionSha256dHash;
    }
    if (voteCount != null) {
      $result.voteCount = voteCount;
    }
    if (proposalHeight != null) {
      $result.proposalHeight = proposalHeight;
    }
    if (proposalAge != null) {
      $result.proposalAge = proposalAge;
    }
    if (declaration != null) {
      $result.declaration = declaration;
    }
    return $result;
  }
  GetSidechainProposalsResponse_SidechainProposal._() : super();
  factory GetSidechainProposalsResponse_SidechainProposal.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetSidechainProposalsResponse_SidechainProposal.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainProposalsResponse.SidechainProposal', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$0.UInt32Value>(1, _omitFieldNames ? '' : 'sidechainNumber', subBuilder: $0.UInt32Value.create)
    ..aOM<$1.ConsensusHex>(2, _omitFieldNames ? '' : 'description', subBuilder: $1.ConsensusHex.create)
    ..aOM<$1.ReverseHex>(3, _omitFieldNames ? '' : 'descriptionSha256dHash', subBuilder: $1.ReverseHex.create)
    ..aOM<$0.UInt32Value>(4, _omitFieldNames ? '' : 'voteCount', subBuilder: $0.UInt32Value.create)
    ..aOM<$0.UInt32Value>(5, _omitFieldNames ? '' : 'proposalHeight', subBuilder: $0.UInt32Value.create)
    ..aOM<$0.UInt32Value>(6, _omitFieldNames ? '' : 'proposalAge', subBuilder: $0.UInt32Value.create)
    ..aOM<$3.SidechainDeclaration>(7, _omitFieldNames ? '' : 'declaration', subBuilder: $3.SidechainDeclaration.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetSidechainProposalsResponse_SidechainProposal clone() => GetSidechainProposalsResponse_SidechainProposal()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetSidechainProposalsResponse_SidechainProposal copyWith(void Function(GetSidechainProposalsResponse_SidechainProposal) updates) => super.copyWith((message) => updates(message as GetSidechainProposalsResponse_SidechainProposal)) as GetSidechainProposalsResponse_SidechainProposal;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSidechainProposalsResponse_SidechainProposal create() => GetSidechainProposalsResponse_SidechainProposal._();
  GetSidechainProposalsResponse_SidechainProposal createEmptyInstance() => create();
  static $pb.PbList<GetSidechainProposalsResponse_SidechainProposal> createRepeated() => $pb.PbList<GetSidechainProposalsResponse_SidechainProposal>();
  @$core.pragma('dart2js:noInline')
  static GetSidechainProposalsResponse_SidechainProposal getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetSidechainProposalsResponse_SidechainProposal>(create);
  static GetSidechainProposalsResponse_SidechainProposal? _defaultInstance;

  @$pb.TagNumber(1)
  $0.UInt32Value get sidechainNumber => $_getN(0);
  @$pb.TagNumber(1)
  set sidechainNumber($0.UInt32Value v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechainNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainNumber() => clearField(1);
  @$pb.TagNumber(1)
  $0.UInt32Value ensureSidechainNumber() => $_ensure(0);

  /// Raw sidechain proposal description
  @$pb.TagNumber(2)
  $1.ConsensusHex get description => $_getN(1);
  @$pb.TagNumber(2)
  set description($1.ConsensusHex v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => clearField(2);
  @$pb.TagNumber(2)
  $1.ConsensusHex ensureDescription() => $_ensure(1);

  @$pb.TagNumber(3)
  $1.ReverseHex get descriptionSha256dHash => $_getN(2);
  @$pb.TagNumber(3)
  set descriptionSha256dHash($1.ReverseHex v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasDescriptionSha256dHash() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescriptionSha256dHash() => clearField(3);
  @$pb.TagNumber(3)
  $1.ReverseHex ensureDescriptionSha256dHash() => $_ensure(2);

  @$pb.TagNumber(4)
  $0.UInt32Value get voteCount => $_getN(3);
  @$pb.TagNumber(4)
  set voteCount($0.UInt32Value v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasVoteCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearVoteCount() => clearField(4);
  @$pb.TagNumber(4)
  $0.UInt32Value ensureVoteCount() => $_ensure(3);

  @$pb.TagNumber(5)
  $0.UInt32Value get proposalHeight => $_getN(4);
  @$pb.TagNumber(5)
  set proposalHeight($0.UInt32Value v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasProposalHeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearProposalHeight() => clearField(5);
  @$pb.TagNumber(5)
  $0.UInt32Value ensureProposalHeight() => $_ensure(4);

  @$pb.TagNumber(6)
  $0.UInt32Value get proposalAge => $_getN(5);
  @$pb.TagNumber(6)
  set proposalAge($0.UInt32Value v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasProposalAge() => $_has(5);
  @$pb.TagNumber(6)
  void clearProposalAge() => clearField(6);
  @$pb.TagNumber(6)
  $0.UInt32Value ensureProposalAge() => $_ensure(5);

  /// Sidechain data, as declared in the M1 proposal.
  /// Might be nil, if the proposal uses an unknown version.
  @$pb.TagNumber(7)
  $3.SidechainDeclaration get declaration => $_getN(6);
  @$pb.TagNumber(7)
  set declaration($3.SidechainDeclaration v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasDeclaration() => $_has(6);
  @$pb.TagNumber(7)
  void clearDeclaration() => clearField(7);
  @$pb.TagNumber(7)
  $3.SidechainDeclaration ensureDeclaration() => $_ensure(6);
}

class GetSidechainProposalsResponse extends $pb.GeneratedMessage {
  factory GetSidechainProposalsResponse({
    $core.Iterable<GetSidechainProposalsResponse_SidechainProposal>? sidechainProposals,
  }) {
    final $result = create();
    if (sidechainProposals != null) {
      $result.sidechainProposals.addAll(sidechainProposals);
    }
    return $result;
  }
  GetSidechainProposalsResponse._() : super();
  factory GetSidechainProposalsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetSidechainProposalsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainProposalsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..pc<GetSidechainProposalsResponse_SidechainProposal>(1, _omitFieldNames ? '' : 'sidechainProposals', $pb.PbFieldType.PM, subBuilder: GetSidechainProposalsResponse_SidechainProposal.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetSidechainProposalsResponse clone() => GetSidechainProposalsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetSidechainProposalsResponse copyWith(void Function(GetSidechainProposalsResponse) updates) => super.copyWith((message) => updates(message as GetSidechainProposalsResponse)) as GetSidechainProposalsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSidechainProposalsResponse create() => GetSidechainProposalsResponse._();
  GetSidechainProposalsResponse createEmptyInstance() => create();
  static $pb.PbList<GetSidechainProposalsResponse> createRepeated() => $pb.PbList<GetSidechainProposalsResponse>();
  @$core.pragma('dart2js:noInline')
  static GetSidechainProposalsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetSidechainProposalsResponse>(create);
  static GetSidechainProposalsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<GetSidechainProposalsResponse_SidechainProposal> get sidechainProposals => $_getList(0);
}

class GetSidechainsRequest extends $pb.GeneratedMessage {
  factory GetSidechainsRequest() => create();
  GetSidechainsRequest._() : super();
  factory GetSidechainsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetSidechainsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetSidechainsRequest clone() => GetSidechainsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetSidechainsRequest copyWith(void Function(GetSidechainsRequest) updates) => super.copyWith((message) => updates(message as GetSidechainsRequest)) as GetSidechainsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSidechainsRequest create() => GetSidechainsRequest._();
  GetSidechainsRequest createEmptyInstance() => create();
  static $pb.PbList<GetSidechainsRequest> createRepeated() => $pb.PbList<GetSidechainsRequest>();
  @$core.pragma('dart2js:noInline')
  static GetSidechainsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetSidechainsRequest>(create);
  static GetSidechainsRequest? _defaultInstance;
}

class GetSidechainsResponse_SidechainInfo extends $pb.GeneratedMessage {
  factory GetSidechainsResponse_SidechainInfo({
    $0.UInt32Value? sidechainNumber,
    $1.ConsensusHex? description,
    $0.UInt32Value? voteCount,
    $0.UInt32Value? proposalHeight,
    $0.UInt32Value? activationHeight,
    $3.SidechainDeclaration? declaration,
  }) {
    final $result = create();
    if (sidechainNumber != null) {
      $result.sidechainNumber = sidechainNumber;
    }
    if (description != null) {
      $result.description = description;
    }
    if (voteCount != null) {
      $result.voteCount = voteCount;
    }
    if (proposalHeight != null) {
      $result.proposalHeight = proposalHeight;
    }
    if (activationHeight != null) {
      $result.activationHeight = activationHeight;
    }
    if (declaration != null) {
      $result.declaration = declaration;
    }
    return $result;
  }
  GetSidechainsResponse_SidechainInfo._() : super();
  factory GetSidechainsResponse_SidechainInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetSidechainsResponse_SidechainInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainsResponse.SidechainInfo', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$0.UInt32Value>(1, _omitFieldNames ? '' : 'sidechainNumber', subBuilder: $0.UInt32Value.create)
    ..aOM<$1.ConsensusHex>(2, _omitFieldNames ? '' : 'description', subBuilder: $1.ConsensusHex.create)
    ..aOM<$0.UInt32Value>(3, _omitFieldNames ? '' : 'voteCount', subBuilder: $0.UInt32Value.create)
    ..aOM<$0.UInt32Value>(4, _omitFieldNames ? '' : 'proposalHeight', subBuilder: $0.UInt32Value.create)
    ..aOM<$0.UInt32Value>(5, _omitFieldNames ? '' : 'activationHeight', subBuilder: $0.UInt32Value.create)
    ..aOM<$3.SidechainDeclaration>(6, _omitFieldNames ? '' : 'declaration', subBuilder: $3.SidechainDeclaration.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetSidechainsResponse_SidechainInfo clone() => GetSidechainsResponse_SidechainInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetSidechainsResponse_SidechainInfo copyWith(void Function(GetSidechainsResponse_SidechainInfo) updates) => super.copyWith((message) => updates(message as GetSidechainsResponse_SidechainInfo)) as GetSidechainsResponse_SidechainInfo;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSidechainsResponse_SidechainInfo create() => GetSidechainsResponse_SidechainInfo._();
  GetSidechainsResponse_SidechainInfo createEmptyInstance() => create();
  static $pb.PbList<GetSidechainsResponse_SidechainInfo> createRepeated() => $pb.PbList<GetSidechainsResponse_SidechainInfo>();
  @$core.pragma('dart2js:noInline')
  static GetSidechainsResponse_SidechainInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetSidechainsResponse_SidechainInfo>(create);
  static GetSidechainsResponse_SidechainInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $0.UInt32Value get sidechainNumber => $_getN(0);
  @$pb.TagNumber(1)
  set sidechainNumber($0.UInt32Value v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechainNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainNumber() => clearField(1);
  @$pb.TagNumber(1)
  $0.UInt32Value ensureSidechainNumber() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.ConsensusHex get description => $_getN(1);
  @$pb.TagNumber(2)
  set description($1.ConsensusHex v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => clearField(2);
  @$pb.TagNumber(2)
  $1.ConsensusHex ensureDescription() => $_ensure(1);

  @$pb.TagNumber(3)
  $0.UInt32Value get voteCount => $_getN(2);
  @$pb.TagNumber(3)
  set voteCount($0.UInt32Value v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasVoteCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearVoteCount() => clearField(3);
  @$pb.TagNumber(3)
  $0.UInt32Value ensureVoteCount() => $_ensure(2);

  @$pb.TagNumber(4)
  $0.UInt32Value get proposalHeight => $_getN(3);
  @$pb.TagNumber(4)
  set proposalHeight($0.UInt32Value v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasProposalHeight() => $_has(3);
  @$pb.TagNumber(4)
  void clearProposalHeight() => clearField(4);
  @$pb.TagNumber(4)
  $0.UInt32Value ensureProposalHeight() => $_ensure(3);

  @$pb.TagNumber(5)
  $0.UInt32Value get activationHeight => $_getN(4);
  @$pb.TagNumber(5)
  set activationHeight($0.UInt32Value v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasActivationHeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearActivationHeight() => clearField(5);
  @$pb.TagNumber(5)
  $0.UInt32Value ensureActivationHeight() => $_ensure(4);

  /// Sidechain data, as declared in the M1 proposal.
  /// Might be nil, if the proposal uses an unknown version.
  @$pb.TagNumber(6)
  $3.SidechainDeclaration get declaration => $_getN(5);
  @$pb.TagNumber(6)
  set declaration($3.SidechainDeclaration v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasDeclaration() => $_has(5);
  @$pb.TagNumber(6)
  void clearDeclaration() => clearField(6);
  @$pb.TagNumber(6)
  $3.SidechainDeclaration ensureDeclaration() => $_ensure(5);
}

class GetSidechainsResponse extends $pb.GeneratedMessage {
  factory GetSidechainsResponse({
    $core.Iterable<GetSidechainsResponse_SidechainInfo>? sidechains,
  }) {
    final $result = create();
    if (sidechains != null) {
      $result.sidechains.addAll(sidechains);
    }
    return $result;
  }
  GetSidechainsResponse._() : super();
  factory GetSidechainsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetSidechainsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..pc<GetSidechainsResponse_SidechainInfo>(1, _omitFieldNames ? '' : 'sidechains', $pb.PbFieldType.PM, subBuilder: GetSidechainsResponse_SidechainInfo.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetSidechainsResponse clone() => GetSidechainsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetSidechainsResponse copyWith(void Function(GetSidechainsResponse) updates) => super.copyWith((message) => updates(message as GetSidechainsResponse)) as GetSidechainsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetSidechainsResponse create() => GetSidechainsResponse._();
  GetSidechainsResponse createEmptyInstance() => create();
  static $pb.PbList<GetSidechainsResponse> createRepeated() => $pb.PbList<GetSidechainsResponse>();
  @$core.pragma('dart2js:noInline')
  static GetSidechainsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetSidechainsResponse>(create);
  static GetSidechainsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<GetSidechainsResponse_SidechainInfo> get sidechains => $_getList(0);
}

class GetTwoWayPegDataRequest extends $pb.GeneratedMessage {
  factory GetTwoWayPegDataRequest({
    $0.UInt32Value? sidechainId,
    $1.ReverseHex? startBlockHash,
    $1.ReverseHex? endBlockHash,
  }) {
    final $result = create();
    if (sidechainId != null) {
      $result.sidechainId = sidechainId;
    }
    if (startBlockHash != null) {
      $result.startBlockHash = startBlockHash;
    }
    if (endBlockHash != null) {
      $result.endBlockHash = endBlockHash;
    }
    return $result;
  }
  GetTwoWayPegDataRequest._() : super();
  factory GetTwoWayPegDataRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetTwoWayPegDataRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTwoWayPegDataRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$0.UInt32Value>(1, _omitFieldNames ? '' : 'sidechainId', subBuilder: $0.UInt32Value.create)
    ..aOM<$1.ReverseHex>(2, _omitFieldNames ? '' : 'startBlockHash', subBuilder: $1.ReverseHex.create)
    ..aOM<$1.ReverseHex>(3, _omitFieldNames ? '' : 'endBlockHash', subBuilder: $1.ReverseHex.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetTwoWayPegDataRequest clone() => GetTwoWayPegDataRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetTwoWayPegDataRequest copyWith(void Function(GetTwoWayPegDataRequest) updates) => super.copyWith((message) => updates(message as GetTwoWayPegDataRequest)) as GetTwoWayPegDataRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTwoWayPegDataRequest create() => GetTwoWayPegDataRequest._();
  GetTwoWayPegDataRequest createEmptyInstance() => create();
  static $pb.PbList<GetTwoWayPegDataRequest> createRepeated() => $pb.PbList<GetTwoWayPegDataRequest>();
  @$core.pragma('dart2js:noInline')
  static GetTwoWayPegDataRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetTwoWayPegDataRequest>(create);
  static GetTwoWayPegDataRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.UInt32Value get sidechainId => $_getN(0);
  @$pb.TagNumber(1)
  set sidechainId($0.UInt32Value v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechainId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainId() => clearField(1);
  @$pb.TagNumber(1)
  $0.UInt32Value ensureSidechainId() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.ReverseHex get startBlockHash => $_getN(1);
  @$pb.TagNumber(2)
  set startBlockHash($1.ReverseHex v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasStartBlockHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartBlockHash() => clearField(2);
  @$pb.TagNumber(2)
  $1.ReverseHex ensureStartBlockHash() => $_ensure(1);

  @$pb.TagNumber(3)
  $1.ReverseHex get endBlockHash => $_getN(2);
  @$pb.TagNumber(3)
  set endBlockHash($1.ReverseHex v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasEndBlockHash() => $_has(2);
  @$pb.TagNumber(3)
  void clearEndBlockHash() => clearField(3);
  @$pb.TagNumber(3)
  $1.ReverseHex ensureEndBlockHash() => $_ensure(2);
}

class GetTwoWayPegDataResponse_ResponseItem extends $pb.GeneratedMessage {
  factory GetTwoWayPegDataResponse_ResponseItem({
    BlockHeaderInfo? blockHeaderInfo,
    BlockInfo? blockInfo,
  }) {
    final $result = create();
    if (blockHeaderInfo != null) {
      $result.blockHeaderInfo = blockHeaderInfo;
    }
    if (blockInfo != null) {
      $result.blockInfo = blockInfo;
    }
    return $result;
  }
  GetTwoWayPegDataResponse_ResponseItem._() : super();
  factory GetTwoWayPegDataResponse_ResponseItem.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetTwoWayPegDataResponse_ResponseItem.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTwoWayPegDataResponse.ResponseItem', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<BlockHeaderInfo>(1, _omitFieldNames ? '' : 'blockHeaderInfo', subBuilder: BlockHeaderInfo.create)
    ..aOM<BlockInfo>(2, _omitFieldNames ? '' : 'blockInfo', subBuilder: BlockInfo.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetTwoWayPegDataResponse_ResponseItem clone() => GetTwoWayPegDataResponse_ResponseItem()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetTwoWayPegDataResponse_ResponseItem copyWith(void Function(GetTwoWayPegDataResponse_ResponseItem) updates) => super.copyWith((message) => updates(message as GetTwoWayPegDataResponse_ResponseItem)) as GetTwoWayPegDataResponse_ResponseItem;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTwoWayPegDataResponse_ResponseItem create() => GetTwoWayPegDataResponse_ResponseItem._();
  GetTwoWayPegDataResponse_ResponseItem createEmptyInstance() => create();
  static $pb.PbList<GetTwoWayPegDataResponse_ResponseItem> createRepeated() => $pb.PbList<GetTwoWayPegDataResponse_ResponseItem>();
  @$core.pragma('dart2js:noInline')
  static GetTwoWayPegDataResponse_ResponseItem getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetTwoWayPegDataResponse_ResponseItem>(create);
  static GetTwoWayPegDataResponse_ResponseItem? _defaultInstance;

  @$pb.TagNumber(1)
  BlockHeaderInfo get blockHeaderInfo => $_getN(0);
  @$pb.TagNumber(1)
  set blockHeaderInfo(BlockHeaderInfo v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBlockHeaderInfo() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHeaderInfo() => clearField(1);
  @$pb.TagNumber(1)
  BlockHeaderInfo ensureBlockHeaderInfo() => $_ensure(0);

  @$pb.TagNumber(2)
  BlockInfo get blockInfo => $_getN(1);
  @$pb.TagNumber(2)
  set blockInfo(BlockInfo v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasBlockInfo() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlockInfo() => clearField(2);
  @$pb.TagNumber(2)
  BlockInfo ensureBlockInfo() => $_ensure(1);
}

class GetTwoWayPegDataResponse extends $pb.GeneratedMessage {
  factory GetTwoWayPegDataResponse({
    $core.Iterable<GetTwoWayPegDataResponse_ResponseItem>? blocks,
  }) {
    final $result = create();
    if (blocks != null) {
      $result.blocks.addAll(blocks);
    }
    return $result;
  }
  GetTwoWayPegDataResponse._() : super();
  factory GetTwoWayPegDataResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetTwoWayPegDataResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTwoWayPegDataResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..pc<GetTwoWayPegDataResponse_ResponseItem>(1, _omitFieldNames ? '' : 'blocks', $pb.PbFieldType.PM, subBuilder: GetTwoWayPegDataResponse_ResponseItem.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetTwoWayPegDataResponse clone() => GetTwoWayPegDataResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetTwoWayPegDataResponse copyWith(void Function(GetTwoWayPegDataResponse) updates) => super.copyWith((message) => updates(message as GetTwoWayPegDataResponse)) as GetTwoWayPegDataResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetTwoWayPegDataResponse create() => GetTwoWayPegDataResponse._();
  GetTwoWayPegDataResponse createEmptyInstance() => create();
  static $pb.PbList<GetTwoWayPegDataResponse> createRepeated() => $pb.PbList<GetTwoWayPegDataResponse>();
  @$core.pragma('dart2js:noInline')
  static GetTwoWayPegDataResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetTwoWayPegDataResponse>(create);
  static GetTwoWayPegDataResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<GetTwoWayPegDataResponse_ResponseItem> get blocks => $_getList(0);
}

class SubscribeEventsRequest extends $pb.GeneratedMessage {
  factory SubscribeEventsRequest({
    $0.UInt32Value? sidechainId,
  }) {
    final $result = create();
    if (sidechainId != null) {
      $result.sidechainId = sidechainId;
    }
    return $result;
  }
  SubscribeEventsRequest._() : super();
  factory SubscribeEventsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SubscribeEventsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubscribeEventsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$0.UInt32Value>(1, _omitFieldNames ? '' : 'sidechainId', subBuilder: $0.UInt32Value.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SubscribeEventsRequest clone() => SubscribeEventsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SubscribeEventsRequest copyWith(void Function(SubscribeEventsRequest) updates) => super.copyWith((message) => updates(message as SubscribeEventsRequest)) as SubscribeEventsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubscribeEventsRequest create() => SubscribeEventsRequest._();
  SubscribeEventsRequest createEmptyInstance() => create();
  static $pb.PbList<SubscribeEventsRequest> createRepeated() => $pb.PbList<SubscribeEventsRequest>();
  @$core.pragma('dart2js:noInline')
  static SubscribeEventsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubscribeEventsRequest>(create);
  static SubscribeEventsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.UInt32Value get sidechainId => $_getN(0);
  @$pb.TagNumber(1)
  set sidechainId($0.UInt32Value v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechainId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainId() => clearField(1);
  @$pb.TagNumber(1)
  $0.UInt32Value ensureSidechainId() => $_ensure(0);
}

class SubscribeEventsResponse_Event_ConnectBlock extends $pb.GeneratedMessage {
  factory SubscribeEventsResponse_Event_ConnectBlock({
    BlockHeaderInfo? headerInfo,
    BlockInfo? blockInfo,
  }) {
    final $result = create();
    if (headerInfo != null) {
      $result.headerInfo = headerInfo;
    }
    if (blockInfo != null) {
      $result.blockInfo = blockInfo;
    }
    return $result;
  }
  SubscribeEventsResponse_Event_ConnectBlock._() : super();
  factory SubscribeEventsResponse_Event_ConnectBlock.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SubscribeEventsResponse_Event_ConnectBlock.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubscribeEventsResponse.Event.ConnectBlock', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<BlockHeaderInfo>(1, _omitFieldNames ? '' : 'headerInfo', subBuilder: BlockHeaderInfo.create)
    ..aOM<BlockInfo>(2, _omitFieldNames ? '' : 'blockInfo', subBuilder: BlockInfo.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SubscribeEventsResponse_Event_ConnectBlock clone() => SubscribeEventsResponse_Event_ConnectBlock()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SubscribeEventsResponse_Event_ConnectBlock copyWith(void Function(SubscribeEventsResponse_Event_ConnectBlock) updates) => super.copyWith((message) => updates(message as SubscribeEventsResponse_Event_ConnectBlock)) as SubscribeEventsResponse_Event_ConnectBlock;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubscribeEventsResponse_Event_ConnectBlock create() => SubscribeEventsResponse_Event_ConnectBlock._();
  SubscribeEventsResponse_Event_ConnectBlock createEmptyInstance() => create();
  static $pb.PbList<SubscribeEventsResponse_Event_ConnectBlock> createRepeated() => $pb.PbList<SubscribeEventsResponse_Event_ConnectBlock>();
  @$core.pragma('dart2js:noInline')
  static SubscribeEventsResponse_Event_ConnectBlock getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubscribeEventsResponse_Event_ConnectBlock>(create);
  static SubscribeEventsResponse_Event_ConnectBlock? _defaultInstance;

  @$pb.TagNumber(1)
  BlockHeaderInfo get headerInfo => $_getN(0);
  @$pb.TagNumber(1)
  set headerInfo(BlockHeaderInfo v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasHeaderInfo() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeaderInfo() => clearField(1);
  @$pb.TagNumber(1)
  BlockHeaderInfo ensureHeaderInfo() => $_ensure(0);

  @$pb.TagNumber(2)
  BlockInfo get blockInfo => $_getN(1);
  @$pb.TagNumber(2)
  set blockInfo(BlockInfo v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasBlockInfo() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlockInfo() => clearField(2);
  @$pb.TagNumber(2)
  BlockInfo ensureBlockInfo() => $_ensure(1);
}

class SubscribeEventsResponse_Event_DisconnectBlock extends $pb.GeneratedMessage {
  factory SubscribeEventsResponse_Event_DisconnectBlock({
    $1.ReverseHex? blockHash,
  }) {
    final $result = create();
    if (blockHash != null) {
      $result.blockHash = blockHash;
    }
    return $result;
  }
  SubscribeEventsResponse_Event_DisconnectBlock._() : super();
  factory SubscribeEventsResponse_Event_DisconnectBlock.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SubscribeEventsResponse_Event_DisconnectBlock.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubscribeEventsResponse.Event.DisconnectBlock', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$1.ReverseHex>(1, _omitFieldNames ? '' : 'blockHash', subBuilder: $1.ReverseHex.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SubscribeEventsResponse_Event_DisconnectBlock clone() => SubscribeEventsResponse_Event_DisconnectBlock()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SubscribeEventsResponse_Event_DisconnectBlock copyWith(void Function(SubscribeEventsResponse_Event_DisconnectBlock) updates) => super.copyWith((message) => updates(message as SubscribeEventsResponse_Event_DisconnectBlock)) as SubscribeEventsResponse_Event_DisconnectBlock;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubscribeEventsResponse_Event_DisconnectBlock create() => SubscribeEventsResponse_Event_DisconnectBlock._();
  SubscribeEventsResponse_Event_DisconnectBlock createEmptyInstance() => create();
  static $pb.PbList<SubscribeEventsResponse_Event_DisconnectBlock> createRepeated() => $pb.PbList<SubscribeEventsResponse_Event_DisconnectBlock>();
  @$core.pragma('dart2js:noInline')
  static SubscribeEventsResponse_Event_DisconnectBlock getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubscribeEventsResponse_Event_DisconnectBlock>(create);
  static SubscribeEventsResponse_Event_DisconnectBlock? _defaultInstance;

  @$pb.TagNumber(1)
  $1.ReverseHex get blockHash => $_getN(0);
  @$pb.TagNumber(1)
  set blockHash($1.ReverseHex v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBlockHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHash() => clearField(1);
  @$pb.TagNumber(1)
  $1.ReverseHex ensureBlockHash() => $_ensure(0);
}

enum SubscribeEventsResponse_Event_Event {
  connectBlock, 
  disconnectBlock, 
  notSet
}

class SubscribeEventsResponse_Event extends $pb.GeneratedMessage {
  factory SubscribeEventsResponse_Event({
    SubscribeEventsResponse_Event_ConnectBlock? connectBlock,
    SubscribeEventsResponse_Event_DisconnectBlock? disconnectBlock,
  }) {
    final $result = create();
    if (connectBlock != null) {
      $result.connectBlock = connectBlock;
    }
    if (disconnectBlock != null) {
      $result.disconnectBlock = disconnectBlock;
    }
    return $result;
  }
  SubscribeEventsResponse_Event._() : super();
  factory SubscribeEventsResponse_Event.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SubscribeEventsResponse_Event.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, SubscribeEventsResponse_Event_Event> _SubscribeEventsResponse_Event_EventByTag = {
    1 : SubscribeEventsResponse_Event_Event.connectBlock,
    2 : SubscribeEventsResponse_Event_Event.disconnectBlock,
    0 : SubscribeEventsResponse_Event_Event.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubscribeEventsResponse.Event', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOM<SubscribeEventsResponse_Event_ConnectBlock>(1, _omitFieldNames ? '' : 'connectBlock', subBuilder: SubscribeEventsResponse_Event_ConnectBlock.create)
    ..aOM<SubscribeEventsResponse_Event_DisconnectBlock>(2, _omitFieldNames ? '' : 'disconnectBlock', subBuilder: SubscribeEventsResponse_Event_DisconnectBlock.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SubscribeEventsResponse_Event clone() => SubscribeEventsResponse_Event()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SubscribeEventsResponse_Event copyWith(void Function(SubscribeEventsResponse_Event) updates) => super.copyWith((message) => updates(message as SubscribeEventsResponse_Event)) as SubscribeEventsResponse_Event;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubscribeEventsResponse_Event create() => SubscribeEventsResponse_Event._();
  SubscribeEventsResponse_Event createEmptyInstance() => create();
  static $pb.PbList<SubscribeEventsResponse_Event> createRepeated() => $pb.PbList<SubscribeEventsResponse_Event>();
  @$core.pragma('dart2js:noInline')
  static SubscribeEventsResponse_Event getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubscribeEventsResponse_Event>(create);
  static SubscribeEventsResponse_Event? _defaultInstance;

  SubscribeEventsResponse_Event_Event whichEvent() => _SubscribeEventsResponse_Event_EventByTag[$_whichOneof(0)]!;
  void clearEvent() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  SubscribeEventsResponse_Event_ConnectBlock get connectBlock => $_getN(0);
  @$pb.TagNumber(1)
  set connectBlock(SubscribeEventsResponse_Event_ConnectBlock v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasConnectBlock() => $_has(0);
  @$pb.TagNumber(1)
  void clearConnectBlock() => clearField(1);
  @$pb.TagNumber(1)
  SubscribeEventsResponse_Event_ConnectBlock ensureConnectBlock() => $_ensure(0);

  @$pb.TagNumber(2)
  SubscribeEventsResponse_Event_DisconnectBlock get disconnectBlock => $_getN(1);
  @$pb.TagNumber(2)
  set disconnectBlock(SubscribeEventsResponse_Event_DisconnectBlock v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasDisconnectBlock() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisconnectBlock() => clearField(2);
  @$pb.TagNumber(2)
  SubscribeEventsResponse_Event_DisconnectBlock ensureDisconnectBlock() => $_ensure(1);
}

class SubscribeEventsResponse extends $pb.GeneratedMessage {
  factory SubscribeEventsResponse({
    SubscribeEventsResponse_Event? event,
  }) {
    final $result = create();
    if (event != null) {
      $result.event = event;
    }
    return $result;
  }
  SubscribeEventsResponse._() : super();
  factory SubscribeEventsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SubscribeEventsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubscribeEventsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<SubscribeEventsResponse_Event>(1, _omitFieldNames ? '' : 'event', subBuilder: SubscribeEventsResponse_Event.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SubscribeEventsResponse clone() => SubscribeEventsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SubscribeEventsResponse copyWith(void Function(SubscribeEventsResponse) updates) => super.copyWith((message) => updates(message as SubscribeEventsResponse)) as SubscribeEventsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubscribeEventsResponse create() => SubscribeEventsResponse._();
  SubscribeEventsResponse createEmptyInstance() => create();
  static $pb.PbList<SubscribeEventsResponse> createRepeated() => $pb.PbList<SubscribeEventsResponse>();
  @$core.pragma('dart2js:noInline')
  static SubscribeEventsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubscribeEventsResponse>(create);
  static SubscribeEventsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SubscribeEventsResponse_Event get event => $_getN(0);
  @$pb.TagNumber(1)
  set event(SubscribeEventsResponse_Event v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasEvent() => $_has(0);
  @$pb.TagNumber(1)
  void clearEvent() => clearField(1);
  @$pb.TagNumber(1)
  SubscribeEventsResponse_Event ensureEvent() => $_ensure(0);
}

class ValidatorServiceApi {
  $pb.RpcClient _client;
  ValidatorServiceApi(this._client);

  $async.Future<GetBlockHeaderInfoResponse> getBlockHeaderInfo($pb.ClientContext? ctx, GetBlockHeaderInfoRequest request) =>
    _client.invoke<GetBlockHeaderInfoResponse>(ctx, 'ValidatorService', 'GetBlockHeaderInfo', request, GetBlockHeaderInfoResponse())
  ;
  $async.Future<GetBlockInfoResponse> getBlockInfo($pb.ClientContext? ctx, GetBlockInfoRequest request) =>
    _client.invoke<GetBlockInfoResponse>(ctx, 'ValidatorService', 'GetBlockInfo', request, GetBlockInfoResponse())
  ;
  $async.Future<GetBmmHStarCommitmentResponse> getBmmHStarCommitment($pb.ClientContext? ctx, GetBmmHStarCommitmentRequest request) =>
    _client.invoke<GetBmmHStarCommitmentResponse>(ctx, 'ValidatorService', 'GetBmmHStarCommitment', request, GetBmmHStarCommitmentResponse())
  ;
  $async.Future<GetChainInfoResponse> getChainInfo($pb.ClientContext? ctx, GetChainInfoRequest request) =>
    _client.invoke<GetChainInfoResponse>(ctx, 'ValidatorService', 'GetChainInfo', request, GetChainInfoResponse())
  ;
  $async.Future<GetChainTipResponse> getChainTip($pb.ClientContext? ctx, GetChainTipRequest request) =>
    _client.invoke<GetChainTipResponse>(ctx, 'ValidatorService', 'GetChainTip', request, GetChainTipResponse())
  ;
  $async.Future<GetCoinbasePSBTResponse> getCoinbasePSBT($pb.ClientContext? ctx, GetCoinbasePSBTRequest request) =>
    _client.invoke<GetCoinbasePSBTResponse>(ctx, 'ValidatorService', 'GetCoinbasePSBT', request, GetCoinbasePSBTResponse())
  ;
  $async.Future<GetCtipResponse> getCtip($pb.ClientContext? ctx, GetCtipRequest request) =>
    _client.invoke<GetCtipResponse>(ctx, 'ValidatorService', 'GetCtip', request, GetCtipResponse())
  ;
  $async.Future<GetSidechainProposalsResponse> getSidechainProposals($pb.ClientContext? ctx, GetSidechainProposalsRequest request) =>
    _client.invoke<GetSidechainProposalsResponse>(ctx, 'ValidatorService', 'GetSidechainProposals', request, GetSidechainProposalsResponse())
  ;
  $async.Future<GetSidechainsResponse> getSidechains($pb.ClientContext? ctx, GetSidechainsRequest request) =>
    _client.invoke<GetSidechainsResponse>(ctx, 'ValidatorService', 'GetSidechains', request, GetSidechainsResponse())
  ;
  $async.Future<GetTwoWayPegDataResponse> getTwoWayPegData($pb.ClientContext? ctx, GetTwoWayPegDataRequest request) =>
    _client.invoke<GetTwoWayPegDataResponse>(ctx, 'ValidatorService', 'GetTwoWayPegData', request, GetTwoWayPegDataResponse())
  ;
  $async.Future<SubscribeEventsResponse> subscribeEvents($pb.ClientContext? ctx, SubscribeEventsRequest request) =>
    _client.invoke<SubscribeEventsResponse>(ctx, 'ValidatorService', 'SubscribeEvents', request, SubscribeEventsResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
