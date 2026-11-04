// This is a generated file - do not edit.
//
// Generated from walletmanager/v1/walletmanager.proto.

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
import 'package:protobuf/well_known_types/google/protobuf/empty.pb.dart' as $1;
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart' as $0;

import '../../orchestrator/v1/orchestrator.pbenum.dart' as $2;
import 'walletmanager.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'walletmanager.pbenum.dart';

class GetWalletStatusRequest extends $pb.GeneratedMessage {
  factory GetWalletStatusRequest() => GetWalletStatusRequest._();

  GetWalletStatusRequest._();

  factory GetWalletStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetWalletStatusRequest()..mergeFromBuffer(data, registry);
  factory GetWalletStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetWalletStatusRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWalletStatusRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: GetWalletStatusRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWalletStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWalletStatusRequest copyWith(void Function(GetWalletStatusRequest) updates) =>
      super.copyWith((message) => updates(message as GetWalletStatusRequest)) as GetWalletStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetWalletStatusRequest() / GetWalletStatusRequest.new instead')
  static GetWalletStatusRequest create() => GetWalletStatusRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetWalletStatusRequest._();
  @$core.override
  GetWalletStatusRequest createEmptyInstance() => GetWalletStatusRequest._();
  @$core.pragma('dart2js:noInline')
  static GetWalletStatusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetWalletStatusRequest>(GetWalletStatusRequest.$_createMessage);
  static GetWalletStatusRequest? _defaultInstance;
}

class GetWalletStatusResponse extends $pb.GeneratedMessage {
  factory GetWalletStatusResponse({
    @$core.Deprecated('This field is deprecated.') $core.bool? hasWallet,
    $core.bool? encrypted,
    @$core.Deprecated('This field is deprecated.') $core.bool? unlocked,
    $core.String? activeWalletId,
    $core.String? activeWalletName,
    WalletState? state,
  }) {
    final result = GetWalletStatusResponse._();
    if (hasWallet != null) result.hasWallet = hasWallet;
    if (encrypted != null) result.encrypted = encrypted;
    if (unlocked != null) result.unlocked = unlocked;
    if (activeWalletId != null) result.activeWalletId = activeWalletId;
    if (activeWalletName != null) result.activeWalletName = activeWalletName;
    if (state != null) result.state = state;
    return result;
  }

  GetWalletStatusResponse._();

  factory GetWalletStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetWalletStatusResponse()..mergeFromBuffer(data, registry);
  factory GetWalletStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetWalletStatusResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWalletStatusResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: GetWalletStatusResponse.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'hasWallet')
    ..aOB(2, _omitFieldNames ? '' : 'encrypted')
    ..aOB(3, _omitFieldNames ? '' : 'unlocked')
    ..aOS(4, _omitFieldNames ? '' : 'activeWalletId')
    ..aOS(5, _omitFieldNames ? '' : 'activeWalletName')
    ..aE<WalletState>(6, _omitFieldNames ? '' : 'state', enumValues: WalletState.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWalletStatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWalletStatusResponse copyWith(void Function(GetWalletStatusResponse) updates) =>
      super.copyWith((message) => updates(message as GetWalletStatusResponse)) as GetWalletStatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetWalletStatusResponse() / GetWalletStatusResponse.new instead')
  static GetWalletStatusResponse create() => GetWalletStatusResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetWalletStatusResponse._();
  @$core.override
  GetWalletStatusResponse createEmptyInstance() => GetWalletStatusResponse._();
  @$core.pragma('dart2js:noInline')
  static GetWalletStatusResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetWalletStatusResponse>(GetWalletStatusResponse.$_createMessage);
  static GetWalletStatusResponse? _defaultInstance;

  /// Use state.
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(1)
  $core.bool get hasWallet => $_getBF(0);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(1)
  set hasWallet($core.bool value) => $_setBool(0, value);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(1)
  $core.bool hasHasWallet() => $_has(0);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(1)
  void clearHasWallet() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get encrypted => $_getBF(1);
  @$pb.TagNumber(2)
  set encrypted($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEncrypted() => $_has(1);
  @$pb.TagNumber(2)
  void clearEncrypted() => $_clearField(2);

  /// Use state.
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(3)
  $core.bool get unlocked => $_getBF(2);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(3)
  set unlocked($core.bool value) => $_setBool(2, value);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(3)
  $core.bool hasUnlocked() => $_has(2);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(3)
  void clearUnlocked() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get activeWalletId => $_getSZ(3);
  @$pb.TagNumber(4)
  set activeWalletId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasActiveWalletId() => $_has(3);
  @$pb.TagNumber(4)
  void clearActiveWalletId() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get activeWalletName => $_getSZ(4);
  @$pb.TagNumber(5)
  set activeWalletName($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasActiveWalletName() => $_has(4);
  @$pb.TagNumber(5)
  void clearActiveWalletName() => $_clearField(5);

  @$pb.TagNumber(6)
  WalletState get state => $_getN(5);
  @$pb.TagNumber(6)
  set state(WalletState value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasState() => $_has(5);
  @$pb.TagNumber(6)
  void clearState() => $_clearField(6);
}

class ListSidechainDepositsRequest extends $pb.GeneratedMessage {
  factory ListSidechainDepositsRequest({
    $core.int? slot,
    $core.String? walletId,
  }) {
    final result = ListSidechainDepositsRequest._();
    if (slot != null) result.slot = slot;
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  ListSidechainDepositsRequest._();

  factory ListSidechainDepositsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSidechainDepositsRequest()..mergeFromBuffer(data, registry);
  factory ListSidechainDepositsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSidechainDepositsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSidechainDepositsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ListSidechainDepositsRequest.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'slot', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSidechainDepositsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSidechainDepositsRequest copyWith(void Function(ListSidechainDepositsRequest) updates) =>
      super.copyWith((message) => updates(message as ListSidechainDepositsRequest)) as ListSidechainDepositsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListSidechainDepositsRequest() / ListSidechainDepositsRequest.new instead')
  static ListSidechainDepositsRequest create() => ListSidechainDepositsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListSidechainDepositsRequest._();
  @$core.override
  ListSidechainDepositsRequest createEmptyInstance() => ListSidechainDepositsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListSidechainDepositsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListSidechainDepositsRequest>(ListSidechainDepositsRequest.$_createMessage);
  static ListSidechainDepositsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get slot => $_getIZ(0);
  @$pb.TagNumber(1)
  set slot($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSlot() => $_has(0);
  @$pb.TagNumber(1)
  void clearSlot() => $_clearField(1);

  /// Empty lists every wallet's deposits.
  @$pb.TagNumber(2)
  $core.String get walletId => $_getSZ(1);
  @$pb.TagNumber(2)
  set walletId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWalletId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWalletId() => $_clearField(2);
}

class SidechainDeposit extends $pb.GeneratedMessage {
  factory SidechainDeposit({
    $core.String? txid,
    $core.String? walletId,
    $core.int? slot,
    $core.String? destination,
    $fixnum.Int64? amountSats,
    $core.String? createdAt,
    $fixnum.Int64? feeSats,
    $core.int? confirmations,
    $core.String? droppedAt,
  }) {
    final result = SidechainDeposit._();
    if (txid != null) result.txid = txid;
    if (walletId != null) result.walletId = walletId;
    if (slot != null) result.slot = slot;
    if (destination != null) result.destination = destination;
    if (amountSats != null) result.amountSats = amountSats;
    if (createdAt != null) result.createdAt = createdAt;
    if (feeSats != null) result.feeSats = feeSats;
    if (confirmations != null) result.confirmations = confirmations;
    if (droppedAt != null) result.droppedAt = droppedAt;
    return result;
  }

  SidechainDeposit._();

  factory SidechainDeposit.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SidechainDeposit()..mergeFromBuffer(data, registry);
  factory SidechainDeposit.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SidechainDeposit()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SidechainDeposit',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: SidechainDeposit.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aOS(2, _omitFieldNames ? '' : 'walletId')
    ..aI(3, _omitFieldNames ? '' : 'slot', fieldType: $pb.PbFieldType.OU3)
    ..aOS(4, _omitFieldNames ? '' : 'destination')
    ..aInt64(5, _omitFieldNames ? '' : 'amountSats')
    ..aOS(6, _omitFieldNames ? '' : 'createdAt')
    ..aInt64(7, _omitFieldNames ? '' : 'feeSats')
    ..aI(8, _omitFieldNames ? '' : 'confirmations')
    ..aOS(9, _omitFieldNames ? '' : 'droppedAt')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SidechainDeposit clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SidechainDeposit copyWith(void Function(SidechainDeposit) updates) =>
      super.copyWith((message) => updates(message as SidechainDeposit)) as SidechainDeposit;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SidechainDeposit() / SidechainDeposit.new instead')
  static SidechainDeposit create() => SidechainDeposit._();
  static $pb.GeneratedMessage $_createMessage() => SidechainDeposit._();
  @$core.override
  SidechainDeposit createEmptyInstance() => SidechainDeposit._();
  @$core.pragma('dart2js:noInline')
  static SidechainDeposit getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SidechainDeposit>(SidechainDeposit.$_createMessage);
  static SidechainDeposit? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get walletId => $_getSZ(1);
  @$pb.TagNumber(2)
  set walletId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWalletId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWalletId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get slot => $_getIZ(2);
  @$pb.TagNumber(3)
  set slot($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSlot() => $_has(2);
  @$pb.TagNumber(3)
  void clearSlot() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get destination => $_getSZ(3);
  @$pb.TagNumber(4)
  set destination($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDestination() => $_has(3);
  @$pb.TagNumber(4)
  void clearDestination() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get amountSats => $_getI64(4);
  @$pb.TagNumber(5)
  set amountSats($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAmountSats() => $_has(4);
  @$pb.TagNumber(5)
  void clearAmountSats() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get createdAt => $_getSZ(5);
  @$pb.TagNumber(6)
  set createdAt($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCreatedAt() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreatedAt() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get feeSats => $_getI64(6);
  @$pb.TagNumber(7)
  set feeSats($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasFeeSats() => $_has(6);
  @$pb.TagNumber(7)
  void clearFeeSats() => $_clearField(7);

  /// Blocks on top of the one holding this deposit. Zero while unconfirmed.
  @$pb.TagNumber(8)
  $core.int get confirmations => $_getIZ(7);
  @$pb.TagNumber(8)
  set confirmations($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasConfirmations() => $_has(7);
  @$pb.TagNumber(8)
  void clearConfirmations() => $_clearField(8);

  /// Set when the network no longer holds the deposit, so it can never confirm
  /// and the user must send it again. Empty while the deposit can still land.
  @$pb.TagNumber(9)
  $core.String get droppedAt => $_getSZ(8);
  @$pb.TagNumber(9)
  set droppedAt($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasDroppedAt() => $_has(8);
  @$pb.TagNumber(9)
  void clearDroppedAt() => $_clearField(9);
}

class ListSidechainDepositsResponse extends $pb.GeneratedMessage {
  factory ListSidechainDepositsResponse({
    $core.Iterable<SidechainDeposit>? deposits,
  }) {
    final result = ListSidechainDepositsResponse._();
    if (deposits != null) result.deposits.addAll(deposits);
    return result;
  }

  ListSidechainDepositsResponse._();

  factory ListSidechainDepositsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSidechainDepositsResponse()..mergeFromBuffer(data, registry);
  factory ListSidechainDepositsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListSidechainDepositsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSidechainDepositsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ListSidechainDepositsResponse.$_createMessage)
    ..pPM<SidechainDeposit>(1, _omitFieldNames ? '' : 'deposits', subBuilder: SidechainDeposit.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSidechainDepositsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListSidechainDepositsResponse copyWith(void Function(ListSidechainDepositsResponse) updates) =>
      super.copyWith((message) => updates(message as ListSidechainDepositsResponse)) as ListSidechainDepositsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListSidechainDepositsResponse() / ListSidechainDepositsResponse.new instead')
  static ListSidechainDepositsResponse create() => ListSidechainDepositsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListSidechainDepositsResponse._();
  @$core.override
  ListSidechainDepositsResponse createEmptyInstance() => ListSidechainDepositsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListSidechainDepositsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListSidechainDepositsResponse>(ListSidechainDepositsResponse.$_createMessage);
  static ListSidechainDepositsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<SidechainDeposit> get deposits => $_getList(0);
}

class GetSidechainDepositTotalsRequest extends $pb.GeneratedMessage {
  factory GetSidechainDepositTotalsRequest({
    $fixnum.Int64? sinceUnix,
    $core.String? walletId,
  }) {
    final result = GetSidechainDepositTotalsRequest._();
    if (sinceUnix != null) result.sinceUnix = sinceUnix;
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  GetSidechainDepositTotalsRequest._();

  factory GetSidechainDepositTotalsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainDepositTotalsRequest()..mergeFromBuffer(data, registry);
  factory GetSidechainDepositTotalsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainDepositTotalsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainDepositTotalsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: GetSidechainDepositTotalsRequest.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'sinceUnix')
    ..aOS(2, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainDepositTotalsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainDepositTotalsRequest copyWith(void Function(GetSidechainDepositTotalsRequest) updates) =>
      super.copyWith((message) => updates(message as GetSidechainDepositTotalsRequest))
          as GetSidechainDepositTotalsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetSidechainDepositTotalsRequest() / GetSidechainDepositTotalsRequest.new instead')
  static GetSidechainDepositTotalsRequest create() => GetSidechainDepositTotalsRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetSidechainDepositTotalsRequest._();
  @$core.override
  GetSidechainDepositTotalsRequest createEmptyInstance() => GetSidechainDepositTotalsRequest._();
  @$core.pragma('dart2js:noInline')
  static GetSidechainDepositTotalsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetSidechainDepositTotalsRequest>(
          GetSidechainDepositTotalsRequest.$_createMessage);
  static GetSidechainDepositTotalsRequest? _defaultInstance;

  /// Seconds since the epoch. The recent total counts deposits at or after it.
  @$pb.TagNumber(1)
  $fixnum.Int64 get sinceUnix => $_getI64(0);
  @$pb.TagNumber(1)
  set sinceUnix($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSinceUnix() => $_has(0);
  @$pb.TagNumber(1)
  void clearSinceUnix() => $_clearField(1);

  /// Empty sums every wallet's deposits.
  @$pb.TagNumber(2)
  $core.String get walletId => $_getSZ(1);
  @$pb.TagNumber(2)
  set walletId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWalletId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWalletId() => $_clearField(2);
}

class GetSidechainDepositTotalsResponse extends $pb.GeneratedMessage {
  factory GetSidechainDepositTotalsResponse({
    $fixnum.Int64? totalSats,
    $fixnum.Int64? recentSats,
  }) {
    final result = GetSidechainDepositTotalsResponse._();
    if (totalSats != null) result.totalSats = totalSats;
    if (recentSats != null) result.recentSats = recentSats;
    return result;
  }

  GetSidechainDepositTotalsResponse._();

  factory GetSidechainDepositTotalsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainDepositTotalsResponse()..mergeFromBuffer(data, registry);
  factory GetSidechainDepositTotalsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetSidechainDepositTotalsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetSidechainDepositTotalsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: GetSidechainDepositTotalsResponse.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'totalSats')
    ..aInt64(2, _omitFieldNames ? '' : 'recentSats')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainDepositTotalsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetSidechainDepositTotalsResponse copyWith(void Function(GetSidechainDepositTotalsResponse) updates) =>
      super.copyWith((message) => updates(message as GetSidechainDepositTotalsResponse))
          as GetSidechainDepositTotalsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetSidechainDepositTotalsResponse() / GetSidechainDepositTotalsResponse.new instead')
  static GetSidechainDepositTotalsResponse create() => GetSidechainDepositTotalsResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetSidechainDepositTotalsResponse._();
  @$core.override
  GetSidechainDepositTotalsResponse createEmptyInstance() => GetSidechainDepositTotalsResponse._();
  @$core.pragma('dart2js:noInline')
  static GetSidechainDepositTotalsResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetSidechainDepositTotalsResponse>(
          GetSidechainDepositTotalsResponse.$_createMessage);
  static GetSidechainDepositTotalsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get totalSats => $_getI64(0);
  @$pb.TagNumber(1)
  set totalSats($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTotalSats() => $_has(0);
  @$pb.TagNumber(1)
  void clearTotalSats() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get recentSats => $_getI64(1);
  @$pb.TagNumber(2)
  set recentSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRecentSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearRecentSats() => $_clearField(2);
}

class GetNodeModeRequest extends $pb.GeneratedMessage {
  factory GetNodeModeRequest() => GetNodeModeRequest._();

  GetNodeModeRequest._();

  factory GetNodeModeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNodeModeRequest()..mergeFromBuffer(data, registry);
  factory GetNodeModeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNodeModeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNodeModeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: GetNodeModeRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNodeModeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNodeModeRequest copyWith(void Function(GetNodeModeRequest) updates) =>
      super.copyWith((message) => updates(message as GetNodeModeRequest)) as GetNodeModeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetNodeModeRequest() / GetNodeModeRequest.new instead')
  static GetNodeModeRequest create() => GetNodeModeRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetNodeModeRequest._();
  @$core.override
  GetNodeModeRequest createEmptyInstance() => GetNodeModeRequest._();
  @$core.pragma('dart2js:noInline')
  static GetNodeModeRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetNodeModeRequest>(GetNodeModeRequest.$_createMessage);
  static GetNodeModeRequest? _defaultInstance;
}

class GetNodeModeResponse extends $pb.GeneratedMessage {
  factory GetNodeModeResponse({
    NodeMode? mode,
    $core.bool? lightModeAvailable,
    $core.bool? remoteEnforcerAvailable,
    $core.Iterable<$core.String>? remoteEnforcerNetworks,
  }) {
    final result = GetNodeModeResponse._();
    if (mode != null) result.mode = mode;
    if (lightModeAvailable != null) result.lightModeAvailable = lightModeAvailable;
    if (remoteEnforcerAvailable != null) result.remoteEnforcerAvailable = remoteEnforcerAvailable;
    if (remoteEnforcerNetworks != null) result.remoteEnforcerNetworks.addAll(remoteEnforcerNetworks);
    return result;
  }

  GetNodeModeResponse._();

  factory GetNodeModeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNodeModeResponse()..mergeFromBuffer(data, registry);
  factory GetNodeModeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNodeModeResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNodeModeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: GetNodeModeResponse.$_createMessage)
    ..aE<NodeMode>(1, _omitFieldNames ? '' : 'mode', enumValues: NodeMode.values)
    ..aOB(2, _omitFieldNames ? '' : 'lightModeAvailable')
    ..aOB(3, _omitFieldNames ? '' : 'remoteEnforcerAvailable')
    ..pPS(4, _omitFieldNames ? '' : 'remoteEnforcerNetworks')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNodeModeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNodeModeResponse copyWith(void Function(GetNodeModeResponse) updates) =>
      super.copyWith((message) => updates(message as GetNodeModeResponse)) as GetNodeModeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetNodeModeResponse() / GetNodeModeResponse.new instead')
  static GetNodeModeResponse create() => GetNodeModeResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetNodeModeResponse._();
  @$core.override
  GetNodeModeResponse createEmptyInstance() => GetNodeModeResponse._();
  @$core.pragma('dart2js:noInline')
  static GetNodeModeResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetNodeModeResponse>(GetNodeModeResponse.$_createMessage);
  static GetNodeModeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  NodeMode get mode => $_getN(0);
  @$pb.TagNumber(1)
  set mode(NodeMode value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMode() => $_has(0);
  @$pb.TagNumber(1)
  void clearMode() => $_clearField(1);

  /// True when the current network has remote services for light mode.
  @$pb.TagNumber(2)
  $core.bool get lightModeAvailable => $_getBF(1);
  @$pb.TagNumber(2)
  set lightModeAvailable($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasLightModeAvailable() => $_has(1);
  @$pb.TagNumber(2)
  void clearLightModeAvailable() => $_clearField(2);

  /// True when the current network has a remote validator endpoint.
  @$pb.TagNumber(3)
  $core.bool get remoteEnforcerAvailable => $_getBF(2);
  @$pb.TagNumber(3)
  set remoteEnforcerAvailable($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRemoteEnforcerAvailable() => $_has(2);
  @$pb.TagNumber(3)
  void clearRemoteEnforcerAvailable() => $_clearField(3);

  /// Display names of every network with a remote validator endpoint.
  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get remoteEnforcerNetworks => $_getList(3);
}

class SetNodeModeRequest extends $pb.GeneratedMessage {
  factory SetNodeModeRequest({
    NodeMode? mode,
  }) {
    final result = SetNodeModeRequest._();
    if (mode != null) result.mode = mode;
    return result;
  }

  SetNodeModeRequest._();

  factory SetNodeModeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetNodeModeRequest()..mergeFromBuffer(data, registry);
  factory SetNodeModeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetNodeModeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetNodeModeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: SetNodeModeRequest.$_createMessage)
    ..aE<NodeMode>(1, _omitFieldNames ? '' : 'mode', enumValues: NodeMode.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetNodeModeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetNodeModeRequest copyWith(void Function(SetNodeModeRequest) updates) =>
      super.copyWith((message) => updates(message as SetNodeModeRequest)) as SetNodeModeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetNodeModeRequest() / SetNodeModeRequest.new instead')
  static SetNodeModeRequest create() => SetNodeModeRequest._();
  static $pb.GeneratedMessage $_createMessage() => SetNodeModeRequest._();
  @$core.override
  SetNodeModeRequest createEmptyInstance() => SetNodeModeRequest._();
  @$core.pragma('dart2js:noInline')
  static SetNodeModeRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetNodeModeRequest>(SetNodeModeRequest.$_createMessage);
  static SetNodeModeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  NodeMode get mode => $_getN(0);
  @$pb.TagNumber(1)
  set mode(NodeMode value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasMode() => $_has(0);
  @$pb.TagNumber(1)
  void clearMode() => $_clearField(1);
}

class SetNodeModeResponse extends $pb.GeneratedMessage {
  factory SetNodeModeResponse() => SetNodeModeResponse._();

  SetNodeModeResponse._();

  factory SetNodeModeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetNodeModeResponse()..mergeFromBuffer(data, registry);
  factory SetNodeModeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetNodeModeResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetNodeModeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: SetNodeModeResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetNodeModeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetNodeModeResponse copyWith(void Function(SetNodeModeResponse) updates) =>
      super.copyWith((message) => updates(message as SetNodeModeResponse)) as SetNodeModeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetNodeModeResponse() / SetNodeModeResponse.new instead')
  static SetNodeModeResponse create() => SetNodeModeResponse._();
  static $pb.GeneratedMessage $_createMessage() => SetNodeModeResponse._();
  @$core.override
  SetNodeModeResponse createEmptyInstance() => SetNodeModeResponse._();
  @$core.pragma('dart2js:noInline')
  static SetNodeModeResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetNodeModeResponse>(SetNodeModeResponse.$_createMessage);
  static SetNodeModeResponse? _defaultInstance;
}

class GenerateWalletRequest extends $pb.GeneratedMessage {
  factory GenerateWalletRequest({
    $core.String? name,
    $core.String? customMnemonic,
    $core.String? passphrase,
    $core.int? account,
    $core.String? derivationPath,
    $core.String? scriptType,
  }) {
    final result = GenerateWalletRequest._();
    if (name != null) result.name = name;
    if (customMnemonic != null) result.customMnemonic = customMnemonic;
    if (passphrase != null) result.passphrase = passphrase;
    if (account != null) result.account = account;
    if (derivationPath != null) result.derivationPath = derivationPath;
    if (scriptType != null) result.scriptType = scriptType;
    return result;
  }

  GenerateWalletRequest._();

  factory GenerateWalletRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GenerateWalletRequest()..mergeFromBuffer(data, registry);
  factory GenerateWalletRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GenerateWalletRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GenerateWalletRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: GenerateWalletRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'customMnemonic')
    ..aOS(3, _omitFieldNames ? '' : 'passphrase')
    ..aI(4, _omitFieldNames ? '' : 'account', fieldType: $pb.PbFieldType.OU3)
    ..aOS(5, _omitFieldNames ? '' : 'derivationPath')
    ..aOS(6, _omitFieldNames ? '' : 'scriptType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateWalletRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateWalletRequest copyWith(void Function(GenerateWalletRequest) updates) =>
      super.copyWith((message) => updates(message as GenerateWalletRequest)) as GenerateWalletRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GenerateWalletRequest() / GenerateWalletRequest.new instead')
  static GenerateWalletRequest create() => GenerateWalletRequest._();
  static $pb.GeneratedMessage $_createMessage() => GenerateWalletRequest._();
  @$core.override
  GenerateWalletRequest createEmptyInstance() => GenerateWalletRequest._();
  @$core.pragma('dart2js:noInline')
  static GenerateWalletRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GenerateWalletRequest>(GenerateWalletRequest.$_createMessage);
  static GenerateWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get customMnemonic => $_getSZ(1);
  @$pb.TagNumber(2)
  set customMnemonic($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCustomMnemonic() => $_has(1);
  @$pb.TagNumber(2)
  void clearCustomMnemonic() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get passphrase => $_getSZ(2);
  @$pb.TagNumber(3)
  set passphrase($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPassphrase() => $_has(2);
  @$pb.TagNumber(3)
  void clearPassphrase() => $_clearField(3);

  /// Optional BIP32 account index for the wallet's account-level key
  /// (purpose'/coin'/account'). 0 = standard. Ignored when derivation_path set.
  @$pb.TagNumber(4)
  $core.int get account => $_getIZ(3);
  @$pb.TagNumber(4)
  set account($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAccount() => $_has(3);
  @$pb.TagNumber(4)
  void clearAccount() => $_clearField(4);

  /// Optional full account-level derivation path (e.g. "m/84'/0'/3'"),
  /// overriding the default purpose/coin/account. Empty = default (BIP84,
  /// network coin, account field). All three levels must be hardened.
  @$pb.TagNumber(5)
  $core.String get derivationPath => $_getSZ(4);
  @$pb.TagNumber(5)
  set derivationPath($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDerivationPath() => $_has(4);
  @$pb.TagNumber(5)
  void clearDerivationPath() => $_clearField(5);

  /// Address type: "legacy", "nested-segwit", "native-segwit" (default), or
  /// "taproot". Pass this rather than a derivation_path that only names the
  /// address type: a stored path pins the coin type to one network.
  @$pb.TagNumber(6)
  $core.String get scriptType => $_getSZ(5);
  @$pb.TagNumber(6)
  set scriptType($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasScriptType() => $_has(5);
  @$pb.TagNumber(6)
  void clearScriptType() => $_clearField(6);
}

class GenerateWalletResponse extends $pb.GeneratedMessage {
  factory GenerateWalletResponse({
    $core.String? walletId,
    $core.String? mnemonic,
  }) {
    final result = GenerateWalletResponse._();
    if (walletId != null) result.walletId = walletId;
    if (mnemonic != null) result.mnemonic = mnemonic;
    return result;
  }

  GenerateWalletResponse._();

  factory GenerateWalletResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GenerateWalletResponse()..mergeFromBuffer(data, registry);
  factory GenerateWalletResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GenerateWalletResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GenerateWalletResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: GenerateWalletResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aOS(2, _omitFieldNames ? '' : 'mnemonic')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateWalletResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateWalletResponse copyWith(void Function(GenerateWalletResponse) updates) =>
      super.copyWith((message) => updates(message as GenerateWalletResponse)) as GenerateWalletResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GenerateWalletResponse() / GenerateWalletResponse.new instead')
  static GenerateWalletResponse create() => GenerateWalletResponse._();
  static $pb.GeneratedMessage $_createMessage() => GenerateWalletResponse._();
  @$core.override
  GenerateWalletResponse createEmptyInstance() => GenerateWalletResponse._();
  @$core.pragma('dart2js:noInline')
  static GenerateWalletResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GenerateWalletResponse>(GenerateWalletResponse.$_createMessage);
  static GenerateWalletResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get mnemonic => $_getSZ(1);
  @$pb.TagNumber(2)
  set mnemonic($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMnemonic() => $_has(1);
  @$pb.TagNumber(2)
  void clearMnemonic() => $_clearField(2);
}

class UnlockWalletRequest extends $pb.GeneratedMessage {
  factory UnlockWalletRequest({
    $core.String? password,
  }) {
    final result = UnlockWalletRequest._();
    if (password != null) result.password = password;
    return result;
  }

  UnlockWalletRequest._();

  factory UnlockWalletRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UnlockWalletRequest()..mergeFromBuffer(data, registry);
  factory UnlockWalletRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UnlockWalletRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnlockWalletRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: UnlockWalletRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'password')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnlockWalletRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnlockWalletRequest copyWith(void Function(UnlockWalletRequest) updates) =>
      super.copyWith((message) => updates(message as UnlockWalletRequest)) as UnlockWalletRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UnlockWalletRequest() / UnlockWalletRequest.new instead')
  static UnlockWalletRequest create() => UnlockWalletRequest._();
  static $pb.GeneratedMessage $_createMessage() => UnlockWalletRequest._();
  @$core.override
  UnlockWalletRequest createEmptyInstance() => UnlockWalletRequest._();
  @$core.pragma('dart2js:noInline')
  static UnlockWalletRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnlockWalletRequest>(UnlockWalletRequest.$_createMessage);
  static UnlockWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get password => $_getSZ(0);
  @$pb.TagNumber(1)
  set password($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPassword() => $_has(0);
  @$pb.TagNumber(1)
  void clearPassword() => $_clearField(1);
}

class UnlockWalletResponse extends $pb.GeneratedMessage {
  factory UnlockWalletResponse() => UnlockWalletResponse._();

  UnlockWalletResponse._();

  factory UnlockWalletResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UnlockWalletResponse()..mergeFromBuffer(data, registry);
  factory UnlockWalletResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UnlockWalletResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnlockWalletResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: UnlockWalletResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnlockWalletResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnlockWalletResponse copyWith(void Function(UnlockWalletResponse) updates) =>
      super.copyWith((message) => updates(message as UnlockWalletResponse)) as UnlockWalletResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UnlockWalletResponse() / UnlockWalletResponse.new instead')
  static UnlockWalletResponse create() => UnlockWalletResponse._();
  static $pb.GeneratedMessage $_createMessage() => UnlockWalletResponse._();
  @$core.override
  UnlockWalletResponse createEmptyInstance() => UnlockWalletResponse._();
  @$core.pragma('dart2js:noInline')
  static UnlockWalletResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UnlockWalletResponse>(UnlockWalletResponse.$_createMessage);
  static UnlockWalletResponse? _defaultInstance;
}

class LockWalletRequest extends $pb.GeneratedMessage {
  factory LockWalletRequest() => LockWalletRequest._();

  LockWalletRequest._();

  factory LockWalletRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LockWalletRequest()..mergeFromBuffer(data, registry);
  factory LockWalletRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LockWalletRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LockWalletRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: LockWalletRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LockWalletRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LockWalletRequest copyWith(void Function(LockWalletRequest) updates) =>
      super.copyWith((message) => updates(message as LockWalletRequest)) as LockWalletRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LockWalletRequest() / LockWalletRequest.new instead')
  static LockWalletRequest create() => LockWalletRequest._();
  static $pb.GeneratedMessage $_createMessage() => LockWalletRequest._();
  @$core.override
  LockWalletRequest createEmptyInstance() => LockWalletRequest._();
  @$core.pragma('dart2js:noInline')
  static LockWalletRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LockWalletRequest>(LockWalletRequest.$_createMessage);
  static LockWalletRequest? _defaultInstance;
}

class LockWalletResponse extends $pb.GeneratedMessage {
  factory LockWalletResponse() => LockWalletResponse._();

  LockWalletResponse._();

  factory LockWalletResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LockWalletResponse()..mergeFromBuffer(data, registry);
  factory LockWalletResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      LockWalletResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'LockWalletResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: LockWalletResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LockWalletResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  LockWalletResponse copyWith(void Function(LockWalletResponse) updates) =>
      super.copyWith((message) => updates(message as LockWalletResponse)) as LockWalletResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use LockWalletResponse() / LockWalletResponse.new instead')
  static LockWalletResponse create() => LockWalletResponse._();
  static $pb.GeneratedMessage $_createMessage() => LockWalletResponse._();
  @$core.override
  LockWalletResponse createEmptyInstance() => LockWalletResponse._();
  @$core.pragma('dart2js:noInline')
  static LockWalletResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<LockWalletResponse>(LockWalletResponse.$_createMessage);
  static LockWalletResponse? _defaultInstance;
}

class EncryptWalletRequest extends $pb.GeneratedMessage {
  factory EncryptWalletRequest({
    $core.String? password,
  }) {
    final result = EncryptWalletRequest._();
    if (password != null) result.password = password;
    return result;
  }

  EncryptWalletRequest._();

  factory EncryptWalletRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EncryptWalletRequest()..mergeFromBuffer(data, registry);
  factory EncryptWalletRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EncryptWalletRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EncryptWalletRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: EncryptWalletRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'password')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EncryptWalletRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EncryptWalletRequest copyWith(void Function(EncryptWalletRequest) updates) =>
      super.copyWith((message) => updates(message as EncryptWalletRequest)) as EncryptWalletRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EncryptWalletRequest() / EncryptWalletRequest.new instead')
  static EncryptWalletRequest create() => EncryptWalletRequest._();
  static $pb.GeneratedMessage $_createMessage() => EncryptWalletRequest._();
  @$core.override
  EncryptWalletRequest createEmptyInstance() => EncryptWalletRequest._();
  @$core.pragma('dart2js:noInline')
  static EncryptWalletRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EncryptWalletRequest>(EncryptWalletRequest.$_createMessage);
  static EncryptWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get password => $_getSZ(0);
  @$pb.TagNumber(1)
  set password($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPassword() => $_has(0);
  @$pb.TagNumber(1)
  void clearPassword() => $_clearField(1);
}

class EncryptWalletResponse extends $pb.GeneratedMessage {
  factory EncryptWalletResponse() => EncryptWalletResponse._();

  EncryptWalletResponse._();

  factory EncryptWalletResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EncryptWalletResponse()..mergeFromBuffer(data, registry);
  factory EncryptWalletResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EncryptWalletResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EncryptWalletResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: EncryptWalletResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EncryptWalletResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EncryptWalletResponse copyWith(void Function(EncryptWalletResponse) updates) =>
      super.copyWith((message) => updates(message as EncryptWalletResponse)) as EncryptWalletResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EncryptWalletResponse() / EncryptWalletResponse.new instead')
  static EncryptWalletResponse create() => EncryptWalletResponse._();
  static $pb.GeneratedMessage $_createMessage() => EncryptWalletResponse._();
  @$core.override
  EncryptWalletResponse createEmptyInstance() => EncryptWalletResponse._();
  @$core.pragma('dart2js:noInline')
  static EncryptWalletResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EncryptWalletResponse>(EncryptWalletResponse.$_createMessage);
  static EncryptWalletResponse? _defaultInstance;
}

class ChangePasswordRequest extends $pb.GeneratedMessage {
  factory ChangePasswordRequest({
    $core.String? oldPassword,
    $core.String? newPassword,
  }) {
    final result = ChangePasswordRequest._();
    if (oldPassword != null) result.oldPassword = oldPassword;
    if (newPassword != null) result.newPassword = newPassword;
    return result;
  }

  ChangePasswordRequest._();

  factory ChangePasswordRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChangePasswordRequest()..mergeFromBuffer(data, registry);
  factory ChangePasswordRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChangePasswordRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChangePasswordRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ChangePasswordRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'oldPassword')
    ..aOS(2, _omitFieldNames ? '' : 'newPassword')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangePasswordRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangePasswordRequest copyWith(void Function(ChangePasswordRequest) updates) =>
      super.copyWith((message) => updates(message as ChangePasswordRequest)) as ChangePasswordRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ChangePasswordRequest() / ChangePasswordRequest.new instead')
  static ChangePasswordRequest create() => ChangePasswordRequest._();
  static $pb.GeneratedMessage $_createMessage() => ChangePasswordRequest._();
  @$core.override
  ChangePasswordRequest createEmptyInstance() => ChangePasswordRequest._();
  @$core.pragma('dart2js:noInline')
  static ChangePasswordRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChangePasswordRequest>(ChangePasswordRequest.$_createMessage);
  static ChangePasswordRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get oldPassword => $_getSZ(0);
  @$pb.TagNumber(1)
  set oldPassword($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOldPassword() => $_has(0);
  @$pb.TagNumber(1)
  void clearOldPassword() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get newPassword => $_getSZ(1);
  @$pb.TagNumber(2)
  set newPassword($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNewPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearNewPassword() => $_clearField(2);
}

class ChangePasswordResponse extends $pb.GeneratedMessage {
  factory ChangePasswordResponse() => ChangePasswordResponse._();

  ChangePasswordResponse._();

  factory ChangePasswordResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChangePasswordResponse()..mergeFromBuffer(data, registry);
  factory ChangePasswordResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ChangePasswordResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChangePasswordResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ChangePasswordResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangePasswordResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ChangePasswordResponse copyWith(void Function(ChangePasswordResponse) updates) =>
      super.copyWith((message) => updates(message as ChangePasswordResponse)) as ChangePasswordResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ChangePasswordResponse() / ChangePasswordResponse.new instead')
  static ChangePasswordResponse create() => ChangePasswordResponse._();
  static $pb.GeneratedMessage $_createMessage() => ChangePasswordResponse._();
  @$core.override
  ChangePasswordResponse createEmptyInstance() => ChangePasswordResponse._();
  @$core.pragma('dart2js:noInline')
  static ChangePasswordResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ChangePasswordResponse>(ChangePasswordResponse.$_createMessage);
  static ChangePasswordResponse? _defaultInstance;
}

class RemoveEncryptionRequest extends $pb.GeneratedMessage {
  factory RemoveEncryptionRequest({
    $core.String? password,
  }) {
    final result = RemoveEncryptionRequest._();
    if (password != null) result.password = password;
    return result;
  }

  RemoveEncryptionRequest._();

  factory RemoveEncryptionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RemoveEncryptionRequest()..mergeFromBuffer(data, registry);
  factory RemoveEncryptionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RemoveEncryptionRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RemoveEncryptionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: RemoveEncryptionRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'password')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveEncryptionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveEncryptionRequest copyWith(void Function(RemoveEncryptionRequest) updates) =>
      super.copyWith((message) => updates(message as RemoveEncryptionRequest)) as RemoveEncryptionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RemoveEncryptionRequest() / RemoveEncryptionRequest.new instead')
  static RemoveEncryptionRequest create() => RemoveEncryptionRequest._();
  static $pb.GeneratedMessage $_createMessage() => RemoveEncryptionRequest._();
  @$core.override
  RemoveEncryptionRequest createEmptyInstance() => RemoveEncryptionRequest._();
  @$core.pragma('dart2js:noInline')
  static RemoveEncryptionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveEncryptionRequest>(RemoveEncryptionRequest.$_createMessage);
  static RemoveEncryptionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get password => $_getSZ(0);
  @$pb.TagNumber(1)
  set password($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPassword() => $_has(0);
  @$pb.TagNumber(1)
  void clearPassword() => $_clearField(1);
}

class RemoveEncryptionResponse extends $pb.GeneratedMessage {
  factory RemoveEncryptionResponse() => RemoveEncryptionResponse._();

  RemoveEncryptionResponse._();

  factory RemoveEncryptionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RemoveEncryptionResponse()..mergeFromBuffer(data, registry);
  factory RemoveEncryptionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RemoveEncryptionResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RemoveEncryptionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: RemoveEncryptionResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveEncryptionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RemoveEncryptionResponse copyWith(void Function(RemoveEncryptionResponse) updates) =>
      super.copyWith((message) => updates(message as RemoveEncryptionResponse)) as RemoveEncryptionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RemoveEncryptionResponse() / RemoveEncryptionResponse.new instead')
  static RemoveEncryptionResponse create() => RemoveEncryptionResponse._();
  static $pb.GeneratedMessage $_createMessage() => RemoveEncryptionResponse._();
  @$core.override
  RemoveEncryptionResponse createEmptyInstance() => RemoveEncryptionResponse._();
  @$core.pragma('dart2js:noInline')
  static RemoveEncryptionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RemoveEncryptionResponse>(RemoveEncryptionResponse.$_createMessage);
  static RemoveEncryptionResponse? _defaultInstance;
}

class WalletMetadata extends $pb.GeneratedMessage {
  factory WalletMetadata({
    $core.String? id,
    $core.String? name,
    WalletType? walletType,
    $core.String? gradientJson,
    $core.String? createdAt,
    $core.String? bip47PaymentCode,
    $core.String? masterMnemonic,
    $core.String? l1Mnemonic,
    $core.Iterable<SidechainStarter>? sidechains,
    $core.bool? watchOnly,
    MultisigInfo? multisig,
    $core.String? hardwareDeviceType,
    $core.String? hardwareFingerprint,
    $core.Iterable<AddressType>? receiveAddressTypes,
    $core.bool? isStarter,
    $core.String? scriptType,
    $core.int? accountIndex,
    $core.String? derivationPath,
  }) {
    final result = WalletMetadata._();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (walletType != null) result.walletType = walletType;
    if (gradientJson != null) result.gradientJson = gradientJson;
    if (createdAt != null) result.createdAt = createdAt;
    if (bip47PaymentCode != null) result.bip47PaymentCode = bip47PaymentCode;
    if (masterMnemonic != null) result.masterMnemonic = masterMnemonic;
    if (l1Mnemonic != null) result.l1Mnemonic = l1Mnemonic;
    if (sidechains != null) result.sidechains.addAll(sidechains);
    if (watchOnly != null) result.watchOnly = watchOnly;
    if (multisig != null) result.multisig = multisig;
    if (hardwareDeviceType != null) result.hardwareDeviceType = hardwareDeviceType;
    if (hardwareFingerprint != null) result.hardwareFingerprint = hardwareFingerprint;
    if (receiveAddressTypes != null) result.receiveAddressTypes.addAll(receiveAddressTypes);
    if (isStarter != null) result.isStarter = isStarter;
    if (scriptType != null) result.scriptType = scriptType;
    if (accountIndex != null) result.accountIndex = accountIndex;
    if (derivationPath != null) result.derivationPath = derivationPath;
    return result;
  }

  WalletMetadata._();

  factory WalletMetadata.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WalletMetadata()..mergeFromBuffer(data, registry);
  factory WalletMetadata.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WalletMetadata()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WalletMetadata',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: WalletMetadata.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aE<WalletType>(3, _omitFieldNames ? '' : 'walletType', enumValues: WalletType.values)
    ..aOS(4, _omitFieldNames ? '' : 'gradientJson')
    ..aOS(5, _omitFieldNames ? '' : 'createdAt')
    ..aOS(6, _omitFieldNames ? '' : 'bip47PaymentCode')
    ..aOS(7, _omitFieldNames ? '' : 'masterMnemonic')
    ..aOS(8, _omitFieldNames ? '' : 'l1Mnemonic')
    ..pPM<SidechainStarter>(9, _omitFieldNames ? '' : 'sidechains', subBuilder: SidechainStarter.$_createMessage)
    ..aOB(10, _omitFieldNames ? '' : 'watchOnly')
    ..aOM<MultisigInfo>(11, _omitFieldNames ? '' : 'multisig', subBuilder: MultisigInfo.$_createMessage)
    ..aOS(12, _omitFieldNames ? '' : 'hardwareDeviceType')
    ..aOS(13, _omitFieldNames ? '' : 'hardwareFingerprint')
    ..pc<AddressType>(14, _omitFieldNames ? '' : 'receiveAddressTypes', $pb.PbFieldType.KE,
        valueOf: AddressType.valueOf,
        enumValues: AddressType.values,
        defaultEnumValue: AddressType.ADDRESS_TYPE_UNSPECIFIED)
    ..aOB(15, _omitFieldNames ? '' : 'isStarter')
    ..aOS(16, _omitFieldNames ? '' : 'scriptType')
    ..aI(17, _omitFieldNames ? '' : 'accountIndex', fieldType: $pb.PbFieldType.OU3)
    ..aOS(18, _omitFieldNames ? '' : 'derivationPath')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WalletMetadata clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WalletMetadata copyWith(void Function(WalletMetadata) updates) =>
      super.copyWith((message) => updates(message as WalletMetadata)) as WalletMetadata;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WalletMetadata() / WalletMetadata.new instead')
  static WalletMetadata create() => WalletMetadata._();
  static $pb.GeneratedMessage $_createMessage() => WalletMetadata._();
  @$core.override
  WalletMetadata createEmptyInstance() => WalletMetadata._();
  @$core.pragma('dart2js:noInline')
  static WalletMetadata getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WalletMetadata>(WalletMetadata.$_createMessage);
  static WalletMetadata? _defaultInstance;

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
  WalletType get walletType => $_getN(2);
  @$pb.TagNumber(3)
  set walletType(WalletType value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasWalletType() => $_has(2);
  @$pb.TagNumber(3)
  void clearWalletType() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get gradientJson => $_getSZ(3);
  @$pb.TagNumber(4)
  set gradientJson($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasGradientJson() => $_has(3);
  @$pb.TagNumber(4)
  void clearGradientJson() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get createdAt => $_getSZ(4);
  @$pb.TagNumber(5)
  set createdAt($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCreatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearCreatedAt() => $_clearField(5);

  /// BIP47 v3 payment code derived from the wallet's master pubkey.
  /// Deterministic per wallet, never changes. Empty for watch-only wallets.
  @$pb.TagNumber(6)
  $core.String get bip47PaymentCode => $_getSZ(5);
  @$pb.TagNumber(6)
  set bip47PaymentCode($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBip47PaymentCode() => $_has(5);
  @$pb.TagNumber(6)
  void clearBip47PaymentCode() => $_clearField(6);

  /// Starter material — populated for the starter wallet only, empty otherwise.
  /// The Starters tab and HD wallet provider read these instead of hitting a
  /// separate RPC.
  @$pb.TagNumber(7)
  $core.String get masterMnemonic => $_getSZ(6);
  @$pb.TagNumber(7)
  set masterMnemonic($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasMasterMnemonic() => $_has(6);
  @$pb.TagNumber(7)
  void clearMasterMnemonic() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get l1Mnemonic => $_getSZ(7);
  @$pb.TagNumber(8)
  set l1Mnemonic($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasL1Mnemonic() => $_has(7);
  @$pb.TagNumber(8)
  void clearL1Mnemonic() => $_clearField(8);

  @$pb.TagNumber(9)
  $pb.PbList<SidechainStarter> get sidechains => $_getList(8);

  /// Watch-only wallets track an external xpub/descriptor; no spending key.
  @$pb.TagNumber(10)
  $core.bool get watchOnly => $_getBF(9);
  @$pb.TagNumber(10)
  set watchOnly($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasWatchOnly() => $_has(9);
  @$pb.TagNumber(10)
  void clearWatchOnly() => $_clearField(10);

  /// Multisig policy, present only for multisig wallets. Cosigner private
  /// material is never exposed here — only public data and a held flag.
  @$pb.TagNumber(11)
  MultisigInfo get multisig => $_getN(10);
  @$pb.TagNumber(11)
  set multisig(MultisigInfo value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasMultisig() => $_has(10);
  @$pb.TagNumber(11)
  void clearMultisig() => $_clearField(11);
  @$pb.TagNumber(11)
  MultisigInfo ensureMultisig() => $_ensure(10);

  /// Device type and master fingerprint for a single-sig hardware wallet.
  @$pb.TagNumber(12)
  $core.String get hardwareDeviceType => $_getSZ(11);
  @$pb.TagNumber(12)
  set hardwareDeviceType($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasHardwareDeviceType() => $_has(11);
  @$pb.TagNumber(12)
  void clearHardwareDeviceType() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get hardwareFingerprint => $_getSZ(12);
  @$pb.TagNumber(13)
  set hardwareFingerprint($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasHardwareFingerprint() => $_has(12);
  @$pb.TagNumber(13)
  void clearHardwareFingerprint() => $_clearField(13);

  /// The address types this wallet derives, its own kind first. A wallet on an
  /// explicit derivation path, a watch-only wallet, and a multisig wallet each
  /// derive exactly one.
  @$pb.TagNumber(14)
  $pb.PbList<AddressType> get receiveAddressTypes => $_getList(13);

  /// True for the one wallet whose seed derives the L1 and sidechain starters.
  /// Each wallet carries its own seed, so this never moves once recorded.
  @$pb.TagNumber(15)
  $core.bool get isStarter => $_getBF(14);
  @$pb.TagNumber(15)
  set isStarter($core.bool value) => $_setBool(14, value);
  @$pb.TagNumber(15)
  $core.bool hasIsStarter() => $_has(14);
  @$pb.TagNumber(15)
  void clearIsStarter() => $_clearField(15);

  /// Key derivation of the wallet. script_type is empty for native segwit.
  /// account_index and derivation_path are exclusive; both empty is standard.
  @$pb.TagNumber(16)
  $core.String get scriptType => $_getSZ(15);
  @$pb.TagNumber(16)
  set scriptType($core.String value) => $_setString(15, value);
  @$pb.TagNumber(16)
  $core.bool hasScriptType() => $_has(15);
  @$pb.TagNumber(16)
  void clearScriptType() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.int get accountIndex => $_getIZ(16);
  @$pb.TagNumber(17)
  set accountIndex($core.int value) => $_setUnsignedInt32(16, value);
  @$pb.TagNumber(17)
  $core.bool hasAccountIndex() => $_has(16);
  @$pb.TagNumber(17)
  void clearAccountIndex() => $_clearField(17);

  @$pb.TagNumber(18)
  $core.String get derivationPath => $_getSZ(17);
  @$pb.TagNumber(18)
  set derivationPath($core.String value) => $_setString(17, value);
  @$pb.TagNumber(18)
  $core.bool hasDerivationPath() => $_has(17);
  @$pb.TagNumber(18)
  void clearDerivationPath() => $_clearField(18);
}

class MultisigInfo extends $pb.GeneratedMessage {
  factory MultisigInfo({
    $core.int? m,
    $core.int? n,
    $core.String? scriptType,
    $core.Iterable<MultisigCosignerInfo>? cosigners,
  }) {
    final result = MultisigInfo._();
    if (m != null) result.m = m;
    if (n != null) result.n = n;
    if (scriptType != null) result.scriptType = scriptType;
    if (cosigners != null) result.cosigners.addAll(cosigners);
    return result;
  }

  MultisigInfo._();

  factory MultisigInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MultisigInfo()..mergeFromBuffer(data, registry);
  factory MultisigInfo.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MultisigInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MultisigInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: MultisigInfo.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'm', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'n', fieldType: $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'scriptType')
    ..pPM<MultisigCosignerInfo>(4, _omitFieldNames ? '' : 'cosigners', subBuilder: MultisigCosignerInfo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MultisigInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MultisigInfo copyWith(void Function(MultisigInfo) updates) =>
      super.copyWith((message) => updates(message as MultisigInfo)) as MultisigInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MultisigInfo() / MultisigInfo.new instead')
  static MultisigInfo create() => MultisigInfo._();
  static $pb.GeneratedMessage $_createMessage() => MultisigInfo._();
  @$core.override
  MultisigInfo createEmptyInstance() => MultisigInfo._();
  @$core.pragma('dart2js:noInline')
  static MultisigInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MultisigInfo>(MultisigInfo.$_createMessage);
  static MultisigInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get m => $_getIZ(0);
  @$pb.TagNumber(1)
  set m($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasM() => $_has(0);
  @$pb.TagNumber(1)
  void clearM() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get n => $_getIZ(1);
  @$pb.TagNumber(2)
  set n($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasN() => $_has(1);
  @$pb.TagNumber(2)
  void clearN() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get scriptType => $_getSZ(2);
  @$pb.TagNumber(3)
  set scriptType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasScriptType() => $_has(2);
  @$pb.TagNumber(3)
  void clearScriptType() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<MultisigCosignerInfo> get cosigners => $_getList(3);
}

class MultisigCosignerInfo extends $pb.GeneratedMessage {
  factory MultisigCosignerInfo({
    $core.String? xpub,
    $core.String? fingerprint,
    $core.String? originPath,
    $core.bool? held,
    $core.String? hardwareDeviceType,
  }) {
    final result = MultisigCosignerInfo._();
    if (xpub != null) result.xpub = xpub;
    if (fingerprint != null) result.fingerprint = fingerprint;
    if (originPath != null) result.originPath = originPath;
    if (held != null) result.held = held;
    if (hardwareDeviceType != null) result.hardwareDeviceType = hardwareDeviceType;
    return result;
  }

  MultisigCosignerInfo._();

  factory MultisigCosignerInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MultisigCosignerInfo()..mergeFromBuffer(data, registry);
  factory MultisigCosignerInfo.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MultisigCosignerInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MultisigCosignerInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: MultisigCosignerInfo.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'xpub')
    ..aOS(2, _omitFieldNames ? '' : 'fingerprint')
    ..aOS(3, _omitFieldNames ? '' : 'originPath')
    ..aOB(4, _omitFieldNames ? '' : 'held')
    ..aOS(5, _omitFieldNames ? '' : 'hardwareDeviceType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MultisigCosignerInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MultisigCosignerInfo copyWith(void Function(MultisigCosignerInfo) updates) =>
      super.copyWith((message) => updates(message as MultisigCosignerInfo)) as MultisigCosignerInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MultisigCosignerInfo() / MultisigCosignerInfo.new instead')
  static MultisigCosignerInfo create() => MultisigCosignerInfo._();
  static $pb.GeneratedMessage $_createMessage() => MultisigCosignerInfo._();
  @$core.override
  MultisigCosignerInfo createEmptyInstance() => MultisigCosignerInfo._();
  @$core.pragma('dart2js:noInline')
  static MultisigCosignerInfo getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MultisigCosignerInfo>(MultisigCosignerInfo.$_createMessage);
  static MultisigCosignerInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get xpub => $_getSZ(0);
  @$pb.TagNumber(1)
  set xpub($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasXpub() => $_has(0);
  @$pb.TagNumber(1)
  void clearXpub() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fingerprint => $_getSZ(1);
  @$pb.TagNumber(2)
  set fingerprint($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFingerprint() => $_has(1);
  @$pb.TagNumber(2)
  void clearFingerprint() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get originPath => $_getSZ(2);
  @$pb.TagNumber(3)
  set originPath($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOriginPath() => $_has(2);
  @$pb.TagNumber(3)
  void clearOriginPath() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get held => $_getBF(3);
  @$pb.TagNumber(4)
  set held($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHeld() => $_has(3);
  @$pb.TagNumber(4)
  void clearHeld() => $_clearField(4);

  /// Device type when this leg signs on a USB device.
  @$pb.TagNumber(5)
  $core.String get hardwareDeviceType => $_getSZ(4);
  @$pb.TagNumber(5)
  set hardwareDeviceType($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHardwareDeviceType() => $_has(4);
  @$pb.TagNumber(5)
  void clearHardwareDeviceType() => $_clearField(5);
}

class SidechainStarter extends $pb.GeneratedMessage {
  factory SidechainStarter({
    $core.int? slot,
    $core.String? name,
    $core.String? mnemonic,
  }) {
    final result = SidechainStarter._();
    if (slot != null) result.slot = slot;
    if (name != null) result.name = name;
    if (mnemonic != null) result.mnemonic = mnemonic;
    return result;
  }

  SidechainStarter._();

  factory SidechainStarter.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SidechainStarter()..mergeFromBuffer(data, registry);
  factory SidechainStarter.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SidechainStarter()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SidechainStarter',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: SidechainStarter.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'slot')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'mnemonic')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SidechainStarter clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SidechainStarter copyWith(void Function(SidechainStarter) updates) =>
      super.copyWith((message) => updates(message as SidechainStarter)) as SidechainStarter;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SidechainStarter() / SidechainStarter.new instead')
  static SidechainStarter create() => SidechainStarter._();
  static $pb.GeneratedMessage $_createMessage() => SidechainStarter._();
  @$core.override
  SidechainStarter createEmptyInstance() => SidechainStarter._();
  @$core.pragma('dart2js:noInline')
  static SidechainStarter getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SidechainStarter>(SidechainStarter.$_createMessage);
  static SidechainStarter? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get slot => $_getIZ(0);
  @$pb.TagNumber(1)
  set slot($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSlot() => $_has(0);
  @$pb.TagNumber(1)
  void clearSlot() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get mnemonic => $_getSZ(2);
  @$pb.TagNumber(3)
  set mnemonic($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMnemonic() => $_has(2);
  @$pb.TagNumber(3)
  void clearMnemonic() => $_clearField(3);
}

class ListWalletsRequest extends $pb.GeneratedMessage {
  factory ListWalletsRequest() => ListWalletsRequest._();

  ListWalletsRequest._();

  factory ListWalletsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListWalletsRequest()..mergeFromBuffer(data, registry);
  factory ListWalletsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListWalletsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListWalletsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ListWalletsRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListWalletsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListWalletsRequest copyWith(void Function(ListWalletsRequest) updates) =>
      super.copyWith((message) => updates(message as ListWalletsRequest)) as ListWalletsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListWalletsRequest() / ListWalletsRequest.new instead')
  static ListWalletsRequest create() => ListWalletsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListWalletsRequest._();
  @$core.override
  ListWalletsRequest createEmptyInstance() => ListWalletsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListWalletsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListWalletsRequest>(ListWalletsRequest.$_createMessage);
  static ListWalletsRequest? _defaultInstance;
}

class ListWalletsResponse extends $pb.GeneratedMessage {
  factory ListWalletsResponse({
    $core.Iterable<WalletMetadata>? wallets,
    $core.String? activeWalletId,
  }) {
    final result = ListWalletsResponse._();
    if (wallets != null) result.wallets.addAll(wallets);
    if (activeWalletId != null) result.activeWalletId = activeWalletId;
    return result;
  }

  ListWalletsResponse._();

  factory ListWalletsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListWalletsResponse()..mergeFromBuffer(data, registry);
  factory ListWalletsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListWalletsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListWalletsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ListWalletsResponse.$_createMessage)
    ..pPM<WalletMetadata>(1, _omitFieldNames ? '' : 'wallets', subBuilder: WalletMetadata.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'activeWalletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListWalletsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListWalletsResponse copyWith(void Function(ListWalletsResponse) updates) =>
      super.copyWith((message) => updates(message as ListWalletsResponse)) as ListWalletsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListWalletsResponse() / ListWalletsResponse.new instead')
  static ListWalletsResponse create() => ListWalletsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListWalletsResponse._();
  @$core.override
  ListWalletsResponse createEmptyInstance() => ListWalletsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListWalletsResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListWalletsResponse>(ListWalletsResponse.$_createMessage);
  static ListWalletsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<WalletMetadata> get wallets => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get activeWalletId => $_getSZ(1);
  @$pb.TagNumber(2)
  set activeWalletId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasActiveWalletId() => $_has(1);
  @$pb.TagNumber(2)
  void clearActiveWalletId() => $_clearField(2);
}

class SwitchWalletRequest extends $pb.GeneratedMessage {
  factory SwitchWalletRequest({
    $core.String? walletId,
    $core.String? dataDir,
  }) {
    final result = SwitchWalletRequest._();
    if (walletId != null) result.walletId = walletId;
    if (dataDir != null) result.dataDir = dataDir;
    return result;
  }

  SwitchWalletRequest._();

  factory SwitchWalletRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SwitchWalletRequest()..mergeFromBuffer(data, registry);
  factory SwitchWalletRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SwitchWalletRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SwitchWalletRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: SwitchWalletRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aOS(2, _omitFieldNames ? '' : 'dataDir')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SwitchWalletRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SwitchWalletRequest copyWith(void Function(SwitchWalletRequest) updates) =>
      super.copyWith((message) => updates(message as SwitchWalletRequest)) as SwitchWalletRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SwitchWalletRequest() / SwitchWalletRequest.new instead')
  static SwitchWalletRequest create() => SwitchWalletRequest._();
  static $pb.GeneratedMessage $_createMessage() => SwitchWalletRequest._();
  @$core.override
  SwitchWalletRequest createEmptyInstance() => SwitchWalletRequest._();
  @$core.pragma('dart2js:noInline')
  static SwitchWalletRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SwitchWalletRequest>(SwitchWalletRequest.$_createMessage);
  static SwitchWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  /// The user's answer when a previous attempt reported must_select_datadir.
  @$pb.TagNumber(2)
  $core.String get dataDir => $_getSZ(1);
  @$pb.TagNumber(2)
  set dataDir($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDataDir() => $_has(1);
  @$pb.TagNumber(2)
  void clearDataDir() => $_clearField(2);
}

class SwitchWalletResponse extends $pb.GeneratedMessage {
  factory SwitchWalletResponse() => SwitchWalletResponse._();

  SwitchWalletResponse._();

  factory SwitchWalletResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SwitchWalletResponse()..mergeFromBuffer(data, registry);
  factory SwitchWalletResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SwitchWalletResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SwitchWalletResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: SwitchWalletResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SwitchWalletResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SwitchWalletResponse copyWith(void Function(SwitchWalletResponse) updates) =>
      super.copyWith((message) => updates(message as SwitchWalletResponse)) as SwitchWalletResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SwitchWalletResponse() / SwitchWalletResponse.new instead')
  static SwitchWalletResponse create() => SwitchWalletResponse._();
  static $pb.GeneratedMessage $_createMessage() => SwitchWalletResponse._();
  @$core.override
  SwitchWalletResponse createEmptyInstance() => SwitchWalletResponse._();
  @$core.pragma('dart2js:noInline')
  static SwitchWalletResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SwitchWalletResponse>(SwitchWalletResponse.$_createMessage);
  static SwitchWalletResponse? _defaultInstance;
}

class UpdateWalletMetadataRequest extends $pb.GeneratedMessage {
  factory UpdateWalletMetadataRequest({
    $core.String? walletId,
    $core.String? name,
    $core.String? gradientJson,
  }) {
    final result = UpdateWalletMetadataRequest._();
    if (walletId != null) result.walletId = walletId;
    if (name != null) result.name = name;
    if (gradientJson != null) result.gradientJson = gradientJson;
    return result;
  }

  UpdateWalletMetadataRequest._();

  factory UpdateWalletMetadataRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateWalletMetadataRequest()..mergeFromBuffer(data, registry);
  factory UpdateWalletMetadataRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateWalletMetadataRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateWalletMetadataRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: UpdateWalletMetadataRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'gradientJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateWalletMetadataRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateWalletMetadataRequest copyWith(void Function(UpdateWalletMetadataRequest) updates) =>
      super.copyWith((message) => updates(message as UpdateWalletMetadataRequest)) as UpdateWalletMetadataRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UpdateWalletMetadataRequest() / UpdateWalletMetadataRequest.new instead')
  static UpdateWalletMetadataRequest create() => UpdateWalletMetadataRequest._();
  static $pb.GeneratedMessage $_createMessage() => UpdateWalletMetadataRequest._();
  @$core.override
  UpdateWalletMetadataRequest createEmptyInstance() => UpdateWalletMetadataRequest._();
  @$core.pragma('dart2js:noInline')
  static UpdateWalletMetadataRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateWalletMetadataRequest>(UpdateWalletMetadataRequest.$_createMessage);
  static UpdateWalletMetadataRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get gradientJson => $_getSZ(2);
  @$pb.TagNumber(3)
  set gradientJson($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGradientJson() => $_has(2);
  @$pb.TagNumber(3)
  void clearGradientJson() => $_clearField(3);
}

class UpdateWalletMetadataResponse extends $pb.GeneratedMessage {
  factory UpdateWalletMetadataResponse() => UpdateWalletMetadataResponse._();

  UpdateWalletMetadataResponse._();

  factory UpdateWalletMetadataResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateWalletMetadataResponse()..mergeFromBuffer(data, registry);
  factory UpdateWalletMetadataResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UpdateWalletMetadataResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UpdateWalletMetadataResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: UpdateWalletMetadataResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateWalletMetadataResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UpdateWalletMetadataResponse copyWith(void Function(UpdateWalletMetadataResponse) updates) =>
      super.copyWith((message) => updates(message as UpdateWalletMetadataResponse)) as UpdateWalletMetadataResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UpdateWalletMetadataResponse() / UpdateWalletMetadataResponse.new instead')
  static UpdateWalletMetadataResponse create() => UpdateWalletMetadataResponse._();
  static $pb.GeneratedMessage $_createMessage() => UpdateWalletMetadataResponse._();
  @$core.override
  UpdateWalletMetadataResponse createEmptyInstance() => UpdateWalletMetadataResponse._();
  @$core.pragma('dart2js:noInline')
  static UpdateWalletMetadataResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UpdateWalletMetadataResponse>(UpdateWalletMetadataResponse.$_createMessage);
  static UpdateWalletMetadataResponse? _defaultInstance;
}

class DeleteWalletRequest extends $pb.GeneratedMessage {
  factory DeleteWalletRequest({
    $core.String? walletId,
  }) {
    final result = DeleteWalletRequest._();
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  DeleteWalletRequest._();

  factory DeleteWalletRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteWalletRequest()..mergeFromBuffer(data, registry);
  factory DeleteWalletRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteWalletRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteWalletRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: DeleteWalletRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteWalletRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteWalletRequest copyWith(void Function(DeleteWalletRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteWalletRequest)) as DeleteWalletRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DeleteWalletRequest() / DeleteWalletRequest.new instead')
  static DeleteWalletRequest create() => DeleteWalletRequest._();
  static $pb.GeneratedMessage $_createMessage() => DeleteWalletRequest._();
  @$core.override
  DeleteWalletRequest createEmptyInstance() => DeleteWalletRequest._();
  @$core.pragma('dart2js:noInline')
  static DeleteWalletRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DeleteWalletRequest>(DeleteWalletRequest.$_createMessage);
  static DeleteWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);
}

class DeleteWalletResponse extends $pb.GeneratedMessage {
  factory DeleteWalletResponse() => DeleteWalletResponse._();

  DeleteWalletResponse._();

  factory DeleteWalletResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteWalletResponse()..mergeFromBuffer(data, registry);
  factory DeleteWalletResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteWalletResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteWalletResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: DeleteWalletResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteWalletResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteWalletResponse copyWith(void Function(DeleteWalletResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteWalletResponse)) as DeleteWalletResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DeleteWalletResponse() / DeleteWalletResponse.new instead')
  static DeleteWalletResponse create() => DeleteWalletResponse._();
  static $pb.GeneratedMessage $_createMessage() => DeleteWalletResponse._();
  @$core.override
  DeleteWalletResponse createEmptyInstance() => DeleteWalletResponse._();
  @$core.pragma('dart2js:noInline')
  static DeleteWalletResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteWalletResponse>(DeleteWalletResponse.$_createMessage);
  static DeleteWalletResponse? _defaultInstance;
}

class DeleteAllWalletsRequest extends $pb.GeneratedMessage {
  factory DeleteAllWalletsRequest() => DeleteAllWalletsRequest._();

  DeleteAllWalletsRequest._();

  factory DeleteAllWalletsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteAllWalletsRequest()..mergeFromBuffer(data, registry);
  factory DeleteAllWalletsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteAllWalletsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteAllWalletsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: DeleteAllWalletsRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteAllWalletsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteAllWalletsRequest copyWith(void Function(DeleteAllWalletsRequest) updates) =>
      super.copyWith((message) => updates(message as DeleteAllWalletsRequest)) as DeleteAllWalletsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DeleteAllWalletsRequest() / DeleteAllWalletsRequest.new instead')
  static DeleteAllWalletsRequest create() => DeleteAllWalletsRequest._();
  static $pb.GeneratedMessage $_createMessage() => DeleteAllWalletsRequest._();
  @$core.override
  DeleteAllWalletsRequest createEmptyInstance() => DeleteAllWalletsRequest._();
  @$core.pragma('dart2js:noInline')
  static DeleteAllWalletsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteAllWalletsRequest>(DeleteAllWalletsRequest.$_createMessage);
  static DeleteAllWalletsRequest? _defaultInstance;
}

class DeleteAllWalletsResponse extends $pb.GeneratedMessage {
  factory DeleteAllWalletsResponse() => DeleteAllWalletsResponse._();

  DeleteAllWalletsResponse._();

  factory DeleteAllWalletsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteAllWalletsResponse()..mergeFromBuffer(data, registry);
  factory DeleteAllWalletsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeleteAllWalletsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeleteAllWalletsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: DeleteAllWalletsResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteAllWalletsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeleteAllWalletsResponse copyWith(void Function(DeleteAllWalletsResponse) updates) =>
      super.copyWith((message) => updates(message as DeleteAllWalletsResponse)) as DeleteAllWalletsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DeleteAllWalletsResponse() / DeleteAllWalletsResponse.new instead')
  static DeleteAllWalletsResponse create() => DeleteAllWalletsResponse._();
  static $pb.GeneratedMessage $_createMessage() => DeleteAllWalletsResponse._();
  @$core.override
  DeleteAllWalletsResponse createEmptyInstance() => DeleteAllWalletsResponse._();
  @$core.pragma('dart2js:noInline')
  static DeleteAllWalletsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeleteAllWalletsResponse>(DeleteAllWalletsResponse.$_createMessage);
  static DeleteAllWalletsResponse? _defaultInstance;
}

class BalanceSnapshot extends $pb.GeneratedMessage {
  factory BalanceSnapshot({
    $2.BinaryType? binary,
    $core.String? displayName,
    $fixnum.Int64? confirmedSats,
    $fixnum.Int64? pendingSats,
    $0.Timestamp? updatedAt,
  }) {
    final result = BalanceSnapshot._();
    if (binary != null) result.binary = binary;
    if (displayName != null) result.displayName = displayName;
    if (confirmedSats != null) result.confirmedSats = confirmedSats;
    if (pendingSats != null) result.pendingSats = pendingSats;
    if (updatedAt != null) result.updatedAt = updatedAt;
    return result;
  }

  BalanceSnapshot._();

  factory BalanceSnapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BalanceSnapshot()..mergeFromBuffer(data, registry);
  factory BalanceSnapshot.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BalanceSnapshot()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BalanceSnapshot',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: BalanceSnapshot.$_createMessage)
    ..aE<$2.BinaryType>(1, _omitFieldNames ? '' : 'binary', enumValues: $2.BinaryType.values)
    ..aOS(2, _omitFieldNames ? '' : 'displayName')
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'confirmedSats', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'pendingSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<$0.Timestamp>(5, _omitFieldNames ? '' : 'updatedAt', subBuilder: $0.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BalanceSnapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BalanceSnapshot copyWith(void Function(BalanceSnapshot) updates) =>
      super.copyWith((message) => updates(message as BalanceSnapshot)) as BalanceSnapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BalanceSnapshot() / BalanceSnapshot.new instead')
  static BalanceSnapshot create() => BalanceSnapshot._();
  static $pb.GeneratedMessage $_createMessage() => BalanceSnapshot._();
  @$core.override
  BalanceSnapshot createEmptyInstance() => BalanceSnapshot._();
  @$core.pragma('dart2js:noInline')
  static BalanceSnapshot getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BalanceSnapshot>(BalanceSnapshot.$_createMessage);
  static BalanceSnapshot? _defaultInstance;

  @$pb.TagNumber(1)
  $2.BinaryType get binary => $_getN(0);
  @$pb.TagNumber(1)
  set binary($2.BinaryType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasBinary() => $_has(0);
  @$pb.TagNumber(1)
  void clearBinary() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get displayName => $_getSZ(1);
  @$pb.TagNumber(2)
  set displayName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDisplayName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplayName() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get confirmedSats => $_getI64(2);
  @$pb.TagNumber(3)
  set confirmedSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasConfirmedSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearConfirmedSats() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get pendingSats => $_getI64(3);
  @$pb.TagNumber(4)
  set pendingSats($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPendingSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearPendingSats() => $_clearField(4);

  @$pb.TagNumber(5)
  $0.Timestamp get updatedAt => $_getN(4);
  @$pb.TagNumber(5)
  set updatedAt($0.Timestamp value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasUpdatedAt() => $_has(4);
  @$pb.TagNumber(5)
  void clearUpdatedAt() => $_clearField(5);
  @$pb.TagNumber(5)
  $0.Timestamp ensureUpdatedAt() => $_ensure(4);
}

class BackupWalletSummary extends $pb.GeneratedMessage {
  factory BackupWalletSummary({
    $core.String? id,
    $core.String? name,
    $core.String? walletType,
  }) {
    final result = BackupWalletSummary._();
    if (id != null) result.id = id;
    if (name != null) result.name = name;
    if (walletType != null) result.walletType = walletType;
    return result;
  }

  BackupWalletSummary._();

  factory BackupWalletSummary.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BackupWalletSummary()..mergeFromBuffer(data, registry);
  factory BackupWalletSummary.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BackupWalletSummary()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BackupWalletSummary',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: BackupWalletSummary.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOS(3, _omitFieldNames ? '' : 'walletType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BackupWalletSummary clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BackupWalletSummary copyWith(void Function(BackupWalletSummary) updates) =>
      super.copyWith((message) => updates(message as BackupWalletSummary)) as BackupWalletSummary;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BackupWalletSummary() / BackupWalletSummary.new instead')
  static BackupWalletSummary create() => BackupWalletSummary._();
  static $pb.GeneratedMessage $_createMessage() => BackupWalletSummary._();
  @$core.override
  BackupWalletSummary createEmptyInstance() => BackupWalletSummary._();
  @$core.pragma('dart2js:noInline')
  static BackupWalletSummary getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BackupWalletSummary>(BackupWalletSummary.$_createMessage);
  static BackupWalletSummary? _defaultInstance;

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
  $core.String get walletType => $_getSZ(2);
  @$pb.TagNumber(3)
  set walletType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWalletType() => $_has(2);
  @$pb.TagNumber(3)
  void clearWalletType() => $_clearField(3);
}

class WalletBackup extends $pb.GeneratedMessage {
  factory WalletBackup({
    $core.String? backupId,
    $0.Timestamp? createdAt,
    $core.String? sourceName,
    $core.bool? encrypted,
    $core.bool? hasMetadata,
    $core.String? activeWalletId,
    $core.Iterable<BackupWalletSummary>? wallets,
    $core.Iterable<BalanceSnapshot>? latestKnownBalance,
    $core.bool? valid,
    $core.String? errorMessage,
  }) {
    final result = WalletBackup._();
    if (backupId != null) result.backupId = backupId;
    if (createdAt != null) result.createdAt = createdAt;
    if (sourceName != null) result.sourceName = sourceName;
    if (encrypted != null) result.encrypted = encrypted;
    if (hasMetadata != null) result.hasMetadata = hasMetadata;
    if (activeWalletId != null) result.activeWalletId = activeWalletId;
    if (wallets != null) result.wallets.addAll(wallets);
    if (latestKnownBalance != null) result.latestKnownBalance.addAll(latestKnownBalance);
    if (valid != null) result.valid = valid;
    if (errorMessage != null) result.errorMessage = errorMessage;
    return result;
  }

  WalletBackup._();

  factory WalletBackup.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WalletBackup()..mergeFromBuffer(data, registry);
  factory WalletBackup.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WalletBackup()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WalletBackup',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: WalletBackup.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'backupId')
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'createdAt', subBuilder: $0.Timestamp.$_createMessage)
    ..aOS(3, _omitFieldNames ? '' : 'sourceName')
    ..aOB(4, _omitFieldNames ? '' : 'encrypted')
    ..aOB(5, _omitFieldNames ? '' : 'hasMetadata')
    ..aOS(6, _omitFieldNames ? '' : 'activeWalletId')
    ..pPM<BackupWalletSummary>(7, _omitFieldNames ? '' : 'wallets', subBuilder: BackupWalletSummary.$_createMessage)
    ..pPM<BalanceSnapshot>(8, _omitFieldNames ? '' : 'latestKnownBalance', subBuilder: BalanceSnapshot.$_createMessage)
    ..aOB(9, _omitFieldNames ? '' : 'valid')
    ..aOS(10, _omitFieldNames ? '' : 'errorMessage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WalletBackup clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WalletBackup copyWith(void Function(WalletBackup) updates) =>
      super.copyWith((message) => updates(message as WalletBackup)) as WalletBackup;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WalletBackup() / WalletBackup.new instead')
  static WalletBackup create() => WalletBackup._();
  static $pb.GeneratedMessage $_createMessage() => WalletBackup._();
  @$core.override
  WalletBackup createEmptyInstance() => WalletBackup._();
  @$core.pragma('dart2js:noInline')
  static WalletBackup getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WalletBackup>(WalletBackup.$_createMessage);
  static WalletBackup? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get backupId => $_getSZ(0);
  @$pb.TagNumber(1)
  set backupId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBackupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearBackupId() => $_clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get createdAt => $_getN(1);
  @$pb.TagNumber(2)
  set createdAt($0.Timestamp value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasCreatedAt() => $_has(1);
  @$pb.TagNumber(2)
  void clearCreatedAt() => $_clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureCreatedAt() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get sourceName => $_getSZ(2);
  @$pb.TagNumber(3)
  set sourceName($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSourceName() => $_has(2);
  @$pb.TagNumber(3)
  void clearSourceName() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get encrypted => $_getBF(3);
  @$pb.TagNumber(4)
  set encrypted($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasEncrypted() => $_has(3);
  @$pb.TagNumber(4)
  void clearEncrypted() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.bool get hasMetadata => $_getBF(4);
  @$pb.TagNumber(5)
  set hasMetadata($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHasMetadata() => $_has(4);
  @$pb.TagNumber(5)
  void clearHasMetadata() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get activeWalletId => $_getSZ(5);
  @$pb.TagNumber(6)
  set activeWalletId($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasActiveWalletId() => $_has(5);
  @$pb.TagNumber(6)
  void clearActiveWalletId() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<BackupWalletSummary> get wallets => $_getList(6);

  @$pb.TagNumber(8)
  $pb.PbList<BalanceSnapshot> get latestKnownBalance => $_getList(7);

  @$pb.TagNumber(9)
  $core.bool get valid => $_getBF(8);
  @$pb.TagNumber(9)
  set valid($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasValid() => $_has(8);
  @$pb.TagNumber(9)
  void clearValid() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get errorMessage => $_getSZ(9);
  @$pb.TagNumber(10)
  set errorMessage($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasErrorMessage() => $_has(9);
  @$pb.TagNumber(10)
  void clearErrorMessage() => $_clearField(10);
}

class ListWalletBackupsRequest extends $pb.GeneratedMessage {
  factory ListWalletBackupsRequest() => ListWalletBackupsRequest._();

  ListWalletBackupsRequest._();

  factory ListWalletBackupsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListWalletBackupsRequest()..mergeFromBuffer(data, registry);
  factory ListWalletBackupsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListWalletBackupsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListWalletBackupsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ListWalletBackupsRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListWalletBackupsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListWalletBackupsRequest copyWith(void Function(ListWalletBackupsRequest) updates) =>
      super.copyWith((message) => updates(message as ListWalletBackupsRequest)) as ListWalletBackupsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListWalletBackupsRequest() / ListWalletBackupsRequest.new instead')
  static ListWalletBackupsRequest create() => ListWalletBackupsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListWalletBackupsRequest._();
  @$core.override
  ListWalletBackupsRequest createEmptyInstance() => ListWalletBackupsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListWalletBackupsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListWalletBackupsRequest>(ListWalletBackupsRequest.$_createMessage);
  static ListWalletBackupsRequest? _defaultInstance;
}

class ListWalletBackupsResponse extends $pb.GeneratedMessage {
  factory ListWalletBackupsResponse({
    $core.Iterable<WalletBackup>? backups,
  }) {
    final result = ListWalletBackupsResponse._();
    if (backups != null) result.backups.addAll(backups);
    return result;
  }

  ListWalletBackupsResponse._();

  factory ListWalletBackupsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListWalletBackupsResponse()..mergeFromBuffer(data, registry);
  factory ListWalletBackupsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListWalletBackupsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListWalletBackupsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ListWalletBackupsResponse.$_createMessage)
    ..pPM<WalletBackup>(1, _omitFieldNames ? '' : 'backups', subBuilder: WalletBackup.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListWalletBackupsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListWalletBackupsResponse copyWith(void Function(ListWalletBackupsResponse) updates) =>
      super.copyWith((message) => updates(message as ListWalletBackupsResponse)) as ListWalletBackupsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListWalletBackupsResponse() / ListWalletBackupsResponse.new instead')
  static ListWalletBackupsResponse create() => ListWalletBackupsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListWalletBackupsResponse._();
  @$core.override
  ListWalletBackupsResponse createEmptyInstance() => ListWalletBackupsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListWalletBackupsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListWalletBackupsResponse>(ListWalletBackupsResponse.$_createMessage);
  static ListWalletBackupsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<WalletBackup> get backups => $_getList(0);
}

class RestoreWalletBackupRequest extends $pb.GeneratedMessage {
  factory RestoreWalletBackupRequest({
    $core.String? backupId,
    $core.String? password,
  }) {
    final result = RestoreWalletBackupRequest._();
    if (backupId != null) result.backupId = backupId;
    if (password != null) result.password = password;
    return result;
  }

  RestoreWalletBackupRequest._();

  factory RestoreWalletBackupRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RestoreWalletBackupRequest()..mergeFromBuffer(data, registry);
  factory RestoreWalletBackupRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RestoreWalletBackupRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RestoreWalletBackupRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: RestoreWalletBackupRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'backupId')
    ..aOS(2, _omitFieldNames ? '' : 'password')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestoreWalletBackupRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestoreWalletBackupRequest copyWith(void Function(RestoreWalletBackupRequest) updates) =>
      super.copyWith((message) => updates(message as RestoreWalletBackupRequest)) as RestoreWalletBackupRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RestoreWalletBackupRequest() / RestoreWalletBackupRequest.new instead')
  static RestoreWalletBackupRequest create() => RestoreWalletBackupRequest._();
  static $pb.GeneratedMessage $_createMessage() => RestoreWalletBackupRequest._();
  @$core.override
  RestoreWalletBackupRequest createEmptyInstance() => RestoreWalletBackupRequest._();
  @$core.pragma('dart2js:noInline')
  static RestoreWalletBackupRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RestoreWalletBackupRequest>(RestoreWalletBackupRequest.$_createMessage);
  static RestoreWalletBackupRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get backupId => $_getSZ(0);
  @$pb.TagNumber(1)
  set backupId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBackupId() => $_has(0);
  @$pb.TagNumber(1)
  void clearBackupId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get password => $_getSZ(1);
  @$pb.TagNumber(2)
  set password($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPassword() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassword() => $_clearField(2);
}

class RestoreWalletBackupResponse extends $pb.GeneratedMessage {
  factory RestoreWalletBackupResponse() => RestoreWalletBackupResponse._();

  RestoreWalletBackupResponse._();

  factory RestoreWalletBackupResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RestoreWalletBackupResponse()..mergeFromBuffer(data, registry);
  factory RestoreWalletBackupResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RestoreWalletBackupResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RestoreWalletBackupResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: RestoreWalletBackupResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestoreWalletBackupResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestoreWalletBackupResponse copyWith(void Function(RestoreWalletBackupResponse) updates) =>
      super.copyWith((message) => updates(message as RestoreWalletBackupResponse)) as RestoreWalletBackupResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RestoreWalletBackupResponse() / RestoreWalletBackupResponse.new instead')
  static RestoreWalletBackupResponse create() => RestoreWalletBackupResponse._();
  static $pb.GeneratedMessage $_createMessage() => RestoreWalletBackupResponse._();
  @$core.override
  RestoreWalletBackupResponse createEmptyInstance() => RestoreWalletBackupResponse._();
  @$core.pragma('dart2js:noInline')
  static RestoreWalletBackupResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RestoreWalletBackupResponse>(RestoreWalletBackupResponse.$_createMessage);
  static RestoreWalletBackupResponse? _defaultInstance;
}

class RestoreWalletBackupStep extends $pb.GeneratedMessage {
  factory RestoreWalletBackupStep({
    $core.String? stepId,
    $core.String? name,
  }) {
    final result = RestoreWalletBackupStep._();
    if (stepId != null) result.stepId = stepId;
    if (name != null) result.name = name;
    return result;
  }

  RestoreWalletBackupStep._();

  factory RestoreWalletBackupStep.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RestoreWalletBackupStep()..mergeFromBuffer(data, registry);
  factory RestoreWalletBackupStep.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RestoreWalletBackupStep()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RestoreWalletBackupStep',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: RestoreWalletBackupStep.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'stepId')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestoreWalletBackupStep clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestoreWalletBackupStep copyWith(void Function(RestoreWalletBackupStep) updates) =>
      super.copyWith((message) => updates(message as RestoreWalletBackupStep)) as RestoreWalletBackupStep;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RestoreWalletBackupStep() / RestoreWalletBackupStep.new instead')
  static RestoreWalletBackupStep create() => RestoreWalletBackupStep._();
  static $pb.GeneratedMessage $_createMessage() => RestoreWalletBackupStep._();
  @$core.override
  RestoreWalletBackupStep createEmptyInstance() => RestoreWalletBackupStep._();
  @$core.pragma('dart2js:noInline')
  static RestoreWalletBackupStep getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RestoreWalletBackupStep>(RestoreWalletBackupStep.$_createMessage);
  static RestoreWalletBackupStep? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get stepId => $_getSZ(0);
  @$pb.TagNumber(1)
  set stepId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStepId() => $_has(0);
  @$pb.TagNumber(1)
  void clearStepId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);
}

class RestoreWalletBackupProgressStatus extends $pb.GeneratedMessage {
  factory RestoreWalletBackupProgressStatus({
    $core.String? stepId,
    RestoreWalletBackupStepState? state,
    $core.String? error,
    $core.bool? complete,
  }) {
    final result = RestoreWalletBackupProgressStatus._();
    if (stepId != null) result.stepId = stepId;
    if (state != null) result.state = state;
    if (error != null) result.error = error;
    if (complete != null) result.complete = complete;
    return result;
  }

  RestoreWalletBackupProgressStatus._();

  factory RestoreWalletBackupProgressStatus.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RestoreWalletBackupProgressStatus()..mergeFromBuffer(data, registry);
  factory RestoreWalletBackupProgressStatus.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RestoreWalletBackupProgressStatus()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RestoreWalletBackupProgressStatus',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: RestoreWalletBackupProgressStatus.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'stepId')
    ..aE<RestoreWalletBackupStepState>(2, _omitFieldNames ? '' : 'state',
        enumValues: RestoreWalletBackupStepState.values)
    ..aOS(3, _omitFieldNames ? '' : 'error')
    ..aOB(4, _omitFieldNames ? '' : 'complete')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestoreWalletBackupProgressStatus clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestoreWalletBackupProgressStatus copyWith(void Function(RestoreWalletBackupProgressStatus) updates) =>
      super.copyWith((message) => updates(message as RestoreWalletBackupProgressStatus))
          as RestoreWalletBackupProgressStatus;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RestoreWalletBackupProgressStatus() / RestoreWalletBackupProgressStatus.new instead')
  static RestoreWalletBackupProgressStatus create() => RestoreWalletBackupProgressStatus._();
  static $pb.GeneratedMessage $_createMessage() => RestoreWalletBackupProgressStatus._();
  @$core.override
  RestoreWalletBackupProgressStatus createEmptyInstance() => RestoreWalletBackupProgressStatus._();
  @$core.pragma('dart2js:noInline')
  static RestoreWalletBackupProgressStatus getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RestoreWalletBackupProgressStatus>(
          RestoreWalletBackupProgressStatus.$_createMessage);
  static RestoreWalletBackupProgressStatus? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get stepId => $_getSZ(0);
  @$pb.TagNumber(1)
  set stepId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasStepId() => $_has(0);
  @$pb.TagNumber(1)
  void clearStepId() => $_clearField(1);

  @$pb.TagNumber(2)
  RestoreWalletBackupStepState get state => $_getN(1);
  @$pb.TagNumber(2)
  set state(RestoreWalletBackupStepState value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasState() => $_has(1);
  @$pb.TagNumber(2)
  void clearState() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get error => $_getSZ(2);
  @$pb.TagNumber(3)
  set error($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasError() => $_has(2);
  @$pb.TagNumber(3)
  void clearError() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get complete => $_getBF(3);
  @$pb.TagNumber(4)
  set complete($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasComplete() => $_has(3);
  @$pb.TagNumber(4)
  void clearComplete() => $_clearField(4);
}

class RestoreWalletBackupProgressResponse extends $pb.GeneratedMessage {
  factory RestoreWalletBackupProgressResponse({
    $core.Iterable<RestoreWalletBackupStep>? steps,
    RestoreWalletBackupProgressStatus? status,
  }) {
    final result = RestoreWalletBackupProgressResponse._();
    if (steps != null) result.steps.addAll(steps);
    if (status != null) result.status = status;
    return result;
  }

  RestoreWalletBackupProgressResponse._();

  factory RestoreWalletBackupProgressResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RestoreWalletBackupProgressResponse()..mergeFromBuffer(data, registry);
  factory RestoreWalletBackupProgressResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RestoreWalletBackupProgressResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RestoreWalletBackupProgressResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: RestoreWalletBackupProgressResponse.$_createMessage)
    ..pPM<RestoreWalletBackupStep>(1, _omitFieldNames ? '' : 'steps',
        subBuilder: RestoreWalletBackupStep.$_createMessage)
    ..aOM<RestoreWalletBackupProgressStatus>(2, _omitFieldNames ? '' : 'status',
        subBuilder: RestoreWalletBackupProgressStatus.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestoreWalletBackupProgressResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RestoreWalletBackupProgressResponse copyWith(void Function(RestoreWalletBackupProgressResponse) updates) =>
      super.copyWith((message) => updates(message as RestoreWalletBackupProgressResponse))
          as RestoreWalletBackupProgressResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RestoreWalletBackupProgressResponse() / RestoreWalletBackupProgressResponse.new instead')
  static RestoreWalletBackupProgressResponse create() => RestoreWalletBackupProgressResponse._();
  static $pb.GeneratedMessage $_createMessage() => RestoreWalletBackupProgressResponse._();
  @$core.override
  RestoreWalletBackupProgressResponse createEmptyInstance() => RestoreWalletBackupProgressResponse._();
  @$core.pragma('dart2js:noInline')
  static RestoreWalletBackupProgressResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RestoreWalletBackupProgressResponse>(
          RestoreWalletBackupProgressResponse.$_createMessage);
  static RestoreWalletBackupProgressResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<RestoreWalletBackupStep> get steps => $_getList(0);

  @$pb.TagNumber(2)
  RestoreWalletBackupProgressStatus get status => $_getN(1);
  @$pb.TagNumber(2)
  set status(RestoreWalletBackupProgressStatus value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasStatus() => $_has(1);
  @$pb.TagNumber(2)
  void clearStatus() => $_clearField(2);
  @$pb.TagNumber(2)
  RestoreWalletBackupProgressStatus ensureStatus() => $_ensure(1);
}

class CreateWatchOnlyWalletRequest extends $pb.GeneratedMessage {
  factory CreateWatchOnlyWalletRequest({
    $core.String? name,
    $core.String? xpubOrDescriptor,
    $core.String? gradientJson,
  }) {
    final result = CreateWatchOnlyWalletRequest._();
    if (name != null) result.name = name;
    if (xpubOrDescriptor != null) result.xpubOrDescriptor = xpubOrDescriptor;
    if (gradientJson != null) result.gradientJson = gradientJson;
    return result;
  }

  CreateWatchOnlyWalletRequest._();

  factory CreateWatchOnlyWalletRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateWatchOnlyWalletRequest()..mergeFromBuffer(data, registry);
  factory CreateWatchOnlyWalletRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateWatchOnlyWalletRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateWatchOnlyWalletRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: CreateWatchOnlyWalletRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'xpubOrDescriptor')
    ..aOS(3, _omitFieldNames ? '' : 'gradientJson')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateWatchOnlyWalletRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateWatchOnlyWalletRequest copyWith(void Function(CreateWatchOnlyWalletRequest) updates) =>
      super.copyWith((message) => updates(message as CreateWatchOnlyWalletRequest)) as CreateWatchOnlyWalletRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateWatchOnlyWalletRequest() / CreateWatchOnlyWalletRequest.new instead')
  static CreateWatchOnlyWalletRequest create() => CreateWatchOnlyWalletRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateWatchOnlyWalletRequest._();
  @$core.override
  CreateWatchOnlyWalletRequest createEmptyInstance() => CreateWatchOnlyWalletRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateWatchOnlyWalletRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateWatchOnlyWalletRequest>(CreateWatchOnlyWalletRequest.$_createMessage);
  static CreateWatchOnlyWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get xpubOrDescriptor => $_getSZ(1);
  @$pb.TagNumber(2)
  set xpubOrDescriptor($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasXpubOrDescriptor() => $_has(1);
  @$pb.TagNumber(2)
  void clearXpubOrDescriptor() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get gradientJson => $_getSZ(2);
  @$pb.TagNumber(3)
  set gradientJson($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasGradientJson() => $_has(2);
  @$pb.TagNumber(3)
  void clearGradientJson() => $_clearField(3);
}

class CreateWatchOnlyWalletResponse extends $pb.GeneratedMessage {
  factory CreateWatchOnlyWalletResponse({
    $core.String? walletId,
  }) {
    final result = CreateWatchOnlyWalletResponse._();
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  CreateWatchOnlyWalletResponse._();

  factory CreateWatchOnlyWalletResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateWatchOnlyWalletResponse()..mergeFromBuffer(data, registry);
  factory CreateWatchOnlyWalletResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateWatchOnlyWalletResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateWatchOnlyWalletResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: CreateWatchOnlyWalletResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateWatchOnlyWalletResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateWatchOnlyWalletResponse copyWith(void Function(CreateWatchOnlyWalletResponse) updates) =>
      super.copyWith((message) => updates(message as CreateWatchOnlyWalletResponse)) as CreateWatchOnlyWalletResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateWatchOnlyWalletResponse() / CreateWatchOnlyWalletResponse.new instead')
  static CreateWatchOnlyWalletResponse create() => CreateWatchOnlyWalletResponse._();
  static $pb.GeneratedMessage $_createMessage() => CreateWatchOnlyWalletResponse._();
  @$core.override
  CreateWatchOnlyWalletResponse createEmptyInstance() => CreateWatchOnlyWalletResponse._();
  @$core.pragma('dart2js:noInline')
  static CreateWatchOnlyWalletResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateWatchOnlyWalletResponse>(CreateWatchOnlyWalletResponse.$_createMessage);
  static CreateWatchOnlyWalletResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);
}

class CreateElectrumWalletRequest extends $pb.GeneratedMessage {
  factory CreateElectrumWalletRequest({
    $core.String? name,
    $core.String? gradientJson,
    $core.Iterable<$core.int>? slots,
    $core.String? customMnemonic,
    $core.String? xpubOrDescriptor,
    $core.String? scriptType,
    $core.int? account,
    $core.String? derivationPath,
    $core.String? hardwareDeviceType,
    $core.String? hardwareFingerprint,
    $core.String? passphrase,
    $core.String? privateDescriptor,
  }) {
    final result = CreateElectrumWalletRequest._();
    if (name != null) result.name = name;
    if (gradientJson != null) result.gradientJson = gradientJson;
    if (slots != null) result.slots.addAll(slots);
    if (customMnemonic != null) result.customMnemonic = customMnemonic;
    if (xpubOrDescriptor != null) result.xpubOrDescriptor = xpubOrDescriptor;
    if (scriptType != null) result.scriptType = scriptType;
    if (account != null) result.account = account;
    if (derivationPath != null) result.derivationPath = derivationPath;
    if (hardwareDeviceType != null) result.hardwareDeviceType = hardwareDeviceType;
    if (hardwareFingerprint != null) result.hardwareFingerprint = hardwareFingerprint;
    if (passphrase != null) result.passphrase = passphrase;
    if (privateDescriptor != null) result.privateDescriptor = privateDescriptor;
    return result;
  }

  CreateElectrumWalletRequest._();

  factory CreateElectrumWalletRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateElectrumWalletRequest()..mergeFromBuffer(data, registry);
  factory CreateElectrumWalletRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateElectrumWalletRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateElectrumWalletRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: CreateElectrumWalletRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'gradientJson')
    ..p<$core.int>(3, _omitFieldNames ? '' : 'slots', $pb.PbFieldType.KU3)
    ..aOS(4, _omitFieldNames ? '' : 'customMnemonic')
    ..aOS(5, _omitFieldNames ? '' : 'xpubOrDescriptor')
    ..aOS(6, _omitFieldNames ? '' : 'scriptType')
    ..aI(7, _omitFieldNames ? '' : 'account', fieldType: $pb.PbFieldType.OU3)
    ..aOS(8, _omitFieldNames ? '' : 'derivationPath')
    ..aOS(9, _omitFieldNames ? '' : 'hardwareDeviceType')
    ..aOS(10, _omitFieldNames ? '' : 'hardwareFingerprint')
    ..aOS(11, _omitFieldNames ? '' : 'passphrase')
    ..aOS(12, _omitFieldNames ? '' : 'privateDescriptor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateElectrumWalletRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateElectrumWalletRequest copyWith(void Function(CreateElectrumWalletRequest) updates) =>
      super.copyWith((message) => updates(message as CreateElectrumWalletRequest)) as CreateElectrumWalletRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateElectrumWalletRequest() / CreateElectrumWalletRequest.new instead')
  static CreateElectrumWalletRequest create() => CreateElectrumWalletRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateElectrumWalletRequest._();
  @$core.override
  CreateElectrumWalletRequest createEmptyInstance() => CreateElectrumWalletRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateElectrumWalletRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateElectrumWalletRequest>(CreateElectrumWalletRequest.$_createMessage);
  static CreateElectrumWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get gradientJson => $_getSZ(1);
  @$pb.TagNumber(2)
  set gradientJson($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGradientJson() => $_has(1);
  @$pb.TagNumber(2)
  void clearGradientJson() => $_clearField(2);

  /// Optional sidechain slots to provision starter material for. Empty = all.
  @$pb.TagNumber(3)
  $pb.PbList<$core.int> get slots => $_getList(2);

  /// Optional BIP39 mnemonic to import an existing seed. Empty = generate a
  /// new seed. Mutually exclusive with xpub_or_descriptor.
  @$pb.TagNumber(4)
  $core.String get customMnemonic => $_getSZ(3);
  @$pb.TagNumber(4)
  set customMnemonic($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCustomMnemonic() => $_has(3);
  @$pb.TagNumber(4)
  void clearCustomMnemonic() => $_clearField(4);

  /// Optional xpub or output descriptor for a watch-only electrum wallet
  /// (no private keys; cannot sign or send). Mutually exclusive with
  /// custom_mnemonic.
  @$pb.TagNumber(5)
  $core.String get xpubOrDescriptor => $_getSZ(4);
  @$pb.TagNumber(5)
  set xpubOrDescriptor($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasXpubOrDescriptor() => $_has(4);
  @$pb.TagNumber(5)
  void clearXpubOrDescriptor() => $_clearField(5);

  /// Address type: "legacy", "nested-segwit", "native-segwit" (default), or
  /// "taproot". A watch-only import uses it only for a bare extended key, which
  /// states no type of its own; a script wrapper, a SLIP-0132 header and an
  /// origin path's purpose all win over it.
  @$pb.TagNumber(6)
  $core.String get scriptType => $_getSZ(5);
  @$pb.TagNumber(6)
  set scriptType($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasScriptType() => $_has(5);
  @$pb.TagNumber(6)
  void clearScriptType() => $_clearField(6);

  /// Optional BIP32 account index for the account-level key. 0 = standard.
  /// Ignored when derivation_path set or for watch-only imports.
  @$pb.TagNumber(7)
  $core.int get account => $_getIZ(6);
  @$pb.TagNumber(7)
  set account($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAccount() => $_has(6);
  @$pb.TagNumber(7)
  void clearAccount() => $_clearField(7);

  /// Optional full account-level derivation path (e.g. "m/84'/0'/3'"),
  /// overriding purpose/coin/account. Empty = default. All three levels must be
  /// hardened. Ignored for watch-only imports.
  @$pb.TagNumber(8)
  $core.String get derivationPath => $_getSZ(7);
  @$pb.TagNumber(8)
  set derivationPath($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDerivationPath() => $_has(7);
  @$pb.TagNumber(8)
  void clearDerivationPath() => $_clearField(8);

  /// Device type and master fingerprint when importing a hardware wallet.
  @$pb.TagNumber(9)
  $core.String get hardwareDeviceType => $_getSZ(8);
  @$pb.TagNumber(9)
  set hardwareDeviceType($core.String value) => $_setString(8, value);
  @$pb.TagNumber(9)
  $core.bool hasHardwareDeviceType() => $_has(8);
  @$pb.TagNumber(9)
  void clearHardwareDeviceType() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get hardwareFingerprint => $_getSZ(9);
  @$pb.TagNumber(10)
  set hardwareFingerprint($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasHardwareFingerprint() => $_has(9);
  @$pb.TagNumber(10)
  void clearHardwareFingerprint() => $_clearField(10);

  /// Optional BIP39 passphrase applied to custom_mnemonic. Ignored for
  /// watch-only imports.
  @$pb.TagNumber(11)
  $core.String get passphrase => $_getSZ(10);
  @$pb.TagNumber(11)
  set passphrase($core.String value) => $_setString(10, value);
  @$pb.TagNumber(11)
  $core.bool hasPassphrase() => $_has(10);
  @$pb.TagNumber(11)
  void clearPassphrase() => $_clearField(11);

  /// Optional single-sig output descriptor that holds an account xprv. The
  /// wallet keeps the key and can sign. Mutually exclusive with the other keys.
  @$pb.TagNumber(12)
  $core.String get privateDescriptor => $_getSZ(11);
  @$pb.TagNumber(12)
  set privateDescriptor($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasPrivateDescriptor() => $_has(11);
  @$pb.TagNumber(12)
  void clearPrivateDescriptor() => $_clearField(12);
}

class CreateElectrumWalletResponse extends $pb.GeneratedMessage {
  factory CreateElectrumWalletResponse({
    $core.String? walletId,
  }) {
    final result = CreateElectrumWalletResponse._();
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  CreateElectrumWalletResponse._();

  factory CreateElectrumWalletResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateElectrumWalletResponse()..mergeFromBuffer(data, registry);
  factory CreateElectrumWalletResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateElectrumWalletResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateElectrumWalletResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: CreateElectrumWalletResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateElectrumWalletResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateElectrumWalletResponse copyWith(void Function(CreateElectrumWalletResponse) updates) =>
      super.copyWith((message) => updates(message as CreateElectrumWalletResponse)) as CreateElectrumWalletResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateElectrumWalletResponse() / CreateElectrumWalletResponse.new instead')
  static CreateElectrumWalletResponse create() => CreateElectrumWalletResponse._();
  static $pb.GeneratedMessage $_createMessage() => CreateElectrumWalletResponse._();
  @$core.override
  CreateElectrumWalletResponse createEmptyInstance() => CreateElectrumWalletResponse._();
  @$core.pragma('dart2js:noInline')
  static CreateElectrumWalletResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateElectrumWalletResponse>(CreateElectrumWalletResponse.$_createMessage);
  static CreateElectrumWalletResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);
}

/// MultisigCosignerInput is one leg of a multisig wallet. A cosigner with a
/// mnemonic or xprv is held on disk (this wallet signs with it); one with only
/// an xpub is a watch-only leg signed elsewhere.
class MultisigCosignerInput extends $pb.GeneratedMessage {
  factory MultisigCosignerInput({
    $core.String? xpub,
    $core.String? originPath,
    $core.String? fingerprint,
    $core.String? mnemonic,
    $core.String? xprv,
    $core.String? passphrase,
    $core.String? hardwareDeviceType,
  }) {
    final result = MultisigCosignerInput._();
    if (xpub != null) result.xpub = xpub;
    if (originPath != null) result.originPath = originPath;
    if (fingerprint != null) result.fingerprint = fingerprint;
    if (mnemonic != null) result.mnemonic = mnemonic;
    if (xprv != null) result.xprv = xprv;
    if (passphrase != null) result.passphrase = passphrase;
    if (hardwareDeviceType != null) result.hardwareDeviceType = hardwareDeviceType;
    return result;
  }

  MultisigCosignerInput._();

  factory MultisigCosignerInput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MultisigCosignerInput()..mergeFromBuffer(data, registry);
  factory MultisigCosignerInput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MultisigCosignerInput()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MultisigCosignerInput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: MultisigCosignerInput.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'xpub')
    ..aOS(2, _omitFieldNames ? '' : 'originPath')
    ..aOS(3, _omitFieldNames ? '' : 'fingerprint')
    ..aOS(4, _omitFieldNames ? '' : 'mnemonic')
    ..aOS(5, _omitFieldNames ? '' : 'xprv')
    ..aOS(6, _omitFieldNames ? '' : 'passphrase')
    ..aOS(7, _omitFieldNames ? '' : 'hardwareDeviceType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MultisigCosignerInput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MultisigCosignerInput copyWith(void Function(MultisigCosignerInput) updates) =>
      super.copyWith((message) => updates(message as MultisigCosignerInput)) as MultisigCosignerInput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MultisigCosignerInput() / MultisigCosignerInput.new instead')
  static MultisigCosignerInput create() => MultisigCosignerInput._();
  static $pb.GeneratedMessage $_createMessage() => MultisigCosignerInput._();
  @$core.override
  MultisigCosignerInput createEmptyInstance() => MultisigCosignerInput._();
  @$core.pragma('dart2js:noInline')
  static MultisigCosignerInput getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MultisigCosignerInput>(MultisigCosignerInput.$_createMessage);
  static MultisigCosignerInput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get xpub => $_getSZ(0);
  @$pb.TagNumber(1)
  set xpub($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasXpub() => $_has(0);
  @$pb.TagNumber(1)
  void clearXpub() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get originPath => $_getSZ(1);
  @$pb.TagNumber(2)
  set originPath($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOriginPath() => $_has(1);
  @$pb.TagNumber(2)
  void clearOriginPath() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fingerprint => $_getSZ(2);
  @$pb.TagNumber(3)
  set fingerprint($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFingerprint() => $_has(2);
  @$pb.TagNumber(3)
  void clearFingerprint() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get mnemonic => $_getSZ(3);
  @$pb.TagNumber(4)
  set mnemonic($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMnemonic() => $_has(3);
  @$pb.TagNumber(4)
  void clearMnemonic() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get xprv => $_getSZ(4);
  @$pb.TagNumber(5)
  set xprv($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasXprv() => $_has(4);
  @$pb.TagNumber(5)
  void clearXprv() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get passphrase => $_getSZ(5);
  @$pb.TagNumber(6)
  set passphrase($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasPassphrase() => $_has(5);
  @$pb.TagNumber(6)
  void clearPassphrase() => $_clearField(6);

  /// Device type ("trezor", "ledger", ...) when this leg signs on a USB device.
  @$pb.TagNumber(7)
  $core.String get hardwareDeviceType => $_getSZ(6);
  @$pb.TagNumber(7)
  set hardwareDeviceType($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasHardwareDeviceType() => $_has(6);
  @$pb.TagNumber(7)
  void clearHardwareDeviceType() => $_clearField(7);
}

class CreateMultisigWalletRequest extends $pb.GeneratedMessage {
  factory CreateMultisigWalletRequest({
    $core.String? name,
    $core.String? gradientJson,
    $core.int? m,
    $core.int? n,
    $core.String? scriptType,
    $core.Iterable<MultisigCosignerInput>? cosigners,
  }) {
    final result = CreateMultisigWalletRequest._();
    if (name != null) result.name = name;
    if (gradientJson != null) result.gradientJson = gradientJson;
    if (m != null) result.m = m;
    if (n != null) result.n = n;
    if (scriptType != null) result.scriptType = scriptType;
    if (cosigners != null) result.cosigners.addAll(cosigners);
    return result;
  }

  CreateMultisigWalletRequest._();

  factory CreateMultisigWalletRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateMultisigWalletRequest()..mergeFromBuffer(data, registry);
  factory CreateMultisigWalletRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateMultisigWalletRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateMultisigWalletRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: CreateMultisigWalletRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'gradientJson')
    ..aI(3, _omitFieldNames ? '' : 'm', fieldType: $pb.PbFieldType.OU3)
    ..aI(4, _omitFieldNames ? '' : 'n', fieldType: $pb.PbFieldType.OU3)
    ..aOS(5, _omitFieldNames ? '' : 'scriptType')
    ..pPM<MultisigCosignerInput>(6, _omitFieldNames ? '' : 'cosigners',
        subBuilder: MultisigCosignerInput.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateMultisigWalletRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateMultisigWalletRequest copyWith(void Function(CreateMultisigWalletRequest) updates) =>
      super.copyWith((message) => updates(message as CreateMultisigWalletRequest)) as CreateMultisigWalletRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateMultisigWalletRequest() / CreateMultisigWalletRequest.new instead')
  static CreateMultisigWalletRequest create() => CreateMultisigWalletRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateMultisigWalletRequest._();
  @$core.override
  CreateMultisigWalletRequest createEmptyInstance() => CreateMultisigWalletRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateMultisigWalletRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateMultisigWalletRequest>(CreateMultisigWalletRequest.$_createMessage);
  static CreateMultisigWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get gradientJson => $_getSZ(1);
  @$pb.TagNumber(2)
  set gradientJson($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasGradientJson() => $_has(1);
  @$pb.TagNumber(2)
  void clearGradientJson() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get m => $_getIZ(2);
  @$pb.TagNumber(3)
  set m($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasM() => $_has(2);
  @$pb.TagNumber(3)
  void clearM() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get n => $_getIZ(3);
  @$pb.TagNumber(4)
  set n($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasN() => $_has(3);
  @$pb.TagNumber(4)
  void clearN() => $_clearField(4);

  /// "wsh" (native P2WSH, default), "sh-wsh" (nested P2SH-P2WSH), or "sh"
  /// (legacy P2SH).
  @$pb.TagNumber(5)
  $core.String get scriptType => $_getSZ(4);
  @$pb.TagNumber(5)
  set scriptType($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasScriptType() => $_has(4);
  @$pb.TagNumber(5)
  void clearScriptType() => $_clearField(5);

  @$pb.TagNumber(6)
  $pb.PbList<MultisigCosignerInput> get cosigners => $_getList(5);
}

class CreateMultisigWalletResponse extends $pb.GeneratedMessage {
  factory CreateMultisigWalletResponse({
    $core.String? walletId,
  }) {
    final result = CreateMultisigWalletResponse._();
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  CreateMultisigWalletResponse._();

  factory CreateMultisigWalletResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateMultisigWalletResponse()..mergeFromBuffer(data, registry);
  factory CreateMultisigWalletResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateMultisigWalletResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateMultisigWalletResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: CreateMultisigWalletResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateMultisigWalletResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateMultisigWalletResponse copyWith(void Function(CreateMultisigWalletResponse) updates) =>
      super.copyWith((message) => updates(message as CreateMultisigWalletResponse)) as CreateMultisigWalletResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateMultisigWalletResponse() / CreateMultisigWalletResponse.new instead')
  static CreateMultisigWalletResponse create() => CreateMultisigWalletResponse._();
  static $pb.GeneratedMessage $_createMessage() => CreateMultisigWalletResponse._();
  @$core.override
  CreateMultisigWalletResponse createEmptyInstance() => CreateMultisigWalletResponse._();
  @$core.pragma('dart2js:noInline')
  static CreateMultisigWalletResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateMultisigWalletResponse>(CreateMultisigWalletResponse.$_createMessage);
  static CreateMultisigWalletResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);
}

class ParseMultisigConfigRequest extends $pb.GeneratedMessage {
  factory ParseMultisigConfigRequest({
    $core.String? content,
  }) {
    final result = ParseMultisigConfigRequest._();
    if (content != null) result.content = content;
    return result;
  }

  ParseMultisigConfigRequest._();

  factory ParseMultisigConfigRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ParseMultisigConfigRequest()..mergeFromBuffer(data, registry);
  factory ParseMultisigConfigRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ParseMultisigConfigRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ParseMultisigConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ParseMultisigConfigRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'content')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParseMultisigConfigRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParseMultisigConfigRequest copyWith(void Function(ParseMultisigConfigRequest) updates) =>
      super.copyWith((message) => updates(message as ParseMultisigConfigRequest)) as ParseMultisigConfigRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ParseMultisigConfigRequest() / ParseMultisigConfigRequest.new instead')
  static ParseMultisigConfigRequest create() => ParseMultisigConfigRequest._();
  static $pb.GeneratedMessage $_createMessage() => ParseMultisigConfigRequest._();
  @$core.override
  ParseMultisigConfigRequest createEmptyInstance() => ParseMultisigConfigRequest._();
  @$core.pragma('dart2js:noInline')
  static ParseMultisigConfigRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ParseMultisigConfigRequest>(ParseMultisigConfigRequest.$_createMessage);
  static ParseMultisigConfigRequest? _defaultInstance;

  /// An output descriptor or a wallet-config file's contents.
  @$pb.TagNumber(1)
  $core.String get content => $_getSZ(0);
  @$pb.TagNumber(1)
  set content($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearContent() => $_clearField(1);
}

class ParsedCosigner extends $pb.GeneratedMessage {
  factory ParsedCosigner({
    $core.String? xpub,
    $core.String? fingerprint,
    $core.String? originPath,
    $core.String? xprv,
  }) {
    final result = ParsedCosigner._();
    if (xpub != null) result.xpub = xpub;
    if (fingerprint != null) result.fingerprint = fingerprint;
    if (originPath != null) result.originPath = originPath;
    if (xprv != null) result.xprv = xprv;
    return result;
  }

  ParsedCosigner._();

  factory ParsedCosigner.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ParsedCosigner()..mergeFromBuffer(data, registry);
  factory ParsedCosigner.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ParsedCosigner()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ParsedCosigner',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ParsedCosigner.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'xpub')
    ..aOS(2, _omitFieldNames ? '' : 'fingerprint')
    ..aOS(3, _omitFieldNames ? '' : 'originPath')
    ..aOS(4, _omitFieldNames ? '' : 'xprv')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParsedCosigner clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParsedCosigner copyWith(void Function(ParsedCosigner) updates) =>
      super.copyWith((message) => updates(message as ParsedCosigner)) as ParsedCosigner;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ParsedCosigner() / ParsedCosigner.new instead')
  static ParsedCosigner create() => ParsedCosigner._();
  static $pb.GeneratedMessage $_createMessage() => ParsedCosigner._();
  @$core.override
  ParsedCosigner createEmptyInstance() => ParsedCosigner._();
  @$core.pragma('dart2js:noInline')
  static ParsedCosigner getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ParsedCosigner>(ParsedCosigner.$_createMessage);
  static ParsedCosigner? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get xpub => $_getSZ(0);
  @$pb.TagNumber(1)
  set xpub($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasXpub() => $_has(0);
  @$pb.TagNumber(1)
  void clearXpub() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fingerprint => $_getSZ(1);
  @$pb.TagNumber(2)
  set fingerprint($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFingerprint() => $_has(1);
  @$pb.TagNumber(2)
  void clearFingerprint() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get originPath => $_getSZ(2);
  @$pb.TagNumber(3)
  set originPath($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOriginPath() => $_has(2);
  @$pb.TagNumber(3)
  void clearOriginPath() => $_clearField(3);

  /// Account-level private key, set only by ValidateDescriptor when the
  /// descriptor holds one.
  @$pb.TagNumber(4)
  $core.String get xprv => $_getSZ(3);
  @$pb.TagNumber(4)
  set xprv($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasXprv() => $_has(3);
  @$pb.TagNumber(4)
  void clearXprv() => $_clearField(4);
}

class ParseMultisigConfigResponse extends $pb.GeneratedMessage {
  factory ParseMultisigConfigResponse({
    $core.int? m,
    $core.int? n,
    $core.String? scriptType,
    $core.Iterable<ParsedCosigner>? cosigners,
  }) {
    final result = ParseMultisigConfigResponse._();
    if (m != null) result.m = m;
    if (n != null) result.n = n;
    if (scriptType != null) result.scriptType = scriptType;
    if (cosigners != null) result.cosigners.addAll(cosigners);
    return result;
  }

  ParseMultisigConfigResponse._();

  factory ParseMultisigConfigResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ParseMultisigConfigResponse()..mergeFromBuffer(data, registry);
  factory ParseMultisigConfigResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ParseMultisigConfigResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ParseMultisigConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ParseMultisigConfigResponse.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'm', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'n', fieldType: $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'scriptType')
    ..pPM<ParsedCosigner>(4, _omitFieldNames ? '' : 'cosigners', subBuilder: ParsedCosigner.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParseMultisigConfigResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ParseMultisigConfigResponse copyWith(void Function(ParseMultisigConfigResponse) updates) =>
      super.copyWith((message) => updates(message as ParseMultisigConfigResponse)) as ParseMultisigConfigResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ParseMultisigConfigResponse() / ParseMultisigConfigResponse.new instead')
  static ParseMultisigConfigResponse create() => ParseMultisigConfigResponse._();
  static $pb.GeneratedMessage $_createMessage() => ParseMultisigConfigResponse._();
  @$core.override
  ParseMultisigConfigResponse createEmptyInstance() => ParseMultisigConfigResponse._();
  @$core.pragma('dart2js:noInline')
  static ParseMultisigConfigResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ParseMultisigConfigResponse>(ParseMultisigConfigResponse.$_createMessage);
  static ParseMultisigConfigResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get m => $_getIZ(0);
  @$pb.TagNumber(1)
  set m($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasM() => $_has(0);
  @$pb.TagNumber(1)
  void clearM() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get n => $_getIZ(1);
  @$pb.TagNumber(2)
  set n($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasN() => $_has(1);
  @$pb.TagNumber(2)
  void clearN() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get scriptType => $_getSZ(2);
  @$pb.TagNumber(3)
  set scriptType($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasScriptType() => $_has(2);
  @$pb.TagNumber(3)
  void clearScriptType() => $_clearField(3);

  @$pb.TagNumber(4)
  $pb.PbList<ParsedCosigner> get cosigners => $_getList(3);
}

class ValidateDescriptorRequest extends $pb.GeneratedMessage {
  factory ValidateDescriptorRequest({
    $core.String? descriptor,
  }) {
    final result = ValidateDescriptorRequest._();
    if (descriptor != null) result.descriptor = descriptor;
    return result;
  }

  ValidateDescriptorRequest._();

  factory ValidateDescriptorRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidateDescriptorRequest()..mergeFromBuffer(data, registry);
  factory ValidateDescriptorRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidateDescriptorRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ValidateDescriptorRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ValidateDescriptorRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'descriptor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateDescriptorRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateDescriptorRequest copyWith(void Function(ValidateDescriptorRequest) updates) =>
      super.copyWith((message) => updates(message as ValidateDescriptorRequest)) as ValidateDescriptorRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ValidateDescriptorRequest() / ValidateDescriptorRequest.new instead')
  static ValidateDescriptorRequest create() => ValidateDescriptorRequest._();
  static $pb.GeneratedMessage $_createMessage() => ValidateDescriptorRequest._();
  @$core.override
  ValidateDescriptorRequest createEmptyInstance() => ValidateDescriptorRequest._();
  @$core.pragma('dart2js:noInline')
  static ValidateDescriptorRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ValidateDescriptorRequest>(ValidateDescriptorRequest.$_createMessage);
  static ValidateDescriptorRequest? _defaultInstance;

  /// An output descriptor, single-sig or sortedmulti.
  @$pb.TagNumber(1)
  $core.String get descriptor => $_getSZ(0);
  @$pb.TagNumber(1)
  set descriptor($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasDescriptor() => $_has(0);
  @$pb.TagNumber(1)
  void clearDescriptor() => $_clearField(1);
}

class ValidateDerivationPathRequest extends $pb.GeneratedMessage {
  factory ValidateDerivationPathRequest({
    $core.String? path,
    $core.bool? multisig,
  }) {
    final result = ValidateDerivationPathRequest._();
    if (path != null) result.path = path;
    if (multisig != null) result.multisig = multisig;
    return result;
  }

  ValidateDerivationPathRequest._();

  factory ValidateDerivationPathRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidateDerivationPathRequest()..mergeFromBuffer(data, registry);
  factory ValidateDerivationPathRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidateDerivationPathRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ValidateDerivationPathRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ValidateDerivationPathRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'path')
    ..aOB(2, _omitFieldNames ? '' : 'multisig')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateDerivationPathRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateDerivationPathRequest copyWith(void Function(ValidateDerivationPathRequest) updates) =>
      super.copyWith((message) => updates(message as ValidateDerivationPathRequest)) as ValidateDerivationPathRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ValidateDerivationPathRequest() / ValidateDerivationPathRequest.new instead')
  static ValidateDerivationPathRequest create() => ValidateDerivationPathRequest._();
  static $pb.GeneratedMessage $_createMessage() => ValidateDerivationPathRequest._();
  @$core.override
  ValidateDerivationPathRequest createEmptyInstance() => ValidateDerivationPathRequest._();
  @$core.pragma('dart2js:noInline')
  static ValidateDerivationPathRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ValidateDerivationPathRequest>(ValidateDerivationPathRequest.$_createMessage);
  static ValidateDerivationPathRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get path => $_getSZ(0);
  @$pb.TagNumber(1)
  set path($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPath() => $_has(0);
  @$pb.TagNumber(1)
  void clearPath() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get multisig => $_getBF(1);
  @$pb.TagNumber(2)
  set multisig($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMultisig() => $_has(1);
  @$pb.TagNumber(2)
  void clearMultisig() => $_clearField(2);
}

class ValidateDerivationPathResponse extends $pb.GeneratedMessage {
  factory ValidateDerivationPathResponse({
    $core.String? normalized,
    $core.String? scriptType,
  }) {
    final result = ValidateDerivationPathResponse._();
    if (normalized != null) result.normalized = normalized;
    if (scriptType != null) result.scriptType = scriptType;
    return result;
  }

  ValidateDerivationPathResponse._();

  factory ValidateDerivationPathResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidateDerivationPathResponse()..mergeFromBuffer(data, registry);
  factory ValidateDerivationPathResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidateDerivationPathResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ValidateDerivationPathResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ValidateDerivationPathResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'normalized')
    ..aOS(2, _omitFieldNames ? '' : 'scriptType')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateDerivationPathResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateDerivationPathResponse copyWith(void Function(ValidateDerivationPathResponse) updates) =>
      super.copyWith((message) => updates(message as ValidateDerivationPathResponse)) as ValidateDerivationPathResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ValidateDerivationPathResponse() / ValidateDerivationPathResponse.new instead')
  static ValidateDerivationPathResponse create() => ValidateDerivationPathResponse._();
  static $pb.GeneratedMessage $_createMessage() => ValidateDerivationPathResponse._();
  @$core.override
  ValidateDerivationPathResponse createEmptyInstance() => ValidateDerivationPathResponse._();
  @$core.pragma('dart2js:noInline')
  static ValidateDerivationPathResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ValidateDerivationPathResponse>(ValidateDerivationPathResponse.$_createMessage);
  static ValidateDerivationPathResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get normalized => $_getSZ(0);
  @$pb.TagNumber(1)
  set normalized($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNormalized() => $_has(0);
  @$pb.TagNumber(1)
  void clearNormalized() => $_clearField(1);

  /// Script type this path is the standard account path for; empty for a custom
  /// path, which is still valid.
  @$pb.TagNumber(2)
  $core.String get scriptType => $_getSZ(1);
  @$pb.TagNumber(2)
  set scriptType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasScriptType() => $_has(1);
  @$pb.TagNumber(2)
  void clearScriptType() => $_clearField(2);
}

class ListDerivationPathsRequest extends $pb.GeneratedMessage {
  factory ListDerivationPathsRequest({
    $core.String? scriptType,
    $core.bool? multisig,
    $core.int? account,
  }) {
    final result = ListDerivationPathsRequest._();
    if (scriptType != null) result.scriptType = scriptType;
    if (multisig != null) result.multisig = multisig;
    if (account != null) result.account = account;
    return result;
  }

  ListDerivationPathsRequest._();

  factory ListDerivationPathsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListDerivationPathsRequest()..mergeFromBuffer(data, registry);
  factory ListDerivationPathsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListDerivationPathsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListDerivationPathsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ListDerivationPathsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'scriptType')
    ..aOB(2, _omitFieldNames ? '' : 'multisig')
    ..aI(3, _omitFieldNames ? '' : 'account', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDerivationPathsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDerivationPathsRequest copyWith(void Function(ListDerivationPathsRequest) updates) =>
      super.copyWith((message) => updates(message as ListDerivationPathsRequest)) as ListDerivationPathsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListDerivationPathsRequest() / ListDerivationPathsRequest.new instead')
  static ListDerivationPathsRequest create() => ListDerivationPathsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListDerivationPathsRequest._();
  @$core.override
  ListDerivationPathsRequest createEmptyInstance() => ListDerivationPathsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListDerivationPathsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListDerivationPathsRequest>(ListDerivationPathsRequest.$_createMessage);
  static ListDerivationPathsRequest? _defaultInstance;

  /// single-sig: "legacy" | "nested-segwit" | "native-segwit" | "taproot";
  /// multisig: "sh" | "sh-wsh" | "wsh" | "tr".
  @$pb.TagNumber(1)
  $core.String get scriptType => $_getSZ(0);
  @$pb.TagNumber(1)
  set scriptType($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasScriptType() => $_has(0);
  @$pb.TagNumber(1)
  void clearScriptType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get multisig => $_getBF(1);
  @$pb.TagNumber(2)
  set multisig($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMultisig() => $_has(1);
  @$pb.TagNumber(2)
  void clearMultisig() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get account => $_getIZ(2);
  @$pb.TagNumber(3)
  set account($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAccount() => $_has(2);
  @$pb.TagNumber(3)
  void clearAccount() => $_clearField(3);
}

class DerivationPathOption extends $pb.GeneratedMessage {
  factory DerivationPathOption({
    $core.String? label,
    $core.String? path,
  }) {
    final result = DerivationPathOption._();
    if (label != null) result.label = label;
    if (path != null) result.path = path;
    return result;
  }

  DerivationPathOption._();

  factory DerivationPathOption.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DerivationPathOption()..mergeFromBuffer(data, registry);
  factory DerivationPathOption.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DerivationPathOption()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DerivationPathOption',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: DerivationPathOption.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'label')
    ..aOS(2, _omitFieldNames ? '' : 'path')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DerivationPathOption clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DerivationPathOption copyWith(void Function(DerivationPathOption) updates) =>
      super.copyWith((message) => updates(message as DerivationPathOption)) as DerivationPathOption;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DerivationPathOption() / DerivationPathOption.new instead')
  static DerivationPathOption create() => DerivationPathOption._();
  static $pb.GeneratedMessage $_createMessage() => DerivationPathOption._();
  @$core.override
  DerivationPathOption createEmptyInstance() => DerivationPathOption._();
  @$core.pragma('dart2js:noInline')
  static DerivationPathOption getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DerivationPathOption>(DerivationPathOption.$_createMessage);
  static DerivationPathOption? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get label => $_getSZ(0);
  @$pb.TagNumber(1)
  set label($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasLabel() => $_has(0);
  @$pb.TagNumber(1)
  void clearLabel() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get path => $_getSZ(1);
  @$pb.TagNumber(2)
  set path($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPath() => $_has(1);
  @$pb.TagNumber(2)
  void clearPath() => $_clearField(2);
}

class ListDerivationPathsResponse extends $pb.GeneratedMessage {
  factory ListDerivationPathsResponse({
    $core.Iterable<DerivationPathOption>? options,
    $core.String? defaultPath,
  }) {
    final result = ListDerivationPathsResponse._();
    if (options != null) result.options.addAll(options);
    if (defaultPath != null) result.defaultPath = defaultPath;
    return result;
  }

  ListDerivationPathsResponse._();

  factory ListDerivationPathsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListDerivationPathsResponse()..mergeFromBuffer(data, registry);
  factory ListDerivationPathsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListDerivationPathsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListDerivationPathsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ListDerivationPathsResponse.$_createMessage)
    ..pPM<DerivationPathOption>(1, _omitFieldNames ? '' : 'options', subBuilder: DerivationPathOption.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'defaultPath')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDerivationPathsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListDerivationPathsResponse copyWith(void Function(ListDerivationPathsResponse) updates) =>
      super.copyWith((message) => updates(message as ListDerivationPathsResponse)) as ListDerivationPathsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListDerivationPathsResponse() / ListDerivationPathsResponse.new instead')
  static ListDerivationPathsResponse create() => ListDerivationPathsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListDerivationPathsResponse._();
  @$core.override
  ListDerivationPathsResponse createEmptyInstance() => ListDerivationPathsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListDerivationPathsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListDerivationPathsResponse>(ListDerivationPathsResponse.$_createMessage);
  static ListDerivationPathsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<DerivationPathOption> get options => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get defaultPath => $_getSZ(1);
  @$pb.TagNumber(2)
  set defaultPath($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDefaultPath() => $_has(1);
  @$pb.TagNumber(2)
  void clearDefaultPath() => $_clearField(2);
}

class ValidateDescriptorResponse extends $pb.GeneratedMessage {
  factory ValidateDescriptorResponse({
    $core.bool? multisig,
    $core.String? scriptType,
    $core.int? m,
    $core.int? n,
    $core.Iterable<ParsedCosigner>? keys,
    $core.String? descriptor,
  }) {
    final result = ValidateDescriptorResponse._();
    if (multisig != null) result.multisig = multisig;
    if (scriptType != null) result.scriptType = scriptType;
    if (m != null) result.m = m;
    if (n != null) result.n = n;
    if (keys != null) result.keys.addAll(keys);
    if (descriptor != null) result.descriptor = descriptor;
    return result;
  }

  ValidateDescriptorResponse._();

  factory ValidateDescriptorResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidateDescriptorResponse()..mergeFromBuffer(data, registry);
  factory ValidateDescriptorResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidateDescriptorResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ValidateDescriptorResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ValidateDescriptorResponse.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'multisig')
    ..aOS(2, _omitFieldNames ? '' : 'scriptType')
    ..aI(3, _omitFieldNames ? '' : 'm', fieldType: $pb.PbFieldType.OU3)
    ..aI(4, _omitFieldNames ? '' : 'n', fieldType: $pb.PbFieldType.OU3)
    ..pPM<ParsedCosigner>(5, _omitFieldNames ? '' : 'keys', subBuilder: ParsedCosigner.$_createMessage)
    ..aOS(6, _omitFieldNames ? '' : 'descriptor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateDescriptorResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateDescriptorResponse copyWith(void Function(ValidateDescriptorResponse) updates) =>
      super.copyWith((message) => updates(message as ValidateDescriptorResponse)) as ValidateDescriptorResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ValidateDescriptorResponse() / ValidateDescriptorResponse.new instead')
  static ValidateDescriptorResponse create() => ValidateDescriptorResponse._();
  static $pb.GeneratedMessage $_createMessage() => ValidateDescriptorResponse._();
  @$core.override
  ValidateDescriptorResponse createEmptyInstance() => ValidateDescriptorResponse._();
  @$core.pragma('dart2js:noInline')
  static ValidateDescriptorResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ValidateDescriptorResponse>(ValidateDescriptorResponse.$_createMessage);
  static ValidateDescriptorResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get multisig => $_getBF(0);
  @$pb.TagNumber(1)
  set multisig($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMultisig() => $_has(0);
  @$pb.TagNumber(1)
  void clearMultisig() => $_clearField(1);

  /// wpkh | sh-wpkh | pkh | tr, or wsh | sh-wsh | sh | tr when multisig.
  @$pb.TagNumber(2)
  $core.String get scriptType => $_getSZ(1);
  @$pb.TagNumber(2)
  set scriptType($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasScriptType() => $_has(1);
  @$pb.TagNumber(2)
  void clearScriptType() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get m => $_getIZ(2);
  @$pb.TagNumber(3)
  set m($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasM() => $_has(2);
  @$pb.TagNumber(3)
  void clearM() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get n => $_getIZ(3);
  @$pb.TagNumber(4)
  set n($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasN() => $_has(3);
  @$pb.TagNumber(4)
  void clearN() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<ParsedCosigner> get keys => $_getList(4);

  /// The one descriptor to import. A receive and change pair joins into it.
  @$pb.TagNumber(6)
  $core.String get descriptor => $_getSZ(5);
  @$pb.TagNumber(6)
  set descriptor($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasDescriptor() => $_has(5);
  @$pb.TagNumber(6)
  void clearDescriptor() => $_clearField(6);
}

class CreateBitcoinCoreWalletRequest extends $pb.GeneratedMessage {
  factory CreateBitcoinCoreWalletRequest({
    $core.String? walletId,
  }) {
    final result = CreateBitcoinCoreWalletRequest._();
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  CreateBitcoinCoreWalletRequest._();

  factory CreateBitcoinCoreWalletRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateBitcoinCoreWalletRequest()..mergeFromBuffer(data, registry);
  factory CreateBitcoinCoreWalletRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateBitcoinCoreWalletRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateBitcoinCoreWalletRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: CreateBitcoinCoreWalletRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateBitcoinCoreWalletRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateBitcoinCoreWalletRequest copyWith(void Function(CreateBitcoinCoreWalletRequest) updates) =>
      super.copyWith((message) => updates(message as CreateBitcoinCoreWalletRequest)) as CreateBitcoinCoreWalletRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateBitcoinCoreWalletRequest() / CreateBitcoinCoreWalletRequest.new instead')
  static CreateBitcoinCoreWalletRequest create() => CreateBitcoinCoreWalletRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateBitcoinCoreWalletRequest._();
  @$core.override
  CreateBitcoinCoreWalletRequest createEmptyInstance() => CreateBitcoinCoreWalletRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateBitcoinCoreWalletRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateBitcoinCoreWalletRequest>(CreateBitcoinCoreWalletRequest.$_createMessage);
  static CreateBitcoinCoreWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);
}

class CreateBitcoinCoreWalletResponse extends $pb.GeneratedMessage {
  factory CreateBitcoinCoreWalletResponse({
    $core.String? coreWalletName,
  }) {
    final result = CreateBitcoinCoreWalletResponse._();
    if (coreWalletName != null) result.coreWalletName = coreWalletName;
    return result;
  }

  CreateBitcoinCoreWalletResponse._();

  factory CreateBitcoinCoreWalletResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateBitcoinCoreWalletResponse()..mergeFromBuffer(data, registry);
  factory CreateBitcoinCoreWalletResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateBitcoinCoreWalletResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateBitcoinCoreWalletResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: CreateBitcoinCoreWalletResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'coreWalletName')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateBitcoinCoreWalletResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateBitcoinCoreWalletResponse copyWith(void Function(CreateBitcoinCoreWalletResponse) updates) =>
      super.copyWith((message) => updates(message as CreateBitcoinCoreWalletResponse))
          as CreateBitcoinCoreWalletResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateBitcoinCoreWalletResponse() / CreateBitcoinCoreWalletResponse.new instead')
  static CreateBitcoinCoreWalletResponse create() => CreateBitcoinCoreWalletResponse._();
  static $pb.GeneratedMessage $_createMessage() => CreateBitcoinCoreWalletResponse._();
  @$core.override
  CreateBitcoinCoreWalletResponse createEmptyInstance() => CreateBitcoinCoreWalletResponse._();
  @$core.pragma('dart2js:noInline')
  static CreateBitcoinCoreWalletResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateBitcoinCoreWalletResponse>(
          CreateBitcoinCoreWalletResponse.$_createMessage);
  static CreateBitcoinCoreWalletResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get coreWalletName => $_getSZ(0);
  @$pb.TagNumber(1)
  set coreWalletName($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCoreWalletName() => $_has(0);
  @$pb.TagNumber(1)
  void clearCoreWalletName() => $_clearField(1);
}

class EnsureCoreWalletsRequest extends $pb.GeneratedMessage {
  factory EnsureCoreWalletsRequest() => EnsureCoreWalletsRequest._();

  EnsureCoreWalletsRequest._();

  factory EnsureCoreWalletsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EnsureCoreWalletsRequest()..mergeFromBuffer(data, registry);
  factory EnsureCoreWalletsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EnsureCoreWalletsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EnsureCoreWalletsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: EnsureCoreWalletsRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EnsureCoreWalletsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EnsureCoreWalletsRequest copyWith(void Function(EnsureCoreWalletsRequest) updates) =>
      super.copyWith((message) => updates(message as EnsureCoreWalletsRequest)) as EnsureCoreWalletsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EnsureCoreWalletsRequest() / EnsureCoreWalletsRequest.new instead')
  static EnsureCoreWalletsRequest create() => EnsureCoreWalletsRequest._();
  static $pb.GeneratedMessage $_createMessage() => EnsureCoreWalletsRequest._();
  @$core.override
  EnsureCoreWalletsRequest createEmptyInstance() => EnsureCoreWalletsRequest._();
  @$core.pragma('dart2js:noInline')
  static EnsureCoreWalletsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EnsureCoreWalletsRequest>(EnsureCoreWalletsRequest.$_createMessage);
  static EnsureCoreWalletsRequest? _defaultInstance;
}

class EnsureCoreWalletsResponse extends $pb.GeneratedMessage {
  factory EnsureCoreWalletsResponse({
    $core.int? syncedCount,
  }) {
    final result = EnsureCoreWalletsResponse._();
    if (syncedCount != null) result.syncedCount = syncedCount;
    return result;
  }

  EnsureCoreWalletsResponse._();

  factory EnsureCoreWalletsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EnsureCoreWalletsResponse()..mergeFromBuffer(data, registry);
  factory EnsureCoreWalletsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EnsureCoreWalletsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EnsureCoreWalletsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: EnsureCoreWalletsResponse.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'syncedCount')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EnsureCoreWalletsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EnsureCoreWalletsResponse copyWith(void Function(EnsureCoreWalletsResponse) updates) =>
      super.copyWith((message) => updates(message as EnsureCoreWalletsResponse)) as EnsureCoreWalletsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EnsureCoreWalletsResponse() / EnsureCoreWalletsResponse.new instead')
  static EnsureCoreWalletsResponse create() => EnsureCoreWalletsResponse._();
  static $pb.GeneratedMessage $_createMessage() => EnsureCoreWalletsResponse._();
  @$core.override
  EnsureCoreWalletsResponse createEmptyInstance() => EnsureCoreWalletsResponse._();
  @$core.pragma('dart2js:noInline')
  static EnsureCoreWalletsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EnsureCoreWalletsResponse>(EnsureCoreWalletsResponse.$_createMessage);
  static EnsureCoreWalletsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get syncedCount => $_getIZ(0);
  @$pb.TagNumber(1)
  set syncedCount($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSyncedCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearSyncedCount() => $_clearField(1);
}

class GetBalanceRequest extends $pb.GeneratedMessage {
  factory GetBalanceRequest({
    $core.String? walletId,
  }) {
    final result = GetBalanceRequest._();
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  GetBalanceRequest._();

  factory GetBalanceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBalanceRequest()..mergeFromBuffer(data, registry);
  factory GetBalanceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBalanceRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBalanceRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: GetBalanceRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBalanceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBalanceRequest copyWith(void Function(GetBalanceRequest) updates) =>
      super.copyWith((message) => updates(message as GetBalanceRequest)) as GetBalanceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBalanceRequest() / GetBalanceRequest.new instead')
  static GetBalanceRequest create() => GetBalanceRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetBalanceRequest._();
  @$core.override
  GetBalanceRequest createEmptyInstance() => GetBalanceRequest._();
  @$core.pragma('dart2js:noInline')
  static GetBalanceRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBalanceRequest>(GetBalanceRequest.$_createMessage);
  static GetBalanceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);
}

class RescanWalletRequest extends $pb.GeneratedMessage {
  factory RescanWalletRequest({
    $core.String? walletId,
  }) {
    final result = RescanWalletRequest._();
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  RescanWalletRequest._();

  factory RescanWalletRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RescanWalletRequest()..mergeFromBuffer(data, registry);
  factory RescanWalletRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RescanWalletRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RescanWalletRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: RescanWalletRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RescanWalletRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RescanWalletRequest copyWith(void Function(RescanWalletRequest) updates) =>
      super.copyWith((message) => updates(message as RescanWalletRequest)) as RescanWalletRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RescanWalletRequest() / RescanWalletRequest.new instead')
  static RescanWalletRequest create() => RescanWalletRequest._();
  static $pb.GeneratedMessage $_createMessage() => RescanWalletRequest._();
  @$core.override
  RescanWalletRequest createEmptyInstance() => RescanWalletRequest._();
  @$core.pragma('dart2js:noInline')
  static RescanWalletRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RescanWalletRequest>(RescanWalletRequest.$_createMessage);
  static RescanWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);
}

class RescanWalletResponse extends $pb.GeneratedMessage {
  factory RescanWalletResponse() => RescanWalletResponse._();

  RescanWalletResponse._();

  factory RescanWalletResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RescanWalletResponse()..mergeFromBuffer(data, registry);
  factory RescanWalletResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RescanWalletResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RescanWalletResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: RescanWalletResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RescanWalletResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RescanWalletResponse copyWith(void Function(RescanWalletResponse) updates) =>
      super.copyWith((message) => updates(message as RescanWalletResponse)) as RescanWalletResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RescanWalletResponse() / RescanWalletResponse.new instead')
  static RescanWalletResponse create() => RescanWalletResponse._();
  static $pb.GeneratedMessage $_createMessage() => RescanWalletResponse._();
  @$core.override
  RescanWalletResponse createEmptyInstance() => RescanWalletResponse._();
  @$core.pragma('dart2js:noInline')
  static RescanWalletResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<RescanWalletResponse>(RescanWalletResponse.$_createMessage);
  static RescanWalletResponse? _defaultInstance;
}

class EstimateFeeRequest extends $pb.GeneratedMessage {
  factory EstimateFeeRequest({
    $core.int? confTarget,
  }) {
    final result = EstimateFeeRequest._();
    if (confTarget != null) result.confTarget = confTarget;
    return result;
  }

  EstimateFeeRequest._();

  factory EstimateFeeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EstimateFeeRequest()..mergeFromBuffer(data, registry);
  factory EstimateFeeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EstimateFeeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EstimateFeeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: EstimateFeeRequest.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'confTarget')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EstimateFeeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EstimateFeeRequest copyWith(void Function(EstimateFeeRequest) updates) =>
      super.copyWith((message) => updates(message as EstimateFeeRequest)) as EstimateFeeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EstimateFeeRequest() / EstimateFeeRequest.new instead')
  static EstimateFeeRequest create() => EstimateFeeRequest._();
  static $pb.GeneratedMessage $_createMessage() => EstimateFeeRequest._();
  @$core.override
  EstimateFeeRequest createEmptyInstance() => EstimateFeeRequest._();
  @$core.pragma('dart2js:noInline')
  static EstimateFeeRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EstimateFeeRequest>(EstimateFeeRequest.$_createMessage);
  static EstimateFeeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get confTarget => $_getIZ(0);
  @$pb.TagNumber(1)
  set confTarget($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConfTarget() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfTarget() => $_clearField(1);
}

class EstimateFeeResponse extends $pb.GeneratedMessage {
  factory EstimateFeeResponse({
    $core.double? satPerVbyte,
  }) {
    final result = EstimateFeeResponse._();
    if (satPerVbyte != null) result.satPerVbyte = satPerVbyte;
    return result;
  }

  EstimateFeeResponse._();

  factory EstimateFeeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EstimateFeeResponse()..mergeFromBuffer(data, registry);
  factory EstimateFeeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EstimateFeeResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EstimateFeeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: EstimateFeeResponse.$_createMessage)
    ..aD(1, _omitFieldNames ? '' : 'satPerVbyte')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EstimateFeeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EstimateFeeResponse copyWith(void Function(EstimateFeeResponse) updates) =>
      super.copyWith((message) => updates(message as EstimateFeeResponse)) as EstimateFeeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EstimateFeeResponse() / EstimateFeeResponse.new instead')
  static EstimateFeeResponse create() => EstimateFeeResponse._();
  static $pb.GeneratedMessage $_createMessage() => EstimateFeeResponse._();
  @$core.override
  EstimateFeeResponse createEmptyInstance() => EstimateFeeResponse._();
  @$core.pragma('dart2js:noInline')
  static EstimateFeeResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EstimateFeeResponse>(EstimateFeeResponse.$_createMessage);
  static EstimateFeeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get satPerVbyte => $_getN(0);
  @$pb.TagNumber(1)
  set satPerVbyte($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSatPerVbyte() => $_has(0);
  @$pb.TagNumber(1)
  void clearSatPerVbyte() => $_clearField(1);
}

class GetBalanceResponse extends $pb.GeneratedMessage {
  factory GetBalanceResponse({
    $core.double? confirmedSats,
    $core.double? unconfirmedSats,
    $core.double? immatureSats,
  }) {
    final result = GetBalanceResponse._();
    if (confirmedSats != null) result.confirmedSats = confirmedSats;
    if (unconfirmedSats != null) result.unconfirmedSats = unconfirmedSats;
    if (immatureSats != null) result.immatureSats = immatureSats;
    return result;
  }

  GetBalanceResponse._();

  factory GetBalanceResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBalanceResponse()..mergeFromBuffer(data, registry);
  factory GetBalanceResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetBalanceResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBalanceResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: GetBalanceResponse.$_createMessage)
    ..aD(1, _omitFieldNames ? '' : 'confirmedSats')
    ..aD(2, _omitFieldNames ? '' : 'unconfirmedSats')
    ..aD(3, _omitFieldNames ? '' : 'immatureSats')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBalanceResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetBalanceResponse copyWith(void Function(GetBalanceResponse) updates) =>
      super.copyWith((message) => updates(message as GetBalanceResponse)) as GetBalanceResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetBalanceResponse() / GetBalanceResponse.new instead')
  static GetBalanceResponse create() => GetBalanceResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetBalanceResponse._();
  @$core.override
  GetBalanceResponse createEmptyInstance() => GetBalanceResponse._();
  @$core.pragma('dart2js:noInline')
  static GetBalanceResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBalanceResponse>(GetBalanceResponse.$_createMessage);
  static GetBalanceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get confirmedSats => $_getN(0);
  @$pb.TagNumber(1)
  set confirmedSats($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConfirmedSats() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfirmedSats() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get unconfirmedSats => $_getN(1);
  @$pb.TagNumber(2)
  set unconfirmedSats($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUnconfirmedSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearUnconfirmedSats() => $_clearField(2);

  /// Coinbase outputs that cannot be spent yet. Not part of the other two.
  @$pb.TagNumber(3)
  $core.double get immatureSats => $_getN(2);
  @$pb.TagNumber(3)
  set immatureSats($core.double value) => $_setDouble(2, value);
  @$pb.TagNumber(3)
  $core.bool hasImmatureSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearImmatureSats() => $_clearField(3);
}

class GetNewAddressRequest extends $pb.GeneratedMessage {
  factory GetNewAddressRequest({
    $core.String? walletId,
    AddressType? addressType,
  }) {
    final result = GetNewAddressRequest._();
    if (walletId != null) result.walletId = walletId;
    if (addressType != null) result.addressType = addressType;
    return result;
  }

  GetNewAddressRequest._();

  factory GetNewAddressRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNewAddressRequest()..mergeFromBuffer(data, registry);
  factory GetNewAddressRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNewAddressRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewAddressRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: GetNewAddressRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aE<AddressType>(2, _omitFieldNames ? '' : 'addressType', enumValues: AddressType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNewAddressRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNewAddressRequest copyWith(void Function(GetNewAddressRequest) updates) =>
      super.copyWith((message) => updates(message as GetNewAddressRequest)) as GetNewAddressRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetNewAddressRequest() / GetNewAddressRequest.new instead')
  static GetNewAddressRequest create() => GetNewAddressRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetNewAddressRequest._();
  @$core.override
  GetNewAddressRequest createEmptyInstance() => GetNewAddressRequest._();
  @$core.pragma('dart2js:noInline')
  static GetNewAddressRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNewAddressRequest>(GetNewAddressRequest.$_createMessage);
  static GetNewAddressRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  @$pb.TagNumber(2)
  AddressType get addressType => $_getN(1);
  @$pb.TagNumber(2)
  set addressType(AddressType value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasAddressType() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddressType() => $_clearField(2);
}

class GetNewAddressResponse extends $pb.GeneratedMessage {
  factory GetNewAddressResponse({
    $core.String? address,
    $core.int? index,
    $core.String? derivationPath,
  }) {
    final result = GetNewAddressResponse._();
    if (address != null) result.address = address;
    if (index != null) result.index = index;
    if (derivationPath != null) result.derivationPath = derivationPath;
    return result;
  }

  GetNewAddressResponse._();

  factory GetNewAddressResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNewAddressResponse()..mergeFromBuffer(data, registry);
  factory GetNewAddressResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetNewAddressResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetNewAddressResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: GetNewAddressResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aI(2, _omitFieldNames ? '' : 'index')
    ..aOS(3, _omitFieldNames ? '' : 'derivationPath')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNewAddressResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetNewAddressResponse copyWith(void Function(GetNewAddressResponse) updates) =>
      super.copyWith((message) => updates(message as GetNewAddressResponse)) as GetNewAddressResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetNewAddressResponse() / GetNewAddressResponse.new instead')
  static GetNewAddressResponse create() => GetNewAddressResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetNewAddressResponse._();
  @$core.override
  GetNewAddressResponse createEmptyInstance() => GetNewAddressResponse._();
  @$core.pragma('dart2js:noInline')
  static GetNewAddressResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetNewAddressResponse>(GetNewAddressResponse.$_createMessage);
  static GetNewAddressResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get index => $_getIZ(1);
  @$pb.TagNumber(2)
  set index($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearIndex() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get derivationPath => $_getSZ(2);
  @$pb.TagNumber(3)
  set derivationPath($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDerivationPath() => $_has(2);
  @$pb.TagNumber(3)
  void clearDerivationPath() => $_clearField(3);
}

class SendTransactionRequest extends $pb.GeneratedMessage {
  factory SendTransactionRequest({
    $core.String? walletId,
    $core.Iterable<$core.MapEntry<$core.String, $fixnum.Int64>>? destinations,
    $fixnum.Int64? feeRateSatPerVbyte,
    $core.bool? subtractFeeFromAmount,
    $core.String? opReturnHex,
    $fixnum.Int64? fixedFeeSats,
    $core.Iterable<UnspentOutput>? requiredInputs,
    $core.Iterable<RawOutput>? rawOutputs,
    $core.Iterable<ExternalInput>? externalInputs,
    $core.bool? replaceable,
    $core.bool? allowReplay,
    UnspentOutput? notificationInput,
  }) {
    final result = SendTransactionRequest._();
    if (walletId != null) result.walletId = walletId;
    if (destinations != null) result.destinations.addEntries(destinations);
    if (feeRateSatPerVbyte != null) result.feeRateSatPerVbyte = feeRateSatPerVbyte;
    if (subtractFeeFromAmount != null) result.subtractFeeFromAmount = subtractFeeFromAmount;
    if (opReturnHex != null) result.opReturnHex = opReturnHex;
    if (fixedFeeSats != null) result.fixedFeeSats = fixedFeeSats;
    if (requiredInputs != null) result.requiredInputs.addAll(requiredInputs);
    if (rawOutputs != null) result.rawOutputs.addAll(rawOutputs);
    if (externalInputs != null) result.externalInputs.addAll(externalInputs);
    if (replaceable != null) result.replaceable = replaceable;
    if (allowReplay != null) result.allowReplay = allowReplay;
    if (notificationInput != null) result.notificationInput = notificationInput;
    return result;
  }

  SendTransactionRequest._();

  factory SendTransactionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendTransactionRequest()..mergeFromBuffer(data, registry);
  factory SendTransactionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendTransactionRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendTransactionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: SendTransactionRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..m<$core.String, $fixnum.Int64>(2, _omitFieldNames ? '' : 'destinations',
        entryClassName: 'SendTransactionRequest.DestinationsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O6,
        packageName: const $pb.PackageName('walletmanager.v1'))
    ..aInt64(3, _omitFieldNames ? '' : 'feeRateSatPerVbyte')
    ..aOB(4, _omitFieldNames ? '' : 'subtractFeeFromAmount')
    ..aOS(5, _omitFieldNames ? '' : 'opReturnHex')
    ..aInt64(6, _omitFieldNames ? '' : 'fixedFeeSats')
    ..pPM<UnspentOutput>(7, _omitFieldNames ? '' : 'requiredInputs', subBuilder: UnspentOutput.$_createMessage)
    ..pPM<RawOutput>(9, _omitFieldNames ? '' : 'rawOutputs', subBuilder: RawOutput.$_createMessage)
    ..pPM<ExternalInput>(10, _omitFieldNames ? '' : 'externalInputs', subBuilder: ExternalInput.$_createMessage)
    ..aOB(11, _omitFieldNames ? '' : 'replaceable')
    ..aOB(12, _omitFieldNames ? '' : 'allowReplay')
    ..aOM<UnspentOutput>(13, _omitFieldNames ? '' : 'notificationInput', subBuilder: UnspentOutput.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendTransactionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendTransactionRequest copyWith(void Function(SendTransactionRequest) updates) =>
      super.copyWith((message) => updates(message as SendTransactionRequest)) as SendTransactionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SendTransactionRequest() / SendTransactionRequest.new instead')
  static SendTransactionRequest create() => SendTransactionRequest._();
  static $pb.GeneratedMessage $_createMessage() => SendTransactionRequest._();
  @$core.override
  SendTransactionRequest createEmptyInstance() => SendTransactionRequest._();
  @$core.pragma('dart2js:noInline')
  static SendTransactionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendTransactionRequest>(SendTransactionRequest.$_createMessage);
  static SendTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbMap<$core.String, $fixnum.Int64> get destinations => $_getMap(1);

  @$pb.TagNumber(3)
  $fixnum.Int64 get feeRateSatPerVbyte => $_getI64(2);
  @$pb.TagNumber(3)
  set feeRateSatPerVbyte($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFeeRateSatPerVbyte() => $_has(2);
  @$pb.TagNumber(3)
  void clearFeeRateSatPerVbyte() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get subtractFeeFromAmount => $_getBF(3);
  @$pb.TagNumber(4)
  set subtractFeeFromAmount($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSubtractFeeFromAmount() => $_has(3);
  @$pb.TagNumber(4)
  void clearSubtractFeeFromAmount() => $_clearField(4);

  /// Raw OP_RETURN payload hex.
  @$pb.TagNumber(5)
  $core.String get opReturnHex => $_getSZ(4);
  @$pb.TagNumber(5)
  set opReturnHex($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOpReturnHex() => $_has(4);
  @$pb.TagNumber(5)
  void clearOpReturnHex() => $_clearField(5);

  /// Exact fee in sats when caller wants deterministic fee selection.
  @$pb.TagNumber(6)
  $fixnum.Int64 get fixedFeeSats => $_getI64(5);
  @$pb.TagNumber(6)
  set fixedFeeSats($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFixedFeeSats() => $_has(5);
  @$pb.TagNumber(6)
  void clearFixedFeeSats() => $_clearField(6);

  /// Explicit wallet inputs to spend.
  @$pb.TagNumber(7)
  $pb.PbList<UnspentOutput> get requiredInputs => $_getList(6);

  /// Outputs with an explicit raw scriptPubKey, kept in order before any
  /// address/op_return outputs. Used for non-standard scripts (e.g. a sidechain
  /// OP_DRIVECHAIN treasury output).
  @$pb.TagNumber(9)
  $pb.PbList<RawOutput> get rawOutputs => $_getList(7);

  /// Inputs not owned by the wallet that must be spent as-is, in order, before
  /// wallet-funded inputs. Used for anyone-can-spend scripts (e.g. a sidechain
  /// CTIP). They are added with an empty scriptSig and not signed.
  @$pb.TagNumber(10)
  $pb.PbList<ExternalInput> get externalInputs => $_getList(8);

  /// Signal BIP125, so a later transaction spending the same inputs replaces
  /// this one. Used to raise a BMM bid.
  @$pb.TagNumber(11)
  $core.bool get replaceable => $_getBF(9);
  @$pb.TagNumber(11)
  set replaceable($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(11)
  $core.bool hasReplaceable() => $_has(9);
  @$pb.TagNumber(11)
  void clearReplaceable() => $_clearField(11);

  /// Send a transaction that can replay onto Bitcoin. The eCash network stamps
  /// the magic nLockTime (499999999) on every send, so stock Bitcoin Core
  /// rejects it; this drops that stamp for one send.
  @$pb.TagNumber(12)
  $core.bool get allowReplay => $_getBF(10);
  @$pb.TagNumber(12)
  set allowReplay($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(12)
  $core.bool hasAllowReplay() => $_has(10);
  @$pb.TagNumber(12)
  void clearAllowReplay() => $_clearField(12);

  /// The coin the BIP47 notification of a first payment spends, from
  /// PreviewSend. Unset lets the wallet pick it.
  @$pb.TagNumber(13)
  UnspentOutput get notificationInput => $_getN(11);
  @$pb.TagNumber(13)
  set notificationInput(UnspentOutput value) => $_setField(13, value);
  @$pb.TagNumber(13)
  $core.bool hasNotificationInput() => $_has(11);
  @$pb.TagNumber(13)
  void clearNotificationInput() => $_clearField(13);
  @$pb.TagNumber(13)
  UnspentOutput ensureNotificationInput() => $_ensure(11);
}

class SendTransactionResponse extends $pb.GeneratedMessage {
  factory SendTransactionResponse({
    $core.String? txid,
  }) {
    final result = SendTransactionResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  SendTransactionResponse._();

  factory SendTransactionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendTransactionResponse()..mergeFromBuffer(data, registry);
  factory SendTransactionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendTransactionResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendTransactionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: SendTransactionResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendTransactionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendTransactionResponse copyWith(void Function(SendTransactionResponse) updates) =>
      super.copyWith((message) => updates(message as SendTransactionResponse)) as SendTransactionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SendTransactionResponse() / SendTransactionResponse.new instead')
  static SendTransactionResponse create() => SendTransactionResponse._();
  static $pb.GeneratedMessage $_createMessage() => SendTransactionResponse._();
  @$core.override
  SendTransactionResponse createEmptyInstance() => SendTransactionResponse._();
  @$core.pragma('dart2js:noInline')
  static SendTransactionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendTransactionResponse>(SendTransactionResponse.$_createMessage);
  static SendTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class PreviewSendRequest extends $pb.GeneratedMessage {
  factory PreviewSendRequest({
    $core.String? walletId,
    $core.Iterable<$core.MapEntry<$core.String, $fixnum.Int64>>? destinations,
    $fixnum.Int64? feeRateSatPerVbyte,
    $core.bool? subtractFeeFromAmount,
    $core.Iterable<UnspentOutput>? requiredInputs,
    $core.bool? allowReplay,
  }) {
    final result = PreviewSendRequest._();
    if (walletId != null) result.walletId = walletId;
    if (destinations != null) result.destinations.addEntries(destinations);
    if (feeRateSatPerVbyte != null) result.feeRateSatPerVbyte = feeRateSatPerVbyte;
    if (subtractFeeFromAmount != null) result.subtractFeeFromAmount = subtractFeeFromAmount;
    if (requiredInputs != null) result.requiredInputs.addAll(requiredInputs);
    if (allowReplay != null) result.allowReplay = allowReplay;
    return result;
  }

  PreviewSendRequest._();

  factory PreviewSendRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PreviewSendRequest()..mergeFromBuffer(data, registry);
  factory PreviewSendRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PreviewSendRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PreviewSendRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: PreviewSendRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..m<$core.String, $fixnum.Int64>(2, _omitFieldNames ? '' : 'destinations',
        entryClassName: 'PreviewSendRequest.DestinationsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O6,
        packageName: const $pb.PackageName('walletmanager.v1'))
    ..aInt64(3, _omitFieldNames ? '' : 'feeRateSatPerVbyte')
    ..aOB(4, _omitFieldNames ? '' : 'subtractFeeFromAmount')
    ..pPM<UnspentOutput>(5, _omitFieldNames ? '' : 'requiredInputs', subBuilder: UnspentOutput.$_createMessage)
    ..aOB(6, _omitFieldNames ? '' : 'allowReplay')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewSendRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewSendRequest copyWith(void Function(PreviewSendRequest) updates) =>
      super.copyWith((message) => updates(message as PreviewSendRequest)) as PreviewSendRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PreviewSendRequest() / PreviewSendRequest.new instead')
  static PreviewSendRequest create() => PreviewSendRequest._();
  static $pb.GeneratedMessage $_createMessage() => PreviewSendRequest._();
  @$core.override
  PreviewSendRequest createEmptyInstance() => PreviewSendRequest._();
  @$core.pragma('dart2js:noInline')
  static PreviewSendRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PreviewSendRequest>(PreviewSendRequest.$_createMessage);
  static PreviewSendRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbMap<$core.String, $fixnum.Int64> get destinations => $_getMap(1);

  @$pb.TagNumber(3)
  $fixnum.Int64 get feeRateSatPerVbyte => $_getI64(2);
  @$pb.TagNumber(3)
  set feeRateSatPerVbyte($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFeeRateSatPerVbyte() => $_has(2);
  @$pb.TagNumber(3)
  void clearFeeRateSatPerVbyte() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get subtractFeeFromAmount => $_getBF(3);
  @$pb.TagNumber(4)
  set subtractFeeFromAmount($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSubtractFeeFromAmount() => $_has(3);
  @$pb.TagNumber(4)
  void clearSubtractFeeFromAmount() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<UnspentOutput> get requiredInputs => $_getList(4);

  @$pb.TagNumber(6)
  $core.bool get allowReplay => $_getBF(5);
  @$pb.TagNumber(6)
  set allowReplay($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAllowReplay() => $_has(5);
  @$pb.TagNumber(6)
  void clearAllowReplay() => $_clearField(6);
}

class PreviewSendResponse extends $pb.GeneratedMessage {
  factory PreviewSendResponse({
    $fixnum.Int64? feeSats,
    $fixnum.Int64? vsizeVbytes,
    $core.Iterable<UnspentOutput>? inputs,
    $fixnum.Int64? notificationFeeSats,
    UnspentOutput? notificationInput,
    $core.bool? feeIsEstimate,
  }) {
    final result = PreviewSendResponse._();
    if (feeSats != null) result.feeSats = feeSats;
    if (vsizeVbytes != null) result.vsizeVbytes = vsizeVbytes;
    if (inputs != null) result.inputs.addAll(inputs);
    if (notificationFeeSats != null) result.notificationFeeSats = notificationFeeSats;
    if (notificationInput != null) result.notificationInput = notificationInput;
    if (feeIsEstimate != null) result.feeIsEstimate = feeIsEstimate;
    return result;
  }

  PreviewSendResponse._();

  factory PreviewSendResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PreviewSendResponse()..mergeFromBuffer(data, registry);
  factory PreviewSendResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PreviewSendResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PreviewSendResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: PreviewSendResponse.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'feeSats')
    ..aInt64(2, _omitFieldNames ? '' : 'vsizeVbytes')
    ..pPM<UnspentOutput>(3, _omitFieldNames ? '' : 'inputs', subBuilder: UnspentOutput.$_createMessage)
    ..aInt64(4, _omitFieldNames ? '' : 'notificationFeeSats')
    ..aOM<UnspentOutput>(5, _omitFieldNames ? '' : 'notificationInput', subBuilder: UnspentOutput.$_createMessage)
    ..aOB(6, _omitFieldNames ? '' : 'feeIsEstimate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewSendResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewSendResponse copyWith(void Function(PreviewSendResponse) updates) =>
      super.copyWith((message) => updates(message as PreviewSendResponse)) as PreviewSendResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PreviewSendResponse() / PreviewSendResponse.new instead')
  static PreviewSendResponse create() => PreviewSendResponse._();
  static $pb.GeneratedMessage $_createMessage() => PreviewSendResponse._();
  @$core.override
  PreviewSendResponse createEmptyInstance() => PreviewSendResponse._();
  @$core.pragma('dart2js:noInline')
  static PreviewSendResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PreviewSendResponse>(PreviewSendResponse.$_createMessage);
  static PreviewSendResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get feeSats => $_getI64(0);
  @$pb.TagNumber(1)
  set feeSats($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFeeSats() => $_has(0);
  @$pb.TagNumber(1)
  void clearFeeSats() => $_clearField(1);

  /// Size of the signed transaction.
  @$pb.TagNumber(2)
  $fixnum.Int64 get vsizeVbytes => $_getI64(1);
  @$pb.TagNumber(2)
  set vsizeVbytes($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVsizeVbytes() => $_has(1);
  @$pb.TagNumber(2)
  void clearVsizeVbytes() => $_clearField(2);

  /// The coins the send spends. A send that pins them pays fee_sats.
  @$pb.TagNumber(3)
  $pb.PbList<UnspentOutput> get inputs => $_getList(2);

  /// Fee of the BIP47 notification a first payment publishes before the
  /// payment. 0 when the send publishes none.
  @$pb.TagNumber(4)
  $fixnum.Int64 get notificationFeeSats => $_getI64(3);
  @$pb.TagNumber(4)
  set notificationFeeSats($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNotificationFeeSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearNotificationFeeSats() => $_clearField(4);

  /// The coin the notification spends. Unset when the send publishes none.
  @$pb.TagNumber(5)
  UnspentOutput get notificationInput => $_getN(4);
  @$pb.TagNumber(5)
  set notificationInput(UnspentOutput value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasNotificationInput() => $_has(4);
  @$pb.TagNumber(5)
  void clearNotificationInput() => $_clearField(5);
  @$pb.TagNumber(5)
  UnspentOutput ensureNotificationInput() => $_ensure(4);

  /// True when fee_sats and notification_fee_sats are estimates: a first BIP47
  /// payment from a one-coin wallet pays from the notification change, so
  /// inputs and notification_input stay empty.
  @$pb.TagNumber(6)
  $core.bool get feeIsEstimate => $_getBF(5);
  @$pb.TagNumber(6)
  set feeIsEstimate($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFeeIsEstimate() => $_has(5);
  @$pb.TagNumber(6)
  void clearFeeIsEstimate() => $_clearField(6);
}

class SetFrozenCoinsRequest extends $pb.GeneratedMessage {
  factory SetFrozenCoinsRequest({
    $core.Iterable<FrozenOutpoint>? outpoints,
  }) {
    final result = SetFrozenCoinsRequest._();
    if (outpoints != null) result.outpoints.addAll(outpoints);
    return result;
  }

  SetFrozenCoinsRequest._();

  factory SetFrozenCoinsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetFrozenCoinsRequest()..mergeFromBuffer(data, registry);
  factory SetFrozenCoinsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetFrozenCoinsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetFrozenCoinsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: SetFrozenCoinsRequest.$_createMessage)
    ..pPM<FrozenOutpoint>(1, _omitFieldNames ? '' : 'outpoints', subBuilder: FrozenOutpoint.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFrozenCoinsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetFrozenCoinsRequest copyWith(void Function(SetFrozenCoinsRequest) updates) =>
      super.copyWith((message) => updates(message as SetFrozenCoinsRequest)) as SetFrozenCoinsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetFrozenCoinsRequest() / SetFrozenCoinsRequest.new instead')
  static SetFrozenCoinsRequest create() => SetFrozenCoinsRequest._();
  static $pb.GeneratedMessage $_createMessage() => SetFrozenCoinsRequest._();
  @$core.override
  SetFrozenCoinsRequest createEmptyInstance() => SetFrozenCoinsRequest._();
  @$core.pragma('dart2js:noInline')
  static SetFrozenCoinsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetFrozenCoinsRequest>(SetFrozenCoinsRequest.$_createMessage);
  static SetFrozenCoinsRequest? _defaultInstance;

  /// The whole frozen set of this install. An outpoint names one coin of one
  /// wallet, so the set covers every wallet at once. An empty list frees all.
  @$pb.TagNumber(1)
  $pb.PbList<FrozenOutpoint> get outpoints => $_getList(0);
}

class FrozenOutpoint extends $pb.GeneratedMessage {
  factory FrozenOutpoint({
    $core.String? txid,
    $core.int? vout,
  }) {
    final result = FrozenOutpoint._();
    if (txid != null) result.txid = txid;
    if (vout != null) result.vout = vout;
    return result;
  }

  FrozenOutpoint._();

  factory FrozenOutpoint.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FrozenOutpoint()..mergeFromBuffer(data, registry);
  factory FrozenOutpoint.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FrozenOutpoint()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FrozenOutpoint',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: FrozenOutpoint.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aI(2, _omitFieldNames ? '' : 'vout')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FrozenOutpoint clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FrozenOutpoint copyWith(void Function(FrozenOutpoint) updates) =>
      super.copyWith((message) => updates(message as FrozenOutpoint)) as FrozenOutpoint;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FrozenOutpoint() / FrozenOutpoint.new instead')
  static FrozenOutpoint create() => FrozenOutpoint._();
  static $pb.GeneratedMessage $_createMessage() => FrozenOutpoint._();
  @$core.override
  FrozenOutpoint createEmptyInstance() => FrozenOutpoint._();
  @$core.pragma('dart2js:noInline')
  static FrozenOutpoint getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FrozenOutpoint>(FrozenOutpoint.$_createMessage);
  static FrozenOutpoint? _defaultInstance;

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
  set vout($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearVout() => $_clearField(2);
}

/// RawOutput is a transaction output with a caller-supplied scriptPubKey.
class RawOutput extends $pb.GeneratedMessage {
  factory RawOutput({
    $fixnum.Int64? valueSats,
    $core.String? scriptHex,
  }) {
    final result = RawOutput._();
    if (valueSats != null) result.valueSats = valueSats;
    if (scriptHex != null) result.scriptHex = scriptHex;
    return result;
  }

  RawOutput._();

  factory RawOutput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RawOutput()..mergeFromBuffer(data, registry);
  factory RawOutput.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      RawOutput()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RawOutput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: RawOutput.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'valueSats')
    ..aOS(2, _omitFieldNames ? '' : 'scriptHex')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RawOutput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  RawOutput copyWith(void Function(RawOutput) updates) =>
      super.copyWith((message) => updates(message as RawOutput)) as RawOutput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use RawOutput() / RawOutput.new instead')
  static RawOutput create() => RawOutput._();
  static $pb.GeneratedMessage $_createMessage() => RawOutput._();
  @$core.override
  RawOutput createEmptyInstance() => RawOutput._();
  @$core.pragma('dart2js:noInline')
  static RawOutput getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RawOutput>(RawOutput.$_createMessage);
  static RawOutput? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get valueSats => $_getI64(0);
  @$pb.TagNumber(1)
  set valueSats($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasValueSats() => $_has(0);
  @$pb.TagNumber(1)
  void clearValueSats() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get scriptHex => $_getSZ(1);
  @$pb.TagNumber(2)
  set scriptHex($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasScriptHex() => $_has(1);
  @$pb.TagNumber(2)
  void clearScriptHex() => $_clearField(2);
}

/// ExternalInput is a UTXO spent by the transaction that the wallet does not own
/// and does not sign — its script must be satisfiable with an empty scriptSig.
class ExternalInput extends $pb.GeneratedMessage {
  factory ExternalInput({
    $core.String? txid,
    $core.int? vout,
    $fixnum.Int64? valueSats,
    $core.String? scriptPubkeyHex,
  }) {
    final result = ExternalInput._();
    if (txid != null) result.txid = txid;
    if (vout != null) result.vout = vout;
    if (valueSats != null) result.valueSats = valueSats;
    if (scriptPubkeyHex != null) result.scriptPubkeyHex = scriptPubkeyHex;
    return result;
  }

  ExternalInput._();

  factory ExternalInput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExternalInput()..mergeFromBuffer(data, registry);
  factory ExternalInput.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExternalInput()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ExternalInput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ExternalInput.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aI(2, _omitFieldNames ? '' : 'vout')
    ..aInt64(3, _omitFieldNames ? '' : 'valueSats')
    ..aOS(4, _omitFieldNames ? '' : 'scriptPubkeyHex')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExternalInput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExternalInput copyWith(void Function(ExternalInput) updates) =>
      super.copyWith((message) => updates(message as ExternalInput)) as ExternalInput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ExternalInput() / ExternalInput.new instead')
  static ExternalInput create() => ExternalInput._();
  static $pb.GeneratedMessage $_createMessage() => ExternalInput._();
  @$core.override
  ExternalInput createEmptyInstance() => ExternalInput._();
  @$core.pragma('dart2js:noInline')
  static ExternalInput getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ExternalInput>(ExternalInput.$_createMessage);
  static ExternalInput? _defaultInstance;

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
  set vout($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearVout() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get valueSats => $_getI64(2);
  @$pb.TagNumber(3)
  set valueSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasValueSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearValueSats() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get scriptPubkeyHex => $_getSZ(3);
  @$pb.TagNumber(4)
  set scriptPubkeyHex($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasScriptPubkeyHex() => $_has(3);
  @$pb.TagNumber(4)
  void clearScriptPubkeyHex() => $_clearField(4);
}

class CreatePsbtRequest extends $pb.GeneratedMessage {
  factory CreatePsbtRequest({
    $core.String? walletId,
    $core.Iterable<$core.MapEntry<$core.String, $fixnum.Int64>>? destinations,
    $fixnum.Int64? feeRateSatPerVbyte,
    $core.bool? subtractFeeFromAmount,
    $core.String? opReturnHex,
    $fixnum.Int64? fixedFeeSats,
    $core.Iterable<UnspentOutput>? requiredInputs,
    $core.Iterable<RawOutput>? rawOutputs,
    $core.Iterable<ExternalInput>? externalInputs,
    $core.bool? allowReplay,
  }) {
    final result = CreatePsbtRequest._();
    if (walletId != null) result.walletId = walletId;
    if (destinations != null) result.destinations.addEntries(destinations);
    if (feeRateSatPerVbyte != null) result.feeRateSatPerVbyte = feeRateSatPerVbyte;
    if (subtractFeeFromAmount != null) result.subtractFeeFromAmount = subtractFeeFromAmount;
    if (opReturnHex != null) result.opReturnHex = opReturnHex;
    if (fixedFeeSats != null) result.fixedFeeSats = fixedFeeSats;
    if (requiredInputs != null) result.requiredInputs.addAll(requiredInputs);
    if (rawOutputs != null) result.rawOutputs.addAll(rawOutputs);
    if (externalInputs != null) result.externalInputs.addAll(externalInputs);
    if (allowReplay != null) result.allowReplay = allowReplay;
    return result;
  }

  CreatePsbtRequest._();

  factory CreatePsbtRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreatePsbtRequest()..mergeFromBuffer(data, registry);
  factory CreatePsbtRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreatePsbtRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreatePsbtRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: CreatePsbtRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..m<$core.String, $fixnum.Int64>(2, _omitFieldNames ? '' : 'destinations',
        entryClassName: 'CreatePsbtRequest.DestinationsEntry',
        keyFieldType: $pb.PbFieldType.OS,
        valueFieldType: $pb.PbFieldType.O6,
        packageName: const $pb.PackageName('walletmanager.v1'))
    ..aInt64(3, _omitFieldNames ? '' : 'feeRateSatPerVbyte')
    ..aOB(4, _omitFieldNames ? '' : 'subtractFeeFromAmount')
    ..aOS(5, _omitFieldNames ? '' : 'opReturnHex')
    ..aInt64(6, _omitFieldNames ? '' : 'fixedFeeSats')
    ..pPM<UnspentOutput>(7, _omitFieldNames ? '' : 'requiredInputs', subBuilder: UnspentOutput.$_createMessage)
    ..pPM<RawOutput>(8, _omitFieldNames ? '' : 'rawOutputs', subBuilder: RawOutput.$_createMessage)
    ..pPM<ExternalInput>(9, _omitFieldNames ? '' : 'externalInputs', subBuilder: ExternalInput.$_createMessage)
    ..aOB(11, _omitFieldNames ? '' : 'allowReplay')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreatePsbtRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreatePsbtRequest copyWith(void Function(CreatePsbtRequest) updates) =>
      super.copyWith((message) => updates(message as CreatePsbtRequest)) as CreatePsbtRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreatePsbtRequest() / CreatePsbtRequest.new instead')
  static CreatePsbtRequest create() => CreatePsbtRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreatePsbtRequest._();
  @$core.override
  CreatePsbtRequest createEmptyInstance() => CreatePsbtRequest._();
  @$core.pragma('dart2js:noInline')
  static CreatePsbtRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreatePsbtRequest>(CreatePsbtRequest.$_createMessage);
  static CreatePsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbMap<$core.String, $fixnum.Int64> get destinations => $_getMap(1);

  @$pb.TagNumber(3)
  $fixnum.Int64 get feeRateSatPerVbyte => $_getI64(2);
  @$pb.TagNumber(3)
  set feeRateSatPerVbyte($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFeeRateSatPerVbyte() => $_has(2);
  @$pb.TagNumber(3)
  void clearFeeRateSatPerVbyte() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get subtractFeeFromAmount => $_getBF(3);
  @$pb.TagNumber(4)
  set subtractFeeFromAmount($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSubtractFeeFromAmount() => $_has(3);
  @$pb.TagNumber(4)
  void clearSubtractFeeFromAmount() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get opReturnHex => $_getSZ(4);
  @$pb.TagNumber(5)
  set opReturnHex($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasOpReturnHex() => $_has(4);
  @$pb.TagNumber(5)
  void clearOpReturnHex() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get fixedFeeSats => $_getI64(5);
  @$pb.TagNumber(6)
  set fixedFeeSats($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFixedFeeSats() => $_has(5);
  @$pb.TagNumber(6)
  void clearFixedFeeSats() => $_clearField(6);

  @$pb.TagNumber(7)
  $pb.PbList<UnspentOutput> get requiredInputs => $_getList(6);

  @$pb.TagNumber(8)
  $pb.PbList<RawOutput> get rawOutputs => $_getList(7);

  @$pb.TagNumber(9)
  $pb.PbList<ExternalInput> get externalInputs => $_getList(8);

  /// Build a PSBT that can replay onto Bitcoin. The eCash network stamps the
  /// magic nLockTime (499999999) on every PSBT; this drops that stamp for one
  /// PSBT.
  @$pb.TagNumber(11)
  $core.bool get allowReplay => $_getBF(9);
  @$pb.TagNumber(11)
  set allowReplay($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(11)
  $core.bool hasAllowReplay() => $_has(9);
  @$pb.TagNumber(11)
  void clearAllowReplay() => $_clearField(11);
}

class CreatePsbtResponse extends $pb.GeneratedMessage {
  factory CreatePsbtResponse({
    $core.String? psbtBase64,
  }) {
    final result = CreatePsbtResponse._();
    if (psbtBase64 != null) result.psbtBase64 = psbtBase64;
    return result;
  }

  CreatePsbtResponse._();

  factory CreatePsbtResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreatePsbtResponse()..mergeFromBuffer(data, registry);
  factory CreatePsbtResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreatePsbtResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreatePsbtResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: CreatePsbtResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'psbtBase64')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreatePsbtResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreatePsbtResponse copyWith(void Function(CreatePsbtResponse) updates) =>
      super.copyWith((message) => updates(message as CreatePsbtResponse)) as CreatePsbtResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreatePsbtResponse() / CreatePsbtResponse.new instead')
  static CreatePsbtResponse create() => CreatePsbtResponse._();
  static $pb.GeneratedMessage $_createMessage() => CreatePsbtResponse._();
  @$core.override
  CreatePsbtResponse createEmptyInstance() => CreatePsbtResponse._();
  @$core.pragma('dart2js:noInline')
  static CreatePsbtResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreatePsbtResponse>(CreatePsbtResponse.$_createMessage);
  static CreatePsbtResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbtBase64 => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbtBase64($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPsbtBase64() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbtBase64() => $_clearField(1);
}

class SignPsbtRequest extends $pb.GeneratedMessage {
  factory SignPsbtRequest({
    $core.String? walletId,
    $core.String? psbtBase64,
  }) {
    final result = SignPsbtRequest._();
    if (walletId != null) result.walletId = walletId;
    if (psbtBase64 != null) result.psbtBase64 = psbtBase64;
    return result;
  }

  SignPsbtRequest._();

  factory SignPsbtRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignPsbtRequest()..mergeFromBuffer(data, registry);
  factory SignPsbtRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignPsbtRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignPsbtRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: SignPsbtRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aOS(2, _omitFieldNames ? '' : 'psbtBase64')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignPsbtRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignPsbtRequest copyWith(void Function(SignPsbtRequest) updates) =>
      super.copyWith((message) => updates(message as SignPsbtRequest)) as SignPsbtRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SignPsbtRequest() / SignPsbtRequest.new instead')
  static SignPsbtRequest create() => SignPsbtRequest._();
  static $pb.GeneratedMessage $_createMessage() => SignPsbtRequest._();
  @$core.override
  SignPsbtRequest createEmptyInstance() => SignPsbtRequest._();
  @$core.pragma('dart2js:noInline')
  static SignPsbtRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignPsbtRequest>(SignPsbtRequest.$_createMessage);
  static SignPsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get psbtBase64 => $_getSZ(1);
  @$pb.TagNumber(2)
  set psbtBase64($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPsbtBase64() => $_has(1);
  @$pb.TagNumber(2)
  void clearPsbtBase64() => $_clearField(2);
}

class SignPsbtResponse extends $pb.GeneratedMessage {
  factory SignPsbtResponse({
    $core.String? psbtBase64,
  }) {
    final result = SignPsbtResponse._();
    if (psbtBase64 != null) result.psbtBase64 = psbtBase64;
    return result;
  }

  SignPsbtResponse._();

  factory SignPsbtResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignPsbtResponse()..mergeFromBuffer(data, registry);
  factory SignPsbtResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignPsbtResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignPsbtResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: SignPsbtResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'psbtBase64')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignPsbtResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignPsbtResponse copyWith(void Function(SignPsbtResponse) updates) =>
      super.copyWith((message) => updates(message as SignPsbtResponse)) as SignPsbtResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SignPsbtResponse() / SignPsbtResponse.new instead')
  static SignPsbtResponse create() => SignPsbtResponse._();
  static $pb.GeneratedMessage $_createMessage() => SignPsbtResponse._();
  @$core.override
  SignPsbtResponse createEmptyInstance() => SignPsbtResponse._();
  @$core.pragma('dart2js:noInline')
  static SignPsbtResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignPsbtResponse>(SignPsbtResponse.$_createMessage);
  static SignPsbtResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbtBase64 => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbtBase64($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPsbtBase64() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbtBase64() => $_clearField(1);
}

class SignPsbtWithCosignerRequest extends $pb.GeneratedMessage {
  factory SignPsbtWithCosignerRequest({
    $core.String? walletId,
    $core.String? psbtBase64,
    $core.String? cosignerXpub,
  }) {
    final result = SignPsbtWithCosignerRequest._();
    if (walletId != null) result.walletId = walletId;
    if (psbtBase64 != null) result.psbtBase64 = psbtBase64;
    if (cosignerXpub != null) result.cosignerXpub = cosignerXpub;
    return result;
  }

  SignPsbtWithCosignerRequest._();

  factory SignPsbtWithCosignerRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignPsbtWithCosignerRequest()..mergeFromBuffer(data, registry);
  factory SignPsbtWithCosignerRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignPsbtWithCosignerRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignPsbtWithCosignerRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: SignPsbtWithCosignerRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aOS(2, _omitFieldNames ? '' : 'psbtBase64')
    ..aOS(3, _omitFieldNames ? '' : 'cosignerXpub')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignPsbtWithCosignerRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignPsbtWithCosignerRequest copyWith(void Function(SignPsbtWithCosignerRequest) updates) =>
      super.copyWith((message) => updates(message as SignPsbtWithCosignerRequest)) as SignPsbtWithCosignerRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SignPsbtWithCosignerRequest() / SignPsbtWithCosignerRequest.new instead')
  static SignPsbtWithCosignerRequest create() => SignPsbtWithCosignerRequest._();
  static $pb.GeneratedMessage $_createMessage() => SignPsbtWithCosignerRequest._();
  @$core.override
  SignPsbtWithCosignerRequest createEmptyInstance() => SignPsbtWithCosignerRequest._();
  @$core.pragma('dart2js:noInline')
  static SignPsbtWithCosignerRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SignPsbtWithCosignerRequest>(SignPsbtWithCosignerRequest.$_createMessage);
  static SignPsbtWithCosignerRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get psbtBase64 => $_getSZ(1);
  @$pb.TagNumber(2)
  set psbtBase64($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPsbtBase64() => $_has(1);
  @$pb.TagNumber(2)
  void clearPsbtBase64() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get cosignerXpub => $_getSZ(2);
  @$pb.TagNumber(3)
  set cosignerXpub($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCosignerXpub() => $_has(2);
  @$pb.TagNumber(3)
  void clearCosignerXpub() => $_clearField(3);
}

class SignPsbtWithCosignerResponse extends $pb.GeneratedMessage {
  factory SignPsbtWithCosignerResponse({
    $core.String? psbtBase64,
  }) {
    final result = SignPsbtWithCosignerResponse._();
    if (psbtBase64 != null) result.psbtBase64 = psbtBase64;
    return result;
  }

  SignPsbtWithCosignerResponse._();

  factory SignPsbtWithCosignerResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignPsbtWithCosignerResponse()..mergeFromBuffer(data, registry);
  factory SignPsbtWithCosignerResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignPsbtWithCosignerResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignPsbtWithCosignerResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: SignPsbtWithCosignerResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'psbtBase64')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignPsbtWithCosignerResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignPsbtWithCosignerResponse copyWith(void Function(SignPsbtWithCosignerResponse) updates) =>
      super.copyWith((message) => updates(message as SignPsbtWithCosignerResponse)) as SignPsbtWithCosignerResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SignPsbtWithCosignerResponse() / SignPsbtWithCosignerResponse.new instead')
  static SignPsbtWithCosignerResponse create() => SignPsbtWithCosignerResponse._();
  static $pb.GeneratedMessage $_createMessage() => SignPsbtWithCosignerResponse._();
  @$core.override
  SignPsbtWithCosignerResponse createEmptyInstance() => SignPsbtWithCosignerResponse._();
  @$core.pragma('dart2js:noInline')
  static SignPsbtWithCosignerResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SignPsbtWithCosignerResponse>(SignPsbtWithCosignerResponse.$_createMessage);
  static SignPsbtWithCosignerResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbtBase64 => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbtBase64($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPsbtBase64() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbtBase64() => $_clearField(1);
}

class CombinePsbtRequest extends $pb.GeneratedMessage {
  factory CombinePsbtRequest({
    $core.Iterable<$core.String>? psbtBase64,
  }) {
    final result = CombinePsbtRequest._();
    if (psbtBase64 != null) result.psbtBase64.addAll(psbtBase64);
    return result;
  }

  CombinePsbtRequest._();

  factory CombinePsbtRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CombinePsbtRequest()..mergeFromBuffer(data, registry);
  factory CombinePsbtRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CombinePsbtRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CombinePsbtRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: CombinePsbtRequest.$_createMessage)
    ..pPS(1, _omitFieldNames ? '' : 'psbtBase64')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CombinePsbtRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CombinePsbtRequest copyWith(void Function(CombinePsbtRequest) updates) =>
      super.copyWith((message) => updates(message as CombinePsbtRequest)) as CombinePsbtRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CombinePsbtRequest() / CombinePsbtRequest.new instead')
  static CombinePsbtRequest create() => CombinePsbtRequest._();
  static $pb.GeneratedMessage $_createMessage() => CombinePsbtRequest._();
  @$core.override
  CombinePsbtRequest createEmptyInstance() => CombinePsbtRequest._();
  @$core.pragma('dart2js:noInline')
  static CombinePsbtRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CombinePsbtRequest>(CombinePsbtRequest.$_createMessage);
  static CombinePsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get psbtBase64 => $_getList(0);
}

class CombinePsbtResponse extends $pb.GeneratedMessage {
  factory CombinePsbtResponse({
    $core.String? psbtBase64,
  }) {
    final result = CombinePsbtResponse._();
    if (psbtBase64 != null) result.psbtBase64 = psbtBase64;
    return result;
  }

  CombinePsbtResponse._();

  factory CombinePsbtResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CombinePsbtResponse()..mergeFromBuffer(data, registry);
  factory CombinePsbtResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CombinePsbtResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CombinePsbtResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: CombinePsbtResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'psbtBase64')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CombinePsbtResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CombinePsbtResponse copyWith(void Function(CombinePsbtResponse) updates) =>
      super.copyWith((message) => updates(message as CombinePsbtResponse)) as CombinePsbtResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CombinePsbtResponse() / CombinePsbtResponse.new instead')
  static CombinePsbtResponse create() => CombinePsbtResponse._();
  static $pb.GeneratedMessage $_createMessage() => CombinePsbtResponse._();
  @$core.override
  CombinePsbtResponse createEmptyInstance() => CombinePsbtResponse._();
  @$core.pragma('dart2js:noInline')
  static CombinePsbtResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CombinePsbtResponse>(CombinePsbtResponse.$_createMessage);
  static CombinePsbtResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbtBase64 => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbtBase64($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPsbtBase64() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbtBase64() => $_clearField(1);
}

class FinalizePsbtRequest extends $pb.GeneratedMessage {
  factory FinalizePsbtRequest({
    $core.String? psbtBase64,
  }) {
    final result = FinalizePsbtRequest._();
    if (psbtBase64 != null) result.psbtBase64 = psbtBase64;
    return result;
  }

  FinalizePsbtRequest._();

  factory FinalizePsbtRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FinalizePsbtRequest()..mergeFromBuffer(data, registry);
  factory FinalizePsbtRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FinalizePsbtRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FinalizePsbtRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: FinalizePsbtRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'psbtBase64')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FinalizePsbtRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FinalizePsbtRequest copyWith(void Function(FinalizePsbtRequest) updates) =>
      super.copyWith((message) => updates(message as FinalizePsbtRequest)) as FinalizePsbtRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FinalizePsbtRequest() / FinalizePsbtRequest.new instead')
  static FinalizePsbtRequest create() => FinalizePsbtRequest._();
  static $pb.GeneratedMessage $_createMessage() => FinalizePsbtRequest._();
  @$core.override
  FinalizePsbtRequest createEmptyInstance() => FinalizePsbtRequest._();
  @$core.pragma('dart2js:noInline')
  static FinalizePsbtRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FinalizePsbtRequest>(FinalizePsbtRequest.$_createMessage);
  static FinalizePsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbtBase64 => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbtBase64($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPsbtBase64() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbtBase64() => $_clearField(1);
}

class FinalizePsbtResponse extends $pb.GeneratedMessage {
  factory FinalizePsbtResponse({
    $core.String? rawTxHex,
  }) {
    final result = FinalizePsbtResponse._();
    if (rawTxHex != null) result.rawTxHex = rawTxHex;
    return result;
  }

  FinalizePsbtResponse._();

  factory FinalizePsbtResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FinalizePsbtResponse()..mergeFromBuffer(data, registry);
  factory FinalizePsbtResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FinalizePsbtResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FinalizePsbtResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: FinalizePsbtResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'rawTxHex')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FinalizePsbtResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FinalizePsbtResponse copyWith(void Function(FinalizePsbtResponse) updates) =>
      super.copyWith((message) => updates(message as FinalizePsbtResponse)) as FinalizePsbtResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FinalizePsbtResponse() / FinalizePsbtResponse.new instead')
  static FinalizePsbtResponse create() => FinalizePsbtResponse._();
  static $pb.GeneratedMessage $_createMessage() => FinalizePsbtResponse._();
  @$core.override
  FinalizePsbtResponse createEmptyInstance() => FinalizePsbtResponse._();
  @$core.pragma('dart2js:noInline')
  static FinalizePsbtResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<FinalizePsbtResponse>(FinalizePsbtResponse.$_createMessage);
  static FinalizePsbtResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get rawTxHex => $_getSZ(0);
  @$pb.TagNumber(1)
  set rawTxHex($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRawTxHex() => $_has(0);
  @$pb.TagNumber(1)
  void clearRawTxHex() => $_clearField(1);
}

class MultisigPsbtStatusRequest extends $pb.GeneratedMessage {
  factory MultisigPsbtStatusRequest({
    $core.String? walletId,
    $core.String? psbtBase64,
  }) {
    final result = MultisigPsbtStatusRequest._();
    if (walletId != null) result.walletId = walletId;
    if (psbtBase64 != null) result.psbtBase64 = psbtBase64;
    return result;
  }

  MultisigPsbtStatusRequest._();

  factory MultisigPsbtStatusRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MultisigPsbtStatusRequest()..mergeFromBuffer(data, registry);
  factory MultisigPsbtStatusRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MultisigPsbtStatusRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MultisigPsbtStatusRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: MultisigPsbtStatusRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aOS(2, _omitFieldNames ? '' : 'psbtBase64')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MultisigPsbtStatusRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MultisigPsbtStatusRequest copyWith(void Function(MultisigPsbtStatusRequest) updates) =>
      super.copyWith((message) => updates(message as MultisigPsbtStatusRequest)) as MultisigPsbtStatusRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MultisigPsbtStatusRequest() / MultisigPsbtStatusRequest.new instead')
  static MultisigPsbtStatusRequest create() => MultisigPsbtStatusRequest._();
  static $pb.GeneratedMessage $_createMessage() => MultisigPsbtStatusRequest._();
  @$core.override
  MultisigPsbtStatusRequest createEmptyInstance() => MultisigPsbtStatusRequest._();
  @$core.pragma('dart2js:noInline')
  static MultisigPsbtStatusRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MultisigPsbtStatusRequest>(MultisigPsbtStatusRequest.$_createMessage);
  static MultisigPsbtStatusRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get psbtBase64 => $_getSZ(1);
  @$pb.TagNumber(2)
  set psbtBase64($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPsbtBase64() => $_has(1);
  @$pb.TagNumber(2)
  void clearPsbtBase64() => $_clearField(2);
}

class MultisigPsbtStatusResponse extends $pb.GeneratedMessage {
  factory MultisigPsbtStatusResponse({
    $core.int? threshold,
    $core.int? signatures,
    $core.bool? finalizable,
    $core.Iterable<$core.bool>? cosignerSigned,
  }) {
    final result = MultisigPsbtStatusResponse._();
    if (threshold != null) result.threshold = threshold;
    if (signatures != null) result.signatures = signatures;
    if (finalizable != null) result.finalizable = finalizable;
    if (cosignerSigned != null) result.cosignerSigned.addAll(cosignerSigned);
    return result;
  }

  MultisigPsbtStatusResponse._();

  factory MultisigPsbtStatusResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MultisigPsbtStatusResponse()..mergeFromBuffer(data, registry);
  factory MultisigPsbtStatusResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      MultisigPsbtStatusResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MultisigPsbtStatusResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: MultisigPsbtStatusResponse.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'threshold', fieldType: $pb.PbFieldType.OU3)
    ..aI(2, _omitFieldNames ? '' : 'signatures', fieldType: $pb.PbFieldType.OU3)
    ..aOB(3, _omitFieldNames ? '' : 'finalizable')
    ..p<$core.bool>(4, _omitFieldNames ? '' : 'cosignerSigned', $pb.PbFieldType.KB)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MultisigPsbtStatusResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MultisigPsbtStatusResponse copyWith(void Function(MultisigPsbtStatusResponse) updates) =>
      super.copyWith((message) => updates(message as MultisigPsbtStatusResponse)) as MultisigPsbtStatusResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use MultisigPsbtStatusResponse() / MultisigPsbtStatusResponse.new instead')
  static MultisigPsbtStatusResponse create() => MultisigPsbtStatusResponse._();
  static $pb.GeneratedMessage $_createMessage() => MultisigPsbtStatusResponse._();
  @$core.override
  MultisigPsbtStatusResponse createEmptyInstance() => MultisigPsbtStatusResponse._();
  @$core.pragma('dart2js:noInline')
  static MultisigPsbtStatusResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<MultisigPsbtStatusResponse>(MultisigPsbtStatusResponse.$_createMessage);
  static MultisigPsbtStatusResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get threshold => $_getIZ(0);
  @$pb.TagNumber(1)
  set threshold($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasThreshold() => $_has(0);
  @$pb.TagNumber(1)
  void clearThreshold() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get signatures => $_getIZ(1);
  @$pb.TagNumber(2)
  set signatures($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSignatures() => $_has(1);
  @$pb.TagNumber(2)
  void clearSignatures() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get finalizable => $_getBF(2);
  @$pb.TagNumber(3)
  set finalizable($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFinalizable() => $_has(2);
  @$pb.TagNumber(3)
  void clearFinalizable() => $_clearField(3);

  /// Aligned to the wallet's cosigners; true where that cosigner has signed.
  @$pb.TagNumber(4)
  $pb.PbList<$core.bool> get cosignerSigned => $_getList(3);
}

class BroadcastTransactionRequest extends $pb.GeneratedMessage {
  factory BroadcastTransactionRequest({
    $core.String? walletId,
    $core.String? txHex,
  }) {
    final result = BroadcastTransactionRequest._();
    if (walletId != null) result.walletId = walletId;
    if (txHex != null) result.txHex = txHex;
    return result;
  }

  BroadcastTransactionRequest._();

  factory BroadcastTransactionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BroadcastTransactionRequest()..mergeFromBuffer(data, registry);
  factory BroadcastTransactionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BroadcastTransactionRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BroadcastTransactionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: BroadcastTransactionRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aOS(2, _omitFieldNames ? '' : 'txHex')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BroadcastTransactionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BroadcastTransactionRequest copyWith(void Function(BroadcastTransactionRequest) updates) =>
      super.copyWith((message) => updates(message as BroadcastTransactionRequest)) as BroadcastTransactionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BroadcastTransactionRequest() / BroadcastTransactionRequest.new instead')
  static BroadcastTransactionRequest create() => BroadcastTransactionRequest._();
  static $pb.GeneratedMessage $_createMessage() => BroadcastTransactionRequest._();
  @$core.override
  BroadcastTransactionRequest createEmptyInstance() => BroadcastTransactionRequest._();
  @$core.pragma('dart2js:noInline')
  static BroadcastTransactionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BroadcastTransactionRequest>(BroadcastTransactionRequest.$_createMessage);
  static BroadcastTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get txHex => $_getSZ(1);
  @$pb.TagNumber(2)
  set txHex($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTxHex() => $_has(1);
  @$pb.TagNumber(2)
  void clearTxHex() => $_clearField(2);
}

class BroadcastTransactionResponse extends $pb.GeneratedMessage {
  factory BroadcastTransactionResponse({
    $core.String? txid,
  }) {
    final result = BroadcastTransactionResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  BroadcastTransactionResponse._();

  factory BroadcastTransactionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BroadcastTransactionResponse()..mergeFromBuffer(data, registry);
  factory BroadcastTransactionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BroadcastTransactionResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BroadcastTransactionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: BroadcastTransactionResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BroadcastTransactionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BroadcastTransactionResponse copyWith(void Function(BroadcastTransactionResponse) updates) =>
      super.copyWith((message) => updates(message as BroadcastTransactionResponse)) as BroadcastTransactionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BroadcastTransactionResponse() / BroadcastTransactionResponse.new instead')
  static BroadcastTransactionResponse create() => BroadcastTransactionResponse._();
  static $pb.GeneratedMessage $_createMessage() => BroadcastTransactionResponse._();
  @$core.override
  BroadcastTransactionResponse createEmptyInstance() => BroadcastTransactionResponse._();
  @$core.pragma('dart2js:noInline')
  static BroadcastTransactionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BroadcastTransactionResponse>(BroadcastTransactionResponse.$_createMessage);
  static BroadcastTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class GetAddressUnspentRequest extends $pb.GeneratedMessage {
  factory GetAddressUnspentRequest({
    $core.String? address,
  }) {
    final result = GetAddressUnspentRequest._();
    if (address != null) result.address = address;
    return result;
  }

  GetAddressUnspentRequest._();

  factory GetAddressUnspentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetAddressUnspentRequest()..mergeFromBuffer(data, registry);
  factory GetAddressUnspentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetAddressUnspentRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAddressUnspentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: GetAddressUnspentRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAddressUnspentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAddressUnspentRequest copyWith(void Function(GetAddressUnspentRequest) updates) =>
      super.copyWith((message) => updates(message as GetAddressUnspentRequest)) as GetAddressUnspentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetAddressUnspentRequest() / GetAddressUnspentRequest.new instead')
  static GetAddressUnspentRequest create() => GetAddressUnspentRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetAddressUnspentRequest._();
  @$core.override
  GetAddressUnspentRequest createEmptyInstance() => GetAddressUnspentRequest._();
  @$core.pragma('dart2js:noInline')
  static GetAddressUnspentRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAddressUnspentRequest>(GetAddressUnspentRequest.$_createMessage);
  static GetAddressUnspentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);
}

class AddressUnspentOutput extends $pb.GeneratedMessage {
  factory AddressUnspentOutput({
    $core.String? txid,
    $core.int? vout,
    $fixnum.Int64? valueSats,
    $core.int? confirmations,
    $fixnum.Int64? blockTime,
  }) {
    final result = AddressUnspentOutput._();
    if (txid != null) result.txid = txid;
    if (vout != null) result.vout = vout;
    if (valueSats != null) result.valueSats = valueSats;
    if (confirmations != null) result.confirmations = confirmations;
    if (blockTime != null) result.blockTime = blockTime;
    return result;
  }

  AddressUnspentOutput._();

  factory AddressUnspentOutput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AddressUnspentOutput()..mergeFromBuffer(data, registry);
  factory AddressUnspentOutput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      AddressUnspentOutput()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddressUnspentOutput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: AddressUnspentOutput.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aI(2, _omitFieldNames ? '' : 'vout')
    ..aInt64(3, _omitFieldNames ? '' : 'valueSats')
    ..aI(4, _omitFieldNames ? '' : 'confirmations')
    ..aInt64(5, _omitFieldNames ? '' : 'blockTime')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddressUnspentOutput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  AddressUnspentOutput copyWith(void Function(AddressUnspentOutput) updates) =>
      super.copyWith((message) => updates(message as AddressUnspentOutput)) as AddressUnspentOutput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use AddressUnspentOutput() / AddressUnspentOutput.new instead')
  static AddressUnspentOutput create() => AddressUnspentOutput._();
  static $pb.GeneratedMessage $_createMessage() => AddressUnspentOutput._();
  @$core.override
  AddressUnspentOutput createEmptyInstance() => AddressUnspentOutput._();
  @$core.pragma('dart2js:noInline')
  static AddressUnspentOutput getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<AddressUnspentOutput>(AddressUnspentOutput.$_createMessage);
  static AddressUnspentOutput? _defaultInstance;

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
  set vout($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearVout() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get valueSats => $_getI64(2);
  @$pb.TagNumber(3)
  set valueSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasValueSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearValueSats() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get confirmations => $_getIZ(3);
  @$pb.TagNumber(4)
  set confirmations($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConfirmations() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfirmations() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get blockTime => $_getI64(4);
  @$pb.TagNumber(5)
  set blockTime($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBlockTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearBlockTime() => $_clearField(5);
}

class GetAddressUnspentResponse extends $pb.GeneratedMessage {
  factory GetAddressUnspentResponse({
    $core.Iterable<AddressUnspentOutput>? utxos,
    $core.int? tipHeight,
  }) {
    final result = GetAddressUnspentResponse._();
    if (utxos != null) result.utxos.addAll(utxos);
    if (tipHeight != null) result.tipHeight = tipHeight;
    return result;
  }

  GetAddressUnspentResponse._();

  factory GetAddressUnspentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetAddressUnspentResponse()..mergeFromBuffer(data, registry);
  factory GetAddressUnspentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetAddressUnspentResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAddressUnspentResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: GetAddressUnspentResponse.$_createMessage)
    ..pPM<AddressUnspentOutput>(1, _omitFieldNames ? '' : 'utxos', subBuilder: AddressUnspentOutput.$_createMessage)
    ..aI(2, _omitFieldNames ? '' : 'tipHeight')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAddressUnspentResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetAddressUnspentResponse copyWith(void Function(GetAddressUnspentResponse) updates) =>
      super.copyWith((message) => updates(message as GetAddressUnspentResponse)) as GetAddressUnspentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetAddressUnspentResponse() / GetAddressUnspentResponse.new instead')
  static GetAddressUnspentResponse create() => GetAddressUnspentResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetAddressUnspentResponse._();
  @$core.override
  GetAddressUnspentResponse createEmptyInstance() => GetAddressUnspentResponse._();
  @$core.pragma('dart2js:noInline')
  static GetAddressUnspentResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetAddressUnspentResponse>(GetAddressUnspentResponse.$_createMessage);
  static GetAddressUnspentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<AddressUnspentOutput> get utxos => $_getList(0);

  @$pb.TagNumber(2)
  $core.int get tipHeight => $_getIZ(1);
  @$pb.TagNumber(2)
  set tipHeight($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTipHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearTipHeight() => $_clearField(2);
}

class BroadcastElectrumTransactionRequest extends $pb.GeneratedMessage {
  factory BroadcastElectrumTransactionRequest({
    $core.String? txHex,
  }) {
    final result = BroadcastElectrumTransactionRequest._();
    if (txHex != null) result.txHex = txHex;
    return result;
  }

  BroadcastElectrumTransactionRequest._();

  factory BroadcastElectrumTransactionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BroadcastElectrumTransactionRequest()..mergeFromBuffer(data, registry);
  factory BroadcastElectrumTransactionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BroadcastElectrumTransactionRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BroadcastElectrumTransactionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: BroadcastElectrumTransactionRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txHex')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BroadcastElectrumTransactionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BroadcastElectrumTransactionRequest copyWith(void Function(BroadcastElectrumTransactionRequest) updates) =>
      super.copyWith((message) => updates(message as BroadcastElectrumTransactionRequest))
          as BroadcastElectrumTransactionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BroadcastElectrumTransactionRequest() / BroadcastElectrumTransactionRequest.new instead')
  static BroadcastElectrumTransactionRequest create() => BroadcastElectrumTransactionRequest._();
  static $pb.GeneratedMessage $_createMessage() => BroadcastElectrumTransactionRequest._();
  @$core.override
  BroadcastElectrumTransactionRequest createEmptyInstance() => BroadcastElectrumTransactionRequest._();
  @$core.pragma('dart2js:noInline')
  static BroadcastElectrumTransactionRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BroadcastElectrumTransactionRequest>(
          BroadcastElectrumTransactionRequest.$_createMessage);
  static BroadcastElectrumTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txHex => $_getSZ(0);
  @$pb.TagNumber(1)
  set txHex($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxHex() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxHex() => $_clearField(1);
}

class BroadcastElectrumTransactionResponse extends $pb.GeneratedMessage {
  factory BroadcastElectrumTransactionResponse({
    $core.String? txid,
  }) {
    final result = BroadcastElectrumTransactionResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  BroadcastElectrumTransactionResponse._();

  factory BroadcastElectrumTransactionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BroadcastElectrumTransactionResponse()..mergeFromBuffer(data, registry);
  factory BroadcastElectrumTransactionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BroadcastElectrumTransactionResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BroadcastElectrumTransactionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: BroadcastElectrumTransactionResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BroadcastElectrumTransactionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BroadcastElectrumTransactionResponse copyWith(void Function(BroadcastElectrumTransactionResponse) updates) =>
      super.copyWith((message) => updates(message as BroadcastElectrumTransactionResponse))
          as BroadcastElectrumTransactionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BroadcastElectrumTransactionResponse() / BroadcastElectrumTransactionResponse.new instead')
  static BroadcastElectrumTransactionResponse create() => BroadcastElectrumTransactionResponse._();
  static $pb.GeneratedMessage $_createMessage() => BroadcastElectrumTransactionResponse._();
  @$core.override
  BroadcastElectrumTransactionResponse createEmptyInstance() => BroadcastElectrumTransactionResponse._();
  @$core.pragma('dart2js:noInline')
  static BroadcastElectrumTransactionResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BroadcastElectrumTransactionResponse>(
          BroadcastElectrumTransactionResponse.$_createMessage);
  static BroadcastElectrumTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

/// HardwareDevice is one connected USB signer. error is set when the device was
/// found but could not be opened.
class HardwareDevice extends $pb.GeneratedMessage {
  factory HardwareDevice({
    $core.String? type,
    $core.String? model,
    $core.String? label,
    $core.String? path,
    $core.String? fingerprint,
    $core.bool? needsPin,
    $core.bool? needsPassphrase,
    $core.String? error,
    $core.int? errorCode,
  }) {
    final result = HardwareDevice._();
    if (type != null) result.type = type;
    if (model != null) result.model = model;
    if (label != null) result.label = label;
    if (path != null) result.path = path;
    if (fingerprint != null) result.fingerprint = fingerprint;
    if (needsPin != null) result.needsPin = needsPin;
    if (needsPassphrase != null) result.needsPassphrase = needsPassphrase;
    if (error != null) result.error = error;
    if (errorCode != null) result.errorCode = errorCode;
    return result;
  }

  HardwareDevice._();

  factory HardwareDevice.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HardwareDevice()..mergeFromBuffer(data, registry);
  factory HardwareDevice.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HardwareDevice()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'HardwareDevice',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: HardwareDevice.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'type')
    ..aOS(2, _omitFieldNames ? '' : 'model')
    ..aOS(3, _omitFieldNames ? '' : 'label')
    ..aOS(4, _omitFieldNames ? '' : 'path')
    ..aOS(5, _omitFieldNames ? '' : 'fingerprint')
    ..aOB(6, _omitFieldNames ? '' : 'needsPin')
    ..aOB(7, _omitFieldNames ? '' : 'needsPassphrase')
    ..aOS(8, _omitFieldNames ? '' : 'error')
    ..aI(9, _omitFieldNames ? '' : 'errorCode')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HardwareDevice clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HardwareDevice copyWith(void Function(HardwareDevice) updates) =>
      super.copyWith((message) => updates(message as HardwareDevice)) as HardwareDevice;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HardwareDevice() / HardwareDevice.new instead')
  static HardwareDevice create() => HardwareDevice._();
  static $pb.GeneratedMessage $_createMessage() => HardwareDevice._();
  @$core.override
  HardwareDevice createEmptyInstance() => HardwareDevice._();
  @$core.pragma('dart2js:noInline')
  static HardwareDevice getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<HardwareDevice>(HardwareDevice.$_createMessage);
  static HardwareDevice? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get type => $_getSZ(0);
  @$pb.TagNumber(1)
  set type($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get model => $_getSZ(1);
  @$pb.TagNumber(2)
  set model($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasModel() => $_has(1);
  @$pb.TagNumber(2)
  void clearModel() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get label => $_getSZ(2);
  @$pb.TagNumber(3)
  set label($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasLabel() => $_has(2);
  @$pb.TagNumber(3)
  void clearLabel() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get path => $_getSZ(3);
  @$pb.TagNumber(4)
  set path($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPath() => $_has(3);
  @$pb.TagNumber(4)
  void clearPath() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get fingerprint => $_getSZ(4);
  @$pb.TagNumber(5)
  set fingerprint($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFingerprint() => $_has(4);
  @$pb.TagNumber(5)
  void clearFingerprint() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get needsPin => $_getBF(5);
  @$pb.TagNumber(6)
  set needsPin($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasNeedsPin() => $_has(5);
  @$pb.TagNumber(6)
  void clearNeedsPin() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.bool get needsPassphrase => $_getBF(6);
  @$pb.TagNumber(7)
  set needsPassphrase($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasNeedsPassphrase() => $_has(6);
  @$pb.TagNumber(7)
  void clearNeedsPassphrase() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.String get error => $_getSZ(7);
  @$pb.TagNumber(8)
  set error($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasError() => $_has(7);
  @$pb.TagNumber(8)
  void clearError() => $_clearField(8);

  /// Raw HWI error code: -18 uninitialized, -12 busy/locked, 0 none.
  @$pb.TagNumber(9)
  $core.int get errorCode => $_getIZ(8);
  @$pb.TagNumber(9)
  set errorCode($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasErrorCode() => $_has(8);
  @$pb.TagNumber(9)
  void clearErrorCode() => $_clearField(9);
}

/// HardwareDeviceSelector identifies which device a command targets.
class HardwareDeviceSelector extends $pb.GeneratedMessage {
  factory HardwareDeviceSelector({
    $core.String? type,
    $core.String? path,
    $core.String? fingerprint,
    $core.String? passphrase,
  }) {
    final result = HardwareDeviceSelector._();
    if (type != null) result.type = type;
    if (path != null) result.path = path;
    if (fingerprint != null) result.fingerprint = fingerprint;
    if (passphrase != null) result.passphrase = passphrase;
    return result;
  }

  HardwareDeviceSelector._();

  factory HardwareDeviceSelector.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HardwareDeviceSelector()..mergeFromBuffer(data, registry);
  factory HardwareDeviceSelector.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      HardwareDeviceSelector()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'HardwareDeviceSelector',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: HardwareDeviceSelector.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'type')
    ..aOS(2, _omitFieldNames ? '' : 'path')
    ..aOS(3, _omitFieldNames ? '' : 'fingerprint')
    ..aOS(4, _omitFieldNames ? '' : 'passphrase')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HardwareDeviceSelector clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  HardwareDeviceSelector copyWith(void Function(HardwareDeviceSelector) updates) =>
      super.copyWith((message) => updates(message as HardwareDeviceSelector)) as HardwareDeviceSelector;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use HardwareDeviceSelector() / HardwareDeviceSelector.new instead')
  static HardwareDeviceSelector create() => HardwareDeviceSelector._();
  static $pb.GeneratedMessage $_createMessage() => HardwareDeviceSelector._();
  @$core.override
  HardwareDeviceSelector createEmptyInstance() => HardwareDeviceSelector._();
  @$core.pragma('dart2js:noInline')
  static HardwareDeviceSelector getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<HardwareDeviceSelector>(HardwareDeviceSelector.$_createMessage);
  static HardwareDeviceSelector? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get type => $_getSZ(0);
  @$pb.TagNumber(1)
  set type($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get path => $_getSZ(1);
  @$pb.TagNumber(2)
  set path($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPath() => $_has(1);
  @$pb.TagNumber(2)
  void clearPath() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fingerprint => $_getSZ(2);
  @$pb.TagNumber(3)
  set fingerprint($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFingerprint() => $_has(2);
  @$pb.TagNumber(3)
  void clearFingerprint() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get passphrase => $_getSZ(3);
  @$pb.TagNumber(4)
  set passphrase($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPassphrase() => $_has(3);
  @$pb.TagNumber(4)
  void clearPassphrase() => $_clearField(4);
}

class EnumerateHardwareDevicesRequest extends $pb.GeneratedMessage {
  factory EnumerateHardwareDevicesRequest({
    $core.String? passphrase,
  }) {
    final result = EnumerateHardwareDevicesRequest._();
    if (passphrase != null) result.passphrase = passphrase;
    return result;
  }

  EnumerateHardwareDevicesRequest._();

  factory EnumerateHardwareDevicesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EnumerateHardwareDevicesRequest()..mergeFromBuffer(data, registry);
  factory EnumerateHardwareDevicesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EnumerateHardwareDevicesRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EnumerateHardwareDevicesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: EnumerateHardwareDevicesRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'passphrase')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EnumerateHardwareDevicesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EnumerateHardwareDevicesRequest copyWith(void Function(EnumerateHardwareDevicesRequest) updates) =>
      super.copyWith((message) => updates(message as EnumerateHardwareDevicesRequest))
          as EnumerateHardwareDevicesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EnumerateHardwareDevicesRequest() / EnumerateHardwareDevicesRequest.new instead')
  static EnumerateHardwareDevicesRequest create() => EnumerateHardwareDevicesRequest._();
  static $pb.GeneratedMessage $_createMessage() => EnumerateHardwareDevicesRequest._();
  @$core.override
  EnumerateHardwareDevicesRequest createEmptyInstance() => EnumerateHardwareDevicesRequest._();
  @$core.pragma('dart2js:noInline')
  static EnumerateHardwareDevicesRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EnumerateHardwareDevicesRequest>(
          EnumerateHardwareDevicesRequest.$_createMessage);
  static EnumerateHardwareDevicesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get passphrase => $_getSZ(0);
  @$pb.TagNumber(1)
  set passphrase($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPassphrase() => $_has(0);
  @$pb.TagNumber(1)
  void clearPassphrase() => $_clearField(1);
}

class EnumerateHardwareDevicesResponse extends $pb.GeneratedMessage {
  factory EnumerateHardwareDevicesResponse({
    $core.Iterable<HardwareDevice>? devices,
  }) {
    final result = EnumerateHardwareDevicesResponse._();
    if (devices != null) result.devices.addAll(devices);
    return result;
  }

  EnumerateHardwareDevicesResponse._();

  factory EnumerateHardwareDevicesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EnumerateHardwareDevicesResponse()..mergeFromBuffer(data, registry);
  factory EnumerateHardwareDevicesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EnumerateHardwareDevicesResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EnumerateHardwareDevicesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: EnumerateHardwareDevicesResponse.$_createMessage)
    ..pPM<HardwareDevice>(1, _omitFieldNames ? '' : 'devices', subBuilder: HardwareDevice.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EnumerateHardwareDevicesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EnumerateHardwareDevicesResponse copyWith(void Function(EnumerateHardwareDevicesResponse) updates) =>
      super.copyWith((message) => updates(message as EnumerateHardwareDevicesResponse))
          as EnumerateHardwareDevicesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EnumerateHardwareDevicesResponse() / EnumerateHardwareDevicesResponse.new instead')
  static EnumerateHardwareDevicesResponse create() => EnumerateHardwareDevicesResponse._();
  static $pb.GeneratedMessage $_createMessage() => EnumerateHardwareDevicesResponse._();
  @$core.override
  EnumerateHardwareDevicesResponse createEmptyInstance() => EnumerateHardwareDevicesResponse._();
  @$core.pragma('dart2js:noInline')
  static EnumerateHardwareDevicesResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EnumerateHardwareDevicesResponse>(
          EnumerateHardwareDevicesResponse.$_createMessage);
  static EnumerateHardwareDevicesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<HardwareDevice> get devices => $_getList(0);
}

class GetHardwareXpubRequest extends $pb.GeneratedMessage {
  factory GetHardwareXpubRequest({
    HardwareDeviceSelector? device,
    $core.String? derivationPath,
  }) {
    final result = GetHardwareXpubRequest._();
    if (device != null) result.device = device;
    if (derivationPath != null) result.derivationPath = derivationPath;
    return result;
  }

  GetHardwareXpubRequest._();

  factory GetHardwareXpubRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetHardwareXpubRequest()..mergeFromBuffer(data, registry);
  factory GetHardwareXpubRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetHardwareXpubRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetHardwareXpubRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: GetHardwareXpubRequest.$_createMessage)
    ..aOM<HardwareDeviceSelector>(1, _omitFieldNames ? '' : 'device',
        subBuilder: HardwareDeviceSelector.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'derivationPath')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHardwareXpubRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHardwareXpubRequest copyWith(void Function(GetHardwareXpubRequest) updates) =>
      super.copyWith((message) => updates(message as GetHardwareXpubRequest)) as GetHardwareXpubRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetHardwareXpubRequest() / GetHardwareXpubRequest.new instead')
  static GetHardwareXpubRequest create() => GetHardwareXpubRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetHardwareXpubRequest._();
  @$core.override
  GetHardwareXpubRequest createEmptyInstance() => GetHardwareXpubRequest._();
  @$core.pragma('dart2js:noInline')
  static GetHardwareXpubRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetHardwareXpubRequest>(GetHardwareXpubRequest.$_createMessage);
  static GetHardwareXpubRequest? _defaultInstance;

  @$pb.TagNumber(1)
  HardwareDeviceSelector get device => $_getN(0);
  @$pb.TagNumber(1)
  set device(HardwareDeviceSelector value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDevice() => $_has(0);
  @$pb.TagNumber(1)
  void clearDevice() => $_clearField(1);
  @$pb.TagNumber(1)
  HardwareDeviceSelector ensureDevice() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get derivationPath => $_getSZ(1);
  @$pb.TagNumber(2)
  set derivationPath($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDerivationPath() => $_has(1);
  @$pb.TagNumber(2)
  void clearDerivationPath() => $_clearField(2);
}

class GetHardwareXpubResponse extends $pb.GeneratedMessage {
  factory GetHardwareXpubResponse({
    $core.String? xpub,
  }) {
    final result = GetHardwareXpubResponse._();
    if (xpub != null) result.xpub = xpub;
    return result;
  }

  GetHardwareXpubResponse._();

  factory GetHardwareXpubResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetHardwareXpubResponse()..mergeFromBuffer(data, registry);
  factory GetHardwareXpubResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetHardwareXpubResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetHardwareXpubResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: GetHardwareXpubResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'xpub')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHardwareXpubResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetHardwareXpubResponse copyWith(void Function(GetHardwareXpubResponse) updates) =>
      super.copyWith((message) => updates(message as GetHardwareXpubResponse)) as GetHardwareXpubResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetHardwareXpubResponse() / GetHardwareXpubResponse.new instead')
  static GetHardwareXpubResponse create() => GetHardwareXpubResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetHardwareXpubResponse._();
  @$core.override
  GetHardwareXpubResponse createEmptyInstance() => GetHardwareXpubResponse._();
  @$core.pragma('dart2js:noInline')
  static GetHardwareXpubResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetHardwareXpubResponse>(GetHardwareXpubResponse.$_createMessage);
  static GetHardwareXpubResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get xpub => $_getSZ(0);
  @$pb.TagNumber(1)
  set xpub($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasXpub() => $_has(0);
  @$pb.TagNumber(1)
  void clearXpub() => $_clearField(1);
}

class SignPsbtWithDeviceRequest extends $pb.GeneratedMessage {
  factory SignPsbtWithDeviceRequest({
    HardwareDeviceSelector? device,
    $core.String? psbtBase64,
  }) {
    final result = SignPsbtWithDeviceRequest._();
    if (device != null) result.device = device;
    if (psbtBase64 != null) result.psbtBase64 = psbtBase64;
    return result;
  }

  SignPsbtWithDeviceRequest._();

  factory SignPsbtWithDeviceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignPsbtWithDeviceRequest()..mergeFromBuffer(data, registry);
  factory SignPsbtWithDeviceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignPsbtWithDeviceRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignPsbtWithDeviceRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: SignPsbtWithDeviceRequest.$_createMessage)
    ..aOM<HardwareDeviceSelector>(1, _omitFieldNames ? '' : 'device',
        subBuilder: HardwareDeviceSelector.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'psbtBase64')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignPsbtWithDeviceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignPsbtWithDeviceRequest copyWith(void Function(SignPsbtWithDeviceRequest) updates) =>
      super.copyWith((message) => updates(message as SignPsbtWithDeviceRequest)) as SignPsbtWithDeviceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SignPsbtWithDeviceRequest() / SignPsbtWithDeviceRequest.new instead')
  static SignPsbtWithDeviceRequest create() => SignPsbtWithDeviceRequest._();
  static $pb.GeneratedMessage $_createMessage() => SignPsbtWithDeviceRequest._();
  @$core.override
  SignPsbtWithDeviceRequest createEmptyInstance() => SignPsbtWithDeviceRequest._();
  @$core.pragma('dart2js:noInline')
  static SignPsbtWithDeviceRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SignPsbtWithDeviceRequest>(SignPsbtWithDeviceRequest.$_createMessage);
  static SignPsbtWithDeviceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  HardwareDeviceSelector get device => $_getN(0);
  @$pb.TagNumber(1)
  set device(HardwareDeviceSelector value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDevice() => $_has(0);
  @$pb.TagNumber(1)
  void clearDevice() => $_clearField(1);
  @$pb.TagNumber(1)
  HardwareDeviceSelector ensureDevice() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get psbtBase64 => $_getSZ(1);
  @$pb.TagNumber(2)
  set psbtBase64($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPsbtBase64() => $_has(1);
  @$pb.TagNumber(2)
  void clearPsbtBase64() => $_clearField(2);
}

class SignPsbtWithDeviceResponse extends $pb.GeneratedMessage {
  factory SignPsbtWithDeviceResponse({
    $core.String? psbtBase64,
  }) {
    final result = SignPsbtWithDeviceResponse._();
    if (psbtBase64 != null) result.psbtBase64 = psbtBase64;
    return result;
  }

  SignPsbtWithDeviceResponse._();

  factory SignPsbtWithDeviceResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignPsbtWithDeviceResponse()..mergeFromBuffer(data, registry);
  factory SignPsbtWithDeviceResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SignPsbtWithDeviceResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignPsbtWithDeviceResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: SignPsbtWithDeviceResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'psbtBase64')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignPsbtWithDeviceResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SignPsbtWithDeviceResponse copyWith(void Function(SignPsbtWithDeviceResponse) updates) =>
      super.copyWith((message) => updates(message as SignPsbtWithDeviceResponse)) as SignPsbtWithDeviceResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SignPsbtWithDeviceResponse() / SignPsbtWithDeviceResponse.new instead')
  static SignPsbtWithDeviceResponse create() => SignPsbtWithDeviceResponse._();
  static $pb.GeneratedMessage $_createMessage() => SignPsbtWithDeviceResponse._();
  @$core.override
  SignPsbtWithDeviceResponse createEmptyInstance() => SignPsbtWithDeviceResponse._();
  @$core.pragma('dart2js:noInline')
  static SignPsbtWithDeviceResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SignPsbtWithDeviceResponse>(SignPsbtWithDeviceResponse.$_createMessage);
  static SignPsbtWithDeviceResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbtBase64 => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbtBase64($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPsbtBase64() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbtBase64() => $_clearField(1);
}

class PromptDevicePinRequest extends $pb.GeneratedMessage {
  factory PromptDevicePinRequest({
    HardwareDeviceSelector? device,
  }) {
    final result = PromptDevicePinRequest._();
    if (device != null) result.device = device;
    return result;
  }

  PromptDevicePinRequest._();

  factory PromptDevicePinRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PromptDevicePinRequest()..mergeFromBuffer(data, registry);
  factory PromptDevicePinRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PromptDevicePinRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PromptDevicePinRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: PromptDevicePinRequest.$_createMessage)
    ..aOM<HardwareDeviceSelector>(1, _omitFieldNames ? '' : 'device',
        subBuilder: HardwareDeviceSelector.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PromptDevicePinRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PromptDevicePinRequest copyWith(void Function(PromptDevicePinRequest) updates) =>
      super.copyWith((message) => updates(message as PromptDevicePinRequest)) as PromptDevicePinRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PromptDevicePinRequest() / PromptDevicePinRequest.new instead')
  static PromptDevicePinRequest create() => PromptDevicePinRequest._();
  static $pb.GeneratedMessage $_createMessage() => PromptDevicePinRequest._();
  @$core.override
  PromptDevicePinRequest createEmptyInstance() => PromptDevicePinRequest._();
  @$core.pragma('dart2js:noInline')
  static PromptDevicePinRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PromptDevicePinRequest>(PromptDevicePinRequest.$_createMessage);
  static PromptDevicePinRequest? _defaultInstance;

  @$pb.TagNumber(1)
  HardwareDeviceSelector get device => $_getN(0);
  @$pb.TagNumber(1)
  set device(HardwareDeviceSelector value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDevice() => $_has(0);
  @$pb.TagNumber(1)
  void clearDevice() => $_clearField(1);
  @$pb.TagNumber(1)
  HardwareDeviceSelector ensureDevice() => $_ensure(0);
}

class PromptDevicePinResponse extends $pb.GeneratedMessage {
  factory PromptDevicePinResponse() => PromptDevicePinResponse._();

  PromptDevicePinResponse._();

  factory PromptDevicePinResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PromptDevicePinResponse()..mergeFromBuffer(data, registry);
  factory PromptDevicePinResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PromptDevicePinResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PromptDevicePinResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: PromptDevicePinResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PromptDevicePinResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PromptDevicePinResponse copyWith(void Function(PromptDevicePinResponse) updates) =>
      super.copyWith((message) => updates(message as PromptDevicePinResponse)) as PromptDevicePinResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PromptDevicePinResponse() / PromptDevicePinResponse.new instead')
  static PromptDevicePinResponse create() => PromptDevicePinResponse._();
  static $pb.GeneratedMessage $_createMessage() => PromptDevicePinResponse._();
  @$core.override
  PromptDevicePinResponse createEmptyInstance() => PromptDevicePinResponse._();
  @$core.pragma('dart2js:noInline')
  static PromptDevicePinResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PromptDevicePinResponse>(PromptDevicePinResponse.$_createMessage);
  static PromptDevicePinResponse? _defaultInstance;
}

class SendDevicePinRequest extends $pb.GeneratedMessage {
  factory SendDevicePinRequest({
    HardwareDeviceSelector? device,
    $core.String? pin,
  }) {
    final result = SendDevicePinRequest._();
    if (device != null) result.device = device;
    if (pin != null) result.pin = pin;
    return result;
  }

  SendDevicePinRequest._();

  factory SendDevicePinRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendDevicePinRequest()..mergeFromBuffer(data, registry);
  factory SendDevicePinRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendDevicePinRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendDevicePinRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: SendDevicePinRequest.$_createMessage)
    ..aOM<HardwareDeviceSelector>(1, _omitFieldNames ? '' : 'device',
        subBuilder: HardwareDeviceSelector.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'pin')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendDevicePinRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendDevicePinRequest copyWith(void Function(SendDevicePinRequest) updates) =>
      super.copyWith((message) => updates(message as SendDevicePinRequest)) as SendDevicePinRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SendDevicePinRequest() / SendDevicePinRequest.new instead')
  static SendDevicePinRequest create() => SendDevicePinRequest._();
  static $pb.GeneratedMessage $_createMessage() => SendDevicePinRequest._();
  @$core.override
  SendDevicePinRequest createEmptyInstance() => SendDevicePinRequest._();
  @$core.pragma('dart2js:noInline')
  static SendDevicePinRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendDevicePinRequest>(SendDevicePinRequest.$_createMessage);
  static SendDevicePinRequest? _defaultInstance;

  @$pb.TagNumber(1)
  HardwareDeviceSelector get device => $_getN(0);
  @$pb.TagNumber(1)
  set device(HardwareDeviceSelector value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDevice() => $_has(0);
  @$pb.TagNumber(1)
  void clearDevice() => $_clearField(1);
  @$pb.TagNumber(1)
  HardwareDeviceSelector ensureDevice() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get pin => $_getSZ(1);
  @$pb.TagNumber(2)
  set pin($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPin() => $_has(1);
  @$pb.TagNumber(2)
  void clearPin() => $_clearField(2);
}

class SendDevicePinResponse extends $pb.GeneratedMessage {
  factory SendDevicePinResponse() => SendDevicePinResponse._();

  SendDevicePinResponse._();

  factory SendDevicePinResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendDevicePinResponse()..mergeFromBuffer(data, registry);
  factory SendDevicePinResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SendDevicePinResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SendDevicePinResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: SendDevicePinResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendDevicePinResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SendDevicePinResponse copyWith(void Function(SendDevicePinResponse) updates) =>
      super.copyWith((message) => updates(message as SendDevicePinResponse)) as SendDevicePinResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SendDevicePinResponse() / SendDevicePinResponse.new instead')
  static SendDevicePinResponse create() => SendDevicePinResponse._();
  static $pb.GeneratedMessage $_createMessage() => SendDevicePinResponse._();
  @$core.override
  SendDevicePinResponse createEmptyInstance() => SendDevicePinResponse._();
  @$core.pragma('dart2js:noInline')
  static SendDevicePinResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SendDevicePinResponse>(SendDevicePinResponse.$_createMessage);
  static SendDevicePinResponse? _defaultInstance;
}

class CloseDeviceRequest extends $pb.GeneratedMessage {
  factory CloseDeviceRequest({
    HardwareDeviceSelector? device,
  }) {
    final result = CloseDeviceRequest._();
    if (device != null) result.device = device;
    return result;
  }

  CloseDeviceRequest._();

  factory CloseDeviceRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CloseDeviceRequest()..mergeFromBuffer(data, registry);
  factory CloseDeviceRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CloseDeviceRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CloseDeviceRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: CloseDeviceRequest.$_createMessage)
    ..aOM<HardwareDeviceSelector>(1, _omitFieldNames ? '' : 'device',
        subBuilder: HardwareDeviceSelector.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CloseDeviceRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CloseDeviceRequest copyWith(void Function(CloseDeviceRequest) updates) =>
      super.copyWith((message) => updates(message as CloseDeviceRequest)) as CloseDeviceRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CloseDeviceRequest() / CloseDeviceRequest.new instead')
  static CloseDeviceRequest create() => CloseDeviceRequest._();
  static $pb.GeneratedMessage $_createMessage() => CloseDeviceRequest._();
  @$core.override
  CloseDeviceRequest createEmptyInstance() => CloseDeviceRequest._();
  @$core.pragma('dart2js:noInline')
  static CloseDeviceRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CloseDeviceRequest>(CloseDeviceRequest.$_createMessage);
  static CloseDeviceRequest? _defaultInstance;

  @$pb.TagNumber(1)
  HardwareDeviceSelector get device => $_getN(0);
  @$pb.TagNumber(1)
  set device(HardwareDeviceSelector value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDevice() => $_has(0);
  @$pb.TagNumber(1)
  void clearDevice() => $_clearField(1);
  @$pb.TagNumber(1)
  HardwareDeviceSelector ensureDevice() => $_ensure(0);
}

class CloseDeviceResponse extends $pb.GeneratedMessage {
  factory CloseDeviceResponse() => CloseDeviceResponse._();

  CloseDeviceResponse._();

  factory CloseDeviceResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CloseDeviceResponse()..mergeFromBuffer(data, registry);
  factory CloseDeviceResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CloseDeviceResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CloseDeviceResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: CloseDeviceResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CloseDeviceResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CloseDeviceResponse copyWith(void Function(CloseDeviceResponse) updates) =>
      super.copyWith((message) => updates(message as CloseDeviceResponse)) as CloseDeviceResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CloseDeviceResponse() / CloseDeviceResponse.new instead')
  static CloseDeviceResponse create() => CloseDeviceResponse._();
  static $pb.GeneratedMessage $_createMessage() => CloseDeviceResponse._();
  @$core.override
  CloseDeviceResponse createEmptyInstance() => CloseDeviceResponse._();
  @$core.pragma('dart2js:noInline')
  static CloseDeviceResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CloseDeviceResponse>(CloseDeviceResponse.$_createMessage);
  static CloseDeviceResponse? _defaultInstance;
}

/// DeriveKeystoreRequest carries one source plus the intent to derive from.
class DeriveKeystoreRequest extends $pb.GeneratedMessage {
  factory DeriveKeystoreRequest({
    $core.String? mnemonic,
    $core.String? passphrase,
    HardwareDeviceSelector? device,
    $core.String? rawKey,
    $core.String? scriptType,
    $core.bool? multisig,
    $core.int? account,
    $core.String? derivationPath,
  }) {
    final result = DeriveKeystoreRequest._();
    if (mnemonic != null) result.mnemonic = mnemonic;
    if (passphrase != null) result.passphrase = passphrase;
    if (device != null) result.device = device;
    if (rawKey != null) result.rawKey = rawKey;
    if (scriptType != null) result.scriptType = scriptType;
    if (multisig != null) result.multisig = multisig;
    if (account != null) result.account = account;
    if (derivationPath != null) result.derivationPath = derivationPath;
    return result;
  }

  DeriveKeystoreRequest._();

  factory DeriveKeystoreRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeriveKeystoreRequest()..mergeFromBuffer(data, registry);
  factory DeriveKeystoreRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeriveKeystoreRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeriveKeystoreRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: DeriveKeystoreRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'mnemonic')
    ..aOS(2, _omitFieldNames ? '' : 'passphrase')
    ..aOM<HardwareDeviceSelector>(3, _omitFieldNames ? '' : 'device',
        subBuilder: HardwareDeviceSelector.$_createMessage)
    ..aOS(4, _omitFieldNames ? '' : 'rawKey')
    ..aOS(5, _omitFieldNames ? '' : 'scriptType')
    ..aOB(6, _omitFieldNames ? '' : 'multisig')
    ..aI(7, _omitFieldNames ? '' : 'account', fieldType: $pb.PbFieldType.OU3)
    ..aOS(8, _omitFieldNames ? '' : 'derivationPath')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeriveKeystoreRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeriveKeystoreRequest copyWith(void Function(DeriveKeystoreRequest) updates) =>
      super.copyWith((message) => updates(message as DeriveKeystoreRequest)) as DeriveKeystoreRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DeriveKeystoreRequest() / DeriveKeystoreRequest.new instead')
  static DeriveKeystoreRequest create() => DeriveKeystoreRequest._();
  static $pb.GeneratedMessage $_createMessage() => DeriveKeystoreRequest._();
  @$core.override
  DeriveKeystoreRequest createEmptyInstance() => DeriveKeystoreRequest._();
  @$core.pragma('dart2js:noInline')
  static DeriveKeystoreRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeriveKeystoreRequest>(DeriveKeystoreRequest.$_createMessage);
  static DeriveKeystoreRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mnemonic => $_getSZ(0);
  @$pb.TagNumber(1)
  set mnemonic($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMnemonic() => $_has(0);
  @$pb.TagNumber(1)
  void clearMnemonic() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get passphrase => $_getSZ(1);
  @$pb.TagNumber(2)
  set passphrase($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPassphrase() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassphrase() => $_clearField(2);

  @$pb.TagNumber(3)
  HardwareDeviceSelector get device => $_getN(2);
  @$pb.TagNumber(3)
  set device(HardwareDeviceSelector value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasDevice() => $_has(2);
  @$pb.TagNumber(3)
  void clearDevice() => $_clearField(3);
  @$pb.TagNumber(3)
  HardwareDeviceSelector ensureDevice() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get rawKey => $_getSZ(3);
  @$pb.TagNumber(4)
  set rawKey($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasRawKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearRawKey() => $_clearField(4);

  /// single-sig: "legacy" | "nested-segwit" | "native-segwit" | "taproot";
  /// multisig: "sh" | "sh-wsh" | "wsh" | "tr".
  @$pb.TagNumber(5)
  $core.String get scriptType => $_getSZ(4);
  @$pb.TagNumber(5)
  set scriptType($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasScriptType() => $_has(4);
  @$pb.TagNumber(5)
  void clearScriptType() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get multisig => $_getBF(5);
  @$pb.TagNumber(6)
  set multisig($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasMultisig() => $_has(5);
  @$pb.TagNumber(6)
  void clearMultisig() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get account => $_getIZ(6);
  @$pb.TagNumber(7)
  set account($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAccount() => $_has(6);
  @$pb.TagNumber(7)
  void clearAccount() => $_clearField(7);

  /// Full account path, e.g. "m/48'/1'/0'/2'". Empty uses the standard path for
  /// the script type.
  @$pb.TagNumber(8)
  $core.String get derivationPath => $_getSZ(7);
  @$pb.TagNumber(8)
  set derivationPath($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasDerivationPath() => $_has(7);
  @$pb.TagNumber(8)
  void clearDerivationPath() => $_clearField(8);
}

class DeriveKeystoreResponse extends $pb.GeneratedMessage {
  factory DeriveKeystoreResponse({
    $core.String? xpub,
    $core.String? fingerprint,
    $core.String? originPath,
    $core.String? descriptor,
  }) {
    final result = DeriveKeystoreResponse._();
    if (xpub != null) result.xpub = xpub;
    if (fingerprint != null) result.fingerprint = fingerprint;
    if (originPath != null) result.originPath = originPath;
    if (descriptor != null) result.descriptor = descriptor;
    return result;
  }

  DeriveKeystoreResponse._();

  factory DeriveKeystoreResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeriveKeystoreResponse()..mergeFromBuffer(data, registry);
  factory DeriveKeystoreResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeriveKeystoreResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeriveKeystoreResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: DeriveKeystoreResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'xpub')
    ..aOS(2, _omitFieldNames ? '' : 'fingerprint')
    ..aOS(3, _omitFieldNames ? '' : 'originPath')
    ..aOS(4, _omitFieldNames ? '' : 'descriptor')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeriveKeystoreResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeriveKeystoreResponse copyWith(void Function(DeriveKeystoreResponse) updates) =>
      super.copyWith((message) => updates(message as DeriveKeystoreResponse)) as DeriveKeystoreResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DeriveKeystoreResponse() / DeriveKeystoreResponse.new instead')
  static DeriveKeystoreResponse create() => DeriveKeystoreResponse._();
  static $pb.GeneratedMessage $_createMessage() => DeriveKeystoreResponse._();
  @$core.override
  DeriveKeystoreResponse createEmptyInstance() => DeriveKeystoreResponse._();
  @$core.pragma('dart2js:noInline')
  static DeriveKeystoreResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeriveKeystoreResponse>(DeriveKeystoreResponse.$_createMessage);
  static DeriveKeystoreResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get xpub => $_getSZ(0);
  @$pb.TagNumber(1)
  set xpub($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasXpub() => $_has(0);
  @$pb.TagNumber(1)
  void clearXpub() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fingerprint => $_getSZ(1);
  @$pb.TagNumber(2)
  set fingerprint($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFingerprint() => $_has(1);
  @$pb.TagNumber(2)
  void clearFingerprint() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get originPath => $_getSZ(2);
  @$pb.TagNumber(3)
  set originPath($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOriginPath() => $_has(2);
  @$pb.TagNumber(3)
  void clearOriginPath() => $_clearField(3);

  /// Single-sig watch descriptor for device/raw sources; empty for multisig.
  @$pb.TagNumber(4)
  $core.String get descriptor => $_getSZ(3);
  @$pb.TagNumber(4)
  set descriptor($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDescriptor() => $_has(3);
  @$pb.TagNumber(4)
  void clearDescriptor() => $_clearField(4);
}

class ExploreSeedRequest extends $pb.GeneratedMessage {
  factory ExploreSeedRequest({
    $core.String? mnemonic,
    $core.String? passphrase,
    $core.String? basePath,
    $core.int? startIndex,
    $core.int? count,
  }) {
    final result = ExploreSeedRequest._();
    if (mnemonic != null) result.mnemonic = mnemonic;
    if (passphrase != null) result.passphrase = passphrase;
    if (basePath != null) result.basePath = basePath;
    if (startIndex != null) result.startIndex = startIndex;
    if (count != null) result.count = count;
    return result;
  }

  ExploreSeedRequest._();

  factory ExploreSeedRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExploreSeedRequest()..mergeFromBuffer(data, registry);
  factory ExploreSeedRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExploreSeedRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ExploreSeedRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ExploreSeedRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'mnemonic')
    ..aOS(2, _omitFieldNames ? '' : 'passphrase')
    ..aOS(3, _omitFieldNames ? '' : 'basePath')
    ..aI(4, _omitFieldNames ? '' : 'startIndex', fieldType: $pb.PbFieldType.OU3)
    ..aI(5, _omitFieldNames ? '' : 'count', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExploreSeedRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExploreSeedRequest copyWith(void Function(ExploreSeedRequest) updates) =>
      super.copyWith((message) => updates(message as ExploreSeedRequest)) as ExploreSeedRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ExploreSeedRequest() / ExploreSeedRequest.new instead')
  static ExploreSeedRequest create() => ExploreSeedRequest._();
  static $pb.GeneratedMessage $_createMessage() => ExploreSeedRequest._();
  @$core.override
  ExploreSeedRequest createEmptyInstance() => ExploreSeedRequest._();
  @$core.pragma('dart2js:noInline')
  static ExploreSeedRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ExploreSeedRequest>(ExploreSeedRequest.$_createMessage);
  static ExploreSeedRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mnemonic => $_getSZ(0);
  @$pb.TagNumber(1)
  set mnemonic($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMnemonic() => $_has(0);
  @$pb.TagNumber(1)
  void clearMnemonic() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get passphrase => $_getSZ(1);
  @$pb.TagNumber(2)
  set passphrase($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPassphrase() => $_has(1);
  @$pb.TagNumber(2)
  void clearPassphrase() => $_clearField(2);

  /// Parent path of the keys, e.g. "m/84'/0'/0'/0". Its purpose picks the address type.
  @$pb.TagNumber(3)
  $core.String get basePath => $_getSZ(2);
  @$pb.TagNumber(3)
  set basePath($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBasePath() => $_has(2);
  @$pb.TagNumber(3)
  void clearBasePath() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get startIndex => $_getIZ(3);
  @$pb.TagNumber(4)
  set startIndex($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasStartIndex() => $_has(3);
  @$pb.TagNumber(4)
  void clearStartIndex() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get count => $_getIZ(4);
  @$pb.TagNumber(5)
  set count($core.int value) => $_setUnsignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCount() => $_has(4);
  @$pb.TagNumber(5)
  void clearCount() => $_clearField(5);
}

class ExploredKey extends $pb.GeneratedMessage {
  factory ExploredKey({
    $core.String? path,
    $core.String? address,
    $core.String? publicKey,
    $core.String? wif,
  }) {
    final result = ExploredKey._();
    if (path != null) result.path = path;
    if (address != null) result.address = address;
    if (publicKey != null) result.publicKey = publicKey;
    if (wif != null) result.wif = wif;
    return result;
  }

  ExploredKey._();

  factory ExploredKey.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExploredKey()..mergeFromBuffer(data, registry);
  factory ExploredKey.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExploredKey()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ExploredKey',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ExploredKey.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'path')
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..aOS(3, _omitFieldNames ? '' : 'publicKey')
    ..aOS(4, _omitFieldNames ? '' : 'wif')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExploredKey clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExploredKey copyWith(void Function(ExploredKey) updates) =>
      super.copyWith((message) => updates(message as ExploredKey)) as ExploredKey;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ExploredKey() / ExploredKey.new instead')
  static ExploredKey create() => ExploredKey._();
  static $pb.GeneratedMessage $_createMessage() => ExploredKey._();
  @$core.override
  ExploredKey createEmptyInstance() => ExploredKey._();
  @$core.pragma('dart2js:noInline')
  static ExploredKey getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ExploredKey>(ExploredKey.$_createMessage);
  static ExploredKey? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get path => $_getSZ(0);
  @$pb.TagNumber(1)
  set path($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPath() => $_has(0);
  @$pb.TagNumber(1)
  void clearPath() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get address => $_getSZ(1);
  @$pb.TagNumber(2)
  set address($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get publicKey => $_getSZ(2);
  @$pb.TagNumber(3)
  set publicKey($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPublicKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearPublicKey() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get wif => $_getSZ(3);
  @$pb.TagNumber(4)
  set wif($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasWif() => $_has(3);
  @$pb.TagNumber(4)
  void clearWif() => $_clearField(4);
}

class ExploreSeedResponse extends $pb.GeneratedMessage {
  factory ExploreSeedResponse({
    $core.String? seedHex,
    $core.String? xprv,
    $core.String? xpub,
    $core.String? bip47PaymentCode,
    $core.Iterable<ExploredKey>? keys,
  }) {
    final result = ExploreSeedResponse._();
    if (seedHex != null) result.seedHex = seedHex;
    if (xprv != null) result.xprv = xprv;
    if (xpub != null) result.xpub = xpub;
    if (bip47PaymentCode != null) result.bip47PaymentCode = bip47PaymentCode;
    if (keys != null) result.keys.addAll(keys);
    return result;
  }

  ExploreSeedResponse._();

  factory ExploreSeedResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExploreSeedResponse()..mergeFromBuffer(data, registry);
  factory ExploreSeedResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ExploreSeedResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ExploreSeedResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ExploreSeedResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'seedHex')
    ..aOS(2, _omitFieldNames ? '' : 'xprv')
    ..aOS(3, _omitFieldNames ? '' : 'xpub')
    ..aOS(4, _omitFieldNames ? '' : 'bip47PaymentCode')
    ..pPM<ExploredKey>(5, _omitFieldNames ? '' : 'keys', subBuilder: ExploredKey.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExploreSeedResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ExploreSeedResponse copyWith(void Function(ExploreSeedResponse) updates) =>
      super.copyWith((message) => updates(message as ExploreSeedResponse)) as ExploreSeedResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ExploreSeedResponse() / ExploreSeedResponse.new instead')
  static ExploreSeedResponse create() => ExploreSeedResponse._();
  static $pb.GeneratedMessage $_createMessage() => ExploreSeedResponse._();
  @$core.override
  ExploreSeedResponse createEmptyInstance() => ExploreSeedResponse._();
  @$core.pragma('dart2js:noInline')
  static ExploreSeedResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ExploreSeedResponse>(ExploreSeedResponse.$_createMessage);
  static ExploreSeedResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get seedHex => $_getSZ(0);
  @$pb.TagNumber(1)
  set seedHex($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSeedHex() => $_has(0);
  @$pb.TagNumber(1)
  void clearSeedHex() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get xprv => $_getSZ(1);
  @$pb.TagNumber(2)
  set xprv($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasXprv() => $_has(1);
  @$pb.TagNumber(2)
  void clearXprv() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get xpub => $_getSZ(2);
  @$pb.TagNumber(3)
  set xpub($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasXpub() => $_has(2);
  @$pb.TagNumber(3)
  void clearXpub() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get bip47PaymentCode => $_getSZ(3);
  @$pb.TagNumber(4)
  set bip47PaymentCode($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBip47PaymentCode() => $_has(3);
  @$pb.TagNumber(4)
  void clearBip47PaymentCode() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<ExploredKey> get keys => $_getList(4);
}

class GenerateMnemonicRequest extends $pb.GeneratedMessage {
  factory GenerateMnemonicRequest() => GenerateMnemonicRequest._();

  GenerateMnemonicRequest._();

  factory GenerateMnemonicRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GenerateMnemonicRequest()..mergeFromBuffer(data, registry);
  factory GenerateMnemonicRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GenerateMnemonicRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GenerateMnemonicRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: GenerateMnemonicRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateMnemonicRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateMnemonicRequest copyWith(void Function(GenerateMnemonicRequest) updates) =>
      super.copyWith((message) => updates(message as GenerateMnemonicRequest)) as GenerateMnemonicRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GenerateMnemonicRequest() / GenerateMnemonicRequest.new instead')
  static GenerateMnemonicRequest create() => GenerateMnemonicRequest._();
  static $pb.GeneratedMessage $_createMessage() => GenerateMnemonicRequest._();
  @$core.override
  GenerateMnemonicRequest createEmptyInstance() => GenerateMnemonicRequest._();
  @$core.pragma('dart2js:noInline')
  static GenerateMnemonicRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GenerateMnemonicRequest>(GenerateMnemonicRequest.$_createMessage);
  static GenerateMnemonicRequest? _defaultInstance;
}

class GenerateMnemonicResponse extends $pb.GeneratedMessage {
  factory GenerateMnemonicResponse({
    $core.String? mnemonic,
  }) {
    final result = GenerateMnemonicResponse._();
    if (mnemonic != null) result.mnemonic = mnemonic;
    return result;
  }

  GenerateMnemonicResponse._();

  factory GenerateMnemonicResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GenerateMnemonicResponse()..mergeFromBuffer(data, registry);
  factory GenerateMnemonicResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GenerateMnemonicResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GenerateMnemonicResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: GenerateMnemonicResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'mnemonic')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateMnemonicResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GenerateMnemonicResponse copyWith(void Function(GenerateMnemonicResponse) updates) =>
      super.copyWith((message) => updates(message as GenerateMnemonicResponse)) as GenerateMnemonicResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GenerateMnemonicResponse() / GenerateMnemonicResponse.new instead')
  static GenerateMnemonicResponse create() => GenerateMnemonicResponse._();
  static $pb.GeneratedMessage $_createMessage() => GenerateMnemonicResponse._();
  @$core.override
  GenerateMnemonicResponse createEmptyInstance() => GenerateMnemonicResponse._();
  @$core.pragma('dart2js:noInline')
  static GenerateMnemonicResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GenerateMnemonicResponse>(GenerateMnemonicResponse.$_createMessage);
  static GenerateMnemonicResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mnemonic => $_getSZ(0);
  @$pb.TagNumber(1)
  set mnemonic($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMnemonic() => $_has(0);
  @$pb.TagNumber(1)
  void clearMnemonic() => $_clearField(1);
}

class ValidateMnemonicRequest extends $pb.GeneratedMessage {
  factory ValidateMnemonicRequest({
    $core.String? mnemonic,
  }) {
    final result = ValidateMnemonicRequest._();
    if (mnemonic != null) result.mnemonic = mnemonic;
    return result;
  }

  ValidateMnemonicRequest._();

  factory ValidateMnemonicRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidateMnemonicRequest()..mergeFromBuffer(data, registry);
  factory ValidateMnemonicRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidateMnemonicRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ValidateMnemonicRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ValidateMnemonicRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'mnemonic')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateMnemonicRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateMnemonicRequest copyWith(void Function(ValidateMnemonicRequest) updates) =>
      super.copyWith((message) => updates(message as ValidateMnemonicRequest)) as ValidateMnemonicRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ValidateMnemonicRequest() / ValidateMnemonicRequest.new instead')
  static ValidateMnemonicRequest create() => ValidateMnemonicRequest._();
  static $pb.GeneratedMessage $_createMessage() => ValidateMnemonicRequest._();
  @$core.override
  ValidateMnemonicRequest createEmptyInstance() => ValidateMnemonicRequest._();
  @$core.pragma('dart2js:noInline')
  static ValidateMnemonicRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ValidateMnemonicRequest>(ValidateMnemonicRequest.$_createMessage);
  static ValidateMnemonicRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mnemonic => $_getSZ(0);
  @$pb.TagNumber(1)
  set mnemonic($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMnemonic() => $_has(0);
  @$pb.TagNumber(1)
  void clearMnemonic() => $_clearField(1);
}

class ValidateMnemonicResponse extends $pb.GeneratedMessage {
  factory ValidateMnemonicResponse({
    MnemonicKind? kind,
  }) {
    final result = ValidateMnemonicResponse._();
    if (kind != null) result.kind = kind;
    return result;
  }

  ValidateMnemonicResponse._();

  factory ValidateMnemonicResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidateMnemonicResponse()..mergeFromBuffer(data, registry);
  factory ValidateMnemonicResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ValidateMnemonicResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ValidateMnemonicResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ValidateMnemonicResponse.$_createMessage)
    ..aE<MnemonicKind>(1, _omitFieldNames ? '' : 'kind', enumValues: MnemonicKind.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateMnemonicResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ValidateMnemonicResponse copyWith(void Function(ValidateMnemonicResponse) updates) =>
      super.copyWith((message) => updates(message as ValidateMnemonicResponse)) as ValidateMnemonicResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ValidateMnemonicResponse() / ValidateMnemonicResponse.new instead')
  static ValidateMnemonicResponse create() => ValidateMnemonicResponse._();
  static $pb.GeneratedMessage $_createMessage() => ValidateMnemonicResponse._();
  @$core.override
  ValidateMnemonicResponse createEmptyInstance() => ValidateMnemonicResponse._();
  @$core.pragma('dart2js:noInline')
  static ValidateMnemonicResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ValidateMnemonicResponse>(ValidateMnemonicResponse.$_createMessage);
  static ValidateMnemonicResponse? _defaultInstance;

  @$pb.TagNumber(1)
  MnemonicKind get kind => $_getN(0);
  @$pb.TagNumber(1)
  set kind(MnemonicKind value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasKind() => $_has(0);
  @$pb.TagNumber(1)
  void clearKind() => $_clearField(1);
}

class ListTransactionsRequest extends $pb.GeneratedMessage {
  factory ListTransactionsRequest({
    $core.String? walletId,
    $core.int? count,
  }) {
    final result = ListTransactionsRequest._();
    if (walletId != null) result.walletId = walletId;
    if (count != null) result.count = count;
    return result;
  }

  ListTransactionsRequest._();

  factory ListTransactionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListTransactionsRequest()..mergeFromBuffer(data, registry);
  factory ListTransactionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListTransactionsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListTransactionsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ListTransactionsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aI(2, _omitFieldNames ? '' : 'count')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTransactionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTransactionsRequest copyWith(void Function(ListTransactionsRequest) updates) =>
      super.copyWith((message) => updates(message as ListTransactionsRequest)) as ListTransactionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListTransactionsRequest() / ListTransactionsRequest.new instead')
  static ListTransactionsRequest create() => ListTransactionsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListTransactionsRequest._();
  @$core.override
  ListTransactionsRequest createEmptyInstance() => ListTransactionsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListTransactionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTransactionsRequest>(ListTransactionsRequest.$_createMessage);
  static ListTransactionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get count => $_getIZ(1);
  @$pb.TagNumber(2)
  set count($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearCount() => $_clearField(2);
}

class TransactionEntry extends $pb.GeneratedMessage {
  factory TransactionEntry({
    $core.String? txid,
    $core.int? vout,
    $core.String? address,
    $core.String? category,
    $core.double? amount,
    $fixnum.Int64? amountSats,
    $core.int? confirmations,
    $fixnum.Int64? blockTime,
    $fixnum.Int64? time,
    $core.String? label,
    $core.double? fee,
    $core.bool? replacedByTxid,
    $core.String? walletId,
    BmmBid? bmmBid,
    $core.String? warningMessage,
    SidechainDeposit? sidechainDeposit,
  }) {
    final result = TransactionEntry._();
    if (txid != null) result.txid = txid;
    if (vout != null) result.vout = vout;
    if (address != null) result.address = address;
    if (category != null) result.category = category;
    if (amount != null) result.amount = amount;
    if (amountSats != null) result.amountSats = amountSats;
    if (confirmations != null) result.confirmations = confirmations;
    if (blockTime != null) result.blockTime = blockTime;
    if (time != null) result.time = time;
    if (label != null) result.label = label;
    if (fee != null) result.fee = fee;
    if (replacedByTxid != null) result.replacedByTxid = replacedByTxid;
    if (walletId != null) result.walletId = walletId;
    if (bmmBid != null) result.bmmBid = bmmBid;
    if (warningMessage != null) result.warningMessage = warningMessage;
    if (sidechainDeposit != null) result.sidechainDeposit = sidechainDeposit;
    return result;
  }

  TransactionEntry._();

  factory TransactionEntry.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransactionEntry()..mergeFromBuffer(data, registry);
  factory TransactionEntry.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransactionEntry()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransactionEntry',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: TransactionEntry.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aI(2, _omitFieldNames ? '' : 'vout')
    ..aOS(3, _omitFieldNames ? '' : 'address')
    ..aOS(4, _omitFieldNames ? '' : 'category')
    ..aD(5, _omitFieldNames ? '' : 'amount')
    ..aInt64(6, _omitFieldNames ? '' : 'amountSats')
    ..aI(7, _omitFieldNames ? '' : 'confirmations')
    ..aInt64(8, _omitFieldNames ? '' : 'blockTime')
    ..aInt64(9, _omitFieldNames ? '' : 'time')
    ..aOS(10, _omitFieldNames ? '' : 'label')
    ..aD(11, _omitFieldNames ? '' : 'fee')
    ..aOB(12, _omitFieldNames ? '' : 'replacedByTxid')
    ..aOS(13, _omitFieldNames ? '' : 'walletId')
    ..aOM<BmmBid>(14, _omitFieldNames ? '' : 'bmmBid', subBuilder: BmmBid.$_createMessage)
    ..aOS(15, _omitFieldNames ? '' : 'warningMessage')
    ..aOM<SidechainDeposit>(16, _omitFieldNames ? '' : 'sidechainDeposit', subBuilder: SidechainDeposit.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransactionEntry clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransactionEntry copyWith(void Function(TransactionEntry) updates) =>
      super.copyWith((message) => updates(message as TransactionEntry)) as TransactionEntry;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TransactionEntry() / TransactionEntry.new instead')
  static TransactionEntry create() => TransactionEntry._();
  static $pb.GeneratedMessage $_createMessage() => TransactionEntry._();
  @$core.override
  TransactionEntry createEmptyInstance() => TransactionEntry._();
  @$core.pragma('dart2js:noInline')
  static TransactionEntry getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransactionEntry>(TransactionEntry.$_createMessage);
  static TransactionEntry? _defaultInstance;

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
  set vout($core.int value) => $_setSignedInt32(1, value);
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
  $core.String get category => $_getSZ(3);
  @$pb.TagNumber(4)
  set category($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasCategory() => $_has(3);
  @$pb.TagNumber(4)
  void clearCategory() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.double get amount => $_getN(4);
  @$pb.TagNumber(5)
  set amount($core.double value) => $_setDouble(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAmount() => $_has(4);
  @$pb.TagNumber(5)
  void clearAmount() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get amountSats => $_getI64(5);
  @$pb.TagNumber(6)
  set amountSats($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAmountSats() => $_has(5);
  @$pb.TagNumber(6)
  void clearAmountSats() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get confirmations => $_getIZ(6);
  @$pb.TagNumber(7)
  set confirmations($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasConfirmations() => $_has(6);
  @$pb.TagNumber(7)
  void clearConfirmations() => $_clearField(7);

  @$pb.TagNumber(8)
  $fixnum.Int64 get blockTime => $_getI64(7);
  @$pb.TagNumber(8)
  set blockTime($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasBlockTime() => $_has(7);
  @$pb.TagNumber(8)
  void clearBlockTime() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get time => $_getI64(8);
  @$pb.TagNumber(9)
  set time($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasTime() => $_has(8);
  @$pb.TagNumber(9)
  void clearTime() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get label => $_getSZ(9);
  @$pb.TagNumber(10)
  set label($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasLabel() => $_has(9);
  @$pb.TagNumber(10)
  void clearLabel() => $_clearField(10);

  @$pb.TagNumber(11)
  $core.double get fee => $_getN(10);
  @$pb.TagNumber(11)
  set fee($core.double value) => $_setDouble(10, value);
  @$pb.TagNumber(11)
  $core.bool hasFee() => $_has(10);
  @$pb.TagNumber(11)
  void clearFee() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get replacedByTxid => $_getBF(11);
  @$pb.TagNumber(12)
  set replacedByTxid($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasReplacedByTxid() => $_has(11);
  @$pb.TagNumber(12)
  void clearReplacedByTxid() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.String get walletId => $_getSZ(12);
  @$pb.TagNumber(13)
  set walletId($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasWalletId() => $_has(12);
  @$pb.TagNumber(13)
  void clearWalletId() => $_clearField(13);

  /// Set when output 0 carries a BMM request. Unset for every other transaction.
  @$pb.TagNumber(14)
  BmmBid get bmmBid => $_getN(13);
  @$pb.TagNumber(14)
  set bmmBid(BmmBid value) => $_setField(14, value);
  @$pb.TagNumber(14)
  $core.bool hasBmmBid() => $_has(13);
  @$pb.TagNumber(14)
  void clearBmmBid() => $_clearField(14);
  @$pb.TagNumber(14)
  BmmBid ensureBmmBid() => $_ensure(13);

  /// A backend warning for this transaction. Empty means no warning.
  @$pb.TagNumber(15)
  $core.String get warningMessage => $_getSZ(14);
  @$pb.TagNumber(15)
  set warningMessage($core.String value) => $_setString(14, value);
  @$pb.TagNumber(15)
  $core.bool hasWarningMessage() => $_has(14);
  @$pb.TagNumber(15)
  void clearWarningMessage() => $_clearField(15);

  /// Set when this install broadcast the transaction as a sidechain deposit request.
  @$pb.TagNumber(16)
  SidechainDeposit get sidechainDeposit => $_getN(15);
  @$pb.TagNumber(16)
  set sidechainDeposit(SidechainDeposit value) => $_setField(16, value);
  @$pb.TagNumber(16)
  $core.bool hasSidechainDeposit() => $_has(15);
  @$pb.TagNumber(16)
  void clearSidechainDeposit() => $_clearField(16);
  @$pb.TagNumber(16)
  SidechainDeposit ensureSidechainDeposit() => $_ensure(15);
}

/// BmmBid names the BMM request one wallet transaction carries.
class BmmBid extends $pb.GeneratedMessage {
  factory BmmBid({
    $core.int? slot,
    $core.String? criticalHash,
    $core.String? prevMainHash,
    $core.bool? lost,
  }) {
    final result = BmmBid._();
    if (slot != null) result.slot = slot;
    if (criticalHash != null) result.criticalHash = criticalHash;
    if (prevMainHash != null) result.prevMainHash = prevMainHash;
    if (lost != null) result.lost = lost;
    return result;
  }

  BmmBid._();

  factory BmmBid.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BmmBid()..mergeFromBuffer(data, registry);
  factory BmmBid.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BmmBid()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BmmBid',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: BmmBid.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'slot', fieldType: $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'criticalHash')
    ..aOS(3, _omitFieldNames ? '' : 'prevMainHash')
    ..aOB(4, _omitFieldNames ? '' : 'lost')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BmmBid clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BmmBid copyWith(void Function(BmmBid) updates) => super.copyWith((message) => updates(message as BmmBid)) as BmmBid;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BmmBid() / BmmBid.new instead')
  static BmmBid create() => BmmBid._();
  static $pb.GeneratedMessage $_createMessage() => BmmBid._();
  @$core.override
  BmmBid createEmptyInstance() => BmmBid._();
  @$core.pragma('dart2js:noInline')
  static BmmBid getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BmmBid>(BmmBid.$_createMessage);
  static BmmBid? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get slot => $_getIZ(0);
  @$pb.TagNumber(1)
  set slot($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSlot() => $_has(0);
  @$pb.TagNumber(1)
  void clearSlot() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get criticalHash => $_getSZ(1);
  @$pb.TagNumber(2)
  set criticalHash($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCriticalHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearCriticalHash() => $_clearField(2);

  /// The mainchain block the sidechain block builds on. The bid reaches only
  /// the block after it.
  @$pb.TagNumber(3)
  $core.String get prevMainHash => $_getSZ(2);
  @$pb.TagNumber(3)
  set prevMainHash($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPrevMainHash() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrevMainHash() => $_clearField(3);

  /// True when the mainchain tip moved past prev_main_hash.
  @$pb.TagNumber(4)
  $core.bool get lost => $_getBF(3);
  @$pb.TagNumber(4)
  set lost($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLost() => $_has(3);
  @$pb.TagNumber(4)
  void clearLost() => $_clearField(4);
}

class ListTransactionsResponse extends $pb.GeneratedMessage {
  factory ListTransactionsResponse({
    $core.Iterable<TransactionEntry>? transactions,
  }) {
    final result = ListTransactionsResponse._();
    if (transactions != null) result.transactions.addAll(transactions);
    return result;
  }

  ListTransactionsResponse._();

  factory ListTransactionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListTransactionsResponse()..mergeFromBuffer(data, registry);
  factory ListTransactionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListTransactionsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListTransactionsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ListTransactionsResponse.$_createMessage)
    ..pPM<TransactionEntry>(1, _omitFieldNames ? '' : 'transactions', subBuilder: TransactionEntry.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTransactionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTransactionsResponse copyWith(void Function(ListTransactionsResponse) updates) =>
      super.copyWith((message) => updates(message as ListTransactionsResponse)) as ListTransactionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListTransactionsResponse() / ListTransactionsResponse.new instead')
  static ListTransactionsResponse create() => ListTransactionsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListTransactionsResponse._();
  @$core.override
  ListTransactionsResponse createEmptyInstance() => ListTransactionsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListTransactionsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTransactionsResponse>(ListTransactionsResponse.$_createMessage);
  static ListTransactionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TransactionEntry> get transactions => $_getList(0);
}

class ListUnspentRequest extends $pb.GeneratedMessage {
  factory ListUnspentRequest({
    $core.String? walletId,
  }) {
    final result = ListUnspentRequest._();
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  ListUnspentRequest._();

  factory ListUnspentRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListUnspentRequest()..mergeFromBuffer(data, registry);
  factory ListUnspentRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListUnspentRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListUnspentRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ListUnspentRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUnspentRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUnspentRequest copyWith(void Function(ListUnspentRequest) updates) =>
      super.copyWith((message) => updates(message as ListUnspentRequest)) as ListUnspentRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListUnspentRequest() / ListUnspentRequest.new instead')
  static ListUnspentRequest create() => ListUnspentRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListUnspentRequest._();
  @$core.override
  ListUnspentRequest createEmptyInstance() => ListUnspentRequest._();
  @$core.pragma('dart2js:noInline')
  static ListUnspentRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListUnspentRequest>(ListUnspentRequest.$_createMessage);
  static ListUnspentRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);
}

class UnspentOutput extends $pb.GeneratedMessage {
  factory UnspentOutput({
    $core.String? txid,
    $core.int? vout,
    $core.String? address,
    $core.double? amount,
    $fixnum.Int64? amountSats,
    $core.int? confirmations,
    $core.String? label,
    $core.bool? spendable,
    $core.bool? solvable,
    $core.String? walletId,
    $0.Timestamp? receivedAt,
    $core.String? derivationPath,
    $core.bool? splittable,
    $core.int? inputWeightUnits,
  }) {
    final result = UnspentOutput._();
    if (txid != null) result.txid = txid;
    if (vout != null) result.vout = vout;
    if (address != null) result.address = address;
    if (amount != null) result.amount = amount;
    if (amountSats != null) result.amountSats = amountSats;
    if (confirmations != null) result.confirmations = confirmations;
    if (label != null) result.label = label;
    if (spendable != null) result.spendable = spendable;
    if (solvable != null) result.solvable = solvable;
    if (walletId != null) result.walletId = walletId;
    if (receivedAt != null) result.receivedAt = receivedAt;
    if (derivationPath != null) result.derivationPath = derivationPath;
    if (splittable != null) result.splittable = splittable;
    if (inputWeightUnits != null) result.inputWeightUnits = inputWeightUnits;
    return result;
  }

  UnspentOutput._();

  factory UnspentOutput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UnspentOutput()..mergeFromBuffer(data, registry);
  factory UnspentOutput.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      UnspentOutput()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnspentOutput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: UnspentOutput.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aI(2, _omitFieldNames ? '' : 'vout')
    ..aOS(3, _omitFieldNames ? '' : 'address')
    ..aD(4, _omitFieldNames ? '' : 'amount')
    ..aInt64(5, _omitFieldNames ? '' : 'amountSats')
    ..aI(6, _omitFieldNames ? '' : 'confirmations')
    ..aOS(7, _omitFieldNames ? '' : 'label')
    ..aOB(8, _omitFieldNames ? '' : 'spendable')
    ..aOB(9, _omitFieldNames ? '' : 'solvable')
    ..aOS(10, _omitFieldNames ? '' : 'walletId')
    ..aOM<$0.Timestamp>(11, _omitFieldNames ? '' : 'receivedAt', subBuilder: $0.Timestamp.$_createMessage)
    ..aOS(12, _omitFieldNames ? '' : 'derivationPath')
    ..aOB(13, _omitFieldNames ? '' : 'splittable')
    ..aI(14, _omitFieldNames ? '' : 'inputWeightUnits')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnspentOutput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UnspentOutput copyWith(void Function(UnspentOutput) updates) =>
      super.copyWith((message) => updates(message as UnspentOutput)) as UnspentOutput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use UnspentOutput() / UnspentOutput.new instead')
  static UnspentOutput create() => UnspentOutput._();
  static $pb.GeneratedMessage $_createMessage() => UnspentOutput._();
  @$core.override
  UnspentOutput createEmptyInstance() => UnspentOutput._();
  @$core.pragma('dart2js:noInline')
  static UnspentOutput getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnspentOutput>(UnspentOutput.$_createMessage);
  static UnspentOutput? _defaultInstance;

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
  set vout($core.int value) => $_setSignedInt32(1, value);
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
  $core.double get amount => $_getN(3);
  @$pb.TagNumber(4)
  set amount($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAmount() => $_has(3);
  @$pb.TagNumber(4)
  void clearAmount() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get amountSats => $_getI64(4);
  @$pb.TagNumber(5)
  set amountSats($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAmountSats() => $_has(4);
  @$pb.TagNumber(5)
  void clearAmountSats() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get confirmations => $_getIZ(5);
  @$pb.TagNumber(6)
  set confirmations($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasConfirmations() => $_has(5);
  @$pb.TagNumber(6)
  void clearConfirmations() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get label => $_getSZ(6);
  @$pb.TagNumber(7)
  set label($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLabel() => $_has(6);
  @$pb.TagNumber(7)
  void clearLabel() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.bool get spendable => $_getBF(7);
  @$pb.TagNumber(8)
  set spendable($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSpendable() => $_has(7);
  @$pb.TagNumber(8)
  void clearSpendable() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get solvable => $_getBF(8);
  @$pb.TagNumber(9)
  set solvable($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasSolvable() => $_has(8);
  @$pb.TagNumber(9)
  void clearSolvable() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.String get walletId => $_getSZ(9);
  @$pb.TagNumber(10)
  set walletId($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasWalletId() => $_has(9);
  @$pb.TagNumber(10)
  void clearWalletId() => $_clearField(10);

  /// Wallet's first-seen mempool timestamp when available, otherwise the
  /// confirming block's time. Unset if neither is known.
  @$pb.TagNumber(11)
  $0.Timestamp get receivedAt => $_getN(10);
  @$pb.TagNumber(11)
  set receivedAt($0.Timestamp value) => $_setField(11, value);
  @$pb.TagNumber(11)
  $core.bool hasReceivedAt() => $_has(10);
  @$pb.TagNumber(11)
  void clearReceivedAt() => $_clearField(11);
  @$pb.TagNumber(11)
  $0.Timestamp ensureReceivedAt() => $_ensure(10);

  /// BIP32 path of the address that owns this output. Empty when the backend
  /// cannot report one (Bitcoin Core bulk lists, the enforcer).
  @$pb.TagNumber(12)
  $core.String get derivationPath => $_getSZ(11);
  @$pb.TagNumber(12)
  set derivationPath($core.String value) => $_setString(11, value);
  @$pb.TagNumber(12)
  $core.bool hasDerivationPath() => $_has(11);
  @$pb.TagNumber(12)
  void clearDerivationPath() => $_clearField(12);

  /// True when the outpoint exists unspent on BTC mainnet. Unset until the
  /// split engine checked it.
  @$pb.TagNumber(13)
  $core.bool get splittable => $_getBF(12);
  @$pb.TagNumber(13)
  set splittable($core.bool value) => $_setBool(12, value);
  @$pb.TagNumber(13)
  $core.bool hasSplittable() => $_has(12);
  @$pb.TagNumber(13)
  void clearSplittable() => $_clearField(13);

  /// The largest weight, in weight units, that spending this output costs. Read
  /// from the output's descriptor, so it covers every script kind the wallet
  /// holds. 0 when the backend cannot report a descriptor.
  @$pb.TagNumber(14)
  $core.int get inputWeightUnits => $_getIZ(13);
  @$pb.TagNumber(14)
  set inputWeightUnits($core.int value) => $_setSignedInt32(13, value);
  @$pb.TagNumber(14)
  $core.bool hasInputWeightUnits() => $_has(13);
  @$pb.TagNumber(14)
  void clearInputWeightUnits() => $_clearField(14);
}

class ListUnspentResponse extends $pb.GeneratedMessage {
  factory ListUnspentResponse({
    $core.Iterable<UnspentOutput>? utxos,
  }) {
    final result = ListUnspentResponse._();
    if (utxos != null) result.utxos.addAll(utxos);
    return result;
  }

  ListUnspentResponse._();

  factory ListUnspentResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListUnspentResponse()..mergeFromBuffer(data, registry);
  factory ListUnspentResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListUnspentResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListUnspentResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ListUnspentResponse.$_createMessage)
    ..pPM<UnspentOutput>(1, _omitFieldNames ? '' : 'utxos', subBuilder: UnspentOutput.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUnspentResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListUnspentResponse copyWith(void Function(ListUnspentResponse) updates) =>
      super.copyWith((message) => updates(message as ListUnspentResponse)) as ListUnspentResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListUnspentResponse() / ListUnspentResponse.new instead')
  static ListUnspentResponse create() => ListUnspentResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListUnspentResponse._();
  @$core.override
  ListUnspentResponse createEmptyInstance() => ListUnspentResponse._();
  @$core.pragma('dart2js:noInline')
  static ListUnspentResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListUnspentResponse>(ListUnspentResponse.$_createMessage);
  static ListUnspentResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<UnspentOutput> get utxos => $_getList(0);
}

class ListReceiveAddressesRequest extends $pb.GeneratedMessage {
  factory ListReceiveAddressesRequest({
    $core.String? walletId,
  }) {
    final result = ListReceiveAddressesRequest._();
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  ListReceiveAddressesRequest._();

  factory ListReceiveAddressesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListReceiveAddressesRequest()..mergeFromBuffer(data, registry);
  factory ListReceiveAddressesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListReceiveAddressesRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListReceiveAddressesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ListReceiveAddressesRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListReceiveAddressesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListReceiveAddressesRequest copyWith(void Function(ListReceiveAddressesRequest) updates) =>
      super.copyWith((message) => updates(message as ListReceiveAddressesRequest)) as ListReceiveAddressesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListReceiveAddressesRequest() / ListReceiveAddressesRequest.new instead')
  static ListReceiveAddressesRequest create() => ListReceiveAddressesRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListReceiveAddressesRequest._();
  @$core.override
  ListReceiveAddressesRequest createEmptyInstance() => ListReceiveAddressesRequest._();
  @$core.pragma('dart2js:noInline')
  static ListReceiveAddressesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListReceiveAddressesRequest>(ListReceiveAddressesRequest.$_createMessage);
  static ListReceiveAddressesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);
}

class ReceiveAddress extends $pb.GeneratedMessage {
  factory ReceiveAddress({
    $core.String? address,
    $core.double? amount,
    $fixnum.Int64? amountSats,
    $core.String? label,
    $core.int? txCount,
    $core.bool? isChange,
    $core.String? derivationPath,
    $0.Timestamp? lastUsedAt,
  }) {
    final result = ReceiveAddress._();
    if (address != null) result.address = address;
    if (amount != null) result.amount = amount;
    if (amountSats != null) result.amountSats = amountSats;
    if (label != null) result.label = label;
    if (txCount != null) result.txCount = txCount;
    if (isChange != null) result.isChange = isChange;
    if (derivationPath != null) result.derivationPath = derivationPath;
    if (lastUsedAt != null) result.lastUsedAt = lastUsedAt;
    return result;
  }

  ReceiveAddress._();

  factory ReceiveAddress.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReceiveAddress()..mergeFromBuffer(data, registry);
  factory ReceiveAddress.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ReceiveAddress()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReceiveAddress',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ReceiveAddress.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aD(2, _omitFieldNames ? '' : 'amount')
    ..aInt64(3, _omitFieldNames ? '' : 'amountSats')
    ..aOS(4, _omitFieldNames ? '' : 'label')
    ..aI(5, _omitFieldNames ? '' : 'txCount')
    ..aOB(6, _omitFieldNames ? '' : 'isChange')
    ..aOS(7, _omitFieldNames ? '' : 'derivationPath')
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'lastUsedAt', subBuilder: $0.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReceiveAddress clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ReceiveAddress copyWith(void Function(ReceiveAddress) updates) =>
      super.copyWith((message) => updates(message as ReceiveAddress)) as ReceiveAddress;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ReceiveAddress() / ReceiveAddress.new instead')
  static ReceiveAddress create() => ReceiveAddress._();
  static $pb.GeneratedMessage $_createMessage() => ReceiveAddress._();
  @$core.override
  ReceiveAddress createEmptyInstance() => ReceiveAddress._();
  @$core.pragma('dart2js:noInline')
  static ReceiveAddress getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReceiveAddress>(ReceiveAddress.$_createMessage);
  static ReceiveAddress? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get amount => $_getN(1);
  @$pb.TagNumber(2)
  set amount($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get amountSats => $_getI64(2);
  @$pb.TagNumber(3)
  set amountSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAmountSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmountSats() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get label => $_getSZ(3);
  @$pb.TagNumber(4)
  set label($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLabel() => $_has(3);
  @$pb.TagNumber(4)
  void clearLabel() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get txCount => $_getIZ(4);
  @$pb.TagNumber(5)
  set txCount($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTxCount() => $_has(4);
  @$pb.TagNumber(5)
  void clearTxCount() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.bool get isChange => $_getBF(5);
  @$pb.TagNumber(6)
  set isChange($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIsChange() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsChange() => $_clearField(6);

  /// BIP32 path this address derives from. Empty when the backend cannot
  /// report one (Bitcoin Core bulk lists, the enforcer).
  @$pb.TagNumber(7)
  $core.String get derivationPath => $_getSZ(6);
  @$pb.TagNumber(7)
  set derivationPath($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDerivationPath() => $_has(6);
  @$pb.TagNumber(7)
  void clearDerivationPath() => $_clearField(7);

  /// Time of the newest tx that pays to or spends from the address; unset when
  /// no tx touched it.
  @$pb.TagNumber(8)
  $0.Timestamp get lastUsedAt => $_getN(7);
  @$pb.TagNumber(8)
  set lastUsedAt($0.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasLastUsedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearLastUsedAt() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureLastUsedAt() => $_ensure(7);
}

class ListReceiveAddressesResponse extends $pb.GeneratedMessage {
  factory ListReceiveAddressesResponse({
    $core.Iterable<ReceiveAddress>? addresses,
  }) {
    final result = ListReceiveAddressesResponse._();
    if (addresses != null) result.addresses.addAll(addresses);
    return result;
  }

  ListReceiveAddressesResponse._();

  factory ListReceiveAddressesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListReceiveAddressesResponse()..mergeFromBuffer(data, registry);
  factory ListReceiveAddressesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListReceiveAddressesResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListReceiveAddressesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ListReceiveAddressesResponse.$_createMessage)
    ..pPM<ReceiveAddress>(1, _omitFieldNames ? '' : 'addresses', subBuilder: ReceiveAddress.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListReceiveAddressesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListReceiveAddressesResponse copyWith(void Function(ListReceiveAddressesResponse) updates) =>
      super.copyWith((message) => updates(message as ListReceiveAddressesResponse)) as ListReceiveAddressesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListReceiveAddressesResponse() / ListReceiveAddressesResponse.new instead')
  static ListReceiveAddressesResponse create() => ListReceiveAddressesResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListReceiveAddressesResponse._();
  @$core.override
  ListReceiveAddressesResponse createEmptyInstance() => ListReceiveAddressesResponse._();
  @$core.pragma('dart2js:noInline')
  static ListReceiveAddressesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListReceiveAddressesResponse>(ListReceiveAddressesResponse.$_createMessage);
  static ListReceiveAddressesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<ReceiveAddress> get addresses => $_getList(0);
}

class GetTransactionDetailsRequest extends $pb.GeneratedMessage {
  factory GetTransactionDetailsRequest({
    $core.String? walletId,
    $core.String? txid,
  }) {
    final result = GetTransactionDetailsRequest._();
    if (walletId != null) result.walletId = walletId;
    if (txid != null) result.txid = txid;
    return result;
  }

  GetTransactionDetailsRequest._();

  factory GetTransactionDetailsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTransactionDetailsRequest()..mergeFromBuffer(data, registry);
  factory GetTransactionDetailsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTransactionDetailsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransactionDetailsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: GetTransactionDetailsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aOS(2, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionDetailsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionDetailsRequest copyWith(void Function(GetTransactionDetailsRequest) updates) =>
      super.copyWith((message) => updates(message as GetTransactionDetailsRequest)) as GetTransactionDetailsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetTransactionDetailsRequest() / GetTransactionDetailsRequest.new instead')
  static GetTransactionDetailsRequest create() => GetTransactionDetailsRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetTransactionDetailsRequest._();
  @$core.override
  GetTransactionDetailsRequest createEmptyInstance() => GetTransactionDetailsRequest._();
  @$core.pragma('dart2js:noInline')
  static GetTransactionDetailsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTransactionDetailsRequest>(GetTransactionDetailsRequest.$_createMessage);
  static GetTransactionDetailsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get txid => $_getSZ(1);
  @$pb.TagNumber(2)
  set txid($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearTxid() => $_clearField(2);
}

class GetTransactionDetailsResponse extends $pb.GeneratedMessage {
  factory GetTransactionDetailsResponse({
    TransactionEntry? transaction,
    $core.String? rawHex,
    $core.String? blockhash,
    $core.int? confirmations,
    $fixnum.Int64? blockTime,
    $core.int? version,
    $core.int? locktime,
    $core.int? sizeBytes,
    $core.int? vsizeVbytes,
    $core.int? weightWu,
    $fixnum.Int64? feeSats,
    $core.double? feeRateSatVb,
    $core.Iterable<TransactionInput>? inputs,
    $fixnum.Int64? totalInputSats,
    $core.Iterable<TransactionOutput>? outputs,
    $fixnum.Int64? totalOutputSats,
  }) {
    final result = GetTransactionDetailsResponse._();
    if (transaction != null) result.transaction = transaction;
    if (rawHex != null) result.rawHex = rawHex;
    if (blockhash != null) result.blockhash = blockhash;
    if (confirmations != null) result.confirmations = confirmations;
    if (blockTime != null) result.blockTime = blockTime;
    if (version != null) result.version = version;
    if (locktime != null) result.locktime = locktime;
    if (sizeBytes != null) result.sizeBytes = sizeBytes;
    if (vsizeVbytes != null) result.vsizeVbytes = vsizeVbytes;
    if (weightWu != null) result.weightWu = weightWu;
    if (feeSats != null) result.feeSats = feeSats;
    if (feeRateSatVb != null) result.feeRateSatVb = feeRateSatVb;
    if (inputs != null) result.inputs.addAll(inputs);
    if (totalInputSats != null) result.totalInputSats = totalInputSats;
    if (outputs != null) result.outputs.addAll(outputs);
    if (totalOutputSats != null) result.totalOutputSats = totalOutputSats;
    return result;
  }

  GetTransactionDetailsResponse._();

  factory GetTransactionDetailsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTransactionDetailsResponse()..mergeFromBuffer(data, registry);
  factory GetTransactionDetailsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTransactionDetailsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTransactionDetailsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: GetTransactionDetailsResponse.$_createMessage)
    ..aOM<TransactionEntry>(1, _omitFieldNames ? '' : 'transaction', subBuilder: TransactionEntry.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'rawHex')
    ..aOS(3, _omitFieldNames ? '' : 'blockhash')
    ..aI(4, _omitFieldNames ? '' : 'confirmations')
    ..aInt64(5, _omitFieldNames ? '' : 'blockTime')
    ..aI(6, _omitFieldNames ? '' : 'version')
    ..aI(7, _omitFieldNames ? '' : 'locktime')
    ..aI(8, _omitFieldNames ? '' : 'sizeBytes')
    ..aI(9, _omitFieldNames ? '' : 'vsizeVbytes')
    ..aI(10, _omitFieldNames ? '' : 'weightWu')
    ..aInt64(11, _omitFieldNames ? '' : 'feeSats')
    ..aD(12, _omitFieldNames ? '' : 'feeRateSatVb')
    ..pPM<TransactionInput>(13, _omitFieldNames ? '' : 'inputs', subBuilder: TransactionInput.$_createMessage)
    ..aInt64(14, _omitFieldNames ? '' : 'totalInputSats')
    ..pPM<TransactionOutput>(15, _omitFieldNames ? '' : 'outputs', subBuilder: TransactionOutput.$_createMessage)
    ..aInt64(16, _omitFieldNames ? '' : 'totalOutputSats')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionDetailsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTransactionDetailsResponse copyWith(void Function(GetTransactionDetailsResponse) updates) =>
      super.copyWith((message) => updates(message as GetTransactionDetailsResponse)) as GetTransactionDetailsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetTransactionDetailsResponse() / GetTransactionDetailsResponse.new instead')
  static GetTransactionDetailsResponse create() => GetTransactionDetailsResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetTransactionDetailsResponse._();
  @$core.override
  GetTransactionDetailsResponse createEmptyInstance() => GetTransactionDetailsResponse._();
  @$core.pragma('dart2js:noInline')
  static GetTransactionDetailsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTransactionDetailsResponse>(GetTransactionDetailsResponse.$_createMessage);
  static GetTransactionDetailsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  TransactionEntry get transaction => $_getN(0);
  @$pb.TagNumber(1)
  set transaction(TransactionEntry value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTransaction() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransaction() => $_clearField(1);
  @$pb.TagNumber(1)
  TransactionEntry ensureTransaction() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get rawHex => $_getSZ(1);
  @$pb.TagNumber(2)
  set rawHex($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRawHex() => $_has(1);
  @$pb.TagNumber(2)
  void clearRawHex() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get blockhash => $_getSZ(2);
  @$pb.TagNumber(3)
  set blockhash($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBlockhash() => $_has(2);
  @$pb.TagNumber(3)
  void clearBlockhash() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get confirmations => $_getIZ(3);
  @$pb.TagNumber(4)
  set confirmations($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasConfirmations() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfirmations() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get blockTime => $_getI64(4);
  @$pb.TagNumber(5)
  set blockTime($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBlockTime() => $_has(4);
  @$pb.TagNumber(5)
  void clearBlockTime() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get version => $_getIZ(5);
  @$pb.TagNumber(6)
  set version($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasVersion() => $_has(5);
  @$pb.TagNumber(6)
  void clearVersion() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get locktime => $_getIZ(6);
  @$pb.TagNumber(7)
  set locktime($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLocktime() => $_has(6);
  @$pb.TagNumber(7)
  void clearLocktime() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.int get sizeBytes => $_getIZ(7);
  @$pb.TagNumber(8)
  set sizeBytes($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSizeBytes() => $_has(7);
  @$pb.TagNumber(8)
  void clearSizeBytes() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.int get vsizeVbytes => $_getIZ(8);
  @$pb.TagNumber(9)
  set vsizeVbytes($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasVsizeVbytes() => $_has(8);
  @$pb.TagNumber(9)
  void clearVsizeVbytes() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.int get weightWu => $_getIZ(9);
  @$pb.TagNumber(10)
  set weightWu($core.int value) => $_setSignedInt32(9, value);
  @$pb.TagNumber(10)
  $core.bool hasWeightWu() => $_has(9);
  @$pb.TagNumber(10)
  void clearWeightWu() => $_clearField(10);

  @$pb.TagNumber(11)
  $fixnum.Int64 get feeSats => $_getI64(10);
  @$pb.TagNumber(11)
  set feeSats($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(11)
  $core.bool hasFeeSats() => $_has(10);
  @$pb.TagNumber(11)
  void clearFeeSats() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.double get feeRateSatVb => $_getN(11);
  @$pb.TagNumber(12)
  set feeRateSatVb($core.double value) => $_setDouble(11, value);
  @$pb.TagNumber(12)
  $core.bool hasFeeRateSatVb() => $_has(11);
  @$pb.TagNumber(12)
  void clearFeeRateSatVb() => $_clearField(12);

  @$pb.TagNumber(13)
  $pb.PbList<TransactionInput> get inputs => $_getList(12);

  @$pb.TagNumber(14)
  $fixnum.Int64 get totalInputSats => $_getI64(13);
  @$pb.TagNumber(14)
  set totalInputSats($fixnum.Int64 value) => $_setInt64(13, value);
  @$pb.TagNumber(14)
  $core.bool hasTotalInputSats() => $_has(13);
  @$pb.TagNumber(14)
  void clearTotalInputSats() => $_clearField(14);

  @$pb.TagNumber(15)
  $pb.PbList<TransactionOutput> get outputs => $_getList(14);

  @$pb.TagNumber(16)
  $fixnum.Int64 get totalOutputSats => $_getI64(15);
  @$pb.TagNumber(16)
  set totalOutputSats($fixnum.Int64 value) => $_setInt64(15, value);
  @$pb.TagNumber(16)
  $core.bool hasTotalOutputSats() => $_has(15);
  @$pb.TagNumber(16)
  void clearTotalOutputSats() => $_clearField(16);
}

class TransactionInput extends $pb.GeneratedMessage {
  factory TransactionInput({
    $core.int? index,
    $core.String? prevTxid,
    $core.int? prevVout,
    $core.String? address,
    $fixnum.Int64? valueSats,
    $core.String? scriptSigAsm,
    $core.String? scriptSigHex,
    $core.Iterable<$core.String>? witness,
    $fixnum.Int64? sequence,
    $core.bool? isCoinbase,
  }) {
    final result = TransactionInput._();
    if (index != null) result.index = index;
    if (prevTxid != null) result.prevTxid = prevTxid;
    if (prevVout != null) result.prevVout = prevVout;
    if (address != null) result.address = address;
    if (valueSats != null) result.valueSats = valueSats;
    if (scriptSigAsm != null) result.scriptSigAsm = scriptSigAsm;
    if (scriptSigHex != null) result.scriptSigHex = scriptSigHex;
    if (witness != null) result.witness.addAll(witness);
    if (sequence != null) result.sequence = sequence;
    if (isCoinbase != null) result.isCoinbase = isCoinbase;
    return result;
  }

  TransactionInput._();

  factory TransactionInput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransactionInput()..mergeFromBuffer(data, registry);
  factory TransactionInput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransactionInput()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransactionInput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: TransactionInput.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'index')
    ..aOS(2, _omitFieldNames ? '' : 'prevTxid')
    ..aI(3, _omitFieldNames ? '' : 'prevVout')
    ..aOS(4, _omitFieldNames ? '' : 'address')
    ..aInt64(5, _omitFieldNames ? '' : 'valueSats')
    ..aOS(6, _omitFieldNames ? '' : 'scriptSigAsm')
    ..aOS(7, _omitFieldNames ? '' : 'scriptSigHex')
    ..pPS(8, _omitFieldNames ? '' : 'witness')
    ..aInt64(9, _omitFieldNames ? '' : 'sequence')
    ..aOB(10, _omitFieldNames ? '' : 'isCoinbase')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransactionInput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransactionInput copyWith(void Function(TransactionInput) updates) =>
      super.copyWith((message) => updates(message as TransactionInput)) as TransactionInput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TransactionInput() / TransactionInput.new instead')
  static TransactionInput create() => TransactionInput._();
  static $pb.GeneratedMessage $_createMessage() => TransactionInput._();
  @$core.override
  TransactionInput createEmptyInstance() => TransactionInput._();
  @$core.pragma('dart2js:noInline')
  static TransactionInput getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransactionInput>(TransactionInput.$_createMessage);
  static TransactionInput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get index => $_getIZ(0);
  @$pb.TagNumber(1)
  set index($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIndex() => $_has(0);
  @$pb.TagNumber(1)
  void clearIndex() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get prevTxid => $_getSZ(1);
  @$pb.TagNumber(2)
  set prevTxid($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPrevTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrevTxid() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get prevVout => $_getIZ(2);
  @$pb.TagNumber(3)
  set prevVout($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPrevVout() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrevVout() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get address => $_getSZ(3);
  @$pb.TagNumber(4)
  set address($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAddress() => $_has(3);
  @$pb.TagNumber(4)
  void clearAddress() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get valueSats => $_getI64(4);
  @$pb.TagNumber(5)
  set valueSats($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasValueSats() => $_has(4);
  @$pb.TagNumber(5)
  void clearValueSats() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get scriptSigAsm => $_getSZ(5);
  @$pb.TagNumber(6)
  set scriptSigAsm($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasScriptSigAsm() => $_has(5);
  @$pb.TagNumber(6)
  void clearScriptSigAsm() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get scriptSigHex => $_getSZ(6);
  @$pb.TagNumber(7)
  set scriptSigHex($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasScriptSigHex() => $_has(6);
  @$pb.TagNumber(7)
  void clearScriptSigHex() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<$core.String> get witness => $_getList(7);

  @$pb.TagNumber(9)
  $fixnum.Int64 get sequence => $_getI64(8);
  @$pb.TagNumber(9)
  set sequence($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasSequence() => $_has(8);
  @$pb.TagNumber(9)
  void clearSequence() => $_clearField(9);

  @$pb.TagNumber(10)
  $core.bool get isCoinbase => $_getBF(9);
  @$pb.TagNumber(10)
  set isCoinbase($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasIsCoinbase() => $_has(9);
  @$pb.TagNumber(10)
  void clearIsCoinbase() => $_clearField(10);
}

class TransactionOutput extends $pb.GeneratedMessage {
  factory TransactionOutput({
    $core.int? index,
    $fixnum.Int64? valueSats,
    $core.String? address,
    $core.String? scriptType,
    $core.String? scriptPubkeyAsm,
    $core.String? scriptPubkeyHex,
    $core.bool? isChange,
    $core.bool? isMine,
  }) {
    final result = TransactionOutput._();
    if (index != null) result.index = index;
    if (valueSats != null) result.valueSats = valueSats;
    if (address != null) result.address = address;
    if (scriptType != null) result.scriptType = scriptType;
    if (scriptPubkeyAsm != null) result.scriptPubkeyAsm = scriptPubkeyAsm;
    if (scriptPubkeyHex != null) result.scriptPubkeyHex = scriptPubkeyHex;
    if (isChange != null) result.isChange = isChange;
    if (isMine != null) result.isMine = isMine;
    return result;
  }

  TransactionOutput._();

  factory TransactionOutput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransactionOutput()..mergeFromBuffer(data, registry);
  factory TransactionOutput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TransactionOutput()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransactionOutput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: TransactionOutput.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'index')
    ..aInt64(2, _omitFieldNames ? '' : 'valueSats')
    ..aOS(3, _omitFieldNames ? '' : 'address')
    ..aOS(4, _omitFieldNames ? '' : 'scriptType')
    ..aOS(5, _omitFieldNames ? '' : 'scriptPubkeyAsm')
    ..aOS(6, _omitFieldNames ? '' : 'scriptPubkeyHex')
    ..aOB(7, _omitFieldNames ? '' : 'isChange')
    ..aOB(8, _omitFieldNames ? '' : 'isMine')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransactionOutput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransactionOutput copyWith(void Function(TransactionOutput) updates) =>
      super.copyWith((message) => updates(message as TransactionOutput)) as TransactionOutput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TransactionOutput() / TransactionOutput.new instead')
  static TransactionOutput create() => TransactionOutput._();
  static $pb.GeneratedMessage $_createMessage() => TransactionOutput._();
  @$core.override
  TransactionOutput createEmptyInstance() => TransactionOutput._();
  @$core.pragma('dart2js:noInline')
  static TransactionOutput getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransactionOutput>(TransactionOutput.$_createMessage);
  static TransactionOutput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get index => $_getIZ(0);
  @$pb.TagNumber(1)
  set index($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasIndex() => $_has(0);
  @$pb.TagNumber(1)
  void clearIndex() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get valueSats => $_getI64(1);
  @$pb.TagNumber(2)
  set valueSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasValueSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearValueSats() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get address => $_getSZ(2);
  @$pb.TagNumber(3)
  set address($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddress() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get scriptType => $_getSZ(3);
  @$pb.TagNumber(4)
  set scriptType($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasScriptType() => $_has(3);
  @$pb.TagNumber(4)
  void clearScriptType() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get scriptPubkeyAsm => $_getSZ(4);
  @$pb.TagNumber(5)
  set scriptPubkeyAsm($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasScriptPubkeyAsm() => $_has(4);
  @$pb.TagNumber(5)
  void clearScriptPubkeyAsm() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get scriptPubkeyHex => $_getSZ(5);
  @$pb.TagNumber(6)
  set scriptPubkeyHex($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasScriptPubkeyHex() => $_has(5);
  @$pb.TagNumber(6)
  void clearScriptPubkeyHex() => $_clearField(6);

  /// The output pays the wallet's own change chain.
  @$pb.TagNumber(7)
  $core.bool get isChange => $_getBF(6);
  @$pb.TagNumber(7)
  set isChange($core.bool value) => $_setBool(6, value);
  @$pb.TagNumber(7)
  $core.bool hasIsChange() => $_has(6);
  @$pb.TagNumber(7)
  void clearIsChange() => $_clearField(7);

  /// The wallet owns the output's address.
  @$pb.TagNumber(8)
  $core.bool get isMine => $_getBF(7);
  @$pb.TagNumber(8)
  set isMine($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasIsMine() => $_has(7);
  @$pb.TagNumber(8)
  void clearIsMine() => $_clearField(8);
}

/// DecodeTransaction inspects a pasted txid, raw transaction hex, or base64 PSBT
/// and returns its decoded inputs/outputs/fee. Read-only: nothing is signed or
/// broadcast.
class DecodeTransactionRequest extends $pb.GeneratedMessage {
  factory DecodeTransactionRequest({
    $core.String? input,
    $core.String? walletId,
    $core.bool? checkOwnership,
  }) {
    final result = DecodeTransactionRequest._();
    if (input != null) result.input = input;
    if (walletId != null) result.walletId = walletId;
    if (checkOwnership != null) result.checkOwnership = checkOwnership;
    return result;
  }

  DecodeTransactionRequest._();

  factory DecodeTransactionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecodeTransactionRequest()..mergeFromBuffer(data, registry);
  factory DecodeTransactionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecodeTransactionRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodeTransactionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: DecodeTransactionRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'input')
    ..aOS(2, _omitFieldNames ? '' : 'walletId')
    ..aOB(3, _omitFieldNames ? '' : 'checkOwnership')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecodeTransactionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecodeTransactionRequest copyWith(void Function(DecodeTransactionRequest) updates) =>
      super.copyWith((message) => updates(message as DecodeTransactionRequest)) as DecodeTransactionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DecodeTransactionRequest() / DecodeTransactionRequest.new instead')
  static DecodeTransactionRequest create() => DecodeTransactionRequest._();
  static $pb.GeneratedMessage $_createMessage() => DecodeTransactionRequest._();
  @$core.override
  DecodeTransactionRequest createEmptyInstance() => DecodeTransactionRequest._();
  @$core.pragma('dart2js:noInline')
  static DecodeTransactionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DecodeTransactionRequest>(DecodeTransactionRequest.$_createMessage);
  static DecodeTransactionRequest? _defaultInstance;

  /// A 64-hex-char txid, a raw transaction hex, or a base64 PSBT. The form is
  /// auto-detected.
  @$pb.TagNumber(1)
  $core.String get input => $_getSZ(0);
  @$pb.TagNumber(1)
  set input($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasInput() => $_has(0);
  @$pb.TagNumber(1)
  void clearInput() => $_clearField(1);

  /// Wallet for txid and ownership checks. Empty uses the active wallet.
  @$pb.TagNumber(2)
  $core.String get walletId => $_getSZ(1);
  @$pb.TagNumber(2)
  set walletId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWalletId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWalletId() => $_clearField(2);

  /// Check output ownership with the wallet backend. This can read the network.
  @$pb.TagNumber(3)
  $core.bool get checkOwnership => $_getBF(2);
  @$pb.TagNumber(3)
  set checkOwnership($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCheckOwnership() => $_has(2);
  @$pb.TagNumber(3)
  void clearCheckOwnership() => $_clearField(3);
}

class DecodeTransactionResponse extends $pb.GeneratedMessage {
  factory DecodeTransactionResponse({
    DecodedForm? form,
    $core.String? txid,
    $core.int? version,
    $core.int? locktime,
    $core.int? sizeBytes,
    $core.int? vsizeVbytes,
    $core.int? weightWu,
    $core.Iterable<TransactionInput>? inputs,
    $core.Iterable<TransactionOutput>? outputs,
    $fixnum.Int64? totalInputSats,
    $core.bool? hasTotalInput,
    $fixnum.Int64? totalOutputSats,
    $fixnum.Int64? feeSats,
    $core.bool? hasFee,
    $core.double? feeRateSatVb,
    $core.bool? isPsbt,
    $core.int? signedInputs,
    $core.String? raw,
    $core.String? warningMessage,
  }) {
    final result = DecodeTransactionResponse._();
    if (form != null) result.form = form;
    if (txid != null) result.txid = txid;
    if (version != null) result.version = version;
    if (locktime != null) result.locktime = locktime;
    if (sizeBytes != null) result.sizeBytes = sizeBytes;
    if (vsizeVbytes != null) result.vsizeVbytes = vsizeVbytes;
    if (weightWu != null) result.weightWu = weightWu;
    if (inputs != null) result.inputs.addAll(inputs);
    if (outputs != null) result.outputs.addAll(outputs);
    if (totalInputSats != null) result.totalInputSats = totalInputSats;
    if (hasTotalInput != null) result.hasTotalInput = hasTotalInput;
    if (totalOutputSats != null) result.totalOutputSats = totalOutputSats;
    if (feeSats != null) result.feeSats = feeSats;
    if (hasFee != null) result.hasFee = hasFee;
    if (feeRateSatVb != null) result.feeRateSatVb = feeRateSatVb;
    if (isPsbt != null) result.isPsbt = isPsbt;
    if (signedInputs != null) result.signedInputs = signedInputs;
    if (raw != null) result.raw = raw;
    if (warningMessage != null) result.warningMessage = warningMessage;
    return result;
  }

  DecodeTransactionResponse._();

  factory DecodeTransactionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecodeTransactionResponse()..mergeFromBuffer(data, registry);
  factory DecodeTransactionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DecodeTransactionResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodeTransactionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: DecodeTransactionResponse.$_createMessage)
    ..aE<DecodedForm>(1, _omitFieldNames ? '' : 'form', enumValues: DecodedForm.values)
    ..aOS(2, _omitFieldNames ? '' : 'txid')
    ..aI(3, _omitFieldNames ? '' : 'version')
    ..aI(4, _omitFieldNames ? '' : 'locktime')
    ..aI(5, _omitFieldNames ? '' : 'sizeBytes')
    ..aI(6, _omitFieldNames ? '' : 'vsizeVbytes')
    ..aI(7, _omitFieldNames ? '' : 'weightWu')
    ..pPM<TransactionInput>(8, _omitFieldNames ? '' : 'inputs', subBuilder: TransactionInput.$_createMessage)
    ..pPM<TransactionOutput>(9, _omitFieldNames ? '' : 'outputs', subBuilder: TransactionOutput.$_createMessage)
    ..aInt64(10, _omitFieldNames ? '' : 'totalInputSats')
    ..aOB(11, _omitFieldNames ? '' : 'hasTotalInput')
    ..aInt64(12, _omitFieldNames ? '' : 'totalOutputSats')
    ..aInt64(13, _omitFieldNames ? '' : 'feeSats')
    ..aOB(14, _omitFieldNames ? '' : 'hasFee')
    ..aD(15, _omitFieldNames ? '' : 'feeRateSatVb')
    ..aOB(16, _omitFieldNames ? '' : 'isPsbt')
    ..aI(17, _omitFieldNames ? '' : 'signedInputs')
    ..aOS(18, _omitFieldNames ? '' : 'raw')
    ..aOS(19, _omitFieldNames ? '' : 'warningMessage')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecodeTransactionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DecodeTransactionResponse copyWith(void Function(DecodeTransactionResponse) updates) =>
      super.copyWith((message) => updates(message as DecodeTransactionResponse)) as DecodeTransactionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DecodeTransactionResponse() / DecodeTransactionResponse.new instead')
  static DecodeTransactionResponse create() => DecodeTransactionResponse._();
  static $pb.GeneratedMessage $_createMessage() => DecodeTransactionResponse._();
  @$core.override
  DecodeTransactionResponse createEmptyInstance() => DecodeTransactionResponse._();
  @$core.pragma('dart2js:noInline')
  static DecodeTransactionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DecodeTransactionResponse>(DecodeTransactionResponse.$_createMessage);
  static DecodeTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  DecodedForm get form => $_getN(0);
  @$pb.TagNumber(1)
  set form(DecodedForm value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasForm() => $_has(0);
  @$pb.TagNumber(1)
  void clearForm() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get txid => $_getSZ(1);
  @$pb.TagNumber(2)
  set txid($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearTxid() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get version => $_getIZ(2);
  @$pb.TagNumber(3)
  set version($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVersion() => $_has(2);
  @$pb.TagNumber(3)
  void clearVersion() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get locktime => $_getIZ(3);
  @$pb.TagNumber(4)
  set locktime($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLocktime() => $_has(3);
  @$pb.TagNumber(4)
  void clearLocktime() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get sizeBytes => $_getIZ(4);
  @$pb.TagNumber(5)
  set sizeBytes($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSizeBytes() => $_has(4);
  @$pb.TagNumber(5)
  void clearSizeBytes() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get vsizeVbytes => $_getIZ(5);
  @$pb.TagNumber(6)
  set vsizeVbytes($core.int value) => $_setSignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasVsizeVbytes() => $_has(5);
  @$pb.TagNumber(6)
  void clearVsizeVbytes() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.int get weightWu => $_getIZ(6);
  @$pb.TagNumber(7)
  set weightWu($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasWeightWu() => $_has(6);
  @$pb.TagNumber(7)
  void clearWeightWu() => $_clearField(7);

  @$pb.TagNumber(8)
  $pb.PbList<TransactionInput> get inputs => $_getList(7);

  @$pb.TagNumber(9)
  $pb.PbList<TransactionOutput> get outputs => $_getList(8);

  @$pb.TagNumber(10)
  $fixnum.Int64 get totalInputSats => $_getI64(9);
  @$pb.TagNumber(10)
  set totalInputSats($fixnum.Int64 value) => $_setInt64(9, value);
  @$pb.TagNumber(10)
  $core.bool hasTotalInputSats() => $_has(9);
  @$pb.TagNumber(10)
  void clearTotalInputSats() => $_clearField(10);

  /// True when every input value is known, so total_input_sats and fee are exact.
  @$pb.TagNumber(11)
  $core.bool get hasTotalInput => $_getBF(10);
  @$pb.TagNumber(11)
  set hasTotalInput($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasHasTotalInput() => $_has(10);
  @$pb.TagNumber(11)
  void clearHasTotalInput() => $_clearField(11);

  @$pb.TagNumber(12)
  $fixnum.Int64 get totalOutputSats => $_getI64(11);
  @$pb.TagNumber(12)
  set totalOutputSats($fixnum.Int64 value) => $_setInt64(11, value);
  @$pb.TagNumber(12)
  $core.bool hasTotalOutputSats() => $_has(11);
  @$pb.TagNumber(12)
  void clearTotalOutputSats() => $_clearField(12);

  @$pb.TagNumber(13)
  $fixnum.Int64 get feeSats => $_getI64(12);
  @$pb.TagNumber(13)
  set feeSats($fixnum.Int64 value) => $_setInt64(12, value);
  @$pb.TagNumber(13)
  $core.bool hasFeeSats() => $_has(12);
  @$pb.TagNumber(13)
  void clearFeeSats() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.bool get hasFee => $_getBF(13);
  @$pb.TagNumber(14)
  set hasFee($core.bool value) => $_setBool(13, value);
  @$pb.TagNumber(14)
  $core.bool hasHasFee() => $_has(13);
  @$pb.TagNumber(14)
  void clearHasFee() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.double get feeRateSatVb => $_getN(14);
  @$pb.TagNumber(15)
  set feeRateSatVb($core.double value) => $_setDouble(14, value);
  @$pb.TagNumber(15)
  $core.bool hasFeeRateSatVb() => $_has(14);
  @$pb.TagNumber(15)
  void clearFeeRateSatVb() => $_clearField(15);

  /// PSBT-only: how many inputs already carry a signature.
  @$pb.TagNumber(16)
  $core.bool get isPsbt => $_getBF(15);
  @$pb.TagNumber(16)
  set isPsbt($core.bool value) => $_setBool(15, value);
  @$pb.TagNumber(16)
  $core.bool hasIsPsbt() => $_has(15);
  @$pb.TagNumber(16)
  void clearIsPsbt() => $_clearField(16);

  @$pb.TagNumber(17)
  $core.int get signedInputs => $_getIZ(16);
  @$pb.TagNumber(17)
  set signedInputs($core.int value) => $_setSignedInt32(16, value);
  @$pb.TagNumber(17)
  $core.bool hasSignedInputs() => $_has(16);
  @$pb.TagNumber(17)
  void clearSignedInputs() => $_clearField(17);

  /// Raw transaction hex, or base64 for a PSBT.
  @$pb.TagNumber(18)
  $core.String get raw => $_getSZ(17);
  @$pb.TagNumber(18)
  set raw($core.String value) => $_setString(17, value);
  @$pb.TagNumber(18)
  $core.bool hasRaw() => $_has(17);
  @$pb.TagNumber(18)
  void clearRaw() => $_clearField(18);

  /// A backend warning for this transaction. Empty means no warning.
  @$pb.TagNumber(19)
  $core.String get warningMessage => $_getSZ(18);
  @$pb.TagNumber(19)
  set warningMessage($core.String value) => $_setString(18, value);
  @$pb.TagNumber(19)
  $core.bool hasWarningMessage() => $_has(18);
  @$pb.TagNumber(19)
  void clearWarningMessage() => $_clearField(19);
}

class BumpFeeRequest extends $pb.GeneratedMessage {
  factory BumpFeeRequest({
    $core.String? walletId,
    $core.String? txid,
    $fixnum.Int64? newFeeRate,
    $core.int? feeFromVout,
  }) {
    final result = BumpFeeRequest._();
    if (walletId != null) result.walletId = walletId;
    if (txid != null) result.txid = txid;
    if (newFeeRate != null) result.newFeeRate = newFeeRate;
    if (feeFromVout != null) result.feeFromVout = feeFromVout;
    return result;
  }

  BumpFeeRequest._();

  factory BumpFeeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BumpFeeRequest()..mergeFromBuffer(data, registry);
  factory BumpFeeRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BumpFeeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BumpFeeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: BumpFeeRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aOS(2, _omitFieldNames ? '' : 'txid')
    ..aInt64(3, _omitFieldNames ? '' : 'newFeeRate')
    ..aI(4, _omitFieldNames ? '' : 'feeFromVout')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BumpFeeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BumpFeeRequest copyWith(void Function(BumpFeeRequest) updates) =>
      super.copyWith((message) => updates(message as BumpFeeRequest)) as BumpFeeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BumpFeeRequest() / BumpFeeRequest.new instead')
  static BumpFeeRequest create() => BumpFeeRequest._();
  static $pb.GeneratedMessage $_createMessage() => BumpFeeRequest._();
  @$core.override
  BumpFeeRequest createEmptyInstance() => BumpFeeRequest._();
  @$core.pragma('dart2js:noInline')
  static BumpFeeRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BumpFeeRequest>(BumpFeeRequest.$_createMessage);
  static BumpFeeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get txid => $_getSZ(1);
  @$pb.TagNumber(2)
  set txid($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearTxid() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get newFeeRate => $_getI64(2);
  @$pb.TagNumber(3)
  set newFeeRate($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNewFeeRate() => $_has(2);
  @$pb.TagNumber(3)
  void clearNewFeeRate() => $_clearField(3);

  /// Output that pays the higher fee. Unset takes it from the change output,
  /// which is the only output a bump may touch without the user's consent.
  @$pb.TagNumber(4)
  $core.int get feeFromVout => $_getIZ(3);
  @$pb.TagNumber(4)
  set feeFromVout($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFeeFromVout() => $_has(3);
  @$pb.TagNumber(4)
  void clearFeeFromVout() => $_clearField(4);
}

class BumpFeeResponse extends $pb.GeneratedMessage {
  factory BumpFeeResponse({
    $core.String? newTxid,
    BumpFeePlan? plan,
  }) {
    final result = BumpFeeResponse._();
    if (newTxid != null) result.newTxid = newTxid;
    if (plan != null) result.plan = plan;
    return result;
  }

  BumpFeeResponse._();

  factory BumpFeeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BumpFeeResponse()..mergeFromBuffer(data, registry);
  factory BumpFeeResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BumpFeeResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BumpFeeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: BumpFeeResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'newTxid')
    ..aOM<BumpFeePlan>(2, _omitFieldNames ? '' : 'plan', subBuilder: BumpFeePlan.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BumpFeeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BumpFeeResponse copyWith(void Function(BumpFeeResponse) updates) =>
      super.copyWith((message) => updates(message as BumpFeeResponse)) as BumpFeeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BumpFeeResponse() / BumpFeeResponse.new instead')
  static BumpFeeResponse create() => BumpFeeResponse._();
  static $pb.GeneratedMessage $_createMessage() => BumpFeeResponse._();
  @$core.override
  BumpFeeResponse createEmptyInstance() => BumpFeeResponse._();
  @$core.pragma('dart2js:noInline')
  static BumpFeeResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BumpFeeResponse>(BumpFeeResponse.$_createMessage);
  static BumpFeeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get newTxid => $_getSZ(0);
  @$pb.TagNumber(1)
  set newTxid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNewTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearNewTxid() => $_clearField(1);

  @$pb.TagNumber(2)
  BumpFeePlan get plan => $_getN(1);
  @$pb.TagNumber(2)
  set plan(BumpFeePlan value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasPlan() => $_has(1);
  @$pb.TagNumber(2)
  void clearPlan() => $_clearField(2);
  @$pb.TagNumber(2)
  BumpFeePlan ensurePlan() => $_ensure(1);
}

class PreviewBumpFeeRequest extends $pb.GeneratedMessage {
  factory PreviewBumpFeeRequest({
    $core.String? walletId,
    $core.String? txid,
    $fixnum.Int64? newFeeRate,
    $core.int? feeFromVout,
  }) {
    final result = PreviewBumpFeeRequest._();
    if (walletId != null) result.walletId = walletId;
    if (txid != null) result.txid = txid;
    if (newFeeRate != null) result.newFeeRate = newFeeRate;
    if (feeFromVout != null) result.feeFromVout = feeFromVout;
    return result;
  }

  PreviewBumpFeeRequest._();

  factory PreviewBumpFeeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PreviewBumpFeeRequest()..mergeFromBuffer(data, registry);
  factory PreviewBumpFeeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PreviewBumpFeeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PreviewBumpFeeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: PreviewBumpFeeRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aOS(2, _omitFieldNames ? '' : 'txid')
    ..aInt64(3, _omitFieldNames ? '' : 'newFeeRate')
    ..aI(4, _omitFieldNames ? '' : 'feeFromVout')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewBumpFeeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewBumpFeeRequest copyWith(void Function(PreviewBumpFeeRequest) updates) =>
      super.copyWith((message) => updates(message as PreviewBumpFeeRequest)) as PreviewBumpFeeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PreviewBumpFeeRequest() / PreviewBumpFeeRequest.new instead')
  static PreviewBumpFeeRequest create() => PreviewBumpFeeRequest._();
  static $pb.GeneratedMessage $_createMessage() => PreviewBumpFeeRequest._();
  @$core.override
  PreviewBumpFeeRequest createEmptyInstance() => PreviewBumpFeeRequest._();
  @$core.pragma('dart2js:noInline')
  static PreviewBumpFeeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PreviewBumpFeeRequest>(PreviewBumpFeeRequest.$_createMessage);
  static PreviewBumpFeeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get txid => $_getSZ(1);
  @$pb.TagNumber(2)
  set txid($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearTxid() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get newFeeRate => $_getI64(2);
  @$pb.TagNumber(3)
  set newFeeRate($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasNewFeeRate() => $_has(2);
  @$pb.TagNumber(3)
  void clearNewFeeRate() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get feeFromVout => $_getIZ(3);
  @$pb.TagNumber(4)
  set feeFromVout($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFeeFromVout() => $_has(3);
  @$pb.TagNumber(4)
  void clearFeeFromVout() => $_clearField(4);
}

class PreviewBumpFeeResponse extends $pb.GeneratedMessage {
  factory PreviewBumpFeeResponse({
    $core.int? inputCount,
    $fixnum.Int64? vsizeVbytes,
    $fixnum.Int64? oldFeeSats,
    $core.double? oldFeeRateSatVb,
    $fixnum.Int64? suggestedFeeRate,
    $core.Iterable<BumpFeeOutput>? outputs,
    BumpFeePlan? plan,
    $core.String? reason,
    $core.bool? canReplace,
    $core.bool? hasChild,
    $core.bool? addsInputs,
    CancelPlan? cancel,
    $core.String? cancelReason,
  }) {
    final result = PreviewBumpFeeResponse._();
    if (inputCount != null) result.inputCount = inputCount;
    if (vsizeVbytes != null) result.vsizeVbytes = vsizeVbytes;
    if (oldFeeSats != null) result.oldFeeSats = oldFeeSats;
    if (oldFeeRateSatVb != null) result.oldFeeRateSatVb = oldFeeRateSatVb;
    if (suggestedFeeRate != null) result.suggestedFeeRate = suggestedFeeRate;
    if (outputs != null) result.outputs.addAll(outputs);
    if (plan != null) result.plan = plan;
    if (reason != null) result.reason = reason;
    if (canReplace != null) result.canReplace = canReplace;
    if (hasChild != null) result.hasChild = hasChild;
    if (addsInputs != null) result.addsInputs = addsInputs;
    if (cancel != null) result.cancel = cancel;
    if (cancelReason != null) result.cancelReason = cancelReason;
    return result;
  }

  PreviewBumpFeeResponse._();

  factory PreviewBumpFeeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PreviewBumpFeeResponse()..mergeFromBuffer(data, registry);
  factory PreviewBumpFeeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PreviewBumpFeeResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PreviewBumpFeeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: PreviewBumpFeeResponse.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'inputCount')
    ..aInt64(2, _omitFieldNames ? '' : 'vsizeVbytes')
    ..aInt64(3, _omitFieldNames ? '' : 'oldFeeSats')
    ..aD(4, _omitFieldNames ? '' : 'oldFeeRateSatVb')
    ..aInt64(5, _omitFieldNames ? '' : 'suggestedFeeRate')
    ..pPM<BumpFeeOutput>(6, _omitFieldNames ? '' : 'outputs', subBuilder: BumpFeeOutput.$_createMessage)
    ..aOM<BumpFeePlan>(7, _omitFieldNames ? '' : 'plan', subBuilder: BumpFeePlan.$_createMessage)
    ..aOS(8, _omitFieldNames ? '' : 'reason')
    ..aOB(9, _omitFieldNames ? '' : 'canReplace')
    ..aOB(10, _omitFieldNames ? '' : 'hasChild')
    ..aOB(11, _omitFieldNames ? '' : 'addsInputs')
    ..aOM<CancelPlan>(12, _omitFieldNames ? '' : 'cancel', subBuilder: CancelPlan.$_createMessage)
    ..aOS(13, _omitFieldNames ? '' : 'cancelReason')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewBumpFeeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewBumpFeeResponse copyWith(void Function(PreviewBumpFeeResponse) updates) =>
      super.copyWith((message) => updates(message as PreviewBumpFeeResponse)) as PreviewBumpFeeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PreviewBumpFeeResponse() / PreviewBumpFeeResponse.new instead')
  static PreviewBumpFeeResponse create() => PreviewBumpFeeResponse._();
  static $pb.GeneratedMessage $_createMessage() => PreviewBumpFeeResponse._();
  @$core.override
  PreviewBumpFeeResponse createEmptyInstance() => PreviewBumpFeeResponse._();
  @$core.pragma('dart2js:noInline')
  static PreviewBumpFeeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<PreviewBumpFeeResponse>(PreviewBumpFeeResponse.$_createMessage);
  static PreviewBumpFeeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get inputCount => $_getIZ(0);
  @$pb.TagNumber(1)
  set inputCount($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasInputCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearInputCount() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get vsizeVbytes => $_getI64(1);
  @$pb.TagNumber(2)
  set vsizeVbytes($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVsizeVbytes() => $_has(1);
  @$pb.TagNumber(2)
  void clearVsizeVbytes() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get oldFeeSats => $_getI64(2);
  @$pb.TagNumber(3)
  set oldFeeSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOldFeeSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearOldFeeSats() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get oldFeeRateSatVb => $_getN(3);
  @$pb.TagNumber(4)
  set oldFeeRateSatVb($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasOldFeeRateSatVb() => $_has(3);
  @$pb.TagNumber(4)
  void clearOldFeeRateSatVb() => $_clearField(4);

  /// Fee rate the backend suggests for the next blocks, in sat/vB.
  @$pb.TagNumber(5)
  $fixnum.Int64 get suggestedFeeRate => $_getI64(4);
  @$pb.TagNumber(5)
  set suggestedFeeRate($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasSuggestedFeeRate() => $_has(4);
  @$pb.TagNumber(5)
  void clearSuggestedFeeRate() => $_clearField(5);

  /// Every output of the transaction, in order.
  @$pb.TagNumber(6)
  $pb.PbList<BumpFeeOutput> get outputs => $_getList(5);

  /// The replacement. Unset when the wallet cannot build one.
  @$pb.TagNumber(7)
  BumpFeePlan get plan => $_getN(6);
  @$pb.TagNumber(7)
  set plan(BumpFeePlan value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasPlan() => $_has(6);
  @$pb.TagNumber(7)
  void clearPlan() => $_clearField(7);
  @$pb.TagNumber(7)
  BumpFeePlan ensurePlan() => $_ensure(6);

  /// Why the wallet cannot build a replacement. Empty when plan is set.
  @$pb.TagNumber(8)
  $core.String get reason => $_getSZ(7);
  @$pb.TagNumber(8)
  set reason($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasReason() => $_has(7);
  @$pb.TagNumber(8)
  void clearReason() => $_clearField(8);

  /// The wallet holds the keys of every input, so it can sign a replacement at
  /// some fee rate. False marks a transaction no rate can replace.
  @$pb.TagNumber(9)
  $core.bool get canReplace => $_getBF(8);
  @$pb.TagNumber(9)
  set canReplace($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasCanReplace() => $_has(8);
  @$pb.TagNumber(9)
  void clearCanReplace() => $_clearField(9);

  /// Another transaction already spends this one. A replacement must outpay that
  /// child too, and a child transaction cannot speed this one up either.
  @$pb.TagNumber(10)
  $core.bool get hasChild => $_getBF(9);
  @$pb.TagNumber(10)
  set hasChild($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(10)
  $core.bool hasHasChild() => $_has(9);
  @$pb.TagNumber(10)
  void clearHasChild() => $_clearField(10);

  /// The backend funds a higher fee from another coin when the chosen output
  /// cannot cover it, so a replacement holds even with no plan to show.
  @$pb.TagNumber(11)
  $core.bool get addsInputs => $_getBF(10);
  @$pb.TagNumber(11)
  set addsInputs($core.bool value) => $_setBool(10, value);
  @$pb.TagNumber(11)
  $core.bool hasAddsInputs() => $_has(10);
  @$pb.TagNumber(11)
  void clearAddsInputs() => $_clearField(11);

  /// The cancel. Unset when the wallet cannot cancel the transaction.
  @$pb.TagNumber(12)
  CancelPlan get cancel => $_getN(11);
  @$pb.TagNumber(12)
  set cancel(CancelPlan value) => $_setField(12, value);
  @$pb.TagNumber(12)
  $core.bool hasCancel() => $_has(11);
  @$pb.TagNumber(12)
  void clearCancel() => $_clearField(12);
  @$pb.TagNumber(12)
  CancelPlan ensureCancel() => $_ensure(11);

  /// Why the wallet cannot cancel the transaction. Empty when cancel is set.
  @$pb.TagNumber(13)
  $core.String get cancelReason => $_getSZ(12);
  @$pb.TagNumber(13)
  set cancelReason($core.String value) => $_setString(12, value);
  @$pb.TagNumber(13)
  $core.bool hasCancelReason() => $_has(12);
  @$pb.TagNumber(13)
  void clearCancelReason() => $_clearField(13);
}

/// CancelPlan is the transaction that pays the wallet's own inputs of an
/// unconfirmed transaction back to the wallet.
class CancelPlan extends $pb.GeneratedMessage {
  factory CancelPlan({
    $fixnum.Int64? recoveredSats,
    $fixnum.Int64? feeSats,
  }) {
    final result = CancelPlan._();
    if (recoveredSats != null) result.recoveredSats = recoveredSats;
    if (feeSats != null) result.feeSats = feeSats;
    return result;
  }

  CancelPlan._();

  factory CancelPlan.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CancelPlan()..mergeFromBuffer(data, registry);
  factory CancelPlan.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CancelPlan()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CancelPlan',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: CancelPlan.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'recoveredSats')
    ..aInt64(2, _omitFieldNames ? '' : 'feeSats')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelPlan clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelPlan copyWith(void Function(CancelPlan) updates) =>
      super.copyWith((message) => updates(message as CancelPlan)) as CancelPlan;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CancelPlan() / CancelPlan.new instead')
  static CancelPlan create() => CancelPlan._();
  static $pb.GeneratedMessage $_createMessage() => CancelPlan._();
  @$core.override
  CancelPlan createEmptyInstance() => CancelPlan._();
  @$core.pragma('dart2js:noInline')
  static CancelPlan getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CancelPlan>(CancelPlan.$_createMessage);
  static CancelPlan? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get recoveredSats => $_getI64(0);
  @$pb.TagNumber(1)
  set recoveredSats($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRecoveredSats() => $_has(0);
  @$pb.TagNumber(1)
  void clearRecoveredSats() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get feeSats => $_getI64(1);
  @$pb.TagNumber(2)
  set feeSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFeeSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearFeeSats() => $_clearField(2);
}

/// BumpFeeOutput is one output of the transaction the fee can come from.
class BumpFeeOutput extends $pb.GeneratedMessage {
  factory BumpFeeOutput({
    $core.int? vout,
    $fixnum.Int64? amountSats,
    $core.String? address,
    $core.bool? isChange,
    $fixnum.Int64? dustSats,
    $core.bool? isMine,
  }) {
    final result = BumpFeeOutput._();
    if (vout != null) result.vout = vout;
    if (amountSats != null) result.amountSats = amountSats;
    if (address != null) result.address = address;
    if (isChange != null) result.isChange = isChange;
    if (dustSats != null) result.dustSats = dustSats;
    if (isMine != null) result.isMine = isMine;
    return result;
  }

  BumpFeeOutput._();

  factory BumpFeeOutput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BumpFeeOutput()..mergeFromBuffer(data, registry);
  factory BumpFeeOutput.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BumpFeeOutput()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BumpFeeOutput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: BumpFeeOutput.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'vout')
    ..aInt64(2, _omitFieldNames ? '' : 'amountSats')
    ..aOS(3, _omitFieldNames ? '' : 'address')
    ..aOB(4, _omitFieldNames ? '' : 'isChange')
    ..aInt64(5, _omitFieldNames ? '' : 'dustSats')
    ..aOB(6, _omitFieldNames ? '' : 'isMine')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BumpFeeOutput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BumpFeeOutput copyWith(void Function(BumpFeeOutput) updates) =>
      super.copyWith((message) => updates(message as BumpFeeOutput)) as BumpFeeOutput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BumpFeeOutput() / BumpFeeOutput.new instead')
  static BumpFeeOutput create() => BumpFeeOutput._();
  static $pb.GeneratedMessage $_createMessage() => BumpFeeOutput._();
  @$core.override
  BumpFeeOutput createEmptyInstance() => BumpFeeOutput._();
  @$core.pragma('dart2js:noInline')
  static BumpFeeOutput getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BumpFeeOutput>(BumpFeeOutput.$_createMessage);
  static BumpFeeOutput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get vout => $_getIZ(0);
  @$pb.TagNumber(1)
  set vout($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVout() => $_has(0);
  @$pb.TagNumber(1)
  void clearVout() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get amountSats => $_getI64(1);
  @$pb.TagNumber(2)
  set amountSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAmountSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmountSats() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get address => $_getSZ(2);
  @$pb.TagNumber(3)
  set address($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearAddress() => $_clearField(3);

  /// The wallet owns this output and it sits on the change chain.
  @$pb.TagNumber(4)
  $core.bool get isChange => $_getBF(3);
  @$pb.TagNumber(4)
  set isChange($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIsChange() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsChange() => $_clearField(4);

  /// Amount below which the output cannot stay in the transaction.
  @$pb.TagNumber(5)
  $fixnum.Int64 get dustSats => $_getI64(4);
  @$pb.TagNumber(5)
  set dustSats($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasDustSats() => $_has(4);
  @$pb.TagNumber(5)
  void clearDustSats() => $_clearField(5);

  /// The wallet owns this output. CPFP spends such an output, so a transaction
  /// with none of them has no child to speed it up.
  @$pb.TagNumber(6)
  $core.bool get isMine => $_getBF(5);
  @$pb.TagNumber(6)
  set isMine($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasIsMine() => $_has(5);
  @$pb.TagNumber(6)
  void clearIsMine() => $_clearField(6);
}

/// BumpFeePlan is the replacement transaction a fee bump builds.
class BumpFeePlan extends $pb.GeneratedMessage {
  factory BumpFeePlan({
    $fixnum.Int64? oldFeeSats,
    $fixnum.Int64? newFeeSats,
    $fixnum.Int64? extraFeeSats,
    $core.double? newFeeRateSatVb,
    $core.int? feeFromVout,
    $fixnum.Int64? amountBeforeSats,
    $fixnum.Int64? amountAfterSats,
    $core.bool? outputRemoved,
    $core.bool? reducesPayment,
  }) {
    final result = BumpFeePlan._();
    if (oldFeeSats != null) result.oldFeeSats = oldFeeSats;
    if (newFeeSats != null) result.newFeeSats = newFeeSats;
    if (extraFeeSats != null) result.extraFeeSats = extraFeeSats;
    if (newFeeRateSatVb != null) result.newFeeRateSatVb = newFeeRateSatVb;
    if (feeFromVout != null) result.feeFromVout = feeFromVout;
    if (amountBeforeSats != null) result.amountBeforeSats = amountBeforeSats;
    if (amountAfterSats != null) result.amountAfterSats = amountAfterSats;
    if (outputRemoved != null) result.outputRemoved = outputRemoved;
    if (reducesPayment != null) result.reducesPayment = reducesPayment;
    return result;
  }

  BumpFeePlan._();

  factory BumpFeePlan.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BumpFeePlan()..mergeFromBuffer(data, registry);
  factory BumpFeePlan.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BumpFeePlan()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BumpFeePlan',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: BumpFeePlan.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'oldFeeSats')
    ..aInt64(2, _omitFieldNames ? '' : 'newFeeSats')
    ..aInt64(3, _omitFieldNames ? '' : 'extraFeeSats')
    ..aD(4, _omitFieldNames ? '' : 'newFeeRateSatVb')
    ..aI(5, _omitFieldNames ? '' : 'feeFromVout')
    ..aInt64(6, _omitFieldNames ? '' : 'amountBeforeSats')
    ..aInt64(7, _omitFieldNames ? '' : 'amountAfterSats')
    ..aOB(8, _omitFieldNames ? '' : 'outputRemoved')
    ..aOB(9, _omitFieldNames ? '' : 'reducesPayment')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BumpFeePlan clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BumpFeePlan copyWith(void Function(BumpFeePlan) updates) =>
      super.copyWith((message) => updates(message as BumpFeePlan)) as BumpFeePlan;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BumpFeePlan() / BumpFeePlan.new instead')
  static BumpFeePlan create() => BumpFeePlan._();
  static $pb.GeneratedMessage $_createMessage() => BumpFeePlan._();
  @$core.override
  BumpFeePlan createEmptyInstance() => BumpFeePlan._();
  @$core.pragma('dart2js:noInline')
  static BumpFeePlan getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BumpFeePlan>(BumpFeePlan.$_createMessage);
  static BumpFeePlan? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get oldFeeSats => $_getI64(0);
  @$pb.TagNumber(1)
  set oldFeeSats($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOldFeeSats() => $_has(0);
  @$pb.TagNumber(1)
  void clearOldFeeSats() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get newFeeSats => $_getI64(1);
  @$pb.TagNumber(2)
  set newFeeSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasNewFeeSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearNewFeeSats() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get extraFeeSats => $_getI64(2);
  @$pb.TagNumber(3)
  set extraFeeSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasExtraFeeSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearExtraFeeSats() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.double get newFeeRateSatVb => $_getN(3);
  @$pb.TagNumber(4)
  set newFeeRateSatVb($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNewFeeRateSatVb() => $_has(3);
  @$pb.TagNumber(4)
  void clearNewFeeRateSatVb() => $_clearField(4);

  /// Output that pays, and what it holds before and after.
  @$pb.TagNumber(5)
  $core.int get feeFromVout => $_getIZ(4);
  @$pb.TagNumber(5)
  set feeFromVout($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFeeFromVout() => $_has(4);
  @$pb.TagNumber(5)
  void clearFeeFromVout() => $_clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get amountBeforeSats => $_getI64(5);
  @$pb.TagNumber(6)
  set amountBeforeSats($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAmountBeforeSats() => $_has(5);
  @$pb.TagNumber(6)
  void clearAmountBeforeSats() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get amountAfterSats => $_getI64(6);
  @$pb.TagNumber(7)
  set amountAfterSats($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasAmountAfterSats() => $_has(6);
  @$pb.TagNumber(7)
  void clearAmountAfterSats() => $_clearField(7);

  /// The output falls under the dust limit, so it goes away and its remainder
  /// joins the fee.
  @$pb.TagNumber(8)
  $core.bool get outputRemoved => $_getBF(7);
  @$pb.TagNumber(8)
  set outputRemoved($core.bool value) => $_setBool(7, value);
  @$pb.TagNumber(8)
  $core.bool hasOutputRemoved() => $_has(7);
  @$pb.TagNumber(8)
  void clearOutputRemoved() => $_clearField(8);

  /// The output belongs to the recipient, not to the wallet.
  @$pb.TagNumber(9)
  $core.bool get reducesPayment => $_getBF(8);
  @$pb.TagNumber(9)
  set reducesPayment($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasReducesPayment() => $_has(8);
  @$pb.TagNumber(9)
  void clearReducesPayment() => $_clearField(9);
}

class CancelTransactionRequest extends $pb.GeneratedMessage {
  factory CancelTransactionRequest({
    $core.String? walletId,
    $core.String? txid,
    $fixnum.Int64? maxFeeSats,
  }) {
    final result = CancelTransactionRequest._();
    if (walletId != null) result.walletId = walletId;
    if (txid != null) result.txid = txid;
    if (maxFeeSats != null) result.maxFeeSats = maxFeeSats;
    return result;
  }

  CancelTransactionRequest._();

  factory CancelTransactionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CancelTransactionRequest()..mergeFromBuffer(data, registry);
  factory CancelTransactionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CancelTransactionRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CancelTransactionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: CancelTransactionRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aOS(2, _omitFieldNames ? '' : 'txid')
    ..aInt64(3, _omitFieldNames ? '' : 'maxFeeSats')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelTransactionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelTransactionRequest copyWith(void Function(CancelTransactionRequest) updates) =>
      super.copyWith((message) => updates(message as CancelTransactionRequest)) as CancelTransactionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CancelTransactionRequest() / CancelTransactionRequest.new instead')
  static CancelTransactionRequest create() => CancelTransactionRequest._();
  static $pb.GeneratedMessage $_createMessage() => CancelTransactionRequest._();
  @$core.override
  CancelTransactionRequest createEmptyInstance() => CancelTransactionRequest._();
  @$core.pragma('dart2js:noInline')
  static CancelTransactionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CancelTransactionRequest>(CancelTransactionRequest.$_createMessage);
  static CancelTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get txid => $_getSZ(1);
  @$pb.TagNumber(2)
  set txid($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearTxid() => $_clearField(2);

  /// The fee the user confirmed. A cancel that costs more is refused.
  @$pb.TagNumber(3)
  $fixnum.Int64 get maxFeeSats => $_getI64(2);
  @$pb.TagNumber(3)
  set maxFeeSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMaxFeeSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearMaxFeeSats() => $_clearField(3);
}

class CancelTransactionResponse extends $pb.GeneratedMessage {
  factory CancelTransactionResponse({
    $core.String? replacementTxid,
    $fixnum.Int64? recoveredSats,
    $fixnum.Int64? feeSats,
  }) {
    final result = CancelTransactionResponse._();
    if (replacementTxid != null) result.replacementTxid = replacementTxid;
    if (recoveredSats != null) result.recoveredSats = recoveredSats;
    if (feeSats != null) result.feeSats = feeSats;
    return result;
  }

  CancelTransactionResponse._();

  factory CancelTransactionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CancelTransactionResponse()..mergeFromBuffer(data, registry);
  factory CancelTransactionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CancelTransactionResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CancelTransactionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: CancelTransactionResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'replacementTxid')
    ..aInt64(2, _omitFieldNames ? '' : 'recoveredSats')
    ..aInt64(3, _omitFieldNames ? '' : 'feeSats')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelTransactionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelTransactionResponse copyWith(void Function(CancelTransactionResponse) updates) =>
      super.copyWith((message) => updates(message as CancelTransactionResponse)) as CancelTransactionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CancelTransactionResponse() / CancelTransactionResponse.new instead')
  static CancelTransactionResponse create() => CancelTransactionResponse._();
  static $pb.GeneratedMessage $_createMessage() => CancelTransactionResponse._();
  @$core.override
  CancelTransactionResponse createEmptyInstance() => CancelTransactionResponse._();
  @$core.pragma('dart2js:noInline')
  static CancelTransactionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CancelTransactionResponse>(CancelTransactionResponse.$_createMessage);
  static CancelTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get replacementTxid => $_getSZ(0);
  @$pb.TagNumber(1)
  set replacementTxid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasReplacementTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearReplacementTxid() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get recoveredSats => $_getI64(1);
  @$pb.TagNumber(2)
  set recoveredSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRecoveredSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearRecoveredSats() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get feeSats => $_getI64(2);
  @$pb.TagNumber(3)
  set feeSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFeeSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearFeeSats() => $_clearField(3);
}

class CreateCpfpRequest extends $pb.GeneratedMessage {
  factory CreateCpfpRequest({
    $core.String? walletId,
    $core.String? parentTxid,
    $core.int? parentVout,
    $fixnum.Int64? targetFeeRate,
  }) {
    final result = CreateCpfpRequest._();
    if (walletId != null) result.walletId = walletId;
    if (parentTxid != null) result.parentTxid = parentTxid;
    if (parentVout != null) result.parentVout = parentVout;
    if (targetFeeRate != null) result.targetFeeRate = targetFeeRate;
    return result;
  }

  CreateCpfpRequest._();

  factory CreateCpfpRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateCpfpRequest()..mergeFromBuffer(data, registry);
  factory CreateCpfpRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateCpfpRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateCpfpRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: CreateCpfpRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aOS(2, _omitFieldNames ? '' : 'parentTxid')
    ..aI(3, _omitFieldNames ? '' : 'parentVout')
    ..aInt64(4, _omitFieldNames ? '' : 'targetFeeRate')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateCpfpRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateCpfpRequest copyWith(void Function(CreateCpfpRequest) updates) =>
      super.copyWith((message) => updates(message as CreateCpfpRequest)) as CreateCpfpRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateCpfpRequest() / CreateCpfpRequest.new instead')
  static CreateCpfpRequest create() => CreateCpfpRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateCpfpRequest._();
  @$core.override
  CreateCpfpRequest createEmptyInstance() => CreateCpfpRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateCpfpRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateCpfpRequest>(CreateCpfpRequest.$_createMessage);
  static CreateCpfpRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get parentTxid => $_getSZ(1);
  @$pb.TagNumber(2)
  set parentTxid($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasParentTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearParentTxid() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get parentVout => $_getIZ(2);
  @$pb.TagNumber(3)
  set parentVout($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasParentVout() => $_has(2);
  @$pb.TagNumber(3)
  void clearParentVout() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get targetFeeRate => $_getI64(3);
  @$pb.TagNumber(4)
  set targetFeeRate($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTargetFeeRate() => $_has(3);
  @$pb.TagNumber(4)
  void clearTargetFeeRate() => $_clearField(4);
}

class CreateCpfpResponse extends $pb.GeneratedMessage {
  factory CreateCpfpResponse({
    $core.String? childTxid,
  }) {
    final result = CreateCpfpResponse._();
    if (childTxid != null) result.childTxid = childTxid;
    return result;
  }

  CreateCpfpResponse._();

  factory CreateCpfpResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateCpfpResponse()..mergeFromBuffer(data, registry);
  factory CreateCpfpResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateCpfpResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateCpfpResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: CreateCpfpResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'childTxid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateCpfpResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateCpfpResponse copyWith(void Function(CreateCpfpResponse) updates) =>
      super.copyWith((message) => updates(message as CreateCpfpResponse)) as CreateCpfpResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateCpfpResponse() / CreateCpfpResponse.new instead')
  static CreateCpfpResponse create() => CreateCpfpResponse._();
  static $pb.GeneratedMessage $_createMessage() => CreateCpfpResponse._();
  @$core.override
  CreateCpfpResponse createEmptyInstance() => CreateCpfpResponse._();
  @$core.pragma('dart2js:noInline')
  static CreateCpfpResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateCpfpResponse>(CreateCpfpResponse.$_createMessage);
  static CreateCpfpResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get childTxid => $_getSZ(0);
  @$pb.TagNumber(1)
  set childTxid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasChildTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearChildTxid() => $_clearField(1);
}

class DeriveAddressesRequest extends $pb.GeneratedMessage {
  factory DeriveAddressesRequest({
    $core.String? walletId,
    $core.int? startIndex,
    $core.int? count,
  }) {
    final result = DeriveAddressesRequest._();
    if (walletId != null) result.walletId = walletId;
    if (startIndex != null) result.startIndex = startIndex;
    if (count != null) result.count = count;
    return result;
  }

  DeriveAddressesRequest._();

  factory DeriveAddressesRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeriveAddressesRequest()..mergeFromBuffer(data, registry);
  factory DeriveAddressesRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeriveAddressesRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeriveAddressesRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: DeriveAddressesRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aI(2, _omitFieldNames ? '' : 'startIndex')
    ..aI(3, _omitFieldNames ? '' : 'count')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeriveAddressesRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeriveAddressesRequest copyWith(void Function(DeriveAddressesRequest) updates) =>
      super.copyWith((message) => updates(message as DeriveAddressesRequest)) as DeriveAddressesRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DeriveAddressesRequest() / DeriveAddressesRequest.new instead')
  static DeriveAddressesRequest create() => DeriveAddressesRequest._();
  static $pb.GeneratedMessage $_createMessage() => DeriveAddressesRequest._();
  @$core.override
  DeriveAddressesRequest createEmptyInstance() => DeriveAddressesRequest._();
  @$core.pragma('dart2js:noInline')
  static DeriveAddressesRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeriveAddressesRequest>(DeriveAddressesRequest.$_createMessage);
  static DeriveAddressesRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get startIndex => $_getIZ(1);
  @$pb.TagNumber(2)
  set startIndex($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasStartIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearStartIndex() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get count => $_getIZ(2);
  @$pb.TagNumber(3)
  set count($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearCount() => $_clearField(3);
}

class DeriveAddressesResponse extends $pb.GeneratedMessage {
  factory DeriveAddressesResponse({
    $core.Iterable<$core.String>? addresses,
  }) {
    final result = DeriveAddressesResponse._();
    if (addresses != null) result.addresses.addAll(addresses);
    return result;
  }

  DeriveAddressesResponse._();

  factory DeriveAddressesResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeriveAddressesResponse()..mergeFromBuffer(data, registry);
  factory DeriveAddressesResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      DeriveAddressesResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DeriveAddressesResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: DeriveAddressesResponse.$_createMessage)
    ..pPS(1, _omitFieldNames ? '' : 'addresses')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeriveAddressesResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DeriveAddressesResponse copyWith(void Function(DeriveAddressesResponse) updates) =>
      super.copyWith((message) => updates(message as DeriveAddressesResponse)) as DeriveAddressesResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use DeriveAddressesResponse() / DeriveAddressesResponse.new instead')
  static DeriveAddressesResponse create() => DeriveAddressesResponse._();
  static $pb.GeneratedMessage $_createMessage() => DeriveAddressesResponse._();
  @$core.override
  DeriveAddressesResponse createEmptyInstance() => DeriveAddressesResponse._();
  @$core.pragma('dart2js:noInline')
  static DeriveAddressesResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DeriveAddressesResponse>(DeriveAddressesResponse.$_createMessage);
  static DeriveAddressesResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<$core.String> get addresses => $_getList(0);
}

class ListEcxBurnsRequest extends $pb.GeneratedMessage {
  factory ListEcxBurnsRequest({
    $core.String? networkId,
    $core.String? coreUrl,
    $core.String? coreCookiePath,
  }) {
    final result = ListEcxBurnsRequest._();
    if (networkId != null) result.networkId = networkId;
    if (coreUrl != null) result.coreUrl = coreUrl;
    if (coreCookiePath != null) result.coreCookiePath = coreCookiePath;
    return result;
  }

  ListEcxBurnsRequest._();

  factory ListEcxBurnsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListEcxBurnsRequest()..mergeFromBuffer(data, registry);
  factory ListEcxBurnsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListEcxBurnsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListEcxBurnsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ListEcxBurnsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'networkId')
    ..aOS(2, _omitFieldNames ? '' : 'coreUrl')
    ..aOS(3, _omitFieldNames ? '' : 'coreCookiePath')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListEcxBurnsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListEcxBurnsRequest copyWith(void Function(ListEcxBurnsRequest) updates) =>
      super.copyWith((message) => updates(message as ListEcxBurnsRequest)) as ListEcxBurnsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListEcxBurnsRequest() / ListEcxBurnsRequest.new instead')
  static ListEcxBurnsRequest create() => ListEcxBurnsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListEcxBurnsRequest._();
  @$core.override
  ListEcxBurnsRequest createEmptyInstance() => ListEcxBurnsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListEcxBurnsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListEcxBurnsRequest>(ListEcxBurnsRequest.$_createMessage);
  static ListEcxBurnsRequest? _defaultInstance;

  /// Burn network to list, "alphanet" or "betanet". Empty lists the running network.
  @$pb.TagNumber(1)
  $core.String get networkId => $_getSZ(0);
  @$pb.TagNumber(1)
  set networkId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasNetworkId() => $_has(0);
  @$pb.TagNumber(1)
  void clearNetworkId() => $_clearField(1);

  /// RPC URL of a node on that network. Empty reads the network's esplora server.
  @$pb.TagNumber(2)
  $core.String get coreUrl => $_getSZ(1);
  @$pb.TagNumber(2)
  set coreUrl($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCoreUrl() => $_has(1);
  @$pb.TagNumber(2)
  void clearCoreUrl() => $_clearField(2);

  /// Path to the node's .cookie file.
  @$pb.TagNumber(3)
  $core.String get coreCookiePath => $_getSZ(2);
  @$pb.TagNumber(3)
  set coreCookiePath($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasCoreCookiePath() => $_has(2);
  @$pb.TagNumber(3)
  void clearCoreCookiePath() => $_clearField(3);
}

class EcxBurn extends $pb.GeneratedMessage {
  factory EcxBurn({
    $core.String? txid,
    $fixnum.Int64? height,
    $fixnum.Int64? burnSats,
    $core.String? payoutAddress,
    $fixnum.Int64? payoutSats,
  }) {
    final result = EcxBurn._();
    if (txid != null) result.txid = txid;
    if (height != null) result.height = height;
    if (burnSats != null) result.burnSats = burnSats;
    if (payoutAddress != null) result.payoutAddress = payoutAddress;
    if (payoutSats != null) result.payoutSats = payoutSats;
    return result;
  }

  EcxBurn._();

  factory EcxBurn.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EcxBurn()..mergeFromBuffer(data, registry);
  factory EcxBurn.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EcxBurn()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EcxBurn',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: EcxBurn.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aInt64(2, _omitFieldNames ? '' : 'height')
    ..aInt64(3, _omitFieldNames ? '' : 'burnSats')
    ..aOS(4, _omitFieldNames ? '' : 'payoutAddress')
    ..aInt64(5, _omitFieldNames ? '' : 'payoutSats')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EcxBurn clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EcxBurn copyWith(void Function(EcxBurn) updates) =>
      super.copyWith((message) => updates(message as EcxBurn)) as EcxBurn;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EcxBurn() / EcxBurn.new instead')
  static EcxBurn create() => EcxBurn._();
  static $pb.GeneratedMessage $_createMessage() => EcxBurn._();
  @$core.override
  EcxBurn createEmptyInstance() => EcxBurn._();
  @$core.pragma('dart2js:noInline')
  static EcxBurn getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EcxBurn>(EcxBurn.$_createMessage);
  static EcxBurn? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  /// 0 while the burn is in the mempool.
  @$pb.TagNumber(2)
  $fixnum.Int64 get height => $_getI64(1);
  @$pb.TagNumber(2)
  set height($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeight() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get burnSats => $_getI64(2);
  @$pb.TagNumber(3)
  set burnSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBurnSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearBurnSats() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get payoutAddress => $_getSZ(3);
  @$pb.TagNumber(4)
  set payoutAddress($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPayoutAddress() => $_has(3);
  @$pb.TagNumber(4)
  void clearPayoutAddress() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get payoutSats => $_getI64(4);
  @$pb.TagNumber(5)
  set payoutSats($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPayoutSats() => $_has(4);
  @$pb.TagNumber(5)
  void clearPayoutSats() => $_clearField(5);
}

class ListEcxBurnsResponse extends $pb.GeneratedMessage {
  factory ListEcxBurnsResponse({
    $core.Iterable<EcxBurn>? burns,
    $fixnum.Int64? totalBurnSats,
    $fixnum.Int64? totalPayoutSats,
    $fixnum.Int64? payoutAddressCount,
    $core.String? csv,
  }) {
    final result = ListEcxBurnsResponse._();
    if (burns != null) result.burns.addAll(burns);
    if (totalBurnSats != null) result.totalBurnSats = totalBurnSats;
    if (totalPayoutSats != null) result.totalPayoutSats = totalPayoutSats;
    if (payoutAddressCount != null) result.payoutAddressCount = payoutAddressCount;
    if (csv != null) result.csv = csv;
    return result;
  }

  ListEcxBurnsResponse._();

  factory ListEcxBurnsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListEcxBurnsResponse()..mergeFromBuffer(data, registry);
  factory ListEcxBurnsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListEcxBurnsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListEcxBurnsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ListEcxBurnsResponse.$_createMessage)
    ..pPM<EcxBurn>(1, _omitFieldNames ? '' : 'burns', subBuilder: EcxBurn.$_createMessage)
    ..aInt64(2, _omitFieldNames ? '' : 'totalBurnSats')
    ..aInt64(3, _omitFieldNames ? '' : 'totalPayoutSats')
    ..aInt64(4, _omitFieldNames ? '' : 'payoutAddressCount')
    ..aOS(5, _omitFieldNames ? '' : 'csv')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListEcxBurnsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListEcxBurnsResponse copyWith(void Function(ListEcxBurnsResponse) updates) =>
      super.copyWith((message) => updates(message as ListEcxBurnsResponse)) as ListEcxBurnsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListEcxBurnsResponse() / ListEcxBurnsResponse.new instead')
  static ListEcxBurnsResponse create() => ListEcxBurnsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListEcxBurnsResponse._();
  @$core.override
  ListEcxBurnsResponse createEmptyInstance() => ListEcxBurnsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListEcxBurnsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListEcxBurnsResponse>(ListEcxBurnsResponse.$_createMessage);
  static ListEcxBurnsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<EcxBurn> get burns => $_getList(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get totalBurnSats => $_getI64(1);
  @$pb.TagNumber(2)
  set totalBurnSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotalBurnSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotalBurnSats() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get totalPayoutSats => $_getI64(2);
  @$pb.TagNumber(3)
  set totalPayoutSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTotalPayoutSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearTotalPayoutSats() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get payoutAddressCount => $_getI64(3);
  @$pb.TagNumber(4)
  set payoutAddressCount($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPayoutAddressCount() => $_has(3);
  @$pb.TagNumber(4)
  void clearPayoutAddressCount() => $_clearField(4);

  /// burn_amount,payout_address,payout_amount in coins.
  @$pb.TagNumber(5)
  $core.String get csv => $_getSZ(4);
  @$pb.TagNumber(5)
  set csv($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasCsv() => $_has(4);
  @$pb.TagNumber(5)
  void clearCsv() => $_clearField(5);
}

class PreviewWalletFromEntropyRequest extends $pb.GeneratedMessage {
  factory PreviewWalletFromEntropyRequest({
    $core.List<$core.int>? entropy,
    $core.String? sourceText,
    $core.int? wordCount,
    $core.String? passphrase,
    $core.List<$core.int>? extraEntropy,
  }) {
    final result = PreviewWalletFromEntropyRequest._();
    if (entropy != null) result.entropy = entropy;
    if (sourceText != null) result.sourceText = sourceText;
    if (wordCount != null) result.wordCount = wordCount;
    if (passphrase != null) result.passphrase = passphrase;
    if (extraEntropy != null) result.extraEntropy = extraEntropy;
    return result;
  }

  PreviewWalletFromEntropyRequest._();

  factory PreviewWalletFromEntropyRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PreviewWalletFromEntropyRequest()..mergeFromBuffer(data, registry);
  factory PreviewWalletFromEntropyRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PreviewWalletFromEntropyRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PreviewWalletFromEntropyRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: PreviewWalletFromEntropyRequest.$_createMessage)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'entropy', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'sourceText')
    ..aI(3, _omitFieldNames ? '' : 'wordCount', fieldType: $pb.PbFieldType.OU3)
    ..aOS(4, _omitFieldNames ? '' : 'passphrase')
    ..a<$core.List<$core.int>>(5, _omitFieldNames ? '' : 'extraEntropy', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewWalletFromEntropyRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewWalletFromEntropyRequest copyWith(void Function(PreviewWalletFromEntropyRequest) updates) =>
      super.copyWith((message) => updates(message as PreviewWalletFromEntropyRequest))
          as PreviewWalletFromEntropyRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PreviewWalletFromEntropyRequest() / PreviewWalletFromEntropyRequest.new instead')
  static PreviewWalletFromEntropyRequest create() => PreviewWalletFromEntropyRequest._();
  static $pb.GeneratedMessage $_createMessage() => PreviewWalletFromEntropyRequest._();
  @$core.override
  PreviewWalletFromEntropyRequest createEmptyInstance() => PreviewWalletFromEntropyRequest._();
  @$core.pragma('dart2js:noInline')
  static PreviewWalletFromEntropyRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PreviewWalletFromEntropyRequest>(
          PreviewWalletFromEntropyRequest.$_createMessage);
  static PreviewWalletFromEntropyRequest? _defaultInstance;

  /// Raw entropy: 16 bytes for 12 words, 32 for 24. Takes precedence over
  /// source_text.
  @$pb.TagNumber(1)
  $core.List<$core.int> get entropy => $_getN(0);
  @$pb.TagNumber(1)
  set entropy($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEntropy() => $_has(0);
  @$pb.TagNumber(1)
  void clearEntropy() => $_clearField(1);

  /// Arbitrary user text, hashed into entropy. Any length, including one
  /// character. Exact-length hex (32 or 64 chars) is taken as raw entropy.
  @$pb.TagNumber(2)
  $core.String get sourceText => $_getSZ(1);
  @$pb.TagNumber(2)
  set sourceText($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSourceText() => $_has(1);
  @$pb.TagNumber(2)
  void clearSourceText() => $_clearField(2);

  /// Words to produce: 12 or 24. Defaults to 12. With no entropy and no
  /// source_text the server mints fresh entropy of this size.
  @$pb.TagNumber(3)
  $core.int get wordCount => $_getIZ(2);
  @$pb.TagNumber(3)
  set wordCount($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWordCount() => $_has(2);
  @$pb.TagNumber(3)
  void clearWordCount() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get passphrase => $_getSZ(3);
  @$pb.TagNumber(4)
  set passphrase($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasPassphrase() => $_has(3);
  @$pb.TagNumber(4)
  void clearPassphrase() => $_clearField(4);

  /// Extra randomness, mixed into the server-minted entropy. Ignored when
  /// entropy or source_text is set.
  @$pb.TagNumber(5)
  $core.List<$core.int> get extraEntropy => $_getN(4);
  @$pb.TagNumber(5)
  set extraEntropy($core.List<$core.int> value) => $_setBytes(4, value);
  @$pb.TagNumber(5)
  $core.bool hasExtraEntropy() => $_has(4);
  @$pb.TagNumber(5)
  void clearExtraEntropy() => $_clearField(5);
}

class PreviewWalletFromEntropyResponse extends $pb.GeneratedMessage {
  factory PreviewWalletFromEntropyResponse({
    $core.String? mnemonic,
    $core.String? seedHex,
    $core.String? masterKey,
    $core.String? chainCode,
    $core.String? bip39Binary,
    $core.String? bip39Checksum,
    $core.String? bip39ChecksumHex,
    $core.String? entropyHex,
  }) {
    final result = PreviewWalletFromEntropyResponse._();
    if (mnemonic != null) result.mnemonic = mnemonic;
    if (seedHex != null) result.seedHex = seedHex;
    if (masterKey != null) result.masterKey = masterKey;
    if (chainCode != null) result.chainCode = chainCode;
    if (bip39Binary != null) result.bip39Binary = bip39Binary;
    if (bip39Checksum != null) result.bip39Checksum = bip39Checksum;
    if (bip39ChecksumHex != null) result.bip39ChecksumHex = bip39ChecksumHex;
    if (entropyHex != null) result.entropyHex = entropyHex;
    return result;
  }

  PreviewWalletFromEntropyResponse._();

  factory PreviewWalletFromEntropyResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PreviewWalletFromEntropyResponse()..mergeFromBuffer(data, registry);
  factory PreviewWalletFromEntropyResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PreviewWalletFromEntropyResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PreviewWalletFromEntropyResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: PreviewWalletFromEntropyResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'mnemonic')
    ..aOS(2, _omitFieldNames ? '' : 'seedHex')
    ..aOS(3, _omitFieldNames ? '' : 'masterKey')
    ..aOS(4, _omitFieldNames ? '' : 'chainCode')
    ..aOS(5, _omitFieldNames ? '' : 'bip39Binary')
    ..aOS(6, _omitFieldNames ? '' : 'bip39Checksum')
    ..aOS(7, _omitFieldNames ? '' : 'bip39ChecksumHex')
    ..aOS(8, _omitFieldNames ? '' : 'entropyHex')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewWalletFromEntropyResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PreviewWalletFromEntropyResponse copyWith(void Function(PreviewWalletFromEntropyResponse) updates) =>
      super.copyWith((message) => updates(message as PreviewWalletFromEntropyResponse))
          as PreviewWalletFromEntropyResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PreviewWalletFromEntropyResponse() / PreviewWalletFromEntropyResponse.new instead')
  static PreviewWalletFromEntropyResponse create() => PreviewWalletFromEntropyResponse._();
  static $pb.GeneratedMessage $_createMessage() => PreviewWalletFromEntropyResponse._();
  @$core.override
  PreviewWalletFromEntropyResponse createEmptyInstance() => PreviewWalletFromEntropyResponse._();
  @$core.pragma('dart2js:noInline')
  static PreviewWalletFromEntropyResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PreviewWalletFromEntropyResponse>(
          PreviewWalletFromEntropyResponse.$_createMessage);
  static PreviewWalletFromEntropyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mnemonic => $_getSZ(0);
  @$pb.TagNumber(1)
  set mnemonic($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMnemonic() => $_has(0);
  @$pb.TagNumber(1)
  void clearMnemonic() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get seedHex => $_getSZ(1);
  @$pb.TagNumber(2)
  set seedHex($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasSeedHex() => $_has(1);
  @$pb.TagNumber(2)
  void clearSeedHex() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get masterKey => $_getSZ(2);
  @$pb.TagNumber(3)
  set masterKey($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMasterKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearMasterKey() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get chainCode => $_getSZ(3);
  @$pb.TagNumber(4)
  set chainCode($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasChainCode() => $_has(3);
  @$pb.TagNumber(4)
  void clearChainCode() => $_clearField(4);

  /// BIP39 entropy and checksum as bit strings, for the entropy breakdown.
  @$pb.TagNumber(5)
  $core.String get bip39Binary => $_getSZ(4);
  @$pb.TagNumber(5)
  set bip39Binary($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBip39Binary() => $_has(4);
  @$pb.TagNumber(5)
  void clearBip39Binary() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get bip39Checksum => $_getSZ(5);
  @$pb.TagNumber(6)
  set bip39Checksum($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBip39Checksum() => $_has(5);
  @$pb.TagNumber(6)
  void clearBip39Checksum() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get bip39ChecksumHex => $_getSZ(6);
  @$pb.TagNumber(7)
  set bip39ChecksumHex($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasBip39ChecksumHex() => $_has(6);
  @$pb.TagNumber(7)
  void clearBip39ChecksumHex() => $_clearField(7);

  /// The entropy the words came from, hex encoded.
  @$pb.TagNumber(8)
  $core.String get entropyHex => $_getSZ(7);
  @$pb.TagNumber(8)
  set entropyHex($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasEntropyHex() => $_has(7);
  @$pb.TagNumber(8)
  void clearEntropyHex() => $_clearField(8);
}

class GetWalletSeedRequest extends $pb.GeneratedMessage {
  factory GetWalletSeedRequest({
    $core.String? walletId,
  }) {
    final result = GetWalletSeedRequest._();
    if (walletId != null) result.walletId = walletId;
    return result;
  }

  GetWalletSeedRequest._();

  factory GetWalletSeedRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetWalletSeedRequest()..mergeFromBuffer(data, registry);
  factory GetWalletSeedRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetWalletSeedRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWalletSeedRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: GetWalletSeedRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWalletSeedRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWalletSeedRequest copyWith(void Function(GetWalletSeedRequest) updates) =>
      super.copyWith((message) => updates(message as GetWalletSeedRequest)) as GetWalletSeedRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetWalletSeedRequest() / GetWalletSeedRequest.new instead')
  static GetWalletSeedRequest create() => GetWalletSeedRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetWalletSeedRequest._();
  @$core.override
  GetWalletSeedRequest createEmptyInstance() => GetWalletSeedRequest._();
  @$core.pragma('dart2js:noInline')
  static GetWalletSeedRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetWalletSeedRequest>(GetWalletSeedRequest.$_createMessage);
  static GetWalletSeedRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);
}

class GetWalletSeedResponse extends $pb.GeneratedMessage {
  factory GetWalletSeedResponse({
    $core.String? seedHex,
    $core.String? mnemonic,
  }) {
    final result = GetWalletSeedResponse._();
    if (seedHex != null) result.seedHex = seedHex;
    if (mnemonic != null) result.mnemonic = mnemonic;
    return result;
  }

  GetWalletSeedResponse._();

  factory GetWalletSeedResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetWalletSeedResponse()..mergeFromBuffer(data, registry);
  factory GetWalletSeedResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetWalletSeedResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetWalletSeedResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: GetWalletSeedResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'seedHex')
    ..aOS(2, _omitFieldNames ? '' : 'mnemonic')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWalletSeedResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetWalletSeedResponse copyWith(void Function(GetWalletSeedResponse) updates) =>
      super.copyWith((message) => updates(message as GetWalletSeedResponse)) as GetWalletSeedResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetWalletSeedResponse() / GetWalletSeedResponse.new instead')
  static GetWalletSeedResponse create() => GetWalletSeedResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetWalletSeedResponse._();
  @$core.override
  GetWalletSeedResponse createEmptyInstance() => GetWalletSeedResponse._();
  @$core.pragma('dart2js:noInline')
  static GetWalletSeedResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetWalletSeedResponse>(GetWalletSeedResponse.$_createMessage);
  static GetWalletSeedResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get seedHex => $_getSZ(0);
  @$pb.TagNumber(1)
  set seedHex($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSeedHex() => $_has(0);
  @$pb.TagNumber(1)
  void clearSeedHex() => $_clearField(1);

  /// BIP39 mnemonic words for the wallet. Sensitive — treat like seed_hex.
  @$pb.TagNumber(2)
  $core.String get mnemonic => $_getSZ(1);
  @$pb.TagNumber(2)
  set mnemonic($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMnemonic() => $_has(1);
  @$pb.TagNumber(2)
  void clearMnemonic() => $_clearField(2);
}

class ListCoreVariantsRequest extends $pb.GeneratedMessage {
  factory ListCoreVariantsRequest() => ListCoreVariantsRequest._();

  ListCoreVariantsRequest._();

  factory ListCoreVariantsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListCoreVariantsRequest()..mergeFromBuffer(data, registry);
  factory ListCoreVariantsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListCoreVariantsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListCoreVariantsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ListCoreVariantsRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCoreVariantsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCoreVariantsRequest copyWith(void Function(ListCoreVariantsRequest) updates) =>
      super.copyWith((message) => updates(message as ListCoreVariantsRequest)) as ListCoreVariantsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListCoreVariantsRequest() / ListCoreVariantsRequest.new instead')
  static ListCoreVariantsRequest create() => ListCoreVariantsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListCoreVariantsRequest._();
  @$core.override
  ListCoreVariantsRequest createEmptyInstance() => ListCoreVariantsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListCoreVariantsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListCoreVariantsRequest>(ListCoreVariantsRequest.$_createMessage);
  static ListCoreVariantsRequest? _defaultInstance;
}

class CoreVariant extends $pb.GeneratedMessage {
  factory CoreVariant({
    $core.String? id,
    $core.String? displayName,
    $core.bool? installed,
  }) {
    final result = CoreVariant._();
    if (id != null) result.id = id;
    if (displayName != null) result.displayName = displayName;
    if (installed != null) result.installed = installed;
    return result;
  }

  CoreVariant._();

  factory CoreVariant.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CoreVariant()..mergeFromBuffer(data, registry);
  factory CoreVariant.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CoreVariant()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CoreVariant',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: CoreVariant.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'displayName')
    ..aOB(3, _omitFieldNames ? '' : 'installed')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CoreVariant clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CoreVariant copyWith(void Function(CoreVariant) updates) =>
      super.copyWith((message) => updates(message as CoreVariant)) as CoreVariant;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CoreVariant() / CoreVariant.new instead')
  static CoreVariant create() => CoreVariant._();
  static $pb.GeneratedMessage $_createMessage() => CoreVariant._();
  @$core.override
  CoreVariant createEmptyInstance() => CoreVariant._();
  @$core.pragma('dart2js:noInline')
  static CoreVariant getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CoreVariant>(CoreVariant.$_createMessage);
  static CoreVariant? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get displayName => $_getSZ(1);
  @$pb.TagNumber(2)
  set displayName($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDisplayName() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisplayName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get installed => $_getBF(2);
  @$pb.TagNumber(3)
  set installed($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasInstalled() => $_has(2);
  @$pb.TagNumber(3)
  void clearInstalled() => $_clearField(3);
}

class ListCoreVariantsResponse extends $pb.GeneratedMessage {
  factory ListCoreVariantsResponse({
    $core.Iterable<CoreVariant>? variants,
    $core.String? activeId,
  }) {
    final result = ListCoreVariantsResponse._();
    if (variants != null) result.variants.addAll(variants);
    if (activeId != null) result.activeId = activeId;
    return result;
  }

  ListCoreVariantsResponse._();

  factory ListCoreVariantsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListCoreVariantsResponse()..mergeFromBuffer(data, registry);
  factory ListCoreVariantsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListCoreVariantsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListCoreVariantsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: ListCoreVariantsResponse.$_createMessage)
    ..pPM<CoreVariant>(1, _omitFieldNames ? '' : 'variants', subBuilder: CoreVariant.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'activeId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCoreVariantsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCoreVariantsResponse copyWith(void Function(ListCoreVariantsResponse) updates) =>
      super.copyWith((message) => updates(message as ListCoreVariantsResponse)) as ListCoreVariantsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListCoreVariantsResponse() / ListCoreVariantsResponse.new instead')
  static ListCoreVariantsResponse create() => ListCoreVariantsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListCoreVariantsResponse._();
  @$core.override
  ListCoreVariantsResponse createEmptyInstance() => ListCoreVariantsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListCoreVariantsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListCoreVariantsResponse>(ListCoreVariantsResponse.$_createMessage);
  static ListCoreVariantsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<CoreVariant> get variants => $_getList(0);

  @$pb.TagNumber(2)
  $core.String get activeId => $_getSZ(1);
  @$pb.TagNumber(2)
  set activeId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasActiveId() => $_has(1);
  @$pb.TagNumber(2)
  void clearActiveId() => $_clearField(2);
}

class GetCoreVariantRequest extends $pb.GeneratedMessage {
  factory GetCoreVariantRequest() => GetCoreVariantRequest._();

  GetCoreVariantRequest._();

  factory GetCoreVariantRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCoreVariantRequest()..mergeFromBuffer(data, registry);
  factory GetCoreVariantRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCoreVariantRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCoreVariantRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: GetCoreVariantRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCoreVariantRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCoreVariantRequest copyWith(void Function(GetCoreVariantRequest) updates) =>
      super.copyWith((message) => updates(message as GetCoreVariantRequest)) as GetCoreVariantRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetCoreVariantRequest() / GetCoreVariantRequest.new instead')
  static GetCoreVariantRequest create() => GetCoreVariantRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetCoreVariantRequest._();
  @$core.override
  GetCoreVariantRequest createEmptyInstance() => GetCoreVariantRequest._();
  @$core.pragma('dart2js:noInline')
  static GetCoreVariantRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCoreVariantRequest>(GetCoreVariantRequest.$_createMessage);
  static GetCoreVariantRequest? _defaultInstance;
}

class GetCoreVariantResponse extends $pb.GeneratedMessage {
  factory GetCoreVariantResponse({
    $core.String? id,
  }) {
    final result = GetCoreVariantResponse._();
    if (id != null) result.id = id;
    return result;
  }

  GetCoreVariantResponse._();

  factory GetCoreVariantResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCoreVariantResponse()..mergeFromBuffer(data, registry);
  factory GetCoreVariantResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetCoreVariantResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetCoreVariantResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: GetCoreVariantResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCoreVariantResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetCoreVariantResponse copyWith(void Function(GetCoreVariantResponse) updates) =>
      super.copyWith((message) => updates(message as GetCoreVariantResponse)) as GetCoreVariantResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetCoreVariantResponse() / GetCoreVariantResponse.new instead')
  static GetCoreVariantResponse create() => GetCoreVariantResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetCoreVariantResponse._();
  @$core.override
  GetCoreVariantResponse createEmptyInstance() => GetCoreVariantResponse._();
  @$core.pragma('dart2js:noInline')
  static GetCoreVariantResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetCoreVariantResponse>(GetCoreVariantResponse.$_createMessage);
  static GetCoreVariantResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class SetCoreVariantRequest extends $pb.GeneratedMessage {
  factory SetCoreVariantRequest({
    $core.String? id,
  }) {
    final result = SetCoreVariantRequest._();
    if (id != null) result.id = id;
    return result;
  }

  SetCoreVariantRequest._();

  factory SetCoreVariantRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetCoreVariantRequest()..mergeFromBuffer(data, registry);
  factory SetCoreVariantRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetCoreVariantRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetCoreVariantRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: SetCoreVariantRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetCoreVariantRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetCoreVariantRequest copyWith(void Function(SetCoreVariantRequest) updates) =>
      super.copyWith((message) => updates(message as SetCoreVariantRequest)) as SetCoreVariantRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetCoreVariantRequest() / SetCoreVariantRequest.new instead')
  static SetCoreVariantRequest create() => SetCoreVariantRequest._();
  static $pb.GeneratedMessage $_createMessage() => SetCoreVariantRequest._();
  @$core.override
  SetCoreVariantRequest createEmptyInstance() => SetCoreVariantRequest._();
  @$core.pragma('dart2js:noInline')
  static SetCoreVariantRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetCoreVariantRequest>(SetCoreVariantRequest.$_createMessage);
  static SetCoreVariantRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);
}

class SetCoreVariantResponse extends $pb.GeneratedMessage {
  factory SetCoreVariantResponse() => SetCoreVariantResponse._();

  SetCoreVariantResponse._();

  factory SetCoreVariantResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetCoreVariantResponse()..mergeFromBuffer(data, registry);
  factory SetCoreVariantResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetCoreVariantResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetCoreVariantResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: SetCoreVariantResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetCoreVariantResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetCoreVariantResponse copyWith(void Function(SetCoreVariantResponse) updates) =>
      super.copyWith((message) => updates(message as SetCoreVariantResponse)) as SetCoreVariantResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetCoreVariantResponse() / SetCoreVariantResponse.new instead')
  static SetCoreVariantResponse create() => SetCoreVariantResponse._();
  static $pb.GeneratedMessage $_createMessage() => SetCoreVariantResponse._();
  @$core.override
  SetCoreVariantResponse createEmptyInstance() => SetCoreVariantResponse._();
  @$core.pragma('dart2js:noInline')
  static SetCoreVariantResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetCoreVariantResponse>(SetCoreVariantResponse.$_createMessage);
  static SetCoreVariantResponse? _defaultInstance;
}

class GetElectrumServerRequest extends $pb.GeneratedMessage {
  factory GetElectrumServerRequest() => GetElectrumServerRequest._();

  GetElectrumServerRequest._();

  factory GetElectrumServerRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetElectrumServerRequest()..mergeFromBuffer(data, registry);
  factory GetElectrumServerRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetElectrumServerRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetElectrumServerRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: GetElectrumServerRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetElectrumServerRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetElectrumServerRequest copyWith(void Function(GetElectrumServerRequest) updates) =>
      super.copyWith((message) => updates(message as GetElectrumServerRequest)) as GetElectrumServerRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetElectrumServerRequest() / GetElectrumServerRequest.new instead')
  static GetElectrumServerRequest create() => GetElectrumServerRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetElectrumServerRequest._();
  @$core.override
  GetElectrumServerRequest createEmptyInstance() => GetElectrumServerRequest._();
  @$core.pragma('dart2js:noInline')
  static GetElectrumServerRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetElectrumServerRequest>(GetElectrumServerRequest.$_createMessage);
  static GetElectrumServerRequest? _defaultInstance;
}

class GetElectrumServerResponse extends $pb.GeneratedMessage {
  factory GetElectrumServerResponse({
    $core.String? url,
    $core.bool? isOverride,
    $core.String? defaultUrl,
  }) {
    final result = GetElectrumServerResponse._();
    if (url != null) result.url = url;
    if (isOverride != null) result.isOverride = isOverride;
    if (defaultUrl != null) result.defaultUrl = defaultUrl;
    return result;
  }

  GetElectrumServerResponse._();

  factory GetElectrumServerResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetElectrumServerResponse()..mergeFromBuffer(data, registry);
  factory GetElectrumServerResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetElectrumServerResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetElectrumServerResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: GetElectrumServerResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'url')
    ..aOB(2, _omitFieldNames ? '' : 'isOverride')
    ..aOS(3, _omitFieldNames ? '' : 'defaultUrl')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetElectrumServerResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetElectrumServerResponse copyWith(void Function(GetElectrumServerResponse) updates) =>
      super.copyWith((message) => updates(message as GetElectrumServerResponse)) as GetElectrumServerResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetElectrumServerResponse() / GetElectrumServerResponse.new instead')
  static GetElectrumServerResponse create() => GetElectrumServerResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetElectrumServerResponse._();
  @$core.override
  GetElectrumServerResponse createEmptyInstance() => GetElectrumServerResponse._();
  @$core.pragma('dart2js:noInline')
  static GetElectrumServerResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetElectrumServerResponse>(GetElectrumServerResponse.$_createMessage);
  static GetElectrumServerResponse? _defaultInstance;

  /// Effective Esplora endpoint the electrum wallet is currently using.
  @$pb.TagNumber(1)
  $core.String get url => $_getSZ(0);
  @$pb.TagNumber(1)
  set url($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUrl() => $_clearField(1);

  /// True when url is a user-set override rather than the network default.
  @$pb.TagNumber(2)
  $core.bool get isOverride => $_getBF(1);
  @$pb.TagNumber(2)
  set isOverride($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasIsOverride() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsOverride() => $_clearField(2);

  /// The network's built-in default endpoint (so the UI can offer "reset").
  @$pb.TagNumber(3)
  $core.String get defaultUrl => $_getSZ(2);
  @$pb.TagNumber(3)
  set defaultUrl($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDefaultUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearDefaultUrl() => $_clearField(3);
}

class SetElectrumServerRequest extends $pb.GeneratedMessage {
  factory SetElectrumServerRequest({
    $core.String? url,
  }) {
    final result = SetElectrumServerRequest._();
    if (url != null) result.url = url;
    return result;
  }

  SetElectrumServerRequest._();

  factory SetElectrumServerRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetElectrumServerRequest()..mergeFromBuffer(data, registry);
  factory SetElectrumServerRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetElectrumServerRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetElectrumServerRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: SetElectrumServerRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'url')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetElectrumServerRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetElectrumServerRequest copyWith(void Function(SetElectrumServerRequest) updates) =>
      super.copyWith((message) => updates(message as SetElectrumServerRequest)) as SetElectrumServerRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetElectrumServerRequest() / SetElectrumServerRequest.new instead')
  static SetElectrumServerRequest create() => SetElectrumServerRequest._();
  static $pb.GeneratedMessage $_createMessage() => SetElectrumServerRequest._();
  @$core.override
  SetElectrumServerRequest createEmptyInstance() => SetElectrumServerRequest._();
  @$core.pragma('dart2js:noInline')
  static SetElectrumServerRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetElectrumServerRequest>(SetElectrumServerRequest.$_createMessage);
  static SetElectrumServerRequest? _defaultInstance;

  /// New Esplora endpoint (http/https). Empty resets to the network default.
  @$pb.TagNumber(1)
  $core.String get url => $_getSZ(0);
  @$pb.TagNumber(1)
  set url($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUrl() => $_clearField(1);
}

class SetElectrumServerResponse extends $pb.GeneratedMessage {
  factory SetElectrumServerResponse({
    $core.String? url,
    $fixnum.Int64? tipHeight,
  }) {
    final result = SetElectrumServerResponse._();
    if (url != null) result.url = url;
    if (tipHeight != null) result.tipHeight = tipHeight;
    return result;
  }

  SetElectrumServerResponse._();

  factory SetElectrumServerResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetElectrumServerResponse()..mergeFromBuffer(data, registry);
  factory SetElectrumServerResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetElectrumServerResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetElectrumServerResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: SetElectrumServerResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'url')
    ..aInt64(2, _omitFieldNames ? '' : 'tipHeight')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetElectrumServerResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetElectrumServerResponse copyWith(void Function(SetElectrumServerResponse) updates) =>
      super.copyWith((message) => updates(message as SetElectrumServerResponse)) as SetElectrumServerResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetElectrumServerResponse() / SetElectrumServerResponse.new instead')
  static SetElectrumServerResponse create() => SetElectrumServerResponse._();
  static $pb.GeneratedMessage $_createMessage() => SetElectrumServerResponse._();
  @$core.override
  SetElectrumServerResponse createEmptyInstance() => SetElectrumServerResponse._();
  @$core.pragma('dart2js:noInline')
  static SetElectrumServerResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetElectrumServerResponse>(SetElectrumServerResponse.$_createMessage);
  static SetElectrumServerResponse? _defaultInstance;

  /// Endpoint now in use (the normalized override, or the default after a reset).
  @$pb.TagNumber(1)
  $core.String get url => $_getSZ(0);
  @$pb.TagNumber(1)
  set url($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasUrl() => $_has(0);
  @$pb.TagNumber(1)
  void clearUrl() => $_clearField(1);

  /// Chain tip height fetched from the new server, confirming connectivity.
  @$pb.TagNumber(2)
  $fixnum.Int64 get tipHeight => $_getI64(1);
  @$pb.TagNumber(2)
  set tipHeight($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTipHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearTipHeight() => $_clearField(2);
}

class GetTorConfigRequest extends $pb.GeneratedMessage {
  factory GetTorConfigRequest() => GetTorConfigRequest._();

  GetTorConfigRequest._();

  factory GetTorConfigRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTorConfigRequest()..mergeFromBuffer(data, registry);
  factory GetTorConfigRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTorConfigRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTorConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: GetTorConfigRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTorConfigRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTorConfigRequest copyWith(void Function(GetTorConfigRequest) updates) =>
      super.copyWith((message) => updates(message as GetTorConfigRequest)) as GetTorConfigRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetTorConfigRequest() / GetTorConfigRequest.new instead')
  static GetTorConfigRequest create() => GetTorConfigRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetTorConfigRequest._();
  @$core.override
  GetTorConfigRequest createEmptyInstance() => GetTorConfigRequest._();
  @$core.pragma('dart2js:noInline')
  static GetTorConfigRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetTorConfigRequest>(GetTorConfigRequest.$_createMessage);
  static GetTorConfigRequest? _defaultInstance;
}

class GetTorConfigResponse extends $pb.GeneratedMessage {
  factory GetTorConfigResponse({
    $core.bool? enabled,
    $core.String? proxy,
    $core.String? defaultProxy,
  }) {
    final result = GetTorConfigResponse._();
    if (enabled != null) result.enabled = enabled;
    if (proxy != null) result.proxy = proxy;
    if (defaultProxy != null) result.defaultProxy = defaultProxy;
    return result;
  }

  GetTorConfigResponse._();

  factory GetTorConfigResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTorConfigResponse()..mergeFromBuffer(data, registry);
  factory GetTorConfigResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetTorConfigResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetTorConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: GetTorConfigResponse.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'enabled')
    ..aOS(2, _omitFieldNames ? '' : 'proxy')
    ..aOS(3, _omitFieldNames ? '' : 'defaultProxy')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTorConfigResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetTorConfigResponse copyWith(void Function(GetTorConfigResponse) updates) =>
      super.copyWith((message) => updates(message as GetTorConfigResponse)) as GetTorConfigResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetTorConfigResponse() / GetTorConfigResponse.new instead')
  static GetTorConfigResponse create() => GetTorConfigResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetTorConfigResponse._();
  @$core.override
  GetTorConfigResponse createEmptyInstance() => GetTorConfigResponse._();
  @$core.pragma('dart2js:noInline')
  static GetTorConfigResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetTorConfigResponse>(GetTorConfigResponse.$_createMessage);
  static GetTorConfigResponse? _defaultInstance;

  /// True when chain connections are routed through the SOCKS5 proxy.
  @$pb.TagNumber(1)
  $core.bool get enabled => $_getBF(0);
  @$pb.TagNumber(1)
  set enabled($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEnabled() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnabled() => $_clearField(1);

  /// SOCKS5 proxy address (host:port) used when enabled.
  @$pb.TagNumber(2)
  $core.String get proxy => $_getSZ(1);
  @$pb.TagNumber(2)
  set proxy($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProxy() => $_has(1);
  @$pb.TagNumber(2)
  void clearProxy() => $_clearField(2);

  /// Default proxy address suggested when none is set (Tor: 127.0.0.1:9050).
  @$pb.TagNumber(3)
  $core.String get defaultProxy => $_getSZ(2);
  @$pb.TagNumber(3)
  set defaultProxy($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDefaultProxy() => $_has(2);
  @$pb.TagNumber(3)
  void clearDefaultProxy() => $_clearField(3);
}

class SetTorConfigRequest extends $pb.GeneratedMessage {
  factory SetTorConfigRequest({
    $core.bool? enabled,
    $core.String? proxy,
  }) {
    final result = SetTorConfigRequest._();
    if (enabled != null) result.enabled = enabled;
    if (proxy != null) result.proxy = proxy;
    return result;
  }

  SetTorConfigRequest._();

  factory SetTorConfigRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetTorConfigRequest()..mergeFromBuffer(data, registry);
  factory SetTorConfigRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetTorConfigRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetTorConfigRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: SetTorConfigRequest.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'enabled')
    ..aOS(2, _omitFieldNames ? '' : 'proxy')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetTorConfigRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetTorConfigRequest copyWith(void Function(SetTorConfigRequest) updates) =>
      super.copyWith((message) => updates(message as SetTorConfigRequest)) as SetTorConfigRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetTorConfigRequest() / SetTorConfigRequest.new instead')
  static SetTorConfigRequest create() => SetTorConfigRequest._();
  static $pb.GeneratedMessage $_createMessage() => SetTorConfigRequest._();
  @$core.override
  SetTorConfigRequest createEmptyInstance() => SetTorConfigRequest._();
  @$core.pragma('dart2js:noInline')
  static SetTorConfigRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetTorConfigRequest>(SetTorConfigRequest.$_createMessage);
  static SetTorConfigRequest? _defaultInstance;

  /// Enable or disable routing chain connections through the SOCKS5 proxy.
  @$pb.TagNumber(1)
  $core.bool get enabled => $_getBF(0);
  @$pb.TagNumber(1)
  set enabled($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEnabled() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnabled() => $_clearField(1);

  /// SOCKS5 proxy address (host:port). Required when enabled; empty uses the default.
  @$pb.TagNumber(2)
  $core.String get proxy => $_getSZ(1);
  @$pb.TagNumber(2)
  set proxy($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProxy() => $_has(1);
  @$pb.TagNumber(2)
  void clearProxy() => $_clearField(2);
}

class SetTorConfigResponse extends $pb.GeneratedMessage {
  factory SetTorConfigResponse({
    $core.bool? enabled,
    $core.String? proxy,
    $fixnum.Int64? tipHeight,
  }) {
    final result = SetTorConfigResponse._();
    if (enabled != null) result.enabled = enabled;
    if (proxy != null) result.proxy = proxy;
    if (tipHeight != null) result.tipHeight = tipHeight;
    return result;
  }

  SetTorConfigResponse._();

  factory SetTorConfigResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetTorConfigResponse()..mergeFromBuffer(data, registry);
  factory SetTorConfigResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SetTorConfigResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetTorConfigResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: SetTorConfigResponse.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'enabled')
    ..aOS(2, _omitFieldNames ? '' : 'proxy')
    ..aInt64(3, _omitFieldNames ? '' : 'tipHeight')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetTorConfigResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SetTorConfigResponse copyWith(void Function(SetTorConfigResponse) updates) =>
      super.copyWith((message) => updates(message as SetTorConfigResponse)) as SetTorConfigResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SetTorConfigResponse() / SetTorConfigResponse.new instead')
  static SetTorConfigResponse create() => SetTorConfigResponse._();
  static $pb.GeneratedMessage $_createMessage() => SetTorConfigResponse._();
  @$core.override
  SetTorConfigResponse createEmptyInstance() => SetTorConfigResponse._();
  @$core.pragma('dart2js:noInline')
  static SetTorConfigResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SetTorConfigResponse>(SetTorConfigResponse.$_createMessage);
  static SetTorConfigResponse? _defaultInstance;

  /// Config now in effect.
  @$pb.TagNumber(1)
  $core.bool get enabled => $_getBF(0);
  @$pb.TagNumber(1)
  set enabled($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEnabled() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnabled() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get proxy => $_getSZ(1);
  @$pb.TagNumber(2)
  set proxy($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasProxy() => $_has(1);
  @$pb.TagNumber(2)
  void clearProxy() => $_clearField(2);

  /// Chain tip height fetched through the proxy, confirming connectivity.
  @$pb.TagNumber(3)
  $fixnum.Int64 get tipHeight => $_getI64(2);
  @$pb.TagNumber(3)
  set tipHeight($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTipHeight() => $_has(2);
  @$pb.TagNumber(3)
  void clearTipHeight() => $_clearField(3);
}

class WatchWalletDataResponse extends $pb.GeneratedMessage {
  factory WatchWalletDataResponse({
    @$core.Deprecated('This field is deprecated.') $core.bool? hasWallet,
    $core.bool? encrypted,
    @$core.Deprecated('This field is deprecated.') $core.bool? unlocked,
    $core.String? activeWalletId,
    $core.Iterable<WalletMetadata>? wallets,
    $core.double? confirmedSats,
    $core.double? unconfirmedSats,
    $fixnum.Int64? seq,
    $core.bool? heartbeat,
    WalletState? state,
  }) {
    final result = WatchWalletDataResponse._();
    if (hasWallet != null) result.hasWallet = hasWallet;
    if (encrypted != null) result.encrypted = encrypted;
    if (unlocked != null) result.unlocked = unlocked;
    if (activeWalletId != null) result.activeWalletId = activeWalletId;
    if (wallets != null) result.wallets.addAll(wallets);
    if (confirmedSats != null) result.confirmedSats = confirmedSats;
    if (unconfirmedSats != null) result.unconfirmedSats = unconfirmedSats;
    if (seq != null) result.seq = seq;
    if (heartbeat != null) result.heartbeat = heartbeat;
    if (state != null) result.state = state;
    return result;
  }

  WatchWalletDataResponse._();

  factory WatchWalletDataResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchWalletDataResponse()..mergeFromBuffer(data, registry);
  factory WatchWalletDataResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchWalletDataResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WatchWalletDataResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: WatchWalletDataResponse.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'hasWallet')
    ..aOB(2, _omitFieldNames ? '' : 'encrypted')
    ..aOB(3, _omitFieldNames ? '' : 'unlocked')
    ..aOS(4, _omitFieldNames ? '' : 'activeWalletId')
    ..pPM<WalletMetadata>(5, _omitFieldNames ? '' : 'wallets', subBuilder: WalletMetadata.$_createMessage)
    ..aD(6, _omitFieldNames ? '' : 'confirmedSats')
    ..aD(7, _omitFieldNames ? '' : 'unconfirmedSats')
    ..aInt64(8, _omitFieldNames ? '' : 'seq')
    ..aOB(9, _omitFieldNames ? '' : 'heartbeat')
    ..aE<WalletState>(10, _omitFieldNames ? '' : 'state', enumValues: WalletState.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchWalletDataResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchWalletDataResponse copyWith(void Function(WatchWalletDataResponse) updates) =>
      super.copyWith((message) => updates(message as WatchWalletDataResponse)) as WatchWalletDataResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WatchWalletDataResponse() / WatchWalletDataResponse.new instead')
  static WatchWalletDataResponse create() => WatchWalletDataResponse._();
  static $pb.GeneratedMessage $_createMessage() => WatchWalletDataResponse._();
  @$core.override
  WatchWalletDataResponse createEmptyInstance() => WatchWalletDataResponse._();
  @$core.pragma('dart2js:noInline')
  static WatchWalletDataResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WatchWalletDataResponse>(WatchWalletDataResponse.$_createMessage);
  static WatchWalletDataResponse? _defaultInstance;

  /// Wallet status
  /// Use state.
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(1)
  $core.bool get hasWallet => $_getBF(0);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(1)
  set hasWallet($core.bool value) => $_setBool(0, value);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(1)
  $core.bool hasHasWallet() => $_has(0);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(1)
  void clearHasWallet() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.bool get encrypted => $_getBF(1);
  @$pb.TagNumber(2)
  set encrypted($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasEncrypted() => $_has(1);
  @$pb.TagNumber(2)
  void clearEncrypted() => $_clearField(2);

  /// Use state.
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(3)
  $core.bool get unlocked => $_getBF(2);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(3)
  set unlocked($core.bool value) => $_setBool(2, value);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(3)
  $core.bool hasUnlocked() => $_has(2);
  @$core.Deprecated('This field is deprecated.')
  @$pb.TagNumber(3)
  void clearUnlocked() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get activeWalletId => $_getSZ(3);
  @$pb.TagNumber(4)
  set activeWalletId($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasActiveWalletId() => $_has(3);
  @$pb.TagNumber(4)
  void clearActiveWalletId() => $_clearField(4);

  /// All wallets
  @$pb.TagNumber(5)
  $pb.PbList<WalletMetadata> get wallets => $_getList(4);

  /// Active wallet balance (zero if no active wallet)
  @$pb.TagNumber(6)
  $core.double get confirmedSats => $_getN(5);
  @$pb.TagNumber(6)
  set confirmedSats($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(6)
  $core.bool hasConfirmedSats() => $_has(5);
  @$pb.TagNumber(6)
  void clearConfirmedSats() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.double get unconfirmedSats => $_getN(6);
  @$pb.TagNumber(7)
  set unconfirmedSats($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasUnconfirmedSats() => $_has(6);
  @$pb.TagNumber(7)
  void clearUnconfirmedSats() => $_clearField(7);

  /// Monotonic sequence number per send within a single stream. Lets the
  /// client detect missed events across a reconnect.
  @$pb.TagNumber(8)
  $fixnum.Int64 get seq => $_getI64(7);
  @$pb.TagNumber(8)
  set seq($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSeq() => $_has(7);
  @$pb.TagNumber(8)
  void clearSeq() => $_clearField(8);

  /// Idle keepalive frames carry no payload — only `seq` and `heartbeat=true`
  /// are populated. The client's heartbeat watchdog uses these to tell a
  /// healthy-but-quiet stream apart from a half-open connection.
  @$pb.TagNumber(9)
  $core.bool get heartbeat => $_getBF(8);
  @$pb.TagNumber(9)
  set heartbeat($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasHeartbeat() => $_has(8);
  @$pb.TagNumber(9)
  void clearHeartbeat() => $_clearField(9);

  @$pb.TagNumber(10)
  WalletState get state => $_getN(9);
  @$pb.TagNumber(10)
  set state(WalletState value) => $_setField(10, value);
  @$pb.TagNumber(10)
  $core.bool hasState() => $_has(9);
  @$pb.TagNumber(10)
  void clearState() => $_clearField(10);
}

class CreateDepositRequest extends $pb.GeneratedMessage {
  factory CreateDepositRequest({
    $core.int? slot,
    $core.String? walletId,
    $core.String? destination,
    $fixnum.Int64? amountSats,
    $fixnum.Int64? feeSats,
  }) {
    final result = CreateDepositRequest._();
    if (slot != null) result.slot = slot;
    if (walletId != null) result.walletId = walletId;
    if (destination != null) result.destination = destination;
    if (amountSats != null) result.amountSats = amountSats;
    if (feeSats != null) result.feeSats = feeSats;
    return result;
  }

  CreateDepositRequest._();

  factory CreateDepositRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateDepositRequest()..mergeFromBuffer(data, registry);
  factory CreateDepositRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateDepositRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateDepositRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: CreateDepositRequest.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'slot')
    ..aOS(2, _omitFieldNames ? '' : 'walletId')
    ..aOS(3, _omitFieldNames ? '' : 'destination')
    ..aInt64(4, _omitFieldNames ? '' : 'amountSats')
    ..aInt64(5, _omitFieldNames ? '' : 'feeSats')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateDepositRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateDepositRequest copyWith(void Function(CreateDepositRequest) updates) =>
      super.copyWith((message) => updates(message as CreateDepositRequest)) as CreateDepositRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateDepositRequest() / CreateDepositRequest.new instead')
  static CreateDepositRequest create() => CreateDepositRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateDepositRequest._();
  @$core.override
  CreateDepositRequest createEmptyInstance() => CreateDepositRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateDepositRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateDepositRequest>(CreateDepositRequest.$_createMessage);
  static CreateDepositRequest? _defaultInstance;

  /// Sidechain slot to credit, 0-255.
  @$pb.TagNumber(1)
  $core.int get slot => $_getIZ(0);
  @$pb.TagNumber(1)
  set slot($core.int value) => $_setSignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSlot() => $_has(0);
  @$pb.TagNumber(1)
  void clearSlot() => $_clearField(1);

  /// Wallet that funds the deposit. Empty uses the active wallet.
  @$pb.TagNumber(2)
  $core.String get walletId => $_getSZ(1);
  @$pb.TagNumber(2)
  set walletId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWalletId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWalletId() => $_clearField(2);

  /// Sidechain address credited with the deposit.
  @$pb.TagNumber(3)
  $core.String get destination => $_getSZ(2);
  @$pb.TagNumber(3)
  set destination($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasDestination() => $_has(2);
  @$pb.TagNumber(3)
  void clearDestination() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get amountSats => $_getI64(3);
  @$pb.TagNumber(4)
  set amountSats($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAmountSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearAmountSats() => $_clearField(4);

  /// Mainchain fee. The deposit tx carries an unsigned CTIP input, so the fee
  /// cannot be estimated from a rate.
  @$pb.TagNumber(5)
  $fixnum.Int64 get feeSats => $_getI64(4);
  @$pb.TagNumber(5)
  set feeSats($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFeeSats() => $_has(4);
  @$pb.TagNumber(5)
  void clearFeeSats() => $_clearField(5);
}

class CreateDepositResponse extends $pb.GeneratedMessage {
  factory CreateDepositResponse({
    $core.String? txid,
  }) {
    final result = CreateDepositResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  CreateDepositResponse._();

  factory CreateDepositResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateDepositResponse()..mergeFromBuffer(data, registry);
  factory CreateDepositResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateDepositResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateDepositResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'walletmanager.v1'),
      createEmptyInstance: CreateDepositResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateDepositResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateDepositResponse copyWith(void Function(CreateDepositResponse) updates) =>
      super.copyWith((message) => updates(message as CreateDepositResponse)) as CreateDepositResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateDepositResponse() / CreateDepositResponse.new instead')
  static CreateDepositResponse create() => CreateDepositResponse._();
  static $pb.GeneratedMessage $_createMessage() => CreateDepositResponse._();
  @$core.override
  CreateDepositResponse createEmptyInstance() => CreateDepositResponse._();
  @$core.pragma('dart2js:noInline')
  static CreateDepositResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<CreateDepositResponse>(CreateDepositResponse.$_createMessage);
  static CreateDepositResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class WalletManagerServiceApi {
  final $pb.RpcClient _client;

  WalletManagerServiceApi(this._client);

  /// Wallet lifecycle
  $async.Future<GetWalletStatusResponse> getWalletStatus($pb.ClientContext? ctx, GetWalletStatusRequest request) =>
      _client.invoke<GetWalletStatusResponse>(
          ctx, 'WalletManagerService', 'GetWalletStatus', request, GetWalletStatusResponse());

  /// How much of Bitcoin this install runs. The frontend asks the user before
  /// it boots anything, and blocks until GetNodeMode reports a mode.
  /// Deposits this install made to a sidechain treasury. An M5 is an ordinary
  /// transaction on the wire, so the record comes from when we broadcast it.
  $async.Future<ListSidechainDepositsResponse> listSidechainDeposits(
          $pb.ClientContext? ctx, ListSidechainDepositsRequest request) =>
      _client.invoke<ListSidechainDepositsResponse>(
          ctx, 'WalletManagerService', 'ListSidechainDeposits', request, ListSidechainDepositsResponse());
  $async.Future<GetSidechainDepositTotalsResponse> getSidechainDepositTotals(
          $pb.ClientContext? ctx, GetSidechainDepositTotalsRequest request) =>
      _client.invoke<GetSidechainDepositTotalsResponse>(
          ctx, 'WalletManagerService', 'GetSidechainDepositTotals', request, GetSidechainDepositTotalsResponse());
  $async.Future<GetNodeModeResponse> getNodeMode($pb.ClientContext? ctx, GetNodeModeRequest request) =>
      _client.invoke<GetNodeModeResponse>(ctx, 'WalletManagerService', 'GetNodeMode', request, GetNodeModeResponse());
  $async.Future<SetNodeModeResponse> setNodeMode($pb.ClientContext? ctx, SetNodeModeRequest request) =>
      _client.invoke<SetNodeModeResponse>(ctx, 'WalletManagerService', 'SetNodeMode', request, SetNodeModeResponse());
  $async.Future<GenerateWalletResponse> generateWallet($pb.ClientContext? ctx, GenerateWalletRequest request) => _client
      .invoke<GenerateWalletResponse>(ctx, 'WalletManagerService', 'GenerateWallet', request, GenerateWalletResponse());
  $async.Future<UnlockWalletResponse> unlockWallet($pb.ClientContext? ctx, UnlockWalletRequest request) => _client
      .invoke<UnlockWalletResponse>(ctx, 'WalletManagerService', 'UnlockWallet', request, UnlockWalletResponse());
  $async.Future<LockWalletResponse> lockWallet($pb.ClientContext? ctx, LockWalletRequest request) =>
      _client.invoke<LockWalletResponse>(ctx, 'WalletManagerService', 'LockWallet', request, LockWalletResponse());
  $async.Future<EncryptWalletResponse> encryptWallet($pb.ClientContext? ctx, EncryptWalletRequest request) => _client
      .invoke<EncryptWalletResponse>(ctx, 'WalletManagerService', 'EncryptWallet', request, EncryptWalletResponse());
  $async.Future<ChangePasswordResponse> changePassword($pb.ClientContext? ctx, ChangePasswordRequest request) => _client
      .invoke<ChangePasswordResponse>(ctx, 'WalletManagerService', 'ChangePassword', request, ChangePasswordResponse());
  $async.Future<RemoveEncryptionResponse> removeEncryption($pb.ClientContext? ctx, RemoveEncryptionRequest request) =>
      _client.invoke<RemoveEncryptionResponse>(
          ctx, 'WalletManagerService', 'RemoveEncryption', request, RemoveEncryptionResponse());
  $async.Future<ListWalletsResponse> listWallets($pb.ClientContext? ctx, ListWalletsRequest request) =>
      _client.invoke<ListWalletsResponse>(ctx, 'WalletManagerService', 'ListWallets', request, ListWalletsResponse());
  $async.Future<SwitchWalletResponse> switchWallet($pb.ClientContext? ctx, SwitchWalletRequest request) => _client
      .invoke<SwitchWalletResponse>(ctx, 'WalletManagerService', 'SwitchWallet', request, SwitchWalletResponse());
  $async.Future<UpdateWalletMetadataResponse> updateWalletMetadata(
          $pb.ClientContext? ctx, UpdateWalletMetadataRequest request) =>
      _client.invoke<UpdateWalletMetadataResponse>(
          ctx, 'WalletManagerService', 'UpdateWalletMetadata', request, UpdateWalletMetadataResponse());
  $async.Future<DeleteWalletResponse> deleteWallet($pb.ClientContext? ctx, DeleteWalletRequest request) => _client
      .invoke<DeleteWalletResponse>(ctx, 'WalletManagerService', 'DeleteWallet', request, DeleteWalletResponse());
  $async.Future<DeleteAllWalletsResponse> deleteAllWallets($pb.ClientContext? ctx, DeleteAllWalletsRequest request) =>
      _client.invoke<DeleteAllWalletsResponse>(
          ctx, 'WalletManagerService', 'DeleteAllWallets', request, DeleteAllWalletsResponse());
  $async.Future<ListWalletBackupsResponse> listWalletBackups(
          $pb.ClientContext? ctx, ListWalletBackupsRequest request) =>
      _client.invoke<ListWalletBackupsResponse>(
          ctx, 'WalletManagerService', 'ListWalletBackups', request, ListWalletBackupsResponse());
  $async.Future<RestoreWalletBackupResponse> restoreWalletBackup(
          $pb.ClientContext? ctx, RestoreWalletBackupRequest request) =>
      _client.invoke<RestoreWalletBackupResponse>(
          ctx, 'WalletManagerService', 'RestoreWalletBackup', request, RestoreWalletBackupResponse());
  $async.Future<RestoreWalletBackupProgressResponse> restoreWalletBackupStream(
          $pb.ClientContext? ctx, RestoreWalletBackupRequest request) =>
      _client.invoke<RestoreWalletBackupProgressResponse>(
          ctx, 'WalletManagerService', 'RestoreWalletBackupStream', request, RestoreWalletBackupProgressResponse());
  $async.Future<CreateWatchOnlyWalletResponse> createWatchOnlyWallet(
          $pb.ClientContext? ctx, CreateWatchOnlyWalletRequest request) =>
      _client.invoke<CreateWatchOnlyWalletResponse>(
          ctx, 'WalletManagerService', 'CreateWatchOnlyWallet', request, CreateWatchOnlyWalletResponse());

  /// Create an electrum wallet: keys are generated locally, but no local Bitcoin
  /// Core or enforcer runs. The wallet reads its chain from Esplora.
  $async.Future<CreateElectrumWalletResponse> createElectrumWallet(
          $pb.ClientContext? ctx, CreateElectrumWalletRequest request) =>
      _client.invoke<CreateElectrumWalletResponse>(
          ctx, 'WalletManagerService', 'CreateElectrumWallet', request, CreateElectrumWalletResponse());
  $async.Future<CreateMultisigWalletResponse> createMultisigWallet(
          $pb.ClientContext? ctx, CreateMultisigWalletRequest request) =>
      _client.invoke<CreateMultisigWalletResponse>(
          ctx, 'WalletManagerService', 'CreateMultisigWallet', request, CreateMultisigWalletResponse());

  /// ParseMultisigConfig parses a descriptor or a wallet-config file (Coldcard
  /// text / Sparrow / Specter / Caravan JSON) into an m-of-n policy + cosigners.
  $async.Future<ParseMultisigConfigResponse> parseMultisigConfig(
          $pb.ClientContext? ctx, ParseMultisigConfigRequest request) =>
      _client.invoke<ParseMultisigConfigResponse>(
          ctx, 'WalletManagerService', 'ParseMultisigConfig', request, ParseMultisigConfigResponse());

  /// ValidateDescriptor reads an output descriptor — single-sig or sortedmulti —
  /// into the script policy it encodes.
  $async.Future<ValidateDescriptorResponse> validateDescriptor(
          $pb.ClientContext? ctx, ValidateDescriptorRequest request) =>
      _client.invoke<ValidateDescriptorResponse>(
          ctx, 'WalletManagerService', 'ValidateDescriptor', request, ValidateDescriptorResponse());

  /// ValidateDerivationPath canonicalises a BIP32 derivation path, or fails with
  /// the reason it is unusable.
  $async.Future<ValidateDerivationPathResponse> validateDerivationPath(
          $pb.ClientContext? ctx, ValidateDerivationPathRequest request) =>
      _client.invoke<ValidateDerivationPathResponse>(
          ctx, 'WalletManagerService', 'ValidateDerivationPath', request, ValidateDerivationPathResponse());

  /// ListDerivationPaths returns the standard account paths for a policy on the
  /// network this backend runs.
  $async.Future<ListDerivationPathsResponse> listDerivationPaths(
          $pb.ClientContext? ctx, ListDerivationPathsRequest request) =>
      _client.invoke<ListDerivationPathsResponse>(
          ctx, 'WalletManagerService', 'ListDerivationPaths', request, ListDerivationPathsResponse());

  /// Core wallet management
  $async.Future<CreateBitcoinCoreWalletResponse> createBitcoinCoreWallet(
          $pb.ClientContext? ctx, CreateBitcoinCoreWalletRequest request) =>
      _client.invoke<CreateBitcoinCoreWalletResponse>(
          ctx, 'WalletManagerService', 'CreateBitcoinCoreWallet', request, CreateBitcoinCoreWalletResponse());
  $async.Future<EnsureCoreWalletsResponse> ensureCoreWallets(
          $pb.ClientContext? ctx, EnsureCoreWalletsRequest request) =>
      _client.invoke<EnsureCoreWalletsResponse>(
          ctx, 'WalletManagerService', 'EnsureCoreWallets', request, EnsureCoreWalletsResponse());

  /// Bitcoin operations (proxied through Core RPC)
  $async.Future<GetBalanceResponse> getBalance($pb.ClientContext? ctx, GetBalanceRequest request) =>
      _client.invoke<GetBalanceResponse>(ctx, 'WalletManagerService', 'GetBalance', request, GetBalanceResponse());
  $async.Future<RescanWalletResponse> rescanWallet($pb.ClientContext? ctx, RescanWalletRequest request) => _client
      .invoke<RescanWalletResponse>(ctx, 'WalletManagerService', 'RescanWallet', request, RescanWalletResponse());
  $async.Future<EstimateFeeResponse> estimateFee($pb.ClientContext? ctx, EstimateFeeRequest request) =>
      _client.invoke<EstimateFeeResponse>(ctx, 'WalletManagerService', 'EstimateFee', request, EstimateFeeResponse());
  $async.Future<GetNewAddressResponse> getNewAddress($pb.ClientContext? ctx, GetNewAddressRequest request) => _client
      .invoke<GetNewAddressResponse>(ctx, 'WalletManagerService', 'GetNewAddress', request, GetNewAddressResponse());
  $async.Future<SendTransactionResponse> sendTransaction($pb.ClientContext? ctx, SendTransactionRequest request) =>
      _client.invoke<SendTransactionResponse>(
          ctx, 'WalletManagerService', 'SendTransaction', request, SendTransactionResponse());

  /// PreviewSend builds a send at a fee rate, with the same coin selection as
  /// SendTransaction, and reports its fee and size. It broadcasts nothing.
  $async.Future<PreviewSendResponse> previewSend($pb.ClientContext? ctx, PreviewSendRequest request) =>
      _client.invoke<PreviewSendResponse>(ctx, 'WalletManagerService', 'PreviewSend', request, PreviewSendResponse());

  /// SetFrozenCoins records the coins the frontend froze. Every send after it
  /// leaves those coins alone, and Bitcoin Core holds them locked for the
  /// length of a send so its own coin selection skips them too.
  $async.Future<$1.Empty> setFrozenCoins($pb.ClientContext? ctx, SetFrozenCoinsRequest request) =>
      _client.invoke<$1.Empty>(ctx, 'WalletManagerService', 'SetFrozenCoins', request, $1.Empty());

  /// CreateDeposit broadcasts a BIP300 deposit request to a sidechain from any wallet.
  $async.Future<CreateDepositResponse> createDeposit($pb.ClientContext? ctx, CreateDepositRequest request) => _client
      .invoke<CreateDepositResponse>(ctx, 'WalletManagerService', 'CreateDeposit', request, CreateDepositResponse());
  $async.Future<ListTransactionsResponse> listTransactions($pb.ClientContext? ctx, ListTransactionsRequest request) =>
      _client.invoke<ListTransactionsResponse>(
          ctx, 'WalletManagerService', 'ListTransactions', request, ListTransactionsResponse());
  $async.Future<ListUnspentResponse> listUnspent($pb.ClientContext? ctx, ListUnspentRequest request) =>
      _client.invoke<ListUnspentResponse>(ctx, 'WalletManagerService', 'ListUnspent', request, ListUnspentResponse());
  $async.Future<ListReceiveAddressesResponse> listReceiveAddresses(
          $pb.ClientContext? ctx, ListReceiveAddressesRequest request) =>
      _client.invoke<ListReceiveAddressesResponse>(
          ctx, 'WalletManagerService', 'ListReceiveAddresses', request, ListReceiveAddressesResponse());
  $async.Future<GetTransactionDetailsResponse> getTransactionDetails(
          $pb.ClientContext? ctx, GetTransactionDetailsRequest request) =>
      _client.invoke<GetTransactionDetailsResponse>(
          ctx, 'WalletManagerService', 'GetTransactionDetails', request, GetTransactionDetailsResponse());
  $async.Future<DecodeTransactionResponse> decodeTransaction(
          $pb.ClientContext? ctx, DecodeTransactionRequest request) =>
      _client.invoke<DecodeTransactionResponse>(
          ctx, 'WalletManagerService', 'DecodeTransaction', request, DecodeTransactionResponse());
  $async.Future<BumpFeeResponse> bumpFee($pb.ClientContext? ctx, BumpFeeRequest request) =>
      _client.invoke<BumpFeeResponse>(ctx, 'WalletManagerService', 'BumpFee', request, BumpFeeResponse());

  /// PreviewBumpFee reports what a fee bump costs, and which output pays it,
  /// without broadcasting anything.
  $async.Future<PreviewBumpFeeResponse> previewBumpFee($pb.ClientContext? ctx, PreviewBumpFeeRequest request) => _client
      .invoke<PreviewBumpFeeResponse>(ctx, 'WalletManagerService', 'PreviewBumpFee', request, PreviewBumpFeeResponse());

  /// CreateCpfp spends an unconfirmed wallet UTXO with a child transaction whose
  /// fee lifts the parent+child package to the target fee rate (CPFP).
  $async.Future<CreateCpfpResponse> createCpfp($pb.ClientContext? ctx, CreateCpfpRequest request) =>
      _client.invoke<CreateCpfpResponse>(ctx, 'WalletManagerService', 'CreateCpfp', request, CreateCpfpResponse());

  /// CancelTransaction replaces an unconfirmed transaction with one that pays
  /// the wallet's own inputs of it back to the wallet.
  $async.Future<CancelTransactionResponse> cancelTransaction(
          $pb.ClientContext? ctx, CancelTransactionRequest request) =>
      _client.invoke<CancelTransactionResponse>(
          ctx, 'WalletManagerService', 'CancelTransaction', request, CancelTransactionResponse());
  $async.Future<DeriveAddressesResponse> deriveAddresses($pb.ClientContext? ctx, DeriveAddressesRequest request) =>
      _client.invoke<DeriveAddressesResponse>(
          ctx, 'WalletManagerService', 'DeriveAddresses', request, DeriveAddressesResponse());

  /// ListEcxBurns lists every burn of the current eCash network, newest first.
  $async.Future<ListEcxBurnsResponse> listEcxBurns($pb.ClientContext? ctx, ListEcxBurnsRequest request) => _client
      .invoke<ListEcxBurnsResponse>(ctx, 'WalletManagerService', 'ListEcxBurns', request, ListEcxBurnsResponse());

  /// PSBT (BIP174). CreatePsbt builds an unsigned PSBT for a send (works for
  /// watch-only wallets); SignPsbt adds this wallet's signatures; CombinePsbt
  /// merges cosigner PSBTs; FinalizePsbt extracts the raw transaction. Electrum
  /// wallets only.
  $async.Future<CreatePsbtResponse> createPsbt($pb.ClientContext? ctx, CreatePsbtRequest request) =>
      _client.invoke<CreatePsbtResponse>(ctx, 'WalletManagerService', 'CreatePsbt', request, CreatePsbtResponse());
  $async.Future<SignPsbtResponse> signPsbt($pb.ClientContext? ctx, SignPsbtRequest request) =>
      _client.invoke<SignPsbtResponse>(ctx, 'WalletManagerService', 'SignPsbt', request, SignPsbtResponse());

  /// SignPsbtWithCosigner signs a multisig PSBT with a single held cosigner's key
  /// (per-keystore signing), leaving the other legs for their own signers.
  $async.Future<SignPsbtWithCosignerResponse> signPsbtWithCosigner(
          $pb.ClientContext? ctx, SignPsbtWithCosignerRequest request) =>
      _client.invoke<SignPsbtWithCosignerResponse>(
          ctx, 'WalletManagerService', 'SignPsbtWithCosigner', request, SignPsbtWithCosignerResponse());
  $async.Future<CombinePsbtResponse> combinePsbt($pb.ClientContext? ctx, CombinePsbtRequest request) =>
      _client.invoke<CombinePsbtResponse>(ctx, 'WalletManagerService', 'CombinePsbt', request, CombinePsbtResponse());
  $async.Future<FinalizePsbtResponse> finalizePsbt($pb.ClientContext? ctx, FinalizePsbtRequest request) => _client
      .invoke<FinalizePsbtResponse>(ctx, 'WalletManagerService', 'FinalizePsbt', request, FinalizePsbtResponse());

  /// MultisigPsbtStatus reports signing progress for a multisig wallet's PSBT:
  /// signature count, whether it can be finalized, and which cosigners signed.
  $async.Future<MultisigPsbtStatusResponse> multisigPsbtStatus(
          $pb.ClientContext? ctx, MultisigPsbtStatusRequest request) =>
      _client.invoke<MultisigPsbtStatusResponse>(
          ctx, 'WalletManagerService', 'MultisigPsbtStatus', request, MultisigPsbtStatusResponse());

  /// BroadcastTransaction broadcasts a finalized raw transaction over the
  /// wallet's chain source and returns its txid.
  $async.Future<BroadcastTransactionResponse> broadcastTransaction(
          $pb.ClientContext? ctx, BroadcastTransactionRequest request) =>
      _client.invoke<BroadcastTransactionResponse>(
          ctx, 'WalletManagerService', 'BroadcastTransaction', request, BroadcastTransactionResponse());

  /// Address reads that belong to no wallet — cheque addresses, whose funds are
  /// not the user's to spend. Always electrum-backed, whatever wallet is active.
  $async.Future<GetAddressUnspentResponse> getAddressUnspent(
          $pb.ClientContext? ctx, GetAddressUnspentRequest request) =>
      _client.invoke<GetAddressUnspentResponse>(
          ctx, 'WalletManagerService', 'GetAddressUnspent', request, GetAddressUnspentResponse());
  $async.Future<BroadcastElectrumTransactionResponse> broadcastElectrumTransaction(
          $pb.ClientContext? ctx, BroadcastElectrumTransactionRequest request) =>
      _client.invoke<BroadcastElectrumTransactionResponse>(
          ctx, 'WalletManagerService', 'BroadcastElectrumTransaction', request, BroadcastElectrumTransactionResponse());

  /// USB hardware wallets.
  $async.Future<EnumerateHardwareDevicesResponse> enumerateHardwareDevices(
          $pb.ClientContext? ctx, EnumerateHardwareDevicesRequest request) =>
      _client.invoke<EnumerateHardwareDevicesResponse>(
          ctx, 'WalletManagerService', 'EnumerateHardwareDevices', request, EnumerateHardwareDevicesResponse());
  $async.Future<GetHardwareXpubResponse> getHardwareXpub($pb.ClientContext? ctx, GetHardwareXpubRequest request) =>
      _client.invoke<GetHardwareXpubResponse>(
          ctx, 'WalletManagerService', 'GetHardwareXpub', request, GetHardwareXpubResponse());
  $async.Future<SignPsbtWithDeviceResponse> signPsbtWithDevice(
          $pb.ClientContext? ctx, SignPsbtWithDeviceRequest request) =>
      _client.invoke<SignPsbtWithDeviceResponse>(
          ctx, 'WalletManagerService', 'SignPsbtWithDevice', request, SignPsbtWithDeviceResponse());

  /// PromptDevicePin shows the PIN matrix; SendDevicePin unlocks with it.
  $async.Future<PromptDevicePinResponse> promptDevicePin($pb.ClientContext? ctx, PromptDevicePinRequest request) =>
      _client.invoke<PromptDevicePinResponse>(
          ctx, 'WalletManagerService', 'PromptDevicePin', request, PromptDevicePinResponse());
  $async.Future<SendDevicePinResponse> sendDevicePin($pb.ClientContext? ctx, SendDevicePinRequest request) => _client
      .invoke<SendDevicePinResponse>(ctx, 'WalletManagerService', 'SendDevicePin', request, SendDevicePinResponse());

  /// CloseDevice releases the device so the next enumerate isn't blocked.
  $async.Future<CloseDeviceResponse> closeDevice($pb.ClientContext? ctx, CloseDeviceRequest request) =>
      _client.invoke<CloseDeviceResponse>(ctx, 'WalletManagerService', 'CloseDevice', request, CloseDeviceResponse());

  /// DeriveKeystore turns a keystore's intent into derived account key material.
  $async.Future<DeriveKeystoreResponse> deriveKeystore($pb.ClientContext? ctx, DeriveKeystoreRequest request) => _client
      .invoke<DeriveKeystoreResponse>(ctx, 'WalletManagerService', 'DeriveKeystore', request, DeriveKeystoreResponse());

  /// ExploreSeed derives the master keys and one page of child keys of a mnemonic.
  $async.Future<ExploreSeedResponse> exploreSeed($pb.ClientContext? ctx, ExploreSeedRequest request) =>
      _client.invoke<ExploreSeedResponse>(ctx, 'WalletManagerService', 'ExploreSeed', request, ExploreSeedResponse());

  /// GenerateMnemonic returns a new random 12-word BIP39 mnemonic.
  $async.Future<GenerateMnemonicResponse> generateMnemonic($pb.ClientContext? ctx, GenerateMnemonicRequest request) =>
      _client.invoke<GenerateMnemonicResponse>(
          ctx, 'WalletManagerService', 'GenerateMnemonic', request, GenerateMnemonicResponse());

  /// ValidateMnemonic says whether a phrase is a BIP39 mnemonic, an Electrum seed, or neither.
  $async.Future<ValidateMnemonicResponse> validateMnemonic($pb.ClientContext? ctx, ValidateMnemonicRequest request) =>
      _client.invoke<ValidateMnemonicResponse>(
          ctx, 'WalletManagerService', 'ValidateMnemonic', request, ValidateMnemonicResponse());

  /// PreviewWalletFromEntropy derives a wallet without saving it, so a caller can
  /// show the words while the user is still choosing their entropy.
  $async.Future<PreviewWalletFromEntropyResponse> previewWalletFromEntropy(
          $pb.ClientContext? ctx, PreviewWalletFromEntropyRequest request) =>
      _client.invoke<PreviewWalletFromEntropyResponse>(
          ctx, 'WalletManagerService', 'PreviewWalletFromEntropy', request, PreviewWalletFromEntropyResponse());

  /// Seed access for cheque engine
  $async.Future<GetWalletSeedResponse> getWalletSeed($pb.ClientContext? ctx, GetWalletSeedRequest request) => _client
      .invoke<GetWalletSeedResponse>(ctx, 'WalletManagerService', 'GetWalletSeed', request, GetWalletSeedResponse());

  /// Bitcoin Core variant selection (untouched / touched / knots).
  $async.Future<ListCoreVariantsResponse> listCoreVariants($pb.ClientContext? ctx, ListCoreVariantsRequest request) =>
      _client.invoke<ListCoreVariantsResponse>(
          ctx, 'WalletManagerService', 'ListCoreVariants', request, ListCoreVariantsResponse());
  $async.Future<GetCoreVariantResponse> getCoreVariant($pb.ClientContext? ctx, GetCoreVariantRequest request) => _client
      .invoke<GetCoreVariantResponse>(ctx, 'WalletManagerService', 'GetCoreVariant', request, GetCoreVariantResponse());
  $async.Future<SetCoreVariantResponse> setCoreVariant($pb.ClientContext? ctx, SetCoreVariantRequest request) => _client
      .invoke<SetCoreVariantResponse>(ctx, 'WalletManagerService', 'SetCoreVariant', request, SetCoreVariantResponse());

  /// Electrum server (Esplora endpoint) selection for electrum wallets.
  $async.Future<GetElectrumServerResponse> getElectrumServer(
          $pb.ClientContext? ctx, GetElectrumServerRequest request) =>
      _client.invoke<GetElectrumServerResponse>(
          ctx, 'WalletManagerService', 'GetElectrumServer', request, GetElectrumServerResponse());
  $async.Future<SetElectrumServerResponse> setElectrumServer(
          $pb.ClientContext? ctx, SetElectrumServerRequest request) =>
      _client.invoke<SetElectrumServerResponse>(
          ctx, 'WalletManagerService', 'SetElectrumServer', request, SetElectrumServerResponse());

  /// Tor SOCKS5 proxy routing for the electrum wallet's chain connections.
  $async.Future<GetTorConfigResponse> getTorConfig($pb.ClientContext? ctx, GetTorConfigRequest request) => _client
      .invoke<GetTorConfigResponse>(ctx, 'WalletManagerService', 'GetTorConfig', request, GetTorConfigResponse());
  $async.Future<SetTorConfigResponse> setTorConfig($pb.ClientContext? ctx, SetTorConfigRequest request) => _client
      .invoke<SetTorConfigResponse>(ctx, 'WalletManagerService', 'SetTorConfig', request, SetTorConfigResponse());

  /// Stream wallet state changes. Sends the full wallet state immediately,
  /// then again whenever wallets or balance change.
  $async.Future<WatchWalletDataResponse> watchWalletData($pb.ClientContext? ctx, $1.Empty request) =>
      _client.invoke<WatchWalletDataResponse>(
          ctx, 'WalletManagerService', 'WatchWalletData', request, WatchWalletDataResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
