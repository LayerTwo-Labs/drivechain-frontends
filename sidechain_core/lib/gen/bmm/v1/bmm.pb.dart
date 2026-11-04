// This is a generated file - do not edit.
//
// Generated from bmm/v1/bmm.proto.

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

import '../../orchestrator/v1/orchestrator.pbenum.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class StartRequest extends $pb.GeneratedMessage {
  factory StartRequest({
    $0.BinaryType? sidechain,
    $fixnum.Int64? maxBidSats,
    $core.String? walletId,
    $core.bool? capToBlockWorth,
  }) {
    final result = StartRequest._();
    if (sidechain != null) result.sidechain = sidechain;
    if (maxBidSats != null) result.maxBidSats = maxBidSats;
    if (walletId != null) result.walletId = walletId;
    if (capToBlockWorth != null) result.capToBlockWorth = capToBlockWorth;
    return result;
  }

  StartRequest._();

  factory StartRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StartRequest()..mergeFromBuffer(data, registry);
  factory StartRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StartRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StartRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'),
      createEmptyInstance: StartRequest.$_createMessage)
    ..aE<$0.BinaryType>(1, _omitFieldNames ? '' : 'sidechain', enumValues: $0.BinaryType.values)
    ..aInt64(3, _omitFieldNames ? '' : 'maxBidSats')
    ..aOS(4, _omitFieldNames ? '' : 'walletId')
    ..aOB(5, _omitFieldNames ? '' : 'capToBlockWorth')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartRequest copyWith(void Function(StartRequest) updates) =>
      super.copyWith((message) => updates(message as StartRequest)) as StartRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StartRequest() / StartRequest.new instead')
  static StartRequest create() => StartRequest._();
  static $pb.GeneratedMessage $_createMessage() => StartRequest._();
  @$core.override
  StartRequest createEmptyInstance() => StartRequest._();
  @$core.pragma('dart2js:noInline')
  static StartRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StartRequest>(StartRequest.$_createMessage);
  static StartRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.BinaryType get sidechain => $_getN(0);
  @$pb.TagNumber(1)
  set sidechain($0.BinaryType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSidechain() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechain() => $_clearField(1);

  /// Ceiling for raises. A bid never goes above this.
  @$pb.TagNumber(3)
  $fixnum.Int64 get maxBidSats => $_getI64(1);
  @$pb.TagNumber(3)
  set maxBidSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(3)
  $core.bool hasMaxBidSats() => $_has(1);
  @$pb.TagNumber(3)
  void clearMaxBidSats() => $_clearField(3);

  /// Wallet that funds every bid. Empty uses the active wallet.
  @$pb.TagNumber(4)
  $core.String get walletId => $_getSZ(2);
  @$pb.TagNumber(4)
  set walletId($core.String value) => $_setString(2, value);
  @$pb.TagNumber(4)
  $core.bool hasWalletId() => $_has(2);
  @$pb.TagNumber(4)
  void clearWalletId() => $_clearField(4);

  /// Hold every bid at or under what the block collects in fees. A chain whose
  /// blocks carry few fees then bids almost nothing, and every competitor wins,
  /// so this is off unless the operator asks for it.
  @$pb.TagNumber(5)
  $core.bool get capToBlockWorth => $_getBF(3);
  @$pb.TagNumber(5)
  set capToBlockWorth($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(5)
  $core.bool hasCapToBlockWorth() => $_has(3);
  @$pb.TagNumber(5)
  void clearCapToBlockWorth() => $_clearField(5);
}

class StartResponse extends $pb.GeneratedMessage {
  factory StartResponse() => StartResponse._();

  StartResponse._();

  factory StartResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StartResponse()..mergeFromBuffer(data, registry);
  factory StartResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StartResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StartResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'),
      createEmptyInstance: StartResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StartResponse copyWith(void Function(StartResponse) updates) =>
      super.copyWith((message) => updates(message as StartResponse)) as StartResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StartResponse() / StartResponse.new instead')
  static StartResponse create() => StartResponse._();
  static $pb.GeneratedMessage $_createMessage() => StartResponse._();
  @$core.override
  StartResponse createEmptyInstance() => StartResponse._();
  @$core.pragma('dart2js:noInline')
  static StartResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StartResponse>(StartResponse.$_createMessage);
  static StartResponse? _defaultInstance;
}

class StopRequest extends $pb.GeneratedMessage {
  factory StopRequest({
    $0.BinaryType? sidechain,
  }) {
    final result = StopRequest._();
    if (sidechain != null) result.sidechain = sidechain;
    return result;
  }

  StopRequest._();

  factory StopRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StopRequest()..mergeFromBuffer(data, registry);
  factory StopRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StopRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StopRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'),
      createEmptyInstance: StopRequest.$_createMessage)
    ..aE<$0.BinaryType>(1, _omitFieldNames ? '' : 'sidechain', enumValues: $0.BinaryType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopRequest copyWith(void Function(StopRequest) updates) =>
      super.copyWith((message) => updates(message as StopRequest)) as StopRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StopRequest() / StopRequest.new instead')
  static StopRequest create() => StopRequest._();
  static $pb.GeneratedMessage $_createMessage() => StopRequest._();
  @$core.override
  StopRequest createEmptyInstance() => StopRequest._();
  @$core.pragma('dart2js:noInline')
  static StopRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StopRequest>(StopRequest.$_createMessage);
  static StopRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.BinaryType get sidechain => $_getN(0);
  @$pb.TagNumber(1)
  set sidechain($0.BinaryType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSidechain() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechain() => $_clearField(1);
}

class StopResponse extends $pb.GeneratedMessage {
  factory StopResponse() => StopResponse._();

  StopResponse._();

  factory StopResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StopResponse()..mergeFromBuffer(data, registry);
  factory StopResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      StopResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StopResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'),
      createEmptyInstance: StopResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  StopResponse copyWith(void Function(StopResponse) updates) =>
      super.copyWith((message) => updates(message as StopResponse)) as StopResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use StopResponse() / StopResponse.new instead')
  static StopResponse create() => StopResponse._();
  static $pb.GeneratedMessage $_createMessage() => StopResponse._();
  @$core.override
  StopResponse createEmptyInstance() => StopResponse._();
  @$core.pragma('dart2js:noInline')
  static StopResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StopResponse>(StopResponse.$_createMessage);
  static StopResponse? _defaultInstance;
}

class ClearHistoryRequest extends $pb.GeneratedMessage {
  factory ClearHistoryRequest({
    $0.BinaryType? sidechain,
  }) {
    final result = ClearHistoryRequest._();
    if (sidechain != null) result.sidechain = sidechain;
    return result;
  }

  ClearHistoryRequest._();

  factory ClearHistoryRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClearHistoryRequest()..mergeFromBuffer(data, registry);
  factory ClearHistoryRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClearHistoryRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClearHistoryRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'),
      createEmptyInstance: ClearHistoryRequest.$_createMessage)
    ..aE<$0.BinaryType>(1, _omitFieldNames ? '' : 'sidechain', enumValues: $0.BinaryType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClearHistoryRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClearHistoryRequest copyWith(void Function(ClearHistoryRequest) updates) =>
      super.copyWith((message) => updates(message as ClearHistoryRequest)) as ClearHistoryRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ClearHistoryRequest() / ClearHistoryRequest.new instead')
  static ClearHistoryRequest create() => ClearHistoryRequest._();
  static $pb.GeneratedMessage $_createMessage() => ClearHistoryRequest._();
  @$core.override
  ClearHistoryRequest createEmptyInstance() => ClearHistoryRequest._();
  @$core.pragma('dart2js:noInline')
  static ClearHistoryRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClearHistoryRequest>(ClearHistoryRequest.$_createMessage);
  static ClearHistoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.BinaryType get sidechain => $_getN(0);
  @$pb.TagNumber(1)
  set sidechain($0.BinaryType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSidechain() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechain() => $_clearField(1);
}

class ClearHistoryResponse extends $pb.GeneratedMessage {
  factory ClearHistoryResponse() => ClearHistoryResponse._();

  ClearHistoryResponse._();

  factory ClearHistoryResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClearHistoryResponse()..mergeFromBuffer(data, registry);
  factory ClearHistoryResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ClearHistoryResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClearHistoryResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'),
      createEmptyInstance: ClearHistoryResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClearHistoryResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ClearHistoryResponse copyWith(void Function(ClearHistoryResponse) updates) =>
      super.copyWith((message) => updates(message as ClearHistoryResponse)) as ClearHistoryResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ClearHistoryResponse() / ClearHistoryResponse.new instead')
  static ClearHistoryResponse create() => ClearHistoryResponse._();
  static $pb.GeneratedMessage $_createMessage() => ClearHistoryResponse._();
  @$core.override
  ClearHistoryResponse createEmptyInstance() => ClearHistoryResponse._();
  @$core.pragma('dart2js:noInline')
  static ClearHistoryResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ClearHistoryResponse>(ClearHistoryResponse.$_createMessage);
  static ClearHistoryResponse? _defaultInstance;
}

class WatchRequest extends $pb.GeneratedMessage {
  factory WatchRequest({
    $0.BinaryType? sidechain,
  }) {
    final result = WatchRequest._();
    if (sidechain != null) result.sidechain = sidechain;
    return result;
  }

  WatchRequest._();

  factory WatchRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchRequest()..mergeFromBuffer(data, registry);
  factory WatchRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WatchRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'),
      createEmptyInstance: WatchRequest.$_createMessage)
    ..aE<$0.BinaryType>(1, _omitFieldNames ? '' : 'sidechain', enumValues: $0.BinaryType.values)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchRequest copyWith(void Function(WatchRequest) updates) =>
      super.copyWith((message) => updates(message as WatchRequest)) as WatchRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WatchRequest() / WatchRequest.new instead')
  static WatchRequest create() => WatchRequest._();
  static $pb.GeneratedMessage $_createMessage() => WatchRequest._();
  @$core.override
  WatchRequest createEmptyInstance() => WatchRequest._();
  @$core.pragma('dart2js:noInline')
  static WatchRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WatchRequest>(WatchRequest.$_createMessage);
  static WatchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.BinaryType get sidechain => $_getN(0);
  @$pb.TagNumber(1)
  set sidechain($0.BinaryType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSidechain() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechain() => $_clearField(1);
}

class WatchResponse extends $pb.GeneratedMessage {
  factory WatchResponse({
    $core.bool? running,
    $fixnum.Int64? maxBidSats,
    Round? current,
    $core.Iterable<Round>? history,
    $core.String? walletId,
    $core.double? nextBlockFeeRateSatVb,
  }) {
    final result = WatchResponse._();
    if (running != null) result.running = running;
    if (maxBidSats != null) result.maxBidSats = maxBidSats;
    if (current != null) result.current = current;
    if (history != null) result.history.addAll(history);
    if (walletId != null) result.walletId = walletId;
    if (nextBlockFeeRateSatVb != null) result.nextBlockFeeRateSatVb = nextBlockFeeRateSatVb;
    return result;
  }

  WatchResponse._();

  factory WatchResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchResponse()..mergeFromBuffer(data, registry);
  factory WatchResponse.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WatchResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'),
      createEmptyInstance: WatchResponse.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'running')
    ..aInt64(3, _omitFieldNames ? '' : 'maxBidSats')
    ..aOM<Round>(4, _omitFieldNames ? '' : 'current', subBuilder: Round.$_createMessage)
    ..pPM<Round>(5, _omitFieldNames ? '' : 'history', subBuilder: Round.$_createMessage)
    ..aOS(6, _omitFieldNames ? '' : 'walletId')
    ..aD(7, _omitFieldNames ? '' : 'nextBlockFeeRateSatVb')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchResponse copyWith(void Function(WatchResponse) updates) =>
      super.copyWith((message) => updates(message as WatchResponse)) as WatchResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WatchResponse() / WatchResponse.new instead')
  static WatchResponse create() => WatchResponse._();
  static $pb.GeneratedMessage $_createMessage() => WatchResponse._();
  @$core.override
  WatchResponse createEmptyInstance() => WatchResponse._();
  @$core.pragma('dart2js:noInline')
  static WatchResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WatchResponse>(WatchResponse.$_createMessage);
  static WatchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get running => $_getBF(0);
  @$pb.TagNumber(1)
  set running($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasRunning() => $_has(0);
  @$pb.TagNumber(1)
  void clearRunning() => $_clearField(1);

  @$pb.TagNumber(3)
  $fixnum.Int64 get maxBidSats => $_getI64(1);
  @$pb.TagNumber(3)
  set maxBidSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(3)
  $core.bool hasMaxBidSats() => $_has(1);
  @$pb.TagNumber(3)
  void clearMaxBidSats() => $_clearField(3);

  /// The round being bid on now, absent when no tip has been seen yet.
  @$pb.TagNumber(4)
  Round get current => $_getN(2);
  @$pb.TagNumber(4)
  set current(Round value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCurrent() => $_has(2);
  @$pb.TagNumber(4)
  void clearCurrent() => $_clearField(4);
  @$pb.TagNumber(4)
  Round ensureCurrent() => $_ensure(2);

  /// Finished rounds, newest first.
  @$pb.TagNumber(5)
  $pb.PbList<Round> get history => $_getList(3);

  /// Wallet that funds the bids. Empty means the active wallet.
  @$pb.TagNumber(6)
  $core.String get walletId => $_getSZ(4);
  @$pb.TagNumber(6)
  set walletId($core.String value) => $_setString(4, value);
  @$pb.TagNumber(6)
  $core.bool hasWalletId() => $_has(4);
  @$pb.TagNumber(6)
  void clearWalletId() => $_clearField(6);

  /// Rate a bid pays to enter the next mainchain block, in sats per vByte, from
  /// Core's own estimate. The engine opens every bid here and never lower. The
  /// amount depends on the size the wallet builds, so this reports the rate.
  @$pb.TagNumber(7)
  $core.double get nextBlockFeeRateSatVb => $_getN(5);
  @$pb.TagNumber(7)
  set nextBlockFeeRateSatVb($core.double value) => $_setDouble(5, value);
  @$pb.TagNumber(7)
  $core.bool hasNextBlockFeeRateSatVb() => $_has(5);
  @$pb.TagNumber(7)
  void clearNextBlockFeeRateSatVb() => $_clearField(7);
}

/// Round is one mainchain tip and the contest for the sidechain block after it.
class Round extends $pb.GeneratedMessage {
  factory Round({
    $core.String? prevMainHash,
    $core.int? prevMainHeight,
    $core.String? result,
    $fixnum.Int64? blockWorthSats,
    $core.Iterable<Bid>? ourBids,
    $core.Iterable<Bid>? otherBids,
    $core.String? winnerCriticalHash,
    $core.String? winnerTxid,
    $fixnum.Int64? winnerBidSats,
    $core.String? includedInBlock,
    $fixnum.Int64? profitSats,
    $core.bool? hasProfit,
    $fixnum.Int64? startedAtUnix,
    $core.int? includedInHeight,
  }) {
    final result$ = Round._();
    if (prevMainHash != null) result$.prevMainHash = prevMainHash;
    if (prevMainHeight != null) result$.prevMainHeight = prevMainHeight;
    if (result != null) result$.result = result;
    if (blockWorthSats != null) result$.blockWorthSats = blockWorthSats;
    if (ourBids != null) result$.ourBids.addAll(ourBids);
    if (otherBids != null) result$.otherBids.addAll(otherBids);
    if (winnerCriticalHash != null) result$.winnerCriticalHash = winnerCriticalHash;
    if (winnerTxid != null) result$.winnerTxid = winnerTxid;
    if (winnerBidSats != null) result$.winnerBidSats = winnerBidSats;
    if (includedInBlock != null) result$.includedInBlock = includedInBlock;
    if (profitSats != null) result$.profitSats = profitSats;
    if (hasProfit != null) result$.hasProfit = hasProfit;
    if (startedAtUnix != null) result$.startedAtUnix = startedAtUnix;
    if (includedInHeight != null) result$.includedInHeight = includedInHeight;
    return result$;
  }

  Round._();

  factory Round.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Round()..mergeFromBuffer(data, registry);
  factory Round.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Round()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Round',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'), createEmptyInstance: Round.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'prevMainHash')
    ..aI(2, _omitFieldNames ? '' : 'prevMainHeight')
    ..aOS(3, _omitFieldNames ? '' : 'result')
    ..aInt64(4, _omitFieldNames ? '' : 'blockWorthSats')
    ..pPM<Bid>(5, _omitFieldNames ? '' : 'ourBids', subBuilder: Bid.$_createMessage)
    ..pPM<Bid>(6, _omitFieldNames ? '' : 'otherBids', subBuilder: Bid.$_createMessage)
    ..aOS(7, _omitFieldNames ? '' : 'winnerCriticalHash')
    ..aOS(8, _omitFieldNames ? '' : 'winnerTxid')
    ..aInt64(9, _omitFieldNames ? '' : 'winnerBidSats')
    ..aOS(10, _omitFieldNames ? '' : 'includedInBlock')
    ..aInt64(11, _omitFieldNames ? '' : 'profitSats')
    ..aOB(12, _omitFieldNames ? '' : 'hasProfit')
    ..aInt64(13, _omitFieldNames ? '' : 'startedAtUnix')
    ..aI(14, _omitFieldNames ? '' : 'includedInHeight')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Round clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Round copyWith(void Function(Round) updates) => super.copyWith((message) => updates(message as Round)) as Round;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Round() / Round.new instead')
  static Round create() => Round._();
  static $pb.GeneratedMessage $_createMessage() => Round._();
  @$core.override
  Round createEmptyInstance() => Round._();
  @$core.pragma('dart2js:noInline')
  static Round getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Round>(Round.$_createMessage);
  static Round? _defaultInstance;

  /// Mainchain block the bids build on. Identifies the round.
  @$pb.TagNumber(1)
  $core.String get prevMainHash => $_getSZ(0);
  @$pb.TagNumber(1)
  set prevMainHash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasPrevMainHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrevMainHash() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get prevMainHeight => $_getIZ(1);
  @$pb.TagNumber(2)
  set prevMainHeight($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPrevMainHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrevMainHeight() => $_clearField(2);

  /// One of: open, won, lost, skipped.
  @$pb.TagNumber(3)
  $core.String get result => $_getSZ(2);
  @$pb.TagNumber(3)
  set result($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasResult() => $_has(2);
  @$pb.TagNumber(3)
  void clearResult() => $_clearField(3);

  /// Fees the block we assembled would collect. A bid above this loses money.
  @$pb.TagNumber(4)
  $fixnum.Int64 get blockWorthSats => $_getI64(3);
  @$pb.TagNumber(4)
  set blockWorthSats($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBlockWorthSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearBlockWorthSats() => $_clearField(4);

  /// Our live bid for the round; earlier raised bids carry replaced_by_txid.
  @$pb.TagNumber(5)
  $pb.PbList<Bid> get ourBids => $_getList(4);

  /// Bids seen in the mempool for this round, ours excluded, highest first.
  @$pb.TagNumber(6)
  $pb.PbList<Bid> get otherBids => $_getList(5);

  /// Sidechain block hash that won the round, when known.
  @$pb.TagNumber(7)
  $core.String get winnerCriticalHash => $_getSZ(6);
  @$pb.TagNumber(7)
  set winnerCriticalHash($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasWinnerCriticalHash() => $_has(6);
  @$pb.TagNumber(7)
  void clearWinnerCriticalHash() => $_clearField(7);

  /// Winning bid, when we saw it. Empty when the winner was never in our view.
  @$pb.TagNumber(8)
  $core.String get winnerTxid => $_getSZ(7);
  @$pb.TagNumber(8)
  set winnerTxid($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasWinnerTxid() => $_has(7);
  @$pb.TagNumber(8)
  void clearWinnerTxid() => $_clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get winnerBidSats => $_getI64(8);
  @$pb.TagNumber(9)
  set winnerBidSats($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(9)
  $core.bool hasWinnerBidSats() => $_has(8);
  @$pb.TagNumber(9)
  void clearWinnerBidSats() => $_clearField(9);

  /// Mainchain block that carried the winning M8.
  @$pb.TagNumber(10)
  $core.String get includedInBlock => $_getSZ(9);
  @$pb.TagNumber(10)
  set includedInBlock($core.String value) => $_setString(9, value);
  @$pb.TagNumber(10)
  $core.bool hasIncludedInBlock() => $_has(9);
  @$pb.TagNumber(10)
  void clearIncludedInBlock() => $_clearField(10);

  /// Fees less our bid, set only when we won.
  @$pb.TagNumber(11)
  $fixnum.Int64 get profitSats => $_getI64(10);
  @$pb.TagNumber(11)
  set profitSats($fixnum.Int64 value) => $_setInt64(10, value);
  @$pb.TagNumber(11)
  $core.bool hasProfitSats() => $_has(10);
  @$pb.TagNumber(11)
  void clearProfitSats() => $_clearField(11);

  @$pb.TagNumber(12)
  $core.bool get hasProfit => $_getBF(11);
  @$pb.TagNumber(12)
  set hasProfit($core.bool value) => $_setBool(11, value);
  @$pb.TagNumber(12)
  $core.bool hasHasProfit() => $_has(11);
  @$pb.TagNumber(12)
  void clearHasProfit() => $_clearField(12);

  @$pb.TagNumber(13)
  $fixnum.Int64 get startedAtUnix => $_getI64(12);
  @$pb.TagNumber(13)
  set startedAtUnix($fixnum.Int64 value) => $_setInt64(12, value);
  @$pb.TagNumber(13)
  $core.bool hasStartedAtUnix() => $_has(12);
  @$pb.TagNumber(13)
  void clearStartedAtUnix() => $_clearField(13);

  @$pb.TagNumber(14)
  $core.int get includedInHeight => $_getIZ(13);
  @$pb.TagNumber(14)
  set includedInHeight($core.int value) => $_setSignedInt32(13, value);
  @$pb.TagNumber(14)
  $core.bool hasIncludedInHeight() => $_has(13);
  @$pb.TagNumber(14)
  void clearIncludedInHeight() => $_clearField(14);
}

/// Bid is one M8 broadcast for a round.
class Bid extends $pb.GeneratedMessage {
  factory Bid({
    $core.String? txid,
    $core.String? criticalHash,
    $fixnum.Int64? bidSats,
    $core.bool? isOurs,
    $core.String? replacedByTxid,
    $core.String? state,
    $core.String? error,
    $core.String? prevMainHash,
  }) {
    final result = Bid._();
    if (txid != null) result.txid = txid;
    if (criticalHash != null) result.criticalHash = criticalHash;
    if (bidSats != null) result.bidSats = bidSats;
    if (isOurs != null) result.isOurs = isOurs;
    if (replacedByTxid != null) result.replacedByTxid = replacedByTxid;
    if (state != null) result.state = state;
    if (error != null) result.error = error;
    if (prevMainHash != null) result.prevMainHash = prevMainHash;
    return result;
  }

  Bid._();

  factory Bid.fromBuffer($core.List<$core.int> data, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Bid()..mergeFromBuffer(data, registry);
  factory Bid.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Bid()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Bid',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'), createEmptyInstance: Bid.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aOS(2, _omitFieldNames ? '' : 'criticalHash')
    ..aInt64(3, _omitFieldNames ? '' : 'bidSats')
    ..aOB(4, _omitFieldNames ? '' : 'isOurs')
    ..aOS(5, _omitFieldNames ? '' : 'replacedByTxid')
    ..aOS(6, _omitFieldNames ? '' : 'state')
    ..aOS(7, _omitFieldNames ? '' : 'error')
    ..aOS(8, _omitFieldNames ? '' : 'prevMainHash')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Bid clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Bid copyWith(void Function(Bid) updates) => super.copyWith((message) => updates(message as Bid)) as Bid;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Bid() / Bid.new instead')
  static Bid create() => Bid._();
  static $pb.GeneratedMessage $_createMessage() => Bid._();
  @$core.override
  Bid createEmptyInstance() => Bid._();
  @$core.pragma('dart2js:noInline')
  static Bid getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Bid>(Bid.$_createMessage);
  static Bid? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  /// Sidechain block hash the bid commits to.
  @$pb.TagNumber(2)
  $core.String get criticalHash => $_getSZ(1);
  @$pb.TagNumber(2)
  set criticalHash($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCriticalHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearCriticalHash() => $_clearField(2);

  /// Fee the bid pays, which is what a miner collects for including it.
  @$pb.TagNumber(3)
  $fixnum.Int64 get bidSats => $_getI64(2);
  @$pb.TagNumber(3)
  set bidSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBidSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearBidSats() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isOurs => $_getBF(3);
  @$pb.TagNumber(4)
  set isOurs($core.bool value) => $_setBool(3, value);
  @$pb.TagNumber(4)
  $core.bool hasIsOurs() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsOurs() => $_clearField(4);

  /// Set when this bid was replaced by a raise. The replacement evicts it from
  /// the mempool, so it is only visible here.
  @$pb.TagNumber(5)
  $core.String get replacedByTxid => $_getSZ(4);
  @$pb.TagNumber(5)
  set replacedByTxid($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasReplacedByTxid() => $_has(4);
  @$pb.TagNumber(5)
  void clearReplacedByTxid() => $_clearField(5);

  /// One of: live, replaced, connected, missed, failed. Only set for our bids.
  @$pb.TagNumber(6)
  $core.String get state => $_getSZ(5);
  @$pb.TagNumber(6)
  set state($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasState() => $_has(5);
  @$pb.TagNumber(6)
  void clearState() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get error => $_getSZ(6);
  @$pb.TagNumber(7)
  set error($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasError() => $_has(6);
  @$pb.TagNumber(7)
  void clearError() => $_clearField(7);

  /// Mainchain tip the bid builds on. A bid for any other tip is already dead.
  @$pb.TagNumber(8)
  $core.String get prevMainHash => $_getSZ(7);
  @$pb.TagNumber(8)
  set prevMainHash($core.String value) => $_setString(7, value);
  @$pb.TagNumber(8)
  $core.bool hasPrevMainHash() => $_has(7);
  @$pb.TagNumber(8)
  void clearPrevMainHash() => $_clearField(8);
}

class GetRoundBidsRequest extends $pb.GeneratedMessage {
  factory GetRoundBidsRequest({
    $0.BinaryType? sidechain,
    $core.String? prevMainHash,
  }) {
    final result = GetRoundBidsRequest._();
    if (sidechain != null) result.sidechain = sidechain;
    if (prevMainHash != null) result.prevMainHash = prevMainHash;
    return result;
  }

  GetRoundBidsRequest._();

  factory GetRoundBidsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetRoundBidsRequest()..mergeFromBuffer(data, registry);
  factory GetRoundBidsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetRoundBidsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetRoundBidsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'),
      createEmptyInstance: GetRoundBidsRequest.$_createMessage)
    ..aE<$0.BinaryType>(1, _omitFieldNames ? '' : 'sidechain', enumValues: $0.BinaryType.values)
    ..aOS(2, _omitFieldNames ? '' : 'prevMainHash')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRoundBidsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRoundBidsRequest copyWith(void Function(GetRoundBidsRequest) updates) =>
      super.copyWith((message) => updates(message as GetRoundBidsRequest)) as GetRoundBidsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetRoundBidsRequest() / GetRoundBidsRequest.new instead')
  static GetRoundBidsRequest create() => GetRoundBidsRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetRoundBidsRequest._();
  @$core.override
  GetRoundBidsRequest createEmptyInstance() => GetRoundBidsRequest._();
  @$core.pragma('dart2js:noInline')
  static GetRoundBidsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetRoundBidsRequest>(GetRoundBidsRequest.$_createMessage);
  static GetRoundBidsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.BinaryType get sidechain => $_getN(0);
  @$pb.TagNumber(1)
  set sidechain($0.BinaryType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSidechain() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechain() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get prevMainHash => $_getSZ(1);
  @$pb.TagNumber(2)
  set prevMainHash($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPrevMainHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrevMainHash() => $_clearField(2);
}

class GetRoundBidsResponse extends $pb.GeneratedMessage {
  factory GetRoundBidsResponse({
    Round? round,
  }) {
    final result = GetRoundBidsResponse._();
    if (round != null) result.round = round;
    return result;
  }

  GetRoundBidsResponse._();

  factory GetRoundBidsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetRoundBidsResponse()..mergeFromBuffer(data, registry);
  factory GetRoundBidsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetRoundBidsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetRoundBidsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'),
      createEmptyInstance: GetRoundBidsResponse.$_createMessage)
    ..aOM<Round>(1, _omitFieldNames ? '' : 'round', subBuilder: Round.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRoundBidsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetRoundBidsResponse copyWith(void Function(GetRoundBidsResponse) updates) =>
      super.copyWith((message) => updates(message as GetRoundBidsResponse)) as GetRoundBidsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetRoundBidsResponse() / GetRoundBidsResponse.new instead')
  static GetRoundBidsResponse create() => GetRoundBidsResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetRoundBidsResponse._();
  @$core.override
  GetRoundBidsResponse createEmptyInstance() => GetRoundBidsResponse._();
  @$core.pragma('dart2js:noInline')
  static GetRoundBidsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetRoundBidsResponse>(GetRoundBidsResponse.$_createMessage);
  static GetRoundBidsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Round get round => $_getN(0);
  @$pb.TagNumber(1)
  set round(Round value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasRound() => $_has(0);
  @$pb.TagNumber(1)
  void clearRound() => $_clearField(1);
  @$pb.TagNumber(1)
  Round ensureRound() => $_ensure(0);
}

class CreateBidRequest extends $pb.GeneratedMessage {
  factory CreateBidRequest({
    $0.BinaryType? sidechain,
    $core.String? walletId,
    $fixnum.Int64? bidSats,
    $core.String? replaceTxid,
    $core.String? expectPrevMainHash,
    $core.bool? capToBlockWorth,
    $core.double? feeRateSatVb,
    $fixnum.Int64? maxBidSats,
  }) {
    final result = CreateBidRequest._();
    if (sidechain != null) result.sidechain = sidechain;
    if (walletId != null) result.walletId = walletId;
    if (bidSats != null) result.bidSats = bidSats;
    if (replaceTxid != null) result.replaceTxid = replaceTxid;
    if (expectPrevMainHash != null) result.expectPrevMainHash = expectPrevMainHash;
    if (capToBlockWorth != null) result.capToBlockWorth = capToBlockWorth;
    if (feeRateSatVb != null) result.feeRateSatVb = feeRateSatVb;
    if (maxBidSats != null) result.maxBidSats = maxBidSats;
    return result;
  }

  CreateBidRequest._();

  factory CreateBidRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateBidRequest()..mergeFromBuffer(data, registry);
  factory CreateBidRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateBidRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateBidRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'),
      createEmptyInstance: CreateBidRequest.$_createMessage)
    ..aE<$0.BinaryType>(1, _omitFieldNames ? '' : 'sidechain', enumValues: $0.BinaryType.values)
    ..aOS(2, _omitFieldNames ? '' : 'walletId')
    ..aInt64(3, _omitFieldNames ? '' : 'bidSats')
    ..aOS(4, _omitFieldNames ? '' : 'replaceTxid')
    ..aOS(5, _omitFieldNames ? '' : 'expectPrevMainHash')
    ..aOB(6, _omitFieldNames ? '' : 'capToBlockWorth')
    ..aD(7, _omitFieldNames ? '' : 'feeRateSatVb')
    ..aInt64(8, _omitFieldNames ? '' : 'maxBidSats')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateBidRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateBidRequest copyWith(void Function(CreateBidRequest) updates) =>
      super.copyWith((message) => updates(message as CreateBidRequest)) as CreateBidRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateBidRequest() / CreateBidRequest.new instead')
  static CreateBidRequest create() => CreateBidRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateBidRequest._();
  @$core.override
  CreateBidRequest createEmptyInstance() => CreateBidRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateBidRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateBidRequest>(CreateBidRequest.$_createMessage);
  static CreateBidRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.BinaryType get sidechain => $_getN(0);
  @$pb.TagNumber(1)
  set sidechain($0.BinaryType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSidechain() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechain() => $_clearField(1);

  /// Wallet that funds the bid. Empty uses the active wallet.
  @$pb.TagNumber(2)
  $core.String get walletId => $_getSZ(1);
  @$pb.TagNumber(2)
  set walletId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasWalletId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWalletId() => $_clearField(2);

  /// Bid, paid as the M8's fee so that a miner collects it.
  @$pb.TagNumber(3)
  $fixnum.Int64 get bidSats => $_getI64(2);
  @$pb.TagNumber(3)
  set bidSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBidSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearBidSats() => $_clearField(3);

  /// Raise an earlier bid by spending its inputs again, which replaces it
  /// rather than bidding against it. Only works within the same slot.
  @$pb.TagNumber(4)
  $core.String get replaceTxid => $_getSZ(3);
  @$pb.TagNumber(4)
  set replaceTxid($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasReplaceTxid() => $_has(3);
  @$pb.TagNumber(4)
  void clearReplaceTxid() => $_clearField(4);

  /// Refuse the bid unless the sidechain builds on this mainchain tip. Stops a
  /// sidechain that has not caught up from spending on an already-dead round.
  @$pb.TagNumber(5)
  $core.String get expectPrevMainHash => $_getSZ(4);
  @$pb.TagNumber(5)
  set expectPrevMainHash($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasExpectPrevMainHash() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpectPrevMainHash() => $_clearField(5);

  /// Lower the bid to what the block collects in fees. Above that it loses money.
  @$pb.TagNumber(6)
  $core.bool get capToBlockWorth => $_getBF(5);
  @$pb.TagNumber(6)
  set capToBlockWorth($core.bool value) => $_setBool(5, value);
  @$pb.TagNumber(6)
  $core.bool hasCapToBlockWorth() => $_has(5);
  @$pb.TagNumber(6)
  void clearCapToBlockWorth() => $_clearField(6);

  /// Size the bid at this rate rather than at a fixed amount, so a wallet that
  /// needs more inputs still pays the rate. The answer reports what it cost.
  /// Ignored when bid_sats is set.
  @$pb.TagNumber(7)
  $core.double get feeRateSatVb => $_getN(6);
  @$pb.TagNumber(7)
  set feeRateSatVb($core.double value) => $_setDouble(6, value);
  @$pb.TagNumber(7)
  $core.bool hasFeeRateSatVb() => $_has(6);
  @$pb.TagNumber(7)
  void clearFeeRateSatVb() => $_clearField(7);

  /// Highest the bid may go, in sats. Zero sets no ceiling.
  @$pb.TagNumber(8)
  $fixnum.Int64 get maxBidSats => $_getI64(7);
  @$pb.TagNumber(8)
  set maxBidSats($fixnum.Int64 value) => $_setInt64(7, value);
  @$pb.TagNumber(8)
  $core.bool hasMaxBidSats() => $_has(7);
  @$pb.TagNumber(8)
  void clearMaxBidSats() => $_clearField(8);
}

class CancelBidRequest extends $pb.GeneratedMessage {
  factory CancelBidRequest({
    $core.String? walletId,
    $core.String? txid,
  }) {
    final result = CancelBidRequest._();
    if (walletId != null) result.walletId = walletId;
    if (txid != null) result.txid = txid;
    return result;
  }

  CancelBidRequest._();

  factory CancelBidRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CancelBidRequest()..mergeFromBuffer(data, registry);
  factory CancelBidRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CancelBidRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CancelBidRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'),
      createEmptyInstance: CancelBidRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aOS(2, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelBidRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelBidRequest copyWith(void Function(CancelBidRequest) updates) =>
      super.copyWith((message) => updates(message as CancelBidRequest)) as CancelBidRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CancelBidRequest() / CancelBidRequest.new instead')
  static CancelBidRequest create() => CancelBidRequest._();
  static $pb.GeneratedMessage $_createMessage() => CancelBidRequest._();
  @$core.override
  CancelBidRequest createEmptyInstance() => CancelBidRequest._();
  @$core.pragma('dart2js:noInline')
  static CancelBidRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CancelBidRequest>(CancelBidRequest.$_createMessage);
  static CancelBidRequest? _defaultInstance;

  /// Wallet that funds the replacement. Empty uses the active wallet.
  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  /// The stranded M8 transaction.
  @$pb.TagNumber(2)
  $core.String get txid => $_getSZ(1);
  @$pb.TagNumber(2)
  set txid($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearTxid() => $_clearField(2);
}

class CancelBidResponse extends $pb.GeneratedMessage {
  factory CancelBidResponse({
    $core.String? replacementTxid,
    $fixnum.Int64? recoveredSats,
    $fixnum.Int64? feeSats,
    $core.Iterable<$core.String>? cancelledTxids,
  }) {
    final result = CancelBidResponse._();
    if (replacementTxid != null) result.replacementTxid = replacementTxid;
    if (recoveredSats != null) result.recoveredSats = recoveredSats;
    if (feeSats != null) result.feeSats = feeSats;
    if (cancelledTxids != null) result.cancelledTxids.addAll(cancelledTxids);
    return result;
  }

  CancelBidResponse._();

  factory CancelBidResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CancelBidResponse()..mergeFromBuffer(data, registry);
  factory CancelBidResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CancelBidResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CancelBidResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'),
      createEmptyInstance: CancelBidResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'replacementTxid')
    ..aInt64(2, _omitFieldNames ? '' : 'recoveredSats')
    ..aInt64(3, _omitFieldNames ? '' : 'feeSats')
    ..pPS(4, _omitFieldNames ? '' : 'cancelledTxids')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelBidResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CancelBidResponse copyWith(void Function(CancelBidResponse) updates) =>
      super.copyWith((message) => updates(message as CancelBidResponse)) as CancelBidResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CancelBidResponse() / CancelBidResponse.new instead')
  static CancelBidResponse create() => CancelBidResponse._();
  static $pb.GeneratedMessage $_createMessage() => CancelBidResponse._();
  @$core.override
  CancelBidResponse createEmptyInstance() => CancelBidResponse._();
  @$core.pragma('dart2js:noInline')
  static CancelBidResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CancelBidResponse>(CancelBidResponse.$_createMessage);
  static CancelBidResponse? _defaultInstance;

  /// The replacement transaction.
  @$pb.TagNumber(1)
  $core.String get replacementTxid => $_getSZ(0);
  @$pb.TagNumber(1)
  set replacementTxid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasReplacementTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearReplacementTxid() => $_clearField(1);

  /// What the fresh address receives.
  @$pb.TagNumber(2)
  $fixnum.Int64 get recoveredSats => $_getI64(1);
  @$pb.TagNumber(2)
  set recoveredSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRecoveredSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearRecoveredSats() => $_clearField(2);

  /// What the replacement pays the miner to evict the chain.
  @$pb.TagNumber(3)
  $fixnum.Int64 get feeSats => $_getI64(2);
  @$pb.TagNumber(3)
  set feeSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFeeSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearFeeSats() => $_clearField(3);

  /// Every bid the replacement evicts, the named one included.
  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get cancelledTxids => $_getList(3);
}

class CreateBidResponse extends $pb.GeneratedMessage {
  factory CreateBidResponse({
    $core.String? criticalHash,
    $core.String? bmmTxid,
    $fixnum.Int64? feesSats,
    $core.String? blockJson,
    $core.String? prevMainHash,
    $fixnum.Int64? bidSats,
  }) {
    final result = CreateBidResponse._();
    if (criticalHash != null) result.criticalHash = criticalHash;
    if (bmmTxid != null) result.bmmTxid = bmmTxid;
    if (feesSats != null) result.feesSats = feesSats;
    if (blockJson != null) result.blockJson = blockJson;
    if (prevMainHash != null) result.prevMainHash = prevMainHash;
    if (bidSats != null) result.bidSats = bidSats;
    return result;
  }

  CreateBidResponse._();

  factory CreateBidResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateBidResponse()..mergeFromBuffer(data, registry);
  factory CreateBidResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateBidResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateBidResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'),
      createEmptyInstance: CreateBidResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'criticalHash')
    ..aOS(2, _omitFieldNames ? '' : 'bmmTxid')
    ..aInt64(3, _omitFieldNames ? '' : 'feesSats')
    ..aOS(4, _omitFieldNames ? '' : 'blockJson')
    ..aOS(5, _omitFieldNames ? '' : 'prevMainHash')
    ..aInt64(6, _omitFieldNames ? '' : 'bidSats')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateBidResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateBidResponse copyWith(void Function(CreateBidResponse) updates) =>
      super.copyWith((message) => updates(message as CreateBidResponse)) as CreateBidResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateBidResponse() / CreateBidResponse.new instead')
  static CreateBidResponse create() => CreateBidResponse._();
  static $pb.GeneratedMessage $_createMessage() => CreateBidResponse._();
  @$core.override
  CreateBidResponse createEmptyInstance() => CreateBidResponse._();
  @$core.pragma('dart2js:noInline')
  static CreateBidResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateBidResponse>(CreateBidResponse.$_createMessage);
  static CreateBidResponse? _defaultInstance;

  /// Sidechain block hash committed to by the bid.
  @$pb.TagNumber(1)
  $core.String get criticalHash => $_getSZ(0);
  @$pb.TagNumber(1)
  set criticalHash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCriticalHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearCriticalHash() => $_clearField(1);

  /// The M8 transaction that was broadcast.
  @$pb.TagNumber(2)
  $core.String get bmmTxid => $_getSZ(1);
  @$pb.TagNumber(2)
  set bmmTxid($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBmmTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearBmmTxid() => $_clearField(2);

  /// Fees the block collects if it connects. A bid above this loses money.
  @$pb.TagNumber(3)
  $fixnum.Int64 get feesSats => $_getI64(2);
  @$pb.TagNumber(3)
  set feesSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFeesSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearFeesSats() => $_clearField(3);

  /// Opaque block, to hand back to ConnectBid.
  @$pb.TagNumber(4)
  $core.String get blockJson => $_getSZ(3);
  @$pb.TagNumber(4)
  set blockJson($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBlockJson() => $_has(3);
  @$pb.TagNumber(4)
  void clearBlockJson() => $_clearField(4);

  /// Mainchain tip the bid builds on.
  @$pb.TagNumber(5)
  $core.String get prevMainHash => $_getSZ(4);
  @$pb.TagNumber(5)
  set prevMainHash($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPrevMainHash() => $_has(4);
  @$pb.TagNumber(5)
  void clearPrevMainHash() => $_clearField(5);

  /// Bid actually broadcast, which cap_to_block_worth may have lowered.
  @$pb.TagNumber(6)
  $fixnum.Int64 get bidSats => $_getI64(5);
  @$pb.TagNumber(6)
  set bidSats($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasBidSats() => $_has(5);
  @$pb.TagNumber(6)
  void clearBidSats() => $_clearField(6);
}

class ConnectBidRequest extends $pb.GeneratedMessage {
  factory ConnectBidRequest({
    $0.BinaryType? sidechain,
    $core.String? criticalHash,
    $core.String? blockJson,
    $core.String? mainBlockHash,
  }) {
    final result = ConnectBidRequest._();
    if (sidechain != null) result.sidechain = sidechain;
    if (criticalHash != null) result.criticalHash = criticalHash;
    if (blockJson != null) result.blockJson = blockJson;
    if (mainBlockHash != null) result.mainBlockHash = mainBlockHash;
    return result;
  }

  ConnectBidRequest._();

  factory ConnectBidRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConnectBidRequest()..mergeFromBuffer(data, registry);
  factory ConnectBidRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConnectBidRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConnectBidRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'),
      createEmptyInstance: ConnectBidRequest.$_createMessage)
    ..aE<$0.BinaryType>(1, _omitFieldNames ? '' : 'sidechain', enumValues: $0.BinaryType.values)
    ..aOS(2, _omitFieldNames ? '' : 'criticalHash')
    ..aOS(3, _omitFieldNames ? '' : 'blockJson')
    ..aOS(4, _omitFieldNames ? '' : 'mainBlockHash')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectBidRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectBidRequest copyWith(void Function(ConnectBidRequest) updates) =>
      super.copyWith((message) => updates(message as ConnectBidRequest)) as ConnectBidRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ConnectBidRequest() / ConnectBidRequest.new instead')
  static ConnectBidRequest create() => ConnectBidRequest._();
  static $pb.GeneratedMessage $_createMessage() => ConnectBidRequest._();
  @$core.override
  ConnectBidRequest createEmptyInstance() => ConnectBidRequest._();
  @$core.pragma('dart2js:noInline')
  static ConnectBidRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConnectBidRequest>(ConnectBidRequest.$_createMessage);
  static ConnectBidRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.BinaryType get sidechain => $_getN(0);
  @$pb.TagNumber(1)
  set sidechain($0.BinaryType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSidechain() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechain() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get criticalHash => $_getSZ(1);
  @$pb.TagNumber(2)
  set criticalHash($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasCriticalHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearCriticalHash() => $_clearField(2);

  /// block_json as returned by CreateBid.
  @$pb.TagNumber(3)
  $core.String get blockJson => $_getSZ(2);
  @$pb.TagNumber(3)
  set blockJson($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasBlockJson() => $_has(2);
  @$pb.TagNumber(3)
  void clearBlockJson() => $_clearField(3);

  /// Mainchain block that carries the commitment. Empty asks the sidechain
  /// which block included the bid, which only answers for a block it already
  /// holds.
  @$pb.TagNumber(4)
  $core.String get mainBlockHash => $_getSZ(3);
  @$pb.TagNumber(4)
  set mainBlockHash($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMainBlockHash() => $_has(3);
  @$pb.TagNumber(4)
  void clearMainBlockHash() => $_clearField(4);
}

class ConnectBidResponse extends $pb.GeneratedMessage {
  factory ConnectBidResponse({
    $core.bool? connected,
    $core.String? mainBlockHash,
    $core.bool? held,
  }) {
    final result = ConnectBidResponse._();
    if (connected != null) result.connected = connected;
    if (mainBlockHash != null) result.mainBlockHash = mainBlockHash;
    if (held != null) result.held = held;
    return result;
  }

  ConnectBidResponse._();

  factory ConnectBidResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConnectBidResponse()..mergeFromBuffer(data, registry);
  factory ConnectBidResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ConnectBidResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConnectBidResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'),
      createEmptyInstance: ConnectBidResponse.$_createMessage)
    ..aOB(1, _omitFieldNames ? '' : 'connected')
    ..aOS(2, _omitFieldNames ? '' : 'mainBlockHash')
    ..aOB(3, _omitFieldNames ? '' : 'held')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectBidResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ConnectBidResponse copyWith(void Function(ConnectBidResponse) updates) =>
      super.copyWith((message) => updates(message as ConnectBidResponse)) as ConnectBidResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ConnectBidResponse() / ConnectBidResponse.new instead')
  static ConnectBidResponse create() => ConnectBidResponse._();
  static $pb.GeneratedMessage $_createMessage() => ConnectBidResponse._();
  @$core.override
  ConnectBidResponse createEmptyInstance() => ConnectBidResponse._();
  @$core.pragma('dart2js:noInline')
  static ConnectBidResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConnectBidResponse>(ConnectBidResponse.$_createMessage);
  static ConnectBidResponse? _defaultInstance;

  /// False while no mainchain block includes the bid yet.
  @$pb.TagNumber(1)
  $core.bool get connected => $_getBF(0);
  @$pb.TagNumber(1)
  set connected($core.bool value) => $_setBool(0, value);
  @$pb.TagNumber(1)
  $core.bool hasConnected() => $_has(0);
  @$pb.TagNumber(1)
  void clearConnected() => $_clearField(1);

  /// Mainchain block that included the bid, when connected.
  @$pb.TagNumber(2)
  $core.String get mainBlockHash => $_getSZ(1);
  @$pb.TagNumber(2)
  set mainBlockHash($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMainBlockHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearMainBlockHash() => $_clearField(2);

  /// The sidechain's chain already holds the block, from a peer or an earlier call.
  @$pb.TagNumber(3)
  $core.bool get held => $_getBF(2);
  @$pb.TagNumber(3)
  set held($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHeld() => $_has(2);
  @$pb.TagNumber(3)
  void clearHeld() => $_clearField(3);
}

class ListBidsRequest extends $pb.GeneratedMessage {
  factory ListBidsRequest({
    $0.BinaryType? sidechain,
    $core.String? prevMainHash,
  }) {
    final result = ListBidsRequest._();
    if (sidechain != null) result.sidechain = sidechain;
    if (prevMainHash != null) result.prevMainHash = prevMainHash;
    return result;
  }

  ListBidsRequest._();

  factory ListBidsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListBidsRequest()..mergeFromBuffer(data, registry);
  factory ListBidsRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListBidsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListBidsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'),
      createEmptyInstance: ListBidsRequest.$_createMessage)
    ..aE<$0.BinaryType>(1, _omitFieldNames ? '' : 'sidechain', enumValues: $0.BinaryType.values)
    ..aOS(2, _omitFieldNames ? '' : 'prevMainHash')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBidsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBidsRequest copyWith(void Function(ListBidsRequest) updates) =>
      super.copyWith((message) => updates(message as ListBidsRequest)) as ListBidsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListBidsRequest() / ListBidsRequest.new instead')
  static ListBidsRequest create() => ListBidsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListBidsRequest._();
  @$core.override
  ListBidsRequest createEmptyInstance() => ListBidsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListBidsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListBidsRequest>(ListBidsRequest.$_createMessage);
  static ListBidsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $0.BinaryType get sidechain => $_getN(0);
  @$pb.TagNumber(1)
  set sidechain($0.BinaryType value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSidechain() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechain() => $_clearField(1);

  /// Mainchain block the bids are built on. An empty hash reads the chain tip.
  @$pb.TagNumber(2)
  $core.String get prevMainHash => $_getSZ(1);
  @$pb.TagNumber(2)
  set prevMainHash($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPrevMainHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrevMainHash() => $_clearField(2);
}

class ListBidsResponse extends $pb.GeneratedMessage {
  factory ListBidsResponse({
    $core.Iterable<Bid>? bids,
  }) {
    final result = ListBidsResponse._();
    if (bids != null) result.bids.addAll(bids);
    return result;
  }

  ListBidsResponse._();

  factory ListBidsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListBidsResponse()..mergeFromBuffer(data, registry);
  factory ListBidsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListBidsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListBidsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'),
      createEmptyInstance: ListBidsResponse.$_createMessage)
    ..pPM<Bid>(1, _omitFieldNames ? '' : 'bids', subBuilder: Bid.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBidsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListBidsResponse copyWith(void Function(ListBidsResponse) updates) =>
      super.copyWith((message) => updates(message as ListBidsResponse)) as ListBidsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListBidsResponse() / ListBidsResponse.new instead')
  static ListBidsResponse create() => ListBidsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListBidsResponse._();
  @$core.override
  ListBidsResponse createEmptyInstance() => ListBidsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListBidsResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListBidsResponse>(ListBidsResponse.$_createMessage);
  static ListBidsResponse? _defaultInstance;

  /// Highest bid first.
  @$pb.TagNumber(1)
  $pb.PbList<Bid> get bids => $_getList(0);
}

class PrepareBMMRequest extends $pb.GeneratedMessage {
  factory PrepareBMMRequest({
    $core.Iterable<PrepareBMMTarget>? targets,
  }) {
    final result = PrepareBMMRequest._();
    if (targets != null) result.targets.addAll(targets);
    return result;
  }

  PrepareBMMRequest._();

  factory PrepareBMMRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PrepareBMMRequest()..mergeFromBuffer(data, registry);
  factory PrepareBMMRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PrepareBMMRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PrepareBMMRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'),
      createEmptyInstance: PrepareBMMRequest.$_createMessage)
    ..pPM<PrepareBMMTarget>(1, _omitFieldNames ? '' : 'targets', subBuilder: PrepareBMMTarget.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrepareBMMRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrepareBMMRequest copyWith(void Function(PrepareBMMRequest) updates) =>
      super.copyWith((message) => updates(message as PrepareBMMRequest)) as PrepareBMMRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PrepareBMMRequest() / PrepareBMMRequest.new instead')
  static PrepareBMMRequest create() => PrepareBMMRequest._();
  static $pb.GeneratedMessage $_createMessage() => PrepareBMMRequest._();
  @$core.override
  PrepareBMMRequest createEmptyInstance() => PrepareBMMRequest._();
  @$core.pragma('dart2js:noInline')
  static PrepareBMMRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PrepareBMMRequest>(PrepareBMMRequest.$_createMessage);
  static PrepareBMMRequest? _defaultInstance;

  /// The sidechains that bid now. Each one needs a coin of its own.
  @$pb.TagNumber(1)
  $pb.PbList<PrepareBMMTarget> get targets => $_getList(0);
}

/// PrepareBMMTarget is one sidechain that bids.
class PrepareBMMTarget extends $pb.GeneratedMessage {
  factory PrepareBMMTarget({
    $core.String? walletId,
    $fixnum.Int64? maxBidSats,
  }) {
    final result = PrepareBMMTarget._();
    if (walletId != null) result.walletId = walletId;
    if (maxBidSats != null) result.maxBidSats = maxBidSats;
    return result;
  }

  PrepareBMMTarget._();

  factory PrepareBMMTarget.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PrepareBMMTarget()..mergeFromBuffer(data, registry);
  factory PrepareBMMTarget.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PrepareBMMTarget()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PrepareBMMTarget',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'),
      createEmptyInstance: PrepareBMMTarget.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aInt64(2, _omitFieldNames ? '' : 'maxBidSats')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrepareBMMTarget clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrepareBMMTarget copyWith(void Function(PrepareBMMTarget) updates) =>
      super.copyWith((message) => updates(message as PrepareBMMTarget)) as PrepareBMMTarget;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PrepareBMMTarget() / PrepareBMMTarget.new instead')
  static PrepareBMMTarget create() => PrepareBMMTarget._();
  static $pb.GeneratedMessage $_createMessage() => PrepareBMMTarget._();
  @$core.override
  PrepareBMMTarget createEmptyInstance() => PrepareBMMTarget._();
  @$core.pragma('dart2js:noInline')
  static PrepareBMMTarget getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PrepareBMMTarget>(PrepareBMMTarget.$_createMessage);
  static PrepareBMMTarget? _defaultInstance;

  /// Wallet that funds its bids. Empty uses the active wallet.
  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  /// Ceiling one of its bids may pay, in sats. It sizes the coin.
  @$pb.TagNumber(2)
  $fixnum.Int64 get maxBidSats => $_getI64(1);
  @$pb.TagNumber(2)
  set maxBidSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMaxBidSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearMaxBidSats() => $_clearField(2);
}

class PrepareBMMResponse extends $pb.GeneratedMessage {
  factory PrepareBMMResponse({
    $core.Iterable<PrepareBMMWallet>? wallets,
  }) {
    final result = PrepareBMMResponse._();
    if (wallets != null) result.wallets.addAll(wallets);
    return result;
  }

  PrepareBMMResponse._();

  factory PrepareBMMResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PrepareBMMResponse()..mergeFromBuffer(data, registry);
  factory PrepareBMMResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PrepareBMMResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PrepareBMMResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'),
      createEmptyInstance: PrepareBMMResponse.$_createMessage)
    ..pPM<PrepareBMMWallet>(1, _omitFieldNames ? '' : 'wallets', subBuilder: PrepareBMMWallet.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrepareBMMResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrepareBMMResponse copyWith(void Function(PrepareBMMResponse) updates) =>
      super.copyWith((message) => updates(message as PrepareBMMResponse)) as PrepareBMMResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PrepareBMMResponse() / PrepareBMMResponse.new instead')
  static PrepareBMMResponse create() => PrepareBMMResponse._();
  static $pb.GeneratedMessage $_createMessage() => PrepareBMMResponse._();
  @$core.override
  PrepareBMMResponse createEmptyInstance() => PrepareBMMResponse._();
  @$core.pragma('dart2js:noInline')
  static PrepareBMMResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PrepareBMMResponse>(PrepareBMMResponse.$_createMessage);
  static PrepareBMMResponse? _defaultInstance;

  /// One entry per wallet the targets name, with aliases of one wallet joined.
  @$pb.TagNumber(1)
  $pb.PbList<PrepareBMMWallet> get wallets => $_getList(0);
}

class PrepareBMMWallet extends $pb.GeneratedMessage {
  factory PrepareBMMWallet({
    $core.String? walletId,
    $core.int? usableCoins,
    $core.int? wantedCoins,
    $core.String? splitTxid,
  }) {
    final result = PrepareBMMWallet._();
    if (walletId != null) result.walletId = walletId;
    if (usableCoins != null) result.usableCoins = usableCoins;
    if (wantedCoins != null) result.wantedCoins = wantedCoins;
    if (splitTxid != null) result.splitTxid = splitTxid;
    return result;
  }

  PrepareBMMWallet._();

  factory PrepareBMMWallet.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PrepareBMMWallet()..mergeFromBuffer(data, registry);
  factory PrepareBMMWallet.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      PrepareBMMWallet()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'PrepareBMMWallet',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'),
      createEmptyInstance: PrepareBMMWallet.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'walletId')
    ..aI(2, _omitFieldNames ? '' : 'usableCoins')
    ..aI(3, _omitFieldNames ? '' : 'wantedCoins')
    ..aOS(4, _omitFieldNames ? '' : 'splitTxid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrepareBMMWallet clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  PrepareBMMWallet copyWith(void Function(PrepareBMMWallet) updates) =>
      super.copyWith((message) => updates(message as PrepareBMMWallet)) as PrepareBMMWallet;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use PrepareBMMWallet() / PrepareBMMWallet.new instead')
  static PrepareBMMWallet create() => PrepareBMMWallet._();
  static $pb.GeneratedMessage $_createMessage() => PrepareBMMWallet._();
  @$core.override
  PrepareBMMWallet createEmptyInstance() => PrepareBMMWallet._();
  @$core.pragma('dart2js:noInline')
  static PrepareBMMWallet getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PrepareBMMWallet>(PrepareBMMWallet.$_createMessage);
  static PrepareBMMWallet? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletId => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasWalletId() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletId() => $_clearField(1);

  /// Coins the wallet holds that a sidechain can bid many rounds from.
  @$pb.TagNumber(2)
  $core.int get usableCoins => $_getIZ(1);
  @$pb.TagNumber(2)
  set usableCoins($core.int value) => $_setSignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasUsableCoins() => $_has(1);
  @$pb.TagNumber(2)
  void clearUsableCoins() => $_clearField(2);

  /// Coins the sidechains that spend this wallet need, one each.
  @$pb.TagNumber(3)
  $core.int get wantedCoins => $_getIZ(2);
  @$pb.TagNumber(3)
  set wantedCoins($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasWantedCoins() => $_has(2);
  @$pb.TagNumber(3)
  void clearWantedCoins() => $_clearField(3);

  /// Transaction that pays the missing coins. Empty when none was necessary.
  @$pb.TagNumber(4)
  $core.String get splitTxid => $_getSZ(3);
  @$pb.TagNumber(4)
  set splitTxid($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasSplitTxid() => $_has(3);
  @$pb.TagNumber(4)
  void clearSplitTxid() => $_clearField(4);
}

/// BMMService drives blind merged mining for a sidechain, paid for by any
/// wallet rather than the enforcer's. A bid is an M8 whose fee buys inclusion;
/// the block it commits to connects once a miner takes that M8.
///
/// A bid names the mainchain tip it was built on, so it is only valid in the
/// very next block. A round is one such tip: every bid competing for it, and
/// what became of them.
class BMMServiceApi {
  final $pb.RpcClient _client;

  BMMServiceApi(this._client);

  /// Start bids on every new mainchain tip and connects the blocks miners take,
  /// until Stop. Bids are funded by the wallet the request names, and are
  /// opened at Core's next block fee and raised toward max_bid_sats when a
  /// competitor outbids us.
  $async.Future<StartResponse> start($pb.ClientContext? ctx, StartRequest request) =>
      _client.invoke<StartResponse>(ctx, 'BMMService', 'Start', request, StartResponse());
  $async.Future<StopResponse> stop($pb.ClientContext? ctx, StopRequest request) =>
      _client.invoke<StopResponse>(ctx, 'BMMService', 'Stop', request, StopResponse());
  $async.Future<ClearHistoryResponse> clearHistory($pb.ClientContext? ctx, ClearHistoryRequest request) =>
      _client.invoke<ClearHistoryResponse>(ctx, 'BMMService', 'ClearHistory', request, ClearHistoryResponse());

  /// Watch streams the round being bid on now plus recent finished rounds. The
  /// full state goes out on every frame, so a reconnect needs no delta merge.
  $async.Future<WatchResponse> watch($pb.ClientContext? ctx, WatchRequest request) =>
      _client.invoke<WatchResponse>(ctx, 'BMMService', 'Watch', request, WatchResponse());

  /// GetRoundBids returns every bid seen for one round. A losing bid never
  /// confirms and leaves the mempool, so this is limited to what was observed
  /// while that round was open.
  $async.Future<GetRoundBidsResponse> getRoundBids($pb.ClientContext? ctx, GetRoundBidsRequest request) =>
      _client.invoke<GetRoundBidsResponse>(ctx, 'BMMService', 'GetRoundBids', request, GetRoundBidsResponse());

  /// CreateBid assembles a sidechain block and broadcasts one M8 bid for it;
  /// ConnectBid connects that block once a miner includes the bid. Use these to
  /// drive a single attempt by hand; Start does both on a loop.
  $async.Future<CreateBidResponse> createBid($pb.ClientContext? ctx, CreateBidRequest request) =>
      _client.invoke<CreateBidResponse>(ctx, 'BMMService', 'CreateBid', request, CreateBidResponse());
  $async.Future<ConnectBidResponse> connectBid($pb.ClientContext? ctx, ConnectBidRequest request) =>
      _client.invoke<ConnectBidResponse>(ctx, 'BMMService', 'ConnectBid', request, ConnectBidResponse());

  /// CancelBid replaces a stranded bid with a payment back to its own wallet,
  /// so the coins under it come back. A bid that can still win is refused.
  $async.Future<CancelBidResponse> cancelBid($pb.ClientContext? ctx, CancelBidRequest request) =>
      _client.invoke<CancelBidResponse>(ctx, 'BMMService', 'CancelBid', request, CancelBidResponse());

  /// ListBids reads the competing bids for the slot out of the mainchain
  /// mempool, highest bid first.
  $async.Future<ListBidsResponse> listBids($pb.ClientContext? ctx, ListBidsRequest request) =>
      _client.invoke<ListBidsResponse>(ctx, 'BMMService', 'ListBids', request, ListBidsResponse());

  /// PrepareBMM gives every bidding sidechain a coin of its own to bid from,
  /// and splits one large coin when the wallet holds too few. One wallet funds
  /// them all, and a bid over another slot's bid change dies when that slot
  /// replaces its own bid.
  $async.Future<PrepareBMMResponse> prepareBMM($pb.ClientContext? ctx, PrepareBMMRequest request) =>
      _client.invoke<PrepareBMMResponse>(ctx, 'BMMService', 'PrepareBMM', request, PrepareBMMResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
