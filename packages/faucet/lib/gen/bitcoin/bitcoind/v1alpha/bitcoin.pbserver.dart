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

import 'bitcoin.pb.dart' as $2;
import 'bitcoin.pbjson.dart';

export 'bitcoin.pb.dart';

abstract class BitcoinServiceBase extends $pb.GeneratedService {
  $async.Future<$2.GetBlockchainInfoResponse> getBlockchainInfo($pb.ServerContext ctx, $2.GetBlockchainInfoRequest request);
  $async.Future<$2.GetTransactionResponse> getTransaction($pb.ServerContext ctx, $2.GetTransactionRequest request);
  $async.Future<$2.ListSinceBlockResponse> listSinceBlock($pb.ServerContext ctx, $2.ListSinceBlockRequest request);
  $async.Future<$2.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $2.GetNewAddressRequest request);
  $async.Future<$2.GetWalletInfoResponse> getWalletInfo($pb.ServerContext ctx, $2.GetWalletInfoRequest request);
  $async.Future<$2.GetBalancesResponse> getBalances($pb.ServerContext ctx, $2.GetBalancesRequest request);
  $async.Future<$2.SendResponse> send($pb.ServerContext ctx, $2.SendRequest request);
  $async.Future<$2.SendToAddressResponse> sendToAddress($pb.ServerContext ctx, $2.SendToAddressRequest request);
  $async.Future<$2.BumpFeeResponse> bumpFee($pb.ServerContext ctx, $2.BumpFeeRequest request);
  $async.Future<$2.EstimateSmartFeeResponse> estimateSmartFee($pb.ServerContext ctx, $2.EstimateSmartFeeRequest request);
  $async.Future<$2.ImportDescriptorsResponse> importDescriptors($pb.ServerContext ctx, $2.ImportDescriptorsRequest request);
  $async.Future<$2.ListTransactionsResponse> listTransactions($pb.ServerContext ctx, $2.ListTransactionsRequest request);
  $async.Future<$2.GetDescriptorInfoResponse> getDescriptorInfo($pb.ServerContext ctx, $2.GetDescriptorInfoRequest request);
  $async.Future<$2.GetRawMempoolResponse> getRawMempool($pb.ServerContext ctx, $2.GetRawMempoolRequest request);
  $async.Future<$2.GetRawTransactionResponse> getRawTransaction($pb.ServerContext ctx, $2.GetRawTransactionRequest request);
  $async.Future<$2.DecodeRawTransactionResponse> decodeRawTransaction($pb.ServerContext ctx, $2.DecodeRawTransactionRequest request);
  $async.Future<$2.GetBlockResponse> getBlock($pb.ServerContext ctx, $2.GetBlockRequest request);
  $async.Future<$2.GetBlockHashResponse> getBlockHash($pb.ServerContext ctx, $2.GetBlockHashRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBlockchainInfo': return $2.GetBlockchainInfoRequest();
      case 'GetTransaction': return $2.GetTransactionRequest();
      case 'ListSinceBlock': return $2.ListSinceBlockRequest();
      case 'GetNewAddress': return $2.GetNewAddressRequest();
      case 'GetWalletInfo': return $2.GetWalletInfoRequest();
      case 'GetBalances': return $2.GetBalancesRequest();
      case 'Send': return $2.SendRequest();
      case 'SendToAddress': return $2.SendToAddressRequest();
      case 'BumpFee': return $2.BumpFeeRequest();
      case 'EstimateSmartFee': return $2.EstimateSmartFeeRequest();
      case 'ImportDescriptors': return $2.ImportDescriptorsRequest();
      case 'ListTransactions': return $2.ListTransactionsRequest();
      case 'GetDescriptorInfo': return $2.GetDescriptorInfoRequest();
      case 'GetRawMempool': return $2.GetRawMempoolRequest();
      case 'GetRawTransaction': return $2.GetRawTransactionRequest();
      case 'DecodeRawTransaction': return $2.DecodeRawTransactionRequest();
      case 'GetBlock': return $2.GetBlockRequest();
      case 'GetBlockHash': return $2.GetBlockHashRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBlockchainInfo': return this.getBlockchainInfo(ctx, request as $2.GetBlockchainInfoRequest);
      case 'GetTransaction': return this.getTransaction(ctx, request as $2.GetTransactionRequest);
      case 'ListSinceBlock': return this.listSinceBlock(ctx, request as $2.ListSinceBlockRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $2.GetNewAddressRequest);
      case 'GetWalletInfo': return this.getWalletInfo(ctx, request as $2.GetWalletInfoRequest);
      case 'GetBalances': return this.getBalances(ctx, request as $2.GetBalancesRequest);
      case 'Send': return this.send(ctx, request as $2.SendRequest);
      case 'SendToAddress': return this.sendToAddress(ctx, request as $2.SendToAddressRequest);
      case 'BumpFee': return this.bumpFee(ctx, request as $2.BumpFeeRequest);
      case 'EstimateSmartFee': return this.estimateSmartFee(ctx, request as $2.EstimateSmartFeeRequest);
      case 'ImportDescriptors': return this.importDescriptors(ctx, request as $2.ImportDescriptorsRequest);
      case 'ListTransactions': return this.listTransactions(ctx, request as $2.ListTransactionsRequest);
      case 'GetDescriptorInfo': return this.getDescriptorInfo(ctx, request as $2.GetDescriptorInfoRequest);
      case 'GetRawMempool': return this.getRawMempool(ctx, request as $2.GetRawMempoolRequest);
      case 'GetRawTransaction': return this.getRawTransaction(ctx, request as $2.GetRawTransactionRequest);
      case 'DecodeRawTransaction': return this.decodeRawTransaction(ctx, request as $2.DecodeRawTransactionRequest);
      case 'GetBlock': return this.getBlock(ctx, request as $2.GetBlockRequest);
      case 'GetBlockHash': return this.getBlockHash(ctx, request as $2.GetBlockHashRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => BitcoinServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => BitcoinServiceBase$messageJson;
}

