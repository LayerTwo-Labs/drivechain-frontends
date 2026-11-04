// This is a generated file - do not edit.
//
// Generated from bbc/v1/bbc.proto.

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

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class GetBlockCountRequest extends $pb.GeneratedMessage {
  factory GetBlockCountRequest() => GetBlockCountRequest._();

  GetBlockCountRequest._();

  factory GetBlockCountRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockCountRequest()..mergeFromBuffer(data, registry);
  factory GetBlockCountRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockCountRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockCountRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bbc.v1'),
      createEmptyInstance: GetBlockCountRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockCountRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockCountRequest copyWith(void Function(GetBlockCountRequest) updates) =>
      super.copyWith((message) => updates(message as GetBlockCountRequest)) as GetBlockCountRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBlockCountRequest() / GetBlockCountRequest.new instead')
  static GetBlockCountRequest create() => GetBlockCountRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetBlockCountRequest._();
  @$core.override
  GetBlockCountRequest createEmptyInstance() => GetBlockCountRequest._();
  @$core.pragma('dart2js:noInline')
  static GetBlockCountRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBlockCountRequest>(GetBlockCountRequest.$_createMessage);
  static GetBlockCountRequest? _defaultInstance;
}

class GetBlockCountResponse extends $pb.GeneratedMessage {
  factory GetBlockCountResponse({
    $fixnum.Int64? count,
  }) {
    final result = GetBlockCountResponse._();
    if (count != null) result.count = count;
    return result;
  }

  GetBlockCountResponse._();

  factory GetBlockCountResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockCountResponse()..mergeFromBuffer(data, registry);
  factory GetBlockCountResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockCountResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockCountResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bbc.v1'),
      createEmptyInstance: GetBlockCountResponse.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'count')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockCountResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockCountResponse copyWith(void Function(GetBlockCountResponse) updates) =>
      super.copyWith((message) => updates(message as GetBlockCountResponse)) as GetBlockCountResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBlockCountResponse() / GetBlockCountResponse.new instead')
  static GetBlockCountResponse create() => GetBlockCountResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetBlockCountResponse._();
  @$core.override
  GetBlockCountResponse createEmptyInstance() => GetBlockCountResponse._();
  @$core.pragma('dart2js:noInline')
  static GetBlockCountResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBlockCountResponse>(GetBlockCountResponse.$_createMessage);
  static GetBlockCountResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get count => $_getI64(0);
  @$pb.TagNumber(1)
  set count($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearCount() => $_clearField(1);
}

class GetBlockchainInfoRequest extends $pb.GeneratedMessage {
  factory GetBlockchainInfoRequest() => GetBlockchainInfoRequest._();

  GetBlockchainInfoRequest._();

  factory GetBlockchainInfoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockchainInfoRequest()..mergeFromBuffer(data, registry);
  factory GetBlockchainInfoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockchainInfoRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockchainInfoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bbc.v1'),
      createEmptyInstance: GetBlockchainInfoRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockchainInfoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockchainInfoRequest copyWith(void Function(GetBlockchainInfoRequest) updates) =>
      super.copyWith((message) => updates(message as GetBlockchainInfoRequest)) as GetBlockchainInfoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBlockchainInfoRequest() / GetBlockchainInfoRequest.new instead')
  static GetBlockchainInfoRequest create() => GetBlockchainInfoRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetBlockchainInfoRequest._();
  @$core.override
  GetBlockchainInfoRequest createEmptyInstance() => GetBlockchainInfoRequest._();
  @$core.pragma('dart2js:noInline')
  static GetBlockchainInfoRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBlockchainInfoRequest>(GetBlockchainInfoRequest.$_createMessage);
  static GetBlockchainInfoRequest? _defaultInstance;
}

class GetBlockchainInfoResponse extends $pb.GeneratedMessage {
  factory GetBlockchainInfoResponse({
    $core.String? chain,
    $fixnum.Int64? blocks,
    $fixnum.Int64? headers,
    $core.String? bestBlockHash,
    $core.double? difficulty,
    $fixnum.Int64? time,
    $fixnum.Int64? medianTime,
    $core.double? verificationProgress,
    $core.bool? initialBlockDownload,
    $core.String? chainWork,
    $fixnum.Int64? sizeOnDisk,
    $core.bool? pruned,
    $core.Iterable<$core.String>? warnings,
  }) {
    final result = GetBlockchainInfoResponse._();
    if (chain != null) result.chain = chain;
    if (blocks != null) result.blocks = blocks;
    if (headers != null) result.headers = headers;
    if (bestBlockHash != null) result.bestBlockHash = bestBlockHash;
    if (difficulty != null) result.difficulty = difficulty;
    if (time != null) result.time = time;
    if (medianTime != null) result.medianTime = medianTime;
    if (verificationProgress != null) result.verificationProgress = verificationProgress;
    if (initialBlockDownload != null) result.initialBlockDownload = initialBlockDownload;
    if (chainWork != null) result.chainWork = chainWork;
    if (sizeOnDisk != null) result.sizeOnDisk = sizeOnDisk;
    if (pruned != null) result.pruned = pruned;
    if (warnings != null) result.warnings.addAll(warnings);
    return result;
  }

  GetBlockchainInfoResponse._();

  factory GetBlockchainInfoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockchainInfoResponse()..mergeFromBuffer(data, registry);
  factory GetBlockchainInfoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBlockchainInfoResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockchainInfoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bbc.v1'),
      createEmptyInstance: GetBlockchainInfoResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'chain')
    ..aInt64(2, _omitFieldNames ? '' : 'blocks')
    ..aInt64(3, _omitFieldNames ? '' : 'headers')
    ..aOS(4, _omitFieldNames ? '' : 'bestBlockHash')
    ..aD(5, _omitFieldNames ? '' : 'difficulty')
    ..aInt64(6, _omitFieldNames ? '' : 'time')
    ..aInt64(7, _omitFieldNames ? '' : 'medianTime')
    ..aD(8, _omitFieldNames ? '' : 'verificationProgress')
    ..aOB(9, _omitFieldNames ? '' : 'initialBlockDownload')
    ..aOS(10, _omitFieldNames ? '' : 'chainWork')
    ..aInt64(11, _omitFieldNames ? '' : 'sizeOnDisk')
    ..aOB(12, _omitFieldNames ? '' : 'pruned')
    ..pPS(13, _omitFieldNames ? '' : 'warnings')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockchainInfoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBlockchainInfoResponse copyWith(void Function(GetBlockchainInfoResponse) updates) =>
      super.copyWith((message) => updates(message as GetBlockchainInfoResponse)) as GetBlockchainInfoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBlockchainInfoResponse() / GetBlockchainInfoResponse.new instead')
  static GetBlockchainInfoResponse create() => GetBlockchainInfoResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetBlockchainInfoResponse._();
  @$core.override
  GetBlockchainInfoResponse createEmptyInstance() => GetBlockchainInfoResponse._();
  @$core.pragma('dart2js:noInline')
  static GetBlockchainInfoResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBlockchainInfoResponse>(GetBlockchainInfoResponse.$_createMessage);
  static GetBlockchainInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get chain => $_getSZ(0);
  @$pb.TagNumber(1)
  set chain($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChain() => $_has(0);
  @$pb.TagNumber(1)
  void clearChain() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get blocks => $_getI64(1);
  @$pb.TagNumber(2)
  set blocks($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBlocks() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlocks() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get headers => $_getI64(2);
  @$pb.TagNumber(3)
  set headers($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHeaders() => $_has(2);
  @$pb.TagNumber(3)
  void clearHeaders() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get bestBlockHash => $_getSZ(3);
  @$pb.TagNumber(4)
  set bestBlockHash($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBestBlockHash() => $_has(3);
  @$pb.TagNumber(4)
  void clearBestBlockHash() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get difficulty => $_getN(4);
  @$pb.TagNumber(5)
  set difficulty($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDifficulty() => $_has(4);
  @$pb.TagNumber(5)
  void clearDifficulty() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get time => $_getI64(5);
  @$pb.TagNumber(6)
  set time($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTime() => $_has(5);
  @$pb.TagNumber(6)
  void clearTime() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get medianTime => $_getI64(6);
  @$pb.TagNumber(7)
  set medianTime($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMedianTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearMedianTime() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.double get verificationProgress => $_getN(7);
  @$pb.TagNumber(8)
  set verificationProgress($core.double value) => $_setDouble(7, value);
  @$pb.TagNumber(8)
  $core.bool hasVerificationProgress() => $_has(7);
  @$pb.TagNumber(8)
  void clearVerificationProgress() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get initialBlockDownload => $_getBF(8);
  @$pb.TagNumber(9)
  set initialBlockDownload($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasInitialBlockDownload() => $_has(8);
  @$pb.TagNumber(9)
  void clearInitialBlockDownload() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get chainWork => $_getSZ(9);
  @$pb.TagNumber(10)
  set chainWork($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasChainWork() => $_has(9);
  @$pb.TagNumber(10)
  void clearChainWork() => $_clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get sizeOnDisk => $_getI64(10);
  @$pb.TagNumber(11)
  set sizeOnDisk($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(11)
  $core.bool hasSizeOnDisk() => $_has(10);
  @$pb.TagNumber(11)
  void clearSizeOnDisk() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get pruned => $_getBF(11);
  @$pb.TagNumber(12)
  set pruned($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasPruned() => $_has(11);
  @$pb.TagNumber(12)
  void clearPruned() => $_clearField(12);

  @$pb.TagNumber(13)
  $pb.PbList<$core.String> get warnings => $_getList(12);
}

class GetSidechainInfoRequest extends $pb.GeneratedMessage {
  factory GetSidechainInfoRequest() => GetSidechainInfoRequest._();

  GetSidechainInfoRequest._();

  factory GetSidechainInfoRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainInfoRequest()..mergeFromBuffer(data, registry);
  factory GetSidechainInfoRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainInfoRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainInfoRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bbc.v1'),
      createEmptyInstance: GetSidechainInfoRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainInfoRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainInfoRequest copyWith(void Function(GetSidechainInfoRequest) updates) =>
      super.copyWith((message) => updates(message as GetSidechainInfoRequest)) as GetSidechainInfoRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetSidechainInfoRequest() / GetSidechainInfoRequest.new instead')
  static GetSidechainInfoRequest create() => GetSidechainInfoRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetSidechainInfoRequest._();
  @$core.override
  GetSidechainInfoRequest createEmptyInstance() => GetSidechainInfoRequest._();
  @$core.pragma('dart2js:noInline')
  static GetSidechainInfoRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSidechainInfoRequest>(GetSidechainInfoRequest.$_createMessage);
  static GetSidechainInfoRequest? _defaultInstance;
}

class GetSidechainInfoResponse extends $pb.GeneratedMessage {
  factory GetSidechainInfoResponse({
    $core.bool? synced,
    $core.String? mainchainTip,
    $core.String? lastError,
  }) {
    final result = GetSidechainInfoResponse._();
    if (synced != null) result.synced = synced;
    if (mainchainTip != null) result.mainchainTip = mainchainTip;
    if (lastError != null) result.lastError = lastError;
    return result;
  }

  GetSidechainInfoResponse._();

  factory GetSidechainInfoResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainInfoResponse()..mergeFromBuffer(data, registry);
  factory GetSidechainInfoResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainInfoResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainInfoResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bbc.v1'),
      createEmptyInstance: GetSidechainInfoResponse.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'synced')
    ..aOS(2, _omitFieldNames ? '' : 'mainchainTip')
    ..aOS(3, _omitFieldNames ? '' : 'lastError')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainInfoResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainInfoResponse copyWith(void Function(GetSidechainInfoResponse) updates) =>
      super.copyWith((message) => updates(message as GetSidechainInfoResponse)) as GetSidechainInfoResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetSidechainInfoResponse() / GetSidechainInfoResponse.new instead')
  static GetSidechainInfoResponse create() => GetSidechainInfoResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetSidechainInfoResponse._();
  @$core.override
  GetSidechainInfoResponse createEmptyInstance() => GetSidechainInfoResponse._();
  @$core.pragma('dart2js:noInline')
  static GetSidechainInfoResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetSidechainInfoResponse>(GetSidechainInfoResponse.$_createMessage);
  static GetSidechainInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get synced => $_getBF(0);
  @$pb.TagNumber(1)
  set synced($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSynced() => $_has(0);
  @$pb.TagNumber(1)
  void clearSynced() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get mainchainTip => $_getSZ(1);
  @$pb.TagNumber(2)
  set mainchainTip($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMainchainTip() => $_has(1);
  @$pb.TagNumber(2)
  void clearMainchainTip() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get lastError => $_getSZ(2);
  @$pb.TagNumber(3)
  set lastError($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLastError() => $_has(2);
  @$pb.TagNumber(3)
  void clearLastError() => $_clearField(3);
}

class GetMainchainTipRequest extends $pb.GeneratedMessage {
  factory GetMainchainTipRequest() => GetMainchainTipRequest._();

  GetMainchainTipRequest._();

  factory GetMainchainTipRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetMainchainTipRequest()..mergeFromBuffer(data, registry);
  factory GetMainchainTipRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetMainchainTipRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetMainchainTipRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bbc.v1'),
      createEmptyInstance: GetMainchainTipRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMainchainTipRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMainchainTipRequest copyWith(void Function(GetMainchainTipRequest) updates) =>
      super.copyWith((message) => updates(message as GetMainchainTipRequest)) as GetMainchainTipRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetMainchainTipRequest() / GetMainchainTipRequest.new instead')
  static GetMainchainTipRequest create() => GetMainchainTipRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetMainchainTipRequest._();
  @$core.override
  GetMainchainTipRequest createEmptyInstance() => GetMainchainTipRequest._();
  @$core.pragma('dart2js:noInline')
  static GetMainchainTipRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMainchainTipRequest>(GetMainchainTipRequest.$_createMessage);
  static GetMainchainTipRequest? _defaultInstance;
}

class GetMainchainTipResponse extends $pb.GeneratedMessage {
  factory GetMainchainTipResponse({
    $core.String? blockHash,
  }) {
    final result = GetMainchainTipResponse._();
    if (blockHash != null) result.blockHash = blockHash;
    return result;
  }

  GetMainchainTipResponse._();

  factory GetMainchainTipResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetMainchainTipResponse()..mergeFromBuffer(data, registry);
  factory GetMainchainTipResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetMainchainTipResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetMainchainTipResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bbc.v1'),
      createEmptyInstance: GetMainchainTipResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'blockHash')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMainchainTipResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMainchainTipResponse copyWith(void Function(GetMainchainTipResponse) updates) =>
      super.copyWith((message) => updates(message as GetMainchainTipResponse)) as GetMainchainTipResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetMainchainTipResponse() / GetMainchainTipResponse.new instead')
  static GetMainchainTipResponse create() => GetMainchainTipResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetMainchainTipResponse._();
  @$core.override
  GetMainchainTipResponse createEmptyInstance() => GetMainchainTipResponse._();
  @$core.pragma('dart2js:noInline')
  static GetMainchainTipResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMainchainTipResponse>(GetMainchainTipResponse.$_createMessage);
  static GetMainchainTipResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get blockHash => $_getSZ(0);
  @$pb.TagNumber(1)
  set blockHash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBlockHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHash() => $_clearField(1);
}

class GetBmmCommitmentRequest extends $pb.GeneratedMessage {
  factory GetBmmCommitmentRequest({
    $core.String? mainchainBlockHash,
  }) {
    final result = GetBmmCommitmentRequest._();
    if (mainchainBlockHash != null) result.mainchainBlockHash = mainchainBlockHash;
    return result;
  }

  GetBmmCommitmentRequest._();

  factory GetBmmCommitmentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBmmCommitmentRequest()..mergeFromBuffer(data, registry);
  factory GetBmmCommitmentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBmmCommitmentRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBmmCommitmentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bbc.v1'),
      createEmptyInstance: GetBmmCommitmentRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'mainchainBlockHash')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBmmCommitmentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBmmCommitmentRequest copyWith(void Function(GetBmmCommitmentRequest) updates) =>
      super.copyWith((message) => updates(message as GetBmmCommitmentRequest)) as GetBmmCommitmentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBmmCommitmentRequest() / GetBmmCommitmentRequest.new instead')
  static GetBmmCommitmentRequest create() => GetBmmCommitmentRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetBmmCommitmentRequest._();
  @$core.override
  GetBmmCommitmentRequest createEmptyInstance() => GetBmmCommitmentRequest._();
  @$core.pragma('dart2js:noInline')
  static GetBmmCommitmentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBmmCommitmentRequest>(GetBmmCommitmentRequest.$_createMessage);
  static GetBmmCommitmentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mainchainBlockHash => $_getSZ(0);
  @$pb.TagNumber(1)
  set mainchainBlockHash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMainchainBlockHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearMainchainBlockHash() => $_clearField(1);
}

class GetBmmCommitmentResponse extends $pb.GeneratedMessage {
  factory GetBmmCommitmentResponse({
    $core.String? commitment,
  }) {
    final result = GetBmmCommitmentResponse._();
    if (commitment != null) result.commitment = commitment;
    return result;
  }

  GetBmmCommitmentResponse._();

  factory GetBmmCommitmentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBmmCommitmentResponse()..mergeFromBuffer(data, registry);
  factory GetBmmCommitmentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBmmCommitmentResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBmmCommitmentResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bbc.v1'),
      createEmptyInstance: GetBmmCommitmentResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'commitment')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBmmCommitmentResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBmmCommitmentResponse copyWith(void Function(GetBmmCommitmentResponse) updates) =>
      super.copyWith((message) => updates(message as GetBmmCommitmentResponse)) as GetBmmCommitmentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBmmCommitmentResponse() / GetBmmCommitmentResponse.new instead')
  static GetBmmCommitmentResponse create() => GetBmmCommitmentResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetBmmCommitmentResponse._();
  @$core.override
  GetBmmCommitmentResponse createEmptyInstance() => GetBmmCommitmentResponse._();
  @$core.pragma('dart2js:noInline')
  static GetBmmCommitmentResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetBmmCommitmentResponse>(GetBmmCommitmentResponse.$_createMessage);
  static GetBmmCommitmentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get commitment => $_getSZ(0);
  @$pb.TagNumber(1)
  set commitment($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCommitment() => $_has(0);
  @$pb.TagNumber(1)
  void clearCommitment() => $_clearField(1);
}

class GetNewAddressRequest extends $pb.GeneratedMessage {
  factory GetNewAddressRequest() => GetNewAddressRequest._();

  GetNewAddressRequest._();

  factory GetNewAddressRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNewAddressRequest()..mergeFromBuffer(data, registry);
  factory GetNewAddressRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNewAddressRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewAddressRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bbc.v1'),
      createEmptyInstance: GetNewAddressRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNewAddressRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNewAddressRequest copyWith(void Function(GetNewAddressRequest) updates) =>
      super.copyWith((message) => updates(message as GetNewAddressRequest)) as GetNewAddressRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetNewAddressRequest() / GetNewAddressRequest.new instead')
  static GetNewAddressRequest create() => GetNewAddressRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetNewAddressRequest._();
  @$core.override
  GetNewAddressRequest createEmptyInstance() => GetNewAddressRequest._();
  @$core.pragma('dart2js:noInline')
  static GetNewAddressRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNewAddressRequest>(GetNewAddressRequest.$_createMessage);
  static GetNewAddressRequest? _defaultInstance;
}

class GetNewAddressResponse extends $pb.GeneratedMessage {
  factory GetNewAddressResponse({
    $core.String? address,
  }) {
    final result = GetNewAddressResponse._();
    if (address != null) result.address = address;
    return result;
  }

  GetNewAddressResponse._();

  factory GetNewAddressResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNewAddressResponse()..mergeFromBuffer(data, registry);
  factory GetNewAddressResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNewAddressResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewAddressResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bbc.v1'),
      createEmptyInstance: GetNewAddressResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNewAddressResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNewAddressResponse copyWith(void Function(GetNewAddressResponse) updates) =>
      super.copyWith((message) => updates(message as GetNewAddressResponse)) as GetNewAddressResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetNewAddressResponse() / GetNewAddressResponse.new instead')
  static GetNewAddressResponse create() => GetNewAddressResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetNewAddressResponse._();
  @$core.override
  GetNewAddressResponse createEmptyInstance() => GetNewAddressResponse._();
  @$core.pragma('dart2js:noInline')
  static GetNewAddressResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNewAddressResponse>(GetNewAddressResponse.$_createMessage);
  static GetNewAddressResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);
}

class SendRequest extends $pb.GeneratedMessage {
  factory SendRequest({
    $core.String? address,
    $fixnum.Int64? amountSats,
    $core.bool? subtractFeeFromAmount,
  }) {
    final result = SendRequest._();
    if (address != null) result.address = address;
    if (amountSats != null) result.amountSats = amountSats;
    if (subtractFeeFromAmount != null) result.subtractFeeFromAmount = subtractFeeFromAmount;
    return result;
  }

  SendRequest._();

  factory SendRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendRequest()..mergeFromBuffer(data, registry);
  factory SendRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bbc.v1'),
      createEmptyInstance: SendRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aInt64(2, _omitFieldNames ? '' : 'amountSats')
    ..aOB(3, _omitFieldNames ? '' : 'subtractFeeFromAmount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendRequest copyWith(void Function(SendRequest) updates) =>
      super.copyWith((message) => updates(message as SendRequest)) as SendRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SendRequest() / SendRequest.new instead')
  static SendRequest create() => SendRequest._();
  static $pb.GeneratedMessage $_createMessage() => SendRequest._();
  @$core.override
  SendRequest createEmptyInstance() => SendRequest._();
  @$core.pragma('dart2js:noInline')
  static SendRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendRequest>(SendRequest.$_createMessage);
  static SendRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get amountSats => $_getI64(1);
  @$pb.TagNumber(2)
  set amountSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAmountSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmountSats() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get subtractFeeFromAmount => $_getBF(2);
  @$pb.TagNumber(3)
  set subtractFeeFromAmount($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSubtractFeeFromAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearSubtractFeeFromAmount() => $_clearField(3);
}

class SendResponse extends $pb.GeneratedMessage {
  factory SendResponse({
    $core.String? txid,
  }) {
    final result = SendResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  SendResponse._();

  factory SendResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendResponse()..mergeFromBuffer(data, registry);
  factory SendResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bbc.v1'),
      createEmptyInstance: SendResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendResponse copyWith(void Function(SendResponse) updates) =>
      super.copyWith((message) => updates(message as SendResponse)) as SendResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SendResponse() / SendResponse.new instead')
  static SendResponse create() => SendResponse._();
  static $pb.GeneratedMessage $_createMessage() => SendResponse._();
  @$core.override
  SendResponse createEmptyInstance() => SendResponse._();
  @$core.pragma('dart2js:noInline')
  static SendResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SendResponse>(SendResponse.$_createMessage);
  static SendResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class EstimateFeeRequest extends $pb.GeneratedMessage {
  factory EstimateFeeRequest() => EstimateFeeRequest._();

  EstimateFeeRequest._();

  factory EstimateFeeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EstimateFeeRequest()..mergeFromBuffer(data, registry);
  factory EstimateFeeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EstimateFeeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EstimateFeeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bbc.v1'),
      createEmptyInstance: EstimateFeeRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EstimateFeeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EstimateFeeRequest copyWith(void Function(EstimateFeeRequest) updates) =>
      super.copyWith((message) => updates(message as EstimateFeeRequest)) as EstimateFeeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EstimateFeeRequest() / EstimateFeeRequest.new instead')
  static EstimateFeeRequest create() => EstimateFeeRequest._();
  static $pb.GeneratedMessage $_createMessage() => EstimateFeeRequest._();
  @$core.override
  EstimateFeeRequest createEmptyInstance() => EstimateFeeRequest._();
  @$core.pragma('dart2js:noInline')
  static EstimateFeeRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EstimateFeeRequest>(EstimateFeeRequest.$_createMessage);
  static EstimateFeeRequest? _defaultInstance;
}

class EstimateFeeResponse extends $pb.GeneratedMessage {
  factory EstimateFeeResponse({
    $fixnum.Int64? satsPerKvb,
  }) {
    final result = EstimateFeeResponse._();
    if (satsPerKvb != null) result.satsPerKvb = satsPerKvb;
    return result;
  }

  EstimateFeeResponse._();

  factory EstimateFeeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EstimateFeeResponse()..mergeFromBuffer(data, registry);
  factory EstimateFeeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EstimateFeeResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EstimateFeeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bbc.v1'),
      createEmptyInstance: EstimateFeeResponse.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'satsPerKvb')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EstimateFeeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EstimateFeeResponse copyWith(void Function(EstimateFeeResponse) updates) =>
      super.copyWith((message) => updates(message as EstimateFeeResponse)) as EstimateFeeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EstimateFeeResponse() / EstimateFeeResponse.new instead')
  static EstimateFeeResponse create() => EstimateFeeResponse._();
  static $pb.GeneratedMessage $_createMessage() => EstimateFeeResponse._();
  @$core.override
  EstimateFeeResponse createEmptyInstance() => EstimateFeeResponse._();
  @$core.pragma('dart2js:noInline')
  static EstimateFeeResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EstimateFeeResponse>(EstimateFeeResponse.$_createMessage);
  static EstimateFeeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get satsPerKvb => $_getI64(0);
  @$pb.TagNumber(1)
  set satsPerKvb($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSatsPerKvb() => $_has(0);
  @$pb.TagNumber(1)
  void clearSatsPerKvb() => $_clearField(1);
}

class ListUtxosRequest extends $pb.GeneratedMessage {
  factory ListUtxosRequest() => ListUtxosRequest._();

  ListUtxosRequest._();

  factory ListUtxosRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListUtxosRequest()..mergeFromBuffer(data, registry);
  factory ListUtxosRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListUtxosRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListUtxosRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bbc.v1'),
      createEmptyInstance: ListUtxosRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUtxosRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUtxosRequest copyWith(void Function(ListUtxosRequest) updates) =>
      super.copyWith((message) => updates(message as ListUtxosRequest)) as ListUtxosRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListUtxosRequest() / ListUtxosRequest.new instead')
  static ListUtxosRequest create() => ListUtxosRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListUtxosRequest._();
  @$core.override
  ListUtxosRequest createEmptyInstance() => ListUtxosRequest._();
  @$core.pragma('dart2js:noInline')
  static ListUtxosRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListUtxosRequest>(ListUtxosRequest.$_createMessage);
  static ListUtxosRequest? _defaultInstance;
}

class Utxo extends $pb.GeneratedMessage {
  factory Utxo({
    $core.String? txid,
    $fixnum.Int64? vout,
    $core.String? address,
    $fixnum.Int64? valueSats,
    $fixnum.Int64? confirmations,
  }) {
    final result = Utxo._();
    if (txid != null) result.txid = txid;
    if (vout != null) result.vout = vout;
    if (address != null) result.address = address;
    if (valueSats != null) result.valueSats = valueSats;
    if (confirmations != null) result.confirmations = confirmations;
    return result;
  }

  Utxo._();

  factory Utxo.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Utxo()..mergeFromBuffer(data, registry);
  factory Utxo.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Utxo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Utxo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bbc.v1'), createEmptyInstance: Utxo.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aInt64(2, _omitFieldNames ? '' : 'vout')
    ..aOS(3, _omitFieldNames ? '' : 'address')
    ..aInt64(4, _omitFieldNames ? '' : 'valueSats')
    ..aInt64(5, _omitFieldNames ? '' : 'confirmations')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Utxo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Utxo copyWith(void Function(Utxo) updates) => super.copyWith((message) => updates(message as Utxo)) as Utxo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Utxo() / Utxo.new instead')
  static Utxo create() => Utxo._();
  static $pb.GeneratedMessage $_createMessage() => Utxo._();
  @$core.override
  Utxo createEmptyInstance() => Utxo._();
  @$core.pragma('dart2js:noInline')
  static Utxo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Utxo>(Utxo.$_createMessage);
  static Utxo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get vout => $_getI64(1);
  @$pb.TagNumber(2)
  set vout($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearVout() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get address => $_getSZ(2);
  @$pb.TagNumber(3)
  set address($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddress() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get valueSats => $_getI64(3);
  @$pb.TagNumber(4)
  set valueSats($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasValueSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearValueSats() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get confirmations => $_getI64(4);
  @$pb.TagNumber(5)
  set confirmations($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasConfirmations() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfirmations() => $_clearField(5);
}

class ListUtxosResponse extends $pb.GeneratedMessage {
  factory ListUtxosResponse({
    $core.Iterable<Utxo>? utxos,
  }) {
    final result = ListUtxosResponse._();
    if (utxos != null) result.utxos.addAll(utxos);
    return result;
  }

  ListUtxosResponse._();

  factory ListUtxosResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListUtxosResponse()..mergeFromBuffer(data, registry);
  factory ListUtxosResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListUtxosResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListUtxosResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bbc.v1'),
      createEmptyInstance: ListUtxosResponse.$_createMessage)
    ..pPM<Utxo>(1, _omitFieldNames ? '' : 'utxos', subBuilder: Utxo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUtxosResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUtxosResponse copyWith(void Function(ListUtxosResponse) updates) =>
      super.copyWith((message) => updates(message as ListUtxosResponse)) as ListUtxosResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListUtxosResponse() / ListUtxosResponse.new instead')
  static ListUtxosResponse create() => ListUtxosResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListUtxosResponse._();
  @$core.override
  ListUtxosResponse createEmptyInstance() => ListUtxosResponse._();
  @$core.pragma('dart2js:noInline')
  static ListUtxosResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListUtxosResponse>(ListUtxosResponse.$_createMessage);
  static ListUtxosResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Utxo> get utxos => $_getList(0);
}

class ListTransactionsRequest extends $pb.GeneratedMessage {
  factory ListTransactionsRequest({
    $fixnum.Int64? count,
  }) {
    final result = ListTransactionsRequest._();
    if (count != null) result.count = count;
    return result;
  }

  ListTransactionsRequest._();

  factory ListTransactionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListTransactionsRequest()..mergeFromBuffer(data, registry);
  factory ListTransactionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListTransactionsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListTransactionsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bbc.v1'),
      createEmptyInstance: ListTransactionsRequest.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'count')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTransactionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTransactionsRequest copyWith(void Function(ListTransactionsRequest) updates) =>
      super.copyWith((message) => updates(message as ListTransactionsRequest)) as ListTransactionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListTransactionsRequest() / ListTransactionsRequest.new instead')
  static ListTransactionsRequest create() => ListTransactionsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListTransactionsRequest._();
  @$core.override
  ListTransactionsRequest createEmptyInstance() => ListTransactionsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListTransactionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTransactionsRequest>(ListTransactionsRequest.$_createMessage);
  static ListTransactionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get count => $_getI64(0);
  @$pb.TagNumber(1)
  set count($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearCount() => $_clearField(1);
}

class Transaction extends $pb.GeneratedMessage {
  factory Transaction({
    $core.String? txid,
    $fixnum.Int64? amountSats,
    $fixnum.Int64? confirmations,
    $fixnum.Int64? time,
    $core.String? address,
    $core.String? category,
  }) {
    final result = Transaction._();
    if (txid != null) result.txid = txid;
    if (amountSats != null) result.amountSats = amountSats;
    if (confirmations != null) result.confirmations = confirmations;
    if (time != null) result.time = time;
    if (address != null) result.address = address;
    if (category != null) result.category = category;
    return result;
  }

  Transaction._();

  factory Transaction.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Transaction()..mergeFromBuffer(data, registry);
  factory Transaction.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Transaction()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Transaction',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bbc.v1'),
      createEmptyInstance: Transaction.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aInt64(2, _omitFieldNames ? '' : 'amountSats')
    ..aInt64(3, _omitFieldNames ? '' : 'confirmations')
    ..aInt64(4, _omitFieldNames ? '' : 'time')
    ..aOS(5, _omitFieldNames ? '' : 'address')
    ..aOS(6, _omitFieldNames ? '' : 'category')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Transaction clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Transaction copyWith(void Function(Transaction) updates) =>
      super.copyWith((message) => updates(message as Transaction)) as Transaction;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Transaction() / Transaction.new instead')
  static Transaction create() => Transaction._();
  static $pb.GeneratedMessage $_createMessage() => Transaction._();
  @$core.override
  Transaction createEmptyInstance() => Transaction._();
  @$core.pragma('dart2js:noInline')
  static Transaction getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Transaction>(Transaction.$_createMessage);
  static Transaction? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get amountSats => $_getI64(1);
  @$pb.TagNumber(2)
  set amountSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAmountSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmountSats() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get confirmations => $_getI64(2);
  @$pb.TagNumber(3)
  set confirmations($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasConfirmations() => $_has(2);
  @$pb.TagNumber(3)
  void clearConfirmations() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get time => $_getI64(3);
  @$pb.TagNumber(4)
  set time($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTime() => $_has(3);
  @$pb.TagNumber(4)
  void clearTime() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get address => $_getSZ(4);
  @$pb.TagNumber(5)
  set address($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAddress() => $_has(4);
  @$pb.TagNumber(5)
  void clearAddress() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get category => $_getSZ(5);
  @$pb.TagNumber(6)
  set category($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCategory() => $_has(5);
  @$pb.TagNumber(6)
  void clearCategory() => $_clearField(6);
}

class ListTransactionsResponse extends $pb.GeneratedMessage {
  factory ListTransactionsResponse({
    $core.Iterable<Transaction>? transactions,
  }) {
    final result = ListTransactionsResponse._();
    if (transactions != null) result.transactions.addAll(transactions);
    return result;
  }

  ListTransactionsResponse._();

  factory ListTransactionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListTransactionsResponse()..mergeFromBuffer(data, registry);
  factory ListTransactionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListTransactionsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListTransactionsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bbc.v1'),
      createEmptyInstance: ListTransactionsResponse.$_createMessage)
    ..pPM<Transaction>(1, _omitFieldNames ? '' : 'transactions', subBuilder: Transaction.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTransactionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTransactionsResponse copyWith(void Function(ListTransactionsResponse) updates) =>
      super.copyWith((message) => updates(message as ListTransactionsResponse)) as ListTransactionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListTransactionsResponse() / ListTransactionsResponse.new instead')
  static ListTransactionsResponse create() => ListTransactionsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListTransactionsResponse._();
  @$core.override
  ListTransactionsResponse createEmptyInstance() => ListTransactionsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListTransactionsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTransactionsResponse>(ListTransactionsResponse.$_createMessage);
  static ListTransactionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Transaction> get transactions => $_getList(0);
}

class StopRequest extends $pb.GeneratedMessage {
  factory StopRequest() => StopRequest._();

  StopRequest._();

  factory StopRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StopRequest()..mergeFromBuffer(data, registry);
  factory StopRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StopRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StopRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bbc.v1'),
      createEmptyInstance: StopRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopRequest copyWith(void Function(StopRequest) updates) =>
      super.copyWith((message) => updates(message as StopRequest)) as StopRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StopRequest() / StopRequest.new instead')
  static StopRequest create() => StopRequest._();
  static $pb.GeneratedMessage $_createMessage() => StopRequest._();
  @$core.override
  StopRequest createEmptyInstance() => StopRequest._();
  @$core.pragma('dart2js:noInline')
  static StopRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StopRequest>(StopRequest.$_createMessage);
  static StopRequest? _defaultInstance;
}

class StopResponse extends $pb.GeneratedMessage {
  factory StopResponse() => StopResponse._();

  StopResponse._();

  factory StopResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StopResponse()..mergeFromBuffer(data, registry);
  factory StopResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StopResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StopResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bbc.v1'),
      createEmptyInstance: StopResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopResponse copyWith(void Function(StopResponse) updates) =>
      super.copyWith((message) => updates(message as StopResponse)) as StopResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StopResponse() / StopResponse.new instead')
  static StopResponse create() => StopResponse._();
  static $pb.GeneratedMessage $_createMessage() => StopResponse._();
  @$core.override
  StopResponse createEmptyInstance() => StopResponse._();
  @$core.pragma('dart2js:noInline')
  static StopResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StopResponse>(StopResponse.$_createMessage);
  static StopResponse? _defaultInstance;
}

/// Big Block Covenant is a Bitcoin Core fork run as a drivechain sidechain, so its RPC
/// surface is Core's rather than the CUSF one the other sidechains expose.
class BbcServiceApi {
  final $pb.RpcClient _client;

  BbcServiceApi(this._client);

  /// Get current block count.
  $async.Future<GetBlockCountResponse> getBlockCount($pb.ClientContext? ctx, GetBlockCountRequest request) =>
      _client.invoke<GetBlockCountResponse>(ctx, 'BbcService', 'GetBlockCount', request, GetBlockCountResponse());

  /// Get the node's chain state.
  $async.Future<GetBlockchainInfoResponse> getBlockchainInfo(
          $pb.ClientContext? ctx, GetBlockchainInfoRequest request) =>
      _client.invoke<GetBlockchainInfoResponse>(
          ctx, 'BbcService', 'GetBlockchainInfo', request, GetBlockchainInfoResponse());

  /// Report whether the node has caught up with the mainchain.
  $async.Future<GetSidechainInfoResponse> getSidechainInfo($pb.ClientContext? ctx, GetSidechainInfoRequest request) =>
      _client.invoke<GetSidechainInfoResponse>(
          ctx, 'BbcService', 'GetSidechainInfo', request, GetSidechainInfoResponse());

  /// Get the mainchain block hash the node is following.
  $async.Future<GetMainchainTipResponse> getMainchainTip($pb.ClientContext? ctx, GetMainchainTipRequest request) =>
      _client.invoke<GetMainchainTipResponse>(ctx, 'BbcService', 'GetMainchainTip', request, GetMainchainTipResponse());

  /// Get the sidechain block a mainchain block commits to, empty when none.
  $async.Future<GetBmmCommitmentResponse> getBmmCommitment($pb.ClientContext? ctx, GetBmmCommitmentRequest request) =>
      _client.invoke<GetBmmCommitmentResponse>(
          ctx, 'BbcService', 'GetBmmCommitment', request, GetBmmCommitmentResponse());

  /// Get a new address from the wallet.
  $async.Future<GetNewAddressResponse> getNewAddress($pb.ClientContext? ctx, GetNewAddressRequest request) =>
      _client.invoke<GetNewAddressResponse>(ctx, 'BbcService', 'GetNewAddress', request, GetNewAddressResponse());

  /// Send to a sidechain address.
  $async.Future<SendResponse> send($pb.ClientContext? ctx, SendRequest request) =>
      _client.invoke<SendResponse>(ctx, 'BbcService', 'Send', request, SendResponse());

  /// Estimate the fee rate in sats per kvB.
  $async.Future<EstimateFeeResponse> estimateFee($pb.ClientContext? ctx, EstimateFeeRequest request) =>
      _client.invoke<EstimateFeeResponse>(ctx, 'BbcService', 'EstimateFee', request, EstimateFeeResponse());

  /// List wallet UTXOs.
  $async.Future<ListUtxosResponse> listUtxos($pb.ClientContext? ctx, ListUtxosRequest request) =>
      _client.invoke<ListUtxosResponse>(ctx, 'BbcService', 'ListUtxos', request, ListUtxosResponse());

  /// List wallet transactions, most recent first.
  $async.Future<ListTransactionsResponse> listTransactions($pb.ClientContext? ctx, ListTransactionsRequest request) =>
      _client.invoke<ListTransactionsResponse>(
          ctx, 'BbcService', 'ListTransactions', request, ListTransactionsResponse());

  /// Stop the node.
  $async.Future<StopResponse> stop($pb.ClientContext? ctx, StopRequest request) =>
      _client.invoke<StopResponse>(ctx, 'BbcService', 'Stop', request, StopResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
