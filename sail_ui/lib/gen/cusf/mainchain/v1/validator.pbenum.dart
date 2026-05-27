//
//  Generated code. Do not modify.
//  source: cusf/mainchain/v1/validator.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Network extends $pb.ProtobufEnum {
  static const Network NETWORK_UNSPECIFIED = Network._(0, _omitEnumNames ? '' : 'NETWORK_UNSPECIFIED');
  static const Network NETWORK_UNKNOWN = Network._(1, _omitEnumNames ? '' : 'NETWORK_UNKNOWN');
  static const Network NETWORK_MAINNET = Network._(2, _omitEnumNames ? '' : 'NETWORK_MAINNET');
  static const Network NETWORK_REGTEST = Network._(3, _omitEnumNames ? '' : 'NETWORK_REGTEST');
  static const Network NETWORK_SIGNET = Network._(4, _omitEnumNames ? '' : 'NETWORK_SIGNET');
  static const Network NETWORK_TESTNET = Network._(5, _omitEnumNames ? '' : 'NETWORK_TESTNET');

  static const $core.List<Network> values = <Network> [
    NETWORK_UNSPECIFIED,
    NETWORK_UNKNOWN,
    NETWORK_MAINNET,
    NETWORK_REGTEST,
    NETWORK_SIGNET,
    NETWORK_TESTNET,
  ];

  static final $core.Map<$core.int, Network> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Network? valueOf($core.int value) => _byValue[value];

  const Network._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
