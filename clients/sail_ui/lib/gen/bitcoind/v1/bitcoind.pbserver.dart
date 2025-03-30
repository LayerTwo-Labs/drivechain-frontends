//
//  Generated code. Do not modify.
//  source: bitcoind/v1/bitcoind.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../../google/protobuf/empty.pb.dart' as $1;
import 'bitcoind.pb.dart' as $2;
import 'bitcoind.pbjson.dart';

export 'bitcoind.pb.dart';

abstract class BitcoindServiceBase extends $pb.GeneratedService {
  $async.Future<$2.ListRecentTransactionsResponse> listRecentTransactions($pb.ServerContext ctx, $2.ListRecentTransactionsRequest request);
  $async.Future<$2.ListBlocksResponse> listBlocks($pb.ServerContext ctx, $2.ListBlocksRequest request);
  $async.Future<$2.GetBlockResponse> getBlock($pb.ServerContext ctx, $2.GetBlockRequest request);
  $async.Future<$2.GetBlockchainInfoResponse> getBlockchainInfo($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$2.ListPeersResponse> listPeers($pb.ServerContext ctx, $1.Empty request);
  $async.Future<$2.EstimateSmartFeeResponse> estimateSmartFee($pb.ServerContext ctx, $2.EstimateSmartFeeRequest request);
  $async.Future<$2.GetRawTransactionResponse> getRawTransaction($pb.ServerContext ctx, $2.GetRawTransactionRequest request);
  $async.Future<$2.CreateWalletResponse> createWallet($pb.ServerContext ctx, $2.CreateWalletRequest request);
  $async.Future<$2.BackupWalletResponse> backupWallet($pb.ServerContext ctx, $2.BackupWalletRequest request);
  $async.Future<$2.DumpWalletResponse> dumpWallet($pb.ServerContext ctx, $2.DumpWalletRequest request);
  $async.Future<$2.ImportWalletResponse> importWallet($pb.ServerContext ctx, $2.ImportWalletRequest request);
  $async.Future<$2.UnloadWalletResponse> unloadWallet($pb.ServerContext ctx, $2.UnloadWalletRequest request);
  $async.Future<$2.DumpPrivKeyResponse> dumpPrivKey($pb.ServerContext ctx, $2.DumpPrivKeyRequest request);
  $async.Future<$2.ImportPrivKeyResponse> importPrivKey($pb.ServerContext ctx, $2.ImportPrivKeyRequest request);
  $async.Future<$2.ImportAddressResponse> importAddress($pb.ServerContext ctx, $2.ImportAddressRequest request);
  $async.Future<$2.ImportPubKeyResponse> importPubKey($pb.ServerContext ctx, $2.ImportPubKeyRequest request);
  $async.Future<$2.KeyPoolRefillResponse> keyPoolRefill($pb.ServerContext ctx, $2.KeyPoolRefillRequest request);
  $async.Future<$2.GetAccountResponse> getAccount($pb.ServerContext ctx, $2.GetAccountRequest request);
  $async.Future<$2.SetAccountResponse> setAccount($pb.ServerContext ctx, $2.SetAccountRequest request);
  $async.Future<$2.GetAddressesByAccountResponse> getAddressesByAccount($pb.ServerContext ctx, $2.GetAddressesByAccountRequest request);
  $async.Future<$2.ListAccountsResponse> listAccounts($pb.ServerContext ctx, $2.ListAccountsRequest request);
  $async.Future<$2.AddMultisigAddressResponse> addMultisigAddress($pb.ServerContext ctx, $2.AddMultisigAddressRequest request);
  $async.Future<$2.CreateMultisigResponse> createMultisig($pb.ServerContext ctx, $2.CreateMultisigRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'ListRecentTransactions': return $2.ListRecentTransactionsRequest();
      case 'ListBlocks': return $2.ListBlocksRequest();
      case 'GetBlock': return $2.GetBlockRequest();
      case 'GetBlockchainInfo': return $1.Empty();
      case 'ListPeers': return $1.Empty();
      case 'EstimateSmartFee': return $2.EstimateSmartFeeRequest();
      case 'GetRawTransaction': return $2.GetRawTransactionRequest();
      case 'CreateWallet': return $2.CreateWalletRequest();
      case 'BackupWallet': return $2.BackupWalletRequest();
      case 'DumpWallet': return $2.DumpWalletRequest();
      case 'ImportWallet': return $2.ImportWalletRequest();
      case 'UnloadWallet': return $2.UnloadWalletRequest();
      case 'DumpPrivKey': return $2.DumpPrivKeyRequest();
      case 'ImportPrivKey': return $2.ImportPrivKeyRequest();
      case 'ImportAddress': return $2.ImportAddressRequest();
      case 'ImportPubKey': return $2.ImportPubKeyRequest();
      case 'KeyPoolRefill': return $2.KeyPoolRefillRequest();
      case 'GetAccount': return $2.GetAccountRequest();
      case 'SetAccount': return $2.SetAccountRequest();
      case 'GetAddressesByAccount': return $2.GetAddressesByAccountRequest();
      case 'ListAccounts': return $2.ListAccountsRequest();
      case 'AddMultisigAddress': return $2.AddMultisigAddressRequest();
      case 'CreateMultisig': return $2.CreateMultisigRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'ListRecentTransactions': return this.listRecentTransactions(ctx, request as $2.ListRecentTransactionsRequest);
      case 'ListBlocks': return this.listBlocks(ctx, request as $2.ListBlocksRequest);
      case 'GetBlock': return this.getBlock(ctx, request as $2.GetBlockRequest);
      case 'GetBlockchainInfo': return this.getBlockchainInfo(ctx, request as $1.Empty);
      case 'ListPeers': return this.listPeers(ctx, request as $1.Empty);
      case 'EstimateSmartFee': return this.estimateSmartFee(ctx, request as $2.EstimateSmartFeeRequest);
      case 'GetRawTransaction': return this.getRawTransaction(ctx, request as $2.GetRawTransactionRequest);
      case 'CreateWallet': return this.createWallet(ctx, request as $2.CreateWalletRequest);
      case 'BackupWallet': return this.backupWallet(ctx, request as $2.BackupWalletRequest);
      case 'DumpWallet': return this.dumpWallet(ctx, request as $2.DumpWalletRequest);
      case 'ImportWallet': return this.importWallet(ctx, request as $2.ImportWalletRequest);
      case 'UnloadWallet': return this.unloadWallet(ctx, request as $2.UnloadWalletRequest);
      case 'DumpPrivKey': return this.dumpPrivKey(ctx, request as $2.DumpPrivKeyRequest);
      case 'ImportPrivKey': return this.importPrivKey(ctx, request as $2.ImportPrivKeyRequest);
      case 'ImportAddress': return this.importAddress(ctx, request as $2.ImportAddressRequest);
      case 'ImportPubKey': return this.importPubKey(ctx, request as $2.ImportPubKeyRequest);
      case 'KeyPoolRefill': return this.keyPoolRefill(ctx, request as $2.KeyPoolRefillRequest);
      case 'GetAccount': return this.getAccount(ctx, request as $2.GetAccountRequest);
      case 'SetAccount': return this.setAccount(ctx, request as $2.SetAccountRequest);
      case 'GetAddressesByAccount': return this.getAddressesByAccount(ctx, request as $2.GetAddressesByAccountRequest);
      case 'ListAccounts': return this.listAccounts(ctx, request as $2.ListAccountsRequest);
      case 'AddMultisigAddress': return this.addMultisigAddress(ctx, request as $2.AddMultisigAddressRequest);
      case 'CreateMultisig': return this.createMultisig(ctx, request as $2.CreateMultisigRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => BitcoindServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => BitcoindServiceBase$messageJson;
}

