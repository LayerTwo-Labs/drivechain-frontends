// This is a generated file - do not edit.
//
// Generated from cusf/sidechain/v1/sidechain.proto.

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

class SequenceId extends $pb.GeneratedMessage {
  factory SequenceId({
    $fixnum.Int64? sequenceId,
  }) {
    final result = SequenceId._();
    if (sequenceId != null) result.sequenceId = sequenceId;
    return result;
  }

  SequenceId._();

  factory SequenceId.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SequenceId()..mergeFromBuffer(data, registry);
  factory SequenceId.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SequenceId()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SequenceId',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'),
      createEmptyInstance: SequenceId.$_createMessage)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'sequenceId', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SequenceId clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SequenceId copyWith(void Function(SequenceId) updates) =>
      super.copyWith((message) => updates(message as SequenceId)) as SequenceId;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SequenceId() / SequenceId.new instead')
  static SequenceId create() => SequenceId._();
  static $pb.GeneratedMessage $_createMessage() => SequenceId._();
  @$core.override
  SequenceId createEmptyInstance() => SequenceId._();
  @$core.pragma('dart2js:noInline')
  static SequenceId getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SequenceId>(SequenceId.$_createMessage);
  static SequenceId? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get sequenceId => $_getI64(0);
  @$pb.TagNumber(1)
  set sequenceId($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasSequenceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSequenceId() => $_clearField(1);
}

class BlockHeaderInfo extends $pb.GeneratedMessage {
  factory BlockHeaderInfo({
    $core.List<$core.int>? blockHash,
    $core.List<$core.int>? prevBlockHash,
    $core.List<$core.int>? prevMainBlockHash,
    $core.int? height,
  }) {
    final result = BlockHeaderInfo._();
    if (blockHash != null) result.blockHash = blockHash;
    if (prevBlockHash != null) result.prevBlockHash = prevBlockHash;
    if (prevMainBlockHash != null) result.prevMainBlockHash = prevMainBlockHash;
    if (height != null) result.height = height;
    return result;
  }

  BlockHeaderInfo._();

  factory BlockHeaderInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BlockHeaderInfo()..mergeFromBuffer(data, registry);
  factory BlockHeaderInfo.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BlockHeaderInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BlockHeaderInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'),
      createEmptyInstance: BlockHeaderInfo.$_createMessage)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'blockHash', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'prevBlockHash', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'prevMainBlockHash', $pb.PbFieldType.OY)
    ..aI(4, _omitFieldNames ? '' : 'height', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockHeaderInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockHeaderInfo copyWith(void Function(BlockHeaderInfo) updates) =>
      super.copyWith((message) => updates(message as BlockHeaderInfo)) as BlockHeaderInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BlockHeaderInfo() / BlockHeaderInfo.new instead')
  static BlockHeaderInfo create() => BlockHeaderInfo._();
  static $pb.GeneratedMessage $_createMessage() => BlockHeaderInfo._();
  @$core.override
  BlockHeaderInfo createEmptyInstance() => BlockHeaderInfo._();
  @$core.pragma('dart2js:noInline')
  static BlockHeaderInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BlockHeaderInfo>(BlockHeaderInfo.$_createMessage);
  static BlockHeaderInfo? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get blockHash => $_getN(0);
  @$pb.TagNumber(1)
  set blockHash($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBlockHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHash() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get prevBlockHash => $_getN(1);
  @$pb.TagNumber(2)
  set prevBlockHash($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPrevBlockHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrevBlockHash() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get prevMainBlockHash => $_getN(2);
  @$pb.TagNumber(3)
  set prevMainBlockHash($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasPrevMainBlockHash() => $_has(2);
  @$pb.TagNumber(3)
  void clearPrevMainBlockHash() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get height => $_getIZ(3);
  @$pb.TagNumber(4)
  set height($core.int value) => $_setUnsignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasHeight() => $_has(3);
  @$pb.TagNumber(4)
  void clearHeight() => $_clearField(4);
}

class BlockInfo extends $pb.GeneratedMessage {
  factory BlockInfo() => BlockInfo._();

  BlockInfo._();

  factory BlockInfo.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BlockInfo()..mergeFromBuffer(data, registry);
  factory BlockInfo.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BlockInfo()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BlockInfo',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'),
      createEmptyInstance: BlockInfo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockInfo clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BlockInfo copyWith(void Function(BlockInfo) updates) =>
      super.copyWith((message) => updates(message as BlockInfo)) as BlockInfo;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BlockInfo() / BlockInfo.new instead')
  static BlockInfo create() => BlockInfo._();
  static $pb.GeneratedMessage $_createMessage() => BlockInfo._();
  @$core.override
  BlockInfo createEmptyInstance() => BlockInfo._();
  @$core.pragma('dart2js:noInline')
  static BlockInfo getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BlockInfo>(BlockInfo.$_createMessage);
  static BlockInfo? _defaultInstance;
}

class GetMempoolTxsRequest extends $pb.GeneratedMessage {
  factory GetMempoolTxsRequest() => GetMempoolTxsRequest._();

  GetMempoolTxsRequest._();

  factory GetMempoolTxsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetMempoolTxsRequest()..mergeFromBuffer(data, registry);
  factory GetMempoolTxsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetMempoolTxsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetMempoolTxsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'),
      createEmptyInstance: GetMempoolTxsRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMempoolTxsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMempoolTxsRequest copyWith(void Function(GetMempoolTxsRequest) updates) =>
      super.copyWith((message) => updates(message as GetMempoolTxsRequest)) as GetMempoolTxsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetMempoolTxsRequest() / GetMempoolTxsRequest.new instead')
  static GetMempoolTxsRequest create() => GetMempoolTxsRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetMempoolTxsRequest._();
  @$core.override
  GetMempoolTxsRequest createEmptyInstance() => GetMempoolTxsRequest._();
  @$core.pragma('dart2js:noInline')
  static GetMempoolTxsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMempoolTxsRequest>(GetMempoolTxsRequest.$_createMessage);
  static GetMempoolTxsRequest? _defaultInstance;
}

class GetMempoolTxsResponse extends $pb.GeneratedMessage {
  factory GetMempoolTxsResponse({
    SequenceId? sequenceId,
  }) {
    final result = GetMempoolTxsResponse._();
    if (sequenceId != null) result.sequenceId = sequenceId;
    return result;
  }

  GetMempoolTxsResponse._();

  factory GetMempoolTxsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetMempoolTxsResponse()..mergeFromBuffer(data, registry);
  factory GetMempoolTxsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetMempoolTxsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetMempoolTxsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'),
      createEmptyInstance: GetMempoolTxsResponse.$_createMessage)
    ..aOM<SequenceId>(1, _omitFieldNames ? '' : 'sequenceId', subBuilder: SequenceId.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMempoolTxsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetMempoolTxsResponse copyWith(void Function(GetMempoolTxsResponse) updates) =>
      super.copyWith((message) => updates(message as GetMempoolTxsResponse)) as GetMempoolTxsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetMempoolTxsResponse() / GetMempoolTxsResponse.new instead')
  static GetMempoolTxsResponse create() => GetMempoolTxsResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetMempoolTxsResponse._();
  @$core.override
  GetMempoolTxsResponse createEmptyInstance() => GetMempoolTxsResponse._();
  @$core.pragma('dart2js:noInline')
  static GetMempoolTxsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<GetMempoolTxsResponse>(GetMempoolTxsResponse.$_createMessage);
  static GetMempoolTxsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SequenceId get sequenceId => $_getN(0);
  @$pb.TagNumber(1)
  set sequenceId(SequenceId value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSequenceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSequenceId() => $_clearField(1);
  @$pb.TagNumber(1)
  SequenceId ensureSequenceId() => $_ensure(0);
}

class GetUtxosRequest extends $pb.GeneratedMessage {
  factory GetUtxosRequest() => GetUtxosRequest._();

  GetUtxosRequest._();

  factory GetUtxosRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetUtxosRequest()..mergeFromBuffer(data, registry);
  factory GetUtxosRequest.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetUtxosRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetUtxosRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'),
      createEmptyInstance: GetUtxosRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUtxosRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUtxosRequest copyWith(void Function(GetUtxosRequest) updates) =>
      super.copyWith((message) => updates(message as GetUtxosRequest)) as GetUtxosRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetUtxosRequest() / GetUtxosRequest.new instead')
  static GetUtxosRequest create() => GetUtxosRequest._();
  static $pb.GeneratedMessage $_createMessage() => GetUtxosRequest._();
  @$core.override
  GetUtxosRequest createEmptyInstance() => GetUtxosRequest._();
  @$core.pragma('dart2js:noInline')
  static GetUtxosRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetUtxosRequest>(GetUtxosRequest.$_createMessage);
  static GetUtxosRequest? _defaultInstance;
}

class GetUtxosResponse extends $pb.GeneratedMessage {
  factory GetUtxosResponse() => GetUtxosResponse._();

  GetUtxosResponse._();

  factory GetUtxosResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetUtxosResponse()..mergeFromBuffer(data, registry);
  factory GetUtxosResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      GetUtxosResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GetUtxosResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'),
      createEmptyInstance: GetUtxosResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUtxosResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  GetUtxosResponse copyWith(void Function(GetUtxosResponse) updates) =>
      super.copyWith((message) => updates(message as GetUtxosResponse)) as GetUtxosResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use GetUtxosResponse() / GetUtxosResponse.new instead')
  static GetUtxosResponse create() => GetUtxosResponse._();
  static $pb.GeneratedMessage $_createMessage() => GetUtxosResponse._();
  @$core.override
  GetUtxosResponse createEmptyInstance() => GetUtxosResponse._();
  @$core.pragma('dart2js:noInline')
  static GetUtxosResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GetUtxosResponse>(GetUtxosResponse.$_createMessage);
  static GetUtxosResponse? _defaultInstance;
}

class SubmitTransactionRequest extends $pb.GeneratedMessage {
  factory SubmitTransactionRequest({
    $core.List<$core.int>? transaction,
  }) {
    final result = SubmitTransactionRequest._();
    if (transaction != null) result.transaction = transaction;
    return result;
  }

  SubmitTransactionRequest._();

  factory SubmitTransactionRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubmitTransactionRequest()..mergeFromBuffer(data, registry);
  factory SubmitTransactionRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubmitTransactionRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubmitTransactionRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'),
      createEmptyInstance: SubmitTransactionRequest.$_createMessage)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'transaction', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitTransactionRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitTransactionRequest copyWith(void Function(SubmitTransactionRequest) updates) =>
      super.copyWith((message) => updates(message as SubmitTransactionRequest)) as SubmitTransactionRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SubmitTransactionRequest() / SubmitTransactionRequest.new instead')
  static SubmitTransactionRequest create() => SubmitTransactionRequest._();
  static $pb.GeneratedMessage $_createMessage() => SubmitTransactionRequest._();
  @$core.override
  SubmitTransactionRequest createEmptyInstance() => SubmitTransactionRequest._();
  @$core.pragma('dart2js:noInline')
  static SubmitTransactionRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubmitTransactionRequest>(SubmitTransactionRequest.$_createMessage);
  static SubmitTransactionRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get transaction => $_getN(0);
  @$pb.TagNumber(1)
  set transaction($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTransaction() => $_has(0);
  @$pb.TagNumber(1)
  void clearTransaction() => $_clearField(1);
}

class SubmitTransactionResponse extends $pb.GeneratedMessage {
  factory SubmitTransactionResponse() => SubmitTransactionResponse._();

  SubmitTransactionResponse._();

  factory SubmitTransactionResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubmitTransactionResponse()..mergeFromBuffer(data, registry);
  factory SubmitTransactionResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubmitTransactionResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubmitTransactionResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'),
      createEmptyInstance: SubmitTransactionResponse.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitTransactionResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubmitTransactionResponse copyWith(void Function(SubmitTransactionResponse) updates) =>
      super.copyWith((message) => updates(message as SubmitTransactionResponse)) as SubmitTransactionResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SubmitTransactionResponse() / SubmitTransactionResponse.new instead')
  static SubmitTransactionResponse create() => SubmitTransactionResponse._();
  static $pb.GeneratedMessage $_createMessage() => SubmitTransactionResponse._();
  @$core.override
  SubmitTransactionResponse createEmptyInstance() => SubmitTransactionResponse._();
  @$core.pragma('dart2js:noInline')
  static SubmitTransactionResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubmitTransactionResponse>(SubmitTransactionResponse.$_createMessage);
  static SubmitTransactionResponse? _defaultInstance;
}

class SubscribeEventsRequest extends $pb.GeneratedMessage {
  factory SubscribeEventsRequest() => SubscribeEventsRequest._();

  SubscribeEventsRequest._();

  factory SubscribeEventsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscribeEventsRequest()..mergeFromBuffer(data, registry);
  factory SubscribeEventsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscribeEventsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubscribeEventsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'),
      createEmptyInstance: SubscribeEventsRequest.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeEventsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeEventsRequest copyWith(void Function(SubscribeEventsRequest) updates) =>
      super.copyWith((message) => updates(message as SubscribeEventsRequest)) as SubscribeEventsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SubscribeEventsRequest() / SubscribeEventsRequest.new instead')
  static SubscribeEventsRequest create() => SubscribeEventsRequest._();
  static $pb.GeneratedMessage $_createMessage() => SubscribeEventsRequest._();
  @$core.override
  SubscribeEventsRequest createEmptyInstance() => SubscribeEventsRequest._();
  @$core.pragma('dart2js:noInline')
  static SubscribeEventsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubscribeEventsRequest>(SubscribeEventsRequest.$_createMessage);
  static SubscribeEventsRequest? _defaultInstance;
}

class SubscribeEventsResponse_Event_ConnectBlock extends $pb.GeneratedMessage {
  factory SubscribeEventsResponse_Event_ConnectBlock({
    BlockHeaderInfo? headerInfo,
    BlockInfo? blockInfo,
  }) {
    final result = SubscribeEventsResponse_Event_ConnectBlock._();
    if (headerInfo != null) result.headerInfo = headerInfo;
    if (blockInfo != null) result.blockInfo = blockInfo;
    return result;
  }

  SubscribeEventsResponse_Event_ConnectBlock._();

  factory SubscribeEventsResponse_Event_ConnectBlock.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscribeEventsResponse_Event_ConnectBlock()..mergeFromBuffer(data, registry);
  factory SubscribeEventsResponse_Event_ConnectBlock.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscribeEventsResponse_Event_ConnectBlock()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubscribeEventsResponse.Event.ConnectBlock',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'),
      createEmptyInstance: SubscribeEventsResponse_Event_ConnectBlock.$_createMessage)
    ..aOM<BlockHeaderInfo>(1, _omitFieldNames ? '' : 'headerInfo', subBuilder: BlockHeaderInfo.$_createMessage)
    ..aOM<BlockInfo>(2, _omitFieldNames ? '' : 'blockInfo', subBuilder: BlockInfo.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeEventsResponse_Event_ConnectBlock clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeEventsResponse_Event_ConnectBlock copyWith(
          void Function(SubscribeEventsResponse_Event_ConnectBlock) updates) =>
      super.copyWith((message) => updates(message as SubscribeEventsResponse_Event_ConnectBlock))
          as SubscribeEventsResponse_Event_ConnectBlock;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SubscribeEventsResponse_Event_ConnectBlock() / SubscribeEventsResponse_Event_ConnectBlock.new instead')
  static SubscribeEventsResponse_Event_ConnectBlock create() => SubscribeEventsResponse_Event_ConnectBlock._();
  static $pb.GeneratedMessage $_createMessage() => SubscribeEventsResponse_Event_ConnectBlock._();
  @$core.override
  SubscribeEventsResponse_Event_ConnectBlock createEmptyInstance() => SubscribeEventsResponse_Event_ConnectBlock._();
  @$core.pragma('dart2js:noInline')
  static SubscribeEventsResponse_Event_ConnectBlock getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubscribeEventsResponse_Event_ConnectBlock>(
          SubscribeEventsResponse_Event_ConnectBlock.$_createMessage);
  static SubscribeEventsResponse_Event_ConnectBlock? _defaultInstance;

  @$pb.TagNumber(1)
  BlockHeaderInfo get headerInfo => $_getN(0);
  @$pb.TagNumber(1)
  set headerInfo(BlockHeaderInfo value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasHeaderInfo() => $_has(0);
  @$pb.TagNumber(1)
  void clearHeaderInfo() => $_clearField(1);
  @$pb.TagNumber(1)
  BlockHeaderInfo ensureHeaderInfo() => $_ensure(0);

  @$pb.TagNumber(2)
  BlockInfo get blockInfo => $_getN(1);
  @$pb.TagNumber(2)
  set blockInfo(BlockInfo value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasBlockInfo() => $_has(1);
  @$pb.TagNumber(2)
  void clearBlockInfo() => $_clearField(2);
  @$pb.TagNumber(2)
  BlockInfo ensureBlockInfo() => $_ensure(1);
}

class SubscribeEventsResponse_Event_DisconnectBlock extends $pb.GeneratedMessage {
  factory SubscribeEventsResponse_Event_DisconnectBlock({
    $core.List<$core.int>? blockHash,
  }) {
    final result = SubscribeEventsResponse_Event_DisconnectBlock._();
    if (blockHash != null) result.blockHash = blockHash;
    return result;
  }

  SubscribeEventsResponse_Event_DisconnectBlock._();

  factory SubscribeEventsResponse_Event_DisconnectBlock.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscribeEventsResponse_Event_DisconnectBlock()..mergeFromBuffer(data, registry);
  factory SubscribeEventsResponse_Event_DisconnectBlock.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscribeEventsResponse_Event_DisconnectBlock()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubscribeEventsResponse.Event.DisconnectBlock',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'),
      createEmptyInstance: SubscribeEventsResponse_Event_DisconnectBlock.$_createMessage)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'blockHash', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeEventsResponse_Event_DisconnectBlock clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeEventsResponse_Event_DisconnectBlock copyWith(
          void Function(SubscribeEventsResponse_Event_DisconnectBlock) updates) =>
      super.copyWith((message) => updates(message as SubscribeEventsResponse_Event_DisconnectBlock))
          as SubscribeEventsResponse_Event_DisconnectBlock;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SubscribeEventsResponse_Event_DisconnectBlock() / SubscribeEventsResponse_Event_DisconnectBlock.new instead')
  static SubscribeEventsResponse_Event_DisconnectBlock create() => SubscribeEventsResponse_Event_DisconnectBlock._();
  static $pb.GeneratedMessage $_createMessage() => SubscribeEventsResponse_Event_DisconnectBlock._();
  @$core.override
  SubscribeEventsResponse_Event_DisconnectBlock createEmptyInstance() =>
      SubscribeEventsResponse_Event_DisconnectBlock._();
  @$core.pragma('dart2js:noInline')
  static SubscribeEventsResponse_Event_DisconnectBlock getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubscribeEventsResponse_Event_DisconnectBlock>(
          SubscribeEventsResponse_Event_DisconnectBlock.$_createMessage);
  static SubscribeEventsResponse_Event_DisconnectBlock? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get blockHash => $_getN(0);
  @$pb.TagNumber(1)
  set blockHash($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasBlockHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearBlockHash() => $_clearField(1);
}

class SubscribeEventsResponse_Event_MempoolTxAdded extends $pb.GeneratedMessage {
  factory SubscribeEventsResponse_Event_MempoolTxAdded({
    $core.List<$core.int>? txid,
  }) {
    final result = SubscribeEventsResponse_Event_MempoolTxAdded._();
    if (txid != null) result.txid = txid;
    return result;
  }

  SubscribeEventsResponse_Event_MempoolTxAdded._();

  factory SubscribeEventsResponse_Event_MempoolTxAdded.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscribeEventsResponse_Event_MempoolTxAdded()..mergeFromBuffer(data, registry);
  factory SubscribeEventsResponse_Event_MempoolTxAdded.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscribeEventsResponse_Event_MempoolTxAdded()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubscribeEventsResponse.Event.MempoolTxAdded',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'),
      createEmptyInstance: SubscribeEventsResponse_Event_MempoolTxAdded.$_createMessage)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'txid', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeEventsResponse_Event_MempoolTxAdded clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeEventsResponse_Event_MempoolTxAdded copyWith(
          void Function(SubscribeEventsResponse_Event_MempoolTxAdded) updates) =>
      super.copyWith((message) => updates(message as SubscribeEventsResponse_Event_MempoolTxAdded))
          as SubscribeEventsResponse_Event_MempoolTxAdded;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SubscribeEventsResponse_Event_MempoolTxAdded() / SubscribeEventsResponse_Event_MempoolTxAdded.new instead')
  static SubscribeEventsResponse_Event_MempoolTxAdded create() => SubscribeEventsResponse_Event_MempoolTxAdded._();
  static $pb.GeneratedMessage $_createMessage() => SubscribeEventsResponse_Event_MempoolTxAdded._();
  @$core.override
  SubscribeEventsResponse_Event_MempoolTxAdded createEmptyInstance() =>
      SubscribeEventsResponse_Event_MempoolTxAdded._();
  @$core.pragma('dart2js:noInline')
  static SubscribeEventsResponse_Event_MempoolTxAdded getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubscribeEventsResponse_Event_MempoolTxAdded>(
          SubscribeEventsResponse_Event_MempoolTxAdded.$_createMessage);
  static SubscribeEventsResponse_Event_MempoolTxAdded? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get txid => $_getN(0);
  @$pb.TagNumber(1)
  set txid($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class SubscribeEventsResponse_Event_MempoolTxRemoved extends $pb.GeneratedMessage {
  factory SubscribeEventsResponse_Event_MempoolTxRemoved({
    $core.List<$core.int>? txid,
  }) {
    final result = SubscribeEventsResponse_Event_MempoolTxRemoved._();
    if (txid != null) result.txid = txid;
    return result;
  }

  SubscribeEventsResponse_Event_MempoolTxRemoved._();

  factory SubscribeEventsResponse_Event_MempoolTxRemoved.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscribeEventsResponse_Event_MempoolTxRemoved()..mergeFromBuffer(data, registry);
  factory SubscribeEventsResponse_Event_MempoolTxRemoved.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscribeEventsResponse_Event_MempoolTxRemoved()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'SubscribeEventsResponse.Event.MempoolTxRemoved',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'),
      createEmptyInstance: SubscribeEventsResponse_Event_MempoolTxRemoved.$_createMessage)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'txid', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeEventsResponse_Event_MempoolTxRemoved clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeEventsResponse_Event_MempoolTxRemoved copyWith(
          void Function(SubscribeEventsResponse_Event_MempoolTxRemoved) updates) =>
      super.copyWith((message) => updates(message as SubscribeEventsResponse_Event_MempoolTxRemoved))
          as SubscribeEventsResponse_Event_MempoolTxRemoved;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated(
      'Use SubscribeEventsResponse_Event_MempoolTxRemoved() / SubscribeEventsResponse_Event_MempoolTxRemoved.new instead')
  static SubscribeEventsResponse_Event_MempoolTxRemoved create() => SubscribeEventsResponse_Event_MempoolTxRemoved._();
  static $pb.GeneratedMessage $_createMessage() => SubscribeEventsResponse_Event_MempoolTxRemoved._();
  @$core.override
  SubscribeEventsResponse_Event_MempoolTxRemoved createEmptyInstance() =>
      SubscribeEventsResponse_Event_MempoolTxRemoved._();
  @$core.pragma('dart2js:noInline')
  static SubscribeEventsResponse_Event_MempoolTxRemoved getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SubscribeEventsResponse_Event_MempoolTxRemoved>(
          SubscribeEventsResponse_Event_MempoolTxRemoved.$_createMessage);
  static SubscribeEventsResponse_Event_MempoolTxRemoved? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get txid => $_getN(0);
  @$pb.TagNumber(1)
  set txid($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

enum SubscribeEventsResponse_Event_Event { connectBlock, disconnectBlock, mempoolTxAdded, mempoolTxRemoved, notSet }

class SubscribeEventsResponse_Event extends $pb.GeneratedMessage {
  factory SubscribeEventsResponse_Event({
    SubscribeEventsResponse_Event_ConnectBlock? connectBlock,
    SubscribeEventsResponse_Event_DisconnectBlock? disconnectBlock,
    SubscribeEventsResponse_Event_MempoolTxAdded? mempoolTxAdded,
    SubscribeEventsResponse_Event_MempoolTxRemoved? mempoolTxRemoved,
  }) {
    final result = SubscribeEventsResponse_Event._();
    if (connectBlock != null) result.connectBlock = connectBlock;
    if (disconnectBlock != null) result.disconnectBlock = disconnectBlock;
    if (mempoolTxAdded != null) result.mempoolTxAdded = mempoolTxAdded;
    if (mempoolTxRemoved != null) result.mempoolTxRemoved = mempoolTxRemoved;
    return result;
  }

  SubscribeEventsResponse_Event._();

  factory SubscribeEventsResponse_Event.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscribeEventsResponse_Event()..mergeFromBuffer(data, registry);
  factory SubscribeEventsResponse_Event.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscribeEventsResponse_Event()..mergeFromJson(json, registry);

  static const $core.Map<$core.int, SubscribeEventsResponse_Event_Event> _SubscribeEventsResponse_Event_EventByTag = {
    1: SubscribeEventsResponse_Event_Event.connectBlock,
    2: SubscribeEventsResponse_Event_Event.disconnectBlock,
    3: SubscribeEventsResponse_Event_Event.mempoolTxAdded,
    4: SubscribeEventsResponse_Event_Event.mempoolTxRemoved,
    0: SubscribeEventsResponse_Event_Event.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubscribeEventsResponse.Event',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'),
      createEmptyInstance: SubscribeEventsResponse_Event.$_createMessage)
    ..oo(0, [1, 2, 3, 4])
    ..aOM<SubscribeEventsResponse_Event_ConnectBlock>(1, _omitFieldNames ? '' : 'connectBlock',
        subBuilder: SubscribeEventsResponse_Event_ConnectBlock.$_createMessage)
    ..aOM<SubscribeEventsResponse_Event_DisconnectBlock>(2, _omitFieldNames ? '' : 'disconnectBlock',
        subBuilder: SubscribeEventsResponse_Event_DisconnectBlock.$_createMessage)
    ..aOM<SubscribeEventsResponse_Event_MempoolTxAdded>(3, _omitFieldNames ? '' : 'mempoolTxAdded',
        subBuilder: SubscribeEventsResponse_Event_MempoolTxAdded.$_createMessage)
    ..aOM<SubscribeEventsResponse_Event_MempoolTxRemoved>(4, _omitFieldNames ? '' : 'mempoolTxRemoved',
        subBuilder: SubscribeEventsResponse_Event_MempoolTxRemoved.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeEventsResponse_Event clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeEventsResponse_Event copyWith(void Function(SubscribeEventsResponse_Event) updates) =>
      super.copyWith((message) => updates(message as SubscribeEventsResponse_Event)) as SubscribeEventsResponse_Event;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SubscribeEventsResponse_Event() / SubscribeEventsResponse_Event.new instead')
  static SubscribeEventsResponse_Event create() => SubscribeEventsResponse_Event._();
  static $pb.GeneratedMessage $_createMessage() => SubscribeEventsResponse_Event._();
  @$core.override
  SubscribeEventsResponse_Event createEmptyInstance() => SubscribeEventsResponse_Event._();
  @$core.pragma('dart2js:noInline')
  static SubscribeEventsResponse_Event getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubscribeEventsResponse_Event>(SubscribeEventsResponse_Event.$_createMessage);
  static SubscribeEventsResponse_Event? _defaultInstance;

  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  SubscribeEventsResponse_Event_Event whichEvent() => _SubscribeEventsResponse_Event_EventByTag[$_whichOneof(0)]!;
  @$pb.TagNumber(1)
  @$pb.TagNumber(2)
  @$pb.TagNumber(3)
  @$pb.TagNumber(4)
  void clearEvent() => $_clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  SubscribeEventsResponse_Event_ConnectBlock get connectBlock => $_getN(0);
  @$pb.TagNumber(1)
  set connectBlock(SubscribeEventsResponse_Event_ConnectBlock value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasConnectBlock() => $_has(0);
  @$pb.TagNumber(1)
  void clearConnectBlock() => $_clearField(1);
  @$pb.TagNumber(1)
  SubscribeEventsResponse_Event_ConnectBlock ensureConnectBlock() => $_ensure(0);

  @$pb.TagNumber(2)
  SubscribeEventsResponse_Event_DisconnectBlock get disconnectBlock => $_getN(1);
  @$pb.TagNumber(2)
  set disconnectBlock(SubscribeEventsResponse_Event_DisconnectBlock value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasDisconnectBlock() => $_has(1);
  @$pb.TagNumber(2)
  void clearDisconnectBlock() => $_clearField(2);
  @$pb.TagNumber(2)
  SubscribeEventsResponse_Event_DisconnectBlock ensureDisconnectBlock() => $_ensure(1);

  @$pb.TagNumber(3)
  SubscribeEventsResponse_Event_MempoolTxAdded get mempoolTxAdded => $_getN(2);
  @$pb.TagNumber(3)
  set mempoolTxAdded(SubscribeEventsResponse_Event_MempoolTxAdded value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasMempoolTxAdded() => $_has(2);
  @$pb.TagNumber(3)
  void clearMempoolTxAdded() => $_clearField(3);
  @$pb.TagNumber(3)
  SubscribeEventsResponse_Event_MempoolTxAdded ensureMempoolTxAdded() => $_ensure(2);

  @$pb.TagNumber(4)
  SubscribeEventsResponse_Event_MempoolTxRemoved get mempoolTxRemoved => $_getN(3);
  @$pb.TagNumber(4)
  set mempoolTxRemoved(SubscribeEventsResponse_Event_MempoolTxRemoved value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasMempoolTxRemoved() => $_has(3);
  @$pb.TagNumber(4)
  void clearMempoolTxRemoved() => $_clearField(4);
  @$pb.TagNumber(4)
  SubscribeEventsResponse_Event_MempoolTxRemoved ensureMempoolTxRemoved() => $_ensure(3);
}

class SubscribeEventsResponse extends $pb.GeneratedMessage {
  factory SubscribeEventsResponse({
    SequenceId? sequenceId,
    SubscribeEventsResponse_Event? event,
  }) {
    final result = SubscribeEventsResponse._();
    if (sequenceId != null) result.sequenceId = sequenceId;
    if (event != null) result.event = event;
    return result;
  }

  SubscribeEventsResponse._();

  factory SubscribeEventsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscribeEventsResponse()..mergeFromBuffer(data, registry);
  factory SubscribeEventsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      SubscribeEventsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SubscribeEventsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.sidechain.v1'),
      createEmptyInstance: SubscribeEventsResponse.$_createMessage)
    ..aOM<SequenceId>(1, _omitFieldNames ? '' : 'sequenceId', subBuilder: SequenceId.$_createMessage)
    ..aOM<SubscribeEventsResponse_Event>(2, _omitFieldNames ? '' : 'event',
        subBuilder: SubscribeEventsResponse_Event.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeEventsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  SubscribeEventsResponse copyWith(void Function(SubscribeEventsResponse) updates) =>
      super.copyWith((message) => updates(message as SubscribeEventsResponse)) as SubscribeEventsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use SubscribeEventsResponse() / SubscribeEventsResponse.new instead')
  static SubscribeEventsResponse create() => SubscribeEventsResponse._();
  static $pb.GeneratedMessage $_createMessage() => SubscribeEventsResponse._();
  @$core.override
  SubscribeEventsResponse createEmptyInstance() => SubscribeEventsResponse._();
  @$core.pragma('dart2js:noInline')
  static SubscribeEventsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<SubscribeEventsResponse>(SubscribeEventsResponse.$_createMessage);
  static SubscribeEventsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  SequenceId get sequenceId => $_getN(0);
  @$pb.TagNumber(1)
  set sequenceId(SequenceId value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasSequenceId() => $_has(0);
  @$pb.TagNumber(1)
  void clearSequenceId() => $_clearField(1);
  @$pb.TagNumber(1)
  SequenceId ensureSequenceId() => $_ensure(0);

  @$pb.TagNumber(2)
  SubscribeEventsResponse_Event get event => $_getN(1);
  @$pb.TagNumber(2)
  set event(SubscribeEventsResponse_Event value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasEvent() => $_has(1);
  @$pb.TagNumber(2)
  void clearEvent() => $_clearField(2);
  @$pb.TagNumber(2)
  SubscribeEventsResponse_Event ensureEvent() => $_ensure(1);
}

class SidechainServiceApi {
  final $pb.RpcClient _client;

  SidechainServiceApi(this._client);

  $async.Future<GetMempoolTxsResponse> getMempoolTxs($pb.ClientContext? ctx, GetMempoolTxsRequest request) =>
      _client.invoke<GetMempoolTxsResponse>(ctx, 'SidechainService', 'GetMempoolTxs', request, GetMempoolTxsResponse());
  $async.Future<GetUtxosResponse> getUtxos($pb.ClientContext? ctx, GetUtxosRequest request) =>
      _client.invoke<GetUtxosResponse>(ctx, 'SidechainService', 'GetUtxos', request, GetUtxosResponse());
  $async.Future<SubmitTransactionResponse> submitTransaction(
          $pb.ClientContext? ctx, SubmitTransactionRequest request) =>
      _client.invoke<SubmitTransactionResponse>(
          ctx, 'SidechainService', 'SubmitTransaction', request, SubmitTransactionResponse());
  $async.Future<SubscribeEventsResponse> subscribeEvents($pb.ClientContext? ctx, SubscribeEventsRequest request) =>
      _client.invoke<SubscribeEventsResponse>(
          ctx, 'SidechainService', 'SubscribeEvents', request, SubscribeEventsResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
