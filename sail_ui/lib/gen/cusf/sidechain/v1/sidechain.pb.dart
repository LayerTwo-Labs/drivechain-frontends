//
//  Generated code. Do not modify.
//  source: cusf/sidechain/v1/sidechain.proto
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

class SequenceId extends $pb.GeneratedMessage {
  factory SequenceId({
    $fixnum.Int64? sequenceId,
  }) {
    final $result = create();
    if (sequenceId != null) {
      $result.sequenceId = sequenceId;
    }
    return $result;
  }
  SequenceId._() : super();
  factory SequenceId.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SequenceId.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SequenceId', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'sequenceId', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SequenceId clone() => SequenceId()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SequenceId copyWith(void Function(SequenceId) updates) => super.copyWith((message) => updates(message as SequenceId)) as SequenceId;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SequenceId create() => SequenceId._();
  SequenceId createEmptyInstance() => create();
  static $pb.PbList<SequenceId> createRepeated() => $pb.PbList<SequenceId>();
  @$core.pragma('dart2js:noInline')
  static SequenceId getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SequenceId>(create);
  static SequenceId? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get sequenceId => $_getI64(0);
  @$pb.TagNumber(1)
  set sequenceId($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSequenceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSequenceId() => clearField(1);
}

class BlockHeaderInfo extends $pb.GeneratedMessage {
  factory BlockHeaderInfo({
    $core.List<$core.int>? blockHash,
    $core.List<$core.int>? prevBlockHash,
    $core.List<$core.int>? prevMainBlockHash,
    $core.int? height,
  }) {
    final $result = create();
    if (blockHash != null) {
      $result.blockHash = blockHash;
    }
    if (prevBlockHash != null) {
      $result.prevBlockHash = prevBlockHash;
    }
    if (prevMainBlockHash != null) {
      $result.prevMainBlockHash = prevMainBlockHash;
    }
    if (height != null) {
      $result.height = height;
    }
    return $result;
  }
  BlockHeaderInfo._() : super();
  factory BlockHeaderInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BlockHeaderInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BlockHeaderInfo', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'blockHash', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'prevBlockHash', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'prevMainBlockHash', $pb.PbFieldType.OY)
    ..a<$core.int>(4, _omitFieldNames ? '' : 'height', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BlockHeaderInfo clone() => BlockHeaderInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BlockHeaderInfo copyWith(void Function(BlockHeaderInfo) updates) => super.copyWith((message) => updates(message as BlockHeaderInfo)) as BlockHeaderInfo;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlockHeaderInfo create() => BlockHeaderInfo._();
  BlockHeaderInfo createEmptyInstance() => create();
  static $pb.PbList<BlockHeaderInfo> createRepeated() => $pb.PbList<BlockHeaderInfo>();
  @$core.pragma('dart2js:noInline')
  static BlockHeaderInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BlockHeaderInfo>(create);
  static BlockHeaderInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get blockHash => $_getN(0);
  @$pb.TagNumber(1)
  set blockHash($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBlockHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHash() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get prevBlockHash => $_getN(1);
  @$pb.TagNumber(2)
  set prevBlockHash($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPrevBlockHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrevBlockHash() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get prevMainBlockHash => $_getN(2);
  @$pb.TagNumber(3)
  set prevMainBlockHash($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasPrevMainBlockHash() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrevMainBlockHash() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get height => $_getIZ(3);
  @$pb.TagNumber(4)
  set height($core.int v) { $_setUnsignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasHeight() => $_has(3);
  @$pb.TagNumber(4)
  void clearHeight() => clearField(4);
}

class BlockInfo extends $pb.GeneratedMessage {
  factory BlockInfo() => create();
  BlockInfo._() : super();
  factory BlockInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BlockInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BlockInfo', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BlockInfo clone() => BlockInfo()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BlockInfo copyWith(void Function(BlockInfo) updates) => super.copyWith((message) => updates(message as BlockInfo)) as BlockInfo;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BlockInfo create() => BlockInfo._();
  BlockInfo createEmptyInstance() => create();
  static $pb.PbList<BlockInfo> createRepeated() => $pb.PbList<BlockInfo>();
  @$core.pragma('dart2js:noInline')
  static BlockInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BlockInfo>(create);
  static BlockInfo? _defaultInstance;
}

class GetMempoolTxsRequest extends $pb.GeneratedMessage {
  factory GetMempoolTxsRequest() => create();
  GetMempoolTxsRequest._() : super();
  factory GetMempoolTxsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetMempoolTxsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetMempoolTxsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetMempoolTxsRequest clone() => GetMempoolTxsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetMempoolTxsRequest copyWith(void Function(GetMempoolTxsRequest) updates) => super.copyWith((message) => updates(message as GetMempoolTxsRequest)) as GetMempoolTxsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMempoolTxsRequest create() => GetMempoolTxsRequest._();
  GetMempoolTxsRequest createEmptyInstance() => create();
  static $pb.PbList<GetMempoolTxsRequest> createRepeated() => $pb.PbList<GetMempoolTxsRequest>();
  @$core.pragma('dart2js:noInline')
  static GetMempoolTxsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetMempoolTxsRequest>(create);
  static GetMempoolTxsRequest? _defaultInstance;
}

class GetMempoolTxsResponse extends $pb.GeneratedMessage {
  factory GetMempoolTxsResponse({
    SequenceId? sequenceId,
  }) {
    final $result = create();
    if (sequenceId != null) {
      $result.sequenceId = sequenceId;
    }
    return $result;
  }
  GetMempoolTxsResponse._() : super();
  factory GetMempoolTxsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetMempoolTxsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetMempoolTxsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'), createEmptyInstance: create)
    ..aOM<SequenceId>(1, _omitFieldNames ? '' : 'sequenceId', subBuilder: SequenceId.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetMempoolTxsResponse clone() => GetMempoolTxsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetMempoolTxsResponse copyWith(void Function(GetMempoolTxsResponse) updates) => super.copyWith((message) => updates(message as GetMempoolTxsResponse)) as GetMempoolTxsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetMempoolTxsResponse create() => GetMempoolTxsResponse._();
  GetMempoolTxsResponse createEmptyInstance() => create();
  static $pb.PbList<GetMempoolTxsResponse> createRepeated() => $pb.PbList<GetMempoolTxsResponse>();
  @$core.pragma('dart2js:noInline')
  static GetMempoolTxsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetMempoolTxsResponse>(create);
  static GetMempoolTxsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SequenceId get sequenceId => $_getN(0);
  @$pb.TagNumber(1)
  set sequenceId(SequenceId v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSequenceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSequenceId() => clearField(1);
  @$pb.TagNumber(1)
  SequenceId ensureSequenceId() => $_ensure(0);
}

class GetUtxosRequest extends $pb.GeneratedMessage {
  factory GetUtxosRequest() => create();
  GetUtxosRequest._() : super();
  factory GetUtxosRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetUtxosRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetUtxosRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetUtxosRequest clone() => GetUtxosRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetUtxosRequest copyWith(void Function(GetUtxosRequest) updates) => super.copyWith((message) => updates(message as GetUtxosRequest)) as GetUtxosRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUtxosRequest create() => GetUtxosRequest._();
  GetUtxosRequest createEmptyInstance() => create();
  static $pb.PbList<GetUtxosRequest> createRepeated() => $pb.PbList<GetUtxosRequest>();
  @$core.pragma('dart2js:noInline')
  static GetUtxosRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetUtxosRequest>(create);
  static GetUtxosRequest? _defaultInstance;
}

class GetUtxosResponse extends $pb.GeneratedMessage {
  factory GetUtxosResponse() => create();
  GetUtxosResponse._() : super();
  factory GetUtxosResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GetUtxosResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetUtxosResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GetUtxosResponse clone() => GetUtxosResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GetUtxosResponse copyWith(void Function(GetUtxosResponse) updates) => super.copyWith((message) => updates(message as GetUtxosResponse)) as GetUtxosResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GetUtxosResponse create() => GetUtxosResponse._();
  GetUtxosResponse createEmptyInstance() => create();
  static $pb.PbList<GetUtxosResponse> createRepeated() => $pb.PbList<GetUtxosResponse>();
  @$core.pragma('dart2js:noInline')
  static GetUtxosResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetUtxosResponse>(create);
  static GetUtxosResponse? _defaultInstance;
}

class SubmitTransactionRequest extends $pb.GeneratedMessage {
  factory SubmitTransactionRequest({
    $core.List<$core.int>? transaction,
  }) {
    final $result = create();
    if (transaction != null) {
      $result.transaction = transaction;
    }
    return $result;
  }
  SubmitTransactionRequest._() : super();
  factory SubmitTransactionRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SubmitTransactionRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubmitTransactionRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'transaction', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SubmitTransactionRequest clone() => SubmitTransactionRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SubmitTransactionRequest copyWith(void Function(SubmitTransactionRequest) updates) => super.copyWith((message) => updates(message as SubmitTransactionRequest)) as SubmitTransactionRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubmitTransactionRequest create() => SubmitTransactionRequest._();
  SubmitTransactionRequest createEmptyInstance() => create();
  static $pb.PbList<SubmitTransactionRequest> createRepeated() => $pb.PbList<SubmitTransactionRequest>();
  @$core.pragma('dart2js:noInline')
  static SubmitTransactionRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubmitTransactionRequest>(create);
  static SubmitTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get transaction => $_getN(0);
  @$pb.TagNumber(1)
  set transaction($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTransaction() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransaction() => clearField(1);
}

class SubmitTransactionResponse extends $pb.GeneratedMessage {
  factory SubmitTransactionResponse() => create();
  SubmitTransactionResponse._() : super();
  factory SubmitTransactionResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SubmitTransactionResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubmitTransactionResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SubmitTransactionResponse clone() => SubmitTransactionResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SubmitTransactionResponse copyWith(void Function(SubmitTransactionResponse) updates) => super.copyWith((message) => updates(message as SubmitTransactionResponse)) as SubmitTransactionResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubmitTransactionResponse create() => SubmitTransactionResponse._();
  SubmitTransactionResponse createEmptyInstance() => create();
  static $pb.PbList<SubmitTransactionResponse> createRepeated() => $pb.PbList<SubmitTransactionResponse>();
  @$core.pragma('dart2js:noInline')
  static SubmitTransactionResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubmitTransactionResponse>(create);
  static SubmitTransactionResponse? _defaultInstance;
}

class SubscribeEventsRequest extends $pb.GeneratedMessage {
  factory SubscribeEventsRequest() => create();
  SubscribeEventsRequest._() : super();
  factory SubscribeEventsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SubscribeEventsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubscribeEventsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SubscribeEventsRequest clone() => SubscribeEventsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SubscribeEventsRequest copyWith(void Function(SubscribeEventsRequest) updates) => super.copyWith((message) => updates(message as SubscribeEventsRequest)) as SubscribeEventsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubscribeEventsRequest create() => SubscribeEventsRequest._();
  SubscribeEventsRequest createEmptyInstance() => create();
  static $pb.PbList<SubscribeEventsRequest> createRepeated() => $pb.PbList<SubscribeEventsRequest>();
  @$core.pragma('dart2js:noInline')
  static SubscribeEventsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubscribeEventsRequest>(create);
  static SubscribeEventsRequest? _defaultInstance;
}

class SubscribeEventsResponse_Event_ConnectBlock extends $pb.GeneratedMessage {
  factory SubscribeEventsResponse_Event_ConnectBlock({
    BlockHeaderInfo? headerInfo,
    BlockInfo? blockInfo,
  }) {
    final $result = create();
    if (headerInfo != null) {
      $result.headerInfo = headerInfo;
    }
    if (blockInfo != null) {
      $result.blockInfo = blockInfo;
    }
    return $result;
  }
  SubscribeEventsResponse_Event_ConnectBlock._() : super();
  factory SubscribeEventsResponse_Event_ConnectBlock.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SubscribeEventsResponse_Event_ConnectBlock.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubscribeEventsResponse.Event.ConnectBlock', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'), createEmptyInstance: create)
    ..aOM<BlockHeaderInfo>(1, _omitFieldNames ? '' : 'headerInfo', subBuilder: BlockHeaderInfo.create)
    ..aOM<BlockInfo>(2, _omitFieldNames ? '' : 'blockInfo', subBuilder: BlockInfo.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SubscribeEventsResponse_Event_ConnectBlock clone() => SubscribeEventsResponse_Event_ConnectBlock()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SubscribeEventsResponse_Event_ConnectBlock copyWith(void Function(SubscribeEventsResponse_Event_ConnectBlock) updates) => super.copyWith((message) => updates(message as SubscribeEventsResponse_Event_ConnectBlock)) as SubscribeEventsResponse_Event_ConnectBlock;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubscribeEventsResponse_Event_ConnectBlock create() => SubscribeEventsResponse_Event_ConnectBlock._();
  SubscribeEventsResponse_Event_ConnectBlock createEmptyInstance() => create();
  static $pb.PbList<SubscribeEventsResponse_Event_ConnectBlock> createRepeated() => $pb.PbList<SubscribeEventsResponse_Event_ConnectBlock>();
  @$core.pragma('dart2js:noInline')
  static SubscribeEventsResponse_Event_ConnectBlock getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubscribeEventsResponse_Event_ConnectBlock>(create);
  static SubscribeEventsResponse_Event_ConnectBlock? _defaultInstance;

  @$pb.TagNumber(1)
  BlockHeaderInfo get headerInfo => $_getN(0);
  @$pb.TagNumber(1)
  set headerInfo(BlockHeaderInfo v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasHeaderInfo() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeaderInfo() => clearField(1);
  @$pb.TagNumber(1)
  BlockHeaderInfo ensureHeaderInfo() => $_ensure(0);

  @$pb.TagNumber(2)
  BlockInfo get blockInfo => $_getN(1);
  @$pb.TagNumber(2)
  set blockInfo(BlockInfo v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasBlockInfo() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlockInfo() => clearField(2);
  @$pb.TagNumber(2)
  BlockInfo ensureBlockInfo() => $_ensure(1);
}

class SubscribeEventsResponse_Event_DisconnectBlock extends $pb.GeneratedMessage {
  factory SubscribeEventsResponse_Event_DisconnectBlock({
    $core.List<$core.int>? blockHash,
  }) {
    final $result = create();
    if (blockHash != null) {
      $result.blockHash = blockHash;
    }
    return $result;
  }
  SubscribeEventsResponse_Event_DisconnectBlock._() : super();
  factory SubscribeEventsResponse_Event_DisconnectBlock.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SubscribeEventsResponse_Event_DisconnectBlock.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubscribeEventsResponse.Event.DisconnectBlock', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'blockHash', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SubscribeEventsResponse_Event_DisconnectBlock clone() => SubscribeEventsResponse_Event_DisconnectBlock()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SubscribeEventsResponse_Event_DisconnectBlock copyWith(void Function(SubscribeEventsResponse_Event_DisconnectBlock) updates) => super.copyWith((message) => updates(message as SubscribeEventsResponse_Event_DisconnectBlock)) as SubscribeEventsResponse_Event_DisconnectBlock;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubscribeEventsResponse_Event_DisconnectBlock create() => SubscribeEventsResponse_Event_DisconnectBlock._();
  SubscribeEventsResponse_Event_DisconnectBlock createEmptyInstance() => create();
  static $pb.PbList<SubscribeEventsResponse_Event_DisconnectBlock> createRepeated() => $pb.PbList<SubscribeEventsResponse_Event_DisconnectBlock>();
  @$core.pragma('dart2js:noInline')
  static SubscribeEventsResponse_Event_DisconnectBlock getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubscribeEventsResponse_Event_DisconnectBlock>(create);
  static SubscribeEventsResponse_Event_DisconnectBlock? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get blockHash => $_getN(0);
  @$pb.TagNumber(1)
  set blockHash($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasBlockHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHash() => clearField(1);
}

class SubscribeEventsResponse_Event_MempoolTxAdded extends $pb.GeneratedMessage {
  factory SubscribeEventsResponse_Event_MempoolTxAdded({
    $core.List<$core.int>? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  SubscribeEventsResponse_Event_MempoolTxAdded._() : super();
  factory SubscribeEventsResponse_Event_MempoolTxAdded.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SubscribeEventsResponse_Event_MempoolTxAdded.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubscribeEventsResponse.Event.MempoolTxAdded', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'txid', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SubscribeEventsResponse_Event_MempoolTxAdded clone() => SubscribeEventsResponse_Event_MempoolTxAdded()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SubscribeEventsResponse_Event_MempoolTxAdded copyWith(void Function(SubscribeEventsResponse_Event_MempoolTxAdded) updates) => super.copyWith((message) => updates(message as SubscribeEventsResponse_Event_MempoolTxAdded)) as SubscribeEventsResponse_Event_MempoolTxAdded;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubscribeEventsResponse_Event_MempoolTxAdded create() => SubscribeEventsResponse_Event_MempoolTxAdded._();
  SubscribeEventsResponse_Event_MempoolTxAdded createEmptyInstance() => create();
  static $pb.PbList<SubscribeEventsResponse_Event_MempoolTxAdded> createRepeated() => $pb.PbList<SubscribeEventsResponse_Event_MempoolTxAdded>();
  @$core.pragma('dart2js:noInline')
  static SubscribeEventsResponse_Event_MempoolTxAdded getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubscribeEventsResponse_Event_MempoolTxAdded>(create);
  static SubscribeEventsResponse_Event_MempoolTxAdded? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get txid => $_getN(0);
  @$pb.TagNumber(1)
  set txid($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class SubscribeEventsResponse_Event_MempoolTxRemoved extends $pb.GeneratedMessage {
  factory SubscribeEventsResponse_Event_MempoolTxRemoved({
    $core.List<$core.int>? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  SubscribeEventsResponse_Event_MempoolTxRemoved._() : super();
  factory SubscribeEventsResponse_Event_MempoolTxRemoved.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SubscribeEventsResponse_Event_MempoolTxRemoved.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubscribeEventsResponse.Event.MempoolTxRemoved', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'txid', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SubscribeEventsResponse_Event_MempoolTxRemoved clone() => SubscribeEventsResponse_Event_MempoolTxRemoved()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SubscribeEventsResponse_Event_MempoolTxRemoved copyWith(void Function(SubscribeEventsResponse_Event_MempoolTxRemoved) updates) => super.copyWith((message) => updates(message as SubscribeEventsResponse_Event_MempoolTxRemoved)) as SubscribeEventsResponse_Event_MempoolTxRemoved;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubscribeEventsResponse_Event_MempoolTxRemoved create() => SubscribeEventsResponse_Event_MempoolTxRemoved._();
  SubscribeEventsResponse_Event_MempoolTxRemoved createEmptyInstance() => create();
  static $pb.PbList<SubscribeEventsResponse_Event_MempoolTxRemoved> createRepeated() => $pb.PbList<SubscribeEventsResponse_Event_MempoolTxRemoved>();
  @$core.pragma('dart2js:noInline')
  static SubscribeEventsResponse_Event_MempoolTxRemoved getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubscribeEventsResponse_Event_MempoolTxRemoved>(create);
  static SubscribeEventsResponse_Event_MempoolTxRemoved? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get txid => $_getN(0);
  @$pb.TagNumber(1)
  set txid($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

enum SubscribeEventsResponse_Event_Event {
  connectBlock, 
  disconnectBlock, 
  mempoolTxAdded, 
  mempoolTxRemoved, 
  notSet
}

class SubscribeEventsResponse_Event extends $pb.GeneratedMessage {
  factory SubscribeEventsResponse_Event({
    SubscribeEventsResponse_Event_ConnectBlock? connectBlock,
    SubscribeEventsResponse_Event_DisconnectBlock? disconnectBlock,
    SubscribeEventsResponse_Event_MempoolTxAdded? mempoolTxAdded,
    SubscribeEventsResponse_Event_MempoolTxRemoved? mempoolTxRemoved,
  }) {
    final $result = create();
    if (connectBlock != null) {
      $result.connectBlock = connectBlock;
    }
    if (disconnectBlock != null) {
      $result.disconnectBlock = disconnectBlock;
    }
    if (mempoolTxAdded != null) {
      $result.mempoolTxAdded = mempoolTxAdded;
    }
    if (mempoolTxRemoved != null) {
      $result.mempoolTxRemoved = mempoolTxRemoved;
    }
    return $result;
  }
  SubscribeEventsResponse_Event._() : super();
  factory SubscribeEventsResponse_Event.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SubscribeEventsResponse_Event.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, SubscribeEventsResponse_Event_Event> _SubscribeEventsResponse_Event_EventByTag = {
    1 : SubscribeEventsResponse_Event_Event.connectBlock,
    2 : SubscribeEventsResponse_Event_Event.disconnectBlock,
    3 : SubscribeEventsResponse_Event_Event.mempoolTxAdded,
    4 : SubscribeEventsResponse_Event_Event.mempoolTxRemoved,
    0 : SubscribeEventsResponse_Event_Event.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubscribeEventsResponse.Event', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'), createEmptyInstance: create)
    ..oo(0, [1, 2, 3, 4])
    ..aOM<SubscribeEventsResponse_Event_ConnectBlock>(1, _omitFieldNames ? '' : 'connectBlock', subBuilder: SubscribeEventsResponse_Event_ConnectBlock.create)
    ..aOM<SubscribeEventsResponse_Event_DisconnectBlock>(2, _omitFieldNames ? '' : 'disconnectBlock', subBuilder: SubscribeEventsResponse_Event_DisconnectBlock.create)
    ..aOM<SubscribeEventsResponse_Event_MempoolTxAdded>(3, _omitFieldNames ? '' : 'mempoolTxAdded', subBuilder: SubscribeEventsResponse_Event_MempoolTxAdded.create)
    ..aOM<SubscribeEventsResponse_Event_MempoolTxRemoved>(4, _omitFieldNames ? '' : 'mempoolTxRemoved', subBuilder: SubscribeEventsResponse_Event_MempoolTxRemoved.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SubscribeEventsResponse_Event clone() => SubscribeEventsResponse_Event()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SubscribeEventsResponse_Event copyWith(void Function(SubscribeEventsResponse_Event) updates) => super.copyWith((message) => updates(message as SubscribeEventsResponse_Event)) as SubscribeEventsResponse_Event;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubscribeEventsResponse_Event create() => SubscribeEventsResponse_Event._();
  SubscribeEventsResponse_Event createEmptyInstance() => create();
  static $pb.PbList<SubscribeEventsResponse_Event> createRepeated() => $pb.PbList<SubscribeEventsResponse_Event>();
  @$core.pragma('dart2js:noInline')
  static SubscribeEventsResponse_Event getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubscribeEventsResponse_Event>(create);
  static SubscribeEventsResponse_Event? _defaultInstance;

  SubscribeEventsResponse_Event_Event whichEvent() => _SubscribeEventsResponse_Event_EventByTag[$_whichOneof(0)]!;
  void clearEvent() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  SubscribeEventsResponse_Event_ConnectBlock get connectBlock => $_getN(0);
  @$pb.TagNumber(1)
  set connectBlock(SubscribeEventsResponse_Event_ConnectBlock v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasConnectBlock() => $_has(0);
  @$pb.TagNumber(1)
  void clearConnectBlock() => clearField(1);
  @$pb.TagNumber(1)
  SubscribeEventsResponse_Event_ConnectBlock ensureConnectBlock() => $_ensure(0);

  @$pb.TagNumber(2)
  SubscribeEventsResponse_Event_DisconnectBlock get disconnectBlock => $_getN(1);
  @$pb.TagNumber(2)
  set disconnectBlock(SubscribeEventsResponse_Event_DisconnectBlock v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasDisconnectBlock() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisconnectBlock() => clearField(2);
  @$pb.TagNumber(2)
  SubscribeEventsResponse_Event_DisconnectBlock ensureDisconnectBlock() => $_ensure(1);

  @$pb.TagNumber(3)
  SubscribeEventsResponse_Event_MempoolTxAdded get mempoolTxAdded => $_getN(2);
  @$pb.TagNumber(3)
  set mempoolTxAdded(SubscribeEventsResponse_Event_MempoolTxAdded v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasMempoolTxAdded() => $_has(2);
  @$pb.TagNumber(3)
  void clearMempoolTxAdded() => clearField(3);
  @$pb.TagNumber(3)
  SubscribeEventsResponse_Event_MempoolTxAdded ensureMempoolTxAdded() => $_ensure(2);

  @$pb.TagNumber(4)
  SubscribeEventsResponse_Event_MempoolTxRemoved get mempoolTxRemoved => $_getN(3);
  @$pb.TagNumber(4)
  set mempoolTxRemoved(SubscribeEventsResponse_Event_MempoolTxRemoved v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasMempoolTxRemoved() => $_has(3);
  @$pb.TagNumber(4)
  void clearMempoolTxRemoved() => clearField(4);
  @$pb.TagNumber(4)
  SubscribeEventsResponse_Event_MempoolTxRemoved ensureMempoolTxRemoved() => $_ensure(3);
}

class SubscribeEventsResponse extends $pb.GeneratedMessage {
  factory SubscribeEventsResponse({
    SequenceId? sequenceId,
    SubscribeEventsResponse_Event? event,
  }) {
    final $result = create();
    if (sequenceId != null) {
      $result.sequenceId = sequenceId;
    }
    if (event != null) {
      $result.event = event;
    }
    return $result;
  }
  SubscribeEventsResponse._() : super();
  factory SubscribeEventsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SubscribeEventsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubscribeEventsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'), createEmptyInstance: create)
    ..aOM<SequenceId>(1, _omitFieldNames ? '' : 'sequenceId', subBuilder: SequenceId.create)
    ..aOM<SubscribeEventsResponse_Event>(2, _omitFieldNames ? '' : 'event', subBuilder: SubscribeEventsResponse_Event.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SubscribeEventsResponse clone() => SubscribeEventsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SubscribeEventsResponse copyWith(void Function(SubscribeEventsResponse) updates) => super.copyWith((message) => updates(message as SubscribeEventsResponse)) as SubscribeEventsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SubscribeEventsResponse create() => SubscribeEventsResponse._();
  SubscribeEventsResponse createEmptyInstance() => create();
  static $pb.PbList<SubscribeEventsResponse> createRepeated() => $pb.PbList<SubscribeEventsResponse>();
  @$core.pragma('dart2js:noInline')
  static SubscribeEventsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubscribeEventsResponse>(create);
  static SubscribeEventsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SequenceId get sequenceId => $_getN(0);
  @$pb.TagNumber(1)
  set sequenceId(SequenceId v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSequenceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSequenceId() => clearField(1);
  @$pb.TagNumber(1)
  SequenceId ensureSequenceId() => $_ensure(0);

  @$pb.TagNumber(2)
  SubscribeEventsResponse_Event get event => $_getN(1);
  @$pb.TagNumber(2)
  set event(SubscribeEventsResponse_Event v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasEvent() => $_has(1);
  @$pb.TagNumber(2)
  void clearEvent() => clearField(2);
  @$pb.TagNumber(2)
  SubscribeEventsResponse_Event ensureEvent() => $_ensure(1);
}

class SidechainServiceApi {
  $pb.RpcClient _client;
  SidechainServiceApi(this._client);

  $async.Future<GetMempoolTxsResponse> getMempoolTxs($pb.ClientContext? ctx, GetMempoolTxsRequest request) =>
    _client.invoke<GetMempoolTxsResponse>(ctx, 'SidechainService', 'GetMempoolTxs', request, GetMempoolTxsResponse())
  ;
  $async.Future<GetUtxosResponse> getUtxos($pb.ClientContext? ctx, GetUtxosRequest request) =>
    _client.invoke<GetUtxosResponse>(ctx, 'SidechainService', 'GetUtxos', request, GetUtxosResponse())
  ;
  $async.Future<SubmitTransactionResponse> submitTransaction($pb.ClientContext? ctx, SubmitTransactionRequest request) =>
    _client.invoke<SubmitTransactionResponse>(ctx, 'SidechainService', 'SubmitTransaction', request, SubmitTransactionResponse())
  ;
  $async.Future<SubscribeEventsResponse> subscribeEvents($pb.ClientContext? ctx, SubscribeEventsRequest request) =>
    _client.invoke<SubscribeEventsResponse>(ctx, 'SidechainService', 'SubscribeEvents', request, SubscribeEventsResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
