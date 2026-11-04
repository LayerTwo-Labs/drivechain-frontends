// This is a generated file - do not edit.
//
// Generated from notification/v1/notification.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class TransactionEvent_Type extends $pb.ProtobufEnum {
  static const TransactionEvent_Type TYPE_UNSPECIFIED =
      TransactionEvent_Type._(0, _omitEnumNames ? '' : 'TYPE_UNSPECIFIED');
  static const TransactionEvent_Type TYPE_RECEIVED = TransactionEvent_Type._(1, _omitEnumNames ? '' : 'TYPE_RECEIVED');
  static const TransactionEvent_Type TYPE_SENT = TransactionEvent_Type._(2, _omitEnumNames ? '' : 'TYPE_SENT');
  static const TransactionEvent_Type TYPE_CONFIRMED =
      TransactionEvent_Type._(3, _omitEnumNames ? '' : 'TYPE_CONFIRMED');

  static const $core.List<TransactionEvent_Type> values = <TransactionEvent_Type>[
    TYPE_UNSPECIFIED,
    TYPE_RECEIVED,
    TYPE_SENT,
    TYPE_CONFIRMED,
  ];

  static final $core.List<TransactionEvent_Type?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 3);
  static TransactionEvent_Type? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TransactionEvent_Type._(super.value, super.name);
}

class TimestampEvent_Type extends $pb.ProtobufEnum {
  static const TimestampEvent_Type TYPE_UNSPECIFIED =
      TimestampEvent_Type._(0, _omitEnumNames ? '' : 'TYPE_UNSPECIFIED');
  static const TimestampEvent_Type TYPE_CREATED = TimestampEvent_Type._(1, _omitEnumNames ? '' : 'TYPE_CREATED');
  static const TimestampEvent_Type TYPE_CONFIRMED = TimestampEvent_Type._(2, _omitEnumNames ? '' : 'TYPE_CONFIRMED');

  static const $core.List<TimestampEvent_Type> values = <TimestampEvent_Type>[
    TYPE_UNSPECIFIED,
    TYPE_CREATED,
    TYPE_CONFIRMED,
  ];

  static final $core.List<TimestampEvent_Type?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 2);
  static TimestampEvent_Type? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const TimestampEvent_Type._(super.value, super.name);
}

class SystemEvent_Type extends $pb.ProtobufEnum {
  static const SystemEvent_Type TYPE_UNSPECIFIED = SystemEvent_Type._(0, _omitEnumNames ? '' : 'TYPE_UNSPECIFIED');
  static const SystemEvent_Type TYPE_SERVICE_CONNECTED =
      SystemEvent_Type._(1, _omitEnumNames ? '' : 'TYPE_SERVICE_CONNECTED');
  static const SystemEvent_Type TYPE_SERVICE_DISCONNECTED =
      SystemEvent_Type._(2, _omitEnumNames ? '' : 'TYPE_SERVICE_DISCONNECTED');
  static const SystemEvent_Type TYPE_SYNC_COMPLETED =
      SystemEvent_Type._(3, _omitEnumNames ? '' : 'TYPE_SYNC_COMPLETED');
  static const SystemEvent_Type TYPE_BLOCK_FOUND = SystemEvent_Type._(4, _omitEnumNames ? '' : 'TYPE_BLOCK_FOUND');

  /// The network dropped a sidechain deposit, so it can never confirm and
  /// the user must send it again.
  static const SystemEvent_Type TYPE_DEPOSIT_DROPPED =
      SystemEvent_Type._(5, _omitEnumNames ? '' : 'TYPE_DEPOSIT_DROPPED');

  static const $core.List<SystemEvent_Type> values = <SystemEvent_Type>[
    TYPE_UNSPECIFIED,
    TYPE_SERVICE_CONNECTED,
    TYPE_SERVICE_DISCONNECTED,
    TYPE_SYNC_COMPLETED,
    TYPE_BLOCK_FOUND,
    TYPE_DEPOSIT_DROPPED,
  ];

  static final $core.List<SystemEvent_Type?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 5);
  static SystemEvent_Type? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SystemEvent_Type._(super.value, super.name);
}

class SidechainWithdrawalEvent_Type extends $pb.ProtobufEnum {
  static const SidechainWithdrawalEvent_Type TYPE_UNSPECIFIED =
      SidechainWithdrawalEvent_Type._(0, _omitEnumNames ? '' : 'TYPE_UNSPECIFIED');
  static const SidechainWithdrawalEvent_Type TYPE_DETECTED =
      SidechainWithdrawalEvent_Type._(1, _omitEnumNames ? '' : 'TYPE_DETECTED');
  static const SidechainWithdrawalEvent_Type TYPE_CONFIRMED =
      SidechainWithdrawalEvent_Type._(2, _omitEnumNames ? '' : 'TYPE_CONFIRMED');

  static const $core.List<SidechainWithdrawalEvent_Type> values = <SidechainWithdrawalEvent_Type>[
    TYPE_UNSPECIFIED,
    TYPE_DETECTED,
    TYPE_CONFIRMED,
  ];

  static final $core.List<SidechainWithdrawalEvent_Type?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 2);
  static SidechainWithdrawalEvent_Type? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SidechainWithdrawalEvent_Type._(super.value, super.name);
}

const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
