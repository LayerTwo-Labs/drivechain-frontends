//
//  Generated code. Do not modify.
//  source: bitcoin/drivechaind/v1/drivechain.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use createSidechainDepositRequestDescriptor instead')
const CreateSidechainDepositRequest$json = {
  '1': 'CreateSidechainDepositRequest',
  '2': [
    {'1': 'destination', '3': 1, '4': 1, '5': 9, '10': 'destination'},
    {'1': 'amount', '3': 2, '4': 1, '5': 1, '10': 'amount'},
    {'1': 'fee', '3': 3, '4': 1, '5': 1, '10': 'fee'},
  ],
};

/// Descriptor for `CreateSidechainDepositRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createSidechainDepositRequestDescriptor = $convert.base64Decode(
    'Ch1DcmVhdGVTaWRlY2hhaW5EZXBvc2l0UmVxdWVzdBIgCgtkZXN0aW5hdGlvbhgBIAEoCVILZG'
    'VzdGluYXRpb24SFgoGYW1vdW50GAIgASgBUgZhbW91bnQSEAoDZmVlGAMgASgBUgNmZWU=');

@$core.Deprecated('Use createSidechainDepositResponseDescriptor instead')
const CreateSidechainDepositResponse$json = {
  '1': 'CreateSidechainDepositResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'errors', '3': 2, '4': 3, '5': 9, '10': 'errors'},
  ],
};

/// Descriptor for `CreateSidechainDepositResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List createSidechainDepositResponseDescriptor = $convert.base64Decode(
    'Ch5DcmVhdGVTaWRlY2hhaW5EZXBvc2l0UmVzcG9uc2USEgoEdHhpZBgBIAEoCVIEdHhpZBIWCg'
    'ZlcnJvcnMYAiADKAlSBmVycm9ycw==');

const $core.Map<$core.String, $core.dynamic> DrivechainServiceBase$json = {
  '1': 'DrivechainService',
  '2': [
    {'1': 'CreateSidechainDeposit', '2': '.bitcoin.drivechaind.v1.CreateSidechainDepositRequest', '3': '.bitcoin.drivechaind.v1.CreateSidechainDepositResponse'},
  ],
};

@$core.Deprecated('Use drivechainServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> DrivechainServiceBase$messageJson = {
  '.bitcoin.drivechaind.v1.CreateSidechainDepositRequest': CreateSidechainDepositRequest$json,
  '.bitcoin.drivechaind.v1.CreateSidechainDepositResponse': CreateSidechainDepositResponse$json,
};

/// Descriptor for `DrivechainService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List drivechainServiceDescriptor = $convert.base64Decode(
    'ChFEcml2ZWNoYWluU2VydmljZRKHAQoWQ3JlYXRlU2lkZWNoYWluRGVwb3NpdBI1LmJpdGNvaW'
    '4uZHJpdmVjaGFpbmQudjEuQ3JlYXRlU2lkZWNoYWluRGVwb3NpdFJlcXVlc3QaNi5iaXRjb2lu'
    'LmRyaXZlY2hhaW5kLnYxLkNyZWF0ZVNpZGVjaGFpbkRlcG9zaXRSZXNwb25zZQ==');

