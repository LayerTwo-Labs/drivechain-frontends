//
//  Generated code. Do not modify.
//  source: walletpsbt/v1/walletpsbt.proto
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

@$core.Deprecated('Use psbtDraftDescriptor instead')
const PsbtDraft$json = {
  '1': 'PsbtDraft',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
    {'1': 'wallet_id', '3': 2, '4': 1, '5': 9, '10': 'walletId'},
    {'1': 'label', '3': 3, '4': 1, '5': 9, '10': 'label'},
    {'1': 'psbt_base64', '3': 4, '4': 1, '5': 9, '10': 'psbtBase64'},
    {'1': 'created_at', '3': 5, '4': 1, '5': 3, '10': 'createdAt'},
    {'1': 'updated_at', '3': 6, '4': 1, '5': 3, '10': 'updatedAt'},
    {'1': 'txid', '3': 7, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `PsbtDraft`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List psbtDraftDescriptor = $convert.base64Decode(
    'CglQc2J0RHJhZnQSDgoCaWQYASABKAlSAmlkEhsKCXdhbGxldF9pZBgCIAEoCVIId2FsbGV0SW'
    'QSFAoFbGFiZWwYAyABKAlSBWxhYmVsEh8KC3BzYnRfYmFzZTY0GAQgASgJUgpwc2J0QmFzZTY0'
    'Eh0KCmNyZWF0ZWRfYXQYBSABKANSCWNyZWF0ZWRBdBIdCgp1cGRhdGVkX2F0GAYgASgDUgl1cG'
    'RhdGVkQXQSEgoEdHhpZBgHIAEoCVIEdHhpZA==');

@$core.Deprecated('Use listDraftsRequestDescriptor instead')
const ListDraftsRequest$json = {
  '1': 'ListDraftsRequest',
  '2': [
    {'1': 'wallet_id', '3': 1, '4': 1, '5': 9, '10': 'walletId'},
  ],
};

/// Descriptor for `ListDraftsRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listDraftsRequestDescriptor = $convert.base64Decode(
    'ChFMaXN0RHJhZnRzUmVxdWVzdBIbCgl3YWxsZXRfaWQYASABKAlSCHdhbGxldElk');

@$core.Deprecated('Use listDraftsResponseDescriptor instead')
const ListDraftsResponse$json = {
  '1': 'ListDraftsResponse',
  '2': [
    {'1': 'drafts', '3': 1, '4': 3, '5': 11, '6': '.walletpsbt.v1.PsbtDraft', '10': 'drafts'},
  ],
};

/// Descriptor for `ListDraftsResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listDraftsResponseDescriptor = $convert.base64Decode(
    'ChJMaXN0RHJhZnRzUmVzcG9uc2USMAoGZHJhZnRzGAEgAygLMhgud2FsbGV0cHNidC52MS5Qc2'
    'J0RHJhZnRSBmRyYWZ0cw==');

@$core.Deprecated('Use saveDraftRequestDescriptor instead')
const SaveDraftRequest$json = {
  '1': 'SaveDraftRequest',
  '2': [
    {'1': 'draft', '3': 1, '4': 1, '5': 11, '6': '.walletpsbt.v1.PsbtDraft', '10': 'draft'},
  ],
};

/// Descriptor for `SaveDraftRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List saveDraftRequestDescriptor = $convert.base64Decode(
    'ChBTYXZlRHJhZnRSZXF1ZXN0Ei4KBWRyYWZ0GAEgASgLMhgud2FsbGV0cHNidC52MS5Qc2J0RH'
    'JhZnRSBWRyYWZ0');

@$core.Deprecated('Use saveDraftResponseDescriptor instead')
const SaveDraftResponse$json = {
  '1': 'SaveDraftResponse',
  '2': [
    {'1': 'draft', '3': 1, '4': 1, '5': 11, '6': '.walletpsbt.v1.PsbtDraft', '10': 'draft'},
  ],
};

/// Descriptor for `SaveDraftResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List saveDraftResponseDescriptor = $convert.base64Decode(
    'ChFTYXZlRHJhZnRSZXNwb25zZRIuCgVkcmFmdBgBIAEoCzIYLndhbGxldHBzYnQudjEuUHNidE'
    'RyYWZ0UgVkcmFmdA==');

@$core.Deprecated('Use deleteDraftRequestDescriptor instead')
const DeleteDraftRequest$json = {
  '1': 'DeleteDraftRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 9, '10': 'id'},
  ],
};

/// Descriptor for `DeleteDraftRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteDraftRequestDescriptor = $convert.base64Decode(
    'ChJEZWxldGVEcmFmdFJlcXVlc3QSDgoCaWQYASABKAlSAmlk');

const $core.Map<$core.String, $core.dynamic> WalletPsbtServiceBase$json = {
  '1': 'WalletPsbtService',
  '2': [
    {'1': 'ListDrafts', '2': '.walletpsbt.v1.ListDraftsRequest', '3': '.walletpsbt.v1.ListDraftsResponse'},
    {'1': 'SaveDraft', '2': '.walletpsbt.v1.SaveDraftRequest', '3': '.walletpsbt.v1.SaveDraftResponse'},
    {'1': 'DeleteDraft', '2': '.walletpsbt.v1.DeleteDraftRequest', '3': '.google.protobuf.Empty'},
  ],
};

@$core.Deprecated('Use walletPsbtServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> WalletPsbtServiceBase$messageJson = {
  '.walletpsbt.v1.ListDraftsRequest': ListDraftsRequest$json,
  '.walletpsbt.v1.ListDraftsResponse': ListDraftsResponse$json,
  '.walletpsbt.v1.PsbtDraft': PsbtDraft$json,
  '.walletpsbt.v1.SaveDraftRequest': SaveDraftRequest$json,
  '.walletpsbt.v1.SaveDraftResponse': SaveDraftResponse$json,
  '.walletpsbt.v1.DeleteDraftRequest': DeleteDraftRequest$json,
  '.google.protobuf.Empty': $1.Empty$json,
};

/// Descriptor for `WalletPsbtService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List walletPsbtServiceDescriptor = $convert.base64Decode(
    'ChFXYWxsZXRQc2J0U2VydmljZRJRCgpMaXN0RHJhZnRzEiAud2FsbGV0cHNidC52MS5MaXN0RH'
    'JhZnRzUmVxdWVzdBohLndhbGxldHBzYnQudjEuTGlzdERyYWZ0c1Jlc3BvbnNlEk4KCVNhdmVE'
    'cmFmdBIfLndhbGxldHBzYnQudjEuU2F2ZURyYWZ0UmVxdWVzdBogLndhbGxldHBzYnQudjEuU2'
    'F2ZURyYWZ0UmVzcG9uc2USSAoLRGVsZXRlRHJhZnQSIS53YWxsZXRwc2J0LnYxLkRlbGV0ZURy'
    'YWZ0UmVxdWVzdBoWLmdvb2dsZS5wcm90b2J1Zi5FbXB0eQ==');

