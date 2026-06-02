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


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
