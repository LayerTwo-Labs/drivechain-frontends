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

class AddressType extends $pb.ProtobufEnum {
  static const AddressType ADDRESS_TYPE_UNSPECIFIED =
      AddressType._(0, _omitEnumNames ? '' : 'ADDRESS_TYPE_UNSPECIFIED');
  static const AddressType ADDRESS_TYPE_SEGWIT = AddressType._(1, _omitEnumNames ? '' : 'ADDRESS_TYPE_SEGWIT');
  static const AddressType ADDRESS_TYPE_TAPROOT = AddressType._(2, _omitEnumNames ? '' : 'ADDRESS_TYPE_TAPROOT');

  static const $core.List<AddressType> values = <AddressType>[
    ADDRESS_TYPE_UNSPECIFIED,
    ADDRESS_TYPE_SEGWIT,
    ADDRESS_TYPE_TAPROOT,
  ];

  static final $core.List<AddressType?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 2);
  static AddressType? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AddressType._(super.value, super.name);
}

/// Script kind of the address a private key controls.
class SweepAddressKind extends $pb.ProtobufEnum {
  static const SweepAddressKind SWEEP_ADDRESS_KIND_UNSPECIFIED =
      SweepAddressKind._(0, _omitEnumNames ? '' : 'SWEEP_ADDRESS_KIND_UNSPECIFIED');
  static const SweepAddressKind SWEEP_ADDRESS_KIND_P2WPKH =
      SweepAddressKind._(1, _omitEnumNames ? '' : 'SWEEP_ADDRESS_KIND_P2WPKH');
  static const SweepAddressKind SWEEP_ADDRESS_KIND_P2PKH =
      SweepAddressKind._(2, _omitEnumNames ? '' : 'SWEEP_ADDRESS_KIND_P2PKH');

  static const $core.List<SweepAddressKind> values = <SweepAddressKind>[
    SWEEP_ADDRESS_KIND_UNSPECIFIED,
    SWEEP_ADDRESS_KIND_P2WPKH,
    SWEEP_ADDRESS_KIND_P2PKH,
  ];

  static final $core.List<SweepAddressKind?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 2);
  static SweepAddressKind? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const SweepAddressKind._(super.value, super.name);
}

/// Coin Selection Strategy
class CoinSelectionStrategy extends $pb.ProtobufEnum {
  static const CoinSelectionStrategy COIN_SELECTION_STRATEGY_UNSPECIFIED =
      CoinSelectionStrategy._(0, _omitEnumNames ? '' : 'COIN_SELECTION_STRATEGY_UNSPECIFIED');
  static const CoinSelectionStrategy COIN_SELECTION_STRATEGY_LARGEST_FIRST =
      CoinSelectionStrategy._(1, _omitEnumNames ? '' : 'COIN_SELECTION_STRATEGY_LARGEST_FIRST');
  static const CoinSelectionStrategy COIN_SELECTION_STRATEGY_SMALLEST_FIRST =
      CoinSelectionStrategy._(2, _omitEnumNames ? '' : 'COIN_SELECTION_STRATEGY_SMALLEST_FIRST');
  static const CoinSelectionStrategy COIN_SELECTION_STRATEGY_RANDOM =
      CoinSelectionStrategy._(3, _omitEnumNames ? '' : 'COIN_SELECTION_STRATEGY_RANDOM');
  static const CoinSelectionStrategy COIN_SELECTION_STRATEGY_BRANCH_AND_BOUND =
      CoinSelectionStrategy._(4, _omitEnumNames ? '' : 'COIN_SELECTION_STRATEGY_BRANCH_AND_BOUND');

  static const $core.List<CoinSelectionStrategy> values = <CoinSelectionStrategy>[
    COIN_SELECTION_STRATEGY_UNSPECIFIED,
    COIN_SELECTION_STRATEGY_LARGEST_FIRST,
    COIN_SELECTION_STRATEGY_SMALLEST_FIRST,
    COIN_SELECTION_STRATEGY_RANDOM,
    COIN_SELECTION_STRATEGY_BRANCH_AND_BOUND,
  ];

  static final $core.List<CoinSelectionStrategy?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 4);
  static CoinSelectionStrategy? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const CoinSelectionStrategy._(super.value, super.name);
}

const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
