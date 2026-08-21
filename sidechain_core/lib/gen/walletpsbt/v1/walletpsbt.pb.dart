//
//  Generated code. Do not modify.
//  source: walletpsbt/v1/walletpsbt.proto
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

class PsbtDraft extends $pb.GeneratedMessage {
  factory PsbtDraft({
    $core.String? id,
    $core.String? walletId,
    $core.String? label,
    $core.String? psbtBase64,
    $fixnum.Int64? createdAt,
    $fixnum.Int64? updatedAt,
    $core.String? txid,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (walletId != null) {
      $result.walletId = walletId;
    }
    if (label != null) {
      $result.label = label;
    }
    if (psbtBase64 != null) {
      $result.psbtBase64 = psbtBase64;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (updatedAt != null) {
      $result.updatedAt = updatedAt;
    }
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  PsbtDraft._() : super();
  factory PsbtDraft.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PsbtDraft.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PsbtDraft', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletpsbt.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'walletId')
    ..aOS(3, _omitFieldNames ? '' : 'label')
    ..aOS(4, _omitFieldNames ? '' : 'psbtBase64')
    ..aInt64(5, _omitFieldNames ? '' : 'createdAt')
    ..aInt64(6, _omitFieldNames ? '' : 'updatedAt')
    ..aOS(7, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PsbtDraft clone() => PsbtDraft()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PsbtDraft copyWith(void Function(PsbtDraft) updates) => super.copyWith((message) => updates(message as PsbtDraft)) as PsbtDraft;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PsbtDraft create() => PsbtDraft._();
  PsbtDraft createEmptyInstance() => create();
  static $pb.PbList<PsbtDraft> createRepeated() => $pb.PbList<PsbtDraft>();
  @$core.pragma('dart2js:noInline')
  static PsbtDraft getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PsbtDraft>(create);
  static PsbtDraft? _defaultInstance;

  /// Server-generated. The first four characters are the reference shown
  /// in the transaction tab.
  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get walletId => $_getSZ(1);
  @$pb.TagNumber(2)
  set walletId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWalletId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWalletId() => clearField(2);

  /// User name from the tab rename; empty until set.
  @$pb.TagNumber(3)
  $core.String get label => $_getSZ(2);
  @$pb.TagNumber(3)
  set label($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLabel() => $_has(2);
  @$pb.TagNumber(3)
  void clearLabel() => clearField(3);

  /// The live PSBT, replaced on every signature.
  @$pb.TagNumber(4)
  $core.String get psbtBase64 => $_getSZ(3);
  @$pb.TagNumber(4)
  set psbtBase64($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPsbtBase64() => $_has(3);
  @$pb.TagNumber(4)
  void clearPsbtBase64() => clearField(4);

  /// Unix milliseconds.
  @$pb.TagNumber(5)
  $fixnum.Int64 get createdAt => $_getI64(4);
  @$pb.TagNumber(5)
  set createdAt($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasCreatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearCreatedAt() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get updatedAt => $_getI64(5);
  @$pb.TagNumber(6)
  set updatedAt($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasUpdatedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearUpdatedAt() => clearField(6);

  /// Set once broadcast.
  @$pb.TagNumber(7)
  $core.String get txid => $_getSZ(6);
  @$pb.TagNumber(7)
  set txid($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasTxid() => $_has(6);
  @$pb.TagNumber(7)
  void clearTxid() => clearField(7);
}

class ListDraftsRequest extends $pb.GeneratedMessage {
  factory ListDraftsRequest({
    $core.String? walletId,
  }) {
    final $result = create();
    if (walletId != null) {
      $result.walletId = walletId;
    }
    return $result;
  }
  ListDraftsRequest._() : super();
  factory ListDraftsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListDraftsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListDraftsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletpsbt.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListDraftsRequest clone() => ListDraftsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListDraftsRequest copyWith(void Function(ListDraftsRequest) updates) => super.copyWith((message) => updates(message as ListDraftsRequest)) as ListDraftsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListDraftsRequest create() => ListDraftsRequest._();
  ListDraftsRequest createEmptyInstance() => create();
  static $pb.PbList<ListDraftsRequest> createRepeated() => $pb.PbList<ListDraftsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListDraftsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListDraftsRequest>(create);
  static ListDraftsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => clearField(1);
}

class ListDraftsResponse extends $pb.GeneratedMessage {
  factory ListDraftsResponse({
    $core.Iterable<PsbtDraft>? drafts,
  }) {
    final $result = create();
    if (drafts != null) {
      $result.drafts.addAll(drafts);
    }
    return $result;
  }
  ListDraftsResponse._() : super();
  factory ListDraftsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListDraftsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListDraftsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletpsbt.v1'), createEmptyInstance: create)
    ..pc<PsbtDraft>(1, _omitFieldNames ? '' : 'drafts', $pb.PbFieldType.PM, subBuilder: PsbtDraft.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListDraftsResponse clone() => ListDraftsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListDraftsResponse copyWith(void Function(ListDraftsResponse) updates) => super.copyWith((message) => updates(message as ListDraftsResponse)) as ListDraftsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListDraftsResponse create() => ListDraftsResponse._();
  ListDraftsResponse createEmptyInstance() => create();
  static $pb.PbList<ListDraftsResponse> createRepeated() => $pb.PbList<ListDraftsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListDraftsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListDraftsResponse>(create);
  static ListDraftsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<PsbtDraft> get drafts => $_getList(0);
}

class SaveDraftRequest extends $pb.GeneratedMessage {
  factory SaveDraftRequest({
    PsbtDraft? draft,
  }) {
    final $result = create();
    if (draft != null) {
      $result.draft = draft;
    }
    return $result;
  }
  SaveDraftRequest._() : super();
  factory SaveDraftRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SaveDraftRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SaveDraftRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletpsbt.v1'), createEmptyInstance: create)
    ..aOM<PsbtDraft>(1, _omitFieldNames ? '' : 'draft', subBuilder: PsbtDraft.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SaveDraftRequest clone() => SaveDraftRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SaveDraftRequest copyWith(void Function(SaveDraftRequest) updates) => super.copyWith((message) => updates(message as SaveDraftRequest)) as SaveDraftRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SaveDraftRequest create() => SaveDraftRequest._();
  SaveDraftRequest createEmptyInstance() => create();
  static $pb.PbList<SaveDraftRequest> createRepeated() => $pb.PbList<SaveDraftRequest>();
  @$core.pragma('dart2js:noInline')
  static SaveDraftRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SaveDraftRequest>(create);
  static SaveDraftRequest? _defaultInstance;

  @$pb.TagNumber(1)
  PsbtDraft get draft => $_getN(0);
  @$pb.TagNumber(1)
  set draft(PsbtDraft v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasDraft() => $_has(0);
  @$pb.TagNumber(1)
  void clearDraft() => clearField(1);
  @$pb.TagNumber(1)
  PsbtDraft ensureDraft() => $_ensure(0);
}

class SaveDraftResponse extends $pb.GeneratedMessage {
  factory SaveDraftResponse({
    PsbtDraft? draft,
  }) {
    final $result = create();
    if (draft != null) {
      $result.draft = draft;
    }
    return $result;
  }
  SaveDraftResponse._() : super();
  factory SaveDraftResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SaveDraftResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SaveDraftResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletpsbt.v1'), createEmptyInstance: create)
    ..aOM<PsbtDraft>(1, _omitFieldNames ? '' : 'draft', subBuilder: PsbtDraft.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SaveDraftResponse clone() => SaveDraftResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SaveDraftResponse copyWith(void Function(SaveDraftResponse) updates) => super.copyWith((message) => updates(message as SaveDraftResponse)) as SaveDraftResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SaveDraftResponse create() => SaveDraftResponse._();
  SaveDraftResponse createEmptyInstance() => create();
  static $pb.PbList<SaveDraftResponse> createRepeated() => $pb.PbList<SaveDraftResponse>();
  @$core.pragma('dart2js:noInline')
  static SaveDraftResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SaveDraftResponse>(create);
  static SaveDraftResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PsbtDraft get draft => $_getN(0);
  @$pb.TagNumber(1)
  set draft(PsbtDraft v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasDraft() => $_has(0);
  @$pb.TagNumber(1)
  void clearDraft() => clearField(1);
  @$pb.TagNumber(1)
  PsbtDraft ensureDraft() => $_ensure(0);
}

class DeleteDraftRequest extends $pb.GeneratedMessage {
  factory DeleteDraftRequest({
    $core.String? id,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    return $result;
  }
  DeleteDraftRequest._() : super();
  factory DeleteDraftRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DeleteDraftRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteDraftRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'walletpsbt.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DeleteDraftRequest clone() => DeleteDraftRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DeleteDraftRequest copyWith(void Function(DeleteDraftRequest) updates) => super.copyWith((message) => updates(message as DeleteDraftRequest)) as DeleteDraftRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DeleteDraftRequest create() => DeleteDraftRequest._();
  DeleteDraftRequest createEmptyInstance() => create();
  static $pb.PbList<DeleteDraftRequest> createRepeated() => $pb.PbList<DeleteDraftRequest>();
  @$core.pragma('dart2js:noInline')
  static DeleteDraftRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteDraftRequest>(create);
  static DeleteDraftRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);
}

class WalletPsbtServiceApi {
  $pb.RpcClient _client;
  WalletPsbtServiceApi(this._client);

  $async.Future<ListDraftsResponse> listDrafts($pb.ClientContext? ctx, ListDraftsRequest request) =>
    _client.invoke<ListDraftsResponse>(ctx, 'WalletPsbtService', 'ListDrafts', request, ListDraftsResponse())
  ;
  $async.Future<SaveDraftResponse> saveDraft($pb.ClientContext? ctx, SaveDraftRequest request) =>
    _client.invoke<SaveDraftResponse>(ctx, 'WalletPsbtService', 'SaveDraft', request, SaveDraftResponse())
  ;
  $async.Future<$1.Empty> deleteDraft($pb.ClientContext? ctx, DeleteDraftRequest request) =>
    _client.invoke<$1.Empty>(ctx, 'WalletPsbtService', 'DeleteDraft', request, $1.Empty())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
