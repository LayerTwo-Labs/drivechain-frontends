//
//  Generated code. Do not modify.
//  source: health/v1/health.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

import '../../google/protobuf/empty.pbjson.dart' as $1;

@$core.Deprecated('Use checkResponseDescriptor instead')
const CheckResponse$json = {
  '1': 'CheckResponse',
  '2': [
    {'1': 'service_statuses', '3': 1, '4': 3, '5': 11, '6': '.health.v1.CheckResponse.ServiceStatus', '10': 'serviceStatuses'},
  ],
  '3': [CheckResponse_ServiceStatus$json],
  '4': [CheckResponse_Status$json],
};

@$core.Deprecated('Use checkResponseDescriptor instead')
const CheckResponse_ServiceStatus$json = {
  '1': 'ServiceStatus',
  '2': [
    {'1': 'service_name', '3': 1, '4': 1, '5': 9, '10': 'serviceName'},
    {'1': 'status', '3': 2, '4': 1, '5': 14, '6': '.health.v1.CheckResponse.Status', '10': 'status'},
  ],
};

@$core.Deprecated('Use checkResponseDescriptor instead')
const CheckResponse_Status$json = {
  '1': 'Status',
  '2': [
    {'1': 'STATUS_UNSPECIFIED', '2': 0},
    {'1': 'STATUS_SERVING', '2': 1},
    {'1': 'STATUS_NOT_SERVING', '2': 2},
    {'1': 'STATUS_SERVICE_UNKNOWN', '2': 3},
  ],
};

/// Descriptor for `CheckResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List checkResponseDescriptor = $convert.base64Decode(
    'Cg1DaGVja1Jlc3BvbnNlElEKEHNlcnZpY2Vfc3RhdHVzZXMYASADKAsyJi5oZWFsdGgudjEuQ2'
    'hlY2tSZXNwb25zZS5TZXJ2aWNlU3RhdHVzUg9zZXJ2aWNlU3RhdHVzZXMaawoNU2VydmljZVN0'
    'YXR1cxIhCgxzZXJ2aWNlX25hbWUYASABKAlSC3NlcnZpY2VOYW1lEjcKBnN0YXR1cxgCIAEoDj'
    'IfLmhlYWx0aC52MS5DaGVja1Jlc3BvbnNlLlN0YXR1c1IGc3RhdHVzImgKBlN0YXR1cxIWChJT'
    'VEFUVVNfVU5TUEVDSUZJRUQQABISCg5TVEFUVVNfU0VSVklORxABEhYKElNUQVRVU19OT1RfU0'
    'VSVklORxACEhoKFlNUQVRVU19TRVJWSUNFX1VOS05PV04QAw==');

const $core.Map<$core.String, $core.dynamic> HealthServiceBase$json = {
  '1': 'HealthService',
  '2': [
    {'1': 'Check', '2': '.google.protobuf.Empty', '3': '.health.v1.CheckResponse'},
  ],
};

@$core.Deprecated('Use healthServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> HealthServiceBase$messageJson = {
  '.google.protobuf.Empty': $1.Empty$json,
  '.health.v1.CheckResponse': CheckResponse$json,
  '.health.v1.CheckResponse.ServiceStatus': CheckResponse_ServiceStatus$json,
};

/// Descriptor for `HealthService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List healthServiceDescriptor = $convert.base64Decode(
    'Cg1IZWFsdGhTZXJ2aWNlEjkKBUNoZWNrEhYuZ29vZ2xlLnByb3RvYnVmLkVtcHR5GhguaGVhbH'
    'RoLnYxLkNoZWNrUmVzcG9uc2U=');

