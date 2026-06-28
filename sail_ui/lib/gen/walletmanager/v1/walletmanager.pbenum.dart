//
//  Generated code. Do not modify.
//  source: walletmanager/v1/walletmanager.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class WalletType extends $pb.ProtobufEnum {
  static const WalletType WALLET_TYPE_UNSPECIFIED = WalletType._(0, _omitEnumNames ? '' : 'WALLET_TYPE_UNSPECIFIED');
  static const WalletType WALLET_TYPE_BITCOIN_CORE = WalletType._(1, _omitEnumNames ? '' : 'WALLET_TYPE_BITCOIN_CORE');
  static const WalletType WALLET_TYPE_ENFORCER = WalletType._(2, _omitEnumNames ? '' : 'WALLET_TYPE_ENFORCER');
  static const WalletType WALLET_TYPE_ELECTRUM = WalletType._(3, _omitEnumNames ? '' : 'WALLET_TYPE_ELECTRUM');

  static const $core.List<WalletType> values = <WalletType> [
    WALLET_TYPE_UNSPECIFIED,
    WALLET_TYPE_BITCOIN_CORE,
    WALLET_TYPE_ENFORCER,
    WALLET_TYPE_ELECTRUM,
  ];

  static final $core.Map<$core.int, WalletType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static WalletType? valueOf($core.int value) => _byValue[value];

  const WalletType._($core.int v, $core.String n) : super(v, n);
}

class RestoreWalletBackupStepState extends $pb.ProtobufEnum {
  static const RestoreWalletBackupStepState RESTORE_WALLET_BACKUP_STEP_STATE_UNSPECIFIED = RestoreWalletBackupStepState._(0, _omitEnumNames ? '' : 'RESTORE_WALLET_BACKUP_STEP_STATE_UNSPECIFIED');
  static const RestoreWalletBackupStepState RESTORE_WALLET_BACKUP_STEP_STATE_STARTED = RestoreWalletBackupStepState._(1, _omitEnumNames ? '' : 'RESTORE_WALLET_BACKUP_STEP_STATE_STARTED');
  static const RestoreWalletBackupStepState RESTORE_WALLET_BACKUP_STEP_STATE_COMPLETED = RestoreWalletBackupStepState._(2, _omitEnumNames ? '' : 'RESTORE_WALLET_BACKUP_STEP_STATE_COMPLETED');
  static const RestoreWalletBackupStepState RESTORE_WALLET_BACKUP_STEP_STATE_FAILED = RestoreWalletBackupStepState._(3, _omitEnumNames ? '' : 'RESTORE_WALLET_BACKUP_STEP_STATE_FAILED');

  static const $core.List<RestoreWalletBackupStepState> values = <RestoreWalletBackupStepState> [
    RESTORE_WALLET_BACKUP_STEP_STATE_UNSPECIFIED,
    RESTORE_WALLET_BACKUP_STEP_STATE_STARTED,
    RESTORE_WALLET_BACKUP_STEP_STATE_COMPLETED,
    RESTORE_WALLET_BACKUP_STEP_STATE_FAILED,
  ];

  static final $core.Map<$core.int, RestoreWalletBackupStepState> _byValue = $pb.ProtobufEnum.initByValue(values);
  static RestoreWalletBackupStepState? valueOf($core.int value) => _byValue[value];

  const RestoreWalletBackupStepState._($core.int v, $core.String n) : super(v, n);
}

class AddressType extends $pb.ProtobufEnum {
  static const AddressType ADDRESS_TYPE_UNSPECIFIED = AddressType._(0, _omitEnumNames ? '' : 'ADDRESS_TYPE_UNSPECIFIED');
  static const AddressType ADDRESS_TYPE_SEGWIT = AddressType._(1, _omitEnumNames ? '' : 'ADDRESS_TYPE_SEGWIT');
  static const AddressType ADDRESS_TYPE_TAPROOT = AddressType._(2, _omitEnumNames ? '' : 'ADDRESS_TYPE_TAPROOT');

  static const $core.List<AddressType> values = <AddressType> [
    ADDRESS_TYPE_UNSPECIFIED,
    ADDRESS_TYPE_SEGWIT,
    ADDRESS_TYPE_TAPROOT,
  ];

  static final $core.Map<$core.int, AddressType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static AddressType? valueOf($core.int value) => _byValue[value];

  const AddressType._($core.int v, $core.String n) : super(v, n);
}

/// DecodedForm reports which artifact the input was recognized as.
class DecodedForm extends $pb.ProtobufEnum {
  static const DecodedForm DECODED_FORM_UNSPECIFIED = DecodedForm._(0, _omitEnumNames ? '' : 'DECODED_FORM_UNSPECIFIED');
  static const DecodedForm DECODED_FORM_TXID = DecodedForm._(1, _omitEnumNames ? '' : 'DECODED_FORM_TXID');
  static const DecodedForm DECODED_FORM_RAW_TX = DecodedForm._(2, _omitEnumNames ? '' : 'DECODED_FORM_RAW_TX');
  static const DecodedForm DECODED_FORM_PSBT = DecodedForm._(3, _omitEnumNames ? '' : 'DECODED_FORM_PSBT');

  static const $core.List<DecodedForm> values = <DecodedForm> [
    DECODED_FORM_UNSPECIFIED,
    DECODED_FORM_TXID,
    DECODED_FORM_RAW_TX,
    DECODED_FORM_PSBT,
  ];

  static final $core.Map<$core.int, DecodedForm> _byValue = $pb.ProtobufEnum.initByValue(values);
  static DecodedForm? valueOf($core.int value) => _byValue[value];

  const DecodedForm._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
