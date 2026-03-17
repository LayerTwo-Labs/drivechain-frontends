//
//  Generated code. Do not modify.
//  source: walletmanager/v1/walletmanager.proto
//

import "package:connectrpc/connect.dart" as connect;
import "walletmanager.pb.dart" as walletmanagerv1walletmanager;
import "walletmanager.connect.spec.dart" as specs;

extension type WalletManagerServiceClient (connect.Transport _transport) {
  Future<walletmanagerv1walletmanager.GetWalletStatusResponse> getWalletStatus(
    walletmanagerv1walletmanager.GetWalletStatusRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.getWalletStatus,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.GenerateWalletResponse> generateWallet(
    walletmanagerv1walletmanager.GenerateWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.generateWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.UnlockWalletResponse> unlockWallet(
    walletmanagerv1walletmanager.UnlockWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.unlockWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.LockWalletResponse> lockWallet(
    walletmanagerv1walletmanager.LockWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.lockWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.EncryptWalletResponse> encryptWallet(
    walletmanagerv1walletmanager.EncryptWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.encryptWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.ChangePasswordResponse> changePassword(
    walletmanagerv1walletmanager.ChangePasswordRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.changePassword,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.RemoveEncryptionResponse> removeEncryption(
    walletmanagerv1walletmanager.RemoveEncryptionRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.removeEncryption,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.ListWalletsResponse> listWallets(
    walletmanagerv1walletmanager.ListWalletsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.listWallets,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.SwitchWalletResponse> switchWallet(
    walletmanagerv1walletmanager.SwitchWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.switchWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.UpdateWalletMetadataResponse> updateWalletMetadata(
    walletmanagerv1walletmanager.UpdateWalletMetadataRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.updateWalletMetadata,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.DeleteWalletResponse> deleteWallet(
    walletmanagerv1walletmanager.DeleteWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.deleteWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.DeleteAllWalletsResponse> deleteAllWallets(
    walletmanagerv1walletmanager.DeleteAllWalletsRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.deleteAllWallets,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }

  Future<walletmanagerv1walletmanager.CreateWatchOnlyWalletResponse> createWatchOnlyWallet(
    walletmanagerv1walletmanager.CreateWatchOnlyWalletRequest input, {
    connect.Headers? headers,
    connect.AbortSignal? signal,
    Function(connect.Headers)? onHeader,
    Function(connect.Headers)? onTrailer,
  }) {
    return connect.Client(_transport).unary(
      specs.WalletManagerService.createWatchOnlyWallet,
      input,
      signal: signal,
      headers: headers,
      onHeader: onHeader,
      onTrailer: onTrailer,
    );
  }
}
