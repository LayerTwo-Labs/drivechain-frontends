// This is a generated file - do not edit.
//
// Generated from multisiglounge/v1/multisiglounge.proto.

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

/// SpendDestination is one output of a spend: an address and an amount in sats.
class SpendDestination extends $pb.GeneratedMessage {
  factory SpendDestination({
    $core.String? address,
    $fixnum.Int64? sats,
  }) {
    final result = SpendDestination._();
    if (address != null) result.address = address;
    if (sats != null) result.sats = sats;
    return result;
  }

  SpendDestination._();

  factory SpendDestination.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SpendDestination()..mergeFromBuffer(data, registry);
  factory SpendDestination.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SpendDestination()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SpendDestination',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'),
      createEmptyInstance: SpendDestination.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aInt64(2, _omitFieldNames ? '' : 'sats')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpendDestination clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SpendDestination copyWith(void Function(SpendDestination) updates) =>
      super.copyWith((message) => updates(message as SpendDestination)) as SpendDestination;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SpendDestination() / SpendDestination.new instead')
  static SpendDestination create() => SpendDestination._();
  static $pb.GeneratedMessage $_createMessage() => SpendDestination._();
  @$core.override
  SpendDestination createEmptyInstance() => SpendDestination._();
  @$core.pragma('dart2js:noInline')
  static SpendDestination getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SpendDestination>(SpendDestination.$_createMessage);
  static SpendDestination? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get sats => $_getI64(1);
  @$pb.TagNumber(2)
  set sats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearSats() => $_clearField(2);
}

class CreateSpendPsbtRequest extends $pb.GeneratedMessage {
  factory CreateSpendPsbtRequest({
    GroupData? group,
    $core.String? walletId,
    $core.Iterable<SpendDestination>? destinations,
    $core.double? feeRateSatVb,
  }) {
    final result = CreateSpendPsbtRequest._();
    if (group != null) result.group = group;
    if (walletId != null) result.walletId = walletId;
    if (destinations != null) result.destinations.addAll(destinations);
    if (feeRateSatVb != null) result.feeRateSatVb = feeRateSatVb;
    return result;
  }

  CreateSpendPsbtRequest._();

  factory CreateSpendPsbtRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateSpendPsbtRequest()..mergeFromBuffer(data, registry);
  factory CreateSpendPsbtRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateSpendPsbtRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateSpendPsbtRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'),
      createEmptyInstance: CreateSpendPsbtRequest.$_createMessage)
    ..aOM<GroupData>(1, _omitFieldNames ? '' : 'group', subBuilder: GroupData.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'walletId')
    ..pPM<SpendDestination>(3, _omitFieldNames ? '' : 'destinations', subBuilder: SpendDestination.$_createMessage)
    ..aD(4, _omitFieldNames ? '' : 'feeRateSatVb')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSpendPsbtRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSpendPsbtRequest copyWith(void Function(CreateSpendPsbtRequest) updates) =>
      super.copyWith((message) => updates(message as CreateSpendPsbtRequest)) as CreateSpendPsbtRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateSpendPsbtRequest() / CreateSpendPsbtRequest.new instead')
  static CreateSpendPsbtRequest create() => CreateSpendPsbtRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateSpendPsbtRequest._();
  @$core.override
  CreateSpendPsbtRequest createEmptyInstance() => CreateSpendPsbtRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateSpendPsbtRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateSpendPsbtRequest>(CreateSpendPsbtRequest.$_createMessage);
  static CreateSpendPsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  GroupData get group => $_getN(0);
  @$pb.TagNumber(1)
  set group(GroupData value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasGroup() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroup() => $_clearField(1);
  @$pb.TagNumber(1)
  GroupData ensureGroup() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get walletId => $_getSZ(1);
  @$pb.TagNumber(2)
  set walletId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWalletId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWalletId() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<SpendDestination> get destinations => $_getList(2);

  /// Optional fee rate in sat/vB. 0 lets bitcoind pick (fallback/estimate fee),
  /// matching the current Dart path which passes no explicit fee rate.
  @$pb.TagNumber(4)
  $core.double get feeRateSatVb => $_getN(3);
  @$pb.TagNumber(4)
  set feeRateSatVb($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFeeRateSatVb() => $_has(3);
  @$pb.TagNumber(4)
  void clearFeeRateSatVb() => $_clearField(4);
}

class CreateSpendPsbtResponse extends $pb.GeneratedMessage {
  factory CreateSpendPsbtResponse({
    $core.String? psbtBase64,
    $fixnum.Int64? feeSats,
  }) {
    final result = CreateSpendPsbtResponse._();
    if (psbtBase64 != null) result.psbtBase64 = psbtBase64;
    if (feeSats != null) result.feeSats = feeSats;
    return result;
  }

  CreateSpendPsbtResponse._();

  factory CreateSpendPsbtResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateSpendPsbtResponse()..mergeFromBuffer(data, registry);
  factory CreateSpendPsbtResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateSpendPsbtResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateSpendPsbtResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'),
      createEmptyInstance: CreateSpendPsbtResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'psbtBase64')
    ..aInt64(2, _omitFieldNames ? '' : 'feeSats')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSpendPsbtResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateSpendPsbtResponse copyWith(void Function(CreateSpendPsbtResponse) updates) =>
      super.copyWith((message) => updates(message as CreateSpendPsbtResponse)) as CreateSpendPsbtResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateSpendPsbtResponse() / CreateSpendPsbtResponse.new instead')
  static CreateSpendPsbtResponse create() => CreateSpendPsbtResponse._();
  static $pb.GeneratedMessage $_createMessage() => CreateSpendPsbtResponse._();
  @$core.override
  CreateSpendPsbtResponse createEmptyInstance() => CreateSpendPsbtResponse._();
  @$core.pragma('dart2js:noInline')
  static CreateSpendPsbtResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateSpendPsbtResponse>(CreateSpendPsbtResponse.$_createMessage);
  static CreateSpendPsbtResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbtBase64 => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbtBase64($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPsbtBase64() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbtBase64() => $_clearField(1);

  /// Fee the funded PSBT pays, in sats.
  @$pb.TagNumber(2)
  $fixnum.Int64 get feeSats => $_getI64(1);
  @$pb.TagNumber(2)
  set feeSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFeeSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearFeeSats() => $_clearField(2);
}

class SyncGroupRequest extends $pb.GeneratedMessage {
  factory SyncGroupRequest({
    GroupData? group,
    $core.String? walletId,
  }) {
    final result = SyncGroupRequest._();
    if (group != null) result.group = group;
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  SyncGroupRequest._();

  factory SyncGroupRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncGroupRequest()..mergeFromBuffer(data, registry);
  factory SyncGroupRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncGroupRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncGroupRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'),
      createEmptyInstance: SyncGroupRequest.$_createMessage)
    ..aOM<GroupData>(1, _omitFieldNames ? '' : 'group', subBuilder: GroupData.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncGroupRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncGroupRequest copyWith(void Function(SyncGroupRequest) updates) =>
      super.copyWith((message) => updates(message as SyncGroupRequest)) as SyncGroupRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SyncGroupRequest() / SyncGroupRequest.new instead')
  static SyncGroupRequest create() => SyncGroupRequest._();
  static $pb.GeneratedMessage $_createMessage() => SyncGroupRequest._();
  @$core.override
  SyncGroupRequest createEmptyInstance() => SyncGroupRequest._();
  @$core.pragma('dart2js:noInline')
  static SyncGroupRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncGroupRequest>(SyncGroupRequest.$_createMessage);
  static SyncGroupRequest? _defaultInstance;

  @$pb.TagNumber(1)
  GroupData get group => $_getN(0);
  @$pb.TagNumber(1)
  set group(GroupData value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasGroup() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroup() => $_clearField(1);
  @$pb.TagNumber(1)
  GroupData ensureGroup() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get walletId => $_getSZ(1);
  @$pb.TagNumber(2)
  set walletId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWalletId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWalletId() => $_clearField(2);
}

/// MultisigUtxo is one unspent output of the watch-only wallet.
class MultisigUtxo extends $pb.GeneratedMessage {
  factory MultisigUtxo({
    $core.String? txid,
    $core.int? vout,
    $core.String? address,
    $fixnum.Int64? amountSats,
    $core.int? confirmations,
    $core.String? scriptPubkey,
    $core.bool? spendable,
    $core.bool? solvable,
    $core.bool? safe,
  }) {
    final result = MultisigUtxo._();
    if (txid != null) result.txid = txid;
    if (vout != null) result.vout = vout;
    if (address != null) result.address = address;
    if (amountSats != null) result.amountSats = amountSats;
    if (confirmations != null) result.confirmations = confirmations;
    if (scriptPubkey != null) result.scriptPubkey = scriptPubkey;
    if (spendable != null) result.spendable = spendable;
    if (solvable != null) result.solvable = solvable;
    if (safe != null) result.safe = safe;
    return result;
  }

  MultisigUtxo._();

  factory MultisigUtxo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MultisigUtxo()..mergeFromBuffer(data, registry);
  factory MultisigUtxo.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MultisigUtxo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MultisigUtxo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'),
      createEmptyInstance: MultisigUtxo.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aI(2, _omitFieldNames ? '' : 'vout', fieldType: $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'address')
    ..aInt64(4, _omitFieldNames ? '' : 'amountSats')
    ..aI(5, _omitFieldNames ? '' : 'confirmations', fieldType: $pb.PbFieldType.OU3)
    ..aOS(6, _omitFieldNames ? '' : 'scriptPubkey')
    ..aOB(7, _omitFieldNames ? '' : 'spendable')
    ..aOB(8, _omitFieldNames ? '' : 'solvable')
    ..aOB(9, _omitFieldNames ? '' : 'safe')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MultisigUtxo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MultisigUtxo copyWith(void Function(MultisigUtxo) updates) =>
      super.copyWith((message) => updates(message as MultisigUtxo)) as MultisigUtxo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MultisigUtxo() / MultisigUtxo.new instead')
  static MultisigUtxo create() => MultisigUtxo._();
  static $pb.GeneratedMessage $_createMessage() => MultisigUtxo._();
  @$core.override
  MultisigUtxo createEmptyInstance() => MultisigUtxo._();
  @$core.pragma('dart2js:noInline')
  static MultisigUtxo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MultisigUtxo>(MultisigUtxo.$_createMessage);
  static MultisigUtxo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get vout => $_getIZ(1);
  @$pb.TagNumber(2)
  set vout($core.int value) => $_setUnsignedInt32(1, value);
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
  $fixnum.Int64 get amountSats => $_getI64(3);
  @$pb.TagNumber(4)
  set amountSats($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAmountSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearAmountSats() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get confirmations => $_getIZ(4);
  @$pb.TagNumber(5)
  set confirmations($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasConfirmations() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfirmations() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get scriptPubkey => $_getSZ(5);
  @$pb.TagNumber(6)
  set scriptPubkey($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasScriptPubkey() => $_has(5);
  @$pb.TagNumber(6)
  void clearScriptPubkey() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get spendable => $_getBF(6);
  @$pb.TagNumber(7)
  set spendable($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasSpendable() => $_has(6);
  @$pb.TagNumber(7)
  void clearSpendable() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get solvable => $_getBF(7);
  @$pb.TagNumber(8)
  set solvable($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSolvable() => $_has(7);
  @$pb.TagNumber(8)
  void clearSolvable() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get safe => $_getBF(8);
  @$pb.TagNumber(9)
  set safe($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasSafe() => $_has(8);
  @$pb.TagNumber(9)
  void clearSafe() => $_clearField(9);
}

class SyncGroupResponse extends $pb.GeneratedMessage {
  factory SyncGroupResponse({
    $fixnum.Int64? confirmedSats,
    $fixnum.Int64? pendingSats,
    $core.int? utxoCount,
    $core.Iterable<MultisigUtxo>? utxos,
  }) {
    final result = SyncGroupResponse._();
    if (confirmedSats != null) result.confirmedSats = confirmedSats;
    if (pendingSats != null) result.pendingSats = pendingSats;
    if (utxoCount != null) result.utxoCount = utxoCount;
    if (utxos != null) result.utxos.addAll(utxos);
    return result;
  }

  SyncGroupResponse._();

  factory SyncGroupResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncGroupResponse()..mergeFromBuffer(data, registry);
  factory SyncGroupResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SyncGroupResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncGroupResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'),
      createEmptyInstance: SyncGroupResponse.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'confirmedSats')
    ..aInt64(2, _omitFieldNames ? '' : 'pendingSats')
    ..aI(3, _omitFieldNames ? '' : 'utxoCount', fieldType: $pb.PbFieldType.OU3)
    ..pPM<MultisigUtxo>(4, _omitFieldNames ? '' : 'utxos', subBuilder: MultisigUtxo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncGroupResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SyncGroupResponse copyWith(void Function(SyncGroupResponse) updates) =>
      super.copyWith((message) => updates(message as SyncGroupResponse)) as SyncGroupResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SyncGroupResponse() / SyncGroupResponse.new instead')
  static SyncGroupResponse create() => SyncGroupResponse._();
  static $pb.GeneratedMessage $_createMessage() => SyncGroupResponse._();
  @$core.override
  SyncGroupResponse createEmptyInstance() => SyncGroupResponse._();
  @$core.pragma('dart2js:noInline')
  static SyncGroupResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncGroupResponse>(SyncGroupResponse.$_createMessage);
  static SyncGroupResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get confirmedSats => $_getI64(0);
  @$pb.TagNumber(1)
  set confirmedSats($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConfirmedSats() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfirmedSats() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get pendingSats => $_getI64(1);
  @$pb.TagNumber(2)
  set pendingSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPendingSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearPendingSats() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get utxoCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set utxoCount($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUtxoCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearUtxoCount() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<MultisigUtxo> get utxos => $_getList(3);
}

class RestoreHistoryRequest extends $pb.GeneratedMessage {
  factory RestoreHistoryRequest({
    GroupData? group,
    $core.String? walletId,
  }) {
    final result = RestoreHistoryRequest._();
    if (group != null) result.group = group;
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  RestoreHistoryRequest._();

  factory RestoreHistoryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RestoreHistoryRequest()..mergeFromBuffer(data, registry);
  factory RestoreHistoryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RestoreHistoryRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RestoreHistoryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'),
      createEmptyInstance: RestoreHistoryRequest.$_createMessage)
    ..aOM<GroupData>(1, _omitFieldNames ? '' : 'group', subBuilder: GroupData.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestoreHistoryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestoreHistoryRequest copyWith(void Function(RestoreHistoryRequest) updates) =>
      super.copyWith((message) => updates(message as RestoreHistoryRequest)) as RestoreHistoryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RestoreHistoryRequest() / RestoreHistoryRequest.new instead')
  static RestoreHistoryRequest create() => RestoreHistoryRequest._();
  static $pb.GeneratedMessage $_createMessage() => RestoreHistoryRequest._();
  @$core.override
  RestoreHistoryRequest createEmptyInstance() => RestoreHistoryRequest._();
  @$core.pragma('dart2js:noInline')
  static RestoreHistoryRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RestoreHistoryRequest>(RestoreHistoryRequest.$_createMessage);
  static RestoreHistoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  GroupData get group => $_getN(0);
  @$pb.TagNumber(1)
  set group(GroupData value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasGroup() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroup() => $_clearField(1);
  @$pb.TagNumber(1)
  GroupData ensureGroup() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get walletId => $_getSZ(1);
  @$pb.TagNumber(2)
  set walletId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWalletId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWalletId() => $_clearField(2);
}

/// MultisigHistoryInput is one input of a reconstructed historical transaction.
class MultisigHistoryInput extends $pb.GeneratedMessage {
  factory MultisigHistoryInput({
    $core.String? txid,
    $core.int? vout,
  }) {
    final result = MultisigHistoryInput._();
    if (txid != null) result.txid = txid;
    if (vout != null) result.vout = vout;
    return result;
  }

  MultisigHistoryInput._();

  factory MultisigHistoryInput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MultisigHistoryInput()..mergeFromBuffer(data, registry);
  factory MultisigHistoryInput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MultisigHistoryInput()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MultisigHistoryInput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'),
      createEmptyInstance: MultisigHistoryInput.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aI(2, _omitFieldNames ? '' : 'vout', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MultisigHistoryInput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MultisigHistoryInput copyWith(void Function(MultisigHistoryInput) updates) =>
      super.copyWith((message) => updates(message as MultisigHistoryInput)) as MultisigHistoryInput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MultisigHistoryInput() / MultisigHistoryInput.new instead')
  static MultisigHistoryInput create() => MultisigHistoryInput._();
  static $pb.GeneratedMessage $_createMessage() => MultisigHistoryInput._();
  @$core.override
  MultisigHistoryInput createEmptyInstance() => MultisigHistoryInput._();
  @$core.pragma('dart2js:noInline')
  static MultisigHistoryInput getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MultisigHistoryInput>(MultisigHistoryInput.$_createMessage);
  static MultisigHistoryInput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get vout => $_getIZ(1);
  @$pb.TagNumber(2)
  set vout($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearVout() => $_clearField(2);
}

/// MultisigHistoryTx is a reconstructed group transaction from chain history.
class MultisigHistoryTx extends $pb.GeneratedMessage {
  factory MultisigHistoryTx({
    $core.String? txid,
    $fixnum.Int64? amountSats,
    $core.bool? isDeposit,
    $core.String? destination,
    $core.int? confirmations,
    $core.int? signatureCount,
    $core.String? status,
    $fixnum.Int64? time,
    $core.String? finalHex,
    $core.Iterable<MultisigHistoryInput>? inputs,
  }) {
    final result = MultisigHistoryTx._();
    if (txid != null) result.txid = txid;
    if (amountSats != null) result.amountSats = amountSats;
    if (isDeposit != null) result.isDeposit = isDeposit;
    if (destination != null) result.destination = destination;
    if (confirmations != null) result.confirmations = confirmations;
    if (signatureCount != null) result.signatureCount = signatureCount;
    if (status != null) result.status = status;
    if (time != null) result.time = time;
    if (finalHex != null) result.finalHex = finalHex;
    if (inputs != null) result.inputs.addAll(inputs);
    return result;
  }

  MultisigHistoryTx._();

  factory MultisigHistoryTx.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MultisigHistoryTx()..mergeFromBuffer(data, registry);
  factory MultisigHistoryTx.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MultisigHistoryTx()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MultisigHistoryTx',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'),
      createEmptyInstance: MultisigHistoryTx.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aInt64(2, _omitFieldNames ? '' : 'amountSats')
    ..aOB(3, _omitFieldNames ? '' : 'isDeposit')
    ..aOS(4, _omitFieldNames ? '' : 'destination')
    ..aI(5, _omitFieldNames ? '' : 'confirmations', fieldType: $pb.PbFieldType.OU3)
    ..aI(6, _omitFieldNames ? '' : 'signatureCount', fieldType: $pb.PbFieldType.OU3)
    ..aOS(7, _omitFieldNames ? '' : 'status')
    ..aInt64(8, _omitFieldNames ? '' : 'time')
    ..aOS(9, _omitFieldNames ? '' : 'finalHex')
    ..pPM<MultisigHistoryInput>(10, _omitFieldNames ? '' : 'inputs', subBuilder: MultisigHistoryInput.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MultisigHistoryTx clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MultisigHistoryTx copyWith(void Function(MultisigHistoryTx) updates) =>
      super.copyWith((message) => updates(message as MultisigHistoryTx)) as MultisigHistoryTx;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MultisigHistoryTx() / MultisigHistoryTx.new instead')
  static MultisigHistoryTx create() => MultisigHistoryTx._();
  static $pb.GeneratedMessage $_createMessage() => MultisigHistoryTx._();
  @$core.override
  MultisigHistoryTx createEmptyInstance() => MultisigHistoryTx._();
  @$core.pragma('dart2js:noInline')
  static MultisigHistoryTx getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MultisigHistoryTx>(MultisigHistoryTx.$_createMessage);
  static MultisigHistoryTx? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  /// Absolute amount in sats (sign dropped; see is_deposit for direction).
  @$pb.TagNumber(2)
  $fixnum.Int64 get amountSats => $_getI64(1);
  @$pb.TagNumber(2)
  set amountSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAmountSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmountSats() => $_clearField(2);

  /// True when the wallet received (positive listtransactions amount).
  @$pb.TagNumber(3)
  $core.bool get isDeposit => $_getBF(2);
  @$pb.TagNumber(3)
  set isDeposit($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsDeposit() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsDeposit() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get destination => $_getSZ(3);
  @$pb.TagNumber(4)
  set destination($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDestination() => $_has(3);
  @$pb.TagNumber(4)
  void clearDestination() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get confirmations => $_getIZ(4);
  @$pb.TagNumber(5)
  set confirmations($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasConfirmations() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfirmations() => $_clearField(5);

  /// Signatures counted from the transaction's witness/scriptSig.
  @$pb.TagNumber(6)
  $core.int get signatureCount => $_getIZ(5);
  @$pb.TagNumber(6)
  set signatureCount($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasSignatureCount() => $_has(5);
  @$pb.TagNumber(6)
  void clearSignatureCount() => $_clearField(6);

  /// "broadcasted" (0-conf or <6), or "confirmed" (>=6).
  @$pb.TagNumber(7)
  $core.String get status => $_getSZ(6);
  @$pb.TagNumber(7)
  set status($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatus() => $_clearField(7);

  /// Block/receive time, seconds since epoch.
  @$pb.TagNumber(8)
  $fixnum.Int64 get time => $_getI64(7);
  @$pb.TagNumber(8)
  set time($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasTime() => $_has(7);
  @$pb.TagNumber(8)
  void clearTime() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get finalHex => $_getSZ(8);
  @$pb.TagNumber(9)
  set finalHex($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasFinalHex() => $_has(8);
  @$pb.TagNumber(9)
  void clearFinalHex() => $_clearField(9);

  @$pb.TagNumber(10)
  $pb.PbList<MultisigHistoryInput> get inputs => $_getList(9);
}

class RestoreHistoryResponse extends $pb.GeneratedMessage {
  factory RestoreHistoryResponse({
    $core.Iterable<MultisigHistoryTx>? transactions,
  }) {
    final result = RestoreHistoryResponse._();
    if (transactions != null) result.transactions.addAll(transactions);
    return result;
  }

  RestoreHistoryResponse._();

  factory RestoreHistoryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RestoreHistoryResponse()..mergeFromBuffer(data, registry);
  factory RestoreHistoryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RestoreHistoryResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RestoreHistoryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'),
      createEmptyInstance: RestoreHistoryResponse.$_createMessage)
    ..pPM<MultisigHistoryTx>(1, _omitFieldNames ? '' : 'transactions', subBuilder: MultisigHistoryTx.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestoreHistoryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestoreHistoryResponse copyWith(void Function(RestoreHistoryResponse) updates) =>
      super.copyWith((message) => updates(message as RestoreHistoryResponse)) as RestoreHistoryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RestoreHistoryResponse() / RestoreHistoryResponse.new instead')
  static RestoreHistoryResponse create() => RestoreHistoryResponse._();
  static $pb.GeneratedMessage $_createMessage() => RestoreHistoryResponse._();
  @$core.override
  RestoreHistoryResponse createEmptyInstance() => RestoreHistoryResponse._();
  @$core.pragma('dart2js:noInline')
  static RestoreHistoryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RestoreHistoryResponse>(RestoreHistoryResponse.$_createMessage);
  static RestoreHistoryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<MultisigHistoryTx> get transactions => $_getList(0);
}

class SignTransactionRequest extends $pb.GeneratedMessage {
  factory SignTransactionRequest({
    $core.String? psbtBase64,
    GroupData? group,
    $core.String? walletId,
  }) {
    final result = SignTransactionRequest._();
    if (psbtBase64 != null) result.psbtBase64 = psbtBase64;
    if (group != null) result.group = group;
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  SignTransactionRequest._();

  factory SignTransactionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignTransactionRequest()..mergeFromBuffer(data, registry);
  factory SignTransactionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignTransactionRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignTransactionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'),
      createEmptyInstance: SignTransactionRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'psbtBase64')
    ..aOM<GroupData>(2, _omitFieldNames ? '' : 'group', subBuilder: GroupData.$_createMessage)
    ..aOS(3, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignTransactionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignTransactionRequest copyWith(void Function(SignTransactionRequest) updates) =>
      super.copyWith((message) => updates(message as SignTransactionRequest)) as SignTransactionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SignTransactionRequest() / SignTransactionRequest.new instead')
  static SignTransactionRequest create() => SignTransactionRequest._();
  static $pb.GeneratedMessage $_createMessage() => SignTransactionRequest._();
  @$core.override
  SignTransactionRequest createEmptyInstance() => SignTransactionRequest._();
  @$core.pragma('dart2js:noInline')
  static SignTransactionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SignTransactionRequest>(SignTransactionRequest.$_createMessage);
  static SignTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbtBase64 => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbtBase64($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPsbtBase64() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbtBase64() => $_clearField(1);

  /// Full group (with per-key derivation paths) so the wallet's xprv can be
  /// derived and substituted into the signing descriptor.
  @$pb.TagNumber(2)
  GroupData get group => $_getN(1);
  @$pb.TagNumber(2)
  set group(GroupData value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasGroup() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroup() => $_clearField(2);
  @$pb.TagNumber(2)
  GroupData ensureGroup() => $_ensure(1);

  /// Wallet whose seed-derived keys sign the PSBT.
  @$pb.TagNumber(3)
  $core.String get walletId => $_getSZ(2);
  @$pb.TagNumber(3)
  set walletId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWalletId() => $_has(2);
  @$pb.TagNumber(3)
  void clearWalletId() => $_clearField(3);
}

class SignTransactionResponse extends $pb.GeneratedMessage {
  factory SignTransactionResponse({
    $core.String? psbtBase64,
    $core.int? addedSignatures,
    $core.bool? isComplete,
  }) {
    final result = SignTransactionResponse._();
    if (psbtBase64 != null) result.psbtBase64 = psbtBase64;
    if (addedSignatures != null) result.addedSignatures = addedSignatures;
    if (isComplete != null) result.isComplete = isComplete;
    return result;
  }

  SignTransactionResponse._();

  factory SignTransactionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignTransactionResponse()..mergeFromBuffer(data, registry);
  factory SignTransactionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignTransactionResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignTransactionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'),
      createEmptyInstance: SignTransactionResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'psbtBase64')
    ..aI(2, _omitFieldNames ? '' : 'addedSignatures', fieldType: $pb.PbFieldType.OU3)
    ..aOB(3, _omitFieldNames ? '' : 'isComplete')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignTransactionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignTransactionResponse copyWith(void Function(SignTransactionResponse) updates) =>
      super.copyWith((message) => updates(message as SignTransactionResponse)) as SignTransactionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SignTransactionResponse() / SignTransactionResponse.new instead')
  static SignTransactionResponse create() => SignTransactionResponse._();
  static $pb.GeneratedMessage $_createMessage() => SignTransactionResponse._();
  @$core.override
  SignTransactionResponse createEmptyInstance() => SignTransactionResponse._();
  @$core.pragma('dart2js:noInline')
  static SignTransactionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SignTransactionResponse>(SignTransactionResponse.$_createMessage);
  static SignTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbtBase64 => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbtBase64($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPsbtBase64() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbtBase64() => $_clearField(1);

  /// Number of partial signatures this call added.
  @$pb.TagNumber(2)
  $core.int get addedSignatures => $_getIZ(1);
  @$pb.TagNumber(2)
  set addedSignatures($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAddedSignatures() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddedSignatures() => $_clearField(2);

  /// True once the PSBT carries the threshold of signatures.
  @$pb.TagNumber(3)
  $core.bool get isComplete => $_getBF(2);
  @$pb.TagNumber(3)
  set isComplete($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsComplete() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsComplete() => $_clearField(3);
}

class CombineAndBroadcastRequest extends $pb.GeneratedMessage {
  factory CombineAndBroadcastRequest({
    $core.Iterable<$core.String>? psbts,
    GroupData? group,
  }) {
    final result = CombineAndBroadcastRequest._();
    if (psbts != null) result.psbts.addAll(psbts);
    if (group != null) result.group = group;
    return result;
  }

  CombineAndBroadcastRequest._();

  factory CombineAndBroadcastRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CombineAndBroadcastRequest()..mergeFromBuffer(data, registry);
  factory CombineAndBroadcastRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CombineAndBroadcastRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CombineAndBroadcastRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'),
      createEmptyInstance: CombineAndBroadcastRequest.$_createMessage)
    ..pPS(1, _omitFieldNames ? '' : 'psbts')
    ..aOM<GroupData>(2, _omitFieldNames ? '' : 'group', subBuilder: GroupData.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CombineAndBroadcastRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CombineAndBroadcastRequest copyWith(void Function(CombineAndBroadcastRequest) updates) =>
      super.copyWith((message) => updates(message as CombineAndBroadcastRequest)) as CombineAndBroadcastRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CombineAndBroadcastRequest() / CombineAndBroadcastRequest.new instead')
  static CombineAndBroadcastRequest create() => CombineAndBroadcastRequest._();
  static $pb.GeneratedMessage $_createMessage() => CombineAndBroadcastRequest._();
  @$core.override
  CombineAndBroadcastRequest createEmptyInstance() => CombineAndBroadcastRequest._();
  @$core.pragma('dart2js:noInline')
  static CombineAndBroadcastRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CombineAndBroadcastRequest>(CombineAndBroadcastRequest.$_createMessage);
  static CombineAndBroadcastRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get psbts => $_getList(0);

  /// Full group, used to reject PSBTs that do not belong to it before combining.
  @$pb.TagNumber(2)
  GroupData get group => $_getN(1);
  @$pb.TagNumber(2)
  set group(GroupData value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasGroup() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroup() => $_clearField(2);
  @$pb.TagNumber(2)
  GroupData ensureGroup() => $_ensure(1);
}

class CombineAndBroadcastResponse extends $pb.GeneratedMessage {
  factory CombineAndBroadcastResponse({
    $core.String? txid,
  }) {
    final result = CombineAndBroadcastResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  CombineAndBroadcastResponse._();

  factory CombineAndBroadcastResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CombineAndBroadcastResponse()..mergeFromBuffer(data, registry);
  factory CombineAndBroadcastResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CombineAndBroadcastResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CombineAndBroadcastResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'),
      createEmptyInstance: CombineAndBroadcastResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CombineAndBroadcastResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CombineAndBroadcastResponse copyWith(void Function(CombineAndBroadcastResponse) updates) =>
      super.copyWith((message) => updates(message as CombineAndBroadcastResponse)) as CombineAndBroadcastResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CombineAndBroadcastResponse() / CombineAndBroadcastResponse.new instead')
  static CombineAndBroadcastResponse create() => CombineAndBroadcastResponse._();
  static $pb.GeneratedMessage $_createMessage() => CombineAndBroadcastResponse._();
  @$core.override
  CombineAndBroadcastResponse createEmptyInstance() => CombineAndBroadcastResponse._();
  @$core.pragma('dart2js:noInline')
  static CombineAndBroadcastResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CombineAndBroadcastResponse>(CombineAndBroadcastResponse.$_createMessage);
  static CombineAndBroadcastResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

/// GroupKey is one cosigner key with the full metadata carried in the published
/// OP_RETURN group JSON.
class GroupKey extends $pb.GeneratedMessage {
  factory GroupKey({
    $core.String? owner,
    $core.String? xpub,
    $core.String? derivationPath,
    $core.String? fingerprint,
    $core.String? originPath,
    $core.bool? isWallet,
  }) {
    final result = GroupKey._();
    if (owner != null) result.owner = owner;
    if (xpub != null) result.xpub = xpub;
    if (derivationPath != null) result.derivationPath = derivationPath;
    if (fingerprint != null) result.fingerprint = fingerprint;
    if (originPath != null) result.originPath = originPath;
    if (isWallet != null) result.isWallet = isWallet;
    return result;
  }

  GroupKey._();

  factory GroupKey.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GroupKey()..mergeFromBuffer(data, registry);
  factory GroupKey.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GroupKey()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GroupKey',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'),
      createEmptyInstance: GroupKey.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'owner')
    ..aOS(2, _omitFieldNames ? '' : 'xpub')
    ..aOS(3, _omitFieldNames ? '' : 'derivationPath')
    ..aOS(4, _omitFieldNames ? '' : 'fingerprint')
    ..aOS(5, _omitFieldNames ? '' : 'originPath')
    ..aOB(6, _omitFieldNames ? '' : 'isWallet')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupKey clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupKey copyWith(void Function(GroupKey) updates) =>
      super.copyWith((message) => updates(message as GroupKey)) as GroupKey;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GroupKey() / GroupKey.new instead')
  static GroupKey create() => GroupKey._();
  static $pb.GeneratedMessage $_createMessage() => GroupKey._();
  @$core.override
  GroupKey createEmptyInstance() => GroupKey._();
  @$core.pragma('dart2js:noInline')
  static GroupKey getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GroupKey>(GroupKey.$_createMessage);
  static GroupKey? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get owner => $_getSZ(0);
  @$pb.TagNumber(1)
  set owner($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOwner() => $_has(0);
  @$pb.TagNumber(1)
  void clearOwner() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get xpub => $_getSZ(1);
  @$pb.TagNumber(2)
  set xpub($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasXpub() => $_has(1);
  @$pb.TagNumber(2)
  void clearXpub() => $_clearField(2);

  /// Full BIP32 derivation path, e.g. "m/48'/1'/0'/2'".
  @$pb.TagNumber(3)
  $core.String get derivationPath => $_getSZ(2);
  @$pb.TagNumber(3)
  set derivationPath($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDerivationPath() => $_has(2);
  @$pb.TagNumber(3)
  void clearDerivationPath() => $_clearField(3);

  /// Master key fingerprint, 8 hex chars. Empty for non-wallet keys.
  @$pb.TagNumber(4)
  $core.String get fingerprint => $_getSZ(3);
  @$pb.TagNumber(4)
  set fingerprint($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFingerprint() => $_has(3);
  @$pb.TagNumber(4)
  void clearFingerprint() => $_clearField(4);

  /// Origin path without the leading "m/". Empty for non-wallet keys.
  @$pb.TagNumber(5)
  $core.String get originPath => $_getSZ(4);
  @$pb.TagNumber(5)
  set originPath($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOriginPath() => $_has(4);
  @$pb.TagNumber(5)
  void clearOriginPath() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isWallet => $_getBF(5);
  @$pb.TagNumber(6)
  set isWallet($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIsWallet() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsWallet() => $_clearField(6);
}

/// GroupData is a full multisig group as published in an OP_RETURN.
class GroupData extends $pb.GeneratedMessage {
  factory GroupData({
    $core.String? id,
    $core.String? name,
    $core.int? n,
    $core.int? m,
    $core.Iterable<GroupKey>? keys,
    $fixnum.Int64? created,
    $core.String? descriptorReceive,
    $core.String? descriptorChange,
    $core.String? watchWalletName,
    $core.String? txid,
  }) {
    final result = GroupData._();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (n != null) result.n = n;
    if (m != null) result.m = m;
    if (keys != null) result.keys.addAll(keys);
    if (created != null) result.created = created;
    if (descriptorReceive != null) result.descriptorReceive = descriptorReceive;
    if (descriptorChange != null) result.descriptorChange = descriptorChange;
    if (watchWalletName != null) result.watchWalletName = watchWalletName;
    if (txid != null) result.txid = txid;
    return result;
  }

  GroupData._();

  factory GroupData.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GroupData()..mergeFromBuffer(data, registry);
  factory GroupData.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GroupData()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GroupData',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'),
      createEmptyInstance: GroupData.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aI(3, _omitFieldNames ? '' : 'n', fieldType: $pb.PbFieldType.OU3)
    ..aI(4, _omitFieldNames ? '' : 'm', fieldType: $pb.PbFieldType.OU3)
    ..pPM<GroupKey>(5, _omitFieldNames ? '' : 'keys', subBuilder: GroupKey.$_createMessage)
    ..aInt64(6, _omitFieldNames ? '' : 'created')
    ..aOS(7, _omitFieldNames ? '' : 'descriptorReceive')
    ..aOS(8, _omitFieldNames ? '' : 'descriptorChange')
    ..aOS(9, _omitFieldNames ? '' : 'watchWalletName')
    ..aOS(10, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupData clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GroupData copyWith(void Function(GroupData) updates) =>
      super.copyWith((message) => updates(message as GroupData)) as GroupData;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GroupData() / GroupData.new instead')
  static GroupData create() => GroupData._();
  static $pb.GeneratedMessage $_createMessage() => GroupData._();
  @$core.override
  GroupData createEmptyInstance() => GroupData._();
  @$core.pragma('dart2js:noInline')
  static GroupData getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GroupData>(GroupData.$_createMessage);
  static GroupData? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get n => $_getIZ(2);
  @$pb.TagNumber(3)
  set n($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasN() => $_has(2);
  @$pb.TagNumber(3)
  void clearN() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get m => $_getIZ(3);
  @$pb.TagNumber(4)
  set m($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasM() => $_has(3);
  @$pb.TagNumber(4)
  void clearM() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<GroupKey> get keys => $_getList(4);

  /// Creation time, milliseconds since epoch (matches the Dart 'created' field).
  @$pb.TagNumber(6)
  $fixnum.Int64 get created => $_getI64(5);
  @$pb.TagNumber(6)
  set created($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCreated() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreated() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get descriptorReceive => $_getSZ(6);
  @$pb.TagNumber(7)
  set descriptorReceive($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDescriptorReceive() => $_has(6);
  @$pb.TagNumber(7)
  void clearDescriptorReceive() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get descriptorChange => $_getSZ(7);
  @$pb.TagNumber(8)
  set descriptorChange($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDescriptorChange() => $_has(7);
  @$pb.TagNumber(8)
  void clearDescriptorChange() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.String get watchWalletName => $_getSZ(8);
  @$pb.TagNumber(9)
  set watchWalletName($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasWatchWalletName() => $_has(8);
  @$pb.TagNumber(9)
  void clearWatchWalletName() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get txid => $_getSZ(9);
  @$pb.TagNumber(10)
  set txid($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasTxid() => $_has(9);
  @$pb.TagNumber(10)
  void clearTxid() => $_clearField(10);
}

class PublishGroupRequest extends $pb.GeneratedMessage {
  factory PublishGroupRequest({
    GroupData? group,
    $core.String? walletId,
  }) {
    final result = PublishGroupRequest._();
    if (group != null) result.group = group;
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  PublishGroupRequest._();

  factory PublishGroupRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PublishGroupRequest()..mergeFromBuffer(data, registry);
  factory PublishGroupRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PublishGroupRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PublishGroupRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'),
      createEmptyInstance: PublishGroupRequest.$_createMessage)
    ..aOM<GroupData>(1, _omitFieldNames ? '' : 'group', subBuilder: GroupData.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PublishGroupRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PublishGroupRequest copyWith(void Function(PublishGroupRequest) updates) =>
      super.copyWith((message) => updates(message as PublishGroupRequest)) as PublishGroupRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PublishGroupRequest() / PublishGroupRequest.new instead')
  static PublishGroupRequest create() => PublishGroupRequest._();
  static $pb.GeneratedMessage $_createMessage() => PublishGroupRequest._();
  @$core.override
  PublishGroupRequest createEmptyInstance() => PublishGroupRequest._();
  @$core.pragma('dart2js:noInline')
  static PublishGroupRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PublishGroupRequest>(PublishGroupRequest.$_createMessage);
  static PublishGroupRequest? _defaultInstance;

  @$pb.TagNumber(1)
  GroupData get group => $_getN(0);
  @$pb.TagNumber(1)
  set group(GroupData value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasGroup() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroup() => $_clearField(1);
  @$pb.TagNumber(1)
  GroupData ensureGroup() => $_ensure(0);

  /// Wallet that funds the broadcast and provides the fresh address.
  @$pb.TagNumber(2)
  $core.String get walletId => $_getSZ(1);
  @$pb.TagNumber(2)
  set walletId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWalletId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWalletId() => $_clearField(2);
}

class PublishGroupResponse extends $pb.GeneratedMessage {
  factory PublishGroupResponse({
    $core.String? txid,
  }) {
    final result = PublishGroupResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  PublishGroupResponse._();

  factory PublishGroupResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PublishGroupResponse()..mergeFromBuffer(data, registry);
  factory PublishGroupResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PublishGroupResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PublishGroupResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'),
      createEmptyInstance: PublishGroupResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PublishGroupResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PublishGroupResponse copyWith(void Function(PublishGroupResponse) updates) =>
      super.copyWith((message) => updates(message as PublishGroupResponse)) as PublishGroupResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PublishGroupResponse() / PublishGroupResponse.new instead')
  static PublishGroupResponse create() => PublishGroupResponse._();
  static $pb.GeneratedMessage $_createMessage() => PublishGroupResponse._();
  @$core.override
  PublishGroupResponse createEmptyInstance() => PublishGroupResponse._();
  @$core.pragma('dart2js:noInline')
  static PublishGroupResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PublishGroupResponse>(PublishGroupResponse.$_createMessage);
  static PublishGroupResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class ImportGroupFromTxidRequest extends $pb.GeneratedMessage {
  factory ImportGroupFromTxidRequest({
    $core.String? txid,
    $core.String? walletId,
  }) {
    final result = ImportGroupFromTxidRequest._();
    if (txid != null) result.txid = txid;
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  ImportGroupFromTxidRequest._();

  factory ImportGroupFromTxidRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportGroupFromTxidRequest()..mergeFromBuffer(data, registry);
  factory ImportGroupFromTxidRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportGroupFromTxidRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportGroupFromTxidRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'),
      createEmptyInstance: ImportGroupFromTxidRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aOS(2, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportGroupFromTxidRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportGroupFromTxidRequest copyWith(void Function(ImportGroupFromTxidRequest) updates) =>
      super.copyWith((message) => updates(message as ImportGroupFromTxidRequest)) as ImportGroupFromTxidRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ImportGroupFromTxidRequest() / ImportGroupFromTxidRequest.new instead')
  static ImportGroupFromTxidRequest create() => ImportGroupFromTxidRequest._();
  static $pb.GeneratedMessage $_createMessage() => ImportGroupFromTxidRequest._();
  @$core.override
  ImportGroupFromTxidRequest createEmptyInstance() => ImportGroupFromTxidRequest._();
  @$core.pragma('dart2js:noInline')
  static ImportGroupFromTxidRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImportGroupFromTxidRequest>(ImportGroupFromTxidRequest.$_createMessage);
  static ImportGroupFromTxidRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  /// Wallet whose keys are matched against the group's cosigners.
  @$pb.TagNumber(2)
  $core.String get walletId => $_getSZ(1);
  @$pb.TagNumber(2)
  set walletId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWalletId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWalletId() => $_clearField(2);
}

class ImportGroupFromTxidResponse extends $pb.GeneratedMessage {
  factory ImportGroupFromTxidResponse({
    GroupData? group,
    $core.Iterable<$core.int>? walletKeyIndices,
  }) {
    final result = ImportGroupFromTxidResponse._();
    if (group != null) result.group = group;
    if (walletKeyIndices != null) result.walletKeyIndices.addAll(walletKeyIndices);
    return result;
  }

  ImportGroupFromTxidResponse._();

  factory ImportGroupFromTxidResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportGroupFromTxidResponse()..mergeFromBuffer(data, registry);
  factory ImportGroupFromTxidResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ImportGroupFromTxidResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportGroupFromTxidResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'),
      createEmptyInstance: ImportGroupFromTxidResponse.$_createMessage)
    ..aOM<GroupData>(1, _omitFieldNames ? '' : 'group', subBuilder: GroupData.$_createMessage)
    ..p<$core.int>(2, _omitFieldNames ? '' : 'walletKeyIndices', $pb.PbFieldType.KU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportGroupFromTxidResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ImportGroupFromTxidResponse copyWith(void Function(ImportGroupFromTxidResponse) updates) =>
      super.copyWith((message) => updates(message as ImportGroupFromTxidResponse)) as ImportGroupFromTxidResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ImportGroupFromTxidResponse() / ImportGroupFromTxidResponse.new instead')
  static ImportGroupFromTxidResponse create() => ImportGroupFromTxidResponse._();
  static $pb.GeneratedMessage $_createMessage() => ImportGroupFromTxidResponse._();
  @$core.override
  ImportGroupFromTxidResponse createEmptyInstance() => ImportGroupFromTxidResponse._();
  @$core.pragma('dart2js:noInline')
  static ImportGroupFromTxidResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ImportGroupFromTxidResponse>(ImportGroupFromTxidResponse.$_createMessage);
  static ImportGroupFromTxidResponse? _defaultInstance;

  @$pb.TagNumber(1)
  GroupData get group => $_getN(0);
  @$pb.TagNumber(1)
  set group(GroupData value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasGroup() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroup() => $_clearField(1);
  @$pb.TagNumber(1)
  GroupData ensureGroup() => $_ensure(0);

  /// Indices into group.keys that belong to the wallet (derived xpub matches).
  @$pb.TagNumber(2)
  $pb.PbList<$core.int> get walletKeyIndices => $_getList(1);
}

/// MultisigKey is one cosigner key in a group.
class MultisigKey extends $pb.GeneratedMessage {
  factory MultisigKey({
    $core.String? xpub,
    $core.String? derivationPath,
    $core.String? fingerprint,
    $core.String? originPath,
    $core.bool? isWallet,
  }) {
    final result = MultisigKey._();
    if (xpub != null) result.xpub = xpub;
    if (derivationPath != null) result.derivationPath = derivationPath;
    if (fingerprint != null) result.fingerprint = fingerprint;
    if (originPath != null) result.originPath = originPath;
    if (isWallet != null) result.isWallet = isWallet;
    return result;
  }

  MultisigKey._();

  factory MultisigKey.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MultisigKey()..mergeFromBuffer(data, registry);
  factory MultisigKey.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MultisigKey()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MultisigKey',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'),
      createEmptyInstance: MultisigKey.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'xpub')
    ..aOS(2, _omitFieldNames ? '' : 'derivationPath')
    ..aOS(3, _omitFieldNames ? '' : 'fingerprint')
    ..aOS(4, _omitFieldNames ? '' : 'originPath')
    ..aOB(5, _omitFieldNames ? '' : 'isWallet')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MultisigKey clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MultisigKey copyWith(void Function(MultisigKey) updates) =>
      super.copyWith((message) => updates(message as MultisigKey)) as MultisigKey;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MultisigKey() / MultisigKey.new instead')
  static MultisigKey create() => MultisigKey._();
  static $pb.GeneratedMessage $_createMessage() => MultisigKey._();
  @$core.override
  MultisigKey createEmptyInstance() => MultisigKey._();
  @$core.pragma('dart2js:noInline')
  static MultisigKey getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MultisigKey>(MultisigKey.$_createMessage);
  static MultisigKey? _defaultInstance;

  /// Extended public key (xpub/tpub).
  @$pb.TagNumber(1)
  $core.String get xpub => $_getSZ(0);
  @$pb.TagNumber(1)
  set xpub($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasXpub() => $_has(0);
  @$pb.TagNumber(1)
  void clearXpub() => $_clearField(1);

  /// Full BIP32 derivation path of the account key, e.g. "m/48'/1'/0'/2'".
  @$pb.TagNumber(2)
  $core.String get derivationPath => $_getSZ(1);
  @$pb.TagNumber(2)
  set derivationPath($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDerivationPath() => $_has(1);
  @$pb.TagNumber(2)
  void clearDerivationPath() => $_clearField(2);

  /// Master key fingerprint, 8 hex chars. Empty for non-wallet keys.
  @$pb.TagNumber(3)
  $core.String get fingerprint => $_getSZ(2);
  @$pb.TagNumber(3)
  set fingerprint($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFingerprint() => $_has(2);
  @$pb.TagNumber(3)
  void clearFingerprint() => $_clearField(3);

  /// Origin path without the leading "m/", e.g. "48'/1'/0'/2'". Empty for non-wallet keys.
  @$pb.TagNumber(4)
  $core.String get originPath => $_getSZ(3);
  @$pb.TagNumber(4)
  set originPath($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOriginPath() => $_has(3);
  @$pb.TagNumber(4)
  void clearOriginPath() => $_clearField(4);

  /// True if this key is owned by the local wallet (emits a [fp/origin] prefix).
  @$pb.TagNumber(5)
  $core.bool get isWallet => $_getBF(4);
  @$pb.TagNumber(5)
  set isWallet($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasIsWallet() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsWallet() => $_clearField(5);
}

/// MultisigGroup describes an m-of-n policy.
class MultisigGroup extends $pb.GeneratedMessage {
  factory MultisigGroup({
    $core.int? m,
    $core.int? n,
    $core.Iterable<MultisigKey>? keys,
  }) {
    final result = MultisigGroup._();
    if (m != null) result.m = m;
    if (n != null) result.n = n;
    if (keys != null) result.keys.addAll(keys);
    return result;
  }

  MultisigGroup._();

  factory MultisigGroup.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MultisigGroup()..mergeFromBuffer(data, registry);
  factory MultisigGroup.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MultisigGroup()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MultisigGroup',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'),
      createEmptyInstance: MultisigGroup.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'm', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'n', fieldType: $pb.PbFieldType.OU3)
    ..pPM<MultisigKey>(3, _omitFieldNames ? '' : 'keys', subBuilder: MultisigKey.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MultisigGroup clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MultisigGroup copyWith(void Function(MultisigGroup) updates) =>
      super.copyWith((message) => updates(message as MultisigGroup)) as MultisigGroup;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MultisigGroup() / MultisigGroup.new instead')
  static MultisigGroup create() => MultisigGroup._();
  static $pb.GeneratedMessage $_createMessage() => MultisigGroup._();
  @$core.override
  MultisigGroup createEmptyInstance() => MultisigGroup._();
  @$core.pragma('dart2js:noInline')
  static MultisigGroup getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MultisigGroup>(MultisigGroup.$_createMessage);
  static MultisigGroup? _defaultInstance;

  /// Threshold (m): signatures required.
  @$pb.TagNumber(1)
  $core.int get m => $_getIZ(0);
  @$pb.TagNumber(1)
  set m($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasM() => $_has(0);
  @$pb.TagNumber(1)
  void clearM() => $_clearField(1);

  /// Total keys (n).
  @$pb.TagNumber(2)
  $core.int get n => $_getIZ(1);
  @$pb.TagNumber(2)
  set n($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasN() => $_has(1);
  @$pb.TagNumber(2)
  void clearN() => $_clearField(2);

  @$pb.TagNumber(3)
  $pb.PbList<MultisigKey> get keys => $_getList(2);
}

class BuildDescriptorsRequest extends $pb.GeneratedMessage {
  factory BuildDescriptorsRequest({
    MultisigGroup? group,
    $core.String? scriptType,
  }) {
    final result = BuildDescriptorsRequest._();
    if (group != null) result.group = group;
    if (scriptType != null) result.scriptType = scriptType;
    return result;
  }

  BuildDescriptorsRequest._();

  factory BuildDescriptorsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BuildDescriptorsRequest()..mergeFromBuffer(data, registry);
  factory BuildDescriptorsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BuildDescriptorsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BuildDescriptorsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'),
      createEmptyInstance: BuildDescriptorsRequest.$_createMessage)
    ..aOM<MultisigGroup>(1, _omitFieldNames ? '' : 'group', subBuilder: MultisigGroup.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'scriptType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BuildDescriptorsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BuildDescriptorsRequest copyWith(void Function(BuildDescriptorsRequest) updates) =>
      super.copyWith((message) => updates(message as BuildDescriptorsRequest)) as BuildDescriptorsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BuildDescriptorsRequest() / BuildDescriptorsRequest.new instead')
  static BuildDescriptorsRequest create() => BuildDescriptorsRequest._();
  static $pb.GeneratedMessage $_createMessage() => BuildDescriptorsRequest._();
  @$core.override
  BuildDescriptorsRequest createEmptyInstance() => BuildDescriptorsRequest._();
  @$core.pragma('dart2js:noInline')
  static BuildDescriptorsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BuildDescriptorsRequest>(BuildDescriptorsRequest.$_createMessage);
  static BuildDescriptorsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  MultisigGroup get group => $_getN(0);
  @$pb.TagNumber(1)
  set group(MultisigGroup value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasGroup() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroup() => $_clearField(1);
  @$pb.TagNumber(1)
  MultisigGroup ensureGroup() => $_ensure(0);

  /// Multisig script type: "wsh" (native P2WSH, default), "sh-wsh" (nested
  /// P2SH-P2WSH), or "sh" (legacy P2SH). Empty means native P2WSH.
  @$pb.TagNumber(2)
  $core.String get scriptType => $_getSZ(1);
  @$pb.TagNumber(2)
  set scriptType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasScriptType() => $_has(1);
  @$pb.TagNumber(2)
  void clearScriptType() => $_clearField(2);
}

class BuildDescriptorsResponse extends $pb.GeneratedMessage {
  factory BuildDescriptorsResponse({
    $core.String? receiveDescriptor,
    $core.String? changeDescriptor,
  }) {
    final result = BuildDescriptorsResponse._();
    if (receiveDescriptor != null) result.receiveDescriptor = receiveDescriptor;
    if (changeDescriptor != null) result.changeDescriptor = changeDescriptor;
    return result;
  }

  BuildDescriptorsResponse._();

  factory BuildDescriptorsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BuildDescriptorsResponse()..mergeFromBuffer(data, registry);
  factory BuildDescriptorsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BuildDescriptorsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BuildDescriptorsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'),
      createEmptyInstance: BuildDescriptorsResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'receiveDescriptor')
    ..aOS(2, _omitFieldNames ? '' : 'changeDescriptor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BuildDescriptorsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BuildDescriptorsResponse copyWith(void Function(BuildDescriptorsResponse) updates) =>
      super.copyWith((message) => updates(message as BuildDescriptorsResponse)) as BuildDescriptorsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BuildDescriptorsResponse() / BuildDescriptorsResponse.new instead')
  static BuildDescriptorsResponse create() => BuildDescriptorsResponse._();
  static $pb.GeneratedMessage $_createMessage() => BuildDescriptorsResponse._();
  @$core.override
  BuildDescriptorsResponse createEmptyInstance() => BuildDescriptorsResponse._();
  @$core.pragma('dart2js:noInline')
  static BuildDescriptorsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BuildDescriptorsResponse>(BuildDescriptorsResponse.$_createMessage);
  static BuildDescriptorsResponse? _defaultInstance;

  /// Receive descriptor (/0/*) with checksum.
  @$pb.TagNumber(1)
  $core.String get receiveDescriptor => $_getSZ(0);
  @$pb.TagNumber(1)
  set receiveDescriptor($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasReceiveDescriptor() => $_has(0);
  @$pb.TagNumber(1)
  void clearReceiveDescriptor() => $_clearField(1);

  /// Change descriptor (/1/*) with checksum.
  @$pb.TagNumber(2)
  $core.String get changeDescriptor => $_getSZ(1);
  @$pb.TagNumber(2)
  set changeDescriptor($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChangeDescriptor() => $_has(1);
  @$pb.TagNumber(2)
  void clearChangeDescriptor() => $_clearField(2);
}

class ValidatePsbtRequest extends $pb.GeneratedMessage {
  factory ValidatePsbtRequest({
    $core.String? psbtBase64,
    $core.int? requiredSigs,
    MultisigGroup? group,
  }) {
    final result = ValidatePsbtRequest._();
    if (psbtBase64 != null) result.psbtBase64 = psbtBase64;
    if (requiredSigs != null) result.requiredSigs = requiredSigs;
    if (group != null) result.group = group;
    return result;
  }

  ValidatePsbtRequest._();

  factory ValidatePsbtRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidatePsbtRequest()..mergeFromBuffer(data, registry);
  factory ValidatePsbtRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidatePsbtRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ValidatePsbtRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'),
      createEmptyInstance: ValidatePsbtRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'psbtBase64')
    ..aI(2, _omitFieldNames ? '' : 'requiredSigs', fieldType: $pb.PbFieldType.OU3)
    ..aOM<MultisigGroup>(3, _omitFieldNames ? '' : 'group', subBuilder: MultisigGroup.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidatePsbtRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidatePsbtRequest copyWith(void Function(ValidatePsbtRequest) updates) =>
      super.copyWith((message) => updates(message as ValidatePsbtRequest)) as ValidatePsbtRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ValidatePsbtRequest() / ValidatePsbtRequest.new instead')
  static ValidatePsbtRequest create() => ValidatePsbtRequest._();
  static $pb.GeneratedMessage $_createMessage() => ValidatePsbtRequest._();
  @$core.override
  ValidatePsbtRequest createEmptyInstance() => ValidatePsbtRequest._();
  @$core.pragma('dart2js:noInline')
  static ValidatePsbtRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ValidatePsbtRequest>(ValidatePsbtRequest.$_createMessage);
  static ValidatePsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbtBase64 => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbtBase64($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPsbtBase64() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbtBase64() => $_clearField(1);

  /// Signatures required per input (m).
  @$pb.TagNumber(2)
  $core.int get requiredSigs => $_getIZ(1);
  @$pb.TagNumber(2)
  set requiredSigs($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRequiredSigs() => $_has(1);
  @$pb.TagNumber(2)
  void clearRequiredSigs() => $_clearField(2);

  /// Optional. When set, every input must match this group's descriptor.
  @$pb.TagNumber(3)
  MultisigGroup get group => $_getN(2);
  @$pb.TagNumber(3)
  set group(MultisigGroup value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasGroup() => $_has(2);
  @$pb.TagNumber(3)
  void clearGroup() => $_clearField(3);
  @$pb.TagNumber(3)
  MultisigGroup ensureGroup() => $_ensure(2);
}

class ValidatePsbtResponse extends $pb.GeneratedMessage {
  factory ValidatePsbtResponse({
    $core.bool? hasSignatures,
    $core.int? signatureCount,
    $core.bool? isComplete,
    $core.bool? finalizable,
    $core.String? error,
  }) {
    final result = ValidatePsbtResponse._();
    if (hasSignatures != null) result.hasSignatures = hasSignatures;
    if (signatureCount != null) result.signatureCount = signatureCount;
    if (isComplete != null) result.isComplete = isComplete;
    if (finalizable != null) result.finalizable = finalizable;
    if (error != null) result.error = error;
    return result;
  }

  ValidatePsbtResponse._();

  factory ValidatePsbtResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidatePsbtResponse()..mergeFromBuffer(data, registry);
  factory ValidatePsbtResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidatePsbtResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ValidatePsbtResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'),
      createEmptyInstance: ValidatePsbtResponse.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'hasSignatures')
    ..aI(2, _omitFieldNames ? '' : 'signatureCount', fieldType: $pb.PbFieldType.OU3)
    ..aOB(3, _omitFieldNames ? '' : 'isComplete')
    ..aOB(4, _omitFieldNames ? '' : 'finalizable')
    ..aOS(5, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidatePsbtResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidatePsbtResponse copyWith(void Function(ValidatePsbtResponse) updates) =>
      super.copyWith((message) => updates(message as ValidatePsbtResponse)) as ValidatePsbtResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ValidatePsbtResponse() / ValidatePsbtResponse.new instead')
  static ValidatePsbtResponse create() => ValidatePsbtResponse._();
  static $pb.GeneratedMessage $_createMessage() => ValidatePsbtResponse._();
  @$core.override
  ValidatePsbtResponse createEmptyInstance() => ValidatePsbtResponse._();
  @$core.pragma('dart2js:noInline')
  static ValidatePsbtResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ValidatePsbtResponse>(ValidatePsbtResponse.$_createMessage);
  static ValidatePsbtResponse? _defaultInstance;

  /// At least one partial signature is present on some input.
  @$pb.TagNumber(1)
  $core.bool get hasSignatures => $_getBF(0);
  @$pb.TagNumber(1)
  set hasSignatures($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHasSignatures() => $_has(0);
  @$pb.TagNumber(1)
  void clearHasSignatures() => $_clearField(1);

  /// Maximum partial-signature count across inputs.
  @$pb.TagNumber(2)
  $core.int get signatureCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set signatureCount($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSignatureCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearSignatureCount() => $_clearField(2);

  /// Every input has reached the required threshold.
  @$pb.TagNumber(3)
  $core.bool get isComplete => $_getBF(2);
  @$pb.TagNumber(3)
  set isComplete($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasIsComplete() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsComplete() => $_clearField(3);

  /// The PSBT can be finalized into a broadcastable transaction.
  @$pb.TagNumber(4)
  $core.bool get finalizable => $_getBF(3);
  @$pb.TagNumber(4)
  set finalizable($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFinalizable() => $_has(3);
  @$pb.TagNumber(4)
  void clearFinalizable() => $_clearField(4);

  /// Non-empty on validation failure (e.g. foreign input, parse error).
  @$pb.TagNumber(5)
  $core.String get error => $_getSZ(4);
  @$pb.TagNumber(5)
  set error($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasError() => $_has(4);
  @$pb.TagNumber(5)
  void clearError() => $_clearField(5);
}

/// MultisigLoungeService builds watch-only multisig descriptors and validates
/// PSBTs for the BitWindow multisig lounge. Pure stateless logic — no wallet,
/// no signing, no broadcast.
class MultisigLoungeServiceApi {
  final $pb.RpcClient _client;

  MultisigLoungeServiceApi(this._client);

  /// BuildDescriptors builds the receive (/0/*) and change (/1/*) watch-only
  /// wsh(sortedmulti) descriptors for a multisig group, with checksums.
  $async.Future<BuildDescriptorsResponse> buildDescriptors($pb.ClientContext? ctx, BuildDescriptorsRequest request) =>
      _client.invoke<BuildDescriptorsResponse>(
          ctx, 'MultisigLoungeService', 'BuildDescriptors', request, BuildDescriptorsResponse());

  /// ValidatePsbt parses a base64 PSBT and reports signature progress. When a
  /// group is supplied, inputs whose script does not belong to the group's
  /// descriptor are rejected.
  $async.Future<ValidatePsbtResponse> validatePsbt($pb.ClientContext? ctx, ValidatePsbtRequest request) => _client
      .invoke<ValidatePsbtResponse>(ctx, 'MultisigLoungeService', 'ValidatePsbt', request, ValidatePsbtResponse());

  /// PublishGroup encodes a multisig group as an OP_RETURN payload (the
  /// BitWindow wire format) and broadcasts it, funding a fresh own address.
  /// Returns the broadcast txid.
  $async.Future<PublishGroupResponse> publishGroup($pb.ClientContext? ctx, PublishGroupRequest request) => _client
      .invoke<PublishGroupResponse>(ctx, 'MultisigLoungeService', 'PublishGroup', request, PublishGroupResponse());

  /// ImportGroupFromTxid fetches the OP_RETURN at the given txid, decodes the
  /// multisig group, and reports which of the group's keys belong to the wallet.
  $async.Future<ImportGroupFromTxidResponse> importGroupFromTxid(
          $pb.ClientContext? ctx, ImportGroupFromTxidRequest request) =>
      _client.invoke<ImportGroupFromTxidResponse>(
          ctx, 'MultisigLoungeService', 'ImportGroupFromTxid', request, ImportGroupFromTxidResponse());

  /// SignTransaction adds the wallet's signature(s) to a multisig PSBT,
  /// deriving the wallet's keys server-side from its seed. The PSBT must belong
  /// to the group (foreign inputs are rejected).
  $async.Future<SignTransactionResponse> signTransaction($pb.ClientContext? ctx, SignTransactionRequest request) =>
      _client.invoke<SignTransactionResponse>(
          ctx, 'MultisigLoungeService', 'SignTransaction', request, SignTransactionResponse());

  /// CombineAndBroadcast merges partial PSBTs, finalizes, and broadcasts — but
  /// only if the combined PSBT reaches the threshold. A non-finalizable PSBT is
  /// never broadcast.
  $async.Future<CombineAndBroadcastResponse> combineAndBroadcast(
          $pb.ClientContext? ctx, CombineAndBroadcastRequest request) =>
      _client.invoke<CombineAndBroadcastResponse>(
          ctx, 'MultisigLoungeService', 'CombineAndBroadcast', request, CombineAndBroadcastResponse());

  /// SyncGroup ensures the group's watch-only wallet exists (creating it from the
  /// Phase-1 descriptors if missing) and returns its balance and UTXOs.
  $async.Future<SyncGroupResponse> syncGroup($pb.ClientContext? ctx, SyncGroupRequest request) =>
      _client.invoke<SyncGroupResponse>(ctx, 'MultisigLoungeService', 'SyncGroup', request, SyncGroupResponse());

  /// RestoreHistory scans the watch-only wallet's transactions and reconstructs
  /// the group's spend/receive records with per-tx signature counts and status.
  $async.Future<RestoreHistoryResponse> restoreHistory($pb.ClientContext? ctx, RestoreHistoryRequest request) =>
      _client.invoke<RestoreHistoryResponse>(
          ctx, 'MultisigLoungeService', 'RestoreHistory', request, RestoreHistoryResponse());

  /// CreateSpendPsbt builds an unsigned funded PSBT spending from the group's
  /// watch-only wallet to the given destinations (ensuring the wallet exists).
  $async.Future<CreateSpendPsbtResponse> createSpendPsbt($pb.ClientContext? ctx, CreateSpendPsbtRequest request) =>
      _client.invoke<CreateSpendPsbtResponse>(
          ctx, 'MultisigLoungeService', 'CreateSpendPsbt', request, CreateSpendPsbtResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
