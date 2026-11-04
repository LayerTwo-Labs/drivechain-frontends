// This is a generated file - do not edit.
//
// Generated from drivechain/v1/drivechain.proto.

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

class ListSidechainsRequest extends $pb.GeneratedMessage {
  factory ListSidechainsRequest() => ListSidechainsRequest._();

  ListSidechainsRequest._();

  factory ListSidechainsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSidechainsRequest()..mergeFromBuffer(data, registry);
  factory ListSidechainsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSidechainsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSidechainsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'),
      createEmptyInstance: ListSidechainsRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSidechainsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSidechainsRequest copyWith(void Function(ListSidechainsRequest) updates) =>
      super.copyWith((message) => updates(message as ListSidechainsRequest)) as ListSidechainsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListSidechainsRequest() / ListSidechainsRequest.new instead')
  static ListSidechainsRequest create() => ListSidechainsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListSidechainsRequest._();
  @$core.override
  ListSidechainsRequest createEmptyInstance() => ListSidechainsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListSidechainsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListSidechainsRequest>(ListSidechainsRequest.$_createMessage);
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
    final result = ListSidechainsResponse_Sidechain._();
    if (title != null) result.title = title;
    if (description != null) result.description = description;
    if (nversion != null) result.nversion = nversion;
    if (hashid1 != null) result.hashid1 = hashid1;
    if (hashid2 != null) result.hashid2 = hashid2;
    if (slot != null) result.slot = slot;
    if (voteCount != null) result.voteCount = voteCount;
    if (proposalHeight != null) result.proposalHeight = proposalHeight;
    if (activationHeight != null) result.activationHeight = activationHeight;
    if (descriptionHex != null) result.descriptionHex = descriptionHex;
    if (balanceSatoshi != null) result.balanceSatoshi = balanceSatoshi;
    if (chaintipTxid != null) result.chaintipTxid = chaintipTxid;
    if (chaintipVout != null) result.chaintipVout = chaintipVout;
    return result;
  }

  ListSidechainsResponse_Sidechain._();

  factory ListSidechainsResponse_Sidechain.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSidechainsResponse_Sidechain()..mergeFromBuffer(data, registry);
  factory ListSidechainsResponse_Sidechain.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSidechainsResponse_Sidechain()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSidechainsResponse.Sidechain',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'),
      createEmptyInstance: ListSidechainsResponse_Sidechain.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'title')
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..aI(3, _omitFieldNames ? '' : 'nversion', fieldType: $pb.PbFieldType.OU3)
    ..aOS(4, _omitFieldNames ? '' : 'hashid1')
    ..aOS(5, _omitFieldNames ? '' : 'hashid2')
    ..aI(6, _omitFieldNames ? '' : 'slot', fieldType: $pb.PbFieldType.OU3)
    ..aI(7, _omitFieldNames ? '' : 'voteCount', fieldType: $pb.PbFieldType.OU3)
    ..aI(8, _omitFieldNames ? '' : 'proposalHeight', fieldType: $pb.PbFieldType.OU3)
    ..aI(9, _omitFieldNames ? '' : 'activationHeight', fieldType: $pb.PbFieldType.OU3)
    ..aOS(10, _omitFieldNames ? '' : 'descriptionHex')
    ..aInt64(11, _omitFieldNames ? '' : 'balanceSatoshi')
    ..aOS(12, _omitFieldNames ? '' : 'chaintipTxid')
    ..aI(13, _omitFieldNames ? '' : 'chaintipVout', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSidechainsResponse_Sidechain clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSidechainsResponse_Sidechain copyWith(void Function(ListSidechainsResponse_Sidechain) updates) =>
      super.copyWith((message) => updates(message as ListSidechainsResponse_Sidechain))
          as ListSidechainsResponse_Sidechain;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListSidechainsResponse_Sidechain() / ListSidechainsResponse_Sidechain.new instead')
  static ListSidechainsResponse_Sidechain create() => ListSidechainsResponse_Sidechain._();
  static $pb.GeneratedMessage $_createMessage() => ListSidechainsResponse_Sidechain._();
  @$core.override
  ListSidechainsResponse_Sidechain createEmptyInstance() => ListSidechainsResponse_Sidechain._();
  @$core.pragma('dart2js:noInline')
  static ListSidechainsResponse_Sidechain getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListSidechainsResponse_Sidechain>(
          ListSidechainsResponse_Sidechain.$_createMessage);
  static ListSidechainsResponse_Sidechain? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get title => $_getSZ(0);
  @$pb.TagNumber(1)
  set title($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTitle() => $_has(0);
  @$pb.TagNumber(1)
  void clearTitle() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get nversion => $_getIZ(2);
  @$pb.TagNumber(3)
  set nversion($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNversion() => $_has(2);
  @$pb.TagNumber(3)
  void clearNversion() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get hashid1 => $_getSZ(3);
  @$pb.TagNumber(4)
  set hashid1($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHashid1() => $_has(3);
  @$pb.TagNumber(4)
  void clearHashid1() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get hashid2 => $_getSZ(4);
  @$pb.TagNumber(5)
  set hashid2($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHashid2() => $_has(4);
  @$pb.TagNumber(5)
  void clearHashid2() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get slot => $_getIZ(5);
  @$pb.TagNumber(6)
  set slot($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSlot() => $_has(5);
  @$pb.TagNumber(6)
  void clearSlot() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get voteCount => $_getIZ(6);
  @$pb.TagNumber(7)
  set voteCount($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasVoteCount() => $_has(6);
  @$pb.TagNumber(7)
  void clearVoteCount() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get proposalHeight => $_getIZ(7);
  @$pb.TagNumber(8)
  set proposalHeight($core.int value) => $_setUnsignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasProposalHeight() => $_has(7);
  @$pb.TagNumber(8)
  void clearProposalHeight() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get activationHeight => $_getIZ(8);
  @$pb.TagNumber(9)
  set activationHeight($core.int value) => $_setUnsignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasActivationHeight() => $_has(8);
  @$pb.TagNumber(9)
  void clearActivationHeight() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get descriptionHex => $_getSZ(9);
  @$pb.TagNumber(10)
  set descriptionHex($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasDescriptionHex() => $_has(9);
  @$pb.TagNumber(10)
  void clearDescriptionHex() => $_clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get balanceSatoshi => $_getI64(10);
  @$pb.TagNumber(11)
  set balanceSatoshi($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(11)
  $core.bool hasBalanceSatoshi() => $_has(10);
  @$pb.TagNumber(11)
  void clearBalanceSatoshi() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.String get chaintipTxid => $_getSZ(11);
  @$pb.TagNumber(12)
  set chaintipTxid($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasChaintipTxid() => $_has(11);
  @$pb.TagNumber(12)
  void clearChaintipTxid() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.int get chaintipVout => $_getIZ(12);
  @$pb.TagNumber(13)
  set chaintipVout($core.int value) => $_setUnsignedInt32(12, value);
  @$pb.TagNumber(13)
  $core.bool hasChaintipVout() => $_has(12);
  @$pb.TagNumber(13)
  void clearChaintipVout() => $_clearField(13);
}

class ListSidechainsResponse extends $pb.GeneratedMessage {
  factory ListSidechainsResponse({
    $core.Iterable<ListSidechainsResponse_Sidechain>? sidechains,
  }) {
    final result = ListSidechainsResponse._();
    if (sidechains != null) result.sidechains.addAll(sidechains);
    return result;
  }

  ListSidechainsResponse._();

  factory ListSidechainsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSidechainsResponse()..mergeFromBuffer(data, registry);
  factory ListSidechainsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSidechainsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSidechainsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'),
      createEmptyInstance: ListSidechainsResponse.$_createMessage)
    ..pPM<ListSidechainsResponse_Sidechain>(1, _omitFieldNames ? '' : 'sidechains',
        subBuilder: ListSidechainsResponse_Sidechain.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSidechainsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSidechainsResponse copyWith(void Function(ListSidechainsResponse) updates) =>
      super.copyWith((message) => updates(message as ListSidechainsResponse)) as ListSidechainsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListSidechainsResponse() / ListSidechainsResponse.new instead')
  static ListSidechainsResponse create() => ListSidechainsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListSidechainsResponse._();
  @$core.override
  ListSidechainsResponse createEmptyInstance() => ListSidechainsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListSidechainsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListSidechainsResponse>(ListSidechainsResponse.$_createMessage);
  static ListSidechainsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ListSidechainsResponse_Sidechain> get sidechains => $_getList(0);
}

class ListSidechainProposalsRequest extends $pb.GeneratedMessage {
  factory ListSidechainProposalsRequest() => ListSidechainProposalsRequest._();

  ListSidechainProposalsRequest._();

  factory ListSidechainProposalsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSidechainProposalsRequest()..mergeFromBuffer(data, registry);
  factory ListSidechainProposalsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSidechainProposalsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSidechainProposalsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'),
      createEmptyInstance: ListSidechainProposalsRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSidechainProposalsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSidechainProposalsRequest copyWith(void Function(ListSidechainProposalsRequest) updates) =>
      super.copyWith((message) => updates(message as ListSidechainProposalsRequest)) as ListSidechainProposalsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListSidechainProposalsRequest() / ListSidechainProposalsRequest.new instead')
  static ListSidechainProposalsRequest create() => ListSidechainProposalsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListSidechainProposalsRequest._();
  @$core.override
  ListSidechainProposalsRequest createEmptyInstance() => ListSidechainProposalsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListSidechainProposalsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListSidechainProposalsRequest>(ListSidechainProposalsRequest.$_createMessage);
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
    final result = SidechainProposal._();
    if (slot != null) result.slot = slot;
    if (data != null) result.data = data;
    if (dataHash != null) result.dataHash = dataHash;
    if (voteCount != null) result.voteCount = voteCount;
    if (proposalHeight != null) result.proposalHeight = proposalHeight;
    if (proposalAge != null) result.proposalAge = proposalAge;
    return result;
  }

  SidechainProposal._();

  factory SidechainProposal.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SidechainProposal()..mergeFromBuffer(data, registry);
  factory SidechainProposal.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SidechainProposal()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SidechainProposal',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'),
      createEmptyInstance: SidechainProposal.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'slot', fieldType: $pb.PbFieldType.OU3)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..aOS(3, _omitFieldNames ? '' : 'dataHash')
    ..aI(4, _omitFieldNames ? '' : 'voteCount', fieldType: $pb.PbFieldType.OU3)
    ..aI(5, _omitFieldNames ? '' : 'proposalHeight', fieldType: $pb.PbFieldType.OU3)
    ..aI(6, _omitFieldNames ? '' : 'proposalAge', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SidechainProposal clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SidechainProposal copyWith(void Function(SidechainProposal) updates) =>
      super.copyWith((message) => updates(message as SidechainProposal)) as SidechainProposal;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SidechainProposal() / SidechainProposal.new instead')
  static SidechainProposal create() => SidechainProposal._();
  static $pb.GeneratedMessage $_createMessage() => SidechainProposal._();
  @$core.override
  SidechainProposal createEmptyInstance() => SidechainProposal._();
  @$core.pragma('dart2js:noInline')
  static SidechainProposal getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SidechainProposal>(SidechainProposal.$_createMessage);
  static SidechainProposal? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get slot => $_getIZ(0);
  @$pb.TagNumber(1)
  set slot($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSlot() => $_has(0);
  @$pb.TagNumber(1)
  void clearSlot() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get data => $_getN(1);
  @$pb.TagNumber(2)
  set data($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasData() => $_has(1);
  @$pb.TagNumber(2)
  void clearData() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get dataHash => $_getSZ(2);
  @$pb.TagNumber(3)
  set dataHash($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDataHash() => $_has(2);
  @$pb.TagNumber(3)
  void clearDataHash() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get voteCount => $_getIZ(3);
  @$pb.TagNumber(4)
  set voteCount($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasVoteCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearVoteCount() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get proposalHeight => $_getIZ(4);
  @$pb.TagNumber(5)
  set proposalHeight($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasProposalHeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearProposalHeight() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get proposalAge => $_getIZ(5);
  @$pb.TagNumber(6)
  set proposalAge($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasProposalAge() => $_has(5);
  @$pb.TagNumber(6)
  void clearProposalAge() => $_clearField(6);
}

class ListSidechainProposalsResponse extends $pb.GeneratedMessage {
  factory ListSidechainProposalsResponse({
    $core.Iterable<SidechainProposal>? proposals,
  }) {
    final result = ListSidechainProposalsResponse._();
    if (proposals != null) result.proposals.addAll(proposals);
    return result;
  }

  ListSidechainProposalsResponse._();

  factory ListSidechainProposalsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSidechainProposalsResponse()..mergeFromBuffer(data, registry);
  factory ListSidechainProposalsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSidechainProposalsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSidechainProposalsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'),
      createEmptyInstance: ListSidechainProposalsResponse.$_createMessage)
    ..pPM<SidechainProposal>(1, _omitFieldNames ? '' : 'proposals', subBuilder: SidechainProposal.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSidechainProposalsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSidechainProposalsResponse copyWith(void Function(ListSidechainProposalsResponse) updates) =>
      super.copyWith((message) => updates(message as ListSidechainProposalsResponse)) as ListSidechainProposalsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListSidechainProposalsResponse() / ListSidechainProposalsResponse.new instead')
  static ListSidechainProposalsResponse create() => ListSidechainProposalsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListSidechainProposalsResponse._();
  @$core.override
  ListSidechainProposalsResponse createEmptyInstance() => ListSidechainProposalsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListSidechainProposalsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListSidechainProposalsResponse>(ListSidechainProposalsResponse.$_createMessage);
  static ListSidechainProposalsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SidechainProposal> get proposals => $_getList(0);
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
    final result = ProposeSidechainRequest._();
    if (slot != null) result.slot = slot;
    if (title != null) result.title = title;
    if (description != null) result.description = description;
    if (version != null) result.version = version;
    if (hashid1 != null) result.hashid1 = hashid1;
    if (hashid2 != null) result.hashid2 = hashid2;
    return result;
  }

  ProposeSidechainRequest._();

  factory ProposeSidechainRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProposeSidechainRequest()..mergeFromBuffer(data, registry);
  factory ProposeSidechainRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProposeSidechainRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ProposeSidechainRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'),
      createEmptyInstance: ProposeSidechainRequest.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'slot', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'title')
    ..aOS(3, _omitFieldNames ? '' : 'description')
    ..aI(4, _omitFieldNames ? '' : 'version', fieldType: $pb.PbFieldType.OU3)
    ..aOS(5, _omitFieldNames ? '' : 'hashid1')
    ..aOS(6, _omitFieldNames ? '' : 'hashid2')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProposeSidechainRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProposeSidechainRequest copyWith(void Function(ProposeSidechainRequest) updates) =>
      super.copyWith((message) => updates(message as ProposeSidechainRequest)) as ProposeSidechainRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ProposeSidechainRequest() / ProposeSidechainRequest.new instead')
  static ProposeSidechainRequest create() => ProposeSidechainRequest._();
  static $pb.GeneratedMessage $_createMessage() => ProposeSidechainRequest._();
  @$core.override
  ProposeSidechainRequest createEmptyInstance() => ProposeSidechainRequest._();
  @$core.pragma('dart2js:noInline')
  static ProposeSidechainRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProposeSidechainRequest>(ProposeSidechainRequest.$_createMessage);
  static ProposeSidechainRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get slot => $_getIZ(0);
  @$pb.TagNumber(1)
  set slot($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSlot() => $_has(0);
  @$pb.TagNumber(1)
  void clearSlot() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get title => $_getSZ(1);
  @$pb.TagNumber(2)
  set title($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearTitle() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get description => $_getSZ(2);
  @$pb.TagNumber(3)
  set description($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDescription() => $_has(2);
  @$pb.TagNumber(3)
  void clearDescription() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get version => $_getIZ(3);
  @$pb.TagNumber(4)
  set version($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasVersion() => $_has(3);
  @$pb.TagNumber(4)
  void clearVersion() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get hashid1 => $_getSZ(4);
  @$pb.TagNumber(5)
  set hashid1($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHashid1() => $_has(4);
  @$pb.TagNumber(5)
  void clearHashid1() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get hashid2 => $_getSZ(5);
  @$pb.TagNumber(6)
  set hashid2($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasHashid2() => $_has(5);
  @$pb.TagNumber(6)
  void clearHashid2() => $_clearField(6);
}

class ProposeSidechainResponse extends $pb.GeneratedMessage {
  factory ProposeSidechainResponse({
    $core.bool? success,
    $core.String? proposalHash,
    $core.String? message,
  }) {
    final result = ProposeSidechainResponse._();
    if (success != null) result.success = success;
    if (proposalHash != null) result.proposalHash = proposalHash;
    if (message != null) result.message = message;
    return result;
  }

  ProposeSidechainResponse._();

  factory ProposeSidechainResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProposeSidechainResponse()..mergeFromBuffer(data, registry);
  factory ProposeSidechainResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ProposeSidechainResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ProposeSidechainResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'),
      createEmptyInstance: ProposeSidechainResponse.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'success')
    ..aOS(2, _omitFieldNames ? '' : 'proposalHash')
    ..aOS(3, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProposeSidechainResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProposeSidechainResponse copyWith(void Function(ProposeSidechainResponse) updates) =>
      super.copyWith((message) => updates(message as ProposeSidechainResponse)) as ProposeSidechainResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ProposeSidechainResponse() / ProposeSidechainResponse.new instead')
  static ProposeSidechainResponse create() => ProposeSidechainResponse._();
  static $pb.GeneratedMessage $_createMessage() => ProposeSidechainResponse._();
  @$core.override
  ProposeSidechainResponse createEmptyInstance() => ProposeSidechainResponse._();
  @$core.pragma('dart2js:noInline')
  static ProposeSidechainResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProposeSidechainResponse>(ProposeSidechainResponse.$_createMessage);
  static ProposeSidechainResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get success => $_getBF(0);
  @$pb.TagNumber(1)
  set success($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSuccess() => $_has(0);
  @$pb.TagNumber(1)
  void clearSuccess() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get proposalHash => $_getSZ(1);
  @$pb.TagNumber(2)
  set proposalHash($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProposalHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearProposalHash() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get message => $_getSZ(2);
  @$pb.TagNumber(3)
  set message($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMessage() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessage() => $_clearField(3);
}

class ListWithdrawalsRequest extends $pb.GeneratedMessage {
  factory ListWithdrawalsRequest({
    $core.int? sidechainId,
    $core.int? startBlockHeight,
    $core.int? endBlockHeight,
  }) {
    final result = ListWithdrawalsRequest._();
    if (sidechainId != null) result.sidechainId = sidechainId;
    if (startBlockHeight != null) result.startBlockHeight = startBlockHeight;
    if (endBlockHeight != null) result.endBlockHeight = endBlockHeight;
    return result;
  }

  ListWithdrawalsRequest._();

  factory ListWithdrawalsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListWithdrawalsRequest()..mergeFromBuffer(data, registry);
  factory ListWithdrawalsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListWithdrawalsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListWithdrawalsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'),
      createEmptyInstance: ListWithdrawalsRequest.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'sidechainId', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'startBlockHeight', fieldType: $pb.PbFieldType.OU3)
    ..aI(3, _omitFieldNames ? '' : 'endBlockHeight', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListWithdrawalsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListWithdrawalsRequest copyWith(void Function(ListWithdrawalsRequest) updates) =>
      super.copyWith((message) => updates(message as ListWithdrawalsRequest)) as ListWithdrawalsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListWithdrawalsRequest() / ListWithdrawalsRequest.new instead')
  static ListWithdrawalsRequest create() => ListWithdrawalsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListWithdrawalsRequest._();
  @$core.override
  ListWithdrawalsRequest createEmptyInstance() => ListWithdrawalsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListWithdrawalsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListWithdrawalsRequest>(ListWithdrawalsRequest.$_createMessage);
  static ListWithdrawalsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get sidechainId => $_getIZ(0);
  @$pb.TagNumber(1)
  set sidechainId($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSidechainId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechainId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get startBlockHeight => $_getIZ(1);
  @$pb.TagNumber(2)
  set startBlockHeight($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStartBlockHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartBlockHeight() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get endBlockHeight => $_getIZ(2);
  @$pb.TagNumber(3)
  set endBlockHeight($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasEndBlockHeight() => $_has(2);
  @$pb.TagNumber(3)
  void clearEndBlockHeight() => $_clearField(3);
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
    final result = WithdrawalBundle._();
    if (m6id != null) result.m6id = m6id;
    if (sidechainId != null) result.sidechainId = sidechainId;
    if (status != null) result.status = status;
    if (sequenceNumber != null) result.sequenceNumber = sequenceNumber;
    if (transactionHex != null) result.transactionHex = transactionHex;
    if (blockHeight != null) result.blockHeight = blockHeight;
    if (age != null) result.age = age;
    if (maxAge != null) result.maxAge = maxAge;
    if (blocksLeft != null) result.blocksLeft = blocksLeft;
    return result;
  }

  WithdrawalBundle._();

  factory WithdrawalBundle.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalBundle()..mergeFromBuffer(data, registry);
  factory WithdrawalBundle.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WithdrawalBundle()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WithdrawalBundle',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'),
      createEmptyInstance: WithdrawalBundle.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'm6id')
    ..aI(2, _omitFieldNames ? '' : 'sidechainId', fieldType: $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'status')
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'sequenceNumber', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(5, _omitFieldNames ? '' : 'transactionHex')
    ..aI(6, _omitFieldNames ? '' : 'blockHeight', fieldType: $pb.PbFieldType.OU3)
    ..aI(7, _omitFieldNames ? '' : 'age', fieldType: $pb.PbFieldType.OU3)
    ..aI(8, _omitFieldNames ? '' : 'maxAge', fieldType: $pb.PbFieldType.OU3)
    ..aI(9, _omitFieldNames ? '' : 'blocksLeft', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalBundle clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WithdrawalBundle copyWith(void Function(WithdrawalBundle) updates) =>
      super.copyWith((message) => updates(message as WithdrawalBundle)) as WithdrawalBundle;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WithdrawalBundle() / WithdrawalBundle.new instead')
  static WithdrawalBundle create() => WithdrawalBundle._();
  static $pb.GeneratedMessage $_createMessage() => WithdrawalBundle._();
  @$core.override
  WithdrawalBundle createEmptyInstance() => WithdrawalBundle._();
  @$core.pragma('dart2js:noInline')
  static WithdrawalBundle getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WithdrawalBundle>(WithdrawalBundle.$_createMessage);
  static WithdrawalBundle? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get m6id => $_getSZ(0);
  @$pb.TagNumber(1)
  set m6id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasM6id() => $_has(0);
  @$pb.TagNumber(1)
  void clearM6id() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get sidechainId => $_getIZ(1);
  @$pb.TagNumber(2)
  set sidechainId($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSidechainId() => $_has(1);
  @$pb.TagNumber(2)
  void clearSidechainId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get status => $_getSZ(2);
  @$pb.TagNumber(3)
  set status($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasStatus() => $_has(2);
  @$pb.TagNumber(3)
  void clearStatus() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get sequenceNumber => $_getI64(3);
  @$pb.TagNumber(4)
  set sequenceNumber($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSequenceNumber() => $_has(3);
  @$pb.TagNumber(4)
  void clearSequenceNumber() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get transactionHex => $_getSZ(4);
  @$pb.TagNumber(5)
  set transactionHex($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTransactionHex() => $_has(4);
  @$pb.TagNumber(5)
  void clearTransactionHex() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get blockHeight => $_getIZ(5);
  @$pb.TagNumber(6)
  set blockHeight($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBlockHeight() => $_has(5);
  @$pb.TagNumber(6)
  void clearBlockHeight() => $_clearField(6);

  /// Score tracking fields (BIP300)
  @$pb.TagNumber(7)
  $core.int get age => $_getIZ(6);
  @$pb.TagNumber(7)
  set age($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAge() => $_has(6);
  @$pb.TagNumber(7)
  void clearAge() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get maxAge => $_getIZ(7);
  @$pb.TagNumber(8)
  set maxAge($core.int value) => $_setUnsignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasMaxAge() => $_has(7);
  @$pb.TagNumber(8)
  void clearMaxAge() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get blocksLeft => $_getIZ(8);
  @$pb.TagNumber(9)
  set blocksLeft($core.int value) => $_setUnsignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasBlocksLeft() => $_has(8);
  @$pb.TagNumber(9)
  void clearBlocksLeft() => $_clearField(9);
}

class ListWithdrawalsResponse extends $pb.GeneratedMessage {
  factory ListWithdrawalsResponse({
    $core.Iterable<WithdrawalBundle>? bundles,
  }) {
    final result = ListWithdrawalsResponse._();
    if (bundles != null) result.bundles.addAll(bundles);
    return result;
  }

  ListWithdrawalsResponse._();

  factory ListWithdrawalsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListWithdrawalsResponse()..mergeFromBuffer(data, registry);
  factory ListWithdrawalsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListWithdrawalsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListWithdrawalsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'),
      createEmptyInstance: ListWithdrawalsResponse.$_createMessage)
    ..pPM<WithdrawalBundle>(1, _omitFieldNames ? '' : 'bundles', subBuilder: WithdrawalBundle.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListWithdrawalsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListWithdrawalsResponse copyWith(void Function(ListWithdrawalsResponse) updates) =>
      super.copyWith((message) => updates(message as ListWithdrawalsResponse)) as ListWithdrawalsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListWithdrawalsResponse() / ListWithdrawalsResponse.new instead')
  static ListWithdrawalsResponse create() => ListWithdrawalsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListWithdrawalsResponse._();
  @$core.override
  ListWithdrawalsResponse createEmptyInstance() => ListWithdrawalsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListWithdrawalsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListWithdrawalsResponse>(ListWithdrawalsResponse.$_createMessage);
  static ListWithdrawalsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<WithdrawalBundle> get bundles => $_getList(0);
}

class ListRecentActionsRequest extends $pb.GeneratedMessage {
  factory ListRecentActionsRequest({
    $core.int? limit,
  }) {
    final result = ListRecentActionsRequest._();
    if (limit != null) result.limit = limit;
    return result;
  }

  ListRecentActionsRequest._();

  factory ListRecentActionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListRecentActionsRequest()..mergeFromBuffer(data, registry);
  factory ListRecentActionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListRecentActionsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListRecentActionsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'),
      createEmptyInstance: ListRecentActionsRequest.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'limit', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListRecentActionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListRecentActionsRequest copyWith(void Function(ListRecentActionsRequest) updates) =>
      super.copyWith((message) => updates(message as ListRecentActionsRequest)) as ListRecentActionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListRecentActionsRequest() / ListRecentActionsRequest.new instead')
  static ListRecentActionsRequest create() => ListRecentActionsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListRecentActionsRequest._();
  @$core.override
  ListRecentActionsRequest createEmptyInstance() => ListRecentActionsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListRecentActionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListRecentActionsRequest>(ListRecentActionsRequest.$_createMessage);
  static ListRecentActionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get limit => $_getIZ(0);
  @$pb.TagNumber(1)
  set limit($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLimit() => $_has(0);
  @$pb.TagNumber(1)
  void clearLimit() => $_clearField(1);
}

class RecentAction extends $pb.GeneratedMessage {
  factory RecentAction({
    $core.String? actionType,
    $core.int? sidechainSlot,
    $core.String? sidechainName,
    $fixnum.Int64? amountSatoshi,
    $core.int? ackCount,
    $core.int? ackTotal,
    $core.String? extraInfo,
    $fixnum.Int64? createdAt,
  }) {
    final result = RecentAction._();
    if (actionType != null) result.actionType = actionType;
    if (sidechainSlot != null) result.sidechainSlot = sidechainSlot;
    if (sidechainName != null) result.sidechainName = sidechainName;
    if (amountSatoshi != null) result.amountSatoshi = amountSatoshi;
    if (ackCount != null) result.ackCount = ackCount;
    if (ackTotal != null) result.ackTotal = ackTotal;
    if (extraInfo != null) result.extraInfo = extraInfo;
    if (createdAt != null) result.createdAt = createdAt;
    return result;
  }

  RecentAction._();

  factory RecentAction.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecentAction()..mergeFromBuffer(data, registry);
  factory RecentAction.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RecentAction()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RecentAction',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'),
      createEmptyInstance: RecentAction.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'actionType')
    ..aI(2, _omitFieldNames ? '' : 'sidechainSlot', fieldType: $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'sidechainName')
    ..aInt64(4, _omitFieldNames ? '' : 'amountSatoshi')
    ..aI(5, _omitFieldNames ? '' : 'ackCount', fieldType: $pb.PbFieldType.OU3)
    ..aI(6, _omitFieldNames ? '' : 'ackTotal', fieldType: $pb.PbFieldType.OU3)
    ..aOS(7, _omitFieldNames ? '' : 'extraInfo')
    ..aInt64(8, _omitFieldNames ? '' : 'createdAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecentAction clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RecentAction copyWith(void Function(RecentAction) updates) =>
      super.copyWith((message) => updates(message as RecentAction)) as RecentAction;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RecentAction() / RecentAction.new instead')
  static RecentAction create() => RecentAction._();
  static $pb.GeneratedMessage $_createMessage() => RecentAction._();
  @$core.override
  RecentAction createEmptyInstance() => RecentAction._();
  @$core.pragma('dart2js:noInline')
  static RecentAction getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RecentAction>(RecentAction.$_createMessage);
  static RecentAction? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get actionType => $_getSZ(0);
  @$pb.TagNumber(1)
  set actionType($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasActionType() => $_has(0);
  @$pb.TagNumber(1)
  void clearActionType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get sidechainSlot => $_getIZ(1);
  @$pb.TagNumber(2)
  set sidechainSlot($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSidechainSlot() => $_has(1);
  @$pb.TagNumber(2)
  void clearSidechainSlot() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get sidechainName => $_getSZ(2);
  @$pb.TagNumber(3)
  set sidechainName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSidechainName() => $_has(2);
  @$pb.TagNumber(3)
  void clearSidechainName() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get amountSatoshi => $_getI64(3);
  @$pb.TagNumber(4)
  set amountSatoshi($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAmountSatoshi() => $_has(3);
  @$pb.TagNumber(4)
  void clearAmountSatoshi() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get ackCount => $_getIZ(4);
  @$pb.TagNumber(5)
  set ackCount($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAckCount() => $_has(4);
  @$pb.TagNumber(5)
  void clearAckCount() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get ackTotal => $_getIZ(5);
  @$pb.TagNumber(6)
  set ackTotal($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAckTotal() => $_has(5);
  @$pb.TagNumber(6)
  void clearAckTotal() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get extraInfo => $_getSZ(6);
  @$pb.TagNumber(7)
  set extraInfo($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasExtraInfo() => $_has(6);
  @$pb.TagNumber(7)
  void clearExtraInfo() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get createdAt => $_getI64(7);
  @$pb.TagNumber(8)
  set createdAt($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasCreatedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearCreatedAt() => $_clearField(8);
}

class ListRecentActionsResponse extends $pb.GeneratedMessage {
  factory ListRecentActionsResponse({
    $core.Iterable<RecentAction>? actions,
    $core.String? subtitle,
  }) {
    final result = ListRecentActionsResponse._();
    if (actions != null) result.actions.addAll(actions);
    if (subtitle != null) result.subtitle = subtitle;
    return result;
  }

  ListRecentActionsResponse._();

  factory ListRecentActionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListRecentActionsResponse()..mergeFromBuffer(data, registry);
  factory ListRecentActionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListRecentActionsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListRecentActionsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'),
      createEmptyInstance: ListRecentActionsResponse.$_createMessage)
    ..pPM<RecentAction>(1, _omitFieldNames ? '' : 'actions', subBuilder: RecentAction.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'subtitle')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListRecentActionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListRecentActionsResponse copyWith(void Function(ListRecentActionsResponse) updates) =>
      super.copyWith((message) => updates(message as ListRecentActionsResponse)) as ListRecentActionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListRecentActionsResponse() / ListRecentActionsResponse.new instead')
  static ListRecentActionsResponse create() => ListRecentActionsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListRecentActionsResponse._();
  @$core.override
  ListRecentActionsResponse createEmptyInstance() => ListRecentActionsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListRecentActionsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListRecentActionsResponse>(ListRecentActionsResponse.$_createMessage);
  static ListRecentActionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<RecentAction> get actions => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get subtitle => $_getSZ(1);
  @$pb.TagNumber(2)
  set subtitle($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSubtitle() => $_has(1);
  @$pb.TagNumber(2)
  void clearSubtitle() => $_clearField(2);
}

class DrivechainServiceApi {
  final $pb.RpcClient _client;

  DrivechainServiceApi(this._client);

  $async.Future<ListSidechainsResponse> listSidechains($pb.ClientContext? ctx, ListSidechainsRequest request) => _client
      .invoke<ListSidechainsResponse>(ctx, 'DrivechainService', 'ListSidechains', request, ListSidechainsResponse());
  $async.Future<ListSidechainProposalsResponse> listSidechainProposals(
          $pb.ClientContext? ctx, ListSidechainProposalsRequest request) =>
      _client.invoke<ListSidechainProposalsResponse>(
          ctx, 'DrivechainService', 'ListSidechainProposals', request, ListSidechainProposalsResponse());
  $async.Future<ProposeSidechainResponse> proposeSidechain($pb.ClientContext? ctx, ProposeSidechainRequest request) =>
      _client.invoke<ProposeSidechainResponse>(
          ctx, 'DrivechainService', 'ProposeSidechain', request, ProposeSidechainResponse());
  $async.Future<ListWithdrawalsResponse> listWithdrawals($pb.ClientContext? ctx, ListWithdrawalsRequest request) =>
      _client.invoke<ListWithdrawalsResponse>(
          ctx, 'DrivechainService', 'ListWithdrawals', request, ListWithdrawalsResponse());
  $async.Future<ListRecentActionsResponse> listRecentActions(
          $pb.ClientContext? ctx, ListRecentActionsRequest request) =>
      _client.invoke<ListRecentActionsResponse>(
          ctx, 'DrivechainService', 'ListRecentActions', request, ListRecentActionsResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
