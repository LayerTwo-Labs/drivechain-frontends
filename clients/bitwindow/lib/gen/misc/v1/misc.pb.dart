//
//  Generated code. Do not modify.
//  source: misc/v1/misc.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import '../../google/protobuf/timestamp.pb.dart' as $5;

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
    $core.String? id,
    $core.String? message,
    $core.String? txid,
    $core.int? vout,
    $core.int? height,
    $fixnum.Int64? feeSatoshi,
    $5.Timestamp? createTime,
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
    if (feeSatoshi != null) {
      $result.feeSatoshi = feeSatoshi;
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
    ..aOS(1, _omitFieldNames ? '' : 'id')
    ..aOS(2, _omitFieldNames ? '' : 'message')
    ..aOS(3, _omitFieldNames ? '' : 'txid')
    ..a<$core.int>(4, _omitFieldNames ? '' : 'vout', $pb.PbFieldType.O3)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'height', $pb.PbFieldType.O3)
    ..aInt64(6, _omitFieldNames ? '' : 'feeSatoshi')
    ..aOM<$5.Timestamp>(7, _omitFieldNames ? '' : 'createTime', subBuilder: $5.Timestamp.create)
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
  $core.String get id => $_getSZ(0);
  @$pb.TagNumber(1)
  set id($core.String v) { $_setString(0, v); }
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
  $fixnum.Int64 get feeSatoshi => $_getI64(5);
  @$pb.TagNumber(6)
  set feeSatoshi($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasFeeSatoshi() => $_has(5);
  @$pb.TagNumber(6)
  void clearFeeSatoshi() => clearField(6);

  @$pb.TagNumber(7)
  $5.Timestamp get createTime => $_getN(6);
  @$pb.TagNumber(7)
  set createTime($5.Timestamp v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasCreateTime() => $_has(6);
  @$pb.TagNumber(7)
  void clearCreateTime() => clearField(7);
  @$pb.TagNumber(7)
  $5.Timestamp ensureCreateTime() => $_ensure(6);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
