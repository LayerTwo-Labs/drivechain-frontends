// This is a generated file - do not edit.
//
// Generated from misc/v1/misc.proto.

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

import 'misc.pbenum.dart';

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

export 'misc.pbenum.dart';

class ListOPReturnResponse extends $pb.GeneratedMessage {
  factory ListOPReturnResponse({
    $core.Iterable<OPReturn>? opReturns,
  }) {
    final result = ListOPReturnResponse._();
    if (opReturns != null) result.opReturns.addAll(opReturns);
    return result;
  }

  ListOPReturnResponse._();

  factory ListOPReturnResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListOPReturnResponse()..mergeFromBuffer(data, registry);
  factory ListOPReturnResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListOPReturnResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListOPReturnResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'),
      createEmptyInstance: ListOPReturnResponse.$_createMessage)
    ..pPM<OPReturn>(1, _omitFieldNames ? '' : 'opReturns', subBuilder: OPReturn.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListOPReturnResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListOPReturnResponse copyWith(void Function(ListOPReturnResponse) updates) =>
      super.copyWith((message) => updates(message as ListOPReturnResponse)) as ListOPReturnResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListOPReturnResponse() / ListOPReturnResponse.new instead')
  static ListOPReturnResponse create() => ListOPReturnResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListOPReturnResponse._();
  @$core.override
  ListOPReturnResponse createEmptyInstance() => ListOPReturnResponse._();
  @$core.pragma('dart2js:noInline')
  static ListOPReturnResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListOPReturnResponse>(ListOPReturnResponse.$_createMessage);
  static ListOPReturnResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<OPReturn> get opReturns => $_getList(0);
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
    final result = OPReturn._();
    if (id != null) result.id = id;
    if (message != null) result.message = message;
    if (txid != null) result.txid = txid;
    if (vout != null) result.vout = vout;
    if (height != null) result.height = height;
    if (createTime != null) result.createTime = createTime;
    return result;
  }

  OPReturn._();

  factory OPReturn.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OPReturn()..mergeFromBuffer(data, registry);
  factory OPReturn.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      OPReturn()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OPReturn',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'), createEmptyInstance: OPReturn.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'txid')
    ..aI(4, _omitFieldNames ? '' : 'vout')
    ..aI(5, _omitFieldNames ? '' : 'height')
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'createTime', subBuilder: $0.Timestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OPReturn clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  OPReturn copyWith(void Function(OPReturn) updates) =>
      super.copyWith((message) => updates(message as OPReturn)) as OPReturn;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use OPReturn() / OPReturn.new instead')
  static OPReturn create() => OPReturn._();
  static $pb.GeneratedMessage $_createMessage() => OPReturn._();
  @$core.override
  OPReturn createEmptyInstance() => OPReturn._();
  @$core.pragma('dart2js:noInline')
  static OPReturn getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OPReturn>(OPReturn.$_createMessage);
  static OPReturn? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get txid => $_getSZ(2);
  @$pb.TagNumber(3)
  set txid($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTxid() => $_has(2);
  @$pb.TagNumber(3)
  void clearTxid() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.int get vout => $_getIZ(3);
  @$pb.TagNumber(4)
  set vout($core.int value) => $_setSignedInt32(3, value);
  @$pb.TagNumber(4)
  $core.bool hasVout() => $_has(3);
  @$pb.TagNumber(4)
  void clearVout() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.int get height => $_getIZ(4);
  @$pb.TagNumber(5)
  set height($core.int value) => $_setSignedInt32(4, value);
  @$pb.TagNumber(5)
  $core.bool hasHeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearHeight() => $_clearField(5);

  @$pb.TagNumber(7)
  $0.Timestamp get createTime => $_getN(5);
  @$pb.TagNumber(7)
  set createTime($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasCreateTime() => $_has(5);
  @$pb.TagNumber(7)
  void clearCreateTime() => $_clearField(7);
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
    $core.String? url,
    $core.String? lang,
    $core.int? subtype,
    $core.bool? nsfw,
  }) {
    final result = BroadcastNewsRequest._();
    if (topic != null) result.topic = topic;
    if (headline != null) result.headline = headline;
    if (content != null) result.content = content;
    if (feeSatPerVbyte != null) result.feeSatPerVbyte = feeSatPerVbyte;
    if (feeSats != null) result.feeSats = feeSats;
    if (url != null) result.url = url;
    if (lang != null) result.lang = lang;
    if (subtype != null) result.subtype = subtype;
    if (nsfw != null) result.nsfw = nsfw;
    return result;
  }

  BroadcastNewsRequest._();

  factory BroadcastNewsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BroadcastNewsRequest()..mergeFromBuffer(data, registry);
  factory BroadcastNewsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BroadcastNewsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BroadcastNewsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'),
      createEmptyInstance: BroadcastNewsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'topic')
    ..aOS(2, _omitFieldNames ? '' : 'headline')
    ..aOS(3, _omitFieldNames ? '' : 'content')
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'feeSatPerVbyte', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'feeSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(6, _omitFieldNames ? '' : 'url')
    ..aOS(7, _omitFieldNames ? '' : 'lang')
    ..aI(8, _omitFieldNames ? '' : 'subtype')
    ..aOB(9, _omitFieldNames ? '' : 'nsfw')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BroadcastNewsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BroadcastNewsRequest copyWith(void Function(BroadcastNewsRequest) updates) =>
      super.copyWith((message) => updates(message as BroadcastNewsRequest)) as BroadcastNewsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BroadcastNewsRequest() / BroadcastNewsRequest.new instead')
  static BroadcastNewsRequest create() => BroadcastNewsRequest._();
  static $pb.GeneratedMessage $_createMessage() => BroadcastNewsRequest._();
  @$core.override
  BroadcastNewsRequest createEmptyInstance() => BroadcastNewsRequest._();
  @$core.pragma('dart2js:noInline')
  static BroadcastNewsRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BroadcastNewsRequest>(BroadcastNewsRequest.$_createMessage);
  static BroadcastNewsRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get topic => $_getSZ(0);
  @$pb.TagNumber(1)
  set topic($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTopic() => $_has(0);
  @$pb.TagNumber(1)
  void clearTopic() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get headline => $_getSZ(1);
  @$pb.TagNumber(2)
  set headline($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasHeadline() => $_has(1);
  @$pb.TagNumber(2)
  void clearHeadline() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get content => $_getSZ(2);
  @$pb.TagNumber(3)
  set content($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasContent() => $_has(2);
  @$pb.TagNumber(3)
  void clearContent() => $_clearField(3);

  /// Fee options - exactly one should be set (0 = use Core's estimate)
  @$pb.TagNumber(4)
  $fixnum.Int64 get feeSatPerVbyte => $_getI64(3);
  @$pb.TagNumber(4)
  set feeSatPerVbyte($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasFeeSatPerVbyte() => $_has(3);
  @$pb.TagNumber(4)
  void clearFeeSatPerVbyte() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get feeSats => $_getI64(4);
  @$pb.TagNumber(5)
  set feeSats($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFeeSats() => $_has(4);
  @$pb.TagNumber(5)
  void clearFeeSats() => $_clearField(5);

  /// Optional Story TLVs (spec §6, §10).
  @$pb.TagNumber(6)
  $core.String get url => $_getSZ(5);
  @$pb.TagNumber(6)
  set url($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUrl() => $_has(5);
  @$pb.TagNumber(6)
  void clearUrl() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get lang => $_getSZ(6);
  @$pb.TagNumber(7)
  set lang($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasLang() => $_has(6);
  @$pb.TagNumber(7)
  void clearLang() => $_clearField(7);

  /// 0=link, 1=text, 2=ask, 3=show, 4=poll, 5=job
  @$pb.TagNumber(8)
  $core.int get subtype => $_getIZ(7);
  @$pb.TagNumber(8)
  set subtype($core.int value) => $_setSignedInt32(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSubtype() => $_has(7);
  @$pb.TagNumber(8)
  void clearSubtype() => $_clearField(8);

  @$pb.TagNumber(9)
  $core.bool get nsfw => $_getBF(8);
  @$pb.TagNumber(9)
  set nsfw($core.bool value) => $_setBool(8, value);
  @$pb.TagNumber(9)
  $core.bool hasNsfw() => $_has(8);
  @$pb.TagNumber(9)
  void clearNsfw() => $_clearField(9);
}

class BroadcastNewsResponse extends $pb.GeneratedMessage {
  factory BroadcastNewsResponse({
    $core.String? txid,
  }) {
    final result = BroadcastNewsResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  BroadcastNewsResponse._();

  factory BroadcastNewsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BroadcastNewsResponse()..mergeFromBuffer(data, registry);
  factory BroadcastNewsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      BroadcastNewsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'BroadcastNewsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'),
      createEmptyInstance: BroadcastNewsResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BroadcastNewsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  BroadcastNewsResponse copyWith(void Function(BroadcastNewsResponse) updates) =>
      super.copyWith((message) => updates(message as BroadcastNewsResponse)) as BroadcastNewsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use BroadcastNewsResponse() / BroadcastNewsResponse.new instead')
  static BroadcastNewsResponse create() => BroadcastNewsResponse._();
  static $pb.GeneratedMessage $_createMessage() => BroadcastNewsResponse._();
  @$core.override
  BroadcastNewsResponse createEmptyInstance() => BroadcastNewsResponse._();
  @$core.pragma('dart2js:noInline')
  static BroadcastNewsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<BroadcastNewsResponse>(BroadcastNewsResponse.$_createMessage);
  static BroadcastNewsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class CreateTopicRequest extends $pb.GeneratedMessage {
  factory CreateTopicRequest({
    $core.String? topic,
    $core.String? name,
    $core.int? retentionDays,
  }) {
    final result = CreateTopicRequest._();
    if (topic != null) result.topic = topic;
    if (name != null) result.name = name;
    if (retentionDays != null) result.retentionDays = retentionDays;
    return result;
  }

  CreateTopicRequest._();

  factory CreateTopicRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateTopicRequest()..mergeFromBuffer(data, registry);
  factory CreateTopicRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateTopicRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateTopicRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'),
      createEmptyInstance: CreateTopicRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'topic')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aI(3, _omitFieldNames ? '' : 'retentionDays')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateTopicRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateTopicRequest copyWith(void Function(CreateTopicRequest) updates) =>
      super.copyWith((message) => updates(message as CreateTopicRequest)) as CreateTopicRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateTopicRequest() / CreateTopicRequest.new instead')
  static CreateTopicRequest create() => CreateTopicRequest._();
  static $pb.GeneratedMessage $_createMessage() => CreateTopicRequest._();
  @$core.override
  CreateTopicRequest createEmptyInstance() => CreateTopicRequest._();
  @$core.pragma('dart2js:noInline')
  static CreateTopicRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateTopicRequest>(CreateTopicRequest.$_createMessage);
  static CreateTopicRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get topic => $_getSZ(0);
  @$pb.TagNumber(1)
  set topic($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTopic() => $_has(0);
  @$pb.TagNumber(1)
  void clearTopic() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.int get retentionDays => $_getIZ(2);
  @$pb.TagNumber(3)
  set retentionDays($core.int value) => $_setSignedInt32(2, value);
  @$pb.TagNumber(3)
  $core.bool hasRetentionDays() => $_has(2);
  @$pb.TagNumber(3)
  void clearRetentionDays() => $_clearField(3);
}

class CreateTopicResponse extends $pb.GeneratedMessage {
  factory CreateTopicResponse({
    $core.String? txid,
  }) {
    final result = CreateTopicResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  CreateTopicResponse._();

  factory CreateTopicResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateTopicResponse()..mergeFromBuffer(data, registry);
  factory CreateTopicResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CreateTopicResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CreateTopicResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'),
      createEmptyInstance: CreateTopicResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateTopicResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CreateTopicResponse copyWith(void Function(CreateTopicResponse) updates) =>
      super.copyWith((message) => updates(message as CreateTopicResponse)) as CreateTopicResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CreateTopicResponse() / CreateTopicResponse.new instead')
  static CreateTopicResponse create() => CreateTopicResponse._();
  static $pb.GeneratedMessage $_createMessage() => CreateTopicResponse._();
  @$core.override
  CreateTopicResponse createEmptyInstance() => CreateTopicResponse._();
  @$core.pragma('dart2js:noInline')
  static CreateTopicResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CreateTopicResponse>(CreateTopicResponse.$_createMessage);
  static CreateTopicResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
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
    final result = Topic._();
    if (id != null) result.id = id;
    if (topic != null) result.topic = topic;
    if (name != null) result.name = name;
    if (createTime != null) result.createTime = createTime;
    if (confirmed != null) result.confirmed = confirmed;
    if (txid != null) result.txid = txid;
    if (retentionDays != null) result.retentionDays = retentionDays;
    return result;
  }

  Topic._();

  factory Topic.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Topic()..mergeFromBuffer(data, registry);
  factory Topic.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Topic()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Topic',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'), createEmptyInstance: Topic.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'topic')
    ..aOS(3, _omitFieldNames ? '' : 'name')
    ..aOM<$0.Timestamp>(4, _omitFieldNames ? '' : 'createTime', subBuilder: $0.Timestamp.$_createMessage)
    ..aOB(5, _omitFieldNames ? '' : 'confirmed')
    ..aOS(6, _omitFieldNames ? '' : 'txid')
    ..aI(7, _omitFieldNames ? '' : 'retentionDays')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Topic clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Topic copyWith(void Function(Topic) updates) => super.copyWith((message) => updates(message as Topic)) as Topic;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Topic() / Topic.new instead')
  static Topic create() => Topic._();
  static $pb.GeneratedMessage $_createMessage() => Topic._();
  @$core.override
  Topic createEmptyInstance() => Topic._();
  @$core.pragma('dart2js:noInline')
  static Topic getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Topic>(Topic.$_createMessage);
  static Topic? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get topic => $_getSZ(1);
  @$pb.TagNumber(2)
  set topic($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTopic() => $_has(1);
  @$pb.TagNumber(2)
  void clearTopic() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get name => $_getSZ(2);
  @$pb.TagNumber(3)
  set name($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasName() => $_has(2);
  @$pb.TagNumber(3)
  void clearName() => $_clearField(3);

  @$pb.TagNumber(4)
  $0.Timestamp get createTime => $_getN(3);
  @$pb.TagNumber(4)
  set createTime($0.Timestamp value) => $_setField(4, value);
  @$pb.TagNumber(4)
  $core.bool hasCreateTime() => $_has(3);
  @$pb.TagNumber(4)
  void clearCreateTime() => $_clearField(4);
  @$pb.TagNumber(4)
  $0.Timestamp ensureCreateTime() => $_ensure(3);

  /// Whether the topic creation transaction has been mined
  @$pb.TagNumber(5)
  $core.bool get confirmed => $_getBF(4);
  @$pb.TagNumber(5)
  set confirmed($core.bool value) => $_setBool(4, value);
  @$pb.TagNumber(5)
  $core.bool hasConfirmed() => $_has(4);
  @$pb.TagNumber(5)
  void clearConfirmed() => $_clearField(5);

  /// Transaction ID of the topic creation
  @$pb.TagNumber(6)
  $core.String get txid => $_getSZ(5);
  @$pb.TagNumber(6)
  set txid($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasTxid() => $_has(5);
  @$pb.TagNumber(6)
  void clearTxid() => $_clearField(6);

  /// Retention period for news items (0 = infinite)
  @$pb.TagNumber(7)
  $core.int get retentionDays => $_getIZ(6);
  @$pb.TagNumber(7)
  set retentionDays($core.int value) => $_setSignedInt32(6, value);
  @$pb.TagNumber(7)
  $core.bool hasRetentionDays() => $_has(6);
  @$pb.TagNumber(7)
  void clearRetentionDays() => $_clearField(7);
}

class ListTopicsResponse extends $pb.GeneratedMessage {
  factory ListTopicsResponse({
    $core.Iterable<Topic>? topics,
  }) {
    final result = ListTopicsResponse._();
    if (topics != null) result.topics.addAll(topics);
    return result;
  }

  ListTopicsResponse._();

  factory ListTopicsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListTopicsResponse()..mergeFromBuffer(data, registry);
  factory ListTopicsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListTopicsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListTopicsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'),
      createEmptyInstance: ListTopicsResponse.$_createMessage)
    ..pPM<Topic>(1, _omitFieldNames ? '' : 'topics', subBuilder: Topic.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTopicsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTopicsResponse copyWith(void Function(ListTopicsResponse) updates) =>
      super.copyWith((message) => updates(message as ListTopicsResponse)) as ListTopicsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListTopicsResponse() / ListTopicsResponse.new instead')
  static ListTopicsResponse create() => ListTopicsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListTopicsResponse._();
  @$core.override
  ListTopicsResponse createEmptyInstance() => ListTopicsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListTopicsResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListTopicsResponse>(ListTopicsResponse.$_createMessage);
  static ListTopicsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Topic> get topics => $_getList(0);
}

class EstimateNewsFeeRequest extends $pb.GeneratedMessage {
  factory EstimateNewsFeeRequest({
    NewsAction? action,
    $core.String? body,
    $core.String? headline,
    $core.String? url,
  }) {
    final result = EstimateNewsFeeRequest._();
    if (action != null) result.action = action;
    if (body != null) result.body = body;
    if (headline != null) result.headline = headline;
    if (url != null) result.url = url;
    return result;
  }

  EstimateNewsFeeRequest._();

  factory EstimateNewsFeeRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EstimateNewsFeeRequest()..mergeFromBuffer(data, registry);
  factory EstimateNewsFeeRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EstimateNewsFeeRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EstimateNewsFeeRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'),
      createEmptyInstance: EstimateNewsFeeRequest.$_createMessage)
    ..aE<NewsAction>(1, _omitFieldNames ? '' : 'action', enumValues: NewsAction.values)
    ..aOS(2, _omitFieldNames ? '' : 'body')
    ..aOS(3, _omitFieldNames ? '' : 'headline')
    ..aOS(4, _omitFieldNames ? '' : 'url')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EstimateNewsFeeRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EstimateNewsFeeRequest copyWith(void Function(EstimateNewsFeeRequest) updates) =>
      super.copyWith((message) => updates(message as EstimateNewsFeeRequest)) as EstimateNewsFeeRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EstimateNewsFeeRequest() / EstimateNewsFeeRequest.new instead')
  static EstimateNewsFeeRequest create() => EstimateNewsFeeRequest._();
  static $pb.GeneratedMessage $_createMessage() => EstimateNewsFeeRequest._();
  @$core.override
  EstimateNewsFeeRequest createEmptyInstance() => EstimateNewsFeeRequest._();
  @$core.pragma('dart2js:noInline')
  static EstimateNewsFeeRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EstimateNewsFeeRequest>(EstimateNewsFeeRequest.$_createMessage);
  static EstimateNewsFeeRequest? _defaultInstance;

  @$pb.TagNumber(1)
  NewsAction get action => $_getN(0);
  @$pb.TagNumber(1)
  set action(NewsAction value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasAction() => $_has(0);
  @$pb.TagNumber(1)
  void clearAction() => $_clearField(1);

  /// Text the action carries.
  @$pb.TagNumber(2)
  $core.String get body => $_getSZ(1);
  @$pb.TagNumber(2)
  set body($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBody() => $_has(1);
  @$pb.TagNumber(2)
  void clearBody() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get headline => $_getSZ(2);
  @$pb.TagNumber(3)
  set headline($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHeadline() => $_has(2);
  @$pb.TagNumber(3)
  void clearHeadline() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get url => $_getSZ(3);
  @$pb.TagNumber(4)
  set url($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasUrl() => $_has(3);
  @$pb.TagNumber(4)
  void clearUrl() => $_clearField(4);
}

class EstimateNewsFeeResponse extends $pb.GeneratedMessage {
  factory EstimateNewsFeeResponse({
    $fixnum.Int64? vsize,
    $core.double? feeSatPerVbyte,
    $fixnum.Int64? feeSats,
  }) {
    final result = EstimateNewsFeeResponse._();
    if (vsize != null) result.vsize = vsize;
    if (feeSatPerVbyte != null) result.feeSatPerVbyte = feeSatPerVbyte;
    if (feeSats != null) result.feeSats = feeSats;
    return result;
  }

  EstimateNewsFeeResponse._();

  factory EstimateNewsFeeResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EstimateNewsFeeResponse()..mergeFromBuffer(data, registry);
  factory EstimateNewsFeeResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      EstimateNewsFeeResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EstimateNewsFeeResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'),
      createEmptyInstance: EstimateNewsFeeResponse.$_createMessage)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'vsize', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aD(2, _omitFieldNames ? '' : 'feeSatPerVbyte')
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'feeSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EstimateNewsFeeResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EstimateNewsFeeResponse copyWith(void Function(EstimateNewsFeeResponse) updates) =>
      super.copyWith((message) => updates(message as EstimateNewsFeeResponse)) as EstimateNewsFeeResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use EstimateNewsFeeResponse() / EstimateNewsFeeResponse.new instead')
  static EstimateNewsFeeResponse create() => EstimateNewsFeeResponse._();
  static $pb.GeneratedMessage $_createMessage() => EstimateNewsFeeResponse._();
  @$core.override
  EstimateNewsFeeResponse createEmptyInstance() => EstimateNewsFeeResponse._();
  @$core.pragma('dart2js:noInline')
  static EstimateNewsFeeResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EstimateNewsFeeResponse>(EstimateNewsFeeResponse.$_createMessage);
  static EstimateNewsFeeResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get vsize => $_getI64(0);
  @$pb.TagNumber(1)
  set vsize($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasVsize() => $_has(0);
  @$pb.TagNumber(1)
  void clearVsize() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.double get feeSatPerVbyte => $_getN(1);
  @$pb.TagNumber(2)
  set feeSatPerVbyte($core.double value) => $_setDouble(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFeeSatPerVbyte() => $_has(1);
  @$pb.TagNumber(2)
  void clearFeeSatPerVbyte() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get feeSats => $_getI64(2);
  @$pb.TagNumber(3)
  set feeSats($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFeeSats() => $_has(2);
  @$pb.TagNumber(3)
  void clearFeeSats() => $_clearField(3);
}

class ListCoinNewsRequest extends $pb.GeneratedMessage {
  factory ListCoinNewsRequest({
    $core.String? topic,
  }) {
    final result = ListCoinNewsRequest._();
    if (topic != null) result.topic = topic;
    return result;
  }

  ListCoinNewsRequest._();

  factory ListCoinNewsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListCoinNewsRequest()..mergeFromBuffer(data, registry);
  factory ListCoinNewsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListCoinNewsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListCoinNewsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'),
      createEmptyInstance: ListCoinNewsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'topic')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCoinNewsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCoinNewsRequest copyWith(void Function(ListCoinNewsRequest) updates) =>
      super.copyWith((message) => updates(message as ListCoinNewsRequest)) as ListCoinNewsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListCoinNewsRequest() / ListCoinNewsRequest.new instead')
  static ListCoinNewsRequest create() => ListCoinNewsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListCoinNewsRequest._();
  @$core.override
  ListCoinNewsRequest createEmptyInstance() => ListCoinNewsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListCoinNewsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListCoinNewsRequest>(ListCoinNewsRequest.$_createMessage);
  static ListCoinNewsRequest? _defaultInstance;

  /// if set, only return news for this topic
  @$pb.TagNumber(1)
  $core.String get topic => $_getSZ(0);
  @$pb.TagNumber(1)
  set topic($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTopic() => $_has(0);
  @$pb.TagNumber(1)
  void clearTopic() => $_clearField(1);
}

class CoinNews extends $pb.GeneratedMessage {
  factory CoinNews({
    $fixnum.Int64? id,
    $core.String? topic,
    $core.String? headline,
    $core.String? content,
    $fixnum.Int64? feeSats,
    $0.Timestamp? createTime,
    $core.String? itemId,
    $core.String? url,
    $core.int? subtype,
    $core.bool? nsfw,
    $core.String? txid,
    $core.int? vout,
  }) {
    final result = CoinNews._();
    if (id != null) result.id = id;
    if (topic != null) result.topic = topic;
    if (headline != null) result.headline = headline;
    if (content != null) result.content = content;
    if (feeSats != null) result.feeSats = feeSats;
    if (createTime != null) result.createTime = createTime;
    if (itemId != null) result.itemId = itemId;
    if (url != null) result.url = url;
    if (subtype != null) result.subtype = subtype;
    if (nsfw != null) result.nsfw = nsfw;
    if (txid != null) result.txid = txid;
    if (vout != null) result.vout = vout;
    return result;
  }

  CoinNews._();

  factory CoinNews.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CoinNews()..mergeFromBuffer(data, registry);
  factory CoinNews.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CoinNews()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CoinNews',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'), createEmptyInstance: CoinNews.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'topic')
    ..aOS(3, _omitFieldNames ? '' : 'headline')
    ..aOS(4, _omitFieldNames ? '' : 'content')
    ..aInt64(5, _omitFieldNames ? '' : 'feeSats')
    ..aOM<$0.Timestamp>(6, _omitFieldNames ? '' : 'createTime', subBuilder: $0.Timestamp.$_createMessage)
    ..aOS(7, _omitFieldNames ? '' : 'itemId')
    ..aOS(11, _omitFieldNames ? '' : 'url')
    ..aI(12, _omitFieldNames ? '' : 'subtype')
    ..aOB(13, _omitFieldNames ? '' : 'nsfw')
    ..aOS(14, _omitFieldNames ? '' : 'txid')
    ..aI(15, _omitFieldNames ? '' : 'vout', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CoinNews clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CoinNews copyWith(void Function(CoinNews) updates) =>
      super.copyWith((message) => updates(message as CoinNews)) as CoinNews;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CoinNews() / CoinNews.new instead')
  static CoinNews create() => CoinNews._();
  static $pb.GeneratedMessage $_createMessage() => CoinNews._();
  @$core.override
  CoinNews createEmptyInstance() => CoinNews._();
  @$core.pragma('dart2js:noInline')
  static CoinNews getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CoinNews>(CoinNews.$_createMessage);
  static CoinNews? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get topic => $_getSZ(1);
  @$pb.TagNumber(2)
  set topic($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTopic() => $_has(1);
  @$pb.TagNumber(2)
  void clearTopic() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get headline => $_getSZ(2);
  @$pb.TagNumber(3)
  set headline($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHeadline() => $_has(2);
  @$pb.TagNumber(3)
  void clearHeadline() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get content => $_getSZ(3);
  @$pb.TagNumber(4)
  set content($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasContent() => $_has(3);
  @$pb.TagNumber(4)
  void clearContent() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get feeSats => $_getI64(4);
  @$pb.TagNumber(5)
  set feeSats($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasFeeSats() => $_has(4);
  @$pb.TagNumber(5)
  void clearFeeSats() => $_clearField(5);

  @$pb.TagNumber(6)
  $0.Timestamp get createTime => $_getN(5);
  @$pb.TagNumber(6)
  set createTime($0.Timestamp value) => $_setField(6, value);
  @$pb.TagNumber(6)
  $core.bool hasCreateTime() => $_has(5);
  @$pb.TagNumber(6)
  void clearCreateTime() => $_clearField(6);
  @$pb.TagNumber(6)
  $0.Timestamp ensureCreateTime() => $_ensure(5);

  /// Hex-encoded 12-byte ItemID; the parent for comments.
  @$pb.TagNumber(7)
  $core.String get itemId => $_getSZ(6);
  @$pb.TagNumber(7)
  set itemId($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasItemId() => $_has(6);
  @$pb.TagNumber(7)
  void clearItemId() => $_clearField(7);

  /// Optional Story TLVs (spec §10).
  @$pb.TagNumber(11)
  $core.String get url => $_getSZ(7);
  @$pb.TagNumber(11)
  set url($core.String value) => $_setString(7, value);
  @$pb.TagNumber(11)
  $core.bool hasUrl() => $_has(7);
  @$pb.TagNumber(11)
  void clearUrl() => $_clearField(11);

  /// 0=link, 1=text, 2=ask, 3=show, 4=poll, 5=job
  @$pb.TagNumber(12)
  $core.int get subtype => $_getIZ(8);
  @$pb.TagNumber(12)
  set subtype($core.int value) => $_setSignedInt32(8, value);
  @$pb.TagNumber(12)
  $core.bool hasSubtype() => $_has(8);
  @$pb.TagNumber(12)
  void clearSubtype() => $_clearField(12);

  @$pb.TagNumber(13)
  $core.bool get nsfw => $_getBF(9);
  @$pb.TagNumber(13)
  set nsfw($core.bool value) => $_setBool(9, value);
  @$pb.TagNumber(13)
  $core.bool hasNsfw() => $_has(9);
  @$pb.TagNumber(13)
  void clearNsfw() => $_clearField(13);

  /// Where the item sits on chain. Empty when the source cannot say, in
  /// which case the client hides its explorer link.
  @$pb.TagNumber(14)
  $core.String get txid => $_getSZ(10);
  @$pb.TagNumber(14)
  set txid($core.String value) => $_setString(10, value);
  @$pb.TagNumber(14)
  $core.bool hasTxid() => $_has(10);
  @$pb.TagNumber(14)
  void clearTxid() => $_clearField(14);

  @$pb.TagNumber(15)
  $core.int get vout => $_getIZ(11);
  @$pb.TagNumber(15)
  set vout($core.int value) => $_setUnsignedInt32(11, value);
  @$pb.TagNumber(15)
  $core.bool hasVout() => $_has(11);
  @$pb.TagNumber(15)
  void clearVout() => $_clearField(15);
}

class ListCoinNewsResponse extends $pb.GeneratedMessage {
  factory ListCoinNewsResponse({
    $core.Iterable<CoinNews>? coinNews,
  }) {
    final result = ListCoinNewsResponse._();
    if (coinNews != null) result.coinNews.addAll(coinNews);
    return result;
  }

  ListCoinNewsResponse._();

  factory ListCoinNewsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListCoinNewsResponse()..mergeFromBuffer(data, registry);
  factory ListCoinNewsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListCoinNewsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListCoinNewsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'),
      createEmptyInstance: ListCoinNewsResponse.$_createMessage)
    ..pPM<CoinNews>(1, _omitFieldNames ? '' : 'coinNews', subBuilder: CoinNews.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCoinNewsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCoinNewsResponse copyWith(void Function(ListCoinNewsResponse) updates) =>
      super.copyWith((message) => updates(message as ListCoinNewsResponse)) as ListCoinNewsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListCoinNewsResponse() / ListCoinNewsResponse.new instead')
  static ListCoinNewsResponse create() => ListCoinNewsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListCoinNewsResponse._();
  @$core.override
  ListCoinNewsResponse createEmptyInstance() => ListCoinNewsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListCoinNewsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListCoinNewsResponse>(ListCoinNewsResponse.$_createMessage);
  static ListCoinNewsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<CoinNews> get coinNews => $_getList(0);
}

class CommentNewsRequest extends $pb.GeneratedMessage {
  factory CommentNewsRequest({
    $core.String? parentId,
    $core.String? body,
    $core.String? url,
    $core.String? lang,
    $core.String? replyQuote,
    $fixnum.Int64? feeSatPerVbyte,
    $fixnum.Int64? feeSats,
  }) {
    final result = CommentNewsRequest._();
    if (parentId != null) result.parentId = parentId;
    if (body != null) result.body = body;
    if (url != null) result.url = url;
    if (lang != null) result.lang = lang;
    if (replyQuote != null) result.replyQuote = replyQuote;
    if (feeSatPerVbyte != null) result.feeSatPerVbyte = feeSatPerVbyte;
    if (feeSats != null) result.feeSats = feeSats;
    return result;
  }

  CommentNewsRequest._();

  factory CommentNewsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentNewsRequest()..mergeFromBuffer(data, registry);
  factory CommentNewsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentNewsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CommentNewsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'),
      createEmptyInstance: CommentNewsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'parentId')
    ..aOS(2, _omitFieldNames ? '' : 'body')
    ..aOS(3, _omitFieldNames ? '' : 'url')
    ..aOS(4, _omitFieldNames ? '' : 'lang')
    ..aOS(5, _omitFieldNames ? '' : 'replyQuote')
    ..a<$fixnum.Int64>(6, _omitFieldNames ? '' : 'feeSatPerVbyte', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(7, _omitFieldNames ? '' : 'feeSats', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentNewsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentNewsRequest copyWith(void Function(CommentNewsRequest) updates) =>
      super.copyWith((message) => updates(message as CommentNewsRequest)) as CommentNewsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CommentNewsRequest() / CommentNewsRequest.new instead')
  static CommentNewsRequest create() => CommentNewsRequest._();
  static $pb.GeneratedMessage $_createMessage() => CommentNewsRequest._();
  @$core.override
  CommentNewsRequest createEmptyInstance() => CommentNewsRequest._();
  @$core.pragma('dart2js:noInline')
  static CommentNewsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CommentNewsRequest>(CommentNewsRequest.$_createMessage);
  static CommentNewsRequest? _defaultInstance;

  /// Hex-encoded 12-byte ItemID of the parent (a story or another comment).
  @$pb.TagNumber(1)
  $core.String get parentId => $_getSZ(0);
  @$pb.TagNumber(1)
  set parentId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasParentId() => $_has(0);
  @$pb.TagNumber(1)
  void clearParentId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get body => $_getSZ(1);
  @$pb.TagNumber(2)
  set body($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasBody() => $_has(1);
  @$pb.TagNumber(2)
  void clearBody() => $_clearField(2);

  /// Optional TLVs (spec §10).
  @$pb.TagNumber(3)
  $core.String get url => $_getSZ(2);
  @$pb.TagNumber(3)
  set url($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasUrl() => $_has(2);
  @$pb.TagNumber(3)
  void clearUrl() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get lang => $_getSZ(3);
  @$pb.TagNumber(4)
  set lang($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasLang() => $_has(3);
  @$pb.TagNumber(4)
  void clearLang() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get replyQuote => $_getSZ(4);
  @$pb.TagNumber(5)
  set replyQuote($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasReplyQuote() => $_has(4);
  @$pb.TagNumber(5)
  void clearReplyQuote() => $_clearField(5);

  /// Fee options - exactly one should be set (0 = use Core's estimate)
  @$pb.TagNumber(6)
  $fixnum.Int64 get feeSatPerVbyte => $_getI64(5);
  @$pb.TagNumber(6)
  set feeSatPerVbyte($fixnum.Int64 value) => $_setInt64(5, value);
  @$pb.TagNumber(6)
  $core.bool hasFeeSatPerVbyte() => $_has(5);
  @$pb.TagNumber(6)
  void clearFeeSatPerVbyte() => $_clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get feeSats => $_getI64(6);
  @$pb.TagNumber(7)
  set feeSats($fixnum.Int64 value) => $_setInt64(6, value);
  @$pb.TagNumber(7)
  $core.bool hasFeeSats() => $_has(6);
  @$pb.TagNumber(7)
  void clearFeeSats() => $_clearField(7);
}

class CommentNewsResponse extends $pb.GeneratedMessage {
  factory CommentNewsResponse({
    $core.String? txid,
  }) {
    final result = CommentNewsResponse._();
    if (txid != null) result.txid = txid;
    return result;
  }

  CommentNewsResponse._();

  factory CommentNewsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentNewsResponse()..mergeFromBuffer(data, registry);
  factory CommentNewsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      CommentNewsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'CommentNewsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'),
      createEmptyInstance: CommentNewsResponse.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentNewsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  CommentNewsResponse copyWith(void Function(CommentNewsResponse) updates) =>
      super.copyWith((message) => updates(message as CommentNewsResponse)) as CommentNewsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use CommentNewsResponse() / CommentNewsResponse.new instead')
  static CommentNewsResponse create() => CommentNewsResponse._();
  static $pb.GeneratedMessage $_createMessage() => CommentNewsResponse._();
  @$core.override
  CommentNewsResponse createEmptyInstance() => CommentNewsResponse._();
  @$core.pragma('dart2js:noInline')
  static CommentNewsResponse getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CommentNewsResponse>(CommentNewsResponse.$_createMessage);
  static CommentNewsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get txid => $_getSZ(0);
  @$pb.TagNumber(1)
  set txid($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => $_clearField(1);
}

class ListCommentsRequest extends $pb.GeneratedMessage {
  factory ListCommentsRequest({
    $core.String? itemId,
  }) {
    final result = ListCommentsRequest._();
    if (itemId != null) result.itemId = itemId;
    return result;
  }

  ListCommentsRequest._();

  factory ListCommentsRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListCommentsRequest()..mergeFromBuffer(data, registry);
  factory ListCommentsRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListCommentsRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListCommentsRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'),
      createEmptyInstance: ListCommentsRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'itemId')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCommentsRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCommentsRequest copyWith(void Function(ListCommentsRequest) updates) =>
      super.copyWith((message) => updates(message as ListCommentsRequest)) as ListCommentsRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListCommentsRequest() / ListCommentsRequest.new instead')
  static ListCommentsRequest create() => ListCommentsRequest._();
  static $pb.GeneratedMessage $_createMessage() => ListCommentsRequest._();
  @$core.override
  ListCommentsRequest createEmptyInstance() => ListCommentsRequest._();
  @$core.pragma('dart2js:noInline')
  static ListCommentsRequest getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListCommentsRequest>(ListCommentsRequest.$_createMessage);
  static ListCommentsRequest? _defaultInstance;

  /// Hex-encoded 12-byte ItemID whose reply thread to return.
  @$pb.TagNumber(1)
  $core.String get itemId => $_getSZ(0);
  @$pb.TagNumber(1)
  set itemId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasItemId() => $_has(0);
  @$pb.TagNumber(1)
  void clearItemId() => $_clearField(1);
}

class Comment extends $pb.GeneratedMessage {
  factory Comment({
    $core.String? itemId,
    $core.String? parentId,
    $core.String? author,
    $core.String? body,
    $core.String? url,
    $core.String? lang,
    $core.String? replyQuote,
    $0.Timestamp? createTime,
    $fixnum.Int64? feeSats,
  }) {
    final result = Comment._();
    if (itemId != null) result.itemId = itemId;
    if (parentId != null) result.parentId = parentId;
    if (author != null) result.author = author;
    if (body != null) result.body = body;
    if (url != null) result.url = url;
    if (lang != null) result.lang = lang;
    if (replyQuote != null) result.replyQuote = replyQuote;
    if (createTime != null) result.createTime = createTime;
    if (feeSats != null) result.feeSats = feeSats;
    return result;
  }

  Comment._();

  factory Comment.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Comment()..mergeFromBuffer(data, registry);
  factory Comment.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      Comment()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Comment',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'), createEmptyInstance: Comment.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'itemId')
    ..aOS(2, _omitFieldNames ? '' : 'parentId')
    ..aOS(3, _omitFieldNames ? '' : 'author')
    ..aOS(4, _omitFieldNames ? '' : 'body')
    ..aOS(5, _omitFieldNames ? '' : 'url')
    ..aOS(6, _omitFieldNames ? '' : 'lang')
    ..aOS(7, _omitFieldNames ? '' : 'replyQuote')
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'createTime', subBuilder: $0.Timestamp.$_createMessage)
    ..aInt64(12, _omitFieldNames ? '' : 'feeSats')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Comment clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Comment copyWith(void Function(Comment) updates) =>
      super.copyWith((message) => updates(message as Comment)) as Comment;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use Comment() / Comment.new instead')
  static Comment create() => Comment._();
  static $pb.GeneratedMessage $_createMessage() => Comment._();
  @$core.override
  Comment createEmptyInstance() => Comment._();
  @$core.pragma('dart2js:noInline')
  static Comment getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Comment>(Comment.$_createMessage);
  static Comment? _defaultInstance;

  /// Hex-encoded 12-byte ItemID of this comment.
  @$pb.TagNumber(1)
  $core.String get itemId => $_getSZ(0);
  @$pb.TagNumber(1)
  set itemId($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasItemId() => $_has(0);
  @$pb.TagNumber(1)
  void clearItemId() => $_clearField(1);

  /// Hex-encoded 12-byte ItemID of the parent Item.
  @$pb.TagNumber(2)
  $core.String get parentId => $_getSZ(1);
  @$pb.TagNumber(2)
  set parentId($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasParentId() => $_has(1);
  @$pb.TagNumber(2)
  void clearParentId() => $_clearField(2);

  /// Hex-encoded 32-byte x-only author pubkey (spec §12).
  @$pb.TagNumber(3)
  $core.String get author => $_getSZ(2);
  @$pb.TagNumber(3)
  set author($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAuthor() => $_has(2);
  @$pb.TagNumber(3)
  void clearAuthor() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get body => $_getSZ(3);
  @$pb.TagNumber(4)
  set body($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasBody() => $_has(3);
  @$pb.TagNumber(4)
  void clearBody() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get url => $_getSZ(4);
  @$pb.TagNumber(5)
  set url($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasUrl() => $_has(4);
  @$pb.TagNumber(5)
  void clearUrl() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get lang => $_getSZ(5);
  @$pb.TagNumber(6)
  set lang($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasLang() => $_has(5);
  @$pb.TagNumber(6)
  void clearLang() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.String get replyQuote => $_getSZ(6);
  @$pb.TagNumber(7)
  set replyQuote($core.String value) => $_setString(6, value);
  @$pb.TagNumber(7)
  $core.bool hasReplyQuote() => $_has(6);
  @$pb.TagNumber(7)
  void clearReplyQuote() => $_clearField(7);

  @$pb.TagNumber(8)
  $0.Timestamp get createTime => $_getN(7);
  @$pb.TagNumber(8)
  set createTime($0.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasCreateTime() => $_has(7);
  @$pb.TagNumber(8)
  void clearCreateTime() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureCreateTime() => $_ensure(7);

  /// Fee of the comment's transaction. 0 when unknown.
  @$pb.TagNumber(12)
  $fixnum.Int64 get feeSats => $_getI64(8);
  @$pb.TagNumber(12)
  set feeSats($fixnum.Int64 value) => $_setInt64(8, value);
  @$pb.TagNumber(12)
  $core.bool hasFeeSats() => $_has(8);
  @$pb.TagNumber(12)
  void clearFeeSats() => $_clearField(12);
}

class ListCommentsResponse extends $pb.GeneratedMessage {
  factory ListCommentsResponse({
    $core.Iterable<Comment>? comments,
  }) {
    final result = ListCommentsResponse._();
    if (comments != null) result.comments.addAll(comments);
    return result;
  }

  ListCommentsResponse._();

  factory ListCommentsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListCommentsResponse()..mergeFromBuffer(data, registry);
  factory ListCommentsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListCommentsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListCommentsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'),
      createEmptyInstance: ListCommentsResponse.$_createMessage)
    ..pPM<Comment>(1, _omitFieldNames ? '' : 'comments', subBuilder: Comment.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCommentsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListCommentsResponse copyWith(void Function(ListCommentsResponse) updates) =>
      super.copyWith((message) => updates(message as ListCommentsResponse)) as ListCommentsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListCommentsResponse() / ListCommentsResponse.new instead')
  static ListCommentsResponse create() => ListCommentsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListCommentsResponse._();
  @$core.override
  ListCommentsResponse createEmptyInstance() => ListCommentsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListCommentsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListCommentsResponse>(ListCommentsResponse.$_createMessage);
  static ListCommentsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<Comment> get comments => $_getList(0);
}

/// File timestamp messages
class TimestampFileRequest extends $pb.GeneratedMessage {
  factory TimestampFileRequest({
    $core.String? filename,
    $core.List<$core.int>? fileData,
  }) {
    final result = TimestampFileRequest._();
    if (filename != null) result.filename = filename;
    if (fileData != null) result.fileData = fileData;
    return result;
  }

  TimestampFileRequest._();

  factory TimestampFileRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimestampFileRequest()..mergeFromBuffer(data, registry);
  factory TimestampFileRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimestampFileRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TimestampFileRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'),
      createEmptyInstance: TimestampFileRequest.$_createMessage)
    ..aOS(1, _omitFieldNames ? '' : 'filename')
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'fileData', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimestampFileRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimestampFileRequest copyWith(void Function(TimestampFileRequest) updates) =>
      super.copyWith((message) => updates(message as TimestampFileRequest)) as TimestampFileRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TimestampFileRequest() / TimestampFileRequest.new instead')
  static TimestampFileRequest create() => TimestampFileRequest._();
  static $pb.GeneratedMessage $_createMessage() => TimestampFileRequest._();
  @$core.override
  TimestampFileRequest createEmptyInstance() => TimestampFileRequest._();
  @$core.pragma('dart2js:noInline')
  static TimestampFileRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TimestampFileRequest>(TimestampFileRequest.$_createMessage);
  static TimestampFileRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get filename => $_getSZ(0);
  @$pb.TagNumber(1)
  set filename($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFilename() => $_has(0);
  @$pb.TagNumber(1)
  void clearFilename() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get fileData => $_getN(1);
  @$pb.TagNumber(2)
  set fileData($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFileData() => $_has(1);
  @$pb.TagNumber(2)
  void clearFileData() => $_clearField(2);
}

class TimestampFileResponse extends $pb.GeneratedMessage {
  factory TimestampFileResponse({
    $fixnum.Int64? id,
    $core.String? fileHash,
    $core.String? txid,
  }) {
    final result = TimestampFileResponse._();
    if (id != null) result.id = id;
    if (fileHash != null) result.fileHash = fileHash;
    if (txid != null) result.txid = txid;
    return result;
  }

  TimestampFileResponse._();

  factory TimestampFileResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimestampFileResponse()..mergeFromBuffer(data, registry);
  factory TimestampFileResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      TimestampFileResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TimestampFileResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'),
      createEmptyInstance: TimestampFileResponse.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'fileHash')
    ..aOS(3, _omitFieldNames ? '' : 'txid')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimestampFileResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TimestampFileResponse copyWith(void Function(TimestampFileResponse) updates) =>
      super.copyWith((message) => updates(message as TimestampFileResponse)) as TimestampFileResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use TimestampFileResponse() / TimestampFileResponse.new instead')
  static TimestampFileResponse create() => TimestampFileResponse._();
  static $pb.GeneratedMessage $_createMessage() => TimestampFileResponse._();
  @$core.override
  TimestampFileResponse createEmptyInstance() => TimestampFileResponse._();
  @$core.pragma('dart2js:noInline')
  static TimestampFileResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TimestampFileResponse>(TimestampFileResponse.$_createMessage);
  static TimestampFileResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get fileHash => $_getSZ(1);
  @$pb.TagNumber(2)
  set fileHash($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFileHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearFileHash() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get txid => $_getSZ(2);
  @$pb.TagNumber(3)
  set txid($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTxid() => $_has(2);
  @$pb.TagNumber(3)
  void clearTxid() => $_clearField(3);
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
    final result = FileTimestamp._();
    if (id != null) result.id = id;
    if (filename != null) result.filename = filename;
    if (fileHash != null) result.fileHash = fileHash;
    if (txid != null) result.txid = txid;
    if (blockHeight != null) result.blockHeight = blockHeight;
    if (status != null) result.status = status;
    if (createdAt != null) result.createdAt = createdAt;
    if (confirmedAt != null) result.confirmedAt = confirmedAt;
    if (confirmations != null) result.confirmations = confirmations;
    return result;
  }

  FileTimestamp._();

  factory FileTimestamp.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FileTimestamp()..mergeFromBuffer(data, registry);
  factory FileTimestamp.fromJson($core.String json, [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      FileTimestamp()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'FileTimestamp',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'),
      createEmptyInstance: FileTimestamp.$_createMessage)
    ..aInt64(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'filename')
    ..aOS(3, _omitFieldNames ? '' : 'fileHash')
    ..aOS(4, _omitFieldNames ? '' : 'txid')
    ..aInt64(5, _omitFieldNames ? '' : 'blockHeight')
    ..aOS(6, _omitFieldNames ? '' : 'status')
    ..aOM<$0.Timestamp>(7, _omitFieldNames ? '' : 'createdAt', subBuilder: $0.Timestamp.$_createMessage)
    ..aOM<$0.Timestamp>(8, _omitFieldNames ? '' : 'confirmedAt', subBuilder: $0.Timestamp.$_createMessage)
    ..aI(9, _omitFieldNames ? '' : 'confirmations', fieldType: $pb.PbFieldType.OU3)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileTimestamp clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  FileTimestamp copyWith(void Function(FileTimestamp) updates) =>
      super.copyWith((message) => updates(message as FileTimestamp)) as FileTimestamp;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use FileTimestamp() / FileTimestamp.new instead')
  static FileTimestamp create() => FileTimestamp._();
  static $pb.GeneratedMessage $_createMessage() => FileTimestamp._();
  @$core.override
  FileTimestamp createEmptyInstance() => FileTimestamp._();
  @$core.pragma('dart2js:noInline')
  static FileTimestamp getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<FileTimestamp>(FileTimestamp.$_createMessage);
  static FileTimestamp? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get id => $_getI64(0);
  @$pb.TagNumber(1)
  set id($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get filename => $_getSZ(1);
  @$pb.TagNumber(2)
  set filename($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFilename() => $_has(1);
  @$pb.TagNumber(2)
  void clearFilename() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.String get fileHash => $_getSZ(2);
  @$pb.TagNumber(3)
  set fileHash($core.String value) => $_setString(2, value);
  @$pb.TagNumber(3)
  $core.bool hasFileHash() => $_has(2);
  @$pb.TagNumber(3)
  void clearFileHash() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get txid => $_getSZ(3);
  @$pb.TagNumber(4)
  set txid($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasTxid() => $_has(3);
  @$pb.TagNumber(4)
  void clearTxid() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get blockHeight => $_getI64(4);
  @$pb.TagNumber(5)
  set blockHeight($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasBlockHeight() => $_has(4);
  @$pb.TagNumber(5)
  void clearBlockHeight() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get status => $_getSZ(5);
  @$pb.TagNumber(6)
  set status($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasStatus() => $_has(5);
  @$pb.TagNumber(6)
  void clearStatus() => $_clearField(6);

  @$pb.TagNumber(7)
  $0.Timestamp get createdAt => $_getN(6);
  @$pb.TagNumber(7)
  set createdAt($0.Timestamp value) => $_setField(7, value);
  @$pb.TagNumber(7)
  $core.bool hasCreatedAt() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreatedAt() => $_clearField(7);
  @$pb.TagNumber(7)
  $0.Timestamp ensureCreatedAt() => $_ensure(6);

  @$pb.TagNumber(8)
  $0.Timestamp get confirmedAt => $_getN(7);
  @$pb.TagNumber(8)
  set confirmedAt($0.Timestamp value) => $_setField(8, value);
  @$pb.TagNumber(8)
  $core.bool hasConfirmedAt() => $_has(7);
  @$pb.TagNumber(8)
  void clearConfirmedAt() => $_clearField(8);
  @$pb.TagNumber(8)
  $0.Timestamp ensureConfirmedAt() => $_ensure(7);

  @$pb.TagNumber(9)
  $core.int get confirmations => $_getIZ(8);
  @$pb.TagNumber(9)
  set confirmations($core.int value) => $_setUnsignedInt32(8, value);
  @$pb.TagNumber(9)
  $core.bool hasConfirmations() => $_has(8);
  @$pb.TagNumber(9)
  void clearConfirmations() => $_clearField(9);
}

class ListTimestampsResponse extends $pb.GeneratedMessage {
  factory ListTimestampsResponse({
    $core.Iterable<FileTimestamp>? timestamps,
  }) {
    final result = ListTimestampsResponse._();
    if (timestamps != null) result.timestamps.addAll(timestamps);
    return result;
  }

  ListTimestampsResponse._();

  factory ListTimestampsResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListTimestampsResponse()..mergeFromBuffer(data, registry);
  factory ListTimestampsResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      ListTimestampsResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListTimestampsResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'),
      createEmptyInstance: ListTimestampsResponse.$_createMessage)
    ..pPM<FileTimestamp>(1, _omitFieldNames ? '' : 'timestamps', subBuilder: FileTimestamp.$_createMessage)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTimestampsResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ListTimestampsResponse copyWith(void Function(ListTimestampsResponse) updates) =>
      super.copyWith((message) => updates(message as ListTimestampsResponse)) as ListTimestampsResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use ListTimestampsResponse() / ListTimestampsResponse.new instead')
  static ListTimestampsResponse create() => ListTimestampsResponse._();
  static $pb.GeneratedMessage $_createMessage() => ListTimestampsResponse._();
  @$core.override
  ListTimestampsResponse createEmptyInstance() => ListTimestampsResponse._();
  @$core.pragma('dart2js:noInline')
  static ListTimestampsResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ListTimestampsResponse>(ListTimestampsResponse.$_createMessage);
  static ListTimestampsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<FileTimestamp> get timestamps => $_getList(0);
}

class VerifyTimestampRequest extends $pb.GeneratedMessage {
  factory VerifyTimestampRequest({
    $core.List<$core.int>? fileData,
    $core.String? filename,
  }) {
    final result = VerifyTimestampRequest._();
    if (fileData != null) result.fileData = fileData;
    if (filename != null) result.filename = filename;
    return result;
  }

  VerifyTimestampRequest._();

  factory VerifyTimestampRequest.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VerifyTimestampRequest()..mergeFromBuffer(data, registry);
  factory VerifyTimestampRequest.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VerifyTimestampRequest()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VerifyTimestampRequest',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'),
      createEmptyInstance: VerifyTimestampRequest.$_createMessage)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'fileData', $pb.PbFieldType.OY)
    ..aOS(2, _omitFieldNames ? '' : 'filename')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyTimestampRequest clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyTimestampRequest copyWith(void Function(VerifyTimestampRequest) updates) =>
      super.copyWith((message) => updates(message as VerifyTimestampRequest)) as VerifyTimestampRequest;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use VerifyTimestampRequest() / VerifyTimestampRequest.new instead')
  static VerifyTimestampRequest create() => VerifyTimestampRequest._();
  static $pb.GeneratedMessage $_createMessage() => VerifyTimestampRequest._();
  @$core.override
  VerifyTimestampRequest createEmptyInstance() => VerifyTimestampRequest._();
  @$core.pragma('dart2js:noInline')
  static VerifyTimestampRequest getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VerifyTimestampRequest>(VerifyTimestampRequest.$_createMessage);
  static VerifyTimestampRequest? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get fileData => $_getN(0);
  @$pb.TagNumber(1)
  set fileData($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasFileData() => $_has(0);
  @$pb.TagNumber(1)
  void clearFileData() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get filename => $_getSZ(1);
  @$pb.TagNumber(2)
  set filename($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasFilename() => $_has(1);
  @$pb.TagNumber(2)
  void clearFilename() => $_clearField(2);
}

class VerifyTimestampResponse extends $pb.GeneratedMessage {
  factory VerifyTimestampResponse({
    FileTimestamp? timestamp,
    $core.String? message,
  }) {
    final result = VerifyTimestampResponse._();
    if (timestamp != null) result.timestamp = timestamp;
    if (message != null) result.message = message;
    return result;
  }

  VerifyTimestampResponse._();

  factory VerifyTimestampResponse.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VerifyTimestampResponse()..mergeFromBuffer(data, registry);
  factory VerifyTimestampResponse.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      VerifyTimestampResponse()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'VerifyTimestampResponse',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'misc.v1'),
      createEmptyInstance: VerifyTimestampResponse.$_createMessage)
    ..aOM<FileTimestamp>(1, _omitFieldNames ? '' : 'timestamp', subBuilder: FileTimestamp.$_createMessage)
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyTimestampResponse clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  VerifyTimestampResponse copyWith(void Function(VerifyTimestampResponse) updates) =>
      super.copyWith((message) => updates(message as VerifyTimestampResponse)) as VerifyTimestampResponse;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  @$core.Deprecated('Use VerifyTimestampResponse() / VerifyTimestampResponse.new instead')
  static VerifyTimestampResponse create() => VerifyTimestampResponse._();
  static $pb.GeneratedMessage $_createMessage() => VerifyTimestampResponse._();
  @$core.override
  VerifyTimestampResponse createEmptyInstance() => VerifyTimestampResponse._();
  @$core.pragma('dart2js:noInline')
  static VerifyTimestampResponse getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<VerifyTimestampResponse>(VerifyTimestampResponse.$_createMessage);
  static VerifyTimestampResponse? _defaultInstance;

  @$pb.TagNumber(1)
  FileTimestamp get timestamp => $_getN(0);
  @$pb.TagNumber(1)
  set timestamp(FileTimestamp value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimestamp() => $_clearField(1);
  @$pb.TagNumber(1)
  FileTimestamp ensureTimestamp() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get message => $_getSZ(1);
  @$pb.TagNumber(2)
  set message($core.String value) => $_setString(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearMessage() => $_clearField(2);
}

class MiscServiceApi {
  final $pb.RpcClient _client;

  MiscServiceApi(this._client);

  $async.Future<ListOPReturnResponse> listOPReturn($pb.ClientContext? ctx, $1.Empty request) =>
      _client.invoke<ListOPReturnResponse>(ctx, 'MiscService', 'ListOPReturn', request, ListOPReturnResponse());
  $async.Future<BroadcastNewsResponse> broadcastNews($pb.ClientContext? ctx, BroadcastNewsRequest request) =>
      _client.invoke<BroadcastNewsResponse>(ctx, 'MiscService', 'BroadcastNews', request, BroadcastNewsResponse());
  $async.Future<CreateTopicResponse> createTopic($pb.ClientContext? ctx, CreateTopicRequest request) =>
      _client.invoke<CreateTopicResponse>(ctx, 'MiscService', 'CreateTopic', request, CreateTopicResponse());
  $async.Future<ListTopicsResponse> listTopics($pb.ClientContext? ctx, $1.Empty request) =>
      _client.invoke<ListTopicsResponse>(ctx, 'MiscService', 'ListTopics', request, ListTopicsResponse());
  $async.Future<ListCoinNewsResponse> listCoinNews($pb.ClientContext? ctx, ListCoinNewsRequest request) =>
      _client.invoke<ListCoinNewsResponse>(ctx, 'MiscService', 'ListCoinNews', request, ListCoinNewsResponse());

  /// Broadcasts a signed Comment (CoinNews Comment, 0x03) on an Item.
  $async.Future<CommentNewsResponse> commentNews($pb.ClientContext? ctx, CommentNewsRequest request) =>
      _client.invoke<CommentNewsResponse>(ctx, 'MiscService', 'CommentNews', request, CommentNewsResponse());

  /// Returns the full reply thread rooted at an Item, highest fee first.
  $async.Future<ListCommentsResponse> listComments($pb.ClientContext? ctx, ListCommentsRequest request) =>
      _client.invoke<ListCommentsResponse>(ctx, 'MiscService', 'ListComments', request, ListCommentsResponse());

  /// What a story or comment would cost to broadcast. Builds nothing.
  $async.Future<EstimateNewsFeeResponse> estimateNewsFee($pb.ClientContext? ctx, EstimateNewsFeeRequest request) =>
      _client.invoke<EstimateNewsFeeResponse>(
          ctx, 'MiscService', 'EstimateNewsFee', request, EstimateNewsFeeResponse());

  /// File timestamping
  $async.Future<TimestampFileResponse> timestampFile($pb.ClientContext? ctx, TimestampFileRequest request) =>
      _client.invoke<TimestampFileResponse>(ctx, 'MiscService', 'TimestampFile', request, TimestampFileResponse());
  $async.Future<ListTimestampsResponse> listTimestamps($pb.ClientContext? ctx, $1.Empty request) =>
      _client.invoke<ListTimestampsResponse>(ctx, 'MiscService', 'ListTimestamps', request, ListTimestampsResponse());
  $async.Future<VerifyTimestampResponse> verifyTimestamp($pb.ClientContext? ctx, VerifyTimestampRequest request) =>
      _client.invoke<VerifyTimestampResponse>(
          ctx, 'MiscService', 'VerifyTimestamp', request, VerifyTimestampResponse());
}

const $core.bool _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
