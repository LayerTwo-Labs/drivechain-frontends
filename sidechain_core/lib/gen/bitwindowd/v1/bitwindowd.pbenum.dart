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
  static const BitcoinNetwork BITCOIN_NETWORK_ECASH = BitcoinNetwork._(7, _omitEnumNames ? '' : 'BITCOIN_NETWORK_ECASH');

  static const $core.List<BitcoinNetwork> values = <BitcoinNetwork> [
    BITCOIN_NETWORK_UNSPECIFIED,
    BITCOIN_NETWORK_UNKNOWN,
    BITCOIN_NETWORK_MAINNET,
    BITCOIN_NETWORK_REGTEST,
    BITCOIN_NETWORK_SIGNET,
    BITCOIN_NETWORK_TESTNET,
    BITCOIN_NETWORK_ECASH,
  ];

  static final $core.Map<$core.int, BitcoinNetwork> _byValue = $pb.ProtobufEnum.initByValue(values);
  static BitcoinNetwork? valueOf($core.int value) => _byValue[value];

  const BitcoinNetwork._($core.int v, $core.String n) : super(v, n);
}

class AddressType extends $pb.ProtobufEnum {
  static const AddressType ADDRESS_TYPE_UNSPECIFIED = AddressType._(0, _omitEnumNames ? '' : 'ADDRESS_TYPE_UNSPECIFIED');
  static const AddressType ADDRESS_TYPE_UNKNOWN = AddressType._(1, _omitEnumNames ? '' : 'ADDRESS_TYPE_UNKNOWN');
  static const AddressType ADDRESS_TYPE_BITCOIN_L1 = AddressType._(2, _omitEnumNames ? '' : 'ADDRESS_TYPE_BITCOIN_L1');
  static const AddressType ADDRESS_TYPE_DRIVECHAIN_DEPOSIT = AddressType._(3, _omitEnumNames ? '' : 'ADDRESS_TYPE_DRIVECHAIN_DEPOSIT');
  static const AddressType ADDRESS_TYPE_BIP47_PAYMENT_CODE = AddressType._(4, _omitEnumNames ? '' : 'ADDRESS_TYPE_BIP47_PAYMENT_CODE');

  static const $core.List<AddressType> values = <AddressType> [
    ADDRESS_TYPE_UNSPECIFIED,
    ADDRESS_TYPE_UNKNOWN,
    ADDRESS_TYPE_BITCOIN_L1,
    ADDRESS_TYPE_DRIVECHAIN_DEPOSIT,
    ADDRESS_TYPE_BIP47_PAYMENT_CODE,
  ];

  static final $core.Map<$core.int, AddressType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static AddressType? valueOf($core.int value) => _byValue[value];

  const AddressType._($core.int v, $core.String n) : super(v, n);
}

class MempoolTxStatus extends $pb.ProtobufEnum {
  static const MempoolTxStatus MEMPOOL_TX_STATUS_UNSPECIFIED = MempoolTxStatus._(0, _omitEnumNames ? '' : 'MEMPOOL_TX_STATUS_UNSPECIFIED');
  static const MempoolTxStatus MEMPOOL_TX_STATUS_PENDING = MempoolTxStatus._(1, _omitEnumNames ? '' : 'MEMPOOL_TX_STATUS_PENDING');
  static const MempoolTxStatus MEMPOOL_TX_STATUS_MINED = MempoolTxStatus._(2, _omitEnumNames ? '' : 'MEMPOOL_TX_STATUS_MINED');
  static const MempoolTxStatus MEMPOOL_TX_STATUS_REMOVED = MempoolTxStatus._(3, _omitEnumNames ? '' : 'MEMPOOL_TX_STATUS_REMOVED');

  static const $core.List<MempoolTxStatus> values = <MempoolTxStatus> [
    MEMPOOL_TX_STATUS_UNSPECIFIED,
    MEMPOOL_TX_STATUS_PENDING,
    MEMPOOL_TX_STATUS_MINED,
    MEMPOOL_TX_STATUS_REMOVED,
  ];

  static final $core.Map<$core.int, MempoolTxStatus> _byValue = $pb.ProtobufEnum.initByValue(values);
  static MempoolTxStatus? valueOf($core.int value) => _byValue[value];

  const MempoolTxStatus._($core.int v, $core.String n) : super(v, n);
}

class MempoolTxSort extends $pb.ProtobufEnum {
  static const MempoolTxSort MEMPOOL_TX_SORT_UNSPECIFIED = MempoolTxSort._(0, _omitEnumNames ? '' : 'MEMPOOL_TX_SORT_UNSPECIFIED');
  static const MempoolTxSort MEMPOOL_TX_SORT_FEE_RATE = MempoolTxSort._(1, _omitEnumNames ? '' : 'MEMPOOL_TX_SORT_FEE_RATE');
  static const MempoolTxSort MEMPOOL_TX_SORT_FEE = MempoolTxSort._(2, _omitEnumNames ? '' : 'MEMPOOL_TX_SORT_FEE');
  static const MempoolTxSort MEMPOOL_TX_SORT_VSIZE = MempoolTxSort._(3, _omitEnumNames ? '' : 'MEMPOOL_TX_SORT_VSIZE');
  static const MempoolTxSort MEMPOOL_TX_SORT_FIRST_SEEN = MempoolTxSort._(4, _omitEnumNames ? '' : 'MEMPOOL_TX_SORT_FIRST_SEEN');

  static const $core.List<MempoolTxSort> values = <MempoolTxSort> [
    MEMPOOL_TX_SORT_UNSPECIFIED,
    MEMPOOL_TX_SORT_FEE_RATE,
    MEMPOOL_TX_SORT_FEE,
    MEMPOOL_TX_SORT_VSIZE,
    MEMPOOL_TX_SORT_FIRST_SEEN,
  ];

  static final $core.Map<$core.int, MempoolTxSort> _byValue = $pb.ProtobufEnum.initByValue(values);
  static MempoolTxSort? valueOf($core.int value) => _byValue[value];

  const MempoolTxSort._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
