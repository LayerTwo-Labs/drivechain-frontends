//
//  Generated code. Do not modify.
//  source: misc/v1/misc.proto
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

class ListOPReturnResponse extends $pb.GeneratedMessage {
  factory ListOPReturnResponse({
    $core.Iterable<OPReturn>? opReturns,
  }) {
    final $result = create();
    if (opReturns != null) {
      $result.opReturns.addAll(opReturns);
    }
    return $result;
  }
  ListOPReturnResponse._() : super();
  factory ListOPReturnResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListOPReturnResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListOPReturnResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'), createEmptyInstance: create)
    ..pc<OPReturn>(1, _omitFieldNames ? '' : 'opReturns', $pb.PbFieldType.PM, subBuilder: OPReturn.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListOPReturnResponse clone() => ListOPReturnResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListOPReturnResponse copyWith(void Function(ListOPReturnResponse) updates) => super.copyWith((message) => updates(message as ListOPReturnResponse)) as ListOPReturnResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListOPReturnResponse create() => ListOPReturnResponse._();
  ListOPReturnResponse createEmptyInstance() => create();
  static $pb.PbList<ListOPReturnResponse> createRepeated() => $pb.PbList<ListOPReturnResponse>();
  @$core.pragma('dart2js:noInline')
  static ListOPReturnResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListOPReturnResponse>(create);
  static ListOPReturnResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<OPReturn> get opReturns => $_getList(0);
}

class OPReturn extends $pb.GeneratedMessage {
  factory OPReturn({
    $fixnum.Int64? id,
    $core.String? message,
    $core.String? txid,
    $core.int? vout,
    $core.int? height,
    $fixnum.Int64? feeSats,
    $0.Timestamp? createTime,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (message != null) {
      $result.message = message;
    }
    if (txid != null) {
      $result.txid = txid;
    }
    if (vout != null) {
      $result.vout = vout;
    }
    if (height != null) {
      $result.height = height;
    }
    if (feeSats != null) {
      $result.feeSats = feeSats;
    }
    if (createTime != null) {
      $result.createTime = createTime;
    }
    return $result;
  }
  OPReturn._() : super();
  factory OPReturn.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OPReturn.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OPReturn', package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'txid')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'vout', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'height', $pb.PbFieldType.O3)
    ..aInt64(6, _omitFieldNames ? '' : 'feeSats')
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'createTime', subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OPReturn clone() => OPReturn()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OPReturn copyWith(void Function(OPReturn) updates) => super.copyWith((message) => updates(message as OPReturn)) as OPReturn;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OPReturn create() => OPReturn._();
  OPReturn createEmptyInstance() => create();
  static $pb.PbList<OPReturn> createRepeated() => $pb.PbList<OPReturn>();
  @$core.pragma('dart2js:noInline')
  static OPReturn getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OPReturn>(create);
  static OPReturn? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get txid => $_getSZ(2);
  @$pb.TagNumber(3)
  set txid($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTxid() => $_has(2);
  @$pb.TagNumber(3)
  void clearTxid() => clearField(3);

  @$pb.TagNumber(4)
  $core.int get vout => $_getIZ(3);
  @$pb.TagNumber(4)
  set vout($core.int v) { $_setSignedInt32(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasVout() => $_has(3);
  @$pb.TagNumber(4)
  void clearVout() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get height => $_getIZ(4);
  @$pb.TagNumber(5)
  set height($core.int v) { $_setSignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasHeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearHeight() => clearField(5);

  @$pb.TagNumber(6)
  $fixnum.Int64 get feeSats => $_getI64(5);
  @$pb.TagNumber(6)
  set feeSats($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasFeeSats() => $_has(5);
  @$pb.TagNumber(6)
  void clearFeeSats() => clearField(6);

  @$pb.TagNumber(7)
  $0.Timestamp get createTime => $_getN(6);
  @$pb.TagNumber(7)
  set createTime($0.Timestamp v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasCreateTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreateTime() => clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureCreateTime() => $_ensure(6);
}

class BroadcastNewsRequest extends $pb.GeneratedMessage {
  factory BroadcastNewsRequest({
    $core.String? topic,
    $core.String? headline,
    $core.String? content,
  }) {
    final $result = create();
    if (topic != null) {
      $result.topic = topic;
    }
    if (headline != null) {
      $result.headline = headline;
    }
    if (content != null) {
      $result.content = content;
    }
    return $result;
  }
  BroadcastNewsRequest._() : super();
  factory BroadcastNewsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BroadcastNewsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BroadcastNewsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'topic')
    ..aOS(2, _omitFieldNames ? '' : 'headline')
    ..aOS(3, _omitFieldNames ? '' : 'content')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BroadcastNewsRequest clone() => BroadcastNewsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BroadcastNewsRequest copyWith(void Function(BroadcastNewsRequest) updates) => super.copyWith((message) => updates(message as BroadcastNewsRequest)) as BroadcastNewsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BroadcastNewsRequest create() => BroadcastNewsRequest._();
  BroadcastNewsRequest createEmptyInstance() => create();
  static $pb.PbList<BroadcastNewsRequest> createRepeated() => $pb.PbList<BroadcastNewsRequest>();
  @$core.pragma('dart2js:noInline')
  static BroadcastNewsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BroadcastNewsRequest>(create);
  static BroadcastNewsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get topic => $_getSZ(0);
  @$pb.TagNumber(1)
  set topic($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTopic() => $_has(0);
  @$pb.TagNumber(1)
  void clearTopic() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get headline => $_getSZ(1);
  @$pb.TagNumber(2)
  set headline($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHeadline() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeadline() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get content => $_getSZ(2);
  @$pb.TagNumber(3)
  set content($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasContent() => $_has(2);
  @$pb.TagNumber(3)
  void clearContent() => clearField(3);
}

class BroadcastNewsResponse extends $pb.GeneratedMessage {
  factory BroadcastNewsResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  BroadcastNewsResponse._() : super();
  factory BroadcastNewsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory BroadcastNewsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BroadcastNewsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  BroadcastNewsResponse clone() => BroadcastNewsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  BroadcastNewsResponse copyWith(void Function(BroadcastNewsResponse) updates) => super.copyWith((message) => updates(message as BroadcastNewsResponse)) as BroadcastNewsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static BroadcastNewsResponse create() => BroadcastNewsResponse._();
  BroadcastNewsResponse createEmptyInstance() => create();
  static $pb.PbList<BroadcastNewsResponse> createRepeated() => $pb.PbList<BroadcastNewsResponse>();
  @$core.pragma('dart2js:noInline')
  static BroadcastNewsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<BroadcastNewsResponse>(create);
  static BroadcastNewsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class CreateTopicRequest extends $pb.GeneratedMessage {
  factory CreateTopicRequest({
    $core.String? topic,
    $core.String? name,
  }) {
    final $result = create();
    if (topic != null) {
      $result.topic = topic;
    }
    if (name != null) {
      $result.name = name;
    }
    return $result;
  }
  CreateTopicRequest._() : super();
  factory CreateTopicRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateTopicRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateTopicRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'topic')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateTopicRequest clone() => CreateTopicRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateTopicRequest copyWith(void Function(CreateTopicRequest) updates) => super.copyWith((message) => updates(message as CreateTopicRequest)) as CreateTopicRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateTopicRequest create() => CreateTopicRequest._();
  CreateTopicRequest createEmptyInstance() => create();
  static $pb.PbList<CreateTopicRequest> createRepeated() => $pb.PbList<CreateTopicRequest>();
  @$core.pragma('dart2js:noInline')
  static CreateTopicRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateTopicRequest>(create);
  static CreateTopicRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get topic => $_getSZ(0);
  @$pb.TagNumber(1)
  set topic($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTopic() => $_has(0);
  @$pb.TagNumber(1)
  void clearTopic() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);
}

class CreateTopicResponse extends $pb.GeneratedMessage {
  factory CreateTopicResponse({
    $core.String? txid,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  CreateTopicResponse._() : super();
  factory CreateTopicResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateTopicResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateTopicResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CreateTopicResponse clone() => CreateTopicResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CreateTopicResponse copyWith(void Function(CreateTopicResponse) updates) => super.copyWith((message) => updates(message as CreateTopicResponse)) as CreateTopicResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CreateTopicResponse create() => CreateTopicResponse._();
  CreateTopicResponse createEmptyInstance() => create();
  static $pb.PbList<CreateTopicResponse> createRepeated() => $pb.PbList<CreateTopicResponse>();
  @$core.pragma('dart2js:noInline')
  static CreateTopicResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateTopicResponse>(create);
  static CreateTopicResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
}

class Topic extends $pb.GeneratedMessage {
  factory Topic({
    $fixnum.Int64? id,
    $core.String? topic,
    $core.String? name,
    $0.Timestamp? createTime,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (topic != null) {
      $result.topic = topic;
    }
    if (name != null) {
      $result.name = name;
    }
    if (createTime != null) {
      $result.createTime = createTime;
    }
    return $result;
  }
  Topic._() : super();
  factory Topic.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Topic.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Topic', package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'topic')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'createTime', subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Topic clone() => Topic()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Topic copyWith(void Function(Topic) updates) => super.copyWith((message) => updates(message as Topic)) as Topic;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Topic create() => Topic._();
  Topic createEmptyInstance() => create();
  static $pb.PbList<Topic> createRepeated() => $pb.PbList<Topic>();
  @$core.pragma('dart2js:noInline')
  static Topic getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Topic>(create);
  static Topic? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get topic => $_getSZ(1);
  @$pb.TagNumber(2)
  set topic($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTopic() => $_has(1);
  @$pb.TagNumber(2)
  void clearTopic() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => clearField(3);

  @$pb.TagNumber(4)
  $0.Timestamp get createTime => $_getN(3);
  @$pb.TagNumber(4)
  set createTime($0.Timestamp v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasCreateTime() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreateTime() => clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureCreateTime() => $_ensure(3);
}

class ListTopicsResponse extends $pb.GeneratedMessage {
  factory ListTopicsResponse({
    $core.Iterable<Topic>? topics,
  }) {
    final $result = create();
    if (topics != null) {
      $result.topics.addAll(topics);
    }
    return $result;
  }
  ListTopicsResponse._() : super();
  factory ListTopicsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListTopicsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListTopicsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'), createEmptyInstance: create)
    ..pc<Topic>(1, _omitFieldNames ? '' : 'topics', $pb.PbFieldType.PM, subBuilder: Topic.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListTopicsResponse clone() => ListTopicsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListTopicsResponse copyWith(void Function(ListTopicsResponse) updates) => super.copyWith((message) => updates(message as ListTopicsResponse)) as ListTopicsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTopicsResponse create() => ListTopicsResponse._();
  ListTopicsResponse createEmptyInstance() => create();
  static $pb.PbList<ListTopicsResponse> createRepeated() => $pb.PbList<ListTopicsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListTopicsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListTopicsResponse>(create);
  static ListTopicsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<Topic> get topics => $_getList(0);
}

class ListCoinNewsRequest extends $pb.GeneratedMessage {
  factory ListCoinNewsRequest({
    $core.String? topic,
  }) {
    final $result = create();
    if (topic != null) {
      $result.topic = topic;
    }
    return $result;
  }
  ListCoinNewsRequest._() : super();
  factory ListCoinNewsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListCoinNewsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListCoinNewsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'topic')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListCoinNewsRequest clone() => ListCoinNewsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListCoinNewsRequest copyWith(void Function(ListCoinNewsRequest) updates) => super.copyWith((message) => updates(message as ListCoinNewsRequest)) as ListCoinNewsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListCoinNewsRequest create() => ListCoinNewsRequest._();
  ListCoinNewsRequest createEmptyInstance() => create();
  static $pb.PbList<ListCoinNewsRequest> createRepeated() => $pb.PbList<ListCoinNewsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListCoinNewsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListCoinNewsRequest>(create);
  static ListCoinNewsRequest? _defaultInstance;

  /// if set, only return news for this topic
  @$pb.TagNumber(1)
  $core.String get topic => $_getSZ(0);
  @$pb.TagNumber(1)
  set topic($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTopic() => $_has(0);
  @$pb.TagNumber(1)
  void clearTopic() => clearField(1);
}

class CoinNews extends $pb.GeneratedMessage {
  factory CoinNews({
    $fixnum.Int64? id,
    $core.String? topic,
    $core.String? headline,
    $core.String? content,
    $fixnum.Int64? feeSats,
    $0.Timestamp? createTime,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (topic != null) {
      $result.topic = topic;
    }
    if (headline != null) {
      $result.headline = headline;
    }
    if (content != null) {
      $result.content = content;
    }
    if (feeSats != null) {
      $result.feeSats = feeSats;
    }
    if (createTime != null) {
      $result.createTime = createTime;
    }
    return $result;
  }
  CoinNews._() : super();
  factory CoinNews.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CoinNews.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CoinNews', package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'topic')
    ..aOS(3, _omitFieldNames ? '' : 'headline')
    ..aOS(4, _omitFieldNames ? '' : 'content')
    ..aInt64(5, _omitFieldNames ? '' : 'feeSats')
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'createTime', subBuilder: $0.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  CoinNews clone() => CoinNews()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  CoinNews copyWith(void Function(CoinNews) updates) => super.copyWith((message) => updates(message as CoinNews)) as CoinNews;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static CoinNews create() => CoinNews._();
  CoinNews createEmptyInstance() => create();
  static $pb.PbList<CoinNews> createRepeated() => $pb.PbList<CoinNews>();
  @$core.pragma('dart2js:noInline')
  static CoinNews getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CoinNews>(create);
  static CoinNews? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get topic => $_getSZ(1);
  @$pb.TagNumber(2)
  set topic($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTopic() => $_has(1);
  @$pb.TagNumber(2)
  void clearTopic() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get headline => $_getSZ(2);
  @$pb.TagNumber(3)
  set headline($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasHeadline() => $_has(2);
  @$pb.TagNumber(3)
  void clearHeadline() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get content => $_getSZ(3);
  @$pb.TagNumber(4)
  set content($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasContent() => $_has(3);
  @$pb.TagNumber(4)
  void clearContent() => clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get feeSats => $_getI64(4);
  @$pb.TagNumber(5)
  set feeSats($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasFeeSats() => $_has(4);
  @$pb.TagNumber(5)
  void clearFeeSats() => clearField(5);

  @$pb.TagNumber(6)
  $0.Timestamp get createTime => $_getN(5);
  @$pb.TagNumber(6)
  set createTime($0.Timestamp v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasCreateTime() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreateTime() => clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureCreateTime() => $_ensure(5);
}

class ListCoinNewsResponse extends $pb.GeneratedMessage {
  factory ListCoinNewsResponse({
    $core.Iterable<CoinNews>? coinNews,
  }) {
    final $result = create();
    if (coinNews != null) {
      $result.coinNews.addAll(coinNews);
    }
    return $result;
  }
  ListCoinNewsResponse._() : super();
  factory ListCoinNewsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListCoinNewsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListCoinNewsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'), createEmptyInstance: create)
    ..pc<CoinNews>(1, _omitFieldNames ? '' : 'coinNews', $pb.PbFieldType.PM, subBuilder: CoinNews.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListCoinNewsResponse clone() => ListCoinNewsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListCoinNewsResponse copyWith(void Function(ListCoinNewsResponse) updates) => super.copyWith((message) => updates(message as ListCoinNewsResponse)) as ListCoinNewsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListCoinNewsResponse create() => ListCoinNewsResponse._();
  ListCoinNewsResponse createEmptyInstance() => create();
  static $pb.PbList<ListCoinNewsResponse> createRepeated() => $pb.PbList<ListCoinNewsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListCoinNewsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListCoinNewsResponse>(create);
  static ListCoinNewsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<CoinNews> get coinNews => $_getList(0);
}

class MiscServiceApi {
  $pb.RpcClient _client;
  MiscServiceApi(this._client);

  $async.Future<ListOPReturnResponse> listOPReturn($pb.ClientContext? ctx, $1.Empty request) =>
    _client.invoke<ListOPReturnResponse>(ctx, 'MiscService', 'ListOPReturn', request, ListOPReturnResponse())
  ;
  $async.Future<BroadcastNewsResponse> broadcastNews($pb.ClientContext? ctx, BroadcastNewsRequest request) =>
    _client.invoke<BroadcastNewsResponse>(ctx, 'MiscService', 'BroadcastNews', request, BroadcastNewsResponse())
  ;
  $async.Future<CreateTopicResponse> createTopic($pb.ClientContext? ctx, CreateTopicRequest request) =>
    _client.invoke<CreateTopicResponse>(ctx, 'MiscService', 'CreateTopic', request, CreateTopicResponse())
  ;
  $async.Future<ListTopicsResponse> listTopics($pb.ClientContext? ctx, $1.Empty request) =>
    _client.invoke<ListTopicsResponse>(ctx, 'MiscService', 'ListTopics', request, ListTopicsResponse())
  ;
  $async.Future<ListCoinNewsResponse> listCoinNews($pb.ClientContext? ctx, ListCoinNewsRequest request) =>
    _client.invoke<ListCoinNewsResponse>(ctx, 'MiscService', 'ListCoinNews', request, ListCoinNewsResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
