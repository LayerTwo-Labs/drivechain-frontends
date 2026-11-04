// This is a generated file - do not edit.
//
// Generated from bitdrive/v1/bitdrive.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $1;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// File metadata stored in OP_RETURN (9 bytes total)
class BitDriveMetadata extends $pb.GeneratedMessage {
  factory BitDriveMetadata({
    $core.int? flags,
    $core.int? timestamp,
    $core.String? fileType,
  }) {
    final result = BitDriveMetadata._();
    if (flags != null) result.flags = flags;
    if (timestamp != null) result.timestamp = timestamp;
    if (fileType != null) result.fileType = fileType;
    return result;
  }

  BitDriveMetadata._();

  factory BitDriveMetadata.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BitDriveMetadata()..mergeFromBuffer(data, registry);
  factory BitDriveMetadata.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BitDriveMetadata()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BitDriveMetadata',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'),
      createEmptyInstance: BitDriveMetadata.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'flags', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'timestamp', fieldType: $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'fileType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BitDriveMetadata clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BitDriveMetadata copyWith(void Function(BitDriveMetadata) updates) =>
      super.copyWith((message) => updates(message as BitDriveMetadata)) as BitDriveMetadata;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BitDriveMetadata() / BitDriveMetadata.new instead')
  static BitDriveMetadata create() => BitDriveMetadata._();
  static $pb.GeneratedMessage $_createMessage() => BitDriveMetadata._();
  @$core.override
  BitDriveMetadata createEmptyInstance() => BitDriveMetadata._();
  @$core.pragma('dart2js:noInline')
  static BitDriveMetadata getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BitDriveMetadata>(BitDriveMetadata.$_createMessage);
  static BitDriveMetadata? _defaultInstance;

  /// Flags (1 byte): bit 0 = encrypted, bit 1 = multisig
  @$pb.TagNumber(1)
  $core.int get flags => $_getIZ(0);
  @$pb.TagNumber(1)
  set flags($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFlags() => $_has(0);
  @$pb.TagNumber(1)
  void clearFlags() => $_clearField(1);

  /// Unix timestamp (4 bytes, big endian)
  @$pb.TagNumber(2)
  $core.int get timestamp => $_getIZ(1);
  @$pb.TagNumber(2)
  set timestamp($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => $_clearField(2);

  /// File type extension (4 bytes ASCII, padded with spaces)
  @$pb.TagNumber(3)
  $core.String get fileType => $_getSZ(2);
  @$pb.TagNumber(3)
  set fileType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFileType() => $_has(2);
  @$pb.TagNumber(3)
  void clearFileType() => $_clearField(3);
}

/// Request to store file content
class StoreFileRequest extends $pb.GeneratedMessage {
  factory StoreFileRequest({
    $core.List<$core.int>? content,
    $core.String? filename,
    $core.String? mimeType,
    $core.bool? encrypt,
    $fixnum.Int64? feeSatPerVbyte,
  }) {
    final result = StoreFileRequest._();
    if (content != null) result.content = content;
    if (filename != null) result.filename = filename;
    if (mimeType != null) result.mimeType = mimeType;
    if (encrypt != null) result.encrypt = encrypt;
    if (feeSatPerVbyte != null) result.feeSatPerVbyte = feeSatPerVbyte;
    return result;
  }

  StoreFileRequest._();

  factory StoreFileRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StoreFileRequest()..mergeFromBuffer(data, registry);
  factory StoreFileRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StoreFileRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StoreFileRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'),
      createEmptyInstance: StoreFileRequest.$_createMessage)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'content', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'filename')
    ..aOS(3, _omitFieldNames ? '' : 'mimeType')
    ..aOB(4, _omitFieldNames ? '' : 'encrypt')
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'feeSatPerVbyte', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StoreFileRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StoreFileRequest copyWith(void Function(StoreFileRequest) updates) =>
      super.copyWith((message) => updates(message as StoreFileRequest)) as StoreFileRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StoreFileRequest() / StoreFileRequest.new instead')
  static StoreFileRequest create() => StoreFileRequest._();
  static $pb.GeneratedMessage $_createMessage() => StoreFileRequest._();
  @$core.override
  StoreFileRequest createEmptyInstance() => StoreFileRequest._();
  @$core.pragma('dart2js:noInline')
  static StoreFileRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StoreFileRequest>(StoreFileRequest.$_createMessage);
  static StoreFileRequest? _defaultInstance;

  /// Raw file content (max 1MB)
  @$pb.TagNumber(1)
  $core.List<$core.int> get content => $_getN(0);
  @$pb.TagNumber(1)
  set content($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearContent() => $_clearField(1);

  /// Optional filename
  @$pb.TagNumber(2)
  $core.String get filename => $_getSZ(1);
  @$pb.TagNumber(2)
  set filename($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFilename() => $_has(1);
  @$pb.TagNumber(2)
  void clearFilename() => $_clearField(2);

  /// Optional MIME type
  @$pb.TagNumber(3)
  $core.String get mimeType => $_getSZ(2);
  @$pb.TagNumber(3)
  set mimeType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMimeType() => $_has(2);
  @$pb.TagNumber(3)
  void clearMimeType() => $_clearField(3);

  /// Whether to encrypt the content
  @$pb.TagNumber(4)
  $core.bool get encrypt => $_getBF(3);
  @$pb.TagNumber(4)
  set encrypt($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEncrypt() => $_has(3);
  @$pb.TagNumber(4)
  void clearEncrypt() => $_clearField(4);

  /// Fee in satoshis per vbyte
  @$pb.TagNumber(5)
  $fixnum.Int64 get feeSatPerVbyte => $_getI64(4);
  @$pb.TagNumber(5)
  set feeSatPerVbyte($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFeeSatPerVbyte() => $_has(4);
  @$pb.TagNumber(5)
  void clearFeeSatPerVbyte() => $_clearField(5);
}

class StoreFileResponse extends $pb.GeneratedMessage {
  factory StoreFileResponse({
    $core.String? txid,
    $core.String? fileType,
    $core.bool? encrypted,
  }) {
    final result = StoreFileResponse._();
    if (txid != null) result.txid = txid;
    if (fileType != null) result.fileType = fileType;
    if (encrypted != null) result.encrypted = encrypted;
    return result;
  }

  StoreFileResponse._();

  factory StoreFileResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StoreFileResponse()..mergeFromBuffer(data, registry);
  factory StoreFileResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StoreFileResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StoreFileResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'),
      createEmptyInstance: StoreFileResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aOS(2, _omitFieldNames ? '' : 'fileType')
    ..aOB(3, _omitFieldNames ? '' : 'encrypted')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StoreFileResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StoreFileResponse copyWith(void Function(StoreFileResponse) updates) =>
      super.copyWith((message) => updates(message as StoreFileResponse)) as StoreFileResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StoreFileResponse() / StoreFileResponse.new instead')
  static StoreFileResponse create() => StoreFileResponse._();
  static $pb.GeneratedMessage $_createMessage() => StoreFileResponse._();
  @$core.override
  StoreFileResponse createEmptyInstance() => StoreFileResponse._();
  @$core.pragma('dart2js:noInline')
  static StoreFileResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StoreFileResponse>(StoreFileResponse.$_createMessage);
  static StoreFileResponse? _defaultInstance;

  /// Transaction ID of the stored content
  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  /// Detected or assigned file type
  @$pb.TagNumber(2)
  $core.String get fileType => $_getSZ(1);
  @$pb.TagNumber(2)
  set fileType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFileType() => $_has(1);
  @$pb.TagNumber(2)
  void clearFileType() => $_clearField(2);

  /// Whether content was encrypted
  @$pb.TagNumber(3)
  $core.bool get encrypted => $_getBF(2);
  @$pb.TagNumber(3)
  set encrypted($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEncrypted() => $_has(2);
  @$pb.TagNumber(3)
  void clearEncrypted() => $_clearField(3);
}

/// Request to retrieve content by txid
class RetrieveContentRequest extends $pb.GeneratedMessage {
  factory RetrieveContentRequest({
    $core.String? txid,
  }) {
    final result = RetrieveContentRequest._();
    if (txid != null) result.txid = txid;
    return result;
  }

  RetrieveContentRequest._();

  factory RetrieveContentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RetrieveContentRequest()..mergeFromBuffer(data, registry);
  factory RetrieveContentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RetrieveContentRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RetrieveContentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'),
      createEmptyInstance: RetrieveContentRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RetrieveContentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RetrieveContentRequest copyWith(void Function(RetrieveContentRequest) updates) =>
      super.copyWith((message) => updates(message as RetrieveContentRequest)) as RetrieveContentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RetrieveContentRequest() / RetrieveContentRequest.new instead')
  static RetrieveContentRequest create() => RetrieveContentRequest._();
  static $pb.GeneratedMessage $_createMessage() => RetrieveContentRequest._();
  @$core.override
  RetrieveContentRequest createEmptyInstance() => RetrieveContentRequest._();
  @$core.pragma('dart2js:noInline')
  static RetrieveContentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RetrieveContentRequest>(RetrieveContentRequest.$_createMessage);
  static RetrieveContentRequest? _defaultInstance;

  /// Transaction ID containing the OP_RETURN data
  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class RetrieveContentResponse extends $pb.GeneratedMessage {
  factory RetrieveContentResponse({
    $core.List<$core.int>? content,
    $core.String? fileType,
    $core.bool? encrypted,
    $core.int? timestamp,
  }) {
    final result = RetrieveContentResponse._();
    if (content != null) result.content = content;
    if (fileType != null) result.fileType = fileType;
    if (encrypted != null) result.encrypted = encrypted;
    if (timestamp != null) result.timestamp = timestamp;
    return result;
  }

  RetrieveContentResponse._();

  factory RetrieveContentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RetrieveContentResponse()..mergeFromBuffer(data, registry);
  factory RetrieveContentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RetrieveContentResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RetrieveContentResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'),
      createEmptyInstance: RetrieveContentResponse.$_createMessage)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'content', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'fileType')
    ..aOB(3, _omitFieldNames ? '' : 'encrypted')
    ..aI(4, _omitFieldNames ? '' : 'timestamp', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RetrieveContentResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RetrieveContentResponse copyWith(void Function(RetrieveContentResponse) updates) =>
      super.copyWith((message) => updates(message as RetrieveContentResponse)) as RetrieveContentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RetrieveContentResponse() / RetrieveContentResponse.new instead')
  static RetrieveContentResponse create() => RetrieveContentResponse._();
  static $pb.GeneratedMessage $_createMessage() => RetrieveContentResponse._();
  @$core.override
  RetrieveContentResponse createEmptyInstance() => RetrieveContentResponse._();
  @$core.pragma('dart2js:noInline')
  static RetrieveContentResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RetrieveContentResponse>(RetrieveContentResponse.$_createMessage);
  static RetrieveContentResponse? _defaultInstance;

  /// Decrypted/raw file content
  @$pb.TagNumber(1)
  $core.List<$core.int> get content => $_getN(0);
  @$pb.TagNumber(1)
  set content($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearContent() => $_clearField(1);

  /// File type
  @$pb.TagNumber(2)
  $core.String get fileType => $_getSZ(1);
  @$pb.TagNumber(2)
  set fileType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFileType() => $_has(1);
  @$pb.TagNumber(2)
  void clearFileType() => $_clearField(2);

  /// Whether content was encrypted
  @$pb.TagNumber(3)
  $core.bool get encrypted => $_getBF(2);
  @$pb.TagNumber(3)
  set encrypted($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEncrypted() => $_has(2);
  @$pb.TagNumber(3)
  void clearEncrypted() => $_clearField(3);

  /// Timestamp
  @$pb.TagNumber(4)
  $core.int get timestamp => $_getIZ(3);
  @$pb.TagNumber(4)
  set timestamp($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => $_clearField(4);
}

/// Scan results
class ScanForFilesResponse extends $pb.GeneratedMessage {
  factory ScanForFilesResponse({
    $core.Iterable<PendingFile>? pendingFiles,
    $core.int? totalScanned,
  }) {
    final result = ScanForFilesResponse._();
    if (pendingFiles != null) result.pendingFiles.addAll(pendingFiles);
    if (totalScanned != null) result.totalScanned = totalScanned;
    return result;
  }

  ScanForFilesResponse._();

  factory ScanForFilesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ScanForFilesResponse()..mergeFromBuffer(data, registry);
  factory ScanForFilesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ScanForFilesResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ScanForFilesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'),
      createEmptyInstance: ScanForFilesResponse.$_createMessage)
    ..pPM<PendingFile>(1, _omitFieldNames ? '' : 'pendingFiles', subBuilder: PendingFile.$_createMessage)
    ..aI(2, _omitFieldNames ? '' : 'totalScanned', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScanForFilesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ScanForFilesResponse copyWith(void Function(ScanForFilesResponse) updates) =>
      super.copyWith((message) => updates(message as ScanForFilesResponse)) as ScanForFilesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ScanForFilesResponse() / ScanForFilesResponse.new instead')
  static ScanForFilesResponse create() => ScanForFilesResponse._();
  static $pb.GeneratedMessage $_createMessage() => ScanForFilesResponse._();
  @$core.override
  ScanForFilesResponse createEmptyInstance() => ScanForFilesResponse._();
  @$core.pragma('dart2js:noInline')
  static ScanForFilesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ScanForFilesResponse>(ScanForFilesResponse.$_createMessage);
  static ScanForFilesResponse? _defaultInstance;

  /// Files found that are not yet downloaded
  @$pb.TagNumber(1)
  $pb.PbList<PendingFile> get pendingFiles => $_getList(0);

  /// Total files scanned
  @$pb.TagNumber(2)
  $core.int get totalScanned => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalScanned($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalScanned() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalScanned() => $_clearField(2);
}

class PendingFile extends $pb.GeneratedMessage {
  factory PendingFile({
    $core.String? txid,
    $core.bool? encrypted,
    $core.int? timestamp,
    $core.String? fileType,
    $core.String? filename,
  }) {
    final result = PendingFile._();
    if (txid != null) result.txid = txid;
    if (encrypted != null) result.encrypted = encrypted;
    if (timestamp != null) result.timestamp = timestamp;
    if (fileType != null) result.fileType = fileType;
    if (filename != null) result.filename = filename;
    return result;
  }

  PendingFile._();

  factory PendingFile.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PendingFile()..mergeFromBuffer(data, registry);
  factory PendingFile.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PendingFile()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PendingFile',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'),
      createEmptyInstance: PendingFile.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aOB(2, _omitFieldNames ? '' : 'encrypted')
    ..aI(3, _omitFieldNames ? '' : 'timestamp', fieldType: $pb.PbFieldType.OU3)
    ..aOS(4, _omitFieldNames ? '' : 'fileType')
    ..aOS(5, _omitFieldNames ? '' : 'filename')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PendingFile clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PendingFile copyWith(void Function(PendingFile) updates) =>
      super.copyWith((message) => updates(message as PendingFile)) as PendingFile;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PendingFile() / PendingFile.new instead')
  static PendingFile create() => PendingFile._();
  static $pb.GeneratedMessage $_createMessage() => PendingFile._();
  @$core.override
  PendingFile createEmptyInstance() => PendingFile._();
  @$core.pragma('dart2js:noInline')
  static PendingFile getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PendingFile>(PendingFile.$_createMessage);
  static PendingFile? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get encrypted => $_getBF(1);
  @$pb.TagNumber(2)
  set encrypted($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEncrypted() => $_has(1);
  @$pb.TagNumber(2)
  void clearEncrypted() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get timestamp => $_getIZ(2);
  @$pb.TagNumber(3)
  set timestamp($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get fileType => $_getSZ(3);
  @$pb.TagNumber(4)
  set fileType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFileType() => $_has(3);
  @$pb.TagNumber(4)
  void clearFileType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get filename => $_getSZ(4);
  @$pb.TagNumber(5)
  set filename($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFilename() => $_has(4);
  @$pb.TagNumber(5)
  void clearFilename() => $_clearField(5);
}

class DownloadPendingFilesResponse extends $pb.GeneratedMessage {
  factory DownloadPendingFilesResponse({
    $core.int? downloadedCount,
    $core.int? failedCount,
  }) {
    final result = DownloadPendingFilesResponse._();
    if (downloadedCount != null) result.downloadedCount = downloadedCount;
    if (failedCount != null) result.failedCount = failedCount;
    return result;
  }

  DownloadPendingFilesResponse._();

  factory DownloadPendingFilesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DownloadPendingFilesResponse()..mergeFromBuffer(data, registry);
  factory DownloadPendingFilesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DownloadPendingFilesResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DownloadPendingFilesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'),
      createEmptyInstance: DownloadPendingFilesResponse.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'downloadedCount', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'failedCount', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadPendingFilesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DownloadPendingFilesResponse copyWith(void Function(DownloadPendingFilesResponse) updates) =>
      super.copyWith((message) => updates(message as DownloadPendingFilesResponse)) as DownloadPendingFilesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DownloadPendingFilesResponse() / DownloadPendingFilesResponse.new instead')
  static DownloadPendingFilesResponse create() => DownloadPendingFilesResponse._();
  static $pb.GeneratedMessage $_createMessage() => DownloadPendingFilesResponse._();
  @$core.override
  DownloadPendingFilesResponse createEmptyInstance() => DownloadPendingFilesResponse._();
  @$core.pragma('dart2js:noInline')
  static DownloadPendingFilesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DownloadPendingFilesResponse>(DownloadPendingFilesResponse.$_createMessage);
  static DownloadPendingFilesResponse? _defaultInstance;

  /// Number of files successfully downloaded
  @$pb.TagNumber(1)
  $core.int get downloadedCount => $_getIZ(0);
  @$pb.TagNumber(1)
  set downloadedCount($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDownloadedCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearDownloadedCount() => $_clearField(1);

  /// Number of files that failed to download
  @$pb.TagNumber(2)
  $core.int get failedCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set failedCount($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFailedCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearFailedCount() => $_clearField(2);
}

/// Local file info
class BitDriveFile extends $pb.GeneratedMessage {
  factory BitDriveFile({
    $fixnum.Int64? id,
    $core.String? filename,
    $core.String? fileType,
    $fixnum.Int64? sizeBytes,
    $core.bool? encrypted,
    $core.String? txid,
    $core.int? timestamp,
    $0.Timestamp? createdAt,
  }) {
    final result = BitDriveFile._();
    if (id != null) result.id = id;
    if (filename != null) result.filename = filename;
    if (fileType != null) result.fileType = fileType;
    if (sizeBytes != null) result.sizeBytes = sizeBytes;
    if (encrypted != null) result.encrypted = encrypted;
    if (txid != null) result.txid = txid;
    if (timestamp != null) result.timestamp = timestamp;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  BitDriveFile._();

  factory BitDriveFile.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BitDriveFile()..mergeFromBuffer(data, registry);
  factory BitDriveFile.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BitDriveFile()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BitDriveFile',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'),
      createEmptyInstance: BitDriveFile.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'filename')
    ..aOS(3, _omitFieldNames ? '' : 'fileType')
    ..aInt64(4, _omitFieldNames ? '' : 'sizeBytes')
    ..aOB(5, _omitFieldNames ? '' : 'encrypted')
    ..aOS(6, _omitFieldNames ? '' : 'txid')
    ..aI(7, _omitFieldNames ? '' : 'timestamp', fieldType: $pb.PbFieldType.OU3)
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'createdAt', subBuilder: $0.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BitDriveFile clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BitDriveFile copyWith(void Function(BitDriveFile) updates) =>
      super.copyWith((message) => updates(message as BitDriveFile)) as BitDriveFile;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BitDriveFile() / BitDriveFile.new instead')
  static BitDriveFile create() => BitDriveFile._();
  static $pb.GeneratedMessage $_createMessage() => BitDriveFile._();
  @$core.override
  BitDriveFile createEmptyInstance() => BitDriveFile._();
  @$core.pragma('dart2js:noInline')
  static BitDriveFile getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BitDriveFile>(BitDriveFile.$_createMessage);
  static BitDriveFile? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get filename => $_getSZ(1);
  @$pb.TagNumber(2)
  set filename($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFilename() => $_has(1);
  @$pb.TagNumber(2)
  void clearFilename() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fileType => $_getSZ(2);
  @$pb.TagNumber(3)
  set fileType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFileType() => $_has(2);
  @$pb.TagNumber(3)
  void clearFileType() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get sizeBytes => $_getI64(3);
  @$pb.TagNumber(4)
  set sizeBytes($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSizeBytes() => $_has(3);
  @$pb.TagNumber(4)
  void clearSizeBytes() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get encrypted => $_getBF(4);
  @$pb.TagNumber(5)
  set encrypted($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEncrypted() => $_has(4);
  @$pb.TagNumber(5)
  void clearEncrypted() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get txid => $_getSZ(5);
  @$pb.TagNumber(6)
  set txid($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTxid() => $_has(5);
  @$pb.TagNumber(6)
  void clearTxid() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get timestamp => $_getIZ(6);
  @$pb.TagNumber(7)
  set timestamp($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTimestamp() => $_has(6);
  @$pb.TagNumber(7)
  void clearTimestamp() => $_clearField(7);

  @$pb.TagNumber(8)
  $0.Timestamp get createdAt => $_getN(7);
  @$pb.TagNumber(8)
  set createdAt($0.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasCreatedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearCreatedAt() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureCreatedAt() => $_ensure(7);
}

class ListFilesResponse extends $pb.GeneratedMessage {
  factory ListFilesResponse({
    $core.Iterable<BitDriveFile>? files,
  }) {
    final result = ListFilesResponse._();
    if (files != null) result.files.addAll(files);
    return result;
  }

  ListFilesResponse._();

  factory ListFilesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListFilesResponse()..mergeFromBuffer(data, registry);
  factory ListFilesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListFilesResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListFilesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'),
      createEmptyInstance: ListFilesResponse.$_createMessage)
    ..pPM<BitDriveFile>(1, _omitFieldNames ? '' : 'files', subBuilder: BitDriveFile.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFilesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListFilesResponse copyWith(void Function(ListFilesResponse) updates) =>
      super.copyWith((message) => updates(message as ListFilesResponse)) as ListFilesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListFilesResponse() / ListFilesResponse.new instead')
  static ListFilesResponse create() => ListFilesResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListFilesResponse._();
  @$core.override
  ListFilesResponse createEmptyInstance() => ListFilesResponse._();
  @$core.pragma('dart2js:noInline')
  static ListFilesResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListFilesResponse>(ListFilesResponse.$_createMessage);
  static ListFilesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<BitDriveFile> get files => $_getList(0);
}

class GetFileRequest extends $pb.GeneratedMessage {
  factory GetFileRequest({
    $fixnum.Int64? id,
    $core.String? txid,
  }) {
    final result = GetFileRequest._();
    if (id != null) result.id = id;
    if (txid != null) result.txid = txid;
    return result;
  }

  GetFileRequest._();

  factory GetFileRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetFileRequest()..mergeFromBuffer(data, registry);
  factory GetFileRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetFileRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetFileRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'),
      createEmptyInstance: GetFileRequest.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFileRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFileRequest copyWith(void Function(GetFileRequest) updates) =>
      super.copyWith((message) => updates(message as GetFileRequest)) as GetFileRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetFileRequest() / GetFileRequest.new instead')
  static GetFileRequest create() => GetFileRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetFileRequest._();
  @$core.override
  GetFileRequest createEmptyInstance() => GetFileRequest._();
  @$core.pragma('dart2js:noInline')
  static GetFileRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetFileRequest>(GetFileRequest.$_createMessage);
  static GetFileRequest? _defaultInstance;

  /// Either id or txid
  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get txid => $_getSZ(1);
  @$pb.TagNumber(2)
  set txid($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearTxid() => $_clearField(2);
}

class GetFileResponse extends $pb.GeneratedMessage {
  factory GetFileResponse({
    BitDriveFile? file,
    $core.List<$core.int>? content,
  }) {
    final result = GetFileResponse._();
    if (file != null) result.file = file;
    if (content != null) result.content = content;
    return result;
  }

  GetFileResponse._();

  factory GetFileResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetFileResponse()..mergeFromBuffer(data, registry);
  factory GetFileResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetFileResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetFileResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'),
      createEmptyInstance: GetFileResponse.$_createMessage)
    ..aOM<BitDriveFile>(1, _omitFieldNames ? '' : 'file', subBuilder: BitDriveFile.$_createMessage)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'content', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFileResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetFileResponse copyWith(void Function(GetFileResponse) updates) =>
      super.copyWith((message) => updates(message as GetFileResponse)) as GetFileResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetFileResponse() / GetFileResponse.new instead')
  static GetFileResponse create() => GetFileResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetFileResponse._();
  @$core.override
  GetFileResponse createEmptyInstance() => GetFileResponse._();
  @$core.pragma('dart2js:noInline')
  static GetFileResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetFileResponse>(GetFileResponse.$_createMessage);
  static GetFileResponse? _defaultInstance;

  @$pb.TagNumber(1)
  BitDriveFile get file => $_getN(0);
  @$pb.TagNumber(1)
  set file(BitDriveFile value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasFile() => $_has(0);
  @$pb.TagNumber(1)
  void clearFile() => $_clearField(1);
  @$pb.TagNumber(1)
  BitDriveFile ensureFile() => $_ensure(0);

  /// Full file content
  @$pb.TagNumber(2)
  $core.List<$core.int> get content => $_getN(1);
  @$pb.TagNumber(2)
  set content($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasContent() => $_has(1);
  @$pb.TagNumber(2)
  void clearContent() => $_clearField(2);
}

class DeleteFileRequest extends $pb.GeneratedMessage {
  factory DeleteFileRequest({
    $fixnum.Int64? id,
  }) {
    final result = DeleteFileRequest._();
    if (id != null) result.id = id;
    return result;
  }

  DeleteFileRequest._();

  factory DeleteFileRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteFileRequest()..mergeFromBuffer(data, registry);
  factory DeleteFileRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteFileRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteFileRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'),
      createEmptyInstance: DeleteFileRequest.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteFileRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteFileRequest copyWith(void Function(DeleteFileRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteFileRequest)) as DeleteFileRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DeleteFileRequest() / DeleteFileRequest.new instead')
  static DeleteFileRequest create() => DeleteFileRequest._();
  static $pb.GeneratedMessage $_createMessage() => DeleteFileRequest._();
  @$core.override
  DeleteFileRequest createEmptyInstance() => DeleteFileRequest._();
  @$core.pragma('dart2js:noInline')
  static DeleteFileRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteFileRequest>(DeleteFileRequest.$_createMessage);
  static DeleteFileRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

/// Multisig data storage
class StoreMultisigDataRequest extends $pb.GeneratedMessage {
  factory StoreMultisigDataRequest({
    $core.List<$core.int>? jsonData,
    $core.bool? encrypt,
    $fixnum.Int64? feeSatPerVbyte,
  }) {
    final result = StoreMultisigDataRequest._();
    if (jsonData != null) result.jsonData = jsonData;
    if (encrypt != null) result.encrypt = encrypt;
    if (feeSatPerVbyte != null) result.feeSatPerVbyte = feeSatPerVbyte;
    return result;
  }

  StoreMultisigDataRequest._();

  factory StoreMultisigDataRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StoreMultisigDataRequest()..mergeFromBuffer(data, registry);
  factory StoreMultisigDataRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StoreMultisigDataRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StoreMultisigDataRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'),
      createEmptyInstance: StoreMultisigDataRequest.$_createMessage)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'jsonData', $pb.PbFieldType.OY)
    ..aOB(2, _omitFieldNames ? '' : 'encrypt')
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'feeSatPerVbyte', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StoreMultisigDataRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StoreMultisigDataRequest copyWith(void Function(StoreMultisigDataRequest) updates) =>
      super.copyWith((message) => updates(message as StoreMultisigDataRequest)) as StoreMultisigDataRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StoreMultisigDataRequest() / StoreMultisigDataRequest.new instead')
  static StoreMultisigDataRequest create() => StoreMultisigDataRequest._();
  static $pb.GeneratedMessage $_createMessage() => StoreMultisigDataRequest._();
  @$core.override
  StoreMultisigDataRequest createEmptyInstance() => StoreMultisigDataRequest._();
  @$core.pragma('dart2js:noInline')
  static StoreMultisigDataRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StoreMultisigDataRequest>(StoreMultisigDataRequest.$_createMessage);
  static StoreMultisigDataRequest? _defaultInstance;

  /// Multisig group data as JSON
  @$pb.TagNumber(1)
  $core.List<$core.int> get jsonData => $_getN(0);
  @$pb.TagNumber(1)
  set jsonData($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasJsonData() => $_has(0);
  @$pb.TagNumber(1)
  void clearJsonData() => $_clearField(1);

  /// Whether to encrypt the data
  @$pb.TagNumber(2)
  $core.bool get encrypt => $_getBF(1);
  @$pb.TagNumber(2)
  set encrypt($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEncrypt() => $_has(1);
  @$pb.TagNumber(2)
  void clearEncrypt() => $_clearField(2);

  /// Fee in satoshis per vbyte
  @$pb.TagNumber(3)
  $fixnum.Int64 get feeSatPerVbyte => $_getI64(2);
  @$pb.TagNumber(3)
  set feeSatPerVbyte($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFeeSatPerVbyte() => $_has(2);
  @$pb.TagNumber(3)
  void clearFeeSatPerVbyte() => $_clearField(3);
}

class StoreMultisigDataResponse extends $pb.GeneratedMessage {
  factory StoreMultisigDataResponse({
    $core.String? txid,
  }) {
    final result = StoreMultisigDataResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  StoreMultisigDataResponse._();

  factory StoreMultisigDataResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StoreMultisigDataResponse()..mergeFromBuffer(data, registry);
  factory StoreMultisigDataResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StoreMultisigDataResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StoreMultisigDataResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'),
      createEmptyInstance: StoreMultisigDataResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StoreMultisigDataResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StoreMultisigDataResponse copyWith(void Function(StoreMultisigDataResponse) updates) =>
      super.copyWith((message) => updates(message as StoreMultisigDataResponse)) as StoreMultisigDataResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StoreMultisigDataResponse() / StoreMultisigDataResponse.new instead')
  static StoreMultisigDataResponse create() => StoreMultisigDataResponse._();
  static $pb.GeneratedMessage $_createMessage() => StoreMultisigDataResponse._();
  @$core.override
  StoreMultisigDataResponse createEmptyInstance() => StoreMultisigDataResponse._();
  @$core.pragma('dart2js:noInline')
  static StoreMultisigDataResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<StoreMultisigDataResponse>(StoreMultisigDataResponse.$_createMessage);
  static StoreMultisigDataResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class GetBitdriveDirResponse extends $pb.GeneratedMessage {
  factory GetBitdriveDirResponse({
    $core.String? path,
  }) {
    final result = GetBitdriveDirResponse._();
    if (path != null) result.path = path;
    return result;
  }

  GetBitdriveDirResponse._();

  factory GetBitdriveDirResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBitdriveDirResponse()..mergeFromBuffer(data, registry);
  factory GetBitdriveDirResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBitdriveDirResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBitdriveDirResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'),
      createEmptyInstance: GetBitdriveDirResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'path')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBitdriveDirResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBitdriveDirResponse copyWith(void Function(GetBitdriveDirResponse) updates) =>
      super.copyWith((message) => updates(message as GetBitdriveDirResponse)) as GetBitdriveDirResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBitdriveDirResponse() / GetBitdriveDirResponse.new instead')
  static GetBitdriveDirResponse create() => GetBitdriveDirResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetBitdriveDirResponse._();
  @$core.override
  GetBitdriveDirResponse createEmptyInstance() => GetBitdriveDirResponse._();
  @$core.pragma('dart2js:noInline')
  static GetBitdriveDirResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBitdriveDirResponse>(GetBitdriveDirResponse.$_createMessage);
  static GetBitdriveDirResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get path => $_getSZ(0);
  @$pb.TagNumber(1)
  set path($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPath() => $_has(0);
  @$pb.TagNumber(1)
  void clearPath() => $_clearField(1);
}

class BitDriveServiceApi {
  final $pb.RpcClient _client;

  BitDriveServiceApi(this._client);

  /// Store file/content to blockchain with optional encryption
  $async.Future<StoreFileResponse> storeFile($pb.ClientContext? ctx, StoreFileRequest request) =>
      _client.invoke<StoreFileResponse>(ctx, 'BitDriveService', 'StoreFile', request, StoreFileResponse());

  /// Retrieve content from blockchain by txid
  $async.Future<RetrieveContentResponse> retrieveContent($pb.ClientContext? ctx, RetrieveContentRequest request) =>
      _client.invoke<RetrieveContentResponse>(
          ctx, 'BitDriveService', 'RetrieveContent', request, RetrieveContentResponse());

  /// Scan for files in wallet transactions
  $async.Future<ScanForFilesResponse> scanForFiles($pb.ClientContext? ctx, $1.Empty request) =>
      _client.invoke<ScanForFilesResponse>(ctx, 'BitDriveService', 'ScanForFiles', request, ScanForFilesResponse());

  /// Download/restore pending files
  $async.Future<DownloadPendingFilesResponse> downloadPendingFiles($pb.ClientContext? ctx, $1.Empty request) =>
      _client.invoke<DownloadPendingFilesResponse>(
          ctx, 'BitDriveService', 'DownloadPendingFiles', request, DownloadPendingFilesResponse());

  /// List stored files from local storage
  $async.Future<ListFilesResponse> listFiles($pb.ClientContext? ctx, $1.Empty request) =>
      _client.invoke<ListFilesResponse>(ctx, 'BitDriveService', 'ListFiles', request, ListFilesResponse());

  /// Get file details
  $async.Future<GetFileResponse> getFile($pb.ClientContext? ctx, GetFileRequest request) =>
      _client.invoke<GetFileResponse>(ctx, 'BitDriveService', 'GetFile', request, GetFileResponse());

  /// Delete local file (does not affect blockchain)
  $async.Future<$1.Empty> deleteFile($pb.ClientContext? ctx, DeleteFileRequest request) =>
      _client.invoke<$1.Empty>(ctx, 'BitDriveService', 'DeleteFile', request, $1.Empty());

  /// Store multisig group data on blockchain
  $async.Future<StoreMultisigDataResponse> storeMultisigData(
          $pb.ClientContext? ctx, StoreMultisigDataRequest request) =>
      _client.invoke<StoreMultisigDataResponse>(
          ctx, 'BitDriveService', 'StoreMultisigData', request, StoreMultisigDataResponse());

  /// Wipe all local BitDrive data
  $async.Future<$1.Empty> wipeData($pb.ClientContext? ctx, $1.Empty request) =>
      _client.invoke<$1.Empty>(ctx, 'BitDriveService', 'WipeData', request, $1.Empty());

  /// Get the BitDrive data directory path
  $async.Future<GetBitdriveDirResponse> getBitdriveDir($pb.ClientContext? ctx, $1.Empty request) => _client
      .invoke<GetBitdriveDirResponse>(ctx, 'BitDriveService', 'GetBitdriveDir', request, GetBitdriveDirResponse());

  /// Open the BitDrive data directory in the OS file manager
  $async.Future<$1.Empty> openBitdriveDir($pb.ClientContext? ctx, $1.Empty request) =>
      _client.invoke<$1.Empty>(ctx, 'BitDriveService', 'OpenBitdriveDir', request, $1.Empty());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
