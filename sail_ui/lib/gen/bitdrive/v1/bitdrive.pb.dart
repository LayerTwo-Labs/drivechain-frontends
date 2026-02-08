//
//  Generated code. Do not modify.
//  source: bitdrive/v1/bitdrive.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import '../../google/protobuf/empty.pb.dart' as $1;
import '../../google/protobuf/timestamp.pb.dart' as $0;

/// File metadata stored in OP_RETURN (9 bytes total)
class BitDriveMetadata extends $pb.GeneratedMessage {
  factory BitDriveMetadata({
    $core.int? flags,
    $core.int? timestamp,
    $core.String? fileType,
  }) {
    final $result = create();
    if (flags != null) {
      $result.flags = flags;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    if (fileType != null) {
      $result.fileType = fileType;
    }
    return $result;
  }
  BitDriveMetadata._() : super();
  factory BitDriveMetadata.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BitDriveMetadata.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BitDriveMetadata', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'flags', $pb.PbFieldType.OU3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'timestamp', $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'fileType')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BitDriveMetadata clone() => BitDriveMetadata()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BitDriveMetadata copyWith(void Function(BitDriveMetadata) updates) => super.copyWith((message) => updates(message as BitDriveMetadata)) as BitDriveMetadata;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BitDriveMetadata create() => BitDriveMetadata._();
  BitDriveMetadata createEmptyInstance() => create();
  static $pb.PbList<BitDriveMetadata> createRepeated() => $pb.PbList<BitDriveMetadata>();
  @$core.pragma('dart2js:noInline')
  static BitDriveMetadata getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BitDriveMetadata>(create);
  static BitDriveMetadata? _defaultInstance;

  /// Flags (1 byte): bit 0 = encrypted, bit 1 = multisig
  @$pb.TagNumber(1)
  $core.int get flags => $_getIZ(0);
  @$pb.TagNumber(1)
  set flags($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFlags() => $_has(0);
  @$pb.TagNumber(1)
  void clearFlags() => clearField(1);

  /// Unix timestamp (4 bytes, big endian)
  @$pb.TagNumber(2)
  $core.int get timestamp => $_getIZ(1);
  @$pb.TagNumber(2)
  set timestamp($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTimestamp() => $_has(1);
  @$pb.TagNumber(2)
  void clearTimestamp() => clearField(2);

  /// File type extension (4 bytes ASCII, padded with spaces)
  @$pb.TagNumber(3)
  $core.String get fileType => $_getSZ(2);
  @$pb.TagNumber(3)
  set fileType($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFileType() => $_has(2);
  @$pb.TagNumber(3)
  void clearFileType() => clearField(3);
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
    final $result = create();
    if (content != null) {
      $result.content = content;
    }
    if (filename != null) {
      $result.filename = filename;
    }
    if (mimeType != null) {
      $result.mimeType = mimeType;
    }
    if (encrypt != null) {
      $result.encrypt = encrypt;
    }
    if (feeSatPerVbyte != null) {
      $result.feeSatPerVbyte = feeSatPerVbyte;
    }
    return $result;
  }
  StoreFileRequest._() : super();
  factory StoreFileRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StoreFileRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StoreFileRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'content', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'filename')
    ..aOS(3, _omitFieldNames ? '' : 'mimeType')
    ..aOB(4, _omitFieldNames ? '' : 'encrypt')
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'feeSatPerVbyte', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StoreFileRequest clone() => StoreFileRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StoreFileRequest copyWith(void Function(StoreFileRequest) updates) => super.copyWith((message) => updates(message as StoreFileRequest)) as StoreFileRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StoreFileRequest create() => StoreFileRequest._();
  StoreFileRequest createEmptyInstance() => create();
  static $pb.PbList<StoreFileRequest> createRepeated() => $pb.PbList<StoreFileRequest>();
  @$core.pragma('dart2js:noInline')
  static StoreFileRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StoreFileRequest>(create);
  static StoreFileRequest? _defaultInstance;

  /// Raw file content (max 1MB)
  @$pb.TagNumber(1)
  $core.List<$core.int> get content => $_getN(0);
  @$pb.TagNumber(1)
  set content($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearContent() => clearField(1);

  /// Optional filename
  @$pb.TagNumber(2)
  $core.String get filename => $_getSZ(1);
  @$pb.TagNumber(2)
  set filename($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFilename() => $_has(1);
  @$pb.TagNumber(2)
  void clearFilename() => clearField(2);

  /// Optional MIME type
  @$pb.TagNumber(3)
  $core.String get mimeType => $_getSZ(2);
  @$pb.TagNumber(3)
  set mimeType($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasMimeType() => $_has(2);
  @$pb.TagNumber(3)
  void clearMimeType() => clearField(3);

  /// Whether to encrypt the content
  @$pb.TagNumber(4)
  $core.bool get encrypt => $_getBF(3);
  @$pb.TagNumber(4)
  set encrypt($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasEncrypt() => $_has(3);
  @$pb.TagNumber(4)
  void clearEncrypt() => clearField(4);

  /// Fee in satoshis per vbyte
  @$pb.TagNumber(5)
  $fixnum.Int64 get feeSatPerVbyte => $_getI64(4);
  @$pb.TagNumber(5)
  set feeSatPerVbyte($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasFeeSatPerVbyte() => $_has(4);
  @$pb.TagNumber(5)
  void clearFeeSatPerVbyte() => clearField(5);
}

class StoreFileResponse extends $pb.GeneratedMessage {
  factory StoreFileResponse({
    $core.String? txid,
    $core.String? fileType,
    $core.bool? encrypted,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (fileType != null) {
      $result.fileType = fileType;
    }
    if (encrypted != null) {
      $result.encrypted = encrypted;
    }
    return $result;
  }
  StoreFileResponse._() : super();
  factory StoreFileResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StoreFileResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StoreFileResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aOS(2, _omitFieldNames ? '' : 'fileType')
    ..aOB(3, _omitFieldNames ? '' : 'encrypted')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StoreFileResponse clone() => StoreFileResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StoreFileResponse copyWith(void Function(StoreFileResponse) updates) => super.copyWith((message) => updates(message as StoreFileResponse)) as StoreFileResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StoreFileResponse create() => StoreFileResponse._();
  StoreFileResponse createEmptyInstance() => create();
  static $pb.PbList<StoreFileResponse> createRepeated() => $pb.PbList<StoreFileResponse>();
  @$core.pragma('dart2js:noInline')
  static StoreFileResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StoreFileResponse>(create);
  static StoreFileResponse? _defaultInstance;

  /// Transaction ID of the stored content
  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  /// Detected or assigned file type
  @$pb.TagNumber(2)
  $core.String get fileType => $_getSZ(1);
  @$pb.TagNumber(2)
  set fileType($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFileType() => $_has(1);
  @$pb.TagNumber(2)
  void clearFileType() => clearField(2);

  /// Whether content was encrypted
  @$pb.TagNumber(3)
  $core.bool get encrypted => $_getBF(2);
  @$pb.TagNumber(3)
  set encrypted($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasEncrypted() => $_has(2);
  @$pb.TagNumber(3)
  void clearEncrypted() => clearField(3);
}

/// Request to retrieve content by txid
class RetrieveContentRequest extends $pb.GeneratedMessage {
  factory RetrieveContentRequest({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  RetrieveContentRequest._() : super();
  factory RetrieveContentRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RetrieveContentRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RetrieveContentRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RetrieveContentRequest clone() => RetrieveContentRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RetrieveContentRequest copyWith(void Function(RetrieveContentRequest) updates) => super.copyWith((message) => updates(message as RetrieveContentRequest)) as RetrieveContentRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RetrieveContentRequest create() => RetrieveContentRequest._();
  RetrieveContentRequest createEmptyInstance() => create();
  static $pb.PbList<RetrieveContentRequest> createRepeated() => $pb.PbList<RetrieveContentRequest>();
  @$core.pragma('dart2js:noInline')
  static RetrieveContentRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RetrieveContentRequest>(create);
  static RetrieveContentRequest? _defaultInstance;

  /// Transaction ID containing the OP_RETURN data
  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class RetrieveContentResponse extends $pb.GeneratedMessage {
  factory RetrieveContentResponse({
    $core.List<$core.int>? content,
    $core.String? fileType,
    $core.bool? encrypted,
    $core.int? timestamp,
  }) {
    final $result = create();
    if (content != null) {
      $result.content = content;
    }
    if (fileType != null) {
      $result.fileType = fileType;
    }
    if (encrypted != null) {
      $result.encrypted = encrypted;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    return $result;
  }
  RetrieveContentResponse._() : super();
  factory RetrieveContentResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RetrieveContentResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RetrieveContentResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'content', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'fileType')
    ..aOB(3, _omitFieldNames ? '' : 'encrypted')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'timestamp', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RetrieveContentResponse clone() => RetrieveContentResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RetrieveContentResponse copyWith(void Function(RetrieveContentResponse) updates) => super.copyWith((message) => updates(message as RetrieveContentResponse)) as RetrieveContentResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RetrieveContentResponse create() => RetrieveContentResponse._();
  RetrieveContentResponse createEmptyInstance() => create();
  static $pb.PbList<RetrieveContentResponse> createRepeated() => $pb.PbList<RetrieveContentResponse>();
  @$core.pragma('dart2js:noInline')
  static RetrieveContentResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RetrieveContentResponse>(create);
  static RetrieveContentResponse? _defaultInstance;

  /// Decrypted/raw file content
  @$pb.TagNumber(1)
  $core.List<$core.int> get content => $_getN(0);
  @$pb.TagNumber(1)
  set content($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearContent() => clearField(1);

  /// File type
  @$pb.TagNumber(2)
  $core.String get fileType => $_getSZ(1);
  @$pb.TagNumber(2)
  set fileType($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFileType() => $_has(1);
  @$pb.TagNumber(2)
  void clearFileType() => clearField(2);

  /// Whether content was encrypted
  @$pb.TagNumber(3)
  $core.bool get encrypted => $_getBF(2);
  @$pb.TagNumber(3)
  set encrypted($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasEncrypted() => $_has(2);
  @$pb.TagNumber(3)
  void clearEncrypted() => clearField(3);

  /// Timestamp
  @$pb.TagNumber(4)
  $core.int get timestamp => $_getIZ(3);
  @$pb.TagNumber(4)
  set timestamp($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTimestamp() => $_has(3);
  @$pb.TagNumber(4)
  void clearTimestamp() => clearField(4);
}

/// Scan results
class ScanForFilesResponse extends $pb.GeneratedMessage {
  factory ScanForFilesResponse({
    $core.Iterable<PendingFile>? pendingFiles,
    $core.int? totalScanned,
  }) {
    final $result = create();
    if (pendingFiles != null) {
      $result.pendingFiles.addAll(pendingFiles);
    }
    if (totalScanned != null) {
      $result.totalScanned = totalScanned;
    }
    return $result;
  }
  ScanForFilesResponse._() : super();
  factory ScanForFilesResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ScanForFilesResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ScanForFilesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'), createEmptyInstance: create)
    ..pc<PendingFile>(1, _omitFieldNames ? '' : 'pendingFiles', $pb.PbFieldType.PM, subBuilder: PendingFile.create)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'totalScanned', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ScanForFilesResponse clone() => ScanForFilesResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ScanForFilesResponse copyWith(void Function(ScanForFilesResponse) updates) => super.copyWith((message) => updates(message as ScanForFilesResponse)) as ScanForFilesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScanForFilesResponse create() => ScanForFilesResponse._();
  ScanForFilesResponse createEmptyInstance() => create();
  static $pb.PbList<ScanForFilesResponse> createRepeated() => $pb.PbList<ScanForFilesResponse>();
  @$core.pragma('dart2js:noInline')
  static ScanForFilesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ScanForFilesResponse>(create);
  static ScanForFilesResponse? _defaultInstance;

  /// Files found that are not yet downloaded
  @$pb.TagNumber(1)
  $core.List<PendingFile> get pendingFiles => $_getList(0);

  /// Total files scanned
  @$pb.TagNumber(2)
  $core.int get totalScanned => $_getIZ(1);
  @$pb.TagNumber(2)
  set totalScanned($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTotalScanned() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalScanned() => clearField(2);
}

class PendingFile extends $pb.GeneratedMessage {
  factory PendingFile({
    $core.String? txid,
    $core.bool? encrypted,
    $core.int? timestamp,
    $core.String? fileType,
    $core.String? filename,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (encrypted != null) {
      $result.encrypted = encrypted;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    if (fileType != null) {
      $result.fileType = fileType;
    }
    if (filename != null) {
      $result.filename = filename;
    }
    return $result;
  }
  PendingFile._() : super();
  factory PendingFile.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PendingFile.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PendingFile', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aOB(2, _omitFieldNames ? '' : 'encrypted')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'timestamp', $pb.PbFieldType.OU3)
    ..aOS(4, _omitFieldNames ? '' : 'fileType')
    ..aOS(5, _omitFieldNames ? '' : 'filename')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PendingFile clone() => PendingFile()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PendingFile copyWith(void Function(PendingFile) updates) => super.copyWith((message) => updates(message as PendingFile)) as PendingFile;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PendingFile create() => PendingFile._();
  PendingFile createEmptyInstance() => create();
  static $pb.PbList<PendingFile> createRepeated() => $pb.PbList<PendingFile>();
  @$core.pragma('dart2js:noInline')
  static PendingFile getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PendingFile>(create);
  static PendingFile? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get encrypted => $_getBF(1);
  @$pb.TagNumber(2)
  set encrypted($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEncrypted() => $_has(1);
  @$pb.TagNumber(2)
  void clearEncrypted() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get timestamp => $_getIZ(2);
  @$pb.TagNumber(3)
  set timestamp($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get fileType => $_getSZ(3);
  @$pb.TagNumber(4)
  set fileType($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFileType() => $_has(3);
  @$pb.TagNumber(4)
  void clearFileType() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get filename => $_getSZ(4);
  @$pb.TagNumber(5)
  set filename($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasFilename() => $_has(4);
  @$pb.TagNumber(5)
  void clearFilename() => clearField(5);
}

class DownloadPendingFilesResponse extends $pb.GeneratedMessage {
  factory DownloadPendingFilesResponse({
    $core.int? downloadedCount,
    $core.int? failedCount,
  }) {
    final $result = create();
    if (downloadedCount != null) {
      $result.downloadedCount = downloadedCount;
    }
    if (failedCount != null) {
      $result.failedCount = failedCount;
    }
    return $result;
  }
  DownloadPendingFilesResponse._() : super();
  factory DownloadPendingFilesResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DownloadPendingFilesResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DownloadPendingFilesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'downloadedCount', $pb.PbFieldType.OU3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'failedCount', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DownloadPendingFilesResponse clone() => DownloadPendingFilesResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DownloadPendingFilesResponse copyWith(void Function(DownloadPendingFilesResponse) updates) => super.copyWith((message) => updates(message as DownloadPendingFilesResponse)) as DownloadPendingFilesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DownloadPendingFilesResponse create() => DownloadPendingFilesResponse._();
  DownloadPendingFilesResponse createEmptyInstance() => create();
  static $pb.PbList<DownloadPendingFilesResponse> createRepeated() => $pb.PbList<DownloadPendingFilesResponse>();
  @$core.pragma('dart2js:noInline')
  static DownloadPendingFilesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DownloadPendingFilesResponse>(create);
  static DownloadPendingFilesResponse? _defaultInstance;

  /// Number of files successfully downloaded
  @$pb.TagNumber(1)
  $core.int get downloadedCount => $_getIZ(0);
  @$pb.TagNumber(1)
  set downloadedCount($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDownloadedCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearDownloadedCount() => clearField(1);

  /// Number of files that failed to download
  @$pb.TagNumber(2)
  $core.int get failedCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set failedCount($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFailedCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearFailedCount() => clearField(2);
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
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (filename != null) {
      $result.filename = filename;
    }
    if (fileType != null) {
      $result.fileType = fileType;
    }
    if (sizeBytes != null) {
      $result.sizeBytes = sizeBytes;
    }
    if (encrypted != null) {
      $result.encrypted = encrypted;
    }
    if (txid != null) {
      $result.txid = txid;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    return $result;
  }
  BitDriveFile._() : super();
  factory BitDriveFile.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BitDriveFile.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BitDriveFile', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'filename')
    ..aOS(3, _omitFieldNames ? '' : 'fileType')
    ..aInt64(4, _omitFieldNames ? '' : 'sizeBytes')
    ..aOB(5, _omitFieldNames ? '' : 'encrypted')
    ..aOS(6, _omitFieldNames ? '' : 'txid')
    ..a<$core.int>(7, _omitFieldNames ? '' : 'timestamp', $pb.PbFieldType.OU3)
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'createdAt', subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BitDriveFile clone() => BitDriveFile()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BitDriveFile copyWith(void Function(BitDriveFile) updates) => super.copyWith((message) => updates(message as BitDriveFile)) as BitDriveFile;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BitDriveFile create() => BitDriveFile._();
  BitDriveFile createEmptyInstance() => create();
  static $pb.PbList<BitDriveFile> createRepeated() => $pb.PbList<BitDriveFile>();
  @$core.pragma('dart2js:noInline')
  static BitDriveFile getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BitDriveFile>(create);
  static BitDriveFile? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get filename => $_getSZ(1);
  @$pb.TagNumber(2)
  set filename($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFilename() => $_has(1);
  @$pb.TagNumber(2)
  void clearFilename() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get fileType => $_getSZ(2);
  @$pb.TagNumber(3)
  set fileType($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFileType() => $_has(2);
  @$pb.TagNumber(3)
  void clearFileType() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get sizeBytes => $_getI64(3);
  @$pb.TagNumber(4)
  set sizeBytes($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSizeBytes() => $_has(3);
  @$pb.TagNumber(4)
  void clearSizeBytes() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get encrypted => $_getBF(4);
  @$pb.TagNumber(5)
  set encrypted($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasEncrypted() => $_has(4);
  @$pb.TagNumber(5)
  void clearEncrypted() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get txid => $_getSZ(5);
  @$pb.TagNumber(6)
  set txid($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTxid() => $_has(5);
  @$pb.TagNumber(6)
  void clearTxid() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get timestamp => $_getIZ(6);
  @$pb.TagNumber(7)
  set timestamp($core.int v) { $_setUnsignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasTimestamp() => $_has(6);
  @$pb.TagNumber(7)
  void clearTimestamp() => clearField(7);

  @$pb.TagNumber(8)
  $0.Timestamp get createdAt => $_getN(7);
  @$pb.TagNumber(8)
  set createdAt($0.Timestamp v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasCreatedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearCreatedAt() => clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureCreatedAt() => $_ensure(7);
}

class ListFilesResponse extends $pb.GeneratedMessage {
  factory ListFilesResponse({
    $core.Iterable<BitDriveFile>? files,
  }) {
    final $result = create();
    if (files != null) {
      $result.files.addAll(files);
    }
    return $result;
  }
  ListFilesResponse._() : super();
  factory ListFilesResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListFilesResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListFilesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'), createEmptyInstance: create)
    ..pc<BitDriveFile>(1, _omitFieldNames ? '' : 'files', $pb.PbFieldType.PM, subBuilder: BitDriveFile.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListFilesResponse clone() => ListFilesResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListFilesResponse copyWith(void Function(ListFilesResponse) updates) => super.copyWith((message) => updates(message as ListFilesResponse)) as ListFilesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListFilesResponse create() => ListFilesResponse._();
  ListFilesResponse createEmptyInstance() => create();
  static $pb.PbList<ListFilesResponse> createRepeated() => $pb.PbList<ListFilesResponse>();
  @$core.pragma('dart2js:noInline')
  static ListFilesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListFilesResponse>(create);
  static ListFilesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<BitDriveFile> get files => $_getList(0);
}

class GetFileRequest extends $pb.GeneratedMessage {
  factory GetFileRequest({
    $fixnum.Int64? id,
    $core.String? txid,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  GetFileRequest._() : super();
  factory GetFileRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetFileRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetFileRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetFileRequest clone() => GetFileRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetFileRequest copyWith(void Function(GetFileRequest) updates) => super.copyWith((message) => updates(message as GetFileRequest)) as GetFileRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFileRequest create() => GetFileRequest._();
  GetFileRequest createEmptyInstance() => create();
  static $pb.PbList<GetFileRequest> createRepeated() => $pb.PbList<GetFileRequest>();
  @$core.pragma('dart2js:noInline')
  static GetFileRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetFileRequest>(create);
  static GetFileRequest? _defaultInstance;

  /// Either id or txid
  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get txid => $_getSZ(1);
  @$pb.TagNumber(2)
  set txid($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearTxid() => clearField(2);
}

class GetFileResponse extends $pb.GeneratedMessage {
  factory GetFileResponse({
    BitDriveFile? file,
    $core.List<$core.int>? content,
  }) {
    final $result = create();
    if (file != null) {
      $result.file = file;
    }
    if (content != null) {
      $result.content = content;
    }
    return $result;
  }
  GetFileResponse._() : super();
  factory GetFileResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetFileResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetFileResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'), createEmptyInstance: create)
    ..aOM<BitDriveFile>(1, _omitFieldNames ? '' : 'file', subBuilder: BitDriveFile.create)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'content', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetFileResponse clone() => GetFileResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetFileResponse copyWith(void Function(GetFileResponse) updates) => super.copyWith((message) => updates(message as GetFileResponse)) as GetFileResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetFileResponse create() => GetFileResponse._();
  GetFileResponse createEmptyInstance() => create();
  static $pb.PbList<GetFileResponse> createRepeated() => $pb.PbList<GetFileResponse>();
  @$core.pragma('dart2js:noInline')
  static GetFileResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetFileResponse>(create);
  static GetFileResponse? _defaultInstance;

  @$pb.TagNumber(1)
  BitDriveFile get file => $_getN(0);
  @$pb.TagNumber(1)
  set file(BitDriveFile v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasFile() => $_has(0);
  @$pb.TagNumber(1)
  void clearFile() => clearField(1);
  @$pb.TagNumber(1)
  BitDriveFile ensureFile() => $_ensure(0);

  /// Full file content
  @$pb.TagNumber(2)
  $core.List<$core.int> get content => $_getN(1);
  @$pb.TagNumber(2)
  set content($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasContent() => $_has(1);
  @$pb.TagNumber(2)
  void clearContent() => clearField(2);
}

class DeleteFileRequest extends $pb.GeneratedMessage {
  factory DeleteFileRequest({
    $fixnum.Int64? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  DeleteFileRequest._() : super();
  factory DeleteFileRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeleteFileRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteFileRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeleteFileRequest clone() => DeleteFileRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeleteFileRequest copyWith(void Function(DeleteFileRequest) updates) => super.copyWith((message) => updates(message as DeleteFileRequest)) as DeleteFileRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteFileRequest create() => DeleteFileRequest._();
  DeleteFileRequest createEmptyInstance() => create();
  static $pb.PbList<DeleteFileRequest> createRepeated() => $pb.PbList<DeleteFileRequest>();
  @$core.pragma('dart2js:noInline')
  static DeleteFileRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteFileRequest>(create);
  static DeleteFileRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

/// Multisig data storage
class StoreMultisigDataRequest extends $pb.GeneratedMessage {
  factory StoreMultisigDataRequest({
    $core.List<$core.int>? jsonData,
    $core.bool? encrypt,
    $fixnum.Int64? feeSatPerVbyte,
  }) {
    final $result = create();
    if (jsonData != null) {
      $result.jsonData = jsonData;
    }
    if (encrypt != null) {
      $result.encrypt = encrypt;
    }
    if (feeSatPerVbyte != null) {
      $result.feeSatPerVbyte = feeSatPerVbyte;
    }
    return $result;
  }
  StoreMultisigDataRequest._() : super();
  factory StoreMultisigDataRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StoreMultisigDataRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StoreMultisigDataRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'jsonData', $pb.PbFieldType.OY)
    ..aOB(2, _omitFieldNames ? '' : 'encrypt')
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'feeSatPerVbyte', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StoreMultisigDataRequest clone() => StoreMultisigDataRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StoreMultisigDataRequest copyWith(void Function(StoreMultisigDataRequest) updates) => super.copyWith((message) => updates(message as StoreMultisigDataRequest)) as StoreMultisigDataRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StoreMultisigDataRequest create() => StoreMultisigDataRequest._();
  StoreMultisigDataRequest createEmptyInstance() => create();
  static $pb.PbList<StoreMultisigDataRequest> createRepeated() => $pb.PbList<StoreMultisigDataRequest>();
  @$core.pragma('dart2js:noInline')
  static StoreMultisigDataRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StoreMultisigDataRequest>(create);
  static StoreMultisigDataRequest? _defaultInstance;

  /// Multisig group data as JSON
  @$pb.TagNumber(1)
  $core.List<$core.int> get jsonData => $_getN(0);
  @$pb.TagNumber(1)
  set jsonData($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasJsonData() => $_has(0);
  @$pb.TagNumber(1)
  void clearJsonData() => clearField(1);

  /// Whether to encrypt the data
  @$pb.TagNumber(2)
  $core.bool get encrypt => $_getBF(1);
  @$pb.TagNumber(2)
  set encrypt($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEncrypt() => $_has(1);
  @$pb.TagNumber(2)
  void clearEncrypt() => clearField(2);

  /// Fee in satoshis per vbyte
  @$pb.TagNumber(3)
  $fixnum.Int64 get feeSatPerVbyte => $_getI64(2);
  @$pb.TagNumber(3)
  set feeSatPerVbyte($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFeeSatPerVbyte() => $_has(2);
  @$pb.TagNumber(3)
  void clearFeeSatPerVbyte() => clearField(3);
}

class StoreMultisigDataResponse extends $pb.GeneratedMessage {
  factory StoreMultisigDataResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  StoreMultisigDataResponse._() : super();
  factory StoreMultisigDataResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StoreMultisigDataResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StoreMultisigDataResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitdrive.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StoreMultisigDataResponse clone() => StoreMultisigDataResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StoreMultisigDataResponse copyWith(void Function(StoreMultisigDataResponse) updates) => super.copyWith((message) => updates(message as StoreMultisigDataResponse)) as StoreMultisigDataResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StoreMultisigDataResponse create() => StoreMultisigDataResponse._();
  StoreMultisigDataResponse createEmptyInstance() => create();
  static $pb.PbList<StoreMultisigDataResponse> createRepeated() => $pb.PbList<StoreMultisigDataResponse>();
  @$core.pragma('dart2js:noInline')
  static StoreMultisigDataResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StoreMultisigDataResponse>(create);
  static StoreMultisigDataResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class BitDriveServiceApi {
  $pb.RpcClient _client;
  BitDriveServiceApi(this._client);

  $async.Future<StoreFileResponse> storeFile($pb.ClientContext? ctx, StoreFileRequest request) =>
    _client.invoke<StoreFileResponse>(ctx, 'BitDriveService', 'StoreFile', request, StoreFileResponse())
  ;
  $async.Future<RetrieveContentResponse> retrieveContent($pb.ClientContext? ctx, RetrieveContentRequest request) =>
    _client.invoke<RetrieveContentResponse>(ctx, 'BitDriveService', 'RetrieveContent', request, RetrieveContentResponse())
  ;
  $async.Future<ScanForFilesResponse> scanForFiles($pb.ClientContext? ctx, $1.Empty request) =>
    _client.invoke<ScanForFilesResponse>(ctx, 'BitDriveService', 'ScanForFiles', request, ScanForFilesResponse())
  ;
  $async.Future<DownloadPendingFilesResponse> downloadPendingFiles($pb.ClientContext? ctx, $1.Empty request) =>
    _client.invoke<DownloadPendingFilesResponse>(ctx, 'BitDriveService', 'DownloadPendingFiles', request, DownloadPendingFilesResponse())
  ;
  $async.Future<ListFilesResponse> listFiles($pb.ClientContext? ctx, $1.Empty request) =>
    _client.invoke<ListFilesResponse>(ctx, 'BitDriveService', 'ListFiles', request, ListFilesResponse())
  ;
  $async.Future<GetFileResponse> getFile($pb.ClientContext? ctx, GetFileRequest request) =>
    _client.invoke<GetFileResponse>(ctx, 'BitDriveService', 'GetFile', request, GetFileResponse())
  ;
  $async.Future<$1.Empty> deleteFile($pb.ClientContext? ctx, DeleteFileRequest request) =>
    _client.invoke<$1.Empty>(ctx, 'BitDriveService', 'DeleteFile', request, $1.Empty())
  ;
  $async.Future<StoreMultisigDataResponse> storeMultisigData($pb.ClientContext? ctx, StoreMultisigDataRequest request) =>
    _client.invoke<StoreMultisigDataResponse>(ctx, 'BitDriveService', 'StoreMultisigData', request, StoreMultisigDataResponse())
  ;
  $async.Future<$1.Empty> wipeData($pb.ClientContext? ctx, $1.Empty request) =>
    _client.invoke<$1.Empty>(ctx, 'BitDriveService', 'WipeData', request, $1.Empty())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
