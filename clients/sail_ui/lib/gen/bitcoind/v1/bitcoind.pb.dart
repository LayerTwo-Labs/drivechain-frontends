//
//  Generated code. Do not modify.
//  source: bitcoind/v1/bitcoind.proto
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
import '../../google/protobuf/timestamp.pb.dart' as $0;

class ListBlocksRequest extends $pb.GeneratedMessage {
  factory ListBlocksRequest({
    $core.int? startHeight,
    $core.int? pageSize,
  }) {
    final $result = create();
    if (startHeight != null) {
      $result.startHeight = startHeight;
    }
    if (pageSize != null) {
      $result.pageSize = pageSize;
    }
    return $result;
  }
  ListBlocksRequest._() : super();
  factory ListBlocksRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListBlocksRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListBlocksRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'startHeight', $pb.PbFieldType.OU3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'pageSize', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListBlocksRequest clone() => ListBlocksRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListBlocksRequest copyWith(void Function(ListBlocksRequest) updates) => super.copyWith((message) => updates(message as ListBlocksRequest)) as ListBlocksRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListBlocksRequest create() => ListBlocksRequest._();
  ListBlocksRequest createEmptyInstance() => create();
  static $pb.PbList<ListBlocksRequest> createRepeated() => $pb.PbList<ListBlocksRequest>();
  @$core.pragma('dart2js:noInline')
  static ListBlocksRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListBlocksRequest>(create);
  static ListBlocksRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get startHeight => $_getIZ(0);
  @$pb.TagNumber(1)
  set startHeight($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasStartHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearStartHeight() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get pageSize => $_getIZ(1);
  @$pb.TagNumber(2)
  set pageSize($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPageSize() => $_has(1);
  @$pb.TagNumber(2)
  void clearPageSize() => clearField(2);
}

class Block extends $pb.GeneratedMessage {
  factory Block({
    $0.Timestamp? blockTime,
    $core.int? height,
    $core.String? hash,
    $core.int? confirmations,
    $core.int? version,
    $core.String? versionHex,
    $core.String? merkleRoot,
    $core.int? nonce,
    $core.String? bits,
    $core.double? difficulty,
    $core.String? previousBlockHash,
    $core.String? nextBlockHash,
    $core.int? strippedSize,
    $core.int? size,
    $core.int? weight,
    $core.Iterable<$core.String>? txids,
  }) {
    final $result = create();
    if (blockTime != null) {
      $result.blockTime = blockTime;
    }
    if (height != null) {
      $result.height = height;
    }
    if (hash != null) {
      $result.hash = hash;
    }
    if (confirmations != null) {
      $result.confirmations = confirmations;
    }
    if (version != null) {
      $result.version = version;
    }
    if (versionHex != null) {
      $result.versionHex = versionHex;
    }
    if (merkleRoot != null) {
      $result.merkleRoot = merkleRoot;
    }
    if (nonce != null) {
      $result.nonce = nonce;
    }
    if (bits != null) {
      $result.bits = bits;
    }
    if (difficulty != null) {
      $result.difficulty = difficulty;
    }
    if (previousBlockHash != null) {
      $result.previousBlockHash = previousBlockHash;
    }
    if (nextBlockHash != null) {
      $result.nextBlockHash = nextBlockHash;
    }
    if (strippedSize != null) {
      $result.strippedSize = strippedSize;
    }
    if (size != null) {
      $result.size = size;
    }
    if (weight != null) {
      $result.weight = weight;
    }
    if (txids != null) {
      $result.txids.addAll(txids);
    }
    return $result;
  }
  Block._() : super();
  factory Block.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Block.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Block', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOM<$0.Timestamp>(1, _omitFieldNames ? '' : 'blockTime', subBuilder: $0.Timestamp.create)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'height', $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'hash')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'confirmations', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'version', $pb.PbFieldType.O3)
    ..aOS(6, _omitFieldNames ? '' : 'versionHex')
    ..aOS(7, _omitFieldNames ? '' : 'merkleRoot')
    ..a<$core.int>(8, _omitFieldNames ? '' : 'nonce', $pb.PbFieldType.OU3)
    ..aOS(9, _omitFieldNames ? '' : 'bits')
    ..a<$core.double>(10, _omitFieldNames ? '' : 'difficulty', $pb.PbFieldType.OD)
    ..aOS(11, _omitFieldNames ? '' : 'previousBlockHash')
    ..aOS(12, _omitFieldNames ? '' : 'nextBlockHash')
    ..a<$core.int>(13, _omitFieldNames ? '' : 'strippedSize', $pb.PbFieldType.O3)
    ..a<$core.int>(14, _omitFieldNames ? '' : 'size', $pb.PbFieldType.O3)
    ..a<$core.int>(15, _omitFieldNames ? '' : 'weight', $pb.PbFieldType.O3)
    ..pPS(16, _omitFieldNames ? '' : 'txids')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Block clone() => Block()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Block copyWith(void Function(Block) updates) => super.copyWith((message) => updates(message as Block)) as Block;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Block create() => Block._();
  Block createEmptyInstance() => create();
  static $pb.PbList<Block> createRepeated() => $pb.PbList<Block>();
  @$core.pragma('dart2js:noInline')
  static Block getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Block>(create);
  static Block? _defaultInstance;

  @$pb.TagNumber(1)
  $0.Timestamp get blockTime => $_getN(0);
  @$pb.TagNumber(1)
  set blockTime($0.Timestamp v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBlockTime() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockTime() => clearField(1);
  @$pb.TagNumber(1)
  $0.Timestamp ensureBlockTime() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.int get height => $_getIZ(1);
  @$pb.TagNumber(2)
  set height($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeight() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get hash => $_getSZ(2);
  @$pb.TagNumber(3)
  set hash($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasHash() => $_has(2);
  @$pb.TagNumber(3)
  void clearHash() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get confirmations => $_getIZ(3);
  @$pb.TagNumber(4)
  set confirmations($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasConfirmations() => $_has(3);
  @$pb.TagNumber(4)
  void clearConfirmations() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get version => $_getIZ(4);
  @$pb.TagNumber(5)
  set version($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasVersion() => $_has(4);
  @$pb.TagNumber(5)
  void clearVersion() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get versionHex => $_getSZ(5);
  @$pb.TagNumber(6)
  set versionHex($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasVersionHex() => $_has(5);
  @$pb.TagNumber(6)
  void clearVersionHex() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get merkleRoot => $_getSZ(6);
  @$pb.TagNumber(7)
  set merkleRoot($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasMerkleRoot() => $_has(6);
  @$pb.TagNumber(7)
  void clearMerkleRoot() => clearField(7);

  @$pb.TagNumber(8)
  $core.int get nonce => $_getIZ(7);
  @$pb.TagNumber(8)
  set nonce($core.int v) { $_setUnsignedInt32(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasNonce() => $_has(7);
  @$pb.TagNumber(8)
  void clearNonce() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get bits => $_getSZ(8);
  @$pb.TagNumber(9)
  set bits($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasBits() => $_has(8);
  @$pb.TagNumber(9)
  void clearBits() => clearField(9);

  @$pb.TagNumber(10)
  $core.double get difficulty => $_getN(9);
  @$pb.TagNumber(10)
  set difficulty($core.double v) { $_setDouble(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasDifficulty() => $_has(9);
  @$pb.TagNumber(10)
  void clearDifficulty() => clearField(10);

  @$pb.TagNumber(11)
  $core.String get previousBlockHash => $_getSZ(10);
  @$pb.TagNumber(11)
  set previousBlockHash($core.String v) { $_setString(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasPreviousBlockHash() => $_has(10);
  @$pb.TagNumber(11)
  void clearPreviousBlockHash() => clearField(11);

  @$pb.TagNumber(12)
  $core.String get nextBlockHash => $_getSZ(11);
  @$pb.TagNumber(12)
  set nextBlockHash($core.String v) { $_setString(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasNextBlockHash() => $_has(11);
  @$pb.TagNumber(12)
  void clearNextBlockHash() => clearField(12);

  @$pb.TagNumber(13)
  $core.int get strippedSize => $_getIZ(12);
  @$pb.TagNumber(13)
  set strippedSize($core.int v) { $_setSignedInt32(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasStrippedSize() => $_has(12);
  @$pb.TagNumber(13)
  void clearStrippedSize() => clearField(13);

  @$pb.TagNumber(14)
  $core.int get size => $_getIZ(13);
  @$pb.TagNumber(14)
  set size($core.int v) { $_setSignedInt32(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasSize() => $_has(13);
  @$pb.TagNumber(14)
  void clearSize() => clearField(14);

  @$pb.TagNumber(15)
  $core.int get weight => $_getIZ(14);
  @$pb.TagNumber(15)
  set weight($core.int v) { $_setSignedInt32(14, v); }
  @$pb.TagNumber(15)
  $core.bool hasWeight() => $_has(14);
  @$pb.TagNumber(15)
  void clearWeight() => clearField(15);

  @$pb.TagNumber(16)
  $core.List<$core.String> get txids => $_getList(15);
}

class ListBlocksResponse extends $pb.GeneratedMessage {
  factory ListBlocksResponse({
    $core.Iterable<Block>? recentBlocks,
    $core.bool? hasMore,
  }) {
    final $result = create();
    if (recentBlocks != null) {
      $result.recentBlocks.addAll(recentBlocks);
    }
    if (hasMore != null) {
      $result.hasMore = hasMore;
    }
    return $result;
  }
  ListBlocksResponse._() : super();
  factory ListBlocksResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListBlocksResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListBlocksResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..pc<Block>(4, _omitFieldNames ? '' : 'recentBlocks', $pb.PbFieldType.PM, subBuilder: Block.create)
    ..aOB(5, _omitFieldNames ? '' : 'hasMore')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListBlocksResponse clone() => ListBlocksResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListBlocksResponse copyWith(void Function(ListBlocksResponse) updates) => super.copyWith((message) => updates(message as ListBlocksResponse)) as ListBlocksResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListBlocksResponse create() => ListBlocksResponse._();
  ListBlocksResponse createEmptyInstance() => create();
  static $pb.PbList<ListBlocksResponse> createRepeated() => $pb.PbList<ListBlocksResponse>();
  @$core.pragma('dart2js:noInline')
  static ListBlocksResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListBlocksResponse>(create);
  static ListBlocksResponse? _defaultInstance;

  @$pb.TagNumber(4)
  $core.List<Block> get recentBlocks => $_getList(0);

  @$pb.TagNumber(5)
  $core.bool get hasMore => $_getBF(1);
  @$pb.TagNumber(5)
  set hasMore($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(5)
  $core.bool hasHasMore() => $_has(1);
  @$pb.TagNumber(5)
  void clearHasMore() => clearField(5);
}

class ListRecentTransactionsRequest extends $pb.GeneratedMessage {
  factory ListRecentTransactionsRequest({
    $fixnum.Int64? count,
  }) {
    final $result = create();
    if (count != null) {
      $result.count = count;
    }
    return $result;
  }
  ListRecentTransactionsRequest._() : super();
  factory ListRecentTransactionsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListRecentTransactionsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListRecentTransactionsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'count')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListRecentTransactionsRequest clone() => ListRecentTransactionsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListRecentTransactionsRequest copyWith(void Function(ListRecentTransactionsRequest) updates) => super.copyWith((message) => updates(message as ListRecentTransactionsRequest)) as ListRecentTransactionsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListRecentTransactionsRequest create() => ListRecentTransactionsRequest._();
  ListRecentTransactionsRequest createEmptyInstance() => create();
  static $pb.PbList<ListRecentTransactionsRequest> createRepeated() => $pb.PbList<ListRecentTransactionsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListRecentTransactionsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListRecentTransactionsRequest>(create);
  static ListRecentTransactionsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get count => $_getI64(0);
  @$pb.TagNumber(1)
  set count($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearCount() => clearField(1);
}

class ListRecentTransactionsResponse extends $pb.GeneratedMessage {
  factory ListRecentTransactionsResponse({
    $core.Iterable<RecentTransaction>? transactions,
  }) {
    final $result = create();
    if (transactions != null) {
      $result.transactions.addAll(transactions);
    }
    return $result;
  }
  ListRecentTransactionsResponse._() : super();
  factory ListRecentTransactionsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListRecentTransactionsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListRecentTransactionsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..pc<RecentTransaction>(1, _omitFieldNames ? '' : 'transactions', $pb.PbFieldType.PM, subBuilder: RecentTransaction.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListRecentTransactionsResponse clone() => ListRecentTransactionsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListRecentTransactionsResponse copyWith(void Function(ListRecentTransactionsResponse) updates) => super.copyWith((message) => updates(message as ListRecentTransactionsResponse)) as ListRecentTransactionsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListRecentTransactionsResponse create() => ListRecentTransactionsResponse._();
  ListRecentTransactionsResponse createEmptyInstance() => create();
  static $pb.PbList<ListRecentTransactionsResponse> createRepeated() => $pb.PbList<ListRecentTransactionsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListRecentTransactionsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListRecentTransactionsResponse>(create);
  static ListRecentTransactionsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<RecentTransaction> get transactions => $_getList(0);
}

class RecentTransaction extends $pb.GeneratedMessage {
  factory RecentTransaction({
    $core.int? virtualSize,
    $0.Timestamp? time,
    $core.String? txid,
    $fixnum.Int64? feeSats,
    Block? confirmedInBlock,
  }) {
    final $result = create();
    if (virtualSize != null) {
      $result.virtualSize = virtualSize;
    }
    if (time != null) {
      $result.time = time;
    }
    if (txid != null) {
      $result.txid = txid;
    }
    if (feeSats != null) {
      $result.feeSats = feeSats;
    }
    if (confirmedInBlock != null) {
      $result.confirmedInBlock = confirmedInBlock;
    }
    return $result;
  }
  RecentTransaction._() : super();
  factory RecentTransaction.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RecentTransaction.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RecentTransaction', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'virtualSize', $pb.PbFieldType.OU3)
    ..aOM<$0.Timestamp>(2, _omitFieldNames ? '' : 'time', subBuilder: $0.Timestamp.create)
    ..aOS(3, _omitFieldNames ? '' : 'txid')
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'feeSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<Block>(5, _omitFieldNames ? '' : 'confirmedInBlock', subBuilder: Block.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RecentTransaction clone() => RecentTransaction()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RecentTransaction copyWith(void Function(RecentTransaction) updates) => super.copyWith((message) => updates(message as RecentTransaction)) as RecentTransaction;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RecentTransaction create() => RecentTransaction._();
  RecentTransaction createEmptyInstance() => create();
  static $pb.PbList<RecentTransaction> createRepeated() => $pb.PbList<RecentTransaction>();
  @$core.pragma('dart2js:noInline')
  static RecentTransaction getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RecentTransaction>(create);
  static RecentTransaction? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get virtualSize => $_getIZ(0);
  @$pb.TagNumber(1)
  set virtualSize($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasVirtualSize() => $_has(0);
  @$pb.TagNumber(1)
  void clearVirtualSize() => clearField(1);

  @$pb.TagNumber(2)
  $0.Timestamp get time => $_getN(1);
  @$pb.TagNumber(2)
  set time($0.Timestamp v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearTime() => clearField(2);
  @$pb.TagNumber(2)
  $0.Timestamp ensureTime() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get txid => $_getSZ(2);
  @$pb.TagNumber(3)
  set txid($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTxid() => $_has(2);
  @$pb.TagNumber(3)
  void clearTxid() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get feeSats => $_getI64(3);
  @$pb.TagNumber(4)
  set feeSats($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFeeSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearFeeSats() => clearField(4);

  @$pb.TagNumber(5)
  Block get confirmedInBlock => $_getN(4);
  @$pb.TagNumber(5)
  set confirmedInBlock(Block v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasConfirmedInBlock() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfirmedInBlock() => clearField(5);
  @$pb.TagNumber(5)
  Block ensureConfirmedInBlock() => $_ensure(4);
}

class GetBlockchainInfoResponse extends $pb.GeneratedMessage {
  factory GetBlockchainInfoResponse({
    $core.String? chain,
    $core.int? blocks,
    $core.int? headers,
    $core.String? bestBlockHash,
    $core.bool? initialBlockDownload,
  }) {
    final $result = create();
    if (chain != null) {
      $result.chain = chain;
    }
    if (blocks != null) {
      $result.blocks = blocks;
    }
    if (headers != null) {
      $result.headers = headers;
    }
    if (bestBlockHash != null) {
      $result.bestBlockHash = bestBlockHash;
    }
    if (initialBlockDownload != null) {
      $result.initialBlockDownload = initialBlockDownload;
    }
    return $result;
  }
  GetBlockchainInfoResponse._() : super();
  factory GetBlockchainInfoResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBlockchainInfoResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockchainInfoResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'chain')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'blocks', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'headers', $pb.PbFieldType.OU3)
    ..aOS(4, _omitFieldNames ? '' : 'bestBlockHash')
    ..aOB(8, _omitFieldNames ? '' : 'initialBlockDownload')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBlockchainInfoResponse clone() => GetBlockchainInfoResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBlockchainInfoResponse copyWith(void Function(GetBlockchainInfoResponse) updates) => super.copyWith((message) => updates(message as GetBlockchainInfoResponse)) as GetBlockchainInfoResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBlockchainInfoResponse create() => GetBlockchainInfoResponse._();
  GetBlockchainInfoResponse createEmptyInstance() => create();
  static $pb.PbList<GetBlockchainInfoResponse> createRepeated() => $pb.PbList<GetBlockchainInfoResponse>();
  @$core.pragma('dart2js:noInline')
  static GetBlockchainInfoResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBlockchainInfoResponse>(create);
  static GetBlockchainInfoResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get chain => $_getSZ(0);
  @$pb.TagNumber(1)
  set chain($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasChain() => $_has(0);
  @$pb.TagNumber(1)
  void clearChain() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get blocks => $_getIZ(1);
  @$pb.TagNumber(2)
  set blocks($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasBlocks() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlocks() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get headers => $_getIZ(2);
  @$pb.TagNumber(3)
  set headers($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasHeaders() => $_has(2);
  @$pb.TagNumber(3)
  void clearHeaders() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get bestBlockHash => $_getSZ(3);
  @$pb.TagNumber(4)
  set bestBlockHash($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasBestBlockHash() => $_has(3);
  @$pb.TagNumber(4)
  void clearBestBlockHash() => clearField(4);

  @$pb.TagNumber(8)
  $core.bool get initialBlockDownload => $_getBF(4);
  @$pb.TagNumber(8)
  set initialBlockDownload($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(8)
  $core.bool hasInitialBlockDownload() => $_has(4);
  @$pb.TagNumber(8)
  void clearInitialBlockDownload() => clearField(8);
}

class Peer extends $pb.GeneratedMessage {
  factory Peer({
    $core.int? id,
    $core.String? addr,
    $core.int? syncedBlocks,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (addr != null) {
      $result.addr = addr;
    }
    if (syncedBlocks != null) {
      $result.syncedBlocks = syncedBlocks;
    }
    return $result;
  }
  Peer._() : super();
  factory Peer.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Peer.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Peer', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'addr')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'syncedBlocks', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Peer clone() => Peer()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Peer copyWith(void Function(Peer) updates) => super.copyWith((message) => updates(message as Peer)) as Peer;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Peer create() => Peer._();
  Peer createEmptyInstance() => create();
  static $pb.PbList<Peer> createRepeated() => $pb.PbList<Peer>();
  @$core.pragma('dart2js:noInline')
  static Peer getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Peer>(create);
  static Peer? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get id => $_getIZ(0);
  @$pb.TagNumber(1)
  set id($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get addr => $_getSZ(1);
  @$pb.TagNumber(2)
  set addr($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAddr() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddr() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get syncedBlocks => $_getIZ(2);
  @$pb.TagNumber(3)
  set syncedBlocks($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSyncedBlocks() => $_has(2);
  @$pb.TagNumber(3)
  void clearSyncedBlocks() => clearField(3);
}

class ListPeersResponse extends $pb.GeneratedMessage {
  factory ListPeersResponse({
    $core.Iterable<Peer>? peers,
  }) {
    final $result = create();
    if (peers != null) {
      $result.peers.addAll(peers);
    }
    return $result;
  }
  ListPeersResponse._() : super();
  factory ListPeersResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListPeersResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListPeersResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..pc<Peer>(1, _omitFieldNames ? '' : 'peers', $pb.PbFieldType.PM, subBuilder: Peer.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListPeersResponse clone() => ListPeersResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListPeersResponse copyWith(void Function(ListPeersResponse) updates) => super.copyWith((message) => updates(message as ListPeersResponse)) as ListPeersResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListPeersResponse create() => ListPeersResponse._();
  ListPeersResponse createEmptyInstance() => create();
  static $pb.PbList<ListPeersResponse> createRepeated() => $pb.PbList<ListPeersResponse>();
  @$core.pragma('dart2js:noInline')
  static ListPeersResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListPeersResponse>(create);
  static ListPeersResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Peer> get peers => $_getList(0);
}

class EstimateSmartFeeRequest extends $pb.GeneratedMessage {
  factory EstimateSmartFeeRequest({
    $fixnum.Int64? confTarget,
  }) {
    final $result = create();
    if (confTarget != null) {
      $result.confTarget = confTarget;
    }
    return $result;
  }
  EstimateSmartFeeRequest._() : super();
  factory EstimateSmartFeeRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EstimateSmartFeeRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EstimateSmartFeeRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'confTarget')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EstimateSmartFeeRequest clone() => EstimateSmartFeeRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EstimateSmartFeeRequest copyWith(void Function(EstimateSmartFeeRequest) updates) => super.copyWith((message) => updates(message as EstimateSmartFeeRequest)) as EstimateSmartFeeRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EstimateSmartFeeRequest create() => EstimateSmartFeeRequest._();
  EstimateSmartFeeRequest createEmptyInstance() => create();
  static $pb.PbList<EstimateSmartFeeRequest> createRepeated() => $pb.PbList<EstimateSmartFeeRequest>();
  @$core.pragma('dart2js:noInline')
  static EstimateSmartFeeRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EstimateSmartFeeRequest>(create);
  static EstimateSmartFeeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get confTarget => $_getI64(0);
  @$pb.TagNumber(1)
  set confTarget($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasConfTarget() => $_has(0);
  @$pb.TagNumber(1)
  void clearConfTarget() => clearField(1);
}

class EstimateSmartFeeResponse extends $pb.GeneratedMessage {
  factory EstimateSmartFeeResponse({
    $core.double? feeRate,
    $core.Iterable<$core.String>? errors,
  }) {
    final $result = create();
    if (feeRate != null) {
      $result.feeRate = feeRate;
    }
    if (errors != null) {
      $result.errors.addAll(errors);
    }
    return $result;
  }
  EstimateSmartFeeResponse._() : super();
  factory EstimateSmartFeeResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EstimateSmartFeeResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EstimateSmartFeeResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'feeRate', $pb.PbFieldType.OD)
    ..pPS(2, _omitFieldNames ? '' : 'errors')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EstimateSmartFeeResponse clone() => EstimateSmartFeeResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EstimateSmartFeeResponse copyWith(void Function(EstimateSmartFeeResponse) updates) => super.copyWith((message) => updates(message as EstimateSmartFeeResponse)) as EstimateSmartFeeResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EstimateSmartFeeResponse create() => EstimateSmartFeeResponse._();
  EstimateSmartFeeResponse createEmptyInstance() => create();
  static $pb.PbList<EstimateSmartFeeResponse> createRepeated() => $pb.PbList<EstimateSmartFeeResponse>();
  @$core.pragma('dart2js:noInline')
  static EstimateSmartFeeResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EstimateSmartFeeResponse>(create);
  static EstimateSmartFeeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get feeRate => $_getN(0);
  @$pb.TagNumber(1)
  set feeRate($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFeeRate() => $_has(0);
  @$pb.TagNumber(1)
  void clearFeeRate() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.String> get errors => $_getList(1);
}

class GetRawTransactionRequest extends $pb.GeneratedMessage {
  factory GetRawTransactionRequest({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  GetRawTransactionRequest._() : super();
  factory GetRawTransactionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetRawTransactionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetRawTransactionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetRawTransactionRequest clone() => GetRawTransactionRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetRawTransactionRequest copyWith(void Function(GetRawTransactionRequest) updates) => super.copyWith((message) => updates(message as GetRawTransactionRequest)) as GetRawTransactionRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRawTransactionRequest create() => GetRawTransactionRequest._();
  GetRawTransactionRequest createEmptyInstance() => create();
  static $pb.PbList<GetRawTransactionRequest> createRepeated() => $pb.PbList<GetRawTransactionRequest>();
  @$core.pragma('dart2js:noInline')
  static GetRawTransactionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetRawTransactionRequest>(create);
  static GetRawTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class RawTransaction extends $pb.GeneratedMessage {
  factory RawTransaction({
    $core.List<$core.int>? data,
    $core.String? hex,
  }) {
    final $result = create();
    if (data != null) {
      $result.data = data;
    }
    if (hex != null) {
      $result.hex = hex;
    }
    return $result;
  }
  RawTransaction._() : super();
  factory RawTransaction.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory RawTransaction.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'RawTransaction', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'data', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'hex')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  RawTransaction clone() => RawTransaction()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  RawTransaction copyWith(void Function(RawTransaction) updates) => super.copyWith((message) => updates(message as RawTransaction)) as RawTransaction;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static RawTransaction create() => RawTransaction._();
  RawTransaction createEmptyInstance() => create();
  static $pb.PbList<RawTransaction> createRepeated() => $pb.PbList<RawTransaction>();
  @$core.pragma('dart2js:noInline')
  static RawTransaction getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<RawTransaction>(create);
  static RawTransaction? _defaultInstance;

  /// Raw transaction data
  @$pb.TagNumber(1)
  $core.List<$core.int> get data => $_getN(0);
  @$pb.TagNumber(1)
  set data($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasData() => $_has(0);
  @$pb.TagNumber(1)
  void clearData() => clearField(1);

  /// Hex-encoded raw transaction data
  @$pb.TagNumber(2)
  $core.String get hex => $_getSZ(1);
  @$pb.TagNumber(2)
  set hex($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHex() => $_has(1);
  @$pb.TagNumber(2)
  void clearHex() => clearField(2);
}

class CreateRawTransactionRequest_Input extends $pb.GeneratedMessage {
  factory CreateRawTransactionRequest_Input({
    $core.String? txid,
    $core.int? vout,
    $core.int? sequence,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (vout != null) {
      $result.vout = vout;
    }
    if (sequence != null) {
      $result.sequence = sequence;
    }
    return $result;
  }
  CreateRawTransactionRequest_Input._() : super();
  factory CreateRawTransactionRequest_Input.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateRawTransactionRequest_Input.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateRawTransactionRequest.Input', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'vout', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'sequence', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateRawTransactionRequest_Input clone() => CreateRawTransactionRequest_Input()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateRawTransactionRequest_Input copyWith(void Function(CreateRawTransactionRequest_Input) updates) => super.copyWith((message) => updates(message as CreateRawTransactionRequest_Input)) as CreateRawTransactionRequest_Input;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateRawTransactionRequest_Input create() => CreateRawTransactionRequest_Input._();
  CreateRawTransactionRequest_Input createEmptyInstance() => create();
  static $pb.PbList<CreateRawTransactionRequest_Input> createRepeated() => $pb.PbList<CreateRawTransactionRequest_Input>();
  @$core.pragma('dart2js:noInline')
  static CreateRawTransactionRequest_Input getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateRawTransactionRequest_Input>(create);
  static CreateRawTransactionRequest_Input? _defaultInstance;

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
  $core.int get sequence => $_getIZ(2);
  @$pb.TagNumber(3)
  set sequence($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSequence() => $_has(2);
  @$pb.TagNumber(3)
  void clearSequence() => clearField(3);
}

/// Transaction creation messages
class CreateRawTransactionRequest extends $pb.GeneratedMessage {
  factory CreateRawTransactionRequest({
    $core.Iterable<CreateRawTransactionRequest_Input>? inputs,
    $core.Map<$core.String, $core.double>? outputs,
    $core.int? locktime,
  }) {
    final $result = create();
    if (inputs != null) {
      $result.inputs.addAll(inputs);
    }
    if (outputs != null) {
      $result.outputs.addAll(outputs);
    }
    if (locktime != null) {
      $result.locktime = locktime;
    }
    return $result;
  }
  CreateRawTransactionRequest._() : super();
  factory CreateRawTransactionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateRawTransactionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateRawTransactionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..pc<CreateRawTransactionRequest_Input>(1, _omitFieldNames ? '' : 'inputs', $pb.PbFieldType.PM, subBuilder: CreateRawTransactionRequest_Input.create)
    ..m<$core.String, $core.double>(2, _omitFieldNames ? '' : 'outputs', entryClassName: 'CreateRawTransactionRequest.OutputsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OD, packageName: const $pb.PackageName('bitcoind.v1'))
    ..a<$core.int>(3, _omitFieldNames ? '' : 'locktime', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateRawTransactionRequest clone() => CreateRawTransactionRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateRawTransactionRequest copyWith(void Function(CreateRawTransactionRequest) updates) => super.copyWith((message) => updates(message as CreateRawTransactionRequest)) as CreateRawTransactionRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateRawTransactionRequest create() => CreateRawTransactionRequest._();
  CreateRawTransactionRequest createEmptyInstance() => create();
  static $pb.PbList<CreateRawTransactionRequest> createRepeated() => $pb.PbList<CreateRawTransactionRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateRawTransactionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateRawTransactionRequest>(create);
  static CreateRawTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<CreateRawTransactionRequest_Input> get inputs => $_getList(0);

  @$pb.TagNumber(2)
  $core.Map<$core.String, $core.double> get outputs => $_getMap(1);

  @$pb.TagNumber(3)
  $core.int get locktime => $_getIZ(2);
  @$pb.TagNumber(3)
  set locktime($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLocktime() => $_has(2);
  @$pb.TagNumber(3)
  void clearLocktime() => clearField(3);
}

class CreateRawTransactionResponse extends $pb.GeneratedMessage {
  factory CreateRawTransactionResponse({
    RawTransaction? tx,
  }) {
    final $result = create();
    if (tx != null) {
      $result.tx = tx;
    }
    return $result;
  }
  CreateRawTransactionResponse._() : super();
  factory CreateRawTransactionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateRawTransactionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateRawTransactionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOM<RawTransaction>(1, _omitFieldNames ? '' : 'tx', subBuilder: RawTransaction.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateRawTransactionResponse clone() => CreateRawTransactionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateRawTransactionResponse copyWith(void Function(CreateRawTransactionResponse) updates) => super.copyWith((message) => updates(message as CreateRawTransactionResponse)) as CreateRawTransactionResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateRawTransactionResponse create() => CreateRawTransactionResponse._();
  CreateRawTransactionResponse createEmptyInstance() => create();
  static $pb.PbList<CreateRawTransactionResponse> createRepeated() => $pb.PbList<CreateRawTransactionResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateRawTransactionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateRawTransactionResponse>(create);
  static CreateRawTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  RawTransaction get tx => $_getN(0);
  @$pb.TagNumber(1)
  set tx(RawTransaction v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasTx() => $_has(0);
  @$pb.TagNumber(1)
  void clearTx() => clearField(1);
  @$pb.TagNumber(1)
  RawTransaction ensureTx() => $_ensure(0);
}

class ScriptSig extends $pb.GeneratedMessage {
  factory ScriptSig({
    $core.String? asm,
    $core.String? hex,
  }) {
    final $result = create();
    if (asm != null) {
      $result.asm = asm;
    }
    if (hex != null) {
      $result.hex = hex;
    }
    return $result;
  }
  ScriptSig._() : super();
  factory ScriptSig.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ScriptSig.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ScriptSig', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'asm')
    ..aOS(2, _omitFieldNames ? '' : 'hex')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ScriptSig clone() => ScriptSig()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ScriptSig copyWith(void Function(ScriptSig) updates) => super.copyWith((message) => updates(message as ScriptSig)) as ScriptSig;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScriptSig create() => ScriptSig._();
  ScriptSig createEmptyInstance() => create();
  static $pb.PbList<ScriptSig> createRepeated() => $pb.PbList<ScriptSig>();
  @$core.pragma('dart2js:noInline')
  static ScriptSig getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ScriptSig>(create);
  static ScriptSig? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get asm => $_getSZ(0);
  @$pb.TagNumber(1)
  set asm($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAsm() => $_has(0);
  @$pb.TagNumber(1)
  void clearAsm() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get hex => $_getSZ(1);
  @$pb.TagNumber(2)
  set hex($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHex() => $_has(1);
  @$pb.TagNumber(2)
  void clearHex() => clearField(2);
}

class Input extends $pb.GeneratedMessage {
  factory Input({
    $core.String? txid,
    $core.int? vout,
    $core.String? coinbase,
    ScriptSig? scriptSig,
    $core.int? sequence,
    $core.Iterable<$core.String>? witness,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (vout != null) {
      $result.vout = vout;
    }
    if (coinbase != null) {
      $result.coinbase = coinbase;
    }
    if (scriptSig != null) {
      $result.scriptSig = scriptSig;
    }
    if (sequence != null) {
      $result.sequence = sequence;
    }
    if (witness != null) {
      $result.witness.addAll(witness);
    }
    return $result;
  }
  Input._() : super();
  factory Input.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Input.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Input', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'vout', $pb.PbFieldType.OU3)
    ..aOS(3, _omitFieldNames ? '' : 'coinbase')
    ..aOM<ScriptSig>(4, _omitFieldNames ? '' : 'scriptSig', subBuilder: ScriptSig.create)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'sequence', $pb.PbFieldType.OU3)
    ..pPS(6, _omitFieldNames ? '' : 'witness')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Input clone() => Input()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Input copyWith(void Function(Input) updates) => super.copyWith((message) => updates(message as Input)) as Input;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Input create() => Input._();
  Input createEmptyInstance() => create();
  static $pb.PbList<Input> createRepeated() => $pb.PbList<Input>();
  @$core.pragma('dart2js:noInline')
  static Input getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Input>(create);
  static Input? _defaultInstance;

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
  $core.String get coinbase => $_getSZ(2);
  @$pb.TagNumber(3)
  set coinbase($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasCoinbase() => $_has(2);
  @$pb.TagNumber(3)
  void clearCoinbase() => clearField(3);

  @$pb.TagNumber(4)
  ScriptSig get scriptSig => $_getN(3);
  @$pb.TagNumber(4)
  set scriptSig(ScriptSig v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasScriptSig() => $_has(3);
  @$pb.TagNumber(4)
  void clearScriptSig() => clearField(4);
  @$pb.TagNumber(4)
  ScriptSig ensureScriptSig() => $_ensure(3);

  @$pb.TagNumber(5)
  $core.int get sequence => $_getIZ(4);
  @$pb.TagNumber(5)
  set sequence($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasSequence() => $_has(4);
  @$pb.TagNumber(5)
  void clearSequence() => clearField(5);

  @$pb.TagNumber(6)
  $core.List<$core.String> get witness => $_getList(5);
}

class ScriptPubKey extends $pb.GeneratedMessage {
  factory ScriptPubKey({
    $core.String? type,
    $core.String? address,
  }) {
    final $result = create();
    if (type != null) {
      $result.type = type;
    }
    if (address != null) {
      $result.address = address;
    }
    return $result;
  }
  ScriptPubKey._() : super();
  factory ScriptPubKey.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ScriptPubKey.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ScriptPubKey', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'type')
    ..aOS(2, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ScriptPubKey clone() => ScriptPubKey()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ScriptPubKey copyWith(void Function(ScriptPubKey) updates) => super.copyWith((message) => updates(message as ScriptPubKey)) as ScriptPubKey;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ScriptPubKey create() => ScriptPubKey._();
  ScriptPubKey createEmptyInstance() => create();
  static $pb.PbList<ScriptPubKey> createRepeated() => $pb.PbList<ScriptPubKey>();
  @$core.pragma('dart2js:noInline')
  static ScriptPubKey getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ScriptPubKey>(create);
  static ScriptPubKey? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get type => $_getSZ(0);
  @$pb.TagNumber(1)
  set type($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get address => $_getSZ(1);
  @$pb.TagNumber(2)
  set address($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearAddress() => clearField(2);
}

class Output extends $pb.GeneratedMessage {
  factory Output({
    $core.double? amount,
    $core.int? vout,
    ScriptPubKey? scriptPubKey,
    ScriptSig? scriptSig,
  }) {
    final $result = create();
    if (amount != null) {
      $result.amount = amount;
    }
    if (vout != null) {
      $result.vout = vout;
    }
    if (scriptPubKey != null) {
      $result.scriptPubKey = scriptPubKey;
    }
    if (scriptSig != null) {
      $result.scriptSig = scriptSig;
    }
    return $result;
  }
  Output._() : super();
  factory Output.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Output.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Output', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'amount', $pb.PbFieldType.OD)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'vout', $pb.PbFieldType.OU3)
    ..aOM<ScriptPubKey>(3, _omitFieldNames ? '' : 'scriptPubKey', subBuilder: ScriptPubKey.create)
    ..aOM<ScriptSig>(4, _omitFieldNames ? '' : 'scriptSig', subBuilder: ScriptSig.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Output clone() => Output()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Output copyWith(void Function(Output) updates) => super.copyWith((message) => updates(message as Output)) as Output;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Output create() => Output._();
  Output createEmptyInstance() => create();
  static $pb.PbList<Output> createRepeated() => $pb.PbList<Output>();
  @$core.pragma('dart2js:noInline')
  static Output getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Output>(create);
  static Output? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get amount => $_getN(0);
  @$pb.TagNumber(1)
  set amount($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAmount() => $_has(0);
  @$pb.TagNumber(1)
  void clearAmount() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get vout => $_getIZ(1);
  @$pb.TagNumber(2)
  set vout($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearVout() => clearField(2);

  @$pb.TagNumber(3)
  ScriptPubKey get scriptPubKey => $_getN(2);
  @$pb.TagNumber(3)
  set scriptPubKey(ScriptPubKey v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasScriptPubKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearScriptPubKey() => clearField(3);
  @$pb.TagNumber(3)
  ScriptPubKey ensureScriptPubKey() => $_ensure(2);

  @$pb.TagNumber(4)
  ScriptSig get scriptSig => $_getN(3);
  @$pb.TagNumber(4)
  set scriptSig(ScriptSig v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasScriptSig() => $_has(3);
  @$pb.TagNumber(4)
  void clearScriptSig() => clearField(4);
  @$pb.TagNumber(4)
  ScriptSig ensureScriptSig() => $_ensure(3);
}

class GetRawTransactionResponse extends $pb.GeneratedMessage {
  factory GetRawTransactionResponse({
    RawTransaction? tx,
    $core.Iterable<Input>? inputs,
    $core.Iterable<Output>? outputs,
    $core.String? blockhash,
    $core.int? confirmations,
    $fixnum.Int64? time,
    $fixnum.Int64? blocktime,
    $core.String? txid,
    $core.String? hash,
    $core.int? size,
    $core.int? vsize,
    $core.int? weight,
    $core.int? version,
    $core.int? locktime,
  }) {
    final $result = create();
    if (tx != null) {
      $result.tx = tx;
    }
    if (inputs != null) {
      $result.inputs.addAll(inputs);
    }
    if (outputs != null) {
      $result.outputs.addAll(outputs);
    }
    if (blockhash != null) {
      $result.blockhash = blockhash;
    }
    if (confirmations != null) {
      $result.confirmations = confirmations;
    }
    if (time != null) {
      $result.time = time;
    }
    if (blocktime != null) {
      $result.blocktime = blocktime;
    }
    if (txid != null) {
      $result.txid = txid;
    }
    if (hash != null) {
      $result.hash = hash;
    }
    if (size != null) {
      $result.size = size;
    }
    if (vsize != null) {
      $result.vsize = vsize;
    }
    if (weight != null) {
      $result.weight = weight;
    }
    if (version != null) {
      $result.version = version;
    }
    if (locktime != null) {
      $result.locktime = locktime;
    }
    return $result;
  }
  GetRawTransactionResponse._() : super();
  factory GetRawTransactionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetRawTransactionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetRawTransactionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOM<RawTransaction>(1, _omitFieldNames ? '' : 'tx', subBuilder: RawTransaction.create)
    ..pc<Input>(2, _omitFieldNames ? '' : 'inputs', $pb.PbFieldType.PM, subBuilder: Input.create)
    ..pc<Output>(3, _omitFieldNames ? '' : 'outputs', $pb.PbFieldType.PM, subBuilder: Output.create)
    ..aOS(4, _omitFieldNames ? '' : 'blockhash')
    ..a<$core.int>(5, _omitFieldNames ? '' : 'confirmations', $pb.PbFieldType.OU3)
    ..aInt64(6, _omitFieldNames ? '' : 'time')
    ..aInt64(7, _omitFieldNames ? '' : 'blocktime')
    ..aOS(8, _omitFieldNames ? '' : 'txid')
    ..aOS(9, _omitFieldNames ? '' : 'hash')
    ..a<$core.int>(10, _omitFieldNames ? '' : 'size', $pb.PbFieldType.O3)
    ..a<$core.int>(11, _omitFieldNames ? '' : 'vsize', $pb.PbFieldType.O3)
    ..a<$core.int>(12, _omitFieldNames ? '' : 'weight', $pb.PbFieldType.O3)
    ..a<$core.int>(13, _omitFieldNames ? '' : 'version', $pb.PbFieldType.OU3)
    ..a<$core.int>(14, _omitFieldNames ? '' : 'locktime', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetRawTransactionResponse clone() => GetRawTransactionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetRawTransactionResponse copyWith(void Function(GetRawTransactionResponse) updates) => super.copyWith((message) => updates(message as GetRawTransactionResponse)) as GetRawTransactionResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetRawTransactionResponse create() => GetRawTransactionResponse._();
  GetRawTransactionResponse createEmptyInstance() => create();
  static $pb.PbList<GetRawTransactionResponse> createRepeated() => $pb.PbList<GetRawTransactionResponse>();
  @$core.pragma('dart2js:noInline')
  static GetRawTransactionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetRawTransactionResponse>(create);
  static GetRawTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  RawTransaction get tx => $_getN(0);
  @$pb.TagNumber(1)
  set tx(RawTransaction v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasTx() => $_has(0);
  @$pb.TagNumber(1)
  void clearTx() => clearField(1);
  @$pb.TagNumber(1)
  RawTransaction ensureTx() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.List<Input> get inputs => $_getList(1);

  @$pb.TagNumber(3)
  $core.List<Output> get outputs => $_getList(2);

  @$pb.TagNumber(4)
  $core.String get blockhash => $_getSZ(3);
  @$pb.TagNumber(4)
  set blockhash($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasBlockhash() => $_has(3);
  @$pb.TagNumber(4)
  void clearBlockhash() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get confirmations => $_getIZ(4);
  @$pb.TagNumber(5)
  set confirmations($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasConfirmations() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfirmations() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get time => $_getI64(5);
  @$pb.TagNumber(6)
  set time($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTime() => $_has(5);
  @$pb.TagNumber(6)
  void clearTime() => clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get blocktime => $_getI64(6);
  @$pb.TagNumber(7)
  set blocktime($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasBlocktime() => $_has(6);
  @$pb.TagNumber(7)
  void clearBlocktime() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get txid => $_getSZ(7);
  @$pb.TagNumber(8)
  set txid($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasTxid() => $_has(7);
  @$pb.TagNumber(8)
  void clearTxid() => clearField(8);

  @$pb.TagNumber(9)
  $core.String get hash => $_getSZ(8);
  @$pb.TagNumber(9)
  set hash($core.String v) { $_setString(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasHash() => $_has(8);
  @$pb.TagNumber(9)
  void clearHash() => clearField(9);

  @$pb.TagNumber(10)
  $core.int get size => $_getIZ(9);
  @$pb.TagNumber(10)
  set size($core.int v) { $_setSignedInt32(9, v); }
  @$pb.TagNumber(10)
  $core.bool hasSize() => $_has(9);
  @$pb.TagNumber(10)
  void clearSize() => clearField(10);

  @$pb.TagNumber(11)
  $core.int get vsize => $_getIZ(10);
  @$pb.TagNumber(11)
  set vsize($core.int v) { $_setSignedInt32(10, v); }
  @$pb.TagNumber(11)
  $core.bool hasVsize() => $_has(10);
  @$pb.TagNumber(11)
  void clearVsize() => clearField(11);

  @$pb.TagNumber(12)
  $core.int get weight => $_getIZ(11);
  @$pb.TagNumber(12)
  set weight($core.int v) { $_setSignedInt32(11, v); }
  @$pb.TagNumber(12)
  $core.bool hasWeight() => $_has(11);
  @$pb.TagNumber(12)
  void clearWeight() => clearField(12);

  @$pb.TagNumber(13)
  $core.int get version => $_getIZ(12);
  @$pb.TagNumber(13)
  set version($core.int v) { $_setUnsignedInt32(12, v); }
  @$pb.TagNumber(13)
  $core.bool hasVersion() => $_has(12);
  @$pb.TagNumber(13)
  void clearVersion() => clearField(13);

  @$pb.TagNumber(14)
  $core.int get locktime => $_getIZ(13);
  @$pb.TagNumber(14)
  set locktime($core.int v) { $_setUnsignedInt32(13, v); }
  @$pb.TagNumber(14)
  $core.bool hasLocktime() => $_has(13);
  @$pb.TagNumber(14)
  void clearLocktime() => clearField(14);
}

enum GetBlockRequest_Identifier {
  hash, 
  height, 
  notSet
}

class GetBlockRequest extends $pb.GeneratedMessage {
  factory GetBlockRequest({
    $core.String? hash,
    $core.int? height,
  }) {
    final $result = create();
    if (hash != null) {
      $result.hash = hash;
    }
    if (height != null) {
      $result.height = height;
    }
    return $result;
  }
  GetBlockRequest._() : super();
  factory GetBlockRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBlockRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, GetBlockRequest_Identifier> _GetBlockRequest_IdentifierByTag = {
    1 : GetBlockRequest_Identifier.hash,
    2 : GetBlockRequest_Identifier.height,
    0 : GetBlockRequest_Identifier.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOS(1, _omitFieldNames ? '' : 'hash')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'height', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBlockRequest clone() => GetBlockRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBlockRequest copyWith(void Function(GetBlockRequest) updates) => super.copyWith((message) => updates(message as GetBlockRequest)) as GetBlockRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBlockRequest create() => GetBlockRequest._();
  GetBlockRequest createEmptyInstance() => create();
  static $pb.PbList<GetBlockRequest> createRepeated() => $pb.PbList<GetBlockRequest>();
  @$core.pragma('dart2js:noInline')
  static GetBlockRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBlockRequest>(create);
  static GetBlockRequest? _defaultInstance;

  GetBlockRequest_Identifier whichIdentifier() => _GetBlockRequest_IdentifierByTag[$_whichOneof(0)]!;
  void clearIdentifier() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get hash => $_getSZ(0);
  @$pb.TagNumber(1)
  set hash($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearHash() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get height => $_getIZ(1);
  @$pb.TagNumber(2)
  set height($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeight() => clearField(2);
}

class GetBlockResponse extends $pb.GeneratedMessage {
  factory GetBlockResponse({
    Block? block,
  }) {
    final $result = create();
    if (block != null) {
      $result.block = block;
    }
    return $result;
  }
  GetBlockResponse._() : super();
  factory GetBlockResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetBlockResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetBlockResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOM<Block>(1, _omitFieldNames ? '' : 'block', subBuilder: Block.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetBlockResponse clone() => GetBlockResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetBlockResponse copyWith(void Function(GetBlockResponse) updates) => super.copyWith((message) => updates(message as GetBlockResponse)) as GetBlockResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetBlockResponse create() => GetBlockResponse._();
  GetBlockResponse createEmptyInstance() => create();
  static $pb.PbList<GetBlockResponse> createRepeated() => $pb.PbList<GetBlockResponse>();
  @$core.pragma('dart2js:noInline')
  static GetBlockResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetBlockResponse>(create);
  static GetBlockResponse? _defaultInstance;

  @$pb.TagNumber(1)
  Block get block => $_getN(0);
  @$pb.TagNumber(1)
  set block(Block v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasBlock() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlock() => clearField(1);
  @$pb.TagNumber(1)
  Block ensureBlock() => $_ensure(0);
}

class CreateWalletRequest extends $pb.GeneratedMessage {
  factory CreateWalletRequest({
    $core.String? name,
    $core.bool? disablePrivateKeys,
    $core.bool? blank,
    $core.String? passphrase,
    $core.bool? avoidReuse,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (disablePrivateKeys != null) {
      $result.disablePrivateKeys = disablePrivateKeys;
    }
    if (blank != null) {
      $result.blank = blank;
    }
    if (passphrase != null) {
      $result.passphrase = passphrase;
    }
    if (avoidReuse != null) {
      $result.avoidReuse = avoidReuse;
    }
    return $result;
  }
  CreateWalletRequest._() : super();
  factory CreateWalletRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateWalletRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateWalletRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOB(2, _omitFieldNames ? '' : 'disablePrivateKeys')
    ..aOB(3, _omitFieldNames ? '' : 'blank')
    ..aOS(4, _omitFieldNames ? '' : 'passphrase')
    ..aOB(5, _omitFieldNames ? '' : 'avoidReuse')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateWalletRequest clone() => CreateWalletRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateWalletRequest copyWith(void Function(CreateWalletRequest) updates) => super.copyWith((message) => updates(message as CreateWalletRequest)) as CreateWalletRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateWalletRequest create() => CreateWalletRequest._();
  CreateWalletRequest createEmptyInstance() => create();
  static $pb.PbList<CreateWalletRequest> createRepeated() => $pb.PbList<CreateWalletRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateWalletRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateWalletRequest>(create);
  static CreateWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get disablePrivateKeys => $_getBF(1);
  @$pb.TagNumber(2)
  set disablePrivateKeys($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDisablePrivateKeys() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisablePrivateKeys() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get blank => $_getBF(2);
  @$pb.TagNumber(3)
  set blank($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasBlank() => $_has(2);
  @$pb.TagNumber(3)
  void clearBlank() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get passphrase => $_getSZ(3);
  @$pb.TagNumber(4)
  set passphrase($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasPassphrase() => $_has(3);
  @$pb.TagNumber(4)
  void clearPassphrase() => clearField(4);

  @$pb.TagNumber(5)
  $core.bool get avoidReuse => $_getBF(4);
  @$pb.TagNumber(5)
  set avoidReuse($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasAvoidReuse() => $_has(4);
  @$pb.TagNumber(5)
  void clearAvoidReuse() => clearField(5);
}

class CreateWalletResponse extends $pb.GeneratedMessage {
  factory CreateWalletResponse({
    $core.String? name,
    $core.String? warning,
  }) {
    final $result = create();
    if (name != null) {
      $result.name = name;
    }
    if (warning != null) {
      $result.warning = warning;
    }
    return $result;
  }
  CreateWalletResponse._() : super();
  factory CreateWalletResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateWalletResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateWalletResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'warning')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateWalletResponse clone() => CreateWalletResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateWalletResponse copyWith(void Function(CreateWalletResponse) updates) => super.copyWith((message) => updates(message as CreateWalletResponse)) as CreateWalletResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateWalletResponse create() => CreateWalletResponse._();
  CreateWalletResponse createEmptyInstance() => create();
  static $pb.PbList<CreateWalletResponse> createRepeated() => $pb.PbList<CreateWalletResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateWalletResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateWalletResponse>(create);
  static CreateWalletResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get warning => $_getSZ(1);
  @$pb.TagNumber(2)
  set warning($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWarning() => $_has(1);
  @$pb.TagNumber(2)
  void clearWarning() => clearField(2);
}

class BackupWalletRequest extends $pb.GeneratedMessage {
  factory BackupWalletRequest({
    $core.String? destination,
    $core.String? wallet,
  }) {
    final $result = create();
    if (destination != null) {
      $result.destination = destination;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  BackupWalletRequest._() : super();
  factory BackupWalletRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BackupWalletRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BackupWalletRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'destination')
    ..aOS(2, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BackupWalletRequest clone() => BackupWalletRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BackupWalletRequest copyWith(void Function(BackupWalletRequest) updates) => super.copyWith((message) => updates(message as BackupWalletRequest)) as BackupWalletRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BackupWalletRequest create() => BackupWalletRequest._();
  BackupWalletRequest createEmptyInstance() => create();
  static $pb.PbList<BackupWalletRequest> createRepeated() => $pb.PbList<BackupWalletRequest>();
  @$core.pragma('dart2js:noInline')
  static BackupWalletRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BackupWalletRequest>(create);
  static BackupWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get destination => $_getSZ(0);
  @$pb.TagNumber(1)
  set destination($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDestination() => $_has(0);
  @$pb.TagNumber(1)
  void clearDestination() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get wallet => $_getSZ(1);
  @$pb.TagNumber(2)
  set wallet($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWallet() => $_has(1);
  @$pb.TagNumber(2)
  void clearWallet() => clearField(2);
}

class BackupWalletResponse extends $pb.GeneratedMessage {
  factory BackupWalletResponse() => create();
  BackupWalletResponse._() : super();
  factory BackupWalletResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BackupWalletResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BackupWalletResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BackupWalletResponse clone() => BackupWalletResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BackupWalletResponse copyWith(void Function(BackupWalletResponse) updates) => super.copyWith((message) => updates(message as BackupWalletResponse)) as BackupWalletResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BackupWalletResponse create() => BackupWalletResponse._();
  BackupWalletResponse createEmptyInstance() => create();
  static $pb.PbList<BackupWalletResponse> createRepeated() => $pb.PbList<BackupWalletResponse>();
  @$core.pragma('dart2js:noInline')
  static BackupWalletResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BackupWalletResponse>(create);
  static BackupWalletResponse? _defaultInstance;
}

class DumpWalletRequest extends $pb.GeneratedMessage {
  factory DumpWalletRequest({
    $core.String? filename,
    $core.String? wallet,
  }) {
    final $result = create();
    if (filename != null) {
      $result.filename = filename;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  DumpWalletRequest._() : super();
  factory DumpWalletRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DumpWalletRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DumpWalletRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'filename')
    ..aOS(2, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DumpWalletRequest clone() => DumpWalletRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DumpWalletRequest copyWith(void Function(DumpWalletRequest) updates) => super.copyWith((message) => updates(message as DumpWalletRequest)) as DumpWalletRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DumpWalletRequest create() => DumpWalletRequest._();
  DumpWalletRequest createEmptyInstance() => create();
  static $pb.PbList<DumpWalletRequest> createRepeated() => $pb.PbList<DumpWalletRequest>();
  @$core.pragma('dart2js:noInline')
  static DumpWalletRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DumpWalletRequest>(create);
  static DumpWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get filename => $_getSZ(0);
  @$pb.TagNumber(1)
  set filename($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFilename() => $_has(0);
  @$pb.TagNumber(1)
  void clearFilename() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get wallet => $_getSZ(1);
  @$pb.TagNumber(2)
  set wallet($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWallet() => $_has(1);
  @$pb.TagNumber(2)
  void clearWallet() => clearField(2);
}

class DumpWalletResponse extends $pb.GeneratedMessage {
  factory DumpWalletResponse({
    $core.String? filename,
  }) {
    final $result = create();
    if (filename != null) {
      $result.filename = filename;
    }
    return $result;
  }
  DumpWalletResponse._() : super();
  factory DumpWalletResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DumpWalletResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DumpWalletResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'filename')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DumpWalletResponse clone() => DumpWalletResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DumpWalletResponse copyWith(void Function(DumpWalletResponse) updates) => super.copyWith((message) => updates(message as DumpWalletResponse)) as DumpWalletResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DumpWalletResponse create() => DumpWalletResponse._();
  DumpWalletResponse createEmptyInstance() => create();
  static $pb.PbList<DumpWalletResponse> createRepeated() => $pb.PbList<DumpWalletResponse>();
  @$core.pragma('dart2js:noInline')
  static DumpWalletResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DumpWalletResponse>(create);
  static DumpWalletResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get filename => $_getSZ(0);
  @$pb.TagNumber(1)
  set filename($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFilename() => $_has(0);
  @$pb.TagNumber(1)
  void clearFilename() => clearField(1);
}

class ImportWalletRequest extends $pb.GeneratedMessage {
  factory ImportWalletRequest({
    $core.String? filename,
    $core.String? wallet,
  }) {
    final $result = create();
    if (filename != null) {
      $result.filename = filename;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  ImportWalletRequest._() : super();
  factory ImportWalletRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ImportWalletRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportWalletRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'filename')
    ..aOS(2, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ImportWalletRequest clone() => ImportWalletRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ImportWalletRequest copyWith(void Function(ImportWalletRequest) updates) => super.copyWith((message) => updates(message as ImportWalletRequest)) as ImportWalletRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportWalletRequest create() => ImportWalletRequest._();
  ImportWalletRequest createEmptyInstance() => create();
  static $pb.PbList<ImportWalletRequest> createRepeated() => $pb.PbList<ImportWalletRequest>();
  @$core.pragma('dart2js:noInline')
  static ImportWalletRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportWalletRequest>(create);
  static ImportWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get filename => $_getSZ(0);
  @$pb.TagNumber(1)
  set filename($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFilename() => $_has(0);
  @$pb.TagNumber(1)
  void clearFilename() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get wallet => $_getSZ(1);
  @$pb.TagNumber(2)
  set wallet($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWallet() => $_has(1);
  @$pb.TagNumber(2)
  void clearWallet() => clearField(2);
}

class ImportWalletResponse extends $pb.GeneratedMessage {
  factory ImportWalletResponse() => create();
  ImportWalletResponse._() : super();
  factory ImportWalletResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ImportWalletResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportWalletResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ImportWalletResponse clone() => ImportWalletResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ImportWalletResponse copyWith(void Function(ImportWalletResponse) updates) => super.copyWith((message) => updates(message as ImportWalletResponse)) as ImportWalletResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportWalletResponse create() => ImportWalletResponse._();
  ImportWalletResponse createEmptyInstance() => create();
  static $pb.PbList<ImportWalletResponse> createRepeated() => $pb.PbList<ImportWalletResponse>();
  @$core.pragma('dart2js:noInline')
  static ImportWalletResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportWalletResponse>(create);
  static ImportWalletResponse? _defaultInstance;
}

class UnloadWalletRequest extends $pb.GeneratedMessage {
  factory UnloadWalletRequest({
    $core.String? walletName,
    $core.String? wallet,
  }) {
    final $result = create();
    if (walletName != null) {
      $result.walletName = walletName;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  UnloadWalletRequest._() : super();
  factory UnloadWalletRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UnloadWalletRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnloadWalletRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'walletName')
    ..aOS(2, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UnloadWalletRequest clone() => UnloadWalletRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UnloadWalletRequest copyWith(void Function(UnloadWalletRequest) updates) => super.copyWith((message) => updates(message as UnloadWalletRequest)) as UnloadWalletRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnloadWalletRequest create() => UnloadWalletRequest._();
  UnloadWalletRequest createEmptyInstance() => create();
  static $pb.PbList<UnloadWalletRequest> createRepeated() => $pb.PbList<UnloadWalletRequest>();
  @$core.pragma('dart2js:noInline')
  static UnloadWalletRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnloadWalletRequest>(create);
  static UnloadWalletRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get walletName => $_getSZ(0);
  @$pb.TagNumber(1)
  set walletName($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWalletName() => $_has(0);
  @$pb.TagNumber(1)
  void clearWalletName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get wallet => $_getSZ(1);
  @$pb.TagNumber(2)
  set wallet($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWallet() => $_has(1);
  @$pb.TagNumber(2)
  void clearWallet() => clearField(2);
}

class UnloadWalletResponse extends $pb.GeneratedMessage {
  factory UnloadWalletResponse() => create();
  UnloadWalletResponse._() : super();
  factory UnloadWalletResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UnloadWalletResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UnloadWalletResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UnloadWalletResponse clone() => UnloadWalletResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UnloadWalletResponse copyWith(void Function(UnloadWalletResponse) updates) => super.copyWith((message) => updates(message as UnloadWalletResponse)) as UnloadWalletResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UnloadWalletResponse create() => UnloadWalletResponse._();
  UnloadWalletResponse createEmptyInstance() => create();
  static $pb.PbList<UnloadWalletResponse> createRepeated() => $pb.PbList<UnloadWalletResponse>();
  @$core.pragma('dart2js:noInline')
  static UnloadWalletResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UnloadWalletResponse>(create);
  static UnloadWalletResponse? _defaultInstance;
}

class DumpPrivKeyRequest extends $pb.GeneratedMessage {
  factory DumpPrivKeyRequest({
    $core.String? address,
    $core.String? wallet,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  DumpPrivKeyRequest._() : super();
  factory DumpPrivKeyRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DumpPrivKeyRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DumpPrivKeyRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DumpPrivKeyRequest clone() => DumpPrivKeyRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DumpPrivKeyRequest copyWith(void Function(DumpPrivKeyRequest) updates) => super.copyWith((message) => updates(message as DumpPrivKeyRequest)) as DumpPrivKeyRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DumpPrivKeyRequest create() => DumpPrivKeyRequest._();
  DumpPrivKeyRequest createEmptyInstance() => create();
  static $pb.PbList<DumpPrivKeyRequest> createRepeated() => $pb.PbList<DumpPrivKeyRequest>();
  @$core.pragma('dart2js:noInline')
  static DumpPrivKeyRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DumpPrivKeyRequest>(create);
  static DumpPrivKeyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get wallet => $_getSZ(1);
  @$pb.TagNumber(2)
  set wallet($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWallet() => $_has(1);
  @$pb.TagNumber(2)
  void clearWallet() => clearField(2);
}

class DumpPrivKeyResponse extends $pb.GeneratedMessage {
  factory DumpPrivKeyResponse({
    $core.String? privateKey,
  }) {
    final $result = create();
    if (privateKey != null) {
      $result.privateKey = privateKey;
    }
    return $result;
  }
  DumpPrivKeyResponse._() : super();
  factory DumpPrivKeyResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DumpPrivKeyResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DumpPrivKeyResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'privateKey')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DumpPrivKeyResponse clone() => DumpPrivKeyResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DumpPrivKeyResponse copyWith(void Function(DumpPrivKeyResponse) updates) => super.copyWith((message) => updates(message as DumpPrivKeyResponse)) as DumpPrivKeyResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DumpPrivKeyResponse create() => DumpPrivKeyResponse._();
  DumpPrivKeyResponse createEmptyInstance() => create();
  static $pb.PbList<DumpPrivKeyResponse> createRepeated() => $pb.PbList<DumpPrivKeyResponse>();
  @$core.pragma('dart2js:noInline')
  static DumpPrivKeyResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DumpPrivKeyResponse>(create);
  static DumpPrivKeyResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get privateKey => $_getSZ(0);
  @$pb.TagNumber(1)
  set privateKey($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPrivateKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrivateKey() => clearField(1);
}

class ImportPrivKeyRequest extends $pb.GeneratedMessage {
  factory ImportPrivKeyRequest({
    $core.String? privateKey,
    $core.String? label,
    $core.bool? rescan,
    $core.String? wallet,
  }) {
    final $result = create();
    if (privateKey != null) {
      $result.privateKey = privateKey;
    }
    if (label != null) {
      $result.label = label;
    }
    if (rescan != null) {
      $result.rescan = rescan;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  ImportPrivKeyRequest._() : super();
  factory ImportPrivKeyRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ImportPrivKeyRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportPrivKeyRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'privateKey')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..aOB(3, _omitFieldNames ? '' : 'rescan')
    ..aOS(4, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ImportPrivKeyRequest clone() => ImportPrivKeyRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ImportPrivKeyRequest copyWith(void Function(ImportPrivKeyRequest) updates) => super.copyWith((message) => updates(message as ImportPrivKeyRequest)) as ImportPrivKeyRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportPrivKeyRequest create() => ImportPrivKeyRequest._();
  ImportPrivKeyRequest createEmptyInstance() => create();
  static $pb.PbList<ImportPrivKeyRequest> createRepeated() => $pb.PbList<ImportPrivKeyRequest>();
  @$core.pragma('dart2js:noInline')
  static ImportPrivKeyRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportPrivKeyRequest>(create);
  static ImportPrivKeyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get privateKey => $_getSZ(0);
  @$pb.TagNumber(1)
  set privateKey($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPrivateKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearPrivateKey() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get rescan => $_getBF(2);
  @$pb.TagNumber(3)
  set rescan($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRescan() => $_has(2);
  @$pb.TagNumber(3)
  void clearRescan() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get wallet => $_getSZ(3);
  @$pb.TagNumber(4)
  set wallet($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasWallet() => $_has(3);
  @$pb.TagNumber(4)
  void clearWallet() => clearField(4);
}

class ImportPrivKeyResponse extends $pb.GeneratedMessage {
  factory ImportPrivKeyResponse() => create();
  ImportPrivKeyResponse._() : super();
  factory ImportPrivKeyResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ImportPrivKeyResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportPrivKeyResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ImportPrivKeyResponse clone() => ImportPrivKeyResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ImportPrivKeyResponse copyWith(void Function(ImportPrivKeyResponse) updates) => super.copyWith((message) => updates(message as ImportPrivKeyResponse)) as ImportPrivKeyResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportPrivKeyResponse create() => ImportPrivKeyResponse._();
  ImportPrivKeyResponse createEmptyInstance() => create();
  static $pb.PbList<ImportPrivKeyResponse> createRepeated() => $pb.PbList<ImportPrivKeyResponse>();
  @$core.pragma('dart2js:noInline')
  static ImportPrivKeyResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportPrivKeyResponse>(create);
  static ImportPrivKeyResponse? _defaultInstance;
}

class ImportAddressRequest extends $pb.GeneratedMessage {
  factory ImportAddressRequest({
    $core.String? address,
    $core.String? label,
    $core.bool? rescan,
    $core.String? wallet,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (label != null) {
      $result.label = label;
    }
    if (rescan != null) {
      $result.rescan = rescan;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  ImportAddressRequest._() : super();
  factory ImportAddressRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ImportAddressRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportAddressRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'label')
    ..aOB(3, _omitFieldNames ? '' : 'rescan')
    ..aOS(4, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ImportAddressRequest clone() => ImportAddressRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ImportAddressRequest copyWith(void Function(ImportAddressRequest) updates) => super.copyWith((message) => updates(message as ImportAddressRequest)) as ImportAddressRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportAddressRequest create() => ImportAddressRequest._();
  ImportAddressRequest createEmptyInstance() => create();
  static $pb.PbList<ImportAddressRequest> createRepeated() => $pb.PbList<ImportAddressRequest>();
  @$core.pragma('dart2js:noInline')
  static ImportAddressRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportAddressRequest>(create);
  static ImportAddressRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get label => $_getSZ(1);
  @$pb.TagNumber(2)
  set label($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasLabel() => $_has(1);
  @$pb.TagNumber(2)
  void clearLabel() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get rescan => $_getBF(2);
  @$pb.TagNumber(3)
  set rescan($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRescan() => $_has(2);
  @$pb.TagNumber(3)
  void clearRescan() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get wallet => $_getSZ(3);
  @$pb.TagNumber(4)
  set wallet($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasWallet() => $_has(3);
  @$pb.TagNumber(4)
  void clearWallet() => clearField(4);
}

class ImportAddressResponse extends $pb.GeneratedMessage {
  factory ImportAddressResponse() => create();
  ImportAddressResponse._() : super();
  factory ImportAddressResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ImportAddressResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportAddressResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ImportAddressResponse clone() => ImportAddressResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ImportAddressResponse copyWith(void Function(ImportAddressResponse) updates) => super.copyWith((message) => updates(message as ImportAddressResponse)) as ImportAddressResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportAddressResponse create() => ImportAddressResponse._();
  ImportAddressResponse createEmptyInstance() => create();
  static $pb.PbList<ImportAddressResponse> createRepeated() => $pb.PbList<ImportAddressResponse>();
  @$core.pragma('dart2js:noInline')
  static ImportAddressResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportAddressResponse>(create);
  static ImportAddressResponse? _defaultInstance;
}

class ImportPubKeyRequest extends $pb.GeneratedMessage {
  factory ImportPubKeyRequest({
    $core.String? pubkey,
    $core.bool? rescan,
    $core.String? wallet,
  }) {
    final $result = create();
    if (pubkey != null) {
      $result.pubkey = pubkey;
    }
    if (rescan != null) {
      $result.rescan = rescan;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  ImportPubKeyRequest._() : super();
  factory ImportPubKeyRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ImportPubKeyRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportPubKeyRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'pubkey')
    ..aOB(2, _omitFieldNames ? '' : 'rescan')
    ..aOS(3, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ImportPubKeyRequest clone() => ImportPubKeyRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ImportPubKeyRequest copyWith(void Function(ImportPubKeyRequest) updates) => super.copyWith((message) => updates(message as ImportPubKeyRequest)) as ImportPubKeyRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportPubKeyRequest create() => ImportPubKeyRequest._();
  ImportPubKeyRequest createEmptyInstance() => create();
  static $pb.PbList<ImportPubKeyRequest> createRepeated() => $pb.PbList<ImportPubKeyRequest>();
  @$core.pragma('dart2js:noInline')
  static ImportPubKeyRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportPubKeyRequest>(create);
  static ImportPubKeyRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get pubkey => $_getSZ(0);
  @$pb.TagNumber(1)
  set pubkey($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPubkey() => $_has(0);
  @$pb.TagNumber(1)
  void clearPubkey() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get rescan => $_getBF(1);
  @$pb.TagNumber(2)
  set rescan($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRescan() => $_has(1);
  @$pb.TagNumber(2)
  void clearRescan() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get wallet => $_getSZ(2);
  @$pb.TagNumber(3)
  set wallet($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasWallet() => $_has(2);
  @$pb.TagNumber(3)
  void clearWallet() => clearField(3);
}

class ImportPubKeyResponse extends $pb.GeneratedMessage {
  factory ImportPubKeyResponse() => create();
  ImportPubKeyResponse._() : super();
  factory ImportPubKeyResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ImportPubKeyResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ImportPubKeyResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ImportPubKeyResponse clone() => ImportPubKeyResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ImportPubKeyResponse copyWith(void Function(ImportPubKeyResponse) updates) => super.copyWith((message) => updates(message as ImportPubKeyResponse)) as ImportPubKeyResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ImportPubKeyResponse create() => ImportPubKeyResponse._();
  ImportPubKeyResponse createEmptyInstance() => create();
  static $pb.PbList<ImportPubKeyResponse> createRepeated() => $pb.PbList<ImportPubKeyResponse>();
  @$core.pragma('dart2js:noInline')
  static ImportPubKeyResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ImportPubKeyResponse>(create);
  static ImportPubKeyResponse? _defaultInstance;
}

class KeyPoolRefillRequest extends $pb.GeneratedMessage {
  factory KeyPoolRefillRequest({
    $core.int? newSize,
    $core.String? wallet,
  }) {
    final $result = create();
    if (newSize != null) {
      $result.newSize = newSize;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  KeyPoolRefillRequest._() : super();
  factory KeyPoolRefillRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory KeyPoolRefillRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'KeyPoolRefillRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'newSize', $pb.PbFieldType.OU3)
    ..aOS(2, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  KeyPoolRefillRequest clone() => KeyPoolRefillRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  KeyPoolRefillRequest copyWith(void Function(KeyPoolRefillRequest) updates) => super.copyWith((message) => updates(message as KeyPoolRefillRequest)) as KeyPoolRefillRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static KeyPoolRefillRequest create() => KeyPoolRefillRequest._();
  KeyPoolRefillRequest createEmptyInstance() => create();
  static $pb.PbList<KeyPoolRefillRequest> createRepeated() => $pb.PbList<KeyPoolRefillRequest>();
  @$core.pragma('dart2js:noInline')
  static KeyPoolRefillRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<KeyPoolRefillRequest>(create);
  static KeyPoolRefillRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get newSize => $_getIZ(0);
  @$pb.TagNumber(1)
  set newSize($core.int v) { $_setUnsignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasNewSize() => $_has(0);
  @$pb.TagNumber(1)
  void clearNewSize() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get wallet => $_getSZ(1);
  @$pb.TagNumber(2)
  set wallet($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWallet() => $_has(1);
  @$pb.TagNumber(2)
  void clearWallet() => clearField(2);
}

class KeyPoolRefillResponse extends $pb.GeneratedMessage {
  factory KeyPoolRefillResponse() => create();
  KeyPoolRefillResponse._() : super();
  factory KeyPoolRefillResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory KeyPoolRefillResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'KeyPoolRefillResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  KeyPoolRefillResponse clone() => KeyPoolRefillResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  KeyPoolRefillResponse copyWith(void Function(KeyPoolRefillResponse) updates) => super.copyWith((message) => updates(message as KeyPoolRefillResponse)) as KeyPoolRefillResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static KeyPoolRefillResponse create() => KeyPoolRefillResponse._();
  KeyPoolRefillResponse createEmptyInstance() => create();
  static $pb.PbList<KeyPoolRefillResponse> createRepeated() => $pb.PbList<KeyPoolRefillResponse>();
  @$core.pragma('dart2js:noInline')
  static KeyPoolRefillResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<KeyPoolRefillResponse>(create);
  static KeyPoolRefillResponse? _defaultInstance;
}

class GetAccountRequest extends $pb.GeneratedMessage {
  factory GetAccountRequest({
    $core.String? address,
    $core.String? wallet,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  GetAccountRequest._() : super();
  factory GetAccountRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetAccountRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAccountRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetAccountRequest clone() => GetAccountRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetAccountRequest copyWith(void Function(GetAccountRequest) updates) => super.copyWith((message) => updates(message as GetAccountRequest)) as GetAccountRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAccountRequest create() => GetAccountRequest._();
  GetAccountRequest createEmptyInstance() => create();
  static $pb.PbList<GetAccountRequest> createRepeated() => $pb.PbList<GetAccountRequest>();
  @$core.pragma('dart2js:noInline')
  static GetAccountRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAccountRequest>(create);
  static GetAccountRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get wallet => $_getSZ(1);
  @$pb.TagNumber(2)
  set wallet($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWallet() => $_has(1);
  @$pb.TagNumber(2)
  void clearWallet() => clearField(2);
}

class GetAccountResponse extends $pb.GeneratedMessage {
  factory GetAccountResponse({
    $core.String? account,
  }) {
    final $result = create();
    if (account != null) {
      $result.account = account;
    }
    return $result;
  }
  GetAccountResponse._() : super();
  factory GetAccountResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetAccountResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAccountResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'account')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetAccountResponse clone() => GetAccountResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetAccountResponse copyWith(void Function(GetAccountResponse) updates) => super.copyWith((message) => updates(message as GetAccountResponse)) as GetAccountResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAccountResponse create() => GetAccountResponse._();
  GetAccountResponse createEmptyInstance() => create();
  static $pb.PbList<GetAccountResponse> createRepeated() => $pb.PbList<GetAccountResponse>();
  @$core.pragma('dart2js:noInline')
  static GetAccountResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAccountResponse>(create);
  static GetAccountResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get account => $_getSZ(0);
  @$pb.TagNumber(1)
  set account($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAccount() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccount() => clearField(1);
}

class SetAccountRequest extends $pb.GeneratedMessage {
  factory SetAccountRequest({
    $core.String? address,
    $core.String? account,
    $core.String? wallet,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (account != null) {
      $result.account = account;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  SetAccountRequest._() : super();
  factory SetAccountRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetAccountRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetAccountRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'account')
    ..aOS(3, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetAccountRequest clone() => SetAccountRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetAccountRequest copyWith(void Function(SetAccountRequest) updates) => super.copyWith((message) => updates(message as SetAccountRequest)) as SetAccountRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetAccountRequest create() => SetAccountRequest._();
  SetAccountRequest createEmptyInstance() => create();
  static $pb.PbList<SetAccountRequest> createRepeated() => $pb.PbList<SetAccountRequest>();
  @$core.pragma('dart2js:noInline')
  static SetAccountRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetAccountRequest>(create);
  static SetAccountRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get account => $_getSZ(1);
  @$pb.TagNumber(2)
  set account($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAccount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAccount() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get wallet => $_getSZ(2);
  @$pb.TagNumber(3)
  set wallet($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasWallet() => $_has(2);
  @$pb.TagNumber(3)
  void clearWallet() => clearField(3);
}

class SetAccountResponse extends $pb.GeneratedMessage {
  factory SetAccountResponse() => create();
  SetAccountResponse._() : super();
  factory SetAccountResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SetAccountResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SetAccountResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SetAccountResponse clone() => SetAccountResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SetAccountResponse copyWith(void Function(SetAccountResponse) updates) => super.copyWith((message) => updates(message as SetAccountResponse)) as SetAccountResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SetAccountResponse create() => SetAccountResponse._();
  SetAccountResponse createEmptyInstance() => create();
  static $pb.PbList<SetAccountResponse> createRepeated() => $pb.PbList<SetAccountResponse>();
  @$core.pragma('dart2js:noInline')
  static SetAccountResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SetAccountResponse>(create);
  static SetAccountResponse? _defaultInstance;
}

class GetAddressesByAccountRequest extends $pb.GeneratedMessage {
  factory GetAddressesByAccountRequest({
    $core.String? account,
    $core.String? wallet,
  }) {
    final $result = create();
    if (account != null) {
      $result.account = account;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  GetAddressesByAccountRequest._() : super();
  factory GetAddressesByAccountRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetAddressesByAccountRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAddressesByAccountRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'account')
    ..aOS(2, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetAddressesByAccountRequest clone() => GetAddressesByAccountRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetAddressesByAccountRequest copyWith(void Function(GetAddressesByAccountRequest) updates) => super.copyWith((message) => updates(message as GetAddressesByAccountRequest)) as GetAddressesByAccountRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAddressesByAccountRequest create() => GetAddressesByAccountRequest._();
  GetAddressesByAccountRequest createEmptyInstance() => create();
  static $pb.PbList<GetAddressesByAccountRequest> createRepeated() => $pb.PbList<GetAddressesByAccountRequest>();
  @$core.pragma('dart2js:noInline')
  static GetAddressesByAccountRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAddressesByAccountRequest>(create);
  static GetAddressesByAccountRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get account => $_getSZ(0);
  @$pb.TagNumber(1)
  set account($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAccount() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccount() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get wallet => $_getSZ(1);
  @$pb.TagNumber(2)
  set wallet($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWallet() => $_has(1);
  @$pb.TagNumber(2)
  void clearWallet() => clearField(2);
}

class GetAddressesByAccountResponse extends $pb.GeneratedMessage {
  factory GetAddressesByAccountResponse({
    $core.Iterable<$core.String>? addresses,
  }) {
    final $result = create();
    if (addresses != null) {
      $result.addresses.addAll(addresses);
    }
    return $result;
  }
  GetAddressesByAccountResponse._() : super();
  factory GetAddressesByAccountResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetAddressesByAccountResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetAddressesByAccountResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'addresses')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetAddressesByAccountResponse clone() => GetAddressesByAccountResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetAddressesByAccountResponse copyWith(void Function(GetAddressesByAccountResponse) updates) => super.copyWith((message) => updates(message as GetAddressesByAccountResponse)) as GetAddressesByAccountResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetAddressesByAccountResponse create() => GetAddressesByAccountResponse._();
  GetAddressesByAccountResponse createEmptyInstance() => create();
  static $pb.PbList<GetAddressesByAccountResponse> createRepeated() => $pb.PbList<GetAddressesByAccountResponse>();
  @$core.pragma('dart2js:noInline')
  static GetAddressesByAccountResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetAddressesByAccountResponse>(create);
  static GetAddressesByAccountResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get addresses => $_getList(0);
}

class ListAccountsRequest extends $pb.GeneratedMessage {
  factory ListAccountsRequest({
    $core.int? minConf,
    $core.String? wallet,
  }) {
    final $result = create();
    if (minConf != null) {
      $result.minConf = minConf;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  ListAccountsRequest._() : super();
  factory ListAccountsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListAccountsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListAccountsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'minConf', $pb.PbFieldType.O3)
    ..aOS(2, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListAccountsRequest clone() => ListAccountsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListAccountsRequest copyWith(void Function(ListAccountsRequest) updates) => super.copyWith((message) => updates(message as ListAccountsRequest)) as ListAccountsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListAccountsRequest create() => ListAccountsRequest._();
  ListAccountsRequest createEmptyInstance() => create();
  static $pb.PbList<ListAccountsRequest> createRepeated() => $pb.PbList<ListAccountsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListAccountsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListAccountsRequest>(create);
  static ListAccountsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get minConf => $_getIZ(0);
  @$pb.TagNumber(1)
  set minConf($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMinConf() => $_has(0);
  @$pb.TagNumber(1)
  void clearMinConf() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get wallet => $_getSZ(1);
  @$pb.TagNumber(2)
  set wallet($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWallet() => $_has(1);
  @$pb.TagNumber(2)
  void clearWallet() => clearField(2);
}

class ListAccountsResponse extends $pb.GeneratedMessage {
  factory ListAccountsResponse({
    $core.Map<$core.String, $core.double>? accounts,
  }) {
    final $result = create();
    if (accounts != null) {
      $result.accounts.addAll(accounts);
    }
    return $result;
  }
  ListAccountsResponse._() : super();
  factory ListAccountsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListAccountsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListAccountsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..m<$core.String, $core.double>(1, _omitFieldNames ? '' : 'accounts', entryClassName: 'ListAccountsResponse.AccountsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OD, packageName: const $pb.PackageName('bitcoind.v1'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListAccountsResponse clone() => ListAccountsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListAccountsResponse copyWith(void Function(ListAccountsResponse) updates) => super.copyWith((message) => updates(message as ListAccountsResponse)) as ListAccountsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListAccountsResponse create() => ListAccountsResponse._();
  ListAccountsResponse createEmptyInstance() => create();
  static $pb.PbList<ListAccountsResponse> createRepeated() => $pb.PbList<ListAccountsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListAccountsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListAccountsResponse>(create);
  static ListAccountsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.Map<$core.String, $core.double> get accounts => $_getMap(0);
}

class AddMultisigAddressRequest extends $pb.GeneratedMessage {
  factory AddMultisigAddressRequest({
    $core.int? requiredSigs,
    $core.Iterable<$core.String>? keys,
    $core.String? label,
    $core.String? wallet,
  }) {
    final $result = create();
    if (requiredSigs != null) {
      $result.requiredSigs = requiredSigs;
    }
    if (keys != null) {
      $result.keys.addAll(keys);
    }
    if (label != null) {
      $result.label = label;
    }
    if (wallet != null) {
      $result.wallet = wallet;
    }
    return $result;
  }
  AddMultisigAddressRequest._() : super();
  factory AddMultisigAddressRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddMultisigAddressRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddMultisigAddressRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'requiredSigs', $pb.PbFieldType.O3)
    ..pPS(2, _omitFieldNames ? '' : 'keys')
    ..aOS(3, _omitFieldNames ? '' : 'label')
    ..aOS(4, _omitFieldNames ? '' : 'wallet')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddMultisigAddressRequest clone() => AddMultisigAddressRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddMultisigAddressRequest copyWith(void Function(AddMultisigAddressRequest) updates) => super.copyWith((message) => updates(message as AddMultisigAddressRequest)) as AddMultisigAddressRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddMultisigAddressRequest create() => AddMultisigAddressRequest._();
  AddMultisigAddressRequest createEmptyInstance() => create();
  static $pb.PbList<AddMultisigAddressRequest> createRepeated() => $pb.PbList<AddMultisigAddressRequest>();
  @$core.pragma('dart2js:noInline')
  static AddMultisigAddressRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddMultisigAddressRequest>(create);
  static AddMultisigAddressRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get requiredSigs => $_getIZ(0);
  @$pb.TagNumber(1)
  set requiredSigs($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRequiredSigs() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequiredSigs() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.String> get keys => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get label => $_getSZ(2);
  @$pb.TagNumber(3)
  set label($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLabel() => $_has(2);
  @$pb.TagNumber(3)
  void clearLabel() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get wallet => $_getSZ(3);
  @$pb.TagNumber(4)
  set wallet($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasWallet() => $_has(3);
  @$pb.TagNumber(4)
  void clearWallet() => clearField(4);
}

class AddMultisigAddressResponse extends $pb.GeneratedMessage {
  factory AddMultisigAddressResponse({
    $core.String? address,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    return $result;
  }
  AddMultisigAddressResponse._() : super();
  factory AddMultisigAddressResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AddMultisigAddressResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AddMultisigAddressResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AddMultisigAddressResponse clone() => AddMultisigAddressResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AddMultisigAddressResponse copyWith(void Function(AddMultisigAddressResponse) updates) => super.copyWith((message) => updates(message as AddMultisigAddressResponse)) as AddMultisigAddressResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AddMultisigAddressResponse create() => AddMultisigAddressResponse._();
  AddMultisigAddressResponse createEmptyInstance() => create();
  static $pb.PbList<AddMultisigAddressResponse> createRepeated() => $pb.PbList<AddMultisigAddressResponse>();
  @$core.pragma('dart2js:noInline')
  static AddMultisigAddressResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AddMultisigAddressResponse>(create);
  static AddMultisigAddressResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);
}

class CreateMultisigRequest extends $pb.GeneratedMessage {
  factory CreateMultisigRequest({
    $core.int? requiredSigs,
    $core.Iterable<$core.String>? keys,
  }) {
    final $result = create();
    if (requiredSigs != null) {
      $result.requiredSigs = requiredSigs;
    }
    if (keys != null) {
      $result.keys.addAll(keys);
    }
    return $result;
  }
  CreateMultisigRequest._() : super();
  factory CreateMultisigRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateMultisigRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateMultisigRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'requiredSigs', $pb.PbFieldType.O3)
    ..pPS(2, _omitFieldNames ? '' : 'keys')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateMultisigRequest clone() => CreateMultisigRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateMultisigRequest copyWith(void Function(CreateMultisigRequest) updates) => super.copyWith((message) => updates(message as CreateMultisigRequest)) as CreateMultisigRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateMultisigRequest create() => CreateMultisigRequest._();
  CreateMultisigRequest createEmptyInstance() => create();
  static $pb.PbList<CreateMultisigRequest> createRepeated() => $pb.PbList<CreateMultisigRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateMultisigRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateMultisigRequest>(create);
  static CreateMultisigRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get requiredSigs => $_getIZ(0);
  @$pb.TagNumber(1)
  set requiredSigs($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasRequiredSigs() => $_has(0);
  @$pb.TagNumber(1)
  void clearRequiredSigs() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.String> get keys => $_getList(1);
}

class CreateMultisigResponse extends $pb.GeneratedMessage {
  factory CreateMultisigResponse({
    $core.String? address,
    $core.String? redeemScript,
  }) {
    final $result = create();
    if (address != null) {
      $result.address = address;
    }
    if (redeemScript != null) {
      $result.redeemScript = redeemScript;
    }
    return $result;
  }
  CreateMultisigResponse._() : super();
  factory CreateMultisigResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateMultisigResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateMultisigResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'address')
    ..aOS(2, _omitFieldNames ? '' : 'redeemScript')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateMultisigResponse clone() => CreateMultisigResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateMultisigResponse copyWith(void Function(CreateMultisigResponse) updates) => super.copyWith((message) => updates(message as CreateMultisigResponse)) as CreateMultisigResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateMultisigResponse create() => CreateMultisigResponse._();
  CreateMultisigResponse createEmptyInstance() => create();
  static $pb.PbList<CreateMultisigResponse> createRepeated() => $pb.PbList<CreateMultisigResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateMultisigResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateMultisigResponse>(create);
  static CreateMultisigResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get address => $_getSZ(0);
  @$pb.TagNumber(1)
  set address($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAddress() => $_has(0);
  @$pb.TagNumber(1)
  void clearAddress() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get redeemScript => $_getSZ(1);
  @$pb.TagNumber(2)
  set redeemScript($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasRedeemScript() => $_has(1);
  @$pb.TagNumber(2)
  void clearRedeemScript() => clearField(2);
}

class CreatePsbtRequest_Input extends $pb.GeneratedMessage {
  factory CreatePsbtRequest_Input({
    $core.String? txid,
    $core.int? vout,
    $core.int? sequence,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (vout != null) {
      $result.vout = vout;
    }
    if (sequence != null) {
      $result.sequence = sequence;
    }
    return $result;
  }
  CreatePsbtRequest_Input._() : super();
  factory CreatePsbtRequest_Input.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreatePsbtRequest_Input.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreatePsbtRequest.Input', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..a<$core.int>(2, _omitFieldNames ? '' : 'vout', $pb.PbFieldType.OU3)
    ..a<$core.int>(3, _omitFieldNames ? '' : 'sequence', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreatePsbtRequest_Input clone() => CreatePsbtRequest_Input()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreatePsbtRequest_Input copyWith(void Function(CreatePsbtRequest_Input) updates) => super.copyWith((message) => updates(message as CreatePsbtRequest_Input)) as CreatePsbtRequest_Input;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreatePsbtRequest_Input create() => CreatePsbtRequest_Input._();
  CreatePsbtRequest_Input createEmptyInstance() => create();
  static $pb.PbList<CreatePsbtRequest_Input> createRepeated() => $pb.PbList<CreatePsbtRequest_Input>();
  @$core.pragma('dart2js:noInline')
  static CreatePsbtRequest_Input getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreatePsbtRequest_Input>(create);
  static CreatePsbtRequest_Input? _defaultInstance;

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
  $core.int get sequence => $_getIZ(2);
  @$pb.TagNumber(3)
  set sequence($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSequence() => $_has(2);
  @$pb.TagNumber(3)
  void clearSequence() => clearField(3);
}

class CreatePsbtRequest extends $pb.GeneratedMessage {
  factory CreatePsbtRequest({
    $core.Iterable<CreatePsbtRequest_Input>? inputs,
    $core.Map<$core.String, $core.double>? outputs,
    $core.int? locktime,
    $core.bool? replaceable,
  }) {
    final $result = create();
    if (inputs != null) {
      $result.inputs.addAll(inputs);
    }
    if (outputs != null) {
      $result.outputs.addAll(outputs);
    }
    if (locktime != null) {
      $result.locktime = locktime;
    }
    if (replaceable != null) {
      $result.replaceable = replaceable;
    }
    return $result;
  }
  CreatePsbtRequest._() : super();
  factory CreatePsbtRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreatePsbtRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreatePsbtRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..pc<CreatePsbtRequest_Input>(1, _omitFieldNames ? '' : 'inputs', $pb.PbFieldType.PM, subBuilder: CreatePsbtRequest_Input.create)
    ..m<$core.String, $core.double>(2, _omitFieldNames ? '' : 'outputs', entryClassName: 'CreatePsbtRequest.OutputsEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OD, packageName: const $pb.PackageName('bitcoind.v1'))
    ..a<$core.int>(3, _omitFieldNames ? '' : 'locktime', $pb.PbFieldType.OU3)
    ..aOB(4, _omitFieldNames ? '' : 'replaceable')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreatePsbtRequest clone() => CreatePsbtRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreatePsbtRequest copyWith(void Function(CreatePsbtRequest) updates) => super.copyWith((message) => updates(message as CreatePsbtRequest)) as CreatePsbtRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreatePsbtRequest create() => CreatePsbtRequest._();
  CreatePsbtRequest createEmptyInstance() => create();
  static $pb.PbList<CreatePsbtRequest> createRepeated() => $pb.PbList<CreatePsbtRequest>();
  @$core.pragma('dart2js:noInline')
  static CreatePsbtRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreatePsbtRequest>(create);
  static CreatePsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<CreatePsbtRequest_Input> get inputs => $_getList(0);

  @$pb.TagNumber(2)
  $core.Map<$core.String, $core.double> get outputs => $_getMap(1);

  @$pb.TagNumber(3)
  $core.int get locktime => $_getIZ(2);
  @$pb.TagNumber(3)
  set locktime($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasLocktime() => $_has(2);
  @$pb.TagNumber(3)
  void clearLocktime() => clearField(3);

  @$pb.TagNumber(4)
  $core.bool get replaceable => $_getBF(3);
  @$pb.TagNumber(4)
  set replaceable($core.bool v) { $_setBool(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasReplaceable() => $_has(3);
  @$pb.TagNumber(4)
  void clearReplaceable() => clearField(4);
}

class CreatePsbtResponse extends $pb.GeneratedMessage {
  factory CreatePsbtResponse({
    $core.String? psbt,
  }) {
    final $result = create();
    if (psbt != null) {
      $result.psbt = psbt;
    }
    return $result;
  }
  CreatePsbtResponse._() : super();
  factory CreatePsbtResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreatePsbtResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreatePsbtResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreatePsbtResponse clone() => CreatePsbtResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreatePsbtResponse copyWith(void Function(CreatePsbtResponse) updates) => super.copyWith((message) => updates(message as CreatePsbtResponse)) as CreatePsbtResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreatePsbtResponse create() => CreatePsbtResponse._();
  CreatePsbtResponse createEmptyInstance() => create();
  static $pb.PbList<CreatePsbtResponse> createRepeated() => $pb.PbList<CreatePsbtResponse>();
  @$core.pragma('dart2js:noInline')
  static CreatePsbtResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreatePsbtResponse>(create);
  static CreatePsbtResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => clearField(1);
}

class DecodePsbtRequest extends $pb.GeneratedMessage {
  factory DecodePsbtRequest({
    $core.String? psbt,
  }) {
    final $result = create();
    if (psbt != null) {
      $result.psbt = psbt;
    }
    return $result;
  }
  DecodePsbtRequest._() : super();
  factory DecodePsbtRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DecodePsbtRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodePsbtRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DecodePsbtRequest clone() => DecodePsbtRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DecodePsbtRequest copyWith(void Function(DecodePsbtRequest) updates) => super.copyWith((message) => updates(message as DecodePsbtRequest)) as DecodePsbtRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecodePsbtRequest create() => DecodePsbtRequest._();
  DecodePsbtRequest createEmptyInstance() => create();
  static $pb.PbList<DecodePsbtRequest> createRepeated() => $pb.PbList<DecodePsbtRequest>();
  @$core.pragma('dart2js:noInline')
  static DecodePsbtRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecodePsbtRequest>(create);
  static DecodePsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => clearField(1);
}

class DecodeRawTransactionResponse extends $pb.GeneratedMessage {
  factory DecodeRawTransactionResponse({
    $core.String? txid,
    $core.String? hash,
    $core.int? size,
    $core.int? virtualSize,
    $core.int? weight,
    $core.int? version,
    $core.int? locktime,
    $core.Iterable<Input>? inputs,
    $core.Iterable<Output>? outputs,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (hash != null) {
      $result.hash = hash;
    }
    if (size != null) {
      $result.size = size;
    }
    if (virtualSize != null) {
      $result.virtualSize = virtualSize;
    }
    if (weight != null) {
      $result.weight = weight;
    }
    if (version != null) {
      $result.version = version;
    }
    if (locktime != null) {
      $result.locktime = locktime;
    }
    if (inputs != null) {
      $result.inputs.addAll(inputs);
    }
    if (outputs != null) {
      $result.outputs.addAll(outputs);
    }
    return $result;
  }
  DecodeRawTransactionResponse._() : super();
  factory DecodeRawTransactionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DecodeRawTransactionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodeRawTransactionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aOS(2, _omitFieldNames ? '' : 'hash')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'size', $pb.PbFieldType.OU3)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'virtualSize', $pb.PbFieldType.OU3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'weight', $pb.PbFieldType.OU3)
    ..a<$core.int>(6, _omitFieldNames ? '' : 'version', $pb.PbFieldType.OU3)
    ..a<$core.int>(7, _omitFieldNames ? '' : 'locktime', $pb.PbFieldType.OU3)
    ..pc<Input>(8, _omitFieldNames ? '' : 'inputs', $pb.PbFieldType.PM, subBuilder: Input.create)
    ..pc<Output>(9, _omitFieldNames ? '' : 'outputs', $pb.PbFieldType.PM, subBuilder: Output.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DecodeRawTransactionResponse clone() => DecodeRawTransactionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DecodeRawTransactionResponse copyWith(void Function(DecodeRawTransactionResponse) updates) => super.copyWith((message) => updates(message as DecodeRawTransactionResponse)) as DecodeRawTransactionResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecodeRawTransactionResponse create() => DecodeRawTransactionResponse._();
  DecodeRawTransactionResponse createEmptyInstance() => create();
  static $pb.PbList<DecodeRawTransactionResponse> createRepeated() => $pb.PbList<DecodeRawTransactionResponse>();
  @$core.pragma('dart2js:noInline')
  static DecodeRawTransactionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecodeRawTransactionResponse>(create);
  static DecodeRawTransactionResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get hash => $_getSZ(1);
  @$pb.TagNumber(2)
  set hash($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearHash() => clearField(2);

  /// The serialized transaction size
  @$pb.TagNumber(3)
  $core.int get size => $_getIZ(2);
  @$pb.TagNumber(3)
  set size($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSize() => $_has(2);
  @$pb.TagNumber(3)
  void clearSize() => clearField(3);

  /// The virtual transaction size (differs from
  /// 'size' for witness transactions).
  @$pb.TagNumber(4)
  $core.int get virtualSize => $_getIZ(3);
  @$pb.TagNumber(4)
  set virtualSize($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasVirtualSize() => $_has(3);
  @$pb.TagNumber(4)
  void clearVirtualSize() => clearField(4);

  /// The transaction's weight
  @$pb.TagNumber(5)
  $core.int get weight => $_getIZ(4);
  @$pb.TagNumber(5)
  set weight($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasWeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearWeight() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get version => $_getIZ(5);
  @$pb.TagNumber(6)
  set version($core.int v) { $_setUnsignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasVersion() => $_has(5);
  @$pb.TagNumber(6)
  void clearVersion() => clearField(6);

  @$pb.TagNumber(7)
  $core.int get locktime => $_getIZ(6);
  @$pb.TagNumber(7)
  set locktime($core.int v) { $_setUnsignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasLocktime() => $_has(6);
  @$pb.TagNumber(7)
  void clearLocktime() => clearField(7);

  @$pb.TagNumber(8)
  $core.List<Input> get inputs => $_getList(7);

  @$pb.TagNumber(9)
  $core.List<Output> get outputs => $_getList(8);
}

class DecodePsbtResponse_WitnessUtxo extends $pb.GeneratedMessage {
  factory DecodePsbtResponse_WitnessUtxo({
    $core.double? amount,
    ScriptPubKey? scriptPubKey,
  }) {
    final $result = create();
    if (amount != null) {
      $result.amount = amount;
    }
    if (scriptPubKey != null) {
      $result.scriptPubKey = scriptPubKey;
    }
    return $result;
  }
  DecodePsbtResponse_WitnessUtxo._() : super();
  factory DecodePsbtResponse_WitnessUtxo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DecodePsbtResponse_WitnessUtxo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodePsbtResponse.WitnessUtxo', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..a<$core.double>(1, _omitFieldNames ? '' : 'amount', $pb.PbFieldType.OD)
    ..aOM<ScriptPubKey>(2, _omitFieldNames ? '' : 'scriptPubKey', subBuilder: ScriptPubKey.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DecodePsbtResponse_WitnessUtxo clone() => DecodePsbtResponse_WitnessUtxo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DecodePsbtResponse_WitnessUtxo copyWith(void Function(DecodePsbtResponse_WitnessUtxo) updates) => super.copyWith((message) => updates(message as DecodePsbtResponse_WitnessUtxo)) as DecodePsbtResponse_WitnessUtxo;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse_WitnessUtxo create() => DecodePsbtResponse_WitnessUtxo._();
  DecodePsbtResponse_WitnessUtxo createEmptyInstance() => create();
  static $pb.PbList<DecodePsbtResponse_WitnessUtxo> createRepeated() => $pb.PbList<DecodePsbtResponse_WitnessUtxo>();
  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse_WitnessUtxo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecodePsbtResponse_WitnessUtxo>(create);
  static DecodePsbtResponse_WitnessUtxo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.double get amount => $_getN(0);
  @$pb.TagNumber(1)
  set amount($core.double v) { $_setDouble(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAmount() => $_has(0);
  @$pb.TagNumber(1)
  void clearAmount() => clearField(1);

  @$pb.TagNumber(2)
  ScriptPubKey get scriptPubKey => $_getN(1);
  @$pb.TagNumber(2)
  set scriptPubKey(ScriptPubKey v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasScriptPubKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearScriptPubKey() => clearField(2);
  @$pb.TagNumber(2)
  ScriptPubKey ensureScriptPubKey() => $_ensure(1);
}

class DecodePsbtResponse_RedeemScript extends $pb.GeneratedMessage {
  factory DecodePsbtResponse_RedeemScript({
    $core.String? asm,
    $core.String? hex,
    $core.String? type,
  }) {
    final $result = create();
    if (asm != null) {
      $result.asm = asm;
    }
    if (hex != null) {
      $result.hex = hex;
    }
    if (type != null) {
      $result.type = type;
    }
    return $result;
  }
  DecodePsbtResponse_RedeemScript._() : super();
  factory DecodePsbtResponse_RedeemScript.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DecodePsbtResponse_RedeemScript.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodePsbtResponse.RedeemScript', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'asm')
    ..aOS(2, _omitFieldNames ? '' : 'hex')
    ..aOS(3, _omitFieldNames ? '' : 'type')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DecodePsbtResponse_RedeemScript clone() => DecodePsbtResponse_RedeemScript()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DecodePsbtResponse_RedeemScript copyWith(void Function(DecodePsbtResponse_RedeemScript) updates) => super.copyWith((message) => updates(message as DecodePsbtResponse_RedeemScript)) as DecodePsbtResponse_RedeemScript;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse_RedeemScript create() => DecodePsbtResponse_RedeemScript._();
  DecodePsbtResponse_RedeemScript createEmptyInstance() => create();
  static $pb.PbList<DecodePsbtResponse_RedeemScript> createRepeated() => $pb.PbList<DecodePsbtResponse_RedeemScript>();
  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse_RedeemScript getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecodePsbtResponse_RedeemScript>(create);
  static DecodePsbtResponse_RedeemScript? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get asm => $_getSZ(0);
  @$pb.TagNumber(1)
  set asm($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAsm() => $_has(0);
  @$pb.TagNumber(1)
  void clearAsm() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get hex => $_getSZ(1);
  @$pb.TagNumber(2)
  set hex($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHex() => $_has(1);
  @$pb.TagNumber(2)
  void clearHex() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get type => $_getSZ(2);
  @$pb.TagNumber(3)
  set type($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasType() => $_has(2);
  @$pb.TagNumber(3)
  void clearType() => clearField(3);
}

class DecodePsbtResponse_Bip32Deriv extends $pb.GeneratedMessage {
  factory DecodePsbtResponse_Bip32Deriv({
    $core.String? pubkey,
    $core.String? masterFingerprint,
    $core.String? path,
  }) {
    final $result = create();
    if (pubkey != null) {
      $result.pubkey = pubkey;
    }
    if (masterFingerprint != null) {
      $result.masterFingerprint = masterFingerprint;
    }
    if (path != null) {
      $result.path = path;
    }
    return $result;
  }
  DecodePsbtResponse_Bip32Deriv._() : super();
  factory DecodePsbtResponse_Bip32Deriv.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DecodePsbtResponse_Bip32Deriv.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodePsbtResponse.Bip32Deriv', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'pubkey')
    ..aOS(2, _omitFieldNames ? '' : 'masterFingerprint')
    ..aOS(3, _omitFieldNames ? '' : 'path')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DecodePsbtResponse_Bip32Deriv clone() => DecodePsbtResponse_Bip32Deriv()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DecodePsbtResponse_Bip32Deriv copyWith(void Function(DecodePsbtResponse_Bip32Deriv) updates) => super.copyWith((message) => updates(message as DecodePsbtResponse_Bip32Deriv)) as DecodePsbtResponse_Bip32Deriv;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse_Bip32Deriv create() => DecodePsbtResponse_Bip32Deriv._();
  DecodePsbtResponse_Bip32Deriv createEmptyInstance() => create();
  static $pb.PbList<DecodePsbtResponse_Bip32Deriv> createRepeated() => $pb.PbList<DecodePsbtResponse_Bip32Deriv>();
  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse_Bip32Deriv getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecodePsbtResponse_Bip32Deriv>(create);
  static DecodePsbtResponse_Bip32Deriv? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get pubkey => $_getSZ(0);
  @$pb.TagNumber(1)
  set pubkey($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPubkey() => $_has(0);
  @$pb.TagNumber(1)
  void clearPubkey() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get masterFingerprint => $_getSZ(1);
  @$pb.TagNumber(2)
  set masterFingerprint($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMasterFingerprint() => $_has(1);
  @$pb.TagNumber(2)
  void clearMasterFingerprint() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get path => $_getSZ(2);
  @$pb.TagNumber(3)
  set path($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPath() => $_has(2);
  @$pb.TagNumber(3)
  void clearPath() => clearField(3);
}

class DecodePsbtResponse_Input extends $pb.GeneratedMessage {
  factory DecodePsbtResponse_Input({
    DecodeRawTransactionResponse? nonWitnessUtxo,
    DecodePsbtResponse_WitnessUtxo? witnessUtxo,
    $core.Map<$core.String, $core.String>? partialSignatures,
    $core.String? sighash,
    DecodePsbtResponse_RedeemScript? redeemScript,
    DecodePsbtResponse_RedeemScript? witnessScript,
    $core.Iterable<DecodePsbtResponse_Bip32Deriv>? bip32Derivs,
    ScriptSig? finalScriptsig,
    $core.Iterable<$core.String>? finalScriptwitness,
    $core.Map<$core.String, $core.String>? unknown,
  }) {
    final $result = create();
    if (nonWitnessUtxo != null) {
      $result.nonWitnessUtxo = nonWitnessUtxo;
    }
    if (witnessUtxo != null) {
      $result.witnessUtxo = witnessUtxo;
    }
    if (partialSignatures != null) {
      $result.partialSignatures.addAll(partialSignatures);
    }
    if (sighash != null) {
      $result.sighash = sighash;
    }
    if (redeemScript != null) {
      $result.redeemScript = redeemScript;
    }
    if (witnessScript != null) {
      $result.witnessScript = witnessScript;
    }
    if (bip32Derivs != null) {
      $result.bip32Derivs.addAll(bip32Derivs);
    }
    if (finalScriptsig != null) {
      $result.finalScriptsig = finalScriptsig;
    }
    if (finalScriptwitness != null) {
      $result.finalScriptwitness.addAll(finalScriptwitness);
    }
    if (unknown != null) {
      $result.unknown.addAll(unknown);
    }
    return $result;
  }
  DecodePsbtResponse_Input._() : super();
  factory DecodePsbtResponse_Input.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DecodePsbtResponse_Input.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodePsbtResponse.Input', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOM<DecodeRawTransactionResponse>(1, _omitFieldNames ? '' : 'nonWitnessUtxo', subBuilder: DecodeRawTransactionResponse.create)
    ..aOM<DecodePsbtResponse_WitnessUtxo>(2, _omitFieldNames ? '' : 'witnessUtxo', subBuilder: DecodePsbtResponse_WitnessUtxo.create)
    ..m<$core.String, $core.String>(3, _omitFieldNames ? '' : 'partialSignatures', entryClassName: 'DecodePsbtResponse.Input.PartialSignaturesEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('bitcoind.v1'))
    ..aOS(4, _omitFieldNames ? '' : 'sighash')
    ..aOM<DecodePsbtResponse_RedeemScript>(5, _omitFieldNames ? '' : 'redeemScript', subBuilder: DecodePsbtResponse_RedeemScript.create)
    ..aOM<DecodePsbtResponse_RedeemScript>(6, _omitFieldNames ? '' : 'witnessScript', subBuilder: DecodePsbtResponse_RedeemScript.create)
    ..pc<DecodePsbtResponse_Bip32Deriv>(7, _omitFieldNames ? '' : 'bip32Derivs', $pb.PbFieldType.PM, subBuilder: DecodePsbtResponse_Bip32Deriv.create)
    ..aOM<ScriptSig>(8, _omitFieldNames ? '' : 'finalScriptsig', subBuilder: ScriptSig.create)
    ..pPS(9, _omitFieldNames ? '' : 'finalScriptwitness')
    ..m<$core.String, $core.String>(10, _omitFieldNames ? '' : 'unknown', entryClassName: 'DecodePsbtResponse.Input.UnknownEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('bitcoind.v1'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DecodePsbtResponse_Input clone() => DecodePsbtResponse_Input()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DecodePsbtResponse_Input copyWith(void Function(DecodePsbtResponse_Input) updates) => super.copyWith((message) => updates(message as DecodePsbtResponse_Input)) as DecodePsbtResponse_Input;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse_Input create() => DecodePsbtResponse_Input._();
  DecodePsbtResponse_Input createEmptyInstance() => create();
  static $pb.PbList<DecodePsbtResponse_Input> createRepeated() => $pb.PbList<DecodePsbtResponse_Input>();
  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse_Input getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecodePsbtResponse_Input>(create);
  static DecodePsbtResponse_Input? _defaultInstance;

  @$pb.TagNumber(1)
  DecodeRawTransactionResponse get nonWitnessUtxo => $_getN(0);
  @$pb.TagNumber(1)
  set nonWitnessUtxo(DecodeRawTransactionResponse v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasNonWitnessUtxo() => $_has(0);
  @$pb.TagNumber(1)
  void clearNonWitnessUtxo() => clearField(1);
  @$pb.TagNumber(1)
  DecodeRawTransactionResponse ensureNonWitnessUtxo() => $_ensure(0);

  @$pb.TagNumber(2)
  DecodePsbtResponse_WitnessUtxo get witnessUtxo => $_getN(1);
  @$pb.TagNumber(2)
  set witnessUtxo(DecodePsbtResponse_WitnessUtxo v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasWitnessUtxo() => $_has(1);
  @$pb.TagNumber(2)
  void clearWitnessUtxo() => clearField(2);
  @$pb.TagNumber(2)
  DecodePsbtResponse_WitnessUtxo ensureWitnessUtxo() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.Map<$core.String, $core.String> get partialSignatures => $_getMap(2);

  @$pb.TagNumber(4)
  $core.String get sighash => $_getSZ(3);
  @$pb.TagNumber(4)
  set sighash($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSighash() => $_has(3);
  @$pb.TagNumber(4)
  void clearSighash() => clearField(4);

  @$pb.TagNumber(5)
  DecodePsbtResponse_RedeemScript get redeemScript => $_getN(4);
  @$pb.TagNumber(5)
  set redeemScript(DecodePsbtResponse_RedeemScript v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasRedeemScript() => $_has(4);
  @$pb.TagNumber(5)
  void clearRedeemScript() => clearField(5);
  @$pb.TagNumber(5)
  DecodePsbtResponse_RedeemScript ensureRedeemScript() => $_ensure(4);

  @$pb.TagNumber(6)
  DecodePsbtResponse_RedeemScript get witnessScript => $_getN(5);
  @$pb.TagNumber(6)
  set witnessScript(DecodePsbtResponse_RedeemScript v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasWitnessScript() => $_has(5);
  @$pb.TagNumber(6)
  void clearWitnessScript() => clearField(6);
  @$pb.TagNumber(6)
  DecodePsbtResponse_RedeemScript ensureWitnessScript() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.List<DecodePsbtResponse_Bip32Deriv> get bip32Derivs => $_getList(6);

  @$pb.TagNumber(8)
  ScriptSig get finalScriptsig => $_getN(7);
  @$pb.TagNumber(8)
  set finalScriptsig(ScriptSig v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasFinalScriptsig() => $_has(7);
  @$pb.TagNumber(8)
  void clearFinalScriptsig() => clearField(8);
  @$pb.TagNumber(8)
  ScriptSig ensureFinalScriptsig() => $_ensure(7);

  @$pb.TagNumber(9)
  $core.List<$core.String> get finalScriptwitness => $_getList(8);

  @$pb.TagNumber(10)
  $core.Map<$core.String, $core.String> get unknown => $_getMap(9);
}

class DecodePsbtResponse_Output extends $pb.GeneratedMessage {
  factory DecodePsbtResponse_Output({
    DecodePsbtResponse_RedeemScript? redeemScript,
    DecodePsbtResponse_RedeemScript? witnessScript,
    $core.Iterable<DecodePsbtResponse_Bip32Deriv>? bip32Derivs,
    $core.Map<$core.String, $core.String>? unknown,
  }) {
    final $result = create();
    if (redeemScript != null) {
      $result.redeemScript = redeemScript;
    }
    if (witnessScript != null) {
      $result.witnessScript = witnessScript;
    }
    if (bip32Derivs != null) {
      $result.bip32Derivs.addAll(bip32Derivs);
    }
    if (unknown != null) {
      $result.unknown.addAll(unknown);
    }
    return $result;
  }
  DecodePsbtResponse_Output._() : super();
  factory DecodePsbtResponse_Output.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DecodePsbtResponse_Output.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodePsbtResponse.Output', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOM<DecodePsbtResponse_RedeemScript>(1, _omitFieldNames ? '' : 'redeemScript', subBuilder: DecodePsbtResponse_RedeemScript.create)
    ..aOM<DecodePsbtResponse_RedeemScript>(2, _omitFieldNames ? '' : 'witnessScript', subBuilder: DecodePsbtResponse_RedeemScript.create)
    ..pc<DecodePsbtResponse_Bip32Deriv>(3, _omitFieldNames ? '' : 'bip32Derivs', $pb.PbFieldType.PM, subBuilder: DecodePsbtResponse_Bip32Deriv.create)
    ..m<$core.String, $core.String>(4, _omitFieldNames ? '' : 'unknown', entryClassName: 'DecodePsbtResponse.Output.UnknownEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('bitcoind.v1'))
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DecodePsbtResponse_Output clone() => DecodePsbtResponse_Output()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DecodePsbtResponse_Output copyWith(void Function(DecodePsbtResponse_Output) updates) => super.copyWith((message) => updates(message as DecodePsbtResponse_Output)) as DecodePsbtResponse_Output;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse_Output create() => DecodePsbtResponse_Output._();
  DecodePsbtResponse_Output createEmptyInstance() => create();
  static $pb.PbList<DecodePsbtResponse_Output> createRepeated() => $pb.PbList<DecodePsbtResponse_Output>();
  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse_Output getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecodePsbtResponse_Output>(create);
  static DecodePsbtResponse_Output? _defaultInstance;

  @$pb.TagNumber(1)
  DecodePsbtResponse_RedeemScript get redeemScript => $_getN(0);
  @$pb.TagNumber(1)
  set redeemScript(DecodePsbtResponse_RedeemScript v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasRedeemScript() => $_has(0);
  @$pb.TagNumber(1)
  void clearRedeemScript() => clearField(1);
  @$pb.TagNumber(1)
  DecodePsbtResponse_RedeemScript ensureRedeemScript() => $_ensure(0);

  @$pb.TagNumber(2)
  DecodePsbtResponse_RedeemScript get witnessScript => $_getN(1);
  @$pb.TagNumber(2)
  set witnessScript(DecodePsbtResponse_RedeemScript v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasWitnessScript() => $_has(1);
  @$pb.TagNumber(2)
  void clearWitnessScript() => clearField(2);
  @$pb.TagNumber(2)
  DecodePsbtResponse_RedeemScript ensureWitnessScript() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.List<DecodePsbtResponse_Bip32Deriv> get bip32Derivs => $_getList(2);

  @$pb.TagNumber(4)
  $core.Map<$core.String, $core.String> get unknown => $_getMap(3);
}

class DecodePsbtResponse extends $pb.GeneratedMessage {
  factory DecodePsbtResponse({
    DecodeRawTransactionResponse? tx,
    $core.Map<$core.String, $core.String>? unknown,
    $core.Iterable<DecodePsbtResponse_Input>? inputs,
    $core.Iterable<DecodePsbtResponse_Output>? outputs,
    $core.double? fee,
  }) {
    final $result = create();
    if (tx != null) {
      $result.tx = tx;
    }
    if (unknown != null) {
      $result.unknown.addAll(unknown);
    }
    if (inputs != null) {
      $result.inputs.addAll(inputs);
    }
    if (outputs != null) {
      $result.outputs.addAll(outputs);
    }
    if (fee != null) {
      $result.fee = fee;
    }
    return $result;
  }
  DecodePsbtResponse._() : super();
  factory DecodePsbtResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DecodePsbtResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DecodePsbtResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOM<DecodeRawTransactionResponse>(1, _omitFieldNames ? '' : 'tx', subBuilder: DecodeRawTransactionResponse.create)
    ..m<$core.String, $core.String>(2, _omitFieldNames ? '' : 'unknown', entryClassName: 'DecodePsbtResponse.UnknownEntry', keyFieldType: $pb.PbFieldType.OS, valueFieldType: $pb.PbFieldType.OS, packageName: const $pb.PackageName('bitcoind.v1'))
    ..pc<DecodePsbtResponse_Input>(3, _omitFieldNames ? '' : 'inputs', $pb.PbFieldType.PM, subBuilder: DecodePsbtResponse_Input.create)
    ..pc<DecodePsbtResponse_Output>(4, _omitFieldNames ? '' : 'outputs', $pb.PbFieldType.PM, subBuilder: DecodePsbtResponse_Output.create)
    ..a<$core.double>(5, _omitFieldNames ? '' : 'fee', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DecodePsbtResponse clone() => DecodePsbtResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DecodePsbtResponse copyWith(void Function(DecodePsbtResponse) updates) => super.copyWith((message) => updates(message as DecodePsbtResponse)) as DecodePsbtResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse create() => DecodePsbtResponse._();
  DecodePsbtResponse createEmptyInstance() => create();
  static $pb.PbList<DecodePsbtResponse> createRepeated() => $pb.PbList<DecodePsbtResponse>();
  @$core.pragma('dart2js:noInline')
  static DecodePsbtResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DecodePsbtResponse>(create);
  static DecodePsbtResponse? _defaultInstance;

  @$pb.TagNumber(1)
  DecodeRawTransactionResponse get tx => $_getN(0);
  @$pb.TagNumber(1)
  set tx(DecodeRawTransactionResponse v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasTx() => $_has(0);
  @$pb.TagNumber(1)
  void clearTx() => clearField(1);
  @$pb.TagNumber(1)
  DecodeRawTransactionResponse ensureTx() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.Map<$core.String, $core.String> get unknown => $_getMap(1);

  @$pb.TagNumber(3)
  $core.List<DecodePsbtResponse_Input> get inputs => $_getList(2);

  @$pb.TagNumber(4)
  $core.List<DecodePsbtResponse_Output> get outputs => $_getList(3);

  @$pb.TagNumber(5)
  $core.double get fee => $_getN(4);
  @$pb.TagNumber(5)
  set fee($core.double v) { $_setDouble(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasFee() => $_has(4);
  @$pb.TagNumber(5)
  void clearFee() => clearField(5);
}

class AnalyzePsbtRequest extends $pb.GeneratedMessage {
  factory AnalyzePsbtRequest({
    $core.String? psbt,
  }) {
    final $result = create();
    if (psbt != null) {
      $result.psbt = psbt;
    }
    return $result;
  }
  AnalyzePsbtRequest._() : super();
  factory AnalyzePsbtRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AnalyzePsbtRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AnalyzePsbtRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AnalyzePsbtRequest clone() => AnalyzePsbtRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AnalyzePsbtRequest copyWith(void Function(AnalyzePsbtRequest) updates) => super.copyWith((message) => updates(message as AnalyzePsbtRequest)) as AnalyzePsbtRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AnalyzePsbtRequest create() => AnalyzePsbtRequest._();
  AnalyzePsbtRequest createEmptyInstance() => create();
  static $pb.PbList<AnalyzePsbtRequest> createRepeated() => $pb.PbList<AnalyzePsbtRequest>();
  @$core.pragma('dart2js:noInline')
  static AnalyzePsbtRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AnalyzePsbtRequest>(create);
  static AnalyzePsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => clearField(1);
}

class AnalyzePsbtResponse_Input_Missing extends $pb.GeneratedMessage {
  factory AnalyzePsbtResponse_Input_Missing({
    $core.Iterable<$core.String>? pubkeys,
    $core.Iterable<$core.String>? signatures,
    $core.String? redeemScript,
    $core.String? witnessScript,
  }) {
    final $result = create();
    if (pubkeys != null) {
      $result.pubkeys.addAll(pubkeys);
    }
    if (signatures != null) {
      $result.signatures.addAll(signatures);
    }
    if (redeemScript != null) {
      $result.redeemScript = redeemScript;
    }
    if (witnessScript != null) {
      $result.witnessScript = witnessScript;
    }
    return $result;
  }
  AnalyzePsbtResponse_Input_Missing._() : super();
  factory AnalyzePsbtResponse_Input_Missing.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AnalyzePsbtResponse_Input_Missing.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AnalyzePsbtResponse.Input.Missing', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'pubkeys')
    ..pPS(2, _omitFieldNames ? '' : 'signatures')
    ..aOS(3, _omitFieldNames ? '' : 'redeemScript')
    ..aOS(4, _omitFieldNames ? '' : 'witnessScript')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AnalyzePsbtResponse_Input_Missing clone() => AnalyzePsbtResponse_Input_Missing()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AnalyzePsbtResponse_Input_Missing copyWith(void Function(AnalyzePsbtResponse_Input_Missing) updates) => super.copyWith((message) => updates(message as AnalyzePsbtResponse_Input_Missing)) as AnalyzePsbtResponse_Input_Missing;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AnalyzePsbtResponse_Input_Missing create() => AnalyzePsbtResponse_Input_Missing._();
  AnalyzePsbtResponse_Input_Missing createEmptyInstance() => create();
  static $pb.PbList<AnalyzePsbtResponse_Input_Missing> createRepeated() => $pb.PbList<AnalyzePsbtResponse_Input_Missing>();
  @$core.pragma('dart2js:noInline')
  static AnalyzePsbtResponse_Input_Missing getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AnalyzePsbtResponse_Input_Missing>(create);
  static AnalyzePsbtResponse_Input_Missing? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get pubkeys => $_getList(0);

  @$pb.TagNumber(2)
  $core.List<$core.String> get signatures => $_getList(1);

  @$pb.TagNumber(3)
  $core.String get redeemScript => $_getSZ(2);
  @$pb.TagNumber(3)
  set redeemScript($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRedeemScript() => $_has(2);
  @$pb.TagNumber(3)
  void clearRedeemScript() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get witnessScript => $_getSZ(3);
  @$pb.TagNumber(4)
  set witnessScript($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasWitnessScript() => $_has(3);
  @$pb.TagNumber(4)
  void clearWitnessScript() => clearField(4);
}

class AnalyzePsbtResponse_Input extends $pb.GeneratedMessage {
  factory AnalyzePsbtResponse_Input({
    $core.bool? hasUtxo,
    $core.bool? isFinal,
    AnalyzePsbtResponse_Input_Missing? missing,
    $core.String? next,
  }) {
    final $result = create();
    if (hasUtxo != null) {
      $result.hasUtxo = hasUtxo;
    }
    if (isFinal != null) {
      $result.isFinal = isFinal;
    }
    if (missing != null) {
      $result.missing = missing;
    }
    if (next != null) {
      $result.next = next;
    }
    return $result;
  }
  AnalyzePsbtResponse_Input._() : super();
  factory AnalyzePsbtResponse_Input.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AnalyzePsbtResponse_Input.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AnalyzePsbtResponse.Input', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'hasUtxo')
    ..aOB(2, _omitFieldNames ? '' : 'isFinal')
    ..aOM<AnalyzePsbtResponse_Input_Missing>(3, _omitFieldNames ? '' : 'missing', subBuilder: AnalyzePsbtResponse_Input_Missing.create)
    ..aOS(4, _omitFieldNames ? '' : 'next')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AnalyzePsbtResponse_Input clone() => AnalyzePsbtResponse_Input()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AnalyzePsbtResponse_Input copyWith(void Function(AnalyzePsbtResponse_Input) updates) => super.copyWith((message) => updates(message as AnalyzePsbtResponse_Input)) as AnalyzePsbtResponse_Input;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AnalyzePsbtResponse_Input create() => AnalyzePsbtResponse_Input._();
  AnalyzePsbtResponse_Input createEmptyInstance() => create();
  static $pb.PbList<AnalyzePsbtResponse_Input> createRepeated() => $pb.PbList<AnalyzePsbtResponse_Input>();
  @$core.pragma('dart2js:noInline')
  static AnalyzePsbtResponse_Input getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AnalyzePsbtResponse_Input>(create);
  static AnalyzePsbtResponse_Input? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get hasUtxo => $_getBF(0);
  @$pb.TagNumber(1)
  set hasUtxo($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasHasUtxo() => $_has(0);
  @$pb.TagNumber(1)
  void clearHasUtxo() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get isFinal => $_getBF(1);
  @$pb.TagNumber(2)
  set isFinal($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasIsFinal() => $_has(1);
  @$pb.TagNumber(2)
  void clearIsFinal() => clearField(2);

  @$pb.TagNumber(3)
  AnalyzePsbtResponse_Input_Missing get missing => $_getN(2);
  @$pb.TagNumber(3)
  set missing(AnalyzePsbtResponse_Input_Missing v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasMissing() => $_has(2);
  @$pb.TagNumber(3)
  void clearMissing() => clearField(3);
  @$pb.TagNumber(3)
  AnalyzePsbtResponse_Input_Missing ensureMissing() => $_ensure(2);

  @$pb.TagNumber(4)
  $core.String get next => $_getSZ(3);
  @$pb.TagNumber(4)
  set next($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasNext() => $_has(3);
  @$pb.TagNumber(4)
  void clearNext() => clearField(4);
}

class AnalyzePsbtResponse extends $pb.GeneratedMessage {
  factory AnalyzePsbtResponse({
    $core.Iterable<AnalyzePsbtResponse_Input>? inputs,
    $core.double? estimatedVsize,
    $core.double? estimatedFeerate,
    $core.double? fee,
    $core.String? next,
    $core.String? error,
  }) {
    final $result = create();
    if (inputs != null) {
      $result.inputs.addAll(inputs);
    }
    if (estimatedVsize != null) {
      $result.estimatedVsize = estimatedVsize;
    }
    if (estimatedFeerate != null) {
      $result.estimatedFeerate = estimatedFeerate;
    }
    if (fee != null) {
      $result.fee = fee;
    }
    if (next != null) {
      $result.next = next;
    }
    if (error != null) {
      $result.error = error;
    }
    return $result;
  }
  AnalyzePsbtResponse._() : super();
  factory AnalyzePsbtResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AnalyzePsbtResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AnalyzePsbtResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..pc<AnalyzePsbtResponse_Input>(1, _omitFieldNames ? '' : 'inputs', $pb.PbFieldType.PM, subBuilder: AnalyzePsbtResponse_Input.create)
    ..a<$core.double>(2, _omitFieldNames ? '' : 'estimatedVsize', $pb.PbFieldType.OD)
    ..a<$core.double>(3, _omitFieldNames ? '' : 'estimatedFeerate', $pb.PbFieldType.OD)
    ..a<$core.double>(4, _omitFieldNames ? '' : 'fee', $pb.PbFieldType.OD)
    ..aOS(5, _omitFieldNames ? '' : 'next')
    ..aOS(6, _omitFieldNames ? '' : 'error')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AnalyzePsbtResponse clone() => AnalyzePsbtResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AnalyzePsbtResponse copyWith(void Function(AnalyzePsbtResponse) updates) => super.copyWith((message) => updates(message as AnalyzePsbtResponse)) as AnalyzePsbtResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AnalyzePsbtResponse create() => AnalyzePsbtResponse._();
  AnalyzePsbtResponse createEmptyInstance() => create();
  static $pb.PbList<AnalyzePsbtResponse> createRepeated() => $pb.PbList<AnalyzePsbtResponse>();
  @$core.pragma('dart2js:noInline')
  static AnalyzePsbtResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AnalyzePsbtResponse>(create);
  static AnalyzePsbtResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<AnalyzePsbtResponse_Input> get inputs => $_getList(0);

  @$pb.TagNumber(2)
  $core.double get estimatedVsize => $_getN(1);
  @$pb.TagNumber(2)
  set estimatedVsize($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEstimatedVsize() => $_has(1);
  @$pb.TagNumber(2)
  void clearEstimatedVsize() => clearField(2);

  @$pb.TagNumber(3)
  $core.double get estimatedFeerate => $_getN(2);
  @$pb.TagNumber(3)
  set estimatedFeerate($core.double v) { $_setDouble(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasEstimatedFeerate() => $_has(2);
  @$pb.TagNumber(3)
  void clearEstimatedFeerate() => clearField(3);

  @$pb.TagNumber(4)
  $core.double get fee => $_getN(3);
  @$pb.TagNumber(4)
  set fee($core.double v) { $_setDouble(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFee() => $_has(3);
  @$pb.TagNumber(4)
  void clearFee() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get next => $_getSZ(4);
  @$pb.TagNumber(5)
  set next($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasNext() => $_has(4);
  @$pb.TagNumber(5)
  void clearNext() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get error => $_getSZ(5);
  @$pb.TagNumber(6)
  set error($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasError() => $_has(5);
  @$pb.TagNumber(6)
  void clearError() => clearField(6);
}

class CombinePsbtRequest extends $pb.GeneratedMessage {
  factory CombinePsbtRequest({
    $core.Iterable<$core.String>? psbts,
  }) {
    final $result = create();
    if (psbts != null) {
      $result.psbts.addAll(psbts);
    }
    return $result;
  }
  CombinePsbtRequest._() : super();
  factory CombinePsbtRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CombinePsbtRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CombinePsbtRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'psbts')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CombinePsbtRequest clone() => CombinePsbtRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CombinePsbtRequest copyWith(void Function(CombinePsbtRequest) updates) => super.copyWith((message) => updates(message as CombinePsbtRequest)) as CombinePsbtRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CombinePsbtRequest create() => CombinePsbtRequest._();
  CombinePsbtRequest createEmptyInstance() => create();
  static $pb.PbList<CombinePsbtRequest> createRepeated() => $pb.PbList<CombinePsbtRequest>();
  @$core.pragma('dart2js:noInline')
  static CombinePsbtRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CombinePsbtRequest>(create);
  static CombinePsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get psbts => $_getList(0);
}

class CombinePsbtResponse extends $pb.GeneratedMessage {
  factory CombinePsbtResponse({
    $core.String? psbt,
  }) {
    final $result = create();
    if (psbt != null) {
      $result.psbt = psbt;
    }
    return $result;
  }
  CombinePsbtResponse._() : super();
  factory CombinePsbtResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CombinePsbtResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CombinePsbtResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CombinePsbtResponse clone() => CombinePsbtResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CombinePsbtResponse copyWith(void Function(CombinePsbtResponse) updates) => super.copyWith((message) => updates(message as CombinePsbtResponse)) as CombinePsbtResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CombinePsbtResponse create() => CombinePsbtResponse._();
  CombinePsbtResponse createEmptyInstance() => create();
  static $pb.PbList<CombinePsbtResponse> createRepeated() => $pb.PbList<CombinePsbtResponse>();
  @$core.pragma('dart2js:noInline')
  static CombinePsbtResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CombinePsbtResponse>(create);
  static CombinePsbtResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => clearField(1);
}

class UtxoUpdatePsbtRequest extends $pb.GeneratedMessage {
  factory UtxoUpdatePsbtRequest({
    $core.String? psbt,
    $core.Iterable<Descriptor>? descriptors,
  }) {
    final $result = create();
    if (psbt != null) {
      $result.psbt = psbt;
    }
    if (descriptors != null) {
      $result.descriptors.addAll(descriptors);
    }
    return $result;
  }
  UtxoUpdatePsbtRequest._() : super();
  factory UtxoUpdatePsbtRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UtxoUpdatePsbtRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UtxoUpdatePsbtRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..pc<Descriptor>(2, _omitFieldNames ? '' : 'descriptors', $pb.PbFieldType.PM, subBuilder: Descriptor.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UtxoUpdatePsbtRequest clone() => UtxoUpdatePsbtRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UtxoUpdatePsbtRequest copyWith(void Function(UtxoUpdatePsbtRequest) updates) => super.copyWith((message) => updates(message as UtxoUpdatePsbtRequest)) as UtxoUpdatePsbtRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UtxoUpdatePsbtRequest create() => UtxoUpdatePsbtRequest._();
  UtxoUpdatePsbtRequest createEmptyInstance() => create();
  static $pb.PbList<UtxoUpdatePsbtRequest> createRepeated() => $pb.PbList<UtxoUpdatePsbtRequest>();
  @$core.pragma('dart2js:noInline')
  static UtxoUpdatePsbtRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UtxoUpdatePsbtRequest>(create);
  static UtxoUpdatePsbtRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<Descriptor> get descriptors => $_getList(1);
}

class UtxoUpdatePsbtResponse extends $pb.GeneratedMessage {
  factory UtxoUpdatePsbtResponse({
    $core.String? psbt,
  }) {
    final $result = create();
    if (psbt != null) {
      $result.psbt = psbt;
    }
    return $result;
  }
  UtxoUpdatePsbtResponse._() : super();
  factory UtxoUpdatePsbtResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UtxoUpdatePsbtResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UtxoUpdatePsbtResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UtxoUpdatePsbtResponse clone() => UtxoUpdatePsbtResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UtxoUpdatePsbtResponse copyWith(void Function(UtxoUpdatePsbtResponse) updates) => super.copyWith((message) => updates(message as UtxoUpdatePsbtResponse)) as UtxoUpdatePsbtResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UtxoUpdatePsbtResponse create() => UtxoUpdatePsbtResponse._();
  UtxoUpdatePsbtResponse createEmptyInstance() => create();
  static $pb.PbList<UtxoUpdatePsbtResponse> createRepeated() => $pb.PbList<UtxoUpdatePsbtResponse>();
  @$core.pragma('dart2js:noInline')
  static UtxoUpdatePsbtResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UtxoUpdatePsbtResponse>(create);
  static UtxoUpdatePsbtResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => clearField(1);
}

class JoinPsbtsRequest extends $pb.GeneratedMessage {
  factory JoinPsbtsRequest({
    $core.Iterable<$core.String>? psbts,
  }) {
    final $result = create();
    if (psbts != null) {
      $result.psbts.addAll(psbts);
    }
    return $result;
  }
  JoinPsbtsRequest._() : super();
  factory JoinPsbtsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory JoinPsbtsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'JoinPsbtsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'psbts')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  JoinPsbtsRequest clone() => JoinPsbtsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  JoinPsbtsRequest copyWith(void Function(JoinPsbtsRequest) updates) => super.copyWith((message) => updates(message as JoinPsbtsRequest)) as JoinPsbtsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinPsbtsRequest create() => JoinPsbtsRequest._();
  JoinPsbtsRequest createEmptyInstance() => create();
  static $pb.PbList<JoinPsbtsRequest> createRepeated() => $pb.PbList<JoinPsbtsRequest>();
  @$core.pragma('dart2js:noInline')
  static JoinPsbtsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<JoinPsbtsRequest>(create);
  static JoinPsbtsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get psbts => $_getList(0);
}

class JoinPsbtsResponse extends $pb.GeneratedMessage {
  factory JoinPsbtsResponse({
    $core.String? psbt,
  }) {
    final $result = create();
    if (psbt != null) {
      $result.psbt = psbt;
    }
    return $result;
  }
  JoinPsbtsResponse._() : super();
  factory JoinPsbtsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory JoinPsbtsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'JoinPsbtsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'psbt')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  JoinPsbtsResponse clone() => JoinPsbtsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  JoinPsbtsResponse copyWith(void Function(JoinPsbtsResponse) updates) => super.copyWith((message) => updates(message as JoinPsbtsResponse)) as JoinPsbtsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static JoinPsbtsResponse create() => JoinPsbtsResponse._();
  JoinPsbtsResponse createEmptyInstance() => create();
  static $pb.PbList<JoinPsbtsResponse> createRepeated() => $pb.PbList<JoinPsbtsResponse>();
  @$core.pragma('dart2js:noInline')
  static JoinPsbtsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<JoinPsbtsResponse>(create);
  static JoinPsbtsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get psbt => $_getSZ(0);
  @$pb.TagNumber(1)
  set psbt($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPsbt() => $_has(0);
  @$pb.TagNumber(1)
  void clearPsbt() => clearField(1);
}

class TestMempoolAcceptRequest extends $pb.GeneratedMessage {
  factory TestMempoolAcceptRequest({
    $core.Iterable<$core.String>? rawtxs,
    $core.double? maxFeeRate,
  }) {
    final $result = create();
    if (rawtxs != null) {
      $result.rawtxs.addAll(rawtxs);
    }
    if (maxFeeRate != null) {
      $result.maxFeeRate = maxFeeRate;
    }
    return $result;
  }
  TestMempoolAcceptRequest._() : super();
  factory TestMempoolAcceptRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TestMempoolAcceptRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TestMempoolAcceptRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..pPS(1, _omitFieldNames ? '' : 'rawtxs')
    ..a<$core.double>(2, _omitFieldNames ? '' : 'maxFeeRate', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TestMempoolAcceptRequest clone() => TestMempoolAcceptRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TestMempoolAcceptRequest copyWith(void Function(TestMempoolAcceptRequest) updates) => super.copyWith((message) => updates(message as TestMempoolAcceptRequest)) as TestMempoolAcceptRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TestMempoolAcceptRequest create() => TestMempoolAcceptRequest._();
  TestMempoolAcceptRequest createEmptyInstance() => create();
  static $pb.PbList<TestMempoolAcceptRequest> createRepeated() => $pb.PbList<TestMempoolAcceptRequest>();
  @$core.pragma('dart2js:noInline')
  static TestMempoolAcceptRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TestMempoolAcceptRequest>(create);
  static TestMempoolAcceptRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.String> get rawtxs => $_getList(0);

  @$pb.TagNumber(2)
  $core.double get maxFeeRate => $_getN(1);
  @$pb.TagNumber(2)
  set maxFeeRate($core.double v) { $_setDouble(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMaxFeeRate() => $_has(1);
  @$pb.TagNumber(2)
  void clearMaxFeeRate() => clearField(2);
}

class TestMempoolAcceptResponse_Result extends $pb.GeneratedMessage {
  factory TestMempoolAcceptResponse_Result({
    $core.String? txid,
    $core.bool? allowed,
    $core.String? rejectReason,
    $core.int? vsize,
    $core.double? fees,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (allowed != null) {
      $result.allowed = allowed;
    }
    if (rejectReason != null) {
      $result.rejectReason = rejectReason;
    }
    if (vsize != null) {
      $result.vsize = vsize;
    }
    if (fees != null) {
      $result.fees = fees;
    }
    return $result;
  }
  TestMempoolAcceptResponse_Result._() : super();
  factory TestMempoolAcceptResponse_Result.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TestMempoolAcceptResponse_Result.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TestMempoolAcceptResponse.Result', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..aOB(2, _omitFieldNames ? '' : 'allowed')
    ..aOS(3, _omitFieldNames ? '' : 'rejectReason')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'vsize', $pb.PbFieldType.OU3)
    ..a<$core.double>(5, _omitFieldNames ? '' : 'fees', $pb.PbFieldType.OD)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TestMempoolAcceptResponse_Result clone() => TestMempoolAcceptResponse_Result()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TestMempoolAcceptResponse_Result copyWith(void Function(TestMempoolAcceptResponse_Result) updates) => super.copyWith((message) => updates(message as TestMempoolAcceptResponse_Result)) as TestMempoolAcceptResponse_Result;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TestMempoolAcceptResponse_Result create() => TestMempoolAcceptResponse_Result._();
  TestMempoolAcceptResponse_Result createEmptyInstance() => create();
  static $pb.PbList<TestMempoolAcceptResponse_Result> createRepeated() => $pb.PbList<TestMempoolAcceptResponse_Result>();
  @$core.pragma('dart2js:noInline')
  static TestMempoolAcceptResponse_Result getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TestMempoolAcceptResponse_Result>(create);
  static TestMempoolAcceptResponse_Result? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);

  @$pb.TagNumber(2)
  $core.bool get allowed => $_getBF(1);
  @$pb.TagNumber(2)
  set allowed($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAllowed() => $_has(1);
  @$pb.TagNumber(2)
  void clearAllowed() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get rejectReason => $_getSZ(2);
  @$pb.TagNumber(3)
  set rejectReason($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRejectReason() => $_has(2);
  @$pb.TagNumber(3)
  void clearRejectReason() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get vsize => $_getIZ(3);
  @$pb.TagNumber(4)
  set vsize($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasVsize() => $_has(3);
  @$pb.TagNumber(4)
  void clearVsize() => clearField(4);

  @$pb.TagNumber(5)
  $core.double get fees => $_getN(4);
  @$pb.TagNumber(5)
  set fees($core.double v) { $_setDouble(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasFees() => $_has(4);
  @$pb.TagNumber(5)
  void clearFees() => clearField(5);
}

class TestMempoolAcceptResponse extends $pb.GeneratedMessage {
  factory TestMempoolAcceptResponse({
    $core.Iterable<TestMempoolAcceptResponse_Result>? results,
  }) {
    final $result = create();
    if (results != null) {
      $result.results.addAll(results);
    }
    return $result;
  }
  TestMempoolAcceptResponse._() : super();
  factory TestMempoolAcceptResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TestMempoolAcceptResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TestMempoolAcceptResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..pc<TestMempoolAcceptResponse_Result>(1, _omitFieldNames ? '' : 'results', $pb.PbFieldType.PM, subBuilder: TestMempoolAcceptResponse_Result.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TestMempoolAcceptResponse clone() => TestMempoolAcceptResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TestMempoolAcceptResponse copyWith(void Function(TestMempoolAcceptResponse) updates) => super.copyWith((message) => updates(message as TestMempoolAcceptResponse)) as TestMempoolAcceptResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TestMempoolAcceptResponse create() => TestMempoolAcceptResponse._();
  TestMempoolAcceptResponse createEmptyInstance() => create();
  static $pb.PbList<TestMempoolAcceptResponse> createRepeated() => $pb.PbList<TestMempoolAcceptResponse>();
  @$core.pragma('dart2js:noInline')
  static TestMempoolAcceptResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TestMempoolAcceptResponse>(create);
  static TestMempoolAcceptResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<TestMempoolAcceptResponse_Result> get results => $_getList(0);
}

enum DescriptorRange_RangeType {
  end, 
  range, 
  notSet
}

/// Add a new message for descriptor range
class DescriptorRange extends $pb.GeneratedMessage {
  factory DescriptorRange({
    $core.int? end,
    Range? range,
  }) {
    final $result = create();
    if (end != null) {
      $result.end = end;
    }
    if (range != null) {
      $result.range = range;
    }
    return $result;
  }
  DescriptorRange._() : super();
  factory DescriptorRange.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DescriptorRange.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, DescriptorRange_RangeType> _DescriptorRange_RangeTypeByTag = {
    1 : DescriptorRange_RangeType.end,
    2 : DescriptorRange_RangeType.range,
    0 : DescriptorRange_RangeType.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DescriptorRange', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..a<$core.int>(1, _omitFieldNames ? '' : 'end', $pb.PbFieldType.O3)
    ..aOM<Range>(2, _omitFieldNames ? '' : 'range', subBuilder: Range.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DescriptorRange clone() => DescriptorRange()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DescriptorRange copyWith(void Function(DescriptorRange) updates) => super.copyWith((message) => updates(message as DescriptorRange)) as DescriptorRange;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DescriptorRange create() => DescriptorRange._();
  DescriptorRange createEmptyInstance() => create();
  static $pb.PbList<DescriptorRange> createRepeated() => $pb.PbList<DescriptorRange>();
  @$core.pragma('dart2js:noInline')
  static DescriptorRange getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DescriptorRange>(create);
  static DescriptorRange? _defaultInstance;

  DescriptorRange_RangeType whichRangeType() => _DescriptorRange_RangeTypeByTag[$_whichOneof(0)]!;
  void clearRangeType() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.int get end => $_getIZ(0);
  @$pb.TagNumber(1)
  set end($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEnd() => $_has(0);
  @$pb.TagNumber(1)
  void clearEnd() => clearField(1);

  @$pb.TagNumber(2)
  Range get range => $_getN(1);
  @$pb.TagNumber(2)
  set range(Range v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasRange() => $_has(1);
  @$pb.TagNumber(2)
  void clearRange() => clearField(2);
  @$pb.TagNumber(2)
  Range ensureRange() => $_ensure(1);
}

/// Add a new message for begin/end range
class Range extends $pb.GeneratedMessage {
  factory Range({
    $core.int? begin,
    $core.int? end,
  }) {
    final $result = create();
    if (begin != null) {
      $result.begin = begin;
    }
    if (end != null) {
      $result.end = end;
    }
    return $result;
  }
  Range._() : super();
  factory Range.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Range.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Range', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..a<$core.int>(1, _omitFieldNames ? '' : 'begin', $pb.PbFieldType.O3)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'end', $pb.PbFieldType.O3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Range clone() => Range()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Range copyWith(void Function(Range) updates) => super.copyWith((message) => updates(message as Range)) as Range;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Range create() => Range._();
  Range createEmptyInstance() => create();
  static $pb.PbList<Range> createRepeated() => $pb.PbList<Range>();
  @$core.pragma('dart2js:noInline')
  static Range getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Range>(create);
  static Range? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get begin => $_getIZ(0);
  @$pb.TagNumber(1)
  set begin($core.int v) { $_setSignedInt32(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBegin() => $_has(0);
  @$pb.TagNumber(1)
  void clearBegin() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get end => $_getIZ(1);
  @$pb.TagNumber(2)
  set end($core.int v) { $_setSignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasEnd() => $_has(1);
  @$pb.TagNumber(2)
  void clearEnd() => clearField(2);
}

enum Descriptor_Descriptor {
  stringDescriptor, 
  objectDescriptor, 
  notSet
}

/// Add a new message for descriptor
class Descriptor extends $pb.GeneratedMessage {
  factory Descriptor({
    $core.String? stringDescriptor,
    DescriptorObject? objectDescriptor,
  }) {
    final $result = create();
    if (stringDescriptor != null) {
      $result.stringDescriptor = stringDescriptor;
    }
    if (objectDescriptor != null) {
      $result.objectDescriptor = objectDescriptor;
    }
    return $result;
  }
  Descriptor._() : super();
  factory Descriptor.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Descriptor.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, Descriptor_Descriptor> _Descriptor_DescriptorByTag = {
    1 : Descriptor_Descriptor.stringDescriptor,
    2 : Descriptor_Descriptor.objectDescriptor,
    0 : Descriptor_Descriptor.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Descriptor', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..oo(0, [1, 2])
    ..aOS(1, _omitFieldNames ? '' : 'stringDescriptor')
    ..aOM<DescriptorObject>(2, _omitFieldNames ? '' : 'objectDescriptor', subBuilder: DescriptorObject.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Descriptor clone() => Descriptor()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Descriptor copyWith(void Function(Descriptor) updates) => super.copyWith((message) => updates(message as Descriptor)) as Descriptor;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Descriptor create() => Descriptor._();
  Descriptor createEmptyInstance() => create();
  static $pb.PbList<Descriptor> createRepeated() => $pb.PbList<Descriptor>();
  @$core.pragma('dart2js:noInline')
  static Descriptor getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Descriptor>(create);
  static Descriptor? _defaultInstance;

  Descriptor_Descriptor whichDescriptor() => _Descriptor_DescriptorByTag[$_whichOneof(0)]!;
  void clearDescriptor() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.String get stringDescriptor => $_getSZ(0);
  @$pb.TagNumber(1)
  set stringDescriptor($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasStringDescriptor() => $_has(0);
  @$pb.TagNumber(1)
  void clearStringDescriptor() => clearField(1);

  @$pb.TagNumber(2)
  DescriptorObject get objectDescriptor => $_getN(1);
  @$pb.TagNumber(2)
  set objectDescriptor(DescriptorObject v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasObjectDescriptor() => $_has(1);
  @$pb.TagNumber(2)
  void clearObjectDescriptor() => clearField(2);
  @$pb.TagNumber(2)
  DescriptorObject ensureObjectDescriptor() => $_ensure(1);
}

/// Add a new message for descriptor objects
class DescriptorObject extends $pb.GeneratedMessage {
  factory DescriptorObject({
    $core.String? desc,
    DescriptorRange? range,
  }) {
    final $result = create();
    if (desc != null) {
      $result.desc = desc;
    }
    if (range != null) {
      $result.range = range;
    }
    return $result;
  }
  DescriptorObject._() : super();
  factory DescriptorObject.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DescriptorObject.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DescriptorObject', package: const $pb.PackageName(_omitMessageNames ? '' : 'bitcoind.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'desc')
    ..aOM<DescriptorRange>(2, _omitFieldNames ? '' : 'range', subBuilder: DescriptorRange.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DescriptorObject clone() => DescriptorObject()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DescriptorObject copyWith(void Function(DescriptorObject) updates) => super.copyWith((message) => updates(message as DescriptorObject)) as DescriptorObject;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DescriptorObject create() => DescriptorObject._();
  DescriptorObject createEmptyInstance() => create();
  static $pb.PbList<DescriptorObject> createRepeated() => $pb.PbList<DescriptorObject>();
  @$core.pragma('dart2js:noInline')
  static DescriptorObject getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DescriptorObject>(create);
  static DescriptorObject? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get desc => $_getSZ(0);
  @$pb.TagNumber(1)
  set desc($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasDesc() => $_has(0);
  @$pb.TagNumber(1)
  void clearDesc() => clearField(1);

  @$pb.TagNumber(2)
  DescriptorRange get range => $_getN(1);
  @$pb.TagNumber(2)
  set range(DescriptorRange v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasRange() => $_has(1);
  @$pb.TagNumber(2)
  void clearRange() => clearField(2);
  @$pb.TagNumber(2)
  DescriptorRange ensureRange() => $_ensure(1);
}

class BitcoindServiceApi {
  $pb.RpcClient _client;
  BitcoindServiceApi(this._client);

  $async.Future<ListRecentTransactionsResponse> listRecentTransactions($pb.ClientContext? ctx, ListRecentTransactionsRequest request) =>
    _client.invoke<ListRecentTransactionsResponse>(ctx, 'BitcoindService', 'ListRecentTransactions', request, ListRecentTransactionsResponse())
  ;
  $async.Future<ListBlocksResponse> listBlocks($pb.ClientContext? ctx, ListBlocksRequest request) =>
    _client.invoke<ListBlocksResponse>(ctx, 'BitcoindService', 'ListBlocks', request, ListBlocksResponse())
  ;
  $async.Future<GetBlockResponse> getBlock($pb.ClientContext? ctx, GetBlockRequest request) =>
    _client.invoke<GetBlockResponse>(ctx, 'BitcoindService', 'GetBlock', request, GetBlockResponse())
  ;
  $async.Future<GetBlockchainInfoResponse> getBlockchainInfo($pb.ClientContext? ctx, $1.Empty request) =>
    _client.invoke<GetBlockchainInfoResponse>(ctx, 'BitcoindService', 'GetBlockchainInfo', request, GetBlockchainInfoResponse())
  ;
  $async.Future<ListPeersResponse> listPeers($pb.ClientContext? ctx, $1.Empty request) =>
    _client.invoke<ListPeersResponse>(ctx, 'BitcoindService', 'ListPeers', request, ListPeersResponse())
  ;
  $async.Future<EstimateSmartFeeResponse> estimateSmartFee($pb.ClientContext? ctx, EstimateSmartFeeRequest request) =>
    _client.invoke<EstimateSmartFeeResponse>(ctx, 'BitcoindService', 'EstimateSmartFee', request, EstimateSmartFeeResponse())
  ;
  $async.Future<GetRawTransactionResponse> getRawTransaction($pb.ClientContext? ctx, GetRawTransactionRequest request) =>
    _client.invoke<GetRawTransactionResponse>(ctx, 'BitcoindService', 'GetRawTransaction', request, GetRawTransactionResponse())
  ;
  $async.Future<CreateRawTransactionResponse> createRawTransaction($pb.ClientContext? ctx, CreateRawTransactionRequest request) =>
    _client.invoke<CreateRawTransactionResponse>(ctx, 'BitcoindService', 'CreateRawTransaction', request, CreateRawTransactionResponse())
  ;
  $async.Future<CreateWalletResponse> createWallet($pb.ClientContext? ctx, CreateWalletRequest request) =>
    _client.invoke<CreateWalletResponse>(ctx, 'BitcoindService', 'CreateWallet', request, CreateWalletResponse())
  ;
  $async.Future<BackupWalletResponse> backupWallet($pb.ClientContext? ctx, BackupWalletRequest request) =>
    _client.invoke<BackupWalletResponse>(ctx, 'BitcoindService', 'BackupWallet', request, BackupWalletResponse())
  ;
  $async.Future<DumpWalletResponse> dumpWallet($pb.ClientContext? ctx, DumpWalletRequest request) =>
    _client.invoke<DumpWalletResponse>(ctx, 'BitcoindService', 'DumpWallet', request, DumpWalletResponse())
  ;
  $async.Future<ImportWalletResponse> importWallet($pb.ClientContext? ctx, ImportWalletRequest request) =>
    _client.invoke<ImportWalletResponse>(ctx, 'BitcoindService', 'ImportWallet', request, ImportWalletResponse())
  ;
  $async.Future<UnloadWalletResponse> unloadWallet($pb.ClientContext? ctx, UnloadWalletRequest request) =>
    _client.invoke<UnloadWalletResponse>(ctx, 'BitcoindService', 'UnloadWallet', request, UnloadWalletResponse())
  ;
  $async.Future<DumpPrivKeyResponse> dumpPrivKey($pb.ClientContext? ctx, DumpPrivKeyRequest request) =>
    _client.invoke<DumpPrivKeyResponse>(ctx, 'BitcoindService', 'DumpPrivKey', request, DumpPrivKeyResponse())
  ;
  $async.Future<ImportPrivKeyResponse> importPrivKey($pb.ClientContext? ctx, ImportPrivKeyRequest request) =>
    _client.invoke<ImportPrivKeyResponse>(ctx, 'BitcoindService', 'ImportPrivKey', request, ImportPrivKeyResponse())
  ;
  $async.Future<ImportAddressResponse> importAddress($pb.ClientContext? ctx, ImportAddressRequest request) =>
    _client.invoke<ImportAddressResponse>(ctx, 'BitcoindService', 'ImportAddress', request, ImportAddressResponse())
  ;
  $async.Future<ImportPubKeyResponse> importPubKey($pb.ClientContext? ctx, ImportPubKeyRequest request) =>
    _client.invoke<ImportPubKeyResponse>(ctx, 'BitcoindService', 'ImportPubKey', request, ImportPubKeyResponse())
  ;
  $async.Future<KeyPoolRefillResponse> keyPoolRefill($pb.ClientContext? ctx, KeyPoolRefillRequest request) =>
    _client.invoke<KeyPoolRefillResponse>(ctx, 'BitcoindService', 'KeyPoolRefill', request, KeyPoolRefillResponse())
  ;
  $async.Future<GetAccountResponse> getAccount($pb.ClientContext? ctx, GetAccountRequest request) =>
    _client.invoke<GetAccountResponse>(ctx, 'BitcoindService', 'GetAccount', request, GetAccountResponse())
  ;
  $async.Future<SetAccountResponse> setAccount($pb.ClientContext? ctx, SetAccountRequest request) =>
    _client.invoke<SetAccountResponse>(ctx, 'BitcoindService', 'SetAccount', request, SetAccountResponse())
  ;
  $async.Future<GetAddressesByAccountResponse> getAddressesByAccount($pb.ClientContext? ctx, GetAddressesByAccountRequest request) =>
    _client.invoke<GetAddressesByAccountResponse>(ctx, 'BitcoindService', 'GetAddressesByAccount', request, GetAddressesByAccountResponse())
  ;
  $async.Future<ListAccountsResponse> listAccounts($pb.ClientContext? ctx, ListAccountsRequest request) =>
    _client.invoke<ListAccountsResponse>(ctx, 'BitcoindService', 'ListAccounts', request, ListAccountsResponse())
  ;
  $async.Future<AddMultisigAddressResponse> addMultisigAddress($pb.ClientContext? ctx, AddMultisigAddressRequest request) =>
    _client.invoke<AddMultisigAddressResponse>(ctx, 'BitcoindService', 'AddMultisigAddress', request, AddMultisigAddressResponse())
  ;
  $async.Future<CreateMultisigResponse> createMultisig($pb.ClientContext? ctx, CreateMultisigRequest request) =>
    _client.invoke<CreateMultisigResponse>(ctx, 'BitcoindService', 'CreateMultisig', request, CreateMultisigResponse())
  ;
  $async.Future<CreatePsbtResponse> createPsbt($pb.ClientContext? ctx, CreatePsbtRequest request) =>
    _client.invoke<CreatePsbtResponse>(ctx, 'BitcoindService', 'CreatePsbt', request, CreatePsbtResponse())
  ;
  $async.Future<DecodePsbtResponse> decodePsbt($pb.ClientContext? ctx, DecodePsbtRequest request) =>
    _client.invoke<DecodePsbtResponse>(ctx, 'BitcoindService', 'DecodePsbt', request, DecodePsbtResponse())
  ;
  $async.Future<AnalyzePsbtResponse> analyzePsbt($pb.ClientContext? ctx, AnalyzePsbtRequest request) =>
    _client.invoke<AnalyzePsbtResponse>(ctx, 'BitcoindService', 'AnalyzePsbt', request, AnalyzePsbtResponse())
  ;
  $async.Future<CombinePsbtResponse> combinePsbt($pb.ClientContext? ctx, CombinePsbtRequest request) =>
    _client.invoke<CombinePsbtResponse>(ctx, 'BitcoindService', 'CombinePsbt', request, CombinePsbtResponse())
  ;
  $async.Future<UtxoUpdatePsbtResponse> utxoUpdatePsbt($pb.ClientContext? ctx, UtxoUpdatePsbtRequest request) =>
    _client.invoke<UtxoUpdatePsbtResponse>(ctx, 'BitcoindService', 'UtxoUpdatePsbt', request, UtxoUpdatePsbtResponse())
  ;
  $async.Future<JoinPsbtsResponse> joinPsbts($pb.ClientContext? ctx, JoinPsbtsRequest request) =>
    _client.invoke<JoinPsbtsResponse>(ctx, 'BitcoindService', 'JoinPsbts', request, JoinPsbtsResponse())
  ;
  $async.Future<TestMempoolAcceptResponse> testMempoolAccept($pb.ClientContext? ctx, TestMempoolAcceptRequest request) =>
    _client.invoke<TestMempoolAcceptResponse>(ctx, 'BitcoindService', 'TestMempoolAccept', request, TestMempoolAcceptResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
