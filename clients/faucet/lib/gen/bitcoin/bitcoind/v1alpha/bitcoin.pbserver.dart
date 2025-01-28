//
//  Generated code. Do not modify.
//  source: bitcoin/bitcoind/v1alpha/bitcoin.proto
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

import '../../../google/protobuf/empty.pb.dart' as $2;
import 'bitcoin.pb.dart' as $3;
import 'bitcoin.pbjson.dart';

export 'bitcoin.pb.dart';

abstract class BitcoinServiceBase extends $pb.GeneratedService {
  $async.Future<$3.GetBlockchainInfoResponse> getBlockchainInfo($pb.ServerContext ctx, $3.GetBlockchainInfoRequest request);
  $async.Future<$3.GetPeerInfoResponse> getPeerInfo($pb.ServerContext ctx, $3.GetPeerInfoRequest request);
  $async.Future<$3.GetTransactionResponse> getTransaction($pb.ServerContext ctx, $3.GetTransactionRequest request);
  $async.Future<$3.ListSinceBlockResponse> listSinceBlock($pb.ServerContext ctx, $3.ListSinceBlockRequest request);
  $async.Future<$3.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $3.GetNewAddressRequest request);
  $async.Future<$3.GetWalletInfoResponse> getWalletInfo($pb.ServerContext ctx, $3.GetWalletInfoRequest request);
  $async.Future<$3.GetBalancesResponse> getBalances($pb.ServerContext ctx, $3.GetBalancesRequest request);
  $async.Future<$3.SendResponse> send($pb.ServerContext ctx, $3.SendRequest request);
  $async.Future<$3.SendToAddressResponse> sendToAddress($pb.ServerContext ctx, $3.SendToAddressRequest request);
  $async.Future<$3.BumpFeeResponse> bumpFee($pb.ServerContext ctx, $3.BumpFeeRequest request);
  $async.Future<$3.EstimateSmartFeeResponse> estimateSmartFee($pb.ServerContext ctx, $3.EstimateSmartFeeRequest request);
  $async.Future<$3.ImportDescriptorsResponse> importDescriptors($pb.ServerContext ctx, $3.ImportDescriptorsRequest request);
  $async.Future<$3.ListWalletsResponse> listWallets($pb.ServerContext ctx, $2.Empty request);
  $async.Future<$3.ListTransactionsResponse> listTransactions($pb.ServerContext ctx, $3.ListTransactionsRequest request);
  $async.Future<$3.GetDescriptorInfoResponse> getDescriptorInfo($pb.ServerContext ctx, $3.GetDescriptorInfoRequest request);
  $async.Future<$3.GetAddressInfoResponse> getAddressInfo($pb.ServerContext ctx, $3.GetAddressInfoRequest request);
  $async.Future<$3.GetRawMempoolResponse> getRawMempool($pb.ServerContext ctx, $3.GetRawMempoolRequest request);
  $async.Future<$3.GetRawTransactionResponse> getRawTransaction($pb.ServerContext ctx, $3.GetRawTransactionRequest request);
  $async.Future<$3.DecodeRawTransactionResponse> decodeRawTransaction($pb.ServerContext ctx, $3.DecodeRawTransactionRequest request);
  $async.Future<$3.GetBlockResponse> getBlock($pb.ServerContext ctx, $3.GetBlockRequest request);
  $async.Future<$3.GetBlockHashResponse> getBlockHash($pb.ServerContext ctx, $3.GetBlockHashRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBlockchainInfo': return $3.GetBlockchainInfoRequest();
      case 'GetPeerInfo': return $3.GetPeerInfoRequest();
      case 'GetTransaction': return $3.GetTransactionRequest();
      case 'ListSinceBlock': return $3.ListSinceBlockRequest();
      case 'GetNewAddress': return $3.GetNewAddressRequest();
      case 'GetWalletInfo': return $3.GetWalletInfoRequest();
      case 'GetBalances': return $3.GetBalancesRequest();
      case 'Send': return $3.SendRequest();
      case 'SendToAddress': return $3.SendToAddressRequest();
      case 'BumpFee': return $3.BumpFeeRequest();
      case 'EstimateSmartFee': return $3.EstimateSmartFeeRequest();
      case 'ImportDescriptors': return $3.ImportDescriptorsRequest();
      case 'ListWallets': return $2.Empty();
      case 'ListTransactions': return $3.ListTransactionsRequest();
      case 'GetDescriptorInfo': return $3.GetDescriptorInfoRequest();
      case 'GetAddressInfo': return $3.GetAddressInfoRequest();
      case 'GetRawMempool': return $3.GetRawMempoolRequest();
      case 'GetRawTransaction': return $3.GetRawTransactionRequest();
      case 'DecodeRawTransaction': return $3.DecodeRawTransactionRequest();
      case 'GetBlock': return $3.GetBlockRequest();
      case 'GetBlockHash': return $3.GetBlockHashRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBlockchainInfo': return this.getBlockchainInfo(ctx, request as $3.GetBlockchainInfoRequest);
      case 'GetPeerInfo': return this.getPeerInfo(ctx, request as $3.GetPeerInfoRequest);
      case 'GetTransaction': return this.getTransaction(ctx, request as $3.GetTransactionRequest);
      case 'ListSinceBlock': return this.listSinceBlock(ctx, request as $3.ListSinceBlockRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $3.GetNewAddressRequest);
      case 'GetWalletInfo': return this.getWalletInfo(ctx, request as $3.GetWalletInfoRequest);
      case 'GetBalances': return this.getBalances(ctx, request as $3.GetBalancesRequest);
      case 'Send': return this.send(ctx, request as $3.SendRequest);
      case 'SendToAddress': return this.sendToAddress(ctx, request as $3.SendToAddressRequest);
      case 'BumpFee': return this.bumpFee(ctx, request as $3.BumpFeeRequest);
      case 'EstimateSmartFee': return this.estimateSmartFee(ctx, request as $3.EstimateSmartFeeRequest);
      case 'ImportDescriptors': return this.importDescriptors(ctx, request as $3.ImportDescriptorsRequest);
      case 'ListWallets': return this.listWallets(ctx, request as $2.Empty);
      case 'ListTransactions': return this.listTransactions(ctx, request as $3.ListTransactionsRequest);
      case 'GetDescriptorInfo': return this.getDescriptorInfo(ctx, request as $3.GetDescriptorInfoRequest);
      case 'GetAddressInfo': return this.getAddressInfo(ctx, request as $3.GetAddressInfoRequest);
      case 'GetRawMempool': return this.getRawMempool(ctx, request as $3.GetRawMempoolRequest);
      case 'GetRawTransaction': return this.getRawTransaction(ctx, request as $3.GetRawTransactionRequest);
      case 'DecodeRawTransaction': return this.decodeRawTransaction(ctx, request as $3.DecodeRawTransactionRequest);
      case 'GetBlock': return this.getBlock(ctx, request as $3.GetBlockRequest);
      case 'GetBlockHash': return this.getBlockHash(ctx, request as $3.GetBlockHashRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => BitcoinServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => BitcoinServiceBase$messageJson;
}

