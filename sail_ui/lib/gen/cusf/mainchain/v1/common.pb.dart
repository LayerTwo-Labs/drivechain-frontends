//
//  Generated code. Do not modify.
//  source: cusf/mainchain/v1/common.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import '../../../google/protobuf/wrappers.pb.dart' as $0;
import '../../common/v1/common.pb.dart' as $1;

class OutPoint extends $pb.GeneratedMessage {
  factory OutPoint({
    $1.ReverseHex? txid,
    $0.UInt32Value? vout,
  }) {
    final $result = create();
    if (txid != null) {
      $result.txid = txid;
    }
    if (vout != null) {
      $result.vout = vout;
    }
    return $result;
  }
  OutPoint._() : super();
  factory OutPoint.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OutPoint.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'OutPoint', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$1.ReverseHex>(1, _omitFieldNames ? '' : 'txid', subBuilder: $1.ReverseHex.create)
    ..aOM<$0.UInt32Value>(2, _omitFieldNames ? '' : 'vout', subBuilder: $0.UInt32Value.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  OutPoint clone() => OutPoint()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  OutPoint copyWith(void Function(OutPoint) updates) => super.copyWith((message) => updates(message as OutPoint)) as OutPoint;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static OutPoint create() => OutPoint._();
  OutPoint createEmptyInstance() => create();
  static $pb.PbList<OutPoint> createRepeated() => $pb.PbList<OutPoint>();
  @$core.pragma('dart2js:noInline')
  static OutPoint getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OutPoint>(create);
  static OutPoint? _defaultInstance;

  @$pb.TagNumber(1)
  $1.ReverseHex get txid => $_getN(0);
  @$pb.TagNumber(1)
  set txid($1.ReverseHex v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxid() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxid() => clearField(1);
  @$pb.TagNumber(1)
  $1.ReverseHex ensureTxid() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.UInt32Value get vout => $_getN(1);
  @$pb.TagNumber(2)
  set vout($0.UInt32Value v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasVout() => $_has(1);
  @$pb.TagNumber(2)
  void clearVout() => clearField(2);
  @$pb.TagNumber(2)
  $0.UInt32Value ensureVout() => $_ensure(1);
}

class SidechainDeclaration_V0 extends $pb.GeneratedMessage {
  factory SidechainDeclaration_V0({
    $0.StringValue? title,
    $0.StringValue? description,
    $1.ConsensusHex? hashId1,
    $1.Hex? hashId2,
  }) {
    final $result = create();
    if (title != null) {
      $result.title = title;
    }
    if (description != null) {
      $result.description = description;
    }
    if (hashId1 != null) {
      $result.hashId1 = hashId1;
    }
    if (hashId2 != null) {
      $result.hashId2 = hashId2;
    }
    return $result;
  }
  SidechainDeclaration_V0._() : super();
  factory SidechainDeclaration_V0.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SidechainDeclaration_V0.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SidechainDeclaration.V0', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..aOM<$0.StringValue>(1, _omitFieldNames ? '' : 'title', subBuilder: $0.StringValue.create)
    ..aOM<$0.StringValue>(2, _omitFieldNames ? '' : 'description', subBuilder: $0.StringValue.create)
    ..aOM<$1.ConsensusHex>(3, _omitFieldNames ? '' : 'hashId1', protoName: 'hash_id_1', subBuilder: $1.ConsensusHex.create)
    ..aOM<$1.Hex>(4, _omitFieldNames ? '' : 'hashId2', protoName: 'hash_id_2', subBuilder: $1.Hex.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SidechainDeclaration_V0 clone() => SidechainDeclaration_V0()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SidechainDeclaration_V0 copyWith(void Function(SidechainDeclaration_V0) updates) => super.copyWith((message) => updates(message as SidechainDeclaration_V0)) as SidechainDeclaration_V0;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SidechainDeclaration_V0 create() => SidechainDeclaration_V0._();
  SidechainDeclaration_V0 createEmptyInstance() => create();
  static $pb.PbList<SidechainDeclaration_V0> createRepeated() => $pb.PbList<SidechainDeclaration_V0>();
  @$core.pragma('dart2js:noInline')
  static SidechainDeclaration_V0 getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SidechainDeclaration_V0>(create);
  static SidechainDeclaration_V0? _defaultInstance;

  @$pb.TagNumber(1)
  $0.StringValue get title => $_getN(0);
  @$pb.TagNumber(1)
  set title($0.StringValue v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasTitle() => $_has(0);
  @$pb.TagNumber(1)
  void clearTitle() => clearField(1);
  @$pb.TagNumber(1)
  $0.StringValue ensureTitle() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.StringValue get description => $_getN(1);
  @$pb.TagNumber(2)
  set description($0.StringValue v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => clearField(2);
  @$pb.TagNumber(2)
  $0.StringValue ensureDescription() => $_ensure(1);

  @$pb.TagNumber(3)
  $1.ConsensusHex get hashId1 => $_getN(2);
  @$pb.TagNumber(3)
  set hashId1($1.ConsensusHex v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasHashId1() => $_has(2);
  @$pb.TagNumber(3)
  void clearHashId1() => clearField(3);
  @$pb.TagNumber(3)
  $1.ConsensusHex ensureHashId1() => $_ensure(2);

  @$pb.TagNumber(4)
  $1.Hex get hashId2 => $_getN(3);
  @$pb.TagNumber(4)
  set hashId2($1.Hex v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasHashId2() => $_has(3);
  @$pb.TagNumber(4)
  void clearHashId2() => clearField(4);
  @$pb.TagNumber(4)
  $1.Hex ensureHashId2() => $_ensure(3);
}

enum SidechainDeclaration_SidechainDeclaration {
  v0, 
  notSet
}

class SidechainDeclaration extends $pb.GeneratedMessage {
  factory SidechainDeclaration({
    SidechainDeclaration_V0? v0,
  }) {
    final $result = create();
    if (v0 != null) {
      $result.v0 = v0;
    }
    return $result;
  }
  SidechainDeclaration._() : super();
  factory SidechainDeclaration.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SidechainDeclaration.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, SidechainDeclaration_SidechainDeclaration> _SidechainDeclaration_SidechainDeclarationByTag = {
    1 : SidechainDeclaration_SidechainDeclaration.v0,
    0 : SidechainDeclaration_SidechainDeclaration.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SidechainDeclaration', package: const $pb.PackageName(_omitMessageNames ? '' : 'cusf.mainchain.v1'), createEmptyInstance: create)
    ..oo(0, [1])
    ..aOM<SidechainDeclaration_V0>(1, _omitFieldNames ? '' : 'v0', subBuilder: SidechainDeclaration_V0.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SidechainDeclaration clone() => SidechainDeclaration()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SidechainDeclaration copyWith(void Function(SidechainDeclaration) updates) => super.copyWith((message) => updates(message as SidechainDeclaration)) as SidechainDeclaration;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SidechainDeclaration create() => SidechainDeclaration._();
  SidechainDeclaration createEmptyInstance() => create();
  static $pb.PbList<SidechainDeclaration> createRepeated() => $pb.PbList<SidechainDeclaration>();
  @$core.pragma('dart2js:noInline')
  static SidechainDeclaration getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SidechainDeclaration>(create);
  static SidechainDeclaration? _defaultInstance;

  SidechainDeclaration_SidechainDeclaration whichSidechainDeclaration() => _SidechainDeclaration_SidechainDeclarationByTag[$_whichOneof(0)]!;
  void clearSidechainDeclaration() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  SidechainDeclaration_V0 get v0 => $_getN(0);
  @$pb.TagNumber(1)
  set v0(SidechainDeclaration_V0 v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasV0() => $_has(0);
  @$pb.TagNumber(1)
  void clearV0() => clearField(1);
  @$pb.TagNumber(1)
  SidechainDeclaration_V0 ensureV0() => $_ensure(0);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
