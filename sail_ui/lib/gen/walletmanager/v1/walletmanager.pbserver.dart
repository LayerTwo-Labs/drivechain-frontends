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

import 'walletmanager.pb.dart' as $4;
import 'walletmanager.pbjson.dart';

export 'walletmanager.pb.dart';

abstract class WalletManagerServiceBase extends $pb.GeneratedService {
  $async.Future<$4.GetWalletStatusResponse> getWalletStatus($pb.ServerContext ctx, $4.GetWalletStatusRequest request);
  $async.Future<$4.GenerateWalletResponse> generateWallet($pb.ServerContext ctx, $4.GenerateWalletRequest request);
  $async.Future<$4.UnlockWalletResponse> unlockWallet($pb.ServerContext ctx, $4.UnlockWalletRequest request);
  $async.Future<$4.LockWalletResponse> lockWallet($pb.ServerContext ctx, $4.LockWalletRequest request);
  $async.Future<$4.EncryptWalletResponse> encryptWallet($pb.ServerContext ctx, $4.EncryptWalletRequest request);
  $async.Future<$4.ChangePasswordResponse> changePassword($pb.ServerContext ctx, $4.ChangePasswordRequest request);
  $async.Future<$4.RemoveEncryptionResponse> removeEncryption($pb.ServerContext ctx, $4.RemoveEncryptionRequest request);
  $async.Future<$4.ListWalletsResponse> listWallets($pb.ServerContext ctx, $4.ListWalletsRequest request);
  $async.Future<$4.SwitchWalletResponse> switchWallet($pb.ServerContext ctx, $4.SwitchWalletRequest request);
  $async.Future<$4.UpdateWalletMetadataResponse> updateWalletMetadata($pb.ServerContext ctx, $4.UpdateWalletMetadataRequest request);
  $async.Future<$4.DeleteWalletResponse> deleteWallet($pb.ServerContext ctx, $4.DeleteWalletRequest request);
  $async.Future<$4.DeleteAllWalletsResponse> deleteAllWallets($pb.ServerContext ctx, $4.DeleteAllWalletsRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetWalletStatus': return $4.GetWalletStatusRequest();
      case 'GenerateWallet': return $4.GenerateWalletRequest();
      case 'UnlockWallet': return $4.UnlockWalletRequest();
      case 'LockWallet': return $4.LockWalletRequest();
      case 'EncryptWallet': return $4.EncryptWalletRequest();
      case 'ChangePassword': return $4.ChangePasswordRequest();
      case 'RemoveEncryption': return $4.RemoveEncryptionRequest();
      case 'ListWallets': return $4.ListWalletsRequest();
      case 'SwitchWallet': return $4.SwitchWalletRequest();
      case 'UpdateWalletMetadata': return $4.UpdateWalletMetadataRequest();
      case 'DeleteWallet': return $4.DeleteWalletRequest();
      case 'DeleteAllWallets': return $4.DeleteAllWalletsRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetWalletStatus': return this.getWalletStatus(ctx, request as $4.GetWalletStatusRequest);
      case 'GenerateWallet': return this.generateWallet(ctx, request as $4.GenerateWalletRequest);
      case 'UnlockWallet': return this.unlockWallet(ctx, request as $4.UnlockWalletRequest);
      case 'LockWallet': return this.lockWallet(ctx, request as $4.LockWalletRequest);
      case 'EncryptWallet': return this.encryptWallet(ctx, request as $4.EncryptWalletRequest);
      case 'ChangePassword': return this.changePassword(ctx, request as $4.ChangePasswordRequest);
      case 'RemoveEncryption': return this.removeEncryption(ctx, request as $4.RemoveEncryptionRequest);
      case 'ListWallets': return this.listWallets(ctx, request as $4.ListWalletsRequest);
      case 'SwitchWallet': return this.switchWallet(ctx, request as $4.SwitchWalletRequest);
      case 'UpdateWalletMetadata': return this.updateWalletMetadata(ctx, request as $4.UpdateWalletMetadataRequest);
      case 'DeleteWallet': return this.deleteWallet(ctx, request as $4.DeleteWalletRequest);
      case 'DeleteAllWallets': return this.deleteAllWallets(ctx, request as $4.DeleteAllWalletsRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WalletManagerServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => WalletManagerServiceBase$messageJson;
}

