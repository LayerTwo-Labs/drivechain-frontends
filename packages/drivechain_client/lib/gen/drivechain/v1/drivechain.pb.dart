//
//  Generated code. Do not modify.
//  source: drivechain/v1/drivechain.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class ListSidechainsRequest extends $pb.GeneratedMessage {
  factory ListSidechainsRequest() => create();
  ListSidechainsRequest._() : super();
  factory ListSidechainsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListSidechainsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSidechainsRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'), createEmptyInstance: create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListSidechainsRequest clone() => ListSidechainsRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListSidechainsRequest copyWith(void Function(ListSidechainsRequest) updates) => super.copyWith((message) => updates(message as ListSidechainsRequest)) as ListSidechainsRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSidechainsRequest create() => ListSidechainsRequest._();
  ListSidechainsRequest createEmptyInstance() => create();
  static $pb.PbList<ListSidechainsRequest> createRepeated() => $pb.PbList<ListSidechainsRequest>();
  @$core.pragma('dart2js:noInline')
  static ListSidechainsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListSidechainsRequest>(create);
  static ListSidechainsRequest? _defaultInstance;
}

class ListSidechainsResponse_Sidechain extends $pb.GeneratedMessage {
  factory ListSidechainsResponse_Sidechain({
    $core.String? title,
    $core.String? description,
    $core.int? nversion,
    $core.String? hashid1,
    $core.String? hashid2,
    $core.int? slot,
    $fixnum.Int64? amountSatoshi,
    $core.String? chaintipTxid,
  }) {
    final $result = create();
    if (title != null) {
      $result.title = title;
    }
    if (description != null) {
      $result.description = description;
    }
    if (nversion != null) {
      $result.nversion = nversion;
    }
    if (hashid1 != null) {
      $result.hashid1 = hashid1;
    }
    if (hashid2 != null) {
      $result.hashid2 = hashid2;
    }
    if (slot != null) {
      $result.slot = slot;
    }
    if (amountSatoshi != null) {
      $result.amountSatoshi = amountSatoshi;
    }
    if (chaintipTxid != null) {
      $result.chaintipTxid = chaintipTxid;
    }
    return $result;
  }
  ListSidechainsResponse_Sidechain._() : super();
  factory ListSidechainsResponse_Sidechain.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListSidechainsResponse_Sidechain.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSidechainsResponse.Sidechain', package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'title')
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'nversion', $pb.PbFieldType.OU3)
    ..aOS(4, _omitFieldNames ? '' : 'hashid1')
    ..aOS(5, _omitFieldNames ? '' : 'hashid2')
    ..a<$core.int>(6, _omitFieldNames ? '' : 'slot', $pb.PbFieldType.O3)
    ..aInt64(7, _omitFieldNames ? '' : 'amountSatoshi')
    ..aOS(8, _omitFieldNames ? '' : 'chaintipTxid')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListSidechainsResponse_Sidechain clone() => ListSidechainsResponse_Sidechain()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListSidechainsResponse_Sidechain copyWith(void Function(ListSidechainsResponse_Sidechain) updates) => super.copyWith((message) => updates(message as ListSidechainsResponse_Sidechain)) as ListSidechainsResponse_Sidechain;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSidechainsResponse_Sidechain create() => ListSidechainsResponse_Sidechain._();
  ListSidechainsResponse_Sidechain createEmptyInstance() => create();
  static $pb.PbList<ListSidechainsResponse_Sidechain> createRepeated() => $pb.PbList<ListSidechainsResponse_Sidechain>();
  @$core.pragma('dart2js:noInline')
  static ListSidechainsResponse_Sidechain getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListSidechainsResponse_Sidechain>(create);
  static ListSidechainsResponse_Sidechain? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get title => $_getSZ(0);
  @$pb.TagNumber(1)
  set title($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTitle() => $_has(0);
  @$pb.TagNumber(1)
  void clearTitle() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get nversion => $_getIZ(2);
  @$pb.TagNumber(3)
  set nversion($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasNversion() => $_has(2);
  @$pb.TagNumber(3)
  void clearNversion() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get hashid1 => $_getSZ(3);
  @$pb.TagNumber(4)
  set hashid1($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasHashid1() => $_has(3);
  @$pb.TagNumber(4)
  void clearHashid1() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get hashid2 => $_getSZ(4);
  @$pb.TagNumber(5)
  set hashid2($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasHashid2() => $_has(4);
  @$pb.TagNumber(5)
  void clearHashid2() => clearField(5);

  @$pb.TagNumber(6)
  $core.int get slot => $_getIZ(5);
  @$pb.TagNumber(6)
  set slot($core.int v) { $_setSignedInt32(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasSlot() => $_has(5);
  @$pb.TagNumber(6)
  void clearSlot() => clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get amountSatoshi => $_getI64(6);
  @$pb.TagNumber(7)
  set amountSatoshi($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasAmountSatoshi() => $_has(6);
  @$pb.TagNumber(7)
  void clearAmountSatoshi() => clearField(7);

  @$pb.TagNumber(8)
  $core.String get chaintipTxid => $_getSZ(7);
  @$pb.TagNumber(8)
  set chaintipTxid($core.String v) { $_setString(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasChaintipTxid() => $_has(7);
  @$pb.TagNumber(8)
  void clearChaintipTxid() => clearField(8);
}

class ListSidechainsResponse extends $pb.GeneratedMessage {
  factory ListSidechainsResponse({
    $core.Iterable<ListSidechainsResponse_Sidechain>? sidechains,
  }) {
    final $result = create();
    if (sidechains != null) {
      $result.sidechains.addAll(sidechains);
    }
    return $result;
  }
  ListSidechainsResponse._() : super();
  factory ListSidechainsResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ListSidechainsResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ListSidechainsResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'drivechain.v1'), createEmptyInstance: create)
    ..pc<ListSidechainsResponse_Sidechain>(1, _omitFieldNames ? '' : 'sidechains', $pb.PbFieldType.PM, subBuilder: ListSidechainsResponse_Sidechain.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ListSidechainsResponse clone() => ListSidechainsResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ListSidechainsResponse copyWith(void Function(ListSidechainsResponse) updates) => super.copyWith((message) => updates(message as ListSidechainsResponse)) as ListSidechainsResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ListSidechainsResponse create() => ListSidechainsResponse._();
  ListSidechainsResponse createEmptyInstance() => create();
  static $pb.PbList<ListSidechainsResponse> createRepeated() => $pb.PbList<ListSidechainsResponse>();
  @$core.pragma('dart2js:noInline')
  static ListSidechainsResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ListSidechainsResponse>(create);
  static ListSidechainsResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<ListSidechainsResponse_Sidechain> get sidechains => $_getList(0);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
