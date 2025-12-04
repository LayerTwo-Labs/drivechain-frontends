//
//  Generated code. Do not modify.
//  source: bitwindowd/v1/bitwindowd.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Direction extends $pb.ProtobufEnum {
  static const Direction DIRECTION_UNSPECIFIED = Direction._(0, _omitEnumNames ? '' : 'DIRECTION_UNSPECIFIED');
  static const Direction DIRECTION_SEND = Direction._(1, _omitEnumNames ? '' : 'DIRECTION_SEND');
  static const Direction DIRECTION_RECEIVE = Direction._(2, _omitEnumNames ? '' : 'DIRECTION_RECEIVE');

  static const $core.List<Direction> values = <Direction> [
    DIRECTION_UNSPECIFIED,
    DIRECTION_SEND,
    DIRECTION_RECEIVE,
  ];

  static final $core.Map<$core.int, Direction> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Direction? valueOf($core.int value) => _byValue[value];

  const Direction._($core.int v, $core.String n) : super(v, n);
}

class BitcoinNetwork extends $pb.ProtobufEnum {
  static const BitcoinNetwork BITCOIN_NETWORK_UNSPECIFIED = BitcoinNetwork._(0, _omitEnumNames ? '' : 'BITCOIN_NETWORK_UNSPECIFIED');
  static const BitcoinNetwork BITCOIN_NETWORK_UNKNOWN = BitcoinNetwork._(1, _omitEnumNames ? '' : 'BITCOIN_NETWORK_UNKNOWN');
  static const BitcoinNetwork BITCOIN_NETWORK_MAINNET = BitcoinNetwork._(2, _omitEnumNames ? '' : 'BITCOIN_NETWORK_MAINNET');
  static const BitcoinNetwork BITCOIN_NETWORK_REGTEST = BitcoinNetwork._(3, _omitEnumNames ? '' : 'BITCOIN_NETWORK_REGTEST');
  static const BitcoinNetwork BITCOIN_NETWORK_SIGNET = BitcoinNetwork._(4, _omitEnumNames ? '' : 'BITCOIN_NETWORK_SIGNET');
  static const BitcoinNetwork BITCOIN_NETWORK_TESTNET = BitcoinNetwork._(5, _omitEnumNames ? '' : 'BITCOIN_NETWORK_TESTNET');
  static const BitcoinNetwork BITCOIN_NETWORK_FORKNET = BitcoinNetwork._(6, _omitEnumNames ? '' : 'BITCOIN_NETWORK_FORKNET');

  static const $core.List<BitcoinNetwork> values = <BitcoinNetwork> [
    BITCOIN_NETWORK_UNSPECIFIED,
    BITCOIN_NETWORK_UNKNOWN,
    BITCOIN_NETWORK_MAINNET,
    BITCOIN_NETWORK_REGTEST,
    BITCOIN_NETWORK_SIGNET,
    BITCOIN_NETWORK_TESTNET,
    BITCOIN_NETWORK_FORKNET,
  ];

  static final $core.Map<$core.int, BitcoinNetwork> _byValue = $pb.ProtobufEnum.initByValue(values);
  static BitcoinNetwork? valueOf($core.int value) => _byValue[value];

  const BitcoinNetwork._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
