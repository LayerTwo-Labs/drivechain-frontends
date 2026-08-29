//
//  Generated code. Do not modify.
//  source: bbc/v1/bbc.proto
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

import 'bbc.pb.dart' as $0;
import 'bbc.pbjson.dart';

export 'bbc.pb.dart';

abstract class BbcServiceBase extends $pb.GeneratedService {
  $async.Future<$0.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $0.GetBlockCountRequest request);
  $async.Future<$0.GetBlockchainInfoResponse> getBlockchainInfo($pb.ServerContext ctx, $0.GetBlockchainInfoRequest request);
  $async.Future<$0.GetSidechainInfoResponse> getSidechainInfo($pb.ServerContext ctx, $0.GetSidechainInfoRequest request);
  $async.Future<$0.GetMainchainTipResponse> getMainchainTip($pb.ServerContext ctx, $0.GetMainchainTipRequest request);
  $async.Future<$0.GetBmmCommitmentResponse> getBmmCommitment($pb.ServerContext ctx, $0.GetBmmCommitmentRequest request);
  $async.Future<$0.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $0.GetNewAddressRequest request);
  $async.Future<$0.SendResponse> send($pb.ServerContext ctx, $0.SendRequest request);
  $async.Future<$0.EstimateFeeResponse> estimateFee($pb.ServerContext ctx, $0.EstimateFeeRequest request);
  $async.Future<$0.ListUtxosResponse> listUtxos($pb.ServerContext ctx, $0.ListUtxosRequest request);
  $async.Future<$0.ListTransactionsResponse> listTransactions($pb.ServerContext ctx, $0.ListTransactionsRequest request);
  $async.Future<$0.StopResponse> stop($pb.ServerContext ctx, $0.StopRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBlockCount': return $0.GetBlockCountRequest();
      case 'GetBlockchainInfo': return $0.GetBlockchainInfoRequest();
      case 'GetSidechainInfo': return $0.GetSidechainInfoRequest();
      case 'GetMainchainTip': return $0.GetMainchainTipRequest();
      case 'GetBmmCommitment': return $0.GetBmmCommitmentRequest();
      case 'GetNewAddress': return $0.GetNewAddressRequest();
      case 'Send': return $0.SendRequest();
      case 'EstimateFee': return $0.EstimateFeeRequest();
      case 'ListUtxos': return $0.ListUtxosRequest();
      case 'ListTransactions': return $0.ListTransactionsRequest();
      case 'Stop': return $0.StopRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBlockCount': return this.getBlockCount(ctx, request as $0.GetBlockCountRequest);
      case 'GetBlockchainInfo': return this.getBlockchainInfo(ctx, request as $0.GetBlockchainInfoRequest);
      case 'GetSidechainInfo': return this.getSidechainInfo(ctx, request as $0.GetSidechainInfoRequest);
      case 'GetMainchainTip': return this.getMainchainTip(ctx, request as $0.GetMainchainTipRequest);
      case 'GetBmmCommitment': return this.getBmmCommitment(ctx, request as $0.GetBmmCommitmentRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $0.GetNewAddressRequest);
      case 'Send': return this.send(ctx, request as $0.SendRequest);
      case 'EstimateFee': return this.estimateFee(ctx, request as $0.EstimateFeeRequest);
      case 'ListUtxos': return this.listUtxos(ctx, request as $0.ListUtxosRequest);
      case 'ListTransactions': return this.listTransactions(ctx, request as $0.ListTransactionsRequest);
      case 'Stop': return this.stop(ctx, request as $0.StopRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => BbcServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => BbcServiceBase$messageJson;
}

