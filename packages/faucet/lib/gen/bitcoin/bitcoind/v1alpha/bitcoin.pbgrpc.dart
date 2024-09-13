//
//  Generated code. Do not modify.
//  source: bitcoin/bitcoind/v1alpha/bitcoin.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'bitcoin.pb.dart' as $0;

export 'bitcoin.pb.dart';

@$pb.GrpcServiceName('bitcoin.bitcoind.v1alpha.BitcoinService')
class BitcoinServiceClient extends $grpc.Client {
  static final _$getBlockchainInfo = $grpc.ClientMethod<$0.GetBlockchainInfoRequest, $0.GetBlockchainInfoResponse>(
      '/bitcoin.bitcoind.v1alpha.BitcoinService/GetBlockchainInfo',
      ($0.GetBlockchainInfoRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetBlockchainInfoResponse.fromBuffer(value));
  static final _$getTransaction = $grpc.ClientMethod<$0.GetTransactionRequest, $0.GetTransactionResponse>(
      '/bitcoin.bitcoind.v1alpha.BitcoinService/GetTransaction',
      ($0.GetTransactionRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetTransactionResponse.fromBuffer(value));
  static final _$listSinceBlock = $grpc.ClientMethod<$0.ListSinceBlockRequest, $0.ListSinceBlockResponse>(
      '/bitcoin.bitcoind.v1alpha.BitcoinService/ListSinceBlock',
      ($0.ListSinceBlockRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ListSinceBlockResponse.fromBuffer(value));
  static final _$getNewAddress = $grpc.ClientMethod<$0.GetNewAddressRequest, $0.GetNewAddressResponse>(
      '/bitcoin.bitcoind.v1alpha.BitcoinService/GetNewAddress',
      ($0.GetNewAddressRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetNewAddressResponse.fromBuffer(value));
  static final _$getWalletInfo = $grpc.ClientMethod<$0.GetWalletInfoRequest, $0.GetWalletInfoResponse>(
      '/bitcoin.bitcoind.v1alpha.BitcoinService/GetWalletInfo',
      ($0.GetWalletInfoRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetWalletInfoResponse.fromBuffer(value));
  static final _$getBalances = $grpc.ClientMethod<$0.GetBalancesRequest, $0.GetBalancesResponse>(
      '/bitcoin.bitcoind.v1alpha.BitcoinService/GetBalances',
      ($0.GetBalancesRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetBalancesResponse.fromBuffer(value));
  static final _$send = $grpc.ClientMethod<$0.SendRequest, $0.SendResponse>(
      '/bitcoin.bitcoind.v1alpha.BitcoinService/Send',
      ($0.SendRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.SendResponse.fromBuffer(value));
  static final _$sendToAddress = $grpc.ClientMethod<$0.SendToAddressRequest, $0.SendToAddressResponse>(
      '/bitcoin.bitcoind.v1alpha.BitcoinService/SendToAddress',
      ($0.SendToAddressRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.SendToAddressResponse.fromBuffer(value));
  static final _$bumpFee = $grpc.ClientMethod<$0.BumpFeeRequest, $0.BumpFeeResponse>(
      '/bitcoin.bitcoind.v1alpha.BitcoinService/BumpFee',
      ($0.BumpFeeRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.BumpFeeResponse.fromBuffer(value));
  static final _$estimateSmartFee = $grpc.ClientMethod<$0.EstimateSmartFeeRequest, $0.EstimateSmartFeeResponse>(
      '/bitcoin.bitcoind.v1alpha.BitcoinService/EstimateSmartFee',
      ($0.EstimateSmartFeeRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.EstimateSmartFeeResponse.fromBuffer(value));
  static final _$importDescriptors = $grpc.ClientMethod<$0.ImportDescriptorsRequest, $0.ImportDescriptorsResponse>(
      '/bitcoin.bitcoind.v1alpha.BitcoinService/ImportDescriptors',
      ($0.ImportDescriptorsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ImportDescriptorsResponse.fromBuffer(value));
  static final _$listTransactions = $grpc.ClientMethod<$0.ListTransactionsRequest, $0.ListTransactionsResponse>(
      '/bitcoin.bitcoind.v1alpha.BitcoinService/ListTransactions',
      ($0.ListTransactionsRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.ListTransactionsResponse.fromBuffer(value));
  static final _$getDescriptorInfo = $grpc.ClientMethod<$0.GetDescriptorInfoRequest, $0.GetDescriptorInfoResponse>(
      '/bitcoin.bitcoind.v1alpha.BitcoinService/GetDescriptorInfo',
      ($0.GetDescriptorInfoRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetDescriptorInfoResponse.fromBuffer(value));
  static final _$getRawMempool = $grpc.ClientMethod<$0.GetRawMempoolRequest, $0.GetRawMempoolResponse>(
      '/bitcoin.bitcoind.v1alpha.BitcoinService/GetRawMempool',
      ($0.GetRawMempoolRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetRawMempoolResponse.fromBuffer(value));
  static final _$getRawTransaction = $grpc.ClientMethod<$0.GetRawTransactionRequest, $0.GetRawTransactionResponse>(
      '/bitcoin.bitcoind.v1alpha.BitcoinService/GetRawTransaction',
      ($0.GetRawTransactionRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetRawTransactionResponse.fromBuffer(value));
  static final _$decodeRawTransaction = $grpc.ClientMethod<$0.DecodeRawTransactionRequest, $0.DecodeRawTransactionResponse>(
      '/bitcoin.bitcoind.v1alpha.BitcoinService/DecodeRawTransaction',
      ($0.DecodeRawTransactionRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.DecodeRawTransactionResponse.fromBuffer(value));
  static final _$getBlock = $grpc.ClientMethod<$0.GetBlockRequest, $0.GetBlockResponse>(
      '/bitcoin.bitcoind.v1alpha.BitcoinService/GetBlock',
      ($0.GetBlockRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetBlockResponse.fromBuffer(value));
  static final _$getBlockHash = $grpc.ClientMethod<$0.GetBlockHashRequest, $0.GetBlockHashResponse>(
      '/bitcoin.bitcoind.v1alpha.BitcoinService/GetBlockHash',
      ($0.GetBlockHashRequest value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.GetBlockHashResponse.fromBuffer(value));

  BitcoinServiceClient($grpc.ClientChannel channel,
      {$grpc.CallOptions? options,
      $core.Iterable<$grpc.ClientInterceptor>? interceptors})
      : super(channel, options: options,
        interceptors: interceptors);

  $grpc.ResponseFuture<$0.GetBlockchainInfoResponse> getBlockchainInfo($0.GetBlockchainInfoRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getBlockchainInfo, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetTransactionResponse> getTransaction($0.GetTransactionRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getTransaction, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListSinceBlockResponse> listSinceBlock($0.ListSinceBlockRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listSinceBlock, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetNewAddressResponse> getNewAddress($0.GetNewAddressRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getNewAddress, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetWalletInfoResponse> getWalletInfo($0.GetWalletInfoRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getWalletInfo, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetBalancesResponse> getBalances($0.GetBalancesRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getBalances, request, options: options);
  }

  $grpc.ResponseFuture<$0.SendResponse> send($0.SendRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$send, request, options: options);
  }

  $grpc.ResponseFuture<$0.SendToAddressResponse> sendToAddress($0.SendToAddressRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$sendToAddress, request, options: options);
  }

  $grpc.ResponseFuture<$0.BumpFeeResponse> bumpFee($0.BumpFeeRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$bumpFee, request, options: options);
  }

  $grpc.ResponseFuture<$0.EstimateSmartFeeResponse> estimateSmartFee($0.EstimateSmartFeeRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$estimateSmartFee, request, options: options);
  }

  $grpc.ResponseFuture<$0.ImportDescriptorsResponse> importDescriptors($0.ImportDescriptorsRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$importDescriptors, request, options: options);
  }

  $grpc.ResponseFuture<$0.ListTransactionsResponse> listTransactions($0.ListTransactionsRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$listTransactions, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetDescriptorInfoResponse> getDescriptorInfo($0.GetDescriptorInfoRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getDescriptorInfo, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetRawMempoolResponse> getRawMempool($0.GetRawMempoolRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getRawMempool, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetRawTransactionResponse> getRawTransaction($0.GetRawTransactionRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getRawTransaction, request, options: options);
  }

  $grpc.ResponseFuture<$0.DecodeRawTransactionResponse> decodeRawTransaction($0.DecodeRawTransactionRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$decodeRawTransaction, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetBlockResponse> getBlock($0.GetBlockRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getBlock, request, options: options);
  }

  $grpc.ResponseFuture<$0.GetBlockHashResponse> getBlockHash($0.GetBlockHashRequest request, {$grpc.CallOptions? options}) {
    return $createUnaryCall(_$getBlockHash, request, options: options);
  }
}

@$pb.GrpcServiceName('bitcoin.bitcoind.v1alpha.BitcoinService')
abstract class BitcoinServiceBase extends $grpc.Service {
  $core.String get $name => 'bitcoin.bitcoind.v1alpha.BitcoinService';

  BitcoinServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.GetBlockchainInfoRequest, $0.GetBlockchainInfoResponse>(
        'GetBlockchainInfo',
        getBlockchainInfo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetBlockchainInfoRequest.fromBuffer(value),
        ($0.GetBlockchainInfoResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetTransactionRequest, $0.GetTransactionResponse>(
        'GetTransaction',
        getTransaction_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetTransactionRequest.fromBuffer(value),
        ($0.GetTransactionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListSinceBlockRequest, $0.ListSinceBlockResponse>(
        'ListSinceBlock',
        listSinceBlock_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListSinceBlockRequest.fromBuffer(value),
        ($0.ListSinceBlockResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetNewAddressRequest, $0.GetNewAddressResponse>(
        'GetNewAddress',
        getNewAddress_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetNewAddressRequest.fromBuffer(value),
        ($0.GetNewAddressResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetWalletInfoRequest, $0.GetWalletInfoResponse>(
        'GetWalletInfo',
        getWalletInfo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetWalletInfoRequest.fromBuffer(value),
        ($0.GetWalletInfoResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetBalancesRequest, $0.GetBalancesResponse>(
        'GetBalances',
        getBalances_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetBalancesRequest.fromBuffer(value),
        ($0.GetBalancesResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SendRequest, $0.SendResponse>(
        'Send',
        send_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SendRequest.fromBuffer(value),
        ($0.SendResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.SendToAddressRequest, $0.SendToAddressResponse>(
        'SendToAddress',
        sendToAddress_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.SendToAddressRequest.fromBuffer(value),
        ($0.SendToAddressResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.BumpFeeRequest, $0.BumpFeeResponse>(
        'BumpFee',
        bumpFee_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.BumpFeeRequest.fromBuffer(value),
        ($0.BumpFeeResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.EstimateSmartFeeRequest, $0.EstimateSmartFeeResponse>(
        'EstimateSmartFee',
        estimateSmartFee_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.EstimateSmartFeeRequest.fromBuffer(value),
        ($0.EstimateSmartFeeResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ImportDescriptorsRequest, $0.ImportDescriptorsResponse>(
        'ImportDescriptors',
        importDescriptors_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ImportDescriptorsRequest.fromBuffer(value),
        ($0.ImportDescriptorsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.ListTransactionsRequest, $0.ListTransactionsResponse>(
        'ListTransactions',
        listTransactions_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.ListTransactionsRequest.fromBuffer(value),
        ($0.ListTransactionsResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetDescriptorInfoRequest, $0.GetDescriptorInfoResponse>(
        'GetDescriptorInfo',
        getDescriptorInfo_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetDescriptorInfoRequest.fromBuffer(value),
        ($0.GetDescriptorInfoResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetRawMempoolRequest, $0.GetRawMempoolResponse>(
        'GetRawMempool',
        getRawMempool_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetRawMempoolRequest.fromBuffer(value),
        ($0.GetRawMempoolResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetRawTransactionRequest, $0.GetRawTransactionResponse>(
        'GetRawTransaction',
        getRawTransaction_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetRawTransactionRequest.fromBuffer(value),
        ($0.GetRawTransactionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.DecodeRawTransactionRequest, $0.DecodeRawTransactionResponse>(
        'DecodeRawTransaction',
        decodeRawTransaction_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.DecodeRawTransactionRequest.fromBuffer(value),
        ($0.DecodeRawTransactionResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetBlockRequest, $0.GetBlockResponse>(
        'GetBlock',
        getBlock_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetBlockRequest.fromBuffer(value),
        ($0.GetBlockResponse value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.GetBlockHashRequest, $0.GetBlockHashResponse>(
        'GetBlockHash',
        getBlockHash_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.GetBlockHashRequest.fromBuffer(value),
        ($0.GetBlockHashResponse value) => value.writeToBuffer()));
  }

  $async.Future<$0.GetBlockchainInfoResponse> getBlockchainInfo_Pre($grpc.ServiceCall call, $async.Future<$0.GetBlockchainInfoRequest> request) async {
    return getBlockchainInfo(call, await request);
  }

  $async.Future<$0.GetTransactionResponse> getTransaction_Pre($grpc.ServiceCall call, $async.Future<$0.GetTransactionRequest> request) async {
    return getTransaction(call, await request);
  }

  $async.Future<$0.ListSinceBlockResponse> listSinceBlock_Pre($grpc.ServiceCall call, $async.Future<$0.ListSinceBlockRequest> request) async {
    return listSinceBlock(call, await request);
  }

  $async.Future<$0.GetNewAddressResponse> getNewAddress_Pre($grpc.ServiceCall call, $async.Future<$0.GetNewAddressRequest> request) async {
    return getNewAddress(call, await request);
  }

  $async.Future<$0.GetWalletInfoResponse> getWalletInfo_Pre($grpc.ServiceCall call, $async.Future<$0.GetWalletInfoRequest> request) async {
    return getWalletInfo(call, await request);
  }

  $async.Future<$0.GetBalancesResponse> getBalances_Pre($grpc.ServiceCall call, $async.Future<$0.GetBalancesRequest> request) async {
    return getBalances(call, await request);
  }

  $async.Future<$0.SendResponse> send_Pre($grpc.ServiceCall call, $async.Future<$0.SendRequest> request) async {
    return send(call, await request);
  }

  $async.Future<$0.SendToAddressResponse> sendToAddress_Pre($grpc.ServiceCall call, $async.Future<$0.SendToAddressRequest> request) async {
    return sendToAddress(call, await request);
  }

  $async.Future<$0.BumpFeeResponse> bumpFee_Pre($grpc.ServiceCall call, $async.Future<$0.BumpFeeRequest> request) async {
    return bumpFee(call, await request);
  }

  $async.Future<$0.EstimateSmartFeeResponse> estimateSmartFee_Pre($grpc.ServiceCall call, $async.Future<$0.EstimateSmartFeeRequest> request) async {
    return estimateSmartFee(call, await request);
  }

  $async.Future<$0.ImportDescriptorsResponse> importDescriptors_Pre($grpc.ServiceCall call, $async.Future<$0.ImportDescriptorsRequest> request) async {
    return importDescriptors(call, await request);
  }

  $async.Future<$0.ListTransactionsResponse> listTransactions_Pre($grpc.ServiceCall call, $async.Future<$0.ListTransactionsRequest> request) async {
    return listTransactions(call, await request);
  }

  $async.Future<$0.GetDescriptorInfoResponse> getDescriptorInfo_Pre($grpc.ServiceCall call, $async.Future<$0.GetDescriptorInfoRequest> request) async {
    return getDescriptorInfo(call, await request);
  }

  $async.Future<$0.GetRawMempoolResponse> getRawMempool_Pre($grpc.ServiceCall call, $async.Future<$0.GetRawMempoolRequest> request) async {
    return getRawMempool(call, await request);
  }

  $async.Future<$0.GetRawTransactionResponse> getRawTransaction_Pre($grpc.ServiceCall call, $async.Future<$0.GetRawTransactionRequest> request) async {
    return getRawTransaction(call, await request);
  }

  $async.Future<$0.DecodeRawTransactionResponse> decodeRawTransaction_Pre($grpc.ServiceCall call, $async.Future<$0.DecodeRawTransactionRequest> request) async {
    return decodeRawTransaction(call, await request);
  }

  $async.Future<$0.GetBlockResponse> getBlock_Pre($grpc.ServiceCall call, $async.Future<$0.GetBlockRequest> request) async {
    return getBlock(call, await request);
  }

  $async.Future<$0.GetBlockHashResponse> getBlockHash_Pre($grpc.ServiceCall call, $async.Future<$0.GetBlockHashRequest> request) async {
    return getBlockHash(call, await request);
  }

  $async.Future<$0.GetBlockchainInfoResponse> getBlockchainInfo($grpc.ServiceCall call, $0.GetBlockchainInfoRequest request);
  $async.Future<$0.GetTransactionResponse> getTransaction($grpc.ServiceCall call, $0.GetTransactionRequest request);
  $async.Future<$0.ListSinceBlockResponse> listSinceBlock($grpc.ServiceCall call, $0.ListSinceBlockRequest request);
  $async.Future<$0.GetNewAddressResponse> getNewAddress($grpc.ServiceCall call, $0.GetNewAddressRequest request);
  $async.Future<$0.GetWalletInfoResponse> getWalletInfo($grpc.ServiceCall call, $0.GetWalletInfoRequest request);
  $async.Future<$0.GetBalancesResponse> getBalances($grpc.ServiceCall call, $0.GetBalancesRequest request);
  $async.Future<$0.SendResponse> send($grpc.ServiceCall call, $0.SendRequest request);
  $async.Future<$0.SendToAddressResponse> sendToAddress($grpc.ServiceCall call, $0.SendToAddressRequest request);
  $async.Future<$0.BumpFeeResponse> bumpFee($grpc.ServiceCall call, $0.BumpFeeRequest request);
  $async.Future<$0.EstimateSmartFeeResponse> estimateSmartFee($grpc.ServiceCall call, $0.EstimateSmartFeeRequest request);
  $async.Future<$0.ImportDescriptorsResponse> importDescriptors($grpc.ServiceCall call, $0.ImportDescriptorsRequest request);
  $async.Future<$0.ListTransactionsResponse> listTransactions($grpc.ServiceCall call, $0.ListTransactionsRequest request);
  $async.Future<$0.GetDescriptorInfoResponse> getDescriptorInfo($grpc.ServiceCall call, $0.GetDescriptorInfoRequest request);
  $async.Future<$0.GetRawMempoolResponse> getRawMempool($grpc.ServiceCall call, $0.GetRawMempoolRequest request);
  $async.Future<$0.GetRawTransactionResponse> getRawTransaction($grpc.ServiceCall call, $0.GetRawTransactionRequest request);
  $async.Future<$0.DecodeRawTransactionResponse> decodeRawTransaction($grpc.ServiceCall call, $0.DecodeRawTransactionRequest request);
  $async.Future<$0.GetBlockResponse> getBlock($grpc.ServiceCall call, $0.GetBlockRequest request);
  $async.Future<$0.GetBlockHashResponse> getBlockHash($grpc.ServiceCall call, $0.GetBlockHashRequest request);
}
