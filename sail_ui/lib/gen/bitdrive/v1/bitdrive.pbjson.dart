//
//  Generated code. Do not modify.
//  source: bitdrive/v1/bitdrive.proto
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

@$core.Deprecated('Use bitDriveMetadataDescriptor instead')
const BitDriveMetadata$json = {
  '1': 'BitDriveMetadata',
  '2': [
    {'1': 'flags', '3': 1, '4': 1, '5': 13, '10': 'flags'},
    {'1': 'timestamp', '3': 2, '4': 1, '5': 13, '10': 'timestamp'},
    {'1': 'file_type', '3': 3, '4': 1, '5': 9, '10': 'fileType'},
  ],
};

/// Descriptor for `BitDriveMetadata`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bitDriveMetadataDescriptor = $convert.base64Decode(
    'ChBCaXREcml2ZU1ldGFkYXRhEhQKBWZsYWdzGAEgASgNUgVmbGFncxIcCgl0aW1lc3RhbXAYAi'
    'ABKA1SCXRpbWVzdGFtcBIbCglmaWxlX3R5cGUYAyABKAlSCGZpbGVUeXBl');

@$core.Deprecated('Use storeFileRequestDescriptor instead')
const StoreFileRequest$json = {
  '1': 'StoreFileRequest',
  '2': [
    {'1': 'content', '3': 1, '4': 1, '5': 12, '10': 'content'},
    {'1': 'filename', '3': 2, '4': 1, '5': 9, '10': 'filename'},
    {'1': 'mime_type', '3': 3, '4': 1, '5': 9, '10': 'mimeType'},
    {'1': 'encrypt', '3': 4, '4': 1, '5': 8, '10': 'encrypt'},
    {'1': 'fee_sat_per_vbyte', '3': 5, '4': 1, '5': 4, '10': 'feeSatPerVbyte'},
  ],
};

/// Descriptor for `StoreFileRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List storeFileRequestDescriptor = $convert.base64Decode(
    'ChBTdG9yZUZpbGVSZXF1ZXN0EhgKB2NvbnRlbnQYASABKAxSB2NvbnRlbnQSGgoIZmlsZW5hbW'
    'UYAiABKAlSCGZpbGVuYW1lEhsKCW1pbWVfdHlwZRgDIAEoCVIIbWltZVR5cGUSGAoHZW5jcnlw'
    'dBgEIAEoCFIHZW5jcnlwdBIpChFmZWVfc2F0X3Blcl92Ynl0ZRgFIAEoBFIOZmVlU2F0UGVyVm'
    'J5dGU=');

@$core.Deprecated('Use storeFileResponseDescriptor instead')
const StoreFileResponse$json = {
  '1': 'StoreFileResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'file_type', '3': 2, '4': 1, '5': 9, '10': 'fileType'},
    {'1': 'encrypted', '3': 3, '4': 1, '5': 8, '10': 'encrypted'},
  ],
};

/// Descriptor for `StoreFileResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List storeFileResponseDescriptor = $convert.base64Decode(
    'ChFTdG9yZUZpbGVSZXNwb25zZRISCgR0eGlkGAEgASgJUgR0eGlkEhsKCWZpbGVfdHlwZRgCIA'
    'EoCVIIZmlsZVR5cGUSHAoJZW5jcnlwdGVkGAMgASgIUgllbmNyeXB0ZWQ=');

@$core.Deprecated('Use retrieveContentRequestDescriptor instead')
const RetrieveContentRequest$json = {
  '1': 'RetrieveContentRequest',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `RetrieveContentRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List retrieveContentRequestDescriptor = $convert.base64Decode(
    'ChZSZXRyaWV2ZUNvbnRlbnRSZXF1ZXN0EhIKBHR4aWQYASABKAlSBHR4aWQ=');

@$core.Deprecated('Use retrieveContentResponseDescriptor instead')
const RetrieveContentResponse$json = {
  '1': 'RetrieveContentResponse',
  '2': [
    {'1': 'content', '3': 1, '4': 1, '5': 12, '10': 'content'},
    {'1': 'file_type', '3': 2, '4': 1, '5': 9, '10': 'fileType'},
    {'1': 'encrypted', '3': 3, '4': 1, '5': 8, '10': 'encrypted'},
    {'1': 'timestamp', '3': 4, '4': 1, '5': 13, '10': 'timestamp'},
  ],
};

/// Descriptor for `RetrieveContentResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List retrieveContentResponseDescriptor = $convert.base64Decode(
    'ChdSZXRyaWV2ZUNvbnRlbnRSZXNwb25zZRIYCgdjb250ZW50GAEgASgMUgdjb250ZW50EhsKCW'
    'ZpbGVfdHlwZRgCIAEoCVIIZmlsZVR5cGUSHAoJZW5jcnlwdGVkGAMgASgIUgllbmNyeXB0ZWQS'
    'HAoJdGltZXN0YW1wGAQgASgNUgl0aW1lc3RhbXA=');

@$core.Deprecated('Use scanForFilesResponseDescriptor instead')
const ScanForFilesResponse$json = {
  '1': 'ScanForFilesResponse',
  '2': [
    {'1': 'pending_files', '3': 1, '4': 3, '5': 11, '6': '.bitdrive.v1.PendingFile', '10': 'pendingFiles'},
    {'1': 'total_scanned', '3': 2, '4': 1, '5': 13, '10': 'totalScanned'},
  ],
};

/// Descriptor for `ScanForFilesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List scanForFilesResponseDescriptor = $convert.base64Decode(
    'ChRTY2FuRm9yRmlsZXNSZXNwb25zZRI9Cg1wZW5kaW5nX2ZpbGVzGAEgAygLMhguYml0ZHJpdm'
    'UudjEuUGVuZGluZ0ZpbGVSDHBlbmRpbmdGaWxlcxIjCg10b3RhbF9zY2FubmVkGAIgASgNUgx0'
    'b3RhbFNjYW5uZWQ=');

@$core.Deprecated('Use pendingFileDescriptor instead')
const PendingFile$json = {
  '1': 'PendingFile',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'encrypted', '3': 2, '4': 1, '5': 8, '10': 'encrypted'},
    {'1': 'timestamp', '3': 3, '4': 1, '5': 13, '10': 'timestamp'},
    {'1': 'file_type', '3': 4, '4': 1, '5': 9, '10': 'fileType'},
    {'1': 'filename', '3': 5, '4': 1, '5': 9, '10': 'filename'},
  ],
};

/// Descriptor for `PendingFile`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List pendingFileDescriptor = $convert.base64Decode(
    'CgtQZW5kaW5nRmlsZRISCgR0eGlkGAEgASgJUgR0eGlkEhwKCWVuY3J5cHRlZBgCIAEoCFIJZW'
    '5jcnlwdGVkEhwKCXRpbWVzdGFtcBgDIAEoDVIJdGltZXN0YW1wEhsKCWZpbGVfdHlwZRgEIAEo'
    'CVIIZmlsZVR5cGUSGgoIZmlsZW5hbWUYBSABKAlSCGZpbGVuYW1l');

@$core.Deprecated('Use downloadPendingFilesResponseDescriptor instead')
const DownloadPendingFilesResponse$json = {
  '1': 'DownloadPendingFilesResponse',
  '2': [
    {'1': 'downloaded_count', '3': 1, '4': 1, '5': 13, '10': 'downloadedCount'},
    {'1': 'failed_count', '3': 2, '4': 1, '5': 13, '10': 'failedCount'},
  ],
};

/// Descriptor for `DownloadPendingFilesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List downloadPendingFilesResponseDescriptor = $convert.base64Decode(
    'ChxEb3dubG9hZFBlbmRpbmdGaWxlc1Jlc3BvbnNlEikKEGRvd25sb2FkZWRfY291bnQYASABKA'
    '1SD2Rvd25sb2FkZWRDb3VudBIhCgxmYWlsZWRfY291bnQYAiABKA1SC2ZhaWxlZENvdW50');

@$core.Deprecated('Use bitDriveFileDescriptor instead')
const BitDriveFile$json = {
  '1': 'BitDriveFile',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'filename', '3': 2, '4': 1, '5': 9, '10': 'filename'},
    {'1': 'file_type', '3': 3, '4': 1, '5': 9, '10': 'fileType'},
    {'1': 'size_bytes', '3': 4, '4': 1, '5': 3, '10': 'sizeBytes'},
    {'1': 'encrypted', '3': 5, '4': 1, '5': 8, '10': 'encrypted'},
    {'1': 'txid', '3': 6, '4': 1, '5': 9, '10': 'txid'},
    {'1': 'timestamp', '3': 7, '4': 1, '5': 13, '10': 'timestamp'},
    {'1': 'created_at', '3': 8, '4': 1, '5': 11, '6': '.google.protobuf.Timestamp', '10': 'createdAt'},
  ],
};

/// Descriptor for `BitDriveFile`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List bitDriveFileDescriptor = $convert.base64Decode(
    'CgxCaXREcml2ZUZpbGUSDgoCaWQYASABKANSAmlkEhoKCGZpbGVuYW1lGAIgASgJUghmaWxlbm'
    'FtZRIbCglmaWxlX3R5cGUYAyABKAlSCGZpbGVUeXBlEh0KCnNpemVfYnl0ZXMYBCABKANSCXNp'
    'emVCeXRlcxIcCgllbmNyeXB0ZWQYBSABKAhSCWVuY3J5cHRlZBISCgR0eGlkGAYgASgJUgR0eG'
    'lkEhwKCXRpbWVzdGFtcBgHIAEoDVIJdGltZXN0YW1wEjkKCmNyZWF0ZWRfYXQYCCABKAsyGi5n'
    'b29nbGUucHJvdG9idWYuVGltZXN0YW1wUgljcmVhdGVkQXQ=');

@$core.Deprecated('Use listFilesResponseDescriptor instead')
const ListFilesResponse$json = {
  '1': 'ListFilesResponse',
  '2': [
    {'1': 'files', '3': 1, '4': 3, '5': 11, '6': '.bitdrive.v1.BitDriveFile', '10': 'files'},
  ],
};

/// Descriptor for `ListFilesResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List listFilesResponseDescriptor = $convert.base64Decode(
    'ChFMaXN0RmlsZXNSZXNwb25zZRIvCgVmaWxlcxgBIAMoCzIZLmJpdGRyaXZlLnYxLkJpdERyaX'
    'ZlRmlsZVIFZmlsZXM=');

@$core.Deprecated('Use getFileRequestDescriptor instead')
const GetFileRequest$json = {
  '1': 'GetFileRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
    {'1': 'txid', '3': 2, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `GetFileRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFileRequestDescriptor = $convert.base64Decode(
    'Cg5HZXRGaWxlUmVxdWVzdBIOCgJpZBgBIAEoA1ICaWQSEgoEdHhpZBgCIAEoCVIEdHhpZA==');

@$core.Deprecated('Use getFileResponseDescriptor instead')
const GetFileResponse$json = {
  '1': 'GetFileResponse',
  '2': [
    {'1': 'file', '3': 1, '4': 1, '5': 11, '6': '.bitdrive.v1.BitDriveFile', '10': 'file'},
    {'1': 'content', '3': 2, '4': 1, '5': 12, '10': 'content'},
  ],
};

/// Descriptor for `GetFileResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List getFileResponseDescriptor = $convert.base64Decode(
    'Cg9HZXRGaWxlUmVzcG9uc2USLQoEZmlsZRgBIAEoCzIZLmJpdGRyaXZlLnYxLkJpdERyaXZlRm'
    'lsZVIEZmlsZRIYCgdjb250ZW50GAIgASgMUgdjb250ZW50');

@$core.Deprecated('Use deleteFileRequestDescriptor instead')
const DeleteFileRequest$json = {
  '1': 'DeleteFileRequest',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 3, '10': 'id'},
  ],
};

/// Descriptor for `DeleteFileRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List deleteFileRequestDescriptor = $convert.base64Decode(
    'ChFEZWxldGVGaWxlUmVxdWVzdBIOCgJpZBgBIAEoA1ICaWQ=');

@$core.Deprecated('Use storeMultisigDataRequestDescriptor instead')
const StoreMultisigDataRequest$json = {
  '1': 'StoreMultisigDataRequest',
  '2': [
    {'1': 'json_data', '3': 1, '4': 1, '5': 12, '10': 'jsonData'},
    {'1': 'encrypt', '3': 2, '4': 1, '5': 8, '10': 'encrypt'},
    {'1': 'fee_sat_per_vbyte', '3': 3, '4': 1, '5': 4, '10': 'feeSatPerVbyte'},
  ],
};

/// Descriptor for `StoreMultisigDataRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List storeMultisigDataRequestDescriptor = $convert.base64Decode(
    'ChhTdG9yZU11bHRpc2lnRGF0YVJlcXVlc3QSGwoJanNvbl9kYXRhGAEgASgMUghqc29uRGF0YR'
    'IYCgdlbmNyeXB0GAIgASgIUgdlbmNyeXB0EikKEWZlZV9zYXRfcGVyX3ZieXRlGAMgASgEUg5m'
    'ZWVTYXRQZXJWYnl0ZQ==');

@$core.Deprecated('Use storeMultisigDataResponseDescriptor instead')
const StoreMultisigDataResponse$json = {
  '1': 'StoreMultisigDataResponse',
  '2': [
    {'1': 'txid', '3': 1, '4': 1, '5': 9, '10': 'txid'},
  ],
};

/// Descriptor for `StoreMultisigDataResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List storeMultisigDataResponseDescriptor = $convert.base64Decode(
    'ChlTdG9yZU11bHRpc2lnRGF0YVJlc3BvbnNlEhIKBHR4aWQYASABKAlSBHR4aWQ=');

const $core.Map<$core.String, $core.dynamic> BitDriveServiceBase$json = {
  '1': 'BitDriveService',
  '2': [
    {'1': 'StoreFile', '2': '.bitdrive.v1.StoreFileRequest', '3': '.bitdrive.v1.StoreFileResponse'},
    {'1': 'RetrieveContent', '2': '.bitdrive.v1.RetrieveContentRequest', '3': '.bitdrive.v1.RetrieveContentResponse'},
    {'1': 'ScanForFiles', '2': '.google.protobuf.Empty', '3': '.bitdrive.v1.ScanForFilesResponse'},
    {'1': 'DownloadPendingFiles', '2': '.google.protobuf.Empty', '3': '.bitdrive.v1.DownloadPendingFilesResponse'},
    {'1': 'ListFiles', '2': '.google.protobuf.Empty', '3': '.bitdrive.v1.ListFilesResponse'},
    {'1': 'GetFile', '2': '.bitdrive.v1.GetFileRequest', '3': '.bitdrive.v1.GetFileResponse'},
    {'1': 'DeleteFile', '2': '.bitdrive.v1.DeleteFileRequest', '3': '.google.protobuf.Empty'},
    {'1': 'StoreMultisigData', '2': '.bitdrive.v1.StoreMultisigDataRequest', '3': '.bitdrive.v1.StoreMultisigDataResponse'},
    {'1': 'WipeData', '2': '.google.protobuf.Empty', '3': '.google.protobuf.Empty'},
  ],
};

@$core.Deprecated('Use bitDriveServiceDescriptor instead')
const $core.Map<$core.String, $core.Map<$core.String, $core.dynamic>> BitDriveServiceBase$messageJson = {
  '.bitdrive.v1.StoreFileRequest': StoreFileRequest$json,
  '.bitdrive.v1.StoreFileResponse': StoreFileResponse$json,
  '.bitdrive.v1.RetrieveContentRequest': RetrieveContentRequest$json,
  '.bitdrive.v1.RetrieveContentResponse': RetrieveContentResponse$json,
  '.google.protobuf.Empty': $1.Empty$json,
  '.bitdrive.v1.ScanForFilesResponse': ScanForFilesResponse$json,
  '.bitdrive.v1.PendingFile': PendingFile$json,
  '.bitdrive.v1.DownloadPendingFilesResponse': DownloadPendingFilesResponse$json,
  '.bitdrive.v1.ListFilesResponse': ListFilesResponse$json,
  '.bitdrive.v1.BitDriveFile': BitDriveFile$json,
  '.google.protobuf.Timestamp': $0.Timestamp$json,
  '.bitdrive.v1.GetFileRequest': GetFileRequest$json,
  '.bitdrive.v1.GetFileResponse': GetFileResponse$json,
  '.bitdrive.v1.DeleteFileRequest': DeleteFileRequest$json,
  '.bitdrive.v1.StoreMultisigDataRequest': StoreMultisigDataRequest$json,
  '.bitdrive.v1.StoreMultisigDataResponse': StoreMultisigDataResponse$json,
};

/// Descriptor for `BitDriveService`. Decode as a `google.protobuf.ServiceDescriptorProto`.
final $typed_data.Uint8List bitDriveServiceDescriptor = $convert.base64Decode(
    'Cg9CaXREcml2ZVNlcnZpY2USSgoJU3RvcmVGaWxlEh0uYml0ZHJpdmUudjEuU3RvcmVGaWxlUm'
    'VxdWVzdBoeLmJpdGRyaXZlLnYxLlN0b3JlRmlsZVJlc3BvbnNlElwKD1JldHJpZXZlQ29udGVu'
    'dBIjLmJpdGRyaXZlLnYxLlJldHJpZXZlQ29udGVudFJlcXVlc3QaJC5iaXRkcml2ZS52MS5SZX'
    'RyaWV2ZUNvbnRlbnRSZXNwb25zZRJJCgxTY2FuRm9yRmlsZXMSFi5nb29nbGUucHJvdG9idWYu'
    'RW1wdHkaIS5iaXRkcml2ZS52MS5TY2FuRm9yRmlsZXNSZXNwb25zZRJZChREb3dubG9hZFBlbm'
    'RpbmdGaWxlcxIWLmdvb2dsZS5wcm90b2J1Zi5FbXB0eRopLmJpdGRyaXZlLnYxLkRvd25sb2Fk'
    'UGVuZGluZ0ZpbGVzUmVzcG9uc2USQwoJTGlzdEZpbGVzEhYuZ29vZ2xlLnByb3RvYnVmLkVtcH'
    'R5Gh4uYml0ZHJpdmUudjEuTGlzdEZpbGVzUmVzcG9uc2USRAoHR2V0RmlsZRIbLmJpdGRyaXZl'
    'LnYxLkdldEZpbGVSZXF1ZXN0GhwuYml0ZHJpdmUudjEuR2V0RmlsZVJlc3BvbnNlEkQKCkRlbG'
    'V0ZUZpbGUSHi5iaXRkcml2ZS52MS5EZWxldGVGaWxlUmVxdWVzdBoWLmdvb2dsZS5wcm90b2J1'
    'Zi5FbXB0eRJiChFTdG9yZU11bHRpc2lnRGF0YRIlLmJpdGRyaXZlLnYxLlN0b3JlTXVsdGlzaW'
    'dEYXRhUmVxdWVzdBomLmJpdGRyaXZlLnYxLlN0b3JlTXVsdGlzaWdEYXRhUmVzcG9uc2USOgoI'
    'V2lwZURhdGESFi5nb29nbGUucHJvdG9idWYuRW1wdHkaFi5nb29nbGUucHJvdG9idWYuRW1wdH'
    'k=');

