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

@$core.Deprecated('Use dispenseCoinsRequestDescriptor instead')
const DispenseCoinsRequest$json = {
  '1': 'DispenseCoinsRequest',
  '2': [
    {'1': 'destination', '3': 1, '4': 1, '5': 9, '10': 'destination'},
    {'1': 'amount', '3': 2, '4': 1, '5': 1, '10': 'amount'},
  ],
};

/// Descriptor for `DispenseCoinsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dispenseCoinsRequestDescriptor = $convert.base64Decode(
    'ChREaXNwZW5zZUNvaW5zUmVxdWVzdBIgCgtkZXN0aW5hdGlvbhgBIAEoCVILZGVzdGluYXRpb2'
    '4SFgoGYW1vdW50GAIgASgBUgZhbW91bnQ=');

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

