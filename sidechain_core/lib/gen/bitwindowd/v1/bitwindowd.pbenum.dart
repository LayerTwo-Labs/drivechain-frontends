// This is a generated file - do not edit.
//
// Generated from bitwindowd/v1/bitwindowd.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Direction extends $pb.ProtobufEnum {
  static const Direction DIRECTION_UNSPECIFIED = Direction._(0, _omitEnumNames ? '' : 'DIRECTION_UNSPECIFIED');
  static const Direction DIRECTION_SEND = Direction._(1, _omitEnumNames ? '' : 'DIRECTION_SEND');
  static const Direction DIRECTION_RECEIVE = Direction._(2, _omitEnumNames ? '' : 'DIRECTION_RECEIVE');

  static const $core.List<Direction> values = <Direction>[
    DIRECTION_UNSPECIFIED,
    DIRECTION_SEND,
    DIRECTION_RECEIVE,
  ];

  static final $core.List<Direction?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 2);
  static Direction? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Direction._(super.value, super.name);
}

class BitcoinNetwork extends $pb.ProtobufEnum {
  static const BitcoinNetwork BITCOIN_NETWORK_UNSPECIFIED =
      BitcoinNetwork._(0, _omitEnumNames ? '' : 'BITCOIN_NETWORK_UNSPECIFIED');
  static const BitcoinNetwork BITCOIN_NETWORK_UNKNOWN =
      BitcoinNetwork._(1, _omitEnumNames ? '' : 'BITCOIN_NETWORK_UNKNOWN');
  static const BitcoinNetwork BITCOIN_NETWORK_MAINNET =
      BitcoinNetwork._(2, _omitEnumNames ? '' : 'BITCOIN_NETWORK_MAINNET');
  static const BitcoinNetwork BITCOIN_NETWORK_REGTEST =
      BitcoinNetwork._(3, _omitEnumNames ? '' : 'BITCOIN_NETWORK_REGTEST');
  static const BitcoinNetwork BITCOIN_NETWORK_SIGNET =
      BitcoinNetwork._(4, _omitEnumNames ? '' : 'BITCOIN_NETWORK_SIGNET');
  static const BitcoinNetwork BITCOIN_NETWORK_TESTNET =
      BitcoinNetwork._(5, _omitEnumNames ? '' : 'BITCOIN_NETWORK_TESTNET');
  static const BitcoinNetwork BITCOIN_NETWORK_ECASH =
      BitcoinNetwork._(7, _omitEnumNames ? '' : 'BITCOIN_NETWORK_ECASH');

  static const $core.List<BitcoinNetwork> values = <BitcoinNetwork>[
    BITCOIN_NETWORK_UNSPECIFIED,
    BITCOIN_NETWORK_UNKNOWN,
    BITCOIN_NETWORK_MAINNET,
    BITCOIN_NETWORK_REGTEST,
    BITCOIN_NETWORK_SIGNET,
    BITCOIN_NETWORK_TESTNET,
    BITCOIN_NETWORK_ECASH,
  ];

  static final $core.List<BitcoinNetwork?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 7);
  static BitcoinNetwork? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const BitcoinNetwork._(super.value, super.name);
}

class AddressType extends $pb.ProtobufEnum {
  static const AddressType ADDRESS_TYPE_UNSPECIFIED =
      AddressType._(0, _omitEnumNames ? '' : 'ADDRESS_TYPE_UNSPECIFIED');
  static const AddressType ADDRESS_TYPE_UNKNOWN = AddressType._(1, _omitEnumNames ? '' : 'ADDRESS_TYPE_UNKNOWN');
  static const AddressType ADDRESS_TYPE_BITCOIN_L1 = AddressType._(2, _omitEnumNames ? '' : 'ADDRESS_TYPE_BITCOIN_L1');
  static const AddressType ADDRESS_TYPE_DRIVECHAIN_DEPOSIT =
      AddressType._(3, _omitEnumNames ? '' : 'ADDRESS_TYPE_DRIVECHAIN_DEPOSIT');
  static const AddressType ADDRESS_TYPE_BIP47_PAYMENT_CODE =
      AddressType._(4, _omitEnumNames ? '' : 'ADDRESS_TYPE_BIP47_PAYMENT_CODE');

  static const $core.List<AddressType> values = <AddressType>[
    ADDRESS_TYPE_UNSPECIFIED,
    ADDRESS_TYPE_UNKNOWN,
    ADDRESS_TYPE_BITCOIN_L1,
    ADDRESS_TYPE_DRIVECHAIN_DEPOSIT,
    ADDRESS_TYPE_BIP47_PAYMENT_CODE,
  ];

  static final $core.List<AddressType?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 4);
  static AddressType? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const AddressType._(super.value, super.name);
}

class MiningPoolWindow extends $pb.ProtobufEnum {
  static const MiningPoolWindow MINING_POOL_WINDOW_UNSPECIFIED =
      MiningPoolWindow._(0, _omitEnumNames ? '' : 'MINING_POOL_WINDOW_UNSPECIFIED');
  static const MiningPoolWindow MINING_POOL_WINDOW_24H =
      MiningPoolWindow._(1, _omitEnumNames ? '' : 'MINING_POOL_WINDOW_24H');
  static const MiningPoolWindow MINING_POOL_WINDOW_3D =
      MiningPoolWindow._(2, _omitEnumNames ? '' : 'MINING_POOL_WINDOW_3D');
  static const MiningPoolWindow MINING_POOL_WINDOW_1W =
      MiningPoolWindow._(3, _omitEnumNames ? '' : 'MINING_POOL_WINDOW_1W');

  static const $core.List<MiningPoolWindow> values = <MiningPoolWindow>[
    MINING_POOL_WINDOW_UNSPECIFIED,
    MINING_POOL_WINDOW_24H,
    MINING_POOL_WINDOW_3D,
    MINING_POOL_WINDOW_1W,
  ];

  static final $core.List<MiningPoolWindow?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 3);
  static MiningPoolWindow? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MiningPoolWindow._(super.value, super.name);
}

const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
