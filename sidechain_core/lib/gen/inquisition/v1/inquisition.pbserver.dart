//
//  Generated code. Do not modify.
//  source: inquisition/v1/inquisition.proto
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

import 'inquisition.pb.dart' as $5;
import 'inquisition.pbjson.dart';

export 'inquisition.pb.dart';

abstract class InquisitionServiceBase extends $pb.GeneratedService {
  $async.Future<$5.GetBlockCountResponse> getBlockCount($pb.ServerContext ctx, $5.GetBlockCountRequest request);
  $async.Future<$5.GetBlockchainInfoResponse> getBlockchainInfo($pb.ServerContext ctx, $5.GetBlockchainInfoRequest request);
  $async.Future<$5.GetSidechainInfoResponse> getSidechainInfo($pb.ServerContext ctx, $5.GetSidechainInfoRequest request);
  $async.Future<$5.GetMainchainTipResponse> getMainchainTip($pb.ServerContext ctx, $5.GetMainchainTipRequest request);
  $async.Future<$5.GetBmmCommitmentResponse> getBmmCommitment($pb.ServerContext ctx, $5.GetBmmCommitmentRequest request);
  $async.Future<$5.GetNewAddressResponse> getNewAddress($pb.ServerContext ctx, $5.GetNewAddressRequest request);
  $async.Future<$5.SendResponse> send($pb.ServerContext ctx, $5.SendRequest request);
  $async.Future<$5.EstimateFeeResponse> estimateFee($pb.ServerContext ctx, $5.EstimateFeeRequest request);
  $async.Future<$5.ListUtxosResponse> listUtxos($pb.ServerContext ctx, $5.ListUtxosRequest request);
  $async.Future<$5.ListTransactionsResponse> listTransactions($pb.ServerContext ctx, $5.ListTransactionsRequest request);
  $async.Future<$5.StopResponse> stop($pb.ServerContext ctx, $5.StopRequest request);

  $pb.GeneratedMessage createRequest($core.String methodName) {
    switch (methodName) {
      case 'GetBlockCount': return $5.GetBlockCountRequest();
      case 'GetBlockchainInfo': return $5.GetBlockchainInfoRequest();
      case 'GetSidechainInfo': return $5.GetSidechainInfoRequest();
      case 'GetMainchainTip': return $5.GetMainchainTipRequest();
      case 'GetBmmCommitment': return $5.GetBmmCommitmentRequest();
      case 'GetNewAddress': return $5.GetNewAddressRequest();
      case 'Send': return $5.SendRequest();
      case 'EstimateFee': return $5.EstimateFeeRequest();
      case 'ListUtxos': return $5.ListUtxosRequest();
      case 'ListTransactions': return $5.ListTransactionsRequest();
      case 'Stop': return $5.StopRequest();
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $async.Future<$pb.GeneratedMessage> handleCall($pb.ServerContext ctx, $core.String methodName, $pb.GeneratedMessage request) {
    switch (methodName) {
      case 'GetBlockCount': return this.getBlockCount(ctx, request as $5.GetBlockCountRequest);
      case 'GetBlockchainInfo': return this.getBlockchainInfo(ctx, request as $5.GetBlockchainInfoRequest);
      case 'GetSidechainInfo': return this.getSidechainInfo(ctx, request as $5.GetSidechainInfoRequest);
      case 'GetMainchainTip': return this.getMainchainTip(ctx, request as $5.GetMainchainTipRequest);
      case 'GetBmmCommitment': return this.getBmmCommitment(ctx, request as $5.GetBmmCommitmentRequest);
      case 'GetNewAddress': return this.getNewAddress(ctx, request as $5.GetNewAddressRequest);
      case 'Send': return this.send(ctx, request as $5.SendRequest);
      case 'EstimateFee': return this.estimateFee(ctx, request as $5.EstimateFeeRequest);
      case 'ListUtxos': return this.listUtxos(ctx, request as $5.ListUtxosRequest);
      case 'ListTransactions': return this.listTransactions(ctx, request as $5.ListTransactionsRequest);
      case 'Stop': return this.stop(ctx, request as $5.StopRequest);
      default: throw $core.ArgumentError('Unknown method: $methodName');
    }
  }

  $core.Map<$core.String, $core.dynamic> get $json => InquisitionServiceBase$json;
  $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> get $messageJson => InquisitionServiceBase$messageJson;
}

