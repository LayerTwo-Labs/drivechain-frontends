// This is a generated file - do not edit.
//
// Generated from cusf/mainchain/v1/validator.proto.

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
import 'package:protobuf/well_known_types/google/protobuf/wrappers.pb.dart' as $1;

import '../../common/v1/common.pb.dart' as $0;
import 'common.pb.dart' as $2;
import 'validator.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'validator.pbenum.dart';

class BlockHeaderInfo extends $pb.GeneratedMessage {
  factory BlockHeaderInfo({
    $0.ReverseHex? blockHash,
    $0.ReverseHex? prevBlockHash,
    $core.int? height,
    $0.ConsensusHex? work,
    $fixnum.Int64? timestamp,
  }) {
    final result = BlockHeaderInfo._();
    if (blockHash != null) result.blockHash = blockHash;
    if (prevBlockHash != null) result.prevBlockHash = prevBlockHash;
    if (height != null) result.height = height;
    if (work != null) result.work = work;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  BlockHeaderInfo._();

  factory BlockHeaderInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BlockHeaderInfo()..mergeFromBuffer(data, registry);
  factory BlockHeaderInfo.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BlockHeaderInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BlockHeaderInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: BlockHeaderInfo.$_createMessage)
    ..aOM<$0.ReverseHex>(1, _omitFieldNames ? '' : 'blockHash', subBuilder: $0.ReverseHex.$_createMessage)
    ..aOM<$0.ReverseHex>(2, _omitFieldNames ? '' : 'prevBlockHash', subBuilder: $0.ReverseHex.$_createMessage)
    ..aI(3, _omitFieldNames ? '' : 'height', fieldType: $pb.PbFieldType.OU3)
    ..aOM<$0.ConsensusHex>(4, _omitFieldNames ? '' : 'work', subBuilder: $0.ConsensusHex.$_createMessage)
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'timestamp', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockHeaderInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockHeaderInfo copyWith(void Function(BlockHeaderInfo) updates) =>
      super.copyWith((message) => updates(message as BlockHeaderInfo)) as BlockHeaderInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BlockHeaderInfo() / BlockHeaderInfo.new instead')
  static BlockHeaderInfo create() => BlockHeaderInfo._();
  static $pb.GeneratedMessage $_createMessage() => BlockHeaderInfo._();
  @$core.override
  BlockHeaderInfo createEmptyInstance() => BlockHeaderInfo._();
  @$core.pragma('dart2js:noInline')
  static BlockHeaderInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BlockHeaderInfo>(BlockHeaderInfo.$_createMessage);
  static BlockHeaderInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $0.ReverseHex get blockHash => $_getN(0);
  @$pb.TagNumber(1)
  set blockHash($0.ReverseHex value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBlockHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHash() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.ReverseHex ensureBlockHash() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.ReverseHex get prevBlockHash => $_getN(1);
  @$pb.TagNumber(2)
  set prevBlockHash($0.ReverseHex value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPrevBlockHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrevBlockHash() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.ReverseHex ensurePrevBlockHash() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.int get height => $_getIZ(2);
  @$pb.TagNumber(3)
  set height($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHeight() => $_has(2);
  @$pb.TagNumber(3)
  void clearHeight() => $_clearField(3);

  /// Total work as a uint256, little-endian
  @$pb.TagNumber(4)
  $0.ConsensusHex get work => $_getN(3);
  @$pb.TagNumber(4)
  set work($0.ConsensusHex value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasWork() => $_has(3);
  @$pb.TagNumber(4)
  void clearWork() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.ConsensusHex ensureWork() => $_ensure(3);

  /// Unix timestamp (seconds since epoch)
  @$pb.TagNumber(5)
  $fixnum.Int64 get timestamp => $_getI64(4);
  @$pb.TagNumber(5)
  set timestamp($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimestamp() => $_clearField(5);
}

class Deposit_Output extends $pb.GeneratedMessage {
  factory Deposit_Output({
    $0.Hex? address,
    $1.UInt64Value? valueSats,
  }) {
    final result = Deposit_Output._();
    if (address != null) result.address = address;
    if (valueSats != null) result.valueSats = valueSats;
    return result;
  }

  Deposit_Output._();

  factory Deposit_Output.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Deposit_Output()..mergeFromBuffer(data, registry);
  factory Deposit_Output.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Deposit_Output()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Deposit.Output',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: Deposit_Output.$_createMessage)
    ..aOM<$0.Hex>(2, _omitFieldNames ? '' : 'address', subBuilder: $0.Hex.$_createMessage)
    ..aOM<$1.UInt64Value>(3, _omitFieldNames ? '' : 'valueSats', subBuilder: $1.UInt64Value.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Deposit_Output clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Deposit_Output copyWith(void Function(Deposit_Output) updates) =>
      super.copyWith((message) => updates(message as Deposit_Output)) as Deposit_Output;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Deposit_Output() / Deposit_Output.new instead')
  static Deposit_Output create() => Deposit_Output._();
  static $pb.GeneratedMessage $_createMessage() => Deposit_Output._();
  @$core.override
  Deposit_Output createEmptyInstance() => Deposit_Output._();
  @$core.pragma('dart2js:noInline')
  static Deposit_Output getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Deposit_Output>(Deposit_Output.$_createMessage);
  static Deposit_Output? _defaultInstance;

  @$pb.TagNumber(2)
  $0.Hex get address => $_getN(0);
  @$pb.TagNumber(2)
  set address($0.Hex value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(2)
  void clearAddress() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Hex ensureAddress() => $_ensure(0);

  @$pb.TagNumber(3)
  $1.UInt64Value get valueSats => $_getN(1);
  @$pb.TagNumber(3)
  set valueSats($1.UInt64Value value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasValueSats() => $_has(1);
  @$pb.TagNumber(3)
  void clearValueSats() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.UInt64Value ensureValueSats() => $_ensure(1);
}

class Deposit extends $pb.GeneratedMessage {
  factory Deposit({
    $1.UInt64Value? sequenceNumber,
    $2.OutPoint? outpoint,
    Deposit_Output? output,
  }) {
    final result = Deposit._();
    if (sequenceNumber != null) result.sequenceNumber = sequenceNumber;
    if (outpoint != null) result.outpoint = outpoint;
    if (output != null) result.output = output;
    return result;
  }

  Deposit._();

  factory Deposit.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Deposit()..mergeFromBuffer(data, registry);
  factory Deposit.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Deposit()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Deposit',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: Deposit.$_createMessage)
    ..aOM<$1.UInt64Value>(1, _omitFieldNames ? '' : 'sequenceNumber', subBuilder: $1.UInt64Value.$_createMessage)
    ..aOM<$2.OutPoint>(2, _omitFieldNames ? '' : 'outpoint', subBuilder: $2.OutPoint.$_createMessage)
    ..aOM<Deposit_Output>(3, _omitFieldNames ? '' : 'output', subBuilder: Deposit_Output.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Deposit clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Deposit copyWith(void Function(Deposit) updates) =>
      super.copyWith((message) => updates(message as Deposit)) as Deposit;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Deposit() / Deposit.new instead')
  static Deposit create() => Deposit._();
  static $pb.GeneratedMessage $_createMessage() => Deposit._();
  @$core.override
  Deposit createEmptyInstance() => Deposit._();
  @$core.pragma('dart2js:noInline')
  static Deposit getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Deposit>(Deposit.$_createMessage);
  static Deposit? _defaultInstance;

  @$pb.TagNumber(1)
  $1.UInt64Value get sequenceNumber => $_getN(0);
  @$pb.TagNumber(1)
  set sequenceNumber($1.UInt64Value value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSequenceNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearSequenceNumber() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.UInt64Value ensureSequenceNumber() => $_ensure(0);

  @$pb.TagNumber(2)
  $2.OutPoint get outpoint => $_getN(1);
  @$pb.TagNumber(2)
  set outpoint($2.OutPoint value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasOutpoint() => $_has(1);
  @$pb.TagNumber(2)
  void clearOutpoint() => $_clearField(2);
  @$pb.TagNumber(2)
  $2.OutPoint ensureOutpoint() => $_ensure(1);

  @$pb.TagNumber(3)
  Deposit_Output get output => $_getN(2);
  @$pb.TagNumber(3)
  set output(Deposit_Output value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasOutput() => $_has(2);
  @$pb.TagNumber(3)
  void clearOutput() => $_clearField(3);
  @$pb.TagNumber(3)
  Deposit_Output ensureOutput() => $_ensure(2);
}

class WithdrawalBundleEvent_Event_Failed extends $pb.GeneratedMessage {
  factory WithdrawalBundleEvent_Event_Failed() => WithdrawalBundleEvent_Event_Failed._();

  WithdrawalBundleEvent_Event_Failed._();

  factory WithdrawalBundleEvent_Event_Failed.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalBundleEvent_Event_Failed()..mergeFromBuffer(data, registry);
  factory WithdrawalBundleEvent_Event_Failed.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalBundleEvent_Event_Failed()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawalBundleEvent.Event.Failed',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: WithdrawalBundleEvent_Event_Failed.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalBundleEvent_Event_Failed clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalBundleEvent_Event_Failed copyWith(void Function(WithdrawalBundleEvent_Event_Failed) updates) =>
      super.copyWith((message) => updates(message as WithdrawalBundleEvent_Event_Failed))
          as WithdrawalBundleEvent_Event_Failed;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WithdrawalBundleEvent_Event_Failed() / WithdrawalBundleEvent_Event_Failed.new instead')
  static WithdrawalBundleEvent_Event_Failed create() => WithdrawalBundleEvent_Event_Failed._();
  static $pb.GeneratedMessage $_createMessage() => WithdrawalBundleEvent_Event_Failed._();
  @$core.override
  WithdrawalBundleEvent_Event_Failed createEmptyInstance() => WithdrawalBundleEvent_Event_Failed._();
  @$core.pragma('dart2js:noInline')
  static WithdrawalBundleEvent_Event_Failed getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WithdrawalBundleEvent_Event_Failed>(
          WithdrawalBundleEvent_Event_Failed.$_createMessage);
  static WithdrawalBundleEvent_Event_Failed? _defaultInstance;
}

class WithdrawalBundleEvent_Event_Succeeded extends $pb.GeneratedMessage {
  factory WithdrawalBundleEvent_Event_Succeeded({
    $1.UInt64Value? sequenceNumber,
    $0.ConsensusHex? transaction,
  }) {
    final result = WithdrawalBundleEvent_Event_Succeeded._();
    if (sequenceNumber != null) result.sequenceNumber = sequenceNumber;
    if (transaction != null) result.transaction = transaction;
    return result;
  }

  WithdrawalBundleEvent_Event_Succeeded._();

  factory WithdrawalBundleEvent_Event_Succeeded.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalBundleEvent_Event_Succeeded()..mergeFromBuffer(data, registry);
  factory WithdrawalBundleEvent_Event_Succeeded.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalBundleEvent_Event_Succeeded()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawalBundleEvent.Event.Succeeded',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: WithdrawalBundleEvent_Event_Succeeded.$_createMessage)
    ..aOM<$1.UInt64Value>(1, _omitFieldNames ? '' : 'sequenceNumber', subBuilder: $1.UInt64Value.$_createMessage)
    ..aOM<$0.ConsensusHex>(2, _omitFieldNames ? '' : 'transaction', subBuilder: $0.ConsensusHex.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalBundleEvent_Event_Succeeded clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalBundleEvent_Event_Succeeded copyWith(void Function(WithdrawalBundleEvent_Event_Succeeded) updates) =>
      super.copyWith((message) => updates(message as WithdrawalBundleEvent_Event_Succeeded))
          as WithdrawalBundleEvent_Event_Succeeded;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WithdrawalBundleEvent_Event_Succeeded() / WithdrawalBundleEvent_Event_Succeeded.new instead')
  static WithdrawalBundleEvent_Event_Succeeded create() => WithdrawalBundleEvent_Event_Succeeded._();
  static $pb.GeneratedMessage $_createMessage() => WithdrawalBundleEvent_Event_Succeeded._();
  @$core.override
  WithdrawalBundleEvent_Event_Succeeded createEmptyInstance() => WithdrawalBundleEvent_Event_Succeeded._();
  @$core.pragma('dart2js:noInline')
  static WithdrawalBundleEvent_Event_Succeeded getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WithdrawalBundleEvent_Event_Succeeded>(
          WithdrawalBundleEvent_Event_Succeeded.$_createMessage);
  static WithdrawalBundleEvent_Event_Succeeded? _defaultInstance;

  @$pb.TagNumber(1)
  $1.UInt64Value get sequenceNumber => $_getN(0);
  @$pb.TagNumber(1)
  set sequenceNumber($1.UInt64Value value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSequenceNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearSequenceNumber() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.UInt64Value ensureSequenceNumber() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.ConsensusHex get transaction => $_getN(1);
  @$pb.TagNumber(2)
  set transaction($0.ConsensusHex value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTransaction() => $_has(1);
  @$pb.TagNumber(2)
  void clearTransaction() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.ConsensusHex ensureTransaction() => $_ensure(1);
}

class WithdrawalBundleEvent_Event_Submitted extends $pb.GeneratedMessage {
  factory WithdrawalBundleEvent_Event_Submitted() => WithdrawalBundleEvent_Event_Submitted._();

  WithdrawalBundleEvent_Event_Submitted._();

  factory WithdrawalBundleEvent_Event_Submitted.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalBundleEvent_Event_Submitted()..mergeFromBuffer(data, registry);
  factory WithdrawalBundleEvent_Event_Submitted.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalBundleEvent_Event_Submitted()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawalBundleEvent.Event.Submitted',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: WithdrawalBundleEvent_Event_Submitted.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalBundleEvent_Event_Submitted clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalBundleEvent_Event_Submitted copyWith(void Function(WithdrawalBundleEvent_Event_Submitted) updates) =>
      super.copyWith((message) => updates(message as WithdrawalBundleEvent_Event_Submitted))
          as WithdrawalBundleEvent_Event_Submitted;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WithdrawalBundleEvent_Event_Submitted() / WithdrawalBundleEvent_Event_Submitted.new instead')
  static WithdrawalBundleEvent_Event_Submitted create() => WithdrawalBundleEvent_Event_Submitted._();
  static $pb.GeneratedMessage $_createMessage() => WithdrawalBundleEvent_Event_Submitted._();
  @$core.override
  WithdrawalBundleEvent_Event_Submitted createEmptyInstance() => WithdrawalBundleEvent_Event_Submitted._();
  @$core.pragma('dart2js:noInline')
  static WithdrawalBundleEvent_Event_Submitted getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WithdrawalBundleEvent_Event_Submitted>(
          WithdrawalBundleEvent_Event_Submitted.$_createMessage);
  static WithdrawalBundleEvent_Event_Submitted? _defaultInstance;
}

enum WithdrawalBundleEvent_Event_Event { failed, succeeded, submitted, notSet }

class WithdrawalBundleEvent_Event extends $pb.GeneratedMessage {
  factory WithdrawalBundleEvent_Event({
    WithdrawalBundleEvent_Event_Failed? failed,
    WithdrawalBundleEvent_Event_Succeeded? succeeded,
    WithdrawalBundleEvent_Event_Submitted? submitted,
  }) {
    final result = WithdrawalBundleEvent_Event._();
    if (failed != null) result.failed = failed;
    if (succeeded != null) result.succeeded = succeeded;
    if (submitted != null) result.submitted = submitted;
    return result;
  }

  WithdrawalBundleEvent_Event._();

  factory WithdrawalBundleEvent_Event.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalBundleEvent_Event()..mergeFromBuffer(data, registry);
  factory WithdrawalBundleEvent_Event.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalBundleEvent_Event()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, WithdrawalBundleEvent_Event_Event> _WithdrawalBundleEvent_Event_EventByTag = {
    1: WithdrawalBundleEvent_Event_Event.failed,
    2: WithdrawalBundleEvent_Event_Event.succeeded,
    3: WithdrawalBundleEvent_Event_Event.submitted,
    0: WithdrawalBundleEvent_Event_Event.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawalBundleEvent.Event',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: WithdrawalBundleEvent_Event.$_createMessage)
    ..oo(0, [1, 2, 3])
    ..aOM<WithdrawalBundleEvent_Event_Failed>(1, _omitFieldNames ? '' : 'failed',
        subBuilder: WithdrawalBundleEvent_Event_Failed.$_createMessage)
    ..aOM<WithdrawalBundleEvent_Event_Succeeded>(2, _omitFieldNames ? '' : 'succeeded',
        subBuilder: WithdrawalBundleEvent_Event_Succeeded.$_createMessage)
    ..aOM<WithdrawalBundleEvent_Event_Submitted>(3, _omitFieldNames ? '' : 'submitted',
        subBuilder: WithdrawalBundleEvent_Event_Submitted.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalBundleEvent_Event clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalBundleEvent_Event copyWith(void Function(WithdrawalBundleEvent_Event) updates) =>
      super.copyWith((message) => updates(message as WithdrawalBundleEvent_Event)) as WithdrawalBundleEvent_Event;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WithdrawalBundleEvent_Event() / WithdrawalBundleEvent_Event.new instead')
  static WithdrawalBundleEvent_Event create() => WithdrawalBundleEvent_Event._();
  static $pb.GeneratedMessage $_createMessage() => WithdrawalBundleEvent_Event._();
  @$core.override
  WithdrawalBundleEvent_Event createEmptyInstance() => WithdrawalBundleEvent_Event._();
  @$core.pragma('dart2js:noInline')
  static WithdrawalBundleEvent_Event getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WithdrawalBundleEvent_Event>(WithdrawalBundleEvent_Event.$_createMessage);
  static WithdrawalBundleEvent_Event? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  WithdrawalBundleEvent_Event_Event whichEvent() => _WithdrawalBundleEvent_Event_EventByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  void clearEvent() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  WithdrawalBundleEvent_Event_Failed get failed => $_getN(0);
  @$pb.TagNumber(1)
  set failed(WithdrawalBundleEvent_Event_Failed value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFailed() => $_has(0);
  @$pb.TagNumber(1)
  void clearFailed() => $_clearField(1);
  @$pb.TagNumber(1)
  WithdrawalBundleEvent_Event_Failed ensureFailed() => $_ensure(0);

  @$pb.TagNumber(2)
  WithdrawalBundleEvent_Event_Succeeded get succeeded => $_getN(1);
  @$pb.TagNumber(2)
  set succeeded(WithdrawalBundleEvent_Event_Succeeded value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSucceeded() => $_has(1);
  @$pb.TagNumber(2)
  void clearSucceeded() => $_clearField(2);
  @$pb.TagNumber(2)
  WithdrawalBundleEvent_Event_Succeeded ensureSucceeded() => $_ensure(1);

  @$pb.TagNumber(3)
  WithdrawalBundleEvent_Event_Submitted get submitted => $_getN(2);
  @$pb.TagNumber(3)
  set submitted(WithdrawalBundleEvent_Event_Submitted value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasSubmitted() => $_has(2);
  @$pb.TagNumber(3)
  void clearSubmitted() => $_clearField(3);
  @$pb.TagNumber(3)
  WithdrawalBundleEvent_Event_Submitted ensureSubmitted() => $_ensure(2);
}

class WithdrawalBundleEvent extends $pb.GeneratedMessage {
  factory WithdrawalBundleEvent({
    $0.ConsensusHex? m6id,
    WithdrawalBundleEvent_Event? event,
  }) {
    final result = WithdrawalBundleEvent._();
    if (m6id != null) result.m6id = m6id;
    if (event != null) result.event = event;
    return result;
  }

  WithdrawalBundleEvent._();

  factory WithdrawalBundleEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalBundleEvent()..mergeFromBuffer(data, registry);
  factory WithdrawalBundleEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalBundleEvent()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawalBundleEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: WithdrawalBundleEvent.$_createMessage)
    ..aOM<$0.ConsensusHex>(1, _omitFieldNames ? '' : 'm6id', subBuilder: $0.ConsensusHex.$_createMessage)
    ..aOM<WithdrawalBundleEvent_Event>(2, _omitFieldNames ? '' : 'event',
        subBuilder: WithdrawalBundleEvent_Event.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalBundleEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalBundleEvent copyWith(void Function(WithdrawalBundleEvent) updates) =>
      super.copyWith((message) => updates(message as WithdrawalBundleEvent)) as WithdrawalBundleEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WithdrawalBundleEvent() / WithdrawalBundleEvent.new instead')
  static WithdrawalBundleEvent create() => WithdrawalBundleEvent._();
  static $pb.GeneratedMessage $_createMessage() => WithdrawalBundleEvent._();
  @$core.override
  WithdrawalBundleEvent createEmptyInstance() => WithdrawalBundleEvent._();
  @$core.pragma('dart2js:noInline')
  static WithdrawalBundleEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WithdrawalBundleEvent>(WithdrawalBundleEvent.$_createMessage);
  static WithdrawalBundleEvent? _defaultInstance;

  @$pb.TagNumber(1)
  $0.ConsensusHex get m6id => $_getN(0);
  @$pb.TagNumber(1)
  set m6id($0.ConsensusHex value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasM6id() => $_has(0);
  @$pb.TagNumber(1)
  void clearM6id() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.ConsensusHex ensureM6id() => $_ensure(0);

  @$pb.TagNumber(2)
  WithdrawalBundleEvent_Event get event => $_getN(1);
  @$pb.TagNumber(2)
  set event(WithdrawalBundleEvent_Event value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasEvent() => $_has(1);
  @$pb.TagNumber(2)
  void clearEvent() => $_clearField(2);
  @$pb.TagNumber(2)
  WithdrawalBundleEvent_Event ensureEvent() => $_ensure(1);
}

enum BlockInfo_Event_Event { deposit, withdrawalBundle, notSet }

class BlockInfo_Event extends $pb.GeneratedMessage {
  factory BlockInfo_Event({
    Deposit? deposit,
    WithdrawalBundleEvent? withdrawalBundle,
  }) {
    final result = BlockInfo_Event._();
    if (deposit != null) result.deposit = deposit;
    if (withdrawalBundle != null) result.withdrawalBundle = withdrawalBundle;
    return result;
  }

  BlockInfo_Event._();

  factory BlockInfo_Event.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BlockInfo_Event()..mergeFromBuffer(data, registry);
  factory BlockInfo_Event.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BlockInfo_Event()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, BlockInfo_Event_Event> _BlockInfo_Event_EventByTag = {
    1: BlockInfo_Event_Event.deposit,
    2: BlockInfo_Event_Event.withdrawalBundle,
    0: BlockInfo_Event_Event.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BlockInfo.Event',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: BlockInfo_Event.$_createMessage)
    ..oo(0, [1, 2])
    ..aOM<Deposit>(1, _omitFieldNames ? '' : 'deposit', subBuilder: Deposit.$_createMessage)
    ..aOM<WithdrawalBundleEvent>(2, _omitFieldNames ? '' : 'withdrawalBundle',
        subBuilder: WithdrawalBundleEvent.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockInfo_Event clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockInfo_Event copyWith(void Function(BlockInfo_Event) updates) =>
      super.copyWith((message) => updates(message as BlockInfo_Event)) as BlockInfo_Event;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BlockInfo_Event() / BlockInfo_Event.new instead')
  static BlockInfo_Event create() => BlockInfo_Event._();
  static $pb.GeneratedMessage $_createMessage() => BlockInfo_Event._();
  @$core.override
  BlockInfo_Event createEmptyInstance() => BlockInfo_Event._();
  @$core.pragma('dart2js:noInline')
  static BlockInfo_Event getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BlockInfo_Event>(BlockInfo_Event.$_createMessage);
  static BlockInfo_Event? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  BlockInfo_Event_Event whichEvent() => _BlockInfo_Event_EventByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearEvent() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  Deposit get deposit => $_getN(0);
  @$pb.TagNumber(1)
  set deposit(Deposit value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDeposit() => $_has(0);
  @$pb.TagNumber(1)
  void clearDeposit() => $_clearField(1);
  @$pb.TagNumber(1)
  Deposit ensureDeposit() => $_ensure(0);

  @$pb.TagNumber(2)
  WithdrawalBundleEvent get withdrawalBundle => $_getN(1);
  @$pb.TagNumber(2)
  set withdrawalBundle(WithdrawalBundleEvent value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasWithdrawalBundle() => $_has(1);
  @$pb.TagNumber(2)
  void clearWithdrawalBundle() => $_clearField(2);
  @$pb.TagNumber(2)
  WithdrawalBundleEvent ensureWithdrawalBundle() => $_ensure(1);
}

/// Specific to an individual sidechain slot
class BlockInfo extends $pb.GeneratedMessage {
  factory BlockInfo({
    $0.ConsensusHex? bmmCommitment,
    $core.Iterable<BlockInfo_Event>? events,
  }) {
    final result = BlockInfo._();
    if (bmmCommitment != null) result.bmmCommitment = bmmCommitment;
    if (events != null) result.events.addAll(events);
    return result;
  }

  BlockInfo._();

  factory BlockInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BlockInfo()..mergeFromBuffer(data, registry);
  factory BlockInfo.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BlockInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BlockInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: BlockInfo.$_createMessage)
    ..aOM<$0.ConsensusHex>(1, _omitFieldNames ? '' : 'bmmCommitment', subBuilder: $0.ConsensusHex.$_createMessage)
    ..pPM<BlockInfo_Event>(2, _omitFieldNames ? '' : 'events', subBuilder: BlockInfo_Event.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockInfo copyWith(void Function(BlockInfo) updates) =>
      super.copyWith((message) => updates(message as BlockInfo)) as BlockInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BlockInfo() / BlockInfo.new instead')
  static BlockInfo create() => BlockInfo._();
  static $pb.GeneratedMessage $_createMessage() => BlockInfo._();
  @$core.override
  BlockInfo createEmptyInstance() => BlockInfo._();
  @$core.pragma('dart2js:noInline')
  static BlockInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BlockInfo>(BlockInfo.$_createMessage);
  static BlockInfo? _defaultInstance;

  /// repeated Deposit deposits = 1;
  /// repeated WithdrawalBundleEvent withdrawal_bundle_events = 2;
  @$pb.TagNumber(1)
  $0.ConsensusHex get bmmCommitment => $_getN(0);
  @$pb.TagNumber(1)
  set bmmCommitment($0.ConsensusHex value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBmmCommitment() => $_has(0);
  @$pb.TagNumber(1)
  void clearBmmCommitment() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.ConsensusHex ensureBmmCommitment() => $_ensure(0);

  @$pb.TagNumber(2)
  $pb.PbList<BlockInfo_Event> get events => $_getList(1);
}

class GetBlockHeaderInfoRequest extends $pb.GeneratedMessage {
  factory GetBlockHeaderInfoRequest({
    $0.ReverseHex? blockHash,
    $core.int? maxAncestors,
  }) {
    final result = GetBlockHeaderInfoRequest._();
    if (blockHash != null) result.blockHash = blockHash;
    if (maxAncestors != null) result.maxAncestors = maxAncestors;
    return result;
  }

  GetBlockHeaderInfoRequest._();

  factory GetBlockHeaderInfoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockHeaderInfoRequest()..mergeFromBuffer(data, registry);
  factory GetBlockHeaderInfoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockHeaderInfoRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockHeaderInfoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetBlockHeaderInfoRequest.$_createMessage)
    ..aOM<$0.ReverseHex>(1, _omitFieldNames ? '' : 'blockHash', subBuilder: $0.ReverseHex.$_createMessage)
    ..aI(2, _omitFieldNames ? '' : 'maxAncestors', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockHeaderInfoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockHeaderInfoRequest copyWith(void Function(GetBlockHeaderInfoRequest) updates) =>
      super.copyWith((message) => updates(message as GetBlockHeaderInfoRequest)) as GetBlockHeaderInfoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBlockHeaderInfoRequest() / GetBlockHeaderInfoRequest.new instead')
  static GetBlockHeaderInfoRequest create() => GetBlockHeaderInfoRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetBlockHeaderInfoRequest._();
  @$core.override
  GetBlockHeaderInfoRequest createEmptyInstance() => GetBlockHeaderInfoRequest._();
  @$core.pragma('dart2js:noInline')
  static GetBlockHeaderInfoRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBlockHeaderInfoRequest>(GetBlockHeaderInfoRequest.$_createMessage);
  static GetBlockHeaderInfoRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.ReverseHex get blockHash => $_getN(0);
  @$pb.TagNumber(1)
  set blockHash($0.ReverseHex value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBlockHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHash() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.ReverseHex ensureBlockHash() => $_ensure(0);

  /// Request block header info for up to `max_ancestors` ancestors.
  /// Fewer ancestors MAY be returned.
  @$pb.TagNumber(2)
  $core.int get maxAncestors => $_getIZ(1);
  @$pb.TagNumber(2)
  set maxAncestors($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMaxAncestors() => $_has(1);
  @$pb.TagNumber(2)
  void clearMaxAncestors() => $_clearField(2);
}

class GetBlockHeaderInfoResponse extends $pb.GeneratedMessage {
  factory GetBlockHeaderInfoResponse({
    $core.Iterable<BlockHeaderInfo>? headerInfos,
  }) {
    final result = GetBlockHeaderInfoResponse._();
    if (headerInfos != null) result.headerInfos.addAll(headerInfos);
    return result;
  }

  GetBlockHeaderInfoResponse._();

  factory GetBlockHeaderInfoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockHeaderInfoResponse()..mergeFromBuffer(data, registry);
  factory GetBlockHeaderInfoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockHeaderInfoResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockHeaderInfoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetBlockHeaderInfoResponse.$_createMessage)
    ..pPM<BlockHeaderInfo>(1, _omitFieldNames ? '' : 'headerInfos', subBuilder: BlockHeaderInfo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockHeaderInfoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockHeaderInfoResponse copyWith(void Function(GetBlockHeaderInfoResponse) updates) =>
      super.copyWith((message) => updates(message as GetBlockHeaderInfoResponse)) as GetBlockHeaderInfoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBlockHeaderInfoResponse() / GetBlockHeaderInfoResponse.new instead')
  static GetBlockHeaderInfoResponse create() => GetBlockHeaderInfoResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetBlockHeaderInfoResponse._();
  @$core.override
  GetBlockHeaderInfoResponse createEmptyInstance() => GetBlockHeaderInfoResponse._();
  @$core.pragma('dart2js:noInline')
  static GetBlockHeaderInfoResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBlockHeaderInfoResponse>(GetBlockHeaderInfoResponse.$_createMessage);
  static GetBlockHeaderInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<BlockHeaderInfo> get headerInfos => $_getList(0);
}

class GetBlockInfoRequest extends $pb.GeneratedMessage {
  factory GetBlockInfoRequest({
    $0.ReverseHex? blockHash,
    $1.UInt32Value? sidechainId,
    $core.int? maxAncestors,
  }) {
    final result = GetBlockInfoRequest._();
    if (blockHash != null) result.blockHash = blockHash;
    if (sidechainId != null) result.sidechainId = sidechainId;
    if (maxAncestors != null) result.maxAncestors = maxAncestors;
    return result;
  }

  GetBlockInfoRequest._();

  factory GetBlockInfoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockInfoRequest()..mergeFromBuffer(data, registry);
  factory GetBlockInfoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockInfoRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockInfoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetBlockInfoRequest.$_createMessage)
    ..aOM<$0.ReverseHex>(1, _omitFieldNames ? '' : 'blockHash', subBuilder: $0.ReverseHex.$_createMessage)
    ..aOM<$1.UInt32Value>(2, _omitFieldNames ? '' : 'sidechainId', subBuilder: $1.UInt32Value.$_createMessage)
    ..aI(3, _omitFieldNames ? '' : 'maxAncestors', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockInfoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockInfoRequest copyWith(void Function(GetBlockInfoRequest) updates) =>
      super.copyWith((message) => updates(message as GetBlockInfoRequest)) as GetBlockInfoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBlockInfoRequest() / GetBlockInfoRequest.new instead')
  static GetBlockInfoRequest create() => GetBlockInfoRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetBlockInfoRequest._();
  @$core.override
  GetBlockInfoRequest createEmptyInstance() => GetBlockInfoRequest._();
  @$core.pragma('dart2js:noInline')
  static GetBlockInfoRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBlockInfoRequest>(GetBlockInfoRequest.$_createMessage);
  static GetBlockInfoRequest? _defaultInstance;

  /// The block to fetch information about.
  @$pb.TagNumber(1)
  $0.ReverseHex get blockHash => $_getN(0);
  @$pb.TagNumber(1)
  set blockHash($0.ReverseHex value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBlockHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHash() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.ReverseHex ensureBlockHash() => $_ensure(0);

  /// The sidechain to filter for events relating to.
  @$pb.TagNumber(2)
  $1.UInt32Value get sidechainId => $_getN(1);
  @$pb.TagNumber(2)
  set sidechainId($1.UInt32Value value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSidechainId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSidechainId() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.UInt32Value ensureSidechainId() => $_ensure(1);

  /// Request block info for up to `max_ancestors` ancestors.
  /// Fewer ancestors MAY be returned.
  @$pb.TagNumber(3)
  $core.int get maxAncestors => $_getIZ(2);
  @$pb.TagNumber(3)
  set maxAncestors($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMaxAncestors() => $_has(2);
  @$pb.TagNumber(3)
  void clearMaxAncestors() => $_clearField(3);
}

class GetBlockInfoResponse_Info extends $pb.GeneratedMessage {
  factory GetBlockInfoResponse_Info({
    BlockHeaderInfo? headerInfo,
    BlockInfo? blockInfo,
  }) {
    final result = GetBlockInfoResponse_Info._();
    if (headerInfo != null) result.headerInfo = headerInfo;
    if (blockInfo != null) result.blockInfo = blockInfo;
    return result;
  }

  GetBlockInfoResponse_Info._();

  factory GetBlockInfoResponse_Info.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockInfoResponse_Info()..mergeFromBuffer(data, registry);
  factory GetBlockInfoResponse_Info.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockInfoResponse_Info()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockInfoResponse.Info',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetBlockInfoResponse_Info.$_createMessage)
    ..aOM<BlockHeaderInfo>(1, _omitFieldNames ? '' : 'headerInfo', subBuilder: BlockHeaderInfo.$_createMessage)
    ..aOM<BlockInfo>(2, _omitFieldNames ? '' : 'blockInfo', subBuilder: BlockInfo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockInfoResponse_Info clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockInfoResponse_Info copyWith(void Function(GetBlockInfoResponse_Info) updates) =>
      super.copyWith((message) => updates(message as GetBlockInfoResponse_Info)) as GetBlockInfoResponse_Info;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBlockInfoResponse_Info() / GetBlockInfoResponse_Info.new instead')
  static GetBlockInfoResponse_Info create() => GetBlockInfoResponse_Info._();
  static $pb.GeneratedMessage $_createMessage() => GetBlockInfoResponse_Info._();
  @$core.override
  GetBlockInfoResponse_Info createEmptyInstance() => GetBlockInfoResponse_Info._();
  @$core.pragma('dart2js:noInline')
  static GetBlockInfoResponse_Info getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBlockInfoResponse_Info>(GetBlockInfoResponse_Info.$_createMessage);
  static GetBlockInfoResponse_Info? _defaultInstance;

  /// Information about the block itself.
  @$pb.TagNumber(1)
  BlockHeaderInfo get headerInfo => $_getN(0);
  @$pb.TagNumber(1)
  set headerInfo(BlockHeaderInfo value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasHeaderInfo() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeaderInfo() => $_clearField(1);
  @$pb.TagNumber(1)
  BlockHeaderInfo ensureHeaderInfo() => $_ensure(0);

  /// Information about the block, filtered for events relating to a specific
  /// sidechain.
  @$pb.TagNumber(2)
  BlockInfo get blockInfo => $_getN(1);
  @$pb.TagNumber(2)
  set blockInfo(BlockInfo value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasBlockInfo() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlockInfo() => $_clearField(2);
  @$pb.TagNumber(2)
  BlockInfo ensureBlockInfo() => $_ensure(1);
}

class GetBlockInfoResponse extends $pb.GeneratedMessage {
  factory GetBlockInfoResponse({
    $core.Iterable<GetBlockInfoResponse_Info>? infos,
  }) {
    final result = GetBlockInfoResponse._();
    if (infos != null) result.infos.addAll(infos);
    return result;
  }

  GetBlockInfoResponse._();

  factory GetBlockInfoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockInfoResponse()..mergeFromBuffer(data, registry);
  factory GetBlockInfoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockInfoResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockInfoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetBlockInfoResponse.$_createMessage)
    ..pPM<GetBlockInfoResponse_Info>(1, _omitFieldNames ? '' : 'infos',
        subBuilder: GetBlockInfoResponse_Info.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockInfoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockInfoResponse copyWith(void Function(GetBlockInfoResponse) updates) =>
      super.copyWith((message) => updates(message as GetBlockInfoResponse)) as GetBlockInfoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBlockInfoResponse() / GetBlockInfoResponse.new instead')
  static GetBlockInfoResponse create() => GetBlockInfoResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetBlockInfoResponse._();
  @$core.override
  GetBlockInfoResponse createEmptyInstance() => GetBlockInfoResponse._();
  @$core.pragma('dart2js:noInline')
  static GetBlockInfoResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBlockInfoResponse>(GetBlockInfoResponse.$_createMessage);
  static GetBlockInfoResponse? _defaultInstance;

  /// Empty if the requested block was not found.
  /// Ancestors MUST be sorted newest-first.
  @$pb.TagNumber(1)
  $pb.PbList<GetBlockInfoResponse_Info> get infos => $_getList(0);
}

class GetBmmHStarCommitmentRequest extends $pb.GeneratedMessage {
  factory GetBmmHStarCommitmentRequest({
    $0.ReverseHex? blockHash,
    $1.UInt32Value? sidechainId,
    $core.int? maxAncestors,
  }) {
    final result = GetBmmHStarCommitmentRequest._();
    if (blockHash != null) result.blockHash = blockHash;
    if (sidechainId != null) result.sidechainId = sidechainId;
    if (maxAncestors != null) result.maxAncestors = maxAncestors;
    return result;
  }

  GetBmmHStarCommitmentRequest._();

  factory GetBmmHStarCommitmentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBmmHStarCommitmentRequest()..mergeFromBuffer(data, registry);
  factory GetBmmHStarCommitmentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBmmHStarCommitmentRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBmmHStarCommitmentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetBmmHStarCommitmentRequest.$_createMessage)
    ..aOM<$0.ReverseHex>(1, _omitFieldNames ? '' : 'blockHash', subBuilder: $0.ReverseHex.$_createMessage)
    ..aOM<$1.UInt32Value>(2, _omitFieldNames ? '' : 'sidechainId', subBuilder: $1.UInt32Value.$_createMessage)
    ..aI(3, _omitFieldNames ? '' : 'maxAncestors', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBmmHStarCommitmentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBmmHStarCommitmentRequest copyWith(void Function(GetBmmHStarCommitmentRequest) updates) =>
      super.copyWith((message) => updates(message as GetBmmHStarCommitmentRequest)) as GetBmmHStarCommitmentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBmmHStarCommitmentRequest() / GetBmmHStarCommitmentRequest.new instead')
  static GetBmmHStarCommitmentRequest create() => GetBmmHStarCommitmentRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetBmmHStarCommitmentRequest._();
  @$core.override
  GetBmmHStarCommitmentRequest createEmptyInstance() => GetBmmHStarCommitmentRequest._();
  @$core.pragma('dart2js:noInline')
  static GetBmmHStarCommitmentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBmmHStarCommitmentRequest>(GetBmmHStarCommitmentRequest.$_createMessage);
  static GetBmmHStarCommitmentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.ReverseHex get blockHash => $_getN(0);
  @$pb.TagNumber(1)
  set blockHash($0.ReverseHex value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBlockHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHash() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.ReverseHex ensureBlockHash() => $_ensure(0);

  @$pb.TagNumber(2)
  $1.UInt32Value get sidechainId => $_getN(1);
  @$pb.TagNumber(2)
  set sidechainId($1.UInt32Value value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasSidechainId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSidechainId() => $_clearField(2);
  @$pb.TagNumber(2)
  $1.UInt32Value ensureSidechainId() => $_ensure(1);

  /// Request commitments for up to `max_ancestors` ancestors.
  /// Fewer ancestors MAY be returned.
  @$pb.TagNumber(3)
  $core.int get maxAncestors => $_getIZ(2);
  @$pb.TagNumber(3)
  set maxAncestors($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMaxAncestors() => $_has(2);
  @$pb.TagNumber(3)
  void clearMaxAncestors() => $_clearField(3);
}

class GetBmmHStarCommitmentResponse_BlockNotFoundError extends $pb.GeneratedMessage {
  factory GetBmmHStarCommitmentResponse_BlockNotFoundError({
    $0.ReverseHex? blockHash,
  }) {
    final result = GetBmmHStarCommitmentResponse_BlockNotFoundError._();
    if (blockHash != null) result.blockHash = blockHash;
    return result;
  }

  GetBmmHStarCommitmentResponse_BlockNotFoundError._();

  factory GetBmmHStarCommitmentResponse_BlockNotFoundError.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBmmHStarCommitmentResponse_BlockNotFoundError()..mergeFromBuffer(data, registry);
  factory GetBmmHStarCommitmentResponse_BlockNotFoundError.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBmmHStarCommitmentResponse_BlockNotFoundError()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetBmmHStarCommitmentResponse.BlockNotFoundError',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetBmmHStarCommitmentResponse_BlockNotFoundError.$_createMessage)
    ..aOM<$0.ReverseHex>(1, _omitFieldNames ? '' : 'blockHash', subBuilder: $0.ReverseHex.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBmmHStarCommitmentResponse_BlockNotFoundError clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBmmHStarCommitmentResponse_BlockNotFoundError copyWith(
          void Function(GetBmmHStarCommitmentResponse_BlockNotFoundError) updates) =>
      super.copyWith((message) => updates(message as GetBmmHStarCommitmentResponse_BlockNotFoundError))
          as GetBmmHStarCommitmentResponse_BlockNotFoundError;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetBmmHStarCommitmentResponse_BlockNotFoundError() / GetBmmHStarCommitmentResponse_BlockNotFoundError.new instead')
  static GetBmmHStarCommitmentResponse_BlockNotFoundError create() =>
      GetBmmHStarCommitmentResponse_BlockNotFoundError._();
  static $pb.GeneratedMessage $_createMessage() => GetBmmHStarCommitmentResponse_BlockNotFoundError._();
  @$core.override
  GetBmmHStarCommitmentResponse_BlockNotFoundError createEmptyInstance() =>
      GetBmmHStarCommitmentResponse_BlockNotFoundError._();
  @$core.pragma('dart2js:noInline')
  static GetBmmHStarCommitmentResponse_BlockNotFoundError getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBmmHStarCommitmentResponse_BlockNotFoundError>(
          GetBmmHStarCommitmentResponse_BlockNotFoundError.$_createMessage);
  static GetBmmHStarCommitmentResponse_BlockNotFoundError? _defaultInstance;

  @$pb.TagNumber(1)
  $0.ReverseHex get blockHash => $_getN(0);
  @$pb.TagNumber(1)
  set blockHash($0.ReverseHex value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBlockHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHash() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.ReverseHex ensureBlockHash() => $_ensure(0);
}

class GetBmmHStarCommitmentResponse_OptionalCommitment extends $pb.GeneratedMessage {
  factory GetBmmHStarCommitmentResponse_OptionalCommitment({
    $0.ConsensusHex? commitment,
  }) {
    final result = GetBmmHStarCommitmentResponse_OptionalCommitment._();
    if (commitment != null) result.commitment = commitment;
    return result;
  }

  GetBmmHStarCommitmentResponse_OptionalCommitment._();

  factory GetBmmHStarCommitmentResponse_OptionalCommitment.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBmmHStarCommitmentResponse_OptionalCommitment()..mergeFromBuffer(data, registry);
  factory GetBmmHStarCommitmentResponse_OptionalCommitment.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBmmHStarCommitmentResponse_OptionalCommitment()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetBmmHStarCommitmentResponse.OptionalCommitment',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetBmmHStarCommitmentResponse_OptionalCommitment.$_createMessage)
    ..aOM<$0.ConsensusHex>(1, _omitFieldNames ? '' : 'commitment', subBuilder: $0.ConsensusHex.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBmmHStarCommitmentResponse_OptionalCommitment clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBmmHStarCommitmentResponse_OptionalCommitment copyWith(
          void Function(GetBmmHStarCommitmentResponse_OptionalCommitment) updates) =>
      super.copyWith((message) => updates(message as GetBmmHStarCommitmentResponse_OptionalCommitment))
          as GetBmmHStarCommitmentResponse_OptionalCommitment;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetBmmHStarCommitmentResponse_OptionalCommitment() / GetBmmHStarCommitmentResponse_OptionalCommitment.new instead')
  static GetBmmHStarCommitmentResponse_OptionalCommitment create() =>
      GetBmmHStarCommitmentResponse_OptionalCommitment._();
  static $pb.GeneratedMessage $_createMessage() => GetBmmHStarCommitmentResponse_OptionalCommitment._();
  @$core.override
  GetBmmHStarCommitmentResponse_OptionalCommitment createEmptyInstance() =>
      GetBmmHStarCommitmentResponse_OptionalCommitment._();
  @$core.pragma('dart2js:noInline')
  static GetBmmHStarCommitmentResponse_OptionalCommitment getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBmmHStarCommitmentResponse_OptionalCommitment>(
          GetBmmHStarCommitmentResponse_OptionalCommitment.$_createMessage);
  static GetBmmHStarCommitmentResponse_OptionalCommitment? _defaultInstance;

  @$pb.TagNumber(1)
  $0.ConsensusHex get commitment => $_getN(0);
  @$pb.TagNumber(1)
  set commitment($0.ConsensusHex value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCommitment() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommitment() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.ConsensusHex ensureCommitment() => $_ensure(0);
}

class GetBmmHStarCommitmentResponse_Commitment extends $pb.GeneratedMessage {
  factory GetBmmHStarCommitmentResponse_Commitment({
    $0.ConsensusHex? commitment,
    $core.Iterable<GetBmmHStarCommitmentResponse_OptionalCommitment>? ancestorCommitments,
  }) {
    final result = GetBmmHStarCommitmentResponse_Commitment._();
    if (commitment != null) result.commitment = commitment;
    if (ancestorCommitments != null) result.ancestorCommitments.addAll(ancestorCommitments);
    return result;
  }

  GetBmmHStarCommitmentResponse_Commitment._();

  factory GetBmmHStarCommitmentResponse_Commitment.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBmmHStarCommitmentResponse_Commitment()..mergeFromBuffer(data, registry);
  factory GetBmmHStarCommitmentResponse_Commitment.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBmmHStarCommitmentResponse_Commitment()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBmmHStarCommitmentResponse.Commitment',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetBmmHStarCommitmentResponse_Commitment.$_createMessage)
    ..aOM<$0.ConsensusHex>(1, _omitFieldNames ? '' : 'commitment', subBuilder: $0.ConsensusHex.$_createMessage)
    ..pPM<GetBmmHStarCommitmentResponse_OptionalCommitment>(2, _omitFieldNames ? '' : 'ancestorCommitments',
        subBuilder: GetBmmHStarCommitmentResponse_OptionalCommitment.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBmmHStarCommitmentResponse_Commitment clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBmmHStarCommitmentResponse_Commitment copyWith(void Function(GetBmmHStarCommitmentResponse_Commitment) updates) =>
      super.copyWith((message) => updates(message as GetBmmHStarCommitmentResponse_Commitment))
          as GetBmmHStarCommitmentResponse_Commitment;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetBmmHStarCommitmentResponse_Commitment() / GetBmmHStarCommitmentResponse_Commitment.new instead')
  static GetBmmHStarCommitmentResponse_Commitment create() => GetBmmHStarCommitmentResponse_Commitment._();
  static $pb.GeneratedMessage $_createMessage() => GetBmmHStarCommitmentResponse_Commitment._();
  @$core.override
  GetBmmHStarCommitmentResponse_Commitment createEmptyInstance() => GetBmmHStarCommitmentResponse_Commitment._();
  @$core.pragma('dart2js:noInline')
  static GetBmmHStarCommitmentResponse_Commitment getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBmmHStarCommitmentResponse_Commitment>(
          GetBmmHStarCommitmentResponse_Commitment.$_createMessage);
  static GetBmmHStarCommitmentResponse_Commitment? _defaultInstance;

  @$pb.TagNumber(1)
  $0.ConsensusHex get commitment => $_getN(0);
  @$pb.TagNumber(1)
  set commitment($0.ConsensusHex value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCommitment() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommitment() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.ConsensusHex ensureCommitment() => $_ensure(0);

  /// Ancestors MUST be sorted newest-first
  @$pb.TagNumber(2)
  $pb.PbList<GetBmmHStarCommitmentResponse_OptionalCommitment> get ancestorCommitments => $_getList(1);
}

enum GetBmmHStarCommitmentResponse_Result { blockNotFound, commitment, notSet }

class GetBmmHStarCommitmentResponse extends $pb.GeneratedMessage {
  factory GetBmmHStarCommitmentResponse({
    GetBmmHStarCommitmentResponse_BlockNotFoundError? blockNotFound,
    GetBmmHStarCommitmentResponse_Commitment? commitment,
  }) {
    final result = GetBmmHStarCommitmentResponse._();
    if (blockNotFound != null) result.blockNotFound = blockNotFound;
    if (commitment != null) result.commitment = commitment;
    return result;
  }

  GetBmmHStarCommitmentResponse._();

  factory GetBmmHStarCommitmentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBmmHStarCommitmentResponse()..mergeFromBuffer(data, registry);
  factory GetBmmHStarCommitmentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBmmHStarCommitmentResponse()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, GetBmmHStarCommitmentResponse_Result> _GetBmmHStarCommitmentResponse_ResultByTag = {
    1: GetBmmHStarCommitmentResponse_Result.blockNotFound,
    2: GetBmmHStarCommitmentResponse_Result.commitment,
    0: GetBmmHStarCommitmentResponse_Result.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBmmHStarCommitmentResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetBmmHStarCommitmentResponse.$_createMessage)
    ..oo(0, [1, 2])
    ..aOM<GetBmmHStarCommitmentResponse_BlockNotFoundError>(1, _omitFieldNames ? '' : 'blockNotFound',
        subBuilder: GetBmmHStarCommitmentResponse_BlockNotFoundError.$_createMessage)
    ..aOM<GetBmmHStarCommitmentResponse_Commitment>(2, _omitFieldNames ? '' : 'commitment',
        subBuilder: GetBmmHStarCommitmentResponse_Commitment.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBmmHStarCommitmentResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBmmHStarCommitmentResponse copyWith(void Function(GetBmmHStarCommitmentResponse) updates) =>
      super.copyWith((message) => updates(message as GetBmmHStarCommitmentResponse)) as GetBmmHStarCommitmentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBmmHStarCommitmentResponse() / GetBmmHStarCommitmentResponse.new instead')
  static GetBmmHStarCommitmentResponse create() => GetBmmHStarCommitmentResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetBmmHStarCommitmentResponse._();
  @$core.override
  GetBmmHStarCommitmentResponse createEmptyInstance() => GetBmmHStarCommitmentResponse._();
  @$core.pragma('dart2js:noInline')
  static GetBmmHStarCommitmentResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBmmHStarCommitmentResponse>(GetBmmHStarCommitmentResponse.$_createMessage);
  static GetBmmHStarCommitmentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  GetBmmHStarCommitmentResponse_Result whichResult() => _GetBmmHStarCommitmentResponse_ResultByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearResult() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  GetBmmHStarCommitmentResponse_BlockNotFoundError get blockNotFound => $_getN(0);
  @$pb.TagNumber(1)
  set blockNotFound(GetBmmHStarCommitmentResponse_BlockNotFoundError value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBlockNotFound() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockNotFound() => $_clearField(1);
  @$pb.TagNumber(1)
  GetBmmHStarCommitmentResponse_BlockNotFoundError ensureBlockNotFound() => $_ensure(0);

  @$pb.TagNumber(2)
  GetBmmHStarCommitmentResponse_Commitment get commitment => $_getN(1);
  @$pb.TagNumber(2)
  set commitment(GetBmmHStarCommitmentResponse_Commitment value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasCommitment() => $_has(1);
  @$pb.TagNumber(2)
  void clearCommitment() => $_clearField(2);
  @$pb.TagNumber(2)
  GetBmmHStarCommitmentResponse_Commitment ensureCommitment() => $_ensure(1);
}

class GetChainInfoRequest extends $pb.GeneratedMessage {
  factory GetChainInfoRequest() => GetChainInfoRequest._();

  GetChainInfoRequest._();

  factory GetChainInfoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetChainInfoRequest()..mergeFromBuffer(data, registry);
  factory GetChainInfoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetChainInfoRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetChainInfoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetChainInfoRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChainInfoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChainInfoRequest copyWith(void Function(GetChainInfoRequest) updates) =>
      super.copyWith((message) => updates(message as GetChainInfoRequest)) as GetChainInfoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetChainInfoRequest() / GetChainInfoRequest.new instead')
  static GetChainInfoRequest create() => GetChainInfoRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetChainInfoRequest._();
  @$core.override
  GetChainInfoRequest createEmptyInstance() => GetChainInfoRequest._();
  @$core.pragma('dart2js:noInline')
  static GetChainInfoRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetChainInfoRequest>(GetChainInfoRequest.$_createMessage);
  static GetChainInfoRequest? _defaultInstance;
}

class GetChainInfoResponse_Bip300Constants extends $pb.GeneratedMessage {
  factory GetChainInfoResponse_Bip300Constants({
    $core.int? withdrawalBundleMaxAge,
    $core.int? withdrawalBundleInclusionThreshold,
    $core.int? usedSidechainSlotProposalMaxAge,
    $core.int? usedSidechainSlotActivationThreshold,
    $core.int? unusedSidechainSlotProposalMaxAge,
    $core.int? unusedSidechainSlotActivationThreshold,
    $core.int? activationHeight,
  }) {
    final result = GetChainInfoResponse_Bip300Constants._();
    if (withdrawalBundleMaxAge != null) result.withdrawalBundleMaxAge = withdrawalBundleMaxAge;
    if (withdrawalBundleInclusionThreshold != null)
      result.withdrawalBundleInclusionThreshold = withdrawalBundleInclusionThreshold;
    if (usedSidechainSlotProposalMaxAge != null)
      result.usedSidechainSlotProposalMaxAge = usedSidechainSlotProposalMaxAge;
    if (usedSidechainSlotActivationThreshold != null)
      result.usedSidechainSlotActivationThreshold = usedSidechainSlotActivationThreshold;
    if (unusedSidechainSlotProposalMaxAge != null)
      result.unusedSidechainSlotProposalMaxAge = unusedSidechainSlotProposalMaxAge;
    if (unusedSidechainSlotActivationThreshold != null)
      result.unusedSidechainSlotActivationThreshold = unusedSidechainSlotActivationThreshold;
    if (activationHeight != null) result.activationHeight = activationHeight;
    return result;
  }

  GetChainInfoResponse_Bip300Constants._();

  factory GetChainInfoResponse_Bip300Constants.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetChainInfoResponse_Bip300Constants()..mergeFromBuffer(data, registry);
  factory GetChainInfoResponse_Bip300Constants.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetChainInfoResponse_Bip300Constants()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetChainInfoResponse.Bip300Constants',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetChainInfoResponse_Bip300Constants.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'withdrawalBundleMaxAge', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'withdrawalBundleInclusionThreshold', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'usedSidechainSlotProposalMaxAge', fieldType: $pb.PbFieldType.OU3)
    ..aI(4, _omitFieldNames ? '' : 'usedSidechainSlotActivationThreshold', fieldType: $pb.PbFieldType.OU3)
    ..aI(5, _omitFieldNames ? '' : 'unusedSidechainSlotProposalMaxAge', fieldType: $pb.PbFieldType.OU3)
    ..aI(6, _omitFieldNames ? '' : 'unusedSidechainSlotActivationThreshold', fieldType: $pb.PbFieldType.OU3)
    ..aI(7, _omitFieldNames ? '' : 'activationHeight', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChainInfoResponse_Bip300Constants clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChainInfoResponse_Bip300Constants copyWith(void Function(GetChainInfoResponse_Bip300Constants) updates) =>
      super.copyWith((message) => updates(message as GetChainInfoResponse_Bip300Constants))
          as GetChainInfoResponse_Bip300Constants;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetChainInfoResponse_Bip300Constants() / GetChainInfoResponse_Bip300Constants.new instead')
  static GetChainInfoResponse_Bip300Constants create() => GetChainInfoResponse_Bip300Constants._();
  static $pb.GeneratedMessage $_createMessage() => GetChainInfoResponse_Bip300Constants._();
  @$core.override
  GetChainInfoResponse_Bip300Constants createEmptyInstance() => GetChainInfoResponse_Bip300Constants._();
  @$core.pragma('dart2js:noInline')
  static GetChainInfoResponse_Bip300Constants getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetChainInfoResponse_Bip300Constants>(
          GetChainInfoResponse_Bip300Constants.$_createMessage);
  static GetChainInfoResponse_Bip300Constants? _defaultInstance;

  /// Maximum age (in mainchain blocks) of a withdrawal bundle before it is
  /// considered failed.
  @$pb.TagNumber(1)
  $core.int get withdrawalBundleMaxAge => $_getIZ(0);
  @$pb.TagNumber(1)
  set withdrawalBundleMaxAge($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWithdrawalBundleMaxAge() => $_has(0);
  @$pb.TagNumber(1)
  void clearWithdrawalBundleMaxAge() => $_clearField(1);

  /// Number of mainchain blocks within `withdrawal_bundle_max_age` that a
  /// withdrawal bundle must be included in to succeed.
  @$pb.TagNumber(2)
  $core.int get withdrawalBundleInclusionThreshold => $_getIZ(1);
  @$pb.TagNumber(2)
  set withdrawalBundleInclusionThreshold($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWithdrawalBundleInclusionThreshold() => $_has(1);
  @$pb.TagNumber(2)
  void clearWithdrawalBundleInclusionThreshold() => $_clearField(2);

  /// Maximum age (in mainchain blocks) of a proposal for an already-used
  /// sidechain slot before it expires.
  @$pb.TagNumber(3)
  $core.int get usedSidechainSlotProposalMaxAge => $_getIZ(2);
  @$pb.TagNumber(3)
  set usedSidechainSlotProposalMaxAge($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUsedSidechainSlotProposalMaxAge() => $_has(2);
  @$pb.TagNumber(3)
  void clearUsedSidechainSlotProposalMaxAge() => $_clearField(3);

  /// Number of votes required to activate a proposal for an already-used
  /// sidechain slot.
  @$pb.TagNumber(4)
  $core.int get usedSidechainSlotActivationThreshold => $_getIZ(3);
  @$pb.TagNumber(4)
  set usedSidechainSlotActivationThreshold($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUsedSidechainSlotActivationThreshold() => $_has(3);
  @$pb.TagNumber(4)
  void clearUsedSidechainSlotActivationThreshold() => $_clearField(4);

  /// Maximum age (in mainchain blocks) of a proposal for an unused sidechain
  /// slot before it expires.
  @$pb.TagNumber(5)
  $core.int get unusedSidechainSlotProposalMaxAge => $_getIZ(4);
  @$pb.TagNumber(5)
  set unusedSidechainSlotProposalMaxAge($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUnusedSidechainSlotProposalMaxAge() => $_has(4);
  @$pb.TagNumber(5)
  void clearUnusedSidechainSlotProposalMaxAge() => $_clearField(5);

  /// Number of votes required to activate a proposal for an unused sidechain
  /// slot.
  @$pb.TagNumber(6)
  $core.int get unusedSidechainSlotActivationThreshold => $_getIZ(5);
  @$pb.TagNumber(6)
  set unusedSidechainSlotActivationThreshold($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUnusedSidechainSlotActivationThreshold() => $_has(5);
  @$pb.TagNumber(6)
  void clearUnusedSidechainSlotActivationThreshold() => $_clearField(6);

  /// Height at which enforcement activates. Blocks below this
  /// height are plain Bitcoin history and are not scanned for BIP300
  /// messages or deposits. 0 means enforced from genesis.
  @$pb.TagNumber(7)
  $core.int get activationHeight => $_getIZ(6);
  @$pb.TagNumber(7)
  set activationHeight($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasActivationHeight() => $_has(6);
  @$pb.TagNumber(7)
  void clearActivationHeight() => $_clearField(7);
}

class GetChainInfoResponse extends $pb.GeneratedMessage {
  factory GetChainInfoResponse({
    Network? network,
    GetChainInfoResponse_Bip300Constants? bip300Constants,
  }) {
    final result = GetChainInfoResponse._();
    if (network != null) result.network = network;
    if (bip300Constants != null) result.bip300Constants = bip300Constants;
    return result;
  }

  GetChainInfoResponse._();

  factory GetChainInfoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetChainInfoResponse()..mergeFromBuffer(data, registry);
  factory GetChainInfoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetChainInfoResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetChainInfoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetChainInfoResponse.$_createMessage)
    ..aE<Network>(1, _omitFieldNames ? '' : 'network', enumValues: Network.values)
    ..aOM<GetChainInfoResponse_Bip300Constants>(2, _omitFieldNames ? '' : 'bip300Constants',
        subBuilder: GetChainInfoResponse_Bip300Constants.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChainInfoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChainInfoResponse copyWith(void Function(GetChainInfoResponse) updates) =>
      super.copyWith((message) => updates(message as GetChainInfoResponse)) as GetChainInfoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetChainInfoResponse() / GetChainInfoResponse.new instead')
  static GetChainInfoResponse create() => GetChainInfoResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetChainInfoResponse._();
  @$core.override
  GetChainInfoResponse createEmptyInstance() => GetChainInfoResponse._();
  @$core.pragma('dart2js:noInline')
  static GetChainInfoResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetChainInfoResponse>(GetChainInfoResponse.$_createMessage);
  static GetChainInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Network get network => $_getN(0);
  @$pb.TagNumber(1)
  set network(Network value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasNetwork() => $_has(0);
  @$pb.TagNumber(1)
  void clearNetwork() => $_clearField(1);

  /// BIP300 consensus constants for the active network.
  @$pb.TagNumber(2)
  GetChainInfoResponse_Bip300Constants get bip300Constants => $_getN(1);
  @$pb.TagNumber(2)
  set bip300Constants(GetChainInfoResponse_Bip300Constants value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasBip300Constants() => $_has(1);
  @$pb.TagNumber(2)
  void clearBip300Constants() => $_clearField(2);
  @$pb.TagNumber(2)
  GetChainInfoResponse_Bip300Constants ensureBip300Constants() => $_ensure(1);
}

class GetChainTipRequest extends $pb.GeneratedMessage {
  factory GetChainTipRequest() => GetChainTipRequest._();

  GetChainTipRequest._();

  factory GetChainTipRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetChainTipRequest()..mergeFromBuffer(data, registry);
  factory GetChainTipRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetChainTipRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetChainTipRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetChainTipRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChainTipRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChainTipRequest copyWith(void Function(GetChainTipRequest) updates) =>
      super.copyWith((message) => updates(message as GetChainTipRequest)) as GetChainTipRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetChainTipRequest() / GetChainTipRequest.new instead')
  static GetChainTipRequest create() => GetChainTipRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetChainTipRequest._();
  @$core.override
  GetChainTipRequest createEmptyInstance() => GetChainTipRequest._();
  @$core.pragma('dart2js:noInline')
  static GetChainTipRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetChainTipRequest>(GetChainTipRequest.$_createMessage);
  static GetChainTipRequest? _defaultInstance;
}

class GetChainTipResponse extends $pb.GeneratedMessage {
  factory GetChainTipResponse({
    BlockHeaderInfo? blockHeaderInfo,
  }) {
    final result = GetChainTipResponse._();
    if (blockHeaderInfo != null) result.blockHeaderInfo = blockHeaderInfo;
    return result;
  }

  GetChainTipResponse._();

  factory GetChainTipResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetChainTipResponse()..mergeFromBuffer(data, registry);
  factory GetChainTipResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetChainTipResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetChainTipResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetChainTipResponse.$_createMessage)
    ..aOM<BlockHeaderInfo>(1, _omitFieldNames ? '' : 'blockHeaderInfo', subBuilder: BlockHeaderInfo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChainTipResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetChainTipResponse copyWith(void Function(GetChainTipResponse) updates) =>
      super.copyWith((message) => updates(message as GetChainTipResponse)) as GetChainTipResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetChainTipResponse() / GetChainTipResponse.new instead')
  static GetChainTipResponse create() => GetChainTipResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetChainTipResponse._();
  @$core.override
  GetChainTipResponse createEmptyInstance() => GetChainTipResponse._();
  @$core.pragma('dart2js:noInline')
  static GetChainTipResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetChainTipResponse>(GetChainTipResponse.$_createMessage);
  static GetChainTipResponse? _defaultInstance;

  @$pb.TagNumber(1)
  BlockHeaderInfo get blockHeaderInfo => $_getN(0);
  @$pb.TagNumber(1)
  set blockHeaderInfo(BlockHeaderInfo value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBlockHeaderInfo() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHeaderInfo() => $_clearField(1);
  @$pb.TagNumber(1)
  BlockHeaderInfo ensureBlockHeaderInfo() => $_ensure(0);
}

class GetCoinbasePSBTRequest_ProposeSidechain extends $pb.GeneratedMessage {
  factory GetCoinbasePSBTRequest_ProposeSidechain({
    $1.UInt32Value? sidechainNumber,
    $0.ConsensusHex? data,
  }) {
    final result = GetCoinbasePSBTRequest_ProposeSidechain._();
    if (sidechainNumber != null) result.sidechainNumber = sidechainNumber;
    if (data != null) result.data = data;
    return result;
  }

  GetCoinbasePSBTRequest_ProposeSidechain._();

  factory GetCoinbasePSBTRequest_ProposeSidechain.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCoinbasePSBTRequest_ProposeSidechain()..mergeFromBuffer(data, registry);
  factory GetCoinbasePSBTRequest_ProposeSidechain.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCoinbasePSBTRequest_ProposeSidechain()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCoinbasePSBTRequest.ProposeSidechain',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetCoinbasePSBTRequest_ProposeSidechain.$_createMessage)
    ..aOM<$1.UInt32Value>(1, _omitFieldNames ? '' : 'sidechainNumber', subBuilder: $1.UInt32Value.$_createMessage)
    ..aOM<$0.ConsensusHex>(2, _omitFieldNames ? '' : 'data', subBuilder: $0.ConsensusHex.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCoinbasePSBTRequest_ProposeSidechain clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCoinbasePSBTRequest_ProposeSidechain copyWith(void Function(GetCoinbasePSBTRequest_ProposeSidechain) updates) =>
      super.copyWith((message) => updates(message as GetCoinbasePSBTRequest_ProposeSidechain))
          as GetCoinbasePSBTRequest_ProposeSidechain;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core
      .Deprecated('Use GetCoinbasePSBTRequest_ProposeSidechain() / GetCoinbasePSBTRequest_ProposeSidechain.new instead')
  static GetCoinbasePSBTRequest_ProposeSidechain create() => GetCoinbasePSBTRequest_ProposeSidechain._();
  static $pb.GeneratedMessage $_createMessage() => GetCoinbasePSBTRequest_ProposeSidechain._();
  @$core.override
  GetCoinbasePSBTRequest_ProposeSidechain createEmptyInstance() => GetCoinbasePSBTRequest_ProposeSidechain._();
  @$core.pragma('dart2js:noInline')
  static GetCoinbasePSBTRequest_ProposeSidechain getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCoinbasePSBTRequest_ProposeSidechain>(
          GetCoinbasePSBTRequest_ProposeSidechain.$_createMessage);
  static GetCoinbasePSBTRequest_ProposeSidechain? _defaultInstance;

  @$pb.TagNumber(1)
  $1.UInt32Value get sidechainNumber => $_getN(0);
  @$pb.TagNumber(1)
  set sidechainNumber($1.UInt32Value value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSidechainNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainNumber() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.UInt32Value ensureSidechainNumber() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.ConsensusHex get data => $_getN(1);
  @$pb.TagNumber(2)
  set data($0.ConsensusHex value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.ConsensusHex ensureData() => $_ensure(1);
}

class GetCoinbasePSBTRequest_AckSidechain extends $pb.GeneratedMessage {
  factory GetCoinbasePSBTRequest_AckSidechain({
    $1.UInt32Value? sidechainNumber,
    $0.ConsensusHex? dataHash,
  }) {
    final result = GetCoinbasePSBTRequest_AckSidechain._();
    if (sidechainNumber != null) result.sidechainNumber = sidechainNumber;
    if (dataHash != null) result.dataHash = dataHash;
    return result;
  }

  GetCoinbasePSBTRequest_AckSidechain._();

  factory GetCoinbasePSBTRequest_AckSidechain.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCoinbasePSBTRequest_AckSidechain()..mergeFromBuffer(data, registry);
  factory GetCoinbasePSBTRequest_AckSidechain.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCoinbasePSBTRequest_AckSidechain()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCoinbasePSBTRequest.AckSidechain',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetCoinbasePSBTRequest_AckSidechain.$_createMessage)
    ..aOM<$1.UInt32Value>(1, _omitFieldNames ? '' : 'sidechainNumber', subBuilder: $1.UInt32Value.$_createMessage)
    ..aOM<$0.ConsensusHex>(2, _omitFieldNames ? '' : 'dataHash', subBuilder: $0.ConsensusHex.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCoinbasePSBTRequest_AckSidechain clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCoinbasePSBTRequest_AckSidechain copyWith(void Function(GetCoinbasePSBTRequest_AckSidechain) updates) =>
      super.copyWith((message) => updates(message as GetCoinbasePSBTRequest_AckSidechain))
          as GetCoinbasePSBTRequest_AckSidechain;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetCoinbasePSBTRequest_AckSidechain() / GetCoinbasePSBTRequest_AckSidechain.new instead')
  static GetCoinbasePSBTRequest_AckSidechain create() => GetCoinbasePSBTRequest_AckSidechain._();
  static $pb.GeneratedMessage $_createMessage() => GetCoinbasePSBTRequest_AckSidechain._();
  @$core.override
  GetCoinbasePSBTRequest_AckSidechain createEmptyInstance() => GetCoinbasePSBTRequest_AckSidechain._();
  @$core.pragma('dart2js:noInline')
  static GetCoinbasePSBTRequest_AckSidechain getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCoinbasePSBTRequest_AckSidechain>(
          GetCoinbasePSBTRequest_AckSidechain.$_createMessage);
  static GetCoinbasePSBTRequest_AckSidechain? _defaultInstance;

  @$pb.TagNumber(1)
  $1.UInt32Value get sidechainNumber => $_getN(0);
  @$pb.TagNumber(1)
  set sidechainNumber($1.UInt32Value value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSidechainNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainNumber() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.UInt32Value ensureSidechainNumber() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.ConsensusHex get dataHash => $_getN(1);
  @$pb.TagNumber(2)
  set dataHash($0.ConsensusHex value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDataHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearDataHash() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.ConsensusHex ensureDataHash() => $_ensure(1);
}

class GetCoinbasePSBTRequest_ProposeBundle extends $pb.GeneratedMessage {
  factory GetCoinbasePSBTRequest_ProposeBundle({
    $1.UInt32Value? sidechainNumber,
    $0.ReverseHex? bundleTxid,
  }) {
    final result = GetCoinbasePSBTRequest_ProposeBundle._();
    if (sidechainNumber != null) result.sidechainNumber = sidechainNumber;
    if (bundleTxid != null) result.bundleTxid = bundleTxid;
    return result;
  }

  GetCoinbasePSBTRequest_ProposeBundle._();

  factory GetCoinbasePSBTRequest_ProposeBundle.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCoinbasePSBTRequest_ProposeBundle()..mergeFromBuffer(data, registry);
  factory GetCoinbasePSBTRequest_ProposeBundle.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCoinbasePSBTRequest_ProposeBundle()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCoinbasePSBTRequest.ProposeBundle',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetCoinbasePSBTRequest_ProposeBundle.$_createMessage)
    ..aOM<$1.UInt32Value>(1, _omitFieldNames ? '' : 'sidechainNumber', subBuilder: $1.UInt32Value.$_createMessage)
    ..aOM<$0.ReverseHex>(2, _omitFieldNames ? '' : 'bundleTxid', subBuilder: $0.ReverseHex.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCoinbasePSBTRequest_ProposeBundle clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCoinbasePSBTRequest_ProposeBundle copyWith(void Function(GetCoinbasePSBTRequest_ProposeBundle) updates) =>
      super.copyWith((message) => updates(message as GetCoinbasePSBTRequest_ProposeBundle))
          as GetCoinbasePSBTRequest_ProposeBundle;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetCoinbasePSBTRequest_ProposeBundle() / GetCoinbasePSBTRequest_ProposeBundle.new instead')
  static GetCoinbasePSBTRequest_ProposeBundle create() => GetCoinbasePSBTRequest_ProposeBundle._();
  static $pb.GeneratedMessage $_createMessage() => GetCoinbasePSBTRequest_ProposeBundle._();
  @$core.override
  GetCoinbasePSBTRequest_ProposeBundle createEmptyInstance() => GetCoinbasePSBTRequest_ProposeBundle._();
  @$core.pragma('dart2js:noInline')
  static GetCoinbasePSBTRequest_ProposeBundle getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCoinbasePSBTRequest_ProposeBundle>(
          GetCoinbasePSBTRequest_ProposeBundle.$_createMessage);
  static GetCoinbasePSBTRequest_ProposeBundle? _defaultInstance;

  @$pb.TagNumber(1)
  $1.UInt32Value get sidechainNumber => $_getN(0);
  @$pb.TagNumber(1)
  set sidechainNumber($1.UInt32Value value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSidechainNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainNumber() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.UInt32Value ensureSidechainNumber() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.ReverseHex get bundleTxid => $_getN(1);
  @$pb.TagNumber(2)
  set bundleTxid($0.ReverseHex value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasBundleTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearBundleTxid() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.ReverseHex ensureBundleTxid() => $_ensure(1);
}

class GetCoinbasePSBTRequest_AckBundles_RepeatPrevious extends $pb.GeneratedMessage {
  factory GetCoinbasePSBTRequest_AckBundles_RepeatPrevious() => GetCoinbasePSBTRequest_AckBundles_RepeatPrevious._();

  GetCoinbasePSBTRequest_AckBundles_RepeatPrevious._();

  factory GetCoinbasePSBTRequest_AckBundles_RepeatPrevious.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCoinbasePSBTRequest_AckBundles_RepeatPrevious()..mergeFromBuffer(data, registry);
  factory GetCoinbasePSBTRequest_AckBundles_RepeatPrevious.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCoinbasePSBTRequest_AckBundles_RepeatPrevious()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCoinbasePSBTRequest.AckBundles.RepeatPrevious',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetCoinbasePSBTRequest_AckBundles_RepeatPrevious.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCoinbasePSBTRequest_AckBundles_RepeatPrevious clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCoinbasePSBTRequest_AckBundles_RepeatPrevious copyWith(
          void Function(GetCoinbasePSBTRequest_AckBundles_RepeatPrevious) updates) =>
      super.copyWith((message) => updates(message as GetCoinbasePSBTRequest_AckBundles_RepeatPrevious))
          as GetCoinbasePSBTRequest_AckBundles_RepeatPrevious;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetCoinbasePSBTRequest_AckBundles_RepeatPrevious() / GetCoinbasePSBTRequest_AckBundles_RepeatPrevious.new instead')
  static GetCoinbasePSBTRequest_AckBundles_RepeatPrevious create() =>
      GetCoinbasePSBTRequest_AckBundles_RepeatPrevious._();
  static $pb.GeneratedMessage $_createMessage() => GetCoinbasePSBTRequest_AckBundles_RepeatPrevious._();
  @$core.override
  GetCoinbasePSBTRequest_AckBundles_RepeatPrevious createEmptyInstance() =>
      GetCoinbasePSBTRequest_AckBundles_RepeatPrevious._();
  @$core.pragma('dart2js:noInline')
  static GetCoinbasePSBTRequest_AckBundles_RepeatPrevious getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCoinbasePSBTRequest_AckBundles_RepeatPrevious>(
          GetCoinbasePSBTRequest_AckBundles_RepeatPrevious.$_createMessage);
  static GetCoinbasePSBTRequest_AckBundles_RepeatPrevious? _defaultInstance;
}

class GetCoinbasePSBTRequest_AckBundles_LeadingBy50 extends $pb.GeneratedMessage {
  factory GetCoinbasePSBTRequest_AckBundles_LeadingBy50() => GetCoinbasePSBTRequest_AckBundles_LeadingBy50._();

  GetCoinbasePSBTRequest_AckBundles_LeadingBy50._();

  factory GetCoinbasePSBTRequest_AckBundles_LeadingBy50.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCoinbasePSBTRequest_AckBundles_LeadingBy50()..mergeFromBuffer(data, registry);
  factory GetCoinbasePSBTRequest_AckBundles_LeadingBy50.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCoinbasePSBTRequest_AckBundles_LeadingBy50()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCoinbasePSBTRequest.AckBundles.LeadingBy50',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetCoinbasePSBTRequest_AckBundles_LeadingBy50.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCoinbasePSBTRequest_AckBundles_LeadingBy50 clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCoinbasePSBTRequest_AckBundles_LeadingBy50 copyWith(
          void Function(GetCoinbasePSBTRequest_AckBundles_LeadingBy50) updates) =>
      super.copyWith((message) => updates(message as GetCoinbasePSBTRequest_AckBundles_LeadingBy50))
          as GetCoinbasePSBTRequest_AckBundles_LeadingBy50;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetCoinbasePSBTRequest_AckBundles_LeadingBy50() / GetCoinbasePSBTRequest_AckBundles_LeadingBy50.new instead')
  static GetCoinbasePSBTRequest_AckBundles_LeadingBy50 create() => GetCoinbasePSBTRequest_AckBundles_LeadingBy50._();
  static $pb.GeneratedMessage $_createMessage() => GetCoinbasePSBTRequest_AckBundles_LeadingBy50._();
  @$core.override
  GetCoinbasePSBTRequest_AckBundles_LeadingBy50 createEmptyInstance() =>
      GetCoinbasePSBTRequest_AckBundles_LeadingBy50._();
  @$core.pragma('dart2js:noInline')
  static GetCoinbasePSBTRequest_AckBundles_LeadingBy50 getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCoinbasePSBTRequest_AckBundles_LeadingBy50>(
          GetCoinbasePSBTRequest_AckBundles_LeadingBy50.$_createMessage);
  static GetCoinbasePSBTRequest_AckBundles_LeadingBy50? _defaultInstance;
}

class GetCoinbasePSBTRequest_AckBundles_Upvotes extends $pb.GeneratedMessage {
  factory GetCoinbasePSBTRequest_AckBundles_Upvotes({
    $core.Iterable<$core.int>? upvotes,
  }) {
    final result = GetCoinbasePSBTRequest_AckBundles_Upvotes._();
    if (upvotes != null) result.upvotes.addAll(upvotes);
    return result;
  }

  GetCoinbasePSBTRequest_AckBundles_Upvotes._();

  factory GetCoinbasePSBTRequest_AckBundles_Upvotes.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCoinbasePSBTRequest_AckBundles_Upvotes()..mergeFromBuffer(data, registry);
  factory GetCoinbasePSBTRequest_AckBundles_Upvotes.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCoinbasePSBTRequest_AckBundles_Upvotes()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetCoinbasePSBTRequest.AckBundles.Upvotes',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetCoinbasePSBTRequest_AckBundles_Upvotes.$_createMessage)
    ..p<$core.int>(1, _omitFieldNames ? '' : 'upvotes', $pb.PbFieldType.KU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCoinbasePSBTRequest_AckBundles_Upvotes clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCoinbasePSBTRequest_AckBundles_Upvotes copyWith(
          void Function(GetCoinbasePSBTRequest_AckBundles_Upvotes) updates) =>
      super.copyWith((message) => updates(message as GetCoinbasePSBTRequest_AckBundles_Upvotes))
          as GetCoinbasePSBTRequest_AckBundles_Upvotes;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetCoinbasePSBTRequest_AckBundles_Upvotes() / GetCoinbasePSBTRequest_AckBundles_Upvotes.new instead')
  static GetCoinbasePSBTRequest_AckBundles_Upvotes create() => GetCoinbasePSBTRequest_AckBundles_Upvotes._();
  static $pb.GeneratedMessage $_createMessage() => GetCoinbasePSBTRequest_AckBundles_Upvotes._();
  @$core.override
  GetCoinbasePSBTRequest_AckBundles_Upvotes createEmptyInstance() => GetCoinbasePSBTRequest_AckBundles_Upvotes._();
  @$core.pragma('dart2js:noInline')
  static GetCoinbasePSBTRequest_AckBundles_Upvotes getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCoinbasePSBTRequest_AckBundles_Upvotes>(
          GetCoinbasePSBTRequest_AckBundles_Upvotes.$_createMessage);
  static GetCoinbasePSBTRequest_AckBundles_Upvotes? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.int> get upvotes => $_getList(0);
}

enum GetCoinbasePSBTRequest_AckBundles_AckBundles { repeatPrevious, leadingBy50, upvotes, notSet }

class GetCoinbasePSBTRequest_AckBundles extends $pb.GeneratedMessage {
  factory GetCoinbasePSBTRequest_AckBundles({
    GetCoinbasePSBTRequest_AckBundles_RepeatPrevious? repeatPrevious,
    GetCoinbasePSBTRequest_AckBundles_LeadingBy50? leadingBy50,
    GetCoinbasePSBTRequest_AckBundles_Upvotes? upvotes,
  }) {
    final result = GetCoinbasePSBTRequest_AckBundles._();
    if (repeatPrevious != null) result.repeatPrevious = repeatPrevious;
    if (leadingBy50 != null) result.leadingBy50 = leadingBy50;
    if (upvotes != null) result.upvotes = upvotes;
    return result;
  }

  GetCoinbasePSBTRequest_AckBundles._();

  factory GetCoinbasePSBTRequest_AckBundles.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCoinbasePSBTRequest_AckBundles()..mergeFromBuffer(data, registry);
  factory GetCoinbasePSBTRequest_AckBundles.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCoinbasePSBTRequest_AckBundles()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, GetCoinbasePSBTRequest_AckBundles_AckBundles>
      _GetCoinbasePSBTRequest_AckBundles_AckBundlesByTag = {
    1: GetCoinbasePSBTRequest_AckBundles_AckBundles.repeatPrevious,
    2: GetCoinbasePSBTRequest_AckBundles_AckBundles.leadingBy50,
    3: GetCoinbasePSBTRequest_AckBundles_AckBundles.upvotes,
    0: GetCoinbasePSBTRequest_AckBundles_AckBundles.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCoinbasePSBTRequest.AckBundles',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetCoinbasePSBTRequest_AckBundles.$_createMessage)
    ..oo(0, [1, 2, 3])
    ..aOM<GetCoinbasePSBTRequest_AckBundles_RepeatPrevious>(1, _omitFieldNames ? '' : 'repeatPrevious',
        subBuilder: GetCoinbasePSBTRequest_AckBundles_RepeatPrevious.$_createMessage)
    ..aOM<GetCoinbasePSBTRequest_AckBundles_LeadingBy50>(2, _omitFieldNames ? '' : 'leadingBy50',
        protoName: 'leading_by_50', subBuilder: GetCoinbasePSBTRequest_AckBundles_LeadingBy50.$_createMessage)
    ..aOM<GetCoinbasePSBTRequest_AckBundles_Upvotes>(3, _omitFieldNames ? '' : 'upvotes',
        subBuilder: GetCoinbasePSBTRequest_AckBundles_Upvotes.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCoinbasePSBTRequest_AckBundles clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCoinbasePSBTRequest_AckBundles copyWith(void Function(GetCoinbasePSBTRequest_AckBundles) updates) =>
      super.copyWith((message) => updates(message as GetCoinbasePSBTRequest_AckBundles))
          as GetCoinbasePSBTRequest_AckBundles;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetCoinbasePSBTRequest_AckBundles() / GetCoinbasePSBTRequest_AckBundles.new instead')
  static GetCoinbasePSBTRequest_AckBundles create() => GetCoinbasePSBTRequest_AckBundles._();
  static $pb.GeneratedMessage $_createMessage() => GetCoinbasePSBTRequest_AckBundles._();
  @$core.override
  GetCoinbasePSBTRequest_AckBundles createEmptyInstance() => GetCoinbasePSBTRequest_AckBundles._();
  @$core.pragma('dart2js:noInline')
  static GetCoinbasePSBTRequest_AckBundles getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCoinbasePSBTRequest_AckBundles>(
          GetCoinbasePSBTRequest_AckBundles.$_createMessage);
  static GetCoinbasePSBTRequest_AckBundles? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  GetCoinbasePSBTRequest_AckBundles_AckBundles whichAckBundles() =>
      _GetCoinbasePSBTRequest_AckBundles_AckBundlesByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  void clearAckBundles() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  GetCoinbasePSBTRequest_AckBundles_RepeatPrevious get repeatPrevious => $_getN(0);
  @$pb.TagNumber(1)
  set repeatPrevious(GetCoinbasePSBTRequest_AckBundles_RepeatPrevious value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRepeatPrevious() => $_has(0);
  @$pb.TagNumber(1)
  void clearRepeatPrevious() => $_clearField(1);
  @$pb.TagNumber(1)
  GetCoinbasePSBTRequest_AckBundles_RepeatPrevious ensureRepeatPrevious() => $_ensure(0);

  @$pb.TagNumber(2)
  GetCoinbasePSBTRequest_AckBundles_LeadingBy50 get leadingBy50 => $_getN(1);
  @$pb.TagNumber(2)
  set leadingBy50(GetCoinbasePSBTRequest_AckBundles_LeadingBy50 value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasLeadingBy50() => $_has(1);
  @$pb.TagNumber(2)
  void clearLeadingBy50() => $_clearField(2);
  @$pb.TagNumber(2)
  GetCoinbasePSBTRequest_AckBundles_LeadingBy50 ensureLeadingBy50() => $_ensure(1);

  @$pb.TagNumber(3)
  GetCoinbasePSBTRequest_AckBundles_Upvotes get upvotes => $_getN(2);
  @$pb.TagNumber(3)
  set upvotes(GetCoinbasePSBTRequest_AckBundles_Upvotes value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasUpvotes() => $_has(2);
  @$pb.TagNumber(3)
  void clearUpvotes() => $_clearField(3);
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
    final result = GetCoinbasePSBTRequest._();
    if (proposeSidechains != null) result.proposeSidechains.addAll(proposeSidechains);
    if (ackSidechains != null) result.ackSidechains.addAll(ackSidechains);
    if (proposeBundles != null) result.proposeBundles.addAll(proposeBundles);
    if (ackBundles != null) result.ackBundles = ackBundles;
    return result;
  }

  GetCoinbasePSBTRequest._();

  factory GetCoinbasePSBTRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCoinbasePSBTRequest()..mergeFromBuffer(data, registry);
  factory GetCoinbasePSBTRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCoinbasePSBTRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCoinbasePSBTRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetCoinbasePSBTRequest.$_createMessage)
    ..pPM<GetCoinbasePSBTRequest_ProposeSidechain>(1, _omitFieldNames ? '' : 'proposeSidechains',
        subBuilder: GetCoinbasePSBTRequest_ProposeSidechain.$_createMessage)
    ..pPM<GetCoinbasePSBTRequest_AckSidechain>(2, _omitFieldNames ? '' : 'ackSidechains',
        subBuilder: GetCoinbasePSBTRequest_AckSidechain.$_createMessage)
    ..pPM<GetCoinbasePSBTRequest_ProposeBundle>(3, _omitFieldNames ? '' : 'proposeBundles',
        subBuilder: GetCoinbasePSBTRequest_ProposeBundle.$_createMessage)
    ..aOM<GetCoinbasePSBTRequest_AckBundles>(4, _omitFieldNames ? '' : 'ackBundles',
        subBuilder: GetCoinbasePSBTRequest_AckBundles.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCoinbasePSBTRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCoinbasePSBTRequest copyWith(void Function(GetCoinbasePSBTRequest) updates) =>
      super.copyWith((message) => updates(message as GetCoinbasePSBTRequest)) as GetCoinbasePSBTRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetCoinbasePSBTRequest() / GetCoinbasePSBTRequest.new instead')
  static GetCoinbasePSBTRequest create() => GetCoinbasePSBTRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetCoinbasePSBTRequest._();
  @$core.override
  GetCoinbasePSBTRequest createEmptyInstance() => GetCoinbasePSBTRequest._();
  @$core.pragma('dart2js:noInline')
  static GetCoinbasePSBTRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCoinbasePSBTRequest>(GetCoinbasePSBTRequest.$_createMessage);
  static GetCoinbasePSBTRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<GetCoinbasePSBTRequest_ProposeSidechain> get proposeSidechains => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<GetCoinbasePSBTRequest_AckSidechain> get ackSidechains => $_getList(1);

  @$pb.TagNumber(3)
  $pb.PbList<GetCoinbasePSBTRequest_ProposeBundle> get proposeBundles => $_getList(2);

  @$pb.TagNumber(4)
  GetCoinbasePSBTRequest_AckBundles get ackBundles => $_getN(3);
  @$pb.TagNumber(4)
  set ackBundles(GetCoinbasePSBTRequest_AckBundles value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasAckBundles() => $_has(3);
  @$pb.TagNumber(4)
  void clearAckBundles() => $_clearField(4);
  @$pb.TagNumber(4)
  GetCoinbasePSBTRequest_AckBundles ensureAckBundles() => $_ensure(3);
}

class GetCoinbasePSBTResponse extends $pb.GeneratedMessage {
  factory GetCoinbasePSBTResponse({
    $0.ConsensusHex? psbt,
  }) {
    final result = GetCoinbasePSBTResponse._();
    if (psbt != null) result.psbt = psbt;
    return result;
  }

  GetCoinbasePSBTResponse._();

  factory GetCoinbasePSBTResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCoinbasePSBTResponse()..mergeFromBuffer(data, registry);
  factory GetCoinbasePSBTResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCoinbasePSBTResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCoinbasePSBTResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetCoinbasePSBTResponse.$_createMessage)
    ..aOM<$0.ConsensusHex>(1, _omitFieldNames ? '' : 'psbt', subBuilder: $0.ConsensusHex.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCoinbasePSBTResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCoinbasePSBTResponse copyWith(void Function(GetCoinbasePSBTResponse) updates) =>
      super.copyWith((message) => updates(message as GetCoinbasePSBTResponse)) as GetCoinbasePSBTResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetCoinbasePSBTResponse() / GetCoinbasePSBTResponse.new instead')
  static GetCoinbasePSBTResponse create() => GetCoinbasePSBTResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetCoinbasePSBTResponse._();
  @$core.override
  GetCoinbasePSBTResponse createEmptyInstance() => GetCoinbasePSBTResponse._();
  @$core.pragma('dart2js:noInline')
  static GetCoinbasePSBTResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCoinbasePSBTResponse>(GetCoinbasePSBTResponse.$_createMessage);
  static GetCoinbasePSBTResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $0.ConsensusHex get psbt => $_getN(0);
  @$pb.TagNumber(1)
  set psbt($0.ConsensusHex value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.ConsensusHex ensurePsbt() => $_ensure(0);
}

class GetCtipRequest extends $pb.GeneratedMessage {
  factory GetCtipRequest({
    $1.UInt32Value? sidechainNumber,
  }) {
    final result = GetCtipRequest._();
    if (sidechainNumber != null) result.sidechainNumber = sidechainNumber;
    return result;
  }

  GetCtipRequest._();

  factory GetCtipRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCtipRequest()..mergeFromBuffer(data, registry);
  factory GetCtipRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCtipRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCtipRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetCtipRequest.$_createMessage)
    ..aOM<$1.UInt32Value>(1, _omitFieldNames ? '' : 'sidechainNumber', subBuilder: $1.UInt32Value.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCtipRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCtipRequest copyWith(void Function(GetCtipRequest) updates) =>
      super.copyWith((message) => updates(message as GetCtipRequest)) as GetCtipRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetCtipRequest() / GetCtipRequest.new instead')
  static GetCtipRequest create() => GetCtipRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetCtipRequest._();
  @$core.override
  GetCtipRequest createEmptyInstance() => GetCtipRequest._();
  @$core.pragma('dart2js:noInline')
  static GetCtipRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCtipRequest>(GetCtipRequest.$_createMessage);
  static GetCtipRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $1.UInt32Value get sidechainNumber => $_getN(0);
  @$pb.TagNumber(1)
  set sidechainNumber($1.UInt32Value value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSidechainNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainNumber() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.UInt32Value ensureSidechainNumber() => $_ensure(0);
}

class GetCtipResponse_Ctip extends $pb.GeneratedMessage {
  factory GetCtipResponse_Ctip({
    $0.ReverseHex? txid,
    $core.int? vout,
    $fixnum.Int64? value,
    $fixnum.Int64? sequenceNumber,
  }) {
    final result = GetCtipResponse_Ctip._();
    if (txid != null) result.txid = txid;
    if (vout != null) result.vout = vout;
    if (value != null) result.value = value;
    if (sequenceNumber != null) result.sequenceNumber = sequenceNumber;
    return result;
  }

  GetCtipResponse_Ctip._();

  factory GetCtipResponse_Ctip.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCtipResponse_Ctip()..mergeFromBuffer(data, registry);
  factory GetCtipResponse_Ctip.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCtipResponse_Ctip()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCtipResponse.Ctip',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetCtipResponse_Ctip.$_createMessage)
    ..aOM<$0.ReverseHex>(1, _omitFieldNames ? '' : 'txid', subBuilder: $0.ReverseHex.$_createMessage)
    ..aI(2, _omitFieldNames ? '' : 'vout', fieldType: $pb.PbFieldType.OU3)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'value', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'sequenceNumber', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCtipResponse_Ctip clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCtipResponse_Ctip copyWith(void Function(GetCtipResponse_Ctip) updates) =>
      super.copyWith((message) => updates(message as GetCtipResponse_Ctip)) as GetCtipResponse_Ctip;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetCtipResponse_Ctip() / GetCtipResponse_Ctip.new instead')
  static GetCtipResponse_Ctip create() => GetCtipResponse_Ctip._();
  static $pb.GeneratedMessage $_createMessage() => GetCtipResponse_Ctip._();
  @$core.override
  GetCtipResponse_Ctip createEmptyInstance() => GetCtipResponse_Ctip._();
  @$core.pragma('dart2js:noInline')
  static GetCtipResponse_Ctip getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCtipResponse_Ctip>(GetCtipResponse_Ctip.$_createMessage);
  static GetCtipResponse_Ctip? _defaultInstance;

  @$pb.TagNumber(1)
  $0.ReverseHex get txid => $_getN(0);
  @$pb.TagNumber(1)
  set txid($0.ReverseHex value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.ReverseHex ensureTxid() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.int get vout => $_getIZ(1);
  @$pb.TagNumber(2)
  set vout($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearVout() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get value => $_getI64(2);
  @$pb.TagNumber(3)
  set value($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasValue() => $_has(2);
  @$pb.TagNumber(3)
  void clearValue() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get sequenceNumber => $_getI64(3);
  @$pb.TagNumber(4)
  set sequenceNumber($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSequenceNumber() => $_has(3);
  @$pb.TagNumber(4)
  void clearSequenceNumber() => $_clearField(4);
}

class GetCtipResponse extends $pb.GeneratedMessage {
  factory GetCtipResponse({
    GetCtipResponse_Ctip? ctip,
  }) {
    final result = GetCtipResponse._();
    if (ctip != null) result.ctip = ctip;
    return result;
  }

  GetCtipResponse._();

  factory GetCtipResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCtipResponse()..mergeFromBuffer(data, registry);
  factory GetCtipResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCtipResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCtipResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetCtipResponse.$_createMessage)
    ..aOM<GetCtipResponse_Ctip>(1, _omitFieldNames ? '' : 'ctip', subBuilder: GetCtipResponse_Ctip.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCtipResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCtipResponse copyWith(void Function(GetCtipResponse) updates) =>
      super.copyWith((message) => updates(message as GetCtipResponse)) as GetCtipResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetCtipResponse() / GetCtipResponse.new instead')
  static GetCtipResponse create() => GetCtipResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetCtipResponse._();
  @$core.override
  GetCtipResponse createEmptyInstance() => GetCtipResponse._();
  @$core.pragma('dart2js:noInline')
  static GetCtipResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetCtipResponse>(GetCtipResponse.$_createMessage);
  static GetCtipResponse? _defaultInstance;

  @$pb.TagNumber(1)
  GetCtipResponse_Ctip get ctip => $_getN(0);
  @$pb.TagNumber(1)
  set ctip(GetCtipResponse_Ctip value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCtip() => $_has(0);
  @$pb.TagNumber(1)
  void clearCtip() => $_clearField(1);
  @$pb.TagNumber(1)
  GetCtipResponse_Ctip ensureCtip() => $_ensure(0);
}

class GetSidechainProposalsRequest extends $pb.GeneratedMessage {
  factory GetSidechainProposalsRequest() => GetSidechainProposalsRequest._();

  GetSidechainProposalsRequest._();

  factory GetSidechainProposalsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainProposalsRequest()..mergeFromBuffer(data, registry);
  factory GetSidechainProposalsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainProposalsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainProposalsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetSidechainProposalsRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainProposalsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainProposalsRequest copyWith(void Function(GetSidechainProposalsRequest) updates) =>
      super.copyWith((message) => updates(message as GetSidechainProposalsRequest)) as GetSidechainProposalsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetSidechainProposalsRequest() / GetSidechainProposalsRequest.new instead')
  static GetSidechainProposalsRequest create() => GetSidechainProposalsRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetSidechainProposalsRequest._();
  @$core.override
  GetSidechainProposalsRequest createEmptyInstance() => GetSidechainProposalsRequest._();
  @$core.pragma('dart2js:noInline')
  static GetSidechainProposalsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSidechainProposalsRequest>(GetSidechainProposalsRequest.$_createMessage);
  static GetSidechainProposalsRequest? _defaultInstance;
}

class GetSidechainProposalsResponse_SidechainProposal extends $pb.GeneratedMessage {
  factory GetSidechainProposalsResponse_SidechainProposal({
    $1.UInt32Value? sidechainNumber,
    $0.ConsensusHex? description,
    $0.ReverseHex? descriptionSha256dHash,
    $1.UInt32Value? voteCount,
    $1.UInt32Value? proposalHeight,
    $1.UInt32Value? proposalAge,
    $2.SidechainDeclaration? declaration,
  }) {
    final result = GetSidechainProposalsResponse_SidechainProposal._();
    if (sidechainNumber != null) result.sidechainNumber = sidechainNumber;
    if (description != null) result.description = description;
    if (descriptionSha256dHash != null) result.descriptionSha256dHash = descriptionSha256dHash;
    if (voteCount != null) result.voteCount = voteCount;
    if (proposalHeight != null) result.proposalHeight = proposalHeight;
    if (proposalAge != null) result.proposalAge = proposalAge;
    if (declaration != null) result.declaration = declaration;
    return result;
  }

  GetSidechainProposalsResponse_SidechainProposal._();

  factory GetSidechainProposalsResponse_SidechainProposal.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainProposalsResponse_SidechainProposal()..mergeFromBuffer(data, registry);
  factory GetSidechainProposalsResponse_SidechainProposal.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainProposalsResponse_SidechainProposal()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'GetSidechainProposalsResponse.SidechainProposal',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetSidechainProposalsResponse_SidechainProposal.$_createMessage)
    ..aOM<$1.UInt32Value>(1, _omitFieldNames ? '' : 'sidechainNumber', subBuilder: $1.UInt32Value.$_createMessage)
    ..aOM<$0.ConsensusHex>(2, _omitFieldNames ? '' : 'description', subBuilder: $0.ConsensusHex.$_createMessage)
    ..aOM<$0.ReverseHex>(3, _omitFieldNames ? '' : 'descriptionSha256dHash', subBuilder: $0.ReverseHex.$_createMessage)
    ..aOM<$1.UInt32Value>(4, _omitFieldNames ? '' : 'voteCount', subBuilder: $1.UInt32Value.$_createMessage)
    ..aOM<$1.UInt32Value>(5, _omitFieldNames ? '' : 'proposalHeight', subBuilder: $1.UInt32Value.$_createMessage)
    ..aOM<$1.UInt32Value>(6, _omitFieldNames ? '' : 'proposalAge', subBuilder: $1.UInt32Value.$_createMessage)
    ..aOM<$2.SidechainDeclaration>(7, _omitFieldNames ? '' : 'declaration',
        subBuilder: $2.SidechainDeclaration.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainProposalsResponse_SidechainProposal clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainProposalsResponse_SidechainProposal copyWith(
          void Function(GetSidechainProposalsResponse_SidechainProposal) updates) =>
      super.copyWith((message) => updates(message as GetSidechainProposalsResponse_SidechainProposal))
          as GetSidechainProposalsResponse_SidechainProposal;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use GetSidechainProposalsResponse_SidechainProposal() / GetSidechainProposalsResponse_SidechainProposal.new instead')
  static GetSidechainProposalsResponse_SidechainProposal create() =>
      GetSidechainProposalsResponse_SidechainProposal._();
  static $pb.GeneratedMessage $_createMessage() => GetSidechainProposalsResponse_SidechainProposal._();
  @$core.override
  GetSidechainProposalsResponse_SidechainProposal createEmptyInstance() =>
      GetSidechainProposalsResponse_SidechainProposal._();
  @$core.pragma('dart2js:noInline')
  static GetSidechainProposalsResponse_SidechainProposal getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetSidechainProposalsResponse_SidechainProposal>(
          GetSidechainProposalsResponse_SidechainProposal.$_createMessage);
  static GetSidechainProposalsResponse_SidechainProposal? _defaultInstance;

  @$pb.TagNumber(1)
  $1.UInt32Value get sidechainNumber => $_getN(0);
  @$pb.TagNumber(1)
  set sidechainNumber($1.UInt32Value value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSidechainNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainNumber() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.UInt32Value ensureSidechainNumber() => $_ensure(0);

  /// Raw sidechain proposal description
  @$pb.TagNumber(2)
  $0.ConsensusHex get description => $_getN(1);
  @$pb.TagNumber(2)
  set description($0.ConsensusHex value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.ConsensusHex ensureDescription() => $_ensure(1);

  @$pb.TagNumber(3)
  $0.ReverseHex get descriptionSha256dHash => $_getN(2);
  @$pb.TagNumber(3)
  set descriptionSha256dHash($0.ReverseHex value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasDescriptionSha256dHash() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescriptionSha256dHash() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.ReverseHex ensureDescriptionSha256dHash() => $_ensure(2);

  @$pb.TagNumber(4)
  $1.UInt32Value get voteCount => $_getN(3);
  @$pb.TagNumber(4)
  set voteCount($1.UInt32Value value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasVoteCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearVoteCount() => $_clearField(4);
  @$pb.TagNumber(4)
  $1.UInt32Value ensureVoteCount() => $_ensure(3);

  @$pb.TagNumber(5)
  $1.UInt32Value get proposalHeight => $_getN(4);
  @$pb.TagNumber(5)
  set proposalHeight($1.UInt32Value value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasProposalHeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearProposalHeight() => $_clearField(5);
  @$pb.TagNumber(5)
  $1.UInt32Value ensureProposalHeight() => $_ensure(4);

  @$pb.TagNumber(6)
  $1.UInt32Value get proposalAge => $_getN(5);
  @$pb.TagNumber(6)
  set proposalAge($1.UInt32Value value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasProposalAge() => $_has(5);
  @$pb.TagNumber(6)
  void clearProposalAge() => $_clearField(6);
  @$pb.TagNumber(6)
  $1.UInt32Value ensureProposalAge() => $_ensure(5);

  /// Sidechain data, as declared in the M1 proposal.
  /// Might be nil, if the proposal uses an unknown version.
  @$pb.TagNumber(7)
  $2.SidechainDeclaration get declaration => $_getN(6);
  @$pb.TagNumber(7)
  set declaration($2.SidechainDeclaration value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasDeclaration() => $_has(6);
  @$pb.TagNumber(7)
  void clearDeclaration() => $_clearField(7);
  @$pb.TagNumber(7)
  $2.SidechainDeclaration ensureDeclaration() => $_ensure(6);
}

class GetSidechainProposalsResponse extends $pb.GeneratedMessage {
  factory GetSidechainProposalsResponse({
    $core.Iterable<GetSidechainProposalsResponse_SidechainProposal>? sidechainProposals,
  }) {
    final result = GetSidechainProposalsResponse._();
    if (sidechainProposals != null) result.sidechainProposals.addAll(sidechainProposals);
    return result;
  }

  GetSidechainProposalsResponse._();

  factory GetSidechainProposalsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainProposalsResponse()..mergeFromBuffer(data, registry);
  factory GetSidechainProposalsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainProposalsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainProposalsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetSidechainProposalsResponse.$_createMessage)
    ..pPM<GetSidechainProposalsResponse_SidechainProposal>(1, _omitFieldNames ? '' : 'sidechainProposals',
        subBuilder: GetSidechainProposalsResponse_SidechainProposal.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainProposalsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainProposalsResponse copyWith(void Function(GetSidechainProposalsResponse) updates) =>
      super.copyWith((message) => updates(message as GetSidechainProposalsResponse)) as GetSidechainProposalsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetSidechainProposalsResponse() / GetSidechainProposalsResponse.new instead')
  static GetSidechainProposalsResponse create() => GetSidechainProposalsResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetSidechainProposalsResponse._();
  @$core.override
  GetSidechainProposalsResponse createEmptyInstance() => GetSidechainProposalsResponse._();
  @$core.pragma('dart2js:noInline')
  static GetSidechainProposalsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSidechainProposalsResponse>(GetSidechainProposalsResponse.$_createMessage);
  static GetSidechainProposalsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<GetSidechainProposalsResponse_SidechainProposal> get sidechainProposals => $_getList(0);
}

class GetSidechainsRequest extends $pb.GeneratedMessage {
  factory GetSidechainsRequest() => GetSidechainsRequest._();

  GetSidechainsRequest._();

  factory GetSidechainsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainsRequest()..mergeFromBuffer(data, registry);
  factory GetSidechainsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetSidechainsRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainsRequest copyWith(void Function(GetSidechainsRequest) updates) =>
      super.copyWith((message) => updates(message as GetSidechainsRequest)) as GetSidechainsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetSidechainsRequest() / GetSidechainsRequest.new instead')
  static GetSidechainsRequest create() => GetSidechainsRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetSidechainsRequest._();
  @$core.override
  GetSidechainsRequest createEmptyInstance() => GetSidechainsRequest._();
  @$core.pragma('dart2js:noInline')
  static GetSidechainsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSidechainsRequest>(GetSidechainsRequest.$_createMessage);
  static GetSidechainsRequest? _defaultInstance;
}

class GetSidechainsResponse_SidechainInfo extends $pb.GeneratedMessage {
  factory GetSidechainsResponse_SidechainInfo({
    $1.UInt32Value? sidechainNumber,
    $0.ConsensusHex? description,
    $1.UInt32Value? voteCount,
    $1.UInt32Value? proposalHeight,
    $1.UInt32Value? activationHeight,
    $2.SidechainDeclaration? declaration,
  }) {
    final result = GetSidechainsResponse_SidechainInfo._();
    if (sidechainNumber != null) result.sidechainNumber = sidechainNumber;
    if (description != null) result.description = description;
    if (voteCount != null) result.voteCount = voteCount;
    if (proposalHeight != null) result.proposalHeight = proposalHeight;
    if (activationHeight != null) result.activationHeight = activationHeight;
    if (declaration != null) result.declaration = declaration;
    return result;
  }

  GetSidechainsResponse_SidechainInfo._();

  factory GetSidechainsResponse_SidechainInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainsResponse_SidechainInfo()..mergeFromBuffer(data, registry);
  factory GetSidechainsResponse_SidechainInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainsResponse_SidechainInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainsResponse.SidechainInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetSidechainsResponse_SidechainInfo.$_createMessage)
    ..aOM<$1.UInt32Value>(1, _omitFieldNames ? '' : 'sidechainNumber', subBuilder: $1.UInt32Value.$_createMessage)
    ..aOM<$0.ConsensusHex>(2, _omitFieldNames ? '' : 'description', subBuilder: $0.ConsensusHex.$_createMessage)
    ..aOM<$1.UInt32Value>(3, _omitFieldNames ? '' : 'voteCount', subBuilder: $1.UInt32Value.$_createMessage)
    ..aOM<$1.UInt32Value>(4, _omitFieldNames ? '' : 'proposalHeight', subBuilder: $1.UInt32Value.$_createMessage)
    ..aOM<$1.UInt32Value>(5, _omitFieldNames ? '' : 'activationHeight', subBuilder: $1.UInt32Value.$_createMessage)
    ..aOM<$2.SidechainDeclaration>(6, _omitFieldNames ? '' : 'declaration',
        subBuilder: $2.SidechainDeclaration.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainsResponse_SidechainInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainsResponse_SidechainInfo copyWith(void Function(GetSidechainsResponse_SidechainInfo) updates) =>
      super.copyWith((message) => updates(message as GetSidechainsResponse_SidechainInfo))
          as GetSidechainsResponse_SidechainInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetSidechainsResponse_SidechainInfo() / GetSidechainsResponse_SidechainInfo.new instead')
  static GetSidechainsResponse_SidechainInfo create() => GetSidechainsResponse_SidechainInfo._();
  static $pb.GeneratedMessage $_createMessage() => GetSidechainsResponse_SidechainInfo._();
  @$core.override
  GetSidechainsResponse_SidechainInfo createEmptyInstance() => GetSidechainsResponse_SidechainInfo._();
  @$core.pragma('dart2js:noInline')
  static GetSidechainsResponse_SidechainInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetSidechainsResponse_SidechainInfo>(
          GetSidechainsResponse_SidechainInfo.$_createMessage);
  static GetSidechainsResponse_SidechainInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $1.UInt32Value get sidechainNumber => $_getN(0);
  @$pb.TagNumber(1)
  set sidechainNumber($1.UInt32Value value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSidechainNumber() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainNumber() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.UInt32Value ensureSidechainNumber() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.ConsensusHex get description => $_getN(1);
  @$pb.TagNumber(2)
  set description($0.ConsensusHex value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.ConsensusHex ensureDescription() => $_ensure(1);

  @$pb.TagNumber(3)
  $1.UInt32Value get voteCount => $_getN(2);
  @$pb.TagNumber(3)
  set voteCount($1.UInt32Value value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasVoteCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearVoteCount() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.UInt32Value ensureVoteCount() => $_ensure(2);

  @$pb.TagNumber(4)
  $1.UInt32Value get proposalHeight => $_getN(3);
  @$pb.TagNumber(4)
  set proposalHeight($1.UInt32Value value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasProposalHeight() => $_has(3);
  @$pb.TagNumber(4)
  void clearProposalHeight() => $_clearField(4);
  @$pb.TagNumber(4)
  $1.UInt32Value ensureProposalHeight() => $_ensure(3);

  @$pb.TagNumber(5)
  $1.UInt32Value get activationHeight => $_getN(4);
  @$pb.TagNumber(5)
  set activationHeight($1.UInt32Value value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasActivationHeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearActivationHeight() => $_clearField(5);
  @$pb.TagNumber(5)
  $1.UInt32Value ensureActivationHeight() => $_ensure(4);

  /// Sidechain data, as declared in the M1 proposal.
  /// Might be nil, if the proposal uses an unknown version.
  @$pb.TagNumber(6)
  $2.SidechainDeclaration get declaration => $_getN(5);
  @$pb.TagNumber(6)
  set declaration($2.SidechainDeclaration value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasDeclaration() => $_has(5);
  @$pb.TagNumber(6)
  void clearDeclaration() => $_clearField(6);
  @$pb.TagNumber(6)
  $2.SidechainDeclaration ensureDeclaration() => $_ensure(5);
}

class GetSidechainsResponse extends $pb.GeneratedMessage {
  factory GetSidechainsResponse({
    $core.Iterable<GetSidechainsResponse_SidechainInfo>? sidechains,
  }) {
    final result = GetSidechainsResponse._();
    if (sidechains != null) result.sidechains.addAll(sidechains);
    return result;
  }

  GetSidechainsResponse._();

  factory GetSidechainsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainsResponse()..mergeFromBuffer(data, registry);
  factory GetSidechainsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetSidechainsResponse.$_createMessage)
    ..pPM<GetSidechainsResponse_SidechainInfo>(1, _omitFieldNames ? '' : 'sidechains',
        subBuilder: GetSidechainsResponse_SidechainInfo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainsResponse copyWith(void Function(GetSidechainsResponse) updates) =>
      super.copyWith((message) => updates(message as GetSidechainsResponse)) as GetSidechainsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetSidechainsResponse() / GetSidechainsResponse.new instead')
  static GetSidechainsResponse create() => GetSidechainsResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetSidechainsResponse._();
  @$core.override
  GetSidechainsResponse createEmptyInstance() => GetSidechainsResponse._();
  @$core.pragma('dart2js:noInline')
  static GetSidechainsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSidechainsResponse>(GetSidechainsResponse.$_createMessage);
  static GetSidechainsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<GetSidechainsResponse_SidechainInfo> get sidechains => $_getList(0);
}

class GetTwoWayPegDataRequest extends $pb.GeneratedMessage {
  factory GetTwoWayPegDataRequest({
    $1.UInt32Value? sidechainId,
    $0.ReverseHex? startBlockHash,
    $0.ReverseHex? endBlockHash,
  }) {
    final result = GetTwoWayPegDataRequest._();
    if (sidechainId != null) result.sidechainId = sidechainId;
    if (startBlockHash != null) result.startBlockHash = startBlockHash;
    if (endBlockHash != null) result.endBlockHash = endBlockHash;
    return result;
  }

  GetTwoWayPegDataRequest._();

  factory GetTwoWayPegDataRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTwoWayPegDataRequest()..mergeFromBuffer(data, registry);
  factory GetTwoWayPegDataRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTwoWayPegDataRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTwoWayPegDataRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetTwoWayPegDataRequest.$_createMessage)
    ..aOM<$1.UInt32Value>(1, _omitFieldNames ? '' : 'sidechainId', subBuilder: $1.UInt32Value.$_createMessage)
    ..aOM<$0.ReverseHex>(2, _omitFieldNames ? '' : 'startBlockHash', subBuilder: $0.ReverseHex.$_createMessage)
    ..aOM<$0.ReverseHex>(3, _omitFieldNames ? '' : 'endBlockHash', subBuilder: $0.ReverseHex.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTwoWayPegDataRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTwoWayPegDataRequest copyWith(void Function(GetTwoWayPegDataRequest) updates) =>
      super.copyWith((message) => updates(message as GetTwoWayPegDataRequest)) as GetTwoWayPegDataRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetTwoWayPegDataRequest() / GetTwoWayPegDataRequest.new instead')
  static GetTwoWayPegDataRequest create() => GetTwoWayPegDataRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetTwoWayPegDataRequest._();
  @$core.override
  GetTwoWayPegDataRequest createEmptyInstance() => GetTwoWayPegDataRequest._();
  @$core.pragma('dart2js:noInline')
  static GetTwoWayPegDataRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTwoWayPegDataRequest>(GetTwoWayPegDataRequest.$_createMessage);
  static GetTwoWayPegDataRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $1.UInt32Value get sidechainId => $_getN(0);
  @$pb.TagNumber(1)
  set sidechainId($1.UInt32Value value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSidechainId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainId() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.UInt32Value ensureSidechainId() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.ReverseHex get startBlockHash => $_getN(1);
  @$pb.TagNumber(2)
  set startBlockHash($0.ReverseHex value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStartBlockHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartBlockHash() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.ReverseHex ensureStartBlockHash() => $_ensure(1);

  @$pb.TagNumber(3)
  $0.ReverseHex get endBlockHash => $_getN(2);
  @$pb.TagNumber(3)
  set endBlockHash($0.ReverseHex value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasEndBlockHash() => $_has(2);
  @$pb.TagNumber(3)
  void clearEndBlockHash() => $_clearField(3);
  @$pb.TagNumber(3)
  $0.ReverseHex ensureEndBlockHash() => $_ensure(2);
}

class GetTwoWayPegDataResponse_ResponseItem extends $pb.GeneratedMessage {
  factory GetTwoWayPegDataResponse_ResponseItem({
    BlockHeaderInfo? blockHeaderInfo,
    BlockInfo? blockInfo,
  }) {
    final result = GetTwoWayPegDataResponse_ResponseItem._();
    if (blockHeaderInfo != null) result.blockHeaderInfo = blockHeaderInfo;
    if (blockInfo != null) result.blockInfo = blockInfo;
    return result;
  }

  GetTwoWayPegDataResponse_ResponseItem._();

  factory GetTwoWayPegDataResponse_ResponseItem.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTwoWayPegDataResponse_ResponseItem()..mergeFromBuffer(data, registry);
  factory GetTwoWayPegDataResponse_ResponseItem.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTwoWayPegDataResponse_ResponseItem()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTwoWayPegDataResponse.ResponseItem',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetTwoWayPegDataResponse_ResponseItem.$_createMessage)
    ..aOM<BlockHeaderInfo>(1, _omitFieldNames ? '' : 'blockHeaderInfo', subBuilder: BlockHeaderInfo.$_createMessage)
    ..aOM<BlockInfo>(2, _omitFieldNames ? '' : 'blockInfo', subBuilder: BlockInfo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTwoWayPegDataResponse_ResponseItem clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTwoWayPegDataResponse_ResponseItem copyWith(void Function(GetTwoWayPegDataResponse_ResponseItem) updates) =>
      super.copyWith((message) => updates(message as GetTwoWayPegDataResponse_ResponseItem))
          as GetTwoWayPegDataResponse_ResponseItem;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetTwoWayPegDataResponse_ResponseItem() / GetTwoWayPegDataResponse_ResponseItem.new instead')
  static GetTwoWayPegDataResponse_ResponseItem create() => GetTwoWayPegDataResponse_ResponseItem._();
  static $pb.GeneratedMessage $_createMessage() => GetTwoWayPegDataResponse_ResponseItem._();
  @$core.override
  GetTwoWayPegDataResponse_ResponseItem createEmptyInstance() => GetTwoWayPegDataResponse_ResponseItem._();
  @$core.pragma('dart2js:noInline')
  static GetTwoWayPegDataResponse_ResponseItem getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetTwoWayPegDataResponse_ResponseItem>(
          GetTwoWayPegDataResponse_ResponseItem.$_createMessage);
  static GetTwoWayPegDataResponse_ResponseItem? _defaultInstance;

  @$pb.TagNumber(1)
  BlockHeaderInfo get blockHeaderInfo => $_getN(0);
  @$pb.TagNumber(1)
  set blockHeaderInfo(BlockHeaderInfo value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBlockHeaderInfo() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHeaderInfo() => $_clearField(1);
  @$pb.TagNumber(1)
  BlockHeaderInfo ensureBlockHeaderInfo() => $_ensure(0);

  @$pb.TagNumber(2)
  BlockInfo get blockInfo => $_getN(1);
  @$pb.TagNumber(2)
  set blockInfo(BlockInfo value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasBlockInfo() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlockInfo() => $_clearField(2);
  @$pb.TagNumber(2)
  BlockInfo ensureBlockInfo() => $_ensure(1);
}

class GetTwoWayPegDataResponse extends $pb.GeneratedMessage {
  factory GetTwoWayPegDataResponse({
    $core.Iterable<GetTwoWayPegDataResponse_ResponseItem>? blocks,
  }) {
    final result = GetTwoWayPegDataResponse._();
    if (blocks != null) result.blocks.addAll(blocks);
    return result;
  }

  GetTwoWayPegDataResponse._();

  factory GetTwoWayPegDataResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTwoWayPegDataResponse()..mergeFromBuffer(data, registry);
  factory GetTwoWayPegDataResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTwoWayPegDataResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTwoWayPegDataResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: GetTwoWayPegDataResponse.$_createMessage)
    ..pPM<GetTwoWayPegDataResponse_ResponseItem>(1, _omitFieldNames ? '' : 'blocks',
        subBuilder: GetTwoWayPegDataResponse_ResponseItem.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTwoWayPegDataResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTwoWayPegDataResponse copyWith(void Function(GetTwoWayPegDataResponse) updates) =>
      super.copyWith((message) => updates(message as GetTwoWayPegDataResponse)) as GetTwoWayPegDataResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetTwoWayPegDataResponse() / GetTwoWayPegDataResponse.new instead')
  static GetTwoWayPegDataResponse create() => GetTwoWayPegDataResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetTwoWayPegDataResponse._();
  @$core.override
  GetTwoWayPegDataResponse createEmptyInstance() => GetTwoWayPegDataResponse._();
  @$core.pragma('dart2js:noInline')
  static GetTwoWayPegDataResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTwoWayPegDataResponse>(GetTwoWayPegDataResponse.$_createMessage);
  static GetTwoWayPegDataResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<GetTwoWayPegDataResponse_ResponseItem> get blocks => $_getList(0);
}

class SubscribeEventsRequest extends $pb.GeneratedMessage {
  factory SubscribeEventsRequest({
    $1.UInt32Value? sidechainId,
  }) {
    final result = SubscribeEventsRequest._();
    if (sidechainId != null) result.sidechainId = sidechainId;
    return result;
  }

  SubscribeEventsRequest._();

  factory SubscribeEventsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscribeEventsRequest()..mergeFromBuffer(data, registry);
  factory SubscribeEventsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscribeEventsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubscribeEventsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: SubscribeEventsRequest.$_createMessage)
    ..aOM<$1.UInt32Value>(1, _omitFieldNames ? '' : 'sidechainId', subBuilder: $1.UInt32Value.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeEventsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeEventsRequest copyWith(void Function(SubscribeEventsRequest) updates) =>
      super.copyWith((message) => updates(message as SubscribeEventsRequest)) as SubscribeEventsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SubscribeEventsRequest() / SubscribeEventsRequest.new instead')
  static SubscribeEventsRequest create() => SubscribeEventsRequest._();
  static $pb.GeneratedMessage $_createMessage() => SubscribeEventsRequest._();
  @$core.override
  SubscribeEventsRequest createEmptyInstance() => SubscribeEventsRequest._();
  @$core.pragma('dart2js:noInline')
  static SubscribeEventsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubscribeEventsRequest>(SubscribeEventsRequest.$_createMessage);
  static SubscribeEventsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $1.UInt32Value get sidechainId => $_getN(0);
  @$pb.TagNumber(1)
  set sidechainId($1.UInt32Value value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSidechainId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainId() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.UInt32Value ensureSidechainId() => $_ensure(0);
}

class SubscribeEventsResponse_Event_ConnectBlock extends $pb.GeneratedMessage {
  factory SubscribeEventsResponse_Event_ConnectBlock({
    BlockHeaderInfo? headerInfo,
    BlockInfo? blockInfo,
  }) {
    final result = SubscribeEventsResponse_Event_ConnectBlock._();
    if (headerInfo != null) result.headerInfo = headerInfo;
    if (blockInfo != null) result.blockInfo = blockInfo;
    return result;
  }

  SubscribeEventsResponse_Event_ConnectBlock._();

  factory SubscribeEventsResponse_Event_ConnectBlock.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscribeEventsResponse_Event_ConnectBlock()..mergeFromBuffer(data, registry);
  factory SubscribeEventsResponse_Event_ConnectBlock.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscribeEventsResponse_Event_ConnectBlock()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubscribeEventsResponse.Event.ConnectBlock',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: SubscribeEventsResponse_Event_ConnectBlock.$_createMessage)
    ..aOM<BlockHeaderInfo>(1, _omitFieldNames ? '' : 'headerInfo', subBuilder: BlockHeaderInfo.$_createMessage)
    ..aOM<BlockInfo>(2, _omitFieldNames ? '' : 'blockInfo', subBuilder: BlockInfo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeEventsResponse_Event_ConnectBlock clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeEventsResponse_Event_ConnectBlock copyWith(
          void Function(SubscribeEventsResponse_Event_ConnectBlock) updates) =>
      super.copyWith((message) => updates(message as SubscribeEventsResponse_Event_ConnectBlock))
          as SubscribeEventsResponse_Event_ConnectBlock;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SubscribeEventsResponse_Event_ConnectBlock() / SubscribeEventsResponse_Event_ConnectBlock.new instead')
  static SubscribeEventsResponse_Event_ConnectBlock create() => SubscribeEventsResponse_Event_ConnectBlock._();
  static $pb.GeneratedMessage $_createMessage() => SubscribeEventsResponse_Event_ConnectBlock._();
  @$core.override
  SubscribeEventsResponse_Event_ConnectBlock createEmptyInstance() => SubscribeEventsResponse_Event_ConnectBlock._();
  @$core.pragma('dart2js:noInline')
  static SubscribeEventsResponse_Event_ConnectBlock getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubscribeEventsResponse_Event_ConnectBlock>(
          SubscribeEventsResponse_Event_ConnectBlock.$_createMessage);
  static SubscribeEventsResponse_Event_ConnectBlock? _defaultInstance;

  @$pb.TagNumber(1)
  BlockHeaderInfo get headerInfo => $_getN(0);
  @$pb.TagNumber(1)
  set headerInfo(BlockHeaderInfo value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasHeaderInfo() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeaderInfo() => $_clearField(1);
  @$pb.TagNumber(1)
  BlockHeaderInfo ensureHeaderInfo() => $_ensure(0);

  @$pb.TagNumber(2)
  BlockInfo get blockInfo => $_getN(1);
  @$pb.TagNumber(2)
  set blockInfo(BlockInfo value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasBlockInfo() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlockInfo() => $_clearField(2);
  @$pb.TagNumber(2)
  BlockInfo ensureBlockInfo() => $_ensure(1);
}

class SubscribeEventsResponse_Event_DisconnectBlock extends $pb.GeneratedMessage {
  factory SubscribeEventsResponse_Event_DisconnectBlock({
    $0.ReverseHex? blockHash,
  }) {
    final result = SubscribeEventsResponse_Event_DisconnectBlock._();
    if (blockHash != null) result.blockHash = blockHash;
    return result;
  }

  SubscribeEventsResponse_Event_DisconnectBlock._();

  factory SubscribeEventsResponse_Event_DisconnectBlock.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscribeEventsResponse_Event_DisconnectBlock()..mergeFromBuffer(data, registry);
  factory SubscribeEventsResponse_Event_DisconnectBlock.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscribeEventsResponse_Event_DisconnectBlock()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubscribeEventsResponse.Event.DisconnectBlock',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: SubscribeEventsResponse_Event_DisconnectBlock.$_createMessage)
    ..aOM<$0.ReverseHex>(1, _omitFieldNames ? '' : 'blockHash', subBuilder: $0.ReverseHex.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeEventsResponse_Event_DisconnectBlock clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeEventsResponse_Event_DisconnectBlock copyWith(
          void Function(SubscribeEventsResponse_Event_DisconnectBlock) updates) =>
      super.copyWith((message) => updates(message as SubscribeEventsResponse_Event_DisconnectBlock))
          as SubscribeEventsResponse_Event_DisconnectBlock;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SubscribeEventsResponse_Event_DisconnectBlock() / SubscribeEventsResponse_Event_DisconnectBlock.new instead')
  static SubscribeEventsResponse_Event_DisconnectBlock create() => SubscribeEventsResponse_Event_DisconnectBlock._();
  static $pb.GeneratedMessage $_createMessage() => SubscribeEventsResponse_Event_DisconnectBlock._();
  @$core.override
  SubscribeEventsResponse_Event_DisconnectBlock createEmptyInstance() =>
      SubscribeEventsResponse_Event_DisconnectBlock._();
  @$core.pragma('dart2js:noInline')
  static SubscribeEventsResponse_Event_DisconnectBlock getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubscribeEventsResponse_Event_DisconnectBlock>(
          SubscribeEventsResponse_Event_DisconnectBlock.$_createMessage);
  static SubscribeEventsResponse_Event_DisconnectBlock? _defaultInstance;

  @$pb.TagNumber(1)
  $0.ReverseHex get blockHash => $_getN(0);
  @$pb.TagNumber(1)
  set blockHash($0.ReverseHex value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBlockHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHash() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.ReverseHex ensureBlockHash() => $_ensure(0);
}

enum SubscribeEventsResponse_Event_Event { connectBlock, disconnectBlock, notSet }

class SubscribeEventsResponse_Event extends $pb.GeneratedMessage {
  factory SubscribeEventsResponse_Event({
    SubscribeEventsResponse_Event_ConnectBlock? connectBlock,
    SubscribeEventsResponse_Event_DisconnectBlock? disconnectBlock,
  }) {
    final result = SubscribeEventsResponse_Event._();
    if (connectBlock != null) result.connectBlock = connectBlock;
    if (disconnectBlock != null) result.disconnectBlock = disconnectBlock;
    return result;
  }

  SubscribeEventsResponse_Event._();

  factory SubscribeEventsResponse_Event.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscribeEventsResponse_Event()..mergeFromBuffer(data, registry);
  factory SubscribeEventsResponse_Event.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscribeEventsResponse_Event()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, SubscribeEventsResponse_Event_Event> _SubscribeEventsResponse_Event_EventByTag = {
    1: SubscribeEventsResponse_Event_Event.connectBlock,
    2: SubscribeEventsResponse_Event_Event.disconnectBlock,
    0: SubscribeEventsResponse_Event_Event.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubscribeEventsResponse.Event',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: SubscribeEventsResponse_Event.$_createMessage)
    ..oo(0, [1, 2])
    ..aOM<SubscribeEventsResponse_Event_ConnectBlock>(1, _omitFieldNames ? '' : 'connectBlock',
        subBuilder: SubscribeEventsResponse_Event_ConnectBlock.$_createMessage)
    ..aOM<SubscribeEventsResponse_Event_DisconnectBlock>(2, _omitFieldNames ? '' : 'disconnectBlock',
        subBuilder: SubscribeEventsResponse_Event_DisconnectBlock.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeEventsResponse_Event clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeEventsResponse_Event copyWith(void Function(SubscribeEventsResponse_Event) updates) =>
      super.copyWith((message) => updates(message as SubscribeEventsResponse_Event)) as SubscribeEventsResponse_Event;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SubscribeEventsResponse_Event() / SubscribeEventsResponse_Event.new instead')
  static SubscribeEventsResponse_Event create() => SubscribeEventsResponse_Event._();
  static $pb.GeneratedMessage $_createMessage() => SubscribeEventsResponse_Event._();
  @$core.override
  SubscribeEventsResponse_Event createEmptyInstance() => SubscribeEventsResponse_Event._();
  @$core.pragma('dart2js:noInline')
  static SubscribeEventsResponse_Event getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubscribeEventsResponse_Event>(SubscribeEventsResponse_Event.$_createMessage);
  static SubscribeEventsResponse_Event? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  SubscribeEventsResponse_Event_Event whichEvent() => _SubscribeEventsResponse_Event_EventByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  void clearEvent() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  SubscribeEventsResponse_Event_ConnectBlock get connectBlock => $_getN(0);
  @$pb.TagNumber(1)
  set connectBlock(SubscribeEventsResponse_Event_ConnectBlock value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasConnectBlock() => $_has(0);
  @$pb.TagNumber(1)
  void clearConnectBlock() => $_clearField(1);
  @$pb.TagNumber(1)
  SubscribeEventsResponse_Event_ConnectBlock ensureConnectBlock() => $_ensure(0);

  @$pb.TagNumber(2)
  SubscribeEventsResponse_Event_DisconnectBlock get disconnectBlock => $_getN(1);
  @$pb.TagNumber(2)
  set disconnectBlock(SubscribeEventsResponse_Event_DisconnectBlock value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDisconnectBlock() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisconnectBlock() => $_clearField(2);
  @$pb.TagNumber(2)
  SubscribeEventsResponse_Event_DisconnectBlock ensureDisconnectBlock() => $_ensure(1);
}

class SubscribeEventsResponse extends $pb.GeneratedMessage {
  factory SubscribeEventsResponse({
    SubscribeEventsResponse_Event? event,
  }) {
    final result = SubscribeEventsResponse._();
    if (event != null) result.event = event;
    return result;
  }

  SubscribeEventsResponse._();

  factory SubscribeEventsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscribeEventsResponse()..mergeFromBuffer(data, registry);
  factory SubscribeEventsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscribeEventsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubscribeEventsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: SubscribeEventsResponse.$_createMessage)
    ..aOM<SubscribeEventsResponse_Event>(1, _omitFieldNames ? '' : 'event',
        subBuilder: SubscribeEventsResponse_Event.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeEventsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeEventsResponse copyWith(void Function(SubscribeEventsResponse) updates) =>
      super.copyWith((message) => updates(message as SubscribeEventsResponse)) as SubscribeEventsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SubscribeEventsResponse() / SubscribeEventsResponse.new instead')
  static SubscribeEventsResponse create() => SubscribeEventsResponse._();
  static $pb.GeneratedMessage $_createMessage() => SubscribeEventsResponse._();
  @$core.override
  SubscribeEventsResponse createEmptyInstance() => SubscribeEventsResponse._();
  @$core.pragma('dart2js:noInline')
  static SubscribeEventsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubscribeEventsResponse>(SubscribeEventsResponse.$_createMessage);
  static SubscribeEventsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SubscribeEventsResponse_Event get event => $_getN(0);
  @$pb.TagNumber(1)
  set event(SubscribeEventsResponse_Event value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasEvent() => $_has(0);
  @$pb.TagNumber(1)
  void clearEvent() => $_clearField(1);
  @$pb.TagNumber(1)
  SubscribeEventsResponse_Event ensureEvent() => $_ensure(0);
}

class SubscribeHeaderSyncProgressRequest extends $pb.GeneratedMessage {
  factory SubscribeHeaderSyncProgressRequest() => SubscribeHeaderSyncProgressRequest._();

  SubscribeHeaderSyncProgressRequest._();

  factory SubscribeHeaderSyncProgressRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscribeHeaderSyncProgressRequest()..mergeFromBuffer(data, registry);
  factory SubscribeHeaderSyncProgressRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscribeHeaderSyncProgressRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubscribeHeaderSyncProgressRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: SubscribeHeaderSyncProgressRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeHeaderSyncProgressRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeHeaderSyncProgressRequest copyWith(void Function(SubscribeHeaderSyncProgressRequest) updates) =>
      super.copyWith((message) => updates(message as SubscribeHeaderSyncProgressRequest))
          as SubscribeHeaderSyncProgressRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SubscribeHeaderSyncProgressRequest() / SubscribeHeaderSyncProgressRequest.new instead')
  static SubscribeHeaderSyncProgressRequest create() => SubscribeHeaderSyncProgressRequest._();
  static $pb.GeneratedMessage $_createMessage() => SubscribeHeaderSyncProgressRequest._();
  @$core.override
  SubscribeHeaderSyncProgressRequest createEmptyInstance() => SubscribeHeaderSyncProgressRequest._();
  @$core.pragma('dart2js:noInline')
  static SubscribeHeaderSyncProgressRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubscribeHeaderSyncProgressRequest>(
          SubscribeHeaderSyncProgressRequest.$_createMessage);
  static SubscribeHeaderSyncProgressRequest? _defaultInstance;
}

class SubscribeHeaderSyncProgressResponse extends $pb.GeneratedMessage {
  factory SubscribeHeaderSyncProgressResponse({
    $1.UInt32Value? currentHeight,
  }) {
    final result = SubscribeHeaderSyncProgressResponse._();
    if (currentHeight != null) result.currentHeight = currentHeight;
    return result;
  }

  SubscribeHeaderSyncProgressResponse._();

  factory SubscribeHeaderSyncProgressResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscribeHeaderSyncProgressResponse()..mergeFromBuffer(data, registry);
  factory SubscribeHeaderSyncProgressResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscribeHeaderSyncProgressResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubscribeHeaderSyncProgressResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: SubscribeHeaderSyncProgressResponse.$_createMessage)
    ..aOM<$1.UInt32Value>(1, _omitFieldNames ? '' : 'currentHeight', subBuilder: $1.UInt32Value.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeHeaderSyncProgressResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeHeaderSyncProgressResponse copyWith(void Function(SubscribeHeaderSyncProgressResponse) updates) =>
      super.copyWith((message) => updates(message as SubscribeHeaderSyncProgressResponse))
          as SubscribeHeaderSyncProgressResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SubscribeHeaderSyncProgressResponse() / SubscribeHeaderSyncProgressResponse.new instead')
  static SubscribeHeaderSyncProgressResponse create() => SubscribeHeaderSyncProgressResponse._();
  static $pb.GeneratedMessage $_createMessage() => SubscribeHeaderSyncProgressResponse._();
  @$core.override
  SubscribeHeaderSyncProgressResponse createEmptyInstance() => SubscribeHeaderSyncProgressResponse._();
  @$core.pragma('dart2js:noInline')
  static SubscribeHeaderSyncProgressResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubscribeHeaderSyncProgressResponse>(
          SubscribeHeaderSyncProgressResponse.$_createMessage);
  static SubscribeHeaderSyncProgressResponse? _defaultInstance;

  /// Current sync height may be unknown at the start of a sync
  @$pb.TagNumber(1)
  $1.UInt32Value get currentHeight => $_getN(0);
  @$pb.TagNumber(1)
  set currentHeight($1.UInt32Value value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasCurrentHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearCurrentHeight() => $_clearField(1);
  @$pb.TagNumber(1)
  $1.UInt32Value ensureCurrentHeight() => $_ensure(0);
}

class StopRequest extends $pb.GeneratedMessage {
  factory StopRequest() => StopRequest._();

  StopRequest._();

  factory StopRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StopRequest()..mergeFromBuffer(data, registry);
  factory StopRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StopRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StopRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: StopRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopRequest copyWith(void Function(StopRequest) updates) =>
      super.copyWith((message) => updates(message as StopRequest)) as StopRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StopRequest() / StopRequest.new instead')
  static StopRequest create() => StopRequest._();
  static $pb.GeneratedMessage $_createMessage() => StopRequest._();
  @$core.override
  StopRequest createEmptyInstance() => StopRequest._();
  @$core.pragma('dart2js:noInline')
  static StopRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StopRequest>(StopRequest.$_createMessage);
  static StopRequest? _defaultInstance;
}

class StopResponse extends $pb.GeneratedMessage {
  factory StopResponse() => StopResponse._();

  StopResponse._();

  factory StopResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StopResponse()..mergeFromBuffer(data, registry);
  factory StopResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StopResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StopResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'),
      createEmptyInstance: StopResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopResponse copyWith(void Function(StopResponse) updates) =>
      super.copyWith((message) => updates(message as StopResponse)) as StopResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StopResponse() / StopResponse.new instead')
  static StopResponse create() => StopResponse._();
  static $pb.GeneratedMessage $_createMessage() => StopResponse._();
  @$core.override
  StopResponse createEmptyInstance() => StopResponse._();
  @$core.pragma('dart2js:noInline')
  static StopResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StopResponse>(StopResponse.$_createMessage);
  static StopResponse? _defaultInstance;
}

class ValidatorServiceApi {
  final $pb.RpcClient _client;

  ValidatorServiceApi(this._client);

  /// Fetches information about a specific mainchain block header,
  /// and optionally, it's ancestors
  $async.Future<GetBlockHeaderInfoResponse> getBlockHeaderInfo(
          $pb.ClientContext? ctx, GetBlockHeaderInfoRequest request) =>
      _client.invoke<GetBlockHeaderInfoResponse>(
          ctx, 'ValidatorService', 'GetBlockHeaderInfo', request, GetBlockHeaderInfoResponse());

  /// Fetches information about a specific mainchain block (and optionally,
  /// it's ancestors), regarding how it pertains to events happening on a
  /// specific sidechain.
  $async.Future<GetBlockInfoResponse> getBlockInfo($pb.ClientContext? ctx, GetBlockInfoRequest request) =>
      _client.invoke<GetBlockInfoResponse>(ctx, 'ValidatorService', 'GetBlockInfo', request, GetBlockInfoResponse());

  /// Fetches BMM h* commitment for a specific mainchain block,
  /// and optionally, it's ancestors
  $async.Future<GetBmmHStarCommitmentResponse> getBmmHStarCommitment(
          $pb.ClientContext? ctx, GetBmmHStarCommitmentRequest request) =>
      _client.invoke<GetBmmHStarCommitmentResponse>(
          ctx, 'ValidatorService', 'GetBmmHStarCommitment', request, GetBmmHStarCommitmentResponse());
  $async.Future<GetChainInfoResponse> getChainInfo($pb.ClientContext? ctx, GetChainInfoRequest request) =>
      _client.invoke<GetChainInfoResponse>(ctx, 'ValidatorService', 'GetChainInfo', request, GetChainInfoResponse());
  $async.Future<GetChainTipResponse> getChainTip($pb.ClientContext? ctx, GetChainTipRequest request) =>
      _client.invoke<GetChainTipResponse>(ctx, 'ValidatorService', 'GetChainTip', request, GetChainTipResponse());
  $async.Future<GetCoinbasePSBTResponse> getCoinbasePSBT($pb.ClientContext? ctx, GetCoinbasePSBTRequest request) =>
      _client.invoke<GetCoinbasePSBTResponse>(
          ctx, 'ValidatorService', 'GetCoinbasePSBT', request, GetCoinbasePSBTResponse());
  $async.Future<GetCtipResponse> getCtip($pb.ClientContext? ctx, GetCtipRequest request) =>
      _client.invoke<GetCtipResponse>(ctx, 'ValidatorService', 'GetCtip', request, GetCtipResponse());
  $async.Future<GetSidechainProposalsResponse> getSidechainProposals(
          $pb.ClientContext? ctx, GetSidechainProposalsRequest request) =>
      _client.invoke<GetSidechainProposalsResponse>(
          ctx, 'ValidatorService', 'GetSidechainProposals', request, GetSidechainProposalsResponse());
  $async.Future<GetSidechainsResponse> getSidechains($pb.ClientContext? ctx, GetSidechainsRequest request) =>
      _client.invoke<GetSidechainsResponse>(ctx, 'ValidatorService', 'GetSidechains', request, GetSidechainsResponse());
  $async.Future<GetTwoWayPegDataResponse> getTwoWayPegData($pb.ClientContext? ctx, GetTwoWayPegDataRequest request) =>
      _client.invoke<GetTwoWayPegDataResponse>(
          ctx, 'ValidatorService', 'GetTwoWayPegData', request, GetTwoWayPegDataResponse());
  $async.Future<SubscribeEventsResponse> subscribeEvents($pb.ClientContext? ctx, SubscribeEventsRequest request) =>
      _client.invoke<SubscribeEventsResponse>(
          ctx, 'ValidatorService', 'SubscribeEvents', request, SubscribeEventsResponse());

  /// Stream header sync progress updates
  $async.Future<SubscribeHeaderSyncProgressResponse> subscribeHeaderSyncProgress(
          $pb.ClientContext? ctx, SubscribeHeaderSyncProgressRequest request) =>
      _client.invoke<SubscribeHeaderSyncProgressResponse>(
          ctx, 'ValidatorService', 'SubscribeHeaderSyncProgress', request, SubscribeHeaderSyncProgressResponse());

  /// Safely shutdown the validator. This is equivalent to sending a SIGINT
  /// to the validator process, and can be used to trigger a graceful shutdown
  /// in cases where you don't have access to the validator process.
  $async.Future<StopResponse> stop($pb.ClientContext? ctx, StopRequest request) =>
      _client.invoke<StopResponse>(ctx, 'ValidatorService', 'Stop', request, StopResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
