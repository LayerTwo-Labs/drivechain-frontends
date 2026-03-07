//
//  Generated code. Do not modify.
//  source: walletmanager/v1/walletmanager.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'walletmanager.pb.dart' as $1;
import 'walletmanager.pbjson.dart';

export 'walletmanager.pb.dart';

abstract class WalletManagerServiceBase extends $pb.GeneratedService {
  $async.Future<$1.GetWalletStatusResponse> getWalletStatus($pb.ServerContext ctx, $1.GetWalletStatusRequest request);
  $async.Future<$1.GenerateWalletResponse> generateWallet($pb.ServerContext ctx, $1.GenerateWalletRequest request);
  $async.Future<$1.UnlockWalletResponse> unlockWallet($pb.ServerContext ctx, $1.UnlockWalletRequest request);
  $async.Future<$1.LockWalletResponse> lockWallet($pb.ServerContext ctx, $1.LockWalletRequest request);
  $async.Future<$1.EncryptWalletResponse> encryptWallet($pb.ServerContext ctx, $1.EncryptWalletRequest request);
  $async.Future<$1.ChangePasswordResponse> changePassword($pb.ServerContext ctx, $1.ChangePasswordRequest request);
  $async.Future<$1.RemoveEncryptionResponse> removeEncryption($pb.ServerContext ctx, $1.RemoveEncryptionRequest request);
  $async.Future<$1.ListWalletsResponse> listWallets($pb.ServerContext ctx, $1.ListWalletsRequest request);
  $async.Future<$1.SwitchWalletResponse> switchWallet($pb.ServerContext ctx, $1.SwitchWalletRequest request);
  $async.Future<$1.UpdateWalletMetadataResponse> updateWalletMetadata($pb.ServerContext ctx, $1.UpdateWalletMetadataRequest request);
  $async.Future<$1.DeleteWalletResponse> deleteWallet($pb.ServerContext ctx, $1.DeleteWalletRequest request);
  $async.Future<$1.DeleteAllWalletsResponse> deleteAllWallets($pb.ServerContext ctx, $1.DeleteAllWalletsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetWalletStatus': return $1.GetWalletStatusRequest();
      case 'GenerateWallet': return $1.GenerateWalletRequest();
      case 'UnlockWallet': return $1.UnlockWalletRequest();
      case 'LockWallet': return $1.LockWalletRequest();
      case 'EncryptWallet': return $1.EncryptWalletRequest();
      case 'ChangePassword': return $1.ChangePasswordRequest();
      case 'RemoveEncryption': return $1.RemoveEncryptionRequest();
      case 'ListWallets': return $1.ListWalletsRequest();
      case 'SwitchWallet': return $1.SwitchWalletRequest();
      case 'UpdateWalletMetadata': return $1.UpdateWalletMetadataRequest();
      case 'DeleteWallet': return $1.DeleteWalletRequest();
      case 'DeleteAllWallets': return $1.DeleteAllWalletsRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetWalletStatus': return this.getWalletStatus(ctx, request as $1.GetWalletStatusRequest);
      case 'GenerateWallet': return this.generateWallet(ctx, request as $1.GenerateWalletRequest);
      case 'UnlockWallet': return this.unlockWallet(ctx, request as $1.UnlockWalletRequest);
      case 'LockWallet': return this.lockWallet(ctx, request as $1.LockWalletRequest);
      case 'EncryptWallet': return this.encryptWallet(ctx, request as $1.EncryptWalletRequest);
      case 'ChangePassword': return this.changePassword(ctx, request as $1.ChangePasswordRequest);
      case 'RemoveEncryption': return this.removeEncryption(ctx, request as $1.RemoveEncryptionRequest);
      case 'ListWallets': return this.listWallets(ctx, request as $1.ListWalletsRequest);
      case 'SwitchWallet': return this.switchWallet(ctx, request as $1.SwitchWalletRequest);
      case 'UpdateWalletMetadata': return this.updateWalletMetadata(ctx, request as $1.UpdateWalletMetadataRequest);
      case 'DeleteWallet': return this.deleteWallet(ctx, request as $1.DeleteWalletRequest);
      case 'DeleteAllWallets': return this.deleteAllWallets(ctx, request as $1.DeleteAllWalletsRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WalletManagerServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => WalletManagerServiceBase$messageJson;
}

