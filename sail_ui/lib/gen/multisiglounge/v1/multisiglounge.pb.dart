//
//  Generated code. Do not modify.
//  source: multisiglounge/v1/multisiglounge.proto
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

/// SpendDestination is one output of a spend: an address and an amount in sats.
class SpendDestination extends $pb.GeneratedMessage {
  factory SpendDestination({
    $core.String? address,
    $fixnum.Int64? sats,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (sats != null) {
      $result.sats = sats;
    }
    return $result;
  }
  SpendDestination._() : super();
  factory SpendDestination.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SpendDestination.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SpendDestination', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aInt64(2, _omitFieldNames ? '' : 'sats')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SpendDestination clone() => SpendDestination()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SpendDestination copyWith(void Function(SpendDestination) updates) => super.copyWith((message) => updates(message as SpendDestination)) as SpendDestination;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SpendDestination create() => SpendDestination._();
  SpendDestination createEmptyInstance() => create();
  static $pb.PbList<SpendDestination> createRepeated() => $pb.PbList<SpendDestination>();
  @$core.pragma('dart2js:noInline')
  static SpendDestination getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SpendDestination>(create);
  static SpendDestination? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get sats => $_getI64(1);
  @$pb.TagNumber(2)
  set sats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearSats() => clearField(2);
}

class CreateSpendPsbtRequest extends $pb.GeneratedMessage {
  factory CreateSpendPsbtRequest({
    GroupData? group,
    $core.String? walletId,
    $core.Iterable<SpendDestination>? destinations,
    $core.double? feeRateSatVb,
  }) {
    final $result = create();
    if (group != null) {
      $result.group = group;
    }
    if (walletId != null) {
      $result.walletId = walletId;
    }
    if (destinations != null) {
      $result.destinations.addAll(destinations);
    }
    if (feeRateSatVb != null) {
      $result.feeRateSatVb = feeRateSatVb;
    }
    return $result;
  }
  CreateSpendPsbtRequest._() : super();
  factory CreateSpendPsbtRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateSpendPsbtRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateSpendPsbtRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..aOM<GroupData>(1, _omitFieldNames ? '' : 'group', subBuilder: GroupData.create)
    ..aOS(2, _omitFieldNames ? '' : 'walletId')
    ..pc<SpendDestination>(3, _omitFieldNames ? '' : 'destinations', $pb.PbFieldType.PM, subBuilder: SpendDestination.create)
    ..a<$core.double>(4, _omitFieldNames ? '' : 'feeRateSatVb', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateSpendPsbtRequest clone() => CreateSpendPsbtRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateSpendPsbtRequest copyWith(void Function(CreateSpendPsbtRequest) updates) => super.copyWith((message) => updates(message as CreateSpendPsbtRequest)) as CreateSpendPsbtRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateSpendPsbtRequest create() => CreateSpendPsbtRequest._();
  CreateSpendPsbtRequest createEmptyInstance() => create();
  static $pb.PbList<CreateSpendPsbtRequest> createRepeated() => $pb.PbList<CreateSpendPsbtRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateSpendPsbtRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateSpendPsbtRequest>(create);
  static CreateSpendPsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  GroupData get group => $_getN(0);
  @$pb.TagNumber(1)
  set group(GroupData v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroup() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroup() => clearField(1);
  @$pb.TagNumber(1)
  GroupData ensureGroup() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get walletId => $_getSZ(1);
  @$pb.TagNumber(2)
  set walletId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWalletId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWalletId() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<SpendDestination> get destinations => $_getList(2);

  /// Optional fee rate in sat/vB. 0 lets bitcoind pick (fallback/estimate fee),
  /// matching the current Dart path which passes no explicit fee rate.
  @$pb.TagNumber(4)
  $core.double get feeRateSatVb => $_getN(3);
  @$pb.TagNumber(4)
  set feeRateSatVb($core.double v) { $_setDouble(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFeeRateSatVb() => $_has(3);
  @$pb.TagNumber(4)
  void clearFeeRateSatVb() => clearField(4);
}

class CreateSpendPsbtResponse extends $pb.GeneratedMessage {
  factory CreateSpendPsbtResponse({
    $core.String? psbtBase64,
    $fixnum.Int64? feeSats,
  }) {
    final $result = create();
    if (psbtBase64 != null) {
      $result.psbtBase64 = psbtBase64;
    }
    if (feeSats != null) {
      $result.feeSats = feeSats;
    }
    return $result;
  }
  CreateSpendPsbtResponse._() : super();
  factory CreateSpendPsbtResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateSpendPsbtResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateSpendPsbtResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbtBase64')
    ..aInt64(2, _omitFieldNames ? '' : 'feeSats')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateSpendPsbtResponse clone() => CreateSpendPsbtResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateSpendPsbtResponse copyWith(void Function(CreateSpendPsbtResponse) updates) => super.copyWith((message) => updates(message as CreateSpendPsbtResponse)) as CreateSpendPsbtResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateSpendPsbtResponse create() => CreateSpendPsbtResponse._();
  CreateSpendPsbtResponse createEmptyInstance() => create();
  static $pb.PbList<CreateSpendPsbtResponse> createRepeated() => $pb.PbList<CreateSpendPsbtResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateSpendPsbtResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateSpendPsbtResponse>(create);
  static CreateSpendPsbtResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbtBase64 => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbtBase64($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbtBase64() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbtBase64() => clearField(1);

  /// Fee the funded PSBT pays, in sats.
  @$pb.TagNumber(2)
  $fixnum.Int64 get feeSats => $_getI64(1);
  @$pb.TagNumber(2)
  set feeSats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFeeSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearFeeSats() => clearField(2);
}

class SyncGroupRequest extends $pb.GeneratedMessage {
  factory SyncGroupRequest({
    GroupData? group,
    $core.String? walletId,
  }) {
    final $result = create();
    if (group != null) {
      $result.group = group;
    }
    if (walletId != null) {
      $result.walletId = walletId;
    }
    return $result;
  }
  SyncGroupRequest._() : super();
  factory SyncGroupRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SyncGroupRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncGroupRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..aOM<GroupData>(1, _omitFieldNames ? '' : 'group', subBuilder: GroupData.create)
    ..aOS(2, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SyncGroupRequest clone() => SyncGroupRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SyncGroupRequest copyWith(void Function(SyncGroupRequest) updates) => super.copyWith((message) => updates(message as SyncGroupRequest)) as SyncGroupRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncGroupRequest create() => SyncGroupRequest._();
  SyncGroupRequest createEmptyInstance() => create();
  static $pb.PbList<SyncGroupRequest> createRepeated() => $pb.PbList<SyncGroupRequest>();
  @$core.pragma('dart2js:noInline')
  static SyncGroupRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncGroupRequest>(create);
  static SyncGroupRequest? _defaultInstance;

  @$pb.TagNumber(1)
  GroupData get group => $_getN(0);
  @$pb.TagNumber(1)
  set group(GroupData v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroup() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroup() => clearField(1);
  @$pb.TagNumber(1)
  GroupData ensureGroup() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get walletId => $_getSZ(1);
  @$pb.TagNumber(2)
  set walletId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWalletId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWalletId() => clearField(2);
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
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (vout != null) {
      $result.vout = vout;
    }
    if (address != null) {
      $result.address = address;
    }
    if (amountSats != null) {
      $result.amountSats = amountSats;
    }
    if (confirmations != null) {
      $result.confirmations = confirmations;
    }
    if (scriptPubkey != null) {
      $result.scriptPubkey = scriptPubkey;
    }
    if (spendable != null) {
      $result.spendable = spendable;
    }
    if (solvable != null) {
      $result.solvable = solvable;
    }
    if (safe != null) {
      $result.safe = safe;
    }
    return $result;
  }
  MultisigUtxo._() : super();
  factory MultisigUtxo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MultisigUtxo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MultisigUtxo', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'vout', $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'address')
    ..aInt64(4, _omitFieldNames ? '' : 'amountSats')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'confirmations', $pb.PbFieldType.OU3)
    ..aOS(6, _omitFieldNames ? '' : 'scriptPubkey')
    ..aOB(7, _omitFieldNames ? '' : 'spendable')
    ..aOB(8, _omitFieldNames ? '' : 'solvable')
    ..aOB(9, _omitFieldNames ? '' : 'safe')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MultisigUtxo clone() => MultisigUtxo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MultisigUtxo copyWith(void Function(MultisigUtxo) updates) => super.copyWith((message) => updates(message as MultisigUtxo)) as MultisigUtxo;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MultisigUtxo create() => MultisigUtxo._();
  MultisigUtxo createEmptyInstance() => create();
  static $pb.PbList<MultisigUtxo> createRepeated() => $pb.PbList<MultisigUtxo>();
  @$core.pragma('dart2js:noInline')
  static MultisigUtxo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MultisigUtxo>(create);
  static MultisigUtxo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get vout => $_getIZ(1);
  @$pb.TagNumber(2)
  set vout($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearVout() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get address => $_getSZ(2);
  @$pb.TagNumber(3)
  set address($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddress() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get amountSats => $_getI64(3);
  @$pb.TagNumber(4)
  set amountSats($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAmountSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearAmountSats() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get confirmations => $_getIZ(4);
  @$pb.TagNumber(5)
  set confirmations($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasConfirmations() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfirmations() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get scriptPubkey => $_getSZ(5);
  @$pb.TagNumber(6)
  set scriptPubkey($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasScriptPubkey() => $_has(5);
  @$pb.TagNumber(6)
  void clearScriptPubkey() => clearField(6);

  @$pb.TagNumber(7)
  $core.bool get spendable => $_getBF(6);
  @$pb.TagNumber(7)
  set spendable($core.bool v) { $_setBool(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasSpendable() => $_has(6);
  @$pb.TagNumber(7)
  void clearSpendable() => clearField(7);

  @$pb.TagNumber(8)
  $core.bool get solvable => $_getBF(7);
  @$pb.TagNumber(8)
  set solvable($core.bool v) { $_setBool(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasSolvable() => $_has(7);
  @$pb.TagNumber(8)
  void clearSolvable() => clearField(8);

  @$pb.TagNumber(9)
  $core.bool get safe => $_getBF(8);
  @$pb.TagNumber(9)
  set safe($core.bool v) { $_setBool(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasSafe() => $_has(8);
  @$pb.TagNumber(9)
  void clearSafe() => clearField(9);
}

class SyncGroupResponse extends $pb.GeneratedMessage {
  factory SyncGroupResponse({
    $fixnum.Int64? confirmedSats,
    $fixnum.Int64? pendingSats,
    $core.int? utxoCount,
    $core.Iterable<MultisigUtxo>? utxos,
  }) {
    final $result = create();
    if (confirmedSats != null) {
      $result.confirmedSats = confirmedSats;
    }
    if (pendingSats != null) {
      $result.pendingSats = pendingSats;
    }
    if (utxoCount != null) {
      $result.utxoCount = utxoCount;
    }
    if (utxos != null) {
      $result.utxos.addAll(utxos);
    }
    return $result;
  }
  SyncGroupResponse._() : super();
  factory SyncGroupResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SyncGroupResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SyncGroupResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'confirmedSats')
    ..aInt64(2, _omitFieldNames ? '' : 'pendingSats')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'utxoCount', $pb.PbFieldType.OU3)
    ..pc<MultisigUtxo>(4, _omitFieldNames ? '' : 'utxos', $pb.PbFieldType.PM, subBuilder: MultisigUtxo.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SyncGroupResponse clone() => SyncGroupResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SyncGroupResponse copyWith(void Function(SyncGroupResponse) updates) => super.copyWith((message) => updates(message as SyncGroupResponse)) as SyncGroupResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SyncGroupResponse create() => SyncGroupResponse._();
  SyncGroupResponse createEmptyInstance() => create();
  static $pb.PbList<SyncGroupResponse> createRepeated() => $pb.PbList<SyncGroupResponse>();
  @$core.pragma('dart2js:noInline')
  static SyncGroupResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SyncGroupResponse>(create);
  static SyncGroupResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get confirmedSats => $_getI64(0);
  @$pb.TagNumber(1)
  set confirmedSats($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConfirmedSats() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfirmedSats() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get pendingSats => $_getI64(1);
  @$pb.TagNumber(2)
  set pendingSats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPendingSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearPendingSats() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get utxoCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set utxoCount($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasUtxoCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearUtxoCount() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<MultisigUtxo> get utxos => $_getList(3);
}

class RestoreHistoryRequest extends $pb.GeneratedMessage {
  factory RestoreHistoryRequest({
    GroupData? group,
    $core.String? walletId,
  }) {
    final $result = create();
    if (group != null) {
      $result.group = group;
    }
    if (walletId != null) {
      $result.walletId = walletId;
    }
    return $result;
  }
  RestoreHistoryRequest._() : super();
  factory RestoreHistoryRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RestoreHistoryRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RestoreHistoryRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..aOM<GroupData>(1, _omitFieldNames ? '' : 'group', subBuilder: GroupData.create)
    ..aOS(2, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RestoreHistoryRequest clone() => RestoreHistoryRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RestoreHistoryRequest copyWith(void Function(RestoreHistoryRequest) updates) => super.copyWith((message) => updates(message as RestoreHistoryRequest)) as RestoreHistoryRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RestoreHistoryRequest create() => RestoreHistoryRequest._();
  RestoreHistoryRequest createEmptyInstance() => create();
  static $pb.PbList<RestoreHistoryRequest> createRepeated() => $pb.PbList<RestoreHistoryRequest>();
  @$core.pragma('dart2js:noInline')
  static RestoreHistoryRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RestoreHistoryRequest>(create);
  static RestoreHistoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  GroupData get group => $_getN(0);
  @$pb.TagNumber(1)
  set group(GroupData v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroup() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroup() => clearField(1);
  @$pb.TagNumber(1)
  GroupData ensureGroup() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get walletId => $_getSZ(1);
  @$pb.TagNumber(2)
  set walletId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWalletId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWalletId() => clearField(2);
}

/// MultisigHistoryInput is one input of a reconstructed historical transaction.
class MultisigHistoryInput extends $pb.GeneratedMessage {
  factory MultisigHistoryInput({
    $core.String? txid,
    $core.int? vout,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (vout != null) {
      $result.vout = vout;
    }
    return $result;
  }
  MultisigHistoryInput._() : super();
  factory MultisigHistoryInput.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MultisigHistoryInput.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MultisigHistoryInput', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'vout', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MultisigHistoryInput clone() => MultisigHistoryInput()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MultisigHistoryInput copyWith(void Function(MultisigHistoryInput) updates) => super.copyWith((message) => updates(message as MultisigHistoryInput)) as MultisigHistoryInput;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MultisigHistoryInput create() => MultisigHistoryInput._();
  MultisigHistoryInput createEmptyInstance() => create();
  static $pb.PbList<MultisigHistoryInput> createRepeated() => $pb.PbList<MultisigHistoryInput>();
  @$core.pragma('dart2js:noInline')
  static MultisigHistoryInput getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MultisigHistoryInput>(create);
  static MultisigHistoryInput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get vout => $_getIZ(1);
  @$pb.TagNumber(2)
  set vout($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearVout() => clearField(2);
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
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (amountSats != null) {
      $result.amountSats = amountSats;
    }
    if (isDeposit != null) {
      $result.isDeposit = isDeposit;
    }
    if (destination != null) {
      $result.destination = destination;
    }
    if (confirmations != null) {
      $result.confirmations = confirmations;
    }
    if (signatureCount != null) {
      $result.signatureCount = signatureCount;
    }
    if (status != null) {
      $result.status = status;
    }
    if (time != null) {
      $result.time = time;
    }
    if (finalHex != null) {
      $result.finalHex = finalHex;
    }
    if (inputs != null) {
      $result.inputs.addAll(inputs);
    }
    return $result;
  }
  MultisigHistoryTx._() : super();
  factory MultisigHistoryTx.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MultisigHistoryTx.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MultisigHistoryTx', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aInt64(2, _omitFieldNames ? '' : 'amountSats')
    ..aOB(3, _omitFieldNames ? '' : 'isDeposit')
    ..aOS(4, _omitFieldNames ? '' : 'destination')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'confirmations', $pb.PbFieldType.OU3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'signatureCount', $pb.PbFieldType.OU3)
    ..aOS(7, _omitFieldNames ? '' : 'status')
    ..aInt64(8, _omitFieldNames ? '' : 'time')
    ..aOS(9, _omitFieldNames ? '' : 'finalHex')
    ..pc<MultisigHistoryInput>(10, _omitFieldNames ? '' : 'inputs', $pb.PbFieldType.PM, subBuilder: MultisigHistoryInput.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MultisigHistoryTx clone() => MultisigHistoryTx()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MultisigHistoryTx copyWith(void Function(MultisigHistoryTx) updates) => super.copyWith((message) => updates(message as MultisigHistoryTx)) as MultisigHistoryTx;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MultisigHistoryTx create() => MultisigHistoryTx._();
  MultisigHistoryTx createEmptyInstance() => create();
  static $pb.PbList<MultisigHistoryTx> createRepeated() => $pb.PbList<MultisigHistoryTx>();
  @$core.pragma('dart2js:noInline')
  static MultisigHistoryTx getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MultisigHistoryTx>(create);
  static MultisigHistoryTx? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  /// Absolute amount in sats (sign dropped; see is_deposit for direction).
  @$pb.TagNumber(2)
  $fixnum.Int64 get amountSats => $_getI64(1);
  @$pb.TagNumber(2)
  set amountSats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAmountSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmountSats() => clearField(2);

  /// True when the wallet received (positive listtransactions amount).
  @$pb.TagNumber(3)
  $core.bool get isDeposit => $_getBF(2);
  @$pb.TagNumber(3)
  set isDeposit($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasIsDeposit() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsDeposit() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get destination => $_getSZ(3);
  @$pb.TagNumber(4)
  set destination($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDestination() => $_has(3);
  @$pb.TagNumber(4)
  void clearDestination() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get confirmations => $_getIZ(4);
  @$pb.TagNumber(5)
  set confirmations($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasConfirmations() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfirmations() => clearField(5);

  /// Signatures counted from the transaction's witness/scriptSig.
  @$pb.TagNumber(6)
  $core.int get signatureCount => $_getIZ(5);
  @$pb.TagNumber(6)
  set signatureCount($core.int v) { $_setUnsignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasSignatureCount() => $_has(5);
  @$pb.TagNumber(6)
  void clearSignatureCount() => clearField(6);

  /// "broadcasted" (0-conf or <6), or "confirmed" (>=6).
  @$pb.TagNumber(7)
  $core.String get status => $_getSZ(6);
  @$pb.TagNumber(7)
  set status($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasStatus() => $_has(6);
  @$pb.TagNumber(7)
  void clearStatus() => clearField(7);

  /// Block/receive time, seconds since epoch.
  @$pb.TagNumber(8)
  $fixnum.Int64 get time => $_getI64(7);
  @$pb.TagNumber(8)
  set time($fixnum.Int64 v) { $_setInt64(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasTime() => $_has(7);
  @$pb.TagNumber(8)
  void clearTime() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get finalHex => $_getSZ(8);
  @$pb.TagNumber(9)
  set finalHex($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasFinalHex() => $_has(8);
  @$pb.TagNumber(9)
  void clearFinalHex() => clearField(9);

  @$pb.TagNumber(10)
  $core.List<MultisigHistoryInput> get inputs => $_getList(9);
}

class RestoreHistoryResponse extends $pb.GeneratedMessage {
  factory RestoreHistoryResponse({
    $core.Iterable<MultisigHistoryTx>? transactions,
  }) {
    final $result = create();
    if (transactions != null) {
      $result.transactions.addAll(transactions);
    }
    return $result;
  }
  RestoreHistoryResponse._() : super();
  factory RestoreHistoryResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RestoreHistoryResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RestoreHistoryResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..pc<MultisigHistoryTx>(1, _omitFieldNames ? '' : 'transactions', $pb.PbFieldType.PM, subBuilder: MultisigHistoryTx.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RestoreHistoryResponse clone() => RestoreHistoryResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RestoreHistoryResponse copyWith(void Function(RestoreHistoryResponse) updates) => super.copyWith((message) => updates(message as RestoreHistoryResponse)) as RestoreHistoryResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RestoreHistoryResponse create() => RestoreHistoryResponse._();
  RestoreHistoryResponse createEmptyInstance() => create();
  static $pb.PbList<RestoreHistoryResponse> createRepeated() => $pb.PbList<RestoreHistoryResponse>();
  @$core.pragma('dart2js:noInline')
  static RestoreHistoryResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RestoreHistoryResponse>(create);
  static RestoreHistoryResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<MultisigHistoryTx> get transactions => $_getList(0);
}

class SignTransactionRequest extends $pb.GeneratedMessage {
  factory SignTransactionRequest({
    $core.String? psbtBase64,
    GroupData? group,
    $core.String? walletId,
  }) {
    final $result = create();
    if (psbtBase64 != null) {
      $result.psbtBase64 = psbtBase64;
    }
    if (group != null) {
      $result.group = group;
    }
    if (walletId != null) {
      $result.walletId = walletId;
    }
    return $result;
  }
  SignTransactionRequest._() : super();
  factory SignTransactionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SignTransactionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignTransactionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbtBase64')
    ..aOM<GroupData>(2, _omitFieldNames ? '' : 'group', subBuilder: GroupData.create)
    ..aOS(3, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SignTransactionRequest clone() => SignTransactionRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SignTransactionRequest copyWith(void Function(SignTransactionRequest) updates) => super.copyWith((message) => updates(message as SignTransactionRequest)) as SignTransactionRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SignTransactionRequest create() => SignTransactionRequest._();
  SignTransactionRequest createEmptyInstance() => create();
  static $pb.PbList<SignTransactionRequest> createRepeated() => $pb.PbList<SignTransactionRequest>();
  @$core.pragma('dart2js:noInline')
  static SignTransactionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignTransactionRequest>(create);
  static SignTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbtBase64 => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbtBase64($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbtBase64() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbtBase64() => clearField(1);

  /// Full group (with per-key derivation paths) so the wallet's xprv can be
  /// derived and substituted into the signing descriptor.
  @$pb.TagNumber(2)
  GroupData get group => $_getN(1);
  @$pb.TagNumber(2)
  set group(GroupData v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasGroup() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroup() => clearField(2);
  @$pb.TagNumber(2)
  GroupData ensureGroup() => $_ensure(1);

  /// Wallet whose seed-derived keys sign the PSBT.
  @$pb.TagNumber(3)
  $core.String get walletId => $_getSZ(2);
  @$pb.TagNumber(3)
  set walletId($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasWalletId() => $_has(2);
  @$pb.TagNumber(3)
  void clearWalletId() => clearField(3);
}

class SignTransactionResponse extends $pb.GeneratedMessage {
  factory SignTransactionResponse({
    $core.String? psbtBase64,
    $core.int? addedSignatures,
    $core.bool? isComplete,
  }) {
    final $result = create();
    if (psbtBase64 != null) {
      $result.psbtBase64 = psbtBase64;
    }
    if (addedSignatures != null) {
      $result.addedSignatures = addedSignatures;
    }
    if (isComplete != null) {
      $result.isComplete = isComplete;
    }
    return $result;
  }
  SignTransactionResponse._() : super();
  factory SignTransactionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SignTransactionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignTransactionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbtBase64')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'addedSignatures', $pb.PbFieldType.OU3)
    ..aOB(3, _omitFieldNames ? '' : 'isComplete')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SignTransactionResponse clone() => SignTransactionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SignTransactionResponse copyWith(void Function(SignTransactionResponse) updates) => super.copyWith((message) => updates(message as SignTransactionResponse)) as SignTransactionResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SignTransactionResponse create() => SignTransactionResponse._();
  SignTransactionResponse createEmptyInstance() => create();
  static $pb.PbList<SignTransactionResponse> createRepeated() => $pb.PbList<SignTransactionResponse>();
  @$core.pragma('dart2js:noInline')
  static SignTransactionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignTransactionResponse>(create);
  static SignTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbtBase64 => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbtBase64($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbtBase64() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbtBase64() => clearField(1);

  /// Number of partial signatures this call added.
  @$pb.TagNumber(2)
  $core.int get addedSignatures => $_getIZ(1);
  @$pb.TagNumber(2)
  set addedSignatures($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAddedSignatures() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddedSignatures() => clearField(2);

  /// True once the PSBT carries the threshold of signatures.
  @$pb.TagNumber(3)
  $core.bool get isComplete => $_getBF(2);
  @$pb.TagNumber(3)
  set isComplete($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasIsComplete() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsComplete() => clearField(3);
}

class CombineAndBroadcastRequest extends $pb.GeneratedMessage {
  factory CombineAndBroadcastRequest({
    $core.Iterable<$core.String>? psbts,
    GroupData? group,
  }) {
    final $result = create();
    if (psbts != null) {
      $result.psbts.addAll(psbts);
    }
    if (group != null) {
      $result.group = group;
    }
    return $result;
  }
  CombineAndBroadcastRequest._() : super();
  factory CombineAndBroadcastRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CombineAndBroadcastRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CombineAndBroadcastRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'psbts')
    ..aOM<GroupData>(2, _omitFieldNames ? '' : 'group', subBuilder: GroupData.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CombineAndBroadcastRequest clone() => CombineAndBroadcastRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CombineAndBroadcastRequest copyWith(void Function(CombineAndBroadcastRequest) updates) => super.copyWith((message) => updates(message as CombineAndBroadcastRequest)) as CombineAndBroadcastRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CombineAndBroadcastRequest create() => CombineAndBroadcastRequest._();
  CombineAndBroadcastRequest createEmptyInstance() => create();
  static $pb.PbList<CombineAndBroadcastRequest> createRepeated() => $pb.PbList<CombineAndBroadcastRequest>();
  @$core.pragma('dart2js:noInline')
  static CombineAndBroadcastRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CombineAndBroadcastRequest>(create);
  static CombineAndBroadcastRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get psbts => $_getList(0);

  /// Full group, used to reject PSBTs that do not belong to it before combining.
  @$pb.TagNumber(2)
  GroupData get group => $_getN(1);
  @$pb.TagNumber(2)
  set group(GroupData v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasGroup() => $_has(1);
  @$pb.TagNumber(2)
  void clearGroup() => clearField(2);
  @$pb.TagNumber(2)
  GroupData ensureGroup() => $_ensure(1);
}

class CombineAndBroadcastResponse extends $pb.GeneratedMessage {
  factory CombineAndBroadcastResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  CombineAndBroadcastResponse._() : super();
  factory CombineAndBroadcastResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CombineAndBroadcastResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CombineAndBroadcastResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CombineAndBroadcastResponse clone() => CombineAndBroadcastResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CombineAndBroadcastResponse copyWith(void Function(CombineAndBroadcastResponse) updates) => super.copyWith((message) => updates(message as CombineAndBroadcastResponse)) as CombineAndBroadcastResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CombineAndBroadcastResponse create() => CombineAndBroadcastResponse._();
  CombineAndBroadcastResponse createEmptyInstance() => create();
  static $pb.PbList<CombineAndBroadcastResponse> createRepeated() => $pb.PbList<CombineAndBroadcastResponse>();
  @$core.pragma('dart2js:noInline')
  static CombineAndBroadcastResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CombineAndBroadcastResponse>(create);
  static CombineAndBroadcastResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
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
    final $result = create();
    if (owner != null) {
      $result.owner = owner;
    }
    if (xpub != null) {
      $result.xpub = xpub;
    }
    if (derivationPath != null) {
      $result.derivationPath = derivationPath;
    }
    if (fingerprint != null) {
      $result.fingerprint = fingerprint;
    }
    if (originPath != null) {
      $result.originPath = originPath;
    }
    if (isWallet != null) {
      $result.isWallet = isWallet;
    }
    return $result;
  }
  GroupKey._() : super();
  factory GroupKey.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GroupKey.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GroupKey', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'owner')
    ..aOS(2, _omitFieldNames ? '' : 'xpub')
    ..aOS(3, _omitFieldNames ? '' : 'derivationPath')
    ..aOS(4, _omitFieldNames ? '' : 'fingerprint')
    ..aOS(5, _omitFieldNames ? '' : 'originPath')
    ..aOB(6, _omitFieldNames ? '' : 'isWallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GroupKey clone() => GroupKey()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GroupKey copyWith(void Function(GroupKey) updates) => super.copyWith((message) => updates(message as GroupKey)) as GroupKey;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GroupKey create() => GroupKey._();
  GroupKey createEmptyInstance() => create();
  static $pb.PbList<GroupKey> createRepeated() => $pb.PbList<GroupKey>();
  @$core.pragma('dart2js:noInline')
  static GroupKey getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GroupKey>(create);
  static GroupKey? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get owner => $_getSZ(0);
  @$pb.TagNumber(1)
  set owner($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasOwner() => $_has(0);
  @$pb.TagNumber(1)
  void clearOwner() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get xpub => $_getSZ(1);
  @$pb.TagNumber(2)
  set xpub($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasXpub() => $_has(1);
  @$pb.TagNumber(2)
  void clearXpub() => clearField(2);

  /// Full BIP32 derivation path, e.g. "m/48'/1'/0'/2'".
  @$pb.TagNumber(3)
  $core.String get derivationPath => $_getSZ(2);
  @$pb.TagNumber(3)
  set derivationPath($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDerivationPath() => $_has(2);
  @$pb.TagNumber(3)
  void clearDerivationPath() => clearField(3);

  /// Master key fingerprint, 8 hex chars. Empty for non-wallet keys.
  @$pb.TagNumber(4)
  $core.String get fingerprint => $_getSZ(3);
  @$pb.TagNumber(4)
  set fingerprint($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFingerprint() => $_has(3);
  @$pb.TagNumber(4)
  void clearFingerprint() => clearField(4);

  /// Origin path without the leading "m/". Empty for non-wallet keys.
  @$pb.TagNumber(5)
  $core.String get originPath => $_getSZ(4);
  @$pb.TagNumber(5)
  set originPath($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasOriginPath() => $_has(4);
  @$pb.TagNumber(5)
  void clearOriginPath() => clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isWallet => $_getBF(5);
  @$pb.TagNumber(6)
  set isWallet($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasIsWallet() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsWallet() => clearField(6);
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
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (name != null) {
      $result.name = name;
    }
    if (n != null) {
      $result.n = n;
    }
    if (m != null) {
      $result.m = m;
    }
    if (keys != null) {
      $result.keys.addAll(keys);
    }
    if (created != null) {
      $result.created = created;
    }
    if (descriptorReceive != null) {
      $result.descriptorReceive = descriptorReceive;
    }
    if (descriptorChange != null) {
      $result.descriptorChange = descriptorChange;
    }
    if (watchWalletName != null) {
      $result.watchWalletName = watchWalletName;
    }
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  GroupData._() : super();
  factory GroupData.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GroupData.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GroupData', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'n', $pb.PbFieldType.OU3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'm', $pb.PbFieldType.OU3)
    ..pc<GroupKey>(5, _omitFieldNames ? '' : 'keys', $pb.PbFieldType.PM, subBuilder: GroupKey.create)
    ..aInt64(6, _omitFieldNames ? '' : 'created')
    ..aOS(7, _omitFieldNames ? '' : 'descriptorReceive')
    ..aOS(8, _omitFieldNames ? '' : 'descriptorChange')
    ..aOS(9, _omitFieldNames ? '' : 'watchWalletName')
    ..aOS(10, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GroupData clone() => GroupData()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GroupData copyWith(void Function(GroupData) updates) => super.copyWith((message) => updates(message as GroupData)) as GroupData;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GroupData create() => GroupData._();
  GroupData createEmptyInstance() => create();
  static $pb.PbList<GroupData> createRepeated() => $pb.PbList<GroupData>();
  @$core.pragma('dart2js:noInline')
  static GroupData getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GroupData>(create);
  static GroupData? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get n => $_getIZ(2);
  @$pb.TagNumber(3)
  set n($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasN() => $_has(2);
  @$pb.TagNumber(3)
  void clearN() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get m => $_getIZ(3);
  @$pb.TagNumber(4)
  set m($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasM() => $_has(3);
  @$pb.TagNumber(4)
  void clearM() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<GroupKey> get keys => $_getList(4);

  /// Creation time, milliseconds since epoch (matches the Dart 'created' field).
  @$pb.TagNumber(6)
  $fixnum.Int64 get created => $_getI64(5);
  @$pb.TagNumber(6)
  set created($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasCreated() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreated() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get descriptorReceive => $_getSZ(6);
  @$pb.TagNumber(7)
  set descriptorReceive($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasDescriptorReceive() => $_has(6);
  @$pb.TagNumber(7)
  void clearDescriptorReceive() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get descriptorChange => $_getSZ(7);
  @$pb.TagNumber(8)
  set descriptorChange($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasDescriptorChange() => $_has(7);
  @$pb.TagNumber(8)
  void clearDescriptorChange() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get watchWalletName => $_getSZ(8);
  @$pb.TagNumber(9)
  set watchWalletName($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasWatchWalletName() => $_has(8);
  @$pb.TagNumber(9)
  void clearWatchWalletName() => clearField(9);

  @$pb.TagNumber(10)
  $core.String get txid => $_getSZ(9);
  @$pb.TagNumber(10)
  set txid($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasTxid() => $_has(9);
  @$pb.TagNumber(10)
  void clearTxid() => clearField(10);
}

class PublishGroupRequest extends $pb.GeneratedMessage {
  factory PublishGroupRequest({
    GroupData? group,
    $core.String? walletId,
  }) {
    final $result = create();
    if (group != null) {
      $result.group = group;
    }
    if (walletId != null) {
      $result.walletId = walletId;
    }
    return $result;
  }
  PublishGroupRequest._() : super();
  factory PublishGroupRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PublishGroupRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PublishGroupRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..aOM<GroupData>(1, _omitFieldNames ? '' : 'group', subBuilder: GroupData.create)
    ..aOS(2, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PublishGroupRequest clone() => PublishGroupRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PublishGroupRequest copyWith(void Function(PublishGroupRequest) updates) => super.copyWith((message) => updates(message as PublishGroupRequest)) as PublishGroupRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PublishGroupRequest create() => PublishGroupRequest._();
  PublishGroupRequest createEmptyInstance() => create();
  static $pb.PbList<PublishGroupRequest> createRepeated() => $pb.PbList<PublishGroupRequest>();
  @$core.pragma('dart2js:noInline')
  static PublishGroupRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PublishGroupRequest>(create);
  static PublishGroupRequest? _defaultInstance;

  @$pb.TagNumber(1)
  GroupData get group => $_getN(0);
  @$pb.TagNumber(1)
  set group(GroupData v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroup() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroup() => clearField(1);
  @$pb.TagNumber(1)
  GroupData ensureGroup() => $_ensure(0);

  /// Wallet that funds the broadcast and provides the fresh address.
  @$pb.TagNumber(2)
  $core.String get walletId => $_getSZ(1);
  @$pb.TagNumber(2)
  set walletId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWalletId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWalletId() => clearField(2);
}

class PublishGroupResponse extends $pb.GeneratedMessage {
  factory PublishGroupResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  PublishGroupResponse._() : super();
  factory PublishGroupResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PublishGroupResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PublishGroupResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  PublishGroupResponse clone() => PublishGroupResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  PublishGroupResponse copyWith(void Function(PublishGroupResponse) updates) => super.copyWith((message) => updates(message as PublishGroupResponse)) as PublishGroupResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static PublishGroupResponse create() => PublishGroupResponse._();
  PublishGroupResponse createEmptyInstance() => create();
  static $pb.PbList<PublishGroupResponse> createRepeated() => $pb.PbList<PublishGroupResponse>();
  @$core.pragma('dart2js:noInline')
  static PublishGroupResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PublishGroupResponse>(create);
  static PublishGroupResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class ImportGroupFromTxidRequest extends $pb.GeneratedMessage {
  factory ImportGroupFromTxidRequest({
    $core.String? txid,
    $core.String? walletId,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (walletId != null) {
      $result.walletId = walletId;
    }
    return $result;
  }
  ImportGroupFromTxidRequest._() : super();
  factory ImportGroupFromTxidRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ImportGroupFromTxidRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportGroupFromTxidRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aOS(2, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ImportGroupFromTxidRequest clone() => ImportGroupFromTxidRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ImportGroupFromTxidRequest copyWith(void Function(ImportGroupFromTxidRequest) updates) => super.copyWith((message) => updates(message as ImportGroupFromTxidRequest)) as ImportGroupFromTxidRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportGroupFromTxidRequest create() => ImportGroupFromTxidRequest._();
  ImportGroupFromTxidRequest createEmptyInstance() => create();
  static $pb.PbList<ImportGroupFromTxidRequest> createRepeated() => $pb.PbList<ImportGroupFromTxidRequest>();
  @$core.pragma('dart2js:noInline')
  static ImportGroupFromTxidRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportGroupFromTxidRequest>(create);
  static ImportGroupFromTxidRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  /// Wallet whose keys are matched against the group's cosigners.
  @$pb.TagNumber(2)
  $core.String get walletId => $_getSZ(1);
  @$pb.TagNumber(2)
  set walletId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWalletId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWalletId() => clearField(2);
}

class ImportGroupFromTxidResponse extends $pb.GeneratedMessage {
  factory ImportGroupFromTxidResponse({
    GroupData? group,
    $core.Iterable<$core.int>? walletKeyIndices,
  }) {
    final $result = create();
    if (group != null) {
      $result.group = group;
    }
    if (walletKeyIndices != null) {
      $result.walletKeyIndices.addAll(walletKeyIndices);
    }
    return $result;
  }
  ImportGroupFromTxidResponse._() : super();
  factory ImportGroupFromTxidResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ImportGroupFromTxidResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportGroupFromTxidResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..aOM<GroupData>(1, _omitFieldNames ? '' : 'group', subBuilder: GroupData.create)
    ..p<$core.int>(2, _omitFieldNames ? '' : 'walletKeyIndices', $pb.PbFieldType.KU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ImportGroupFromTxidResponse clone() => ImportGroupFromTxidResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ImportGroupFromTxidResponse copyWith(void Function(ImportGroupFromTxidResponse) updates) => super.copyWith((message) => updates(message as ImportGroupFromTxidResponse)) as ImportGroupFromTxidResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportGroupFromTxidResponse create() => ImportGroupFromTxidResponse._();
  ImportGroupFromTxidResponse createEmptyInstance() => create();
  static $pb.PbList<ImportGroupFromTxidResponse> createRepeated() => $pb.PbList<ImportGroupFromTxidResponse>();
  @$core.pragma('dart2js:noInline')
  static ImportGroupFromTxidResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportGroupFromTxidResponse>(create);
  static ImportGroupFromTxidResponse? _defaultInstance;

  @$pb.TagNumber(1)
  GroupData get group => $_getN(0);
  @$pb.TagNumber(1)
  set group(GroupData v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroup() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroup() => clearField(1);
  @$pb.TagNumber(1)
  GroupData ensureGroup() => $_ensure(0);

  /// Indices into group.keys that belong to the wallet (derived xpub matches).
  @$pb.TagNumber(2)
  $core.List<$core.int> get walletKeyIndices => $_getList(1);
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
    final $result = create();
    if (xpub != null) {
      $result.xpub = xpub;
    }
    if (derivationPath != null) {
      $result.derivationPath = derivationPath;
    }
    if (fingerprint != null) {
      $result.fingerprint = fingerprint;
    }
    if (originPath != null) {
      $result.originPath = originPath;
    }
    if (isWallet != null) {
      $result.isWallet = isWallet;
    }
    return $result;
  }
  MultisigKey._() : super();
  factory MultisigKey.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MultisigKey.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MultisigKey', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'xpub')
    ..aOS(2, _omitFieldNames ? '' : 'derivationPath')
    ..aOS(3, _omitFieldNames ? '' : 'fingerprint')
    ..aOS(4, _omitFieldNames ? '' : 'originPath')
    ..aOB(5, _omitFieldNames ? '' : 'isWallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MultisigKey clone() => MultisigKey()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MultisigKey copyWith(void Function(MultisigKey) updates) => super.copyWith((message) => updates(message as MultisigKey)) as MultisigKey;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MultisigKey create() => MultisigKey._();
  MultisigKey createEmptyInstance() => create();
  static $pb.PbList<MultisigKey> createRepeated() => $pb.PbList<MultisigKey>();
  @$core.pragma('dart2js:noInline')
  static MultisigKey getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MultisigKey>(create);
  static MultisigKey? _defaultInstance;

  /// Extended public key (xpub/tpub).
  @$pb.TagNumber(1)
  $core.String get xpub => $_getSZ(0);
  @$pb.TagNumber(1)
  set xpub($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasXpub() => $_has(0);
  @$pb.TagNumber(1)
  void clearXpub() => clearField(1);

  /// Full BIP32 derivation path of the account key, e.g. "m/48'/1'/0'/2'".
  @$pb.TagNumber(2)
  $core.String get derivationPath => $_getSZ(1);
  @$pb.TagNumber(2)
  set derivationPath($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDerivationPath() => $_has(1);
  @$pb.TagNumber(2)
  void clearDerivationPath() => clearField(2);

  /// Master key fingerprint, 8 hex chars. Empty for non-wallet keys.
  @$pb.TagNumber(3)
  $core.String get fingerprint => $_getSZ(2);
  @$pb.TagNumber(3)
  set fingerprint($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFingerprint() => $_has(2);
  @$pb.TagNumber(3)
  void clearFingerprint() => clearField(3);

  /// Origin path without the leading "m/", e.g. "48'/1'/0'/2'". Empty for non-wallet keys.
  @$pb.TagNumber(4)
  $core.String get originPath => $_getSZ(3);
  @$pb.TagNumber(4)
  set originPath($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasOriginPath() => $_has(3);
  @$pb.TagNumber(4)
  void clearOriginPath() => clearField(4);

  /// True if this key is owned by the local wallet (emits a [fp/origin] prefix).
  @$pb.TagNumber(5)
  $core.bool get isWallet => $_getBF(4);
  @$pb.TagNumber(5)
  set isWallet($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasIsWallet() => $_has(4);
  @$pb.TagNumber(5)
  void clearIsWallet() => clearField(5);
}

/// MultisigGroup describes an m-of-n policy.
class MultisigGroup extends $pb.GeneratedMessage {
  factory MultisigGroup({
    $core.int? m,
    $core.int? n,
    $core.Iterable<MultisigKey>? keys,
  }) {
    final $result = create();
    if (m != null) {
      $result.m = m;
    }
    if (n != null) {
      $result.n = n;
    }
    if (keys != null) {
      $result.keys.addAll(keys);
    }
    return $result;
  }
  MultisigGroup._() : super();
  factory MultisigGroup.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MultisigGroup.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MultisigGroup', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'm', $pb.PbFieldType.OU3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'n', $pb.PbFieldType.OU3)
    ..pc<MultisigKey>(3, _omitFieldNames ? '' : 'keys', $pb.PbFieldType.PM, subBuilder: MultisigKey.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MultisigGroup clone() => MultisigGroup()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MultisigGroup copyWith(void Function(MultisigGroup) updates) => super.copyWith((message) => updates(message as MultisigGroup)) as MultisigGroup;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MultisigGroup create() => MultisigGroup._();
  MultisigGroup createEmptyInstance() => create();
  static $pb.PbList<MultisigGroup> createRepeated() => $pb.PbList<MultisigGroup>();
  @$core.pragma('dart2js:noInline')
  static MultisigGroup getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MultisigGroup>(create);
  static MultisigGroup? _defaultInstance;

  /// Threshold (m): signatures required.
  @$pb.TagNumber(1)
  $core.int get m => $_getIZ(0);
  @$pb.TagNumber(1)
  set m($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasM() => $_has(0);
  @$pb.TagNumber(1)
  void clearM() => clearField(1);

  /// Total keys (n).
  @$pb.TagNumber(2)
  $core.int get n => $_getIZ(1);
  @$pb.TagNumber(2)
  set n($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasN() => $_has(1);
  @$pb.TagNumber(2)
  void clearN() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<MultisigKey> get keys => $_getList(2);
}

class BuildDescriptorsRequest extends $pb.GeneratedMessage {
  factory BuildDescriptorsRequest({
    MultisigGroup? group,
  }) {
    final $result = create();
    if (group != null) {
      $result.group = group;
    }
    return $result;
  }
  BuildDescriptorsRequest._() : super();
  factory BuildDescriptorsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BuildDescriptorsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BuildDescriptorsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..aOM<MultisigGroup>(1, _omitFieldNames ? '' : 'group', subBuilder: MultisigGroup.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BuildDescriptorsRequest clone() => BuildDescriptorsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BuildDescriptorsRequest copyWith(void Function(BuildDescriptorsRequest) updates) => super.copyWith((message) => updates(message as BuildDescriptorsRequest)) as BuildDescriptorsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BuildDescriptorsRequest create() => BuildDescriptorsRequest._();
  BuildDescriptorsRequest createEmptyInstance() => create();
  static $pb.PbList<BuildDescriptorsRequest> createRepeated() => $pb.PbList<BuildDescriptorsRequest>();
  @$core.pragma('dart2js:noInline')
  static BuildDescriptorsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BuildDescriptorsRequest>(create);
  static BuildDescriptorsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  MultisigGroup get group => $_getN(0);
  @$pb.TagNumber(1)
  set group(MultisigGroup v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasGroup() => $_has(0);
  @$pb.TagNumber(1)
  void clearGroup() => clearField(1);
  @$pb.TagNumber(1)
  MultisigGroup ensureGroup() => $_ensure(0);
}

class BuildDescriptorsResponse extends $pb.GeneratedMessage {
  factory BuildDescriptorsResponse({
    $core.String? receiveDescriptor,
    $core.String? changeDescriptor,
  }) {
    final $result = create();
    if (receiveDescriptor != null) {
      $result.receiveDescriptor = receiveDescriptor;
    }
    if (changeDescriptor != null) {
      $result.changeDescriptor = changeDescriptor;
    }
    return $result;
  }
  BuildDescriptorsResponse._() : super();
  factory BuildDescriptorsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BuildDescriptorsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BuildDescriptorsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'receiveDescriptor')
    ..aOS(2, _omitFieldNames ? '' : 'changeDescriptor')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BuildDescriptorsResponse clone() => BuildDescriptorsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BuildDescriptorsResponse copyWith(void Function(BuildDescriptorsResponse) updates) => super.copyWith((message) => updates(message as BuildDescriptorsResponse)) as BuildDescriptorsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BuildDescriptorsResponse create() => BuildDescriptorsResponse._();
  BuildDescriptorsResponse createEmptyInstance() => create();
  static $pb.PbList<BuildDescriptorsResponse> createRepeated() => $pb.PbList<BuildDescriptorsResponse>();
  @$core.pragma('dart2js:noInline')
  static BuildDescriptorsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BuildDescriptorsResponse>(create);
  static BuildDescriptorsResponse? _defaultInstance;

  /// Receive descriptor (/0/*) with checksum.
  @$pb.TagNumber(1)
  $core.String get receiveDescriptor => $_getSZ(0);
  @$pb.TagNumber(1)
  set receiveDescriptor($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasReceiveDescriptor() => $_has(0);
  @$pb.TagNumber(1)
  void clearReceiveDescriptor() => clearField(1);

  /// Change descriptor (/1/*) with checksum.
  @$pb.TagNumber(2)
  $core.String get changeDescriptor => $_getSZ(1);
  @$pb.TagNumber(2)
  set changeDescriptor($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasChangeDescriptor() => $_has(1);
  @$pb.TagNumber(2)
  void clearChangeDescriptor() => clearField(2);
}

class ValidatePsbtRequest extends $pb.GeneratedMessage {
  factory ValidatePsbtRequest({
    $core.String? psbtBase64,
    $core.int? requiredSigs,
    MultisigGroup? group,
  }) {
    final $result = create();
    if (psbtBase64 != null) {
      $result.psbtBase64 = psbtBase64;
    }
    if (requiredSigs != null) {
      $result.requiredSigs = requiredSigs;
    }
    if (group != null) {
      $result.group = group;
    }
    return $result;
  }
  ValidatePsbtRequest._() : super();
  factory ValidatePsbtRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ValidatePsbtRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ValidatePsbtRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbtBase64')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'requiredSigs', $pb.PbFieldType.OU3)
    ..aOM<MultisigGroup>(3, _omitFieldNames ? '' : 'group', subBuilder: MultisigGroup.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ValidatePsbtRequest clone() => ValidatePsbtRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ValidatePsbtRequest copyWith(void Function(ValidatePsbtRequest) updates) => super.copyWith((message) => updates(message as ValidatePsbtRequest)) as ValidatePsbtRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ValidatePsbtRequest create() => ValidatePsbtRequest._();
  ValidatePsbtRequest createEmptyInstance() => create();
  static $pb.PbList<ValidatePsbtRequest> createRepeated() => $pb.PbList<ValidatePsbtRequest>();
  @$core.pragma('dart2js:noInline')
  static ValidatePsbtRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ValidatePsbtRequest>(create);
  static ValidatePsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbtBase64 => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbtBase64($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbtBase64() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbtBase64() => clearField(1);

  /// Signatures required per input (m).
  @$pb.TagNumber(2)
  $core.int get requiredSigs => $_getIZ(1);
  @$pb.TagNumber(2)
  set requiredSigs($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRequiredSigs() => $_has(1);
  @$pb.TagNumber(2)
  void clearRequiredSigs() => clearField(2);

  /// Optional. When set, every input must match this group's descriptor.
  @$pb.TagNumber(3)
  MultisigGroup get group => $_getN(2);
  @$pb.TagNumber(3)
  set group(MultisigGroup v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasGroup() => $_has(2);
  @$pb.TagNumber(3)
  void clearGroup() => clearField(3);
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
    final $result = create();
    if (hasSignatures != null) {
      $result.hasSignatures = hasSignatures;
    }
    if (signatureCount != null) {
      $result.signatureCount = signatureCount;
    }
    if (isComplete != null) {
      $result.isComplete = isComplete;
    }
    if (finalizable != null) {
      $result.finalizable = finalizable;
    }
    if (error != null) {
      $result.error = error;
    }
    return $result;
  }
  ValidatePsbtResponse._() : super();
  factory ValidatePsbtResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ValidatePsbtResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ValidatePsbtResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'multisiglounge.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'hasSignatures')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'signatureCount', $pb.PbFieldType.OU3)
    ..aOB(3, _omitFieldNames ? '' : 'isComplete')
    ..aOB(4, _omitFieldNames ? '' : 'finalizable')
    ..aOS(5, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ValidatePsbtResponse clone() => ValidatePsbtResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ValidatePsbtResponse copyWith(void Function(ValidatePsbtResponse) updates) => super.copyWith((message) => updates(message as ValidatePsbtResponse)) as ValidatePsbtResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ValidatePsbtResponse create() => ValidatePsbtResponse._();
  ValidatePsbtResponse createEmptyInstance() => create();
  static $pb.PbList<ValidatePsbtResponse> createRepeated() => $pb.PbList<ValidatePsbtResponse>();
  @$core.pragma('dart2js:noInline')
  static ValidatePsbtResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ValidatePsbtResponse>(create);
  static ValidatePsbtResponse? _defaultInstance;

  /// At least one partial signature is present on some input.
  @$pb.TagNumber(1)
  $core.bool get hasSignatures => $_getBF(0);
  @$pb.TagNumber(1)
  set hasSignatures($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHasSignatures() => $_has(0);
  @$pb.TagNumber(1)
  void clearHasSignatures() => clearField(1);

  /// Maximum partial-signature count across inputs.
  @$pb.TagNumber(2)
  $core.int get signatureCount => $_getIZ(1);
  @$pb.TagNumber(2)
  set signatureCount($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSignatureCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearSignatureCount() => clearField(2);

  /// Every input has reached the required threshold.
  @$pb.TagNumber(3)
  $core.bool get isComplete => $_getBF(2);
  @$pb.TagNumber(3)
  set isComplete($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasIsComplete() => $_has(2);
  @$pb.TagNumber(3)
  void clearIsComplete() => clearField(3);

  /// The PSBT can be finalized into a broadcastable transaction.
  @$pb.TagNumber(4)
  $core.bool get finalizable => $_getBF(3);
  @$pb.TagNumber(4)
  set finalizable($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFinalizable() => $_has(3);
  @$pb.TagNumber(4)
  void clearFinalizable() => clearField(4);

  /// Non-empty on validation failure (e.g. foreign input, parse error).
  @$pb.TagNumber(5)
  $core.String get error => $_getSZ(4);
  @$pb.TagNumber(5)
  set error($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasError() => $_has(4);
  @$pb.TagNumber(5)
  void clearError() => clearField(5);
}

class MultisigLoungeServiceApi {
  $pb.RpcClient _client;
  MultisigLoungeServiceApi(this._client);

  $async.Future<BuildDescriptorsResponse> buildDescriptors($pb.ClientContext? ctx, BuildDescriptorsRequest request) =>
    _client.invoke<BuildDescriptorsResponse>(ctx, 'MultisigLoungeService', 'BuildDescriptors', request, BuildDescriptorsResponse())
  ;
  $async.Future<ValidatePsbtResponse> validatePsbt($pb.ClientContext? ctx, ValidatePsbtRequest request) =>
    _client.invoke<ValidatePsbtResponse>(ctx, 'MultisigLoungeService', 'ValidatePsbt', request, ValidatePsbtResponse())
  ;
  $async.Future<PublishGroupResponse> publishGroup($pb.ClientContext? ctx, PublishGroupRequest request) =>
    _client.invoke<PublishGroupResponse>(ctx, 'MultisigLoungeService', 'PublishGroup', request, PublishGroupResponse())
  ;
  $async.Future<ImportGroupFromTxidResponse> importGroupFromTxid($pb.ClientContext? ctx, ImportGroupFromTxidRequest request) =>
    _client.invoke<ImportGroupFromTxidResponse>(ctx, 'MultisigLoungeService', 'ImportGroupFromTxid', request, ImportGroupFromTxidResponse())
  ;
  $async.Future<SignTransactionResponse> signTransaction($pb.ClientContext? ctx, SignTransactionRequest request) =>
    _client.invoke<SignTransactionResponse>(ctx, 'MultisigLoungeService', 'SignTransaction', request, SignTransactionResponse())
  ;
  $async.Future<CombineAndBroadcastResponse> combineAndBroadcast($pb.ClientContext? ctx, CombineAndBroadcastRequest request) =>
    _client.invoke<CombineAndBroadcastResponse>(ctx, 'MultisigLoungeService', 'CombineAndBroadcast', request, CombineAndBroadcastResponse())
  ;
  $async.Future<SyncGroupResponse> syncGroup($pb.ClientContext? ctx, SyncGroupRequest request) =>
    _client.invoke<SyncGroupResponse>(ctx, 'MultisigLoungeService', 'SyncGroup', request, SyncGroupResponse())
  ;
  $async.Future<RestoreHistoryResponse> restoreHistory($pb.ClientContext? ctx, RestoreHistoryRequest request) =>
    _client.invoke<RestoreHistoryResponse>(ctx, 'MultisigLoungeService', 'RestoreHistory', request, RestoreHistoryResponse())
  ;
  $async.Future<CreateSpendPsbtResponse> createSpendPsbt($pb.ClientContext? ctx, CreateSpendPsbtRequest request) =>
    _client.invoke<CreateSpendPsbtResponse>(ctx, 'MultisigLoungeService', 'CreateSpendPsbt', request, CreateSpendPsbtResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
