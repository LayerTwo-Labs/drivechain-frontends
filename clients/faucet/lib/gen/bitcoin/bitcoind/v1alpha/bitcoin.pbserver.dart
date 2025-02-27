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

import '../../../google/protobuf/empty.pb.dart' as $3;
import 'bitcoin.pb.dart' as $4;
import 'bitcoin.pbjson.dart';

export 'bitcoin.pb.dart';

abstract class BitcoinServiceBase extends $pb.GeneratedService {
  $async.Future<$4.GetBlockchainInfoResponse> getBlockchainInfo($pb.ServerContext ctx, $4.GetBlockchainInfoRequest request);
  $async.Future<$4.GetPeerInfoResponse> getPeerInfo($pb.ServerContext ctx, $4.GetPeerInfoRequest request);
  $async.Future<$4.GetTransactionResponse> getTransaction($pb.ServerContext ctx, $4.GetTransactionRequest request);
  $async.Future<$4.ListSinceBlockResponse> listSinceBlock($pb.ServerContext ctx, $4.ListSinceBlockRequest request);
  $async.Future<$4.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $4.GetNewAddressRequest request);
  $async.Future<$4.GetWalletInfoResponse> getWalletInfo($pb.ServerContext ctx, $4.GetWalletInfoRequest request);
  $async.Future<$4.GetBalancesResponse> getBalances($pb.ServerContext ctx, $4.GetBalancesRequest request);
  $async.Future<$4.SendResponse> send($pb.ServerContext ctx, $4.SendRequest request);
  $async.Future<$4.SendToAddressResponse> sendToAddress($pb.ServerContext ctx, $4.SendToAddressRequest request);
  $async.Future<$4.BumpFeeResponse> bumpFee($pb.ServerContext ctx, $4.BumpFeeRequest request);
  $async.Future<$4.EstimateSmartFeeResponse> estimateSmartFee($pb.ServerContext ctx, $4.EstimateSmartFeeRequest request);
  $async.Future<$4.ImportDescriptorsResponse> importDescriptors($pb.ServerContext ctx, $4.ImportDescriptorsRequest request);
  $async.Future<$4.ListWalletsResponse> listWallets($pb.ServerContext ctx, $3.Empty request);
  $async.Future<$4.ListTransactionsResponse> listTransactions($pb.ServerContext ctx, $4.ListTransactionsRequest request);
  $async.Future<$4.GetDescriptorInfoResponse> getDescriptorInfo($pb.ServerContext ctx, $4.GetDescriptorInfoRequest request);
  $async.Future<$4.GetAddressInfoResponse> getAddressInfo($pb.ServerContext ctx, $4.GetAddressInfoRequest request);
  $async.Future<$4.GetRawMempoolResponse> getRawMempool($pb.ServerContext ctx, $4.GetRawMempoolRequest request);
  $async.Future<$4.GetRawTransactionResponse> getRawTransaction($pb.ServerContext ctx, $4.GetRawTransactionRequest request);
  $async.Future<$4.DecodeRawTransactionResponse> decodeRawTransaction($pb.ServerContext ctx, $4.DecodeRawTransactionRequest request);
  $async.Future<$4.GetBlockResponse> getBlock($pb.ServerContext ctx, $4.GetBlockRequest request);
  $async.Future<$4.GetBlockHashResponse> getBlockHash($pb.ServerContext ctx, $4.GetBlockHashRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBlockchainInfo': return $4.GetBlockchainInfoRequest();
      case 'GetPeerInfo': return $4.GetPeerInfoRequest();
      case 'GetTransaction': return $4.GetTransactionRequest();
      case 'ListSinceBlock': return $4.ListSinceBlockRequest();
      case 'GetNewAddress': return $4.GetNewAddressRequest();
      case 'GetWalletInfo': return $4.GetWalletInfoRequest();
      case 'GetBalances': return $4.GetBalancesRequest();
      case 'Send': return $4.SendRequest();
      case 'SendToAddress': return $4.SendToAddressRequest();
      case 'BumpFee': return $4.BumpFeeRequest();
      case 'EstimateSmartFee': return $4.EstimateSmartFeeRequest();
      case 'ImportDescriptors': return $4.ImportDescriptorsRequest();
      case 'ListWallets': return $3.Empty();
      case 'ListTransactions': return $4.ListTransactionsRequest();
      case 'GetDescriptorInfo': return $4.GetDescriptorInfoRequest();
      case 'GetAddressInfo': return $4.GetAddressInfoRequest();
      case 'GetRawMempool': return $4.GetRawMempoolRequest();
      case 'GetRawTransaction': return $4.GetRawTransactionRequest();
      case 'DecodeRawTransaction': return $4.DecodeRawTransactionRequest();
      case 'GetBlock': return $4.GetBlockRequest();
      case 'GetBlockHash': return $4.GetBlockHashRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBlockchainInfo': return this.getBlockchainInfo(ctx, request as $4.GetBlockchainInfoRequest);
      case 'GetPeerInfo': return this.getPeerInfo(ctx, request as $4.GetPeerInfoRequest);
      case 'GetTransaction': return this.getTransaction(ctx, request as $4.GetTransactionRequest);
      case 'ListSinceBlock': return this.listSinceBlock(ctx, request as $4.ListSinceBlockRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $4.GetNewAddressRequest);
      case 'GetWalletInfo': return this.getWalletInfo(ctx, request as $4.GetWalletInfoRequest);
      case 'GetBalances': return this.getBalances(ctx, request as $4.GetBalancesRequest);
      case 'Send': return this.send(ctx, request as $4.SendRequest);
      case 'SendToAddress': return this.sendToAddress(ctx, request as $4.SendToAddressRequest);
      case 'BumpFee': return this.bumpFee(ctx, request as $4.BumpFeeRequest);
      case 'EstimateSmartFee': return this.estimateSmartFee(ctx, request as $4.EstimateSmartFeeRequest);
      case 'ImportDescriptors': return this.importDescriptors(ctx, request as $4.ImportDescriptorsRequest);
      case 'ListWallets': return this.listWallets(ctx, request as $3.Empty);
      case 'ListTransactions': return this.listTransactions(ctx, request as $4.ListTransactionsRequest);
      case 'GetDescriptorInfo': return this.getDescriptorInfo(ctx, request as $4.GetDescriptorInfoRequest);
      case 'GetAddressInfo': return this.getAddressInfo(ctx, request as $4.GetAddressInfoRequest);
      case 'GetRawMempool': return this.getRawMempool(ctx, request as $4.GetRawMempoolRequest);
      case 'GetRawTransaction': return this.getRawTransaction(ctx, request as $4.GetRawTransactionRequest);
      case 'DecodeRawTransaction': return this.decodeRawTransaction(ctx, request as $4.DecodeRawTransactionRequest);
      case 'GetBlock': return this.getBlock(ctx, request as $4.GetBlockRequest);
      case 'GetBlockHash': return this.getBlockHash(ctx, request as $4.GetBlockHashRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => BitcoinServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => BitcoinServiceBase$messageJson;
}

