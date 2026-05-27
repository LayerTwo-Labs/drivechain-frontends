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

  @$pb.TagNumber(7)
  $0.Timestamp get createTime => $_getN(5);
  @$pb.TagNumber(7)
  set createTime($0.Timestamp v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasCreateTime() => $_has(5);
  @$pb.TagNumber(7)
  void clearCreateTime() => clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureCreateTime() => $_ensure(5);
}

class BroadcastNewsRequest extends $pb.GeneratedMessage {
  factory BroadcastNewsRequest({
    $core.String? topic,
    $core.String? headline,
    $core.String? content,
    $fixnum.Int64? feeSatPerVbyte,
    $fixnum.Int64? feeSats,
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
    if (feeSatPerVbyte != null) {
      $result.feeSatPerVbyte = feeSatPerVbyte;
    }
    if (feeSats != null) {
      $result.feeSats = feeSats;
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
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'feeSatPerVbyte', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'feeSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
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

  /// Fee options - exactly one should be set (0 = use Core's estimate)
  @$pb.TagNumber(4)
  $fixnum.Int64 get feeSatPerVbyte => $_getI64(3);
  @$pb.TagNumber(4)
  set feeSatPerVbyte($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasFeeSatPerVbyte() => $_has(3);
  @$pb.TagNumber(4)
  void clearFeeSatPerVbyte() => clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get feeSats => $_getI64(4);
  @$pb.TagNumber(5)
  set feeSats($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasFeeSats() => $_has(4);
  @$pb.TagNumber(5)
  void clearFeeSats() => clearField(5);
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
    $core.int? retentionDays,
  }) {
    final $result = create();
    if (topic != null) {
      $result.topic = topic;
    }
    if (name != null) {
      $result.name = name;
    }
    if (retentionDays != null) {
      $result.retentionDays = retentionDays;
    }
    return $result;
  }
  CreateTopicRequest._() : super();
  factory CreateTopicRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CreateTopicRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateTopicRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'topic')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'retentionDays', $pb.PbFieldType.O3)
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

  @$pb.TagNumber(3)
  $core.int get retentionDays => $_getIZ(2);
  @$pb.TagNumber(3)
  set retentionDays($core.int v) { $_setSignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasRetentionDays() => $_has(2);
  @$pb.TagNumber(3)
  void clearRetentionDays() => clearField(3);
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
    $core.bool? confirmed,
    $core.String? txid,
    $core.int? retentionDays,
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
    if (confirmed != null) {
      $result.confirmed = confirmed;
    }
    if (txid != null) {
      $result.txid = txid;
    }
    if (retentionDays != null) {
      $result.retentionDays = retentionDays;
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
    ..aOB(5, _omitFieldNames ? '' : 'confirmed')
    ..aOS(6, _omitFieldNames ? '' : 'txid')
    ..a<$core.int>(7, _omitFieldNames ? '' : 'retentionDays', $pb.PbFieldType.O3)
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

  /// Whether the topic creation transaction has been mined
  @$pb.TagNumber(5)
  $core.bool get confirmed => $_getBF(4);
  @$pb.TagNumber(5)
  set confirmed($core.bool v) { $_setBool(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasConfirmed() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfirmed() => clearField(5);

  /// Transaction ID of the topic creation
  @$pb.TagNumber(6)
  $core.String get txid => $_getSZ(5);
  @$pb.TagNumber(6)
  set txid($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasTxid() => $_has(5);
  @$pb.TagNumber(6)
  void clearTxid() => clearField(6);

  /// Retention period for news items (0 = infinite)
  @$pb.TagNumber(7)
  $core.int get retentionDays => $_getIZ(6);
  @$pb.TagNumber(7)
  set retentionDays($core.int v) { $_setSignedInt32(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasRetentionDays() => $_has(6);
  @$pb.TagNumber(7)
  void clearRetentionDays() => clearField(7);
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

/// File timestamp messages
class TimestampFileRequest extends $pb.GeneratedMessage {
  factory TimestampFileRequest({
    $core.String? filename,
    $core.List<$core.int>? fileData,
  }) {
    final $result = create();
    if (filename != null) {
      $result.filename = filename;
    }
    if (fileData != null) {
      $result.fileData = fileData;
    }
    return $result;
  }
  TimestampFileRequest._() : super();
  factory TimestampFileRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TimestampFileRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TimestampFileRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'filename')
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'fileData', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TimestampFileRequest clone() => TimestampFileRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TimestampFileRequest copyWith(void Function(TimestampFileRequest) updates) => super.copyWith((message) => updates(message as TimestampFileRequest)) as TimestampFileRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TimestampFileRequest create() => TimestampFileRequest._();
  TimestampFileRequest createEmptyInstance() => create();
  static $pb.PbList<TimestampFileRequest> createRepeated() => $pb.PbList<TimestampFileRequest>();
  @$core.pragma('dart2js:noInline')
  static TimestampFileRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TimestampFileRequest>(create);
  static TimestampFileRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get filename => $_getSZ(0);
  @$pb.TagNumber(1)
  set filename($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFilename() => $_has(0);
  @$pb.TagNumber(1)
  void clearFilename() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get fileData => $_getN(1);
  @$pb.TagNumber(2)
  set fileData($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFileData() => $_has(1);
  @$pb.TagNumber(2)
  void clearFileData() => clearField(2);
}

class TimestampFileResponse extends $pb.GeneratedMessage {
  factory TimestampFileResponse({
    $fixnum.Int64? id,
    $core.String? fileHash,
    $core.String? txid,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (fileHash != null) {
      $result.fileHash = fileHash;
    }
    if (txid != null) {
      $result.txid = txid;
    }
    return $result;
  }
  TimestampFileResponse._() : super();
  factory TimestampFileResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TimestampFileResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TimestampFileResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'fileHash')
    ..aOS(3, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TimestampFileResponse clone() => TimestampFileResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TimestampFileResponse copyWith(void Function(TimestampFileResponse) updates) => super.copyWith((message) => updates(message as TimestampFileResponse)) as TimestampFileResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TimestampFileResponse create() => TimestampFileResponse._();
  TimestampFileResponse createEmptyInstance() => create();
  static $pb.PbList<TimestampFileResponse> createRepeated() => $pb.PbList<TimestampFileResponse>();
  @$core.pragma('dart2js:noInline')
  static TimestampFileResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TimestampFileResponse>(create);
  static TimestampFileResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get fileHash => $_getSZ(1);
  @$pb.TagNumber(2)
  set fileHash($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFileHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearFileHash() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get txid => $_getSZ(2);
  @$pb.TagNumber(3)
  set txid($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTxid() => $_has(2);
  @$pb.TagNumber(3)
  void clearTxid() => clearField(3);
}

class FileTimestamp extends $pb.GeneratedMessage {
  factory FileTimestamp({
    $fixnum.Int64? id,
    $core.String? filename,
    $core.String? fileHash,
    $core.String? txid,
    $fixnum.Int64? blockHeight,
    $core.String? status,
    $0.Timestamp? createdAt,
    $0.Timestamp? confirmedAt,
    $core.int? confirmations,
  }) {
    final $result = create();
    if (id != null) {
      $result.id = id;
    }
    if (filename != null) {
      $result.filename = filename;
    }
    if (fileHash != null) {
      $result.fileHash = fileHash;
    }
    if (txid != null) {
      $result.txid = txid;
    }
    if (blockHeight != null) {
      $result.blockHeight = blockHeight;
    }
    if (status != null) {
      $result.status = status;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    if (confirmedAt != null) {
      $result.confirmedAt = confirmedAt;
    }
    if (confirmations != null) {
      $result.confirmations = confirmations;
    }
    return $result;
  }
  FileTimestamp._() : super();
  factory FileTimestamp.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory FileTimestamp.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FileTimestamp', package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'), createEmptyInstance: create)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'filename')
    ..aOS(3, _omitFieldNames ? '' : 'fileHash')
    ..aOS(4, _omitFieldNames ? '' : 'txid')
    ..aInt64(5, _omitFieldNames ? '' : 'blockHeight')
    ..aOS(6, _omitFieldNames ? '' : 'status')
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'createdAt', subBuilder: $0.Timestamp.create)
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'confirmedAt', subBuilder: $0.Timestamp.create)
    ..a<$core.int>(9, _omitFieldNames ? '' : 'confirmations', $pb.PbFieldType.OU3)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  FileTimestamp clone() => FileTimestamp()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  FileTimestamp copyWith(void Function(FileTimestamp) updates) => super.copyWith((message) => updates(message as FileTimestamp)) as FileTimestamp;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static FileTimestamp create() => FileTimestamp._();
  FileTimestamp createEmptyInstance() => create();
  static $pb.PbList<FileTimestamp> createRepeated() => $pb.PbList<FileTimestamp>();
  @$core.pragma('dart2js:noInline')
  static FileTimestamp getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FileTimestamp>(create);
  static FileTimestamp? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get filename => $_getSZ(1);
  @$pb.TagNumber(2)
  set filename($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFilename() => $_has(1);
  @$pb.TagNumber(2)
  void clearFilename() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get fileHash => $_getSZ(2);
  @$pb.TagNumber(3)
  set fileHash($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasFileHash() => $_has(2);
  @$pb.TagNumber(3)
  void clearFileHash() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get txid => $_getSZ(3);
  @$pb.TagNumber(4)
  set txid($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasTxid() => $_has(3);
  @$pb.TagNumber(4)
  void clearTxid() => clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get blockHeight => $_getI64(4);
  @$pb.TagNumber(5)
  set blockHeight($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasBlockHeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearBlockHeight() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get status => $_getSZ(5);
  @$pb.TagNumber(6)
  set status($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => clearField(6);

  @$pb.TagNumber(7)
  $0.Timestamp get createdAt => $_getN(6);
  @$pb.TagNumber(7)
  set createdAt($0.Timestamp v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasCreatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreatedAt() => clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureCreatedAt() => $_ensure(6);

  @$pb.TagNumber(8)
  $0.Timestamp get confirmedAt => $_getN(7);
  @$pb.TagNumber(8)
  set confirmedAt($0.Timestamp v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasConfirmedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearConfirmedAt() => clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureConfirmedAt() => $_ensure(7);

  @$pb.TagNumber(9)
  $core.int get confirmations => $_getIZ(8);
  @$pb.TagNumber(9)
  set confirmations($core.int v) { $_setUnsignedInt32(8, v); }
  @$pb.TagNumber(9)
  $core.bool hasConfirmations() => $_has(8);
  @$pb.TagNumber(9)
  void clearConfirmations() => clearField(9);
}

class ListTimestampsResponse extends $pb.GeneratedMessage {
  factory ListTimestampsResponse({
    $core.Iterable<FileTimestamp>? timestamps,
  }) {
    final $result = create();
    if (timestamps != null) {
      $result.timestamps.addAll(timestamps);
    }
    return $result;
  }
  ListTimestampsResponse._() : super();
  factory ListTimestampsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListTimestampsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListTimestampsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'), createEmptyInstance: create)
    ..pc<FileTimestamp>(1, _omitFieldNames ? '' : 'timestamps', $pb.PbFieldType.PM, subBuilder: FileTimestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListTimestampsResponse clone() => ListTimestampsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListTimestampsResponse copyWith(void Function(ListTimestampsResponse) updates) => super.copyWith((message) => updates(message as ListTimestampsResponse)) as ListTimestampsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListTimestampsResponse create() => ListTimestampsResponse._();
  ListTimestampsResponse createEmptyInstance() => create();
  static $pb.PbList<ListTimestampsResponse> createRepeated() => $pb.PbList<ListTimestampsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListTimestampsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListTimestampsResponse>(create);
  static ListTimestampsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<FileTimestamp> get timestamps => $_getList(0);
}

class VerifyTimestampRequest extends $pb.GeneratedMessage {
  factory VerifyTimestampRequest({
    $core.List<$core.int>? fileData,
    $core.String? filename,
  }) {
    final $result = create();
    if (fileData != null) {
      $result.fileData = fileData;
    }
    if (filename != null) {
      $result.filename = filename;
    }
    return $result;
  }
  VerifyTimestampRequest._() : super();
  factory VerifyTimestampRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VerifyTimestampRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VerifyTimestampRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'fileData', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'filename')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VerifyTimestampRequest clone() => VerifyTimestampRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VerifyTimestampRequest copyWith(void Function(VerifyTimestampRequest) updates) => super.copyWith((message) => updates(message as VerifyTimestampRequest)) as VerifyTimestampRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VerifyTimestampRequest create() => VerifyTimestampRequest._();
  VerifyTimestampRequest createEmptyInstance() => create();
  static $pb.PbList<VerifyTimestampRequest> createRepeated() => $pb.PbList<VerifyTimestampRequest>();
  @$core.pragma('dart2js:noInline')
  static VerifyTimestampRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VerifyTimestampRequest>(create);
  static VerifyTimestampRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get fileData => $_getN(0);
  @$pb.TagNumber(1)
  set fileData($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasFileData() => $_has(0);
  @$pb.TagNumber(1)
  void clearFileData() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get filename => $_getSZ(1);
  @$pb.TagNumber(2)
  set filename($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFilename() => $_has(1);
  @$pb.TagNumber(2)
  void clearFilename() => clearField(2);
}

class VerifyTimestampResponse extends $pb.GeneratedMessage {
  factory VerifyTimestampResponse({
    FileTimestamp? timestamp,
    $core.String? message,
  }) {
    final $result = create();
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    if (message != null) {
      $result.message = message;
    }
    return $result;
  }
  VerifyTimestampResponse._() : super();
  factory VerifyTimestampResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VerifyTimestampResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VerifyTimestampResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'), createEmptyInstance: create)
    ..aOM<FileTimestamp>(1, _omitFieldNames ? '' : 'timestamp', subBuilder: FileTimestamp.create)
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  VerifyTimestampResponse clone() => VerifyTimestampResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  VerifyTimestampResponse copyWith(void Function(VerifyTimestampResponse) updates) => super.copyWith((message) => updates(message as VerifyTimestampResponse)) as VerifyTimestampResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static VerifyTimestampResponse create() => VerifyTimestampResponse._();
  VerifyTimestampResponse createEmptyInstance() => create();
  static $pb.PbList<VerifyTimestampResponse> createRepeated() => $pb.PbList<VerifyTimestampResponse>();
  @$core.pragma('dart2js:noInline')
  static VerifyTimestampResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VerifyTimestampResponse>(create);
  static VerifyTimestampResponse? _defaultInstance;

  @$pb.TagNumber(1)
  FileTimestamp get timestamp => $_getN(0);
  @$pb.TagNumber(1)
  set timestamp(FileTimestamp v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimestamp() => clearField(1);
  @$pb.TagNumber(1)
  FileTimestamp ensureTimestamp() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => clearField(2);
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
  $async.Future<TimestampFileResponse> timestampFile($pb.ClientContext? ctx, TimestampFileRequest request) =>
    _client.invoke<TimestampFileResponse>(ctx, 'MiscService', 'TimestampFile', request, TimestampFileResponse())
  ;
  $async.Future<ListTimestampsResponse> listTimestamps($pb.ClientContext? ctx, $1.Empty request) =>
    _client.invoke<ListTimestampsResponse>(ctx, 'MiscService', 'ListTimestamps', request, ListTimestampsResponse())
  ;
  $async.Future<VerifyTimestampResponse> verifyTimestamp($pb.ClientContext? ctx, VerifyTimestampRequest request) =>
    _client.invoke<VerifyTimestampResponse>(ctx, 'MiscService', 'VerifyTimestamp', request, VerifyTimestampResponse())
  ;
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
