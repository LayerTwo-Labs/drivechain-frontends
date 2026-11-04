// This is a generated file - do not edit.
//
// Generated from m4/v1/m4.proto.

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

import 'm4.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'm4.pbenum.dart';

class M4Vote extends $pb.GeneratedMessage {
  factory M4Vote({
    $core.int? sidechainSlot,
    $core.String? voteType,
    $core.String? bundleHash,
    $core.int? bundleIndex,
  }) {
    final result = M4Vote._();
    if (sidechainSlot != null) result.sidechainSlot = sidechainSlot;
    if (voteType != null) result.voteType = voteType;
    if (bundleHash != null) result.bundleHash = bundleHash;
    if (bundleIndex != null) result.bundleIndex = bundleIndex;
    return result;
  }

  M4Vote._();

  factory M4Vote.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      M4Vote()..mergeFromBuffer(data, registry);
  factory M4Vote.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      M4Vote()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'M4Vote',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'm4.v1'), createEmptyInstance: M4Vote.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'sidechainSlot', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'voteType')
    ..aOS(3, _omitFieldNames ? '' : 'bundleHash')
    ..aI(4, _omitFieldNames ? '' : 'bundleIndex', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  M4Vote clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  M4Vote copyWith(void Function(M4Vote) updates) => super.copyWith((message) => updates(message as M4Vote)) as M4Vote;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use M4Vote() / M4Vote.new instead')
  static M4Vote create() => M4Vote._();
  static $pb.GeneratedMessage $_createMessage() => M4Vote._();
  @$core.override
  M4Vote createEmptyInstance() => M4Vote._();
  @$core.pragma('dart2js:noInline')
  static M4Vote getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<M4Vote>(M4Vote.$_createMessage);
  static M4Vote? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get sidechainSlot => $_getIZ(0);
  @$pb.TagNumber(1)
  set sidechainSlot($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSidechainSlot() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainSlot() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get voteType => $_getSZ(1);
  @$pb.TagNumber(2)
  set voteType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVoteType() => $_has(1);
  @$pb.TagNumber(2)
  void clearVoteType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get bundleHash => $_getSZ(2);
  @$pb.TagNumber(3)
  set bundleHash($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBundleHash() => $_has(2);
  @$pb.TagNumber(3)
  void clearBundleHash() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get bundleIndex => $_getIZ(3);
  @$pb.TagNumber(4)
  set bundleIndex($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBundleIndex() => $_has(3);
  @$pb.TagNumber(4)
  void clearBundleIndex() => $_clearField(4);
}

class M4HistoryEntry extends $pb.GeneratedMessage {
  factory M4HistoryEntry({
    $core.int? blockHeight,
    $core.String? blockHash,
    $fixnum.Int64? blockTime,
    $core.int? version,
    $core.Iterable<M4Vote>? votes,
  }) {
    final result = M4HistoryEntry._();
    if (blockHeight != null) result.blockHeight = blockHeight;
    if (blockHash != null) result.blockHash = blockHash;
    if (blockTime != null) result.blockTime = blockTime;
    if (version != null) result.version = version;
    if (votes != null) result.votes.addAll(votes);
    return result;
  }

  M4HistoryEntry._();

  factory M4HistoryEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      M4HistoryEntry()..mergeFromBuffer(data, registry);
  factory M4HistoryEntry.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      M4HistoryEntry()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'M4HistoryEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'm4.v1'),
      createEmptyInstance: M4HistoryEntry.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'blockHeight', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'blockHash')
    ..aInt64(3, _omitFieldNames ? '' : 'blockTime')
    ..aI(4, _omitFieldNames ? '' : 'version', fieldType: $pb.PbFieldType.OU3)
    ..pPM<M4Vote>(5, _omitFieldNames ? '' : 'votes', subBuilder: M4Vote.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  M4HistoryEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  M4HistoryEntry copyWith(void Function(M4HistoryEntry) updates) =>
      super.copyWith((message) => updates(message as M4HistoryEntry)) as M4HistoryEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use M4HistoryEntry() / M4HistoryEntry.new instead')
  static M4HistoryEntry create() => M4HistoryEntry._();
  static $pb.GeneratedMessage $_createMessage() => M4HistoryEntry._();
  @$core.override
  M4HistoryEntry createEmptyInstance() => M4HistoryEntry._();
  @$core.pragma('dart2js:noInline')
  static M4HistoryEntry getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<M4HistoryEntry>(M4HistoryEntry.$_createMessage);
  static M4HistoryEntry? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get blockHeight => $_getIZ(0);
  @$pb.TagNumber(1)
  set blockHeight($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBlockHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHeight() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get blockHash => $_getSZ(1);
  @$pb.TagNumber(2)
  set blockHash($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBlockHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlockHash() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get blockTime => $_getI64(2);
  @$pb.TagNumber(3)
  set blockTime($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBlockTime() => $_has(2);
  @$pb.TagNumber(3)
  void clearBlockTime() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get version => $_getIZ(3);
  @$pb.TagNumber(4)
  set version($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearVersion() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<M4Vote> get votes => $_getList(4);
}

class GetM4HistoryRequest extends $pb.GeneratedMessage {
  factory GetM4HistoryRequest({
    $core.int? limit,
  }) {
    final result = GetM4HistoryRequest._();
    if (limit != null) result.limit = limit;
    return result;
  }

  GetM4HistoryRequest._();

  factory GetM4HistoryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetM4HistoryRequest()..mergeFromBuffer(data, registry);
  factory GetM4HistoryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetM4HistoryRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetM4HistoryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'm4.v1'),
      createEmptyInstance: GetM4HistoryRequest.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'limit', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetM4HistoryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetM4HistoryRequest copyWith(void Function(GetM4HistoryRequest) updates) =>
      super.copyWith((message) => updates(message as GetM4HistoryRequest)) as GetM4HistoryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetM4HistoryRequest() / GetM4HistoryRequest.new instead')
  static GetM4HistoryRequest create() => GetM4HistoryRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetM4HistoryRequest._();
  @$core.override
  GetM4HistoryRequest createEmptyInstance() => GetM4HistoryRequest._();
  @$core.pragma('dart2js:noInline')
  static GetM4HistoryRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetM4HistoryRequest>(GetM4HistoryRequest.$_createMessage);
  static GetM4HistoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get limit => $_getIZ(0);
  @$pb.TagNumber(1)
  set limit($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLimit() => $_has(0);
  @$pb.TagNumber(1)
  void clearLimit() => $_clearField(1);
}

class GetM4HistoryResponse extends $pb.GeneratedMessage {
  factory GetM4HistoryResponse({
    $core.Iterable<M4HistoryEntry>? history,
  }) {
    final result = GetM4HistoryResponse._();
    if (history != null) result.history.addAll(history);
    return result;
  }

  GetM4HistoryResponse._();

  factory GetM4HistoryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetM4HistoryResponse()..mergeFromBuffer(data, registry);
  factory GetM4HistoryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetM4HistoryResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetM4HistoryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'm4.v1'),
      createEmptyInstance: GetM4HistoryResponse.$_createMessage)
    ..pPM<M4HistoryEntry>(1, _omitFieldNames ? '' : 'history', subBuilder: M4HistoryEntry.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetM4HistoryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetM4HistoryResponse copyWith(void Function(GetM4HistoryResponse) updates) =>
      super.copyWith((message) => updates(message as GetM4HistoryResponse)) as GetM4HistoryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetM4HistoryResponse() / GetM4HistoryResponse.new instead')
  static GetM4HistoryResponse create() => GetM4HistoryResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetM4HistoryResponse._();
  @$core.override
  GetM4HistoryResponse createEmptyInstance() => GetM4HistoryResponse._();
  @$core.pragma('dart2js:noInline')
  static GetM4HistoryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetM4HistoryResponse>(GetM4HistoryResponse.$_createMessage);
  static GetM4HistoryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<M4HistoryEntry> get history => $_getList(0);
}

class BundleUpvote extends $pb.GeneratedMessage {
  factory BundleUpvote({
    $core.int? sidechainSlot,
    $core.String? m6id,
  }) {
    final result = BundleUpvote._();
    if (sidechainSlot != null) result.sidechainSlot = sidechainSlot;
    if (m6id != null) result.m6id = m6id;
    return result;
  }

  BundleUpvote._();

  factory BundleUpvote.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BundleUpvote()..mergeFromBuffer(data, registry);
  factory BundleUpvote.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BundleUpvote()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BundleUpvote',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'm4.v1'),
      createEmptyInstance: BundleUpvote.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'sidechainSlot', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'm6id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BundleUpvote clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BundleUpvote copyWith(void Function(BundleUpvote) updates) =>
      super.copyWith((message) => updates(message as BundleUpvote)) as BundleUpvote;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BundleUpvote() / BundleUpvote.new instead')
  static BundleUpvote create() => BundleUpvote._();
  static $pb.GeneratedMessage $_createMessage() => BundleUpvote._();
  @$core.override
  BundleUpvote createEmptyInstance() => BundleUpvote._();
  @$core.pragma('dart2js:noInline')
  static BundleUpvote getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BundleUpvote>(BundleUpvote.$_createMessage);
  static BundleUpvote? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get sidechainSlot => $_getIZ(0);
  @$pb.TagNumber(1)
  set sidechainSlot($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSidechainSlot() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainSlot() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get m6id => $_getSZ(1);
  @$pb.TagNumber(2)
  set m6id($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasM6id() => $_has(1);
  @$pb.TagNumber(2)
  void clearM6id() => $_clearField(2);
}

class GetVotesRequest extends $pb.GeneratedMessage {
  factory GetVotesRequest() => GetVotesRequest._();

  GetVotesRequest._();

  factory GetVotesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetVotesRequest()..mergeFromBuffer(data, registry);
  factory GetVotesRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetVotesRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetVotesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'm4.v1'),
      createEmptyInstance: GetVotesRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetVotesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetVotesRequest copyWith(void Function(GetVotesRequest) updates) =>
      super.copyWith((message) => updates(message as GetVotesRequest)) as GetVotesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetVotesRequest() / GetVotesRequest.new instead')
  static GetVotesRequest create() => GetVotesRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetVotesRequest._();
  @$core.override
  GetVotesRequest createEmptyInstance() => GetVotesRequest._();
  @$core.pragma('dart2js:noInline')
  static GetVotesRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetVotesRequest>(GetVotesRequest.$_createMessage);
  static GetVotesRequest? _defaultInstance;
}

class GetVotesResponse extends $pb.GeneratedMessage {
  factory GetVotesResponse({
    VotePolicy? policy,
    $core.Iterable<BundleUpvote>? upvotes,
  }) {
    final result = GetVotesResponse._();
    if (policy != null) result.policy = policy;
    if (upvotes != null) result.upvotes.addAll(upvotes);
    return result;
  }

  GetVotesResponse._();

  factory GetVotesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetVotesResponse()..mergeFromBuffer(data, registry);
  factory GetVotesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetVotesResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetVotesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'm4.v1'),
      createEmptyInstance: GetVotesResponse.$_createMessage)
    ..aE<VotePolicy>(1, _omitFieldNames ? '' : 'policy', enumValues: VotePolicy.values)
    ..pPM<BundleUpvote>(2, _omitFieldNames ? '' : 'upvotes', subBuilder: BundleUpvote.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetVotesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetVotesResponse copyWith(void Function(GetVotesResponse) updates) =>
      super.copyWith((message) => updates(message as GetVotesResponse)) as GetVotesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetVotesResponse() / GetVotesResponse.new instead')
  static GetVotesResponse create() => GetVotesResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetVotesResponse._();
  @$core.override
  GetVotesResponse createEmptyInstance() => GetVotesResponse._();
  @$core.pragma('dart2js:noInline')
  static GetVotesResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetVotesResponse>(GetVotesResponse.$_createMessage);
  static GetVotesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  VotePolicy get policy => $_getN(0);
  @$pb.TagNumber(1)
  set policy(VotePolicy value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPolicy() => $_has(0);
  @$pb.TagNumber(1)
  void clearPolicy() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<BundleUpvote> get upvotes => $_getList(1);
}

class SetBundleUpvoteRequest extends $pb.GeneratedMessage {
  factory SetBundleUpvoteRequest({
    $core.int? sidechainSlot,
    $core.String? m6id,
  }) {
    final result = SetBundleUpvoteRequest._();
    if (sidechainSlot != null) result.sidechainSlot = sidechainSlot;
    if (m6id != null) result.m6id = m6id;
    return result;
  }

  SetBundleUpvoteRequest._();

  factory SetBundleUpvoteRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetBundleUpvoteRequest()..mergeFromBuffer(data, registry);
  factory SetBundleUpvoteRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetBundleUpvoteRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetBundleUpvoteRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'm4.v1'),
      createEmptyInstance: SetBundleUpvoteRequest.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'sidechainSlot', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'm6id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetBundleUpvoteRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetBundleUpvoteRequest copyWith(void Function(SetBundleUpvoteRequest) updates) =>
      super.copyWith((message) => updates(message as SetBundleUpvoteRequest)) as SetBundleUpvoteRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetBundleUpvoteRequest() / SetBundleUpvoteRequest.new instead')
  static SetBundleUpvoteRequest create() => SetBundleUpvoteRequest._();
  static $pb.GeneratedMessage $_createMessage() => SetBundleUpvoteRequest._();
  @$core.override
  SetBundleUpvoteRequest createEmptyInstance() => SetBundleUpvoteRequest._();
  @$core.pragma('dart2js:noInline')
  static SetBundleUpvoteRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetBundleUpvoteRequest>(SetBundleUpvoteRequest.$_createMessage);
  static SetBundleUpvoteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get sidechainSlot => $_getIZ(0);
  @$pb.TagNumber(1)
  set sidechainSlot($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSidechainSlot() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainSlot() => $_clearField(1);

  /// Unset clears the upvote, so the sidechain gets the policy vote.
  @$pb.TagNumber(2)
  $core.String get m6id => $_getSZ(1);
  @$pb.TagNumber(2)
  set m6id($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasM6id() => $_has(1);
  @$pb.TagNumber(2)
  void clearM6id() => $_clearField(2);
}

class SetBundleUpvoteResponse extends $pb.GeneratedMessage {
  factory SetBundleUpvoteResponse() => SetBundleUpvoteResponse._();

  SetBundleUpvoteResponse._();

  factory SetBundleUpvoteResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetBundleUpvoteResponse()..mergeFromBuffer(data, registry);
  factory SetBundleUpvoteResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetBundleUpvoteResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetBundleUpvoteResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'm4.v1'),
      createEmptyInstance: SetBundleUpvoteResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetBundleUpvoteResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetBundleUpvoteResponse copyWith(void Function(SetBundleUpvoteResponse) updates) =>
      super.copyWith((message) => updates(message as SetBundleUpvoteResponse)) as SetBundleUpvoteResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetBundleUpvoteResponse() / SetBundleUpvoteResponse.new instead')
  static SetBundleUpvoteResponse create() => SetBundleUpvoteResponse._();
  static $pb.GeneratedMessage $_createMessage() => SetBundleUpvoteResponse._();
  @$core.override
  SetBundleUpvoteResponse createEmptyInstance() => SetBundleUpvoteResponse._();
  @$core.pragma('dart2js:noInline')
  static SetBundleUpvoteResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetBundleUpvoteResponse>(SetBundleUpvoteResponse.$_createMessage);
  static SetBundleUpvoteResponse? _defaultInstance;
}

class SetVotePolicyRequest extends $pb.GeneratedMessage {
  factory SetVotePolicyRequest({
    VotePolicy? policy,
  }) {
    final result = SetVotePolicyRequest._();
    if (policy != null) result.policy = policy;
    return result;
  }

  SetVotePolicyRequest._();

  factory SetVotePolicyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetVotePolicyRequest()..mergeFromBuffer(data, registry);
  factory SetVotePolicyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetVotePolicyRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetVotePolicyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'm4.v1'),
      createEmptyInstance: SetVotePolicyRequest.$_createMessage)
    ..aE<VotePolicy>(1, _omitFieldNames ? '' : 'policy', enumValues: VotePolicy.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetVotePolicyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetVotePolicyRequest copyWith(void Function(SetVotePolicyRequest) updates) =>
      super.copyWith((message) => updates(message as SetVotePolicyRequest)) as SetVotePolicyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetVotePolicyRequest() / SetVotePolicyRequest.new instead')
  static SetVotePolicyRequest create() => SetVotePolicyRequest._();
  static $pb.GeneratedMessage $_createMessage() => SetVotePolicyRequest._();
  @$core.override
  SetVotePolicyRequest createEmptyInstance() => SetVotePolicyRequest._();
  @$core.pragma('dart2js:noInline')
  static SetVotePolicyRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetVotePolicyRequest>(SetVotePolicyRequest.$_createMessage);
  static SetVotePolicyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  VotePolicy get policy => $_getN(0);
  @$pb.TagNumber(1)
  set policy(VotePolicy value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasPolicy() => $_has(0);
  @$pb.TagNumber(1)
  void clearPolicy() => $_clearField(1);
}

class SetVotePolicyResponse extends $pb.GeneratedMessage {
  factory SetVotePolicyResponse() => SetVotePolicyResponse._();

  SetVotePolicyResponse._();

  factory SetVotePolicyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetVotePolicyResponse()..mergeFromBuffer(data, registry);
  factory SetVotePolicyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetVotePolicyResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetVotePolicyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'm4.v1'),
      createEmptyInstance: SetVotePolicyResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetVotePolicyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetVotePolicyResponse copyWith(void Function(SetVotePolicyResponse) updates) =>
      super.copyWith((message) => updates(message as SetVotePolicyResponse)) as SetVotePolicyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetVotePolicyResponse() / SetVotePolicyResponse.new instead')
  static SetVotePolicyResponse create() => SetVotePolicyResponse._();
  static $pb.GeneratedMessage $_createMessage() => SetVotePolicyResponse._();
  @$core.override
  SetVotePolicyResponse createEmptyInstance() => SetVotePolicyResponse._();
  @$core.pragma('dart2js:noInline')
  static SetVotePolicyResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetVotePolicyResponse>(SetVotePolicyResponse.$_createMessage);
  static SetVotePolicyResponse? _defaultInstance;
}

/// M4 Explorer Service
class M4ServiceApi {
  final $pb.RpcClient _client;

  M4ServiceApi(this._client);

  /// Get M4 voting history
  $async.Future<GetM4HistoryResponse> getM4History($pb.ClientContext? ctx, GetM4HistoryRequest request) =>
      _client.invoke<GetM4HistoryResponse>(ctx, 'M4Service', 'GetM4History', request, GetM4HistoryResponse());

  /// Get the votes the enforcer puts in the next block it builds.
  $async.Future<GetVotesResponse> getVotes($pb.ClientContext? ctx, GetVotesRequest request) =>
      _client.invoke<GetVotesResponse>(ctx, 'M4Service', 'GetVotes', request, GetVotesResponse());

  /// Upvote one pending bundle of a sidechain, or clear the upvote.
  $async.Future<SetBundleUpvoteResponse> setBundleUpvote($pb.ClientContext? ctx, SetBundleUpvoteRequest request) =>
      _client.invoke<SetBundleUpvoteResponse>(ctx, 'M4Service', 'SetBundleUpvote', request, SetBundleUpvoteResponse());

  /// Set the vote for a sidechain that has no upvote.
  $async.Future<SetVotePolicyResponse> setVotePolicy($pb.ClientContext? ctx, SetVotePolicyRequest request) =>
      _client.invoke<SetVotePolicyResponse>(ctx, 'M4Service', 'SetVotePolicy', request, SetVotePolicyResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
