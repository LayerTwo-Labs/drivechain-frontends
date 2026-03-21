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

import 'walletmanager.pb.dart' as $5;
import 'walletmanager.pbjson.dart';

export 'walletmanager.pb.dart';

abstract class WalletManagerServiceBase extends $pb.GeneratedService {
  $async.Future<$5.GetWalletStatusResponse> getWalletStatus($pb.ServerContext ctx, $5.GetWalletStatusRequest request);
  $async.Future<$5.GenerateWalletResponse> generateWallet($pb.ServerContext ctx, $5.GenerateWalletRequest request);
  $async.Future<$5.UnlockWalletResponse> unlockWallet($pb.ServerContext ctx, $5.UnlockWalletRequest request);
  $async.Future<$5.LockWalletResponse> lockWallet($pb.ServerContext ctx, $5.LockWalletRequest request);
  $async.Future<$5.EncryptWalletResponse> encryptWallet($pb.ServerContext ctx, $5.EncryptWalletRequest request);
  $async.Future<$5.ChangePasswordResponse> changePassword($pb.ServerContext ctx, $5.ChangePasswordRequest request);
  $async.Future<$5.RemoveEncryptionResponse> removeEncryption($pb.ServerContext ctx, $5.RemoveEncryptionRequest request);
  $async.Future<$5.ListWalletsResponse> listWallets($pb.ServerContext ctx, $5.ListWalletsRequest request);
  $async.Future<$5.SwitchWalletResponse> switchWallet($pb.ServerContext ctx, $5.SwitchWalletRequest request);
  $async.Future<$5.UpdateWalletMetadataResponse> updateWalletMetadata($pb.ServerContext ctx, $5.UpdateWalletMetadataRequest request);
  $async.Future<$5.DeleteWalletResponse> deleteWallet($pb.ServerContext ctx, $5.DeleteWalletRequest request);
  $async.Future<$5.DeleteAllWalletsResponse> deleteAllWallets($pb.ServerContext ctx, $5.DeleteAllWalletsRequest request);
  $async.Future<$5.CreateWatchOnlyWalletResponse> createWatchOnlyWallet($pb.ServerContext ctx, $5.CreateWatchOnlyWalletRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetWalletStatus': return $5.GetWalletStatusRequest();
      case 'GenerateWallet': return $5.GenerateWalletRequest();
      case 'UnlockWallet': return $5.UnlockWalletRequest();
      case 'LockWallet': return $5.LockWalletRequest();
      case 'EncryptWallet': return $5.EncryptWalletRequest();
      case 'ChangePassword': return $5.ChangePasswordRequest();
      case 'RemoveEncryption': return $5.RemoveEncryptionRequest();
      case 'ListWallets': return $5.ListWalletsRequest();
      case 'SwitchWallet': return $5.SwitchWalletRequest();
      case 'UpdateWalletMetadata': return $5.UpdateWalletMetadataRequest();
      case 'DeleteWallet': return $5.DeleteWalletRequest();
      case 'DeleteAllWallets': return $5.DeleteAllWalletsRequest();
      case 'CreateWatchOnlyWallet': return $5.CreateWatchOnlyWalletRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetWalletStatus': return this.getWalletStatus(ctx, request as $5.GetWalletStatusRequest);
      case 'GenerateWallet': return this.generateWallet(ctx, request as $5.GenerateWalletRequest);
      case 'UnlockWallet': return this.unlockWallet(ctx, request as $5.UnlockWalletRequest);
      case 'LockWallet': return this.lockWallet(ctx, request as $5.LockWalletRequest);
      case 'EncryptWallet': return this.encryptWallet(ctx, request as $5.EncryptWalletRequest);
      case 'ChangePassword': return this.changePassword(ctx, request as $5.ChangePasswordRequest);
      case 'RemoveEncryption': return this.removeEncryption(ctx, request as $5.RemoveEncryptionRequest);
      case 'ListWallets': return this.listWallets(ctx, request as $5.ListWalletsRequest);
      case 'SwitchWallet': return this.switchWallet(ctx, request as $5.SwitchWalletRequest);
      case 'UpdateWalletMetadata': return this.updateWalletMetadata(ctx, request as $5.UpdateWalletMetadataRequest);
      case 'DeleteWallet': return this.deleteWallet(ctx, request as $5.DeleteWalletRequest);
      case 'DeleteAllWallets': return this.deleteAllWallets(ctx, request as $5.DeleteAllWalletsRequest);
      case 'CreateWatchOnlyWallet': return this.createWatchOnlyWallet(ctx, request as $5.CreateWatchOnlyWalletRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => WalletManagerServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => WalletManagerServiceBase$messageJson;
}

