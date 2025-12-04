//
//  Generated code. Do not modify.
//  source: notification/v1/notification.proto
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
import 'notification.pbenum.dart';

export 'notification.pbenum.dart';

enum WatchResponse_Event {
  transaction, 
  timestampEvent, 
  system, 
  notSet
}

class WatchResponse extends $pb.GeneratedMessage {
  factory WatchResponse({
    $0.Timestamp? timestamp,
    TransactionEvent? transaction,
    TimestampEvent? timestampEvent,
    SystemEvent? system,
  }) {
    final $result = create();
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    if (transaction != null) {
      $result.transaction = transaction;
    }
    if (timestampEvent != null) {
      $result.timestampEvent = timestampEvent;
    }
    if (system != null) {
      $result.system = system;
    }
    return $result;
  }
  WatchResponse._() : super();
  factory WatchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WatchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, WatchResponse_Event> _WatchResponse_EventByTag = {
    2 : WatchResponse_Event.transaction,
    3 : WatchResponse_Event.timestampEvent,
    4 : WatchResponse_Event.system,
    0 : WatchResponse_Event.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WatchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'notification.v1'), createEmptyInstance: create)
    ..oo(0, [2, 3, 4])
    ..aOM<$0.Timestamp>(1, _omitFieldNames ? '' : 'timestamp', subBuilder: $0.Timestamp.create)
    ..aOM<TransactionEvent>(2, _omitFieldNames ? '' : 'transaction', subBuilder: TransactionEvent.create)
    ..aOM<TimestampEvent>(3, _omitFieldNames ? '' : 'timestampEvent', subBuilder: TimestampEvent.create)
    ..aOM<SystemEvent>(4, _omitFieldNames ? '' : 'system', subBuilder: SystemEvent.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WatchResponse clone() => WatchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WatchResponse copyWith(void Function(WatchResponse) updates) => super.copyWith((message) => updates(message as WatchResponse)) as WatchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WatchResponse create() => WatchResponse._();
  WatchResponse createEmptyInstance() => create();
  static $pb.PbList<WatchResponse> createRepeated() => $pb.PbList<WatchResponse>();
  @$core.pragma('dart2js:noInline')
  static WatchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WatchResponse>(create);
  static WatchResponse? _defaultInstance;

  WatchResponse_Event whichEvent() => _WatchResponse_EventByTag[$_whichOneof(0)]!;
  void clearEvent() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $0.Timestamp get timestamp => $_getN(0);
  @$pb.TagNumber(1)
  set timestamp($0.Timestamp v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimestamp() => clearField(1);
  @$pb.TagNumber(1)
  $0.Timestamp ensureTimestamp() => $_ensure(0);

  @$pb.TagNumber(2)
  TransactionEvent get transaction => $_getN(1);
  @$pb.TagNumber(2)
  set transaction(TransactionEvent v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasTransaction() => $_has(1);
  @$pb.TagNumber(2)
  void clearTransaction() => clearField(2);
  @$pb.TagNumber(2)
  TransactionEvent ensureTransaction() => $_ensure(1);

  @$pb.TagNumber(3)
  TimestampEvent get timestampEvent => $_getN(2);
  @$pb.TagNumber(3)
  set timestampEvent(TimestampEvent v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasTimestampEvent() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestampEvent() => clearField(3);
  @$pb.TagNumber(3)
  TimestampEvent ensureTimestampEvent() => $_ensure(2);

  @$pb.TagNumber(4)
  SystemEvent get system => $_getN(3);
  @$pb.TagNumber(4)
  set system(SystemEvent v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasSystem() => $_has(3);
  @$pb.TagNumber(4)
  void clearSystem() => clearField(4);
  @$pb.TagNumber(4)
  SystemEvent ensureSystem() => $_ensure(3);
}

class TransactionEvent extends $pb.GeneratedMessage {
  factory TransactionEvent({
    TransactionEvent_Type? type,
    $core.String? txid,
    $fixnum.Int64? amountSats,
    $core.int? confirmations,
  }) {
    final $result = create();
    if (type != null) {
      $result.type = type;
    }
    if (txid != null) {
      $result.txid = txid;
    }
    if (amountSats != null) {
      $result.amountSats = amountSats;
    }
    if (confirmations != null) {
      $result.confirmations = confirmations;
    }
    return $result;
  }
  TransactionEvent._() : super();
  factory TransactionEvent.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TransactionEvent.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransactionEvent', package: const $pb.PackageName(_omitMessageNames ? '' : 'notification.v1'), createEmptyInstance: create)
    ..e<TransactionEvent_Type>(1, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE, defaultOrMaker: TransactionEvent_Type.TYPE_UNSPECIFIED, valueOf: TransactionEvent_Type.valueOf, enumValues: TransactionEvent_Type.values)
    ..aOS(2, _omitFieldNames ? '' : 'txid')
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'amountSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'confirmations', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TransactionEvent clone() => TransactionEvent()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TransactionEvent copyWith(void Function(TransactionEvent) updates) => super.copyWith((message) => updates(message as TransactionEvent)) as TransactionEvent;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransactionEvent create() => TransactionEvent._();
  TransactionEvent createEmptyInstance() => create();
  static $pb.PbList<TransactionEvent> createRepeated() => $pb.PbList<TransactionEvent>();
  @$core.pragma('dart2js:noInline')
  static TransactionEvent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransactionEvent>(create);
  static TransactionEvent? _defaultInstance;

  @$pb.TagNumber(1)
  TransactionEvent_Type get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(TransactionEvent_Type v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get txid => $_getSZ(1);
  @$pb.TagNumber(2)
  set txid($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearTxid() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get amountSats => $_getI64(2);
  @$pb.TagNumber(3)
  set amountSats($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAmountSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmountSats() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get confirmations => $_getIZ(3);
  @$pb.TagNumber(4)
  set confirmations($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasConfirmations() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfirmations() => clearField(4);
}

class TimestampEvent extends $pb.GeneratedMessage {
  factory TimestampEvent({
    TimestampEvent_Type? type,
    $fixnum.Int64? id,
    $core.String? filename,
    $core.String? txid,
    $fixnum.Int64? blockHeight,
  }) {
    final $result = create();
    if (type != null) {
      $result.type = type;
    }
    if (id != null) {
      $result.id = id;
    }
    if (filename != null) {
      $result.filename = filename;
    }
    if (txid != null) {
      $result.txid = txid;
    }
    if (blockHeight != null) {
      $result.blockHeight = blockHeight;
    }
    return $result;
  }
  TimestampEvent._() : super();
  factory TimestampEvent.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TimestampEvent.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TimestampEvent', package: const $pb.PackageName(_omitMessageNames ? '' : 'notification.v1'), createEmptyInstance: create)
    ..e<TimestampEvent_Type>(1, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE, defaultOrMaker: TimestampEvent_Type.TYPE_UNSPECIFIED, valueOf: TimestampEvent_Type.valueOf, enumValues: TimestampEvent_Type.values)
    ..aInt64(2, _omitFieldNames ? '' : 'id')
    ..aOS(3, _omitFieldNames ? '' : 'filename')
    ..aOS(4, _omitFieldNames ? '' : 'txid')
    ..aInt64(5, _omitFieldNames ? '' : 'blockHeight')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TimestampEvent clone() => TimestampEvent()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TimestampEvent copyWith(void Function(TimestampEvent) updates) => super.copyWith((message) => updates(message as TimestampEvent)) as TimestampEvent;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TimestampEvent create() => TimestampEvent._();
  TimestampEvent createEmptyInstance() => create();
  static $pb.PbList<TimestampEvent> createRepeated() => $pb.PbList<TimestampEvent>();
  @$core.pragma('dart2js:noInline')
  static TimestampEvent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TimestampEvent>(create);
  static TimestampEvent? _defaultInstance;

  @$pb.TagNumber(1)
  TimestampEvent_Type get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(TimestampEvent_Type v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get id => $_getI64(1);
  @$pb.TagNumber(2)
  set id($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasId() => $_has(1);
  @$pb.TagNumber(2)
  void clearId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get filename => $_getSZ(2);
  @$pb.TagNumber(3)
  set filename($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFilename() => $_has(2);
  @$pb.TagNumber(3)
  void clearFilename() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get txid => $_getSZ(3);
  @$pb.TagNumber(4)
  set txid($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTxid() => $_has(3);
  @$pb.TagNumber(4)
  void clearTxid() => clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get blockHeight => $_getI64(4);
  @$pb.TagNumber(5)
  set blockHeight($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasBlockHeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearBlockHeight() => clearField(5);
}

class SystemEvent extends $pb.GeneratedMessage {
  factory SystemEvent({
    SystemEvent_Type? type,
    $core.String? message,
  }) {
    final $result = create();
    if (type != null) {
      $result.type = type;
    }
    if (message != null) {
      $result.message = message;
    }
    return $result;
  }
  SystemEvent._() : super();
  factory SystemEvent.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SystemEvent.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SystemEvent', package: const $pb.PackageName(_omitMessageNames ? '' : 'notification.v1'), createEmptyInstance: create)
    ..e<SystemEvent_Type>(1, _omitFieldNames ? '' : 'type', $pb.PbFieldType.OE, defaultOrMaker: SystemEvent_Type.TYPE_UNSPECIFIED, valueOf: SystemEvent_Type.valueOf, enumValues: SystemEvent_Type.values)
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SystemEvent clone() => SystemEvent()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SystemEvent copyWith(void Function(SystemEvent) updates) => super.copyWith((message) => updates(message as SystemEvent)) as SystemEvent;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SystemEvent create() => SystemEvent._();
  SystemEvent createEmptyInstance() => create();
  static $pb.PbList<SystemEvent> createRepeated() => $pb.PbList<SystemEvent>();
  @$core.pragma('dart2js:noInline')
  static SystemEvent getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SystemEvent>(create);
  static SystemEvent? _defaultInstance;

  @$pb.TagNumber(1)
  SystemEvent_Type get type => $_getN(0);
  @$pb.TagNumber(1)
  set type(SystemEvent_Type v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);
}

class NotificationServiceApi {
  $pb.RpcClient _client;
  NotificationServiceApi(this._client);

  $async.Future<WatchResponse> watch($pb.ClientContext? ctx, $1.Empty request) =>
    _client.invoke<WatchResponse>(ctx, 'NotificationService', 'Watch', request, WatchResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
