//
//  Generated code. Do not modify.
//  source: fast_withdrawal/v1/fast_withdrawal.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import '../../google/protobuf/timestamp.pbjson.dart' as $0;

@$core.Deprecated('Use initiateFastWithdrawalRequestDescriptor instead')
const InitiateFastWithdrawalRequest$json = {
  '1': 'InitiateFastWithdrawalRequest',
  '2': [
    {'1': 'sidechain', '3': 1, '4': 1, '5': 9, '10': 'sidechain'},
    {'1': 'amount', '3': 2, '4': 1, '5': 3, '10': 'amount'},
    {'1': 'destination', '3': 3, '4': 1, '5': 9, '10': 'destination'},
  ],
};

/// Descriptor for `InitiateFastWithdrawalRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List initiateFastWithdrawalRequestDescriptor =
    $convert.base64Decode('Ch1Jbml0aWF0ZUZhc3RXaXRoZHJhd2FsUmVxdWVzdBIcCglzaWRlY2hhaW4YASABKAlSCXNpZG'
        'VjaGFpbhIWCgZhbW91bnQYAiABKANSBmFtb3VudBIgCgtkZXN0aW5hdGlvbhgDIAEoCVILZGVz'
        'dGluYXRpb24=');

@$core.Deprecated('Use fastWithdrawalUpdateDescriptor instead')
const FastWithdrawalUpdate$json = {
  '1': 'FastWithdrawalUpdate',
  '2': [
    {'1': 'status', '3': 1, '4': 1, '5': 14, '6': '.fast_withdrawal.v1.FastWithdrawalUpdate.Status', '10': 'status'},
    {'1': 'txid', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'txid', '17': true},
    {'1': 'error', '3': 3, '4': 1, '5': 9, '9': 1, '10': 'error', '17': true},
    {'1': 'block_hash', '3': 4, '4': 1, '5': 9, '9': 2, '10': 'blockHash', '17': true},
    {'1': 'timestamp', '3': 5, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'timestamp'},
    {'1': 'message', '3': 6, '4': 1, '5': 9, '10': 'message'},
  ],
  '4': [FastWithdrawalUpdate_Status$json],
  '8': [
    {'1': '_txid'},
    {'1': '_error'},
    {'1': '_block_hash'},
  ],
};

@$core.Deprecated('Use fastWithdrawalUpdateDescriptor instead')
const FastWithdrawalUpdate_Status$json = {
  '1': 'Status',
  '2': [
    {'1': 'STATUS_UNSPECIFIED', '2': 0},
    {'1': 'STATUS_INITIATING', '2': 1},
    {'1': 'STATUS_PENDING', '2': 2},
    {'1': 'STATUS_DETECTED', '2': 3},
    {'1': 'STATUS_CONFIRMED', '2': 4},
    {'1': 'STATUS_FAILED', '2': 5},
    {'1': 'STATUS_COMPLETED', '2': 6},
  ],
};

/// Descriptor for `FastWithdrawalUpdate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List fastWithdrawalUpdateDescriptor =
    $convert.base64Decode('ChRGYXN0V2l0aGRyYXdhbFVwZGF0ZRJHCgZzdGF0dXMYASABKA4yLy5mYXN0X3dpdGhkcmF3YW'
        'wudjEuRmFzdFdpdGhkcmF3YWxVcGRhdGUuU3RhdHVzUgZzdGF0dXMSFwoEdHhpZBgCIAEoCUgA'
        'UgR0eGlkiAEBEhkKBWVycm9yGAMgASgJSAFSBWVycm9yiAEBEiIKCmJsb2NrX2hhc2gYBCABKA'
        'lIAlIJYmxvY2tIYXNoiAEBEjgKCXRpbWVzdGFtcBgFIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5U'
        'aW1lc3RhbXBSCXRpbWVzdGFtcBIYCgdtZXNzYWdlGAYgASgJUgdtZXNzYWdlIp8BCgZTdGF0dX'
        'MSFgoSU1RBVFVTX1VOU1BFQ0lGSUVEEAASFQoRU1RBVFVTX0lOSVRJQVRJTkcQARISCg5TVEFU'
        'VVNfUEVORElORxACEhMKD1NUQVRVU19ERVRFQ1RFRBADEhQKEFNUQVRVU19DT05GSVJNRUQQBB'
        'IRCg1TVEFUVVNfRkFJTEVEEAUSFAoQU1RBVFVTX0NPTVBMRVRFRBAGQgcKBV90eGlkQggKBl9l'
        'cnJvckINCgtfYmxvY2tfaGFzaA==');

const $core.Map<$core.String, $core.dynamic> FastWithdrawalServiceBase$json = {
  '1': 'FastWithdrawalService',
  '2': [
    {
      '1': 'InitiateFastWithdrawal',
      '2': '.fast_withdrawal.v1.InitiateFastWithdrawalRequest',
      '3': '.fast_withdrawal.v1.FastWithdrawalUpdate',
      '6': true
    },
  ],
};

@$core.Deprecated('Use fastWithdrawalServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> FastWithdrawalServiceBase$messageJson = {
  '.fast_withdrawal.v1.InitiateFastWithdrawalRequest': InitiateFastWithdrawalRequest$json,
  '.fast_withdrawal.v1.FastWithdrawalUpdate': FastWithdrawalUpdate$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
};

/// Descriptor for `FastWithdrawalService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List fastWithdrawalServiceDescriptor =
    $convert.base64Decode('ChVGYXN0V2l0aGRyYXdhbFNlcnZpY2USdwoWSW5pdGlhdGVGYXN0V2l0aGRyYXdhbBIxLmZhc3'
        'Rfd2l0aGRyYXdhbC52MS5Jbml0aWF0ZUZhc3RXaXRoZHJhd2FsUmVxdWVzdBooLmZhc3Rfd2l0'
        'aGRyYXdhbC52MS5GYXN0V2l0aGRyYXdhbFVwZGF0ZTAB');
