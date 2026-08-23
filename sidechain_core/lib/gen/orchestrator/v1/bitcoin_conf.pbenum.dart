//
//  Generated code. Do not modify.
//  source: orchestrator/v1/bitcoin_conf.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// WalletBackend is what serves the wallet's chain data.
class WalletBackend extends $pb.ProtobufEnum {
  static const WalletBackend WALLET_BACKEND_UNSPECIFIED = WalletBackend._(0, _omitEnumNames ? '' : 'WALLET_BACKEND_UNSPECIFIED');
  static const WalletBackend WALLET_BACKEND_ELECTRUM = WalletBackend._(1, _omitEnumNames ? '' : 'WALLET_BACKEND_ELECTRUM');
  static const WalletBackend WALLET_BACKEND_CORE = WalletBackend._(2, _omitEnumNames ? '' : 'WALLET_BACKEND_CORE');

  static const $core.List<WalletBackend> values = <WalletBackend> [
    WALLET_BACKEND_UNSPECIFIED,
    WALLET_BACKEND_ELECTRUM,
    WALLET_BACKEND_CORE,
  ];

  static final $core.Map<$core.int, WalletBackend> _byValue = $pb.ProtobufEnum.initByValue(values);
  static WalletBackend? valueOf($core.int value) => _byValue[value];

  const WalletBackend._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
