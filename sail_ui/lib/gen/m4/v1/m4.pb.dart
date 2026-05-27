//
//  Generated code. Do not modify.
//  source: m4/v1/m4.proto
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

class M4Vote extends $pb.GeneratedMessage {
  factory M4Vote({
    $core.int? sidechainSlot,
    $core.String? voteType,
    $core.String? bundleHash,
    $core.int? bundleIndex,
  }) {
    final $result = create();
    if (sidechainSlot != null) {
      $result.sidechainSlot = sidechainSlot;
    }
    if (voteType != null) {
      $result.voteType = voteType;
    }
    if (bundleHash != null) {
      $result.bundleHash = bundleHash;
    }
    if (bundleIndex != null) {
      $result.bundleIndex = bundleIndex;
    }
    return $result;
  }
  M4Vote._() : super();
  factory M4Vote.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory M4Vote.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'M4Vote', package: const $pb.PackageName(_omitMessageNames ? '' : 'm4.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'sidechainSlot', $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'voteType')
    ..aOS(3, _omitFieldNames ? '' : 'bundleHash')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'bundleIndex', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  M4Vote clone() => M4Vote()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  M4Vote copyWith(void Function(M4Vote) updates) => super.copyWith((message) => updates(message as M4Vote)) as M4Vote;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static M4Vote create() => M4Vote._();
  M4Vote createEmptyInstance() => create();
  static $pb.PbList<M4Vote> createRepeated() => $pb.PbList<M4Vote>();
  @$core.pragma('dart2js:noInline')
  static M4Vote getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<M4Vote>(create);
  static M4Vote? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get sidechainSlot => $_getIZ(0);
  @$pb.TagNumber(1)
  set sidechainSlot($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechainSlot() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainSlot() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get voteType => $_getSZ(1);
  @$pb.TagNumber(2)
  set voteType($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasVoteType() => $_has(1);
  @$pb.TagNumber(2)
  void clearVoteType() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get bundleHash => $_getSZ(2);
  @$pb.TagNumber(3)
  set bundleHash($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasBundleHash() => $_has(2);
  @$pb.TagNumber(3)
  void clearBundleHash() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get bundleIndex => $_getIZ(3);
  @$pb.TagNumber(4)
  set bundleIndex($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasBundleIndex() => $_has(3);
  @$pb.TagNumber(4)
  void clearBundleIndex() => clearField(4);
}

class M4HistoryEntry extends $pb.GeneratedMessage {
  factory M4HistoryEntry({
    $core.int? blockHeight,
    $core.String? blockHash,
    $fixnum.Int64? blockTime,
    $core.int? version,
    $core.Iterable<M4Vote>? votes,
  }) {
    final $result = create();
    if (blockHeight != null) {
      $result.blockHeight = blockHeight;
    }
    if (blockHash != null) {
      $result.blockHash = blockHash;
    }
    if (blockTime != null) {
      $result.blockTime = blockTime;
    }
    if (version != null) {
      $result.version = version;
    }
    if (votes != null) {
      $result.votes.addAll(votes);
    }
    return $result;
  }
  M4HistoryEntry._() : super();
  factory M4HistoryEntry.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory M4HistoryEntry.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'M4HistoryEntry', package: const $pb.PackageName(_omitMessageNames ? '' : 'm4.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'blockHeight', $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'blockHash')
    ..aInt64(3, _omitFieldNames ? '' : 'blockTime')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'version', $pb.PbFieldType.OU3)
    ..pc<M4Vote>(5, _omitFieldNames ? '' : 'votes', $pb.PbFieldType.PM, subBuilder: M4Vote.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  M4HistoryEntry clone() => M4HistoryEntry()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  M4HistoryEntry copyWith(void Function(M4HistoryEntry) updates) => super.copyWith((message) => updates(message as M4HistoryEntry)) as M4HistoryEntry;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static M4HistoryEntry create() => M4HistoryEntry._();
  M4HistoryEntry createEmptyInstance() => create();
  static $pb.PbList<M4HistoryEntry> createRepeated() => $pb.PbList<M4HistoryEntry>();
  @$core.pragma('dart2js:noInline')
  static M4HistoryEntry getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<M4HistoryEntry>(create);
  static M4HistoryEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get blockHeight => $_getIZ(0);
  @$pb.TagNumber(1)
  set blockHeight($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBlockHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHeight() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get blockHash => $_getSZ(1);
  @$pb.TagNumber(2)
  set blockHash($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasBlockHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlockHash() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get blockTime => $_getI64(2);
  @$pb.TagNumber(3)
  set blockTime($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasBlockTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearBlockTime() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get version => $_getIZ(3);
  @$pb.TagNumber(4)
  set version($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearVersion() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<M4Vote> get votes => $_getList(4);
}

class GetM4HistoryRequest extends $pb.GeneratedMessage {
  factory GetM4HistoryRequest({
    $core.int? limit,
  }) {
    final $result = create();
    if (limit != null) {
      $result.limit = limit;
    }
    return $result;
  }
  GetM4HistoryRequest._() : super();
  factory GetM4HistoryRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetM4HistoryRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetM4HistoryRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'm4.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'limit', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetM4HistoryRequest clone() => GetM4HistoryRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetM4HistoryRequest copyWith(void Function(GetM4HistoryRequest) updates) => super.copyWith((message) => updates(message as GetM4HistoryRequest)) as GetM4HistoryRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetM4HistoryRequest create() => GetM4HistoryRequest._();
  GetM4HistoryRequest createEmptyInstance() => create();
  static $pb.PbList<GetM4HistoryRequest> createRepeated() => $pb.PbList<GetM4HistoryRequest>();
  @$core.pragma('dart2js:noInline')
  static GetM4HistoryRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetM4HistoryRequest>(create);
  static GetM4HistoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get limit => $_getIZ(0);
  @$pb.TagNumber(1)
  set limit($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasLimit() => $_has(0);
  @$pb.TagNumber(1)
  void clearLimit() => clearField(1);
}

class GetM4HistoryResponse extends $pb.GeneratedMessage {
  factory GetM4HistoryResponse({
    $core.Iterable<M4HistoryEntry>? history,
  }) {
    final $result = create();
    if (history != null) {
      $result.history.addAll(history);
    }
    return $result;
  }
  GetM4HistoryResponse._() : super();
  factory GetM4HistoryResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetM4HistoryResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetM4HistoryResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'm4.v1'), createEmptyInstance: create)
    ..pc<M4HistoryEntry>(1, _omitFieldNames ? '' : 'history', $pb.PbFieldType.PM, subBuilder: M4HistoryEntry.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetM4HistoryResponse clone() => GetM4HistoryResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetM4HistoryResponse copyWith(void Function(GetM4HistoryResponse) updates) => super.copyWith((message) => updates(message as GetM4HistoryResponse)) as GetM4HistoryResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetM4HistoryResponse create() => GetM4HistoryResponse._();
  GetM4HistoryResponse createEmptyInstance() => create();
  static $pb.PbList<GetM4HistoryResponse> createRepeated() => $pb.PbList<GetM4HistoryResponse>();
  @$core.pragma('dart2js:noInline')
  static GetM4HistoryResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetM4HistoryResponse>(create);
  static GetM4HistoryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<M4HistoryEntry> get history => $_getList(0);
}

class GetVotePreferencesRequest extends $pb.GeneratedMessage {
  factory GetVotePreferencesRequest() => create();
  GetVotePreferencesRequest._() : super();
  factory GetVotePreferencesRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetVotePreferencesRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetVotePreferencesRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'm4.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetVotePreferencesRequest clone() => GetVotePreferencesRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetVotePreferencesRequest copyWith(void Function(GetVotePreferencesRequest) updates) => super.copyWith((message) => updates(message as GetVotePreferencesRequest)) as GetVotePreferencesRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetVotePreferencesRequest create() => GetVotePreferencesRequest._();
  GetVotePreferencesRequest createEmptyInstance() => create();
  static $pb.PbList<GetVotePreferencesRequest> createRepeated() => $pb.PbList<GetVotePreferencesRequest>();
  @$core.pragma('dart2js:noInline')
  static GetVotePreferencesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetVotePreferencesRequest>(create);
  static GetVotePreferencesRequest? _defaultInstance;
}

class GetVotePreferencesResponse extends $pb.GeneratedMessage {
  factory GetVotePreferencesResponse({
    $core.Iterable<M4Vote>? preferences,
  }) {
    final $result = create();
    if (preferences != null) {
      $result.preferences.addAll(preferences);
    }
    return $result;
  }
  GetVotePreferencesResponse._() : super();
  factory GetVotePreferencesResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetVotePreferencesResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetVotePreferencesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'm4.v1'), createEmptyInstance: create)
    ..pc<M4Vote>(1, _omitFieldNames ? '' : 'preferences', $pb.PbFieldType.PM, subBuilder: M4Vote.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetVotePreferencesResponse clone() => GetVotePreferencesResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetVotePreferencesResponse copyWith(void Function(GetVotePreferencesResponse) updates) => super.copyWith((message) => updates(message as GetVotePreferencesResponse)) as GetVotePreferencesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetVotePreferencesResponse create() => GetVotePreferencesResponse._();
  GetVotePreferencesResponse createEmptyInstance() => create();
  static $pb.PbList<GetVotePreferencesResponse> createRepeated() => $pb.PbList<GetVotePreferencesResponse>();
  @$core.pragma('dart2js:noInline')
  static GetVotePreferencesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetVotePreferencesResponse>(create);
  static GetVotePreferencesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<M4Vote> get preferences => $_getList(0);
}

class SetVotePreferenceRequest extends $pb.GeneratedMessage {
  factory SetVotePreferenceRequest({
    $core.int? sidechainSlot,
    $core.String? voteType,
    $core.String? bundleHash,
  }) {
    final $result = create();
    if (sidechainSlot != null) {
      $result.sidechainSlot = sidechainSlot;
    }
    if (voteType != null) {
      $result.voteType = voteType;
    }
    if (bundleHash != null) {
      $result.bundleHash = bundleHash;
    }
    return $result;
  }
  SetVotePreferenceRequest._() : super();
  factory SetVotePreferenceRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetVotePreferenceRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetVotePreferenceRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'm4.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'sidechainSlot', $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'voteType')
    ..aOS(3, _omitFieldNames ? '' : 'bundleHash')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetVotePreferenceRequest clone() => SetVotePreferenceRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetVotePreferenceRequest copyWith(void Function(SetVotePreferenceRequest) updates) => super.copyWith((message) => updates(message as SetVotePreferenceRequest)) as SetVotePreferenceRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetVotePreferenceRequest create() => SetVotePreferenceRequest._();
  SetVotePreferenceRequest createEmptyInstance() => create();
  static $pb.PbList<SetVotePreferenceRequest> createRepeated() => $pb.PbList<SetVotePreferenceRequest>();
  @$core.pragma('dart2js:noInline')
  static SetVotePreferenceRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetVotePreferenceRequest>(create);
  static SetVotePreferenceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get sidechainSlot => $_getIZ(0);
  @$pb.TagNumber(1)
  set sidechainSlot($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechainSlot() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainSlot() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get voteType => $_getSZ(1);
  @$pb.TagNumber(2)
  set voteType($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasVoteType() => $_has(1);
  @$pb.TagNumber(2)
  void clearVoteType() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get bundleHash => $_getSZ(2);
  @$pb.TagNumber(3)
  set bundleHash($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasBundleHash() => $_has(2);
  @$pb.TagNumber(3)
  void clearBundleHash() => clearField(3);
}

class SetVotePreferenceResponse extends $pb.GeneratedMessage {
  factory SetVotePreferenceResponse({
    $core.bool? success,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    return $result;
  }
  SetVotePreferenceResponse._() : super();
  factory SetVotePreferenceResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetVotePreferenceResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetVotePreferenceResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'm4.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetVotePreferenceResponse clone() => SetVotePreferenceResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetVotePreferenceResponse copyWith(void Function(SetVotePreferenceResponse) updates) => super.copyWith((message) => updates(message as SetVotePreferenceResponse)) as SetVotePreferenceResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetVotePreferenceResponse create() => SetVotePreferenceResponse._();
  SetVotePreferenceResponse createEmptyInstance() => create();
  static $pb.PbList<SetVotePreferenceResponse> createRepeated() => $pb.PbList<SetVotePreferenceResponse>();
  @$core.pragma('dart2js:noInline')
  static SetVotePreferenceResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetVotePreferenceResponse>(create);
  static SetVotePreferenceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => clearField(1);
}

class GenerateM4BytesRequest extends $pb.GeneratedMessage {
  factory GenerateM4BytesRequest() => create();
  GenerateM4BytesRequest._() : super();
  factory GenerateM4BytesRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GenerateM4BytesRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GenerateM4BytesRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'm4.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GenerateM4BytesRequest clone() => GenerateM4BytesRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GenerateM4BytesRequest copyWith(void Function(GenerateM4BytesRequest) updates) => super.copyWith((message) => updates(message as GenerateM4BytesRequest)) as GenerateM4BytesRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateM4BytesRequest create() => GenerateM4BytesRequest._();
  GenerateM4BytesRequest createEmptyInstance() => create();
  static $pb.PbList<GenerateM4BytesRequest> createRepeated() => $pb.PbList<GenerateM4BytesRequest>();
  @$core.pragma('dart2js:noInline')
  static GenerateM4BytesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GenerateM4BytesRequest>(create);
  static GenerateM4BytesRequest? _defaultInstance;
}

class GenerateM4BytesResponse extends $pb.GeneratedMessage {
  factory GenerateM4BytesResponse({
    $core.String? hex,
    $core.String? interpretation,
  }) {
    final $result = create();
    if (hex != null) {
      $result.hex = hex;
    }
    if (interpretation != null) {
      $result.interpretation = interpretation;
    }
    return $result;
  }
  GenerateM4BytesResponse._() : super();
  factory GenerateM4BytesResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GenerateM4BytesResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GenerateM4BytesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'm4.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'hex')
    ..aOS(2, _omitFieldNames ? '' : 'interpretation')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GenerateM4BytesResponse clone() => GenerateM4BytesResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GenerateM4BytesResponse copyWith(void Function(GenerateM4BytesResponse) updates) => super.copyWith((message) => updates(message as GenerateM4BytesResponse)) as GenerateM4BytesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GenerateM4BytesResponse create() => GenerateM4BytesResponse._();
  GenerateM4BytesResponse createEmptyInstance() => create();
  static $pb.PbList<GenerateM4BytesResponse> createRepeated() => $pb.PbList<GenerateM4BytesResponse>();
  @$core.pragma('dart2js:noInline')
  static GenerateM4BytesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GenerateM4BytesResponse>(create);
  static GenerateM4BytesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hex => $_getSZ(0);
  @$pb.TagNumber(1)
  set hex($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHex() => $_has(0);
  @$pb.TagNumber(1)
  void clearHex() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get interpretation => $_getSZ(1);
  @$pb.TagNumber(2)
  set interpretation($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasInterpretation() => $_has(1);
  @$pb.TagNumber(2)
  void clearInterpretation() => clearField(2);
}

class M4ServiceApi {
  $pb.RpcClient _client;
  M4ServiceApi(this._client);

  $async.Future<GetM4HistoryResponse> getM4History($pb.ClientContext? ctx, GetM4HistoryRequest request) =>
    _client.invoke<GetM4HistoryResponse>(ctx, 'M4Service', 'GetM4History', request, GetM4HistoryResponse())
  ;
  $async.Future<GetVotePreferencesResponse> getVotePreferences($pb.ClientContext? ctx, GetVotePreferencesRequest request) =>
    _client.invoke<GetVotePreferencesResponse>(ctx, 'M4Service', 'GetVotePreferences', request, GetVotePreferencesResponse())
  ;
  $async.Future<SetVotePreferenceResponse> setVotePreference($pb.ClientContext? ctx, SetVotePreferenceRequest request) =>
    _client.invoke<SetVotePreferenceResponse>(ctx, 'M4Service', 'SetVotePreference', request, SetVotePreferenceResponse())
  ;
  $async.Future<GenerateM4BytesResponse> generateM4Bytes($pb.ClientContext? ctx, GenerateM4BytesRequest request) =>
    _client.invoke<GenerateM4BytesResponse>(ctx, 'M4Service', 'GenerateM4Bytes', request, GenerateM4BytesResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
