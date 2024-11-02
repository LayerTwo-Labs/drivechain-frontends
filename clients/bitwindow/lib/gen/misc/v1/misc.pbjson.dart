//
//  Generated code. Do not modify.
//  source: misc/v1/misc.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use listOPReturnResponseDescriptor instead')
const ListOPReturnResponse$json = {
  '1': 'ListOPReturnResponse',
  '2': [
    {'1': 'op_returns', '3': 1, '4': 3, '5': 11, '6': '.misc.v1.OPReturn', '10': 'opReturns'},
  ],
};

/// Descriptor for `ListOPReturnResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listOPReturnResponseDescriptor = $convert.base64Decode(
    'ChRMaXN0T1BSZXR1cm5SZXNwb25zZRIwCgpvcF9yZXR1cm5zGAEgAygLMhEubWlzYy52MS5PUF'
    'JldHVyblIJb3BSZXR1cm5z');

@$core.Deprecated('Use oPReturnDescriptor instead')
const OPReturn$json = {
  '1': 'OPReturn',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
    {'1': 'txid', '3': 3, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'vout', '3': 4, '4': 1, '5': 5, '10': 'vout'},
    {'1': 'height', '3': 5, '4': 1, '5': 5, '9': 0, '10': 'height', '17': true},
    {'1': 'fee_satoshi', '3': 6, '4': 1, '5': 3, '10': 'feeSatoshi'},
    {'1': 'create_time', '3': 7, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createTime'},
  ],
  '8': [
    {'1': '_height'},
  ],
};

/// Descriptor for `OPReturn`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List oPReturnDescriptor = $convert.base64Decode(
    'CghPUFJldHVybhIOCgJpZBgBIAEoCVICaWQSGAoHbWVzc2FnZRgCIAEoCVIHbWVzc2FnZRISCg'
    'R0eGlkGAMgASgJUgR0eGlkEhIKBHZvdXQYBCABKAVSBHZvdXQSGwoGaGVpZ2h0GAUgASgFSABS'
    'BmhlaWdodIgBARIfCgtmZWVfc2F0b3NoaRgGIAEoA1IKZmVlU2F0b3NoaRI7CgtjcmVhdGVfdG'
    'ltZRgHIAEoCzIaLmdvb2dsZS5wcm90b2J1Zi5UaW1lc3RhbXBSCmNyZWF0ZVRpbWVCCQoHX2hl'
    'aWdodA==');

