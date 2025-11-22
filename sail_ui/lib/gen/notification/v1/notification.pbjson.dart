//
//  Generated code. Do not modify.
//  source: notification/v1/notification.proto
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
import '../../google/protobuf/timestamp.pbjson.dart' as $0;

@$core.Deprecated('Use notificationEventDescriptor instead')
const NotificationEvent$json = {
  '1': 'NotificationEvent',
  '2': [
    {'1': 'timestamp', '3': 1, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'timestamp'},
    {'1': 'transaction', '3': 2, '4': 1, '5': 11, '6': '.notification.v1.TransactionEvent', '9': 0, '10': 'transaction'},
    {'1': 'timestamp_event', '3': 3, '4': 1, '5': 11, '6': '.notification.v1.TimestampEvent', '9': 0, '10': 'timestampEvent'},
    {'1': 'system', '3': 4, '4': 1, '5': 11, '6': '.notification.v1.SystemEvent', '9': 0, '10': 'system'},
  ],
  '8': [
    {'1': 'event'},
  ],
};

/// Descriptor for `NotificationEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List notificationEventDescriptor = $convert.base64Decode(
    'ChFOb3RpZmljYXRpb25FdmVudBI4Cgl0aW1lc3RhbXAYASABKAsyGi5nb29nbGUucHJvdG9idW'
    'YuVGltZXN0YW1wUgl0aW1lc3RhbXASRQoLdHJhbnNhY3Rpb24YAiABKAsyIS5ub3RpZmljYXRp'
    'b24udjEuVHJhbnNhY3Rpb25FdmVudEgAUgt0cmFuc2FjdGlvbhJKCg90aW1lc3RhbXBfZXZlbn'
    'QYAyABKAsyHy5ub3RpZmljYXRpb24udjEuVGltZXN0YW1wRXZlbnRIAFIOdGltZXN0YW1wRXZl'
    'bnQSNgoGc3lzdGVtGAQgASgLMhwubm90aWZpY2F0aW9uLnYxLlN5c3RlbUV2ZW50SABSBnN5c3'
    'RlbUIHCgVldmVudA==');

@$core.Deprecated('Use transactionEventDescriptor instead')
const TransactionEvent$json = {
  '1': 'TransactionEvent',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 14, '6': '.notification.v1.TransactionEvent.Type', '10': 'type'},
    {'1': 'txid', '3': 2, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'amount_sats', '3': 3, '4': 1, '5': 4, '10': 'amountSats'},
    {'1': 'confirmations', '3': 4, '4': 1, '5': 13, '10': 'confirmations'},
  ],
  '4': [TransactionEvent_Type$json],
};

@$core.Deprecated('Use transactionEventDescriptor instead')
const TransactionEvent_Type$json = {
  '1': 'Type',
  '2': [
    {'1': 'TYPE_UNSPECIFIED', '2': 0},
    {'1': 'TYPE_RECEIVED', '2': 1},
    {'1': 'TYPE_SENT', '2': 2},
    {'1': 'TYPE_CONFIRMED', '2': 3},
  ],
};

/// Descriptor for `TransactionEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transactionEventDescriptor = $convert.base64Decode(
    'ChBUcmFuc2FjdGlvbkV2ZW50EjoKBHR5cGUYASABKA4yJi5ub3RpZmljYXRpb24udjEuVHJhbn'
    'NhY3Rpb25FdmVudC5UeXBlUgR0eXBlEhIKBHR4aWQYAiABKAlSBHR4aWQSHwoLYW1vdW50X3Nh'
    'dHMYAyABKARSCmFtb3VudFNhdHMSJAoNY29uZmlybWF0aW9ucxgEIAEoDVINY29uZmlybWF0aW'
    '9ucyJSCgRUeXBlEhQKEFRZUEVfVU5TUEVDSUZJRUQQABIRCg1UWVBFX1JFQ0VJVkVEEAESDQoJ'
    'VFlQRV9TRU5UEAISEgoOVFlQRV9DT05GSVJNRUQQAw==');

@$core.Deprecated('Use timestampEventDescriptor instead')
const TimestampEvent$json = {
  '1': 'TimestampEvent',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 14, '6': '.notification.v1.TimestampEvent.Type', '10': 'type'},
    {'1': 'id', '3': 2, '4': 1, '5': 3, '10': 'id'},
    {'1': 'filename', '3': 3, '4': 1, '5': 9, '10': 'filename'},
    {'1': 'txid', '3': 4, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'block_height', '3': 5, '4': 1, '5': 3, '9': 0, '10': 'blockHeight', '17': true},
  ],
  '4': [TimestampEvent_Type$json],
  '8': [
    {'1': '_block_height'},
  ],
};

@$core.Deprecated('Use timestampEventDescriptor instead')
const TimestampEvent_Type$json = {
  '1': 'Type',
  '2': [
    {'1': 'TYPE_UNSPECIFIED', '2': 0},
    {'1': 'TYPE_CREATED', '2': 1},
    {'1': 'TYPE_CONFIRMED', '2': 2},
  ],
};

/// Descriptor for `TimestampEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List timestampEventDescriptor = $convert.base64Decode(
    'Cg5UaW1lc3RhbXBFdmVudBI4CgR0eXBlGAEgASgOMiQubm90aWZpY2F0aW9uLnYxLlRpbWVzdG'
    'FtcEV2ZW50LlR5cGVSBHR5cGUSDgoCaWQYAiABKANSAmlkEhoKCGZpbGVuYW1lGAMgASgJUghm'
    'aWxlbmFtZRISCgR0eGlkGAQgASgJUgR0eGlkEiYKDGJsb2NrX2hlaWdodBgFIAEoA0gAUgtibG'
    '9ja0hlaWdodIgBASJCCgRUeXBlEhQKEFRZUEVfVU5TUEVDSUZJRUQQABIQCgxUWVBFX0NSRUFU'
    'RUQQARISCg5UWVBFX0NPTkZJUk1FRBACQg8KDV9ibG9ja19oZWlnaHQ=');

@$core.Deprecated('Use systemEventDescriptor instead')
const SystemEvent$json = {
  '1': 'SystemEvent',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 14, '6': '.notification.v1.SystemEvent.Type', '10': 'type'},
    {'1': 'message', '3': 2, '4': 1, '5': 9, '10': 'message'},
  ],
  '4': [SystemEvent_Type$json],
};

@$core.Deprecated('Use systemEventDescriptor instead')
const SystemEvent_Type$json = {
  '1': 'Type',
  '2': [
    {'1': 'TYPE_UNSPECIFIED', '2': 0},
    {'1': 'TYPE_SERVICE_CONNECTED', '2': 1},
    {'1': 'TYPE_SERVICE_DISCONNECTED', '2': 2},
    {'1': 'TYPE_SYNC_COMPLETED', '2': 3},
    {'1': 'TYPE_BLOCK_FOUND', '2': 4},
  ],
};

/// Descriptor for `SystemEvent`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List systemEventDescriptor = $convert.base64Decode(
    'CgtTeXN0ZW1FdmVudBI1CgR0eXBlGAEgASgOMiEubm90aWZpY2F0aW9uLnYxLlN5c3RlbUV2ZW'
    '50LlR5cGVSBHR5cGUSGAoHbWVzc2FnZRgCIAEoCVIHbWVzc2FnZSKGAQoEVHlwZRIUChBUWVBF'
    'X1VOU1BFQ0lGSUVEEAASGgoWVFlQRV9TRVJWSUNFX0NPTk5FQ1RFRBABEh0KGVRZUEVfU0VSVk'
    'lDRV9ESVNDT05ORUNURUQQAhIXChNUWVBFX1NZTkNfQ09NUExFVEVEEAMSFAoQVFlQRV9CTE9D'
    'S19GT1VORBAE');

const $core.Map<$core.String, $core.dynamic> NotificationServiceBase$json = {
  '1': 'NotificationService',
  '2': [
    {'1': 'Watch', '2': '.google.protobuf.Empty', '3': '.notification.v1.NotificationEvent', '6': true},
  ],
};

@$core.Deprecated('Use notificationServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> NotificationServiceBase$messageJson = {
  '.google.protobuf.Empty': $1.Empty$json,
  '.notification.v1.NotificationEvent': NotificationEvent$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.notification.v1.TransactionEvent': TransactionEvent$json,
  '.notification.v1.TimestampEvent': TimestampEvent$json,
  '.notification.v1.SystemEvent': SystemEvent$json,
};

/// Descriptor for `NotificationService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List notificationServiceDescriptor = $convert.base64Decode(
    'ChNOb3RpZmljYXRpb25TZXJ2aWNlEkUKBVdhdGNoEhYuZ29vZ2xlLnByb3RvYnVmLkVtcHR5Gi'
    'Iubm90aWZpY2F0aW9uLnYxLk5vdGlmaWNhdGlvbkV2ZW50MAE=');

