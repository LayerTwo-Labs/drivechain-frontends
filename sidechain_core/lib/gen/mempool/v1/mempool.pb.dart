// This is a generated file - do not edit.
//
// Generated from mempool/v1/mempool.proto.

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
import 'package:protobuf/well_known_types/google/protobuf/timestamp.pb.dart' as $0;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

/// Transaction is a mempool transaction as Core reported it when it entered.
class Transaction extends $pb.GeneratedMessage {
  factory Transaction({
    $core.String? txid,
    $fixnum.Int64? feeSats,
    $core.int? vsize,
    $0.Timestamp? time,
    $fixnum.Int64? ancestorFeeSats,
    $core.int? ancestorVsize,
    $core.int? height,
  }) {
    final result = Transaction._();
    if (txid != null) result.txid = txid;
    if (feeSats != null) result.feeSats = feeSats;
    if (vsize != null) result.vsize = vsize;
    if (time != null) result.time = time;
    if (ancestorFeeSats != null) result.ancestorFeeSats = ancestorFeeSats;
    if (ancestorVsize != null) result.ancestorVsize = ancestorVsize;
    if (height != null) result.height = height;
    return result;
  }

  Transaction._();

  factory Transaction.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Transaction()..mergeFromBuffer(data, registry);
  factory Transaction.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Transaction()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Transaction',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mempool.v1'),
      createEmptyInstance: Transaction.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'feeSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(3, _omitFieldNames ? '' : 'vsize', fieldType: $pb.PbFieldType.OU3)
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'time', subBuilder: $0.Timestamp.$_createMessage)
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'ancestorFeeSats', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aI(6, _omitFieldNames ? '' : 'ancestorVsize', fieldType: $pb.PbFieldType.OU3)
    ..aI(7, _omitFieldNames ? '' : 'height', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Transaction clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Transaction copyWith(void Function(Transaction) updates) =>
      super.copyWith((message) => updates(message as Transaction)) as Transaction;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Transaction() / Transaction.new instead')
  static Transaction create() => Transaction._();
  static $pb.GeneratedMessage $_createMessage() => Transaction._();
  @$core.override
  Transaction createEmptyInstance() => Transaction._();
  @$core.pragma('dart2js:noInline')
  static Transaction getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Transaction>(Transaction.$_createMessage);
  static Transaction? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get feeSats => $_getI64(1);
  @$pb.TagNumber(2)
  set feeSats($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFeeSats() => $_has(1);
  @$pb.TagNumber(2)
  void clearFeeSats() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get vsize => $_getIZ(2);
  @$pb.TagNumber(3)
  set vsize($core.int value) => $_setUnsignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVsize() => $_has(2);
  @$pb.TagNumber(3)
  void clearVsize() => $_clearField(3);

  @$pb.TagNumber(4)
  $0.Timestamp get time => $_getN(3);
  @$pb.TagNumber(4)
  set time($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasTime() => $_has(3);
  @$pb.TagNumber(4)
  void clearTime() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureTime() => $_ensure(3);

  /// The fee and size of the transaction with its unconfirmed ancestors.
  @$pb.TagNumber(5)
  $fixnum.Int64 get ancestorFeeSats => $_getI64(4);
  @$pb.TagNumber(5)
  set ancestorFeeSats($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasAncestorFeeSats() => $_has(4);
  @$pb.TagNumber(5)
  void clearAncestorFeeSats() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.int get ancestorVsize => $_getIZ(5);
  @$pb.TagNumber(6)
  set ancestorVsize($core.int value) => $_setUnsignedInt32(5, value);
  @$pb.TagNumber(6)
  $core.bool hasAncestorVsize() => $_has(5);
  @$pb.TagNumber(6)
  void clearAncestorVsize() => $_clearField(6);

  /// The tip height when the transaction entered.
  @$pb.TagNumber(7)
  $core.int get height => $_getIZ(6);
  @$pb.TagNumber(7)
  set height($core.int value) => $_setUnsignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasHeight() => $_has(6);
  @$pb.TagNumber(7)
  void clearHeight() => $_clearField(7);
}

class ListTransactionsRequest extends $pb.GeneratedMessage {
  factory ListTransactionsRequest({
    $core.int? count,
  }) {
    final result = ListTransactionsRequest._();
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mempool.v1'),
      createEmptyInstance: ListTransactionsRequest.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'count', fieldType: $pb.PbFieldType.OU3)
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

  /// The most transactions to give. Zero gives all.
  @$pb.TagNumber(1)
  $core.int get count => $_getIZ(0);
  @$pb.TagNumber(1)
  set count($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearCount() => $_clearField(1);
}

class ListTransactionsResponse extends $pb.GeneratedMessage {
  factory ListTransactionsResponse({
    $core.Iterable<Transaction>? transactions,
    $fixnum.Int64? total,
  }) {
    final result = ListTransactionsResponse._();
    if (transactions != null) result.transactions.addAll(transactions);
    if (total != null) result.total = total;
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
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mempool.v1'),
      createEmptyInstance: ListTransactionsResponse.$_createMessage)
    ..pPM<Transaction>(1, _omitFieldNames ? '' : 'transactions', subBuilder: Transaction.$_createMessage)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'total', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
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
  $pb.PbList<Transaction> get transactions => $_getList(0);

  /// The number of transactions in the mempool.
  @$pb.TagNumber(2)
  $fixnum.Int64 get total => $_getI64(1);
  @$pb.TagNumber(2)
  set total($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTotal() => $_has(1);
  @$pb.TagNumber(2)
  void clearTotal() => $_clearField(2);
}

class GetStatsRequest extends $pb.GeneratedMessage {
  factory GetStatsRequest({
    $core.Iterable<$core.double>? bucketEdges,
  }) {
    final result = GetStatsRequest._();
    if (bucketEdges != null) result.bucketEdges.addAll(bucketEdges);
    return result;
  }

  GetStatsRequest._();

  factory GetStatsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetStatsRequest()..mergeFromBuffer(data, registry);
  factory GetStatsRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetStatsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetStatsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mempool.v1'),
      createEmptyInstance: GetStatsRequest.$_createMessage)
    ..p<$core.double>(1, _omitFieldNames ? '' : 'bucketEdges', $pb.PbFieldType.KD)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatsRequest copyWith(void Function(GetStatsRequest) updates) =>
      super.copyWith((message) => updates(message as GetStatsRequest)) as GetStatsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetStatsRequest() / GetStatsRequest.new instead')
  static GetStatsRequest create() => GetStatsRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetStatsRequest._();
  @$core.override
  GetStatsRequest createEmptyInstance() => GetStatsRequest._();
  @$core.pragma('dart2js:noInline')
  static GetStatsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetStatsRequest>(GetStatsRequest.$_createMessage);
  static GetStatsRequest? _defaultInstance;

  /// The lower edges of the fee rate buckets in sat/vB, in ascending order.
  /// A bucket ends at the next edge. The last bucket has no end.
  @$pb.TagNumber(1)
  $pb.PbList<$core.double> get bucketEdges => $_getList(0);
}

class FeeBucket extends $pb.GeneratedMessage {
  factory FeeBucket({
    $core.double? minFeeRate,
    $fixnum.Int64? txCount,
    $fixnum.Int64? vsize,
    $fixnum.Int64? feeSats,
  }) {
    final result = FeeBucket._();
    if (minFeeRate != null) result.minFeeRate = minFeeRate;
    if (txCount != null) result.txCount = txCount;
    if (vsize != null) result.vsize = vsize;
    if (feeSats != null) result.feeSats = feeSats;
    return result;
  }

  FeeBucket._();

  factory FeeBucket.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FeeBucket()..mergeFromBuffer(data, registry);
  factory FeeBucket.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FeeBucket()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FeeBucket',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mempool.v1'),
      createEmptyInstance: FeeBucket.$_createMessage)
    ..aD(1, _omitFieldNames ? '' : 'minFeeRate')
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'txCount', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'vsize', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'feeSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FeeBucket clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FeeBucket copyWith(void Function(FeeBucket) updates) =>
      super.copyWith((message) => updates(message as FeeBucket)) as FeeBucket;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FeeBucket() / FeeBucket.new instead')
  static FeeBucket create() => FeeBucket._();
  static $pb.GeneratedMessage $_createMessage() => FeeBucket._();
  @$core.override
  FeeBucket createEmptyInstance() => FeeBucket._();
  @$core.pragma('dart2js:noInline')
  static FeeBucket getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FeeBucket>(FeeBucket.$_createMessage);
  static FeeBucket? _defaultInstance;

  /// The lower edge in sat/vB.
  @$pb.TagNumber(1)
  $core.double get minFeeRate => $_getN(0);
  @$pb.TagNumber(1)
  set minFeeRate($core.double value) => $_setDouble(0, value);
  @$pb.TagNumber(1)
  $core.bool hasMinFeeRate() => $_has(0);
  @$pb.TagNumber(1)
  void clearMinFeeRate() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get txCount => $_getI64(1);
  @$pb.TagNumber(2)
  set txCount($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTxCount() => $_has(1);
  @$pb.TagNumber(2)
  void clearTxCount() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get vsize => $_getI64(2);
  @$pb.TagNumber(3)
  set vsize($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasVsize() => $_has(2);
  @$pb.TagNumber(3)
  void clearVsize() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get feeSats => $_getI64(3);
  @$pb.TagNumber(4)
  set feeSats($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFeeSats() => $_has(3);
  @$pb.TagNumber(4)
  void clearFeeSats() => $_clearField(4);
}

class GetStatsResponse extends $pb.GeneratedMessage {
  factory GetStatsResponse({
    $fixnum.Int64? txCount,
    $fixnum.Int64? vsize,
    $fixnum.Int64? feeSats,
    $core.double? medianFeeRate,
    $core.Iterable<FeeBucket>? buckets,
  }) {
    final result = GetStatsResponse._();
    if (txCount != null) result.txCount = txCount;
    if (vsize != null) result.vsize = vsize;
    if (feeSats != null) result.feeSats = feeSats;
    if (medianFeeRate != null) result.medianFeeRate = medianFeeRate;
    if (buckets != null) result.buckets.addAll(buckets);
    return result;
  }

  GetStatsResponse._();

  factory GetStatsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetStatsResponse()..mergeFromBuffer(data, registry);
  factory GetStatsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetStatsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetStatsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mempool.v1'),
      createEmptyInstance: GetStatsResponse.$_createMessage)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'txCount', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'vsize', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'feeSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aD(4, _omitFieldNames ? '' : 'medianFeeRate')
    ..pPM<FeeBucket>(5, _omitFieldNames ? '' : 'buckets', subBuilder: FeeBucket.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetStatsResponse copyWith(void Function(GetStatsResponse) updates) =>
      super.copyWith((message) => updates(message as GetStatsResponse)) as GetStatsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetStatsResponse() / GetStatsResponse.new instead')
  static GetStatsResponse create() => GetStatsResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetStatsResponse._();
  @$core.override
  GetStatsResponse createEmptyInstance() => GetStatsResponse._();
  @$core.pragma('dart2js:noInline')
  static GetStatsResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetStatsResponse>(GetStatsResponse.$_createMessage);
  static GetStatsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get txCount => $_getI64(0);
  @$pb.TagNumber(1)
  set txCount($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxCount() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxCount() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get vsize => $_getI64(1);
  @$pb.TagNumber(2)
  set vsize($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasVsize() => $_has(1);
  @$pb.TagNumber(2)
  void clearVsize() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get feeSats => $_getI64(2);
  @$pb.TagNumber(3)
  set feeSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFeeSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearFeeSats() => $_clearField(3);

  /// The fee rate in sat/vB at the middle of the sorted rates.
  @$pb.TagNumber(4)
  $core.double get medianFeeRate => $_getN(3);
  @$pb.TagNumber(4)
  set medianFeeRate($core.double value) => $_setDouble(3, value);
  @$pb.TagNumber(4)
  $core.bool hasMedianFeeRate() => $_has(3);
  @$pb.TagNumber(4)
  void clearMedianFeeRate() => $_clearField(4);

  /// One bucket per edge of the request, in the same order.
  @$pb.TagNumber(5)
  $pb.PbList<FeeBucket> get buckets => $_getList(4);
}

class WatchStatsResponse extends $pb.GeneratedMessage {
  factory WatchStatsResponse({
    GetStatsResponse? stats,
    $core.bool? heartbeat,
  }) {
    final result = WatchStatsResponse._();
    if (stats != null) result.stats = stats;
    if (heartbeat != null) result.heartbeat = heartbeat;
    return result;
  }

  WatchStatsResponse._();

  factory WatchStatsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchStatsResponse()..mergeFromBuffer(data, registry);
  factory WatchStatsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchStatsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WatchStatsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mempool.v1'),
      createEmptyInstance: WatchStatsResponse.$_createMessage)
    ..aOM<GetStatsResponse>(1, _omitFieldNames ? '' : 'stats', subBuilder: GetStatsResponse.$_createMessage)
    ..aOB(2, _omitFieldNames ? '' : 'heartbeat')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchStatsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchStatsResponse copyWith(void Function(WatchStatsResponse) updates) =>
      super.copyWith((message) => updates(message as WatchStatsResponse)) as WatchStatsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WatchStatsResponse() / WatchStatsResponse.new instead')
  static WatchStatsResponse create() => WatchStatsResponse._();
  static $pb.GeneratedMessage $_createMessage() => WatchStatsResponse._();
  @$core.override
  WatchStatsResponse createEmptyInstance() => WatchStatsResponse._();
  @$core.pragma('dart2js:noInline')
  static WatchStatsResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<WatchStatsResponse>(WatchStatsResponse.$_createMessage);
  static WatchStatsResponse? _defaultInstance;

  /// Unset in a heartbeat frame.
  @$pb.TagNumber(1)
  GetStatsResponse get stats => $_getN(0);
  @$pb.TagNumber(1)
  set stats(GetStatsResponse value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasStats() => $_has(0);
  @$pb.TagNumber(1)
  void clearStats() => $_clearField(1);
  @$pb.TagNumber(1)
  GetStatsResponse ensureStats() => $_ensure(0);

  /// True for an idle keepalive frame that carries no stats.
  @$pb.TagNumber(2)
  $core.bool get heartbeat => $_getBF(1);
  @$pb.TagNumber(2)
  set heartbeat($core.bool value) => $_setBool(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHeartbeat() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeartbeat() => $_clearField(2);
}

class WatchTransactionsRequest extends $pb.GeneratedMessage {
  factory WatchTransactionsRequest() => WatchTransactionsRequest._();

  WatchTransactionsRequest._();

  factory WatchTransactionsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchTransactionsRequest()..mergeFromBuffer(data, registry);
  factory WatchTransactionsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchTransactionsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WatchTransactionsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mempool.v1'),
      createEmptyInstance: WatchTransactionsRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchTransactionsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchTransactionsRequest copyWith(void Function(WatchTransactionsRequest) updates) =>
      super.copyWith((message) => updates(message as WatchTransactionsRequest)) as WatchTransactionsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WatchTransactionsRequest() / WatchTransactionsRequest.new instead')
  static WatchTransactionsRequest create() => WatchTransactionsRequest._();
  static $pb.GeneratedMessage $_createMessage() => WatchTransactionsRequest._();
  @$core.override
  WatchTransactionsRequest createEmptyInstance() => WatchTransactionsRequest._();
  @$core.pragma('dart2js:noInline')
  static WatchTransactionsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WatchTransactionsRequest>(WatchTransactionsRequest.$_createMessage);
  static WatchTransactionsRequest? _defaultInstance;
}

class WatchTransactionsResponse extends $pb.GeneratedMessage {
  factory WatchTransactionsResponse({
    Snapshot? snapshot,
    $core.Iterable<Change>? changes,
    $core.bool? heartbeat,
  }) {
    final result = WatchTransactionsResponse._();
    if (snapshot != null) result.snapshot = snapshot;
    if (changes != null) result.changes.addAll(changes);
    if (heartbeat != null) result.heartbeat = heartbeat;
    return result;
  }

  WatchTransactionsResponse._();

  factory WatchTransactionsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchTransactionsResponse()..mergeFromBuffer(data, registry);
  factory WatchTransactionsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      WatchTransactionsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'WatchTransactionsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mempool.v1'),
      createEmptyInstance: WatchTransactionsResponse.$_createMessage)
    ..aOM<Snapshot>(1, _omitFieldNames ? '' : 'snapshot', subBuilder: Snapshot.$_createMessage)
    ..pPM<Change>(2, _omitFieldNames ? '' : 'changes', subBuilder: Change.$_createMessage)
    ..aOB(3, _omitFieldNames ? '' : 'heartbeat')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchTransactionsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  WatchTransactionsResponse copyWith(void Function(WatchTransactionsResponse) updates) =>
      super.copyWith((message) => updates(message as WatchTransactionsResponse)) as WatchTransactionsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use WatchTransactionsResponse() / WatchTransactionsResponse.new instead')
  static WatchTransactionsResponse create() => WatchTransactionsResponse._();
  static $pb.GeneratedMessage $_createMessage() => WatchTransactionsResponse._();
  @$core.override
  WatchTransactionsResponse createEmptyInstance() => WatchTransactionsResponse._();
  @$core.pragma('dart2js:noInline')
  static WatchTransactionsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<WatchTransactionsResponse>(WatchTransactionsResponse.$_createMessage);
  static WatchTransactionsResponse? _defaultInstance;

  /// A full mempool. A large one comes in parts: each part except the last
  /// has more set.
  @$pb.TagNumber(1)
  Snapshot get snapshot => $_getN(0);
  @$pb.TagNumber(1)
  set snapshot(Snapshot value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSnapshot() => $_has(0);
  @$pb.TagNumber(1)
  void clearSnapshot() => $_clearField(1);
  @$pb.TagNumber(1)
  Snapshot ensureSnapshot() => $_ensure(0);

  /// The changes after the newest snapshot, in order.
  @$pb.TagNumber(2)
  $pb.PbList<Change> get changes => $_getList(1);

  /// A heartbeat holds no data. It shows that the stream is alive.
  @$pb.TagNumber(3)
  $core.bool get heartbeat => $_getBF(2);
  @$pb.TagNumber(3)
  set heartbeat($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHeartbeat() => $_has(2);
  @$pb.TagNumber(3)
  void clearHeartbeat() => $_clearField(3);
}

class Snapshot extends $pb.GeneratedMessage {
  factory Snapshot({
    $core.int? height,
    $core.Iterable<Transaction>? transactions,
    $core.bool? more,
  }) {
    final result = Snapshot._();
    if (height != null) result.height = height;
    if (transactions != null) result.transactions.addAll(transactions);
    if (more != null) result.more = more;
    return result;
  }

  Snapshot._();

  factory Snapshot.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Snapshot()..mergeFromBuffer(data, registry);
  factory Snapshot.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Snapshot()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Snapshot',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mempool.v1'),
      createEmptyInstance: Snapshot.$_createMessage)
    ..aI(1, _omitFieldNames ? '' : 'height', fieldType: $pb.PbFieldType.OU3)
    ..pPM<Transaction>(2, _omitFieldNames ? '' : 'transactions', subBuilder: Transaction.$_createMessage)
    ..aOB(3, _omitFieldNames ? '' : 'more')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Snapshot clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Snapshot copyWith(void Function(Snapshot) updates) =>
      super.copyWith((message) => updates(message as Snapshot)) as Snapshot;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Snapshot() / Snapshot.new instead')
  static Snapshot create() => Snapshot._();
  static $pb.GeneratedMessage $_createMessage() => Snapshot._();
  @$core.override
  Snapshot createEmptyInstance() => Snapshot._();
  @$core.pragma('dart2js:noInline')
  static Snapshot getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Snapshot>(Snapshot.$_createMessage);
  static Snapshot? _defaultInstance;

  /// The tip height of the snapshot.
  @$pb.TagNumber(1)
  $core.int get height => $_getIZ(0);
  @$pb.TagNumber(1)
  set height($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHeight() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeight() => $_clearField(1);

  @$pb.TagNumber(2)
  $pb.PbList<Transaction> get transactions => $_getList(1);

  @$pb.TagNumber(3)
  $core.bool get more => $_getBF(2);
  @$pb.TagNumber(3)
  set more($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasMore() => $_has(2);
  @$pb.TagNumber(3)
  void clearMore() => $_clearField(3);
}

enum Change_Change { added, removed, block, notSet }

class Change extends $pb.GeneratedMessage {
  factory Change({
    Transaction? added,
    $core.String? removed,
    Block? block,
  }) {
    final result = Change._();
    if (added != null) result.added = added;
    if (removed != null) result.removed = removed;
    if (block != null) result.block = block;
    return result;
  }

  Change._();

  factory Change.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Change()..mergeFromBuffer(data, registry);
  factory Change.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Change()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, Change_Change> _Change_ChangeByTag = {
    1: Change_Change.added,
    2: Change_Change.removed,
    3: Change_Change.block,
    0: Change_Change.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Change',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mempool.v1'),
      createEmptyInstance: Change.$_createMessage)
    ..oo(0, [1, 2, 3])
    ..aOM<Transaction>(1, _omitFieldNames ? '' : 'added', subBuilder: Transaction.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'removed')
    ..aOM<Block>(3, _omitFieldNames ? '' : 'block', subBuilder: Block.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Change copyWith(void Function(Change) updates) => super.copyWith((message) => updates(message as Change)) as Change;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Change() / Change.new instead')
  static Change create() => Change._();
  static $pb.GeneratedMessage $_createMessage() => Change._();
  @$core.override
  Change createEmptyInstance() => Change._();
  @$core.pragma('dart2js:noInline')
  static Change getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Change>(Change.$_createMessage);
  static Change? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  Change_Change whichChange() => _Change_ChangeByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  void clearChange() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  Transaction get added => $_getN(0);
  @$pb.TagNumber(1)
  set added(Transaction value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAdded() => $_has(0);
  @$pb.TagNumber(1)
  void clearAdded() => $_clearField(1);
  @$pb.TagNumber(1)
  Transaction ensureAdded() => $_ensure(0);

  /// A transaction that left the mempool for a reason other than a block.
  @$pb.TagNumber(2)
  $core.String get removed => $_getSZ(1);
  @$pb.TagNumber(2)
  set removed($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasRemoved() => $_has(1);
  @$pb.TagNumber(2)
  void clearRemoved() => $_clearField(2);

  @$pb.TagNumber(3)
  Block get block => $_getN(2);
  @$pb.TagNumber(3)
  set block(Block value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasBlock() => $_has(2);
  @$pb.TagNumber(3)
  void clearBlock() => $_clearField(3);
  @$pb.TagNumber(3)
  Block ensureBlock() => $_ensure(2);
}

/// Block is a block that Core connected to or disconnected from the tip.
class Block extends $pb.GeneratedMessage {
  factory Block({
    $core.String? hash,
    $core.int? height,
    $core.bool? connected,
    $core.Iterable<$core.String>? txids,
  }) {
    final result = Block._();
    if (hash != null) result.hash = hash;
    if (height != null) result.height = height;
    if (connected != null) result.connected = connected;
    if (txids != null) result.txids.addAll(txids);
    return result;
  }

  Block._();

  factory Block.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Block()..mergeFromBuffer(data, registry);
  factory Block.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Block()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Block',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'mempool.v1'), createEmptyInstance: Block.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'hash')
    ..aI(2, _omitFieldNames ? '' : 'height', fieldType: $pb.PbFieldType.OU3)
    ..aOB(3, _omitFieldNames ? '' : 'connected')
    ..pPS(4, _omitFieldNames ? '' : 'txids')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Block copyWith(void Function(Block) updates) => super.copyWith((message) => updates(message as Block)) as Block;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Block() / Block.new instead')
  static Block create() => Block._();
  static $pb.GeneratedMessage $_createMessage() => Block._();
  @$core.override
  Block createEmptyInstance() => Block._();
  @$core.pragma('dart2js:noInline')
  static Block getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Block>(Block.$_createMessage);
  static Block? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get hash => $_getSZ(0);
  @$pb.TagNumber(1)
  set hash($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearHash() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get height => $_getIZ(1);
  @$pb.TagNumber(2)
  set height($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHeight() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeight() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.bool get connected => $_getBF(2);
  @$pb.TagNumber(3)
  set connected($core.bool value) => $_setBool(2, value);
  @$pb.TagNumber(3)
  $core.bool hasConnected() => $_has(2);
  @$pb.TagNumber(3)
  void clearConnected() => $_clearField(3);

  /// The transactions of the block, in block order.
  @$pb.TagNumber(4)
  $pb.PbList<$core.String> get txids => $_getList(3);
}

/// MempoolService reads the mainchain mempool from the memory of drivechaind.
/// Core's ZMQ sequence feed keeps that copy current.
class MempoolServiceApi {
  final $pb.RpcClient _client;

  MempoolServiceApi(this._client);

  /// ListTransactions gives the newest mempool transactions, newest first.
  $async.Future<ListTransactionsResponse> listTransactions($pb.ClientContext? ctx, ListTransactionsRequest request) =>
      _client.invoke<ListTransactionsResponse>(
          ctx, 'MempoolService', 'ListTransactions', request, ListTransactionsResponse());

  /// GetStats gives the size of the mempool and its fee rate buckets.
  $async.Future<GetStatsResponse> getStats($pb.ClientContext? ctx, GetStatsRequest request) =>
      _client.invoke<GetStatsResponse>(ctx, 'MempoolService', 'GetStats', request, GetStatsResponse());

  /// WatchStats sends the GetStats result, then the result again on each change.
  $async.Future<WatchStatsResponse> watchStats($pb.ClientContext? ctx, GetStatsRequest request) =>
      _client.invoke<WatchStatsResponse>(ctx, 'MempoolService', 'WatchStats', request, WatchStatsResponse());

  /// WatchTransactions sends the full mempool, then each change. A new full
  /// mempool replaces the old one.
  $async.Future<WatchTransactionsResponse> watchTransactions(
          $pb.ClientContext? ctx, WatchTransactionsRequest request) =>
      _client.invoke<WatchTransactionsResponse>(
          ctx, 'MempoolService', 'WatchTransactions', request, WatchTransactionsResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
