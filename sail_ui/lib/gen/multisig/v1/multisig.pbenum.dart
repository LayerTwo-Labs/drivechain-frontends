//
//  Generated code. Do not modify.
//  source: multisig/v1/multisig.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class TxStatus extends $pb.ProtobufEnum {
  static const TxStatus TX_STATUS_UNSPECIFIED = TxStatus._(0, _omitEnumNames ? '' : 'TX_STATUS_UNSPECIFIED');
  static const TxStatus TX_STATUS_NEEDS_SIGNATURES = TxStatus._(1, _omitEnumNames ? '' : 'TX_STATUS_NEEDS_SIGNATURES');
  static const TxStatus TX_STATUS_AWAITING_SIGNED_PSBTS =
      TxStatus._(2, _omitEnumNames ? '' : 'TX_STATUS_AWAITING_SIGNED_PSBTS');
  static const TxStatus TX_STATUS_READY_TO_COMBINE = TxStatus._(3, _omitEnumNames ? '' : 'TX_STATUS_READY_TO_COMBINE');
  static const TxStatus TX_STATUS_READY_FOR_BROADCAST =
      TxStatus._(4, _omitEnumNames ? '' : 'TX_STATUS_READY_FOR_BROADCAST');
  static const TxStatus TX_STATUS_BROADCASTED = TxStatus._(5, _omitEnumNames ? '' : 'TX_STATUS_BROADCASTED');
  static const TxStatus TX_STATUS_CONFIRMED = TxStatus._(6, _omitEnumNames ? '' : 'TX_STATUS_CONFIRMED');
  static const TxStatus TX_STATUS_COMPLETED = TxStatus._(7, _omitEnumNames ? '' : 'TX_STATUS_COMPLETED');
  static const TxStatus TX_STATUS_VOIDED = TxStatus._(8, _omitEnumNames ? '' : 'TX_STATUS_VOIDED');

  static const $core.List<TxStatus> values = <TxStatus>[
    TX_STATUS_UNSPECIFIED,
    TX_STATUS_NEEDS_SIGNATURES,
    TX_STATUS_AWAITING_SIGNED_PSBTS,
    TX_STATUS_READY_TO_COMBINE,
    TX_STATUS_READY_FOR_BROADCAST,
    TX_STATUS_BROADCASTED,
    TX_STATUS_CONFIRMED,
    TX_STATUS_COMPLETED,
    TX_STATUS_VOIDED,
  ];

  static final $core.Map<$core.int, TxStatus> _byValue = $pb.ProtobufEnum.initByValue(values);
  static TxStatus? valueOf($core.int value) => _byValue[value];

  const TxStatus._($core.int v, $core.String n) : super(v, n);
}

class TxType extends $pb.ProtobufEnum {
  static const TxType TX_TYPE_UNSPECIFIED = TxType._(0, _omitEnumNames ? '' : 'TX_TYPE_UNSPECIFIED');
  static const TxType TX_TYPE_DEPOSIT = TxType._(1, _omitEnumNames ? '' : 'TX_TYPE_DEPOSIT');
  static const TxType TX_TYPE_WITHDRAWAL = TxType._(2, _omitEnumNames ? '' : 'TX_TYPE_WITHDRAWAL');

  static const $core.List<TxType> values = <TxType>[
    TX_TYPE_UNSPECIFIED,
    TX_TYPE_DEPOSIT,
    TX_TYPE_WITHDRAWAL,
  ];

  static final $core.Map<$core.int, TxType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static TxType? valueOf($core.int value) => _byValue[value];

  const TxType._($core.int v, $core.String n) : super(v, n);
}

const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
