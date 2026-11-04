// This is a generated file - do not edit.
//
// Generated from notification/v1/notification.proto.

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

import 'notification.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'notification.pbenum.dart';

enum WatchResponse_Event { transaction, timestampEvent, system, sidechainWithdrawal, notSet }

class WatchResponse extends $pb.GeneratedMessage {
  factory WatchResponse({
    $0.Timestamp? timestamp,
    TransactionEvent? transaction,
    TimestampEvent? timestampEvent,
    SystemEvent? system,
    SidechainWithdrawalEvent? sidechainWithdrawal,
  }) {
    final result = WatchResponse._();
    if (timestamp != null) result.timestamp = timestamp;
    if (transaction != null) result.transaction = transaction;
    if (timestampEvent != null) result.timestampEvent = timestampEvent;
    if (system != null) result.system = system;
    if (sidechainWithdrawal != null) result.sidechainWithdrawal = sidechainWithdrawal;
    return result;
  }

  WatchResponse._();

  factory WatchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchResponse()..mergeFromBuffer(data, registry);
  factory WatchResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchResponse()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, WatchResponse_Event> _WatchResponse_EventByTag = {
    2: WatchResponse_Event.transaction,
    3: WatchResponse_Event.timestampEvent,
    4: WatchResponse_Event.system,
    5: WatchResponse_Event.sidechainWithdrawal,
    0: WatchResponse_Event.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WatchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'notification.v1'),
      createEmptyInstance: WatchResponse.$_createMessage)
    ..oo(0, [2, 3, 4, 5])
    ..aOM<$0.Timestamp>(1, _omitFieldNames ? '' : 'timestamp', subBuilder: $0.Timestamp.$_createMessage)
    ..aOM<TransactionEvent>(2, _omitFieldNames ? '' : 'transaction', subBuilder: TransactionEvent.$_createMessage)
    ..aOM<TimestampEvent>(3, _omitFieldNames ? '' : 'timestampEvent', subBuilder: TimestampEvent.$_createMessage)
    ..aOM<SystemEvent>(4, _omitFieldNames ? '' : 'system', subBuilder: SystemEvent.$_createMessage)
    ..aOM<SidechainWithdrawalEvent>(5, _omitFieldNames ? '' : 'sidechainWithdrawal',
        subBuilder: SidechainWithdrawalEvent.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchResponse copyWith(void Function(WatchResponse) updates) =>
      super.copyWith((message) => updates(message as WatchResponse)) as WatchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WatchResponse() / WatchResponse.new instead')
  static WatchResponse create() => WatchResponse._();
  static $pb.GeneratedMessage $_createMessage() => WatchResponse._();
  @$core.override
  WatchResponse createEmptyInstance() => WatchResponse._();
  @$core.pragma('dart2js:noInline')
  static WatchResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WatchResponse>(WatchResponse.$_createMessage);
  static WatchResponse? _defaultInstance;

  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  WatchResponse_Event whichEvent() => _WatchResponse_EventByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  @$pb.TagNumber(5)
  void clearEvent() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $0.Timestamp get timestamp => $_getN(0);
  @$pb.TagNumber(1)
  set timestamp($0.Timestamp value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimestamp() => $_clearField(1);
  @$pb.TagNumber(1)
  $0.Timestamp ensureTimestamp() => $_ensure(0);

  @$pb.TagNumber(2)
  TransactionEvent get transaction => $_getN(1);
  @$pb.TagNumber(2)
  set transaction(TransactionEvent value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasTransaction() => $_has(1);
  @$pb.TagNumber(2)
  void clearTransaction() => $_clearField(2);
  @$pb.TagNumber(2)
  TransactionEvent ensureTransaction() => $_ensure(1);

  @$pb.TagNumber(3)
  TimestampEvent get timestampEvent => $_getN(2);
  @$pb.TagNumber(3)
  set timestampEvent(TimestampEvent value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestampEvent() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestampEvent() => $_clearField(3);
  @$pb.TagNumber(3)
  TimestampEvent ensureTimestampEvent() => $_ensure(2);

  @$pb.TagNumber(4)
  SystemEvent get system => $_getN(3);
  @$pb.TagNumber(4)
  set system(SystemEvent value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasSystem() => $_has(3);
  @$pb.TagNumber(4)
  void clearSystem() => $_clearField(4);
  @$pb.TagNumber(4)
  SystemEvent ensureSystem() => $_ensure(3);

  @$pb.TagNumber(5)
  SidechainWithdrawalEvent get sidechainWithdrawal => $_getN(4);
  @$pb.TagNumber(5)
  set sidechainWithdrawal(SidechainWithdrawalEvent value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasSidechainWithdrawal() => $_has(4);
  @$pb.TagNumber(5)
  void clearSidechainWithdrawal() => $_clearField(5);
  @$pb.TagNumber(5)
  SidechainWithdrawalEvent ensureSidechainWithdrawal() => $_ensure(4);
}

class TransactionEvent extends $pb.GeneratedMessage {
  factory TransactionEvent({
    TransactionEvent_Type? type,
    $core.String? txid,
    $fixnum.Int64? amountSats,
    $core.int? confirmations,
  }) {
    final result = TransactionEvent._();
    if (type != null) result.type = type;
    if (txid != null) result.txid = txid;
    if (amountSats != null) result.amountSats = amountSats;
    if (confirmations != null) result.confirmations = confirmations;
    return result;
  }

  TransactionEvent._();

  factory TransactionEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransactionEvent()..mergeFromBuffer(data, registry);
  factory TransactionEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransactionEvent()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransactionEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'notification.v1'),
      createEmptyInstance: TransactionEvent.$_createMessage)
    ..aE<TransactionEvent_Type>(1, _omitFieldNames ? '' : 'type', enumValues: TransactionEvent_Type.values)
    ..aOS(2, _omitFieldNames ? '' : 'txid')
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'amountSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(4, _omitFieldNames ? '' : 'confirmations', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransactionEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransactionEvent copyWith(void Function(TransactionEvent) updates) =>
      super.copyWith((message) => updates(message as TransactionEvent)) as TransactionEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TransactionEvent() / TransactionEvent.new instead')
  static TransactionEvent create() => TransactionEvent._();
  static $pb.GeneratedMessage $_createMessage() => TransactionEvent._();
  @$core.override
  TransactionEvent createEmptyInstance() => TransactionEvent._();
  @$core.pragma('dart2js:noInline')
  static TransactionEvent getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransactionEvent>(TransactionEvent.$_createMessage);
  static TransactionEvent? _defaultInstance;

  @$pb.TagNumber(1)
  TransactionEvent_Type get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(TransactionEvent_Type value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get txid => $_getSZ(1);
  @$pb.TagNumber(2)
  set txid($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearTxid() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get amountSats => $_getI64(2);
  @$pb.TagNumber(3)
  set amountSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAmountSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmountSats() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get confirmations => $_getIZ(3);
  @$pb.TagNumber(4)
  set confirmations($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConfirmations() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfirmations() => $_clearField(4);
}

class TimestampEvent extends $pb.GeneratedMessage {
  factory TimestampEvent({
    TimestampEvent_Type? type,
    $fixnum.Int64? id,
    $core.String? filename,
    $core.String? txid,
    $fixnum.Int64? blockHeight,
  }) {
    final result = TimestampEvent._();
    if (type != null) result.type = type;
    if (id != null) result.id = id;
    if (filename != null) result.filename = filename;
    if (txid != null) result.txid = txid;
    if (blockHeight != null) result.blockHeight = blockHeight;
    return result;
  }

  TimestampEvent._();

  factory TimestampEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimestampEvent()..mergeFromBuffer(data, registry);
  factory TimestampEvent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimestampEvent()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TimestampEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'notification.v1'),
      createEmptyInstance: TimestampEvent.$_createMessage)
    ..aE<TimestampEvent_Type>(1, _omitFieldNames ? '' : 'type', enumValues: TimestampEvent_Type.values)
    ..aInt64(2, _omitFieldNames ? '' : 'id')
    ..aOS(3, _omitFieldNames ? '' : 'filename')
    ..aOS(4, _omitFieldNames ? '' : 'txid')
    ..aInt64(5, _omitFieldNames ? '' : 'blockHeight')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimestampEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimestampEvent copyWith(void Function(TimestampEvent) updates) =>
      super.copyWith((message) => updates(message as TimestampEvent)) as TimestampEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TimestampEvent() / TimestampEvent.new instead')
  static TimestampEvent create() => TimestampEvent._();
  static $pb.GeneratedMessage $_createMessage() => TimestampEvent._();
  @$core.override
  TimestampEvent createEmptyInstance() => TimestampEvent._();
  @$core.pragma('dart2js:noInline')
  static TimestampEvent getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TimestampEvent>(TimestampEvent.$_createMessage);
  static TimestampEvent? _defaultInstance;

  @$pb.TagNumber(1)
  TimestampEvent_Type get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(TimestampEvent_Type value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get id => $_getI64(1);
  @$pb.TagNumber(2)
  set id($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get filename => $_getSZ(2);
  @$pb.TagNumber(3)
  set filename($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFilename() => $_has(2);
  @$pb.TagNumber(3)
  void clearFilename() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get txid => $_getSZ(3);
  @$pb.TagNumber(4)
  set txid($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTxid() => $_has(3);
  @$pb.TagNumber(4)
  void clearTxid() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get blockHeight => $_getI64(4);
  @$pb.TagNumber(5)
  set blockHeight($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBlockHeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearBlockHeight() => $_clearField(5);
}

class SystemEvent extends $pb.GeneratedMessage {
  factory SystemEvent({
    SystemEvent_Type? type,
    $core.String? message,
  }) {
    final result = SystemEvent._();
    if (type != null) result.type = type;
    if (message != null) result.message = message;
    return result;
  }

  SystemEvent._();

  factory SystemEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SystemEvent()..mergeFromBuffer(data, registry);
  factory SystemEvent.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SystemEvent()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SystemEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'notification.v1'),
      createEmptyInstance: SystemEvent.$_createMessage)
    ..aE<SystemEvent_Type>(1, _omitFieldNames ? '' : 'type', enumValues: SystemEvent_Type.values)
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SystemEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SystemEvent copyWith(void Function(SystemEvent) updates) =>
      super.copyWith((message) => updates(message as SystemEvent)) as SystemEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SystemEvent() / SystemEvent.new instead')
  static SystemEvent create() => SystemEvent._();
  static $pb.GeneratedMessage $_createMessage() => SystemEvent._();
  @$core.override
  SystemEvent createEmptyInstance() => SystemEvent._();
  @$core.pragma('dart2js:noInline')
  static SystemEvent getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SystemEvent>(SystemEvent.$_createMessage);
  static SystemEvent? _defaultInstance;

  @$pb.TagNumber(1)
  SystemEvent_Type get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(SystemEvent_Type value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

class SidechainWithdrawalEvent extends $pb.GeneratedMessage {
  factory SidechainWithdrawalEvent({
    SidechainWithdrawalEvent_Type? type,
    $core.String? txid,
    $core.String? sidechain,
    $fixnum.Int64? amount,
    $core.String? destination,
    $0.Timestamp? detectedAt,
    $core.String? blockHash,
  }) {
    final result = SidechainWithdrawalEvent._();
    if (type != null) result.type = type;
    if (txid != null) result.txid = txid;
    if (sidechain != null) result.sidechain = sidechain;
    if (amount != null) result.amount = amount;
    if (destination != null) result.destination = destination;
    if (detectedAt != null) result.detectedAt = detectedAt;
    if (blockHash != null) result.blockHash = blockHash;
    return result;
  }

  SidechainWithdrawalEvent._();

  factory SidechainWithdrawalEvent.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SidechainWithdrawalEvent()..mergeFromBuffer(data, registry);
  factory SidechainWithdrawalEvent.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SidechainWithdrawalEvent()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SidechainWithdrawalEvent',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'notification.v1'),
      createEmptyInstance: SidechainWithdrawalEvent.$_createMessage)
    ..aE<SidechainWithdrawalEvent_Type>(1, _omitFieldNames ? '' : 'type',
        enumValues: SidechainWithdrawalEvent_Type.values)
    ..aOS(2, _omitFieldNames ? '' : 'txid')
    ..aOS(3, _omitFieldNames ? '' : 'sidechain')
    ..aInt64(4, _omitFieldNames ? '' : 'amount')
    ..aOS(5, _omitFieldNames ? '' : 'destination')
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'detectedAt', subBuilder: $0.Timestamp.$_createMessage)
    ..aOS(7, _omitFieldNames ? '' : 'blockHash')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SidechainWithdrawalEvent clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SidechainWithdrawalEvent copyWith(void Function(SidechainWithdrawalEvent) updates) =>
      super.copyWith((message) => updates(message as SidechainWithdrawalEvent)) as SidechainWithdrawalEvent;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SidechainWithdrawalEvent() / SidechainWithdrawalEvent.new instead')
  static SidechainWithdrawalEvent create() => SidechainWithdrawalEvent._();
  static $pb.GeneratedMessage $_createMessage() => SidechainWithdrawalEvent._();
  @$core.override
  SidechainWithdrawalEvent createEmptyInstance() => SidechainWithdrawalEvent._();
  @$core.pragma('dart2js:noInline')
  static SidechainWithdrawalEvent getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SidechainWithdrawalEvent>(SidechainWithdrawalEvent.$_createMessage);
  static SidechainWithdrawalEvent? _defaultInstance;

  @$pb.TagNumber(1)
  SidechainWithdrawalEvent_Type get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(SidechainWithdrawalEvent_Type value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get txid => $_getSZ(1);
  @$pb.TagNumber(2)
  set txid($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearTxid() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get sidechain => $_getSZ(2);
  @$pb.TagNumber(3)
  set sidechain($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSidechain() => $_has(2);
  @$pb.TagNumber(3)
  void clearSidechain() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get amount => $_getI64(3);
  @$pb.TagNumber(4)
  set amount($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAmount() => $_has(3);
  @$pb.TagNumber(4)
  void clearAmount() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get destination => $_getSZ(4);
  @$pb.TagNumber(5)
  set destination($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDestination() => $_has(4);
  @$pb.TagNumber(5)
  void clearDestination() => $_clearField(5);

  @$pb.TagNumber(6)
  $0.Timestamp get detectedAt => $_getN(5);
  @$pb.TagNumber(6)
  set detectedAt($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasDetectedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearDetectedAt() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureDetectedAt() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.String get blockHash => $_getSZ(6);
  @$pb.TagNumber(7)
  set blockHash($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasBlockHash() => $_has(6);
  @$pb.TagNumber(7)
  void clearBlockHash() => $_clearField(7);
}

class NotificationServiceApi {
  final $pb.RpcClient _client;

  NotificationServiceApi(this._client);

  /// Watch returns a stream of notification events
  $async.Future<WatchResponse> watch($pb.ClientContext? ctx, $1.Empty request) =>
      _client.invoke<WatchResponse>(ctx, 'NotificationService', 'Watch', request, WatchResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
