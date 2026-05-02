//
//  Generated code. Do not modify.
//  source: orchestrator/v1/orchestrator.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// SidechainType keeps the response strongly-typed so callers don't have to
/// match magic strings. UNSPECIFIED is reserved for forwards-compat — when
/// a frontend sees it, the binary is known to the orchestrator but doesn't
/// have a typed enum value yet.
class SidechainType extends $pb.ProtobufEnum {
  static const SidechainType SIDECHAIN_TYPE_UNSPECIFIED =
      SidechainType._(0, _omitEnumNames ? '' : 'SIDECHAIN_TYPE_UNSPECIFIED');
  static const SidechainType SIDECHAIN_TYPE_THUNDER =
      SidechainType._(1, _omitEnumNames ? '' : 'SIDECHAIN_TYPE_THUNDER');
  static const SidechainType SIDECHAIN_TYPE_ZSIDE = SidechainType._(2, _omitEnumNames ? '' : 'SIDECHAIN_TYPE_ZSIDE');
  static const SidechainType SIDECHAIN_TYPE_BITNAMES =
      SidechainType._(3, _omitEnumNames ? '' : 'SIDECHAIN_TYPE_BITNAMES');
  static const SidechainType SIDECHAIN_TYPE_BITASSETS =
      SidechainType._(4, _omitEnumNames ? '' : 'SIDECHAIN_TYPE_BITASSETS');
  static const SidechainType SIDECHAIN_TYPE_TRUTHCOIN =
      SidechainType._(5, _omitEnumNames ? '' : 'SIDECHAIN_TYPE_TRUTHCOIN');
  static const SidechainType SIDECHAIN_TYPE_PHOTON = SidechainType._(6, _omitEnumNames ? '' : 'SIDECHAIN_TYPE_PHOTON');
  static const SidechainType SIDECHAIN_TYPE_COINSHIFT =
      SidechainType._(7, _omitEnumNames ? '' : 'SIDECHAIN_TYPE_COINSHIFT');

  static const $core.List<SidechainType> values = <SidechainType>[
    SIDECHAIN_TYPE_UNSPECIFIED,
    SIDECHAIN_TYPE_THUNDER,
    SIDECHAIN_TYPE_ZSIDE,
    SIDECHAIN_TYPE_BITNAMES,
    SIDECHAIN_TYPE_BITASSETS,
    SIDECHAIN_TYPE_TRUTHCOIN,
    SIDECHAIN_TYPE_PHOTON,
    SIDECHAIN_TYPE_COINSHIFT,
  ];

  static final $core.Map<$core.int, SidechainType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static SidechainType? valueOf($core.int value) => _byValue[value];

  const SidechainType._($core.int v, $core.String n) : super(v, n);
}

const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
