//
//  Generated code. Do not modify.
//  source: faucet/v1/faucet.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import '../../bitcoin/bitcoind/v1alpha/bitcoin.pbjson.dart' as $3;
import '../../google/protobuf/timestamp.pbjson.dart' as $0;

@$core.Deprecated('Use dispenseCoinsRequestDescriptor instead')
const DispenseCoinsRequest$json = {
  '1': 'DispenseCoinsRequest',
  '2': [
    {'1': 'destination', '3': 1, '4': 1, '5': 9, '8': {}, '10': 'destination'},
    {'1': 'amount', '3': 2, '4': 1, '5': 1, '8': {}, '10': 'amount'},
  ],
};

/// Descriptor for `DispenseCoinsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dispenseCoinsRequestDescriptor = $convert.base64Decode(
    'ChREaXNwZW5zZUNvaW5zUmVxdWVzdBIoCgtkZXN0aW5hdGlvbhgBIAEoCUIGukgDyAEBUgtkZX'
    'N0aW5hdGlvbhIeCgZhbW91bnQYAiABKAFCBrpIA8gBAVIGYW1vdW50');

@$core.Deprecated('Use dispenseCoinsResponseDescriptor instead')
const DispenseCoinsResponse$json = {
  '1': 'DispenseCoinsResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `DispenseCoinsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dispenseCoinsResponseDescriptor = $convert.base64Decode(
    'ChVEaXNwZW5zZUNvaW5zUmVzcG9uc2USEgoEdHhpZBgBIAEoCVIEdHhpZA==');

@$core.Deprecated('Use listClaimsRequestDescriptor instead')
const ListClaimsRequest$json = {
  '1': 'ListClaimsRequest',
};

/// Descriptor for `ListClaimsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listClaimsRequestDescriptor = $convert.base64Decode(
    'ChFMaXN0Q2xhaW1zUmVxdWVzdA==');

@$core.Deprecated('Use listClaimsResponseDescriptor instead')
const ListClaimsResponse$json = {
  '1': 'ListClaimsResponse',
  '2': [
    {'1': 'transactions', '3': 1, '4': 3, '5': 11, '6': '.bitcoin.bitcoind.v1alpha.GetTransactionResponse', '10': 'transactions'},
  ],
};

/// Descriptor for `ListClaimsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listClaimsResponseDescriptor = $convert.base64Decode(
    'ChJMaXN0Q2xhaW1zUmVzcG9uc2USVAoMdHJhbnNhY3Rpb25zGAEgAygLMjAuYml0Y29pbi5iaX'
    'Rjb2luZC52MWFscGhhLkdldFRyYW5zYWN0aW9uUmVzcG9uc2VSDHRyYW5zYWN0aW9ucw==');

const $core.Map<$core.String, $core.dynamic> FaucetServiceBase$json = {
  '1': 'FaucetService',
  '2': [
    {'1': 'DispenseCoins', '2': '.faucet.v1.DispenseCoinsRequest', '3': '.faucet.v1.DispenseCoinsResponse', '4': {}},
    {'1': 'ListClaims', '2': '.faucet.v1.ListClaimsRequest', '3': '.faucet.v1.ListClaimsResponse', '4': {}},
  ],
};

@$core.Deprecated('Use faucetServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> FaucetServiceBase$messageJson = {
  '.faucet.v1.DispenseCoinsRequest': DispenseCoinsRequest$json,
  '.faucet.v1.DispenseCoinsResponse': DispenseCoinsResponse$json,
  '.faucet.v1.ListClaimsRequest': ListClaimsRequest$json,
  '.faucet.v1.ListClaimsResponse': ListClaimsResponse$json,
  '.bitcoin.bitcoind.v1alpha.GetTransactionResponse': $3.GetTransactionResponse$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.bitcoin.bitcoind.v1alpha.GetTransactionResponse.Details': $3.GetTransactionResponse_Details$json,
};

/// Descriptor for `FaucetService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List faucetServiceDescriptor = $convert.base64Decode(
    'Cg1GYXVjZXRTZXJ2aWNlElQKDURpc3BlbnNlQ29pbnMSHy5mYXVjZXQudjEuRGlzcGVuc2VDb2'
    'luc1JlcXVlc3QaIC5mYXVjZXQudjEuRGlzcGVuc2VDb2luc1Jlc3BvbnNlIgASSwoKTGlzdENs'
    'YWltcxIcLmZhdWNldC52MS5MaXN0Q2xhaW1zUmVxdWVzdBodLmZhdWNldC52MS5MaXN0Q2xhaW'
    '1zUmVzcG9uc2UiAA==');

