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
  static const SidechainType SIDECHAIN_TYPE_UNSPECIFIED = SidechainType._(0, _omitEnumNames ? '' : 'SIDECHAIN_TYPE_UNSPECIFIED');
  static const SidechainType SIDECHAIN_TYPE_THUNDER = SidechainType._(1, _omitEnumNames ? '' : 'SIDECHAIN_TYPE_THUNDER');
  static const SidechainType SIDECHAIN_TYPE_ZSIDE = SidechainType._(2, _omitEnumNames ? '' : 'SIDECHAIN_TYPE_ZSIDE');
  static const SidechainType SIDECHAIN_TYPE_BITNAMES = SidechainType._(3, _omitEnumNames ? '' : 'SIDECHAIN_TYPE_BITNAMES');
  static const SidechainType SIDECHAIN_TYPE_BITASSETS = SidechainType._(4, _omitEnumNames ? '' : 'SIDECHAIN_TYPE_BITASSETS');
  static const SidechainType SIDECHAIN_TYPE_TRUTHCOIN = SidechainType._(5, _omitEnumNames ? '' : 'SIDECHAIN_TYPE_TRUTHCOIN');
  static const SidechainType SIDECHAIN_TYPE_PHOTON = SidechainType._(6, _omitEnumNames ? '' : 'SIDECHAIN_TYPE_PHOTON');
  static const SidechainType SIDECHAIN_TYPE_COINSHIFT = SidechainType._(7, _omitEnumNames ? '' : 'SIDECHAIN_TYPE_COINSHIFT');

  static const $core.List<SidechainType> values = <SidechainType> [
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

/// BinaryType is the single typed identifier for any binary the system tracks.
/// Used wire-side by the orchestrator and consumed directly by the Flutter
/// frontends — there is no parallel Dart enum. UNSPECIFIED is reserved for
/// forwards-compat: when a frontend sees it, the binary is known to the
/// orchestrator but doesn't have a typed enum value yet.
class BinaryType extends $pb.ProtobufEnum {
  static const BinaryType BINARY_TYPE_UNSPECIFIED = BinaryType._(0, _omitEnumNames ? '' : 'BINARY_TYPE_UNSPECIFIED');
  static const BinaryType BINARY_TYPE_BITCOIND = BinaryType._(1, _omitEnumNames ? '' : 'BINARY_TYPE_BITCOIND');
  static const BinaryType BINARY_TYPE_ENFORCER = BinaryType._(2, _omitEnumNames ? '' : 'BINARY_TYPE_ENFORCER');
  static const BinaryType BINARY_TYPE_BITWINDOWD = BinaryType._(3, _omitEnumNames ? '' : 'BINARY_TYPE_BITWINDOWD');
  static const BinaryType BINARY_TYPE_THUNDER = BinaryType._(4, _omitEnumNames ? '' : 'BINARY_TYPE_THUNDER');
  static const BinaryType BINARY_TYPE_ZSIDE = BinaryType._(5, _omitEnumNames ? '' : 'BINARY_TYPE_ZSIDE');
  static const BinaryType BINARY_TYPE_BITNAMES = BinaryType._(6, _omitEnumNames ? '' : 'BINARY_TYPE_BITNAMES');
  static const BinaryType BINARY_TYPE_BITASSETS = BinaryType._(7, _omitEnumNames ? '' : 'BINARY_TYPE_BITASSETS');
  static const BinaryType BINARY_TYPE_TRUTHCOIN = BinaryType._(8, _omitEnumNames ? '' : 'BINARY_TYPE_TRUTHCOIN');
  static const BinaryType BINARY_TYPE_PHOTON = BinaryType._(9, _omitEnumNames ? '' : 'BINARY_TYPE_PHOTON');
  static const BinaryType BINARY_TYPE_COINSHIFT = BinaryType._(10, _omitEnumNames ? '' : 'BINARY_TYPE_COINSHIFT');
  static const BinaryType BINARY_TYPE_GRPCURL = BinaryType._(11, _omitEnumNames ? '' : 'BINARY_TYPE_GRPCURL');
  static const BinaryType BINARY_TYPE_ORCHESTRATORD = BinaryType._(12, _omitEnumNames ? '' : 'BINARY_TYPE_ORCHESTRATORD');
  static const BinaryType BINARY_TYPE_ZSIDED = BinaryType._(13, _omitEnumNames ? '' : 'BINARY_TYPE_ZSIDED');

  static const $core.List<BinaryType> values = <BinaryType> [
    BINARY_TYPE_UNSPECIFIED,
    BINARY_TYPE_BITCOIND,
    BINARY_TYPE_ENFORCER,
    BINARY_TYPE_BITWINDOWD,
    BINARY_TYPE_THUNDER,
    BINARY_TYPE_ZSIDE,
    BINARY_TYPE_BITNAMES,
    BINARY_TYPE_BITASSETS,
    BINARY_TYPE_TRUTHCOIN,
    BINARY_TYPE_PHOTON,
    BINARY_TYPE_COINSHIFT,
    BINARY_TYPE_GRPCURL,
    BINARY_TYPE_ORCHESTRATORD,
    BINARY_TYPE_ZSIDED,
  ];

  static final $core.Map<$core.int, BinaryType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static BinaryType? valueOf($core.int value) => _byValue[value];

  const BinaryType._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
