// This is a generated file - do not edit.
//
// Generated from walletpsbt/v1/walletpsbt.proto.

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
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

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
    final result = PsbtDraft._();
    if (id != null) result.id = id;
    if (walletId != null) result.walletId = walletId;
    if (label != null) result.label = label;
    if (psbtBase64 != null) result.psbtBase64 = psbtBase64;
    if (createdAt != null) result.createdAt = createdAt;
    if (updatedAt != null) result.updatedAt = updatedAt;
    if (txid != null) result.txid = txid;
    return result;
  }

  PsbtDraft._();

  factory PsbtDraft.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PsbtDraft()..mergeFromBuffer(data, registry);
  factory PsbtDraft.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PsbtDraft()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PsbtDraft',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletpsbt.v1'),
      createEmptyInstance: PsbtDraft.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'walletId')
    ..aOS(3, _omitFieldNames ? '' : 'label')
    ..aOS(4, _omitFieldNames ? '' : 'psbtBase64')
    ..aInt64(5, _omitFieldNames ? '' : 'createdAt')
    ..aInt64(6, _omitFieldNames ? '' : 'updatedAt')
    ..aOS(7, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PsbtDraft clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PsbtDraft copyWith(void Function(PsbtDraft) updates) =>
      super.copyWith((message) => updates(message as PsbtDraft)) as PsbtDraft;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PsbtDraft() / PsbtDraft.new instead')
  static PsbtDraft create() => PsbtDraft._();
  static $pb.GeneratedMessage $_createMessage() => PsbtDraft._();
  @$core.override
  PsbtDraft createEmptyInstance() => PsbtDraft._();
  @$core.pragma('dart2js:noInline')
  static PsbtDraft getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PsbtDraft>(PsbtDraft.$_createMessage);
  static PsbtDraft? _defaultInstance;

  /// Server-generated. The first four characters are the reference shown
  /// in the transaction tab.
  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get walletId => $_getSZ(1);
  @$pb.TagNumber(2)
  set walletId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWalletId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWalletId() => $_clearField(2);

  /// User name from the tab rename; empty until set.
  @$pb.TagNumber(3)
  $core.String get label => $_getSZ(2);
  @$pb.TagNumber(3)
  set label($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLabel() => $_has(2);
  @$pb.TagNumber(3)
  void clearLabel() => $_clearField(3);

  /// The live PSBT, replaced on every signature.
  @$pb.TagNumber(4)
  $core.String get psbtBase64 => $_getSZ(3);
  @$pb.TagNumber(4)
  set psbtBase64($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPsbtBase64() => $_has(3);
  @$pb.TagNumber(4)
  void clearPsbtBase64() => $_clearField(4);

  /// Unix milliseconds.
  @$pb.TagNumber(5)
  $fixnum.Int64 get createdAt => $_getI64(4);
  @$pb.TagNumber(5)
  set createdAt($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCreatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearCreatedAt() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get updatedAt => $_getI64(5);
  @$pb.TagNumber(6)
  set updatedAt($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUpdatedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearUpdatedAt() => $_clearField(6);

  /// Set once broadcast.
  @$pb.TagNumber(7)
  $core.String get txid => $_getSZ(6);
  @$pb.TagNumber(7)
  set txid($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasTxid() => $_has(6);
  @$pb.TagNumber(7)
  void clearTxid() => $_clearField(7);
}

class ListDraftsRequest extends $pb.GeneratedMessage {
  factory ListDraftsRequest({
    $core.String? walletId,
  }) {
    final result = ListDraftsRequest._();
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  ListDraftsRequest._();

  factory ListDraftsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListDraftsRequest()..mergeFromBuffer(data, registry);
  factory ListDraftsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListDraftsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListDraftsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletpsbt.v1'),
      createEmptyInstance: ListDraftsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDraftsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDraftsRequest copyWith(void Function(ListDraftsRequest) updates) =>
      super.copyWith((message) => updates(message as ListDraftsRequest)) as ListDraftsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListDraftsRequest() / ListDraftsRequest.new instead')
  static ListDraftsRequest create() => ListDraftsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListDraftsRequest._();
  @$core.override
  ListDraftsRequest createEmptyInstance() => ListDraftsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListDraftsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListDraftsRequest>(ListDraftsRequest.$_createMessage);
  static ListDraftsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);
}

class ListDraftsResponse extends $pb.GeneratedMessage {
  factory ListDraftsResponse({
    $core.Iterable<PsbtDraft>? drafts,
  }) {
    final result = ListDraftsResponse._();
    if (drafts != null) result.drafts.addAll(drafts);
    return result;
  }

  ListDraftsResponse._();

  factory ListDraftsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListDraftsResponse()..mergeFromBuffer(data, registry);
  factory ListDraftsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListDraftsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListDraftsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletpsbt.v1'),
      createEmptyInstance: ListDraftsResponse.$_createMessage)
    ..pPM<PsbtDraft>(1, _omitFieldNames ? '' : 'drafts', subBuilder: PsbtDraft.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDraftsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDraftsResponse copyWith(void Function(ListDraftsResponse) updates) =>
      super.copyWith((message) => updates(message as ListDraftsResponse)) as ListDraftsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListDraftsResponse() / ListDraftsResponse.new instead')
  static ListDraftsResponse create() => ListDraftsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListDraftsResponse._();
  @$core.override
  ListDraftsResponse createEmptyInstance() => ListDraftsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListDraftsResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListDraftsResponse>(ListDraftsResponse.$_createMessage);
  static ListDraftsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<PsbtDraft> get drafts => $_getList(0);
}

class SaveDraftRequest extends $pb.GeneratedMessage {
  factory SaveDraftRequest({
    PsbtDraft? draft,
  }) {
    final result = SaveDraftRequest._();
    if (draft != null) result.draft = draft;
    return result;
  }

  SaveDraftRequest._();

  factory SaveDraftRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SaveDraftRequest()..mergeFromBuffer(data, registry);
  factory SaveDraftRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SaveDraftRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SaveDraftRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletpsbt.v1'),
      createEmptyInstance: SaveDraftRequest.$_createMessage)
    ..aOM<PsbtDraft>(1, _omitFieldNames ? '' : 'draft', subBuilder: PsbtDraft.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SaveDraftRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SaveDraftRequest copyWith(void Function(SaveDraftRequest) updates) =>
      super.copyWith((message) => updates(message as SaveDraftRequest)) as SaveDraftRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SaveDraftRequest() / SaveDraftRequest.new instead')
  static SaveDraftRequest create() => SaveDraftRequest._();
  static $pb.GeneratedMessage $_createMessage() => SaveDraftRequest._();
  @$core.override
  SaveDraftRequest createEmptyInstance() => SaveDraftRequest._();
  @$core.pragma('dart2js:noInline')
  static SaveDraftRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SaveDraftRequest>(SaveDraftRequest.$_createMessage);
  static SaveDraftRequest? _defaultInstance;

  @$pb.TagNumber(1)
  PsbtDraft get draft => $_getN(0);
  @$pb.TagNumber(1)
  set draft(PsbtDraft value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDraft() => $_has(0);
  @$pb.TagNumber(1)
  void clearDraft() => $_clearField(1);
  @$pb.TagNumber(1)
  PsbtDraft ensureDraft() => $_ensure(0);
}

class SaveDraftResponse extends $pb.GeneratedMessage {
  factory SaveDraftResponse({
    PsbtDraft? draft,
  }) {
    final result = SaveDraftResponse._();
    if (draft != null) result.draft = draft;
    return result;
  }

  SaveDraftResponse._();

  factory SaveDraftResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SaveDraftResponse()..mergeFromBuffer(data, registry);
  factory SaveDraftResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SaveDraftResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SaveDraftResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletpsbt.v1'),
      createEmptyInstance: SaveDraftResponse.$_createMessage)
    ..aOM<PsbtDraft>(1, _omitFieldNames ? '' : 'draft', subBuilder: PsbtDraft.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SaveDraftResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SaveDraftResponse copyWith(void Function(SaveDraftResponse) updates) =>
      super.copyWith((message) => updates(message as SaveDraftResponse)) as SaveDraftResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SaveDraftResponse() / SaveDraftResponse.new instead')
  static SaveDraftResponse create() => SaveDraftResponse._();
  static $pb.GeneratedMessage $_createMessage() => SaveDraftResponse._();
  @$core.override
  SaveDraftResponse createEmptyInstance() => SaveDraftResponse._();
  @$core.pragma('dart2js:noInline')
  static SaveDraftResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SaveDraftResponse>(SaveDraftResponse.$_createMessage);
  static SaveDraftResponse? _defaultInstance;

  @$pb.TagNumber(1)
  PsbtDraft get draft => $_getN(0);
  @$pb.TagNumber(1)
  set draft(PsbtDraft value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDraft() => $_has(0);
  @$pb.TagNumber(1)
  void clearDraft() => $_clearField(1);
  @$pb.TagNumber(1)
  PsbtDraft ensureDraft() => $_ensure(0);
}

class DeleteDraftRequest extends $pb.GeneratedMessage {
  factory DeleteDraftRequest({
    $core.String? id,
  }) {
    final result = DeleteDraftRequest._();
    if (id != null) result.id = id;
    return result;
  }

  DeleteDraftRequest._();

  factory DeleteDraftRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteDraftRequest()..mergeFromBuffer(data, registry);
  factory DeleteDraftRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteDraftRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteDraftRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletpsbt.v1'),
      createEmptyInstance: DeleteDraftRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteDraftRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteDraftRequest copyWith(void Function(DeleteDraftRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteDraftRequest)) as DeleteDraftRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DeleteDraftRequest() / DeleteDraftRequest.new instead')
  static DeleteDraftRequest create() => DeleteDraftRequest._();
  static $pb.GeneratedMessage $_createMessage() => DeleteDraftRequest._();
  @$core.override
  DeleteDraftRequest createEmptyInstance() => DeleteDraftRequest._();
  @$core.pragma('dart2js:noInline')
  static DeleteDraftRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteDraftRequest>(DeleteDraftRequest.$_createMessage);
  static DeleteDraftRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

/// Persists in-progress multisig spends for the Send tab, so partial
/// signatures survive restarts. The PSBT blob itself carries the
/// signatures; signing state is derived from it, never stored.
class WalletPsbtServiceApi {
  final $pb.RpcClient _client;

  WalletPsbtServiceApi(this._client);

  $async.Future<ListDraftsResponse> listDrafts($pb.ClientContext? ctx, ListDraftsRequest request) =>
      _client.invoke<ListDraftsResponse>(ctx, 'WalletPsbtService', 'ListDrafts', request, ListDraftsResponse());
  $async.Future<SaveDraftResponse> saveDraft($pb.ClientContext? ctx, SaveDraftRequest request) =>
      _client.invoke<SaveDraftResponse>(ctx, 'WalletPsbtService', 'SaveDraft', request, SaveDraftResponse());
  $async.Future<$0.Empty> deleteDraft($pb.ClientContext? ctx, DeleteDraftRequest request) =>
      _client.invoke<$0.Empty>(ctx, 'WalletPsbtService', 'DeleteDraft', request, $0.Empty());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
