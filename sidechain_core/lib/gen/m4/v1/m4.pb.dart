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

import 'm4.pbenum.dart';

export 'm4.pbenum.dart';

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

class BundleUpvote extends $pb.GeneratedMessage {
  factory BundleUpvote({
    $core.int? sidechainSlot,
    $core.String? m6id,
  }) {
    final $result = create();
    if (sidechainSlot != null) {
      $result.sidechainSlot = sidechainSlot;
    }
    if (m6id != null) {
      $result.m6id = m6id;
    }
    return $result;
  }
  BundleUpvote._() : super();
  factory BundleUpvote.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BundleUpvote.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BundleUpvote', package: const $pb.PackageName(_omitMessageNames ? '' : 'm4.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'sidechainSlot', $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'm6id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BundleUpvote clone() => BundleUpvote()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BundleUpvote copyWith(void Function(BundleUpvote) updates) => super.copyWith((message) => updates(message as BundleUpvote)) as BundleUpvote;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BundleUpvote create() => BundleUpvote._();
  BundleUpvote createEmptyInstance() => create();
  static $pb.PbList<BundleUpvote> createRepeated() => $pb.PbList<BundleUpvote>();
  @$core.pragma('dart2js:noInline')
  static BundleUpvote getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BundleUpvote>(create);
  static BundleUpvote? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get sidechainSlot => $_getIZ(0);
  @$pb.TagNumber(1)
  set sidechainSlot($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechainSlot() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainSlot() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get m6id => $_getSZ(1);
  @$pb.TagNumber(2)
  set m6id($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasM6id() => $_has(1);
  @$pb.TagNumber(2)
  void clearM6id() => clearField(2);
}

class GetVotesRequest extends $pb.GeneratedMessage {
  factory GetVotesRequest() => create();
  GetVotesRequest._() : super();
  factory GetVotesRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetVotesRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetVotesRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'm4.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetVotesRequest clone() => GetVotesRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetVotesRequest copyWith(void Function(GetVotesRequest) updates) => super.copyWith((message) => updates(message as GetVotesRequest)) as GetVotesRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetVotesRequest create() => GetVotesRequest._();
  GetVotesRequest createEmptyInstance() => create();
  static $pb.PbList<GetVotesRequest> createRepeated() => $pb.PbList<GetVotesRequest>();
  @$core.pragma('dart2js:noInline')
  static GetVotesRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetVotesRequest>(create);
  static GetVotesRequest? _defaultInstance;
}

class GetVotesResponse extends $pb.GeneratedMessage {
  factory GetVotesResponse({
    VotePolicy? policy,
    $core.Iterable<BundleUpvote>? upvotes,
  }) {
    final $result = create();
    if (policy != null) {
      $result.policy = policy;
    }
    if (upvotes != null) {
      $result.upvotes.addAll(upvotes);
    }
    return $result;
  }
  GetVotesResponse._() : super();
  factory GetVotesResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetVotesResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetVotesResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'm4.v1'), createEmptyInstance: create)
    ..e<VotePolicy>(1, _omitFieldNames ? '' : 'policy', $pb.PbFieldType.OE, defaultOrMaker: VotePolicy.VOTE_POLICY_UNSPECIFIED, valueOf: VotePolicy.valueOf, enumValues: VotePolicy.values)
    ..pc<BundleUpvote>(2, _omitFieldNames ? '' : 'upvotes', $pb.PbFieldType.PM, subBuilder: BundleUpvote.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetVotesResponse clone() => GetVotesResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetVotesResponse copyWith(void Function(GetVotesResponse) updates) => super.copyWith((message) => updates(message as GetVotesResponse)) as GetVotesResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetVotesResponse create() => GetVotesResponse._();
  GetVotesResponse createEmptyInstance() => create();
  static $pb.PbList<GetVotesResponse> createRepeated() => $pb.PbList<GetVotesResponse>();
  @$core.pragma('dart2js:noInline')
  static GetVotesResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetVotesResponse>(create);
  static GetVotesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  VotePolicy get policy => $_getN(0);
  @$pb.TagNumber(1)
  set policy(VotePolicy v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasPolicy() => $_has(0);
  @$pb.TagNumber(1)
  void clearPolicy() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<BundleUpvote> get upvotes => $_getList(1);
}

class SetBundleUpvoteRequest extends $pb.GeneratedMessage {
  factory SetBundleUpvoteRequest({
    $core.int? sidechainSlot,
    $core.String? m6id,
  }) {
    final $result = create();
    if (sidechainSlot != null) {
      $result.sidechainSlot = sidechainSlot;
    }
    if (m6id != null) {
      $result.m6id = m6id;
    }
    return $result;
  }
  SetBundleUpvoteRequest._() : super();
  factory SetBundleUpvoteRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetBundleUpvoteRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetBundleUpvoteRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'm4.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'sidechainSlot', $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'm6id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetBundleUpvoteRequest clone() => SetBundleUpvoteRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetBundleUpvoteRequest copyWith(void Function(SetBundleUpvoteRequest) updates) => super.copyWith((message) => updates(message as SetBundleUpvoteRequest)) as SetBundleUpvoteRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetBundleUpvoteRequest create() => SetBundleUpvoteRequest._();
  SetBundleUpvoteRequest createEmptyInstance() => create();
  static $pb.PbList<SetBundleUpvoteRequest> createRepeated() => $pb.PbList<SetBundleUpvoteRequest>();
  @$core.pragma('dart2js:noInline')
  static SetBundleUpvoteRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetBundleUpvoteRequest>(create);
  static SetBundleUpvoteRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get sidechainSlot => $_getIZ(0);
  @$pb.TagNumber(1)
  set sidechainSlot($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechainSlot() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainSlot() => clearField(1);

  /// Unset clears the upvote, so the sidechain gets the policy vote.
  @$pb.TagNumber(2)
  $core.String get m6id => $_getSZ(1);
  @$pb.TagNumber(2)
  set m6id($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasM6id() => $_has(1);
  @$pb.TagNumber(2)
  void clearM6id() => clearField(2);
}

class SetBundleUpvoteResponse extends $pb.GeneratedMessage {
  factory SetBundleUpvoteResponse() => create();
  SetBundleUpvoteResponse._() : super();
  factory SetBundleUpvoteResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetBundleUpvoteResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetBundleUpvoteResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'm4.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetBundleUpvoteResponse clone() => SetBundleUpvoteResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetBundleUpvoteResponse copyWith(void Function(SetBundleUpvoteResponse) updates) => super.copyWith((message) => updates(message as SetBundleUpvoteResponse)) as SetBundleUpvoteResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetBundleUpvoteResponse create() => SetBundleUpvoteResponse._();
  SetBundleUpvoteResponse createEmptyInstance() => create();
  static $pb.PbList<SetBundleUpvoteResponse> createRepeated() => $pb.PbList<SetBundleUpvoteResponse>();
  @$core.pragma('dart2js:noInline')
  static SetBundleUpvoteResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetBundleUpvoteResponse>(create);
  static SetBundleUpvoteResponse? _defaultInstance;
}

class SetVotePolicyRequest extends $pb.GeneratedMessage {
  factory SetVotePolicyRequest({
    VotePolicy? policy,
  }) {
    final $result = create();
    if (policy != null) {
      $result.policy = policy;
    }
    return $result;
  }
  SetVotePolicyRequest._() : super();
  factory SetVotePolicyRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetVotePolicyRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetVotePolicyRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'm4.v1'), createEmptyInstance: create)
    ..e<VotePolicy>(1, _omitFieldNames ? '' : 'policy', $pb.PbFieldType.OE, defaultOrMaker: VotePolicy.VOTE_POLICY_UNSPECIFIED, valueOf: VotePolicy.valueOf, enumValues: VotePolicy.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetVotePolicyRequest clone() => SetVotePolicyRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetVotePolicyRequest copyWith(void Function(SetVotePolicyRequest) updates) => super.copyWith((message) => updates(message as SetVotePolicyRequest)) as SetVotePolicyRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetVotePolicyRequest create() => SetVotePolicyRequest._();
  SetVotePolicyRequest createEmptyInstance() => create();
  static $pb.PbList<SetVotePolicyRequest> createRepeated() => $pb.PbList<SetVotePolicyRequest>();
  @$core.pragma('dart2js:noInline')
  static SetVotePolicyRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetVotePolicyRequest>(create);
  static SetVotePolicyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  VotePolicy get policy => $_getN(0);
  @$pb.TagNumber(1)
  set policy(VotePolicy v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasPolicy() => $_has(0);
  @$pb.TagNumber(1)
  void clearPolicy() => clearField(1);
}

class SetVotePolicyResponse extends $pb.GeneratedMessage {
  factory SetVotePolicyResponse() => create();
  SetVotePolicyResponse._() : super();
  factory SetVotePolicyResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetVotePolicyResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetVotePolicyResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'm4.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetVotePolicyResponse clone() => SetVotePolicyResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetVotePolicyResponse copyWith(void Function(SetVotePolicyResponse) updates) => super.copyWith((message) => updates(message as SetVotePolicyResponse)) as SetVotePolicyResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetVotePolicyResponse create() => SetVotePolicyResponse._();
  SetVotePolicyResponse createEmptyInstance() => create();
  static $pb.PbList<SetVotePolicyResponse> createRepeated() => $pb.PbList<SetVotePolicyResponse>();
  @$core.pragma('dart2js:noInline')
  static SetVotePolicyResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetVotePolicyResponse>(create);
  static SetVotePolicyResponse? _defaultInstance;
}

class M4ServiceApi {
  $pb.RpcClient _client;
  M4ServiceApi(this._client);

  $async.Future<GetM4HistoryResponse> getM4History($pb.ClientContext? ctx, GetM4HistoryRequest request) =>
    _client.invoke<GetM4HistoryResponse>(ctx, 'M4Service', 'GetM4History', request, GetM4HistoryResponse())
  ;
  $async.Future<GetVotesResponse> getVotes($pb.ClientContext? ctx, GetVotesRequest request) =>
    _client.invoke<GetVotesResponse>(ctx, 'M4Service', 'GetVotes', request, GetVotesResponse())
  ;
  $async.Future<SetBundleUpvoteResponse> setBundleUpvote($pb.ClientContext? ctx, SetBundleUpvoteRequest request) =>
    _client.invoke<SetBundleUpvoteResponse>(ctx, 'M4Service', 'SetBundleUpvote', request, SetBundleUpvoteResponse())
  ;
  $async.Future<SetVotePolicyResponse> setVotePolicy($pb.ClientContext? ctx, SetVotePolicyRequest request) =>
    _client.invoke<SetVotePolicyResponse>(ctx, 'M4Service', 'SetVotePolicy', request, SetVotePolicyResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
