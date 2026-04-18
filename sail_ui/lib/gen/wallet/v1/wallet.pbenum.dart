//
//  Generated code. Do not modify.
//  source: wallet/v1/wallet.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// Coin Selection Strategy
class CoinSelectionStrategy extends $pb.ProtobufEnum {
  static const CoinSelectionStrategy COIN_SELECTION_STRATEGY_UNSPECIFIED = CoinSelectionStrategy._(0, _omitEnumNames ? '' : 'COIN_SELECTION_STRATEGY_UNSPECIFIED');
  static const CoinSelectionStrategy COIN_SELECTION_STRATEGY_LARGEST_FIRST = CoinSelectionStrategy._(1, _omitEnumNames ? '' : 'COIN_SELECTION_STRATEGY_LARGEST_FIRST');
  static const CoinSelectionStrategy COIN_SELECTION_STRATEGY_SMALLEST_FIRST = CoinSelectionStrategy._(2, _omitEnumNames ? '' : 'COIN_SELECTION_STRATEGY_SMALLEST_FIRST');
  static const CoinSelectionStrategy COIN_SELECTION_STRATEGY_RANDOM = CoinSelectionStrategy._(3, _omitEnumNames ? '' : 'COIN_SELECTION_STRATEGY_RANDOM');

  static const $core.List<CoinSelectionStrategy> values = <CoinSelectionStrategy> [
    COIN_SELECTION_STRATEGY_UNSPECIFIED,
    COIN_SELECTION_STRATEGY_LARGEST_FIRST,
    COIN_SELECTION_STRATEGY_SMALLEST_FIRST,
    COIN_SELECTION_STRATEGY_RANDOM,
  ];

  static final $core.Map<$core.int, CoinSelectionStrategy> _byValue = $pb.ProtobufEnum.initByValue(values);
  static CoinSelectionStrategy? valueOf($core.int value) => _byValue[value];

  const CoinSelectionStrategy._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
