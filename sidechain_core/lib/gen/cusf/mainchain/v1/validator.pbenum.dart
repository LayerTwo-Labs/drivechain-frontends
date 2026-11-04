// This is a generated file - do not edit.
//
// Generated from cusf/mainchain/v1/validator.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Network extends $pb.ProtobufEnum {
  static const Network NETWORK_UNSPECIFIED = Network._(0, _omitEnumNames ? '' : 'NETWORK_UNSPECIFIED');
  static const Network NETWORK_UNKNOWN = Network._(1, _omitEnumNames ? '' : 'NETWORK_UNKNOWN');
  static const Network NETWORK_MAINNET = Network._(2, _omitEnumNames ? '' : 'NETWORK_MAINNET');
  static const Network NETWORK_REGTEST = Network._(3, _omitEnumNames ? '' : 'NETWORK_REGTEST');
  static const Network NETWORK_SIGNET = Network._(4, _omitEnumNames ? '' : 'NETWORK_SIGNET');
  static const Network NETWORK_TESTNET = Network._(5, _omitEnumNames ? '' : 'NETWORK_TESTNET');

  static const $core.List<Network> values = <Network>[
    NETWORK_UNSPECIFIED,
    NETWORK_UNKNOWN,
    NETWORK_MAINNET,
    NETWORK_REGTEST,
    NETWORK_SIGNET,
    NETWORK_TESTNET,
  ];

  static final $core.List<Network?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 5);
  static Network? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const Network._(super.value, super.name);
}

const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
