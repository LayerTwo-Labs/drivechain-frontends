//
//  Generated code. Do not modify.
//  source: bmm/v1/bmm.proto
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

import '../../orchestrator/v1/orchestrator.pbenum.dart' as $2;

class StartRequest extends $pb.GeneratedMessage {
  factory StartRequest({
    $2.BinaryType? sidechain,
    $fixnum.Int64? minBidSats,
    $fixnum.Int64? maxBidSats,
    $core.String? walletId,
  }) {
    final $result = create();
    if (sidechain != null) {
      $result.sidechain = sidechain;
    }
    if (minBidSats != null) {
      $result.minBidSats = minBidSats;
    }
    if (maxBidSats != null) {
      $result.maxBidSats = maxBidSats;
    }
    if (walletId != null) {
      $result.walletId = walletId;
    }
    return $result;
  }
  StartRequest._() : super();
  factory StartRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StartRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StartRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'), createEmptyInstance: create)
    ..e<$2.BinaryType>(1, _omitFieldNames ? '' : 'sidechain', $pb.PbFieldType.OE, defaultOrMaker: $2.BinaryType.BINARY_TYPE_UNSPECIFIED, valueOf: $2.BinaryType.valueOf, enumValues: $2.BinaryType.values)
    ..aInt64(2, _omitFieldNames ? '' : 'minBidSats')
    ..aInt64(3, _omitFieldNames ? '' : 'maxBidSats')
    ..aOS(4, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StartRequest clone() => StartRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StartRequest copyWith(void Function(StartRequest) updates) => super.copyWith((message) => updates(message as StartRequest)) as StartRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StartRequest create() => StartRequest._();
  StartRequest createEmptyInstance() => create();
  static $pb.PbList<StartRequest> createRepeated() => $pb.PbList<StartRequest>();
  @$core.pragma('dart2js:noInline')
  static StartRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StartRequest>(create);
  static StartRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $2.BinaryType get sidechain => $_getN(0);
  @$pb.TagNumber(1)
  set sidechain($2.BinaryType v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechain() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechain() => clearField(1);

  /// Opening bid for each round, paid as the M8's fee.
  @$pb.TagNumber(2)
  $fixnum.Int64 get minBidSats => $_getI64(1);
  @$pb.TagNumber(2)
  set minBidSats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMinBidSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearMinBidSats() => clearField(2);

  /// Ceiling for raises. A bid is never raised above this, nor above what the
  /// block is worth, since either loses money.
  @$pb.TagNumber(3)
  $fixnum.Int64 get maxBidSats => $_getI64(2);
  @$pb.TagNumber(3)
  set maxBidSats($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasMaxBidSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearMaxBidSats() => clearField(3);

  /// Wallet that funds every bid. Empty uses the active wallet.
  @$pb.TagNumber(4)
  $core.String get walletId => $_getSZ(3);
  @$pb.TagNumber(4)
  set walletId($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasWalletId() => $_has(3);
  @$pb.TagNumber(4)
  void clearWalletId() => clearField(4);
}

class StartResponse extends $pb.GeneratedMessage {
  factory StartResponse() => create();
  StartResponse._() : super();
  factory StartResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StartResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StartResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StartResponse clone() => StartResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StartResponse copyWith(void Function(StartResponse) updates) => super.copyWith((message) => updates(message as StartResponse)) as StartResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StartResponse create() => StartResponse._();
  StartResponse createEmptyInstance() => create();
  static $pb.PbList<StartResponse> createRepeated() => $pb.PbList<StartResponse>();
  @$core.pragma('dart2js:noInline')
  static StartResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StartResponse>(create);
  static StartResponse? _defaultInstance;
}

class StopRequest extends $pb.GeneratedMessage {
  factory StopRequest({
    $2.BinaryType? sidechain,
  }) {
    final $result = create();
    if (sidechain != null) {
      $result.sidechain = sidechain;
    }
    return $result;
  }
  StopRequest._() : super();
  factory StopRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StopRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StopRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'), createEmptyInstance: create)
    ..e<$2.BinaryType>(1, _omitFieldNames ? '' : 'sidechain', $pb.PbFieldType.OE, defaultOrMaker: $2.BinaryType.BINARY_TYPE_UNSPECIFIED, valueOf: $2.BinaryType.valueOf, enumValues: $2.BinaryType.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StopRequest clone() => StopRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StopRequest copyWith(void Function(StopRequest) updates) => super.copyWith((message) => updates(message as StopRequest)) as StopRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StopRequest create() => StopRequest._();
  StopRequest createEmptyInstance() => create();
  static $pb.PbList<StopRequest> createRepeated() => $pb.PbList<StopRequest>();
  @$core.pragma('dart2js:noInline')
  static StopRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StopRequest>(create);
  static StopRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $2.BinaryType get sidechain => $_getN(0);
  @$pb.TagNumber(1)
  set sidechain($2.BinaryType v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechain() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechain() => clearField(1);
}

class StopResponse extends $pb.GeneratedMessage {
  factory StopResponse() => create();
  StopResponse._() : super();
  factory StopResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory StopResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'StopResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  StopResponse clone() => StopResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  StopResponse copyWith(void Function(StopResponse) updates) => super.copyWith((message) => updates(message as StopResponse)) as StopResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static StopResponse create() => StopResponse._();
  StopResponse createEmptyInstance() => create();
  static $pb.PbList<StopResponse> createRepeated() => $pb.PbList<StopResponse>();
  @$core.pragma('dart2js:noInline')
  static StopResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<StopResponse>(create);
  static StopResponse? _defaultInstance;
}

class ClearHistoryRequest extends $pb.GeneratedMessage {
  factory ClearHistoryRequest({
    $2.BinaryType? sidechain,
  }) {
    final $result = create();
    if (sidechain != null) {
      $result.sidechain = sidechain;
    }
    return $result;
  }
  ClearHistoryRequest._() : super();
  factory ClearHistoryRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClearHistoryRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClearHistoryRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'), createEmptyInstance: create)
    ..e<$2.BinaryType>(1, _omitFieldNames ? '' : 'sidechain', $pb.PbFieldType.OE, defaultOrMaker: $2.BinaryType.BINARY_TYPE_UNSPECIFIED, valueOf: $2.BinaryType.valueOf, enumValues: $2.BinaryType.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClearHistoryRequest clone() => ClearHistoryRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClearHistoryRequest copyWith(void Function(ClearHistoryRequest) updates) => super.copyWith((message) => updates(message as ClearHistoryRequest)) as ClearHistoryRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClearHistoryRequest create() => ClearHistoryRequest._();
  ClearHistoryRequest createEmptyInstance() => create();
  static $pb.PbList<ClearHistoryRequest> createRepeated() => $pb.PbList<ClearHistoryRequest>();
  @$core.pragma('dart2js:noInline')
  static ClearHistoryRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClearHistoryRequest>(create);
  static ClearHistoryRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $2.BinaryType get sidechain => $_getN(0);
  @$pb.TagNumber(1)
  set sidechain($2.BinaryType v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechain() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechain() => clearField(1);
}

class ClearHistoryResponse extends $pb.GeneratedMessage {
  factory ClearHistoryResponse() => create();
  ClearHistoryResponse._() : super();
  factory ClearHistoryResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ClearHistoryResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ClearHistoryResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ClearHistoryResponse clone() => ClearHistoryResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ClearHistoryResponse copyWith(void Function(ClearHistoryResponse) updates) => super.copyWith((message) => updates(message as ClearHistoryResponse)) as ClearHistoryResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ClearHistoryResponse create() => ClearHistoryResponse._();
  ClearHistoryResponse createEmptyInstance() => create();
  static $pb.PbList<ClearHistoryResponse> createRepeated() => $pb.PbList<ClearHistoryResponse>();
  @$core.pragma('dart2js:noInline')
  static ClearHistoryResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ClearHistoryResponse>(create);
  static ClearHistoryResponse? _defaultInstance;
}

class WatchRequest extends $pb.GeneratedMessage {
  factory WatchRequest({
    $2.BinaryType? sidechain,
  }) {
    final $result = create();
    if (sidechain != null) {
      $result.sidechain = sidechain;
    }
    return $result;
  }
  WatchRequest._() : super();
  factory WatchRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WatchRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WatchRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'), createEmptyInstance: create)
    ..e<$2.BinaryType>(1, _omitFieldNames ? '' : 'sidechain', $pb.PbFieldType.OE, defaultOrMaker: $2.BinaryType.BINARY_TYPE_UNSPECIFIED, valueOf: $2.BinaryType.valueOf, enumValues: $2.BinaryType.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WatchRequest clone() => WatchRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WatchRequest copyWith(void Function(WatchRequest) updates) => super.copyWith((message) => updates(message as WatchRequest)) as WatchRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WatchRequest create() => WatchRequest._();
  WatchRequest createEmptyInstance() => create();
  static $pb.PbList<WatchRequest> createRepeated() => $pb.PbList<WatchRequest>();
  @$core.pragma('dart2js:noInline')
  static WatchRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WatchRequest>(create);
  static WatchRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $2.BinaryType get sidechain => $_getN(0);
  @$pb.TagNumber(1)
  set sidechain($2.BinaryType v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechain() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechain() => clearField(1);
}

class WatchResponse extends $pb.GeneratedMessage {
  factory WatchResponse({
    $core.bool? running,
    $fixnum.Int64? minBidSats,
    $fixnum.Int64? maxBidSats,
    Round? current,
    $core.Iterable<Round>? history,
    $core.String? walletId,
  }) {
    final $result = create();
    if (running != null) {
      $result.running = running;
    }
    if (minBidSats != null) {
      $result.minBidSats = minBidSats;
    }
    if (maxBidSats != null) {
      $result.maxBidSats = maxBidSats;
    }
    if (current != null) {
      $result.current = current;
    }
    if (history != null) {
      $result.history.addAll(history);
    }
    if (walletId != null) {
      $result.walletId = walletId;
    }
    return $result;
  }
  WatchResponse._() : super();
  factory WatchResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory WatchResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WatchResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'running')
    ..aInt64(2, _omitFieldNames ? '' : 'minBidSats')
    ..aInt64(3, _omitFieldNames ? '' : 'maxBidSats')
    ..aOM<Round>(4, _omitFieldNames ? '' : 'current', subBuilder: Round.create)
    ..pc<Round>(5, _omitFieldNames ? '' : 'history', $pb.PbFieldType.PM, subBuilder: Round.create)
    ..aOS(6, _omitFieldNames ? '' : 'walletId')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  WatchResponse clone() => WatchResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  WatchResponse copyWith(void Function(WatchResponse) updates) => super.copyWith((message) => updates(message as WatchResponse)) as WatchResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static WatchResponse create() => WatchResponse._();
  WatchResponse createEmptyInstance() => create();
  static $pb.PbList<WatchResponse> createRepeated() => $pb.PbList<WatchResponse>();
  @$core.pragma('dart2js:noInline')
  static WatchResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WatchResponse>(create);
  static WatchResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get running => $_getBF(0);
  @$pb.TagNumber(1)
  set running($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRunning() => $_has(0);
  @$pb.TagNumber(1)
  void clearRunning() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get minBidSats => $_getI64(1);
  @$pb.TagNumber(2)
  set minBidSats($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMinBidSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearMinBidSats() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get maxBidSats => $_getI64(2);
  @$pb.TagNumber(3)
  set maxBidSats($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasMaxBidSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearMaxBidSats() => clearField(3);

  /// The round being bid on now, absent when no tip has been seen yet.
  @$pb.TagNumber(4)
  Round get current => $_getN(3);
  @$pb.TagNumber(4)
  set current(Round v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasCurrent() => $_has(3);
  @$pb.TagNumber(4)
  void clearCurrent() => clearField(4);
  @$pb.TagNumber(4)
  Round ensureCurrent() => $_ensure(3);

  /// Finished rounds, newest first.
  @$pb.TagNumber(5)
  $core.List<Round> get history => $_getList(4);

  /// Wallet that funds the bids. Empty means the active wallet.
  @$pb.TagNumber(6)
  $core.String get walletId => $_getSZ(5);
  @$pb.TagNumber(6)
  set walletId($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasWalletId() => $_has(5);
  @$pb.TagNumber(6)
  void clearWalletId() => clearField(6);
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
    final $result = create();
    if (prevMainHash != null) {
      $result.prevMainHash = prevMainHash;
    }
    if (prevMainHeight != null) {
      $result.prevMainHeight = prevMainHeight;
    }
    if (result != null) {
      $result.result = result;
    }
    if (blockWorthSats != null) {
      $result.blockWorthSats = blockWorthSats;
    }
    if (ourBids != null) {
      $result.ourBids.addAll(ourBids);
    }
    if (otherBids != null) {
      $result.otherBids.addAll(otherBids);
    }
    if (winnerCriticalHash != null) {
      $result.winnerCriticalHash = winnerCriticalHash;
    }
    if (winnerTxid != null) {
      $result.winnerTxid = winnerTxid;
    }
    if (winnerBidSats != null) {
      $result.winnerBidSats = winnerBidSats;
    }
    if (includedInBlock != null) {
      $result.includedInBlock = includedInBlock;
    }
    if (profitSats != null) {
      $result.profitSats = profitSats;
    }
    if (hasProfit != null) {
      $result.hasProfit = hasProfit;
    }
    if (startedAtUnix != null) {
      $result.startedAtUnix = startedAtUnix;
    }
    if (includedInHeight != null) {
      $result.includedInHeight = includedInHeight;
    }
    return $result;
  }
  Round._() : super();
  factory Round.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Round.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Round', package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'prevMainHash')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'prevMainHeight', $pb.PbFieldType.O3)
    ..aOS(3, _omitFieldNames ? '' : 'result')
    ..aInt64(4, _omitFieldNames ? '' : 'blockWorthSats')
    ..pc<Bid>(5, _omitFieldNames ? '' : 'ourBids', $pb.PbFieldType.PM, subBuilder: Bid.create)
    ..pc<Bid>(6, _omitFieldNames ? '' : 'otherBids', $pb.PbFieldType.PM, subBuilder: Bid.create)
    ..aOS(7, _omitFieldNames ? '' : 'winnerCriticalHash')
    ..aOS(8, _omitFieldNames ? '' : 'winnerTxid')
    ..aInt64(9, _omitFieldNames ? '' : 'winnerBidSats')
    ..aOS(10, _omitFieldNames ? '' : 'includedInBlock')
    ..aInt64(11, _omitFieldNames ? '' : 'profitSats')
    ..aOB(12, _omitFieldNames ? '' : 'hasProfit')
    ..aInt64(13, _omitFieldNames ? '' : 'startedAtUnix')
    ..a<$core.int>(14, _omitFieldNames ? '' : 'includedInHeight', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Round clone() => Round()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Round copyWith(void Function(Round) updates) => super.copyWith((message) => updates(message as Round)) as Round;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Round create() => Round._();
  Round createEmptyInstance() => create();
  static $pb.PbList<Round> createRepeated() => $pb.PbList<Round>();
  @$core.pragma('dart2js:noInline')
  static Round getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Round>(create);
  static Round? _defaultInstance;

  /// Mainchain block the bids build on. Identifies the round.
  @$pb.TagNumber(1)
  $core.String get prevMainHash => $_getSZ(0);
  @$pb.TagNumber(1)
  set prevMainHash($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPrevMainHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrevMainHash() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get prevMainHeight => $_getIZ(1);
  @$pb.TagNumber(2)
  set prevMainHeight($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPrevMainHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrevMainHeight() => clearField(2);

  /// One of: open, won, lost, skipped.
  @$pb.TagNumber(3)
  $core.String get result => $_getSZ(2);
  @$pb.TagNumber(3)
  set result($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasResult() => $_has(2);
  @$pb.TagNumber(3)
  void clearResult() => clearField(3);

  /// Fees the block we assembled would collect. A bid above this loses money.
  @$pb.TagNumber(4)
  $fixnum.Int64 get blockWorthSats => $_getI64(3);
  @$pb.TagNumber(4)
  set blockWorthSats($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasBlockWorthSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearBlockWorthSats() => clearField(4);

  /// Our live bid for the round; earlier raised bids carry replaced_by_txid.
  @$pb.TagNumber(5)
  $core.List<Bid> get ourBids => $_getList(4);

  /// Bids seen in the mempool for this round, ours excluded, highest first.
  @$pb.TagNumber(6)
  $core.List<Bid> get otherBids => $_getList(5);

  /// Sidechain block hash that won the round, when known.
  @$pb.TagNumber(7)
  $core.String get winnerCriticalHash => $_getSZ(6);
  @$pb.TagNumber(7)
  set winnerCriticalHash($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasWinnerCriticalHash() => $_has(6);
  @$pb.TagNumber(7)
  void clearWinnerCriticalHash() => clearField(7);

  /// Winning bid, when we saw it. Empty when the winner was never in our view.
  @$pb.TagNumber(8)
  $core.String get winnerTxid => $_getSZ(7);
  @$pb.TagNumber(8)
  set winnerTxid($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasWinnerTxid() => $_has(7);
  @$pb.TagNumber(8)
  void clearWinnerTxid() => clearField(8);

  @$pb.TagNumber(9)
  $fixnum.Int64 get winnerBidSats => $_getI64(8);
  @$pb.TagNumber(9)
  set winnerBidSats($fixnum.Int64 v) { $_setInt64(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasWinnerBidSats() => $_has(8);
  @$pb.TagNumber(9)
  void clearWinnerBidSats() => clearField(9);

  /// Mainchain block that carried the winning M8.
  @$pb.TagNumber(10)
  $core.String get includedInBlock => $_getSZ(9);
  @$pb.TagNumber(10)
  set includedInBlock($core.String v) { $_setString(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasIncludedInBlock() => $_has(9);
  @$pb.TagNumber(10)
  void clearIncludedInBlock() => clearField(10);

  /// Fees less our bid, set only when we won.
  @$pb.TagNumber(11)
  $fixnum.Int64 get profitSats => $_getI64(10);
  @$pb.TagNumber(11)
  set profitSats($fixnum.Int64 v) { $_setInt64(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasProfitSats() => $_has(10);
  @$pb.TagNumber(11)
  void clearProfitSats() => clearField(11);

  @$pb.TagNumber(12)
  $core.bool get hasProfit => $_getBF(11);
  @$pb.TagNumber(12)
  set hasProfit($core.bool v) { $_setBool(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasHasProfit() => $_has(11);
  @$pb.TagNumber(12)
  void clearHasProfit() => clearField(12);

  @$pb.TagNumber(13)
  $fixnum.Int64 get startedAtUnix => $_getI64(12);
  @$pb.TagNumber(13)
  set startedAtUnix($fixnum.Int64 v) { $_setInt64(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasStartedAtUnix() => $_has(12);
  @$pb.TagNumber(13)
  void clearStartedAtUnix() => clearField(13);

  @$pb.TagNumber(14)
  $core.int get includedInHeight => $_getIZ(13);
  @$pb.TagNumber(14)
  set includedInHeight($core.int v) { $_setSignedInt32(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasIncludedInHeight() => $_has(13);
  @$pb.TagNumber(14)
  void clearIncludedInHeight() => clearField(14);
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
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (criticalHash != null) {
      $result.criticalHash = criticalHash;
    }
    if (bidSats != null) {
      $result.bidSats = bidSats;
    }
    if (isOurs != null) {
      $result.isOurs = isOurs;
    }
    if (replacedByTxid != null) {
      $result.replacedByTxid = replacedByTxid;
    }
    if (state != null) {
      $result.state = state;
    }
    if (error != null) {
      $result.error = error;
    }
    if (prevMainHash != null) {
      $result.prevMainHash = prevMainHash;
    }
    return $result;
  }
  Bid._() : super();
  factory Bid.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Bid.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Bid', package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aOS(2, _omitFieldNames ? '' : 'criticalHash')
    ..aInt64(3, _omitFieldNames ? '' : 'bidSats')
    ..aOB(4, _omitFieldNames ? '' : 'isOurs')
    ..aOS(5, _omitFieldNames ? '' : 'replacedByTxid')
    ..aOS(6, _omitFieldNames ? '' : 'state')
    ..aOS(7, _omitFieldNames ? '' : 'error')
    ..aOS(8, _omitFieldNames ? '' : 'prevMainHash')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Bid clone() => Bid()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Bid copyWith(void Function(Bid) updates) => super.copyWith((message) => updates(message as Bid)) as Bid;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Bid create() => Bid._();
  Bid createEmptyInstance() => create();
  static $pb.PbList<Bid> createRepeated() => $pb.PbList<Bid>();
  @$core.pragma('dart2js:noInline')
  static Bid getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Bid>(create);
  static Bid? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  /// Sidechain block hash the bid commits to.
  @$pb.TagNumber(2)
  $core.String get criticalHash => $_getSZ(1);
  @$pb.TagNumber(2)
  set criticalHash($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCriticalHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearCriticalHash() => clearField(2);

  /// Fee the bid pays, which is what a miner collects for including it.
  @$pb.TagNumber(3)
  $fixnum.Int64 get bidSats => $_getI64(2);
  @$pb.TagNumber(3)
  set bidSats($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasBidSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearBidSats() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get isOurs => $_getBF(3);
  @$pb.TagNumber(4)
  set isOurs($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasIsOurs() => $_has(3);
  @$pb.TagNumber(4)
  void clearIsOurs() => clearField(4);

  /// Set when this bid was replaced by a raise. The replacement evicts it from
  /// the mempool, so it is only visible here.
  @$pb.TagNumber(5)
  $core.String get replacedByTxid => $_getSZ(4);
  @$pb.TagNumber(5)
  set replacedByTxid($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasReplacedByTxid() => $_has(4);
  @$pb.TagNumber(5)
  void clearReplacedByTxid() => clearField(5);

  /// One of: live, replaced, connected, missed, failed. Only set for our bids.
  @$pb.TagNumber(6)
  $core.String get state => $_getSZ(5);
  @$pb.TagNumber(6)
  set state($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasState() => $_has(5);
  @$pb.TagNumber(6)
  void clearState() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get error => $_getSZ(6);
  @$pb.TagNumber(7)
  set error($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasError() => $_has(6);
  @$pb.TagNumber(7)
  void clearError() => clearField(7);

  /// Mainchain tip the bid builds on. A bid for any other tip is already dead.
  @$pb.TagNumber(8)
  $core.String get prevMainHash => $_getSZ(7);
  @$pb.TagNumber(8)
  set prevMainHash($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasPrevMainHash() => $_has(7);
  @$pb.TagNumber(8)
  void clearPrevMainHash() => clearField(8);
}

class GetRoundBidsRequest extends $pb.GeneratedMessage {
  factory GetRoundBidsRequest({
    $2.BinaryType? sidechain,
    $core.String? prevMainHash,
  }) {
    final $result = create();
    if (sidechain != null) {
      $result.sidechain = sidechain;
    }
    if (prevMainHash != null) {
      $result.prevMainHash = prevMainHash;
    }
    return $result;
  }
  GetRoundBidsRequest._() : super();
  factory GetRoundBidsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetRoundBidsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetRoundBidsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'), createEmptyInstance: create)
    ..e<$2.BinaryType>(1, _omitFieldNames ? '' : 'sidechain', $pb.PbFieldType.OE, defaultOrMaker: $2.BinaryType.BINARY_TYPE_UNSPECIFIED, valueOf: $2.BinaryType.valueOf, enumValues: $2.BinaryType.values)
    ..aOS(2, _omitFieldNames ? '' : 'prevMainHash')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetRoundBidsRequest clone() => GetRoundBidsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetRoundBidsRequest copyWith(void Function(GetRoundBidsRequest) updates) => super.copyWith((message) => updates(message as GetRoundBidsRequest)) as GetRoundBidsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRoundBidsRequest create() => GetRoundBidsRequest._();
  GetRoundBidsRequest createEmptyInstance() => create();
  static $pb.PbList<GetRoundBidsRequest> createRepeated() => $pb.PbList<GetRoundBidsRequest>();
  @$core.pragma('dart2js:noInline')
  static GetRoundBidsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetRoundBidsRequest>(create);
  static GetRoundBidsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $2.BinaryType get sidechain => $_getN(0);
  @$pb.TagNumber(1)
  set sidechain($2.BinaryType v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechain() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechain() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get prevMainHash => $_getSZ(1);
  @$pb.TagNumber(2)
  set prevMainHash($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPrevMainHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrevMainHash() => clearField(2);
}

class GetRoundBidsResponse extends $pb.GeneratedMessage {
  factory GetRoundBidsResponse({
    Round? round,
  }) {
    final $result = create();
    if (round != null) {
      $result.round = round;
    }
    return $result;
  }
  GetRoundBidsResponse._() : super();
  factory GetRoundBidsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetRoundBidsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetRoundBidsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'), createEmptyInstance: create)
    ..aOM<Round>(1, _omitFieldNames ? '' : 'round', subBuilder: Round.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetRoundBidsResponse clone() => GetRoundBidsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetRoundBidsResponse copyWith(void Function(GetRoundBidsResponse) updates) => super.copyWith((message) => updates(message as GetRoundBidsResponse)) as GetRoundBidsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRoundBidsResponse create() => GetRoundBidsResponse._();
  GetRoundBidsResponse createEmptyInstance() => create();
  static $pb.PbList<GetRoundBidsResponse> createRepeated() => $pb.PbList<GetRoundBidsResponse>();
  @$core.pragma('dart2js:noInline')
  static GetRoundBidsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetRoundBidsResponse>(create);
  static GetRoundBidsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Round get round => $_getN(0);
  @$pb.TagNumber(1)
  set round(Round v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasRound() => $_has(0);
  @$pb.TagNumber(1)
  void clearRound() => clearField(1);
  @$pb.TagNumber(1)
  Round ensureRound() => $_ensure(0);
}

class CreateBidRequest extends $pb.GeneratedMessage {
  factory CreateBidRequest({
    $2.BinaryType? sidechain,
    $core.String? walletId,
    $fixnum.Int64? bidSats,
    $core.String? replaceTxid,
    $core.String? expectPrevMainHash,
    $core.bool? capToBlockWorth,
  }) {
    final $result = create();
    if (sidechain != null) {
      $result.sidechain = sidechain;
    }
    if (walletId != null) {
      $result.walletId = walletId;
    }
    if (bidSats != null) {
      $result.bidSats = bidSats;
    }
    if (replaceTxid != null) {
      $result.replaceTxid = replaceTxid;
    }
    if (expectPrevMainHash != null) {
      $result.expectPrevMainHash = expectPrevMainHash;
    }
    if (capToBlockWorth != null) {
      $result.capToBlockWorth = capToBlockWorth;
    }
    return $result;
  }
  CreateBidRequest._() : super();
  factory CreateBidRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateBidRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateBidRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'), createEmptyInstance: create)
    ..e<$2.BinaryType>(1, _omitFieldNames ? '' : 'sidechain', $pb.PbFieldType.OE, defaultOrMaker: $2.BinaryType.BINARY_TYPE_UNSPECIFIED, valueOf: $2.BinaryType.valueOf, enumValues: $2.BinaryType.values)
    ..aOS(2, _omitFieldNames ? '' : 'walletId')
    ..aInt64(3, _omitFieldNames ? '' : 'bidSats')
    ..aOS(4, _omitFieldNames ? '' : 'replaceTxid')
    ..aOS(5, _omitFieldNames ? '' : 'expectPrevMainHash')
    ..aOB(6, _omitFieldNames ? '' : 'capToBlockWorth')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateBidRequest clone() => CreateBidRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateBidRequest copyWith(void Function(CreateBidRequest) updates) => super.copyWith((message) => updates(message as CreateBidRequest)) as CreateBidRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateBidRequest create() => CreateBidRequest._();
  CreateBidRequest createEmptyInstance() => create();
  static $pb.PbList<CreateBidRequest> createRepeated() => $pb.PbList<CreateBidRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateBidRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateBidRequest>(create);
  static CreateBidRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $2.BinaryType get sidechain => $_getN(0);
  @$pb.TagNumber(1)
  set sidechain($2.BinaryType v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechain() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechain() => clearField(1);

  /// Wallet that funds the bid. Empty uses the active wallet.
  @$pb.TagNumber(2)
  $core.String get walletId => $_getSZ(1);
  @$pb.TagNumber(2)
  set walletId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWalletId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWalletId() => clearField(2);

  /// Bid, paid as the M8's fee so that a miner collects it.
  @$pb.TagNumber(3)
  $fixnum.Int64 get bidSats => $_getI64(2);
  @$pb.TagNumber(3)
  set bidSats($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasBidSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearBidSats() => clearField(3);

  /// Raise an earlier bid by spending its inputs again, which replaces it
  /// rather than bidding against it. Only works within the same slot.
  @$pb.TagNumber(4)
  $core.String get replaceTxid => $_getSZ(3);
  @$pb.TagNumber(4)
  set replaceTxid($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasReplaceTxid() => $_has(3);
  @$pb.TagNumber(4)
  void clearReplaceTxid() => clearField(4);

  /// Refuse the bid unless the sidechain builds on this mainchain tip. Stops a
  /// sidechain that has not caught up from spending on an already-dead round.
  @$pb.TagNumber(5)
  $core.String get expectPrevMainHash => $_getSZ(4);
  @$pb.TagNumber(5)
  set expectPrevMainHash($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasExpectPrevMainHash() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpectPrevMainHash() => clearField(5);

  /// Lower the bid to what the block collects in fees. Above that it loses money.
  @$pb.TagNumber(6)
  $core.bool get capToBlockWorth => $_getBF(5);
  @$pb.TagNumber(6)
  set capToBlockWorth($core.bool v) { $_setBool(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasCapToBlockWorth() => $_has(5);
  @$pb.TagNumber(6)
  void clearCapToBlockWorth() => clearField(6);
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
    final $result = create();
    if (criticalHash != null) {
      $result.criticalHash = criticalHash;
    }
    if (bmmTxid != null) {
      $result.bmmTxid = bmmTxid;
    }
    if (feesSats != null) {
      $result.feesSats = feesSats;
    }
    if (blockJson != null) {
      $result.blockJson = blockJson;
    }
    if (prevMainHash != null) {
      $result.prevMainHash = prevMainHash;
    }
    if (bidSats != null) {
      $result.bidSats = bidSats;
    }
    return $result;
  }
  CreateBidResponse._() : super();
  factory CreateBidResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateBidResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateBidResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'criticalHash')
    ..aOS(2, _omitFieldNames ? '' : 'bmmTxid')
    ..aInt64(3, _omitFieldNames ? '' : 'feesSats')
    ..aOS(4, _omitFieldNames ? '' : 'blockJson')
    ..aOS(5, _omitFieldNames ? '' : 'prevMainHash')
    ..aInt64(6, _omitFieldNames ? '' : 'bidSats')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateBidResponse clone() => CreateBidResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateBidResponse copyWith(void Function(CreateBidResponse) updates) => super.copyWith((message) => updates(message as CreateBidResponse)) as CreateBidResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateBidResponse create() => CreateBidResponse._();
  CreateBidResponse createEmptyInstance() => create();
  static $pb.PbList<CreateBidResponse> createRepeated() => $pb.PbList<CreateBidResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateBidResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateBidResponse>(create);
  static CreateBidResponse? _defaultInstance;

  /// Sidechain block hash committed to by the bid.
  @$pb.TagNumber(1)
  $core.String get criticalHash => $_getSZ(0);
  @$pb.TagNumber(1)
  set criticalHash($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCriticalHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearCriticalHash() => clearField(1);

  /// The M8 transaction that was broadcast.
  @$pb.TagNumber(2)
  $core.String get bmmTxid => $_getSZ(1);
  @$pb.TagNumber(2)
  set bmmTxid($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasBmmTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearBmmTxid() => clearField(2);

  /// Fees the block collects if it connects. A bid above this loses money.
  @$pb.TagNumber(3)
  $fixnum.Int64 get feesSats => $_getI64(2);
  @$pb.TagNumber(3)
  set feesSats($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFeesSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearFeesSats() => clearField(3);

  /// Opaque block, to hand back to ConnectBid.
  @$pb.TagNumber(4)
  $core.String get blockJson => $_getSZ(3);
  @$pb.TagNumber(4)
  set blockJson($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasBlockJson() => $_has(3);
  @$pb.TagNumber(4)
  void clearBlockJson() => clearField(4);

  /// Mainchain tip the bid builds on.
  @$pb.TagNumber(5)
  $core.String get prevMainHash => $_getSZ(4);
  @$pb.TagNumber(5)
  set prevMainHash($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasPrevMainHash() => $_has(4);
  @$pb.TagNumber(5)
  void clearPrevMainHash() => clearField(5);

  /// Bid actually broadcast, which cap_to_block_worth may have lowered.
  @$pb.TagNumber(6)
  $fixnum.Int64 get bidSats => $_getI64(5);
  @$pb.TagNumber(6)
  set bidSats($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasBidSats() => $_has(5);
  @$pb.TagNumber(6)
  void clearBidSats() => clearField(6);
}

class ConnectBidRequest extends $pb.GeneratedMessage {
  factory ConnectBidRequest({
    $2.BinaryType? sidechain,
    $core.String? criticalHash,
    $core.String? blockJson,
    $core.String? mainBlockHash,
  }) {
    final $result = create();
    if (sidechain != null) {
      $result.sidechain = sidechain;
    }
    if (criticalHash != null) {
      $result.criticalHash = criticalHash;
    }
    if (blockJson != null) {
      $result.blockJson = blockJson;
    }
    if (mainBlockHash != null) {
      $result.mainBlockHash = mainBlockHash;
    }
    return $result;
  }
  ConnectBidRequest._() : super();
  factory ConnectBidRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConnectBidRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConnectBidRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'), createEmptyInstance: create)
    ..e<$2.BinaryType>(1, _omitFieldNames ? '' : 'sidechain', $pb.PbFieldType.OE, defaultOrMaker: $2.BinaryType.BINARY_TYPE_UNSPECIFIED, valueOf: $2.BinaryType.valueOf, enumValues: $2.BinaryType.values)
    ..aOS(2, _omitFieldNames ? '' : 'criticalHash')
    ..aOS(3, _omitFieldNames ? '' : 'blockJson')
    ..aOS(4, _omitFieldNames ? '' : 'mainBlockHash')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConnectBidRequest clone() => ConnectBidRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConnectBidRequest copyWith(void Function(ConnectBidRequest) updates) => super.copyWith((message) => updates(message as ConnectBidRequest)) as ConnectBidRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConnectBidRequest create() => ConnectBidRequest._();
  ConnectBidRequest createEmptyInstance() => create();
  static $pb.PbList<ConnectBidRequest> createRepeated() => $pb.PbList<ConnectBidRequest>();
  @$core.pragma('dart2js:noInline')
  static ConnectBidRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConnectBidRequest>(create);
  static ConnectBidRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $2.BinaryType get sidechain => $_getN(0);
  @$pb.TagNumber(1)
  set sidechain($2.BinaryType v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechain() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechain() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get criticalHash => $_getSZ(1);
  @$pb.TagNumber(2)
  set criticalHash($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasCriticalHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearCriticalHash() => clearField(2);

  /// block_json as returned by CreateBid.
  @$pb.TagNumber(3)
  $core.String get blockJson => $_getSZ(2);
  @$pb.TagNumber(3)
  set blockJson($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasBlockJson() => $_has(2);
  @$pb.TagNumber(3)
  void clearBlockJson() => clearField(3);

  /// Mainchain block that carries the commitment. Empty asks the sidechain
  /// which block included the bid, which only answers for a block it already
  /// holds.
  @$pb.TagNumber(4)
  $core.String get mainBlockHash => $_getSZ(3);
  @$pb.TagNumber(4)
  set mainBlockHash($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasMainBlockHash() => $_has(3);
  @$pb.TagNumber(4)
  void clearMainBlockHash() => clearField(4);
}

class ConnectBidResponse extends $pb.GeneratedMessage {
  factory ConnectBidResponse({
    $core.bool? connected,
    $core.String? mainBlockHash,
  }) {
    final $result = create();
    if (connected != null) {
      $result.connected = connected;
    }
    if (mainBlockHash != null) {
      $result.mainBlockHash = mainBlockHash;
    }
    return $result;
  }
  ConnectBidResponse._() : super();
  factory ConnectBidResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConnectBidResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ConnectBidResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'connected')
    ..aOS(2, _omitFieldNames ? '' : 'mainBlockHash')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ConnectBidResponse clone() => ConnectBidResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ConnectBidResponse copyWith(void Function(ConnectBidResponse) updates) => super.copyWith((message) => updates(message as ConnectBidResponse)) as ConnectBidResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ConnectBidResponse create() => ConnectBidResponse._();
  ConnectBidResponse createEmptyInstance() => create();
  static $pb.PbList<ConnectBidResponse> createRepeated() => $pb.PbList<ConnectBidResponse>();
  @$core.pragma('dart2js:noInline')
  static ConnectBidResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConnectBidResponse>(create);
  static ConnectBidResponse? _defaultInstance;

  /// False while no mainchain block includes the bid yet.
  @$pb.TagNumber(1)
  $core.bool get connected => $_getBF(0);
  @$pb.TagNumber(1)
  set connected($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConnected() => $_has(0);
  @$pb.TagNumber(1)
  void clearConnected() => clearField(1);

  /// Mainchain block that included the bid, when connected.
  @$pb.TagNumber(2)
  $core.String get mainBlockHash => $_getSZ(1);
  @$pb.TagNumber(2)
  set mainBlockHash($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMainBlockHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearMainBlockHash() => clearField(2);
}

class ListBidsRequest extends $pb.GeneratedMessage {
  factory ListBidsRequest({
    $2.BinaryType? sidechain,
  }) {
    final $result = create();
    if (sidechain != null) {
      $result.sidechain = sidechain;
    }
    return $result;
  }
  ListBidsRequest._() : super();
  factory ListBidsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListBidsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListBidsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'), createEmptyInstance: create)
    ..e<$2.BinaryType>(1, _omitFieldNames ? '' : 'sidechain', $pb.PbFieldType.OE, defaultOrMaker: $2.BinaryType.BINARY_TYPE_UNSPECIFIED, valueOf: $2.BinaryType.valueOf, enumValues: $2.BinaryType.values)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListBidsRequest clone() => ListBidsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListBidsRequest copyWith(void Function(ListBidsRequest) updates) => super.copyWith((message) => updates(message as ListBidsRequest)) as ListBidsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListBidsRequest create() => ListBidsRequest._();
  ListBidsRequest createEmptyInstance() => create();
  static $pb.PbList<ListBidsRequest> createRepeated() => $pb.PbList<ListBidsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListBidsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListBidsRequest>(create);
  static ListBidsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $2.BinaryType get sidechain => $_getN(0);
  @$pb.TagNumber(1)
  set sidechain($2.BinaryType v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechain() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechain() => clearField(1);
}

class ListBidsResponse extends $pb.GeneratedMessage {
  factory ListBidsResponse({
    $core.Iterable<Bid>? bids,
  }) {
    final $result = create();
    if (bids != null) {
      $result.bids.addAll(bids);
    }
    return $result;
  }
  ListBidsResponse._() : super();
  factory ListBidsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListBidsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListBidsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'), createEmptyInstance: create)
    ..pc<Bid>(1, _omitFieldNames ? '' : 'bids', $pb.PbFieldType.PM, subBuilder: Bid.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListBidsResponse clone() => ListBidsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListBidsResponse copyWith(void Function(ListBidsResponse) updates) => super.copyWith((message) => updates(message as ListBidsResponse)) as ListBidsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListBidsResponse create() => ListBidsResponse._();
  ListBidsResponse createEmptyInstance() => create();
  static $pb.PbList<ListBidsResponse> createRepeated() => $pb.PbList<ListBidsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListBidsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListBidsResponse>(create);
  static ListBidsResponse? _defaultInstance;

  /// Highest bid first.
  @$pb.TagNumber(1)
  $core.List<Bid> get bids => $_getList(0);
}

class AttackBidRequest extends $pb.GeneratedMessage {
  factory AttackBidRequest({
    $2.BinaryType? sidechain,
    $core.String? walletId,
    $fixnum.Int64? bidSats,
  }) {
    final $result = create();
    if (sidechain != null) {
      $result.sidechain = sidechain;
    }
    if (walletId != null) {
      $result.walletId = walletId;
    }
    if (bidSats != null) {
      $result.bidSats = bidSats;
    }
    return $result;
  }
  AttackBidRequest._() : super();
  factory AttackBidRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AttackBidRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AttackBidRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'), createEmptyInstance: create)
    ..e<$2.BinaryType>(1, _omitFieldNames ? '' : 'sidechain', $pb.PbFieldType.OE, defaultOrMaker: $2.BinaryType.BINARY_TYPE_UNSPECIFIED, valueOf: $2.BinaryType.valueOf, enumValues: $2.BinaryType.values)
    ..aOS(2, _omitFieldNames ? '' : 'walletId')
    ..aInt64(3, _omitFieldNames ? '' : 'bidSats')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AttackBidRequest clone() => AttackBidRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AttackBidRequest copyWith(void Function(AttackBidRequest) updates) => super.copyWith((message) => updates(message as AttackBidRequest)) as AttackBidRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AttackBidRequest create() => AttackBidRequest._();
  AttackBidRequest createEmptyInstance() => create();
  static $pb.PbList<AttackBidRequest> createRepeated() => $pb.PbList<AttackBidRequest>();
  @$core.pragma('dart2js:noInline')
  static AttackBidRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AttackBidRequest>(create);
  static AttackBidRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $2.BinaryType get sidechain => $_getN(0);
  @$pb.TagNumber(1)
  set sidechain($2.BinaryType v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSidechain() => $_has(0);
  @$pb.TagNumber(1)
  void clearSidechain() => clearField(1);

  /// Wallet that funds the bid. Empty uses the active wallet.
  @$pb.TagNumber(2)
  $core.String get walletId => $_getSZ(1);
  @$pb.TagNumber(2)
  set walletId($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWalletId() => $_has(1);
  @$pb.TagNumber(2)
  void clearWalletId() => clearField(2);

  /// Bid, paid as the M8's fee so that a miner collects it.
  @$pb.TagNumber(3)
  $fixnum.Int64 get bidSats => $_getI64(2);
  @$pb.TagNumber(3)
  set bidSats($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasBidSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearBidSats() => clearField(3);
}

class AttackBidResponse extends $pb.GeneratedMessage {
  factory AttackBidResponse({
    $core.String? criticalHash,
    $core.String? bmmTxid,
  }) {
    final $result = create();
    if (criticalHash != null) {
      $result.criticalHash = criticalHash;
    }
    if (bmmTxid != null) {
      $result.bmmTxid = bmmTxid;
    }
    return $result;
  }
  AttackBidResponse._() : super();
  factory AttackBidResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AttackBidResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AttackBidResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bmm.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'criticalHash')
    ..aOS(2, _omitFieldNames ? '' : 'bmmTxid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AttackBidResponse clone() => AttackBidResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AttackBidResponse copyWith(void Function(AttackBidResponse) updates) => super.copyWith((message) => updates(message as AttackBidResponse)) as AttackBidResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AttackBidResponse create() => AttackBidResponse._();
  AttackBidResponse createEmptyInstance() => create();
  static $pb.PbList<AttackBidResponse> createRepeated() => $pb.PbList<AttackBidResponse>();
  @$core.pragma('dart2js:noInline')
  static AttackBidResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AttackBidResponse>(create);
  static AttackBidResponse? _defaultInstance;

  /// Random hash committed to. No block exists for it, so it never connects.
  @$pb.TagNumber(1)
  $core.String get criticalHash => $_getSZ(0);
  @$pb.TagNumber(1)
  set criticalHash($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCriticalHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearCriticalHash() => clearField(1);

  /// The M8 transaction that was broadcast.
  @$pb.TagNumber(2)
  $core.String get bmmTxid => $_getSZ(1);
  @$pb.TagNumber(2)
  set bmmTxid($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasBmmTxid() => $_has(1);
  @$pb.TagNumber(2)
  void clearBmmTxid() => clearField(2);
}

class BMMServiceApi {
  $pb.RpcClient _client;
  BMMServiceApi(this._client);

  $async.Future<StartResponse> start($pb.ClientContext? ctx, StartRequest request) =>
    _client.invoke<StartResponse>(ctx, 'BMMService', 'Start', request, StartResponse())
  ;
  $async.Future<StopResponse> stop($pb.ClientContext? ctx, StopRequest request) =>
    _client.invoke<StopResponse>(ctx, 'BMMService', 'Stop', request, StopResponse())
  ;
  $async.Future<ClearHistoryResponse> clearHistory($pb.ClientContext? ctx, ClearHistoryRequest request) =>
    _client.invoke<ClearHistoryResponse>(ctx, 'BMMService', 'ClearHistory', request, ClearHistoryResponse())
  ;
  $async.Future<WatchResponse> watch($pb.ClientContext? ctx, WatchRequest request) =>
    _client.invoke<WatchResponse>(ctx, 'BMMService', 'Watch', request, WatchResponse())
  ;
  $async.Future<GetRoundBidsResponse> getRoundBids($pb.ClientContext? ctx, GetRoundBidsRequest request) =>
    _client.invoke<GetRoundBidsResponse>(ctx, 'BMMService', 'GetRoundBids', request, GetRoundBidsResponse())
  ;
  $async.Future<CreateBidResponse> createBid($pb.ClientContext? ctx, CreateBidRequest request) =>
    _client.invoke<CreateBidResponse>(ctx, 'BMMService', 'CreateBid', request, CreateBidResponse())
  ;
  $async.Future<ConnectBidResponse> connectBid($pb.ClientContext? ctx, ConnectBidRequest request) =>
    _client.invoke<ConnectBidResponse>(ctx, 'BMMService', 'ConnectBid', request, ConnectBidResponse())
  ;
  $async.Future<ListBidsResponse> listBids($pb.ClientContext? ctx, ListBidsRequest request) =>
    _client.invoke<ListBidsResponse>(ctx, 'BMMService', 'ListBids', request, ListBidsResponse())
  ;
  $async.Future<AttackBidResponse> attackBid($pb.ClientContext? ctx, AttackBidRequest request) =>
    _client.invoke<AttackBidResponse>(ctx, 'BMMService', 'AttackBid', request, AttackBidResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
