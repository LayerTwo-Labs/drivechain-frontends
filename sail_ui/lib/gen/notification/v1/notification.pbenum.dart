//
//  Generated code. Do not modify.
//  source: notification/v1/notification.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class TransactionEvent_Type extends $pb.ProtobufEnum {
  static const TransactionEvent_Type TYPE_UNSPECIFIED = TransactionEvent_Type._(0, _omitEnumNames ? '' : 'TYPE_UNSPECIFIED');
  static const TransactionEvent_Type TYPE_RECEIVED = TransactionEvent_Type._(1, _omitEnumNames ? '' : 'TYPE_RECEIVED');
  static const TransactionEvent_Type TYPE_SENT = TransactionEvent_Type._(2, _omitEnumNames ? '' : 'TYPE_SENT');
  static const TransactionEvent_Type TYPE_CONFIRMED = TransactionEvent_Type._(3, _omitEnumNames ? '' : 'TYPE_CONFIRMED');

  static const $core.List<TransactionEvent_Type> values = <TransactionEvent_Type> [
    TYPE_UNSPECIFIED,
    TYPE_RECEIVED,
    TYPE_SENT,
    TYPE_CONFIRMED,
  ];

  static final $core.Map<$core.int, TransactionEvent_Type> _byValue = $pb.ProtobufEnum.initByValue(values);
  static TransactionEvent_Type? valueOf($core.int value) => _byValue[value];

  const TransactionEvent_Type._($core.int v, $core.String n) : super(v, n);
}

class TimestampEvent_Type extends $pb.ProtobufEnum {
  static const TimestampEvent_Type TYPE_UNSPECIFIED = TimestampEvent_Type._(0, _omitEnumNames ? '' : 'TYPE_UNSPECIFIED');
  static const TimestampEvent_Type TYPE_CREATED = TimestampEvent_Type._(1, _omitEnumNames ? '' : 'TYPE_CREATED');
  static const TimestampEvent_Type TYPE_CONFIRMED = TimestampEvent_Type._(2, _omitEnumNames ? '' : 'TYPE_CONFIRMED');

  static const $core.List<TimestampEvent_Type> values = <TimestampEvent_Type> [
    TYPE_UNSPECIFIED,
    TYPE_CREATED,
    TYPE_CONFIRMED,
  ];

  static final $core.Map<$core.int, TimestampEvent_Type> _byValue = $pb.ProtobufEnum.initByValue(values);
  static TimestampEvent_Type? valueOf($core.int value) => _byValue[value];

  const TimestampEvent_Type._($core.int v, $core.String n) : super(v, n);
}

class SystemEvent_Type extends $pb.ProtobufEnum {
  static const SystemEvent_Type TYPE_UNSPECIFIED = SystemEvent_Type._(0, _omitEnumNames ? '' : 'TYPE_UNSPECIFIED');
  static const SystemEvent_Type TYPE_SERVICE_CONNECTED = SystemEvent_Type._(1, _omitEnumNames ? '' : 'TYPE_SERVICE_CONNECTED');
  static const SystemEvent_Type TYPE_SERVICE_DISCONNECTED = SystemEvent_Type._(2, _omitEnumNames ? '' : 'TYPE_SERVICE_DISCONNECTED');
  static const SystemEvent_Type TYPE_SYNC_COMPLETED = SystemEvent_Type._(3, _omitEnumNames ? '' : 'TYPE_SYNC_COMPLETED');
  static const SystemEvent_Type TYPE_BLOCK_FOUND = SystemEvent_Type._(4, _omitEnumNames ? '' : 'TYPE_BLOCK_FOUND');

  static const $core.List<SystemEvent_Type> values = <SystemEvent_Type> [
    TYPE_UNSPECIFIED,
    TYPE_SERVICE_CONNECTED,
    TYPE_SERVICE_DISCONNECTED,
    TYPE_SYNC_COMPLETED,
    TYPE_BLOCK_FOUND,
  ];

  static final $core.Map<$core.int, SystemEvent_Type> _byValue = $pb.ProtobufEnum.initByValue(values);
  static SystemEvent_Type? valueOf($core.int value) => _byValue[value];

  const SystemEvent_Type._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
