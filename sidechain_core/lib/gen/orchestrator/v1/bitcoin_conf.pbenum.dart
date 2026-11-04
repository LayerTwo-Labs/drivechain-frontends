// This is a generated file - do not edit.
//
// Generated from orchestrator/v1/bitcoin_conf.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// WalletBackend is what serves the wallet's chain data.
class WalletBackend extends $pb.ProtobufEnum {
  static const WalletBackend WALLET_BACKEND_UNSPECIFIED =
      WalletBackend._(0, _omitEnumNames ? '' : 'WALLET_BACKEND_UNSPECIFIED');
  static const WalletBackend WALLET_BACKEND_ELECTRUM =
      WalletBackend._(1, _omitEnumNames ? '' : 'WALLET_BACKEND_ELECTRUM');
  static const WalletBackend WALLET_BACKEND_CORE = WalletBackend._(2, _omitEnumNames ? '' : 'WALLET_BACKEND_CORE');

  static const $core.List<WalletBackend> values = <WalletBackend>[
    WALLET_BACKEND_UNSPECIFIED,
    WALLET_BACKEND_ELECTRUM,
    WALLET_BACKEND_CORE,
  ];

  static final $core.List<WalletBackend?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 2);
  static WalletBackend? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const WalletBackend._(super.value, super.name);
}

const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
