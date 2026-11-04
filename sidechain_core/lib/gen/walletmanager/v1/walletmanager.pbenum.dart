// This is a generated file - do not edit.
//
// Generated from walletmanager/v1/walletmanager.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// WalletState is the lock state of the wallet file.
class WalletState extends $pb.ProtobufEnum {
  static const WalletState WALLET_STATE_UNSPECIFIED =
      WalletState._(0, _omitEnumNames ? '' : 'WALLET_STATE_UNSPECIFIED');

  /// No wallet file exists.
  static const WalletState WALLET_STATE_NO_WALLET = WalletState._(1, _omitEnumNames ? '' : 'WALLET_STATE_NO_WALLET');

  /// The wallet file exists, but its wallets are not loaded.
  static const WalletState WALLET_STATE_LOCKED = WalletState._(2, _omitEnumNames ? '' : 'WALLET_STATE_LOCKED');

  /// The wallets are loaded.
  static const WalletState WALLET_STATE_UNLOCKED = WalletState._(3, _omitEnumNames ? '' : 'WALLET_STATE_UNLOCKED');

  static const $core.List<WalletState> values = <WalletState>[
    WALLET_STATE_UNSPECIFIED,
    WALLET_STATE_NO_WALLET,
    WALLET_STATE_LOCKED,
    WALLET_STATE_UNLOCKED,
  ];

  static final $core.List<WalletState?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 3);
  static WalletState? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const WalletState._(super.value, super.name);
}

/// NodeMode is how much of Bitcoin this install runs.
class NodeMode extends $pb.ProtobufEnum {
  /// The user never picked. The frontend must ask before it boots anything.
  static const NodeMode NODE_MODE_UNSPECIFIED = NodeMode._(0, _omitEnumNames ? '' : 'NODE_MODE_UNSPECIFIED');

  /// Runs Bitcoin Core and the enforcer on this machine.
  static const NodeMode NODE_MODE_FULL = NodeMode._(1, _omitEnumNames ? '' : 'NODE_MODE_FULL');

  /// Runs local sidechains with remote Bitcoin services.
  static const NodeMode NODE_MODE_LIGHT = NodeMode._(2, _omitEnumNames ? '' : 'NODE_MODE_LIGHT');

  static const $core.List<NodeMode> values = <NodeMode>[
    NODE_MODE_UNSPECIFIED,
    NODE_MODE_FULL,
    NODE_MODE_LIGHT,
  ];

  static final $core.List<NodeMode?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 2);
  static NodeMode? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const NodeMode._(super.value, super.name);
}

class WalletType extends $pb.ProtobufEnum {
  static const WalletType WALLET_TYPE_UNSPECIFIED = WalletType._(0, _omitEnumNames ? '' : 'WALLET_TYPE_UNSPECIFIED');
  static const WalletType WALLET_TYPE_BITCOIN_CORE = WalletType._(1, _omitEnumNames ? '' : 'WALLET_TYPE_BITCOIN_CORE');
  static const WalletType WALLET_TYPE_ENFORCER = WalletType._(2, _omitEnumNames ? '' : 'WALLET_TYPE_ENFORCER');

  /// Electrum wallet — keys are local, but it runs neither Bitcoin Core nor the
  /// enforcer locally; chain/wallet read data is served via the datasource layer.
  static const WalletType WALLET_TYPE_ELECTRUM = WalletType._(3, _omitEnumNames ? '' : 'WALLET_TYPE_ELECTRUM');

  static const $core.List<WalletType> values = <WalletType>[
    WALLET_TYPE_UNSPECIFIED,
    WALLET_TYPE_BITCOIN_CORE,
    WALLET_TYPE_ENFORCER,
    WALLET_TYPE_ELECTRUM,
  ];

  static final $core.List<WalletType?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 3);
  static WalletType? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const WalletType._(super.value, super.name);
}

class RestoreWalletBackupStepState extends $pb.ProtobufEnum {
  static const RestoreWalletBackupStepState RESTORE_WALLET_BACKUP_STEP_STATE_UNSPECIFIED =
      RestoreWalletBackupStepState._(0, _omitEnumNames ? '' : 'RESTORE_WALLET_BACKUP_STEP_STATE_UNSPECIFIED');
  static const RestoreWalletBackupStepState RESTORE_WALLET_BACKUP_STEP_STATE_STARTED =
      RestoreWalletBackupStepState._(1, _omitEnumNames ? '' : 'RESTORE_WALLET_BACKUP_STEP_STATE_STARTED');
  static const RestoreWalletBackupStepState RESTORE_WALLET_BACKUP_STEP_STATE_COMPLETED =
      RestoreWalletBackupStepState._(2, _omitEnumNames ? '' : 'RESTORE_WALLET_BACKUP_STEP_STATE_COMPLETED');
  static const RestoreWalletBackupStepState RESTORE_WALLET_BACKUP_STEP_STATE_FAILED =
      RestoreWalletBackupStepState._(3, _omitEnumNames ? '' : 'RESTORE_WALLET_BACKUP_STEP_STATE_FAILED');

  static const $core.List<RestoreWalletBackupStepState> values = <RestoreWalletBackupStepState>[
    RESTORE_WALLET_BACKUP_STEP_STATE_UNSPECIFIED,
    RESTORE_WALLET_BACKUP_STEP_STATE_STARTED,
    RESTORE_WALLET_BACKUP_STEP_STATE_COMPLETED,
    RESTORE_WALLET_BACKUP_STEP_STATE_FAILED,
  ];

  static final $core.List<RestoreWalletBackupStepState?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 3);
  static RestoreWalletBackupStepState? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const RestoreWalletBackupStepState._(super.value, super.name);
}

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

class MnemonicKind extends $pb.ProtobufEnum {
  static const MnemonicKind MNEMONIC_KIND_UNSPECIFIED =
      MnemonicKind._(0, _omitEnumNames ? '' : 'MNEMONIC_KIND_UNSPECIFIED');
  static const MnemonicKind MNEMONIC_KIND_BIP39 = MnemonicKind._(1, _omitEnumNames ? '' : 'MNEMONIC_KIND_BIP39');
  static const MnemonicKind MNEMONIC_KIND_ELECTRUM = MnemonicKind._(2, _omitEnumNames ? '' : 'MNEMONIC_KIND_ELECTRUM');
  static const MnemonicKind MNEMONIC_KIND_INVALID = MnemonicKind._(3, _omitEnumNames ? '' : 'MNEMONIC_KIND_INVALID');

  static const $core.List<MnemonicKind> values = <MnemonicKind>[
    MNEMONIC_KIND_UNSPECIFIED,
    MNEMONIC_KIND_BIP39,
    MNEMONIC_KIND_ELECTRUM,
    MNEMONIC_KIND_INVALID,
  ];

  static final $core.List<MnemonicKind?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 3);
  static MnemonicKind? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const MnemonicKind._(super.value, super.name);
}

/// DecodedForm reports which artifact the input was recognized as.
class DecodedForm extends $pb.ProtobufEnum {
  static const DecodedForm DECODED_FORM_UNSPECIFIED =
      DecodedForm._(0, _omitEnumNames ? '' : 'DECODED_FORM_UNSPECIFIED');
  static const DecodedForm DECODED_FORM_TXID = DecodedForm._(1, _omitEnumNames ? '' : 'DECODED_FORM_TXID');
  static const DecodedForm DECODED_FORM_RAW_TX = DecodedForm._(2, _omitEnumNames ? '' : 'DECODED_FORM_RAW_TX');
  static const DecodedForm DECODED_FORM_PSBT = DecodedForm._(3, _omitEnumNames ? '' : 'DECODED_FORM_PSBT');

  static const $core.List<DecodedForm> values = <DecodedForm>[
    DECODED_FORM_UNSPECIFIED,
    DECODED_FORM_TXID,
    DECODED_FORM_RAW_TX,
    DECODED_FORM_PSBT,
  ];

  static final $core.List<DecodedForm?> _byValue = $pb.ProtobufEnum.$_initByValueList(values, 3);
  static DecodedForm? valueOf($core.int value) => value < 0 || value >= _byValue.length ? null : _byValue[value];

  const DecodedForm._(super.value, super.name);
}

const $core.bool _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
