// This is a generated file - do not edit.
//
// Generated from wallet/v1/wallet.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// Coin Selection Strategy
class CoinSelectionStrategy extends $pb.ProtobufEnum {
  static const CoinSelectionStrategy COIN_SELECTION_STRATEGY_UNSPECIFIED =
      CoinSelectionStrategy._(
          0, _omitEnumNames ? '' : 'COIN_SELECTION_STRATEGY_UNSPECIFIED');
  static const CoinSelectionStrategy COIN_SELECTION_STRATEGY_LARGEST_FIRST =
      CoinSelectionStrategy._(
          1, _omitEnumNames ? '' : 'COIN_SELECTION_STRATEGY_LARGEST_FIRST');
  static const CoinSelectionStrategy COIN_SELECTION_STRATEGY_SMALLEST_FIRST =
      CoinSelectionStrategy._(
          2, _omitEnumNames ? '' : 'COIN_SELECTION_STRATEGY_SMALLEST_FIRST');
  static const CoinSelectionStrategy COIN_SELECTION_STRATEGY_RANDOM =
      CoinSelectionStrategy._(
          3, _omitEnumNames ? '' : 'COIN_SELECTION_STRATEGY_RANDOM');

  static const $core.List<CoinSelectionStrategy> values =
      <CoinSelectionStrategy>[
    COIN_SELECTION_STRATEGY_UNSPECIFIED,
    COIN_SELECTION_STRATEGY_LARGEST_FIRST,
    COIN_SELECTION_STRATEGY_SMALLEST_FIRST,
    COIN_SELECTION_STRATEGY_RANDOM,
  ];

  static final $core.List<CoinSelectionStrategy?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 3);
  static CoinSelectionStrategy? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CoinSelectionStrategy._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');
