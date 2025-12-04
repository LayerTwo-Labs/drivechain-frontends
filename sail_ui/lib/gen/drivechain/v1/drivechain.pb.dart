//
//  Generated code. Do not modify.
//  source: drivechain/v1/drivechain.proto
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

class ListSidechainsRequest extends $pb.GeneratedMessage {
  factory ListSidechainsRequest() => create();
  ListSidechainsRequest._() : super();
  factory ListSidechainsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListSidechainsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSidechainsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListSidechainsRequest clone() => ListSidechainsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListSidechainsRequest copyWith(void Function(ListSidechainsRequest) updates) => super.copyWith((message) => updates(message as ListSidechainsRequest)) as ListSidechainsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSidechainsRequest create() => ListSidechainsRequest._();
  ListSidechainsRequest createEmptyInstance() => create();
  static $pb.PbList<ListSidechainsRequest> createRepeated() => $pb.PbList<ListSidechainsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListSidechainsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListSidechainsRequest>(create);
  static ListSidechainsRequest? _defaultInstance;
}

class ListSidechainsResponse_Sidechain extends $pb.GeneratedMessage {
  factory ListSidechainsResponse_Sidechain({
    $core.String? title,
    $core.String? description,
    $core.int? nversion,
    $core.String? hashid1,
    $core.String? hashid2,
    $core.int? slot,
    $core.int? voteCount,
    $core.int? proposalHeight,
    $core.int? activationHeight,
    $core.String? descriptionHex,
    $fixnum.Int64? balanceSatoshi,
    $core.String? chaintipTxid,
    $core.int? chaintipVout,
  }) {
    final $result = create();
    if (title != null) {
      $result.title = title;
    }
    if (description != null) {
      $result.description = description;
    }
    if (nversion != null) {
      $result.nversion = nversion;
    }
    if (hashid1 != null) {
      $result.hashid1 = hashid1;
    }
    if (hashid2 != null) {
      $result.hashid2 = hashid2;
    }
    if (slot != null) {
      $result.slot = slot;
    }
    if (voteCount != null) {
      $result.voteCount = voteCount;
    }
    if (proposalHeight != null) {
      $result.proposalHeight = proposalHeight;
    }
    if (activationHeight != null) {
      $result.activationHeight = activationHeight;
    }
    if (descriptionHex != null) {
      $result.descriptionHex = descriptionHex;
    }
    if (balanceSatoshi != null) {
      $result.balanceSatoshi = balanceSatoshi;
    }
    if (chaintipTxid != null) {
      $result.chaintipTxid = chaintipTxid;
    }
    if (chaintipVout != null) {
      $result.chaintipVout = chaintipVout;
    }
    return $result;
  }
  ListSidechainsResponse_Sidechain._() : super();
  factory ListSidechainsResponse_Sidechain.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListSidechainsResponse_Sidechain.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSidechainsResponse.Sidechain', package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'title')
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'nversion', $pb.PbFieldType.OU3)
    ..aOS(4, _omitFieldNames ? '' : 'hashid1')
    ..aOS(5, _omitFieldNames ? '' : 'hashid2')
    ..a<$core.int>(6, _omitFieldNames ? '' : 'slot', $pb.PbFieldType.OU3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'voteCount', $pb.PbFieldType.OU3)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'proposalHeight', $pb.PbFieldType.OU3)
    ..a<$core.int>(9, _omitFieldNames ? '' : 'activationHeight', $pb.PbFieldType.OU3)
    ..aOS(10, _omitFieldNames ? '' : 'descriptionHex')
    ..aInt64(11, _omitFieldNames ? '' : 'balanceSatoshi')
    ..aOS(12, _omitFieldNames ? '' : 'chaintipTxid')
    ..a<$core.int>(13, _omitFieldNames ? '' : 'chaintipVout', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListSidechainsResponse_Sidechain clone() => ListSidechainsResponse_Sidechain()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListSidechainsResponse_Sidechain copyWith(void Function(ListSidechainsResponse_Sidechain) updates) => super.copyWith((message) => updates(message as ListSidechainsResponse_Sidechain)) as ListSidechainsResponse_Sidechain;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSidechainsResponse_Sidechain create() => ListSidechainsResponse_Sidechain._();
  ListSidechainsResponse_Sidechain createEmptyInstance() => create();
  static $pb.PbList<ListSidechainsResponse_Sidechain> createRepeated() => $pb.PbList<ListSidechainsResponse_Sidechain>();
  @$core.pragma('dart2js:noInline')
  static ListSidechainsResponse_Sidechain getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListSidechainsResponse_Sidechain>(create);
  static ListSidechainsResponse_Sidechain? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get title => $_getSZ(0);
  @$pb.TagNumber(1)
  set title($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTitle() => $_has(0);
  @$pb.TagNumber(1)
  void clearTitle() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get nversion => $_getIZ(2);
  @$pb.TagNumber(3)
  set nversion($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasNversion() => $_has(2);
  @$pb.TagNumber(3)
  void clearNversion() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get hashid1 => $_getSZ(3);
  @$pb.TagNumber(4)
  set hashid1($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasHashid1() => $_has(3);
  @$pb.TagNumber(4)
  void clearHashid1() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get hashid2 => $_getSZ(4);
  @$pb.TagNumber(5)
  set hashid2($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasHashid2() => $_has(4);
  @$pb.TagNumber(5)
  void clearHashid2() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get slot => $_getIZ(5);
  @$pb.TagNumber(6)
  set slot($core.int v) { $_setUnsignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasSlot() => $_has(5);
  @$pb.TagNumber(6)
  void clearSlot() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get voteCount => $_getIZ(6);
  @$pb.TagNumber(7)
  set voteCount($core.int v) { $_setUnsignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasVoteCount() => $_has(6);
  @$pb.TagNumber(7)
  void clearVoteCount() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get proposalHeight => $_getIZ(7);
  @$pb.TagNumber(8)
  set proposalHeight($core.int v) { $_setUnsignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasProposalHeight() => $_has(7);
  @$pb.TagNumber(8)
  void clearProposalHeight() => clearField(8);

  @$pb.TagNumber(9)
  $core.int get activationHeight => $_getIZ(8);
  @$pb.TagNumber(9)
  set activationHeight($core.int v) { $_setUnsignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasActivationHeight() => $_has(8);
  @$pb.TagNumber(9)
  void clearActivationHeight() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get descriptionHex => $_getSZ(9);
  @$pb.TagNumber(10)
  set descriptionHex($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasDescriptionHex() => $_has(9);
  @$pb.TagNumber(10)
  void clearDescriptionHex() => clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get balanceSatoshi => $_getI64(10);
  @$pb.TagNumber(11)
  set balanceSatoshi($fixnum.Int64 v) { $_setInt64(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasBalanceSatoshi() => $_has(10);
  @$pb.TagNumber(11)
  void clearBalanceSatoshi() => clearField(11);

  @$pb.TagNumber(12)
  $core.String get chaintipTxid => $_getSZ(11);
  @$pb.TagNumber(12)
  set chaintipTxid($core.String v) { $_setString(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasChaintipTxid() => $_has(11);
  @$pb.TagNumber(12)
  void clearChaintipTxid() => clearField(12);

  @$pb.TagNumber(13)
  $core.int get chaintipVout => $_getIZ(12);
  @$pb.TagNumber(13)
  set chaintipVout($core.int v) { $_setUnsignedInt32(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasChaintipVout() => $_has(12);
  @$pb.TagNumber(13)
  void clearChaintipVout() => clearField(13);
}

class ListSidechainsResponse extends $pb.GeneratedMessage {
  factory ListSidechainsResponse({
    $core.Iterable<ListSidechainsResponse_Sidechain>? sidechains,
  }) {
    final $result = create();
    if (sidechains != null) {
      $result.sidechains.addAll(sidechains);
    }
    return $result;
  }
  ListSidechainsResponse._() : super();
  factory ListSidechainsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListSidechainsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSidechainsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'), createEmptyInstance: create)
    ..pc<ListSidechainsResponse_Sidechain>(1, _omitFieldNames ? '' : 'sidechains', $pb.PbFieldType.PM, subBuilder: ListSidechainsResponse_Sidechain.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListSidechainsResponse clone() => ListSidechainsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListSidechainsResponse copyWith(void Function(ListSidechainsResponse) updates) => super.copyWith((message) => updates(message as ListSidechainsResponse)) as ListSidechainsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSidechainsResponse create() => ListSidechainsResponse._();
  ListSidechainsResponse createEmptyInstance() => create();
  static $pb.PbList<ListSidechainsResponse> createRepeated() => $pb.PbList<ListSidechainsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListSidechainsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListSidechainsResponse>(create);
  static ListSidechainsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ListSidechainsResponse_Sidechain> get sidechains => $_getList(0);
}

class ListSidechainProposalsRequest extends $pb.GeneratedMessage {
  factory ListSidechainProposalsRequest() => create();
  ListSidechainProposalsRequest._() : super();
  factory ListSidechainProposalsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListSidechainProposalsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSidechainProposalsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListSidechainProposalsRequest clone() => ListSidechainProposalsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListSidechainProposalsRequest copyWith(void Function(ListSidechainProposalsRequest) updates) => super.copyWith((message) => updates(message as ListSidechainProposalsRequest)) as ListSidechainProposalsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSidechainProposalsRequest create() => ListSidechainProposalsRequest._();
  ListSidechainProposalsRequest createEmptyInstance() => create();
  static $pb.PbList<ListSidechainProposalsRequest> createRepeated() => $pb.PbList<ListSidechainProposalsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListSidechainProposalsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListSidechainProposalsRequest>(create);
  static ListSidechainProposalsRequest? _defaultInstance;
}

class SidechainProposal extends $pb.GeneratedMessage {
  factory SidechainProposal({
    $core.int? slot,
    $core.List<$core.int>? data,
    $core.String? dataHash,
    $core.int? voteCount,
    $core.int? proposalHeight,
    $core.int? proposalAge,
  }) {
    final $result = create();
    if (slot != null) {
      $result.slot = slot;
    }
    if (data != null) {
      $result.data = data;
    }
    if (dataHash != null) {
      $result.dataHash = dataHash;
    }
    if (voteCount != null) {
      $result.voteCount = voteCount;
    }
    if (proposalHeight != null) {
      $result.proposalHeight = proposalHeight;
    }
    if (proposalAge != null) {
      $result.proposalAge = proposalAge;
    }
    return $result;
  }
  SidechainProposal._() : super();
  factory SidechainProposal.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SidechainProposal.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SidechainProposal', package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'slot', $pb.PbFieldType.OU3)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..aOS(3, _omitFieldNames ? '' : 'dataHash')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'voteCount', $pb.PbFieldType.OU3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'proposalHeight', $pb.PbFieldType.OU3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'proposalAge', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SidechainProposal clone() => SidechainProposal()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SidechainProposal copyWith(void Function(SidechainProposal) updates) => super.copyWith((message) => updates(message as SidechainProposal)) as SidechainProposal;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SidechainProposal create() => SidechainProposal._();
  SidechainProposal createEmptyInstance() => create();
  static $pb.PbList<SidechainProposal> createRepeated() => $pb.PbList<SidechainProposal>();
  @$core.pragma('dart2js:noInline')
  static SidechainProposal getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SidechainProposal>(create);
  static SidechainProposal? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get slot => $_getIZ(0);
  @$pb.TagNumber(1)
  set slot($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSlot() => $_has(0);
  @$pb.TagNumber(1)
  void clearSlot() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get data => $_getN(1);
  @$pb.TagNumber(2)
  set data($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get dataHash => $_getSZ(2);
  @$pb.TagNumber(3)
  set dataHash($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDataHash() => $_has(2);
  @$pb.TagNumber(3)
  void clearDataHash() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get voteCount => $_getIZ(3);
  @$pb.TagNumber(4)
  set voteCount($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasVoteCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearVoteCount() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get proposalHeight => $_getIZ(4);
  @$pb.TagNumber(5)
  set proposalHeight($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasProposalHeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearProposalHeight() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get proposalAge => $_getIZ(5);
  @$pb.TagNumber(6)
  set proposalAge($core.int v) { $_setUnsignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasProposalAge() => $_has(5);
  @$pb.TagNumber(6)
  void clearProposalAge() => clearField(6);
}

class ListSidechainProposalsResponse extends $pb.GeneratedMessage {
  factory ListSidechainProposalsResponse({
    $core.Iterable<SidechainProposal>? proposals,
  }) {
    final $result = create();
    if (proposals != null) {
      $result.proposals.addAll(proposals);
    }
    return $result;
  }
  ListSidechainProposalsResponse._() : super();
  factory ListSidechainProposalsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListSidechainProposalsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSidechainProposalsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'), createEmptyInstance: create)
    ..pc<SidechainProposal>(1, _omitFieldNames ? '' : 'proposals', $pb.PbFieldType.PM, subBuilder: SidechainProposal.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListSidechainProposalsResponse clone() => ListSidechainProposalsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListSidechainProposalsResponse copyWith(void Function(ListSidechainProposalsResponse) updates) => super.copyWith((message) => updates(message as ListSidechainProposalsResponse)) as ListSidechainProposalsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSidechainProposalsResponse create() => ListSidechainProposalsResponse._();
  ListSidechainProposalsResponse createEmptyInstance() => create();
  static $pb.PbList<ListSidechainProposalsResponse> createRepeated() => $pb.PbList<ListSidechainProposalsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListSidechainProposalsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListSidechainProposalsResponse>(create);
  static ListSidechainProposalsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<SidechainProposal> get proposals => $_getList(0);
}

class ProposeSidechainRequest extends $pb.GeneratedMessage {
  factory ProposeSidechainRequest({
    $core.int? slot,
    $core.String? title,
    $core.String? description,
    $core.int? version,
    $core.String? hashid1,
    $core.String? hashid2,
  }) {
    final $result = create();
    if (slot != null) {
      $result.slot = slot;
    }
    if (title != null) {
      $result.title = title;
    }
    if (description != null) {
      $result.description = description;
    }
    if (version != null) {
      $result.version = version;
    }
    if (hashid1 != null) {
      $result.hashid1 = hashid1;
    }
    if (hashid2 != null) {
      $result.hashid2 = hashid2;
    }
    return $result;
  }
  ProposeSidechainRequest._() : super();
  factory ProposeSidechainRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ProposeSidechainRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ProposeSidechainRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'slot', $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'title')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'version', $pb.PbFieldType.OU3)
    ..aOS(5, _omitFieldNames ? '' : 'hashid1')
    ..aOS(6, _omitFieldNames ? '' : 'hashid2')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ProposeSidechainRequest clone() => ProposeSidechainRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ProposeSidechainRequest copyWith(void Function(ProposeSidechainRequest) updates) => super.copyWith((message) => updates(message as ProposeSidechainRequest)) as ProposeSidechainRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProposeSidechainRequest create() => ProposeSidechainRequest._();
  ProposeSidechainRequest createEmptyInstance() => create();
  static $pb.PbList<ProposeSidechainRequest> createRepeated() => $pb.PbList<ProposeSidechainRequest>();
  @$core.pragma('dart2js:noInline')
  static ProposeSidechainRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProposeSidechainRequest>(create);
  static ProposeSidechainRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get slot => $_getIZ(0);
  @$pb.TagNumber(1)
  set slot($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSlot() => $_has(0);
  @$pb.TagNumber(1)
  void clearSlot() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get version => $_getIZ(3);
  @$pb.TagNumber(4)
  set version($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearVersion() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get hashid1 => $_getSZ(4);
  @$pb.TagNumber(5)
  set hashid1($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasHashid1() => $_has(4);
  @$pb.TagNumber(5)
  void clearHashid1() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get hashid2 => $_getSZ(5);
  @$pb.TagNumber(6)
  set hashid2($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasHashid2() => $_has(5);
  @$pb.TagNumber(6)
  void clearHashid2() => clearField(6);
}

class ProposeSidechainResponse extends $pb.GeneratedMessage {
  factory ProposeSidechainResponse({
    $core.bool? success,
    $core.String? proposalHash,
    $core.String? message,
  }) {
    final $result = create();
    if (success != null) {
      $result.success = success;
    }
    if (proposalHash != null) {
      $result.proposalHash = proposalHash;
    }
    if (message != null) {
      $result.message = message;
    }
    return $result;
  }
  ProposeSidechainResponse._() : super();
  factory ProposeSidechainResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ProposeSidechainResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ProposeSidechainResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'proposalHash')
    ..aOS(3, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ProposeSidechainResponse clone() => ProposeSidechainResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ProposeSidechainResponse copyWith(void Function(ProposeSidechainResponse) updates) => super.copyWith((message) => updates(message as ProposeSidechainResponse)) as ProposeSidechainResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProposeSidechainResponse create() => ProposeSidechainResponse._();
  ProposeSidechainResponse createEmptyInstance() => create();
  static $pb.PbList<ProposeSidechainResponse> createRepeated() => $pb.PbList<ProposeSidechainResponse>();
  @$core.pragma('dart2js:noInline')
  static ProposeSidechainResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProposeSidechainResponse>(create);
  static ProposeSidechainResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get proposalHash => $_getSZ(1);
  @$pb.TagNumber(2)
  set proposalHash($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasProposalHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearProposalHash() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get message => $_getSZ(2);
  @$pb.TagNumber(3)
  set message($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessage() => clearField(3);
}

class ListWithdrawalsRequest extends $pb.GeneratedMessage {
  factory ListWithdrawalsRequest({
    $core.int? sidechainId,
    $core.int? startBlockHeight,
    $core.int? endBlockHeight,
  }) {
    final $result = create();
    if (sidechainId != null) {
      $result.sidechainId = sidechainId;
    }
    if (startBlockHeight != null) {
      $result.startBlockHeight = startBlockHeight;
    }
    if (endBlockHeight != null) {
      $result.endBlockHeight = endBlockHeight;
    }
    return $result;
  }
  ListWithdrawalsRequest._() : super();
  factory ListWithdrawalsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListWithdrawalsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListWithdrawalsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'sidechainId', $pb.PbFieldType.OU3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'startBlockHeight', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'endBlockHeight', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListWithdrawalsRequest clone() => ListWithdrawalsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListWithdrawalsRequest copyWith(void Function(ListWithdrawalsRequest) updates) => super.copyWith((message) => updates(message as ListWithdrawalsRequest)) as ListWithdrawalsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListWithdrawalsRequest create() => ListWithdrawalsRequest._();
  ListWithdrawalsRequest createEmptyInstance() => create();
  static $pb.PbList<ListWithdrawalsRequest> createRepeated() => $pb.PbList<ListWithdrawalsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListWithdrawalsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListWithdrawalsRequest>(create);
  static ListWithdrawalsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get sidechainId => $_getIZ(0);
  @$pb.TagNumber(1)
  set sidechainId($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechainId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainId() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get startBlockHeight => $_getIZ(1);
  @$pb.TagNumber(2)
  set startBlockHeight($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasStartBlockHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartBlockHeight() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get endBlockHeight => $_getIZ(2);
  @$pb.TagNumber(3)
  set endBlockHeight($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasEndBlockHeight() => $_has(2);
  @$pb.TagNumber(3)
  void clearEndBlockHeight() => clearField(3);
}

class WithdrawalBundle extends $pb.GeneratedMessage {
  factory WithdrawalBundle({
    $core.String? m6id,
    $core.int? sidechainId,
    $core.String? status,
    $fixnum.Int64? sequenceNumber,
    $core.String? transactionHex,
    $core.int? blockHeight,
    $core.int? age,
    $core.int? maxAge,
    $core.int? blocksLeft,
  }) {
    final $result = create();
    if (m6id != null) {
      $result.m6id = m6id;
    }
    if (sidechainId != null) {
      $result.sidechainId = sidechainId;
    }
    if (status != null) {
      $result.status = status;
    }
    if (sequenceNumber != null) {
      $result.sequenceNumber = sequenceNumber;
    }
    if (transactionHex != null) {
      $result.transactionHex = transactionHex;
    }
    if (blockHeight != null) {
      $result.blockHeight = blockHeight;
    }
    if (age != null) {
      $result.age = age;
    }
    if (maxAge != null) {
      $result.maxAge = maxAge;
    }
    if (blocksLeft != null) {
      $result.blocksLeft = blocksLeft;
    }
    return $result;
  }
  WithdrawalBundle._() : super();
  factory WithdrawalBundle.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WithdrawalBundle.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawalBundle', package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'm6id')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'sidechainId', $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'status')
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'sequenceNumber', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(5, _omitFieldNames ? '' : 'transactionHex')
    ..a<$core.int>(6, _omitFieldNames ? '' : 'blockHeight', $pb.PbFieldType.OU3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'age', $pb.PbFieldType.OU3)
    ..a<$core.int>(8, _omitFieldNames ? '' : 'maxAge', $pb.PbFieldType.OU3)
    ..a<$core.int>(9, _omitFieldNames ? '' : 'blocksLeft', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WithdrawalBundle clone() => WithdrawalBundle()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WithdrawalBundle copyWith(void Function(WithdrawalBundle) updates) => super.copyWith((message) => updates(message as WithdrawalBundle)) as WithdrawalBundle;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WithdrawalBundle create() => WithdrawalBundle._();
  WithdrawalBundle createEmptyInstance() => create();
  static $pb.PbList<WithdrawalBundle> createRepeated() => $pb.PbList<WithdrawalBundle>();
  @$core.pragma('dart2js:noInline')
  static WithdrawalBundle getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WithdrawalBundle>(create);
  static WithdrawalBundle? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get m6id => $_getSZ(0);
  @$pb.TagNumber(1)
  set m6id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasM6id() => $_has(0);
  @$pb.TagNumber(1)
  void clearM6id() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get sidechainId => $_getIZ(1);
  @$pb.TagNumber(2)
  set sidechainId($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSidechainId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSidechainId() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get status => $_getSZ(2);
  @$pb.TagNumber(3)
  set status($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get sequenceNumber => $_getI64(3);
  @$pb.TagNumber(4)
  set sequenceNumber($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSequenceNumber() => $_has(3);
  @$pb.TagNumber(4)
  void clearSequenceNumber() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get transactionHex => $_getSZ(4);
  @$pb.TagNumber(5)
  set transactionHex($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTransactionHex() => $_has(4);
  @$pb.TagNumber(5)
  void clearTransactionHex() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get blockHeight => $_getIZ(5);
  @$pb.TagNumber(6)
  set blockHeight($core.int v) { $_setUnsignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasBlockHeight() => $_has(5);
  @$pb.TagNumber(6)
  void clearBlockHeight() => clearField(6);

  /// Score tracking fields (BIP300)
  @$pb.TagNumber(7)
  $core.int get age => $_getIZ(6);
  @$pb.TagNumber(7)
  set age($core.int v) { $_setUnsignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasAge() => $_has(6);
  @$pb.TagNumber(7)
  void clearAge() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get maxAge => $_getIZ(7);
  @$pb.TagNumber(8)
  set maxAge($core.int v) { $_setUnsignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasMaxAge() => $_has(7);
  @$pb.TagNumber(8)
  void clearMaxAge() => clearField(8);

  @$pb.TagNumber(9)
  $core.int get blocksLeft => $_getIZ(8);
  @$pb.TagNumber(9)
  set blocksLeft($core.int v) { $_setUnsignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasBlocksLeft() => $_has(8);
  @$pb.TagNumber(9)
  void clearBlocksLeft() => clearField(9);
}

class ListWithdrawalsResponse extends $pb.GeneratedMessage {
  factory ListWithdrawalsResponse({
    $core.Iterable<WithdrawalBundle>? bundles,
  }) {
    final $result = create();
    if (bundles != null) {
      $result.bundles.addAll(bundles);
    }
    return $result;
  }
  ListWithdrawalsResponse._() : super();
  factory ListWithdrawalsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListWithdrawalsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListWithdrawalsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'), createEmptyInstance: create)
    ..pc<WithdrawalBundle>(1, _omitFieldNames ? '' : 'bundles', $pb.PbFieldType.PM, subBuilder: WithdrawalBundle.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListWithdrawalsResponse clone() => ListWithdrawalsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListWithdrawalsResponse copyWith(void Function(ListWithdrawalsResponse) updates) => super.copyWith((message) => updates(message as ListWithdrawalsResponse)) as ListWithdrawalsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListWithdrawalsResponse create() => ListWithdrawalsResponse._();
  ListWithdrawalsResponse createEmptyInstance() => create();
  static $pb.PbList<ListWithdrawalsResponse> createRepeated() => $pb.PbList<ListWithdrawalsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListWithdrawalsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListWithdrawalsResponse>(create);
  static ListWithdrawalsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<WithdrawalBundle> get bundles => $_getList(0);
}

class DrivechainServiceApi {
  $pb.RpcClient _client;
  DrivechainServiceApi(this._client);

  $async.Future<ListSidechainsResponse> listSidechains($pb.ClientContext? ctx, ListSidechainsRequest request) =>
    _client.invoke<ListSidechainsResponse>(ctx, 'DrivechainService', 'ListSidechains', request, ListSidechainsResponse())
  ;
  $async.Future<ListSidechainProposalsResponse> listSidechainProposals($pb.ClientContext? ctx, ListSidechainProposalsRequest request) =>
    _client.invoke<ListSidechainProposalsResponse>(ctx, 'DrivechainService', 'ListSidechainProposals', request, ListSidechainProposalsResponse())
  ;
  $async.Future<ProposeSidechainResponse> proposeSidechain($pb.ClientContext? ctx, ProposeSidechainRequest request) =>
    _client.invoke<ProposeSidechainResponse>(ctx, 'DrivechainService', 'ProposeSidechain', request, ProposeSidechainResponse())
  ;
  $async.Future<ListWithdrawalsResponse> listWithdrawals($pb.ClientContext? ctx, ListWithdrawalsRequest request) =>
    _client.invoke<ListWithdrawalsResponse>(ctx, 'DrivechainService', 'ListWithdrawals', request, ListWithdrawalsResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
