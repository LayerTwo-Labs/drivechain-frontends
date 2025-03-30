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

class DrivechainServiceApi {
  $pb.RpcClient _client;
  DrivechainServiceApi(this._client);

  $async.Future<ListSidechainsResponse> listSidechains($pb.ClientContext? ctx, ListSidechainsRequest request) =>
    _client.invoke<ListSidechainsResponse>(ctx, 'DrivechainService', 'ListSidechains', request, ListSidechainsResponse())
  ;
  $async.Future<ListSidechainProposalsResponse> listSidechainProposals($pb.ClientContext? ctx, ListSidechainProposalsRequest request) =>
    _client.invoke<ListSidechainProposalsResponse>(ctx, 'DrivechainService', 'ListSidechainProposals', request, ListSidechainProposalsResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
