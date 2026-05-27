//
//  Generated code. Do not modify.
//  source: fast_withdrawal/v1/fast_withdrawal.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class FastWithdrawalUpdate_Status extends $pb.ProtobufEnum {
  static const FastWithdrawalUpdate_Status STATUS_UNSPECIFIED = FastWithdrawalUpdate_Status._(0, _omitEnumNames ? '' : 'STATUS_UNSPECIFIED');
  static const FastWithdrawalUpdate_Status STATUS_INITIATING = FastWithdrawalUpdate_Status._(1, _omitEnumNames ? '' : 'STATUS_INITIATING');
  static const FastWithdrawalUpdate_Status STATUS_PENDING = FastWithdrawalUpdate_Status._(2, _omitEnumNames ? '' : 'STATUS_PENDING');
  static const FastWithdrawalUpdate_Status STATUS_DETECTED = FastWithdrawalUpdate_Status._(3, _omitEnumNames ? '' : 'STATUS_DETECTED');
  static const FastWithdrawalUpdate_Status STATUS_CONFIRMED = FastWithdrawalUpdate_Status._(4, _omitEnumNames ? '' : 'STATUS_CONFIRMED');
  static const FastWithdrawalUpdate_Status STATUS_FAILED = FastWithdrawalUpdate_Status._(5, _omitEnumNames ? '' : 'STATUS_FAILED');
  static const FastWithdrawalUpdate_Status STATUS_COMPLETED = FastWithdrawalUpdate_Status._(6, _omitEnumNames ? '' : 'STATUS_COMPLETED');

  static const $core.List<FastWithdrawalUpdate_Status> values = <FastWithdrawalUpdate_Status> [
    STATUS_UNSPECIFIED,
    STATUS_INITIATING,
    STATUS_PENDING,
    STATUS_DETECTED,
    STATUS_CONFIRMED,
    STATUS_FAILED,
    STATUS_COMPLETED,
  ];

  static final $core.Map<$core.int, FastWithdrawalUpdate_Status> _byValue = $pb.ProtobufEnum.initByValue(values);
  static FastWithdrawalUpdate_Status? valueOf($core.int value) => _byValue[value];

  const FastWithdrawalUpdate_Status._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
